@isTest
public class RE_MY_ExecuteAutomateJobTest {
    static testmethod void  testschedule(){
         //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();
        
        List<RE_Market_Quotes__c> quoteList = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(23.6560,'USD','BBL','MID RON PREMIUM');
        createMQ1.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD','BBL','Gasoil 0.05% S');
        createMQ2.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(54.4658,'USD','BBL','Kero Premium');
        createMQ3.RE_Quote_Type__c = 'Assessed Premium';
        RE_Market_Quotes__c createMQ4  = RE_UtilityClass.getMarketQuotesold(23560,'USD','BBL','MID RON PREMIUM');
        createMQ4.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ5  = RE_UtilityClass.getMarketQuotesold(57.4638,'USD','BBL','Gasoil 0.05% S');
        createMQ5.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ6  = RE_UtilityClass.getMarketQuotesold(54.4628,'USD','BBL','Kero Premium');
        createMQ6.RE_Quote_Type__c = 'Assessed Premium';
        quoteList.add(createMQ1);
        quoteList.add(createMQ2);
        quoteList.add(createMQ3);
        quoteList.add(createMQ4);
        quoteList.add(createMQ5);
        quoteList.add(createMQ6);
		update quoteList;
        RE_UtilityClass.getCountryCode('Malaysia');
        RE_UtilityClass.getCountryCode('Singapore');
        RE_UtilityClass.getCountryCode('Thailand');
        
        RE_FX_Rates__c FXrate2 = RE_UtilityClass.createFXRecords('MYR/USD',4.3720,'USD','MYR','Malaysia');
        RE_FX_Rates__c FXrate1 = RE_UtilityClass.createFXRecords('MYR CTS/USD',437.20,'USD','MYR CTS','Malaysia');
        RE_FX_Rates__c FXrate3 = RE_UtilityClass.createFXRecordsYday('MYR/USD',4.3520,'USD','MYR','Malaysia');
        RE_FX_Rates__c FXrate4 = RE_UtilityClass.createFXRecordsYday('MYR CTS/USD',435.20,'USD','MYR CTS','Malaysia');
        RE_FX_Rates__c FXrate5 = RE_UtilityClass.createFXRecordsYday('MYR/USD',4.3420,'USD','MYR','Malaysia');
        RE_FX_Rates__c FXrate6 = RE_UtilityClass.createFXRecordsYday('MYR CTS/USD',434.20,'USD','MYR CTS','Malaysia');
        RE_FX_Rates__c FXrate9 = RE_UtilityClass.createFXRecords('THB/USD',14.3720,'USD','THB','Thailand');
        Test.StartTest();
        RE_MY_ExecuteAutomateJob sh1 = new RE_MY_ExecuteAutomateJob(); 
        RE_TH_ExecuteAutomateJob th1 = new RE_TH_ExecuteAutomateJob();
        RE_AMVCalculationScheduler amvsh1 = new RE_AMVCalculationScheduler();
        RE_TH_AMVCalculationScheduler thamvsh = new RE_TH_AMVCalculationScheduler();
        sh1.execute(null);
        th1.execute(null);
        amvsh1.execute(null);
        thamvsh.execute(null);
        String sch = '0  00 1 3 * ?';
        RE_FX_Rates__c FXrate7 = RE_UtilityClass.createFXRecords('SGD/USD',4.3720,'USD','SGD','Singapore');
        RE_FX_Rates__c FXrate8 = RE_UtilityClass.createFXRecords('SGD CTS/USD',437.20,'USD','SGD CTS','Singapore');
        RE_MY_ExecuteAutomateJob sh2 = new RE_MY_ExecuteAutomateJob();  
        RE_AMVCalculationScheduler amvsh2 = new RE_AMVCalculationScheduler();
        system.schedule('Test2', sch, sh2);
        System.Schedule('Test3', sch, amvsh2);
        Test.stopTest();
    }
}