trigger RE_ProductTrigger on RE_Product__c (after update) {
	if (Trigger.isUpdate && Trigger.isAfter){
         RE_ProductTriggerHelper.onAfterMC0Dipupdate(Trigger.new);
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        RE_ProductTriggerHelper.updateTHDepoPricing([SELECT Id,RE_TH_Oil_Loss_Percent__c,TH_15_to_30_factor__c,RecordtypeId,Recordtype.Name,RE_TH_TP_PremiumHCV__c,RE_TH_TP_PremiumHCV2__c,TH_TP_PremiumHCV2_UNIT__c,RE_TH_TP_Premium__c,TP_Premium_Unit__c,RE_TH_HCV_Quote1_Percent__c,RE_TH_HCV_Quote2_Percent__c  from RE_Product__c where Id IN: Trigger.New]);
    }
}