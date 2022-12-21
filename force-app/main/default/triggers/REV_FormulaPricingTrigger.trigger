trigger REV_FormulaPricingTrigger on Rev_Formula_Price_Staging_Table__c (before insert,after insert,before update,
                                                                         after update) {
	 if(Trigger.isInsert){
        if(Trigger.isAfter){
            REV_FormulaPricingTriggerClass.onafterInsert(Trigger.new);
        } 
    }
}