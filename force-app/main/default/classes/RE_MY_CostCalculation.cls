public class RE_MY_CostCalculation{
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
    public Map<String,Double> curConvMap = soqldata.fetchLatestFxData();

    public List<RE_MY_FormulaFetchController.formulaWrapper> formWrapList = new List<RE_MY_FormulaFetchController.formulaWrapper>();

    public RE_UtilitywrapperController.lineitemwraapper finalhcval;
    public RE_UtilitywrapperController.lineitemwraapper finalbioval;
    public RE_UtilitywrapperController.lineitemwraapper finaltppval;
    public RE_UtilitywrapperController.lineitemwraapper finalmpval;
    public RE_UtilitywrapperController.lineitemwraapper finalbbpval;
    public RE_UtilitywrapperController.lineitemwraapper finalrstval;
    public RE_UtilitywrapperController.lineitemwraapper finalsahval;
    public RE_UtilitywrapperController.lineitemwraapper finalmasval;
    public RE_UtilitywrapperController.lineitemwraapper finalslpval;
    public RE_UtilitywrapperController.lineitemwraapper finalolval;
    public RE_UtilitywrapperController.lineitemwraapper finalptval;
    public RE_UtilitywrapperController.lineitemwraapper finalmrfval;
    public RE_UtilitywrapperController.lineitemwraapper finalbolval;
    public RE_UtilitywrapperController.lineitemwraapper finalpcval;
    public RE_UtilitywrapperController.lineitemwraapper finalacval;
    public Map<Id, Double> finalmccval = new Map<Id, Double>();
    public Map<Id,Double> laiddownCostMap = new Map<Id,Double>();
    public Map<Id,Double> marginalCostMap = new Map<Id,Double>();
    public String errormessage = '';

    public Boolean lineItemsCalculation(RE_Job_Run_Audit__c jra){
        if(!malaysiaCCList.isEmpty()){
            RE_MY_FormulaFetchController ffcntrlr = new RE_MY_FormulaFetchController();
            formWrapList = ffcntrlr.formulaforDepotData(malaysiaCCList,malformulalist);
            RE_MY_HcvBioController hcvcal = new RE_MY_HcvBioController();
            finalhcval = hcvcal.hcfDataPreparation(formWrapList,curConvMap,false,latestmarketquotes,latestbioquotes);
            errormessage = errormessage + finalhcval.errorMessage;
            finalbioval = hcvcal.hcfDataPreparation(formWrapList,curConvMap,true,latestmarketquotes,latestbioquotes);
            errormessage = errormessage + finalbioval.errorMessage;
            RE_MY_TransferPricePremiumController tpval = new RE_MY_TransferPricePremiumController();
            finaltppval = tpval.transferPricePremiumPreparation(formWrapList,curConvMap);
            errormessage = errormessage + finaltppval.errorMessage;
            RE_MY_MarketPremiumController mpval = new RE_MY_MarketPremiumController();
            finalmpval = mpval.marketPremiumPreparation(formWrapList,curConvMap,latestmarketquotes);
            errormessage = errormessage + finalmpval.errorMessage;
            RE_MY_BreakBulkFixedPremiumController bbfpval = new RE_MY_BreakBulkFixedPremiumController();
            finalbbpval = bbfpval.breakBulkFixedPremiumPreparation(formWrapList,curConvMap,latestmarketquotes);
            errormessage = errormessage + finalbbpval.errorMessage;
            RE_MY_RecoverySalesTaxController rstval = new RE_MY_RecoverySalesTaxController(prodlist);
            finalrstval = rstval.recoverySalesTaxPreparation(malaysiaCCList,curConvMap);
            errormessage = errormessage + finalrstval.errorMessage;
            RE_MY_StorageAndHandlingTariffController sahval = new RE_MY_StorageAndHandlingTariffController();
            finalsahval = sahval.shtPreparation(malaysiaCCList,curConvMap);
            errormessage = errormessage + finalsahval.errorMessage;
            RE_MY_MarketingSellingTariffController masval = new RE_MY_MarketingSellingTariffController();
            finalmasval = masval.mstPreparation(malaysiaCCList,curConvMap);
            errormessage = errormessage + finalmasval.errorMessage;
            RE_MY_SmallLotPremiumController slval = new RE_MY_SmallLotPremiumController();
            finalslpval = slval.slpDataPreparation(formWrapList,curConvMap);
            errormessage = errormessage + finalslpval.errorMessage;
            RE_MY_PrimaryTransportCostController ptcval = new RE_MY_PrimaryTransportCostController();
            finalptval = ptcval.primaryTransportCostpreparation(malaysiaCCList,curConvMap);
            errormessage = errormessage + finalptval.errorMessage;
            RE_MY_MRFreightCostController mrfval = new RE_MY_MRFreightCostController();
            finalmrfval = mrfval.mrfreightDataPreparation(formWrapList,curConvMap,latestmarketquotes);
            errormessage = errormessage + finalmrfval.errorMessage;
            RE_MY_BioOilLosscontroller bolval = new RE_MY_BioOilLosscontroller();
            finalbolval = bolval.bioOilLossDataPreparation(formWrapList,finalbioval.finalval);
            errormessage = errormessage + finalbolval.errorMessage;
            RE_MY_PortChargeController pcval = new RE_MY_PortChargeController();
            finalpcval = pcval.pcDataPreparation(formWrapList,curConvMap);
            errormessage = errormessage + finalpcval.errorMessage;
            RE_MY_OilLossController olval = new RE_MY_OilLossController();
            finalolval = olval.olDataPreparation(formWrapList,finalhcval.finalval,finalmpval.finalval,finalslpval.finalval,finalmrfval.finalval,finalpcval.finalval);
            errormessage = errormessage + finalolval.errorMessage;
            RE_MY_AdditiveCostController acval = new RE_MY_AdditiveCostController();
            finalacval = acval.additivecostCalculation(malaysiaCCList,prodlist,curConvMap);
            errormessage = errormessage + finalacval.errorMessage;
            finalmccval = MarkUpCreditChargeCalculation();
            marginallaidDownCostCalculation();
            return finalCostingData(jra);
        }
        return false;
    }

    public void marginallaidDownCostCalculation(){
        for(RE_Depot_Pricing_Backbone__c dpbdata : malaysiaCCList){
            Double marginalCost = 0;
            Double laidDownCost = 0;
            if(finalhcval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalhcval.finalval.get(dpbdata.Id);
            if(finalbioval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalbioval.finalval.get(dpbdata.Id);
            if(finaltppval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finaltppval.finalval.get(dpbdata.Id);
            if(finalmpval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalmpval.finalval.get(dpbdata.Id);
            if(finalbbpval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalbbpval.finalval.get(dpbdata.Id);
            if(finalrstval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalrstval.finalval.get(dpbdata.Id);
            if(finalsahval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalsahval.finalval.get(dpbdata.Id);
            if(finalslpval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalslpval.finalval.get(dpbdata.Id);
            if(finalptval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalptval.finalval.get(dpbdata.Id);
            if(finalmrfval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalmrfval.finalval.get(dpbdata.Id);
            if(finalbolval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalbolval.finalval.get(dpbdata.Id);
            if(finalpcval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalpcval.finalval.get(dpbdata.Id);
            if(finalacval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalacval.finalval.get(dpbdata.Id);
            if(finalolval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalolval.finalval.get(dpbdata.Id);
            marginalCostMap.put(dpbdata.Id, marginalCost);

            if(finalmccval.containsKey(dpbdata.Id))
                laidDownCost = marginalCost + finalmccval.get(dpbdata.Id);
            if(finalmasval.finalval.containsKey(dpbdata.Id))
                laidDownCost = laidDownCost + finalmasval.finalval.get(dpbdata.Id);
            laiddownCostMap.put(dpbdata.Id,laidDownCost);
        }
    }

    public Map<Id, Double> MarkUpCreditChargeCalculation(){
        Double mccpercentage = Double.valueOf(System.Label.RE_MY_MarkUp_Credit_Charge_Percentage);
        Double mccminVal = Double.valueOf(System.Label.RE_MY_MarkUp_Credit_Charge_Min_Value);
        for(RE_Depot_Pricing_Backbone__c dpbdata : malaysiaCCList){
            Double Markupvalue =0;
            Double finalMarkupCredit =0;
            if(finalhcval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalhcval.finalval.get(dpbdata.Id);
            if(finalbioval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalbioval.finalval.get(dpbdata.Id);
            if(finalbbpval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalbbpval.finalval.get(dpbdata.Id);
            if(finaltppval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finaltppval.finalval.get(dpbdata.Id);
            if(finalrstval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalrstval.finalval.get(dpbdata.Id);
            if(finalmpval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalmpval.finalval.get(dpbdata.Id);
            if(finalsahval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalsahval.finalval.get(dpbdata.Id);
            if(finalmasval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalmasval.finalval.get(dpbdata.Id);
            if(finalslpval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalslpval.finalval.get(dpbdata.Id);
            if(finalolval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalolval.finalval.get(dpbdata.Id);
            if(finalptval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalptval.finalval.get(dpbdata.Id);
            if(finalmrfval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalmrfval.finalval.get(dpbdata.Id);
            if(finalbolval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalbolval.finalval.get(dpbdata.Id);
            if(finalpcval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalpcval.finalval.get(dpbdata.Id);
            if(finalacval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalacval.finalval.get(dpbdata.Id);
            finalMarkupCredit = (Markupvalue*mccpercentage*1/365) > mccminVal ? (Markupvalue * mccpercentage * 1/365) : mccminVal;

            finalmccval.put(dpbdata.Id,finalMarkupCredit);
        }
        return finalmccval;
    }

    public Boolean finalCostingData(RE_Job_Run_Audit__c jra){
        Boolean Issuccess;
        if(String.isEmpty(errormessage)){
            List<RE_MY_CostPrice__c> costingList = new List<RE_MY_CostPrice__c>();
            List<RE_MY_CostPrice__c> updateLatestData = new List<RE_MY_CostPrice__c>();
            Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
            List<RE_MY_CostPrice__c> costDataLatest = [SELECT RE_IsLatest__c FROM RE_MY_CostPrice__c WHERE recordtypeId = : rectypeId AND RE_IsLatest__c = True];
            if(!costDataLatest.isEmpty()){
                for(RE_MY_CostPrice__c costMY : costDataLatest){
                    costMY.RE_IsLatest__c = False;
                    updateLatestData.add(costMY);
                }
            }
            Integer jobCount = 0;
            List<RE_Job_Run_Audit__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
            WHERE createddate = Today AND RE_Job_Type__c = 'Malaysia Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
            if(!costDataToday.isEmpty())
                jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
            for(RE_Depot_Pricing_Backbone__c dpbdata : malaysiaCCList){
                RE_MY_CostPrice__c costData = new RE_MY_CostPrice__c();
                costData.recordtypeId=Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
                costData.RE_Job_Run_Count__c = jobCount;
                costData.RE_IsLatest__c = True;
                costData.RE_Country__c = dpbdata.RE_Country__c;
                costData.RE_Depot_Name__c = dpbdata.RE_Depot_Name__c;
                costData.RE_Product_Name__c = dpbdata.RE_Product_Name__c;
                costData.RE_Costprice_Unit__c = dpbdata.RE_Final_Price_Unit__c;
                costData.RE_Pricing_Date__c = System.today();
                if(finalhcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Hydrocarbon_Value__c = finalhcval.finalval.get(dpbdata.Id);
                if(finalbioval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Bio_Cost__c = finalbioval.finalval.get(dpbdata.Id);
                if(finalmpval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Market_Premium__c = finalmpval.finalval.get(dpbdata.Id);
                if(finalbbpval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Breakbulk_Premium__c = finalbbpval.finalval.get(dpbdata.Id);
                if(finalmasval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Marketing_Selling_Tariff__c = finalmasval.finalval.get(dpbdata.Id);
                if(finalolval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Oil_Loss__c = finalolval.finalval.get(dpbdata.Id);
                if(finalslpval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Small_Lot_Premium__c = finalslpval.finalval.get(dpbdata.Id);
                if(finalsahval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Storage_Handling_Cost__c = finalsahval.finalval.get(dpbdata.Id);
                if(finaltppval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Transfer_Price_Premium__c = finaltppval.finalval.get(dpbdata.Id);
                if(finalptval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Primary_Transport_Cost__c = finalptval.finalval.get(dpbdata.Id);
                if(finalmrfval.finalval.containsKey(dpbdata.Id))
                    costData.RE_MR_Freight_Cost__c = finalmrfval.finalval.get(dpbdata.Id);
                if(finalbolval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Bio_Loss__c = finalbolval.finalval.get(dpbdata.Id);
                if(finalpcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Port_Charges_Cost__c = finalpcval.finalval.get(dpbdata.Id);
                if(finalrstval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Recovery_Sales_Tax__c = finalrstval.finalval.get(dpbdata.Id);
                if(finalacval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Additive_Cost__c = finalacval.finalval.get(dpbdata.Id);
                if(marginalCostMap.containsKey(dpbdata.Id))
                    costData.RE_Costprice_Marginal_Cost__c = marginalCostMap.get(dpbdata.Id);
                if(finalmccval.containsKey(dpbdata.Id))
                    costData.RE_Mark_Up_Credit_Charge__c = finalmccval.get(dpbdata.Id);
                if(laiddownCostMap.containsKey(dpbdata.Id))
                    costData.RE_Costprice_Laid_Down_Cost__c = laiddownCostMap.get(dpbdata.Id);
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
                    System.debug('RE_MY_CostCalculation-finalCostingData-Error-->'+e.getMessage());
                    System.debug('RE_MY_CostCalculation-finalCostingData-Error-LN-->'+e.getLineNumber());
                    RV_ClassException.insertExceptionRecord('finalCostingData',e.getMessage()+'-'+e.getLineNumber(),'RE_MY_CostCalculation','finalCostingData','Exception');                          
                }
            }
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
            System.debug('RE_MY_CostCalculation-finalCostingData-Update JRA-Error-->'+e.getMessage());
            System.debug('RE_MY_CostCalculation-finalCostingData-Update JRA-Error-LN-->'+e.getLineNumber());
            RV_ClassException.insertExceptionRecord('finalCostingData-Update JRA-',e.getMessage()+'-'+e.getLineNumber(),'RE_MY_CostCalculation','finalCostingData','Exception'); 
        }
        return Issuccess;
    }
}