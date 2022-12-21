//AdditionalTestCoverage_12Jun2019_Soumyajit starts 
@isTest
public class RV_SnapshotSchedulerTest {

    @isTest
    static void doTest()
    {
        Test.startTest();
        RV_SnapshotScheduler obj = new RV_SnapshotScheduler();
		system.schedule('Test RV_SnapshotScheduler', '0 0 2 * * ?', obj);
        Test.stopTest();
    }
}
//AdditionalTestCoverage_12Jun2019_Soumyajit ends