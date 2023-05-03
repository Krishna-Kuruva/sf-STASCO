/*****************************************************************************
 * Purpose: Test class for TCP_MyShellContactsCtrl
 * Verion : 1.0
 * **************************************************************************/
@isTest
public class TCP_MyShellContactsCtrlTest {
	/* Data Setup */
    @TestSetup
    static void createTestData() {
         User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<Account_Contact_Relationship__c> testacr=TCP_TestDataUtilities.createACRRecords(testAccounts[0], testContact[0], 1);
        } 
    }
    /* 
     * To test functionality of my shell contacts for portal user
     */
    @isTest 
    static void getShellContactsTest() {
        Account acc=[select id,name from account where name='SampleAccount0' limit 1];
        
        List<Account_Contact_Relationship__c>  acrRecList=[select id, account__c,Portal_User_Contact__c from Account_Contact_Relationship__c where account__c=:acc.id limit 1];
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c from contact limit 1]);
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        Test.startTest();
            List<Id> accIds=new List<Id>();
            accIds.add(acrRecList[0].id);
            system.assert(accIds.size()>0);
            List<TCP_MyShellContactsCtrl.ContactWrapper> wrapperList = TCP_MyShellContactsCtrl.getShellContacts(acrRecList[0].account__c);
        Test.stopTest();
    }
}