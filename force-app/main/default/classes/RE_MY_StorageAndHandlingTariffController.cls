public class RE_MY_StorageAndHandlingTariffController {     
    //Preparing formula data and adding values to the Map
    public RE_UtilitywrapperController.lineitemwraapper shtPreparation(List<RE_Depot_Pricing_Backbone__c> depotpricinglist,Map<String, Double> curConvMap){
        Map<Id, Double> shtCalculation = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){ 
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                Double value = dpbData.RE_Snh_Cost__c != null ? dpbData.RE_Snh_Cost__c : 0;
                Double conversionmultiplier = conv.unitConversionMultiplier(dpbData.RE_SnH_Unit__c,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                            dpbData.RE_Product_Name__r.Name,curConvMap);
                value = value * conversionmultiplier;                
                shtCalculation.put(dpbData.Id,value);                            
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = shtCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_StorageAndHandlingTariffController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    
    //Preparing formula data and adding values to the Map
    public RE_UtilitywrapperController.lineitemwraapper spaPreparation(List<RE_Depot_Pricing_Backbone__c> depotpricinglist,Map<String, Double> curConvMap){
        Map<Id, Double> shtCalculation = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_Depot_Pricing_Backbone__c dpbData : depotpricinglist){ 
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                Double value = dpbData.RE_Spot_Price_Adjustment__c != null ? dpbData.RE_Spot_Price_Adjustment__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.RE_Spot_Price_Adjustment_Unit__c != null)
                	conversionmultiplier = conv.unitConversionMultiplier(dpbData.RE_Spot_Price_Adjustment_Unit__c,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                            dpbData.RE_Product_Name__r.Name,curConvMap);
                value = value * conversionmultiplier;                
                shtCalculation.put(dpbData.Id,value);   
                System.debug('loc -prod-value'+location+'--'+product+'--'+value+'--'+dpbData.RE_Spot_Price_Adjustment__c);
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = shtCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_StorageAndHandlingTariffController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    
    public RE_UtilitywrapperController.lineitemwraapper shospPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> shosppricinglist, Map<String, Double> curConvMap){
        Map<Id, Double> shtCalculation = new Map<Id, Double>();
        String location;
        String product;
        String source;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperAMVMY dpbData : shosppricinglist){ 
                location = dpbData.location;
                product = dpbData.product;
                source = dpbData.hcfObj.RE_Source_Name__r.Name;
                Double value = dpbData.hcfObj.RE_MY_Storage_Handling_Cost_OSP__c != null ? dpbData.hcfObj.RE_MY_Storage_Handling_Cost_OSP__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_MY_Storage_Handling_Unit__c != null)
                	conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_MY_Storage_Handling_Unit__c,dpbData.finalUnit,dpbData.country,dpbData.product,curConvMap);
                value = value * conversionmultiplier;                
                shtCalculation.put(dpbData.hcfObj.Id,value);                            
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = shtCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_StorageAndHandlingTariffController for '+ source +' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
}