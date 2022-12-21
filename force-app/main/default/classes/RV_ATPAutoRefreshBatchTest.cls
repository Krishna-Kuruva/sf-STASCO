/**
 * Created by Dharmendra.Singh2 on 11/12/2020.
 */

@IsTest
public class RV_ATPAutoRefreshBatchTest {
    @TestSetup
    public static void setup(){

        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;

        Account acc = new Account();
        acc = RV_TestHelper.insertAccount(acc);
        acc.Rv_Available_for_OLF__c = true;
        insert acc;


        Customer_Sales_Management__c customerSalesManagement = new Customer_Sales_Management__c();
        customerSalesManagement.Customer__c = acc.Id;
        customerSalesManagement.Plant__c    = insertLoc.Id;

        insert customerSalesManagement;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(customerSalesManagement.Id, yesterday);

        List<ATP__c> atps = new List<ATP__c>();
        ATP__c atp = new ATP__c();
        atp.ATP_Refresh__c = false;
        atp.ATP_Auto_Refresh__c = true;
        atp.ATP_Live__c = 1000;
        atp.Location__c = insertLoc.Id;
        atps.add(atp);

        ATP__c atp2 = new ATP__c();
        atp2.ATP_Refresh__c = false;
        atp2.ATP_Auto_Refresh__c = true;
        atp2.ATP_Live__c = 1000;
        atp2.ATP2_Live__c = 500;
        atp2.Batch1__c = true;
        atp2.Location__c = insertLoc.Id;
        atps.add(atp2);

        ATP__c atp3 = new ATP__c();
        atp3.ATP_Refresh__c = false;
        atp3.ATP_Auto_Refresh__c = true;
        atp3.ATP_Live__c = 1000;
        atp3.ATP3_Live__c = 500;
        atp3.Batch2__c = true;
        atp3.Location__c = insertLoc.Id;
        atps.add(atp3);

        insert atps;
        // System.assertEquals(1, atps.size());

    }
    public static testMethod void ATPAutoRefresh(){
        Test.startTest();
        RV_ATPAutoRefreshSchedule autoRefreshSchedule= new RV_ATPAutoRefreshSchedule();
        String cronExpr = '0 0 23 * * ?';
        String jobId = System.schedule('EmailBatchJob', cronExpr, autoRefreshSchedule);
        autoRefreshSchedule.execute(null);

        Rv_archiveCustSalesMgmtSchedule archiveCustSalesMgmtSchedule= new Rv_archiveCustSalesMgmtSchedule();
        String cronExpr2 = '0 0 23 * * ?';
        String jobId2 = System.schedule('archiveCustSalesSchedule', cronExpr2, archiveCustSalesMgmtSchedule);
        archiveCustSalesMgmtSchedule.execute(null);

        /*
        RV_ATPAutoRefreshBatch autoRefreshBatch = new RV_ATPAutoRefreshBatch();
        Database.executeBatch(autoRefreshBatch);
         */
        Test.stopTest();
    }

}