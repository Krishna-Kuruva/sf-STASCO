/******************************************************************************************************************
className           :    RE_MOAHistoryTriggerHelper
Description         :    Helper class for Trigger RE_MOAHistoryTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
Test Class          :    RE_MOAHistoryTriggerHelperTest
*******************************************************************************************************************/
public without sharing class RE_MOAHistoryTriggerHelper 
{
    public static void preventUpdateDel(RE_MOAHistory__c[] records)
    {
        records[0].addError('Modifying/Deleting History Records is NOT Allowed');
    }

}