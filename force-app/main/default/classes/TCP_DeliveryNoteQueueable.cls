/*****************************************************************************************************
ClassName	:	TCP_DeliveryNoteQueueable
Description	:	This class manages Delivery Note processing
Technical notes	:	1. Tried to make multiple queries on external object, but taking more processing time and if any one call fails whole transaction will fail
					2. Hence chosen to make one future call for one customer(TCP_OrderController.fetchGSAPCurrentOrders)
					3. By following this, each customer gets its own transaction limits as there is lot of processing once after receiving goods issue data
*****************************************************************************************************/

public with sharing class TCP_DeliveryNoteQueueable implements Queueable, Database.AllowsCallouts{
	set<string> soldToIds = new set<string>();
    integer i;
    RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
    public TCP_DeliveryNoteQueueable(set<string> soldToIdsfromCallingClass,integer jobcount){
        
        this.soldToIds = soldToIdsfromCallingClass;
        this.i = jobcount;
    }
    
    public void execute(QueueableContext context) { 
    
        try{
            
            //insert audit record for tracking this job
            
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Automate';
            jrAudit.RE_Job_Type__c = 'TCP Delivery Note '+i;
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';
            insert jrAudit;
            if(!soldToIds.isEmpty()){
                for(string tempSoldID :  soldToIds){
                    TCP_OrderController.fetchDeliveryNotedetails(tempSoldID,true);
                }
            }
            
            //Finalizer class to manage final actions based on outcome of current job
            TCP_Queueable_finalizer tcpFinalActions = new TCP_Queueable_finalizer(jrAudit);
            System.attachFinalizer(tcpFinalActions);
            }
        catch(Exception e){
            system.debug('Exception in TCP_DeliveryNoteQueueable class : '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('QUEUE_EXECUTE',e.getMessage(),'TCP_DeliveryNoteQueueable','execute','Exception');

        }
    }
    
    
}