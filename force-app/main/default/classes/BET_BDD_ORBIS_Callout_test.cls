@istest
public class BET_BDD_ORBIS_Callout_test {
    public static void database(){
        BET_BDD_AuthInfo__c betBddAuthInfo=new BET_BDD_AuthInfo__c();
        betBddAuthInfo.client_Id__c = '3210B2948B571';
        betBddAuthInfo.Client_Secret__c= '3MVG9xqN3LZm';
        betBddAuthInfo.username__c='betedp.integration@shell.com';
        betBddAuthInfo.password__c='Integration@12';
        betBddAuthInfo.endpointSF__c='https://test.salesforce.com/services/oauth2/token';
        
        insert betBddAuthInfo;
    }
    static testmethod void test_OrbisApi() {
        database();
        Test.startTest();       
        BET_BDD_ORBIS_Callout.getOrbisData('shell bri b','','');
        Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis());
        BET_BDD_ORBIS_Callout.getOrbisData('shell bri b','','');
        Test.stopTest();
        
    }
}