public class RE_MY_MarketPremiumController {
	//Preparing formula data and adding to wrapper list for Malaysia Market Premium Calculation
	public RE_UtilitywrapperController.lineitemwraapper marketPremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> marketPremiumCalculation,
			Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestMarketQuotes){
		List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();
		for(RE_MY_FormulaFetchController.formulaWrapper mPdata : marketPremiumCalculation){
			RE_UtilitywrapperController.formulaWrappertp formwrap = new RE_UtilitywrapperController.formulaWrappertp();
			RE_unitConversion conv = new RE_unitConversion();
			Double marketpremiumval = 0;
			for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){
				if(mPdata.hcfObj.RE_MY_Market_Premium_Quote__c != null && mPdata.hcfObj.RE_MY_Market_Premium_Quote__c == mopsQuote.RE_Quote_Name__c){
					Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,mPdata.finalUnit,mPdata.country,
							mPdata.hcfObj.RE_MY_Product__c,curConvMap);
					marketpremiumval = mopsQuote.RE_Price__c* conversionmultiplier;
				}
			}
			formwrap.PremiumValue = marketpremiumval;
			formwrap.PremiumPerc = mPdata.hcfObj.RE_MY_Market_Premium_Percentage__c != null ? mPdata.hcfObj.RE_MY_Market_Premium_Percentage__c/100 : 0;
			formwrap.depoId = mPdata.depoId;
			formwrap.location = mPdata.location;
			formwrap.product = mPdata.product;
			formulaWrapList.add(formwrap);
		}
		return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_MarketPremiumController');

	}

	//Preparing formula data and adding to wrapper list for Singapore Market Premium Calculation
	public RE_UtilitywrapperController.lineitemwraapper marketPremiumPreparationSG(List<RE_MY_FormulaFetchController.formulaWrapperSG> marketPremiumCalculation,
			Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestMarketQuotes){
		List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();
		for(RE_MY_FormulaFetchController.formulaWrapperSG mPdata : marketPremiumCalculation){
			RE_UtilitywrapperController.formulaWrappertp formwrap = new RE_UtilitywrapperController.formulaWrappertp();
			RE_unitConversion conv = new RE_unitConversion();
			Double marketpremiumval = 0;
			for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){
				if(mPdata.hcfObj.RE_SG_Market_Premium_Quote__c != null && mPdata.hcfObj.RE_SG_Market_Premium_Quote__c == mopsQuote.RE_Quote_Name__c){
					Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,mPdata.finalUnit,mPdata.country,
							mPdata.hcfObj.RE_SG_Product__c,curConvMap);
					marketpremiumval = mopsQuote.RE_Price__c * conversionmultiplier;
				}
			}
			formwrap.PremiumValue = marketpremiumval;
			formwrap.PremiumPerc = mPdata.hcfObj.RE_SG_Market_Premium_Percent__c != null ? mPdata.hcfObj.RE_SG_Market_Premium_Percent__c/100 : 0;
			formwrap.depoId = mPdata.depoId;
			formwrap.location = mPdata.location;
			formwrap.product = mPdata.product;
			formulaWrapList.add(formwrap);
		}
		return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_MarketPremiumController');
	}
    
    public RE_UtilitywrapperController.lineitemwraapper AMVmarketPremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> marketPremiumCalculation,
                                                                                 Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestMarketQuotes){
      
	  List<RE_UtilitywrapperController.rbpformulaWrapper> formulaWrapList = new List<RE_UtilitywrapperController.rbpformulaWrapper>();	
	  
		for(RE_MY_FormulaFetchController.formulaWrapperAMVMY depotppdata : marketPremiumCalculation){
			
			RE_UtilitywrapperController.rbpformulaWrapper formwrap = new RE_UtilitywrapperController.rbpformulaWrapper();
			
			RE_unitConversion conv = new RE_unitConversion();
			Double marketpremiumval = 0;
			for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){
                if(depotppdata.hcfObj.RE_MY_Market_Premium_Quote__c != null && depotppdata.hcfObj.RE_MY_Market_Premium_Quote__c == mopsQuote.RE_Quote_Name__c){
					Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,depotppdata.finalUnit,depotppdata.country,
                                                                           depotppdata.hcfObj.RE_Product_Name__r.Name,curConvMap);
                	marketpremiumval = mopsQuote.RE_Price__c* conversionmultiplier;
				}
			}
            formwrap.PremiumValue = marketpremiumval;
			formwrap.PremiumPerc = depotppdata.hcfObj.RE_MY_Market_Premium_Percentage__c != null ? depotppdata.hcfObj.RE_MY_Market_Premium_Percentage__c/100 : 0;
			formwrap.rbId =  depotppdata.hcfObj.Id; 
            formwrap.location = depotppdata.location;
            formwrap.source = depotppdata.hcfObj.RE_Source_Name__r.Name;
            formwrap.product = depotppdata.product;
			formulaWrapList.add(formwrap);
		}   		
		return RE_UtilitywrapperController.rbfinalCalculation(formulaWrapList,'RE_MY_MarketPremiumController');                                                                              
																					 
	}
    
    //Premium calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper PHmarketPremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> marketPremiumCalculation, Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestMarketQuotes,Map<String,RE_Product__c> proddataMap){        
        List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();	        
        for(RE_MY_FormulaFetchController.formulaWrapperTH depotppdata : marketPremiumCalculation){            
            RE_UtilitywrapperController.formulaWrappertp formwrap = new RE_UtilitywrapperController.formulaWrappertp();            
            RE_unitConversion conv = new RE_unitConversion();
            Double marketpremiumval = 0;
            for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){
                if(depotppdata.hcfObj.RE_PH_Premium__c != null && depotppdata.hcfObj.RE_PH_Premium__c == mopsQuote.RE_Quote_Name__c && proddataMap.containskey(depotppdata.product)){
                    Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,depotppdata.finalUnit,depotppdata.country,proddataMap.get(depotppdata.product).RE_Product_Group__c,curConvMap);
                    marketpremiumval = mopsQuote.RE_Price__c* conversionmultiplier;
                }
            }
            formwrap.PremiumValue = marketpremiumval;
            formwrap.PremiumPerc = depotppdata.hcfObj.RE_TH_HCV_Quote1_Percent__c != null ? depotppdata.hcfObj.RE_TH_HCV_Quote1_Percent__c/100 : 0;
            formwrap.depoId = depotppdata.depoId; 
            formwrap.location = depotppdata.location;
            formwrap.product = depotppdata.product;
            formulaWrapList.add(formwrap);
        }   		
        return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_MarketPremiumController');                                                                              
        
    }
}