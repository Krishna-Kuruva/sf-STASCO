/*****************************************************************************
@Name:  Rv_ATPTrigger     
@=========================================================================
@Purpose: Trigger will execute on insert and update to calculate ATP Refresh                                                                                        
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/18/2017         INITIAL DEVELOPMENT

******************************************************************************/
trigger Rv_ATPTrigger on ATP__c (before insert, before update,after update) {
    //System.debug('^^^^trigger runnnig^^^^^^^' );
   if (Trigger.isInsert && Trigger.isBefore){ // on after insert
        RV_ATPTriggerHelper.onBeforeinsertAtp(Trigger.new);
   }
   if (Trigger.isUpdate && Trigger.isBefore){// on after update
        RV_ATPTriggerHelper.onBeforeUpdateAtp(Trigger.new,Trigger.newMap,Trigger.oldMap);
   }
   if (Trigger.isUpdate && Trigger.isAfter){// on after update
        RV_ATPTriggerHelper.onAfterUpdateAtp(Trigger.new,Trigger.newMap,Trigger.oldMap);
   }
}