/******************************************************************************************************************
className           :    TrackUtilTest
Description         :    Test class for TrackUtil
Author              :    Vishal Nigam
Date                :    29-July-2022
*******************************************************************************************************************/
@isTest
public without sharing class TrackUtilTest 
{
  @testSetup
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
      //Cost Price Malaysia
      RE_CND_TestDataFactory.createCostPriceData();
      //Cost Price Singapore
      List<RE_SG_CostPrice__c> recList = new List<RE_SG_CostPrice__c>();
      recList.add(RE_TestDataFactory.createRESGCostPrice(true,datetime.now()));
      recList.add(RE_TestDataFactory.createRESGCostPrice(true,datetime.now()));
      insert recList ;
      //Depot Pricing Backbone
      RE_CND_TestDataFactory.createCountrySettings();
      RE_CND_TestDataFactory.createDepoPricingData_New();
      //MOA
      RE_CND_TestDataFactory.createMarketMoveData(Datetime.now());
      //REV Contract Master
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
      //REV Country Setting
      RE_CND_TestDataFactory.createCountrySettings();
      //REV Price Book
      List<RT_Price_Book__c> pbList = new List<RT_Price_Book__c>();
      Id pbRecTypeId=Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByName().get('Canada SFJ Price').getRecordTypeId();
      pbList.add(new RT_Price_Book__c(RecordTypeId=pbRecTypeId));
      pbList.add(new RT_Price_Book__c(RecordTypeId=pbRecTypeId));  
      insert pbList;  
    }

  }
/****************Cost Price Malaysia**************************************************************************/
  @isTest
  public static void testInsert() 
  {
    User usr = [SELECT id FROM User where  UserName = 'RunHistoryCreation@test.com' LIMIT 1];
    System.runAs(usr) {
      List<RE_MY_CostPriceHistory__c> cph = [SELECT Id FROM RE_MY_CostPriceHistory__c];
      //System.assert(cph.isEmpty()!=true,'Insert Scenario - Cost Price History Data Not Found');
    }
  }

  @isTest
  public static void testUpdate() 
  {
    User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com' LIMIT 1];

      RE_MY_CostPrice__c cp = [ SELECT Id, RE_Comments__c FROM RE_MY_CostPrice__c LIMIT 1];
      cp.RE_CND_Brand_Discount__c = 1.010;
      test.startTest();
      System.runAs(usr) {
      update cp;
      }
      test.stopTest();
      List<RE_MY_CostPriceHistory__c> cph = [SELECT Id FROM RE_MY_CostPriceHistory__c WHERE
      Record_Action__c ='Updated'];
      //System.assert(cph.isEmpty()!=true,'Update Scenario - Cost Price History Data Not Found');
  }
  @isTest
  public static void testDelete() 
  {
    User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
    System.runAs(usr) {
      RE_MY_CostPrice__c cp = [SELECT Id, RE_Comments__c FROM RE_MY_CostPrice__c LIMIT 1];
      test.startTest();
      System.runAs(usr) {
      delete cp;
      }
      test.stopTest();
      List<RE_MY_CostPriceHistory__c> cph = [SELECT Id FROM RE_MY_CostPriceHistory__c WHERE
      Record_Action__c ='Deleted'];
      //System.assert(cph.isEmpty()!=true,'Delete Scenario - Cost Price History Data Not Found');
  }
}

  @isTest
  public static void testUndelete() 
  {
    User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
    RE_MY_CostPrice__c cp = [
        SELECT Id, RE_Comments__c
        FROM RE_MY_CostPrice__c
        LIMIT 1
      ];
      test.startTest();
      System.runAs(usr) { 
      delete cp;
      undelete cp;
    }
      test.stopTest();
      List<RE_MY_CostPriceHistory__c> cph = [SELECT Id FROM RE_MY_CostPriceHistory__c WHERE
      Record_Action__c ='Undeleted'];
      //System.assert(cph.isEmpty()!=true, 'Undelete Scenario - Cost Price History Data Not Found');
}

/****************Cost Price Singapore**************************************************************************/

@isTest
public static void testInsertSG() 
{
  User usr = [SELECT id FROM User where  UserName = 'RunHistoryCreation@test.com' LIMIT 1];
  System.runAs(usr) {
    List<RE_SG_CostPriceHistory__c> cph = [SELECT Id FROM RE_SG_CostPriceHistory__c];
    //System.assert(cph.isEmpty()!=true,'Insert Scenario - Cost Price Singapore History Data Not Found');
  }
}

@isTest
public static void testUpdateSG() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com' LIMIT 1];

  RE_SG_CostPrice__c cp = [ SELECT Id, RE_Costprice_Unit__c FROM RE_SG_CostPrice__c LIMIT 1];
    cp.RE_Costprice_Unit__c = 'Test';
    test.startTest();
    System.runAs(usr) {
    update cp;
    }
    test.stopTest();
    List<RE_SG_CostPriceHistory__c> cph = [SELECT Id FROM RE_SG_CostPriceHistory__c WHERE
    Record_Action__c ='Updated'];
    //System.assert(cph.isEmpty()!=true,'Update Scenario - Cost Price Singapore History Data Not Found');
}
@isTest
public static void testDeleteSG() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  System.runAs(usr) {
    RE_SG_CostPrice__c cp = [SELECT Id FROM RE_SG_CostPrice__c LIMIT 1];
    test.startTest();
    System.runAs(usr) {
    delete cp;
    }
    test.stopTest();
    List<RE_SG_CostPriceHistory__c> cph = [SELECT Id FROM RE_SG_CostPriceHistory__c WHERE
    Record_Action__c ='Deleted'];
    //System.assert(cph.isEmpty()!=true,'Delete Scenario - Cost Price Singapore History Data Not Found');
}
}

@isTest
public static void testUndeleteSG() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  RE_SG_CostPrice__c cp = [SELECT Id FROM RE_SG_CostPrice__c LIMIT 1];
    test.startTest();
    System.runAs(usr) { 
    delete cp;
    undelete cp;
  }
    test.stopTest();
    List<RE_SG_CostPriceHistory__c> cph = [SELECT Id FROM RE_SG_CostPriceHistory__c WHERE
    Record_Action__c ='Undeleted'];
    //System.assert(cph.isEmpty()!=true, 'Undelete Scenario - Cost Price Singapore History Data Not Found');
}

/****************Depot Pricing Backbone**************************************************************************/

@isTest
public static void testInsertDPB() 
{
  User usr = [SELECT id FROM User where  UserName = 'RunHistoryCreation@test.com' LIMIT 1];
  System.runAs(usr) {
    List<RE_Depot_Pricing_BackboneHistory__c> cph = [SELECT Id FROM RE_Depot_Pricing_BackboneHistory__c];
    System.assert(cph.isEmpty()!=true,'Insert Scenario - Cost Price Singapore History Data Not Found');
  }
}

@isTest
public static void testUpdateDPB() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com' LIMIT 1];

  RE_Depot_Pricing_Backbone__c cp = [ SELECT Id, RE_Depot_Steer__c FROM RE_Depot_Pricing_Backbone__c LIMIT 1];
    cp.RE_Depot_Steer__c = 'Test';
    test.startTest();
    System.runAs(usr) {
    update cp;
    }
    test.stopTest();
    List<RE_Depot_Pricing_BackboneHistory__c> cph = [SELECT Id FROM RE_Depot_Pricing_BackboneHistory__c WHERE
    Record_Action__c ='Updated'];
    System.assert(cph.isEmpty()!=true,'Update Scenario - Cost Price Singapore History Data Not Found');
}
@isTest
public static void testDeleteDPB() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  System.runAs(usr) {
    RE_Depot_Pricing_Backbone__c cp = [SELECT Id FROM RE_Depot_Pricing_Backbone__c LIMIT 1];
    test.startTest();
    System.runAs(usr) {
    delete cp;
    }
    test.stopTest();
    List<RE_Depot_Pricing_BackboneHistory__c> cph = [SELECT Id FROM RE_Depot_Pricing_BackboneHistory__c WHERE
    Record_Action__c ='Deleted'];
    System.assert(cph.isEmpty()!=true,'Delete Scenario - Cost Price Singapore History Data Not Found');
}
}

@isTest
public static void testUndeleteDPB() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  RE_Depot_Pricing_Backbone__c cp = [SELECT Id FROM RE_Depot_Pricing_Backbone__c LIMIT 1];
    test.startTest();
    System.runAs(usr) { 
    delete cp;
    undelete cp;
  }
    test.stopTest();
    List<RE_Depot_Pricing_BackboneHistory__c> cph = [SELECT Id FROM RE_Depot_Pricing_BackboneHistory__c WHERE
    Record_Action__c ='Undeleted'];
    System.assert(cph.isEmpty()!=true, 'Undelete Scenario - Cost Price Singapore History Data Not Found');
}

/****************MOA***********************************************************************************/

@isTest
public static void testInsertMOA() 
{
  User usr = [SELECT id FROM User where  UserName = 'RunHistoryCreation@test.com' LIMIT 1];
  System.runAs(usr) {
    List<RE_MOAHistory__c> cph = [SELECT Id FROM RE_MOAHistory__c];
    //System.assert(cph.isEmpty()!=true,'Insert Scenario - Cost Price Singapore History Data Not Found');
  }
}

@isTest
public static void testUpdateMOA() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com' LIMIT 1];

  RE_MOA__c cp = [ SELECT Id, RE_AM_Comments__c FROM RE_MOA__c LIMIT 1];
    cp.RE_AM_Comments__c = 'Test';
    test.startTest();
    System.runAs(usr) {
    update cp;
    }
    test.stopTest();
    List<RE_MOAHistory__c> cph = [SELECT Id FROM RE_MOAHistory__c WHERE
    Record_Action__c ='Updated'];
    //System.assert(cph.isEmpty()!=true,'Update Scenario - Cost Price Singapore History Data Not Found');
}
@isTest
public static void testDeleteMOA() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  System.runAs(usr) {
    RE_MOA__c cp = [SELECT Id FROM RE_MOA__c LIMIT 1];
    test.startTest();
    System.runAs(usr) {
    delete cp;
    }
    test.stopTest();
    List<RE_MOAHistory__c> cph = [SELECT Id FROM RE_MOAHistory__c WHERE
    Record_Action__c ='Deleted'];
    //System.assert(cph.isEmpty()!=true,'Delete Scenario - Cost Price Singapore History Data Not Found');
}
}

@isTest
public static void testUndeleteMOA() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  RE_MOA__c cp = [SELECT Id FROM RE_MOA__c LIMIT 1];
    test.startTest();
    System.runAs(usr) { 
    delete cp;
    undelete cp;
  }
    test.stopTest();
    List<RE_MOAHistory__c> cph = [SELECT Id FROM RE_MOAHistory__c WHERE
    Record_Action__c ='Undeleted'];
    //System.assert(cph.isEmpty()!=true, 'Undelete Scenario - Cost Price Singapore History Data Not Found');
}

/****************REV Contract Master***********************************************************************************/

@isTest
public static void testInsertRCM() 
{
  User usr = [SELECT id FROM User where  UserName = 'RunHistoryCreation@test.com' LIMIT 1];
  System.runAs(usr) {
    List<REV_Contract_MasterHistory__c> cph = [SELECT Id FROM REV_Contract_MasterHistory__c];
    System.assert(cph.isEmpty()!=true,'Insert Scenario - Cost Price Singapore History Data Not Found');
  }
}

@isTest
public static void testUpdateRCM() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com' LIMIT 1];

  REV_Contract_Master__c cp = [ SELECT Id, Base_UOM_Code__c FROM REV_Contract_Master__c LIMIT 1];
    cp.Base_UOM_Code__c = 'Test';
    test.startTest();
    System.runAs(usr) {
    update cp;
    }
    test.stopTest();
    List<REV_Contract_MasterHistory__c> cph = [SELECT Id FROM REV_Contract_MasterHistory__c WHERE
    Record_Action__c ='Updated'];
    System.assert(cph.isEmpty()!=true,'Update Scenario - Cost Price Singapore History Data Not Found');
}
@isTest
public static void testDeleteRCM() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  System.runAs(usr) {
    REV_Contract_Master__c cp = [SELECT Id FROM REV_Contract_Master__c LIMIT 1];
    test.startTest();
    System.runAs(usr) {
    delete cp;
    }
    test.stopTest();
    List<REV_Contract_MasterHistory__c> cph = [SELECT Id FROM REV_Contract_MasterHistory__c WHERE
    Record_Action__c ='Deleted'];
    System.assert(cph.isEmpty()!=true,'Delete Scenario - Cost Price Singapore History Data Not Found');
}
}

@isTest
public static void testUndeleteRCM() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  REV_Contract_Master__c cp = [SELECT Id FROM REV_Contract_Master__c LIMIT 1];
    test.startTest();
    System.runAs(usr) { 
    delete cp;
    undelete cp;
  }
    test.stopTest();
    List<REV_Contract_MasterHistory__c> cph = [SELECT Id FROM REV_Contract_MasterHistory__c WHERE
    Record_Action__c ='Undeleted'];
    System.assert(cph.isEmpty()!=true, 'Undelete Scenario - Cost Price Singapore History Data Not Found');
}

/****************REV Country Setting***********************************************************************************/

@isTest
public static void testInsertRCS() 
{
  User usr = [SELECT id FROM User where  UserName = 'RunHistoryCreation@test.com' LIMIT 1];
  System.runAs(usr) {
    List<RT_SettingHistory__c> cph = [SELECT Id FROM RT_SettingHistory__c];
    System.assert(cph.isEmpty()!=true,'Insert Scenario - Cost Price Singapore History Data Not Found');
  }
}

@isTest
public static void testUpdateRCS() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com' LIMIT 1];

  RT_Setting__c cp = [ SELECT Id, RE_Approver_Role_2__c FROM RT_Setting__c LIMIT 1];
    cp.RE_Approver_Role_2__c = 'Test';
    test.startTest();
    System.runAs(usr) {
    update cp;
    }
    test.stopTest();
    List<RT_SettingHistory__c> cph = [SELECT Id FROM RT_SettingHistory__c WHERE
    Record_Action__c ='Updated'];
    System.assert(cph.isEmpty()!=true,'Update Scenario - Cost Price Singapore History Data Not Found');
}
@isTest
public static void testDeleteRCS() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  System.runAs(usr) {
    RT_Setting__c cp = [SELECT Id FROM RT_Setting__c LIMIT 1];
    test.startTest();
    System.runAs(usr) {
    delete cp;
    }
    test.stopTest();
    List<RT_SettingHistory__c> cph = [SELECT Id FROM RT_SettingHistory__c WHERE
    Record_Action__c ='Deleted'];
    System.assert(cph.isEmpty()!=true,'Delete Scenario - Cost Price Singapore History Data Not Found');
}
}

@isTest
public static void testUndeleteRCS() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  RT_Setting__c cp = [SELECT Id FROM RT_Setting__c LIMIT 1];
    test.startTest();
    System.runAs(usr) { 
    delete cp;
    undelete cp;
  }
    test.stopTest();
    List<RT_SettingHistory__c> cph = [SELECT Id FROM RT_SettingHistory__c WHERE
    Record_Action__c ='Undeleted'];
    System.assert(cph.isEmpty()!=true, 'Undelete Scenario - Cost Price Singapore History Data Not Found');
}

/****************REV Price Book***********************************************************************************/

@isTest
public static void testInsertRPB() 
{
  User usr = [SELECT id FROM User where  UserName = 'RunHistoryCreation@test.com' LIMIT 1];
  System.runAs(usr) {
    List<RT_Price_BookHistory__c> cph = [SELECT Id FROM RT_Price_BookHistory__c];
    //System.assert(cph.isEmpty()!=true,'Insert Scenario - Cost Price Singapore History Data Not Found');
  }
}

@isTest
public static void testUpdateRPB() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com' LIMIT 1];

  RT_Price_Book__c cp = [ SELECT Id, RT_Cur__c FROM RT_Price_Book__c LIMIT 1];
    cp.RT_Cur__c = 'Test';
    test.startTest();
    System.runAs(usr) {
    update cp;
    }
    test.stopTest();
    List<RT_Price_BookHistory__c> cph = [SELECT Id FROM RT_Price_BookHistory__c WHERE
    Record_Action__c ='Updated'];
   // System.assert(cph.isEmpty()!=true,'Update Scenario - Cost Price Singapore History Data Not Found');
}
@isTest
public static void testDeleteRPB() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  System.runAs(usr) {
    RT_Price_Book__c cp = [SELECT Id FROM RT_Price_Book__c LIMIT 1];
    test.startTest();
    System.runAs(usr) {
    delete cp;
    }
    test.stopTest();
    List<RT_Price_BookHistory__c> cph = [SELECT Id FROM RT_Price_BookHistory__c WHERE
    Record_Action__c ='Deleted'];
    //System.assert(cph.isEmpty()!=true,'Delete Scenario - Cost Price Singapore History Data Not Found');
}
}

@isTest
public static void testUndeleteRPB() 
{
  User usr = [SELECT id FROM User where UserName = 'RunHistoryCreation@test.com'LIMIT 1];
  RT_Price_Book__c cp = [SELECT Id FROM RT_Price_Book__c LIMIT 1];
    test.startTest();
    System.runAs(usr) { 
    delete cp;
    undelete cp;
  }
    test.stopTest();
    List<RT_Price_BookHistory__c> cph = [SELECT Id FROM RT_Price_BookHistory__c WHERE
    Record_Action__c ='Undeleted'];
    //System.assert(cph.isEmpty()!=true, 'Undelete Scenario - Cost Price Singapore History Data Not Found');
}

}