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
        emailNames.add('Internal Rack Notification');
        emailNames.add('Internal Shell Canada BRPP Notification');
        emailNames.add('Shell Canada Rack Notification');
        emailNames.add('Shell Rack Customer Notification');
        emailNames.add('SFJ Rack notification');       
        emailNames.add('Canadian Rack Prices');
        emailNames.add('7 Day Canadian Rack Prices');
        emailNames.add('Ready to Upload Notification');
        emailNames.add('Shell Canada - Branded Customer Notification');
        emailNames.add('No Revised Pricing');
        emailNames.add('Canadian Rack Pricing and rack pricing Files');
        
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
        emailNames.add('Internal Rack Notification');      
        emailNames.add('Shell Rack Customer Notification');
        emailNames.add('SFJ Rack notification');
        
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
        emailNames.add('Internal Shell Canada BRPP Notification');  
                
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
        emailNames.add('Shell Canada - Branded Customer Notification');      
        
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
        emailNames.add('Shell Canada - Branded Customer Notification');   
        emailNames.add('Internal Rack Notification');
        emailNames.add('Internal Shell Canada BRPP Notification');
        emailNames.add('Shell Canada Rack Notification');
        emailNames.add('Shell Rack Customer Notification');
        emailNames.add('SFJ Rack notification');      
        emailNames.add('Canadian Rack Pricing and rack pricing Files'); 
        
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
        emailNames.add('Internal Rack Notification');       
        emailNames.add('Shell Rack Customer Notification');
        emailNames.add('SFJ Rack notification');       
  
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
        emailNames.add('Shell Canada - Branded Customer Notification');   

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
        emailNames.add('Internal Shell Canada BRPP Notification');      
        
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
        emailNames.add('Shell Canada Rack Notification');      
        
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
        emailNames.add('Canadian Rack Pricing and rack pricing Files');      
        
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
        emailNames.add('No Revised Pricing');    
        emailNames.add('Ready to Upload Notification'); 
        emailNames.add('7 Day Canadian Rack Prices');
        emailNames.add('Canadian Rack Prices');

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
        emailNames.add('Shell Canada - Branded Customer Notification');      
        
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
}