@isTest
public class Rv_ITdashboardTest {

    @testSetup
    static void testData(){
        //Create IT Alert Custom Setting Data
        List<IT_Alert_Notification_Control__c> alertList = new List<IT_Alert_Notification_Control__c>();
        IT_Alert_Notification_Control__c alert1 = new IT_Alert_Notification_Control__c();
        alert1.Name = 'Price-4EXCHANGE';
        alert1.Last_Notification_Time__c = System.now().addMinutes(-5);
        alert1.Notification_Sent__c = true;
        IT_Alert_Notification_Control__c alert2 = new IT_Alert_Notification_Control__c();
        alert2.Name = 'Price-3NYMEX';
        alert2.Last_Notification_Time__c = System.now().addMinutes(-10);
        alert2.Next_Alert_Date_Time__c = System.now().addMinutes(-10);
        alert2.Notification_Sent__c = true;
        alertList.add(alert1);
        alertList.add(alert2);
        insert alertList;
    }

    @isTest
    static void doTest()
    {
        Rv_ITdashboardController.global_overrideChecks = true;
        Rv_ITdashboardAlert.global_overrideChecks = true;

        list<Revolution_Setting__c> revSet = new list<Revolution_Setting__c>();
        Revolution_Setting__c s1 = new Revolution_Setting__c();
        s1.name='OLF Username';
        s1.Value__c=UserInfo.getUserName();
        revset.add(s1);
        Revolution_Setting__c s2 = new Revolution_Setting__c();
        s2.name='OLF Connection Active';
        s2.Value__c='TRUE';
        revset.add(s2);
        Revolution_Setting__c s3 = new Revolution_Setting__c();
        s3.name= OLF_DashboardApexController.global_ICELGO_thresholdLabel;
        s3.Value__c='200';
        revset.add(s3);
        insert revset;

        Reuters_Quotes__c iceRQ = new Reuters_Quotes__c();
        iceRQ.Quote_Display_Name__c = Rv_ITdashboardAlert.global_ICEquoteName;
        iceRq.Valid_From_Date__c = System.today();
        iceRq.Valid_To_Date__c = System.today();
        iceRq.Price__c= 100;
        iceRq.Quote_Name__c= Rv_ITdashboardAlert.global_ICEquoteName;
        iceRq.CurrencyCode__c ='USD';
        iceRq.Unit_Of_Measure__c = 't';
        insert iceRq;

        Test.startTest();

        List<Revolution_Batch__mdt> batchMdt = Rv_ITdashboardController.getBatchMdt('IT Dashboard Alert every 0 Min','THIS');

        CronTrigger[] ct = [SELECT Id FROM CronTrigger where CronJobDetail.name = 'IT Dashboard Alert every 0 Min' limit 1];
        if(ct.size()==0)
        {
            Rv_ITdashboardController.doBatchAction('IT Dashboard Alert every 0 Min', 'RUN');
            CronTrigger[] ct2 = [SELECT Id FROM CronTrigger where CronJobDetail.name = 'IT Dashboard Alert every 0 Min' limit 1];
            if(ct2.size()>0)
                Rv_ITdashboardController.doBatchAction(ct2[0].id, 'STOP');
        }
        else
            Rv_ITdashboardController.doBatchAction(ct[0].id, 'STOP');

        Rv_ITdashboardController.global_limitQueries = 0;
        Rv_ITdashboardController.getAllData();
        Rv_ITdashboardController.doBatchAction(batchMdt[0].Batch_Name__c, 'RUN');
        Rv_ITdashboardController.doBatchAction('DI Dashboard Snapshot 8 AM', 'RUNADHOC');
        Rv_ITdashboardController.doBatchAction('Daily BSP & Price Trend', 'RUNADHOC');

        ct = [SELECT Id FROM CronTrigger where CronJobDetail.name = 'ATP Daily Refresh Batch' limit 1];
        if(ct.size()==0)
        {
            Rv_ITdashboardController.doBatchAction('ATP Daily Refresh Batch', 'RUN');
            CronTrigger[] ct2 = [SELECT Id FROM CronTrigger where CronJobDetail.name = 'ATP Daily Refresh Batch' limit 1];
            if(ct2.size()>0)
                Rv_ITdashboardController.doBatchAction(ct2[0].id, 'STOP');
        }
        else
            Rv_ITdashboardController.doBatchAction(ct[0].id, 'STOP');
        batchMdt = Rv_ITdashboardController.getBatchMdt('ATP Daily Refresh Batch','THIS');
        Rv_ITdashboardController.doBatchAction(batchMdt[0].Batch_Name__c, 'RUN');

        Rv_ITdashboardController.checkGovenorLimits('Test');

        //327368_Soumyajit_09Aug2019 starts
        ct = [SELECT Id FROM CronTrigger where CronJobDetail.name = 'OLF Scheduled Inactivation' limit 1];
        if(ct.size()==0)
        {
            Rv_ITdashboardController.doBatchAction('OLF Scheduled Inactivation', 'RUN');
            CronTrigger[] ct2 = [SELECT Id FROM CronTrigger where CronJobDetail.name = 'OLF Scheduled Inactivation' limit 1];
            if(ct2.size()>0)
                Rv_ITdashboardController.doBatchAction(ct2[0].id, 'STOP');
        }
        else
            Rv_ITdashboardController.doBatchAction(ct[0].id, 'STOP');
        batchMdt = Rv_ITdashboardController.getBatchMdt('OLF Scheduled Inactivation','THIS');
        //327368_Soumyajit_09Aug2019 ends

        Rv_ITdashboardController.doBatchAction(batchMdt[0].Batch_Name__c, 'RUN');

        Rv_ITdashboardController.startStopAllBatches('StopAll');
        Rv_ITdashboardController.startStopAllBatches('RunAll');
        Rv_ITdashboardController.getAllData();
        Test.stopTest();
    }

    @isTest
    static void testCheckAlertValidity(){
        String startTime = '00:00:00';
        String endTime = '23:59:59';
        String timzoneIdKey = 'Europe/Amsterdam';
        Boolean isAlertValid = Rv_ITdashboardController.checkAlertValidity(startTime, endTime, timzoneIdKey);
        System.assertEquals(false, isAlertValid, 'Alert is not valid!');

        startTime = '23:59:59';
        endTime = '00:00:00';
        Rv_ITdashboardController.checkAlertValidity(startTime, endTime, timzoneIdKey);

        startTime = '';
        endTime = '00:00:00';
    }

    @isTest
    static void testGetIceMonthDetails(){
        String quoteName = 'AGO/IGO';
        Rv_ITdashboardController.getIceMonthDetails(quoteName);
    }

    @isTest
    static void testCheckAndSendAlert(){
        List<Rv_ITdashboardController.errorWrapper> errorList = new List<Rv_ITdashboardController.errorWrapper>();
        Rv_ITdashboardController.errorWrapper errorWraper1 = new Rv_ITdashboardController.errorWrapper();
        errorWraper1.SectionName = 'Price';
        errorWraper1.saveError = true;
        errorWraper1.repeatAlert = true;
        errorWraper1.NotificationSent = false;
        errorWraper1.ErrorMsg = 'Test Error Message';
        errorWraper1.DisplayLabel = '3	NYMEX';
        errorWraper1.CheckTime = DateTime.now();
        errorWraper1.alertIntervalInMin = 1;
        Rv_ITdashboardController.errorWrapper errorWraper2 = new Rv_ITdashboardController.errorWrapper();
        errorWraper2.SectionName = 'Price';
        errorWraper2.saveError = true;
        errorWraper2.repeatAlert = true;
        errorWraper2.NotificationSent = false;
        errorWraper2.ErrorMsg = 'Test Error Message2';
        errorWraper2.DisplayLabel = '4	EXCHANGE';
        errorWraper2.CheckTime = DateTime.now();
        errorWraper2.alertIntervalInMin = 1;
        errorList.add(errorWraper1);
        errorList.add(errorWraper2);
        Rv_ITdashboardController.errorWrapper errorWraper3 = new Rv_ITdashboardController.errorWrapper();
        errorWraper3.SectionName = 'Price';
        errorWraper3.saveError = true;
        errorWraper3.repeatAlert = true;
        errorWraper3.NotificationSent = false;
        errorWraper3.ErrorMsg = 'Test Error Message3';
        errorWraper3.DisplayLabel = '1	BRENT';
        errorWraper3.CheckTime = DateTime.now();
        errorWraper3.alertIntervalInMin = 1;
        errorList.add(errorWraper3);
        Rv_ITdashboardController.checkAndSendAlert(errorList, true);
        errorList.clear();
        Rv_ITdashboardController.errorWrapper errorWraper4 = new Rv_ITdashboardController.errorWrapper();
        errorWraper4.SectionName = 'Price';
        errorWraper4.saveError = true;
        errorWraper4.repeatAlert = true;
        errorWraper4.NotificationSent = true;
        errorWraper4.ErrorMsg = 'Test Error Message';
        errorWraper4.DisplayLabel = '3	NYMEX';
        errorWraper4.CheckTime = DateTime.now();
        errorWraper4.alertIntervalInMin = 0;
        errorList.add(errorWraper4);
        Rv_ITdashboardController.errorWrapper errorWraper5 = new Rv_ITdashboardController.errorWrapper();
        errorWraper5.SectionName = 'Price';
        errorWraper5.saveError = true;
        errorWraper5.repeatAlert = false;
        errorWraper5.NotificationSent = true;
        errorWraper5.ErrorMsg = 'Test Error Message2';
        errorWraper5.DisplayLabel = '4	EXCHANGE';
        errorWraper5.CheckTime = DateTime.now();
        errorWraper5.alertIntervalInMin = 1;
        errorList.add(errorWraper5);
        Rv_ITdashboardController.checkAndSendAlert(errorList, true);
    }

    @isTest
    static void testSaveError(){
        List<Rv_ITdashboardController.errorWrapper> errorList = new List<Rv_ITdashboardController.errorWrapper>();
        Rv_ITdashboardController.errorWrapper errorWraper1 = new Rv_ITdashboardController.errorWrapper();
        errorWraper1.SectionName = 'Price';
        errorWraper1.saveError = true;
        errorWraper1.repeatAlert = true;
        errorWraper1.NotificationSent = false;
        errorWraper1.ErrorMsg = 'Test Error Message';
        errorWraper1.DisplayLabel = '3	NYMEX';
        errorWraper1.CheckTime = DateTime.now();
        errorWraper1.alertIntervalInMin = 1;
        Rv_ITdashboardController.errorWrapper errorWraper2 = new Rv_ITdashboardController.errorWrapper();
        errorWraper2.SectionName = 'Price';
        errorWraper2.saveError = true;
        errorWraper2.repeatAlert = false;
        errorWraper2.NotificationSent = false;
        errorWraper2.ErrorMsg = 'Test Error Message2';
        errorWraper2.DisplayLabel = '4	EXCHANGE';
        errorWraper2.CheckTime = DateTime.now();
        errorWraper2.alertIntervalInMin = 1;
        errorList.add(errorWraper1);
        errorList.add(errorWraper2);
        Rv_ITdashboardController.saveError(errorList);
    }
}
