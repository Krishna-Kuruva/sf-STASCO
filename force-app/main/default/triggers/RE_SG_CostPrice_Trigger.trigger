trigger RE_SG_CostPrice_Trigger on RE_SG_CostPrice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    /*
    switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RE_SG_CostPrice_TriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RE_SG_CostPrice_TriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RE_SG_CostPrice_TriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RE_SG_CostPrice_TriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RE_SG_CostPrice_TriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RE_SG_CostPrice_TriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RE_SG_CostPrice_TriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        } */
		
    if ((Trigger.isInsert && Trigger.isAfter) || (Trigger.isUpdate && Trigger.isAfter)){
        RE_SingaporeOutputController.createmarginaspirationonTrigger(Trigger.new);
    } 
}