public class RE_ExternalMarketQuotesTriggerHelper {
/*
	Version : 0.0 
	Author	: Souvik 
	Date	: 24-09-2020
	Details	: GSAP Integration
	*/
	
    public static void onAfterMopsTriggerHelper(List<RE_External_Market_Quotes__c> newMopsLst
                                               ,Map<ID,RE_External_Market_Quotes__c> oldMopsMap
                                               ,Map<ID,RE_External_Market_Quotes__c> newMopsMap)
    {
        Map<String,RE_ExternalQuoteMapping__c> extQuoteSettings = RE_ExternalQuoteMapping__c.getAll();
        Map<String,RE_ExternalQuoteMapping__c> extQuoteSettingsMap = new Map<String,RE_ExternalQuoteMapping__c>();
        list<RE_Market_Quotes__c> insertMarkQuote = new list<RE_Market_Quotes__c>();
        
        for(String key: extQuoteSettings.keyset())
        {
            RE_ExternalQuoteMapping__c extQuote = extQuoteSettings.get(key);
            extQuoteSettingsMap.put(extQuote.External_Quote_Source__c + '_' + extQuote.External_Quote_Type__c + '_' + extQuote.External_Quotation_Number__c,
                                    extQuote);
        }
		System.debug('extQuoteSettingsMap--'+extQuoteSettingsMap);
        if(extQuoteSettingsMap.size()>0 )
        {
            for(RE_External_Market_Quotes__c mop : newMopsLst)
            {
                String key = mop.RE_Quote_Source__c + '_' + mop.RE_Quote_Type__c + '_' + mop.RE_Quote_No__c;
                Double defaultVal = Double.valueOf(mop.RE_Default_Per_Unit__c);
                System.debug('Checking for '+key);
                if(extQuoteSettingsMap.containsKey(key))
                {
                    RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();
                    RE_ExternalQuoteMapping__c extQuote = extQuoteSettingsMap.get(key);
                    
                    markQuote.RE_Quote_Name__c = extQuote.RE_Quote_Name__c;
                    markQuote.RE_Quote_Type__c = extQuote.RE_Quote_Type__c;                    
                    markQuote.RE_Rate_Unit__c = RE_ExternalTriggerHelper.rateUnitValue(mop.RE_Default_Currency__c, mop.RE_Unit_of_Measure__c);
                    markQuote.RE_Price__c = extQuote.RE_Multiplier__c != null ? (mop.RE_Quote_Price__c/defaultVal) * extQuote.RE_Multiplier__c : mop.RE_Quote_Price__c/defaultVal;
                    markQuote.RE_Pricing_Date__c = RE_ExternalTriggerHelper.convertToDate(mop.RE_Quote_Date__c,'ExMOPS');
                    markQuote.RE_Tracker__c = 'D';
                    markQuote.RE_Country_Name__c = extQuote.RE_Country__c;
                    System.debug('Inserting ' + markQuote);
                    insertMarkQuote.add(markQuote);
                }
            }
        }
        
        if(insertMarkQuote.size()>0)
        {
            try{insert insertMarkQuote;}
            catch(Exception e)
            {System.debug('Failed while inserting to Market Quotes '+e.getMessage());}
        }
    }
}