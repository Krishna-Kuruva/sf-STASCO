Trigger BET_BDDFormTrigger on BET_BDD_Form__c (before update,before insert,before delete) {
    if(trigger.isDelete){
        BET_BDDFormTriggerHelper.preventSubmitDelete(trigger.old);
    }
    if(trigger.isUpdate){
        // BET_BDDFormTriggerHelper.updateLastModifiedbyUser(trigger.new);
        BET_BDDFormTriggerHelper.updateOwnerAndCof(trigger.new,trigger.oldMap,trigger.isUpdate);
        BET_BDDFormTriggerHelper.fillGsapDefaults(trigger.new,trigger.oldMap);
        BET_BDDFormTriggerHelper.updateBusinessLine(trigger.new,trigger.oldMap);
        BET_BDDFormTriggerHelper.businessLineValidation(trigger.new);
        //Adding the validation for Relationship
        //BET_BDDFormTriggerHelper.relationShipMandatoryValidation(trigger.new);
        BET_BDDFormTriggerHelper.emailFieldValidation(trigger.new,trigger.oldMap);
        BET_BDDFormTriggerHelper.fieldRequiredCheck(trigger.newMap);
        BET_BDDFormTriggerHelper.recordLock(trigger.newMap,trigger.oldMap);
        BET_BDD_UpdateEntityLegalForm.updateRecordFromTrigger(trigger.new,trigger.oldMap);
		BET_BDDFormTriggerHelper.checkApproverMandatoryFields(trigger.new);
        BET_BDDFormTriggerHelper.restrictChangesAfterApproval(trigger.new,trigger.oldMap);
        BET_BDDFormTriggerHelper.restricMDNProposedTransactionFields(trigger.new,trigger.oldMap);
		//call method
        BET_BDDFormTriggerHelper.updateGTMDNStatusFields(trigger.new,trigger.oldMap);
		//call method
    }
    if(trigger.isInsert){
        //  BET_BDDFormTriggerHelper.updateLastModifiedbyUser(trigger.new,trigger.isInsert);
        BET_BDDFormTriggerHelper.ownerUpdateValidation(trigger.new);
        BET_BDDFormTriggerHelper.updateBusinessLine(trigger.new,trigger.oldMap);
        BET_BDDFormTriggerHelper.businessLineValidation(trigger.new);
        //Adding the validation for Relationship
        //BET_BDDFormTriggerHelper.relationShipMandatoryValidation(trigger.new);
        BET_BDD_UpdateEntityLegalForm.updateRecordFromTrigger(trigger.new,trigger.oldMap);
		BET_BDDFormTriggerHelper.checkApproverMandatoryFields(trigger.new);
    }
}