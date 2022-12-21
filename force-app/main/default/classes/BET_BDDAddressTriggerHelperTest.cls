@isTest
public class BET_BDDAddressTriggerHelperTest {
    static testmethod void testsameAsLegalAddressUpdate(){
        recordtype rc1 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'GOLDTIER' limit 1];
        recordtype rc2 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'MDN' limit 1];
          Id docRecTypeIdSena = Schema.SObjectType.BET_BDD_Form__c.getRecordTypeInfosByDeveloperName().get('WONA_NEW_CPTBNK').getRecordTypeId();
        BET_BDD_Form__c bddForm=BET_BDD_SearchController_TestDataFactory.createBDDForm('WONA','Bank','New Onboard');
       bddForm.RecordTypeId = docRecTypeIdSena;
       bddForm.MDN_OI_Business_Roles__c ='BANK';
        insert bddForm;
        BET_BDD_Address__c addRec = new BET_BDD_Address__c(BDD_Form__c = bddForm.Id,Address_Type__c = 'Registered',Same_TR_AND_REGAdd__c = True,RecordTypeId=rc2.id);
        try{
            insert addRec;}
        catch(Exception e){
            System.debug(e);}
        BET_BDD_Address__c addRec1 = new BET_BDD_Address__c(BDD_Form__c = bddForm.Id,Address_Type__c = 'Legal',SameAs_LegAdd__c = True,RecordTypeId=rc1.id);
        insert addRec1;
        BET_BDD_Address__c addRec2 = new BET_BDD_Address__c(BDD_Form__c = bddForm.Id,Address_Type__c = 'Billing',SameAs_LegAdd__c = True,RecordTypeId=rc2.id,Same_TR_AND_REGAdd__c = True);
        try{
            insert addRec2;}
        catch(Exception e){
            System.debug(e);}
        BET_BDD_Address__c addRec3 = new BET_BDD_Address__c(BDD_Form__c = bddForm.Id,Address_Type__c = 'Invoice',SameAs_LegAdd__c = True,RecordTypeId=rc2.id);
        try{
            insert addRec3;}
        catch(Exception e){
            System.debug(e);}
        BET_BDD_Address__c addRec4 = new BET_BDD_Address__c(BDD_Form__c = bddForm.Id,Address_Type__c = 'Invoice',Same_TR_AND_REGAdd__c = True,RecordTypeId=rc2.id);
        try{
            insert addRec4;}
        catch(Exception e){
            System.debug(e);}
        bddForm.RecordTypeId = Schema.SObjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('WONA NEW CPT/BANK FORM').getRecordTypeId();
        try{
            update bddForm;}
        catch(Exception e){
            System.debug(e);}
        BET_BDD_Address__c addRec5 = new BET_BDD_Address__c(BDD_Form__c = bddForm.Id,Address_Type__c = 'Registered',BusLine__c = 'Crude',RecordTypeId=rc2.id);
        try{
            insert addRec5;
            addRec5.AddLine1__c = 'test';
            update addRec5;}
        catch(Exception e){
            System.debug(e);} 
    }
    
}