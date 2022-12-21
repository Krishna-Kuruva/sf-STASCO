trigger RT_SettingHistoryTrigger on RT_SettingHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RT_SettingHistoryTriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RT_SettingHistoryTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RT_SettingHistoryTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RT_SettingHistoryTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RT_SettingHistoryTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RT_SettingHistoryTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RT_SettingHistoryTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }

}