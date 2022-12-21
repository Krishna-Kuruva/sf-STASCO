trigger RV_CspTrigger on Customer_Specific_Pricing__c (before insert, before update, after insert, after update) {
/*****************************************************************************
@Name:  RV_CspTrigger     
@=========================================================================
@Purpose: Trigger for Customer_Specific_Pricing__c object
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    12-Feb-2020         INITIAL DEVELOPMENT

******************************************************************************/
    
    if(Trigger.isBefore){
        //Before insert
        if(Trigger.isInsert){
            RV_CspTriggerHelper.onBeforeInsert(Trigger.new);
        }
        //Before update
        if(Trigger.isUpdate){
            RV_CspTriggerHelper.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        //Before delete
        if(Trigger.isDelete){
            RV_CspTriggerHelper.onBeforeDelete(Trigger.old, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter){
        //After insert
        if(Trigger.isInsert){
            RV_CspTriggerHelper.onAfterInsert(Trigger.new, Trigger.newMap);
        }
        //After Update
        if(Trigger.isUpdate){
            RV_CspTriggerHelper.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}