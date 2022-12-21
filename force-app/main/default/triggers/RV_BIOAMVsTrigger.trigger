/*****************************************************************************
@Name:  RV_BIOAMVsTrigger     
@=========================================================================
@Purpose: BIO AMV Trigger
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/04/2018         INITIAL DEVELOPMENT

******************************************************************************/
trigger RV_BIOAMVsTrigger on Bio_AMVs__c (before insert,before update) {
	
    //Re-activated by Gouri Kulakrni for Bio AMV date fix -02.01.2020
    
    if(Trigger.isBefore && Trigger.isInsert){
        RV_BIOAMVsTriggerHelper.onBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        RV_BIOAMVsTriggerHelper.onBeforeUpdate(Trigger.new);
    }
}