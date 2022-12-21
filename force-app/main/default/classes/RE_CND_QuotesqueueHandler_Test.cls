/******************************************************************************************************************
className           :    RE_CND_QuotesqueueHandler_Test
Description         :    Test class for RE_CN_Quotes_Queue, RE_CND_QuotesqueueHandler and RE_CND_CanadaQuoteScheduler
Author              :    Aasiya Siraj
Date				:	 10-May-2021 
*******************************************************************************************************************/
@isTest
public class RE_CND_QuotesqueueHandler_Test {
    
    @testSetup 
    static void setup() {
        List<RE_Zema_Quotes_Settings__c> zemaListCreated = RE_CND_TestDataFactory.createZemaQuotes();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Automate','Canada Daily Reuters Quote Move','CA');
        
               
        RE_JobControls__c jobControl1 =  RE_CND_TestDataFactory.createJobControlSetting('JC1','RE_CND_QuotesQueueHandler','getTodaysCanadianQuotes','Canada',true);
        RE_JobControls__c jobControl2 =  RE_CND_TestDataFactory.createJobControlSetting('JC2','RE_CND_QuotesQueueHandler','moveToMarketQuotes','Canada',true);
        RE_JobControls__c jobControl3 =  RE_CND_TestDataFactory.createJobControlSetting('JC3','RE_CND_QuotesQueueHandler','moveToReutersHistory','Canada',true);
        RE_JobControls__c jobControl4 =  RE_CND_TestDataFactory.createJobControlSetting('JC4','RE_CND_QuotesQueueHandler','deleteCanadaQuotes','Canada',true);
        RE_JobControls__c jobControl5 =  RE_CND_TestDataFactory.createJobControlSetting('JC5','RE_CND_QuotesQueueHandler','deleteCommonQuotes','Canada',true);
        RE_JobControls__c jobControl6 =  RE_CND_TestDataFactory.createJobControlSetting('JC6','RE_CND_QuotesQueueHandler','sendJobReportMail','Canada',true);
        RE_JobControls__c jobControl7 =  RE_CND_TestDataFactory.createJobControlSetting('JC7','RE_CND_QuotesQueueHandler','sendSuccessReportMail','Canada',true);
        RE_JobControls__c jobControl8 =  RE_CND_TestDataFactory.createJobControlSetting('JC8','RE_CND_QuotesQueueHandler','sendFailureReportMail','Canada',true);
        RE_JobControls__c jobControl9 =  RE_CND_TestDataFactory.createJobControlSetting('JC9','RE_CND_QuotesQueueHandler','moveToFXRates','Canada',true);

        Reuters_Quotes__c rqs=RE_CND_TestDataFactory.createReutersQuote('Test Quote', System.today()+6, 25.00,'l','CAD');
        Reuters_Quotes__c rqs2=RE_CND_TestDataFactory.createReutersQuote
            ('Argus US east coast Gasoline 83.5 CBOB NYH barge Daily (low) barge Nymex Gasoline RBOB USC/USG Interpolation: previous',
             System.today()+8, 16.00,'BBL','USD');
        Reuters_Quotes__c rqs3=RE_CND_TestDataFactory.createReutersQuote
            ('ICE Cleared Settle Oil (Futures) Settlement Price North Sea Brent Crude',System.today()+5, 32.00,'l','CAD');
        Reuters_Quotes__c rqs4=RE_CND_TestDataFactory.createReutersQuote('test',System.today()+2, 26.00,'GAL','USD');
        Reuters_Quotes__c rqs5=RE_CND_TestDataFactory.createReutersQuote('Reuters 12 Noon USD Exchange Benckmark USD Mid Canada Dollar CAD Interpolation: previous',
                                                                         System.today()+2, 0,'l','CAD');
        RE_Market_Quotes__c mqs =RE_CND_TestDataFactory.createMarketQuotes('Test Display',System.today()+6, 25.00,'CA');
        RE_Market_Quotes__c mqs2 =RE_CND_TestDataFactory.createMarketQuotes('ICE Brent M+0',System.today()+5, 25.00,null);
        
        RE_FX_Rates__c fxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.5,System.today(),'CAD');
        RE_Rate_Unit_Manager__c rum=RE_CND_TestDataFactory.createRateUnitManager('RUM1','CAD CTS/LTR','CAD CTS','LTR');
        RE_Rate_Unit_Manager__c rum2=RE_CND_TestDataFactory.createRateUnitManager('RUM2','USD/BBL','USD','BBL');
        RE_Currency_Conversion__c cc= RE_CND_TestDataFactory.createCurrencyConversion('CC1','USD','CAD CTS','100*FxRate');
        RE_Default_Unit_Rate_Settings__c defaultunit =
            RE_CND_TestDataFactory.createDefaultUnit('DS1','Settlement Quote','CAD CTS/LTR','Canada','RE_Market_Quotes__c',true);
        Reuters_History__c rhs=RE_CND_TestDataFactory.createReutersHistrory('Test Display',rqs.Quote_Name__c,rqs.CreatedDate,rqs.Frequency__c,rqs.Id,rqs.Price__c,rqs.Pricing_Date__c,'TU');
    }
    
   
   @isTest
    static  void quoteSchedular(){
        Test.startTest();
        RE_CND_CanadaQuoteScheduler p = new RE_CND_CanadaQuoteScheduler(); 
        String sch = '0 30 * * * ? 2099'; 
        String jobID=system.schedule('canada Queue Schedular', sch, p);
        p.execute(null);
        System.assertNotEquals(null, jobID);
        Test.stopTest();
    }
    
 @isTest
    static  void canadaQuoteQueueTest(){
        Test.startTest();
        RE_Job_Run_Audit__c jobAudit=[SELECT RE_Run_Time__c,RE_Job_Status__c,Other_Comments__c,RE_Exception__c,RE_Run_Type__c,RE_Job_Type__c 
                                      FROM RE_Job_Run_Audit__c WHERE RE_Run_Type__c='Automate' LIMIT 1];
        ID jobID=System.enqueueJob(new RE_CND_Quotes_Queue(jobAudit));
        System.assertNotEquals(null, jobID);
        Test.stopTest();
    }
    
    @isTest
    static  void canadaQuoteQueueException(){
        Test.startTest();
        RE_Job_Run_Audit__c jobAudit=[SELECT RE_Run_Time__c,RE_Job_Status__c,Other_Comments__c,RE_Exception__c,RE_Run_Type__c,RE_Job_Type__c 
                                      FROM RE_Job_Run_Audit__c WHERE RE_Run_Type__c='Automate' LIMIT 1];
        ID jobID=System.enqueueJob(new RE_CND_Quotes_Queue(jobAudit));
        System.assertNotEquals(null, jobID);
        Test.stopTest();
    }
    
    @isTest
    static  void deletionException(){
        Test.startTest();
        RE_Job_Run_Audit__c jobAudit=[SELECT RE_Run_Time__c,RE_Job_Status__c,RE_Exception__c,Other_Comments__c,RE_Run_Type__c,RE_Job_Type__c 
                                      FROM RE_Job_Run_Audit__c WHERE RE_Run_Type__c='Automate' LIMIT 1];
        List<Reuters_Quotes__c> reuterlist=[SELECT Id,Price__c,Pricing_Date__c,Quote_Name__c FROM Reuters_Quotes__c WHERE CreatedDate=TODAY];
        Set<Id>canadaQuoteIds = new Set<Id>();
        Set<Id>commonQuoteIds = new Set<Id>();
        for (Reuters_Quotes__c rq :reuterlist)
        {
            canadaQuoteIds.add(rq.Id);
            commonQuoteIds.add(rq.Id);
        }
        RE_CND_QuotesQueueHandler.deleteQuotes(canadaQuoteIds,commonQuoteIds,true,true, jobAudit);
        RE_CND_QuotesQueueHandler.deleteQuotes(canadaQuoteIds,commonQuoteIds,true,true, jobAudit);
        List<Reuters_Quotes__c> reuterlist1=[SELECT Id,Price__c,Pricing_Date__c,Quote_Name__c FROM Reuters_Quotes__c WHERE CreatedDate=TODAY];
        System.assertEquals(0, reuterlist1.size());
        Test.stopTest();
    }
    
    @isTest
    static  void partialdeletionException(){
        Test.startTest();
        RE_Job_Run_Audit__c jobAudit=[SELECT RE_Run_Time__c,RE_Exception__c,RE_Job_Status__c,Other_Comments__c,RE_Run_Type__c,RE_Job_Type__c 
                                      FROM RE_Job_Run_Audit__c WHERE RE_Run_Type__c='Automate' LIMIT 1];
        List<Reuters_Quotes__c> reuterlist=[SELECT Id,Price__c,Pricing_Date__c,Quote_Name__c FROM Reuters_Quotes__c WHERE CreatedDate=TODAY];
        Set<Id>canadaQuoteIds = new Set<Id>();
        Set<Id>commonQuoteIds = new Set<Id>();
        for (Reuters_Quotes__c rq :reuterlist)
        {
            canadaQuoteIds.add(rq.Id);
            commonQuoteIds.add(rq.Id);
        }
        RE_CND_QuotesQueueHandler.partialDeleteCanadaQuotes(canadaQuoteIds,commonQuoteIds,true,true, jobAudit,canadaQuoteIds);
        List<Reuters_Quotes__c> reuterlist1=[SELECT Id,Price__c,Pricing_Date__c,Quote_Name__c FROM Reuters_Quotes__c WHERE CreatedDate=TODAY];
        System.assertEquals(0, reuterlist1.size());
        Test.stopTest();
    }
    
    @isTest
    static  void moveToMarketQuotesDatabaseUpsertException(){
        Test.startTest();
        Set<String> canadianQuoteName = new Set<String>();
        Map<Id,String> idDisplayMap = new Map<Id,String>();
        Map<String,String> displayMap = new Map<String,String>();
        Map<String,String> frequencyNameMap = new Map<String,String>();
        Map<String,Boolean> pricetobeconvrtdMap = new Map<String,Boolean>();
        Map<Id, RE_CND_QuotesQueueHandler.StatusWrapper>  isMovedtoMarket = new Map<Id, RE_CND_QuotesQueueHandler.StatusWrapper> ();
        Map<Id, RE_CND_QuotesQueueHandler.StatusWrapper>  isMovedtoHistory = new Map<Id, RE_CND_QuotesQueueHandler.StatusWrapper> ();
        RE_CND_QuotesQueueHandler.StatusWrapper sw = new RE_CND_QuotesQueueHandler.StatusWrapper();
        sw.isCreated=false;
        sw.isUpdated=false;
        sw.isFailed=false;
        sw.noActionRequired=false;
        
        List<Id> reuterIdList = new List<Id>();
        RE_Job_Run_Audit__c jobAudit=[SELECT RE_Run_Time__c,RE_Exception__c,RE_Job_Status__c,Other_Comments__c,RE_Run_Type__c,RE_Job_Type__c 
                                      FROM RE_Job_Run_Audit__c WHERE RE_Run_Type__c='Automate' LIMIT 1];
        List<Reuters_Quotes__c> reuterlist=[SELECT Id,Price__c,CurrencyCode__c,Unit_Of_Measure__c,Pricing_Date__c,Quote_Name__c FROM Reuters_Quotes__c WHERE CreatedDate=TODAY];
        for (Reuters_Quotes__c rq :reuterlist)
        {
            idDisplayMap.put(rq.Id,rq.Quote_Name__c);
            displayMap.put(rq.Quote_Name__c,'Testing long quote dispaly name in move toMarketQuotes Testing long quote dispaly name in move toMarketQuotes');
            isMovedtoMarket.put(rq.Id,sw);
            isMovedtoHistory.put(rq.Id,sw);
            reuterIdList.add(rq.Id);
        }
        for(RE_Zema_Quotes_Settings__c zemaQuote:[SELECT Quote_Name__c,Country__c,Frequency__c,Type__c,Display_Name__c,Price_to_be_converted__c FROM RE_Zema_Quotes_Settings__c WHERE Country__c LIKE '%Canada%'])
            {
                frequencyNameMap.put(zemaQuote.Quote_Name__c, zemaQuote.Frequency__c);
                pricetobeconvrtdMap.put(zemaQuote.Quote_Name__c, zemaQuote.Price_to_be_converted__c);
            }
        isMovedtoMarket = 	RE_CND_QuotesQueueHandler.moveToMarketQuotes(1.2,reuterlist,displayMap,idDisplayMap,jobAudit,isMovedtoMarket,frequencyNameMap,pricetobeconvrtdMap);
        isMovedtoHistory = 	RE_CND_QuotesQueueHandler.moveToReutersHistory(reuterlist,displayMap,reuterIdList,jobAudit,isMovedtoHistory);
        Test.stopTest();
    }

      
}