trigger RV_UpdateSHTContract on SAP_Staging__c (after update, after insert) {    
    
    if (Trigger.isInsert && Trigger.isAfter){
        RV_UpdateSHTContractHelper.onAfterInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isAfter){
       RV_UpdateSHTContractHelper.onAfterUpdate(Trigger.new);
    }
}