/******************************************************************************************************************
className           :    RE_MY_CostPriceHistoryTriggerHandler
Description         :    Helper class for Trigger RE_MY_CostPriceHistoryTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
Test Class          :    RE_MY_CostPriceHistoryTriggerHelperTest
*******************************************************************************************************************/
public without sharing class RE_MY_CostPriceHistoryTriggerHandler {

    public static void beforeInsert(List<SObject> newRecords)
    {

    }
    public static void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        RE_MY_CostPriceHistoryTriggerHelper.preventUpdateDel(newRecords);
    }
    public static void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        RE_MY_CostPriceHistoryTriggerHelper.preventUpdateDel(oldRecords);
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