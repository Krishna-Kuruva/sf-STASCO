global class BET_DocumentStatusUpdateBatchScheduler implements schedulable{
    global void execute(SchedulableContext sc)
    {
        BET_DocumentStatusUpdateBatch myBatchObject = new BET_DocumentStatusUpdateBatch(); 
        Id batchId = Database.executeBatch(myBatchObject,1000);
        
    }
    
}