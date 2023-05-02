/**************************************************************************************************************
Author: Surbhi Srivastava
PBI Number: 1593743 (OLF Precomputation Fix: Add a service to clear old data)
Description: Purpose of the batch is to clear out the precomputation yesterday data from the system which is 
called from OLF_OldOffersCleanupBatchScheduler apex class.
Implementation Date: 19-12-2022
**************************************************************************************************************
Version - 1.0 | Last Updated Date - 19-12-2022
**************************************************************************************************************/

global class OLF_OldOffersCleanupBatch implements Database.Batchable<SObject>,Database.Stateful{
    global integer successCount = 0;
    global integer totalCount = 0;
    global integer failedCount = 0;
    
    global Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT ID From RV_OLF_MRC_Data__c'); 
    }
    
    global void execute (Database.BatchableContext bc, List<RV_OLF_MRC_Data__c> scope){
        System.debug('scope ::' +scope);
        if(scope.size() > 0){
            try{
                Database.DeleteResult[] lstOfDeletedMRCs = Database.delete(scope,false);
                totalCount = totalCount + scope.size(); 
                System.debug('totalCount ::' +totalCount);
                for(Database.DeleteResult dr : lstOfDeletedMRCs) { 
                    if (dr.isSuccess()){
                        successCount ++;
                        System.debug('Successfully deleted offers with ID: ' + dr.getId());
                    }
                    else{
                        failedCount ++;                                   
                    } 
                }
            }
            catch(exception e){
                System.debug('Something exception occured');
                RV_Exception__c rvException = new RV_Exception__c(getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString(),Apex_Class__c = 'OLF_OldOffersCleanupBatch',Method_Name__c = 'Batch Execute Method' );
                insert rvException;
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        try{
            AsyncApexJob a = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                              FROM AsyncApexJob WHERE Id =:bc.getJobId()];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'BNG-ECO Revolution SBOBNG-PTID/TH'];                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
            mail.setToAddresses(OLF_DashboardApexController.getUserEmailFromPermissionSet('RV_OnlineSalesManagement'));
            if(owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            mail.setSubject('OLF Daily Old Offers Clean Up Batch Status: ' + a.Status);
            mail.setPlainTextBody('Total Records processed by batch: ' + totalCount +
                                  ' with '+ failedCount + ' failures, and '+successCount + ' records are successfully deleted without any error.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(exception e){
            System.debug('Something exception occured');
            RV_Exception__c rvException = new RV_Exception__c(getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString(),Apex_Class__c = 'OLF_OldOffersCleanupBatch',Method_Name__c = 'Batch Finish Method' );
            insert rvException;
        }
    }   
}