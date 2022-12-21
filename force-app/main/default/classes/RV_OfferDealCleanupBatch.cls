/**
Discription:- This class delete recoderds everyday at 8AM GMT+1.
Scheduler Class:- RV_OfferDealCleanupBatchScheduler
Test Class: RV_OfferDealCleanupBatchTest
Created By:-Ashish Soni
**/

global class RV_OfferDealCleanupBatch implements Database.Batchable<SObject>,Database.Stateful{
    global integer successCount = 0;
    global integer totalCount = 0;
    global integer failedCount = 0;
    
    
    global Database.Querylocator start (Database.BatchableContext BC) {
        
        String query = 'select Id,Name,is_Active__c from RV_Offer_Tracking__c where is_Active__c=true';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<RV_Offer_Tracking__c> scope) {
        List<RV_Offer_Tracking__c> offerTrackingDeleteList = new List<RV_Offer_Tracking__c>();
        try{
            for(RV_Offer_Tracking__c rvOfferItr: scope){
                RV_Offer_Tracking__c offerTrackUpdateRef = new RV_Offer_Tracking__c();
                offerTrackUpdateRef.Id = rvOfferItr.Id;
                offerTrackUpdateRef.is_Active__c = false;
                offerTrackingDeleteList.add(offerTrackUpdateRef);
            }
            List<Database.SaveResult> results = Database.update(offerTrackingDeleteList,false);
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
            RV_Exception__c rvException = new RV_Exception__c(getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString(),Apex_Class__c = 'RV_OfferDealCleanupBatch',Method_Name__c = 'Batch Start Method' );
            insert rvException;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //ASHISH: Added as part of PBI:1351565--START
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          from AsyncApexJob where Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses((System.label.RV_offerCleanupBatchEmailIds).split(','));
        mail.setSubject('RV_OfferDealCleanupBatch Batch Status: ' + a.Status);
        mail.setPlainTextBody('Total Records processed by batch: ' + totalCount +
                              ' with '+ failedCount + ' failures, and '+successCount + ' records are successfully processed without any error');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //PBI:1351565 END
    }
}