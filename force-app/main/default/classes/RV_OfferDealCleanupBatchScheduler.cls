/**
Discription:- this class runs everyday at 8AM GMT+1.
Created By:-Ashish Soni
**/

global class RV_OfferDealCleanupBatchScheduler implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    RV_OfferDealCleanupBatch b = new RV_OfferDealCleanupBatch(); 
      database.executebatch(b);
    }
}