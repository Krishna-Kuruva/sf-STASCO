public class RE_PH_CostCalculation {    
    RE_SOQLController soqldata = new RE_SOQLController();
    //Get latest Depot pricing data
    public List<RE_Depot_Pricing_Backbone__c> PHDPBList = soqldata.fetchPHDepoPricingData();
    //Get Market Quotes Data
    public List<RE_Market_Quotes__c> latestmarketquotes = new List<RE_Market_Quotes__c> ();
    // Get PH product data map
    public Map<String,RE_Product__c> proddataMap = soqldata.fetchPHprodDataMap('Philippines');
    public Map<String,Double> curConvMap = new Map<String,Double>();
    //Get holiday list
    public Static Map<String, RE_Holiday_Calendar__c> holidayMap = RE_SOQLController.fetchHolidayData();
    public String datatype;
    public List<RE_MY_FormulaFetchController.formulaWrapperTH> formWrapListPH = new List<RE_MY_FormulaFetchController.formulaWrapperTH>();
    
    public RE_PH_CostCalculation(String type){
        System.debug('type--'+type);
        datatype = type;
        String mopstype = (type == 'D-1') ? 'D' : type;
        latestmarketquotes = soqldata.fetchMarketQuotesPHData(mopstype);
        System.debug('latestmarketquotes-'+latestmarketquotes);
        String fxtype = (type == 'D-1') ? 'D+1' : type;
        curConvMap = soqldata.fetchPHLatestFxData(fxtype);
        System.debug('curConvMap-'+curConvMap);
    }
    
    public RE_UtilitywrapperController.lineitemwraapper finalhcval;    //hcv
    public RE_UtilitywrapperController.lineitemwraapper finalbioval;   //biovalue
    public RE_UtilitywrapperController.lineitemwraapper finalfpval;   //fixedpremium value
    public RE_UtilitywrapperController.lineitemwraapper finalmpval;    //marketprem
    public RE_UtilitywrapperController.lineitemwraapper finalfcval;    //freight charge
    public RE_UtilitywrapperController.lineitemwraapper finalshiftval; //MISC - Shifting Cost
    public RE_UtilitywrapperController.lineitemwraapper finalpqhval;   //PQ Cost
    public RE_UtilitywrapperController.lineitemwraapper finalpcval;    //port charges
    public RE_UtilitywrapperController.lineitemwraapper finalslpval;   //small lot premium
    public RE_UtilitywrapperController.lineitemwraapper finalhhval;    // MISC - Hosehandling Cost
    public RE_UtilitywrapperController.lineitemwraapper finalptval;    //PrimaryTransport
    public RE_UtilitywrapperController.lineitemwraapper finalfrsval;   //freight shifting cost
    public RE_UtilitywrapperController.lineitemwraapper finaldmrgval;  // demurrage calculation
    public RE_UtilitywrapperController.lineitemwraapper finalflcval;   // FLC Service Fee
    public RE_UtilitywrapperController.lineitemwraapper finalbrkgeval; // MISC - Brokerage Fee
    public RE_UtilitywrapperController.lineitemwraapper finalwtrfntval; //MISC - Waterfront Operations Cost
    public RE_UtilitywrapperController.lineitemwraapper finaltcval;     //Terminal Cost
    public RE_UtilitywrapperController.lineitemwraapper finalwharval;   //Wharfage Cost
    public RE_UtilitywrapperController.lineitemwraapper finalfmfval;    //Fuel Marking Factor  & MISC - Fuel Marking Fee
    public RE_UtilitywrapperController.lineitemwraapper finalrstval;    // sales tax
    public RE_UtilitywrapperController.lineitemwraapper finaladval;     //Additive cost
    public RE_UtilitywrapperController.lineitemwraapper finalsnhval;        //S&H cost
    public Map<Id, Double> finalmccval = new Map<Id, Double>();
    public Map<Id,Double> laiddownCostMap = new Map<Id,Double>();
    public String errormessage = '';
    
    public Boolean lineItemsCalculation(RE_Job_Run_Audit__c jra){
        if(!PHDPBList.isEmpty()){
            RE_MY_FormulaFetchController ffcntrlr = new RE_MY_FormulaFetchController();
            formWrapListPH = ffcntrlr.formulaforDepotDataTH(PHDPBList);
            RE_MY_HcvBioController hcvcal = new RE_MY_HcvBioController();
            System.debug('1');
            finalhcval = hcvcal.PHhcfDataPreparation(formWrapListPH,curConvMap,latestmarketquotes,proddataMap);
            errormessage = errormessage + finalhcval.errorMessage;
            System.debug('finalhcval--'+finalhcval);
            finalbioval = hcvcal.PHbioCostCalculation(formWrapListPH,curConvMap,latestmarketquotes,proddataMap);
            errormessage = errormessage + finalbioval.errorMessage;
            RE_MY_TransferPricePremiumController tpval = new RE_MY_TransferPricePremiumController();
            System.debug('finalbioval--'+finalbioval);
            finalfpval = tpval.fixedPremiumPreparation(formWrapListPH,curConvMap,proddataMap);
            errormessage = errormessage + finalfpval.errorMessage;
            RE_MY_MarketPremiumController mpval = new RE_MY_MarketPremiumController();
            System.debug('finalfpval--'+finalfpval);
            finalmpval = mpval.PHmarketPremiumPreparation(formWrapListPH,curConvMap,latestmarketquotes,proddataMap);
            errormessage = errormessage + finalmpval.errorMessage;          
            RE_FreightChargesController fcval = new RE_FreightChargesController();
            System.debug('finalmpval--'+finalmpval);
            finalfcval = fcval.PHfrPreparation(formWrapListPH,curConvMap,latestmarketquotes,proddataMap);
            errormessage = errormessage + finalfcval.errorMessage;          
            RE_MY_PrimaryTransportCostController ptcval = new RE_MY_PrimaryTransportCostController();
            System.debug('finalfcval--'+finalfcval);
            finalptval = ptcval.primaryTransportCostpreparationPH(PHDPBList,curConvMap,proddataMap);
            errormessage = errormessage + finalptval.errorMessage;
            RE_MY_SmallLotPremiumController slval = new RE_MY_SmallLotPremiumController();
            System.debug('finalptval--'+finalptval);
            finalslpval = slval.slpDataPreparationPH(formWrapListPH,curConvMap,latestmarketquotes,proddataMap);
            errormessage = errormessage + finalslpval.errorMessage;
            RE_PH_MiscCostCalculation  fmiscval = new RE_PH_MiscCostCalculation();
            System.debug('finalslpval--'+finalslpval);
            finalfrsval = fmiscval.PHfreightShiftngPreparation(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalfrsval.errorMessage;
            System.debug('finalfrsval--'+finalfrsval);
            finaldmrgval = fmiscval.PHdemurragePreparation(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finaldmrgval.errorMessage;
            System.debug('finaldmrgval--'+finaldmrgval);
            finalflcval  = fmiscval.flcservicePreparationPH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalflcval.errorMessage;
            System.debug('finalflcval--'+finalflcval);
            finalbrkgeval  = fmiscval.miscbrokeragefeePrepPH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalbrkgeval.errorMessage;
            System.debug('finalbrkgeval--'+finalbrkgeval);
            finalhhval  = fmiscval.mischosehandlingfeePH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalhhval.errorMessage;
            System.debug('finalhhval--'+finalhhval);
            finalpcval  = fmiscval.miscportchargePH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalpcval.errorMessage;
            System.debug('finalpcval--'+finalpcval);
            finalpqhval  = fmiscval.miscPQcostPH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalpqhval.errorMessage;
            System.debug('finalpqhval--'+finalpqhval);
            finalshiftval  = fmiscval.miscShiftingcostPH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalshiftval.errorMessage;
            System.debug('finalshiftval--'+finalshiftval);
            finalwtrfntval  = fmiscval.miscWaterfrontOpscostPH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalwtrfntval.errorMessage;
            System.debug('finalwtrfntval--'+finalwtrfntval);
            finaltcval  = fmiscval.miscTerminalcostPH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finaltcval.errorMessage;
            System.debug('finaltcval--'+finaltcval);
            finalwharval  = fmiscval.wharfagecostPH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalwharval.errorMessage;
            System.debug('finalwharval--'+finalwharval);
            finalfmfval  = fmiscval.fuelmarkingfeePH(formWrapListPH, curConvMap,proddataMap);
            errormessage = errormessage + finalfmfval.errorMessage;
            RE_MY_RecoverySalesTaxController rstval = new RE_MY_RecoverySalesTaxController();
            System.debug('finalfmfval--'+finalfmfval);
            finalrstval = rstval.SalesTaxPHPreparation(PHDPBList,curConvMap,proddataMap.values());
            errormessage = errormessage + finalrstval.errorMessage;
            System.debug('finalrstval--'+finalrstval);
            RE_MY_AdditiveCostController adtval = new RE_MY_AdditiveCostController();
            finaladval = adtval.additivecostCalculation(PHDPBList,proddataMap.values(),curConvMap);
            System.debug('finaladval--'+finaladval);
            errormessage = errormessage + finaladval.errorMessage;
            RE_MY_StorageAndHandlingTariffController snhval = new RE_MY_StorageAndHandlingTariffController();
            finalsnhval = snhval.shtPreparation(PHDPBList,curConvMap);
            System.debug('finalsnhval--'+finalsnhval);
            errormessage = errormessage + finalsnhval.errorMessage;
            laidDownCostCalculation();
            finalCostingData(jra);
        }
        return true;
    }
    
    //Laid down cost calculation
    public void laidDownCostCalculation(){        
        for(RE_Depot_Pricing_Backbone__c dpbdata : PHDPBList){
            Double marginalCost = 0;
            Double laidDownCost = 0;
            
            if(finalhcval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalhcval.finalval.get(dpbdata.Id);            
            if(finalfpval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalfpval.finalval.get(dpbdata.Id);
            if(finalmpval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalmpval.finalval.get(dpbdata.Id);
            if(finalfcval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalfcval.finalval.get(dpbdata.Id);  
            if(finalbioval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalbioval.finalval.get(dpbdata.Id);
            if(finalslpval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalslpval.finalval.get(dpbdata.Id);
            //if(finalptval.finalval.containsKey(dpbdata.Id))
              //  laidDownCost = laidDownCost + finalptval.finalval.get(dpbdata.Id);
            if(finalflcval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalflcval.finalval.get(dpbdata.Id);
            if(finaltcval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finaltcval.finalval.get(dpbdata.Id);
            Double oceanval = dpbdata.RE_PH_Ocean_Cost__c != null ? dpbdata.RE_PH_Ocean_Cost__c/100 : 0;
            Double snhval = dpbdata.RE_PH_S_H__c != null ? dpbdata.RE_PH_S_H__c/100 : 0;
            Double ptval = dpbdata.RE_PH_PT_Percentage__c != null ? dpbdata.RE_PH_PT_Percentage__c/100 : 0;
            Double insuranceval = dpbdata.RE_Insurance_Percentage__c != null ? dpbdata.RE_Insurance_Percentage__c/100 : 0;
            laidDownCost = (1+ (oceanval + snhval + ptval + insuranceval))* laidDownCost;
         
            if(finaldmrgval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finaldmrgval.finalval.get(dpbdata.Id);
            if(finalbrkgeval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalbrkgeval.finalval.get(dpbdata.Id);           
            if(finalhhval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalhhval.finalval.get(dpbdata.Id);
            if(finalpcval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalpcval.finalval.get(dpbdata.Id);
            if(finalpqhval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalpqhval.finalval.get(dpbdata.Id);     
            if(finalshiftval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalshiftval.finalval.get(dpbdata.Id);
            if(finalwtrfntval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalwtrfntval.finalval.get(dpbdata.Id);         
            if(finalwharval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalwharval.finalval.get(dpbdata.Id);
            if(finalfmfval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalfmfval.finalval.get(dpbdata.Id);
           // if(finalrstval.finalval.containsKey(dpbdata.Id))
             //   laidDownCost = laidDownCost + finalrstval.finalval.get(dpbdata.Id);
            if(finaladval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finaladval.finalval.get(dpbdata.Id);
           
            laiddownCostMap.put(dpbdata.Id, laidDownCost);      
        }
    }
    
    //create cost price data for all depot pricing backbone data. For blended product, create a new cost price record.
    public Boolean finalCostingData(RE_Job_Run_Audit__c jra){
        Boolean Issuccess;
        if(String.isEmpty(errormessage)){
            List<RE_MY_CostPrice__c> blendedcostingList = new List<RE_MY_CostPrice__c>();
            List<RE_MY_CostPrice__c> nonblendedcostingList = new List<RE_MY_CostPrice__c>();
            List<RE_MY_CostPrice__c> updateLatestData = new List<RE_MY_CostPrice__c>();
            
            Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
            List<RE_MY_CostPrice__c> costDataLatest = [SELECT RE_Type__c,RE_IsLatest__c,RE_PH_Is_Today__c, RE_Depot_Name__c,RE_Product_Name__c,Createddate FROM RE_MY_CostPrice__c WHERE recordtypeId = : rectypeId AND RE_IsLatest__c = True AND RE_Type__c =:datatype AND Createddate = Today];
            
            //updating old data
            if(!costDataLatest.isEmpty()){
                for(RE_MY_CostPrice__c costPH : costDataLatest){
                    costPH.RE_IsLatest__c = False;
                    costPH.RE_Type__c = '';
                    costPH.RE_PH_Is_Today__c = False;
                    updateLatestData.add(costPH);
                }                   
            }   
            
            if(datatype == 'WTD' || datatype == 'MTD') {
                for(RE_MY_CostPrice__c costdata : [SELECT RE_Type__c,RE_IsLatest__c,RE_PH_Is_Today__c, RE_Depot_Name__c,RE_Product_Name__c,Createddate FROM RE_MY_CostPrice__c WHERE recordtypeId = : rectypeId AND RE_IsLatest__c = True AND RE_Type__c =:datatype  AND Createddate != Today]){
                    costdata.RE_Type__c = '';
                    costdata.RE_PH_Is_Today__c = False;
                    updateLatestData.add(costdata);
                }
            }
                
                                 
            Integer jobCount = 0;
            List<RE_Job_Run_Audit__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
                                                       WHERE createddate = Today AND RE_Job_Type__c = 'Philippines Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
            if(!costDataToday.isEmpty())
                jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
            for(RE_Depot_Pricing_Backbone__c dpbdata : PHDPBList){
                RE_MY_CostPrice__c costData = new RE_MY_CostPrice__c();
                costData.RE_Type__c = datatype;
                costData.recordtypeId=Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
                costData.RE_Job_Run_Count__c = jobCount;
                costData.RE_PH_Is_Today__c = True;
                costData.RE_IsLatest__c = True;
                costData.RE_Country__c = dpbdata.RE_Country__c;
                costData.RE_Depot_Name__c = dpbdata.RE_Depot_Name__c;
                costData.RE_Product_Name__c = dpbdata.RE_Product_Name__c;
                costData.RE_Costprice_Unit__c = dpbdata.RE_Final_Price_Unit__c;
                costData.RE_Blend_Percent__c  = dpbdata.RE_PH_Blend_Percentage__c;
                costData.RE_Pricing_Date__c = System.today();
                costData.RE_PH_Is_Blend__c = dpbdata.RE_PH_Blend_Percentage__c != 100 ? True : False;                    
                if(finalhcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Hydrocarbon_Value__c = finalhcval.finalval.get(dpbdata.Id);  //hydrocarbon
                if(finalbioval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Bio_Cost__c = finalbioval.finalval.get(dpbdata.Id);
                if(finalptval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_PT_Cost__c = finalptval.finalval.get(dpbdata.Id);
                if(finalslpval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_Small_LOT__c = finalslpval.finalval.get(dpbdata.Id);
                if(finaldmrgval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_Demurrage__c = finaldmrgval.finalval.get(dpbdata.Id);
                if(finalflcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_FLC_Service_Fee__c = finalflcval.finalval.get(dpbdata.Id);
                if(finalbrkgeval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_MISC_Brokerage_Fee__c = finalbrkgeval.finalval.get(dpbdata.Id);
                if(finalhhval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_MISC_Hosehandling_Cost__c = finalhhval.finalval.get(dpbdata.Id);
                if(finalpcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_MISC_Port_Charges__c = finalpcval.finalval.get(dpbdata.Id);
                if(finalpqhval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_MISC_PQ_Cost__c = finalpqhval.finalval.get(dpbdata.Id);
                if(finalshiftval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_MISC_Shifting_Cost__c = finalshiftval.finalval.get(dpbdata.Id);
                if(finalwtrfntval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_MISC_Waterfront_Operations_Cost__c = finalwtrfntval.finalval.get(dpbdata.Id);
                if(finaltcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_Terminal_Cost__c = finaltcval.finalval.get(dpbdata.Id);
                if(finalwharval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_Wharfage_Cost__c = finalwharval.finalval.get(dpbdata.Id);                
                if(finalfmfval.finalval.containsKey(dpbdata.Id))
                    costData.RE_PH_MISC_Fuel_Marking_Fee__c = finalfmfval.finalval.get(dpbdata.Id);
                if(finalrstval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Recovery_Sales_Tax__c = finalrstval.finalval.get(dpbdata.Id);
                if(finaladval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Additive_Cost__c = finaladval.finalval.get(dpbdata.Id);
                if(finalsnhval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Storage_Handling_Cost__c = finalsnhval.finalval.get(dpbdata.Id);
                if(laiddownCostMap.containsKey(dpbdata.Id))
                    costData.RE_Costprice_Laid_Down_Cost__c = laiddownCostMap.get(dpbdata.Id);
              /*  if(dpbdata.id == 'a2n3G0000004QU1QAM' || dpbdata.id == 'a2n3G0000004QU3QAM')
                	System.debug('RE_Hydrocarbon_Value__c-->'+costData.RE_Hydrocarbon_Value__c);*/
                if(finalfcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Freight_Pipeline_Charges__c = finalfcval.finalval.get(dpbdata.Id);
                if(finalmpval.finalval.containsKey(dpbdata.Id))                
                    costData.RE_Market_Premium__c = finalmpval.finalval.get(dpbdata.Id);
                else if(finalfpval.finalval.containsKey(dpbdata.Id))                
                    costData.RE_Market_Premium__c = finalfpval.finalval.get(dpbdata.Id);
                 // Multiplying RE_PH_Percent_Base_Fuel__c with LD
                if(dpbdata.RE_Product_Name__r.RE_PH_Percent_Base_Fuel__c != null)
                    costdata.RE_Costprice_Laid_Down_Cost__c = costdata.RE_Costprice_Laid_Down_Cost__c * (dpbdata.RE_Product_Name__r.RE_PH_Percent_Base_Fuel__c / 100);
                //LTR15 to LTR ONLY for LDC
                String prodgroup = dpbData.RE_Reference_Product__c != null ? proddataMap.get(dpbData.RE_Reference_Product__r.Name).RE_Product_Group__c : proddataMap.get(dpbdata.RE_Product_Name__r.Name).RE_Product_Group__c;
                for(RE_MY_VolumeConversion__c  convfactor : RE_MY_VolumeConversion__c.getall().values()){
                    if(convfactor.RE_MY_Product_Subgroup__c == prodgroup && convfactor.RE_MY_Country__c == dpbdata.RE_Country__r.Name &&
                       convfactor.RE_MY_Volume_Unit__c == 'L15' && convfactor.RE_MY_Base_Volume_Unit__c == 'LTR' && convfactor.RE_MY_Conversion_Rate__c != null && convfactor.RE_MY_Conversion_Rate__c >0)             
                        costdata.RE_Costprice_Laid_Down_Cost__c = costdata.RE_Costprice_Laid_Down_Cost__c / convfactor.RE_MY_Conversion_Rate__c;
                    
                }
                costData.RE_Data__c = dataDateCalcuation(datatype);
                costData.RE_Effective_Date__c = effectivedatecalculation(datatype);
                if(costData.RE_PH_Is_Blend__c)
                	blendedcostingList.add(costData);
                else
                    nonblendedcostingList.add(costData);
            }
            if(!blendedcostingList.isEmpty()){
                try{
                    
                    if(!updateLatestData.isEmpty())
                        update updateLatestData;                        
                    insert blendedcostingList;                 
                    Issuccess = True;
                }
                catch(Exception ex){
                    System.debug(ex.getCause());
                    Issuccess = False;
                }
                
            }
            else
                Issuccess = False;  
            if(!nonblendedcostingList.isEmpty()){
                try{              
                    insert nonblendedcostingList;                 
                    Issuccess = True;
                }
                catch(Exception ex){
                    System.debug(ex.getCause());
                    Issuccess = False;
                }
                
            }
            else
                Issuccess = False;  
        }
        else{
            Issuccess = False;
            
        }
        try{
            jra.RE_IsSuccess__c = Issuccess;
            jra.RE_Exception__c = errormessage;
            update jra;
        }
        catch(Exception e){
            System.debug(e.getCause());
            
        }
        return Issuccess;
    }
    
   
    //MTD-WTD Mops and Fx Data insert
    public void phMTDWTDDataCreation(String type) {
        List<RE_Market_Quotes__c> quotedata = new List<RE_Market_Quotes__c>();
        List<RE_FX_Rates__c> fxdata = new List<RE_FX_Rates__c>();
        List<AggregateResult> mopslist = new List<AggregateResult>();
        List<AggregateResult> fxlist = new List<AggregateResult>();
        for(RE_Market_Quotes__c quote : [SELECT id,RE_Tracker__c FROM RE_Market_Quotes__c WHERE RE_Tracker__c =: type AND createddate != Today]){
            quote.RE_Tracker__c = '';
            quotedata.add(quote);
        }
        for(RE_FX_Rates__c fxd : [SELECT id,RE_Tracker__c FROM RE_FX_Rates__c WHERE RE_Tracker__c =: type AND createddate != Today]){
            fxd.RE_Tracker__c = '';
            fxdata.add(fxd);
        }
        if(type == 'WTD'){
            
            mopslist =  [
                SELECT AVG(RE_Price__c) pravgval,RE_Quote_Name__c,RE_Rate_Unit__c,RE_Quote_Type__c FROM RE_Market_Quotes__c 
                WHERE RE_Pricing_Date__c = THIS_WEEK AND RE_Quote_Type__c IN('Settlement','Market Premium','Freight') AND RE_Is_MTDWTD__c = False AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
                GROUP BY RE_Quote_Name__c,RE_Rate_Unit__c, RE_Quote_Type__c
            ];
            
            fxlist = [
                SELECT avg(RE_Forex_Rate__c) fxavgval FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'PHP' 
                AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Pricing_Date__c = THIS_WEEK AND RE_Is_MTDWTD__c = False
            ];
        }
        
        if(type == 'MTD'){
            mopslist =  [
                SELECT AVG(RE_Price__c) pravgval,RE_Quote_Name__c,RE_Rate_Unit__c,RE_Quote_Type__c FROM RE_Market_Quotes__c 
                WHERE RE_Pricing_Date__c = THIS_MONTH AND RE_Quote_Type__c IN('Settlement','Market Premium','Freight') AND RE_Is_MTDWTD__c = False AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
                GROUP BY RE_Quote_Name__c,RE_Rate_Unit__c, RE_Quote_Type__c
            ];
            fxlist = [
                SELECT avg(RE_Forex_Rate__c) fxavgval FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'PHP' 
                AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Pricing_Date__c = THIS_MONTH AND RE_Is_MTDWTD__c = False
            ];
        }
        
        for(AggregateResult mopsdatalastweek : mopslist){
            RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();                    
            markQuote.RE_Quote_Name__c = (String)mopsdatalastweek.get('RE_Quote_Name__c');
            markQuote.RE_Quote_Type__c = (String)mopsdatalastweek.get('RE_Quote_Type__c');                    
            markQuote.RE_Rate_Unit__c = (String)mopsdatalastweek.get('RE_Rate_Unit__c');
            markQuote.RE_Price__c = (Decimal) mopsdatalastweek.get('pravgval');
            markQuote.RE_Pricing_Date__c = System.today();
            markQuote.RE_Tracker__c = type;
            markQuote.RE_Is_MTDWTD__c = True;
            markQuote.RE_Country_Name__c = 'SG;PH;TH;MY';
            quotedata.add(markQuote);
        }
        
        for( AggregateResult fx : fxlist){
            RE_FX_Rates__c FXDataCTS   = new RE_FX_Rates__c();
            FXDataCTS.RE_Conversion_Unit__c = 'PHP';
            FXDataCTS.RE_Base_Unit__c  =  'USD'; 
            FXDataCTS.RE_Forex_Name__c = 'PHP/USD';
            FXDataCTS.RE_Trade_Type__c = 'Sell';
            FXDataCTS.RE_Pricing_Date__c = System.today();
            FXDataCTS.RE_Forex_Rate__c = (Decimal) fx.get('fxavgval');
            FXDataCTS.RE_Tracker__c = type;
            FXDataCTS.RE_Is_MTDWTD__c = True;
            fxdata.add(FXDataCTS);
        }
        
        if(!quotedata.isEmpty()){
            try{upsert quotedata;}
            catch(Exception ex){System.debug(ex.getCause());}
        }
            
        if(!fxdata.isEmpty()){
            try{upsert fxdata;}
            catch(Exception ex){System.debug(ex.getCause());}
        }
        
    }
    
    //Efective date calculation for all types of record
    public String effectivedatecalculation(String type){    
        String effectivedate;
        String holidayDate = String.valueof(System.today());
        Datetime valdate = System.today();  
        String day = valdate.format('EEE');
        Datetime toDate;
        if(type == 'D-1'){
            if(day == 'Sat'){
                holidayDate = String.valueof(System.today().addDays(2));
                effectivedate = valdate.format('MMM') + ' ' + valdate.format('dd') +'-'+valdate.addDays(2).format('MMM') + ' ' +valdate.addDays(2).format('dd');
            }
            else
                effectivedate = valdate.format('MMM') + ' ' + valdate.format('dd');            
            if(holidayMap.containsKey(holidayDate)){
                if(day == 'Fri' || day == 'Sat'){
                    toDate = System.today().addDays(3);
                }
                else{
                    toDate = System.today().addDays(1);
                }
                effectivedate = valdate.format('MMM') + ' ' + valdate.format('dd') +'-'+toDate.format('MMM') + ' ' +toDate.format('dd');
            }
        }
        if(type == 'W-1'){
            Datetime dtwk = System.today().toStartofWeek();
            effectivedate =  dtwk.addDays(1).format('MMM')+ ' ' + dtwk.addDays(1).format('dd') + '-' + dtwk.addDays(7).format('MMM')+ ' ' + dtwk.addDays(7).format('dd') ;      
        }
        if(type == 'M-1'){
            Datetime dtmn = System.today().toStartOfMonth();
            effectivedate = dtmn.format('MMM') +' '+ '1'+ '-' + dtmn.format('MMM') + String.valueof(Date.daysInMonth(dtmn.year(), dtmn.month()));
        }
        return effectivedate;
    }
    
    ////Fetch data date for all types of record
    public String dataDateCalcuation(String type){
        String effectivedate;
        Datetime valdate = System.today();  
        Datetime dtwk = System.today().toStartofWeek();
        Datetime dtmn = System.today().toStartOfMonth().addDays(-1);
        if(type == 'D-1')
            effectivedate = valdate.addDays(-1).format('MMM') +' ' +valdate.addDays(-1).format('dd');
        if(type == 'W-1'){      
            effectivedate =  dtwk.addDays(-7).format('MMM')+ ' ' + dtwk.addDays(-7).format('dd') + '-' + dtwk.addDays(-3).format('MMM')+ ' ' + dtwk.addDays(-3).format('dd');
        }
        if(type == 'M-1'){      
            effectivedate = dtmn.format('MMM') +' '+ '1'+ '-' + dtmn.format('MMM') + String.valueof(Date.daysInMonth(dtmn.year(), dtmn.month()));
        }
        if(type == 'WTD'){
            effectivedate =  dtwk.format('MMM')+ ' ' + dtwk.format('dd') + '-' + valdate.format('MMM')+ ' ' + valdate.format('dd');
        }
        if(type == 'MTD'){
            effectivedate = valdate.format('MMM') +' '+ '1'+ '-' + valdate.format('MMM')+ ' ' + valdate.format('dd');
        }
        return effectivedate;
     }
        
}