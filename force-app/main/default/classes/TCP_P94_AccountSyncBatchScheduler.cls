/* Description - Scheduler Class which will run every 2 hours
 * Date - 02-05-2023
 * Created By - Madhu Javvaji
 */

global class TCP_P94_AccountSyncBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
      TCP_P94_AccountSyncBatch b = new TCP_P94_AccountSyncBatch(); 
      database.executebatch(b,500);
   }
}