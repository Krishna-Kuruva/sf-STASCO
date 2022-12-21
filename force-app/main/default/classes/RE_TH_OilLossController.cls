public class RE_TH_OilLossController {
    
public RE_UtilitywrapperController.lineitemwraapper olDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> olformList,Map<Id, Double> finalhcval,List<RE_Product__c> prodlist){//,Map<Id, Double> finalmpval
        List<slpformulaWrapper> formulaWrapList = new List<slpformulaWrapper>();  
    	Map<String,RE_Product__c> prodMap = new Map<String,RE_Product__c>();
        for(RE_Product__c prod : prodlist){
            prodMap.put(prod.Name,prod);
        }
        //Preparing formula data and adding it to the wrapper list
        for(RE_MY_FormulaFetchController.formulaWrapperTH slpformula : olformList){
            slpformulaWrapper slpwrapper = new slpformulaWrapper();			
            slpwrapper.hcvCost = finalhcval.containsKey(slpformula.depoId) ? finalhcval.get(slpformula.depoId) : 0;			
            //slpwrapper.mpCost = finalmpval.containsKey(slpformula.depoId) ? finalmpval.get(slpformula.depoId) : 0;	
            slpwrapper.oillosspercentage =prodMap.containsKey(slpformula.product) ? (prodMap.get(slpformula.product).RE_TH_Oil_Loss_Percent__c != Null ? (prodMap.get(slpformula.product).RE_TH_Oil_Loss_Percent__c/100) : 0) : 0;
            //slpwrapper.oillosspercentage = slpformula.hcfObj.RE_SG_Oil_Loss_Percent__c != null ? slpformula.hcfObj.RE_SG_Oil_Loss_Percent__c/100 : 0;
            slpwrapper.depoId = slpformula.depoId;
            slpwrapper.location = slpformula.location;
            slpwrapper.product = slpformula.product;
            formulaWrapList.add(slpwrapper);
        }
        return slpCalculation(formulaWrapList);
	}
    
	public RE_UtilitywrapperController.lineitemwraapper slpCalculation(List<slpformulaWrapper> formulaWrapList){
        Map<Id, Double> olValue = new Map<Id, Double>();  
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();  
        try{
            for(slpformulaWrapper wrapperdata : formulaWrapList){
                location = wrapperdata.location;
                product = wrapperdata.product;
                //Double finalPrice = ((wrapperdata.hcvCost + wrapperdata.mpCost)* wrapperdata.oillosspercentage);

                Double finalPrice = ((wrapperdata.hcvCost)* wrapperdata.oillosspercentage);
                olValue.put(wrapperdata.depoId,finalPrice);
            }	         	
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = olValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_SG_OilLossController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;   
	}
	
	public class slpformulaWrapper{
        public Double hcvCost;        
        public Double mpCost;
        public Double oillosspercentage;
        public String location;
        public String product;
        public Id depoId;
	}	
}