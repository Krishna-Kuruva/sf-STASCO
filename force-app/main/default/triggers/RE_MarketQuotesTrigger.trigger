trigger RE_MarketQuotesTrigger on RE_Market_Quotes__c (before insert, after insert, after update) { 
     public Boolean isEastData = RE_MarketQuotesTriggerHelper.checkCountry(trigger.new);
    if (Trigger.isInsert && Trigger.isBefore){
        if(isEastData){
            RE_MarketQuotesTriggerHelper.onBeforeTriggerHelper(Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
    }   
    if (Trigger.isInsert && Trigger.isAfter){
        if(isEastData){
            if(!RE_MarketQuotesTriggerHelper.checkMTDWTD(Trigger.new)){
                //RE_MarketQuotesTriggerHelper.temperaturegaincalculation(Trigger.new, Trigger.oldMap, Trigger.newMap);
                Boolean runonce = RE_MarketQuotesTriggerHelper.runOnce();
                System.debug('runonce '+ runonce);
                if(runonce){
                    RE_MarketQuotesTriggerHelper.middayoutputgenerate(Trigger.new);      
                }  
                else{
                    RE_MarketQuotesTriggerHelper.onAfterMiddayInsertion(Trigger.new, Trigger.oldMap, Trigger.newMap);   
                }  
            }
            else{
                Boolean runonce = RE_MarketQuotesTriggerHelper.runOnce();
                if(runonce)
                    RE_MarketQuotesTriggerHelper.afterW1M1QuoteInsert(Trigger.new);
            }
        }
    }
    if (Trigger.isUpdate && Trigger.isAfter){
        if(isEastData){
            RE_MarketQuotesTriggerHelper.onAfterMiddayInsertion(Trigger.new, Trigger.oldMap, Trigger.newMap);
            RE_MarketQuotesTriggerHelper.middayoutputgenerate(Trigger.new);
        }
    }  
}