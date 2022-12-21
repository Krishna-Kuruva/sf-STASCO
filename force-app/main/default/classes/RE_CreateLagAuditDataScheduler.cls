public class RE_CreateLagAuditDataScheduler implements Schedulable {
	
    public void execute(System.SchedulableContext c){
        RE_ExternalTriggerHelper.CreateLagAuditData();
    }
}