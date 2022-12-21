@isTest
public with sharing class RT_SettingHistoryTriggerHelperTest {
    @TestSetup
    public static void testSetup() 
    {
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
      User u = new User(
        Alias = 'standt',
        Email = 'standarduser@testorg.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'RunHistoryCreation@test.com'
      );
      insert u;
      system.runAs(u)
      {
        RE_CND_TestDataFactory.createCountrySettings();                                         
      }
    }
    
    @isTest
    public static void preventUpdateDelTest()
    {
        List<RT_SettingHistory__c> recList = [select id,RE_Approver_Role_1__c from RT_SettingHistory__c];
        try {
        Delete recList;
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        }
        try {
            for(RT_SettingHistory__c rec :recList) 
            {
                rec.RE_Approver_Role_1__c = 'Testing'; 
            }
            Update recList; 
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        } 
    }

}