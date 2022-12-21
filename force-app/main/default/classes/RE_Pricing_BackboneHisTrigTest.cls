@isTest
public with sharing class RE_Pricing_BackboneHisTrigTest 
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
    RE_CND_TestDataFactory.createCountrySettings();
    RE_CND_TestDataFactory.createDepoPricingData_New();
  }
}

@isTest
public static void preventUpdateDelTest()
{
    List<RE_Depot_Pricing_BackboneHistory__c> recList = [select id,RE_PH_BIO_Fixed__c from RE_Depot_Pricing_BackboneHistory__c];
    try {
    Delete recList;
    }
    catch(Exception e){
      System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
    }
    try {
        for(RE_Depot_Pricing_BackboneHistory__c rec :recList) 
        {
            rec.RE_PH_BIO_Fixed__c = 6.25; 
        }
        Update recList; 
    }
    catch(Exception e){
      System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
    } 
}
}