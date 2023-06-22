/* Description - Batch Class which will run every 2 hours
 * Date - 10-05-2023
 * Created By - Madhu Javvaji
 */


global class TCP_P94_ProductSyncBatch implements Database.Batchable<sObject>,Database.Stateful {
	//start  
    public Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(TCP_P94_ProductSyncBatchHelper.getQuery());
   	}

    //execute
    public void execute(Database.BatchableContext BC, List<sObject> scope){
    	TCP_P94_ProductSyncBatchHelper.upsertProducts((List<TCP_P94_Staging_object__c>)scope);
    }

    //finish
   	public void finish(Database.BatchableContext BC){
   	}
    
}