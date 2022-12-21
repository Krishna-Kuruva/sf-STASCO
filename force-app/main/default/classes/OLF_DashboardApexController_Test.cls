@isTest
public class OLF_DashboardApexController_Test {
    /*
    Version : 0.0
    Author  : Soumyajit
    Date    : 03-May-2019
    Details : Test Class for OLF_DashboardApexController
    */
    @isTest
    public static void doTest()
    {
        Location__c  loc = new Location__c(name='TestLocation');
        insert loc;       
        Id revRcdTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        Account  acc1 = new Account(name='TestAccount1',Customer_Type__c = 'Sold To',RecordTypeId = revRcdTypId, Rv_Available_for_OLF__c = true, Rv_Credit_Limit__c=100, Rv_Credit_Available__c=500);
        insert acc1;
        Account  acc2 = new Account(name='TestAccount2',RecordTypeId = revRcdTypId, Rv_Available_for_OLF__c = true);
        insert acc2;        
        Product_Catalogue__c mat = new Product_Catalogue__c(name='TestProduct',Commodity_Grade_L2__c='AGO B0',Level_1__c='AGO',Level_0__c='Gasoil');
        insert mat;
        
        MRC__c  mc = new MRC__c(name='TestMRC',Sold_To__c = acc1.id, Plant__c = loc.id, Product__c=mat.id);
        insert mc;
        
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
        s3.name='Lifting Window 1';s3.Value__c='ATP1';s3.Start_Day__c = 1;s3.End_Day__c = 14;s3.Active__c = true;
        revset.add(s3);
        Revolution_Setting__c s4 = new Revolution_Setting__c();
        s4.name='Lifting Window 2';s4.Value__c='ATP2';s4.Start_Day__c = 15;s4.End_Day__c = 29;s4.Active__c = true;
        revset.add(s4);
        Revolution_Setting__c s5 = new Revolution_Setting__c();
        s5.name='Lifting Window 3';s5.Value__c='ATP3';s5.Start_Day__c = 20;s5.End_Day__c = 45;s5.Active__c = true;
        revset.add(s5);
        Revolution_Setting__c s6 = new Revolution_Setting__c();
        s6.name='Lifting Window 4';s6.Value__c='ATP4';s6.Start_Day__c = 46;s6.End_Day__c = 60;s6.Active__c = true;
        revset.add(s6);
        insert revset;
        
        OLF_DashboardApexController.global_overrideChecks = true;       
        //UserActivateButton_Soumyajit_01Aug2019 starts
        Online_User_API_Audit__c onlUsrApiAdt= new Online_User_API_Audit__c(API_Request_Time__c=system.now());
        insert onlUsrApiAdt;
        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];
        //UserActivateButton_Soumyajit_01Aug2019 ends
        SHT__c shtInsertATP1 = new SHT__c();
        shtInsertATP1 = RV_TestHelper.insertSHT(shtInsertATP1,loc,acc1,mc);
        shtInsertATP1.IsATPVolumeReduced__c = true;
        shtInsertATP1.IsVolumeHedged__c  = true;
        shtInsertATP1.Contract_Start__c = System.today().addDays(1);
        shtInsertATP1.Contract_End_Date__c = System.today().addDays(15);
        shtInsertATP1.Tranche__c = 'ATP1';
        shtInsertATP1.SAP_Contract_Number__c = '3231232';
        shtInsertATP1.OLF_Deal_Number__c = '23232222';
        insert shtInsertATP1;       
        SAP_Staging__c objSAP = new SAP_Staging__c();
        objSAP.Sent_to_OLF__c = 'Failed';
        objSAP.Deal_Created_Date__c = System.now();
        objSAP.SHTId__c = shtInsertATP1.Id;
        insert objSAP;       
        Test.startTest();
        OLF_DashboardApexController.setThresholdPrice('100');	//ICELimit_Soumyajit_27Apr2020
        OLF_DashboardApexController.setSettingsCalled = false;
        OLF_DashboardApexController.setThresholdPrice('200');	//ICELimit_Soumyajit_27Apr2020
        OLF_DashboardApexController.OLFInitWrap ofw= OLF_DashboardApexController.getAllDetails();
        OLF_DashboardApexController.OLFAccountMRCWrap oamw1 = OLF_DashboardApexController.getAccountData('','ALL');
        OLF_DashboardApexController.OLFAccountMRCWrap oamw2 = OLF_DashboardApexController.getAccountData('','');
        OLF_DashboardApexController.OLFAccountMRCWrap oamw3 = OLF_DashboardApexController.getAccountData('TestAccount1','THIS');
        OLF_DashboardApexController.OLFAccountMRCWrap oamw4 = OLF_DashboardApexController.getAccountData('TestAccount2','THIS');
        List<OLF_DashboardApexController.MRCWrap> mw1= OLF_DashboardApexController.getMRCData('TestAccount1','ALL','ALL','ALL');
        List<OLF_DashboardApexController.MRCWrap> mw2= OLF_DashboardApexController.getMRCData('TestAccount1','TestProduct','ALL','THIS');
        List<OLF_DashboardApexController.MRCWrap> mw3= OLF_DashboardApexController.getMRCData('TestAccount1','ALL','TestLocation','THIS');
        List<OLF_DashboardApexController.MRCWrap> mw4= OLF_DashboardApexController.getMRCData('TestAccount1','TestProduct','TestLocation','THIS');
        List<OLF_DashboardApexController.MRCWrap> mw5= OLF_DashboardApexController.getMRCData('TestAccount1','','','');
        OLF_DashboardApexController.userActivateInactivateFromScreen('STOP');//UserActivateButton_Soumyajit_01Aug2019
        OLF_DashboardApexController.userActivateInactivateFromScreen('START');//UserActivateButton_Soumyajit_01Aug2019
        OLF_DashboardApexController.checkUserPermission('RV_OnlineSalesManagement');
        OLF_DashboardApexController.getNextFireTimeOLFSInactivateSch();
        OLF_DashboardApexController.getOlfStagingRecordCount(objSAP.Deal_Created_Date__c,objSAP.Deal_Created_Date__c);
        OLF_DashboardApexController.retryOlfStagingRecords(objSAP.Deal_Created_Date__c,objSAP.Deal_Created_Date__c);       
        List<Revolution_Setting__c> objRVSettings = [SELECT ID,Name,Active__c,Start_Day__c,End_Day__c FROM Revolution_Setting__c WHERE Name LIKE 'Lifting Window%'];
        String trancheSetting =  '[{"endDay":14,"isActive":false,"settingID":"' + objRVSettings[0].Id + '","settingName":"Lifting Window 1","settingValue":"ATP1","startDay":1,"startDate":"2022-08-23T06:14:32.166Z","endDate":"2022-09-05T06:14:32.166Z"},{"endDay":28,"isActive":false,"settingID":"' + objRVSettings[1].Id + '","settingName":"Lifting Window 2","settingValue":"ATP2","startDay":15,"startDate":"2022-09-06T06:14:32.166Z","endDate":"2022-09-19T06:14:32.166Z"},{"endDay":45,"isActive":false,"settingID":"' + objRVSettings[2].Id + '","settingName":"Lifting Window 3","settingValue":"ATP3","startDay":29,"startDate":"2022-09-20T06:14:32.166Z","endDate":"2022-10-06T06:14:32.166Z"},{"endDay":60,"isActive":false,"settingID":"' + objRVSettings[3].Id + '","settingName":"Lifting Window 4","settingValue":"ATP4","startDay":46,"startDate":"2022-10-07T06:14:32.166Z","endDate":"2022-10-21T06:14:32.166Z"}]';
        OLF_DashboardApexController.updateTrancheSetting(trancheSetting);
        OLF_DashboardApexController.OLFAutoInactivationScheduleJob(system.now());
        Test.stopTest();
    }
}