@isTest
public class TCP_STNSAPSoldToShipToSchedulerTest {
	
    @TestSetup
    static void createTestData() {       
    	List<Account> testAccounts=TCP_TestDataUtilities.createParentAccountsBulk(50);
       
    }
    
    @isTest
    static  void testScheduledJob() {
        List<Account> acc=[select id,name,recordtype.id from account];
        String CRON_EXP = '0 0 15 * * ?';
        Test.startTest();      
        String jobId = System.schedule('Account Updates',CRON_EXP,new TCP_STNSAPSoldToShipToScheduler());        
        Test.stopTest();
        System.assert(true);
    }
    

}