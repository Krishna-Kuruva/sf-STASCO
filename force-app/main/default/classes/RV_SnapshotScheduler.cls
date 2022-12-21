global class RV_SnapshotScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
      RV_DI_Dashboard_Snapshot b = new RV_DI_Dashboard_Snapshot(); 
      database.executebatch(b); 
   }
}