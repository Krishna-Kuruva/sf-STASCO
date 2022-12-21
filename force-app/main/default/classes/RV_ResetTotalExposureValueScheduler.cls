/*****************************************************************************
@Name:  RV_ResetTotalExposureValueScheduler     
@=========================================================================
@Purpose: Schedule will call batch class to execute SHTDave master reset values                                                                                    
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      1/12/2018         INITIAL DEVELOPMENT

******************************************************************************/
global class RV_ResetTotalExposureValueScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      System.enqueueJob(new RV_ResetTotalExposureValueDailyBatch());
   }
}