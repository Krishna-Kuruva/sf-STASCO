/******************************************************************************************************************
className           :    RE_Depot_Pricing_Backbone_TriggerHandler
Description         :    Handler class for Trigger RE_Depot_Pricing_Backbone_Trigger
Author              :    Vishal Nigam
Date                :    06-Sept-2022
*******************************************************************************************************************/
public without sharing class RE_Depot_Pricing_Backbone_TriggerHandler {
    public static void beforeInsert(List<SObject> newRecords)
    {

    }
    public static void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {

    }
    public static void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        
    }
    public static void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        RE_Depot_Pricing_Backbone_TriggerHelper.createHistoryRecords( newRecords,'RE_Depot_Pricing_Backbone__c', 'RE_Depot_Pricing_BackboneHistory__c', 'Inserted');
    }
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        RE_Depot_Pricing_Backbone_TriggerHelper.createHistoryRecords( newRecords,'RE_Depot_Pricing_Backbone__c', 'RE_Depot_Pricing_BackboneHistory__c', 'Updated');
    }
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        RE_Depot_Pricing_Backbone_TriggerHelper.createHistoryRecords( oldRecords,'RE_Depot_Pricing_Backbone__c', 'RE_Depot_Pricing_BackboneHistory__c', 'Deleted');
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        RE_Depot_Pricing_Backbone_TriggerHelper.createHistoryRecords( newRecords,'RE_Depot_Pricing_Backbone__c', 'RE_Depot_Pricing_BackboneHistory__c', 'Undeleted');
    }

}