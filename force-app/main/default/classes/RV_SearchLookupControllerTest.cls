@isTest
public class RV_SearchLookupControllerTest {
	static testMethod void testMethod1(){
        String objectName = 'Account';
        List<String> fields = new List<String>();
        fields.add('Name');
        String searchTerm = 'Test';
        String findInField = '';
        String filterQuery ='';
        
        String findInField1 = 'NAME';
        String filterQuery1 ='Name in (\'Test\')';
        
        Test.startTest();
        RV_SearchLookupController.search(objectName,fields, searchTerm, findInField, filterQuery);
        RV_SearchLookupController.search(objectName,fields, searchTerm, findInField1, filterQuery1);
        Test.stopTest();
    }
}