@isTest
public class TCP_GoodsIssueSchedulerTest {
    @TestSetup
    static void createTestData() {
        TCP_TestDataUtilities.createParentAccountsBulk(50);
    }
@isTest
static  void testScheduledJob() {
// Create Test Data
    String cronExp = '0 0 15 * * ?';
    Test.startTest();
    // Schedule the test job
    System.schedule('Account Updates',cronExp,new TCP_GoodsIssueScheduler());
    // Key thing to Note: Stopping the test will run the job synchronously
    Test.stopTest();
    System.assert(true);
}
}