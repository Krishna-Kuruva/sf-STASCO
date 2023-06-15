/**
 * CreatedBy - Swarna
 * Description- refer all the latest Reuter Quotes for scenario calculations after the Zema EOD job
 */
global class RV_refreshLocationSteersBatch implements Database.Batchable<SObject>,Database.Stateful{
        global integer successCount = 0;
        global integer totalCount = 0;
        global integer failedCount = 0;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select Id,  Name, RecordTypeId,Scenario_Value__c, Scenario__c,Source_Steer__c, Steer_Value__c from Location_Steer__c where Rv_Is_Active_Steer__c = true and RecordType.DeveloperName = \'Source_Steer\'';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Location_Steer__c> scope)
    {
        try{
            List<Database.SaveResult> results = Database.update(scope,false);
            totalCount = scope.size();
            successCount= 0;
            failedCount= 0;
            for (Database.SaveResult result: results)
            {
                if (result.isSuccess())
                {
                    successCount = successCount +1;
                }else{
                    failedCount++;
                }
            }
        }Catch(exception e){
            RV_Exception__c rvException = new RV_Exception__c(getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString(),Apex_Class__c = 'RV_refreshLocationSteersBatch',Method_Name__c = 'Batch Start Method' );
            insert rvException;
        }

    }
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          from AsyncApexJob where Id =:BC.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses((System.label.RV_offerCleanupBatchEmailIds).split(','));
        mail.setSubject('RV_refereshLocationSteersBatch Batch Status: ' + a.Status);
        mail.setPlainTextBody('Total Records processed by batch: ' + totalCount +
                              ' with '+ failedCount + ' failures, and '+successCount + ' records are successfully processed without any error');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

}