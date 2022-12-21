/*****************************************************************************
@Name:  RV_BIOAMVScheduler     
@=========================================================================
@Purpose: scheduling the batch class
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/04/2018         INITIAL DEVELOPMENT

******************************************************************************/
public class RV_BIOAMVScheduler implements Schedulable{
    
	public void execute(SchedulableContext sc) {
        
      System.enqueueJob(new RV_BIOAMVDailyBatch());
   }
}