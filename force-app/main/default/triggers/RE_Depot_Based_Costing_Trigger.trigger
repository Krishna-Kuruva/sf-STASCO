trigger RE_Depot_Based_Costing_Trigger on RE_Depot_Based_Costing__c (after insert, after update) { 
    //update Malaysia MOA object
    RE_Depot_Based_Costing_TriggerHelper.onAfterAMVDepoCostOutput(Trigger.New, Trigger.NewMap);
    //update Thailand MOA object 
    RE_Depot_Based_Costing_TriggerHelper.onAfterTHAMVDepoCostOutput(Trigger.New, Trigger.NewMap);
    
}