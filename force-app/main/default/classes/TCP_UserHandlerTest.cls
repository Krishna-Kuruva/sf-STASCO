@isTest(SeeAllData = False)
private class TCP_UserHandlerTest {
    
	@TestSetup
    static void createTestData(){
        User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
            List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
            List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
            List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testContact[0]);
            listofusers[0].isActive = True;
            listofusers[0].CIPM_Access__c = True;
            update listofusers[0];     
        }
    }
    static testMethod void testCIPMPreRegister(){
        
        list<user> listofusers = [select id FROM user WHERE email = 'testuser002@test.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TCP_CIPM_MockTest('201','{"uuid": "123abc"}'));
        Test.startTest();
        TCP_CIPM_PreRegisterHandler.manageCIPMRegister(listofusers[0].id);
        Test.stopTest();
    }
    
    static testMethod void testCIPMPreRegister2(){
        
        list<user> listofusers = [select id FROM user WHERE email = 'testuser002@test.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TCP_CIPM_MockTest('422','{"error_details": {"user_id": {"invalid": "Account is already verified"}},"error_description": ""}'));
        Test.startTest();
        TCP_CIPM_PreRegisterHandler.manageCIPMRegister(listofusers[0].id);
        Test.stopTest();
        
    }
    
    static testMethod void testCIPMPreRegister3(){
        
        list<user> listofusers = [select id FROM user WHERE email = 'testuser002@test.com' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new TCP_CIPM_MockTest('200',''));
        Test.startTest();
        TCP_CIPM_PreRegisterHandler.manageCIPMRegister(listofusers[0].id);
        Test.stopTest();
        
    }
    
    static testMethod void testresendCIPMRequest(){
        list<user> listofusers = [select id FROM user WHERE email = 'testuser002@test.com' LIMIT 1];
        ApexPages.StandardController stdUser = new ApexPages.StandardController(listofusers[0]);
        TCP_CIPM_PreRegisterHandler handler = new TCP_CIPM_PreRegisterHandler(stdUser);
        Test.setMock(HttpCalloutMock.class, new TCP_CIPM_MockTest('201','{"uuid": "123abc"}'));
        Test.startTest();
        handler.resendCIPMRequest();
        Test.stopTest();
    }
    
}