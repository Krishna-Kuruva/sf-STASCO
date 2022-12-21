trigger RE_Depot_Pricing_BackboneHistoryTrigger on RE_Depot_Pricing_BackboneHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RE_Depot_BackboneHistoryTriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RE_Depot_BackboneHistoryTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RE_Depot_BackboneHistoryTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RE_Depot_BackboneHistoryTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RE_Depot_BackboneHistoryTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RE_Depot_BackboneHistoryTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RE_Depot_BackboneHistoryTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
}