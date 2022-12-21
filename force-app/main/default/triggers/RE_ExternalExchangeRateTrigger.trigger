trigger RE_ExternalExchangeRateTrigger on RE_External_Exchange_Rate__c (After insert, After update) { 
    if(RE_Trigger_Activate__c.getValues('RE_ExternalExchangeRateTrigger').RE_Active__c){
        if((trigger.isUpdate || trigger.isInsert)&& trigger.isAfter){
            RE_ExternalExchangeRateTriggerHelper.onAfterExternalFXRatesHelper(Trigger.new, Trigger.newmap, Trigger.oldmap);
        }
    }
    
}