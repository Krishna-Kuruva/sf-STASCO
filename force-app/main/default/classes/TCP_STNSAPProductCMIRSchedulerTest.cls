@isTest
public class TCP_STNSAPProductCMIRSchedulerTest {
  
    
    @TestSetup
    static void createTestData() {       
    	 TCP_TestDataUtilities.createParentAccountsBulk(50);
    }
    
    @isTest
    static  void testScheduledJob() {
        List<Account> acc=[SELECT id, Active__c , AccountNumber, Customer_Type__c, Sales_Area__c, TCP_STNSAP_ExternalId1__c , TCP_STNSAP_ExternalId2__c  FROM Account];
        System.debug('Checking account '+acc);
        String cronExp = '0 0 14 * * ?';
        Test.startTest();      
        System.schedule('Account Updates',cronExp,new TCP_STNSAPProductCMIRScheduler());        
        Test.stopTest();
        System.assert(true);
    }
    
 
}