trigger Rv_ShtDaveMasterTrigger on SHT_Dave_Master__c (After  Update) {
    if (Trigger.isUpdate && Trigger.isAfter){ // on after update
       //system.debug('New Record==>'+Trigger.new);
        RV_SHTDaveTriggerHelper.publishTotalExposure(Trigger.new);
    }
}