public class RE_MY_COSteerController {  

	public RE_UtilitywrapperController.lineitemwraapper shospPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> cospricinglist, Map<String, Double> curConvMap){
        Map<Id, Double> cosCalculation = new Map<Id, Double>();
        String location;
        String product;
        String source;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperAMVMY dpbData : cospricinglist){ 
                location = dpbData.location;
                product = dpbData.product;
                source = dpbData.hcfObj.RE_Source_Name__r.Name;
                Double value = (dpbData.hcfObj.RE_CO_Steer__c != null && dpbData.hcfObj.RE_CO_Steer_Valid_From__c <= System.today() 
                                && dpbData.hcfObj.RE_CO_Steer_Valid_To__c >= System.today())? dpbData.hcfObj.RE_CO_Steer__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_MY_CO_Steer_Unit__c != null)
                	conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_MY_CO_Steer_Unit__c,dpbData.finalUnit,dpbData.country,dpbData.product,curConvMap);
                value = value * conversionmultiplier;                
                cosCalculation.put(dpbData.hcfObj.Id,value);                            
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = cosCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_COSteerController for '+ source +' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
}