/******************************************************************************************************************
className           :    REV_Contract_MasterHistoryTriggerHandler
Description         :    Handler class for Trigger REV_Contract_MasterHistoryTrigger
Author              :    Vishal Nigam
Date                :    06-Sept-2022
Test Class          :    REV_Contract_MasterHistoryTrigrHlprTest
*******************************************************************************************************************/
public without sharing class REV_Contract_MasterHistoryTriggerHandler 
{
    public static void beforeInsert(List<SObject> newRecords)
    {

    }
    public static void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        REV_Contract_MasterHistoryTriggerHelper.preventUpdateDel(newRecords);
    }
    public static void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        REV_Contract_MasterHistoryTriggerHelper.preventUpdateDel(oldRecords);
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