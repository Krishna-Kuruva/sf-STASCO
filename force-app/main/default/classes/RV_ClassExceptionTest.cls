@isTest
public class RV_ClassExceptionTest {
    
	static testMethod void TestInsert(){
        RV_ClassException.getInstance();
        RV_ClassException.insertExceptionRecord('ERROR', 'TEST', 'TEST', 'Test', 'Error');
        
        //Fix_Exception_04Sep2019_Soumyajit starts
        List<RV_Exception__c> excpList = new List<RV_Exception__c> ();
        RV_Exception__c rvExcep = new RV_Exception__c();
        rvExcep.Status_Code__c = 'ERROR';
        excpList.add(rvExcep);
        RV_ClassException.insertExceptionRecord(excpList);
        //Fix_Exception_04Sep2019_Soumyajit ends
    }
}