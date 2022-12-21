/**************************************************************************************************
* Name: RE_CND_StartCalculatingDepoPricingQueue
* Object: RE_Market_Quotes__c, RE_MOA__c, RE_MY_CostPrice__c, RE_Depot_Pricing_Backbone__c
* Purpose: Execute Depo Pricing for Revolution Canada
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-05-11
* Modify History: 
* 2022-05-11		Abhilash		Created
**************************************************************************************************/
public class RE_CND_StartCalculatingDepoPricingQueue implements Queueable {

    private DateTime requestdDate;
    private date request_Date;
    private date effectiveFromDate;
    private date effectiveToDate;
    private Id jobRunAudId;
    private Map<String,Decimal> latestNtMveGasoline;
    private Map<String,Decimal> latestNtMveDiesel;
    public static Boolean IsSuccessJobAudit = true; 
    
    public RE_CND_StartCalculatingDepoPricingQueue(DateTime requestdDate, date request_Date, date effectiveFromDate, date effectiveToDate, Id jobRunAudId, Map<String,Decimal> latestNtMveGasoline, Map<String,Decimal> latestNtMveDiesel)
    {
        this.requestdDate = requestdDate;
        this.request_Date = request_Date;
        this.effectiveFromDate = effectiveFromDate;
        this.effectiveToDate = effectiveToDate;
        this.jobRunAudId = jobRunAudId;
        this.latestNtMveGasoline = latestNtMveGasoline;
        this.latestNtMveDiesel = latestNtMveDiesel;
    }
    
    public void execute(QueueableContext context) 
    {
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit = [SELECT Id, RE_Job_Status__c, RE_Exception__c, Other_Comments__c FROM RE_Job_Run_Audit__c WHERE Id =: jobRunAudId];
        
        try
        {        
            List<RE_MOA__c> updatedMOA = New List<RE_MOA__c>();   
            List<RT_Setting__c> cndActivePricngDiff = new List<RT_Setting__c>();
            List<RE_Depot_Pricing_Backbone__c> unbrandedExecutePriceBaseProduct  = new List<RE_Depot_Pricing_Backbone__c>();      
            List<RE_Depot_Pricing_Backbone__c> unbrandedAndBrandedDerivedProduct = new List<RE_Depot_Pricing_Backbone__c>();          
            Map<String,RE_MY_CostPrice__c> prevDayCostPrice = new Map<String,RE_MY_CostPrice__c>();
            List<RE_MY_CostPrice__c> currentCostPriceList = new List<RE_MY_CostPrice__c>();            
            Map<String,Decimal> currentNtMveGasoline = new Map<String,Decimal>();
            Map<String,Decimal> currentNtMveDiesel = new Map<String,Decimal>();
            Map<String,Decimal> unBrandedAndBrandedProdCostPrice = new Map<String,Decimal>();
            Map<String,Decimal> unBrandedAndBrandedMV = new Map<String,Decimal>();
            Map<String,Decimal> unBrandBaseProdCostPrice = new Map<String,Decimal>();
            Map<String,Decimal> brandBaseProdCostPrice = new Map<String,Decimal>();
            Set<Id> insertedCostPriceIds = new Set<Id>();
            List<RV_Exception__c> excpList = new List<RV_Exception__c>();
            List<RE_MY_CostPrice__c> initialVersnLst = new List<RE_MY_CostPrice__c>();   
            Map<String,RE_MY_CostPrice__c> oldMapCostPrice = new Map<String,RE_MY_CostPrice__c>();
            List<RE_MY_CostPrice__c> oldCostPrceLst = new List<RE_MY_CostPrice__c>();
            List<RT_Price_Book__c> oldPriceBookLst = new List<RT_Price_Book__c>();
            String fxLiveQuoteName,epDefaultUnitRate; 
            Decimal currtFxRate = 0.00;            
            Map<String,String> baseProdctUnitRate = new Map<String,String>();
            Boolean updateSuccess = False;
            Map<Id,String> diffType = New Map<Id,String>();
            Map<Id,Decimal> diffValue = New Map<Id,Decimal>();
            Map<Id,String> diffUnit = New Map<Id,String>();
             
            Map<String,Decimal> refRackNtMveGasoline = new Map<String,Decimal>();
            Map<String,String> refRackGasoline = new Map<String,String>();           
            Map<String,Decimal> refRackNtMveDiesel = new Map<String,Decimal>();
            Map<String,String> refRackDiesel = new Map<String,String>();
            Decimal baseNtMve = 0.00;
            Decimal refNtMve = 0.00;
            Decimal rackBaseDiff = 0.00;
            String refBaseRack;
            
            Id cndDepotPricingRecdTypId = Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            Id cndPricngDiffRecdTypId = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('Canada_Pricing_Differential').getRecordTypeId();
            Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
            
            updatedMOA = [SELECT Id, RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Today_s_Price__c, RE_CND_Market_Move__c, RE_CND_Competitive_Adj__c, 
                         RE_CND_Net_Move__c, RE_CND_New_End_Price__c, RE_CND_Difference__c FROM RE_MOA__c WHERE recordtypeid =: cadMOARecordTypeId AND RE_CND_Effective_From_Date__c =: effectiveFromDate
                         AND RE_IsLatest__c =: TRUE ORDER BY RE_CND_Group__c];
    
            // Get all the current day's active Cost Price and Price Book records to set Redundant
            RE_CND_ExecuteDepoPricingController.currentDayRecordsWrapper curDayRecrdWrapper = new RE_CND_ExecuteDepoPricingController.currentDayRecordsWrapper(); 
            curDayRecrdWrapper = RE_CND_ExecuteDepoPricingController.getCurentDayAllCostPriceRecords(request_Date);    
            oldMapCostPrice = curDayRecrdWrapper.currtDayMapCostPriceList;            
            oldPriceBookLst = curDayRecrdWrapper.currtDayPrcBookList;
            oldCostPrceLst = curDayRecrdWrapper.currtDayCostPrcList;
            
            Datetime requestedFxStartDt = (DateTime)request_Date;
            Datetime requestedFxEndDt = requestedFxStartDt.AddHours(23).AddMinutes(59).AddSeconds(59);
            
            // Get the Live Fx Rate Quote 
            for(RE_Zema_Quotes_Settings__c fxQuote: [SELECT Display_Name__c FROM RE_Zema_Quotes_Settings__c 
                                                     WHERE Country__c LIKE '%Canada%' AND Type__c =:'FX Rates' 
                                                     AND Frequency__c =: 'Live' AND Is_Active__c =: TRUE LIMIT 1])
            {
                fxLiveQuoteName = fxQuote.Display_Name__c;
            } 
            
            // Get current Fx Rate
            for(RE_FX_Rates__c curfx: [SELECT Id, RE_Forex_Rate__c FROM RE_FX_Rates__c 
                                       WHERE RE_Quote_Name__c =: fxLiveQuoteName AND RE_Trade_Type__c =: 'Exchange Rate' 
                                       AND RE_Pricing_Date__c >=: requestedFxStartDt AND RE_Pricing_Date__c <=: requestedFxEndDt
                                       LIMIT 1])
            {
                currtFxRate = curfx.RE_Forex_Rate__c;
            }
      
            // Get the Base Reference Rack Settings
            for(RE_CND_Base_Reference_Rack_Settings__c bseRefRacks : RE_CND_Base_Reference_Rack_Settings__c.getall().values())
            {
                if((bseRefRacks.Is_Active__c) && (bseRefRacks.Product_Classification_L0__c == 'Gasoline'))
                {                    
                    if(latestNtMveGasoline.containsKey(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c) 
                       && latestNtMveGasoline.containsKey(bseRefRacks.Base_Rack__c+' '+bseRefRacks.Product_Classification_L0__c))
                    {                       
                        baseNtMve = latestNtMveGasoline.get(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c);
                        refNtMve = latestNtMveGasoline.get(bseRefRacks.Base_Rack__c+' '+bseRefRacks.Product_Classification_L0__c);
                        rackBaseDiff = baseNtMve - refNtMve;                        
                        refRackNtMveGasoline.put(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c,rackBaseDiff);
                        refRackGasoline.put(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c,bseRefRacks.Base_Rack__c);
                    }
                }
                else if((bseRefRacks.Is_Active__c) && (bseRefRacks.Product_Classification_L0__c == 'Gas Oil'))
                {
                    if(latestNtMveDiesel.containsKey(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c) 
                       && latestNtMveDiesel.containsKey(bseRefRacks.Base_Rack__c+' '+bseRefRacks.Product_Classification_L0__c))
                    {
                        baseNtMve = latestNtMveDiesel.get(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c);
                        refNtMve = latestNtMveDiesel.get(bseRefRacks.Base_Rack__c+' '+bseRefRacks.Product_Classification_L0__c);
                        rackBaseDiff = baseNtMve - refNtMve;
                        refRackNtMveDiesel.put(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c,rackBaseDiff);
                        refRackDiesel.put(bseRefRacks.Rack__c+' '+bseRefRacks.Product_Classification_L0__c,bseRefRacks.Base_Rack__c);
                    }               
                }
            }
            
            // Get all the Canada active Pricing Differential           
            RE_CND_ExecuteDepoPricingController.differentialRecordsWrapper diffRecod = New RE_CND_ExecuteDepoPricingController.differentialRecordsWrapper();
            diffRecod = RE_CND_ExecuteDepoPricingController.getActiveCNDPricngDifferential(cndPricngDiffRecdTypId);
            diffType = diffRecod.diffRecordType;
            diffValue = diffRecod.diffRecordValue;
            diffUnit = diffRecod.diffRecordUnit;
            
            // Get all the Branded and Unbranded Base and Derived Products respectively
            RE_CND_ExecuteDepoPricingController.cndDepotPricingRecordWrapper cndAllActiveDepotPricing = new RE_CND_ExecuteDepoPricingController.cndDepotPricingRecordWrapper();            
            cndAllActiveDepotPricing =  RE_CND_ExecuteDepoPricingController.getActiveAllCNDDepotPricing(cndDepotPricingRecdTypId);             
            unbrandedExecutePriceBaseProduct = cndAllActiveDepotPricing.unbrandedExecutePriceBaseProduct;
            unbrandedAndBrandedDerivedProduct = cndAllActiveDepotPricing.unbrandedAndBrandedDerivedProduct;
            
            // Get the previous day's cost price records
            prevDayCostPrice = RE_CND_ExecuteDepoPricingController.getLatestCostPriceRecords(request_Date);
            
            // Get the default unit rate for Price execution Calculation
            for(RE_Default_Unit_Rate_Settings__c dunitRate : RE_Default_Unit_Rate_Settings__c.getall().values())
            {
                if((dunitRate.Country_Name__c == 'Canada') && (dunitRate.Object_Name__c == 'RE_MOA__c')
                   && (dunitRate.Type__c == 'Price Execution') && (dunitRate.Is_Active__c == TRUE))
                {
                    epDefaultUnitRate = dunitRate.Default_Unit_Rate__c;                  
                }
            }            
            
            // Unbranded Execute Pricing for Base Products           
            if(unbrandedExecutePriceBaseProduct.size() > 0)
            {         
                for(RE_Depot_Pricing_Backbone__c unBrndExecteBaseProd : unbrandedExecutePriceBaseProduct)
                {                
                    RE_MY_CostPrice__c currCostPrice = new RE_MY_CostPrice__c();
                    
                    if(unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c == 'Gasoline')
                    {                       
                        rackBaseDiff = 0.00;
                        refBaseRack = '';
                        
                        if(refRackNtMveGasoline.containsKey(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                            rackBaseDiff = refRackNtMveGasoline.get(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c);
                        
                        if(refRackGasoline.containsKey(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                            refBaseRack = refRackGasoline.get(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c);
                        
                        currCostPrice = RE_CND_ExecuteDepoPricingController.calculatePricingLogic(request_Date, unBrndExecteBaseProd, cndActivePricngDiff, prevDayCostPrice,  requestdDate, effectiveFromDate, effectiveToDate, TRUE, 0.00, FALSE, 0.00, currtFxRate, epDefaultUnitRate, null,diffType,diffValue,diffUnit,rackBaseDiff,refBaseRack,updatedMOA);
                    }
                    else
                    {
                        rackBaseDiff = 0.00;
                        refBaseRack = '';
                        
                        if(refRackNtMveDiesel.containsKey(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                            rackBaseDiff = refRackNtMveDiesel.get(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c);
                        else if(refRackNtMveDiesel.containsKey(unBrndExecteBaseProd.RE_CND_Rack__c+' '+'Gas Oil'))
                            rackBaseDiff = refRackNtMveDiesel.get(unBrndExecteBaseProd.RE_CND_Rack__c+' '+'Gas Oil');  
                        
                        if(refRackDiesel.containsKey(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                            refBaseRack = refRackDiesel.get(unBrndExecteBaseProd.RE_CND_Rack__c+' '+unBrndExecteBaseProd.RE_Product_Name__r.RE_Product_Classification_L0__c);
                        else if(refRackDiesel.containsKey(unBrndExecteBaseProd.RE_CND_Rack__c+' '+'Gas Oil'))
                            refBaseRack = refRackDiesel.get(unBrndExecteBaseProd.RE_CND_Rack__c+' '+'Gas Oil'); 
                        
                        currCostPrice = RE_CND_ExecuteDepoPricingController.calculatePricingLogic(request_Date, unBrndExecteBaseProd, cndActivePricngDiff, prevDayCostPrice, requestdDate, effectiveFromDate, effectiveToDate, TRUE, 0.00, FALSE, 0.00, currtFxRate, epDefaultUnitRate, null,diffType,diffValue,diffUnit,rackBaseDiff,refBaseRack,updatedMOA); 
                    }
                    
                    currentCostPriceList.add(currCostPrice); 
                    unBrandedAndBrandedMV.put(unBrndExecteBaseProd.RE_Product_Name__r.RT_Product_Code__c+'-'+unBrndExecteBaseProd.RE_Location_Name__r.RE_Location_Code__c+ '-' + unBrndExecteBaseProd.RE_CND_Group__c, currCostPrice.RE_CND_Market_Move__c);
                    unBrandedAndBrandedProdCostPrice.put(unBrndExecteBaseProd.RE_Product_Name__r.RT_Product_Code__c+'-'+unBrndExecteBaseProd.RE_Location_Name__r.RE_Location_Code__c+ '-' + unBrndExecteBaseProd.RE_CND_Group__c, currCostPrice.RE_CND_New_Base_Value__c);
                    baseProdctUnitRate.put(unBrndExecteBaseProd.RE_Product_Name__r.RT_Product_Code__c+'-'+unBrndExecteBaseProd.RE_Location_Name__r.RE_Location_Code__c+ '-' + unBrndExecteBaseProd.RE_CND_Group__c, currCostPrice.RE_Costprice_Unit__c);
                }
            }
            
            // Unbranded/Branded Pricing for Derived Products 
            if(unbrandedAndBrandedDerivedProduct.size() > 0)
            {                
                for(RE_Depot_Pricing_Backbone__c unBrndBrndDerivedProd : unbrandedAndBrandedDerivedProduct)
                {                   
                    RE_MY_CostPrice__c currCostPrice = new RE_MY_CostPrice__c();
                    
                    if(unBrandedAndBrandedProdCostPrice.containsKey(unBrndBrndDerivedProd.RE_CND_Pricing_Basis__c))
                    {           
                        if(unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c == 'Gasoline')
                        {
                            rackBaseDiff = 0.00;
                            refBaseRack = '';
                            
                            if(refRackNtMveGasoline.containsKey(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                                rackBaseDiff = refRackNtMveGasoline.get(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c);
                            
                            if(refRackGasoline.containsKey(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                                refBaseRack = refRackGasoline.get(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c);
                            
                            currCostPrice = RE_CND_ExecuteDepoPricingController.calculatePricingLogic(request_Date, unBrndBrndDerivedProd, cndActivePricngDiff, prevDayCostPrice, requestdDate, effectiveFromDate, effectiveToDate, FALSE, 
                                                                  unBrandedAndBrandedMV.get(unBrndBrndDerivedProd.RE_CND_Pricing_Basis__c), TRUE, unBrandedAndBrandedProdCostPrice.get(unBrndBrndDerivedProd.RE_CND_Pricing_Basis__c), currtFxRate, epDefaultUnitRate, baseProdctUnitRate.get(unBrndBrndDerivedProd.RE_CND_Pricing_Basis__c),diffType,diffValue,diffUnit,
                                                                  rackBaseDiff,refBaseRack,updatedMOA);                            
                        }
                        else
                        {
                            rackBaseDiff = 0.00;
                            refBaseRack = '';
                            
                            if(refRackNtMveDiesel.containsKey(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                                rackBaseDiff = refRackNtMveDiesel.get(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c);
                            else if(refRackNtMveDiesel.containsKey(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+'Gas Oil'))
                                rackBaseDiff = refRackNtMveDiesel.get(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+'Gas Oil');
                            
                            if(refRackDiesel.containsKey(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c))
                                refBaseRack = refRackDiesel.get(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+unBrndBrndDerivedProd.RE_Product_Name__r.RE_Product_Classification_L0__c);                                            
                            else if(refRackDiesel.containsKey(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+'Gas Oil'))
                                refBaseRack = refRackDiesel.get(unBrndBrndDerivedProd.RE_CND_Rack__c+' '+'Gas Oil');                                            
                            
                            currCostPrice = RE_CND_ExecuteDepoPricingController.calculatePricingLogic(request_Date, unBrndBrndDerivedProd, cndActivePricngDiff, prevDayCostPrice, requestdDate, effectiveFromDate, effectiveToDate, FALSE, 
                                                                  unBrandedAndBrandedMV.get(unBrndBrndDerivedProd.RE_CND_Pricing_Basis__c), TRUE, unBrandedAndBrandedProdCostPrice.get(unBrndBrndDerivedProd.RE_CND_Pricing_Basis__c), currtFxRate, epDefaultUnitRate, baseProdctUnitRate.get(unBrndBrndDerivedProd.RE_CND_Pricing_Basis__c),diffType,diffValue,diffUnit,
                                                                  rackBaseDiff,refBaseRack,updatedMOA);                            
                        }
                        
                        currentCostPriceList.add(currCostPrice);                         
                    }                           
                }
            }
            
            // Insert New Cost Price records
            if(currentCostPriceList.size() > 0)
            {                         
                Database.SaveResult[] cpList = Database.insert(currentCostPriceList, false);
                insertedCostPriceIds = RE_CND_Utility.handleInsert('RE_CND_ExecuteDepoPricingController','startCalculatingDepoPricing-InsertNewCostPrice',cpList,jrAudit);                            
            }
            
            if(excpList.size()>0)
            {                
                RV_ClassException.insertExceptionRecord(excpList); 
                String otherComment = 'Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
                RE_CND_Utility.updateJobAuditPartialSuccess(jrAudit,'DML Exception while Database.Insert',otherComment);                                
            }            
            
            // Records existing on same day then update the InitialVersion same as Name in CostPrice
            if((insertedCostPriceIds.Size() > 0) && (oldMapCostPrice != null) && (oldMapCostPrice.Size() > 0))            
                initialVersnLst = RE_CND_ExecuteDepoPricingController.updateInitialVersionInOlderCostPrice(insertedCostPriceIds,curDayRecrdWrapper);     
            // If no existing records on same day then update the InitialVersion same as Name in CostPrice
            else if(insertedCostPriceIds.Size() > 0)   
                initialVersnLst = RE_CND_ExecuteDepoPricingController.updateInitialVersionInCostPrice(insertedCostPriceIds);
            
            // Update Cost Price, Price Book
            if(initialVersnLst.Size() > 0)
            {               
                RE_CND_CostPriceBatchUpdate updateCp = New RE_CND_CostPriceBatchUpdate(initialVersnLst, oldPriceBookLst, jrAudit, jrAudit.RE_Job_Status__c, IsSuccessJobAudit);
                Database.executeBatch(updateCp);              
            }
            else if((jrAudit.RE_Job_Status__c == 'Processing') && (IsSuccessJobAudit))
            {
                jrAudit.RE_Job_Status__c = 'Completed';               
                update jrAudit;                   
            }
            else
            {             
                String comments = 'Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
                RE_CND_Utility.updateJobAuditPartialSuccess(jrAudit,'Issue while generating Canada Depo Pricing Job',comments);                
            }        
        }
        catch(Exception ex)
        {       
            System.debug('startCalculatingDepoPricing-Main-->'+ex.getMessage());
            System.debug('startCalculatingDepoPricing-Main-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('CalculatingDepoPricing',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','startCalculatingDepoPricing-Main','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);  
        }        
        
    }
}