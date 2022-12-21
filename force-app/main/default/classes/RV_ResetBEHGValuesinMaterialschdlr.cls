global class RV_ResetBEHGValuesinMaterialschdlr implements Schedulable {
    global void execute(SchedulableContext sc) {
      system.debug('-------------inside scheduler class');
      RV_ResetBEHGValuesinMaterialBatch b = new RV_ResetBEHGValuesinMaterialBatch(); 
      database.executebatch(b); 
   }
}