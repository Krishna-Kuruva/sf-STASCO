/******************************************************************************************************************
className           :    RT_REVContractTriggerHandler
Description         :    Handler class for Trigger RT_REVContractTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
*******************************************************************************************************************/
public without sharing class RT_REVContractTriggerHandler {
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
        RT_REVContractTrigger_Helper.createHistoryRecords( newRecords,'REV_Contract_Master__c', 'REV_Contract_MasterHistory__c', 'Inserted');
    }
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        RT_REVContractTrigger_Helper.createHistoryRecords( newRecords,'REV_Contract_Master__c', 'REV_Contract_MasterHistory__c', 'Updated');
    }
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        RT_REVContractTrigger_Helper.createHistoryRecords( oldRecords,'REV_Contract_Master__c', 'REV_Contract_MasterHistory__c', 'Deleted');
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        RT_REVContractTrigger_Helper.createHistoryRecords( newRecords,'REV_Contract_Master__c', 'REV_Contract_MasterHistory__c', 'Undeleted');
    }

}