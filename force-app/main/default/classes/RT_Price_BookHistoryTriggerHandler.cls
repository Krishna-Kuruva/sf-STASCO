/******************************************************************************************************************
className           :    RT_Price_BookHistoryTriggerHandler
Description         :    Handler class for Trigger RT_Price_BookHistoryTrigger
Author              :    Vishal Nigam
Date                :    06-Sept-2022
Test Class          :    RT_Price_BookHistoryTriggerHelperTest
*******************************************************************************************************************/
public without sharing class RT_Price_BookHistoryTriggerHandler 
{
    public static void beforeInsert(List<SObject> newRecords)
    {

    }
    public static void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        RT_Price_BookHistoryTriggerHelper.preventUpdateDel(newRecords);
    }
    public static void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        RT_Price_BookHistoryTriggerHelper.preventUpdateDel(oldRecords);
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