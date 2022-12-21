public class RE_MY_OilLossController {  
    public RE_UtilitywrapperController.lineitemwraapper olDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapper> olformList,
       Map<Id, Double> finalhcval,Map<Id, Double> finalmpval,Map<Id, Double> finalslpval,Map<Id, Double> finalmrfval,Map<Id, Double> finalpcval){
        List<formulaWrapperol> formulaWrapList = new List<formulaWrapperol>();                          
		//Preparing formula data and adding it to the wrapper list
        for(RE_MY_FormulaFetchController.formulaWrapper slpformula : olformList){
			formulaWrapperol olwrapper = new formulaWrapperol();			
            olwrapper.hcvCost = finalhcval.containsKey(slpformula.depoId) ? finalhcval.get(slpformula.depoId) : 0;
			olwrapper.marketpremiumcost = finalmpval.containsKey(slpformula.depoId) ? finalmpval.get(slpformula.depoId) : 0;
            olwrapper.smalllotcost = finalslpval.containsKey(slpformula.depoId) ? finalslpval.get(slpformula.depoId) : 0;
            olwrapper.mrfreightcost = finalmrfval.containsKey(slpformula.depoId) ? finalmrfval.get(slpformula.depoId) : 0;
            olwrapper.portchargecost = finalpcval.containsKey(slpformula.depoId) ? finalpcval.get(slpformula.depoId) : 0;
            olwrapper.oillosspercentage = slpformula.hcfObj.RE_MY_Oil_Loss_Percentage__c != null ? slpformula.hcfObj.RE_MY_Oil_Loss_Percentage__c/100 : 0;
            olwrapper.depoId = slpformula.depoId;
            olwrapper.location = slpformula.location;
            olwrapper.product = slpformula.product;
            formulaWrapList.add(olwrapper);
        }
		return olCalculation(formulaWrapList);
    }
    
	public RE_UtilitywrapperController.lineitemwraapper olCalculation(List<formulaWrapperol> formulaWrapList){
        Map<Id, Double> olValue = new Map<Id, Double>();  
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(formulaWrapperol wrapperdata : formulaWrapList){						
                Id depoId = wrapperdata.depoId;	
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.hcvCost + wrapperdata.marketpremiumcost +
                                    wrapperdata.smalllotcost + wrapperdata.mrfreightcost + wrapperdata.portchargecost) 
                                    * wrapperdata.oillosspercentage;                
                olValue.put(depoId,finalPrice);
            }	
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = olValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_OilLossController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
	}
    
     public class formulaWrapperol{
        public Double hcvCost;
        public Double marketpremiumcost;
        public Double smalllotcost;
        public Double mrfreightcost;
        public Double portchargecost;
        public Double oillosspercentage;
        public String location;
        public String product;
        public Id depoId;
	}
		
    public RE_UtilitywrapperController.lineitemwraapper AMVolDataPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> olformList,
       Map<Id, Double> finalhcval,Map<Id, Double> finalmpval,Map<Id, Double> finalslpval,Map<Id, Double> finalmrfval,Map<Id, Double> finalpcval){
          List<formulaWrapperoiloss> formulaWrapList = new List<formulaWrapperoiloss>();                          
		//Preparing formula data and adding it to the wrapper list
        for(RE_MY_FormulaFetchController.formulaWrapperAMVMY slpformula : olformList){
			formulaWrapperoiloss olwrapper = new formulaWrapperoiloss();			
            olwrapper.hcvCost = finalhcval.containsKey(slpformula.depoId) ? finalhcval.get(slpformula.depoId) : 0;
			olwrapper.marketpremiumcost = finalmpval.containsKey(slpformula.hcfObj.Id) ? finalmpval.get(slpformula.hcfObj.Id) : 0;
            olwrapper.smalllotcost = finalslpval.containsKey(slpformula.hcfObj.Id) ? finalslpval.get(slpformula.hcfObj.Id) : 0;
            olwrapper.mrfreightcost = finalmrfval.containsKey(slpformula.hcfObj.Id) ? finalmrfval.get(slpformula.hcfObj.Id) : 0;
            olwrapper.portchargecost = finalpcval.containsKey(slpformula.hcfObj.Id) ? finalpcval.get(slpformula.hcfObj.Id) : 0;
            olwrapper.oillosspercentage = slpformula.hcfObj.RE_MY_Oil_Loss_Percentage__c != null ? slpformula.hcfObj.RE_MY_Oil_Loss_Percentage__c/100 : 0;
            olwrapper.rbId = slpformula.hcfObj.Id;
            olwrapper.location = slpformula.location;
            olwrapper.product = slpformula.product;
            olwrapper.source = slpformula.hcfObj.RE_Source_Name__c;
            formulaWrapList.add(olwrapper);
        }
		return oilossCalculation(formulaWrapList);
    }
    
	public RE_UtilitywrapperController.lineitemwraapper oilossCalculation(List<formulaWrapperoiloss> formulaWrapList){
        Map<Id, Double> olValue = new Map<Id, Double>();  
        String location;
        String product;
        String source;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        try{
            for(formulaWrapperoiloss wrapperdata : formulaWrapList){						
                Id rbId = wrapperdata.rbId;	
                location = wrapperdata.location;
                product = wrapperdata.product;
                source = wrapperdata.source;
                Double finalPrice = (wrapperdata.hcvCost + wrapperdata.marketpremiumcost +
                                    wrapperdata.smalllotcost + wrapperdata.mrfreightcost + wrapperdata.portchargecost) 
                                    * wrapperdata.oillosspercentage;                
                olValue.put(rbId,finalPrice);
            }	
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = olValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_OilLossController for '+ location +' and '+ product + ' and '+ source +' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
	}
    
     public class formulaWrapperoiloss{
        public Double hcvCost;
        public Double marketpremiumcost;
        public Double smalllotcost;
        public Double mrfreightcost;
        public Double portchargecost;
        public Double oillosspercentage;
        public String location;
        public String product;
        public String source;
        public Id rbId;

       }
}