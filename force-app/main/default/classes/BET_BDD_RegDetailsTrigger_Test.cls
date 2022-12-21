@isTest
public class BET_BDD_RegDetailsTrigger_Test {
    @testSetup static void setup() {
        //insert user
        Profile prof = [select id from profile where name = 'System Administrator'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'BETTest123@test.com';
        user.email = 'BETTest123@test.com';
        user.alias = 'BET User';
        user.EmailEncodingKey = 'ISO-8859-1';
		user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.UserRoleId = null;
        insert user;
        
        //insert BET user
        Profile BETProf = [select id from profile where name LIKE '%BET User%'];
        User BETUser = new User();
        BETUser.firstName = 'test1';
        BETUser.lastName = 'test2';
        BETUser.profileId = BETProf.id;
        BETUser.username = 'BETTest456@test.com';
        BETUser.email = 'BETTest456@test.com';
        BETUser.alias = 'BET User';
        BETUser.EmailEncodingKey = 'ISO-8859-1';
		BETUser.LanguageLocaleKey = 'en_US';
        BETUser.LocaleSidKey = 'en_US';
        BETUser.TimeZoneSidKey = 'America/Los_Angeles';
        BETUser.UserRoleId = null;
        BETUser.Is_COF_User__c = true;
        insert BETUser;
        
        System.runAs(user) {
            //assign cof permission set
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'BET_COF'];
            if(ps != null){
                PermissionSetAssignment psa = new PermissionSetAssignment
                    (PermissionSetId = ps.Id, AssigneeId = BETUser.Id);
                insert psa;  
            }   
        }        
        
        System.runAs(BETUser){
            //insert GLOBAL Test Record
            recordtype rc2 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'GOLDTIER' limit 1];
            recordtype rc6 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'GLOBAL_NEW_VES' limit 1];
            recordtype rc3 = [Select Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Document__c' and developername = 'GLOBAL' limit 1];
            BET_BDD_Form__c globalForm = new BET_BDD_Form__c();
            globalForm.BDD_Entity_Type__c = 'Vessel';
            globalForm.BDD_Line_of_Business__c = 'GLOBAL';
            globalForm.BDD_Onboard_Type__c = 'New Onboard';
            globalForm.GT_Cust_Entity_Type_Class__c = 'Bank/Financial Institution | Co-operative';
            globalForm.GT_BDD_Region_Role_Comm__c = 'ANZPI | Bank for LC';
            //commented by Ashish J. on 20/09/2021 for changing the field type to Multiselect picklist
            //globalForm.GT_BDD_Commodity__c = 'Crude';
            //globalForm.GT_BDD_Business_Division__c = 'Crude Global';
            globalForm.GT_Desk__c = 'test';
            globalForm.GT_Short_Name__c = 'test';
            globalForm.GT_Legal_Name__c = 'test';
            globalForm.GT_Ship_ID_Num_IMO__c = 'test';
            globalForm.GT_Entity_Type__c = 'Fund';
            globalForm.GT_Req_Name__c = 'test';
            globalForm.GT_Is_Rem__c = 'No';
            globalForm.RecordTypeId = rc6.Id;
            globalForm.GT_Legal_Name__c = 'GlobalForm_RecordLock_Test';
            globalForm.BET_Status__c = 'Draft';
            globalForm.Assigned_COF__c = BETUser.Id;
            globalForm.GT_Product_Risk__c = 'Low';      
            //below 2 fields newly added in GT
        	globalForm.GT_Type_Of_RelationShip__c = 'Basic Customer';
        	globalForm.GT_Relationship__c = 'End User';
            try{
                insert globalForm;
            }catch(exception ex){
                system.debug('Inserting BET form from Test Setup method >> ' + ex.getMessage());
            }
            
            //insert address records
            BET_BDD_Address__c bddAddress1 = new BET_BDD_Address__c(BDD_Form__c=globalForm.id,Address_Type__c='Operating',
                                                                    Country__c='Germany',AddLine1__c='Test',
                                                                    City__c='Berlin',RecordTypeId=rc2.id);
            BET_BDD_Address__c bddAddress2 = new BET_BDD_Address__c(BDD_Form__c=globalForm.id,Address_Type__c='Legal',Country__c='Germany',
                                                                    AddLine1__c='Test',City__c='Berlin',County__c = '12234',
                                                                    RecordTypeId=rc2.id);
            insert bddAddress1;
            insert bddAddress2;
            
            //insert doc record
            BET_BDD_Document__c bddDocGlo3 = new BET_BDD_Document__c(BET_Document__c = 'Vessel Report',BET_Document_Type__c='Vessel Report',
                                                                     BET_BDD_Form__c=globalForm.Id,BET_Section__c = 'GT',
                                                                     BET_IDD_Link__c = 'test',RecordTypeId = rc3.Id);
            BET_BDD_Document__c bddDocGlo4 = new BET_BDD_Document__c(BET_Document__c = 'OFAC IMO Check',BET_Document_Type__c='Other Screening Document',
                                                                     BET_BDD_Form__c=globalForm.Id,BET_Section__c = 'GT',
                                                                     BET_IDD_Link__c = 'test',RecordTypeId = rc3.Id);   
            insert bddDocGlo3;
            insert bddDocGlo4;
            
            globalForm.BET_Status__c = 'Ready to Onboard';
			globalForm.BDD_Eligible_Status__c='Yes';
            update globalForm;
        }
    }
    
    @isTest static void testRecordLockForInsert() {
        List<BET_BDD_Form__c> BETFormsList = [Select Id from BET_BDD_Form__c where GT_Legal_Name__c = 'GlobalForm_RecordLock_Test'];
        Test.startTest();
        if(BETFormsList.size() > 0){
            BET_Registration_Details__c RegDet = new BET_Registration_Details__c();
            RegDet.BDD_Form__c = BETFormsList[0].Id;
            RegDet.Registration_ID__c = 'REG1234';
            RegDet.Registration_ID_Type__c = 'LEI';
            try{
                insert RegDet;
            }catch(exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Only ‘BET Status’ is editable at this stage.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        }
        Test.stopTest();
    }
    
    @isTest static void testRecordLockForUpdateAndDelete() {
        Test.startTest();
        BET_BDD_Form__c BETForm = [Select Id from BET_BDD_Form__c where GT_Legal_Name__c = 'GlobalForm_RecordLock_Test'];
        if(BETForm != null){
            BETForm.BET_Status__c = 'Draft';
            update BETForm;
            
            BET_Registration_Details__c RegDet = new BET_Registration_Details__c();
            RegDet.BDD_Form__c = BETForm.Id;
            RegDet.Registration_ID__c = 'REG1234';
            RegDet.Registration_ID_Type__c = 'LEI';
            insert RegDet;   
            
            BETForm.BET_Status__c = 'Ready to Onboard';
            update BETForm;
            
            //Update reg details record
            BET_Registration_Details__c RegDetailsRec = [Select Id, Registration_ID__c from BET_Registration_Details__c where 
                                                         Registration_ID__c = 'REG1234'];
            RegDetailsRec.Registration_ID__c = 'REG4567';
            try{
                update RegDetailsRec;
            }catch(exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Only ‘BET Status’ is editable at this stage.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            try{
                Delete RegDet;
            }catch(exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Only ‘BET Status’ is editable at this stage.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        }
        Test.stopTest();
    }
}