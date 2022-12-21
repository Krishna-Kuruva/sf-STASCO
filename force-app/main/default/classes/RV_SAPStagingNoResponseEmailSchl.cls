/*****************************************************************************
@Name:  RV_SAPStagingNoResponseEmailSchl      
@=========================================================================
@Purpose: Schedule will call batch class to execute and send email to deal owner if there are no response from gsap till 1 hr from deal creation.                                                                                      
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      20/09/2019         INITIAL DEVELOPMENT

******************************************************************************/
global class RV_SAPStagingNoResponseEmailSchl implements Schedulable{
	global void execute(SchedulableContext sc) {

        RV_SAPStagingNoResponseEmailBatch b = new RV_SAPStagingNoResponseEmailBatch(); 
      	database.executebatch(b); 
   }
}