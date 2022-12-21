public class RE_SG_DistDiscController {

    public RE_UtilitywrapperController.lineitemwraapper distdiscPreparation(List<RE_MY_FormulaFetchController.formulaWrapperSG> formWrapList,Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestMarketQuotes){
        List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();   
		for(RE_MY_FormulaFetchController.formulaWrapperSG dddata : formWrapList){      
			RE_UtilitywrapperController.formulaWrappertp formwrap = new RE_UtilitywrapperController.formulaWrappertp();  
			RE_unitConversion conv = new RE_unitConversion();
            Double marketpremiumval = 0;
			for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){
                if(dddata.hcfObj.RE_SG_Dist_Disc_Quote__c != null && dddata.hcfObj.RE_SG_Dist_Disc_Quote__c == mopsQuote.RE_Quote_Name__c){
					Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,dddata.finalUnit,dddata.country,
                                                                           dddata.hcfObj.RE_SG_Product__c,curConvMap);
                	marketpremiumval = mopsQuote.RE_Price__c* conversionmultiplier;
				}
			}
            formwrap.PremiumValue = marketpremiumval;
			formwrap.PremiumPerc = dddata.hcfObj.RE_SG_Dist_Disc_Percentage__c != null ? dddata.hcfObj.RE_SG_Dist_Disc_Percentage__c/100 : 0;
			formwrap.depoId = dddata.depoId; 
            formwrap.location = dddata.location;
			formwrap.product = dddata.product;
			formulaWrapList.add(formwrap);
		}
		return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_SG_DistDiscController');
    } 
}