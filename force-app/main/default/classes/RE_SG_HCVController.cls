public class RE_SG_HCVController {
    public RE_UtilitywrapperController.lineitemwraapper hcfDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperSG> hcfList,Map<String,Double> curConvMap,
                                              List<RE_Market_Quotes__c> latestmarketquotes){        
		RE_unitConversion conv = new RE_unitConversion();
		List<formulaWrapper> formulaWrapList = new List<formulaWrapper>();
		for(RE_MY_FormulaFetchController.formulaWrapperSG hcformula : hcfList){
			formulaWrapper formwrap = new formulaWrapper();  
			Double mopsVal1 = 0;
			Double mopsVal2 = 0;            
            
			for(RE_Market_Quotes__c mopsQuote : latestMarketQuotes){                
			  if(hcformula.hcfObj.RE_SG_HCV_Quote_1__c == mopsQuote.RE_Quote_Name__c){  
					                  
				  Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,hcformula.finalUnit,hcformula.country,
																			  hcformula.hcfObj.RE_SG_Product__c,curConvMap);
				  mopsVal1 = mopsQuote.RE_Price__c * conversionmultiplier;
			  }
			  if(hcformula.hcfObj.RE_SG_HCV_Quote_2__c == mopsQuote.RE_Quote_Name__c){                    
				  Double conversionmultiplier2 = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,hcformula.finalUnit,hcformula.country,
																			  hcformula.hcfObj.RE_SG_Product__c,curConvMap);
				  mopsVal2 = mopsQuote.RE_Price__c * conversionmultiplier2;
			  }
			}
			formwrap.MOPSval1 = mopsVal1;
			formwrap.MOPSval2 = mopsVal2;            
			formwrap.MOPSpercentage1 = hcformula.hcfObj.RE_SG_HCV_Quote_1_Percent__c != null ? hcformula.hcfObj.RE_SG_HCV_Quote_1_Percent__c/100 : 0;
			formwrap.MOPSpercentage2 = hcformula.hcfObj.RE_SG_HCV_Quote_2_Percent__c != null ? hcformula.hcfObj.RE_SG_HCV_Quote_2_Percent__c/100 : 0;			
            formwrap.depoId = hcformula.depoId;
            formwrap.location = hcformula.location;
			formwrap.product = hcformula.product;
			formulaWrapList.add(formwrap);
		}
		return hcfCalculation(formulaWrapList);
	} 	 	
    
	public RE_UtilitywrapperController.lineitemwraapper hcfCalculation(List<formulaWrapper> formulaWrapList){
		Map<Id, Double> hcValue = new Map<Id, Double>();  
        String location;
        String product;
		RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(formulaWrapper wrapperdata : formulaWrapList){ 
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.MOPSpercentage1 * wrapperdata.MOPSval1) + (wrapperdata.MOPSpercentage2 * wrapperdata.MOPSval2);                   
                hcValue.put(wrapperdata.depoId,finalPrice);
            }		
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = hcValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at HCV Calculation for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;      
	}
	  
	public class formulaWrapper{
		public Double MOPSval1;
		public Double MOPSpercentage1;
		public Double MOPSval2;
		public Double MOPSpercentage2;
        public String location;
        public String product;
		public Id depoId;
	}
}