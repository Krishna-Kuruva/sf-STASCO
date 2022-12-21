@isTest
public class RE_MopsTriggerHelperTest {
    /*
	Version : 1.0 
	Author	: Souvik
	Date	: 21-Oct-2020
	Details	: Initial Development
	*/
	
    @isTest
    static void doTest()
    {
        test.startTest();
        List<RE_Trigger_Activate__c> trglist = new List<RE_Trigger_Activate__c>();
        RE_Trigger_Activate__c trgact1 = new RE_Trigger_Activate__c();
		trgact1.Name = 'RE_ExternalMarketQuotesTrigger';
		trgact1.RE_Active__c = True;
        trglist.add(trgact1);
        RE_Trigger_Activate__c trgact2 = new RE_Trigger_Activate__c();
		trgact2.Name = 'RE_ExternalExchangeRateTrigger';
		trgact2.RE_Active__c = True;
        trglist.add(trgact2);
        RE_Trigger_Activate__c trgact3 = new RE_Trigger_Activate__c();
        trgact3.Name = 'RE_ExternalFXMappings';
        trgact3.RE_Active__c = True;
        trglist.add(trgact3);
        RE_Trigger_Activate__c trgact4 = new RE_Trigger_Activate__c();
        trgact4.Name = 'RE_PremiaTrigger';
        trgact4.RE_Active__c = True;
        trglist.add(trgact4);
        RE_Trigger_Activate__c trgact5 = new RE_Trigger_Activate__c();
        trgact5.Name = 'RE_AssessedPremiaTrigger';
        trgact5.RE_Active__c = True;
        trglist.add(trgact5);
        RE_Trigger_Activate__c trgact6 = new RE_Trigger_Activate__c();
        trgact6.Name = 'RE_MopsTrigger';
        trgact6.RE_Active__c = True;
        trglist.add(trgact6);
        insert trglist;
        RE_ExternalQuoteMapping__c extQuote = new RE_ExternalQuoteMapping__c();
        extQuote.name='test';
        extQuote.External_Quote_Source__c = 'testSource';
        extQuote.External_Quote_Type__c = 'testType';
        extQuote.External_Quotation_Number__c = 'testNum';
        extQuote.RE_Quote_Name__c = 'testName';
        extQuote.RE_Quote_Type__c = 'testType';
        insert extQuote;
        
        RE_ExternalQuoteMapping__c extQuote1 = new RE_ExternalQuoteMapping__c();
        extQuote1.name='test1';
        extQuote1.External_Quote_Source__c = 'tS';
        extQuote1.External_Quote_Type__c = 'tT';
        extQuote1.External_Quotation_Number__c = 'testNum1';
        extQuote1.RE_Quote_Name__c = 'testName1';
        extQuote1.RE_Quote_Type__c = 'testType1';
        insert extQuote1;
        
        Mops__c mop = new Mops__c();
        mop.Quotation_source__c = 'testSource';
        mop.Quotation_Type__c = 'testType';
        mop.Quotation_number__c = 'testNum';
        mop.Default_Currency__c = 'USD';
        mop.Default_UoM__c = 'Lr';
        mop.Price__c = 1;
        mop.Quotation_date__c = '01.01.2020';
        insert mop;
        
        Premia__c prem = new Premia__c();
        prem.Quotation_source__c = 'testSource';
        prem.Quotation_Type__c = 'testType';
        prem.Quotation_number__c = 'testNum';  
        prem.Default_UoM__c = 'Lr';
        prem.Price__c = 1;
        prem.Quotation_date__c = '01.01.2020';
        insert prem;
        
        assessed_premia__c aprem = new assessed_premia__c();
        aprem.Quotation_source__c = 'testSource';
        aprem.Quotation_Type__c = 'testType';
        aprem.Quotation_number__c = 'testNum';  
        aprem.Default_UoM__c = 'Lr';
        aprem.Price__c = 1;
        aprem.Quotation_date__c = '01.01.2020';
        insert aprem;
    
        RE_ExternalFXMappings__c extMapping = new RE_ExternalFXMappings__c();
        extMapping.Name = 'TestExFX';
        extMapping.RE_External_Currency__c = 'MYR';
        extMapping.RE_Conversion_Unit__c= 'MYR CTS' ;
        extMapping.RE_Base_Unit__c = 'USD';
        extMapping.RE_Forex_Name__c = 'MYR CTS/USD';
        extMapping.RE_Type__c = 'M';
        insert extMapping;
        
        RE_ExternalFXMappings__c extMapping1 = new RE_ExternalFXMappings__c();
        extMapping1.Name = 'TestExFX1';
        extMapping1.RE_External_Currency__c = 'MYR';
        extMapping1.RE_Conversion_Unit__c= 'MYR' ;
        extMapping1.RE_Base_Unit__c = 'USD';
        extMapping1.RE_Forex_Name__c = 'MYR/USD';
        extMapping1.RE_Type__c = 'M';
        insert extMapping1;
        
        RE_External_FX_Rates__c exFXRate = new RE_External_FX_Rates__c();
        exFXRate.RE_Currency__c  = 'MYR';
        exFXRate.RE_Buy_Rate__c  = 4.8567;
        exFXRate.RE_Sell_Rate__c = 4.0856;
        exFXRate.RE_Mean_Rate__c = 4.0859;
        exFXRate.RE_Date__c =  '01.01.2020';
        insert exFXRate;
        
        RE_External_Exchange_Rate__c exfxdata = new RE_External_Exchange_Rate__c();
        exfxdata.RE_Exchange_Rate_Type__c = 'M';
        exfxdata.RE_From_Currency__c = 'USD';
        exfxdata.RE_To_Currency__c = 'MYR';
        exfxdata.RE_Effective_Date__c = '2020-03-03';
        exfxdata.RE_Rate__c = 4.255;
       	insert exfxdata;
        
        RE_External_Market_Quotes__c marketdata = new RE_External_Market_Quotes__c();
        marketdata.RE_Quote_Source__c = 'tS';
        marketdata.RE_Quote_Type__c = 'tT';
        marketdata.RE_Quote_No__c = 'testNum1';
        marketdata.RE_Quote_Date__c = '2020-09-09';
        marketdata.RE_Quote_Price__c = 0.71;
        marketdata.RE_Default_Currency__c = 'USD';
        marketdata.RE_Default_Per_Unit__c = 1;
        marketdata.RE_Unit_of_Measure__c = 'BBL';
        insert marketdata;
        
        test.stopTest();
    }
    
    @isTest
    static void testHttpPostFx() {
		String reqbody = '[{"EXCHANGERATETYPE": "M","FROMCURRENCY": "USD","TOCURRENCY": "AED", "EFFECTIVEDATE": "2020-09-16","RATE": 3.6732,"LASTACTIONCODE": "C","LASTACTIONTIMESTAMP": "2020-09-15 09:00:20"}]';		    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody= Blob.valueOf(reqbody);
        req.requestURI = '/services/apexrest/RE_FX_Rates'; //Request URL
        req.httpMethod = 'POST';
    
        RestContext.request = req;
        RestContext.response= res;
    
        Test.startTest();
            RE_FxRateController.createFxRate();
        Test.stopTest();
    }
    
    @isTest
    static void testHttpPostMops() {
		String reqbody = '[{"QUOTESOURCE": "EL","QUOTETYPE": "S","QUOTENO": "FREIGHT FBE01","QUOTEDATE": "2020-09-14","QUOTEPRICE": -0.71,"DEFAULTCURRENCY": "USD","DEFAULTPERUNIT": 1,"UNITOFMEASURE": "BB6","NOQUOTEINDICATOR": "","GROSSNETINDICATOR": ""}]';		    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody= Blob.valueOf(reqbody);
        req.requestURI = '/services/apexrest/Mops'; //Request URL
        req.httpMethod = 'POST';
    
        RestContext.request = req;
        RestContext.response= res;
    
        Test.startTest();
            RE_MarketQuotesController.createMops();
        Test.stopTest();
    }
}