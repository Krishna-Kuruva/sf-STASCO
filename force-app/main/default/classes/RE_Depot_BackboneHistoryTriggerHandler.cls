/******************************************************************************************************************
className           :    RE_Depot_Pricing_BackboneHistoryTriggerHandler
Description         :    Handler class for Trigger RE_Depot_Pricing_BackboneHistoryTrigger
Author              :    Vishal Nigam
Date                :    06-Sept-2022
Test Class          :    RE_Pricing_BackboneHisTrigTest
*******************************************************************************************************************/
public with sharing class RE_Depot_BackboneHistoryTriggerHandler 
{
    public static void beforeInsert(List<SObject> newRecords)
    {

    }
    public static void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        RE_Depot_BackboneHistoryTriggerHelper.preventUpdateDel(newRecords);
    }
    public static void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        RE_Depot_BackboneHistoryTriggerHelper.preventUpdateDel(oldRecords);
    }
    public static void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
       
    }
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
       
    }
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
       
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
       
    }
}