@isTest
public class RV_ATPTriggerHelperTest {
    static testMethod void atpTriggerHelperMethd(){
        //Insert Location
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        
        
        
        //Insert dashbaord
        String revdashboardRT = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
		Revolution_Dashboard__c revDashboard = new Revolution_Dashboard__c();
        revDashboard.Plant_Name__c = insertLoc.Id;
        revDashboard.RecordTypeId = revdashboardRT;
        revDashboard.Sales_Channel__c = 'DE01';
        revDashboard.UniqueKey__c = 'DE01'+revDashboard.Plant_Name__c+'10';
        revDashboard.MOT__c = 'Truck';
        revDashboard.BSP_IGO__c = 34;
        revDashboard.PSP_IGO__c = 45;
        revDashboard.OTM_IGO__c = 55;
        revDashboard.ATP1_Live_IGO__c = 1000;
        revDashboard.ATP2_Live_IGO__c = 1000;
        revDashboard.ATP3_Live_IGO__c = 1000;
        
        revDashboard.BSP_AGO__c = 40;
        revDashboard.PSP_AGO__c = 43;
        revDashboard.OTM_AGO__c = 58;
        revDashboard.ATP1_Live_AGO__c = 1003;
        revDashboard.ATP2_Live_AGO__c = 1000;
        revDashboard.ATP3_Live_AGO__c = 1000;
        
        revDashboard.BSP_MOGAS__c = 37;
        revDashboard.PSP_MOGAS__c = 49;
        revDashboard.OTM_MOGAS__c = 56;
         
        revDashboard.ATP1_Live_MOGAS__c = 1004;
        revDashboard.ATP2_Live_AGO__c = 1000;
        revDashboard.ATP3_Live_AGO__c = 1000;
        insert revDashboard;   
        
        //Insert ATP
        RV_ATPTriggerHelper.recursiveDashboard=true;
        List<ATP__c> atpList = new List<ATP__c>(); // added by Dharmendra
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        atpList.add(atpInsert);

        ATP__c atpInsert2 = new ATP__c();
        atpInsert2  = RV_TestHelper.insertATPRecord(atpInsert2,insertLoc);
        atpInsert2.ATP_Refresh__c = true;
        atpList.add(atpInsert2);

        ATP__c atpInsert3 = new ATP__c();
        atpInsert3  = RV_TestHelper.insertATPRecord(atpInsert3,insertLoc);
        atpInsert3.ATP_Refresh__c = true;
        atpList.add(atpInsert3);

        ATP__c atpInsert4 = new ATP__c();
        atpInsert4  = RV_TestHelper.insertATPRecord(atpInsert4,insertLoc);
        atpInsert4.ATP_Refresh__c = true;
        atpList.add(atpInsert4);

        ATP__c atpInsert5   = new ATP__c();
        atpInsert5          = RV_TestHelper.insertATPRecord(atpInsert5,insertLoc);
        atpInsert5.ATP_Refresh__c = true;
        atpList.add(atpInsert5);
        
        ATP__c atpInsertIgo = new ATP__c();
        atpInsertIgo  = RV_TestHelper.insertATPRecord(atpInsertIgo,insertLoc);
        atpInsertIgo.Grade_Level2__c='IGO 50ppm';
        atpList.add(atpInsertIgo); // added by Dharmendra
        
        //insert atpInsert;
        ATP__c atpInsertUlg = new ATP__c();
        atpInsertUlg=RV_TestHelper.insertATPRecordULG(atpInsertUlg,insertLoc);
        atpList.add(atpInsertUlg);

        atpList[2].ATP2_Live__c = null;
        atpList[2].ATP2__c = null;
        atpList[2].Reset_2__c = true;
        atpList[2].Reset_3__c = true;

        atpList[4].ATP_Refresh__c = true;
        atpList[4].ATP2_Live__c = null;
        atpList[4].ATP2__c = null;
        atpList[4].ATP3_Live__c = null;
        atpList[4].ATP3__c      = null;
        atpList[4].Reset_2__c = true;
        atpList[4].Reset_3__c = true;

        insert atpList;

        atpList[3].ATP2_Live__c = null;
        atpList[3].ATP2__c      = null;
        atpList[3].ATP3_Live__c = null;
        atpList[3].ATP3__c      = null;
        atpList[3].ATP_Refresh__c = true;
        atpList[3].Reset_2__c   = true;
        atpList[3].Reset_3__c   = true;

        update atpList;
       /*
        insert atpInsert;
        insert atpInsertUlg;
        insert atpInsertIgo;
        */

        //AdditionalTestCoverage_12Jun2019_Soumyajit starts 
        Location__c insertLocNull = new Location__c();
        insertLocNull = RV_TestHelper.insertLocation(insertLocNull);
        insertLocNull.name='Test Loc Null';
        insertLocNull.Plant_Code__c = 'D9999';
        insert insertLocNull;
        
        ATP__c atpInsertNull = new ATP__c();
        atpInsertNull=RV_TestHelper.insertATPRecordULG(atpInsertNull,insertLocNull);
        atpInsertNull.ATP_Live__c = 100;
        atpInsertNull.ATP2_Live__c = 100;
        atpInsertNull.ATP3_Live__c = 100;
        insert atpInsertNull;
        
        Revolution_Dashboard__c revDashboardNull = new Revolution_Dashboard__c();
        revDashboardNull.Plant_Name__c = insertLocNull.Id;
        revDashboardNull.RecordTypeId = revdashboardRT;
        revDashboardNull.Sales_Channel__c = 'DE01';
        revDashboardNull.UniqueKey__c = 'DE01'+revDashboardNull.Plant_Name__c+'10';
        revDashboardNull.MOT__c = 'Truck';
        insert revDashboardNull;
        
        //AdditionalTestCoverage_12Jun2019_Soumyajit ends 
        
        test.startTest();
        
        atpInsert.ATP_Live__c = 1100;
        atpInsert.ATP2_Live__c = 1200;
        atpInsert.ATP3_Live__c = 1300;
        
        atpInsertUlg.ATP_Live__c = 1100;
        atpInsertUlg.ATP2_Live__c = 1200;
        atpInsertUlg.ATP3_Live__c = 1300;
        
        atpInsertIgo.ATP_Live__c = 1100;
        atpInsertIgo.ATP2_Live__c = 1200;
        atpInsertIgo.ATP3_Live__c = 1300;
        
        update atpInsert;
        update atpInsertIgo;
        update atpInsertUlg;
        atpInsertIgo.ATP1__c = 1200;
        update atpInsertIgo;
        test.stopTest();
        
        
    }

}