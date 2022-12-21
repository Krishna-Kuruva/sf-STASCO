trigger RT_Price_BookHistoryTrigger on RT_Price_BookHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RT_Price_BookHistoryTriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RT_Price_BookHistoryTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RT_Price_BookHistoryTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RT_Price_BookHistoryTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RT_Price_BookHistoryTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RT_Price_BookHistoryTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RT_Price_BookHistoryTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
}