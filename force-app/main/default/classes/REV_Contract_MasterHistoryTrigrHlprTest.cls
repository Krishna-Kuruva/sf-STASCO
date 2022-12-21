@isTest
public without sharing class REV_Contract_MasterHistoryTrigrHlprTest 
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
        Id prodRecordID = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByName().get('Canada').getRecordTypeId();
        RE_Product__c prdRec =RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        Account acc = new Account();
        Id acctRecordID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution Canada').getRecordTypeId();
        acc.RecordTypeId = acctRecordID;
        acc.Name='Testing';        
        insert acc;
        RE_Location__c loc = new RE_Location__c();
        loc.RecordTypeId=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByName().get('Canada').getRecordTypeId();
        loc.Name='Testing Demo';        
        insert loc;
        RE_CND_TestDataFactory.createRevMaster(prodRecordID,'Gaspe','Test',prdRec.Id,prdRec.Id,acc.Id,acc.Id,
                                               loc.Id,prdRec.Id,'MYR CTS/BBL');
        RE_CND_TestDataFactory.createRevMaster(prodRecordID,'Gaspe','Test',prdRec.Id,prdRec.Id,acc.Id,acc.Id,
                                               loc.Id,prdRec.Id,'MYR CTS/BBL');                                             
      }
    }
    
    @isTest
    public static void preventUpdateDelTest()
    {
        List<REV_Contract_MasterHistory__c> recList = [select id,Base_UOM_Code__c from REV_Contract_MasterHistory__c];
        try {
        Delete recList;
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        }
        try {
            for(REV_Contract_MasterHistory__c rec :recList) 
            {
                rec.Base_UOM_Code__c = 'Testing'; 
            }
            Update recList; 
        }
        catch(Exception e){
          System.AssertEquals(e.getMessage().contains('Modifying/Deleting History Records is NOT Allowed'), true);
        } 
    }

}