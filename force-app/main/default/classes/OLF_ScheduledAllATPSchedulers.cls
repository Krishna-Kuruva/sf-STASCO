/**************************************************************************************************************
Author: Surbhi Srivastava
PBI Number: 1593743 (OLF Precomputation Fix: Add a service to clear old data)
Description: Purpose of this scheduler class is to do the price calculation before the activation of olf(8 A.M.)          
Implementation Date: 19-12-2022
**************************************************************************************************************
Version - 1.0 | Last Updated Date - 27-12-2022
**************************************************************************************************************/

global class OLF_ScheduledAllATPSchedulers implements schedulable
{
    global void execute(SchedulableContext sc)
    {            
        CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger where NextFireTime != null and state != 'DELETED' and CronJobDetail.name like '%ATP%Scheduler%'];            
        for(CronTrigger objCronTrigger : ct){
            System.abortJob(objCronTrigger.id);
        }
        Datetime sysTime = System.now().addSeconds(5);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('ATP1 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP1Scheduler());
        System.schedule('ATP2 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP2Scheduler());
        System.schedule('ATP3 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP3Scheduler());
        System.schedule('ATP4 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP5Scheduler());
    }
}