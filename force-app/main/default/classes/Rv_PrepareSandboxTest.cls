@isTest
class Rv_PrepareSandboxTest {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 29-Apr-2020
	Details	: Post Refresh controller test class
	*/
    @isTest
    static void testSandboxPrep() {

        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Olf_Customer_Email__c = 'test@abc.com';
        accInsert.Rv_Available_for_OLF__c = true;
        accInsert.Rv_Olf_EmailID__c = 'test1@abc.com;test2@abc.com;';
        insert accInsert;
        
        System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        
        Test.startTest();

        Test.testSandboxPostCopyScript(
            new Rv_PrepareSandbox(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        List<String> runType = new List<String>{'GsapUpdate'
                                                ,'ITalertEmailUpdate'
                                                ,'OlfEmailUpdate'
                                                ,'OlfConnInsert'
                                                ,'OlfAccEmailUpdate'};
        Rv_PrepareSandbox.pageIniitWrapper pw = Rv_PrepareSandbox.initPage();
        List<String> runResult = Rv_PrepareSandbox.RvGermanyRunFromPage(runType, true, null, null, null);
        Test.stopTest();
    }
}