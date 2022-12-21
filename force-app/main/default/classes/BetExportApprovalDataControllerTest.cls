@isTest
public class BetExportApprovalDataControllerTest {
    public static string recTypeIDWonaCpt = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW CPT/BANK FORM').getRecordTypeId(); 
    public static string recTypeIDWonaIndvl = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW INDIVIDUAL FORM').getRecordTypeId();
    public Static Id loggedInUser = UserInfo.getUserId();
    
    @testSetup static void setup() {
        // Create common test accounts
        List<BET_BDD_Form__c> formList = new List<BET_BDD_Form__c>();
        Profile prof = [select id from profile where name = 'BET User' LIMIT 1];
        User user1 = new User(Alias = 'batman',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Wayne',
                              profileId=prof.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Is_COF_User__c=true,
                              Username = 'Tstdwgyguwgdgdaaaa@kiran.com',
                              TimeZoneSidKey='America/Chicago');
        insert user1;
        for(Integer i=0;i<20;i++) {
            BET_BDD_Form__c bddForm=new BET_BDD_Form__c(recordtypeId =recTypeIDWonaCpt,BDD_Entity_Type__c='Counterparty',Full_Legal_Name__c ='Test Name'+i,BDD_Line_of_Business__c='WONA',BDD_Onboard_Type__c='New Onboard',Assigned_COF__c =user1.Id,OwnerId=user1.Id);
            bddform.IsSuccessInBulkBatch__c = true;
            bddform.BET_Status__c ='Draft';
            //bddform.BDD_Approver__c = loggedInUser;
            formList.add(bddForm);
        }
        for(Integer i=0;i<20;i++) {
            BET_BDD_Form__c bddForm=new BET_BDD_Form__c(recordtypeId =recTypeIDWonaIndvl,BDD_Entity_Type__c='Counterparty',Full_Legal_Name__c ='Test Name'+i,BDD_Line_of_Business__c='WONA',BDD_Onboard_Type__c='New Onboard',Assigned_COF__c =user1.Id,OwnerId=user1.Id);
            bddform.IsSuccessInBulkBatch__c = true;
            bddform.BET_Status__c ='Draft';
            //bddform.BDD_Approver__c = loggedInUser;
            formList.add(bddForm);
        }
        insert formList;        
    }
    
    static testmethod void testgetMyApprovalDataToExport(){
        test.startTest();
        Profile prof = [select id from profile where name = 'BET User' LIMIT 1];
        User user1 = new User(Alias = 'batman',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Wayne',
                              profileId=prof.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Is_Approver_User__c=true,
                              Username = 'Tstdwwwwwww@kiran.com',
                              TimeZoneSidKey='America/Chicago');
        insert user1;
        List<BET_BDD_Form__c>updateList = new List<BET_BDD_Form__c>();
            for(BET_BDD_Form__c obj : [select id,BDD_Approver__c from BET_BDD_Form__c]){
                obj.BDD_Approver__c = user1.Id;
                obj.GT_Legal_Name__c = 'TestLeagal';
            	obj.GT_BDD_Commodity__c ='Gas & Power';
            	obj.GT_Cust_Entity_Type_Class__c ='Non-Financial Business | Private Company';
                updateList.add(obj);
            }
            update updateList;
        System.runAs(user1){                       
            List<BET_BDD_Form__c> myapprovals = BetExportApprovalDataController.getMyApprovalDataToExport();
            system.assertNotEquals(0, myapprovals.size());
            test.stopTest();
        }
    }
    
    static testmethod void testgetBulkApprovalRecords(){
        test.startTest();
        Profile prof = [select id from profile where name = 'BET User' LIMIT 1];
        User user1 = new User(Alias = 'batman',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Wayne',
                              profileId=prof.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Is_Approver_User__c=true,
                              Username = 'Tst@kiran.com',
                              TimeZoneSidKey='America/Chicago');
        insert user1;
        List<BET_BDD_Form__c>updateList = new List<BET_BDD_Form__c>();
            for(BET_BDD_Form__c obj : [select id,BDD_Approver__c from BET_BDD_Form__c]){
                obj.BDD_Approver__c = user1.Id;
                obj.GT_Legal_Name__c = 'TestLeagal';
            	obj.GT_BDD_Commodity__c ='Gas & Power';
            	obj.GT_Cust_Entity_Type_Class__c ='Non-Financial Business | Private Company';
                updateList.add(obj);
            }
            update updateList;
        System.runAs(user1){
            List<BET_BDD_Form__c> myapprovals = BetExportApprovalDataController.getBulkApprovalRecords('','Name','asc');
            system.assertNotEquals(0, myapprovals.size());
            List<BET_BDD_Form__c> myapprovalsTest = BetExportApprovalDataController.getBulkApprovalRecords('Test','Name','asc');
            system.assertEquals(20, myapprovalsTest.size());
            test.stopTest();
        }
    }
    
}