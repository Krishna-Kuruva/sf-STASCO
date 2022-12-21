/*****************************************************************************
@Name:  RV_ATPAutoRefreshBatch      
@=========================================================================
@Purpose: Batch will execute  to calculate ATP auto Refresh                                                                                        
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/18/2017         INITIAL DEVELOPMENT

******************************************************************************/
global  class RV_ATPAutoRefreshBatch implements Database.Batchable<sObject> {
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'SELECT id,ATP_Refresh__c,ATP_Auto_Refresh__c,ATP_Live__c,Minimum ATP1 ,Location__r.Minimum_ATP1__c,Location__c from ATP__c where ATP_Auto_Refresh__c = true';
      return Database.getQueryLocator(query);
   } 

   global void execute(Database.BatchableContext BC, List<ATP__c> scope){
    
         List<ATP__c> finalupdateATPRecord = new List<ATP__c>();
         for(ATP__c atpRecords : scope){
             if(atpRecords.ATP_Live__c <> null){
                if(atpRecords.Minimum_ATP1__c == null)atpRecords.Minimum_ATP1__c=0.0;
                atpRecords.ATP1__c = atpRecords.Minimum_ATP1__c;
                atpRecords.ATP_Live__c = atpRecords.ATP1__c;
                atpRecords.Sales_8_30_17_30__c = 0;
                //atpRecords.ATP_Refresh__c = false;
                finalupdateATPRecord.add(atpRecords);
            }
         }
         try{
             update finalupdateATPRecord;
         }catch(Exception e){
                System.debug('%%%%%%%%%%%%%%%'+e);
         }
    }

   global void finish(Database.BatchableContext BC){
   }
}