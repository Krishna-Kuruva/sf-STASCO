trigger RT_Price_BookTrigger on RT_Price_Book__c (before delete) {
/*
trigger RT_Price_BookTrigger on RT_Price_Book__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Id MalaysiaRecordTypeId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('MY Price Book').getRecordTypeId();
    Boolean nonMalaysiaRecords =false;
    If(trigger.isInsert || trigger.isUpdate)
    {
        for(RT_Price_Book__c rec : Trigger.new)
        {
            If(rec.RecordTypeId != MalaysiaRecordTypeId)
            {
                nonMalaysiaRecords = true; 
                break; 
            }
        }
    }
    
    RT_Price_BookTriggerHandler obj = new RT_Price_BookTriggerHandler(nonMalaysiaRecords);
    
    switch on Trigger.operationType 
    {
        when BEFORE_INSERT {
            RT_Price_BookTriggerHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            RT_Price_BookTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when BEFORE_DELETE {
            RT_Price_BookTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_INSERT {
            RT_Price_BookTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            RT_Price_BookTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_DELETE {
            RT_Price_BookTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            RT_Price_BookTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
*/
}