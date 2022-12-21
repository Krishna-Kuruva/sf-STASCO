public class RE_MY_AdditiveCostController { 
    
    public RE_UtilitywrapperController.lineitemwraapper additivecostCalculation(List<RE_Depot_Pricing_Backbone__c> malaysiaCCList, List<RE_Product__c> prodlist, 
                                                 Map<String,Double> curConvMap){
        Map<Id,Double> finalacval = new Map<Id,Double>();
		String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        RE_unitConversion conv = new RE_unitConversion();
		try{
            for(RE_Depot_Pricing_Backbone__c dpbData : malaysiaCCList){
                Double costdata = 0;
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                String prodName;
                if(dpbData.RE_Country__r.Name == 'Philippines')
                	prodName = dpbData.RE_Reference_Product__c != null ? dpbData.RE_Reference_Product__r.Name : dpbdata.RE_Product_Name__r.Name;
                else
                    prodName = dpbdata.RE_Product_Name__r.Name;
                    
                for(RE_Product__c prodData : prodlist){  
                    if(prodName == prodData.Name && prodData.RE_Additive_Cost__c != null && prodData.RE_Additive_Cost_Unit__c != null){  
						                     
                        Double conversionmultiplier = conv.unitConversionMultiplier(prodData.RE_Additive_Cost_Unit__c,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                            prodData.Name,curConvMap);
                		costdata = prodData.RE_Additive_Cost__c * conversionmultiplier;
                    }
                }                
                finalacval.put(dpbData.Id, costdata);
            }    
        	finalineitemval.errorMessage = '';
            finalineitemval.finalval = finalacval;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_AdditiveCostController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
}