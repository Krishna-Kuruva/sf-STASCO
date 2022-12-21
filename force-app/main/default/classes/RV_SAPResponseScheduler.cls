public class RV_SAPResponseScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        
      RV_BatchUpdateSHTContract b = new RV_BatchUpdateSHTContract(); 
      database.executebatch(b); 	
        
      RV_SAPStagingNoResponseEmailBatch sapStagingEmail = new RV_SAPStagingNoResponseEmailBatch();
      database.executeBatch(sapStagingEmail);
   }
}