@isTest
public class TCP_OrderStatusAlertSchedulerTest {
	@TestSetup
    static void createTestData() {       
    	List<Account> accList = TCP_TestDataUtilities.createAccounts(1, true);
        List<Order> ordList = TCP_TestDataUtilities.createOrders(4, accList[0]);
       
    }
    
    @isTest
    static  void testScheduledJob() {
        List<Account> accList = [Select id from Account];
        List<Order> ordList = [Select id from Order];
        ordList[0].TCP_Order_Status__c = 'Approved';
        ordList[0].GSAP_Status__c = 'No GSAP Response';
        update ordList;
        
        String CRON_EXP = '0 0 * * * ?';
        Test.startTest();      
        String jobId = System.schedule('Order Status Alert job 1 Test',CRON_EXP,new TCP_OrderStatusAlertScheduler());        
        Test.stopTest();
        System.assert(true);
    }
}