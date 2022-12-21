global class RV_DIDashBoardProductDiffScheduler implements Schedulable {

   global void execute(SchedulableContext SC) {
      RV_DIDashboardProductDiff_Snapshot M = new RV_DIDashboardProductDiff_Snapshot(); 
       database.executebatch(m);
   } 
}