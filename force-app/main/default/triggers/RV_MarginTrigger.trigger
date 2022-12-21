trigger RV_MarginTrigger on Margin__c (before insert,before update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            RV_MarginTriggerHelper.onBeforeInsert(Trigger.new);
        }
    }
     if(Trigger.isUpdate){
        if(Trigger.isBefore){
            RV_MarginTriggerHelper.onBeforeUpdate(Trigger.new);
        }
    }
}