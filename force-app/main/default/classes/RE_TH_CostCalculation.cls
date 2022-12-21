public class RE_TH_CostCalculation { 
    RE_SOQLController soqldata = new RE_SOQLController();
    //Get latest Depot pricing data
    public List<RE_Depot_Pricing_Backbone__c> thailandCCList = soqldata.fetchTHDepoPricingData();
    //Get Market Quotes Data
    public List<RE_Market_Quotes__c> latestmarketquotes = soqldata.fetchMarketQuotesTHData();
    //Get (HDGO,GTL,POME,ETHANOL) Quotes Data for Malaysia
    public List<RE_Bio_Quotes__c> latestbioquotes = soqldata.fetchThailandQuotesData('Thailand');
    //Get Malaysia product data
    public List<RE_Product__c> prodlist = RE_SOQLController.fetchThailandprodData('Thailand');
    //Get Latest Fx Data
    public Map<String,Double> curConvMap = soqldata.fetchLatestMidFxData();
    public List<RE_MY_FormulaFetchController.formulaWrapper> formWrapList = new List<RE_MY_FormulaFetchController.formulaWrapper>();

    public List<RE_MY_FormulaFetchController.formulaWrapperTH> formWrapListTH = new List<RE_MY_FormulaFetchController.formulaWrapperTH>();
	
    public RE_UtilitywrapperController.lineitemwraapper finalhcval;
   // public RE_UtilitywrapperController.lineitemwraapper finalbioval;
   // public RE_UtilitywrapperController.lineitemwraapper finaltppval;
   // public RE_UtilitywrapperController.lineitemwraapper finalmpval;
   // public RE_UtilitywrapperController.lineitemwraapper finalbbpval;
    public RE_UtilitywrapperController.lineitemwraapper finalrstval;		//sales tax
    public RE_UtilitywrapperController.lineitemwraapper finalsahval;
   // public RE_UtilitywrapperController.lineitemwraapper finalmasval;
   // public RE_UtilitywrapperController.lineitemwraapper finalslpval;
    public RE_UtilitywrapperController.lineitemwraapper finalolval;
    public RE_UtilitywrapperController.lineitemwraapper finalptval;
   // public RE_UtilitywrapperController.lineitemwraapper finalmrfval;
   // public RE_UtilitywrapperController.lineitemwraapper finalbolval;
   // public RE_UtilitywrapperController.lineitemwraapper finalpcval;  // port charges
    public RE_UtilitywrapperController.lineitemwraapper finalacval;		//aditive cost
    public Map<Id, Double> finalmccval = new Map<Id, Double>();
    public Map<Id,Double> laiddownCostMap = new Map<Id,Double>();
    public Map<Id,Double> marginalCostMap = new Map<Id,Double>();
    Map<String, String> quoteMapes = new  Map<String, String> ();
    public String errormessage = '';

    public Boolean lineItemsCalculation(RE_Job_Run_Audit__c jra){//RE_Job_Run_Audit__c jra
        if(Test.isRunningTest()){
            curConvMap.put('THB-USD',4.3720);
            curConvMap.put('BBL-USD',4.3720);
            curConvMap.put('STG-THB',4.3720);
        }
        if(!thailandCCList.isEmpty()){ 
            
            for(RE_Bio_Quotes__c rbq : latestbioquotes){
                latestmarketquotes.add(new RE_Market_Quotes__c(RE_Price__c=rbq.RE_Price__c,RE_Pricing_Date__c=rbq.RE_Pricing_Date__c,RE_Rate_Unit__c=rbq.RE_Bio_RateUnit__c,RE_Quote_Name__c=rbq.RE_Bio_Quotes_Name__c,RE_Country_Name__c = 'SG;PH;TH;MY'));
            	quoteMapes.put(rbq.RE_Bio_Quotes_Name__c,rbq.RE_Bio_Quotes_Name__c);
            }
            //fatch data from RE_Depot_Pricing_Backbone__c for TH wrt Product,Depot
            RE_MY_FormulaFetchController ffcntrlr = new RE_MY_FormulaFetchController();
            formWrapListTH = ffcntrlr.formulaforDepotDataTH(thailandCCList);
            //HCV calculation
            RE_TH_HCVController hcvcal = new RE_TH_HCVController();
            finalhcval =  hcvcal.hcfDataPreparation(formWrapListTH,curConvMap,latestmarketquotes,prodlist,quoteMapes);
            System.debug(finalhcval);
            errormessage = errormessage + finalhcval.errorMessage;
            RE_MY_AdditiveCostController acval = new RE_MY_AdditiveCostController();
            finalacval = acval.additivecostCalculation(thailandCCList,prodlist,curConvMap);
            System.debug(finalacval);
            errormessage = errormessage + finalacval.errorMessage;
            
            RE_MY_StorageAndHandlingTariffController sahval = new RE_MY_StorageAndHandlingTariffController();
            finalsahval = sahval.shtPreparation(thailandCCList,curConvMap);
            errormessage = errormessage + finalsahval.errorMessage;
            System.debug(finalsahval);

            RE_MY_PrimaryTransportCostController ptcval = new RE_MY_PrimaryTransportCostController();
            finalptval = ptcval.primaryTransportCostpreparation(thailandCCList,curConvMap);
            errormessage = errormessage + finalptval.errorMessage;
            System.debug(finalptval);

            //List<RE_MY_FormulaFetchController.formulaWrapperTH> olformList,Map<Id, Double> finalhcval,Map<Id, Double> finalmpval,List<RE_Product__c> prodlist
            /*RE_TH_OilLossController olval = new RE_TH_OilLossController();//finalmpval.finalval
            finalolval = olval.olDataPreparation(formWrapListTH,finalhcval.finalval,prodlist);
            errormessage = errormessage + finalolval.errorMessage;
            System.debug(finalolval);*/
			
			RE_MY_RecoverySalesTaxController rcst	= new RE_MY_RecoverySalesTaxController();
			finalrstval	=	rcst.recoverySalesTaxTHPreparation(thailandCCList,curConvMap,prodlist);
			errormessage = errormessage + finalrstval.errorMessage;
            System.debug(finalrstval);
			
            marginallaidDownCostCalculation();
            finalCostingData(jra);
        }
        return false;
    }
    
    public void marginallaidDownCostCalculation(){
        //finalbbpval,finalmasval,finalslpval,finalmrfval,finalbolval,finalpcval
		
        for(RE_Depot_Pricing_Backbone__c dpbdata : thailandCCList){
            Double marginalCost = 0;
            Double laidDownCost = 0;
            if(finalhcval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalhcval.finalval.get(dpbdata.Id);
			
            
            
            if(finalsahval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalsahval.finalval.get(dpbdata.Id);
            if(finalptval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalptval.finalval.get(dpbdata.Id);
			
            if(finalacval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalacval.finalval.get(dpbdata.Id);
			/*
            if(finalolval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalolval.finalval.get(dpbdata.Id);*/
			
			if(finalrstval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalrstval.finalval.get(dpbdata.Id);
			
            marginalCostMap.put(dpbdata.Id, marginalCost);

            //if(finalmccval.containsKey(dpbdata.Id))
                laidDownCost = marginalCost ;//+ finalmccval.get(dpbdata.Id);
            /*if(finalmasval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalmasval.finalval.get(dpbdata.Id);*/
            laiddownCostMap.put(dpbdata.Id,laidDownCost);
        }
    }
	public void finalCostingData(RE_Job_Run_Audit__c jra){
        Boolean Issuccess;
		Integer jobCount = 0;
        System.debug(String.isEmpty(errormessage)+'    '+errormessage);
        
        if(String.isEmpty(errormessage)){           
        
            List<RE_MY_CostPrice__c>costingList = new List<RE_MY_CostPrice__c>();
            List<RE_MY_CostPrice__c> updateLatestData = new List<RE_MY_CostPrice__c>();
            Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
                List<RE_MY_CostPrice__c> costDataLatest = [SELECT RE_IsLatest__c FROM RE_MY_CostPrice__c WHERE recordtypeId = : rectypeId AND RE_IsLatest__c = True];
                if(!costDataLatest.isEmpty()){
                    for(RE_MY_CostPrice__c costMY : costDataLatest){
                        costMY.RE_IsLatest__c = False;
                        updateLatestData.add(costMY);
                    }
                }
            List<RE_Job_Run_Audit__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
                WHERE createddate = Today AND RE_Job_Type__c = 'Thailand Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
            if(!costDataToday.isEmpty())
                    jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
            for(RE_Depot_Pricing_Backbone__c dpbdata : thailandCCList){
                
                RE_MY_CostPrice__c costData = new RE_MY_CostPrice__c();
                
                costData.recordtypeId=Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;//'0120C00000077tO';
                costData.RE_Job_Run_Count__c = jobCount;
                costData.RE_IsLatest__c = True;
                costData.RE_Country__c = dpbdata.RE_Country__c;
                costData.RE_Depot_Name__c = dpbdata.RE_Depot_Name__c;
                costData.RE_Product_Name__c = dpbdata.RE_Product_Name__c;
                costData.RE_Costprice_Unit__c = dpbdata.RE_Final_Price_Unit__c;
                costData.RE_Pricing_Date__c = System.today();
                if(finalhcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Hydrocarbon_Value__c = finalhcval.finalval.get(dpbdata.Id);
                /*if(finalolval.finalval.containsKey(dpbdata.Id))
                        costData.RE_Oil_Loss__c = finalolval.finalval.get(dpbdata.Id);*/
                if(finalsahval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Storage_Handling_Cost__c = finalsahval.finalval.get(dpbdata.Id);
                if(finalptval.finalval.containsKey(dpbdata.Id))
                        costData.RE_Primary_Transport_Cost__c = finalptval.finalval.get(dpbdata.Id);
                if(finalacval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Additive_Cost__c = finalacval.finalval.get(dpbdata.Id);
                if(laiddownCostMap.containsKey(dpbdata.Id))
                    costData.RE_Costprice_Laid_Down_Cost__c = laiddownCostMap.get(dpbdata.Id);
                if(finalrstval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Recovery_Sales_Tax__c = finalrstval.finalval.get(dpbdata.Id);
                    
                //if(marginalCostMap.containsKey(dpbdata.Id))
                  //      costData.RE_Costprice_Marginal_Cost__c = marginalCostMap.get(dpbdata.Id);
                costingList.add(costData);
            }
            if(!costingList.isEmpty()){
                    try{
                        if(!updateLatestData.isEmpty())
                            update updateLatestData;
                        insert costingList;
                        Issuccess = True;
                    }
                    catch(Exception e){
                        Issuccess = False;
                    }
                }
        }else{
            Issuccess = False;
        }
         try{
            jra.RE_IsSuccess__c = Issuccess;
            jra.RE_Exception__c = errormessage;
            update jra;
        }
        catch(Exception e){

        }
		
	}
}