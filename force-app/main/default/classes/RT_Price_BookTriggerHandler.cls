/******************************************************************************************************************
className           :    RT_Price_BookTriggerHandler
Description         :    Handler class for Trigger RT_Price_BookTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
*******************************************************************************************************************/
public without sharing class RT_Price_BookTriggerHandler {

    public static Boolean nonMalaysiaRecords;
    public RT_Price_BookTriggerHandler(Boolean nonMalaysiaRec)
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
        RT_Price_BookTriggerHelper.createHistoryRecords( newRecords,'RT_Price_Book__c', 'RT_Price_BookHistory__c', 'Inserted');
    
        }
    }
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        If(nonMalaysiaRecords)
        {
        RT_Price_BookTriggerHelper.createHistoryRecords( newRecords,'RT_Price_Book__c', 'RT_Price_BookHistory__c', 'Updated');
        }
    }
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        If(nonMalaysiaRecords)
        {
        RT_Price_BookTriggerHelper.createHistoryRecords( oldRecords,'RT_Price_Book__c', 'RT_Price_BookHistory__c', 'Deleted');
        }
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        If(nonMalaysiaRecords)
        {
        RT_Price_BookTriggerHelper.createHistoryRecords( newRecords,'RT_Price_Book__c', 'RT_Price_BookHistory__c', 'Undeleted');
        }
    }

}