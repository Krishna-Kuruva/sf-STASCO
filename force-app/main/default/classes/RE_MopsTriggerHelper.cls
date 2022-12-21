public class RE_MopsTriggerHelper
{
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 30-Dec-2019
	Details	: Initial Development
	*/
	
    public static void onAfterMopsTriggerHelper(List<Mops__c> newMopsLst
                                               ,Map<ID,Mops__c> oldMopsMap
                                               ,Map<ID,Mops__c> newMopsMap)
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
            for(Mops__c mop :newMopsLst)
            {
                String key = mop.Quotation_source__c + '_' + mop.Quotation_Type__c + '_' + mop.Quotation_number__c;
                
                System.debug('Checking for '+key);
                if(extQuoteSettingsMap.containsKey(key))
                {
                    RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();
                    RE_ExternalQuoteMapping__c extQuote = extQuoteSettingsMap.get(key);
                    
                    markQuote.RE_Quote_Name__c = extQuote.RE_Quote_Name__c;
                    markQuote.RE_Quote_Type__c = extQuote.RE_Quote_Type__c;                    
                    markQuote.RE_Rate_Unit__c = RE_ExternalTriggerHelper.rateUnitValue(mop.Default_Currency__c, mop.Default_UoM__c);
                    markQuote.RE_Price__c = mop.Price__c;
                    markQuote.RE_Pricing_Date__c = RE_ExternalTriggerHelper.convertToDate(mop.Quotation_Date__c,'MOPS');
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