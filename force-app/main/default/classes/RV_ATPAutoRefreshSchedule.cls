/*****************************************************************************
@Name:  RV_ATPAutoRefreshSchedule     
@=========================================================================
@Purpose: Schedule will call batch class to execute ATP auto refresh                                                                                    
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/18/2017         INITIAL DEVELOPMENT

******************************************************************************/
global class RV_ATPAutoRefreshSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
       System.enqueueJob(new RV_ATPAutoRefreshDailyBatch());
       System.enqueueJob(new Rv_archiveCustSalesMgmtQueueable());
       System.enqueueJob(new RV_SHTDailyUpdateQueueable());	//Fix_199964_27Nov2019_Soumyajit
   }
}