@isTest(SeeAllData = False)
private class TCP_OpenId_RegistrationHandlerTest {
    
    
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
    
    static testMethod void testCreateAndUpdateUser() {
        TCP_OpenId_RegistrationHandler handler = new TCP_OpenId_RegistrationHandler();
        string addressval = '{"address":[address: {"street_address":"teststreet","locality":"testloc","state":"teststate","country":"testcon","postal_code":"testpost" }]}';
        Auth.UserData sampleData = new Auth.UserData('testId', '1', 'Test2',
                                                     '1 Test2', 'testuser002@test.com', 'testuserlong', 'testuser2@test.com', 'en_US', 'openid',
                                                     null, new Map<String, String>{'language' => 'en_US','email_verified' => 'true','email' => 'testuser002@test.com','given_name' => '1', 'family_name' => 'test2', 'phone_number' => '123456666', 'phone_type' => 'mobile', 'address'=>addressval} );
        Test.startTest();
        User u = handler.createUser(null, sampleData);
        System.assertEquals('testuser002@test.com', u.email); 
        System.assertEquals('test2', u.lastName);
        System.assertEquals('1', u.firstName);
        
        
        //insert(u);
        String uid = u.id;
        
        sampleData = new Auth.UserData('testId', '12', 'Test22',
                                       '1 Test2', 'testuser002@test.com', 'testuserlong', 'testuser2@test.com', 'en_US', 'openid',
                                       null, new Map<String, String>{'language' => 'en_US','zoneinfo'=>'Europe/London','locale'=> 'en_US', 'email_verified' => 'true','email' => 'testuser002@test.com','given_name' => '12', 'family_name' => 'test22', 'phone_number' => '123456666', 'phone_type' => 'mobile', 'address'=>addressval} );
        handler.updateUser(uid, null, sampleData);
        
        User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
        System.assertEquals('test22', updatedUser.lastName);
        System.assertEquals('12', updatedUser.firstName);
        Test.stopTest();
    }
    
    static testMethod void coverExceptionsTest() {
        
        TCP_OpenId_RegistrationHandler handler = new TCP_OpenId_RegistrationHandler();
        string addressval = '{"address":[address: {"street_address":"teststreet","locality":"testloc","state":"teststate","country":"testcon","postal_code":"testpost" }]}';
        Auth.UserData sampleData = new Auth.UserData('', '1', 'Test2345678',
                                                     '1 Test2345678', 'testuser002@test.com', 'testuserlong', 'testuser2@test.com', 'en_US', 'openid',
                                                     null, new Map<String, String>{'language' => 'en_US','email_verified' => 'false','email' => 'testuser002@test.com','given_name' => '1', 'family_name' => 'test2345678', 'phone_number' => '123456666', 'phone_type' => 'mobile', 'address'=>addressval} );
        Test.startTest();
        try{
            User u = handler.createUser(null, sampleData);
            
        }
        catch(Exception e){
            system.assertEquals('Can\'t create a new user or link an existing user because last name or email is missing, or email is not verified.', e.getMessage());
        }
        	
        Test.StopTest();
        
        
    }
    
    static testMethod void coverExceptionsTest2() {
        
        TCP_OpenId_RegistrationHandler handler = new TCP_OpenId_RegistrationHandler();
        string addressval = '{"address":[address: {"street_address":"teststreet","locality":"testloc","state":"teststate","country":"testcon","postal_code":"testpost" }]}';
        Auth.UserData sampleData = new Auth.UserData('', '1', 'Test2345678',
                                                     '1 Test2345678', 'testuser002@test.com', 'testuserlong', 'testuser2@test.com', 'en_US', 'openid',
                                                     null, new Map<String, String>{'language' => 'en_US','email_verified' => 'false','email' => 'testuser002@test.com','given_name' => '1', 'family_name' => 'test2345678', 'phone_number' => '123456666', 'phone_type' => 'mobile', 'address'=>addressval} );
        Test.startTest();
        try{
           handler.updateUser(null, null, sampleData);
            
        }
        catch(Exception e){
            system.assertEquals('Can\'t update the existing user because the email that was used is not verified', e.getMessage());
        }
        	
        Test.StopTest();
        
        
    }
}