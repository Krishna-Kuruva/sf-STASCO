/******************************************************************************************************************
className           :    RT_Price_BookHistoryTriggerHelper
Description         :    Helper class for Trigger RT_Price_BookHistoryTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
Test Class          :    RT_Price_BookHistoryTriggerHelperTest
*******************************************************************************************************************/
public without sharing class RT_Price_BookHistoryTriggerHelper {

    public static void preventUpdateDel(RT_Price_BookHistory__c[] records)
    {
        records[0].addError('Modifying/Deleting History Records is NOT Allowed');
    }
}