@isTest
private class RV_RevolutionDailyBatchTest {

    @testSetup 
    static void setup() {
        List<SHT_Dave_Master__c> shtDaveMasterInsertlst = new List<SHT_Dave_Master__c>();
        List<SHT_Dave__c> shtDaveInsertlst = new List<SHT_Dave__c>();
        List<ATP__c> atplst = new List<ATP__c>();
        
        Location__c loc = new Location__c();
        loc.Name = 'Ludwigshafen depot';
        loc.Plant_Code__c = 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        
        insert loc;
        SHT_Dave_Master__c shtMasterDaveAGOInsert = new SHT_Dave_Master__c();
        shtMasterDaveAGOInsert.Name = Label.AGO_B7;
        shtMasterDaveAGOInsert.Hedged__c = 1.2;
        shtMasterDaveAGOInsert.Total_Exposure_Factors__c = 1.4;
        shtDaveMasterInsertlst.add(shtMasterDaveAGOInsert);
            
        SHT_Dave_Master__c shtMasterDaveIGOInsert = new SHT_Dave_Master__c();
        shtMasterDaveIGOInsert.Name = Label.AGO_B7;
        shtMasterDaveIGOInsert.Hedged__c = 1.2;
        shtMasterDaveIGOInsert.Total_Exposure_Factors__c = 1.4;
        shtDaveMasterInsertlst.add(shtMasterDaveIGOInsert);
        
        SHT_Dave_Master__c shtMasterDaveULGInsert = new SHT_Dave_Master__c();
        shtMasterDaveULGInsert.Name = Label.AGO_B7;
        shtMasterDaveULGInsert.Hedged__c = 1.2;
        shtMasterDaveULGInsert.Total_Exposure_Factors__c = 1.4;
        shtDaveMasterInsertlst.add(shtMasterDaveULGInsert);
        insert shtDaveMasterInsertlst;
        
        SHT_Dave__c shtDaveInsert = new SHT_Dave__c();
        shtDaveInsert.Product_Name__c = Label.AGO_B7;
        shtDaveInsert.Exposure_Factor__c = 100.00;
        shtDaveInsert.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsert);
        
        SHT_Dave__c shtDaveInsertIGO = new SHT_Dave__c();
        shtDaveInsertIGO.Product_Name__c = Label.IGO_50ppm;
        shtDaveInsertIGO.Exposure_Factor__c = 0.00;
        shtDaveInsertIGO.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertIGO);
        
        SHT_Dave__c shtDaveInsertm98 = new SHT_Dave__c();
        shtDaveInsertm98.Product_Name__c = Label.MOGAS_98;
        shtDaveInsertm98.Exposure_Factor__c = 100.00;
        shtDaveInsertm98.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertm98);
        
        SHT_Dave__c shtDaveInsertME10 = new SHT_Dave__c();
        shtDaveInsertME10.Product_Name__c = Label.MOGAS_E10;
        shtDaveInsertME10.Exposure_Factor__c = 0.00;
        shtDaveInsertME10.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertME10);
        
        SHT_Dave__c shtDaveInsertUGL95 = new SHT_Dave__c();
        shtDaveInsertUGL95.Product_Name__c = Label.UGL95_E5;
        shtDaveInsertUGL95.Exposure_Factor__c = 0.00;
        shtDaveInsertUGL95.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertUGL95);
        
        ATP__c atpDataInsertAGO = new ATP__c();
        atpDataInsertAGO.Location__c = loc.Id;
        atpDataInsertAGO.Grade_Level2__c = Label.AGO_B7;
        atpDataInsertAGO.ATP1__c = 1000;
        atpDataInsertAGO.ATP2__c = 1000;
        atpDataInsertAGO.ATP3__c = 1000;
        atpDataInsertAGO.ATP_Live__c = 1000;
        atpDataInsertAGO.ATP2_Live__c  = 1000;
        atpDataInsertAGO.ATP3_Live__c  = 1000;   
        atpDataInsertAGO.Sales_8_30_17_30__c = 0;
        atpDataInsertAGO.Sales_15_28__c = 0;
        atpDataInsertAGO.Sales_29_61__c = 0;
        atpDataInsertAGO.Lifting_Validity_From1__c = Date.Today();
        atpDataInsertAGO.ATP_Auto_Refresh__c = true;
        atplst.add(atpDataInsertAGO);
        
        
        ATP__c atpDataInsertIGO = new ATP__c();
        atpDataInsertIGO.Location__c = loc.Id;
        atpDataInsertIGO.Grade_Level2__c = Label.IGO_50ppm;
        atpDataInsertIGO.ATP1__c = 1000;
        atpDataInsertIGO.ATP2__c = 1000;
        atpDataInsertIGO.ATP3__c = 1000;
        atpDataInsertIGO.ATP_Live__c = 1000;
        atpDataInsertIGO.ATP2_Live__c  = 1000;
        atpDataInsertIGO.ATP3_Live__c  = 1000;   
        atpDataInsertIGO.Sales_8_30_17_30__c = 0;
        atpDataInsertIGO.Sales_15_28__c = 0;
        atpDataInsertIGO.Sales_29_61__c = 0;
        atpDataInsertIGO.Lifting_Validity_From2__c = Date.Today();
        atpDataInsertIGO.Batch1__c = true;
        atplst.add(atpDataInsertIGO);
        
        ATP__c atpDataInsertbatch2 = new ATP__c();
        atpDataInsertbatch2.Location__c = loc.Id;
        atpDataInsertbatch2.Grade_Level2__c = Label.IGO_50ppm;
        atpDataInsertbatch2.ATP1__c = 1000;
        atpDataInsertbatch2.ATP2__c = 1000;
        atpDataInsertbatch2.ATP3__c = 1000;
        atpDataInsertbatch2.ATP_Live__c = 1000;
        atpDataInsertbatch2.ATP2_Live__c  = 1000;
        atpDataInsertbatch2.ATP3_Live__c  = 1000;   
        atpDataInsertbatch2.Sales_8_30_17_30__c = 0;
        atpDataInsertbatch2.Sales_15_28__c = 0;
        atpDataInsertbatch2.Sales_29_61__c = 0;
        atpDataInsertbatch2.Lifting_Validity_From2__c = Date.Today();
        atpDataInsertbatch2.Batch2__c = true;
        atplst.add(atpDataInsertbatch2);
        insert atplst;
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'ADAM OMMERT MINERALOELHANDEL';
        acc.Customer_Type__c = 'Ship To';
        acc.Sold_To_Number__c = '11175980';
        acc.Has_MRC__c = true;
        acc.RecordTypeId = RecordTypeIdAccount;
        
        insert acc;
        
        SHT__c insertSHTRec = new SHT__c();
        insertSHTRec.Location__c = loc.Id;
        insertSHTRec.Status__c = 'Saved';
        insertSHTRec.Contract_Start__c = System.today();
        insertSHTRec.Contract_End_Date__c = System.today().addDays(14);
        insertSHTRec.Customer__c = acc.Id;
        insertSHTRec.Tranche__c = 'ATP1';
        insertSHTRec.Volume_CBM__c = 100;
        insertSHTRec.Status__c = 'Saved';
        //insertSHTRec.CreatedDate = System.Today().addDays(-1);
        insertSHTRec.Sales_Type__c = 'Obam Sales';
        insertSHTRec.Product_Category__c = 'AGO B7';
        insertSHTRec.Select__c = true;
        
        insert insertSHTRec;
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(insertSHTRec.Id, yesterday);
    }

    static testmethod void testExposureValueDailyBatch() {        
        Test.startTest();
        RV_ResetTotalExposureValueDailyBatch batchObj = new RV_ResetTotalExposureValueDailyBatch();
        System.enqueueJob(new RV_ResetTotalExposureValueDailyBatch());
        Test.stopTest();
    }
    static testmethod void testAutoRefreshDailyBatch() {        
        Test.startTest();
        RV_ATPAutoRefreshDailyBatch batchObj1 = new RV_ATPAutoRefreshDailyBatch();
        System.enqueueJob(new RV_ATPAutoRefreshDailyBatch());
        Test.stopTest();
    }
    static testmethod void testRV_SHTAutoRefreshBatch() {        
        Test.startTest();
        RV_SHTAutoRefreshBatch batchObj1 = new RV_SHTAutoRefreshBatch();
        Id batchId1 = Database.executeBatch(batchObj1);
        Test.stopTest();
    }
    //Test method for Scheduler
    @isTest static void testMethodforATPScheduler() {
        Test.StartTest();
        RV_ATPAutoRefreshSchedule atpScheduler = new RV_ATPAutoRefreshSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('ATP Scheduler', sch, atpScheduler); 
        System.enqueueJob(new RV_ATPAutoRefreshDailyBatch());
        Test.stopTest();
    
    }
    @isTest static void testMethodforSHTDaveScheduler() {
        Test.StartTest();
        RV_ResetTotalExposureValueScheduler shtdaveScheduler = new RV_ResetTotalExposureValueScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('SHT Dave Scheduler', sch, shtdaveScheduler); 
        System.enqueueJob(new RV_ResetTotalExposureValueDailyBatch());
        Test.stopTest();
    }
    
}