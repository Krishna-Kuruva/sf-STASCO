/*****************************************************************************
@Name:  IK_LiveDisruptionTrigger     
@=========================================================================
@Purpose: Trigger will execute on insert,update delete to  send email to particular user group                          
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      14/11/2017           INITIAL DEVELOPMENT
  
******************************************************************************/  
trigger IK_LiveDisruptionTrigger on Live_Disruption__c (before insert,after insert,before update,after update,after delete) {
   
   List<TriggerActiveInactive__mdt> triggermdt = [Select id,DeveloperName,MasterLabel,isBeforeInsert__c,isAfterInsert__c,isBeforeUpdate__c,isAfterUpdate__c,isBeforeDelete__c,isAfterDelete__c
                                                  from TriggerActiveInactive__mdt where MasterLabel = 'Live_Disruption__c']; 
   
    if(triggermdt.get(0).isBeforeInsert__c){
       if (Trigger.isInsert && Trigger.isBefore){ // on before insert
            IK_LiveDisruptionTriggerClass.onbeforeinsertLiveDisrupt(Trigger.new);
       }  
    }
   
   if(triggermdt.get(0).isAfterInsert__c){
       if (Trigger.isInsert && Trigger.isAfter){ // on after insert
            System.debug('------Trigger.new-------'+Trigger.new);
            IK_LiveDisruptionTriggerClass.onafterinsertLiveDisrupt(Trigger.new);
       }
   }
    
   if(triggermdt.get(0).isBeforeUpdate__c){ 
       if (Trigger.isUpdate && Trigger.isBefore){// on before update
            IK_LiveDisruptionTriggerClass.onBeforeupdateLiveDisrupt(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
       }
   }
   
   if(triggermdt.get(0).isAfterUpdate__c){ 
       if (Trigger.isUpdate && Trigger.isAfter){// on after update
            IK_LiveDisruptionTriggerClass.onafterupdateLiveDisrupt(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
       }
   }
    
   if(triggermdt.get(0).isAfterDelete__c){ 
       if (Trigger.isDelete && Trigger.isAfter){// on after delete
                IK_LiveDisruptionTriggerClass.onafterdeleteLiveDisrupt(Trigger.old);
       }
   }
}