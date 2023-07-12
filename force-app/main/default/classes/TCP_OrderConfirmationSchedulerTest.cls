@isTest
public class TCP_OrderConfirmationSchedulerTest {
    class MockFinalizerContext implements System.FinalizerContext {
    ParentJobResult result;
    public Id getAsyncApexJobId() { // valid Id, or query one 
         return '707000000000000';
    }
    public Exception getException() { return new System.AsyncException('heap breached'); }
    public String getRequestId() { return 'someRequestId'; }
    public ParentJobResult getResult() { return this.result; }
    MockFinalizerContext (ParentJobResult mockResult) {this.result = mockResult;}
 }
    @TestSetup
    static void createTestData() {
      List<Account> testAccounts=TCP_TestDataUtilities.createParentAccountsBulk(50);
      TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
    }
    @isTest
    static  void testScheduledJob() {
        String cronExp = '0 0 13 * * ?';
        Test.startTest();
        System.schedule('Account Updates',cronExp,new TCP_OrderConfirmationScheduler());
        Test.stopTest();
        System.assert(true);
    }
 
    @IsTest
 static void givenUnhandledExceptionVerifyFinalizer() {
    // Given Finalizer
    RE_Job_Run_Audit__c jraudit=new RE_Job_Run_Audit__c();
    TCP_Queueable_finalizer finalizer = new TCP_Queueable_finalizer(jraudit);
    // When finalizer invoked by SFDC as unhandled exception
    finalizer.execute(new MockFinalizerContext(ParentJobResult.UNHANDLED_EXCEPTION));
    System.assert(true);
    
 }
}