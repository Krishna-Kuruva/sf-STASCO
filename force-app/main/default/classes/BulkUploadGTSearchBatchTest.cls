@isTest
public class BulkUploadGTSearchBatchTest {
    public static string recTypeIDWonaCpt = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW CPT/BANK FORM').getRecordTypeId(); 
    public static string recTypeIDWonaIndvl = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW INDIVIDUAL FORM').getRecordTypeId();
    
	@testSetup static void setup() {
        // Create common test accounts
        List<BET_BDD_Form__c> formList = new List<BET_BDD_Form__c>();
        Profile prof = [select id from profile where name = 'BET User' LIMIT 1];
        User user1 = new User(Alias = 'batman',
                              Email='dwawdiwjdjawiojdij@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Wayne',
                              profileId=prof.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Is_COF_User__c=true,
                              Username = 'Tsawdwtdwidwaudiawdkkkkk@kiran.com',
                              TimeZoneSidKey='America/Chicago');
        insert user1;
        for(Integer i=0;i<20;i++) {
            BET_BDD_Form__c bddForm=new BET_BDD_Form__c(recordtypeId =recTypeIDWonaCpt,BDD_Entity_Type__c='Counterparty',Full_Legal_Name__c ='Test Name'+i,BDD_Line_of_Business__c='WONA',BDD_Onboard_Type__c='New Onboard',Assigned_COF__c =user1.Id,OwnerId=user1.Id);
        	formList.add(bddForm);
        }
        for(Integer i=0;i<20;i++) {
            BET_BDD_Form__c bddForm=new BET_BDD_Form__c(recordtypeId =recTypeIDWonaIndvl,BDD_Entity_Type__c='Counterparty',Full_Legal_Name__c ='Test Name'+i,BDD_Line_of_Business__c='WONA',BDD_Onboard_Type__c='New Onboard',Assigned_COF__c =user1.Id,OwnerId=user1.Id);
        	formList.add(bddForm);
        }
        insert formList;        
    }
    
    static testmethod void testgetNewBddFormId(){
        test.startTest();
        BulkUploadGTSearchBatch batchc = new BulkUploadGTSearchBatch();
        Database.executeBatch(batchc,50);
        test.stopTest();
        
    }
    
    static testmethod void testbatchMethod(){
        test.startTest();
        BulkUploadGTSearchBatch batchc = new BulkUploadGTSearchBatch(10);
        Database.executeBatch(batchc,50);
        test.stopTest();
        
    }
    
    static testmethod void testscheduler(){
        test.startTest();
        BulkUploadGTSearchBatchScheduler sh1 = new BulkUploadGTSearchBatchScheduler(1);
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test BulkUploadGTSearchBatchScheduler Check', sch, sh1); 
        Test.stopTest();
    }
}