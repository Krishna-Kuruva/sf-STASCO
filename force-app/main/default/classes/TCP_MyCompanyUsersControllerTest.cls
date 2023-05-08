/*****************************************************************************
* Purpose: Test class for TCP_MyCompanyUsersController
* Verion : 1.0
* **************************************************************************/
@isTest
public class TCP_MyCompanyUsersControllerTest {
    @TestSetup
    static void createTestData() {
         User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<Account_Contact_Relationship__c> testacr=TCP_TestDataUtilities.createACRRecords(testAccounts[0], testContact[0], 1);
        }
    }
    @isTest 
    static void getMyCompanyTest() {
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        Account acc=[select id,name,recordtype.id from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpAccountRecTypeid;
        update acc;
        List<TCP_ShellContactEmail__c> shellConList=new List<TCP_ShellContactEmail__c>();
        List<Account_Contact_Relationship__c>  acrRecList=[select id, account__c,Portal_User_Contact__c from Account_Contact_Relationship__c where account__c=:acc.id limit 1];
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        TCP_ShellContactEmail__c shellCon=TCP_TestDataUtilities.createShellContacts();
        TCP_ShellContactEmail__c shellConIns=[Select Id,Contact_Email__c from TCP_ShellContactEmail__c];
        shellConList.add(shellConIns);
        system.runas(listofusers[0]){
        Test.startTest();
        List<Id> accIds=new List<Id>();
        accIds.add(acrRecList[0].id);
        system.assert(accIds.size()>0);
        List<TCP_MyCompanyUsersController.ContactWrapper> wrapperList = TCP_MyCompanyUsersController.getContacts();
        TCP_MyCompanyUsersController.getAccountDetailsOfComOps();
        List<TCP_ShellContactEmail__c> conList=TCP_MyCompanyUsersController.getShellContacts(acc.Id);
        TCP_MyCompanyUsersController.getNewRequestDetails(acc.id, shellConIns.Id, 'FirstName', 'LastName', '1234', 'Email@gmail.com', 'Comments');
        TCP_MyCompanyUsersController.getComplaintDetails(acc.id, shellConIns.Id, 'ShellRefNumber', 'CustomerPO', 'Description', 'Product');
        TCP_MyCompanyUsersController.getCommentDetails(acc.id, shellConIns.Id, 'Description');
        TCP_MyCompanyUsersController.getEnquiryDetails(acc.id, shellConIns.Id, 'Description');
        TCP_MyCompanyUsersController.getUserEditDetails(testCons[0].EMail, 'companyName', testCons[0].Name, shellConIns.Id, 'EditDetails');
        TCP_MyCompanyUsersController.getUserDeleteDetails(testCons[0].EMail, 'companyName', testCons[0].Name, shellConIns.Id, 'Description', 'deletereason');
        
        Test.stopTest();
            system.assertEquals(shellConList, shellConList);
        }
    }
    @isTest
    static void getMyCompanyUsersTestNegative(){
        List<TCP_ShellContactEmail__c> shellConList=new List<TCP_ShellContactEmail__c>();
        test.startTest();
        TCP_MyCompanyUsersController.getShellContacts('acc.Id');
        TCP_MyCompanyUsersController.getShellContacts('null');
        List<TCP_ShellContactEmail__c> conList=TCP_MyCompanyUsersController.getShellContacts(null);
        TCP_MyCompanyUsersController.getNewRequestDetails('acc.id', 'shellConIns.Id', 'FirstName', 'LastName', '1234', 'Email@gmail.com', 'Comments');
        TCP_MyCompanyUsersController.getComplaintDetails('acc.id', 'shellConIns.Id', 'ShellRefNumber', 'CustomerPO', 'Description', 'Product');
        TCP_MyCompanyUsersController.getCommentDetails('acc.id', 'shellConIns.Id', 'Description');
        TCP_MyCompanyUsersController.getEnquiryDetails('acc.id', 'shellConIns.Id', 'Description');
        TCP_MyCompanyUsersController.getUserEditDetails('testCons[0].EMail', 'companyName', 'testCons[0].Name', 'shellConIns.Id', 'EditDetails');
        TCP_MyCompanyUsersController.getUserDeleteDetails('testCons[0].EMail', 'companyName', 'testCons[0].Name', 'shellConIns.Id', 'Description', 'deletereason');
        test.stopTest();
        system.assertEquals(shellConList, conList);
    }
}