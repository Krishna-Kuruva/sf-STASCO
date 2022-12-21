@isTest
public class RE_CND_UtilityTest {
    
      @isTest
    static  void handleUpsertTest(){
        Test.startTest(); 
        List<RE_Location__c> locList = new List<RE_Location__c>();
        
        RE_Job_Run_Audit__c jrAudit = RE_CND_TestDataFactory.createJobRunAudit('Automate','Canada Daily Reuters Quote Move','CA');
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        loc1.RE_Country_Name__c='ABC';
        locList.add(loc1);
        Database.UpsertResult[] upsertStatus= Database.upsert(locList, false);
        RE_CND_Utility.handleUpsertResult('ABC','XYZ',upsertStatus,jrAudit);
		Test.stopTest();
    }
		 @isTest
    static  void handleUpdateTest(){
        Test.startTest(); 
        List<RE_Location__c> locList = new List<RE_Location__c>();
        
        RE_Job_Run_Audit__c jrAudit = RE_CND_TestDataFactory.createJobRunAudit('Automate','Canada Daily Reuters Quote Move','CA');
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        loc1.RE_Country_Name__c='ABC';
        locList.add(loc1);
        Database.SaveResult[] updateStatus= Database.update(locList, false);
        RE_CND_Utility.handleUpdateResult('ABC','XYZ',updateStatus,false,jrAudit);
		Test.stopTest();
    }
    
    
     @isTest
    static  void handleInsertTest(){
        Test.startTest(); 
        List<RE_Location__c> locList = new List<RE_Location__c>();
        
        RE_Job_Run_Audit__c jrAudit = RE_CND_TestDataFactory.createJobRunAudit('Automate','Canada Daily Reuters Quote Move','CA');
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc = new RE_Location__c();
        loc.RecordTypeId=locRecordID;
        loc.RE_Location_Code__c='C11';
        loc.Name='wf';
        loc.RE_Country_Name__c='XYZ';
        loc.RT_Active__c=TRUE;
        locList.add(loc);
        Database.SaveResult[] insertStatus= Database.insert(locList, false);
       	RE_CND_Utility.handleInsert('A','B',insertStatus,jrAudit);
		Test.stopTest();
    }
}