public without sharing class RE_MY_CostPriceHistoryTriggerHelper {

    public static void preventUpdateDel(RE_MY_CostPriceHistory__c[] records)
    {
        records[0].addError('Modifying/Deleting History Records is NOT Allowed');
    }
}