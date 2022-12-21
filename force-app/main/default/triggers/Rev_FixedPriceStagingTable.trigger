trigger Rev_FixedPriceStagingTable on Fixed_Price_Staging_Table__c (before insert,after insert,before update,after update) { 
	List<TriggerActiveInactive__mdt> triggermdt = [Select id,DeveloperName,MasterLabel,isBeforeInsert__c,isAfterInsert__c,isBeforeUpdate__c,isAfterUpdate__c,isBeforeDelete__c,isAfterDelete__c
                                                  from TriggerActiveInactive__mdt where MasterLabel = 'Fixed_Price_Staging_Table__c']; 
   
	if(triggermdt.get(0).isAfterInsert__c){
		if(Trigger.isInsert && Trigger.isAfter){
            Rev_GSAPStagingTableClass.onafterInsert(Trigger.new);
            /*set<id> recIds = Trigger.newmap.keySet();
            list<id> recids2 = new list<id>();
            recids2.addall(recids);
            FixedPriceDataInsertBatch fdp = new FixedPriceDataInsertBatch( recIds2 );
			Database.executebatch(fdp,100); */
        } 
    }
	
	if(triggermdt.get(0).isAfterUpdate__c){
		if(Trigger.isUpdate && Trigger.isAfter){
            Rev_GSAPStagingTableClass.onafterUpdate(Trigger.new);
        } 
    }
}