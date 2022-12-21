public class BulkUploadGTSearchBatchScheduler implements Schedulable {
    Integer batchLimit = 200;
    public BulkUploadGTSearchBatchScheduler(Integer batchRecordLimit){
        if(batchRecordLimit !=null)
            this.batchLimit = batchRecordLimit;
    }
    public void execute(SchedulableContext ctx) {
        BulkUploadGTSearchBatch myBatchObject = new BulkUploadGTSearchBatch(batchLimit); 
        Id batchId = Database.executeBatch(myBatchObject,1);
    }
}