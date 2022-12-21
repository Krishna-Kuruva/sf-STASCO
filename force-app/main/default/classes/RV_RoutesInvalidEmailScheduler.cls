global class RV_RoutesInvalidEmailScheduler implements Schedulable{
	global void execute(SchedulableContext sc) {

        RV_RoutesInvalidEmailBatch b = new RV_RoutesInvalidEmailBatch(); 
      	database.executebatch(b); 
    }
}