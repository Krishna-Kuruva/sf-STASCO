/**************************************************************************************************
* Name: RE_MY_DataAnalysisReportQueue_Test
* Object: RE_MY_Output__c
* Purpose: Test class of RE_MY_DataAnalysisReportQueue
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-09-19
* Modify History: 
* 2022-09-19		Abhilash		Created
**************************************************************************************************/
@isTest
public class RE_MY_DataAnalysisReportQueue_Test {

    @testSetup static void setup() 
    { 
        String userId  = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String userEmail  = UserInfo.getUserEmail();
        List<APXTConga4__Conga_Template__c> tempList = new List<APXTConga4__Conga_Template__c>();
		APXTConga4__Conga_Template__c template1 = new APXTConga4__Conga_Template__c();
        template1.APXTConga4__Name__c =  'MY Monthly CBU Costing and Chart';
		tempList.add(template1);
        insert tempList;
                
        List<APXTConga4__Conga_Email_Template__c> etempList = new List<APXTConga4__Conga_Email_Template__c>();
		APXTConga4__Conga_Email_Template__c etemplate1 = new APXTConga4__Conga_Email_Template__c();		 
        etemplate1.APXTConga4__Name__c = 'Malaysia Monthly CBU Costing and Chart Template';
		etempList.add(etemplate1);        
        insert etempList;
        
        APXTConga4__Conga_Merge_Query__c ApexCongaQry = new APXTConga4__Conga_Merge_Query__c();
        ApexCongaQry.RE_Type__c = 'MY CBU Monthly Chart';
        ApexCongaQry.APXTConga4__Name__c = 'RE MY Monthly CBU B0B7Kero BLI';
        insert ApexCongaQry;
        
        APXTConga4__Conga_Solution__c soln = New APXTConga4__Conga_Solution__c();
        soln.Name = 'RE MY Data Analysis';
        soln.APXTConga4__Custom_Object_Id__c = 'RE_MY_Output__c';
        insert soln;
                
        APXTConga4__Conga_Solution_Query__c solnQury = new APXTConga4__Conga_Solution_Query__c();
        solnQury.APXTConga4__Alias__c='CBUBLIB0B7Kero';
        solnQury.APXTConga4__Conga_Query__c = ApexCongaQry.Id;  
        solnQury.APXTConga4__Conga_Solution__c = soln.Id;
        insert solnQury;        
    }    
    
    @isTest
    static void myDataAnalysis_NoData_Test() 
    { 
        Test.startTest();        
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;         

		System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));        
        Test.stopTest();        
    }
    
    @isTest
    static void myDataAnalysis_Data_Test() 
    {      
        RV_MetadataCoverageTest.setMetadata('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize('[{"MasterLabel": "ERTest0001","Country__c": "Malaysia","To_List__c" : "","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "","Type__c" : "MY Monthly CBU Costing and Chart", "Is_Active__c" : true}]', List<RE_Email_Recipient__mdt>.class));
        
        Test.startTest();
        
        RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
        reMyOp1.RE_Type__c = 'Malaysia Output';
        reMyOp1.RE_Region__c = 'Peninsular';     
        reMyOp1.RE_Depot_Name__c  = 'Bagan Luar';
        reMyOp1.RE_Pricing_Date__c  = System.today();        
        reMyOp1.RE_Gasoil_B0_0_001_S_MC__c = 156.78;
        reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 13.766;
        reMyOp1.RE_KEROSENE_MC__c   = 338.9902;
        insert reMyOp1;          
        
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;      

        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());        
		System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));      
        
        Test.stopTest();        
    }
    
    @isTest
    static void myDataAnalysis_WebServiceCallout_Error_Test() 
    {             
        RV_MetadataCoverageTest.setMetadata('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize('[{"MasterLabel": "ERTest0001","Country__c": "Malaysia","To_List__c" : "","Cc_List__c" : "","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "MY Monthly CBU Costing and Chart", "Is_Active__c" : true}]', List<RE_Email_Recipient__mdt>.class));
        
        Test.startTest();
        
        RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
        reMyOp1.RE_Type__c = 'Malaysia Output';
        reMyOp1.RE_Region__c = 'Peninsular';     
        reMyOp1.RE_Depot_Name__c  = 'Bagan Luar';
        reMyOp1.RE_Pricing_Date__c  = System.today();        
        reMyOp1.RE_Gasoil_B0_0_001_S_MC__c = 156.78;
        reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 13.766;
        reMyOp1.RE_KEROSENE_MC__c   = 338.9902;
        insert reMyOp1;
        
        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;         
        
		System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));
        
        Test.stopTest();        
    }    
    
    @isTest
    static void myDataAnalysis_Data_Test_ToListOnly() 
    {      
        RV_MetadataCoverageTest.setMetadata('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize('[{"MasterLabel": "ERTest0001","Country__c": "Malaysia","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "","Bcc_List__c" : "","Type__c" : "MY Monthly CBU Costing and Chart", "Is_Active__c" : true}]', List<RE_Email_Recipient__mdt>.class));
        
        Test.startTest();
        
        RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
        reMyOp1.RE_Type__c = 'Malaysia Output';
        reMyOp1.RE_Region__c = 'Peninsular';     
        reMyOp1.RE_Depot_Name__c  = 'Bagan Luar';
        reMyOp1.RE_Pricing_Date__c  = System.today();        
        reMyOp1.RE_Gasoil_B0_0_001_S_MC__c = 156.78;
        reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 13.766;
        reMyOp1.RE_KEROSENE_MC__c   = 338.9902;
        insert reMyOp1;          
        
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;      

        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());        
		System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));      
        
        Test.stopTest();        
    }
    
    @isTest
    static void myDataAnalysis_Data_Test_ToCcList() 
    {      
        RV_MetadataCoverageTest.setMetadata('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize('[{"MasterLabel": "ERTest0001","Country__c": "Malaysia","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "","Type__c" : "MY Monthly CBU Costing and Chart", "Is_Active__c" : true}]', List<RE_Email_Recipient__mdt>.class));
        
        Test.startTest();
        
        RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
        reMyOp1.RE_Type__c = 'Malaysia Output';
        reMyOp1.RE_Region__c = 'Peninsular';     
        reMyOp1.RE_Depot_Name__c  = 'Bagan Luar';
        reMyOp1.RE_Pricing_Date__c  = System.today();        
        reMyOp1.RE_Gasoil_B0_0_001_S_MC__c = 156.78;
        reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 13.766;
        reMyOp1.RE_KEROSENE_MC__c   = 338.9902;
        insert reMyOp1;          
        
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;      

        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());        
		System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));      
        
        Test.stopTest();        
    }

    @isTest
    static void myDataAnalysis_Data_Test_ToCcBccList() 
    {      
        RV_MetadataCoverageTest.setMetadata('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize('[{"MasterLabel": "ERTest0001","Country__c": "Malaysia","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "MY Monthly CBU Costing and Chart", "Is_Active__c" : true}]', List<RE_Email_Recipient__mdt>.class));
        
        Test.startTest();
        
        RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
        reMyOp1.RE_Type__c = 'Malaysia Output';
        reMyOp1.RE_Region__c = 'Peninsular';     
        reMyOp1.RE_Depot_Name__c  = 'Bagan Luar';
        reMyOp1.RE_Pricing_Date__c  = System.today();        
        reMyOp1.RE_Gasoil_B0_0_001_S_MC__c = 156.78;
        reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 13.766;
        reMyOp1.RE_KEROSENE_MC__c   = 338.9902;
        insert reMyOp1;          
        
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;      

        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());        
		System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));      
        
        Test.stopTest();        
    }

    @isTest
    static void myDataAnalysis_Data_Test_ToBccList() 
    {      
        RV_MetadataCoverageTest.setMetadata('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize('[{"MasterLabel": "ERTest0001","Country__c": "Malaysia","To_List__c" : "abhilash.kt@shell.com","Cc_List__c" : "","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "MY Monthly CBU Costing and Chart", "Is_Active__c" : true}]', List<RE_Email_Recipient__mdt>.class));
        
        Test.startTest();
        
        RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
        reMyOp1.RE_Type__c = 'Malaysia Output';
        reMyOp1.RE_Region__c = 'Peninsular';     
        reMyOp1.RE_Depot_Name__c  = 'Bagan Luar';
        reMyOp1.RE_Pricing_Date__c  = System.today();        
        reMyOp1.RE_Gasoil_B0_0_001_S_MC__c = 156.78;
        reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 13.766;
        reMyOp1.RE_KEROSENE_MC__c   = 338.9902;
        insert reMyOp1;          
        
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;      

        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());        
		System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));      
        
        Test.stopTest();        
    }
    
    @isTest
    static void reCalculate_myDataAnalysis_Data_Test() 
    {             
        RV_MetadataCoverageTest.setMetadata('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE',
                                            (List<RE_Email_Recipient__mdt>) JSON.deserialize('[{"MasterLabel": "ERTest0001","Country__c": "Malaysia","To_List__c" : "","Cc_List__c" : "abhilash.kt@shell.com","Bcc_List__c" : "abhilash.kt@shell.com","Type__c" : "MY Monthly CBU Costing and Chart", "Is_Active__c" : true}]', List<RE_Email_Recipient__mdt>.class));

        
        Test.startTest();
        
        RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
        reMyOp1.RE_Type__c = 'Malaysia Output';
        reMyOp1.RE_Region__c = 'Peninsular';     
        reMyOp1.RE_Depot_Name__c  = 'Bagan Luar';
        reMyOp1.RE_Pricing_Date__c  = System.today();        
        reMyOp1.RE_Gasoil_B0_0_001_S_MC__c = 156.78;
        reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 13.766;
        reMyOp1.RE_KEROSENE_MC__c   = 338.9902;
        insert reMyOp1;          

        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';         
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c='Processing';
        jrAuditMY.RE_Country_Name__c='MY';
        insert jrAuditMY;    
        
        Test.setMock(HttpCalloutMock.class, new RE_MockHttpResponseGenerator());
        System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));
             
        Test.stopTest();        
    }    
    
}