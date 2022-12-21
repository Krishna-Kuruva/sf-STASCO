public class RE_MY_AMVCalculationController {               
    RE_SOQLController soqldata = new RE_SOQLController();
    //Get latest Depot pricing data
    public List<RE_Depot_Pricing_Backbone__c> malaysiaCCList = soqldata.fetchMYDepotpricingData();
    //Get Market Quotes Data
    public List<RE_Market_Quotes__c> latestmarketquotes = soqldata.fetchMarketQuotesData();
    //Get Bio Quotes Data for Malaysia
    public List<RE_Bio_Quotes__c> latestbioquotes = soqldata.fetchMalaysianBioQuotesData();
    //Get Malaysia formula data
    List<RE_Malaysian_Formula_Table__mdt> malformulalist = soqldata.fetchMalaysiaformulaData();
    //Get Malaysia product data
    public List<RE_Product__c> prodlist = RE_SOQLController.fetchMalaysiaprodData();
    //Get Latest Fx Data
    public Map<String,Double> curConvMap = soqldata.fetchLatestMidFxData();
    //Get Route Backbone data
    public List<RE_Route_Backbone__c> routebackbonelist = RE_SOQLController.fetchRouteBackboneData();
    public Map<Id,Double> depotweightedMap = new Map<Id,Double>();
   	public Map<Id,Double> depotweightedCOvalMap = new Map<Id,Double>();
    public Map<Id,String> depotcommentMap = new Map<Id,String>();
    public List<RE_Route_Based_Costing__c> rbcostlist = new List<RE_Route_Based_Costing__c>();
    public List<RE_MY_FormulaFetchController.formulaWrapper> formWrapList = new List<RE_MY_FormulaFetchController.formulaWrapper>();
    public List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> formWrapAMVMYList = new List<RE_MY_FormulaFetchController.formulaWrapperAMVMY>();

    //to store changed plant price form MOA 
    //public  Map<String,RE_MOA__c> moaMapPlantPrice = new Map<String,RE_MOA__c>();
    public Static Map<String,RE_MOA__c> moaMapPlantPrice = new Map<String,RE_MOA__c>();
    
    public RE_UtilitywrapperController.lineitemwraapper finalhcval;
    public RE_UtilitywrapperController.lineitemwraapper finalbioval;
    public RE_UtilitywrapperController.lineitemwraapper finalrstval;
    public RE_UtilitywrapperController.lineitemwraapper finalsahval;
    public RE_UtilitywrapperController.lineitemwraapper finalspaval;
    
    public RE_UtilitywrapperController.lineitemwraapper finaltppval;
    public RE_UtilitywrapperController.lineitemwraapper finalmpval;
    public RE_UtilitywrapperController.lineitemwraapper finalbbpval;
    public RE_UtilitywrapperController.lineitemwraapper finalslpval;
    public RE_UtilitywrapperController.lineitemwraapper finalolval;
    public RE_UtilitywrapperController.lineitemwraapper finalptval;
    public RE_UtilitywrapperController.lineitemwraapper finalmrfval;
    public RE_UtilitywrapperController.lineitemwraapper finalbolval;
    public RE_UtilitywrapperController.lineitemwraapper finalpcval;
    public RE_UtilitywrapperController.lineitemwraapper finalshospval;
    public RE_UtilitywrapperController.lineitemwraapper finalcosval;
    public RE_UtilitywrapperController.lineitemwraapper finalfcval;
    
    public String errormessage = '';
    
    public Boolean lineItemsCalculation(RE_Job_Run_Audit__c jra){
        RE_MY_FormulaFetchController ffcntrlr = new RE_MY_FormulaFetchController();
        if(!malaysiaCCList.isEmpty()){
            formWrapList = ffcntrlr.formulaforDepotData(malaysiaCCList,malformulalist);
            RE_MY_HcvBioController hcvcal = new RE_MY_HcvBioController();
            finalhcval = hcvcal.hcfDataPreparation(formWrapList,curConvMap,false,latestmarketquotes,latestbioquotes);
            errormessage = errormessage + finalhcval.errorMessage;
            finalbioval = hcvcal.hcfDataPreparation(formWrapList,curConvMap,true,latestmarketquotes,latestbioquotes);
            errormessage = errormessage + finalbioval.errorMessage;
            RE_MY_RecoverySalesTaxController rstval = new RE_MY_RecoverySalesTaxController(prodlist);
            finalrstval = rstval.recoverySalesTaxPreparation(malaysiaCCList,curConvMap);
            errormessage = errormessage + finalrstval.errorMessage;
            RE_MY_StorageAndHandlingTariffController sahval = new RE_MY_StorageAndHandlingTariffController();
            finalsahval = sahval.shtPreparation(malaysiaCCList,curConvMap);
            errormessage = errormessage + finalsahval.errorMessage;
            finalspaval = sahval.spaPreparation(malaysiaCCList,curConvMap);
            errormessage = errormessage + finalspaval.errorMessage;
            //System.debug('@@finalspaval'+finalspaval);
            if(!routebackbonelist.isEmpty()){
                System.debug('@@routebackbonelistIsNotEmpty');
                formWrapAMVMYList = ffcntrlr.formulaforDepotDataAMVMY(malaysiaCCList,routebackbonelist);
                RE_MY_TransferPricePremiumController tpval = new RE_MY_TransferPricePremiumController();
                finaltppval = tpval.AMVtransferPricePremiumPreparation(formWrapAMVMYList,curConvMap);
                errormessage = errormessage + finaltppval.errorMessage;
                RE_MY_MarketPremiumController mpval = new RE_MY_MarketPremiumController();
                finalmpval = mpval.AMVmarketPremiumPreparation(formWrapAMVMYList,curConvMap,latestmarketquotes);
                errormessage = errormessage + finalmpval.errorMessage;
                RE_MY_BreakBulkFixedPremiumController bbfpval = new RE_MY_BreakBulkFixedPremiumController();
                finalbbpval = bbfpval.AMVbreakBulkFixedPremiumPreparation(formWrapAMVMYList,curConvMap,latestmarketquotes);
                errormessage = errormessage + finalbbpval.errorMessage;
                RE_MY_SmallLotPremiumController slval = new RE_MY_SmallLotPremiumController();
                finalslpval = slval.AMVslpDataPreparation(formWrapAMVMYList,curConvMap);
                errormessage = errormessage + finalslpval.errorMessage;
                RE_MY_PrimaryTransportCostController ptcval = new RE_MY_PrimaryTransportCostController();
                finalptval = ptcval.AMVprimaryTransportCostpreparation(formWrapAMVMYList,curConvMap);
                errormessage = errormessage + finalptval.errorMessage;
                RE_MY_MRFreightCostController mrfval = new RE_MY_MRFreightCostController();
                finalmrfval = mrfval.AMVmrfreightDataPreparation(formWrapAMVMYList,curConvMap,latestmarketquotes);
                errormessage = errormessage + finalmrfval.errorMessage;
                RE_MY_BioOilLosscontroller bolval = new RE_MY_BioOilLosscontroller();
                finalbolval = bolval.AMVbioOilLossDataPreparation(formWrapAMVMYList,finalbioval.finalval);
                errormessage = errormessage + finalbolval.errorMessage;
                RE_MY_PortChargeController pcval = new RE_MY_PortChargeController();
                finalpcval = pcval.AMVpcDataPreparation(formWrapAMVMYList,curConvMap);
                errormessage = errormessage + finalpcval.errorMessage;
                RE_MY_OilLossController olval = new RE_MY_OilLossController();
                finalolval = olval.AMVolDataPreparation(formWrapAMVMYList,finalhcval.finalval,finalmpval.finalval,finalslpval.finalval,finalmrfval.finalval,finalpcval.finalval);
                errormessage = errormessage + finalolval.errorMessage;
                RE_MY_StorageAndHandlingTariffController sahospval = new RE_MY_StorageAndHandlingTariffController();
                finalshospval = sahospval.shospPreparation(formWrapAMVMYList,curConvMap);
                errormessage = errormessage + finalshospval.errorMessage;
                RE_MY_COSteerController cosval = new RE_MY_COSteerController();
                finalcosval = cosval.shospPreparation(formWrapAMVMYList,curConvMap);
                errormessage = errormessage + finalcosval.errorMessage;
                //RE_FreightChargesController fcval = new RE_FreightChargesController();
                //finalfcval = fcval.frcPreparation(formWrapAMVMYList,curConvMap);
                //errormessage = errormessage + finalfcval.errorMessage;
                routebasedcostingData();
            }
            return finaldepotbasedCostingData(jra);
        }
        return false;
    }
    
    public void routebasedcostingData(){
        Double finalvalue;
        Double coValue;
        Id rectypeId = Schema.SObjectType.RE_Route_Based_Costing__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        List<RE_Route_Based_Costing__c> updateLatestData = new List<RE_Route_Based_Costing__c>();
        List<RE_Route_Based_Costing__c> costDataLatest = [SELECT RE_IsLatest__c FROM RE_Route_Based_Costing__c WHERE RE_IsLatest__c = True AND recordtypeid =: rectypeId];
        if(!costDataLatest.isEmpty()){
            for(RE_Route_Based_Costing__c rbcMY : costDataLatest){
                rbcMY.RE_IsLatest__c = False;
                updateLatestData.add(rbcMY);
            }
        }
        for(RE_MY_FormulaFetchController.formulaWrapperAMVMY rbdata : formWrapAMVMYList){
            finalvalue = 0;
            coValue = 0;
            RE_Route_Based_Costing__c rbcostdata = new RE_Route_Based_Costing__c();
            rbcostdata.recordtypeId=rectypeId;
            rbcostdata.RE_Route_Backbone__c = rbdata.hcfObj.Id;
            rbcostdata.RE_Depot_Pricing_Backbone__c = rbdata.depoId;
            rbcostdata.RE_IsLatest__c = True;
            rbcostdata.RE_Costprice_Unit__c = rbdata.finalUnit;
            rbcostdata.RE_Transfer_Price_Premium__c = finaltppval.finalval.containskey(rbdata.hcfObj.Id) ? finaltppval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Market_Premium__c = finalmpval.finalval.containskey(rbdata.hcfObj.Id) ? finalmpval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Breakbulk_Premium__c = finalbbpval.finalval.containskey(rbdata.hcfObj.Id) ? finalbbpval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Small_Lot_Premium__c = finalslpval.finalval.containskey(rbdata.hcfObj.Id) ? finalslpval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Primary_Transport_Cost__c = finalptval.finalval.containskey(rbdata.hcfObj.Id) ? finalptval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_MR_Freight_Cost__c = finalmrfval.finalval.containskey(rbdata.hcfObj.Id) ? finalmrfval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Bio_Loss__c = finalbolval.finalval.containskey(rbdata.hcfObj.Id) ? finalbolval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Port_Charges_Cost__c = finalpcval.finalval.containskey(rbdata.hcfObj.Id) ? finalpcval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Oil_Loss__c = finalolval.finalval.containskey(rbdata.hcfObj.Id) ? finalolval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_Storage_Handling_OSP__c = finalshospval.finalval.containskey(rbdata.hcfObj.Id) ? finalshospval.finalval.get(rbdata.hcfObj.Id) : 0;
            rbcostdata.RE_CO_Steer__c = finalcosval.finalval.containskey(rbdata.hcfObj.Id) ? finalcosval.finalval.get(rbdata.hcfObj.Id) : 0;
            //rbcostdata.RE_Freight_Pipeline_Charges__c = finalfcval.finalval.containskey(rbdata.hcfObj.Id) ? finalfcval.finalval.get(rbdata.hcfObj.Id) : 0;
            
            finalvalue = rbdata.hcfObj.RE_Route_Utilization__c/100 * ( rbcostdata.RE_Bio_Loss__c + rbcostdata.RE_Breakbulk_Premium__c +
                                                                      rbcostdata.RE_Market_Premium__c + rbcostdata.RE_MR_Freight_Cost__c +  rbcostdata.RE_Oil_Loss__c + rbcostdata.RE_Port_Charges_Cost__c +
                                                                      rbcostdata.RE_Small_Lot_Premium__c + rbcostdata.RE_Primary_Transport_Cost__c + rbcostdata.RE_Storage_Handling_OSP__c +
                                                                      rbcostdata.RE_Transfer_Price_Premium__c + rbcostdata.RE_CO_Steer__c/* + rbcostdata.RE_Freight_Pipeline_Charges__c*/);
            
            coValue = rbdata.hcfObj.RE_Route_Utilization__c/100 * rbcostdata.RE_CO_Steer__c;
            
	    if(depotweightedCOvalMap.containsKey(rbcostdata.RE_Depot_Pricing_Backbone__c)){
                depotweightedCOvalMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c,depotweightedCOvalMap.get(rbcostdata.RE_Depot_Pricing_Backbone__c) + coValue);
            }
            else {
                depotweightedCOvalMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c, coValue);
	    }
            
            if(depotweightedMap.containsKey(rbcostdata.RE_Depot_Pricing_Backbone__c)){
                depotweightedMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c,depotweightedMap.get(rbcostdata.RE_Depot_Pricing_Backbone__c) + finalvalue);
            }
            else {
                depotweightedMap.put(rbcostdata.RE_Depot_Pricing_Backbone__c, finalvalue);
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
            System.debug('Error on inserting RE_Route_Based_Costing__c');
        }
    }
    
    public Boolean finaldepotbasedCostingData(RE_Job_Run_Audit__c jra){
        Boolean Issuccess;
        Id rectypeId = Schema.SObjectType.RE_Depot_Based_Costing__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        if(String.isEmpty(errormessage)){
            Map<String,Double> costpricemap = RE_SOQLController.fetchlatestMYCostPrice();
            List<RE_Depot_Based_Costing__c> costingList = new List<RE_Depot_Based_Costing__c>();
            List<RE_Depot_Based_Costing__c> updateLatestData = new List<RE_Depot_Based_Costing__c>();
            List<RE_Depot_Based_Costing__c> deletetodaysData = new List<RE_Depot_Based_Costing__c>();
            List<RE_Depot_Based_Costing__c> costDataLatest = [SELECT createddate,RE_IsLatest__c FROM RE_Depot_Based_Costing__c WHERE RE_IsLatest__c = True AND recordtypeId =: rectypeId];
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
                                                       WHERE createddate = Today AND RE_Job_Type__c = 'Malaysia AMV Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
            if(!costDataToday.isEmpty())
                jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
            for(RE_Depot_Pricing_Backbone__c dpbdata : malaysiaCCList){
                remarks = '';
                if(depotweightedMap.containskey(dpbdata.Id)) {
                    RE_Depot_Based_Costing__c costData = new RE_Depot_Based_Costing__c();
                    costData.RE_Job_Run_Count__c = jobCount;
                    costData.recordtypeId=rectypeId;
                    costData.RE_IsLatest__c = True;
                    costData.RE_Depot_Pricing_Backbone__c = dpbdata.Id;
                    costData.RE_HCV_Value__c = finalhcval.finalval.containskey(dpbdata.Id) ? finalhcval.finalval.get(dpbdata.Id) : 0;
                    costData.RE_Bio_Value__c = finalbioval.finalval.containskey(dpbdata.Id) ? finalbioval.finalval.get(dpbdata.Id) : 0;
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
                    if(costpricemap.containsKey(dpbdata.RE_Depot_Name__c+'_'+dpbdata.RE_Product_Name__c))
                        costData.RE_Morning_CBU_Value__c = costpricemap.get(dpbdata.RE_Depot_Name__c+'_'+dpbdata.RE_Product_Name__c);
                    costingList.add(costData);
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
    public Static List<Aggregateresult> fetchProductAMVoutputdata(String country){
        Id recordType= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        return ([Select RE_Product__r.Name from  RE_MOA__c where RE_Country__r.Name =:country AND RE_IsLatest__c = True AND RecordTypeId = :recordType group by RE_Product__r.Name]);
    }
    @AuraEnabled
    public Static List<RE_MOA__c> fetchAMVoutputdata(String prodName){
        Id recordType= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        System.debug('prodName->'+prodName);
        return ([Select Id,RE_Depot_Name__r.RE_Region_Name__c,RE_Depot_Name__r.Name,RE_MC_Morning__c,RE_Prev_Mid_Day_price_out__c,RE_Today_s_BSP__c,RE_Target_Margin__c,
                 RE_PSP__c,RE_Final_PSP__c,RE_Remark__c,RE_Spot_Price_Adj__c,RE_AM_Challenged_Price__c,RE_Agreed_PSP__c,RE_AM_Comments__c,RE_isDisabled__c,RE_Mid_Day_price_out__c,
                 RE_Price_Value__c from  RE_MOA__c where RE_IsLatest__c = True and RE_Product__r.Name = :prodName AND RecordTypeId = :recordType
                 order by RE_Depot_Name__r.RE_Region_Name__c]);
    }
    @AuraEnabled
    public Static void saveAMVdata(List<RE_MOA__c> amvupdatedList){
        System.debug('amvupdatedList--'+amvupdatedList);
        try{
            update amvupdatedList;
        }
        catch(Exception ex){
            System.debug('Failed to update'+ex.getMessage());
        }
    }
    
    @Auraenabled
    public Static List<AggregateResult> fetchSalesTaxHeaderData(){
        return ([SELECT RE_Product_Type__c FROM RE_Sales_Tax__c where  RE_Valid_From__c<= Today AND RE_Valid_To__c>= Today group by RE_Product_Type__c  order by RE_Product_Type__c ]);
    }
    
    @Auraenabled
    public Static List<Decimal> fetchSalesTaxData(String region){
        Map<String, Decimal> vallist = new Map<String,Decimal>();
        Map<String, Decimal> finalvallist = new Map<String,Decimal>();
        String soql = 'SELECT RE_Product_Type__c,RE_Tax_Value__c,RE_Region__c FROM RE_Sales_Tax__c WHERE RE_Region__c includes (\''+region+'\') AND RE_Valid_From__c<= Today AND RE_Valid_To__c>= Today ORDER BY RE_Product_Type__c';
        List<RE_Sales_Tax__c> sobjList = Database.query(soql);
        for (RE_Sales_Tax__c stdata : sobjList){
            vallist.put(stdata.RE_Product_Type__c,stdata.RE_Tax_Value__c);
        }
        
        for(Aggregateresult pdtype : fetchSalesTaxHeaderData()){
            if(vallist.containskey((String)pdtype.get('RE_Product_Type__c')))
                finalvallist.put((String)pdtype.get('RE_Product_Type__c'),vallist.get((String)pdtype.get('RE_Product_Type__c')));
            else
                finalvallist.put((String)pdtype.get('RE_Product_Type__c'),0);
        }
        System.debug('finalvallist-->'+finalvallist.values());
        return finalvallist.values();
    }
    
    public class compDataWrapper{
        @AuraEnabled
        public String product{get;set;}
        @AuraEnabled
        public Double cbumovement{get;set;}
        @AuraEnabled
        public Double previousmidday{get;set;}
        @AuraEnabled
        public Double todaymidday{get;set;}        
    }
    
    @Auraenabled
    public static List<compDataWrapper> fetchcompareData(){
        Map<String, compDataWrapper> compdataList = new Map<String, compDataWrapper>();
        RE_MY_Output__c outputList = [SELECT RE_Gasoil_B7_0_05_S_MC_Diff__c,RE_Gasoil_B0_0_05_S_MC_Diff__c,RE_Gasoil_B0_0_001_S_MC_Diff__c,RE_Gasoil_B7_0_001_S_MC_Diff__c,RE_MOGAS_95_MC_Diff__c FROM RE_MY_Output__c
                                      WHERE RE_Type__c = 'Malaysia Output' AND RE_Depot_Name__c = 'Bagan Luar'
                                      ORDER BY CREATEDDATE DESC LIMIT 1];
        Map<String, Double> todayMiddayMap = new Map<String, Double>();
        for(RE_Midday_Pricing__c middaytoday : [
            SELECT RE_Product__c, RE_Midday_Forecast_Price__c FROM RE_Midday_Pricing__c
            WHERE RE_Product__c IN ('E5 GO B7','E5 GO B0','U95')
            AND CREATEDDATE = Today]){
                todayMiddayMap.put(middaytoday.RE_Product__c,middaytoday.RE_Midday_Forecast_Price__c);
            }
        for(RE_Midday_Pricing__c middayList : [
            SELECT RE_Product__c, RE_Midday_Forecast_Price__c FROM RE_Midday_Pricing__c
            WHERE RE_Product__c IN ('E5 GO B7','E5 GO B0','U95')
            AND CREATEDDATE != Today
            AND CREATEDDATE = LAST_N_DAYS : 7
            ORDER BY CREATEDDATE DESC
        ]){
            compDataWrapper cmdata = new compDataWrapper();
            cmdata.previousmidday = middayList.RE_Midday_Forecast_Price__c;
            if(todayMiddayMap.containsKey(middayList.RE_Product__c))
            	cmdata.todaymidday = todayMiddayMap.get(middayList.RE_Product__c);
            if(middayList.RE_Product__c == 'E5 GO B7'){
                cmdata.product = 'E2 B7';
                cmdata.cbumovement = outputList.RE_Gasoil_B7_0_05_S_MC_Diff__c != null ? outputList.RE_Gasoil_B7_0_05_S_MC_Diff__c : 0;
            }
            if(middayList.RE_Product__c == 'E5 GO B0'){
                cmdata.product = 'E2 B0';
                cmdata.cbumovement = outputList.RE_Gasoil_B0_0_05_S_MC_Diff__c != null ? outputList.RE_Gasoil_B0_0_05_S_MC_Diff__c : 0;
            }
            if(middayList.RE_Product__c == 'U95'){
                cmdata.product = 'U95';
                cmdata.cbumovement = outputList.RE_MOGAS_95_MC_Diff__c != null ? outputList.RE_MOGAS_95_MC_Diff__c : 0;
            }
            if(!compdataList.containsKey(cmdata.product))
                compdataList.put(cmdata.product,cmdata);
        }
        return compdataList.values();
    }
    
    @AuraEnabled
    public Static RE_MOA__c submitForApproval(RE_MOA__c datToApprovalProcess){
        system.debug('datToApprovalProcess--'+datToApprovalProcess);
        try{
            if(datToApprovalProcess.RE_AM_Challenged_Price__c >= datToApprovalProcess.RE_Final_PSP__c ){
                datToApprovalProcess.RE_Status__c='Auto Approved';
                datToApprovalProcess.RE_Agreed_PSP__c =datToApprovalProcess.RE_AM_Challenged_Price__c;
                datToApprovalProcess.Challenged_User__c =UserInfo.getUserId();
                
                update datToApprovalProcess;
            }
            else{
                datToApprovalProcess.RE_Status__c='Submitted';
                datToApprovalProcess.Challenged_User__c =UserInfo.getUserId();
                update datToApprovalProcess;
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments(datToApprovalProcess.RE_AM_Comments__c);
                req.setObjectId(datToApprovalProcess.id);
                // Submit the approval request for the Opportunity        
                Approval.ProcessResult result = Approval.process(req);
                
                FeedItem feed = new FeedItem();
                feed.ParentId =datToApprovalProcess.id;
                feed.Body =  'Record is submitted to an approval process \n Comments: '+datToApprovalProcess.RE_AM_Comments__c+'\n AM Challenged Price :'+ datToApprovalProcess.RE_AM_Challenged_Price__c+'\n Final PSP :'+ datToApprovalProcess.RE_Final_PSP__c;
                feed.IsRichText =false;
                insert feed;
            }
            
        }catch(exception ex){
            system.debug('excetion'+ex);
            throw new AuraException(ex.getMessage());
        }
        return datToApprovalProcess;
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
    
    @AuraEnabled
    public Static Map<String,string > generateCustomOppdata(){
        Map<String,string > message= new Map<String,string>();
        List<RE_Job_Run_Audit__c> custJobcount=new List<RE_Job_Run_Audit__c>();
        //checks customs opps data is created or not
        custJobcount=[select id ,RE_Job_Status__c from RE_Job_Run_Audit__c where RE_Job_Type__c='CustomerOps Output' AND createdDate=today AND RE_IsSuccess__c=true AND (RE_Job_Status__c = 'Completed' OR RE_Job_Status__c = 'Processing')];
        if(custJobcount.size() > 0) {
            //send error message to UI 
            message.put('Error','true');
            if(custJobcount[0].RE_Job_Status__c == 'Completed')
                message.put('message','Custom opps data has been generated already, please check with Admin');
            else 
                message.put('message','Custom opps data still processing, Please refresh page after 2mins');
        } 
        else{
            //Check holiday Saturday or Sunday (There is no CBU on  Saturday / Sunday and public holiday)
            List<String> holidaysDate= new List<String>();
            for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
                holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
            
            Datetime currentDay = (DateTime)System.today();
            String dayOfWeek = currentDay.format('EEEE');
            boolean checkNotHoliday = true;
            if( dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday' || holidaysDate.contains(string.valueof(currentDay)))
               checkNotHoliday = false;
            
            //Insert a job to create custom opps data
            RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
            insertJob.RE_Run_Type__c='Manual';
            insertJob.RE_Job_Type__c = 'CustomerOps Output';
            insertJob.RE_User__c=UserInfo.getUserId();
            insertJob.RE_Run_Time__c=DateTime.now();
            insertJob.RE_Job_Run_Count__c = 0;
            insertJob.RE_Job_Status__c = 'Processing';
            
            if(checkNotHoliday){
                insert insertJob;
                message.put('Error','false');
                message.put('message','Job Triggered Successfully');
            }
            else{
                message.put('Error','true');
                string errormessage;
                if(holidaysDate.contains(string.valueof(currentDay)))
                    errormessage = 'Customer Opps data will not be generate due to Public holiday';
                else
                    errormessage = 'Saturday and Sunday ther will be no midDay';
                message.put('message',errormessage);
            }
        }  
        
        return message;
    }
    
    @AuraEnabled
    public Static Map<String , List<RE_customerOppWrapper.ProductListprice>>  getDirectListPrice(){
        Map<String , RE_MOA__c> directList = new Map<String , RE_MOA__c>();
        Map<String , RE_MOA__c> lastWeekListPrice = new Map<String , RE_MOA__c>();
        List<String> salesOrg = new List<String>();
        Map<String , List<RE_customerOppWrapper.ProductListprice>> orgTpPro = new Map<String , List<RE_customerOppWrapper.ProductListprice>>();
        
        Date validFrom , ValidTo;
        List<String> holidaysDate= new List<String>();
        Datetime currentDay = (DateTime)System.today();
        Datetime D_1 = currentDay.adddays(1);      
        
        String dayOfWeek = currentDay.format('EEEE');
        String D_1dayOfWeek = D_1.format('EEEE');
        
        for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
            holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        
        //current week start and End date and Next week start and End Date
        date todaysDate = System.today();
        date weekStart = todaysDate.toStartofWeek();
        date weekEnd = weekStart.addDays(6);
        date nextweekSt = weekStart.addDays(7);
        date nextweekEd = nextweekSt.addDays(6);
        
        if(dayOfWeek == 'Friday' || dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday' ||  ( D_1dayOfWeek == 'Thursday' && holidaysDate.contains(string.valueof(D_1) ))
               || ( dayOfWeek == 'Thursday' && holidaysDate.contains(string.valueof(D_1) ))  ){
            validFrom = nextweekSt;
            ValidTo = nextweekEd;
            directList = getMOAmap(false);
            system.debug('directList--'+directList.size());
            if(directList.size() == 0){
                List<RE_MOA__c> nextweekdata = new List<RE_MOA__c>();
                lastWeekListPrice = getMOAmap(true);
                for(RE_MOA__c lastweekdata :lastWeekListPrice.values() ){
                    lastweekdata.id = null;
                    lastweekdata.RE_valid_from__c = nextweekSt;
                    lastweekdata.RE_valid_to__c = nextweekEd;
                    nextweekdata.add(lastweekdata);
                }
                if(!nextweekdata.isEmpty())
                    insert nextweekdata;
                
                directList = getMOAmap(false);
            }
        }
        else{
            validFrom = weekStart;
            ValidTo = weekEnd;
            directList = getMOAmap(true);
        }
        
        for(RT_Setting__c  salesorgvalues : [SELECT Name, Id, Value__c, Type__c FROM RT_Setting__c where recordtype.name='MY Code Value Mapping' AND TYPE__C ='MY Sales'] )
            salesOrg.add(salesorgvalues.Value__c);
        
        for(RE_Product__c prodList : [SELECT Id, RE_Product_Short_Name__c,RE_Material__c, RE_Product_Group__c, RE_Product_Code__c, Name FROM RE_Product__c where recordtype.name= 'Malaysia' AND Active__c = true order by Name  asc ]){
            For(String saleorgvalues : salesOrg ){
                RE_customerOppWrapper.ProductListprice prod = new RE_customerOppWrapper.ProductListprice();
                prod.product = prodList.Name ; 
                prod.material = prodList.RE_Material__c;
                prod.productId = prodList.id ; 
                prod.validFrom = validFrom;
                prod.validTo = ValidTo;
                prod.listPrice = directList.containsKey(saleorgvalues+'_'+prodList.Name) ?  String.valueOf( directList.get(saleorgvalues+'_'+prodList.Name).RE_Final_PSP__c):'0' ;
                prod.Id = directList.containsKey(saleorgvalues+'_'+prodList.Name) ?  String.valueOf( directList.get(saleorgvalues+'_'+prodList.Name).Id):'';
                prod.salesOrgProduct = saleorgvalues+'_'+prodList.Name;
                prod.SalesOrg = saleorgvalues;                
                
                List<RE_customerOppWrapper.ProductListprice> prodOrgmap = new List<RE_customerOppWrapper.ProductListprice>();
                if(orgTpPro.containsKey(saleorgvalues)){
                    prodOrgmap = orgTpPro.get(saleorgvalues);
                    prodOrgmap.add(prod);
                    orgTpPro.put(saleorgvalues,prodOrgmap);
                }
                else{
                    prodOrgmap.add(prod);
                    orgTpPro.put(saleorgvalues,prodOrgmap);
                }
            }
        }        
        System.debug('End AMV Calcu - getDirectListPrice Method Class DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime());
        return orgTpPro;
    }
    
    @AuraEnabled
    public Static void  updateDirectLisprice( List<RE_customerOppWrapper.ProductListprice> updateData){
        system.debug('data in apex'+updateData);
        Id moarectypeid = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('RE MY List Price').getRecordTypeId();
        Map<String , RE_MOA__c> directList = new Map<String , RE_MOA__c>();
        List<RE_MOA__c> updateListprice = new List<RE_MOA__c>();
        List<String> holidaysDate= new List<String>();
        Datetime currentDay = (DateTime)System.today();
        Datetime D_1 = currentDay.adddays(1);      
        
        String dayOfWeek = currentDay.format('EEEE');
        String D_1dayOfWeek = D_1.format('EEEE');
        
        for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
            holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
        
        if(dayOfWeek == 'Friday' || dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday' ||  ( D_1dayOfWeek == 'Thursday' && holidaysDate.contains(string.valueof(D_1) )))
            directList = getMOAmap(false);        
        else
            directList = getMOAmap(true);
        
        for(RE_customerOppWrapper.ProductListprice listPricevalue:updateData){
            RE_MOA__c updatedListPrice = new RE_MOA__c();
            if(directList.containsKey(listPricevalue.salesOrgProduct)){
                updatedListPrice = directList.get(listPricevalue.salesOrgProduct);
                updatedListPrice.RE_Final_PSP__c = decimal.valueOf( listPricevalue.listPrice);
                updateListprice.add(updatedListPrice);
            }
            else{
                updatedListPrice.RE_Final_PSP__c = decimal.valueOf( listPricevalue.listPrice);
                updatedListPrice.RE_Product__c = listPricevalue.productId;
                updatedListPrice.RecordTypeId = moarectypeid;
                updatedListPrice.RE_Sales_org__c = listPricevalue.SalesOrg;
                updatedListPrice.RE_valid_from__c = listPricevalue.validFrom;
                updatedListPrice.RE_valid_to__c = listPricevalue.validTo;
                updateListprice.add(updatedListPrice);
            }
        }
        
        upsert updateListprice;
        system.debug('update is done');
    }
    
    public static Map<String , RE_MOA__c> getMOAmap(boolean isDataforCurrentweek){
        Map<String , RE_MOA__c> directList = new Map<String , RE_MOA__c>();
        List<RE_MOA__c> moaData = new list<RE_MOA__c>();
        
        if(isDataforCurrentweek)
            moaData =[SELECT Name, Id, RE_Product__c,RE_Product__r.name, RE_Final_PSP__c, RE_valid_to__c, RE_valid_from__c, RE_Sales_org__c FROM RE_MOA__c where recordtype.name ='RE MY List Price' AND RE_valid_to__c = this_week AND RE_valid_from__c = this_week];
        else
            moaData =[SELECT Name, Id, RE_Product__c,RE_Product__r.name, RE_Final_PSP__c, RE_valid_to__c, RE_valid_from__c, RE_Sales_org__c FROM RE_MOA__c where recordtype.name ='RE MY List Price' AND RE_valid_to__c = next_week AND RE_valid_from__c = next_week];
        
        for(RE_MOA__c ListPrice :moaData){
            directList.put(ListPrice.RE_Sales_org__c+'_'+ListPrice.RE_Product__r.name , ListPrice);
        }
        
        return directList;
    }

    @AuraEnabled
    public Static void checkPM_EMPlantPrice( string region){
        List<String> location = new List<String>();
        String locationData;
        if(region == 'PM'){
            location.add('Peninsular');
			locationData = '(\'Peninsular\')';            
        }       
        else{
            location.add('Sarawak');
            location.add('Sabah');
            locationData = '(\'Sarawak\',\'Sabah\')';
        }
      
        getMoaData(location);
        RE_MY_CustOpsCalculationController.createListPrice();
        map<String ,RT_Setting__c> IntradayPricingList = RE_MY_CustOpsCalculationController.IntradayPricing;
        List<RT_Price_Book__c> todaysCBUvalues = new List<RT_Price_Book__c>();
        List<Id> contractid = New List<Id>();
        List<String> uniqueContracts = new List<String>();
        Double standdisc,listPriceTier;
        String WhereCondition =' RT_Location__r.RE_Region_Name__c IN '+ locationData+' AND RE_Contract_Master__r.RE_Customer_Name__r.type =\'Reseller\' AND RE_Valid_To__c >= TODAY  AND RE_Is_CBU__c  = True  AND RE_Valid_From__c <=TODAY ';
        RE_customOppController.approvalscheme = RE_customOppController.approvalScheme('MY');
            
        for(RT_Price_Book__c resellerCBU : RE_MY_CustOpsCalculationController.getDirectpricebookdata(WhereCondition)){
            double finalPrice;
            RT_Price_Book__c newfuturepbdata = new RT_Price_Book__c ();
            string keyCOntracts = resellerCBU.RE_Sold_To_Number__c+'_'+resellerCBU.RE_Ship_To_Number__c+'_'+resellerCBU.RE_Contract_Master__r.RT_Material_Desc__r.RE_Material__c + '_'+resellerCBU.RE_Contract_Master__r.RT_Plant_Desc__r.RE_Location_Code__c;
            //uniqueContracts.add();
            newfuturepbdata = resellerCBU.clone(false, true, false, false);
            newfuturepbdata.id= null;
            standdisc = resellerCBU.RE_Contract_Master__r.RE_Standard_Discount__c != null ? resellerCBU.RE_Contract_Master__r.RE_Standard_Discount__c : 0.00;
            listPriceTier = double.valueof(resellerCBU.RE_Contract_Master__r.List_Price_Tier__r.Value__c != null ? resellerCBU.RE_Contract_Master__r.List_Price_Tier__r.Value__c : '0.00');
            string key = resellerCBU.RT_Location__r.Name+'_'+resellerCBU.RT_Product__r.Name;
            string curentProdkey = resellerCBU.RT_Location__r.Name+'_'+resellerCBU.RT_Product__r.Name +'_' +resellerCBU.RE_Sales_Org__c;
            string relevantKey = (IntradayPricingList.containsKey(curentProdkey) ? IntradayPricingList.get(curentProdkey).RE_Location__r.name + '_' + IntradayPricingList.get(curentProdkey).RE_Relevant_Product__c : '');
            double intradayPrice = double.valueOf( (IntradayPricingList.containsKey(curentProdkey) ? (IntradayPricingList.get(curentProdkey).Value__c != null ? IntradayPricingList.get(curentProdkey).Value__c : '0' ): '0'));
			newfuturepbdata.RE_Yesterday_Final_Price__c = resellerCBU.RE_Final_Price_Rebate__c;
            newfuturepbdata.RE_List_Price__c = moaMapPlantPrice.containsKey(key) ? moaMapPlantPrice.get(key).RE_Price_Value__c : (moaMapPlantPrice.containsKey(relevantKey) ? moaMapPlantPrice.get(relevantKey).RE_Price_Value__c : 0);
            newfuturepbdata.RE_List_Price__c = (newfuturepbdata.RE_List_Price__c +intradayPrice+listPriceTier);   

            finalPrice = newfuturepbdata.RE_List_Price__c - standdisc + (newfuturepbdata.RE_Transport_Charge__c != null ? newfuturepbdata.RE_Transport_Charge__c : 0) + (newfuturepbdata.RE_Service_SurChg__c != null ? newfuturepbdata.RE_Service_SurChg__c : 0);
            newfuturepbdata.RE_Final_Price_Rebate__c = (newfuturepbdata.RE_Contract_Master__r.RE_Round_Up__c ? RE_MY_CustOpsCalculationController.roundUpcustom(finalPrice) : finalPrice);
            newfuturepbdata.RE_Latest_price_dt__c = DateTime.now();    

            //RE_customOppController.approvalscheme = RE_customOppController.approvalScheme('MY');
            
            if( (moaMapPlantPrice.containsKey(key) || moaMapPlantPrice.containsKey(relevantKey)) 
               && resellerCBU.RE_List_Price__c != newfuturepbdata.RE_List_Price__c && !uniqueContracts.contains(keyCOntracts) ){
                todaysCBUvalues.add(RE_customOppController.updateApprovalScheme(newfuturepbdata , newfuturepbdata.RE_Contract_Master__r.RE_PH_Approval_Scheme__c , RE_customOppController.getMarginForApproval(newfuturepbdata,true))); 
                
               }
            uniqueContracts.add(keyCOntracts);
        } 
        system.debug('--'+todaysCBUvalues.size());
        if(todaysCBUvalues.size()>0)
            insert todaysCBUvalues;
    }

    public static void getMoaData(List<string> region){
        Id recordType= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        System.debug('prodName->'+region);

        for(RE_MOA__c resionBasedMOA : [Select Id,RE_Depot_Name__r.RE_Region_Name__c,RE_Depot_Name__r.Name,RE_Product__r.Name,RE_MC_Morning__c,RE_Prev_Mid_Day_price_out__c,RE_Today_s_BSP__c,RE_Target_Margin__c,
        RE_PSP__c,RE_Final_PSP__c,RE_Remark__c,RE_Spot_Price_Adj__c,RE_AM_Challenged_Price__c,RE_Agreed_PSP__c,RE_AM_Comments__c,RE_isDisabled__c,RE_Mid_Day_price_out__c,
        RE_Price_Value__c from  RE_MOA__c where RE_IsLatest__c = True and RE_Depot_Name__r.RE_Region_Name__c IN: region AND RecordTypeId =: recordType
        order by RE_Depot_Name__r.RE_Region_Name__c]){            
            if(resionBasedMOA.RE_Prev_Mid_Day_price_out__c != resionBasedMOA.RE_Price_Value__c && resionBasedMOA.RE_Price_Value__c != null && resionBasedMOA.RE_Price_Value__c != 0)
                moaMapPlantPrice.put(resionBasedMOA.RE_Depot_Name__r.Name+'_'+resionBasedMOA.RE_Product__r.Name, resionBasedMOA);
                      
        }  
       // return moaMapPlantPrice;
    }
}