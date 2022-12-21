trigger BET_BDD_RegDetailsTrigger on BET_Registration_Details__c (before insert, before update, before delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            BET_BDD_RegDetailsTriggerHelper.OnBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            BET_BDD_RegDetailsTriggerHelper.OnBeforeInsert(Trigger.new);
        }
        if(Trigger.isDelete){
            BET_BDD_RegDetailsTriggerHelper.OnBeforeDelete(Trigger.old,Trigger.oldMap);
        }
    }
}