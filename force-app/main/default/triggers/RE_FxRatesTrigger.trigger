trigger RE_FxRatesTrigger on RE_FX_Rates__c (before insert, after insert) { 
 	if ((Trigger.isInsert) && Trigger.isBefore)
         RE_FxRatesTriggerHelper.onBeforeTriggerHelper(Trigger.new, Trigger.oldMap, Trigger.newMap);
    
     if ((Trigger.isInsert) && Trigger.isAfter)
         RE_FxRatesTriggerHelper.onAfterTriggerHelper(Trigger.new, Trigger.oldMap, Trigger.newMap);

}