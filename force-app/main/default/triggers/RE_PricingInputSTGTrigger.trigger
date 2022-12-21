trigger RE_PricingInputSTGTrigger on RE_Pricing_Input_STG__c (after insert) {
    
    if(Trigger.isAfter && Trigger.isinsert){      
        RE_PricingInputSTGTriggerHelper.processingPricingInputStgData(Trigger.new);       
    }
}