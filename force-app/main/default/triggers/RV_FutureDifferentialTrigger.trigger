trigger RV_FutureDifferentialTrigger on Future_Differential__c (before insert,before update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            RV_FutureDifferentialTriggerHelper.onBeforeInsert(Trigger.new);
        }
    }
     if(Trigger.isUpdate){
        if(Trigger.isBefore){
            RV_FutureDifferentialTriggerHelper.onBeforeUpdate(Trigger.new);
        }
    }
}