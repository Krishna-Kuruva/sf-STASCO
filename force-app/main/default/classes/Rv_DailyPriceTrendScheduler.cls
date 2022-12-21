global class Rv_DailyPriceTrendScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        System.enqueueJob(new Rv_DailyPriceTrendQueueable());
    }

}