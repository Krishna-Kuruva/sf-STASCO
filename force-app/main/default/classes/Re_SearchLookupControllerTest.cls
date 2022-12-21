@isTest(SeeAllData=false)
private with sharing class Re_SearchLookupControllerTest {
    @isTest
    private static void testMethod1(){
        System.debug('testMethod1 starts');
        Id accountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution PH').getRecordTypeId();
        Account acc = RE_UtilityClass.createcustomer('Sample Direct Account','Sold To','123456','Direct','',accountRecordType);
        String objectName = 'Account';
        List<String> fields = new List<String>();
        fields.add('Name');
        String searchTerm = 'Sample';
        String findInField = '';
        String filterQuery = '';
        
        String findInField1 = 'NAME';
        String filterQuery1 ='RecordType.Name=\'Revolution PH\'';
        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{acc.Id});
        List<sObject> sobjectList0 = Re_SearchLookupController.lookupRecords(objectName, fields, searchTerm, findInField, filterQuery);
        List<sObject> sobjectList1 = Re_SearchLookupController.lookupRecords(objectName, fields, searchTerm, findInField, filterQuery1);
        List<sObject> sobjectList2 = Re_SearchLookupController.lookupRecords(objectName, fields, '', findInField, filterQuery1);
        System.assertEquals(1, sobjectList0.size(),'Match found');
        Test.stopTest();
    }
}