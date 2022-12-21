/**************************************************************************************************
* Name: RE_MY_DataAnalysisReportScheduler
* Object: RE_MY_Output__c
* Purpose: Used for Malaysis Data Analysis Report geneartion
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-09-19
* Modify History: 
* 2022-09-19		Abhilash		Created
**************************************************************************************************/
global class RE_MY_DataAnalysisReportScheduler implements schedulable
{
    global void execute(SchedulableContext sc) 
    {               
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
        
        try
        {
            Integer maxJobRunCount = 0;
            // Get the latest MY Data Analysis Report Job type for today
            List<RE_Job_Run_Audit__c> jobDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c 
                                                      WHERE createddate = Today AND RE_Job_Type__c =: 'MY Data Analysis Report' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
            if(!jobDataToday.isEmpty())
                maxJobRunCount = Integer.valueOf(jobDataToday[0].RE_Job_Run_Count__c)+1;  
            
            jrAuditMY.RE_Run_Type__c = 'Automate';
            jrAuditMY.RE_Run_Time__c = System.now();
            jrAuditMY.RE_Job_Type__c = 'MY Data Analysis Report';
            jrAuditMY.RE_User__c = UserInfo.getUserId();
            jrAuditMY.RE_Job_Run_Count__c = maxJobRunCount;
            jrAuditMY.RE_Job_Status__c = 'Processing';
            jrAuditMY.RE_Country_Name__c = 'MY';
            insert jrAuditMY;               
            
            System.enqueueJob(new RE_MY_DataAnalysisReportQueue(jrAuditMY));
        }
        Catch(Exception ex)
        {
            System.debug('RE_MY_DataAnalysisReportScheduler-Error-->'+ex.getMessage());
            System.debug('RE_MY_DataAnalysisReportScheduler-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('RE_MY_DataAnalysisReportScheduler-',ex.getMessage()+'-'+ex.getLineNumber(),'RE_MY_DataAnalysisReportScheduler','execute','Exception'); 
            RE_CND_Utility.updateJobAudit(jrAuditMY,'Failed',ex);
        }         
    }    
}