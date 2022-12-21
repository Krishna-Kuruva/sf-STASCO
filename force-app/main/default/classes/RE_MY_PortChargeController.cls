public class RE_MY_PortChargeController {  
	
    public RE_UtilitywrapperController.lineitemwraapper pcDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> pcList,
                                                                          Map<String,Double> curConvMap){
		Map<Id, Double> pcValue = new Map<Id, Double>();   
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        RE_unitConversion conv = new RE_unitConversion();		
        try{
            for(RE_MY_FormulaFetchController.formulaWrapper slpformula : pcList){
                Double portcchargeval = 0;
                location = slpformula.location;
                product = slpformula.product;
                if(slpformula.hcfObj.RE_MY_Port_Charges__c != null){
                    Double conversionmultiplier = conv.unitConversionMultiplier(slpformula.hcfObj.RE_MY_Port_Charges_Unit__c,slpformula.finalUnit,slpformula.country,
                                                                                slpformula.hcfObj.RE_MY_Product__c,curConvMap);
                    portcchargeval = slpformula.hcfObj.RE_MY_Port_Charges__c * conversionmultiplier;
                }                    
                pcValue.put(slpformula.depoId,portcchargeval);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = pcValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_PortChargeController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    
    public RE_UtilitywrapperController.lineitemwraapper AMVpcDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> pcList,
                                                                          Map<String,Double> curConvMap){
		Map<Id, Double> pcValue = new Map<Id, Double>();   
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        RE_unitConversion conv = new RE_unitConversion();		
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperAMVMY slpformula : pcList){
                Double portcchargeval = 0;
                location = slpformula.location;
                product = slpformula.product;
                if(slpformula.hcfObj.RE_MY_Port_Charges__c != null){
                    Double conversionmultiplier = conv.unitConversionMultiplier(slpformula.hcfObj.RE_MY_Port_Charges_Unit__c,slpformula.finalUnit,slpformula.country,
                                                                                slpformula.hcfObj.RE_Product_Name__c,curConvMap);
                    portcchargeval = slpformula.hcfObj.RE_MY_Port_Charges__c * conversionmultiplier;
                }                    
                pcValue.put(slpformula.hcfObj.Id,portcchargeval);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = pcValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_PortChargeController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
}