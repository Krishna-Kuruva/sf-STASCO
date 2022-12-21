@isTest
public without sharing class RT_Price_BookHistoryTriggerHelperTest 
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
        List<RT_Price_Book__c> pbList = new List<RT_Price_Book__c>();
        Id pbRecTypeId=Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('Canada SFJ Price').getRecordTypeId();
        pbList.add(new RT_Price_Book__c(RecordTypeId=pbRecTypeId));
        pbList.add(new RT_Price_Book__c(RecordTypeId=pbRecTypeId));  
        insert pbList;                                       
      }
    }
    
    @isTest
    public static void preventUpdateDelTest()
    {
        List<RT_Price_BookHistory__c> recList = [select id,RT_Cur__c from RT_Price_BookHistory__c];
        try {
        Delete recList;
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        }
        try {
            for(RT_Price_BookHistory__c rec :recList) 
            {
                rec.RT_Cur__c = 'Testing'; 
            }
            Update recList; 
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        } 
    }

}