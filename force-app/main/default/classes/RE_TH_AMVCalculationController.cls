public class RE_TH_AMVCalculationController {
    RE_SOQLController soqldata = new RE_SOQLController();
    //Get latest Depot pricing data
    public List<RE_Depot_Pricing_Backbone__c> thailandCCList = soqldata.fetchTHDepoPricingData();
    //Get Market Quotes Data
    public List<RE_Market_Quotes__c> latestmarketquotes = soqldata.fetchMarketQuotesTHData();
    //Get Bio Quotes Data for Thailand
    public List<RE_Bio_Quotes__c> latestbioquotes = soqldata.fetchThailandQuotesData('Thailand');
    //Get Thailand product data
    public List<RE_Product__c> prodlist = RE_SOQLController.fetchThailandprodData('Thailand');
    //Get Latest Fx Data
    public Map<String,Double> curConvMap = soqldata.fetchLatestMidFxData();
    //Get Route Backbone data
    public List<RE_Route_Backbone__c> routebackbonelist = RE_SOQLController.fetchTHRouteBackboneData();
    public Map<Id,Double> depotweightedMap = new Map<Id,Double>();
    public Map<Id,Double> depotweightedCOvalMap = new Map<Id,Double>();
    public Map<Id,String> depotcommentMap = new Map<Id,String>();
    public List<RE_Route_Based_Costing__c> rbcostlist = new List<RE_Route_Based_Costing__c>();
   
    
    public List<RE_MY_FormulaFetchController.formulaWrapperTH> formWrapListTH = new List<RE_MY_FormulaFetchController.formulaWrapperTH>();
    public List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> formWrapAMVTHList = new List<RE_MY_FormulaFetchController.formulaWrapperAMVMY>();
    public RE_UtilitywrapperController.lineitemwraapper finalhcval;			//HCV
    public RE_UtilitywrapperController.lineitemwraapper finalrstval;	    //sales tax
    public RE_UtilitywrapperController.lineitemwraapper finalsahval;	    //Storage and handling 
    public RE_UtilitywrapperController.lineitemwraapper finalacval;		    //aditive cost
    public RE_UtilitywrapperController.lineitemwraapper finalptval;		    //PT
    public RE_UtilitywrapperController.lineitemwraapper finalcosval;	    //CO Steer
    public RE_UtilitywrapperController.lineitemwraapper finalspaval;        //spot price
    
    Map<String, String> quoteMapes = new  Map<String, String> ();
    public String errormessage = '';
    
    public Boolean lineItemsCalculation(RE_Job_Run_Audit__c jra){
        RE_MY_FormulaFetchController ffcntrlr = new RE_MY_FormulaFetchController();
        if(!thailandCCList.isEmpty()){
            System.debug('thaiCClist@@'+thailandCCList);
            for(RE_Bio_Quotes__c rbq : latestbioquotes){
                latestmarketquotes.add(new RE_Market_Quotes__c(RE_Price__c=rbq.RE_Price__c,RE_Pricing_Date__c=rbq.RE_Pricing_Date__c,RE_Rate_Unit__c=rbq.RE_Bio_RateUnit__c,RE_Quote_Name__c=rbq.RE_Bio_Quotes_Name__c, RE_Country_Name__c = 'SG;PH;TH;MY'));
                quoteMapes.put(rbq.RE_Bio_Quotes_Name__c,rbq.RE_Bio_Quotes_Name__c);
            }
            //HCV value calculation using Depot Pricing Backbone object
            formWrapListTH = ffcntrlr.formulaforDepotDataTH(thailandCCList);
            RE_TH_HCVController hcvcal = new RE_TH_HCVController();
            finalhcval = hcvcal.hcfDataPreparation(formWrapListTH,curConvMap,latestmarketquotes,prodlist,quoteMapes);
            errormessage = errormessage + finalhcval.errorMessage;
            System.debug('--finalhcval-'+finalhcval);
            
            //SalesTax calculation using Depot Pricing Backbone object
            RE_MY_RecoverySalesTaxController rcst	= new RE_MY_RecoverySalesTaxController();
            finalrstval	=	rcst.recoverySalesTaxTHPreparation(thailandCCList,curConvMap,prodlist);
            errormessage = errormessage + finalrstval.errorMessage;
            System.debug('--finalrstval-'+finalrstval);
            
            //Storage and handling and SPA calculation using Depot Pricing Backbone
            RE_MY_StorageAndHandlingTariffController sahval = new RE_MY_StorageAndHandlingTariffController();
            finalsahval = sahval.shtPreparation(thailandCCList,curConvMap);
            errormessage = errormessage + finalsahval.errorMessage;
            System.debug('finalsahval--'+finalsahval);
            finalspaval = sahval.spaPreparation(thailandCCList,curConvMap);
            errormessage = errormessage + finalspaval.errorMessage;
            System.debug('finalsahval--'+finalspaval);
            
            //Additive Cost calculation using Depot Pricing Backbone and Product 
            RE_MY_AdditiveCostController acval = new RE_MY_AdditiveCostController();
            finalacval = acval.additivecostCalculation(thailandCCList,prodlist,curConvMap);
            System.debug('finalacval--'+ finalacval);
            errormessage = errormessage + finalacval.errorMessage;
            
             
            
            if(!routebackbonelist.isEmpty()){
                System.debug('@@routebackbonelistIsNotEmpty');
                formWrapAMVTHList = ffcntrlr.formulaforDepotDataAMVMY(thailandCCList,routebackbonelist);
                
                RE_MY_PrimaryTransportCostController ptcval = new RE_MY_PrimaryTransportCostController();
                finalptval = ptcval.AMVprimaryTransportCostpreparation(formWrapAMVTHList,curConvMap);
                errormessage = errormessage + finalptval.errorMessage;
                System.debug('--finalptval-'+finalptval);                   
                RE_MY_COSteerController cosval = new RE_MY_COSteerController();
                finalcosval = cosval.shospPreparation(formWrapAMVTHList,curConvMap);
                errormessage = errormessage + finalcosval.errorMessage;
                System.debug('--finalcosval-'+finalcosval);
                
                routebasedcostingData();
            }
            return finaldepotbasedCostingData(jra);
        }
        return false;
    }
    
    public void routebasedcostingData(){        
        Id rectypeId = Schema.SObjectType.RE_Route_Based_Costing__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
        Double finalvalue;
        Double coValue;
        List<RE_Route_Based_Costing__c> updateLatestData = new List<RE_Route_Based_Costing__c>();
        List<RE_Route_Based_Costing__c> costDataLatest = [SELECT RE_IsLatest__c,recordtypeId FROM RE_Route_Based_Costing__c WHERE RE_IsLatest__c = True AND recordtypeid =: rectypeId];
        if(!costDataLatest.isEmpty()){
            for(RE_Route_Based_Costing__c rbcMY : costDataLatest){
                rbcMY.RE_IsLatest__c = False;
                updateLatestData.add(rbcMY);
            }
        }
        for(RE_MY_FormulaFetchController.formulaWrapperAMVMY rbdata : formWrapAMVTHList){
            finalvalue = 0;
            coValue = 0;
            RE_Route_Based_Costing__c rbcostdata = new RE_Route_Based_Costing__c();
            rbcostdata.recordtypeId=rectypeId;
            rbcostdata.RE_Route_Backbone__c = rbdata.hcfObj.Id;
            rbcostdata.RE_Depot_Pricing_Backbone__c = rbdata.depoId;
            rbcostdata.RE_IsLatest__c = True;
            rbcostdata.RE_Primary_Transport_Cost__c = finalptval.finalval.containskey(rbdata.hcfObj.Id) ? finalptval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_CO_Steer__c = finalcosval.finalval.containskey(rbdata.hcfObj.Id) ? finalcosval.finalval.get(rbdata.hcfObj.Id) : 0;
            
            finalvalue = rbdata.hcfObj.RE_Route_Utilization__c/100 * (rbcostdata.RE_Primary_Transport_Cost__c+rbcostdata.RE_CO_Steer__c);
            
            coValue = rbdata.hcfObj.RE_Route_Utilization__c/100 * rbcostdata.RE_CO_Steer__c;
            
            //updating final value to final weighted map 
            if(depotweightedMap.containsKey(rbcostdata.RE_Depot_Pricing_Backbone__c)){
                depotweightedMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c,depotweightedMap.get(rbcostdata.RE_Depot_Pricing_Backbone__c) + finalvalue);
            }
            else {
                depotweightedMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c, finalvalue);
            }
            //updating CO steer value to CO weighted map
            if(depotweightedCOvalMap.containsKey(rbcostdata.RE_Depot_Pricing_Backbone__c)){
                depotweightedCOvalMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c,depotweightedCOvalMap.get(rbcostdata.RE_Depot_Pricing_Backbone__c) + coValue);
            }
            else {
                depotweightedCOvalMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c, coValue);
            }
            
            if(depotcommentMap.containsKey(rbcostdata.RE_Depot_Pricing_Backbone__c)){
                if(rbdata.hcfObj.RE_MY_Comments__c != '' && rbdata.hcfObj.RE_MY_Comments__c != null && rbdata.hcfObj.RE_CO_Steer_Valid_From__c <= System.today() 
                   && rbdata.hcfObj.RE_CO_Steer_Valid_To__c >= System.today())
                    depotcommentMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c,depotcommentMap.get(rbcostdata.RE_Depot_Pricing_Backbone__c) +' || '+ rbdata.hcfObj.RE_MY_Comments__c);
            }
            else{
                if(rbdata.hcfObj.RE_MY_Comments__c != '' && rbdata.hcfObj.RE_MY_Comments__c != null)
                    depotcommentMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c, rbdata.hcfObj.RE_MY_Comments__c);
            }
            rbcostlist.add(rbcostdata);
        }
        
        try{
            if(!rbcostlist.isEmpty()){
                if(!updateLatestData.isEmpty())
                    update updateLatestData;
                insert rbcostlist;
            }
        }
        catch(Exception ex){
            System.debug('Error on inserting RE_Route_Based_Costing__c'+ex);
        }
    }
    
    public Boolean finaldepotbasedCostingData(RE_Job_Run_Audit__c jra){
        Boolean Issuccess;
        Id rectypeId = Schema.SObjectType.RE_Depot_Based_Costing__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
        
        if(String.isEmpty(errormessage)){
            Map<String,Double> costpricemap = RE_SOQLController.fetchlatestTHCostPrice();
            List<RE_Depot_Based_Costing__c> costingList = new List<RE_Depot_Based_Costing__c>();
            List<RE_Depot_Based_Costing__c> updateLatestData = new List<RE_Depot_Based_Costing__c>();
            List<RE_Depot_Based_Costing__c> deletetodaysData = new List<RE_Depot_Based_Costing__c>();
            List<RE_Depot_Based_Costing__c> costDataLatest = [SELECT createddate,recordtypeId, RE_IsLatest__c FROM RE_Depot_Based_Costing__c WHERE RE_IsLatest__c = True AND recordtypeId =: rectypeId];
            if(!costDataLatest.isEmpty()){
                for(RE_Depot_Based_Costing__c costMY : costDataLatest){
                    if(costMY.createddate == System.today()){
                        deletetodaysData.add(costMY);
                    }else{
                        costMY.RE_IsLatest__c = False;
                        updateLatestData.add(costMY);
                    }
                }
            }
            Integer jobCount = 0;
            String remarks;
            List<RE_Job_Run_Audit__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
                                                       WHERE createddate = Today AND RE_Job_Type__c = 'Thailand AMV Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
            if(!costDataToday.isEmpty())
                jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
            
            for(RE_Depot_Pricing_Backbone__c dpbdata : thailandCCList){
                remarks = '';
                System.debug('depotweightedMap@@'+depotweightedMap);
                if(depotweightedMap.containskey(dpbdata.Id)) {
                    RE_Depot_Based_Costing__c costData = new RE_Depot_Based_Costing__c();
                    costData.RE_Job_Run_Count__c = jobCount;
                    costData.recordtypeId=rectypeId;
                    costData.RE_IsLatest__c = True;
                    costData.RE_Depot_Pricing_Backbone__c = dpbdata.Id;
                    costData.RE_HCV_Value__c = finalhcval.finalval.containskey(dpbdata.Id) ? finalhcval.finalval.get(dpbdata.Id) : 0;
                    costData.RE_S_N_H_Cost__c = finalsahval.finalval.containskey(dpbdata.Id) ? finalsahval.finalval.get(dpbdata.Id) : 0;
                    costData.RE_Sales_Tax__c = finalrstval.finalval.containskey(dpbdata.Id) ? finalrstval.finalval.get(dpbdata.Id) : 0;
                    costData.RE_Spot_Price_Adjustment__c = finalspaval.finalval.containskey(dpbdata.Id) ? finalspaval.finalval.get(dpbdata.Id) : 0;
                    costData.RE_Weighted_Avg__c = depotweightedMap.containskey(dpbdata.Id) ? depotweightedMap.get(dpbdata.Id) : 0;
                    costData.RE_Weighted_CO_Val__c = depotweightedCOvalMap.containskey(dpbdata.Id) ? depotweightedCOvalMap.get(dpbdata.Id) : 0;
                    if (dpbdata.RE_Comments__c != '' && dpbdata.RE_Comments__c != null)
                        remarks = dpbdata.RE_Comments__c + ' || ';
                    if(depotcommentMap.containsKey(dpbdata.Id) )
                        remarks = remarks + depotcommentMap.get(dpbdata.Id) + ' || ';
                    costData.RE_Comments__c = remarks;
                    system.debug('-costpricemap --'+costpricemap);
                    system.debug('dpbdata.RE_Depot_Name__c+\'_\'+dpbdata.RE_Product_Name__c --'+dpbdata.RE_Depot_Name__c+'_'+dpbdata.RE_Product_Name__c);
                    if(costpricemap.containsKey(dpbdata.RE_Depot_Name__c+'_'+dpbdata.RE_Product_Name__c))
                        costData.RE_Morning_CBU_Value__c = costpricemap.get(dpbdata.RE_Depot_Name__c+'_'+dpbdata.RE_Product_Name__c);
                    costingList.add(costData);
                    System.debug('costData : '+costData);
                    
                }
            }
            if(!costingList.isEmpty()){
                try{
                    if(!updateLatestData.isEmpty())
                        update updateLatestData;
                    if(!deletetodaysData.isEmpty())
                        delete deletetodaysData;
                    insert costingList;
                    Issuccess = True;
                }
                catch(Exception e){
                    Issuccess = False;
                }
            }            
        }
        else{
            Issuccess = False;
        }
        System.debug('Issuccess : '+Issuccess);
        try{
            jra.RE_IsSuccess__c = Issuccess;
            jra.RE_Exception__c = errormessage;
            update jra;
        }
        catch(Exception e){
            System.debug('Error on updating AMV Job');
        }
        return Issuccess;
    }
     @AuraEnabled
    public Static List<Aggregateresult> fetchProductAMVTHoutputdata(String country){
        Id recordType= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
        return ([Select RE_Product__r.Name from  RE_MOA__c where RE_Country__r.Name =:country AND RE_IsLatest__c = True AND RecordTypeId = :recordType group by RE_Product__r.Name]);
       
    }
    @AuraEnabled
    public Static List<RE_MOA__c> fetchAMVTHoutputdata(String prodName){
        Id recordType= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
        System.debug('prodName->'+prodName);
        return ([Select Id,RE_Depot_Name__r.Name,RE_LDC_Morning__c,RE_MC_Morning__c,RE_Prev_Mid_Day_price_out__c,RE_Today_s_BSP__c,RE_Target_Margin__c,
                 RE_PSP__c,RE_Final_PSP__c,RE_Remark__c,RE_Spot_Price_Adj__c,RE_AM_Challenged_Price__c,RE_Agreed_PSP__c,RE_AM_Comments__c,RE_isDisabled__c,RE_Mid_Day_price_out__c
                 from  RE_MOA__c where RE_IsLatest__c = True AND RE_Product__r.Name = :prodName AND RecordTypeId = :recordType ]);
    }
    @AuraEnabled
    public Static void saveAMVTHdata(List<RE_MOA__c> amvupdatedList){
        System.debug('amvupdatedList--'+amvupdatedList);
        try{
            update amvupdatedList;
        }
        catch(Exception ex){
            System.debug('Failed to update'+ex.getMessage());
        }
    }
   
   @AuraEnabled
    public Static void sendEmailtoAM(){
        List<String> tomail = System.label.RE_MY_Mail_Recipient.split(';');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(tomail);
        email.setSubject('PSP submitted by Pricing Desk for - '+System.Today());
        email.setHtmlBody('Hi, <br/><br/>Final PSP has been calculated by team and submitted for challenge. <br/><br/>Regards,<br/> Pricing Team');
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
    }
}