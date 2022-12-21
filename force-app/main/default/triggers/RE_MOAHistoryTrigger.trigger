trigger RE_MOAHistoryTrigger on RE_MOAHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RE_MOAHistoryTriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RE_MOAHistoryTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RE_MOAHistoryTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RE_MOAHistoryTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RE_MOAHistoryTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RE_MOAHistoryTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RE_MOAHistoryTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
}