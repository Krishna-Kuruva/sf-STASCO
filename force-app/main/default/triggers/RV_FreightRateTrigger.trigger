trigger RV_FreightRateTrigger on Freight_Rate__c (before insert,after insert,before update,after update) {
    
   if(Trigger.isInsert && Trigger.isBefore){
  	 RV_FreightRateTriggerHelper.onBeforeInsertHelper(Trigger.new,Trigger.Old);
   }
    
   if(Trigger.isInsert && Trigger.isAfter){
  	 RV_FreightRateTriggerHelper.onAfterInsertHelper(Trigger.new,Trigger.Old);
   }
    
   if(Trigger.isUpdate && Trigger.isBefore){
  	 RV_FreightRateTriggerHelper.onBeforeUpdateHelper(Trigger.newMap,Trigger.OldMap);
   }
   if(Trigger.isUpdate && Trigger.isAfter){
  	 RV_FreightRateTriggerHelper.onAfterUpdateHelper(Trigger.newMap,Trigger.OldMap);
   }

}