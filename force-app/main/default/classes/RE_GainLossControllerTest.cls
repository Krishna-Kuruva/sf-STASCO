/*******************************************************************************************************************************************************-*********
@ Class:          RE_GainLossControllerTest
@ Version:        1.0
@ Author:         Sunidhi Pandey
@ Purpose:        Test classes for RE_GainLossController. 
------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
    public class RE_GainLossControllerTest {
    
    public static testmethod void InitialTestDetails(){
        
        Country__c createCtry1 = RE_UtilityClass.getCountryCode('Malaysia');
        Country__c createCtry2 = RE_UtilityClass.getCountryCode('Thailand');
        
         //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();
        
     //Creating Latest Market Quotes data
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(23.6560,'USD/BBL','BBL','MID RON PREMIUM','D');
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.05% S','D');
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(33.6560,'USD/BBL','BBL','Gasoil 0.001% S','D');
        RE_Market_Quotes__c createMQ4  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','Gasoil 0.25% S','D');
        RE_Market_Quotes__c createMQ5  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','Gasoil 0.001% Premium','D');
        RE_Market_Quotes__c createMQ6  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Kero','D');
        RE_Market_Quotes__c createMQ7  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','MOGAS 97','D');
        RE_Market_Quotes__c createMQ8  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','MOGAS 95','D');
        RE_Market_Quotes__c createMQ9  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Kero Premium','D');
        RE_Market_Quotes__c createMQ10  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Distillation Discount','D');
        
        createMQ2.RE_Quote_Type__c='Settlement';
        update createMQ2;
        RE_FX_Rates__c sFXRates= new RE_FX_Rates__c(RE_Forex_Name__c='MYR CTS/USD',
                                                    RE_Forex_Rate__c=135.235,
                                                    RE_Base_Unit__c='USD',
                                                    RE_Conversion_Unit__c='MYR CTS',
                                                    RE_Pricing_Date__c=System.now()+1,
                                                    RE_Trade_Type__c = 'Sell',
                                                    RE_Tracker__c = 'D+1');
        insert sFXRates;
        RE_FX_Rates__c sFXRates1= new RE_FX_Rates__c(RE_Forex_Name__c='MYR CTS/USD',
                                                    RE_Forex_Rate__c=135.235,
                                                    RE_Base_Unit__c='USD',
                                                    RE_Conversion_Unit__c='MYR CTS',
                                                    RE_Pricing_Date__c=System.now()-5,
                                                    RE_Trade_Type__c = 'Sell',
                                                    RE_Tracker__c = 'D');
        insert sFXRates1;
        RE_FX_Rates__c sFXRates2= new RE_FX_Rates__c(RE_Forex_Name__c='THB/USD',
                                                    RE_Forex_Rate__c=135.235,
                                                    RE_Base_Unit__c='USD',
                                                    RE_Conversion_Unit__c='THB',
                                                    RE_Pricing_Date__c=System.now()-5,
                                                    RE_Trade_Type__c = 'Sell',
                                                    RE_Tracker__c = 'D');
        insert sFXRates2;
               
		RE_FX_Rates__c fX1 = RE_UtilityClass.createFXRecords('MYR CTS/USD',136.2900,'USD','MYR CTS','Malaysia','D'); 
      	RE_FX_Rates__c fX2 = RE_UtilityClass.createFXRecords('MYR/USD',1.3629,'USD','MYR','Malaysia','D');
      	RE_FX_Rates__c fX3 = RE_UtilityClass.createFXRecords('THB/USD',1.3629,'USD','THB','Thailand','D');
        
    //Creating Custom setting data
        RE_Weekly_Data__c weeklyData1 = new RE_Weekly_Data__c();
        weeklyData1.Name ='WD-0001';
        weeklyData1.RE_Month__c ='Apr';
        weeklyData1.RE_Valid_From__c = System.Today()-31;
        weeklyData1.RE_Valid_To__c = System.Today()+31;
        weeklyData1.RE_Week_End_Date__c = System.Today();
        weeklyData1.RE_Week_Number__c = '1';
        weeklyData1.RE_Week_Start_Date__c =System.Today();
        weeklyData1.RE_Year__c ='2020';
        insert weeklyData1;
       
       RE_Gain_Loss_Audit__c glaudit = new RE_Gain_Loss_Audit__c (RE_WeekAverage__c=2.22,
                                                                  RE_MOPS_Name__c = 'Gasoil 0.001% S',
                                                                  RE_MonthlyAverage__c = 2.33,
                                                                  RE_Published_Date__c = System.today(),
                                                                  RE_Type__c = 'W-1',
                                                                  RE_Weeks_AVG__c = 2.22,
                                                                  RE_Months_AVG__c = 3.23,
                                                                  RE_Week_Number__c ='1',
                                                                  RE_Year__c = '2020',
                                                                  RE_Month__c = 'Apr',
                                                                  RE_Price__c  = 170.66,
                                                                  recordtypeId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId(),
                                                                 RE_Quote_Name__c=createMQ1.Id);
        RE_Gain_Loss_Audit__c glaudit2 = new RE_Gain_Loss_Audit__c (RE_WeekAverage__c=2.22,
                                                                  RE_MOPS_Name__c = 'Gasoil 0.001% S',
                                                                  RE_MonthlyAverage__c = 2.33,
                                                                  RE_Published_Date__c = System.today(),
                                                                  RE_Type__c = 'M-1',
                                                                  RE_Weeks_AVG__c = 2.22,
                                                                  RE_Months_AVG__c = 3.23,
                                                                  RE_Week_Number__c ='1',
                                                                  RE_Year__c = '2020',
                                                                  RE_Month__c = 'Apr',
                                                                  RE_Price__c  = 170.66,
                                                                  recordtypeId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId(),
                                                                  RE_Quote_Name__c=createMQ2.Id);
        insert glaudit;
        insert glaudit2;        
        
        Test.startTest();
        RE_GainLossController.OptionWrapper optionWrap = new RE_GainLossController.OptionWrapper('Kero','Kero');
        RE_GainLossController.getMopsProducts();
        RE_GainLossController.GainLossWrapper gainLossWrappr = new RE_GainLossController.GainLossWrapper();
        gainLossWrappr.liftingDate = 'test';
        gainLossWrappr.Differences=2.22;
        gainLossWrappr.monthAverage = 7.87;
        gainLossWrappr.Position = 'test';
        gainLossWrappr.week_1 = 8.66;
        gainLossWrappr.weeks = 'week1';
        RE_GainLossController.gainLossDetails('Gasoil 0.001% S','Malaysia');
        RE_GainLossController.glWrap gainWrap = new RE_GainLossController.glWrap();
        gainWrap.monthlydifference = 3.33;
        gainWrap.mopsdata = 'Gasoil 0.001% S';
        gainWrap.weeklydifference = 4.45;
        RE_Gain_Loss_Audit__c glaudit1 = new RE_Gain_Loss_Audit__c (RE_WeekAverage__c=2.22,
                                                                  RE_MOPS_Name__c = 'Gasoil 0.001% S',
                                                                 RE_MonthlyAverage__c = 2.33,
                                                                 RE_Published_Date__c = System.today(),
                                                                 RE_Type__c = 'D',
                                                                 RE_Price__c  = 170.66,
                                                                 recordtypeId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId(),
                                                                 RE_Quote_Name__c=createMQ2.Id);
        insert glaudit1;
        RE_GainLossController.fetchGainLossData('Gasoil 0.001% S','Malaysia');
        RE_UtilityClass.getCountryCode('Singapore');
        RE_UtilityClass.getProduct('IGO 10ppm','Singapore','SGD CTS/LTR');
        list<RE_Product__c>  prodlist = RE_GainLossClass.fetchMC0Data();
        RE_GainLossClass.updateRecords(prodlist);
        RE_ExternalTriggerHelper.CreateLagAuditData();
       	RE_ExternalTriggerHelper.createweeklyLagData('MYR CTS','MYR CTS/LTR','Malaysia');
        RE_ExternalTriggerHelper.createmonthlyLagData('MYR CTS','MYR CTS/LTR','Malaysia');
        RE_CreateLagAuditDataScheduler ob= new RE_CreateLagAuditDataScheduler();
        ob.execute(null);
        RE_ExternalTriggerHelper.createDailyLagAuditData('MYR CTS/LTR','Malaysia');
        
        Test.stopTest();
     	
    }

}