public class RE_AssessedPremiaTriggerHelper
{
    public static void onAfterAssessedPremiaTriggerHelper(List<assessed_premia__c> newassessedapremiaLst
                                               ,Map<ID,assessed_premia__c> oldassessedapremiaMap
                                               ,Map<ID,assessed_premia__c> newassessedapremiaMap)
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

        if(extQuoteSettingsMap.size()>0 )
        {
            for(assessed_premia__c aprem :newassessedapremiaLst)
            {
                String key = aprem.Quotation_source__c + '_' + aprem.Quotation_type__c + '_' + aprem.Quotation_number__c;
                
                System.debug('Checking for '+key);
                if(extQuoteSettingsMap.containsKey(key))
                {
                    RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();
                    RE_ExternalQuoteMapping__c extQuote = extQuoteSettingsMap.get(key);
                    
                    markQuote.RE_Quote_Name__c = extQuote.RE_Quote_Name__c;
                    markQuote.RE_Quote_Type__c = extQuote.RE_Quote_Type__c;
                    markQuote.RE_Rate_Unit__c = RE_ExternalTriggerHelper.rateUnitValue(aprem.Default_currency__c,aprem.Default_UoM__c);
                    markQuote.RE_Price__c = aprem.Price__c;
                    markQuote.RE_Pricing_Date__c = RE_ExternalTriggerHelper.convertToDate(aprem.Quotation_date__c,'MOPS');
                    markQuote.RE_Tracker__c = 'D';
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