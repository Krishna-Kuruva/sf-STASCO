public class RE_ExternalExchangeRateTriggerHelper {
    /*
Version : 0.0 
Author	: Souvik
Date	: 24-Sep-2020
Details	: GSAP Integration
*/
    
    public static void onAfterExternalFXRatesHelper(List<RE_External_Exchange_Rate__c> newExternalFXRateList
                                                    ,Map<ID,RE_External_Exchange_Rate__c> newExternalFXRateMap
                                                    ,Map<ID,RE_External_Exchange_Rate__c> oldExternalFXRateMap)
    {
        
        Map<String,RE_ExternalFXMappings__c> extFXRateCustSetting = RE_ExternalFXMappings__c.getAll();
        List<RE_FX_Rates__c> sFXRate = new List<RE_FX_Rates__c>();
        
        for(RE_External_Exchange_Rate__c extFXRateObj : newExternalFXRateList)
        {
            for(String str : extFXRateCustSetting.keySet())
            {                
                RE_ExternalFXMappings__c extFXRateValue = extFXRateCustSetting.get(str); 
                if(extFXRateValue.RE_External_Currency__c == extFXRateObj.RE_To_Currency__c && extFXRateValue.RE_Type__c == extFXRateObj.RE_Exchange_Rate_Type__c)
                {
                    
                    List<String> sTradeType = new List<String>{'Buy','Sell','Exchange Rate'};
                        for(Integer i=0; i<sTradeType.size(); i++)
                    {
                        RE_FX_Rates__c FXDataCTS   = new RE_FX_Rates__c();
                        FXDataCTS.RE_Tracker__c = 'D+1';
                        FXDataCTS.RE_Conversion_Unit__c = extFXRateValue.RE_Conversion_Unit__c;
                        FXDataCTS.RE_Base_Unit__c  =  extFXRateValue.RE_Base_Unit__c; 
                        FXDataCTS.RE_Forex_Name__c = extFXRateValue.RE_Forex_Name__c;
                        FXDataCTS.RE_Trade_Type__c = sTradeType[i];
                        FXDataCTS.RE_Pricing_Date__c = RE_ExternalTriggerHelper.convertToDate(extFXRateObj.RE_Effective_Date__c,'ExFX');   
                        
                        if(extFXRateValue.RE_Conversion_Unit__c.contains('CTS') || extFXRateValue.RE_Conversion_Unit__c == 'STG'){                            
                            if(sTradeType[i]=='Buy')
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Rate__c*100;                            
                            if(sTradeType[i]=='Sell')                            
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Rate__c*100;                              
                            if(sTradeType[i]=='Exchange Rate')                            
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Rate__c*100;                                                           
                        }
                        else{                            
                            if(sTradeType[i]=='Buy')
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Rate__c;
                            if(sTradeType[i]=='Sell')
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Rate__c;  
                            if(sTradeType[i]=='Exchange Rate')
                                FXDataCTS.RE_Forex_Rate__c = extFXRateObj.RE_Rate__c;
                        }
                        sFXRate.add(FXDataCTS);
                    } 
                }
            }
        }
        if(sFXRate.size()>0)
        {
            try{insert sFXRate;}
            catch(Exception e)
            {System.debug('Failed while inserting to Exchange Rates '+e.getMessage());}
        }
    }  
}