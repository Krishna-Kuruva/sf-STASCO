/*************************************************************************************
    @Name:  BET_BDD_DocumentTrigger     
    @=================================================================================
    @Purpose: Trigger for BET_BDD_Document__c object
    @=================================================================================
    @History                                                            
    @---------                                                            
    @VERSION AUTHOR                            DATE                DETAIL                                 
    @1.0 - Rahul Sharma     ```````````````    24-Aug-2020         INITIAL DEVELOPMENT
    
*************************************************************************************/
trigger BET_BDD_DocumentTrigger on BET_BDD_Document__c (before insert, before update, after insert, after update, before delete) {

    if(Trigger.isBefore){
        //Before insert
        if(Trigger.isInsert){
            BET_BDD_DocumentTriggerHelper.onBeforeInsert(Trigger.new);
        }
        //Before update
        if(Trigger.isUpdate){
            BET_BDD_DocumentTriggerHelper.onBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        //Before delete
        if(Trigger.isDelete){
            BET_BDD_DocumentTriggerHelper.onBeforeDelete(Trigger.old);
        }
    }
    if(Trigger.isAfter){
        //After insert
        if(Trigger.isInsert){
            BET_BDD_DocumentTriggerHelper.onAfterInsert(Trigger.new);
        }
        //After Update
        if(Trigger.isUpdate){
            BET_BDD_DocumentTriggerHelper.onAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
}