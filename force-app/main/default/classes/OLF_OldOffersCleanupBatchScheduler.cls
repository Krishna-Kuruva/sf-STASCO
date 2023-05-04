/**************************************************************************************************************
Author: Surbhi Srivastava
PBI Number: 1593743 (OLF Precomputation Fix: Add a service to clear old data)
Description: Purpose of this scheduler class is to call OLF_OldOffersCleanupBatch apex class.            
Implementation Date: 19-12-2022
**************************************************************************************************************
Version - 1.0 | Last Updated Date - 19-12-2022
**************************************************************************************************************/

global class OLF_OldOffersCleanupBatchScheduler implements schedulable
{
    global void execute(SchedulableContext sc)
    {        
            OLF_OldOffersCleanupBatch objOfferCleanupBatch = new OLF_OldOffersCleanupBatch(); 
            database.executebatch(objOfferCleanupBatch);
    }
}