public class RE_PremiaTriggerHelper
{
    public static void onAfterPremiaTriggerHelper(List<Premia__c> newPremiaLst
                                               ,Map<ID,Premia__c> oldPremiaMap
                                               ,Map<ID,Premia__c> newPremiaMap)
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
            for(Premia__c prem :newPremiaLst)
            {
                String key = prem.Quotation_source__c + '_' + prem.Quotation_type__c + '_' + prem.Quotation_number__c;
                
                System.debug('Checking for '+key);
                if(extQuoteSettingsMap.containsKey(key))
                {
                    RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();
                    RE_ExternalQuoteMapping__c extQuote = extQuoteSettingsMap.get(key);
                    
                    markQuote.RE_Quote_Name__c = extQuote.RE_Quote_Name__c;
                    markQuote.RE_Quote_Type__c = extQuote.RE_Quote_Type__c;
                    markQuote.RE_Rate_Unit__c = RE_ExternalTriggerHelper.rateUnitValue(prem.Default_currency__c,prem.Default_UoM__c);
                    markQuote.RE_Price__c = prem.Price__c;
                    markQuote.RE_Tracker__c = 'D'; 
                    markQuote.RE_Pricing_Date__c = RE_ExternalTriggerHelper.convertToDate(prem.Quotation_date__c,'MOPS');
                    
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