/* Description - Scheduler Class which will run every 2 hours
 * Date - 10-05-2023
 * Created By - Madhu Javvaji
 */


global class TCP_P94_ProductSyncBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
      TCP_P94_ProductSyncBatch b = new TCP_P94_ProductSyncBatch(); 
      database.executebatch(b,2000);
   }
}