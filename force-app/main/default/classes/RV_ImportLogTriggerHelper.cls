/**
* Created by Dharmendra.Singh2 on 6/14/2021.
*/

public with sharing class RV_ImportLogTriggerHelper {
    
    public static void cancelUploadJob(String key){
        if(key != null){
            String jobNameKey = '%'+ key+'%';
            // List<CronJobDetail> cronJobDetails = [SELECT Id,JobType,Name FROM CronJobDetail where Name LIKE : jobNameKey ];
            CronTrigger obj = [SELECT Id, CronJobDetail.Name, CronJobDetail.Id,State FROM CronTrigger where CronJobDetail.Name LIKE : jobNameKey limit 1];
            System.debug('---obj---'+obj);
            if(obj != null){
                System.abortJob(obj.Id);
            } 
        }
        
        
    }
    
}