public class RE_MY_BreakBulkFixedPremiumController {  

    public RE_UtilitywrapperController.lineitemwraapper breakBulkFixedPremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> BreakBulkFixedPremiumList,
                                                            Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestMarketQuotes){
        List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();                
        for(RE_MY_FormulaFetchController.formulaWrapper BPformul : BreakBulkFixedPremiumList)    
        {                    
            RE_UtilitywrapperController.formulaWrappertp formwrap = new RE_UtilitywrapperController.formulaWrappertp();
            RE_unitConversion conv = new RE_unitConversion();
            Double breakbulkValue = 0;
            if(BPformul.hcfObj.RE_MY_BreakBulk_Premium_Quote__c != null){
                for (RE_Market_Quotes__c mQuotes : latestMarketQuotes){                    
                    if(mQuotes.RE_Quote_Name__c == BPformul.hcfObj.RE_MY_BreakBulk_Premium_Quote__c){
                        Double conversionmultiplier = conv.unitConversionMultiplier(mQuotes.RE_Rate_Unit__c,BPformul.finalUnit,BPformul.country,
                                                                           BPformul.hcfObj.RE_MY_Product__c,curConvMap);
                		breakbulkValue = mQuotes.RE_Price__c * conversionmultiplier;
                    }
                }                        
            }
            Double fixedvalue = 0;
            if(BPformul.hcfObj.RE_MY_Fixed_Premium__c != null && BPformul.hcfObj.RE_MY_Fixed_Premium_Unit__c != null) {
                Double conversionmultiplier = conv.unitConversionMultiplier(BPformul.hcfObj.RE_MY_Fixed_Premium_Unit__c,BPformul.finalUnit,BPformul.country,
                                                                           BPformul.hcfObj.RE_MY_Product__c,curConvMap);
                		fixedvalue = BPformul.hcfObj.RE_MY_Fixed_Premium__c* conversionmultiplier;
            }       
            formwrap.PremiumValue = breakbulkValue + fixedvalue;
            formwrap.PremiumPerc = BPformul.hcfObj.RE_MY_BreakBulk_Premium_Quote_Percentage__c != null ? BPformul.hcfObj.RE_MY_BreakBulk_Premium_Quote_Percentage__c/100 : 0;
            formwrap.depoId = BPformul.depoId;
            formwrap.location = BPformul.location;
            formwrap.product = BPformul.product;
            formulaWrapList.add(formwrap);            
        }        
        return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_BreakBulkFixedPremiumController');        
    }  
    
    public RE_UtilitywrapperController.lineitemwraapper AMVbreakBulkFixedPremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> BreakBulkFixedPremiumList,
                                                                                         Map<String,Double> curConvMap,List<RE_Market_Quotes__c> latestMarketQuotes){
		
				
		List<RE_UtilitywrapperController.rbpformulaWrapper> formulaWrapList = new List<RE_UtilitywrapperController.rbpformulaWrapper>();		
		for(RE_MY_FormulaFetchController.formulaWrapperAMVMY depotppdata : BreakBulkFixedPremiumList){
			
			RE_UtilitywrapperController.rbpformulaWrapper formwrap = new RE_UtilitywrapperController.rbpformulaWrapper();
			RE_unitConversion conv = new RE_unitConversion();
            Double breakbulkValue = 0;
            if(depotppdata.hcfObj.RE_MY_BreakBulk_Premium_Quote__c != null){
                for (RE_Market_Quotes__c mQuotes : latestMarketQuotes){                    
                    if(mQuotes.RE_Quote_Name__c == depotppdata.hcfObj.RE_MY_BreakBulk_Premium_Quote__c){
                        Double conversionmultiplier = conv.unitConversionMultiplier(mQuotes.RE_Rate_Unit__c,depotppdata.finalUnit,depotppdata.country,
                                                                           depotppdata.hcfObj.RE_Product_Name__r.Name,curConvMap);
                		breakbulkValue = mQuotes.RE_Price__c * conversionmultiplier;
                    }
                }                        
            }
            Double fixedvalue = 0;
            
            if(depotppdata.hcfObj.RE_Fixed_Premium__c != null && depotppdata.hcfObj.RE_Fixed_Premium_Unit__c != null) {
                Double conversionmultiplier = conv.unitConversionMultiplier(depotppdata.hcfObj.RE_Fixed_Premium_Unit__c,depotppdata.finalUnit,depotppdata.country,
                                                                           depotppdata.hcfObj.RE_Product_Name__r.Name,curConvMap);
                		fixedvalue = depotppdata.hcfObj.RE_Fixed_Premium__c* conversionmultiplier;
            }       
            formwrap.PremiumValue = breakbulkValue + fixedvalue;
			formwrap.PremiumPerc = depotppdata.hcfObj.RE_MY_BreakBulk_Premium_Quote_Percentage__c != null ? depotppdata.hcfObj.RE_MY_BreakBulk_Premium_Quote_Percentage__c/100 : 0;
			formwrap.rbId =  depotppdata.hcfObj.Id; 
            formwrap.location = depotppdata.location;
            formwrap.source = depotppdata.hcfObj.RE_Source_Name__r.Name;
            formwrap.product = depotppdata.product;
			formulaWrapList.add(formwrap);
		} 
        
		 return RE_UtilitywrapperController.rbfinalCalculation(formulaWrapList,'RE_MY_BreakBulkFixedPremiumController');                                                                                                 
	}
}