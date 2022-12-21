/******************************************************************************************************************
className           :    RE_SG_CostPrice_TriggerHandler
Description         :    Handler class for Trigger RE_SG_CostPrice_Trigger
Author              :    Vishal Nigam
Date                :    06-Sept-2022
*******************************************************************************************************************/
public with sharing class RE_SG_CostPrice_TriggerHandler {

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
        RE_SG_CostPrice_TriggerHelper.createHistoryRecords( newRecords,'RE_SG_CostPrice__c', 'RE_SG_CostPriceHistory__c', 'Inserted');
    }
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        RE_SG_CostPrice_TriggerHelper.createHistoryRecords( newRecords,'RE_SG_CostPrice__c', 'RE_SG_CostPriceHistory__c', 'Updated');
    }
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        RE_SG_CostPrice_TriggerHelper.createHistoryRecords( oldRecords,'RE_SG_CostPrice__c', 'RE_SG_CostPriceHistory__c', 'Deleted');
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        RE_SG_CostPrice_TriggerHelper.createHistoryRecords( newRecords,'RE_SG_CostPrice__c', 'RE_SG_CostPriceHistory__c', 'Undeleted');
    }
}