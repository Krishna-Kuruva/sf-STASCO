trigger RE_MOA_Trigger on RE_MOA__c (before delete) {
/*trigger RE_MOA_Trigger on RE_MOA__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
  Id MalaysiaRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
    Boolean nonMalaysiaRecords =false;
    If(trigger.isInsert || trigger.isUpdate)
    {
        for(RE_MOA__c rec : Trigger.new)
        {
            If(rec.RecordTypeId != MalaysiaRecordTypeId)
            {
                nonMalaysiaRecords = true;
                break;  
            }
        }
    }
    RE_MOA_TriggerHandler obj = new RE_MOA_TriggerHandler(nonMalaysiaRecords);
    switch on Trigger.operationType 
    {
        when BEFORE_INSERT {
            RE_MOA_TriggerHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            RE_MOA_TriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when BEFORE_DELETE {
            RE_MOA_TriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_INSERT {
            RE_MOA_TriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            RE_MOA_TriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_DELETE {
            RE_MOA_TriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            RE_MOA_TriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
   */ 
}