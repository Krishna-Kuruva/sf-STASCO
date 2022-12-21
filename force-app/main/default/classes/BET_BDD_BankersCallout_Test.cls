@isTest
public class BET_BDD_BankersCallout_Test {
    
  static testmethod void test_BankersApi() {
        
        Test.startTest();        
     	BET_BDD_BankersCallout.getBankersData('dsr company','125315','');
        Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis());
        BET_BDD_BankersCallout.getBankersData('dsr company','125315','');
        Test.stopTest();
        
    }
}