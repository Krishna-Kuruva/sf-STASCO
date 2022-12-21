trigger RE_Job_Run_Audit_Trigger on RE_Job_Run_Audit__c (before insert, after insert) {
    Boolean isEastData = RE_Job_Run_Audit_TriggerHelper.checkCountry(Trigger.new);
    if (Trigger.isInsert && Trigger.isAfter){
        if(isEastData){
            RE_Job_Run_Audit_TriggerHelper jradata = new RE_Job_Run_Audit_TriggerHelper();
        	jradata.onBeforeJobRunAudit(Trigger.new, Trigger.newMap);
        }
    }
}