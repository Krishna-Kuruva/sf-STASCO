/******************************************************************************************************************
className           :    REVCountry_Setting_TriggerHandler
Description         :    Handler class for Trigger REVCountry_Setting_Trigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
*******************************************************************************************************************/
public without sharing class REVCountry_Setting_TriggerHandler {
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
        REVCountry_Setting_TriggerHelper.createHistoryRecords( newRecords,'RT_Setting__c', 'RT_SettingHistory__c', 'Inserted');
    }
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        REVCountry_Setting_TriggerHelper.createHistoryRecords( newRecords,'RT_Setting__c', 'RT_SettingHistory__c', 'Updated');
    }
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        REVCountry_Setting_TriggerHelper.createHistoryRecords( oldRecords,'RT_Setting__c', 'RT_SettingHistory__c', 'Deleted');
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        REVCountry_Setting_TriggerHelper.createHistoryRecords( newRecords,'RT_Setting__c', 'RT_SettingHistory__c', 'Undeleted');
    }

}