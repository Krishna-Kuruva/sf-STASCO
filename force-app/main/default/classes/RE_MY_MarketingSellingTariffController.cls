public class RE_MY_MarketingSellingTariffController {    
    
    //Preparing formula data and adding values to the Map
    public RE_UtilitywrapperController.lineitemwraapper mstPreparation(List<RE_Depot_Pricing_Backbone__c> depotpricinglist,Map<String, Double> curConvMap){
        Map<Id, Double> mstCalculation = new Map<Id, Double>(); 
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){   
                Double value = 0;   
                Double conversionmultiplier;
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                if(dpbData.RE_Country__r.Name == 'Malaysia'){
                    conversionmultiplier = conv.unitConversionMultiplier(System.Label.RE_MY_Marketing_Selling_Tariff_Unit,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                                   dpbData.RE_Product_Name__r.Name,curConvMap);
                    value = Double.valueOf(System.Label.RE_MY_Marketing_Selling_Tariff) * conversionmultiplier;      
                }
                else if(dpbData.RE_Country__r.Name == 'Singapore'){
                    conversionmultiplier = conv.unitConversionMultiplier(System.Label.RE_SG_Marketing_Selling_Tariff_Unit,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                           dpbData.RE_Product_Name__r.Name,curConvMap);
            		value = Double.valueOf(System.Label.RE_SG_Marketing_Selling_Tariff) * conversionmultiplier; 
                }
                mstCalculation.put(dpbData.Id,value);                            
            }
        	finalineitemval.errorMessage = '';
            finalineitemval.finalval = mstCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_MarketingSellingTariffController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;    
            
    }
}