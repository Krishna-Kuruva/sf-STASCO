@isTest
public class BET_BDD_GTMI_Callout_Test {
    
    static testmethod void test_GTMIApi() {
        
        Test.startTest();        
        BET_BDD_GTMI_Callout.getGTMIData('dsr company','',0,'');
        Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis());
        BET_BDD_GTMI_Callout.getGTMIData('dsr company','',0,'');
        Test.stopTest();
        
    }
}