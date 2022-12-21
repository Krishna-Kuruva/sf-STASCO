/**************************************************************************************************
* Name: RE_MY_DataAnalysisReportScheduler_Test
* Object: RE_MY_Output__c
* Purpose: Test class of RE_MY_DataAnalysisReportScheduler
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-09-19
* Modify History: 
* 2022-09-19		Abhilash		Created
**************************************************************************************************/
@isTest
public class RE_MY_DataAnalysisReportScheduler_Test {
    
    @isTest
    static void myDataAnalysis_NoData_Test() 
    { 
        Test.startTest();        
        RE_MY_DataAnalysisReportScheduler dataAnysReportSchdlr = new RE_MY_DataAnalysisReportScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('MY DataAnalysis Report Scheduler', sch, dataAnysReportSchdlr);  
        Test.stopTest();        
    }
    
    @isTest
    static void myDataAnalysis_Data_Test() 
    {             
        Test.startTest();
        
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        jrAuditMY.RE_Run_Type__c = 'Automate';
        jrAuditMY.RE_Run_Time__c = System.now();
        jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
        jrAuditMY.RE_User__c = UserInfo.getUserId();
        jrAuditMY.RE_Job_Run_Count__c = 0;
        jrAuditMY.RE_Job_Status__c = 'Completed';
        jrAuditMY.RE_Country_Name__c = 'MY';
        insert jrAuditMY;   
        
        RE_MY_DataAnalysisReportScheduler dataAnysReportSchdlr = new RE_MY_DataAnalysisReportScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('MY DataAnalysis Report Scheduler', sch, dataAnysReportSchdlr); 
        
        Test.stopTest();        
    }    
    
}