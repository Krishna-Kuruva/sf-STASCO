/***** TCP STNSAP SoldTo ShipTo Service 1 Queueable  ***********/
public class TCP_STNSAPSoldToQueueable implements Queueable, Database.AllowsCallouts{ 
	set<string> salesAreaIds = new set<string>();
    integer i;
    RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
    public TCP_STNSAPSoldToQueueable (set<string> salesAreaIdsfromCallingClass,integer jobcount){        
    	this.salesAreaIds  = salesAreaIdsfromCallingClass;
        this.i = jobcount;
    }
    
	public void execute(QueueableContext context) {     
        try{            
            //insert audit record for tracking this job
            
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Automate';
            jrAudit.RE_Job_Type__c = 'TCP STNSAP SoldTo Job '+i;
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';            
            insert jrAudit;
            if(!salesAreaIds.isEmpty()){
                for(string tempsalesAreaId :  salesAreaIds){
                    TCP_STNSAPDataService.fetchSTNSAPSoldTo(tempsalesAreaId);
                }
            }
            
            //Finalizer class to manage final actions based on outcome of current job
            TCP_Queueable_finalizer tcpFinalActions = new TCP_Queueable_finalizer(jrAudit);
            System.attachFinalizer(tcpFinalActions);
            }
        catch(Exception e){
            system.debug('Exception in TCP_GoodsIssueQueueable class : '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('STNSAP SoldTo Queueable Exception',e.getMessage(),'TCP_STNSAPSoldToQueueable','execute','Exception');            
        }
    }
}