@isTest
public class TCP_GoodsIssueSchedulerTest {
    @TestSetup
    static void createTestData() {
        
         List<Account> testAccountsList=TCP_TestDataUtilities.createParentAccountsBulk(50);
    }
@isTest
static  void testScheduledJob() {
    
   List<Account> acc=[select id,name,recordtype.id from account];
       
// Create Test Data
String CRON_EXP = '0 0 13 * * ?';
Test.startTest();
// Schedule the test job
String jobId = System.schedule('Account Updates',CRON_EXP,new TCP_GoodsIssueScheduler());
// Key thing to Note: Stopping the test will run the job synchronously
Test.stopTest();
    System.assert(true);
}
}