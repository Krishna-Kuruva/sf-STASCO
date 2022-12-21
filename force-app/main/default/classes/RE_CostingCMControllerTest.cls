/*******************************************************************************************************************************************************-*********
@ Class:          RE_CostingCMControllerTest
@ Version:        1.0
@ Author:         Seemesh Patel (seemesh.patel@shell.com)
@ Purpose:        Test classes.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.01.2020 / Seemesh Patel / Created the class.
******************************************************************************************************************************************************************/

@isTest
public class RE_CostingCMControllerTest {
    
    /*************************************************************************************************************************************************************
@ Method:         prepareCMUrlTest 
@ Version:        1.0
@ Author:         Seemesh Patel (seemesh.patel@shell.com)
@ Purpose:        Method which call RE_CostingCMController class prepareCMUrl(Method) to perform test action
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.01.2020 / Seemesh Patel / Created the Method.
**************************************************************************************************************************************************************/
    
    static testmethod void prepareCMUrlTest(){
        
        Id mycostRecordTypeId= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        
        Country__c countrys = RE_UtilityClass.getCountryCode('Malaysia'); 
        List<RE_MY_CostPrice__c> costMYs = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c objRef = new RE_MY_CostPrice__c(recordtypeid = mycostRecordTypeId, RE_Country__c = countrys.Id);
        costMYs.add(objRef);
        
        
        APXTConga4__Conga_Template__c templates =  new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Singapore Output Template' );
        
        APXTConga4__Conga_Email_Template__c emailsTemps =  new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Revolution Singapore Template' );
        
        
        APXTConga4__Conga_Merge_Query__c mergeQuerys =  new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Singapore Email Ids' );
        
        insert costMYs;
        insert templates;
        insert emailsTemps;
        insert mergeQuerys;
        
        Test.startTest();
        Test.setCurrentPage(Page.CostingOutputConga);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(costMYs);
        stdSetController.setSelected(costMYs);
        RE_CostingCMController ext = new RE_CostingCMController(stdSetController);
        ext.prepareCMUrl();
        Test.stopTest();
        
        
    }
    
    
    /*************************************************************************************************************************************************************
@ Method:         prepareCMUrlMalaysiaTest 
@ Version:        1.0
@ Author:         Seemesh Patel (seemesh.patel@shell.com)
@ Purpose:        Method which call RE_MY_CostingController class prepareCMUrl(Method) to perform test action
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.01.2020 / Seemesh Patel / Created the Method.
**************************************************************************************************************************************************************/
    
    static testmethod void prepareCMUrlMalaysiaTest(){
        
        Id mycostRecordTypeId= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        
        Country__c countrys = RE_UtilityClass.getCountryCode('Malaysia'); 
        List<RE_MY_CostPrice__c> costMYs = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c objRef = new RE_MY_CostPrice__c(recordtypeid = mycostRecordTypeId, RE_Country__c = countrys.Id);
        costMYs.add(objRef);
        
        
        APXTConga4__Conga_Template__c templates =  new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Costing Output sheet' );
        
        APXTConga4__Conga_Email_Template__c emailsTemps =  new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Revolution Malaysian Template' );
        
        
        APXTConga4__Conga_Merge_Query__c mergeQuerys =  new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Malaysia Email Ids' );
        
        insert costMYs;
        insert templates;
        insert emailsTemps;
        insert mergeQuerys;
        
        Test.startTest();
        Test.setCurrentPage(Page.CostingOutputConga);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(costMYs);
        stdSetController.setSelected(costMYs);
        RE_MY_CostingController ext = new RE_MY_CostingController(stdSetController);
        ext.prepareMYUrl();
        Test.stopTest();
        
        
    }
    static testmethod void prepareCMUrlMalaysiaTest_1(){
        
        Id mycostRecordTypeId= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        
        Country__c countrys = RE_UtilityClass.getCountryCode('Malaysia'); 
        List<RE_MY_CostPrice__c> costMYs = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c objRef = new RE_MY_CostPrice__c(recordtypeid = mycostRecordTypeId, RE_Country__c = countrys.Id);
        costMYs.add(objRef);
        
        
        APXTConga4__Conga_Template__c templates =  new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Costing Output sheet' );
        
        APXTConga4__Conga_Email_Template__c emailsTemps =  new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Revolution Malaysian Template' );
        
        
        APXTConga4__Conga_Merge_Query__c mergeQuerys =  new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Malaysia Email Ids' );
        
        insert costMYs;
        insert templates;
        insert emailsTemps;
        insert mergeQuerys;
        
        Id mycostRecordTypeId1= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Singapore').getRecordTypeId();
        
        Country__c countrys1 = RE_UtilityClass.getCountryCode('Singapore'); 
        List<RE_MY_CostPrice__c> costMYs1 = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c objRef1 = new RE_MY_CostPrice__c(recordtypeid = mycostRecordTypeId1, RE_Country__c = countrys1.Id);
        costMYs.add(objRef1);
        
        
        APXTConga4__Conga_Template__c templates1 =  new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Singapore Output Template' );
        
        APXTConga4__Conga_Email_Template__c emailsTemps1 =  new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Revolution Singapore Template' );
        
        
        APXTConga4__Conga_Merge_Query__c mergeQuerys1 =  new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Singapore Email Ids' );
        
        insert costMYs1;
        insert templates1;
        insert emailsTemps1;
        insert mergeQuerys1;
        
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());
        //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();        
        List<RE_Market_Quotes__c> quotelist = new List<RE_Market_Quotes__c>();        
        RE_Market_Quotes__c createMQ8  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','MOGAS 95','D');
        createMQ8.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ9  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Kero Premium','D');
        createMQ9.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ10  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Distillation Discount','D');
        createMQ10.RE_Quote_Type__c = 'Assessed Premium';
        quotelist.add(createMQ8);
        quotelist.add(createMQ9);
        quotelist.add(createMQ10);
        update quotelist;
        RE_FX_Rates__c fX1 = RE_UtilityClass.createFXRecords('MYR CTS/USD',136.2900,'USD','MYR CTS','Malaysia','D'); 
        RE_FX_Rates__c fX2 = RE_UtilityClass.createFXRecords('MYR/USD',1.3629,'USD','MYR','Malaysia','D');
        RE_FX_Rates__c fX3 = RE_UtilityClass.createFXRecords('SGD CTS/USD',136.2900,'USD','SGD CTS','Singapore','D'); 
        RE_FX_Rates__c fX4 = RE_UtilityClass.createFXRecords('SGD/USD',1.3629,'USD','SGD','Singapore','D');
        
        RE_SendCostingNotificationScheduler ob= new RE_SendCostingNotificationScheduler();
        
        ob.execute(null);
        Test.stopTest();
        
        
    }
    static testmethod void prepareMidDayUrl(){
        
        Id mycostRecordTypeId= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        
        Country__c countrys = RE_UtilityClass.getCountryCode('Malaysia'); 
        List<RE_MY_CostPrice__c> costMYs = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c objRef = new RE_MY_CostPrice__c(recordtypeid = mycostRecordTypeId, RE_Country__c = countrys.Id);
        costMYs.add(objRef);
        
        APXTConga4__Conga_Template__c templates =  new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Malaysia MidDay PM Template' );
        APXTConga4__Conga_Email_Template__c emailsTemps =  new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Malaysia Mid Day Email Template' ); 
        APXTConga4__Conga_Merge_Query__c mergeQuerys =  new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Malaysia MidDay PM Email Ids' );
        
        insert costMYs;
        insert templates;
        insert emailsTemps;
        insert mergeQuerys;
        
        Test.startTest();
        //Test.setCurrentPage(Page.CostingOutputConga);
        //ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(costMYs);
        //stdSetController.setSelected(costMYs);
        RE_MidDayMailController ext = new RE_MidDayMailController();
        ext.prepareMidDayUrl();
        Test.stopTest();
        
        
    }
    static testmethod void prepareSGMidDayUrl(){       
        Id mycostRecordTypeId1= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        
        Country__c countrys1 = RE_UtilityClass.getCountryCode('Malaysia'); 
        List<RE_MY_CostPrice__c> costMYs1 = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c objRef1 = new RE_MY_CostPrice__c(recordtypeid = mycostRecordTypeId1, RE_Country__c = countrys1.Id);
        costMYs1.add(objRef1);
        
        
        APXTConga4__Conga_Template__c templates1 =  new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Singapore MidDay Output Template' );  
        APXTConga4__Conga_Email_Template__c emailsTemps1 =  new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Singapore Mid Day Email Template' );   
        APXTConga4__Conga_Merge_Query__c mergeQuerys1 =  new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'SG MidDay Email Ids' );
        
        insert costMYs1;
        insert templates1;
        insert emailsTemps1;
        insert mergeQuerys1;
        
        
        Test.startTest();
        //Test.setCurrentPage(Page.CostingOutputConga);
        //ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(costMYs);
        //stdSetController.setSelected(costMYs);
        RE_MidDayMailController ext = new RE_MidDayMailController();
        ext.prepareCMUrl();
        Test.stopTest();              
    }
    static testmethod void prepareCMUrlThailandTest(){
        
        Id mycostRecordTypeId= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId();
        
        Country__c countrys = RE_UtilityClass.getCountryCode('Thailand'); 
        List<RE_MY_CostPrice__c> costMYs = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c objRef = new RE_MY_CostPrice__c(recordtypeid = mycostRecordTypeId, RE_Country__c = countrys.Id);
        costMYs.add(objRef);
        
        
        APXTConga4__Conga_Template__c templates =  new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Thailand Output Template' );
        
        APXTConga4__Conga_Email_Template__c emailsTemps =  new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Thailand Output Email Template' );
        
        
        APXTConga4__Conga_Merge_Query__c mergeQuerys =  new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Thailand Output Email Ids' );
        
        insert costMYs;
        insert templates;
        insert emailsTemps;
        insert mergeQuerys;
        
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());
        //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();        
        List<RE_Market_Quotes__c> quotelist = new List<RE_Market_Quotes__c>();        
        RE_Market_Quotes__c createMQ8  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','MOGAS 95','D');
        createMQ8.RE_Quote_Type__c = 'Settlement';
        
        quotelist.add(createMQ8);
        
        update quotelist;
        RE_FX_Rates__c fX1 = RE_UtilityClass.createFXRecords('THB/USD',136.2900,'USD','THB','Thailand','D');
        RE_FX_Rates__c fX2 = RE_UtilityClass.createFXRecords('THB/USD',136.2900,'USD','THB','Thailand','D+1');
        
        
        RE_THAutoSendNotificationScheduler ob= new RE_THAutoSendNotificationScheduler();
        
        ob.execute(null);
        Test.stopTest();
        
        
    }
}