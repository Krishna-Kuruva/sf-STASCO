public class RE_FreightChargesController {
	public RE_UtilitywrapperController.lineitemwraapper frcPreparation(List<RE_MY_FormulaFetchController.formulaWrapperAMVMY> frcpricinglist, Map<String, Double> curConvMap){
        Map<Id, Double> frcCalculation = new Map<Id, Double>();
        String location;
        String product; 
        String source;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{ 
            for(RE_MY_FormulaFetchController.formulaWrapperAMVMY dpbData : frcpricinglist){ 
                location = dpbData.location;
                product = dpbData.product;
                source = dpbData.hcfObj.RE_Source_Name__r.Name;
                Double value = dpbData.hcfObj.RE_MY_Freight_Charges__c != null ? dpbData.hcfObj.RE_MY_Freight_Charges__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_MY_Freight_Charges_Unit__c != null)
                	conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_MY_Freight_Charges_Unit__c,dpbData.finalUnit,dpbData.country,dpbData.product,curConvMap);
                value = value * conversionmultiplier;                
                frcCalculation.put(dpbData.hcfObj.Id,value);                            
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = frcCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_FreightChargesController for '+ source +' and '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    }
    
    public RE_UtilitywrapperController.lineitemwraapper PHfrPreparation(List<RE_MY_FormulaFetchController.formulaWrapperTH> frcpricinglist, Map<String, Double> curConvMap,List<RE_Market_Quotes__c> latestmarketquotes,Map<String,RE_Product__c> proddataMap){
        Map<Id, Double> frcCalculation = new Map<Id, Double>();
        String location;
        String product;
        RE_UtilitywrapperController.lineitemwraapper finalineitemval = new RE_UtilitywrapperController.lineitemwraapper();        
        RE_unitConversion conv = new RE_unitConversion();
        try{
            for(RE_MY_FormulaFetchController.formulaWrapperTH dpbData : frcpricinglist){ 
                location = dpbData.location;
                product = dpbData.product;
                Double frCharge = dpbData.hcfObj.RE_PH_Freight_Charges__c != null ? dpbData.hcfObj.RE_PH_Freight_Charges__c : 0;
                Double conversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_Freight_Charges_Unit__c != null && proddataMap.containskey(dpbData.product)){
                    conversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_Freight_Charges_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                }
                frCharge = frCharge * conversionmultiplier;     
                Double frQuoteVal = 0;
                Double Qtconversionmultiplier;
                for(RE_Market_Quotes__c mopsQuote : latestmarketquotes){       
                    if(dpbData.hcfObj.RE_PH_Freight_Quote__c == mopsQuote.RE_Quote_Name__c){     
                        if(dpbData.hcfObj.RE_Reference_Product__c != null)
                            Qtconversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,dpbData.hcfObj.RE_Final_Price_Unit__c,dpbData.country, proddataMap.get(dpbData.hcfObj.RE_Reference_Product__r.Name).RE_Product_Group__c,curConvMap);
                        else
                            Qtconversionmultiplier = conv.unitConversionMultiplier(mopsQuote.RE_Rate_Unit__c,dpbData.hcfObj.RE_Final_Price_Unit__c,dpbData.country, proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                        frQuoteVal = mopsQuote.RE_Price__c * Qtconversionmultiplier;
                    }
                }
                Double frsCharge = dpbData.hcfObj.RE_PH_Freight_Shifting_Cost__c != null ? dpbData.hcfObj.RE_PH_Freight_Shifting_Cost__c : 0;
                Double frsconversionmultiplier = 0;
                if(dpbData.hcfObj.RE_PH_Freight_Shifting_Cost_Unit__c != null && proddataMap.containskey(dpbData.product))
                    frsconversionmultiplier = conv.unitConversionMultiplier(dpbData.hcfObj.RE_PH_Freight_Shifting_Cost_Unit__c,dpbData.finalUnit,dpbData.country,proddataMap.get(dpbData.product).RE_Product_Group__c,curConvMap);
                frsCharge = frsCharge * frsconversionmultiplier;
                Double Qtpercentage = dpbData.hcfObj.RE_PH_Freight_Conversion_Factor__c != null ? dpbData.hcfObj.RE_PH_Freight_Conversion_Factor__c/100 : 0;     
                Double HCVPerc = dpbData.hcfObj.RE_TH_HCV_Quote1_Percent__c != null ? dpbData.hcfObj.RE_TH_HCV_Quote1_Percent__c/100 : 0;
                
                frcCalculation.put(dpbData.hcfObj.Id,HCVPerc * Qtpercentage*(frCharge+frQuoteVal+frsCharge));  
            }        
            finalineitemval.errorMessage = '';
            finalineitemval.finalval = frcCalculation;
        }
        catch(Exception ex){
            finalineitemval.errorMessage = 'Error at RE_FreightChargesController for '+ location +' and '+ product + ' ' + ex.getMessage();
            finalineitemval.finalval = new Map<Id, Double>();
        }
        return finalineitemval;
    } 
}