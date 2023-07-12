/* Description - Batch Class which will run every 2 hours
 * Date - 02-05-2023
 * Created By - Madhu Javvaji
 */

global class TCP_P94_AccountSyncBatch implements Database.Batchable<sObject>,Database.Stateful {
	//start  
    public Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(TCP_P94_AccountSyncBatchHelper.getQuery());
   	}

    //execute
    public void execute(Database.BatchableContext BC, List<sObject> scope){
    	TCP_P94_AccountSyncBatchHelper.upsertAccounts((List<TCP_P94_Staging_object__c>)scope);
    }

    //finish
   	public void finish(Database.BatchableContext BC){
   	}
    
}