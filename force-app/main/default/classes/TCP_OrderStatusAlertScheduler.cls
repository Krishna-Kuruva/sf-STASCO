global with sharing class TCP_OrderStatusAlertScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        TCP_BatchJobOrderStatusAlert batchAlert = new TCP_BatchJobOrderStatusAlert();
        Id batchId = Database.executeBatch(batchAlert, 100);
    }
    
}