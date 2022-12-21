@isTest
public class betGtAndMdnStatusChangeEmailBatchTest {
    static testmethod void testMthod(){
        Test.startTest();
        recordtype rc = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'SENA_NEW_CPTBNK' limit 1];
        recordtype rc2 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'GOLDTIER' limit 1];
        BET_BDD_Form__c bddform = new BET_BDD_Form__c();
        bddform.BDD_Entity_Type__c = 'Counterparty';
        bddform.BDD_Line_of_Business__c = 'SENA';
        bddform.BDD_Onboard_Type__c = 'New Onboard';
        bddform.MDN_OI_BusLine_multi__c='COAL';
        bddform.GT_Int_Business_Rel__c = 'test';
        bddform.MDN_CR_BusLine__c='COAL';
        bddform.MDN_BA_BusLine__c='COAL';
        bddform.RecordTypeId=rc.Id;
        bddform.MDN_CD_Rationale__c='Test';
        bddform.GT_Cust_Entity_Type_Class__c='Bank/Financial Institution | Co-operative';
        bddform.GT_Contact_With_CP__c='Test';
        bddform.GT_Rationale_OB_CP__c='Test';
        //below 2 fields newly added in GT
        bddform.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddform.GT_Relationship__c = 'End User';
        bddForm.MDN_OI_Business_Roles__c ='BROKER';
        try{
            insert bddform;}
        Catch(Exception e){
            system.debug('@@@@@######Exception:- '+e.getMessage());
        }
        //bddform.MDN_PC_Business_Line__c = 'Crude';
        bddform.GoldTier_Status__c = 'KYC Completed';
        bddform.MDN_Status__c = 'FOData Review';
        try{
            update bddform;
            //betGtAndMdnStatusChangeEmailBatch b = new betGtAndMdnStatusChangeEmailBatch ();
            //database.executebatch(b,200);
            betGtAndMdnStatusChangeEmailBatch testsche = new betGtAndMdnStatusChangeEmailBatch();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
        }
        Catch(Exception e){
            system.debug('@@@@@######Exception38line:- '+e.getMessage());
        }
        
        bddform.MDN_OI_BusLine_multi__c= Null;
        bddform.MDN_PC_Business_Line__c = 'Crude';
        try{
            update bddform;}
        Catch(Exception e){
            
        }
        
        BET_BDD_Address__c bddAddress1=new BET_BDD_Address__c(BDD_Form__c=bddform.id,Address_Type__c='Legal',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc2.id);
        insert bddAddress1;
        // BET_BDD_Address__c bddAddress2=new BET_BDD_Address__c(BDD_Form__c=bddform.id,Address_Type__c='Legal',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc3.id,PostCode__c='1234',State_Lkp__c=bddState.id,BusLine__c='COAL');
        // insert bddAddress2;
        
        // bddAddress2.SameAs_LegAdd__c=true;
        // bddAddress2.BusLine__c = 'COAL';
        // try{ update bddAddress2;}
        //   Catch(Exception e){ }
        
        bddform.MDN_OI_BusLine_multi__c='CREDIT PARENT LINE';
        bddform.GT_Cust_Entity_Type_Class__c='Bank/Financial Institution |';
        try {update bddform; }
        Catch(Exception e){ }
        bddform.MDN_OI_BusLine_multi__c='CREDIT PARENT LINE;Broker - Crude';
        bddform.BET_Status__c='Ready to Onboard';
        try{ update bddform; }
        Catch(Exception e){ }
        try{
            bddform.MDN_PC_Business_Line__c='Broker - Crude';
            update bddform;
        }catch(Exception e){}
        try{
            bddform.MDN_PC_Business_Line__c='';
            bddform.MDN_CR_BusLine__c='Broker - Crude';
            update bddform;
        }catch(Exception e){}
        bddform.MDN_CR_BusLine__c='COAL';
        try{
            bddform.MDN_BA_BusLine__c='Broker - Crude';
            update bddform;
        }catch(Exception e){}
        bddform.MDN_BA_BusLine__c='COAL';
        try{
            bddform.MDN_OI_BusLine_multi__c='';
            update bddform;
        }catch(Exception e){}
        try{
            bddform.MDN_OI_BusLine_multi__c='';
            bddform.MDN_PC_Business_Line__c='';
            bddform.MDN_CR_BusLine__c='';
            bddform.MDN_BA_BusLine__c='';
            update bddform;
        }catch(Exception e){}   
        Test.stopTest();
        
    }
}