/***** TCP STNSAP SoldTo ShipTo Service 2 Queueable  ***********/
public class TCP_STNSAPSoldToShipToQueueable implements Queueable, Database.AllowsCallouts{ 
	list<string> soldToIds = new list<string>();
    integer i;
    RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
    public TCP_STNSAPSoldToShipToQueueable(list<string> soldToIdsfromCallingClass,integer jobcount){
        
        this.soldToIds = soldToIdsfromCallingClass;
        this.i = jobcount;
    }
    
    public void execute(QueueableContext context) { 
    
        try{
            
            //insert audit record for tracking this job
            
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Automate';
            jrAudit.RE_Job_Type__c = 'TCP STNSAP SoldTo ShipTo Job '+i;
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';
            
            insert jrAudit;
            if(!soldToIds.isEmpty()){
                for(string tempSoldID :  soldToIds){
                    TCP_STNSAPDataService.fetchSTNSAPSoldToShipTo(tempSoldID);
                }
            }
            
            //Finalizer class to manage final actions based on outcome of current job
            TCP_Queueable_finalizer tcpFinalActions = new TCP_Queueable_finalizer(jrAudit);
            System.attachFinalizer(tcpFinalActions);
            }
        catch(Exception e){
            system.debug('Exception in TCP_STNSAPSoldToShipToQueueable class : '+e.getMessage()+'line : '+e.getLineNumber());
            RV_ClassException.insertExceptionRecord('QUEUE_EXECUTE',e.getMessage(),'TCP_STNSAPSoldToShipToQueueable','execute','Exception');

        }
    }
    
}