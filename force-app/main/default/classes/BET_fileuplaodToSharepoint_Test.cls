@isTest
public class BET_fileuplaodToSharepoint_Test {
    
    public static Id test_GTMIApi() {
      
        BET_BDD_Form__c bddform = new BET_BDD_Form__c();
        bddform.BDD_Entity_Type__c = 'Bank';
        bddform.BDD_Line_of_Business__c = 'WONA';
        bddform.BDD_Onboard_Type__c = 'New Onboard';
        bddform.MDN_PC_Type__c = 'Main';
        bddform.BET_Status__c = 'Draft';
        
        insert bddform;
        Id docRecTypeId = Schema.SObjectType.BET_BDD_Document__c.getRecordTypeInfosByDeveloperName().get('WONA').getRecordTypeId();
        BET_BDD_Document__c bddDoc1 = new BET_BDD_Document__c(BET_Manual_Upload__c=true,BET_Source__c = 'Orbis',BET_Document__c = '3rd Party Report',BET_Retry__c = false,BET_Upload_Status__c = 'In Progress',BET_BDD_Form__c=bddform.Id,BET_Section__c = 'GT',BET_Document_Type__c='3rd Party Report',BET_SharePoint_Fld_Name__c='HSBC Bank USA National Association - Bank - 09172020',RecordTypeId=docRecTypeId);
        
        insert bddDoc1;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        
            insert contentVersion;  
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = bddDoc1.id;
        cdl.ContentDocumentId = conDoc;
        cdl.shareType = 'V';
        insert cdl;
        
        return bdddoc1.Id;
      
    }
    
     static testmethod void test_UploadTest() {
         
            Id DocId;
            Profile prof = [select id from profile where name = 'System Administrator'];
            User user = new User(Alias = 'batman',
            Email='testtermsconditions1234423@kaplan.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            profileId=prof.Id,
            LocaleSidKey='en_US',
            LanguageLocaleKey='en_US',
            Username = 'Tst@kiran.com',
            TimeZoneSidKey='America/Chicago');
            system.runAs(user){
       
           DocId = test_GTMIApi();
}	
         User u=[SELECT Id from User where id=:userinfo.getUserId()];
         System.runas(u){
         Test.StartTest();
       // BET_fileuplaodToSharepoint.indicateExternalSystem(bddDoc1);
       Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis()); 
        BET_fileuplaodToSharepoint.indicateExternalSystem(DocId);
             Test.StopTest();}
         

         
     }
}