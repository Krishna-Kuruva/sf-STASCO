global class TCP_BatchJobOrderStatusAlert implements Database.Batchable<sObject>,Database.Stateful {
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString =  'SELECT id,LastModifiedDate,tcp_email_alert_sent__c, Name,Sold_To__r.Sales_Area__r.Sales_Region__c, OrderNumber,GSAP_Status__c, Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, CreatedBy.Name,CreatedDate from Order where GSAP_Status__c IN (\'No GSAP Response\', \'Sent Failed\') AND tcp_email_alert_sent__c = false';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        try{
            TCP_OrderFailedAlertHelper.processFailedOrderList(scope);
            
        }catch(Exception e){
            TCP_ExceptionLogClass.insertExceptionRecord('TCP Batch Alert',e.getMessage(),'TCP_BatchJobOrderStatusAlert','execute','Exception');
        }
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
        // give a call to another batch class
        // Can give to another batch class
        // Can give callout request
        system.debug('batch job id = '+bc.getJobId());
    }
}