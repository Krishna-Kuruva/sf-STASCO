global class Rv_archiveCustSalesMgmtSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
       System.enqueueJob(new RV_ATPAutoRefreshDailyBatch());
   }
}