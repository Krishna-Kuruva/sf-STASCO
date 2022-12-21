trigger RE_MY_CostPriceHistoryTrigger on RE_MY_CostPriceHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RE_MY_CostPriceHistoryTriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RE_MY_CostPriceHistoryTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RE_MY_CostPriceHistoryTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RE_MY_CostPriceHistoryTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RE_MY_CostPriceHistoryTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RE_MY_CostPriceHistoryTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RE_MY_CostPriceHistoryTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
}