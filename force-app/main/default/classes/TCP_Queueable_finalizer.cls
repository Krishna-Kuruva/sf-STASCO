/*****************************************************************************************************
ClassName	:	TCP_Queueable_finalizer
Description	:	This class manages final actions of Queaueable jobs in TCP
*****************************************************************************************************/

public class TCP_Queueable_finalizer implements Finalizer {
    public RE_Job_Run_Audit__c jrauditRec;
    public TCP_Queueable_finalizer(RE_Job_Run_Audit__c jraudit){
        this.jrauditRec = jraudit;
    }
    public void execute(FinalizerContext ctx){
        Id parentQueueableJobId = ctx.getAsyncApexJobId();
        String parentJobId = '' + ctx.getAsyncApexJobId();
        try{
            if (ctx.getResult() == ParentJobResult.SUCCESS) {
            jrauditRec.RE_Job_Status__c = 'Completed';
            update jrauditRec;
            } else {
                RV_ClassException.insertExceptionRecord('Finalizer Action',ctx.getException().getMessage(),'TCP_Queueable_finalizer','execute','Exception');
                jrauditRec.RE_Job_Status__c = 'Failed';
                update jrauditRec;
                
            }
        }
        catch(Exception e){
                RV_ClassException.insertExceptionRecord('Finalizer Action',ctx.getException().getMessage(),'TCP_Queueable_finalizer','execute','Exception');
        }
        
    }
}