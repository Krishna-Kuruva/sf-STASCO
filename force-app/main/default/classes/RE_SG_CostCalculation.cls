public class RE_SG_CostCalculation {  
    RE_SOQLController soqldata = new RE_SOQLController();
    //Get latest Depot pricing data  
    public List<RE_Depot_Pricing_Backbone__c> depotpricinglist = soqldata.fetchSGDepotpricingData();
    //Get Market Quotes Data
    public List<RE_Market_Quotes__c> latestmarketquotes;
    //Get Singapore formula data
    public List<RE_SG_Cost_Price_Manager__mdt> sgformulalist = soqldata.fetchSingaporeformulaData();
    //Get Singapore product data
    public List<RE_Product__c> productlist = RE_SOQLController.fetchSingaporeprodData();
    //Get Latest Fx Data
    public Map<String,Double> curConvMap;
    public Double curconvDD = soqldata.fetchLastMondayFxData();
    public Double currencyConversionMultipler;
    public List<RE_MY_FormulaFetchController.formulaWrapperSG> formWrapList = new List<RE_MY_FormulaFetchController.formulaWrapperSG>();

    public RE_UtilitywrapperController.lineitemwraapper finalhcval;
    public RE_UtilitywrapperController.lineitemwraapper finalmpval;
    public RE_UtilitywrapperController.lineitemwraapper finalsahval;
    public RE_UtilitywrapperController.lineitemwraapper finalmasval;
    public RE_UtilitywrapperController.lineitemwraapper finalolval;
    public RE_UtilitywrapperController.lineitemwraapper finalptval;
    public RE_UtilitywrapperController.lineitemwraapper finalacval;
    public RE_UtilitywrapperController.lineitemwraapper finalddval;
    public RE_UtilitywrapperController.lineitemwraapper finalfpval;
    public RE_UtilitywrapperController.lineitemwraapper finalcpaval;

    public Map<Id, Double> finalmccval = new Map<Id, Double>();
    public Map<Id,Double> laiddownCostMap = new Map<Id,Double>();
    public Map<Id,Double> marginalCostMap = new Map<Id,Double>();
    public Map<Id,Double> laiddownCostMapSG = new Map<Id,Double>();
    public Map<Id,Double> marginalCostMapSG = new Map<Id,Double>();
    public String errormessage = '';

    public Boolean lineItemsCalculation(RE_Job_Run_Audit__c jra){
        if(!depotpricinglist.isEmpty()){
            RE_MY_FormulaFetchController ffcntrlr = new RE_MY_FormulaFetchController();
            formWrapList = ffcntrlr.formulaforDepotDataSG(depotpricinglist,sgformulalist);
            system.debug(formWrapList);
            if(jra.RE_Job_Type__c == 'Singapore Output'){
                latestmarketquotes = soqldata.fetchMarketQuotesData();
				curConvMap = soqldata.fetchLatestFxData();				                
            }
            else if(jra.RE_Job_Type__c == 'SG Midday Output'){
                latestmarketquotes = soqldata.fetchMiddayMarketQuotesData();
				curConvMap = soqldata.fetchLatestMidFxData();				
            }
			currencyConversionMultipler = curConvMap.get('SGD-USD');                  
            RE_SG_HCVController hcvcal = new RE_SG_HCVController();
            finalhcval = hcvcal.hcfDataPreparation(formWrapList,curConvMap,latestmarketquotes);
            errormessage = errormessage + finalhcval.errorMessage;
            RE_MY_MarketPremiumController mpval = new RE_MY_MarketPremiumController();
            finalmpval = mpval.marketPremiumPreparationSG(formWrapList,curConvMap,latestmarketquotes);
            errormessage = errormessage + finalmpval.errorMessage;
            RE_MY_StorageAndHandlingTariffController sahval = new RE_MY_StorageAndHandlingTariffController();
            finalsahval = sahval.shtPreparation(depotpricinglist,curConvMap);
            errormessage = errormessage + finalsahval.errorMessage;
            RE_MY_MarketingSellingTariffController masval = new RE_MY_MarketingSellingTariffController();
            finalmasval = masval.mstPreparation(depotpricinglist,curConvMap);
            errormessage = errormessage + finalmasval.errorMessage;
            RE_MY_PrimaryTransportCostController ptcval = new RE_MY_PrimaryTransportCostController();
            finalptval = ptcval.primaryTransportCostpreparation(depotpricinglist,curConvMap);
            errormessage = errormessage + finalptval.errorMessage;
            RE_MY_AdditiveCostController acval = new RE_MY_AdditiveCostController();
            finalacval = acval.additivecostCalculation(depotpricinglist,productlist,curConvMap);
            errormessage = errormessage + finalacval.errorMessage;
            RE_SG_DistDiscController ddval = new RE_SG_DistDiscController();
            finalddval = ddval.distdiscPreparation(formWrapList,curConvMap,latestmarketquotes);
            errormessage = errormessage + finalddval.errorMessage;
            RE_SG_FixedPremiumController fpval = new RE_SG_FixedPremiumController();
            finalfpval = fpval.fixedPremiumPreparation(depotpricinglist,curConvMap);
            errormessage = errormessage + finalfpval.errorMessage;
            RE_SG_OilLossController olval = new RE_SG_OilLossController();
            finalolval = olval.olDataPreparation(formWrapList,finalhcval.finalval,finalmpval.finalval);
            errormessage = errormessage + finalolval.errorMessage;
            RE_SG_CostPriceAdjustmentController cpval = new RE_SG_CostPriceAdjustmentController();
            finalcpaval = cpval.cpaPreparation(depotpricinglist, curConvMap);
            errormessage = errormessage + finalcpaval.errorMessage;
            finalmccval = MarkUpCreditChargeCalculation();
            marginallaidDownCostCalculation(true);
            marginallaidDownCostCalculation(false);
            return finalCostingData(jra);
        }
        return false;
    }


    public Map<Id, Double> MarkUpCreditChargeCalculation(){
        Double mccpercentage = Double.valueOf(System.Label.RE_SG_MarkUp_Credit_Charge_Percentage);
        Double mccminVal = Double.valueOf(System.Label.RE_SG_MarkUp_Credit_Charge_Min_Value);
        for(RE_Depot_Pricing_Backbone__c dpbdata : depotpricinglist){
            Double Markupvalue =0;
            Double finalMarkupCredit =0;
            if(finalhcval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalhcval.finalval.get(dpbdata.Id);
            if(finalmpval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalmpval.finalval.get(dpbdata.Id);
            if(finalsahval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalsahval.finalval.get(dpbdata.Id);
            if(finalmasval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalmasval.finalval.get(dpbdata.Id);
            if(finalolval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalolval.finalval.get(dpbdata.Id);
            if(finalptval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalptval.finalval.get(dpbdata.Id);
            if(finalacval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalacval.finalval.get(dpbdata.Id);
            if(finalddval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalddval.finalval.get(dpbdata.Id);
            if(finalfpval.finalval.containsKey(dpbdata.Id))
                Markupvalue = Markupvalue + finalfpval.finalval.get(dpbdata.Id);
            finalMarkupCredit = (Markupvalue*mccpercentage*30/365) > mccminVal ? (Markupvalue*mccpercentage*30/365) : mccminVal;
            finalmccval.put(dpbdata.Id,finalMarkupCredit);
        }
        return finalmccval;
    }

    public void marginallaidDownCostCalculation(Boolean Isfxdata){
        for(RE_Depot_Pricing_Backbone__c dpbdata : depotpricinglist){
            Double marginalCost = 0;
            Double laidDownCost = 0;
            if(finalhcval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalhcval.finalval.get(dpbdata.Id);
            if(finalmpval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalmpval.finalval.get(dpbdata.Id);
            if(finalsahval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalsahval.finalval.get(dpbdata.Id);
            if(finalptval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalptval.finalval.get(dpbdata.Id);
            if(finalacval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalacval.finalval.get(dpbdata.Id);
            if(finalolval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalolval.finalval.get(dpbdata.Id);            
            if(finalcpaval.finalval.containsKey(dpbdata.Id))
                marginalCost = marginalCost + finalcpaval.finalval.get(dpbdata.Id);
            if(Isfxdata){                
                if(finalddval.finalval.containsKey(dpbdata.Id)){
                    if(dpbdata.RE_IsDistillisationRate__c)
                 		marginalCost = currencyConversionMultipler * marginalCost + curconvDD * finalddval.finalval.get(dpbdata.Id);   
                    else
                        marginalCost = currencyConversionMultipler * (marginalCost + finalddval.finalval.get(dpbdata.Id));   
                }                    
                if(finalfpval.finalval.containsKey(dpbdata.Id)){
                    if(dpbdata.RE_IsDistillisationRate__c)
                 		marginalCost = marginalCost + curconvDD * finalfpval.finalval.get(dpbdata.Id);  
                    else
                        marginalCost = marginalCost + currencyConversionMultipler * finalfpval.finalval.get(dpbdata.Id);  
                }                	
                marginalCostMapSG.put(dpbdata.Id, marginalCost);
                if(finalmccval.containsKey(dpbdata.Id))
                    laidDownCost = marginalCost + currencyConversionMultipler * finalmccval.get(dpbdata.Id);
                if(finalmasval.finalval.containsKey(dpbdata.Id))
                    laidDownCost = laidDownCost + currencyConversionMultipler * finalmasval.finalval.get(dpbdata.Id);
                laiddownCostMapSG.put(dpbdata.Id,laidDownCost);
            }
            else{
                if(finalddval.finalval.containsKey(dpbdata.Id))
                    marginalCost = marginalCost + finalddval.finalval.get(dpbdata.Id);
                marginalCostMap.put(dpbdata.Id, marginalCost);
                if(finalmccval.containsKey(dpbdata.Id))
                    laidDownCost = marginalCost + finalmccval.get(dpbdata.Id);
                if(finalmasval.finalval.containsKey(dpbdata.Id))
                    laidDownCost = laidDownCost + finalmasval.finalval.get(dpbdata.Id);
                laiddownCostMap.put(dpbdata.Id,laidDownCost);
            }

        }
    }

    public Boolean finalCostingData(RE_Job_Run_Audit__c jra){
        Boolean Issuccess;
        if(String.isEmpty(errormessage)){
            List<RE_SG_CostPrice__c> costingList = new List<RE_SG_CostPrice__c>();
            List<RE_SG_CostPrice__c> updateLatestData = new List<RE_SG_CostPrice__c>();
            Integer jobCount = 0;
            
            if(jra.RE_Job_Type__c == 'Singapore Output'){
                List<RE_SG_CostPrice__c> costDataLatest = [SELECT RE_IsLatest__c FROM RE_SG_CostPrice__c WHERE RE_IsLatest__c = True AND RE_IsMidday__c = False];
                if(!costDataLatest.isEmpty()){
                    for(RE_SG_CostPrice__c costSG : costDataLatest){
                        costSG.RE_IsLatest__c = False;
                        updateLatestData.add(costSG);
                    }
                }
                
                List<RE_Job_Run_Audit__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
                WHERE createddate = Today AND RE_Job_Type__c = 'Singapore Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
                if(!costDataToday.isEmpty())
                    jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
            }
            else if(jra.RE_Job_Type__c == 'SG Midday Output'){
                List<RE_SG_CostPrice__c> costDataLatest = [SELECT RE_IsLatest__c FROM RE_SG_CostPrice__c WHERE RE_IsLatest__c = True AND RE_IsMidday__c = True];
                if(!costDataLatest.isEmpty()){
                    for(RE_SG_CostPrice__c costSG : costDataLatest){
                        costSG.RE_IsLatest__c = False;
                        updateLatestData.add(costSG);
                    }
                }
                
                List<RE_Job_Run_Audit__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c
                WHERE createddate = Today AND RE_Job_Type__c = 'SG Midday Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
                if(!costDataToday.isEmpty())
                    jobCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
            }
            
            for(RE_Depot_Pricing_Backbone__c dpbdata : depotpricinglist){
                RE_SG_CostPrice__c costData = new RE_SG_CostPrice__c();
                if(jra.RE_Job_Type__c == 'SG Midday Output')
                    costData.RE_IsMidday__c = True;
                else
                    costData.RE_IsMidday__c = False;
                costData.RE_Job_Run_Count__c = jobCount;
                costData.RE_IsLatest__c = True;
                costData.RE_Location_Name__c = dpbdata.RE_Depot_Name__c;
                costData.RE_Product_Name__c = dpbdata.RE_Product_Name__c;
                costData.RE_Costprice_Unit__c = dpbdata.RE_Final_Price_Unit__c;
                costData.RE_Pricing_Date__c = System.today();
                if(finalhcval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Hydrocarbon_Value__c = finalhcval.finalval.get(dpbdata.Id);
                if(laiddownCostMap.containsKey(dpbdata.Id))
                    costData.RE_Costprice_Laid_Down_Cost__c = laiddownCostMap.get(dpbdata.Id);
                if(laiddownCostMapSG.containsKey(dpbdata.Id))
                    costData.RE_FX_Laid_Down_Cost__c = laiddownCostMapSG.get(dpbdata.Id);
                if(marginalCostMap.containsKey(dpbdata.Id))
                    costData.RE_Costprice_Marginal_Cost__c = marginalCostMap.get(dpbdata.Id);
                if(marginalCostMapSG.containsKey(dpbdata.Id))
                    costData.RE_FX_Marginal_Cost__c = marginalCostMapSG.get(dpbdata.Id);
                if(finalmasval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Marketing_Selling_Tariff__c = finalmasval.finalval.get(dpbdata.Id);
                if(finalolval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Oil_Loss__c = finalolval.finalval.get(dpbdata.Id);
                if(finalptval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Primary_Transport_Cost__c = finalptval.finalval.get(dpbdata.Id);
                if(finalsahval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Storage_Handling_Cost__c = finalsahval.finalval.get(dpbdata.Id);
                if(finalmccval.containsKey(dpbdata.Id))
                    costData.RE_Mark_Up_Credit_Charge__c = finalmccval.get(dpbdata.Id);
                if(finalacval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Additive_Cost__c = finalacval.finalval.get(dpbdata.Id);
                if(finalmpval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Market_Premium__c = finalmpval.finalval.get(dpbdata.Id);
                if(finalddval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Distillation_Discount__c = finalddval.finalval.get(dpbdata.Id);
                if(finalfpval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Fixed_Premium__c = finalfpval.finalval.get(dpbdata.Id);
                if(finalcpaval.finalval.containsKey(dpbdata.Id))
                    costData.RE_Cost_Price_Adjustment__c = finalcpaval.finalval.get(dpbdata.Id);
                if(dpbdata.RE_Product_Name__r.Name == 'IGO 10ppm'){
                    RE_Product__c igoprod;
                    for(RE_Product__c productdata : productlist){
                        if(productdata.Name == dpbdata.RE_Product_Name__r.Name)
                            igoprod = productdata;
                    }
                    
                    if(jra.RE_Job_Type__c == 'Singapore Output'){
                        if(igoprod.RE_Morning_MC0_Value__c != null && 
						   igoprod.RE_Morning_MC0_Valid_From__c <= System.today() && 
						   igoprod.RE_Morning_MC0_Valid_To__c >= System.today()){
							costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c - igoprod.RE_Morning_MC0_Value__c * currencyConversionMultipler * 100/Double.valueOf(System.Label.RE_BBL_to_LTR);
						}	
                        else{
                            costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c;
                        }
                    }
                    else{
                        if(igoprod.RE_Midday_MC0_Value__c != null && 
						   igoprod.RE_Midday_MC0_Valid_From__c <= System.today() && 
						   igoprod.RE_Midday_MC0_Valid_To__c >= System.today()){
							costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c - igoprod.RE_Midday_MC0_Value__c * currencyConversionMultipler * 100/Double.valueOf(System.Label.RE_BBL_to_LTR);
						}	
                        else{
                            costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c;
                        }
                    }                    
                }
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
                    System.debug('RE_SG_CostCalculation-finalCostingData-Error-->'+e.getMessage());
                    System.debug('RE_SG_CostCalculation-finalCostingData-Error-LN-->'+e.getLineNumber());
                    RV_ClassException.insertExceptionRecord('finalCostingData',e.getMessage()+'-'+e.getLineNumber(),'RE_SG_CostCalculation','finalCostingData','Exception');
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
            System.debug('RE_SG_CostCalculation-finalCostingData-Update JRA-Error-->'+e.getMessage());
            System.debug('RE_SG_CostCalculation-finalCostingData-Update JRA-Error-LN-->'+e.getLineNumber());
            RV_ClassException.insertExceptionRecord('finalCostingData-Update JRA-',e.getMessage()+'-'+e.getLineNumber(),'RE_SG_CostCalculation','finalCostingData','Exception');
        }
        return Issuccess;
    }
}