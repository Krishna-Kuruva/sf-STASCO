@isTest
public class RE_ControlDashboardTest {

    @isTest
    public static void RE_ControlDashboardTestMethod(){
       
        RE_ControlDashboard.getAutomatedJobs();
        RE_ControlDashboard.getData();
        RE_ControlDashboard.getJobsMetaData();
    }
    
   @testSetup
    public static void getDataTest(){
        
        RE_Job_Run_Audit__c jobType = new RE_Job_Run_Audit__c();
        jobType.RE_Job_Type__c = 'Malaysia Output';
        insert jobType;
        
       List<RE_Market_Quotes__c> marketQuoteList =  new List<RE_Market_Quotes__c>();
        
        RE_Market_Quotes__c marketQuote = new RE_Market_Quotes__c();
        marketQuote.RE_Quote_Name__c = 'Kero Premium';
        marketQuote.RE_Quote_Type__c = 'Market Premium';
        marketQuote.RE_Tracker__c = 'D';
        marketQuote.RE_Is_MTDWTD__c = false;
        marketQuote.RE_Country_Name__c = 'SG';
        marketQuoteList.add(marketQuote); 
        
        RE_Market_Quotes__c marketQuote2 = new RE_Market_Quotes__c();
        marketQuote2.RE_Quote_Name__c = 'Kero Premium';
        marketQuote2.RE_Quote_Type__c = 'Settlement';
        marketQuote2.RE_Tracker__c = 'D';
        marketQuote2.RE_Is_MTDWTD__c = false;
        marketQuote2.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote2); 
        
        RE_Market_Quotes__c marketQuote3 = new RE_Market_Quotes__c();
        marketQuote3.RE_Quote_Name__c = 'MID RON PREMIUM';
        marketQuote3.RE_Quote_Type__c = 'Assessed Premium';
        marketQuote3.RE_Tracker__c = 'D';
        marketQuote3.RE_Is_MTDWTD__c = false;
        marketQuote3.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote3); 
        
        RE_Market_Quotes__c marketQuote4 = new RE_Market_Quotes__c();
        marketQuote4.RE_Quote_Name__c = 'Kero Premium';
        marketQuote4.RE_Quote_Type__c = 'Midday';
        marketQuote4.RE_Tracker__c = 'D';
        marketQuote4.RE_Is_MTDWTD__c = false;
        marketQuote4.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote4); 
        
        RE_Market_Quotes__c marketQuote5 = new RE_Market_Quotes__c();
        marketQuote5.RE_Quote_Name__c = 'MKT PREMIA MPI08';
        marketQuote5.RE_Quote_Type__c = 'Market Premium';
        marketQuote5.RE_Tracker__c = 'D';
        marketQuote5.RE_Is_MTDWTD__c = false;
        marketQuote5.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote5); 
        
        RE_Market_Quotes__c marketQuote6 = new RE_Market_Quotes__c();
        marketQuote6.RE_Quote_Name__c = 'FuelSave98 Premium';
        marketQuote6.RE_Quote_Type__c = 'Assessed Premium';
        marketQuote6.RE_Tracker__c = 'D';
        marketQuote6.RE_Is_MTDWTD__c = false;
        marketQuote6.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote6); 
        
        RE_Market_Quotes__c marketQuote7 = new RE_Market_Quotes__c();
        marketQuote7.RE_Quote_Name__c = 'CME Discount';
        marketQuote7.RE_Quote_Type__c = 'Freight';
        marketQuote7.RE_Tracker__c = 'D';
        marketQuote7.RE_Is_MTDWTD__c = false;
        marketQuote7.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote7); 
        
        RE_Market_Quotes__c marketQuote8 = new RE_Market_Quotes__c();
        marketQuote8.RE_Quote_Name__c = 'Breakbulk Premium';
        marketQuote8.RE_Quote_Type__c = 'Assessed Premium';
        marketQuote8.RE_Tracker__c = 'D';
        marketQuote8.RE_Is_MTDWTD__c = false;
        marketQuote8.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote8); 
        
        RE_Market_Quotes__c marketQuote9 = new RE_Market_Quotes__c();
        marketQuote9.RE_Quote_Name__c = 'CME Discount';
        marketQuote9.RE_Quote_Type__c = 'Forward Swap';
        marketQuote9.RE_Tracker__c = 'D';
        marketQuote9.RE_Is_MTDWTD__c = false;
        marketQuote9.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote9); 
        
        RE_Market_Quotes__c marketQuote10 = new RE_Market_Quotes__c();
        marketQuote10.RE_Quote_Name__c = 'UCAP RBD CNO';
        marketQuote10.RE_Quote_Type__c = 'Forward Swap';
        marketQuote10.RE_Tracker__c = 'D';
        marketQuote10.RE_Is_MTDWTD__c = false;
        marketQuote10.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote10); 
        
        RE_Market_Quotes__c marketQuote11 = new RE_Market_Quotes__c();
        marketQuote11.RE_Quote_Name__c = 'Ethanol';
        marketQuote11.RE_Quote_Type__c = 'Forward Swap';
        marketQuote11.RE_Tracker__c = 'D';
        marketQuote11.RE_Is_MTDWTD__c = false;
        marketQuote11.RE_Country_Name__c = 'SG';
		marketQuoteList.add(marketQuote11); 
        
        insert marketQuoteList;
        
        List<String> conversionUnit = new List<String>{'PHP','MYR','SGD'};
        List<RE_FX_Rates__c> fxRateList = new List<RE_FX_Rates__c>(); 
        for(String item : conversionUnit)
        {
            RE_FX_Rates__c fxRate = new RE_FX_Rates__c();
            fxRate.RE_Conversion_Unit__c = item;
            fxRate.RE_Is_MTDWTD__c = false;
            fxRateList.add(fxRate);
        }
        insert fxRateList;
    }
}