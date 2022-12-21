public class RE_MY_MRFreightCostController {   
    public RE_UtilitywrapperController.lineitemwraapper mrfreightDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> mrformList, 
                                                    Map<String,Double> curConvMap, List<RE_Market_Quotes__c> latestmarketquotes){
        List<formulaWrappermrf> formulaWrapList = new List<formulaWrappermrf>();        
		RE_unitConversion conv = new RE_unitConversion();		
		//Preparing formula data and adding it to the wrapper list
        for(RE_MY_FormulaFetchController.formulaWrapper slpformula : mrformList){
			formulaWrappermrf mrfwrapper = new formulaWrappermrf();			
            Double demmurageval = 0;
            if(slpformula.hcfObj.RE_MY_MR_Demurrage__c != null ){
                Double conversionmultiplier = conv.unitConversionMultiplier(slpformula.hcfObj.RE_MY_MR_Demurrage_Unit__c,slpformula.finalUnit,slpformula.country,
                                                                            slpformula.hcfObj.RE_MY_Product__c,curConvMap);
                demmurageval = slpformula.hcfObj.RE_MY_MR_Demurrage__c * conversionmultiplier; 
            }    
            mrfwrapper.mrdemurrage = demmurageval;
			Double mrFreightQuote = 0;
			for(RE_Market_Quotes__c mqdata : latestmarketquotes){
				if(mqdata.RE_Quote_Name__c == slpformula.hcfObj.RE_MY_MR_Frieght_Quote__c){
					Double conversionmultiplier = conv.unitConversionMultiplier(mqdata.RE_Rate_Unit__c,slpformula.finalUnit,slpformula.country,
                                                                            slpformula.hcfObj.RE_MY_Product__c,curConvMap);
                	mrFreightQuote = mqdata.RE_Price__c * conversionmultiplier;
				}
			}
			mrfwrapper.mrFreightPremium = mrFreightQuote;
			mrfwrapper.mrCostPercentage = slpformula.hcfObj.RE_MY_MR_Cost_Percentage__c != null ? slpformula.hcfObj.RE_MY_MR_Cost_Percentage__c/100 : 0;
            mrfwrapper.depoId = slpformula.depoId;
            mrfwrapper.location = slpformula.location;
            mrfwrapper.product = slpformula.product;
            formulaWrapList.add(mrfwrapper);
        }
		return mrfCalculation(formulaWrapList);
    }
    
	public RE_UtilitywrapperController.lineitemwraapper mrfCalculation(List<formulaWrappermrf> formulaWrapList){
        Map<Id, Double> mrfValue = new Map<Id, Double>();  
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(formulaWrappermrf wrapperdata : formulaWrapList){						                
                Id depoId = wrapperdata.depoId;	
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.mrdemurrage + wrapperdata.mrFreightPremium) * wrapperdata.mrCostPercentage;
                mrfValue.put(depoId,finalPrice);
            }	
           	finalineitemval.errorMessage = '';
            finalineitemval.finalval = mrfValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_MRFreightCostController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
	}
    
    public class formulaWrappermrf{
		public Double mrFreightPremium;
        public Double mrdemurrage;
        public Double mrCostPercentage;
        public String location;
        public String product;
        public Id depoId;
	}
    public class rbpformulaWrappermrf{
	public Double mrFreightPremium;
        public Double mrdemurrage;
        public Double mrCostPercentage;
        public String location;
        public String product;
        public String source;
        public Id depoId;
	}
    public RE_UtilitywrapperController.lineitemwraapper AMVmrfreightDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> mrformList, 
                                                    Map<String,Double> curConvMap, List<RE_Market_Quotes__c> latestmarketquotes){
    List<rbpformulaWrappermrf> formulaWrapList = new List<rbpformulaWrappermrf>();        
		RE_unitConversion conv = new RE_unitConversion();		
		//Preparing formula data and adding it to the wrapper list
        for(RE_MY_FormulaFetchController.formulaWrapperAMVMY slpformula : mrformList){
			rbpformulaWrappermrf mrfwrapper = new rbpformulaWrappermrf();			
            Double demmurageval = 0;
            if(slpformula.hcfObj.RE_MY_MR_Demurrage__c != null ){
                Double conversionmultiplier = conv.unitConversionMultiplier(slpformula.hcfObj.RE_MY_MR_Demurrage_Unit__c,slpformula.finalUnit,slpformula.country,
                                                                            slpformula.hcfObj.RE_Product_Name__r.Name,curConvMap);
                demmurageval = slpformula.hcfObj.RE_MY_MR_Demurrage__c * conversionmultiplier; 
            }    
            mrfwrapper.mrdemurrage = demmurageval;
			Double mrFreightQuote = 0;
			for(RE_Market_Quotes__c mqdata : latestmarketquotes){
				if(mqdata.RE_Quote_Name__c == slpformula.hcfObj.RE_MY_MR_Frieght_Quote__c){
					Double conversionmultiplier = conv.unitConversionMultiplier(mqdata.RE_Rate_Unit__c,slpformula.finalUnit,slpformula.country,
                                                                            slpformula.hcfObj.RE_Product_Name__r.Name,curConvMap);
                	mrFreightQuote = mqdata.RE_Price__c * conversionmultiplier;
				}
			}
			mrfwrapper.mrFreightPremium = mrFreightQuote;
			mrfwrapper.mrCostPercentage = slpformula.hcfObj.RE_MY_MR_Cost_Percentage__c != null ? slpformula.hcfObj.RE_MY_MR_Cost_Percentage__c/100 : 0;
            mrfwrapper.depoId = slpformula.hcfObj.Id;
            mrfwrapper.location = slpformula.location;
            mrfwrapper.product = slpformula.product;
            mrfwrapper.source = slpformula.hcfObj.RE_Source_Name__r.Name;
            formulaWrapList.add(mrfwrapper);
        }
		return rbpmrfCalculation(formulaWrapList);
    }
	public RE_UtilitywrapperController.lineitemwraapper rbpmrfCalculation(List<rbpformulaWrappermrf> formulaWrapList){
        Map<Id, Double> mrfValue = new Map<Id, Double>();  
        String location;
        String product;
        String source;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(rbpformulaWrappermrf wrapperdata : formulaWrapList){						                
                Id depoId = wrapperdata.depoId;	
                location = wrapperdata.location;
                product = wrapperdata.product;
                source	=	wrapperdata.source;
                Double finalPrice = (wrapperdata.mrdemurrage + wrapperdata.mrFreightPremium) * wrapperdata.mrCostPercentage;
                mrfValue.put(depoId,finalPrice);
            }	
           	finalineitemval.errorMessage = '';
            finalineitemval.finalval = mrfValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_MRFreightCostController for Source '+ source +' : '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
	}   		
}