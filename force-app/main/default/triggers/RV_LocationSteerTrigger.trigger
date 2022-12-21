trigger RV_LocationSteerTrigger on Location_Steer__c (before insert,before update,after update) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        
            RV_LocationSteerTriggerHelper.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        
            RV_LocationSteerTriggerHelper.onAfterInsert(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
            
            RV_LocationSteerTriggerHelper.onBeforeUpdate(Trigger.new);

    }
    if(Trigger.isUpdate && Trigger.isAfter){
            
            
        	RV_LocationSteerTriggerHelper.onAfterUpdate(Trigger.new);
    }
}