public class RE_MY_TransferPricePremiumController {
    
	public RE_UtilitywrapperController.lineitemwraapper transferPricePremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> TransferPricePremiumList,Map<String,Double> curConvMap){
		List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();		
		for(RE_MY_FormulaFetchController.formulaWrapper depotppdata : TransferPricePremiumList){
			RE_UtilitywrapperController.formulaWrappertp formwrap = new RE_UtilitywrapperController.formulaWrappertp();
			RE_unitConversion conv = new RE_unitConversion();
			if(depotppdata.hcfObj.RE_MY_TP_Premium__c != null){
				Double conversionmultiplier = conv.unitConversionMultiplier(depotppdata.hcfObj.RE_MY_TP_Premium_Unit__c,depotppdata.finalUnit,depotppdata.country,
                                                                           depotppdata.hcfObj.RE_MY_Product__c,curConvMap);
                formwrap.PremiumValue = depotppdata.hcfObj.RE_MY_TP_Premium__c * conversionmultiplier;
			}
			else{
				formwrap.PremiumValue = 0;
			}
			formwrap.PremiumPerc = depotppdata.hcfObj.RE_MY_TP_Premium_Percentage__c != null ? depotppdata.hcfObj.RE_MY_TP_Premium_Percentage__c/100 : 0;
			formwrap.depoId =  depotppdata.depoId; 
            formwrap.location = depotppdata.location;
            formwrap.product = depotppdata.product;
			formulaWrapList.add(formwrap);
		}   		
		return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_TransferPricePremiumController');
	} 
    
    //For AMV, transfer price premium calculation based on Route Backbone data
    public RE_UtilitywrapperController.lineitemwraapper AMVtransferPricePremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> TransferPricePremiumList,Map<String,Double> curConvMap){
		List<RE_UtilitywrapperController.rbpformulaWrapper> formulaWrapList = new List<RE_UtilitywrapperController.rbpformulaWrapper>();		
		for(RE_MY_FormulaFetchController.formulaWrapperAMVMY depotppdata : TransferPricePremiumList){
			RE_UtilitywrapperController.rbpformulaWrapper formwrap = new RE_UtilitywrapperController.rbpformulaWrapper();
			RE_unitConversion conv = new RE_unitConversion();
			if(depotppdata.hcfObj.RE_MY_TP_Premium__c != null){
				Double conversionmultiplier = conv.unitConversionMultiplier(depotppdata.hcfObj.RE_MY_TP_Premium_Unit__c,depotppdata.finalUnit,depotppdata.country,
                                                                           depotppdata.hcfObj.RE_Product_Name__r.Name,curConvMap);
                formwrap.PremiumValue = depotppdata.hcfObj.RE_MY_TP_Premium__c * conversionmultiplier;
			}
			else{
				formwrap.PremiumValue = 0;
			}
			formwrap.PremiumPerc = depotppdata.hcfObj.RE_MY_TP_Premium_Percentage__c != null ? depotppdata.hcfObj.RE_MY_TP_Premium_Percentage__c/100 : 0;
			formwrap.rbId =  depotppdata.hcfObj.Id; 
            formwrap.location = depotppdata.location;
            formwrap.source = depotppdata.hcfObj.RE_Source_Name__r.Name;
            formwrap.product = depotppdata.product;
			formulaWrapList.add(formwrap);
		}   		
		return RE_UtilitywrapperController.rbfinalCalculation(formulaWrapList,'RE_MY_TransferPricePremiumController');
	} 
    //Fixed Premium calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper fixedPremiumPreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> fetchPHDepoPricingList, Map<String,Double> curConvMap,Map<String,RE_Product__c> proddataMap){        
        List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();	        
        for(RE_MY_FormulaFetchController.formulaWrapperTH depotppdata : fetchPHDepoPricingList){            
            RE_UtilitywrapperController.formulaWrappertp formwrap = new RE_UtilitywrapperController.formulaWrappertp();            
            RE_unitConversion conv = new RE_unitConversion();
            Double fixedpremiumval = 0;
            
            if(depotppdata.hcfObj.RE_Fixed_Premium__c != null && depotppdata.hcfObj.RE_Fixed_Premium_Unit__c != null && proddataMap.containskey(depotppdata.product)){
                Double conversionmultiplier = conv.unitConversionMultiplier(depotppdata.hcfObj.RE_Fixed_Premium_Unit__c,depotppdata.finalUnit,depotppdata.country, proddataMap.get(depotppdata.product).RE_Product_Group__c,curConvMap);
                fixedpremiumval = depotppdata.hcfObj.RE_Fixed_Premium__c* conversionmultiplier;
            }
            formwrap.PremiumValue = fixedpremiumval;
            formwrap.PremiumPerc = depotppdata.hcfObj.RE_TH_HCV_Quote1_Percent__c != null ? depotppdata.hcfObj.RE_TH_HCV_Quote1_Percent__c/100 : 0;
            formwrap.depoId = depotppdata.depoId; 
            formwrap.location = depotppdata.location;
            formwrap.product = depotppdata.product;
            formulaWrapList.add(formwrap);
        }   		
        return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_MarketPremiumController');                                                                              
        
    }
}