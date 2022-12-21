trigger BET_BDDAddressTrigger on BET_BDD_Address__c (before insert,before update,after insert,after update,before delete) {
    if((trigger.isBefore)&&(trigger.isDelete)){
        BET_BDDAddressTriggerHelper.preventSubmitDelete(trigger.old);
    }
    if((trigger.isBefore)&&(trigger.isInsert || trigger.isUpdate)){
         BET_BDDAddressTriggerHelper.addressRecordLocked(trigger.new);
        BET_BDDAddressTriggerHelper.addressTypeInvalid(trigger.new);
        BET_BDDAddressTriggerHelper.duplicateRecordBlock(trigger.new,trigger.oldMap);
       
    }
    if((trigger.isBefore)&&(trigger.isInsert)){
         BET_BDDAddressTriggerHelper.addressRecordLocked(trigger.new);
         BET_BDDAddressTriggerHelper.updateBusinessLine(trigger.new);
        BET_BDDAddressTriggerHelper.mdnRecordTypeLock(trigger.new);
    }
    
      if((trigger.isAfter)&&(trigger.isUpdate)){
         BET_BDDAddressTriggerHelper.updateBusinessLine(trigger.new);
          BET_BDDAddressTriggerHelper.updateLegalandRegisteredAddress(trigger.new,trigger.oldMap);
    }
    if((trigger.isAfter)&&(trigger.isInsert || trigger.isUpdate)){
        BET_BDDAddressTriggerHelper.sameAsLegalAddressUpdate(trigger.new,trigger.oldMap);
    }
     if((trigger.isBefore)&&(trigger.isUpdate)){
         
        
    }
}