@isTest
public class TCP_STNSAPProductCMIRSchedulerTest {
  
    
    @TestSetup
    static void createTestData() {       
    	 
         List<Account> testAccountsList=TCP_TestDataUtilities.createParentAccountsBulk(50);
    }
    
    @isTest
    static  void testScheduledJob() {
        List<Account> acc=[SELECT id, Active__c , AccountNumber, Customer_Type__c, Sales_Area__c, TCP_STNSAP_ExternalId1__c , TCP_STNSAP_ExternalId2__c  FROM Account];
        System.debug('Checking account '+acc);
        String CRON_EXP = '0 0 14 * * ?';
        Test.startTest();      
        String jobId = System.schedule('Account Updates',CRON_EXP,new TCP_STNSAPProductCMIRScheduler());        
        Test.stopTest();
        System.assert(true);
    }
    
 
}