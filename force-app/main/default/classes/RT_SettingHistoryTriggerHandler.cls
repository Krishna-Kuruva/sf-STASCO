/******************************************************************************************************************
className           :    RT_SettingHistoryTriggerHandler
Description         :    Handler class for Trigger RT_SettingHistoryTrigger
Author              :    Vishal Nigam
Date                :    06-Sept-2022
Test Class          :    RT_SettingHistoryTriggerHelperTest
*******************************************************************************************************************/
public without sharing class RT_SettingHistoryTriggerHandler 
{
    public static void beforeInsert(List<SObject> newRecords)
    {

    }
    public static void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        RT_SettingHistoryTriggerHelper.preventUpdateDel(newRecords);
    }
    public static void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        RT_SettingHistoryTriggerHelper.preventUpdateDel(oldRecords);
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