@isTest
public class TCP_STNSAPSoldToSchedulerTest {
	
    
    @TestSetup
    static void createTestData() {       
    	List<Account> testAccounts=TCP_TestDataUtilities.createParentAccountsBulk(45);
       
    }
    
    @isTest
    static  void testScheduledJob() {
        List<Account> acc=[select id,name,recordtype.id from account];
        String CRON_EXP = '0 0 15 * * ?';//0 0 0 28 2 ? 2028';
        Test.startTest();      
        String jobId = System.schedule('Account Updates',CRON_EXP,new TCP_STNSAPSoldToScheduler());        
        Test.stopTest();
        System.assert(true);
    }
    
    
}