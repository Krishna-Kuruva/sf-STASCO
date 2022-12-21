trigger RE_ExternalMarketQuotesTrigger on RE_External_Market_Quotes__c (after insert, after update) 
{
    if(RE_Trigger_Activate__c.getValues('RE_ExternalMarketQuotesTrigger').RE_Active__c){
     	if ((Trigger.isUpdate || Trigger.isInsert) && Trigger.isAfter)
        	RE_ExternalMarketQuotesTriggerHelper.onAfterMopsTriggerHelper(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}