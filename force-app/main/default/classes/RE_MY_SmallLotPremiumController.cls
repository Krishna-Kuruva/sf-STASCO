public class RE_MY_SmallLotPremiumController {
    public RE_UtilitywrapperController.lineitemwraapper slpDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> slpList, Map<String,Double> curConvMap){
        List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();        
		RE_unitConversion conv = new RE_unitConversion();		
		//Preparing formula data and adding it to the wrapper list
        for(RE_MY_FormulaFetchController.formulaWrapper slpformula : slpList){
			RE_UtilitywrapperController.formulaWrappertp slpwrapper = new RE_UtilitywrapperController.formulaWrappertp();			            
			Double smalllotpremium = 0;
            if(slpformula.hcfObj.RE_MY_Small_lot_premium__c != null){
                Double conversionmultiplier = conv.unitConversionMultiplier(slpformula.hcfObj.RE_MY_Small_lot_premium_Unit__c,slpformula.finalUnit,slpformula.country,
                                                                           slpformula.hcfObj.RE_MY_Product__c,curConvMap);
                smalllotpremium = slpformula.hcfObj.RE_MY_Small_lot_premium__c* conversionmultiplier;                
            }
            slpwrapper.PremiumValue = smalllotpremium;
			slpwrapper.PremiumPerc = slpformula.hcfObj.RE_MY_Small_lot_percentage__c != null ? slpformula.hcfObj.RE_MY_Small_lot_percentage__c/100 : 0;
            slpwrapper.depoId = slpformula.depoId;
            slpwrapper.location = slpformula.location;
            slpwrapper.product = slpformula.product;
            formulaWrapList.add(slpwrapper);
        }
		return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_SmallLotPremiumController');
    }
    //Small Lot Prem Calculation for PH
     public RE_UtilitywrapperController.lineitemwraapper slpDataPreparationPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> fetchPHDepoPricingList, Map<String,Double> curConvMap, List<RE_Market_Quotes__c> latestmarketquotes,Map<String,RE_Product__c> proddataMap){
        List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();        
		RE_unitConversion conv = new RE_unitConversion();		
		//Preparing formula data and adding it to the wrapper list
        for(RE_MY_FormulaFetchController.formulaWrapperTH slpformula : fetchPHDepoPricingList){
			RE_UtilitywrapperController.formulaWrappertp slpwrapper = new RE_UtilitywrapperController.formulaWrappertp();			            
			Double smalllotpremium = 0;
			if(slpformula.hcfObj.RE_PH_Small_Lot__c != null){
            for(RE_Market_Quotes__c mopsQuote : latestmarketquotes){       
					if(slpformula.hcfObj.RE_PH_Small_Lot__c == mopsQuote.RE_Quote_Name__c && proddataMap.containskey(slpformula.product)){ 
                        System.debug('inside if smalllot--');
						Double conversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,slpformula.hcfObj.RE_Final_Price_Unit__c,slpformula.country, proddataMap.get(slpformula.product).RE_Product_Group__c,curConvMap);
                        smalllotpremium = mopsQuote.RE_Price__c * conversionmultiplier;
                        System.debug('conversionmultipliersmalllot--'+conversionmultiplier);
                        System.debug('smalllotpremium--'+smalllotpremium);
					}
				}
			}	
			if(smalllotpremium != 0 )
            {
                System.debug('slpformula.depoId--'+ slpformula.depoId);
            }
            slpwrapper.PremiumValue = smalllotpremium;
			slpwrapper.PremiumPerc = 1;
            slpwrapper.depoId = slpformula.depoId;
            slpwrapper.location = slpformula.location;
            slpwrapper.product = slpformula.product;
            formulaWrapList.add(slpwrapper);
        }
		return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_SmallLotPremiumController');
    }	
    
    public RE_UtilitywrapperController.lineitemwraapper AMVslpDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> slpList, Map<String,Double> curConvMap){
        List<RE_UtilitywrapperController.rbpformulaWrapper> formulaWrapList = new List<RE_UtilitywrapperController.rbpformulaWrapper>();		
		for(RE_MY_FormulaFetchController.formulaWrapperAMVMY depotppdata : slpList){
			
			RE_UtilitywrapperController.rbpformulaWrapper formwrap = new RE_UtilitywrapperController.rbpformulaWrapper();
			RE_unitConversion conv = new RE_unitConversion();
            Double smalllotpremium = 0;
            if(depotppdata.hcfObj.RE_MY_Small_lot_premium__c != null){
                Double conversionmultiplier = conv.unitConversionMultiplier(depotppdata.hcfObj.RE_MY_Small_lot_premium_Unit__c,depotppdata.finalUnit,depotppdata.country,
                                                                           depotppdata.hcfObj.RE_Product_Name__r.Name,curConvMap);
                smalllotpremium = depotppdata.hcfObj.RE_MY_Small_lot_premium__c* conversionmultiplier;                
            }
            formwrap.PremiumValue = smalllotpremium;
			formwrap.PremiumPerc = depotppdata.hcfObj.RE_MY_Small_lot_percentage__c != null ? depotppdata.hcfObj.RE_MY_Small_lot_percentage__c/100 : 0;
			formwrap.rbId =  depotppdata.hcfObj.Id; 
            formwrap.location = depotppdata.location;
            formwrap.source = depotppdata.hcfObj.RE_Source_Name__r.Name;
            formwrap.product = depotppdata.product;
			formulaWrapList.add(formwrap);
		}   		
		return RE_UtilitywrapperController.rbfinalCalculation(formulaWrapList,'RE_MY_SmallLotPremiumController');
    }
}