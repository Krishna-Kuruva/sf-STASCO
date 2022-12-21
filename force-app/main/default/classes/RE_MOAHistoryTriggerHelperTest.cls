@isTest
public without sharing class RE_MOAHistoryTriggerHelperTest 
{
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
        RE_CND_TestDataFactory.createMarketMoveData(Datetime.now());
      }
    }
    
    @isTest
    public static void preventUpdateDelTest()
    {
        List<RE_MOAHistory__c> recList = [select id,RE_AM_Comments__c from RE_MOAHistory__c];
        try {
        Delete recList;
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        }
        try {
            for(RE_MOAHistory__c rec :recList) 
            {
                rec.RE_AM_Comments__c = 'Testing'; 
            }
            Update recList; 
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        } 
    }

}