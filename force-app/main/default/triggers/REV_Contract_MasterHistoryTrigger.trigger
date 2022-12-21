trigger REV_Contract_MasterHistoryTrigger on REV_Contract_MasterHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                REV_Contract_MasterHistoryTriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                REV_Contract_MasterHistoryTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                REV_Contract_MasterHistoryTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                REV_Contract_MasterHistoryTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                REV_Contract_MasterHistoryTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                REV_Contract_MasterHistoryTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                REV_Contract_MasterHistoryTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }

}