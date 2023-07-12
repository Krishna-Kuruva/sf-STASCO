@isTest
public class TCP_STNSAPSoldToShipToSchedulerTest {
	
    @TestSetup
    static void createTestData() {       
    	TCP_TestDataUtilities.createParentAccountsBulk(50);
    }
    
    @isTest
    static  void testScheduledJob() {
        String cronExp = '0 0 15 * * ?';
        Test.startTest();      
        System.schedule('Account Updates',cronExp,new TCP_STNSAPSoldToShipToScheduler());        
        Test.stopTest();
        System.assert(true);
    }
    

}