/*****************************************************************************
@Name:  RV_SHTDaveTriggerHelper     
@=========================================================================
@Purpose: Trigger  will execute when we are inserting data in SHT Dave for transaction type Hedge
         
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/14/2017         INITIAL DEVELOPMENT

******************************************************************************/
trigger RV_SHTDave on SHT_Dave__c (before insert,after insert) {
	
    if(Trigger.isInsert && Trigger.isBefore){
        //System.debug('^^^^^^^^^^'+Trigger.new);
        RV_SHTDaveTriggerHelper.onBeforeInsert(Trigger.new);
    }
   
    
}