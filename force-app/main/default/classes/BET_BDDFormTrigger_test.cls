@isTest
public class BET_BDDFormTrigger_test {
    static testmethod void testTrigger1(){
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
        bddform.MDN_PC_Business_Line__c = 'Crude';
         try{
            update bddform;}
        Catch(Exception e){
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
     static testmethod void testTrigger2(){
         Test.startTest();
          recordtype rc1 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'STUSCO_NEW_CPTBNK' limit 1];
        recordtype rc2 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'GOLDTIER' limit 1];
      //   recordtype rc3 = [Select Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Document__c' and developername = 'STUSCO' limit 1];
           BET_BDD_Form__c bddform1 = new BET_BDD_Form__c();
        bddform1.BDD_Entity_Type__c = 'Counterparty';
        bddform1.BDD_Line_of_Business__c = 'STUSCO';
        bddform1.BDD_Onboard_Type__c = 'New Onboard';
        bddform1.MDN_OI_BusLine_multi__c='COAL';
        bddform1.MDN_CR_BusLine__c='COAL';
        bddform1.MDN_BA_BusLine__c='COAL';
        bddform1.MDN_OI_Business_Line__c='Crude Lease Royalty';
        bddform1.RecordTypeId=rc1.Id;
        bddform1.MDN_Setup_CP_Bank__c='Yes';
        bddform1.MDN_BA_BankName__c='Test';
        bddform1.MDN_BA_Acc_Num__c='1234';
        bddform1.MDN_BA_EPayment__c='Yes-Wire';
        bddform1.GT_Cust_Entity_Type_Class__c='Vessel';
        //below 2 fields newly added in GT
        bddform1.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddform1.GT_Relationship__c = 'End User';
        try{  insert bddform1; }
         Catch(Exception e){ }
        BET_BDD_Address__c bddAddress=new BET_BDD_Address__c(BDD_Form__c=bddform1.id,Address_Type__c='Main',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc2.id);
        try{  insert bddAddress;}
         Catch(Exception e){ }
       // BET_BDD_Address__c bddAddress10=new BET_BDD_Address__c(BDD_Form__c=bddform1.id,Address_Type__c='Main',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc3.id,PostCode__c='1234',State_Lkp__c=bddState.id,BusLine__c='COAL');
       // try{ insert bddAddress10;}
       //  Catch(Exception e){ }
        bddform1.BET_Status__c='Ready to Onboard';
        try{  update bddform1; }
        Catch(Exception e){ }
        bddform1.BET_Status__c='Draft';
          try{  update bddform1; }
        Catch(Exception e){ }
         bddform1.MDN_OI_Business_Line__c='Crude Lease Net';
        bddform1.MDN_OI_Div__c = '02 - Fuels';
        bddform1.MDN_OI_DistChan__c = '06 - Supply';
        bddform1.MDN_OI_TerAgmt__c = 'Yes';
        bddform1.BET_Status__c='Ready to Onboard';
        try{  update bddform1; }
        Catch(Exception e){ }
         bddform1.BET_Status__c='Draft';
          try{  update bddform1; }
        Catch(Exception e){ }
         bddform1.MDN_OI_Business_Line__c='Products';
         bddform1.MDN_OI_Div__c = Null;
        bddform1.MDN_OI_DistChan__c = Null;
        bddform1.MDN_OI_TerAgmt__c = Null;
        bddform1.MDN_OI_LPSNum__c = 'test';
        bddform1.MDN_OI_FedWat__c = 'Yes';
        bddform1.BET_Status__c='Ready to Onboard';
        try{  update bddform1; }
        Catch(Exception e){ }
      //  BET_BDD_Document__c bddDoc3 = new BET_BDD_Document__c(BET_Manual_Upload__c=false,BET_Source__c = 'Other',BET_Document__c = '3rd Party Report',BET_Retry__c = true,BET_Upload_Status__c = 'Failed',BET_BDD_Form__c=bddform1.Id,BET_Section__c = 'MDN',BET_Document_Type__c='3rd Party Report',BET_SharePoint_Fld_Name__c='HSBC Bank',RecordTypeId = rc3.Id);
       // insert bddDoc3;
        Test.stopTest();

     }
    static testmethod void testTrigger3(){
        Test.startTest();
        // recordtype rc3 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'MDN' limit 1];
        recordtype rc5 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'WONA_NEW_CPTBNK' limit 1];
         BET_BDD_Form__c bddform2 = new BET_BDD_Form__c();
        bddform2.BDD_Entity_Type__c = 'Counterparty';
        bddform2.BDD_Line_of_Business__c = 'WONA';
        bddform2.BDD_Onboard_Type__c = 'New Onboard';
        bddform2.MDN_OI_BusLine_multi__c='COAL';
        bddform2.MDN_CR_BusLine__c='COAL';
        bddform2.MDN_BA_BusLine__c='COAL';
        bddform2.RecordTypeId=rc5.Id;
        bddform2.MDN_CD_Rationale__c='Test';
        bddform2.GT_Cust_Entity_Type_Class__c='Bank/Financial Institution | Co-operative';
        bddform2.GT_Contact_With_CP__c='Test';
        bddform2.GT_Rationale_OB_CP__c='Test';
        //below 2 fields newly added in GT
        bddform2.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddform2.GT_Relationship__c = 'End User';
        try{ insert bddform2; }
         Catch(Exception e){ }
        
        
        
     //   BET_BDD_Address__c bddAddress3=new BET_BDD_Address__c(BDD_Form__c=bddform2.id,Address_Type__c='Registered',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc3.id);
      //  insert bddAddress3;
     //   BET_BDD_Address__c bddAddress4=new BET_BDD_Address__c(BDD_Form__c=bddform2.id,Address_Type__c='Registered',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc3.id,PostCode__c='1234',State_Lkp__c=bddState.id,BusLine__c='COAL');
     //   insert bddAddress4;
        
        
        bddform2.MDN_CD_Rationale__c='Ready to Onboard';
        try {update bddform2;}
         Catch(Exception e){ }   
         Test.stopTest();
    }
    static testmethod void testTrigger4(){
          Test.startTest();
        recordtype rc2 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'GOLDTIER' limit 1];
         recordtype rc3 = [Select Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Document__c' and developername = 'WONA' limit 1];
        Id rc4 = Schema.SObjectType.BET_BDD_Form__c.getRecordTypeInfosByDeveloperName().get('WONA_NEW_CPTBNK').getRecordTypeId();
        BET_BDD_Form__c globalForm = new BET_BDD_Form__c();
         globalForm.BDD_Entity_Type__c = 'Counterparty';
        globalForm.BDD_Line_of_Business__c = 'WONA';
        globalForm.RecordTypeId = rc4;
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
        //below 2 fields newly added in GT
        globalForm.GT_Type_Of_RelationShip__c = 'Basic Customer';
        globalForm.GT_Relationship__c = 'End User';
        globalForm.MDN_OI_Business_Roles__c ='BANK';
        try {insert globalForm;}
         Catch(Exception e){ }
        globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
         Catch(Exception e){ }
        globalForm.BET_Status__c = 'Draft';
         try {update globalForm;}
         Catch(Exception e){ }
        BET_BDD_Address__c bddAddressGlo=new BET_BDD_Address__c(BDD_Form__c=globalForm.id,Address_Type__c='Legal',Country__c='Germany',City__c='Berlin',RecordTypeId=rc2.id);
        insert bddAddressGlo;
        BET_BDD_Address__c bddAddressGloOpp=new BET_BDD_Address__c(BDD_Form__c=globalForm.id,Address_Type__c='Operating',AddLine1__c='Test',Country__c='Germany',City__c='Berlin',RecordTypeId=rc2.id);
        try{insert bddAddressGloOpp;}
        Catch(Exception e){ }
        globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
         Catch(Exception e){ }
         globalForm.BET_Status__c = 'Draft';
         try {update globalForm;}
         Catch(Exception e){ }
        bddAddressGlo.AddLine1__c='Test';
        update bddAddressGlo;
        globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
         Catch(Exception e){ }
         globalForm.BET_Status__c = 'Draft';
         try {update globalForm;}
         Catch(Exception e){ }
         BET_BDD_Document__c bddDocGlo3 = new BET_BDD_Document__c(BET_Document__c = '3rd Party Report',BET_Document_Type__c='3rd Party Report',BET_BDD_Form__c=globalForm.Id,BET_IDD_Link__c = 'test',BET_Section__c = 'GT',RecordTypeId = rc3.Id);
         insert bddDocGlo3;
         globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
         Catch(Exception e){ }  
         Test.stopTest();
    } 
     static testmethod void testTrigger5(){
         Test.startTest();
         recordtype rc2 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'GOLDTIER' limit 1];
       recordtype rc6 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'GLOBAL_NEW_VES' limit 1];
   //  Id�docRecTypeId�=�Schema.SObjectType.BET_BDD_Document__c.getRecordTypeInfosByDeveloperName().get('GLOBAL').getRecordTypeId(); 
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
         //below 2 fields newly added in GT
        globalForm.GT_Type_Of_RelationShip__c = 'Basic Customer';
        globalForm.GT_Relationship__c = 'End User';
        try {insert globalForm;}
         Catch(Exception e){ }
        globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
         Catch(Exception e){ }
        globalForm.BET_Status__c = 'Draft';
         try {update globalForm;}
         Catch(Exception e){ }
         globalForm.GT_Product_Risk__c = 'High';
                  try {update globalForm;}
         Catch(Exception e){ }
     //   BET_BDD_Address__c bddAddressGlo=new BET_BDD_Address__c(BDD_Form__c=globalForm.id,Address_Type__c='Legal',Country__c='Germany',City__c='Berlin',RecordTypeId=rc2.id);
      //  insert bddAddressGlo;
        BET_BDD_Address__c bddAddressGloOpp=new BET_BDD_Address__c(BDD_Form__c=globalForm.id,Address_Type__c='Operating',AddLine1__c='Test',Country__c='Germany',City__c='Berlin',RecordTypeId=rc2.id);
        insert bddAddressGloOpp;
        globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
          Catch(Exception e){ }
          globalForm.BET_Status__c = 'Draft';
         try {update globalForm;}
          Catch(Exception e){ }
          BET_BDD_Address__c bddAddressGlo=new BET_BDD_Address__c(BDD_Form__c=globalForm.id,Address_Type__c='Legal',Country__c='Germany',City__c='Berlin',RecordTypeId=rc2.id);
        insert bddAddressGlo;
          globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
          Catch(Exception e){ }
         globalForm.BET_Status__c = 'Draft';
         try {update globalForm;}
         Catch(Exception e){ }
        bddAddressGlo.AddLine1__c='Test';
        update bddAddressGlo;
        globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
         Catch(Exception e){ }
         globalForm.BET_Status__c = 'Draft';
         try {update globalForm;}
         Catch(Exception e){ }
         BET_BDD_Document__c bddDocGlo3 = new BET_BDD_Document__c(BET_Document__c = 'Vessel Report',BET_Document_Type__c='Vessel Report',BET_BDD_Form__c=globalForm.Id,BET_Section__c = 'GT',BET_IDD_Link__c = 'test',RecordTypeId = rc3.Id);
         insert bddDocGlo3;
         globalForm.BET_Status__c = 'Ready to Onboard';
         try {update globalForm;}
         Catch(Exception e){ } 
        Test.stopTest();
     }
    static testmethod void testTrigger6(){
        Test.startTest();
         recordtype rc1 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'STUSCO_NEW_CPTBNK' limit 1];
          recordtype rc = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'SENA_NEW_CPTBNK' limit 1];
        recordtype rc3 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'MDN' limit 1];
        recordtype rc5 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'WONA_NEW_CPTBNK' limit 1];
  final String WonaCreditInfo = 'MDN_CR_Lim_req__c;MDN_CR_Ant_FirstTrade_Date__c;MDN_CR_Price__c;MDN_CR_PhyFin__c;MDN_CR_PurchSale__c;MDN_CR_PriceType__c;MDN_CR_BusLine__c;MDN_CR_IntRelations__c';
     final String SenaCreditInfo = 'MDN_CR_CredType__c;MDN_CR_Lim_req__c;MDN_CR_Credit_Limit__c;MDN_CR_StartDate__c;MDN_CR_LocationPP__c;MDN_CR_VolFreq__c;MDN_CR_Commodity__c;MDN_CR_EndDate__c;MDN_CR_Price__c;MDN_CR_PhyFin__c;MDN_CR_Cur__c;MDN_CR_Vol__c;MDN_CR_PurchSale__c;MDN_CR_Units__c;MDN_CR_BusLine__c;MDN_CR_IntRelations__c';
     final String StuscoCreditInfo = 'MDN_CR_StartDate__c;MDN_CR_LocationPP__c;MDN_CR_VolFreq__c;MDN_CR_Commodity__c;MDN_CR_EndDate__c;MDN_CR_Price__c;MDN_CR_PhyFin__c;MDN_CR_Cur__c;MDN_CR_Vol__c;MDN_CR_PurchSale__c;MDN_CR_Units__c;MDN_CR_IntRelations__c';
        BET_BDD_Form__c bddForma=BET_BDD_SearchController_TestDataFactory.createBDDForm('WONA','Bank','New Onboard');
         bddForma.RecordTypeId =rc5.Id;
         bddForma.MDN_OI_BusLine_multi__c = 'Crude';
        bddForma.MDN_CR_Lim_req__c = 'No';
            bddForma.MDN_CR_Ant_FirstTrade_Date__c = System.today();
            bddForma.MDN_CR_Price__c = '23';
            bddForma.MDN_CR_PhyFin__c = 'Physical';
            bddForma.MDN_CR_PurchSale__c = 'Purchase';
            bddForma.MDN_CR_PriceType__c = 'Fixed';
            bddForma.MDN_CR_BusLine__c = 'Crude';
            bddForma.MDN_CR_IntRelations__c = 'test';
        bddForma.MDN_CP_Rel_Desc__c = 'Counterparty';
        //below 2 fields newly added in GT
        bddForma.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddForma.GT_Relationship__c = 'End User';
        bddForma.MDN_OI_Business_Roles__c ='BANK';
           insert bddForma;
        BET_BDDFormTriggerUtil.isCreditInfoFilled(bddForma);
         BET_BDD_Form__c bddFormb=BET_BDD_SearchController_TestDataFactory.createBDDForm('SENA','Bank','New Onboard');
       bddFormb.RecordTypeId =rc.Id;
          bddFormb.MDN_OI_BusLine_multi__c = 'Crude';
        //below 2 fields newly added in GT
        bddFormb.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddFormb.GT_Relationship__c = 'End User';
        bddFormb.MDN_OI_Business_Roles__c ='BROKER';
             insert bddFormb;
         BET_BDD_Form__c bddFormc=BET_BDD_SearchController_TestDataFactory.createBDDForm('STUSCO','Bank','New Onboard');
       bddFormc.RecordTypeId =rc1.Id;
        //below 2 fields newly added in GT
        bddFormc.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddFormc.GT_Relationship__c = 'End User';
        bddFormc.MDN_OI_Func__c = 'Trading';
            insert bddFormc;
        BET_BDD_Address__c bddAddress3=new BET_BDD_Address__c(BDD_Form__c=bddFormc.id,Address_Type__c='Invoice',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc3.Id);
        BET_BDD_Address__c bddAddress1=new BET_BDD_Address__c(BDD_Form__c=bddForma.id,Address_Type__c='Registered',BusLine__c = 'Crude',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc3.id);
        BET_BDD_Address__c bddAddress2=new BET_BDD_Address__c(BDD_Form__c=bddFormb.id,Address_Type__c='Legal',Country__c='Germany',AddLine1__c='Test',BusLine__c = 'Crude',City__c='Berlin',County__c = '12234',RecordTypeId=rc3.id);
        
             insert bddAddress3;
             insert bddAddress1;
             insert bddAddress2;
            bddAddress1.BusLine__c = 'Crude';
         	bddAddress2.BusLine__c = 'Crude';
         update bddAddress1;
         update bddAddress2;
			         	
         
        List<BET_BDD_Address__c> addLst1 = new List<BET_BDD_Address__c>();
         BET_BDD_Address__c addrec1 = [Select Name,Id,Section__c,BusLine__c,Address_Type__c,Country__c,AddLine1__c,City__c,State_Lkp__c,PostCode__c from BET_BDD_Address__c where Id =: bddAddress1.Id];
        List<BET_BDD_Address__c> addLst = new List<BET_BDD_Address__c>();
         addLst.add(addrec1);
         BET_BDDFormTriggerHelper.addressFieldsFilled(addLst,'WONA');
           BET_BDD_Address__c addrec2 = [Select Name,Id,Section__c,BusLine__c,County__c,Address_Type__c,Country__c,AddLine1__c,City__c,State_Lkp__c,PostCode__c from BET_BDD_Address__c where Id =: bddAddress2.Id];
           addLst1.add(addrec2);
         BET_BDDFormTriggerHelper.addressFieldsFilled(addLst1,'SENA');
          BET_BDD_Address__c addrec3 = [Select Name,Id,Section__c,BusLine__c,Address_Type__c,Country__c,AddLine1__c,City__c,State_Lkp__c,PostCode__c from BET_BDD_Address__c where Id =: bddAddress3.Id];
        List<BET_BDD_Address__c> addLst2 = new List<BET_BDD_Address__c>();
         addLst2.add(addrec3);
         BET_BDDFormTriggerHelper.addressFieldsFilled(addLst2,'STUSCO');   
         Test.stopTest();
    }
    static testmethod void testTrigger(){
        recordtype rc = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'SENA_NEW_CPTBNK' limit 1];
        recordtype rc1 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'STUSCO_NEW_CPTBNK' limit 1];
        recordtype rc2 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'GOLDTIER' limit 1];
        recordtype rc3 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Address__c' and developername = 'MDN' limit 1];
        recordtype rc4 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Country_vs_States__c' and developername = 'State' limit 1];
        recordtype rc5 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'WONA_NEW_CPTBNK' limit 1];
        recordtype rc6 = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'BET_BDD_Form__c' and developername = 'GLOBAL_NEW_VES' limit 1];
     
        BET_BDD_Country_vs_States__c bddState=new BET_BDD_Country_vs_States__c(Country__c='Germany',RecordTypeId=rc4.id,State__c='Berlin');
        insert bddState;  
   		 
       
       
       
       
        Profile prof1 = [select id from profile where name = 'System Administrator' LIMIT 1];
        User user1 = new User(Alias = 'batmanss',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Waynsse',
                              profileId=prof1.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Username = 'Tstsdsd@kiran.com',
                              TimeZoneSidKey='America/Chicago');
        
        Profile prof = [select id from profile where name = 'BET User' LIMIT 1];
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
        
        User user2 = new User(Alias = 'test',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Waynedsds',
                              profileId=prof.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Username = 'Tst@kiranddf.com',
                              TimeZoneSidKey='America/Chicago');
        
        User user3 = new User(Alias = 'testM',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='WaynedsDSds',
                              profileId=prof.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Username = 'TstD@kiranddf.com',
                              TimeZoneSidKey='America/Chicago');
        System.runAs(user1){
            
            insert user;
            List<PermissionSet> perm=[SELECT ID,Name From PermissionSet WHERE Name='BET_COF' OR Name='BET_Eligible_Approver' OR Name='BET_Trader'];
            List<PermissionSetAssignment> lstAssgn=new List<PermissionSetAssignment>();
            for(PermissionSet per:perm){
                System.debug('per'+per.name);
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =per.Id, AssigneeId = user.Id);
                lstAssgn.add(psa);
            }	        
            
            insert user2;
            for(PermissionSet per:perm){
                if(per.name=='BET_Eligible_Approver'){
                    PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =per.Id, AssigneeId = user2.Id);
                    lstAssgn.add(psa);}
            }
    
            insert user3;
            for(PermissionSet per:perm){
                if(per.name=='BET_COF'){
                    PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId =per.Id, AssigneeId = user3.Id);
                    lstAssgn.add(psa);}
            }
            insert lstAssgn;
            update user;
            update user2;
            update user3;
            
        } 
        System.runAs(user3){
            BET_BDD_Form__c globalForm1 = new BET_BDD_Form__c();
         globalForm1.BDD_Entity_Type__c = 'Counterparty';
        globalForm1.BDD_Line_of_Business__c = 'WONA';
        globalForm1.BDD_Onboard_Type__c = 'New Onboard';
        globalForm1.GT_Cust_Entity_Type_Class__c = 'Bank/Financial Institution | Co-operative';
        globalForm1.GT_BDD_Region_Role_Comm__c = 'ANZPI | Bank for LC';
        //commented by Ashish J. on 20/09/2021 for changing the field type to Multiselect picklist
        //globalForm1.GT_BDD_Commodity__c = 'Crude';
        //globalForm1.GT_BDD_Business_Division__c = 'Crude Global';
        globalForm1.GT_Desk__c = 'test';
        globalForm1.GT_Short_Name__c = 'test';
        globalForm1.GT_Legal_Name__c = 'test';
        globalForm1.GT_Ship_ID_Num_IMO__c = 'test';
        globalForm1.GT_Entity_Type__c = 'Fund';
        globalForm1.GT_Req_Name__c = 'test';
         globalForm1.RecordTypeId = rc5.Id; 
            //below 2 fields newly added in GT
        globalForm1.GT_Type_Of_RelationShip__c = 'Basic Customer';
        globalForm1.GT_Relationship__c = 'End User';
        try {insert globalForm1;}
         Catch(Exception e){ }
       globalForm1.Full_Legal_Name__c = 'test';
            try {update globalForm1;}
         Catch(Exception e){ }
              globalForm1.BET_Status__c = 'Ready for BDD Approver';
            try {update globalForm1;}
         Catch(Exception e){ }
             globalForm1.BET_Status__c = 'Ready for COF';
            try {update globalForm1;}
         Catch(Exception e){ }
             globalForm1.GT_OTC__c = 'test';
             try {update globalForm1;}
         Catch(Exception e){ }
            
        }
     
        System.runAs(user){
          /*  try{
                System.debug('herehere');
                bddform2.GT_BDD_Region_Role_Comm__c='ANZPI | Bank for LC';
                bddform2.GT_Legal_Name__c='Test';
                bddform2.BDD_Approver__c=user.id;
                update bddform2;
                bddform2.BET_Status__c='Ready for BDD Approver';
                update bddform2;
                bddform2.BET_Status__c='Ready to Onboard';
                update bddform2;
                bddform2.BET_Status__c='Draft';
                update bddform2;
            }catch(Exception e){} */
            
        }
       // Savepoint sp;
        System.runAs(user2){
           /* try{
                bddform2.BET_Status__c='Draft';
                update bddform2;
                bddform2.BET_Status__c='Draft';
                bddform2.MDN_CD_Rationale__c='Draft';
                update bddform2;
                throw new MyException('Test');
            }catch(Exception e){
                Boolean test=e.getMessage().contains('Approver')?True:False;
                System.assertEquals(test, True);
            }
            try{
                System.debug('bddform2.MDN_CD_Rationale__c'+bddform2.MDN_CD_Rationale__c);
                bddform2.MDN_CD_Rationale__c='Ready to Onboard';
                bddform2.BET_Status__c='Ready to Onboard';
                bddform2.BDD_AppCom__c ='Draft';
                update bddform2;
            }catch(Exception e){} */
            
        }
        
        BET_BDD_Form__c bddform3 = new BET_BDD_Form__c();
        bddform3.BDD_Entity_Type__c = 'Vessel';
        bddform3.BDD_Line_of_Business__c = 'GLOBAL';
        bddform3.BDD_Onboard_Type__c = 'New Onboard';
        bddform3.MDN_OI_BusLine_multi__c='COAL';
        bddform3.MDN_CR_BusLine__c='COAL';
        bddform3.MDN_BA_BusLine__c='COAL';
        bddform3.RecordTypeId=rc6.Id;
        bddform3.MDN_CD_Rationale__c='Test';
        bddform3.GT_Cust_Entity_Type_Class__c='Bank/Financial Institution | Co-operative';
        bddform3.GT_Contact_With_CP__c='Test';
        bddform3.GT_Rationale_OB_CP__c='Test';
           //below 2 fields newly added in GT
        bddform3.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddform3.GT_Relationship__c = 'End User';
        insert bddform3;
        
        BET_BDD_Address__c bddAddress33=new BET_BDD_Address__c(BDD_Form__c=bddform3.id,Address_Type__c='Legal',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId = rc2.Id);
        insert bddAddress33;
        
        System.runAs(user3){
            try{
                bddform3.BET_Status__c='Ready to Onboard';
                update bddform3;}
            catch(Exception e){}
            bddform3.GT_First_Name__c = 'test';
            try{update bddform3;}
            catch(Exception e){}
        }
        System.runAs(user3){
          bddform3.BET_Status__c='Ready for BDD Approver';
            try{update bddform3;}
            catch(Exception e){}
             //commented by Ashish J. on 28/09/2021 for changing the field type to picklist
             //bddform3.GT_GI__c='test'; 
             try{update bddform3;}
            catch(Exception e){}
        }
        System.runAs(user2){
            try{
                bddform3.BET_Status__c='Submitted';
                update bddform3;}
            catch(Exception e){}
        }
        System.runAs(user3){
            try{
                bddform3.BDD_AppCom__c='Test';
                update bddform3;}
            catch(Exception e){}
            try{
                bddform3.BET_Status__c='Submitted';
                update bddform3;
             bddform3.MDN_BA_BankName__c = 'test';
            update bddform3;}
            catch(Exception e){}
        } 
       
        
    }
    
    public virtual class MyException extends Exception{}
	
	static testmethod void testTriggerRestrict(){
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
        bddform.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddform.GT_Relationship__c = 'End User';
        bddForm.MDN_OI_Business_Roles__c ='BROKER';
        try{
            insert bddform;}
        Catch(Exception e){
            
        }
        bddform.MDN_PC_Business_Line__c = 'Crude';
         try{
            update bddform;}
        Catch(Exception e){
        }
          bddform.MDN_OI_BusLine_multi__c= Null;
         bddform.MDN_PC_Business_Line__c = 'Crude';
         try{
            update bddform;}
        Catch(Exception e){
            
        }
        
        BET_BDD_Address__c bddAddress1=new BET_BDD_Address__c(BDD_Form__c=bddform.id,Address_Type__c='Legal',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc2.id);
        insert bddAddress1;
        bddform.BET_Status__c='Ready to Onboard';
        try{ update bddform; }
         Catch(Exception e){ }
        try{
            bddform.BDD_Eligible_Status__c='Yes';
            update bddform;
        }catch(Exception e){
		
		}  
         Test.stopTest();
        
    }
	
	
	static testmethod void testTriggerRestrictCheck(){
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
        bddform.GT_Type_Of_RelationShip__c = 'Basic Customer';
        bddform.GT_Relationship__c = 'End User';
        bddForm.MDN_OI_Business_Roles__c ='BROKER';
        try{
            insert bddform;}
        Catch(Exception e){
            
        }
        bddform.MDN_PC_Business_Line__c = 'Crude';
         try{
            update bddform;}
        Catch(Exception e){
        }
          bddform.MDN_OI_BusLine_multi__c= Null;
         bddform.MDN_PC_Business_Line__c = 'Crude';
         try{
            update bddform;}
        Catch(Exception e){
            
        }
        
        BET_BDD_Address__c bddAddress1=new BET_BDD_Address__c(BDD_Form__c=bddform.id,Address_Type__c='Legal',Country__c='Germany',AddLine1__c='Test',City__c='Berlin',RecordTypeId=rc2.id);
        insert bddAddress1;
        bddform.BET_Status__c='Ready to Onboard';
        try{ update bddform; }
         Catch(Exception e){ }
		 
		Profile prof = [select id from profile where name = 'BET User' LIMIT 1];
        User user = new User(Alias = 'batman',
                             Email='testtermscondifhufhuiwfuiw@kaplan.com',
                             EmailEncodingKey='UTF-8',
                             Firstname='Bruce',
                             Lastname='Wayne',
                             profileId=prof.Id,
                             LocaleSidKey='en_US',
                             LanguageLocaleKey='en_US',
                             Username = 'testhufhuiwfuiwaa11@kiran.com',
                             TimeZoneSidKey='America/Chicago');
        User user1 = new User(Alias = 'batman',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Wayne',
                              profileId=prof.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Is_Approver_User__c=true,
                              Username = 'testhufhuiwfuiwaa11dwadwdwa@kiran.com',
                              TimeZoneSidKey='America/Chicago');
        insert user1;
		System.runAs(user){								
			try{
				bddform.BDD_Eligible_Status__c='Yes';
                bddform.BDD_Approver__c = user1.Id;
				update bddform;
			}catch(Exception e){
			
			} 
		} 
         Test.stopTest();
        
    }
}