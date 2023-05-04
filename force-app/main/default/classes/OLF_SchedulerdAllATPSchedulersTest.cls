/***************************************************************************************************************
Author: Surbhi Srivastava
PBI Number: 1593743 (OLF Precomputation Fix: Add a service to clear old data)
Description: Purpose of the test class is to cover an apex class scheduler named as OLF_ScheduledAllATPScheduler       
Implementation Date: 23-2-2023
****************************************************************************************************************
Version - 1.0 | Last Updated Date - 11-04-2023
****************************************************************************************************************/
@isTest
public class OLF_SchedulerdAllATPSchedulersTest {
    @isTest
    public static void executeTest(){ 
        Datetime sysTime = System.now().addSeconds(5);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('ATP1 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP1Scheduler());
        System.schedule('ATP2 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP2Scheduler());
        System.schedule('ATP3 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP3Scheduler());
        System.schedule('ATP4 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP5Scheduler());
        SchedulableContext sc = null;
        OLF_ScheduledAllATPSchedulers objAllATPScheduler = new OLF_ScheduledAllATPSchedulers();
        objAllATPScheduler.execute(sc);
    }
}