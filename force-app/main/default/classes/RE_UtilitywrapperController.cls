public class RE_UtilitywrapperController {   
	
    public class lineitemwraapper{
        public string errorMessage;	
        public Map<Id, Double> finalval;
    }       
    
    public class formulaWrappertp{
		public Double PremiumPerc;
        public Double PremiumValue;
        public String location;
        public String product;
        public Id depoId;
	}    
    
    public Static lineitemwraapper finalCalculation(List<formulaWrappertp> formulaWrapList, String className){
        String location;
        String product;
        lineitemwraapper finalineitemval = new lineitemwraapper();        
        Map<Id, Double> tppValue = new Map<Id, Double>(); 
        try{
            for(formulaWrappertp wrapperdata : formulaWrapList){                
                location = wrapperdata.location;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.PremiumPerc * wrapperdata.PremiumValue ) ;
                tppValue.put(wrapperdata.depoId, finalPrice);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = tppValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at '+className+' for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval; 
	} 

    public class rbpformulaWrapper{
		public Double PremiumPerc;
        public Double PremiumValue;
        public String location;
        public String source;
        public String product;
        public Id rbId;
	}

    public Static lineitemwraapper rbfinalCalculation(List<rbpformulaWrapper> formulaWrapList, String className){
        String location;
        String product;
        String source;
        lineitemwraapper finalineitemval = new lineitemwraapper();
        Map<Id, Double> tppValue = new Map<Id, Double>();
        try{
            for(rbpformulaWrapper wrapperdata : formulaWrapList){
                location = wrapperdata.location;
                source = wrapperdata.source;
                product = wrapperdata.product;
                Double finalPrice = (wrapperdata.PremiumPerc * wrapperdata.PremiumValue ) ;
                tppValue.put(wrapperdata.rbId, finalPrice);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = tppValue;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at '+className+' for '+source + ' and '+location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval; 
	} 
    public class formulaWrapperee{
        public Double MOPSval1;
        public Double MOPSval2;
		//public Double FixedSurcharge;
        public String location;
        public String product;
        public Id depoId;
    }
    
}