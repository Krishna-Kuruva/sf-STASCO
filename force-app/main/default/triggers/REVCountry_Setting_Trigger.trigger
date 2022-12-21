trigger REVCountry_Setting_Trigger on RT_Setting__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                REVCountry_Setting_TriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                REVCountry_Setting_TriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                REVCountry_Setting_TriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                REVCountry_Setting_TriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                REVCountry_Setting_TriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                REVCountry_Setting_TriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                REVCountry_Setting_TriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
}