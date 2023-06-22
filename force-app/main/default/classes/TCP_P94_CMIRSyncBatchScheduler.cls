/* Description - Scheduler Class which will run every 2 hours
 * Date - 16-05-2023
 * Created By - Madhu Javvaji
 */

global class TCP_P94_CMIRSyncBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
      TCP_P94_CMIRSyncBatch b = new TCP_P94_CMIRSyncBatch(); 
      database.executebatch(b,500);
   }
}