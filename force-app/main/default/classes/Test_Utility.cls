/**************************************************************************************************
 * Class Name : Test_Utility 
 * Description: To create a customer user
 * Verion     : 1.0
 * **************************************************************************************************/
@isTest
public with sharing class Test_Utility {
    
    //Create Account
     public static Account createAccount()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
            insert acc;
        return acc;
    }
    
    //Create Contact 
   	
    public static Contact createContact()
    {
        Account acc = Test_Utility.createAccount();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'FirstName';
        con.LastName = 'LastName';
        con.Email = 'FirstName@test.com';
            insert con;
        return con;
    }
    
    //Create Community User
    
    public static User createCommunityUser()
    {
         User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        Contact con = Test_Utility.createContact();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TCPCustomerCommunityPlusUser' LIMIT 1];
		User usr = New User();
         	usr.UserName = 'test_' + math.random() + '@test.com';
            usr.FirstName = 'Test-First';
            usr.LastName = 'Test-Last';
            usr.Alias = 'test';
            usr.email = 'test' + math.random() + '@test.com';
            //usr.CommunityNickName = string.valueOf(math.random()).substring(0,6);
            usr.ProfileID = p.id;
            usr.TimeZoneSidKey = 'America/New_York';
            usr.LocaleSidKey = 'en_US';
            usr.EmailEncodingKey = 'UTF-8'; 
            usr.LanguageLocaleKey = 'en_US';
            usr.ContactID = con.Id;
        insert usr;
        //System.setPassword(usr.Id, 'Test@1234');
        return usr;
        }
        return null;
    }
    public static AuthSession getsession()
    {
        User usr = Test_Utility.createCommunityUser();
        AuthSession sessions = [SELECT CreatedDate,Id,IsCurrent,LastModifiedDate,LoginGeoId,LoginHistoryId,LoginType,LogoutUrl,NumSecondsValid,ParentId,SessionSecurityLevel,SessionType,SourceIp,UsersId,UserType  from AuthSession where UsersId=:usr.Id];
        return sessions;
    }
}