/******************************************************************************************************************
className           :    RE_Cost_Price_Trigger_Handler
Description         :    Handler class for Trigger RE_MY_CostPrice_Trigger
Author              :    Vishal Nigam
Date                :    29-July-2022
*******************************************************************************************************************/
public without sharing class RE_Cost_Price_Trigger_Handler 
{
    public static Boolean nonMalaysiaRecords;
    public RE_Cost_Price_Trigger_Handler(Boolean nonMalaysiaRec)
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
            RE_Cost_Price_Trigger_Helper.createHistoryRecords( newRecords,'RE_MY_CostPrice__c', 'RE_MY_CostPriceHistory__c', 'Inserted');
        }
    }
        
    public static void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap)
    {
        If(nonMalaysiaRecords)
        {
          RE_Cost_Price_Trigger_Helper.createHistoryRecords( newRecords,'RE_MY_CostPrice__c', 'RE_MY_CostPriceHistory__c', 'Updated');
        }
    }
        
    public static void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap)
    {
        If(nonMalaysiaRecords)
        {
           RE_Cost_Price_Trigger_Helper.createHistoryRecords( oldRecords,'RE_MY_CostPrice__c', 'RE_MY_CostPriceHistory__c', 'Deleted');
        }
    }
    public static void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap)
    {
        If(nonMalaysiaRecords)
        {
           RE_Cost_Price_Trigger_Helper.createHistoryRecords( newRecords,'RE_MY_CostPrice__c', 'RE_MY_CostPriceHistory__c', 'Undeleted');
        }
    }

}