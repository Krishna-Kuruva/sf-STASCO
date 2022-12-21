global class RV_SHTAutoRefreshScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
      system.debug('-------------inside scheduler class');
      RV_SHTAutoRefreshBatch b = new RV_SHTAutoRefreshBatch(); 
      database.executebatch(b); 
   }
}