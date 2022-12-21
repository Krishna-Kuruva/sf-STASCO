public class RE_SG_CostPriceAdjustmentController { 
    
    //Preparing formula data and adding values to the Map
    public RE_UtilitywrapperController.lineitemwraapper cpaPreparation(List<RE_Depot_Pricing_Backbone__c> depotpricinglist,Map<String, Double> curConvMap){
        Map<Id, Double> cpaval = new Map<Id, Double>(); 
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();  
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){ 
                Double value = dpbdata.RE_Cost_Price_Adjustment__c != null ? dpbdata.RE_Cost_Price_Adjustment__c : 0;
                Double conversionmultiplier = 0;
                if(dpbdata.RE_Cost_Price_Adjustment_Unit__c != null)
                    conversionmultiplier = conv.unitConversionMultiplier(dpbdata.RE_Cost_Price_Adjustment_Unit__c,dpbData.RE_Final_Price_Unit__c,
                                                                         dpbData.RE_Country__r.Name, dpbData.RE_Product_Name__r.Name,curConvMap);
                value = value * conversionmultiplier;
                cpaval.put(dpbData.Id,value);                            
            }
           	finalineitemval.errorMessage = '';
            finalineitemval.finalval = cpaval;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_StorageAndHandlingTariffController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    } 
}