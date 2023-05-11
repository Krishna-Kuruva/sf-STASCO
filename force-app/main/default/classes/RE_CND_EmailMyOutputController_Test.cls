/**************************************************************************************************
* Name: RE_CND_EmailMyOutputController_Test
* Object: RE_MY_CostPrice__c, RE_MY_Output__c
* Purpose: My Output record creation to make use of Email output for Revolution Canada Test Class
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-11-12
* Modify History: 
* 2021-11-12		Abhilash		Created
**************************************************************************************************/
@isTest
public class RE_CND_EmailMyOutputController_Test {
    
    public static String internalRackNotification = 'Internal Rack Notification';
    public static String shellCanadaRackNotification = 'Shell Canada Rack Notification';
    public static String internalShellCndBRPPNotifi = 'Internal Shell Canada BRPP Notification';
    public static String sfjRacknotification = 'SFJ Rack notification';
    public static String canadianRackPrices = 'Canadian Rack Prices';
    public static String canadianRackPrices7Day = '7 Day Canadian Rack Prices';
    public static String shellRackCustomerNotification = 'Shell Rack Customer Notification';
    public static String shellCndBrandedCustomerNotifi = 'Shell Canada - Branded Customer Notification';
    public static String canadianRackPricngAndRackPricng = 'Canadian Rack Pricing and rack pricing Files';
    public static String readyToUploadNotification = 'Ready to Upload Notification';
    public static String noRevisedPricing = 'No Revised Pricing';
    
   @isTest
    static void emailMyOutputCreation_Test()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(internalRackNotification);
        emailNames.add(internalShellCndBRPPNotifi);
        emailNames.add(shellCanadaRackNotification);
        emailNames.add(shellRackCustomerNotification);
        emailNames.add(sfjRacknotification);       
        emailNames.add(canadianRackPrices);
        emailNames.add(canadianRackPrices7Day);
        emailNames.add(readyToUploadNotification);
        emailNames.add(shellCndBrandedCustomerNotifi);
        emailNames.add(noRevisedPricing);
        emailNames.add(canadianRackPricngAndRackPricng);
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','NewBAPP','Edmonton','ULSD','40004','C123','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP2 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0003','RackChangeNotification','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                   'Edmonton','Edmonton','Regular', 'Ordinaire',1, '', true);
        RE_CND_Conga_Output_Settings__c congOP3 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0004','RackChangeNotification','','RUG','40004','C123','Unbranded',
                                                                                                   '','','Regular', 'Ordinaire',2, '', true);
        RE_CND_Conga_Output_Settings__c congOP4 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0005','BrandedNotificationChangeAmount','Edmonton','ULSD','40004','C123','Branded',
                                                                                                   'Edmonton','Edmonton','Regular', 'Ordinaire',2, '', true);
        RE_CND_Conga_Output_Settings__c congOP5 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0006','BrandedNotificationExternalWeb','Edmonton','ULSD','40004','C123','Branded',
                                                                                                   'Edmonton','Edmonton','Regular', 'Ordinaire',2, '', true);
        RE_CND_Conga_Output_Settings__c congOP6 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0007','CanadianRackPricing','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                   'Edmonton','','Regular', 'Ordinaire',2, '', true);  
        RE_CND_Conga_Output_Settings__c congOP7 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0008','NewBAPP','','','','','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);       
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,false,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }
    
    @isTest
    static void emailMyOutputCreation_Test1()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(internalRackNotification);      
        emailNames.add(shellRackCustomerNotification);
        emailNames.add(sfjRacknotification);
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }    
    
    @isTest
    static void emailMyOutputCreation_Test2()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(internalShellCndBRPPNotifi);  
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','NewBAPP','Edmonton','ULSD','40004','C123','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);        
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }   
    
    @isTest
    static void emailMyOutputCreation_Test3()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(shellCndBrandedCustomerNotifi);      
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','BrandedNotificationChangeAmount','Edmonton','ULSD','40005','C234','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true); 
        RE_CND_Conga_Output_Settings__c congOP2 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0003','BrandedNotificationExternalWeb','Edmonton','ULSD','40005','C234','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }     
    
    @isTest
    static void emailMyOutputCreation_Test4()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(shellCndBrandedCustomerNotifi);   
        emailNames.add(internalRackNotification);
        emailNames.add(internalShellCndBRPPNotifi);
        emailNames.add(shellCanadaRackNotification);
        emailNames.add(shellRackCustomerNotification);
        emailNames.add(sfjRacknotification);      
        emailNames.add(canadianRackPricngAndRackPricng); 
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','','','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','NewBAPP','Edmonton','ULSD','','','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP3 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0003','BrandedNotificationChangeAmount','','','','','Branded',
                                                                                                   'Edmonton','','Bronze', 'BR',1, 'left', true); 
        RE_CND_Conga_Output_Settings__c congOP4 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0004','BrandedNotificationExternalWeb','','','','','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP5 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0005','CanadianRackPricing','','','','','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }    
    
    @isTest
    static void emailMyOutputCreation_Test5()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();          
        emailNames.add(internalRackNotification);       
        emailNames.add(shellRackCustomerNotification);
        emailNames.add(sfjRacknotification);       
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','','','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','NewBAPP','Edmonton','ULSD','','','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }  
    
    @isTest
    static void emailMyOutputCreation_Test6()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(shellCndBrandedCustomerNotifi);   
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','','','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','BrandedNotificationChangeAmount','Edmonton','ULSD','','','Branded',
                                                                                                   'Edmonton','','Bronze', 'BR',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP2 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0003','BrandedNotificationExternalWeb','Edmonton','ULSD','','','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }    
    
    @isTest
    static void emailMyOutputCreation_Test7()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(internalShellCndBRPPNotifi);      
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','NewBAPP','Edmonton','ULSD','40005','C234','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    } 
    
    @isTest
    static void emailMyOutputCreation_Test8()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(shellCanadaRackNotification);      
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP2 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0003','RackChangeNotification','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                   'Edmonton','Edmonton','Regular', 'Ordinaire',1, '', true);
        RE_CND_Conga_Output_Settings__c congOP3 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0004','RackChangeNotification','','RUG','40004','C123','Unbranded',
                                                                                                   '','','Regular', 'Ordinaire',2, '', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }     
    
    @isTest
    static void emailMyOutputCreation_Test9()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(canadianRackPricngAndRackPricng);      
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','CanadianRackPricing','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','CanadianRackPricing','Edmonton','ULSD','40004','C123','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP2 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0003','CanadianRackPricing','','','','','Unbranded',
                                                                                                   'Edmonton','Edmonton','RUL', 'RUL',1, 'left', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }       
    
    @isTest
    static void emailMyOutputCreation_Test10()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<String> emailNames = New List<String>();
        emailNames.add(noRevisedPricing);    
        emailNames.add(readyToUploadNotification); 
        emailNames.add(canadianRackPrices7Day);
        emailNames.add(canadianRackPrices);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,true,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }  
    
    @isTest
    static void emailMyOutputCreation_Test11()
    {
        Test.startTest();
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Email Output','CA'); 
        
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1); 
        
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceDataForEmailOutput(prngDateTime,reqDate,prngFrmToDate);   
        
        List<String> emailNames = New List<String>();
        emailNames.add(shellCndBrandedCustomerNotifi);      
        
        Id cndMyOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        List<RE_MY_Output__c> cndMyOPdata = New List<RE_MY_Output__c>();
        RE_MY_Output__c oldmyOP = new RE_MY_Output__c(RecordTypeId = cndMyOutputRecdTypId,RE_IsLatest__c = TRUE);
        cndMyOPdata.add(oldmyOP);  
        insert cndMyOPdata;
        
        RE_CND_Conga_Output_Settings__c congOP =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0001','RackCustomerNotification','Edmonton','RUG','40004','C123','Unbranded',
                                                                                                  'Edmonton','Edmonton','Regular', 'Ordinaire',1, 'left', true);
        RE_CND_Conga_Output_Settings__c congOP1 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0002','BrandedNotificationChangeAmount','Edmonton','ULSD','40005','C234','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, '', true); 
        RE_CND_Conga_Output_Settings__c congOP2 =  RE_CND_TestDataFactory.createCongaOutputSettngs('CND_0003','BrandedNotificationExternalWeb','Edmonton','ULSD','40005','C234','Branded',
                                                                                                   'Edmonton','Edmonton','Bronze', 'BR',1, '', true);
        
        RE_CND_EmailMyOutputController.emailMyOutputCreation(emailNames,TRUE,prngFrmToDate,jra,'Processing');
        
        Test.stopTest();
    }  
    
    @isTest
    static void emailMyOutputCreation_Test12() {
        RV_MetadataCoverageTest.setMetadata('Select id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Canada\' AND Type__c =\'Shell Canada Rack Notification\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize(
                                                '['+
                                                '{"MasterLabel": "ERTest0001","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Shell Canada Rack Notification", "Is_Active__c" : true},'+
                                                '{"MasterLabel": "ERTest0002","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Shell Canada Rack Notification", "Is_Active__c" : true}'+
                                                ']',
                                                List<RE_Email_Recipient__mdt>.class));
        RV_MetadataCoverageTest.setMetadata('Select id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Canada\' AND Type__c =\'Internal Shell Canada BRPP Notification\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize(
                                                '['+
                                                '{"MasterLabel": "ERTest0003","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Internal Shell Canada BRPP Notification", "Is_Active__c" : true},'+
                                                '{"MasterLabel": "ERTest0004","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Internal Shell Canada BRPP Notification", "Is_Active__c" : true}'+
                                                ']',
                                                List<RE_Email_Recipient__mdt>.class));
        RV_MetadataCoverageTest.setMetadata('Select id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Canada\' AND Type__c =\'SFJ Rack notification\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize(
                                                '['+
                                                '{"MasterLabel": "ERTest0003","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "SFJ Rack notification", "Is_Active__c" : true},'+
                                                '{"MasterLabel": "ERTest0004","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "SFJ Rack notification", "Is_Active__c" : true}'+
                                                ']',
                                                List<RE_Email_Recipient__mdt>.class));
        RV_MetadataCoverageTest.setMetadata('Select id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Canada\' AND Type__c =\'Canadian Rack Prices\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize(
                                                '['+
                                                '{"MasterLabel": "ERTest0003","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Canadian Rack Prices", "Is_Active__c" : true},'+
                                                '{"MasterLabel": "ERTest0004","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Canadian Rack Prices", "Is_Active__c" : true}'+
                                                ']',
                                                List<RE_Email_Recipient__mdt>.class));
      	RV_MetadataCoverageTest.setMetadata('Select id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Canada\' AND Type__c =\'7 Day Canadian Rack Prices\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize(
                                                '['+
                                                '{"MasterLabel": "ERTest0003","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "7 Day Canadian Rack Prices", "Is_Active__c" : true},'+
                                                '{"MasterLabel": "ERTest0004","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "7 Day Canadian Rack Prices", "Is_Active__c" : true}'+
                                                ']',
                                                List<RE_Email_Recipient__mdt>.class));
        RV_MetadataCoverageTest.setMetadata('Select id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Canada\' AND Type__c =\'Canadian Rack Pricing and rack pricing Files\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize(
                                                '['+
                                                '{"MasterLabel": "ERTest0003","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Canadian Rack Pricing and rack pricing Files", "Is_Active__c" : true},'+
                                                '{"MasterLabel": "ERTest0004","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Canadian Rack Pricing and rack pricing Files", "Is_Active__c" : true}'+
                                                ']',
                                                List<RE_Email_Recipient__mdt>.class));
        RV_MetadataCoverageTest.setMetadata('Select id, MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Canada\' AND Type__c =\'Ready to Upload Notification\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize(
                                                '['+
                                                '{"MasterLabel": "ERTest0003","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Ready to Upload Notification", "Is_Active__c" : true},'+
                                                '{"MasterLabel": "ERTest0004","Country__c": "Canada","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "Ready to Upload Notification", "Is_Active__c" : true}'+
                                                ']',
                                                List<RE_Email_Recipient__mdt>.class));  
        Test.startTest(); 
            Map<String, String> emailNameMap = new Map<String, String>();
            emailNameMap.put(shellCanadaRackNotification, shellCanadaRackNotification);
            emailNameMap.put(internalShellCndBRPPNotifi, internalShellCndBRPPNotifi);
            emailNameMap.put(sfjRacknotification, sfjRacknotification);
            emailNameMap.put(canadianRackPrices, canadianRackPrices);
            emailNameMap.put(canadianRackPrices7Day, canadianRackPrices7Day);
            emailNameMap.put(canadianRackPricngAndRackPricng, canadianRackPricngAndRackPricng);
            emailNameMap.put(readyToUploadNotification, readyToUploadNotification);
            RE_CND_EmailMyOutputController.shellCanadaRackNotificationEmail(emailNameMap, false);
            RE_CND_EmailMyOutputController.internalShellCndBRPPNotifiEmail(emailNameMap, false);
            RE_CND_EmailMyOutputController.sfjRacknotificationEmail(emailNameMap, false);
            RE_CND_EmailMyOutputController.canadianRackPricesEmail(emailNameMap, false);
            RE_CND_EmailMyOutputController.canadianRackPrices7DayEmail(emailNameMap, false);
            RE_CND_EmailMyOutputController.canadianRackPricngAndRackPricngEmail(emailNameMap, false);
            RE_CND_EmailMyOutputController.readyToUploadNotificationEmail(emailNameMap, false);
        Test.stopTest();       
    }
}