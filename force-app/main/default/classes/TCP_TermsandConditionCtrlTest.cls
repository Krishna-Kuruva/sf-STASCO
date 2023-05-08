/*****************************************************************************
 * Purpose: Test class for TCP_TermsandConditionCtrl
 * Verion : 1.0
 * **************************************************************************/
@isTest
public class TCP_TermsandConditionCtrlTest {
    /* Data Setup */
    @TestSetup
    static void createTestData() {
        
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        
            
    }
    /* 
     * To test functionality of terms and conditions for portal user
     */
    @isTest 
    static void communityusersContactTest() {
       
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c from contact limit 1]);
        //List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        //List<User> listofusers=[select id,name,contactId,ProfileId,email from user where email='testuser2@test.com' limit 1];
        boolean istrue=true;
        Test.startTest();
       		TCP_TermsandConditionCtrl.getCommUserContactId();
        Test.stopTest();
    }
   
     /* 
     * To test functionality of terms and conditions for commops user
     */
	@isTest 
    static void communityusersContactNegativeTest() {
       
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c,email,LastName from contact where LastName='SampleContact0' limit 1]);
     
        	Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        	User u = new User();
            u.Alias = '2tser';
            u.EmailEncodingKey = 'UTF-8';            
            u.FirstName = 'testing';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey = 'en_US';
            u.ProfileId = profileId;
            u.TimeZoneSidKey = 'America/Los_Angeles';
  			//u.ContactId=testCons[0].id;
            u.Username = 'test1user001@test.com';
            u.Email = testCons[0].email;
            u.LastName = 'Test1';
            insert u;
        
            boolean istrue=true;
        System.runAs(u){
               Test.startTest();
                TCP_TermsandConditionCtrl.getCommUserContactId();
            Test.stopTest();
            
        }
         
        
                
    }

}