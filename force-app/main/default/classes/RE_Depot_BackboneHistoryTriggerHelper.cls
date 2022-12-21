/******************************************************************************************************************
className           :    RE_Depot_Pricing_BackboneHistoryTriggerHelper
Description         :    Helper class for Trigger RE_Depot_Pricing_BackboneHistoryTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
Test Class          :    RE_Pricing_BackboneHisTrigTest
*******************************************************************************************************************/
public without sharing class RE_Depot_BackboneHistoryTriggerHelper 
{
    public static void preventUpdateDel(RE_Depot_Pricing_BackboneHistory__c[] records)
    {
        records[0].addError('Modifying/Deleting History Records is NOT Allowed');
    }
}