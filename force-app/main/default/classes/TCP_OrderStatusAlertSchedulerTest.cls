@isTest
public class TCP_OrderStatusAlertSchedulerTest {
	@TestSetup
    static void createTestData() {       
    	List<Account> accList = TCP_TestDataUtilities.createAccounts(1, true);
        TCP_TestDataUtilities.createOrders(4, accList[0]);
       
    }
    
    @isTest
    static  void testScheduledJob() {
        List<Order> ordList = [Select id from Order];
        ordList[0].TCP_Order_Status__c = 'Approved';
        ordList[0].GSAP_Status__c = 'No GSAP Response';
        update ordList;
        
        String cronExp = '0 0 * * * ?';
        Test.startTest();      
        System.schedule('Order Status Alert job 1 Test',cronExp,new TCP_OrderStatusAlertScheduler());        
        Test.stopTest();
        System.assert(true);
    }
}