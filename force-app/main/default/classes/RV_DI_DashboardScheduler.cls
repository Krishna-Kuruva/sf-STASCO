global class RV_DI_DashboardScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
      RV_DI_DashboardBatch b = new RV_DI_DashboardBatch(); 
      database.executebatch(b); 
   } 
}