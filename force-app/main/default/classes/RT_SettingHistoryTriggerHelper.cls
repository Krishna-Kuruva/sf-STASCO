/******************************************************************************************************************
className           :    RT_SettingHistoryTriggerHelper
Description         :    Helper class for Trigger RT_SettingHistoryTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
Test Class          :    RT_SettingHistoryTriggerHelperTest
*******************************************************************************************************************/
public without sharing class RT_SettingHistoryTriggerHelper 
{
    public static void preventUpdateDel(RT_SettingHistory__c[] records)
    {
        records[0].addError('Modifying/Deleting History Records is NOT Allowed');
    }
}