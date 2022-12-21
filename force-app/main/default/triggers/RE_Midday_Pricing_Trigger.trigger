//trigger to update the lastest shell price from midday pricing object in depot based costing for AMV calculation 
trigger RE_Midday_Pricing_Trigger on RE_Midday_Pricing__c (after insert,after update) {
    if((trigger.isInsert || trigger.isUpdate)&& trigger.isAfter)
    {
        RE_Midday_Pricing_TriggerHelper.onAfterShellPriceHelper(Trigger.new,Trigger.newMap);
    }
}