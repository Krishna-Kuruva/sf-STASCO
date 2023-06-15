global class RV_refreshLocSteersBatchScheduled implements Schedulable {

 global void execute(SchedulableContext sc) {
        RV_refreshLocationSteersBatch b = new RV_refreshLocationSteersBatch();
        database.executebatch(b);
    }
}
//schedule
//System.schedule(Schedule Job Name 12', '0 15 17 ? * MON-FRI', new RV_refreshLocSteersBatchScheduled());