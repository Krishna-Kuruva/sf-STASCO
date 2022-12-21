public class RE_ExternalFXRatesHelper {     
    public static void onAfterExternalFXRatesHelper(List<RE_External_FX_Rates__c> newExternalFXRateList){
        Map<String,RE_ExternalFXMappings__c> extFXRateCustSetting = RE_ExternalFXMappings__c.getAll();
        List<RE_FX_Rates__c> sFXRate = new List<RE_FX_Rates__c>();
        for(RE_External_FX_Rates__c extFXRateObj : newExternalFXRateList){
            for(String str : extFXRateCustSetting.keySet()){  //iterating through the custom settings
                
                RE_ExternalFXMappings__c extFXRateValue = extFXRateCustSetting.get(str); //getting the key value 
                System.debug('extFXRateValue :'+ extFXRateValue);
                //comparing the GSAP data with the custom settings data
                if(extFXRateValue.RE_External_Currency__c == extFXRateObj.RE_Currency__c){
                    System.debug('extFXRateValue.RE_External_Currency__c :'+ extFXRateValue.RE_External_Currency__c);
                    List<String> sTradeType = new List<String>{'Buy','Sell','Exchange Rate'};
                    for(Integer i=0; i<sTradeType.size(); i++){
                        RE_FX_Rates__c FXDataCTS   = new RE_FX_Rates__c();
                        FXDataCTS.RE_Conversion_Unit__c = extFXRateValue.RE_Conversion_Unit__c;
                        FXDataCTS.RE_Base_Unit__c  =  extFXRateValue.RE_Base_Unit__c; 
                        FXDataCTS.RE_Forex_Name__c = extFXRateValue.RE_Forex_Name__c;
                        FXDataCTS.RE_Trade_Type__c = sTradeType[i];
                        //FXDataCTS.RE_Tracker__c = 'D';
                        FXDataCTS.RE_Pricing_Date__c = RE_ExternalTriggerHelper.convertToDate(extFXRateObj.RE_Date__c,'FX');                 
                        if(extFXRateValue.RE_Conversion_Unit__c.contains('CTS')){                            
                            if(sTradeType[i]=='Buy')
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Buy_Rate__c*100;                            
                            if(sTradeType[i]=='Sell')                            
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Sell_Rate__c*100;                              
                            if(sTradeType[i]=='Exchange Rate')                            
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Mean_Rate__c*100;                               
                            
                        }
                        else{                            
                            if(sTradeType[i]=='Buy')
                            FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Buy_Rate__c;
                            if(sTradeType[i]=='Sell')
                            FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Sell_Rate__c;  
                            if(sTradeType[i]=='Exchange Rate')
                            FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Mean_Rate__c;
                        }
                        sFXRate.add(FXDataCTS);
                    } 
                }
            }            
        }
        insert sFXRate;        
    }  
}