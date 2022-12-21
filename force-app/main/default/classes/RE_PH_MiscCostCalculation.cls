public class RE_PH_MiscCostCalculation {
    //Freight Shifting Cost Calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper PHfreightShiftngPreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> frshiftingchargepricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> frcCalculation = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : frshiftingchargepricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double frCharge = dpbData.hcfObj.RE_PH_Freight_Shifting_Cost__c != null ? dpbData.hcfObj.RE_PH_Freight_Shifting_Cost__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_Freight_Shifting_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_Freight_Shifting_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                frCharge = frCharge * conversionmultiplier;
                frcCalculation.put(depoId,frCharge);			                               
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = frcCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at PHfreightShiftngPreparation for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    } 
    //Demurrage Calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper PHdemurragePreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> dmrgCalculation = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double demurrage = dpbData.hcfObj.RE_PH_Demurrage__c != null ? dpbData.hcfObj.RE_PH_Demurrage__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_Demurrage_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_Demurrage_Unit__c,dpbData.finalUnit,dpbData.country, proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                demurrage = demurrage * conversionmultiplier;
                dmrgCalculation.put(depoId,demurrage);	
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = dmrgCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at PHdemurragePreparation for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    } 
    //FLC Service Cost Calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper flcservicePreparationPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> flcserviceCalculation = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double flcCost = dpbData.hcfObj.RE_PH_FLC_Service_Fee__c != null ? dpbData.hcfObj.RE_PH_FLC_Service_Fee__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_FLC_Service_Fee_Unit__c != null  && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_FLC_Service_Fee_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                flcCost = flcCost * conversionmultiplier;
                flcserviceCalculation.put(depoId,flcCost);
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = flcserviceCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at flcservicePreparationPH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    } 
    // Misc Brokerage Fee Calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper miscbrokeragefeePrepPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> miscbrokeragefeeCalculation = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double brokrgeFee = dpbData.hcfObj.RE_PH_MISC_Brokerage_Fee__c != null ? dpbData.hcfObj.RE_PH_MISC_Brokerage_Fee__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_MISC_Brokerage_Fee_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_MISC_Brokerage_Fee_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                brokrgeFee = brokrgeFee * conversionmultiplier;
                miscbrokeragefeeCalculation.put(depoId,brokrgeFee);	
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = miscbrokeragefeeCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at miscbrokeragefeePrepPH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    // Misc. Hosehandling Fee Calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper mischosehandlingfeePH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> mischosehandlingfee = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double hosehandlingFee = dpbData.hcfObj.RE_PH_MISC_Hosehandling_Cost__c != null ? dpbData.hcfObj.RE_PH_MISC_Hosehandling_Cost__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_MISC_Hosehandling_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_MISC_Hosehandling_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                hosehandlingFee = hosehandlingFee * conversionmultiplier;
                mischosehandlingfee.put(depoId,hosehandlingFee);
               
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = mischosehandlingfee;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at mischosehandlingfeePH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    // Misc. Port Charge Calculation
    public RE_UtilitywrapperController.lineitemwraapper miscportchargePH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> miscportchargefee = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double portCharge = dpbData.hcfObj.RE_PH_MISC_Port_Charges__c != null ? dpbData.hcfObj.RE_PH_MISC_Port_Charges__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_MISC_Port_Charges_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_MISC_Port_Charges_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                portCharge = portCharge * conversionmultiplier;
                miscportchargefee.put(depoId,portCharge);
                
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = miscportchargefee;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at miscportchargePH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    // Misc. PQ Cost
    public RE_UtilitywrapperController.lineitemwraapper miscPQcostPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> miscPQcost = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double PQCharge = dpbData.hcfObj.RE_PH_MISC_PQ_Cost__c != null ? dpbData.hcfObj.RE_PH_MISC_PQ_Cost__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_MISC_PQ_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_MISC_PQ_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                PQCharge = PQCharge * conversionmultiplier;
                miscPQcost.put(depoId,PQCharge);
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = miscPQcost;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at miscPQcostPH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    // Misc. Shifting Cost for PH
    public RE_UtilitywrapperController.lineitemwraapper miscShiftingcostPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> miscShiftingcost = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double shiftingcost = dpbData.hcfObj.RE_PH_MISC_Shifting_Cost__c != null ? dpbData.hcfObj.RE_PH_MISC_Shifting_Cost__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_MISC_Shifting_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_MISC_Shifting_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                shiftingcost = shiftingcost * conversionmultiplier;
                miscShiftingcost.put(depoId,shiftingcost);	
                
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = miscShiftingcost;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at miscShiftingcostPH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    // Misc. Waterfront Operations Cost fro PH
    public RE_UtilitywrapperController.lineitemwraapper miscWaterfrontOpscostPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> miscWatrfrontcost = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double waterfrontcost = dpbData.hcfObj.RE_PH_MISC_Waterfront_Operations_Cost__c != null ? dpbData.hcfObj.RE_PH_MISC_Waterfront_Operations_Cost__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_Waterfront_Operations_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_Waterfront_Operations_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                waterfrontcost = waterfrontcost * conversionmultiplier;
                miscWatrfrontcost.put(depoId,waterfrontcost);				
                                        
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = miscWatrfrontcost;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at miscWaterfrontOpscostPH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    // Misc. Terminal Cost for PH
    public RE_UtilitywrapperController.lineitemwraapper miscTerminalcostPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> miscTerminalcost = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double terminalcost = dpbData.hcfObj.RE_PH_Terminal_Cost__c != null ? dpbData.hcfObj.RE_PH_Terminal_Cost__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_Terminal_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_Terminal_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                terminalcost = terminalcost * conversionmultiplier;
                miscTerminalcost.put(depoId,terminalcost);
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = miscTerminalcost;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at miscTerminalcostPH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    // Wharfage cost Calculation for PH
    public RE_UtilitywrapperController.lineitemwraapper wharfagecostPH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> wharfagecostMap = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double wharfagecost = dpbData.hcfObj.RE_PH_Wharfage_Cost__c != null ? dpbData.hcfObj.RE_PH_Wharfage_Cost__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_Wharfage_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_Wharfage_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                wharfagecost = wharfagecost * conversionmultiplier;
                wharfagecostMap.put(depoId,wharfagecost);
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = wharfagecostMap;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at wharfagecostPH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    
    // Fuel Marking Factor * MISC - Fuel Marking Fee Calculation
    public RE_UtilitywrapperController.lineitemwraapper fuelmarkingfeePH(List<RE_MY_FormulaFetchController.formulaWrapperTH> dpbpricinglist, Map<String, Double> curConvMap,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> fuelmarkingfeeMap = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : dpbpricinglist){ 
                Id depoId = dpbData.depoId;
                location = dpbData.location;
                product = dpbData.product;
                Double fuelmarkingfee = dpbData.hcfObj.RE_PH_MISC_Fuel_Marking_Fee__c != null ? dpbData.hcfObj.RE_PH_MISC_Fuel_Marking_Fee__c : 0;
                //fetching the value of fuel marking factor
                Double fuelmarkingfactor = dpbData.hcfObj.RE_PH_Fuel_Marking_Factor__c != null ? dpbData.hcfObj.RE_PH_Fuel_Marking_Factor__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_MISC_Fuel_Marking_Fee_Unit__c != null && proddataMap.containskey(dpbData.product))
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_MISC_Fuel_Marking_Fee_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                fuelmarkingfee = fuelmarkingfee * conversionmultiplier;
                fuelmarkingfeeMap.put(depoId,fuelmarkingfee * fuelmarkingfactor);
                
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = fuelmarkingfeeMap;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at fuelmarkingfeePH for '+' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    } 
}