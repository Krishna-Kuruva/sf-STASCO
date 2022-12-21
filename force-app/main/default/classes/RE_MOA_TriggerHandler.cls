/******************************************************************************************************************
className           :    RE_MOA_TriggerHandler
Description         :    Handler class for Trigger RE_MOA_Trigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
*******************************************************************************************************************/
public with sharing class RE_MOA_TriggerHandler {

    public static Boolean nonMalaysiaRecords;
    public RE_MOA_TriggerHandler(Boolean nonMalaysiaRec)
    {
       nonMalaysiaRecords = nonMalaysiaRec;

    }
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
        If(nonMalaysiaRecords)
        {
        RE_MOA_TriggerHelper.createHistoryRecords( newRecords,'RE_MOA__c', 'RE_MOAHistory__c', 'Inserted');
    
        }
    }
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        If(nonMalaysiaRecords)
        {
        RE_MOA_TriggerHelper.createHistoryRecords( newRecords,'RE_MOA__c', 'RE_MOAHistory__c', 'Updated');
        }
    }
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        If(nonMalaysiaRecords)
        {
        RE_MOA_TriggerHelper.createHistoryRecords( oldRecords,'RE_MOA__c', 'RE_MOAHistory__c', 'Deleted');
        }
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        If(nonMalaysiaRecords)
        {
        RE_MOA_TriggerHelper.createHistoryRecords( newRecords,'RE_MOA__c', 'RE_MOAHistory__c', 'Undeleted');
        }
    }

}