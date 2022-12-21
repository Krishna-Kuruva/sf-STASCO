@isTest
public class RE_SG_CostPriceHistoryTriggerHelperTest {
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
    List<RE_SG_CostPrice__c> recList = new List<RE_SG_CostPrice__c>();
    recList.add(RE_TestDataFactory.createRESGCostPrice(true,datetime.now()));
    recList.add(RE_TestDataFactory.createRESGCostPrice(true,datetime.now()));
    recList.add(RE_TestDataFactory.createRESGCostPrice(true,datetime.now()));
    insert recList ;
  }
}

@isTest
public static void preventUpdateDelTest()
{
    List<RE_SG_CostPriceHistory__c> recList = [select id,RE_Additive_Cost__c from RE_SG_CostPriceHistory__c];
    try {
    Delete recList;
    }
    catch(Exception e){
      System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
    }
    try {
        for(RE_SG_CostPriceHistory__c rec :recList) 
        {
            rec.RE_Additive_Cost__c = 1; 
        }
        Update recList; 
    }
    catch(Exception e){
      System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
    } 
}
}