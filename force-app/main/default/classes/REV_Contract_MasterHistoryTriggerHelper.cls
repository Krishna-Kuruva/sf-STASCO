/******************************************************************************************************************
className           :    REV_Contract_MasterHistoryTriggerHelper
Description         :    Helper class for Trigger REV_Contract_MasterHistoryTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
Test Class          :    REV_Contract_MasterHistoryTrigrHlprTest
*******************************************************************************************************************/
public without sharing class REV_Contract_MasterHistoryTriggerHelper 
{
    public static void preventUpdateDel(REV_Contract_MasterHistory__c[] records)
    {
        records[0].addError('Modifying/Deleting History Records is NOT Allowed');
    }

}