public class RE_MY_PrimaryTransportCostController {
    public RE_UtilitywrapperController.lineitemwraapper primaryTransportCostpreparation(List<RE_Depot_Pricing_Backbone__c> ptcCalculationList,
                                                                                        Map<String,Double> curConvMap){
        Map<Id,Double> ptcvalMap = new Map<Id,Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        Double ptcost;
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_Depot_Pricing_Backbone__c dpbdata : ptcCalculationList){
                location = dpbdata.RE_Depot_Name__r.Name;
                product = dpbdata.RE_Product_Name__r.Name;
                ptcost = 0;
                Double ptcval = dpbdata.RE_Primary_Transport_Cost__c != null ? dpbdata.RE_Primary_Transport_Cost__c : 0;
                Double ptoval = dpbdata.RE_Primary_Transport_Offset__c != null ? dpbdata.RE_Primary_Transport_Offset__c : 0;
                ptcost = ptcval + ptoval;
                if(dpbdata.RE_Primary_Transport_Unit__c != null){
                    Double conversionmultiplier = conv.unitConversionMultiplier(dpbdata.RE_Primary_Transport_Unit__c,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                                dpbData.RE_Product_Name__r.Name,curConvMap);
                    ptcost = ptcost * conversionmultiplier;                                        
                }
                 ptcvalMap.put(dpbdata.Id,ptcost);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = ptcvalMap;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_PrimaryTransportCostController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    
    public RE_UtilitywrapperController.lineitemwraapper AMVprimaryTransportCostpreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> ptcCalculationList,
                                                                                        Map<String,Double> curConvMap){
      Map<Id,Double> ptcvalMap = new Map<Id,Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        Double ptcost;
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperAMVMY dpbdata : ptcCalculationList){
                location = dpbdata.location;//dpbData.RE_Depot_Name__r.Name;
                product = dpbData.hcfObj.RE_Product_Name__r.Name;
                ptcost = 0;
                Double ptcval = dpbdata.hcfObj.RE_MY_Primary_Transport_Cost__c != null ? dpbdata.hcfObj.RE_MY_Primary_Transport_Cost__c : 0;
                Double ptoval = dpbdata.hcfObj.RE_MY_Primary_Transport_Offset__c != null ? dpbdata.hcfObj.RE_MY_Primary_Transport_Offset__c : 0;
                ptcost = ptcval + ptoval;
                if(dpbdata.hcfObj.RE_MY_Primary_Transport_Unit__c != null){
                    Double conversionmultiplier = conv.unitConversionMultiplier(dpbdata.hcfObj.RE_MY_Primary_Transport_Unit__c,dpbData.finalUnit,dpbData.country,
                                                                                dpbData.hcfObj.RE_Product_Name__r.Name,curConvMap);
                    ptcost = ptcost * conversionmultiplier;                                        
                }
                 ptcvalMap.put(dpbdata.hcfObj.Id,ptcost);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = ptcvalMap;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_PrimaryTransportCostController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    //Primary Transport Calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper primaryTransportCostpreparationPH(List<RE_Depot_Pricing_Backbone__c> ptcCalculationList,
                                                                                        Map<String,Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id,Double> ptcvalMap = new Map<Id,Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();
        Double ptcost = 0;
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_Depot_Pricing_Backbone__c dpbdata : ptcCalculationList){
                location = dpbData.RE_Depot_Name__r.Name;
                product = dpbData.RE_Product_Name__r.Name;
                ptcost = dpbdata.RE_Primary_Transport_Cost__c != null ? dpbdata.RE_Primary_Transport_Cost__c : 0;
                if(dpbdata.RE_Primary_Transport_Unit__c != null && proddataMap.containskey(product)){
                    Double conversionmultiplier = conv.unitConversionMultiplier(dpbdata.RE_Primary_Transport_Unit__c,dpbData.RE_Final_Price_Unit__c,dpbData.RE_Country__r.Name,
                                                                                proddataMap.get(product).RE_Product_Group__c,curConvMap);
                    ptcost = ptcost * conversionmultiplier;                                        
                }
                 ptcvalMap.put(dpbdata.Id,ptcost);
            }
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = ptcvalMap;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_MY_PrimaryTransportCostController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    } 
}