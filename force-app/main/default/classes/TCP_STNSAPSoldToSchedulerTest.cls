@isTest
public class TCP_STNSAPSoldToSchedulerTest {
	
    
    @TestSetup
    static void createTestData() {       
    	TCP_TestDataUtilities.createParentAccountsBulk(45);
    }
    
    @isTest
    static  void testScheduledJob() {
        String cronExp = '0 0 15 * * ?';
        Test.startTest();      
        System.schedule('Account Updates',cronExp,new TCP_STNSAPSoldToScheduler());        
        Test.stopTest();
        System.assert(true);
    }
    
    
}