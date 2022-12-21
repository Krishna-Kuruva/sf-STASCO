public class RE_MY_BioOilLosscontroller {   
    public RE_UtilitywrapperController.lineitemwraapper bioOilLossDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> slpList, Map<Id, Double> finalbioval){
		List<RE_UtilitywrapperController.formulaWrappertp> formulaWrapList = new List<RE_UtilitywrapperController.formulaWrappertp>();
        for(RE_MY_FormulaFetchController.formulaWrapper slpformula : slpList){
			RE_UtilitywrapperController.formulaWrappertp slpwrapper = new RE_UtilitywrapperController.formulaWrappertp();			
            Double biocostval = 0;
			if(finalbioval.containsKey(slpformula.depoId))
                biocostval = finalbioval.get(slpformula.depoId);
            slpwrapper.PremiumValue = biocostval;
			slpwrapper.PremiumPerc = slpformula.hcfObj.RE_MY_Bio_Loss_Percentage__c != null ? slpformula.hcfObj.RE_MY_Bio_Loss_Percentage__c/100 : 0;
            slpwrapper.depoId = slpformula.depoId;
            slpwrapper.location = slpformula.location;
            slpwrapper.product = slpformula.product;
            formulaWrapList.add(slpwrapper);
        }
		return RE_UtilitywrapperController.finalCalculation(formulaWrapList,'RE_MY_BioOilLosscontroller');
    }
    
    public RE_UtilitywrapperController.lineitemwraapper AMVbioOilLossDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> slpList, Map<Id, Double> finalbioval){
        List<RE_UtilitywrapperController.rbpformulaWrapper> formulaWrapList = new List<RE_UtilitywrapperController.rbpformulaWrapper>();
        for(RE_MY_FormulaFetchController.formulaWrapperAMVMY slpformula : slpList){
            RE_UtilitywrapperController.rbpformulaWrapper slpwrapper = new RE_UtilitywrapperController.rbpformulaWrapper();			
            Double biocostval = 0;
            if(finalbioval.containsKey(slpformula.depoId))
                biocostval = finalbioval.get(slpformula.depoId);
            slpwrapper.PremiumValue = biocostval;
            slpwrapper.PremiumPerc = slpformula.hcfObj.RE_MY_Bio_Loss_Percentage__c != null ? slpformula.hcfObj.RE_MY_Bio_Loss_Percentage__c/100 : 0;
            slpwrapper.rbId = slpformula.hcfObj.Id;
            slpwrapper.location = slpformula.location;
            slpwrapper.product = slpformula.product;
            formulaWrapList.add(slpwrapper);
        }
        return RE_UtilitywrapperController.rbfinalCalculation(formulaWrapList,'RE_MY_BioOilLosscontroller');
    }
}