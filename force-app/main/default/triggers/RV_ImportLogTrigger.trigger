/**
 * Created by Dharmendra.Singh2 on 6/14/2021.
 */

trigger RV_ImportLogTrigger on RT_ImportLog__c (after update) {

    List<String> rtImportLogs = new List<String>();
    If(Trigger.isUpdate){
        for(RT_ImportLog__c importLog : Trigger.new){
            String key;
            if(importLog.ImportStatus__c == 'Cancelled'){
                key = importLog.Id;
            }
            System.debug('---Key---'+key);
            if(key != null){
                RV_ImportLogTriggerHelper.cancelUploadJob(key);
            }
            
        }
       // RV_ImportLogTriggerHelper.cancelUploadJob(rtImportLogs);

    }

}