trigger RE_ExternalFXMappings on RE_External_FX_Rates__c (after insert, after update) { 
     if(RE_Trigger_Activate__c.getValues('RE_ExternalFXMappings').RE_Active__c){
        if((trigger.isUpdate || trigger.isInsert)&& trigger.isAfter){
            RE_ExternalFXRatesHelper.onAfterExternalFXRatesHelper(Trigger.new); //Calling the helper class
        }
     }
}