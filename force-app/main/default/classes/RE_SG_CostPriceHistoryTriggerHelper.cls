/******************************************************************************************************************
className           :    RE_SG_CostPriceHistoryTriggerHelper
Description         :    Helper class for Trigger RE_SG_CostPriceHistoryTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
Test Class          :    RE_SG_CostPriceHistoryTriggerHelperTest
*******************************************************************************************************************/
public without sharing class RE_SG_CostPriceHistoryTriggerHelper 
{
    public static void preventUpdateDel(RE_SG_CostPriceHistory__c[] records)
    {
        records[0].addError('Modifying/Deleting History Records is NOT Allowed');
    }
}