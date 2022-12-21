/******************************************************************************************************************
className           :    RE_CND_CanadaQuoteScheduler
Description         :    Schedular Class to schedule RE_CND_Quotes_Queue
Author              :    Aasiya Siraj
Date				:	 30-April-2021 
*******************************************************************************************************************/

global class RE_CND_CanadaQuoteScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        try{ 
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Automate';
            jrAudit.RE_Job_Type__c = 'Canada Daily Reuters Quote Move';
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';
            jrAudit.RE_Country_Name__c='CA';
            insert jrAudit;
            System.enqueueJob(new RE_CND_Quotes_Queue(jrAudit));
            
        }
        catch(Exception ex){
            RV_ClassException.insertExceptionRecord('QUEUE_EXECUTE',ex.getMessage(),'RE_CND_CanadaQuoteScheduler','execute','Exception');
        }
    }
}