trigger RE_Depot_Pricing_Backbone_Trigger on RE_Depot_Pricing_Backbone__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RE_Depot_Pricing_Backbone_TriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RE_Depot_Pricing_Backbone_TriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RE_Depot_Pricing_Backbone_TriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RE_Depot_Pricing_Backbone_TriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RE_Depot_Pricing_Backbone_TriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RE_Depot_Pricing_Backbone_TriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RE_Depot_Pricing_Backbone_TriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
        If(!Trigger.isDelete && !Trigger.isUndelete)
        {
            RE_Depot_Pricing_Backbone_TriggerHelper.onAfterPMTChange(Trigger.new,Trigger.newmap);
        }

}