@isTest
public class BET_BDD_Search_Controller_Test {
    public static void database(){
        BET_BDD_AuthInfo__c betBddAuthInfo=new BET_BDD_AuthInfo__c();
        betBddAuthInfo.client_Id__c = '3210B2948B571';
        betBddAuthInfo.Client_Secret__c= '3MVG9xqN3LZm';
        betBddAuthInfo.username__c='betedp.integration@shell.com';
        betBddAuthInfo.password__c='Integration@12';
        betBddAuthInfo.endpointSF__c='https://test.salesforce.com/services/oauth2/token';
        //test comment added for deployment
        insert betBddAuthInfo;
    }
    
    static testmethod void testgetVerificationStatus(){
        BET_BDD_OFAC_Callout.getOFACData('', 'Bank', '', '');
        BET_BDD_VIES_Callout.getViesData('1234', 'GE', '');
        BET_BDD_SovosCallout.getSovosData('Test', '', '', '');
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis());
        BET_BDD_Search_Controller.getVerificationStatus('1234','Germany','','WONA','Bank','','Shell');
        BET_BDD_Search_Controller.getVerificationStatus('1234','Germany','','SENA','Bank','','Shell');
        BET_BDD_Search_Controller.getVerificationStatus('1234','Germany','','Global','Vessel','','Shell');
        Test.stopTest();
    }
    
    static testmethod void testgetNewBddFormId(){
        
        BET_BDD_Search_Controller.newBddFormCrResponse newForm=new BET_BDD_Search_Controller.newBddFormCrResponse();
        Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis());
        
        BET_BDD_Form__c bddForm=BET_BDD_SearchController_TestDataFactory.createBDDForm('WONA','Bank','New Onboard');
        BET_BDD_Form__c OrbisbddForm=BET_BDD_SearchController_TestDataFactory.createBDDForm('WONA','Counterparty','New Onboard');
        BET_BDD_Form__c SENAForm=BET_BDD_SearchController_TestDataFactory.createBDDForm('SENA','Bank','New Onboard');
        BET_BDD_Form__c STUSCOForm=BET_BDD_SearchController_TestDataFactory.createBDDForm('STUSCO','Counterparty','Related Party Update');
        
        Object BankersResult=JSON.serialize(BET_BDD_SearchController_TestDataFactory.getBankersResult());
        Object OrbisResult=JSON.serialize(BET_BDD_SearchController_TestDataFactory.getOrbisResult());
        Object GTMIResult=JSON.serialize(BET_BDD_SearchController_TestDataFactory.getGTMIResult());
        
        Test.startTest();
        BET_BDD_Search_Controller.getNewBddFormId(bddForm,OrbisResult,BankersResult,true,'1234','India',GTMIResult,'','');
        BET_BDD_Search_Controller.getNewBddFormId(OrbisbddForm,OrbisResult,BankersResult,true,'1234','India',GTMIResult,'','');
        BET_BDD_Search_Controller.getNewBddFormId(SENAForm,OrbisResult,BankersResult,true,'1234','India',GTMIResult,'','');
        BET_BDD_Search_Controller.getNewBddFormId(STUSCOForm,OrbisResult,BankersResult,true,'1234','India',GTMIResult,'','');
        
        
        
        String recordTyepeWONA=BET_Utility.getRecordTypeId('WONA', 'Bank', 'Remediation Update');
        String recordTyepeSENA=BET_Utility.getRecordTypeId('SENA', 'Bank', 'Remediation Update');
        String recordTyepeSENANew=BET_Utility.getRecordTypeId('SENA', 'Bank', 'New Onboard');
        String recordTyepeSTUSCO=BET_Utility.getRecordTypeId('STUSCO', 'Bank', 'Remediation Update');
        String recordTyepeSTUSCONew=BET_Utility.getRecordTypeId('STUSCO', 'Individual', 'New Onboard');
        String recordTyepeSTUSCORem=BET_Utility.getRecordTypeId('STUSCO', 'Individual', 'Remediation Update');
        map<string, string> mapSENA=BET_Utility.getGtAddressTypeByRegion('SENA', 'Registered');
        map<string, string> mapSENATr=BET_Utility.getGtAddressTypeByRegion('SENA', 'Trading');
        
        Test.stopTest();
    }
    
    static testmethod void testQueueable(){
        Profile profbet = [select id from profile where name = 'BET User' LIMIT 1];
        User user1 = new User(Alias = 'batman',
                              Email='testtermsconditions1234423@kaplan.com',
                              EmailEncodingKey='UTF-8',
                              Firstname='Bruce',
                              Lastname='Wayne',
                              profileId=profbet.Id,
                              LocaleSidKey='en_US',
                              LanguageLocaleKey='en_US',
                              Is_COF_User__c=true,
                              Username = 'Tstdwgyguwgdgdaaaa@kiran.com',
                              TimeZoneSidKey='America/Chicago');
        insert user1;
        Id docRecTypeIdWona = Schema.SObjectType.BET_BDD_Document__c.getRecordTypeInfosByDeveloperName().get('WONA').getRecordTypeId();
        Id docRecTypeIdSena = Schema.SObjectType.BET_BDD_Document__c.getRecordTypeInfosByDeveloperName().get('SENA').getRecordTypeId();
        BET_BDD_Form__c bddform = new BET_BDD_Form__c();
        bddform.BDD_Entity_Type__c = 'Bank';
        bddform.BDD_Line_of_Business__c = 'WONA';
        bddform.MDN_PC_Type__c = 'Main';
        bddform.BDD_Onboard_Type__c = 'New Onboard';
        bddform.BET_Status__c = 'Draft';
        //below 2 fields newly added in GT
        	bddform.GT_Type_Of_RelationShip__c = 'Basic Customer';
        	bddform.GT_Relationship__c = 'End User';
        bddform.Assigned_COF__c =user1.Id;
        bddform.OwnerId=user1.Id;
        insert bddform;
        
        
        BET_BDD_Document__c bddDoc1 = new BET_BDD_Document__c(BET_Manual_Upload__c=true,BET_Source__c = 'Orbis',BET_Document__c = '3rd Party Report',BET_Retry__c = false,BET_Upload_Status__c = 'In Progress',BET_BDD_Form__c=bddform.Id,BET_Section__c = 'GT',BET_Document_Type__c='3rd Party Report',BET_SharePoint_Fld_Name__c='HSBC Bank USA National Association - Bank - 09172020',RecordTypeId = docRecTypeIdWona);
        insert bddDoc1;
        BET_BDD_Document__c bddDoc2 = new BET_BDD_Document__c(BET_Manual_Upload__c=true,BET_Source__c = 'Orbis',BET_Document__c = '3rd Party Report',BET_Retry__c = false,BET_Upload_Status__c = 'In Progress',BET_BDD_Form__c=bddform.Id,BET_Section__c = 'GT',BET_Document_Type__c='3rd Party Report',BET_SharePoint_Fld_Name__c='HSBC Bank USA National Association - Bank - 09172020',RecordTypeId = docRecTypeIdWona);
        insert bddDoc2;
        
        
        List<BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper> lstEndPtWrap=new List<BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper>();
        BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper wrap=new BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper();
        wrap.endPointURL='TestingPass';
        wrap.accessToken='Test';
        wrap.userId='TestUser';
        wrap.bddDoc=bddDoc1;
        lstEndPtWrap.add(wrap);
        BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper wrap1=new BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper();
        wrap1.endPointURL='TestingFail';
        wrap1.bddDoc=bddDoc2;
        wrap1.accessToken='Test';
        wrap1.userId='TestUser';
        lstEndPtWrap.add(wrap1);
        Profile prof = [select id from profile where name = 'System Administrator'];
        User user = new User(Alias = 'batman',
                             Email='testtermsconditions1234423@kaplan.com',
                             EmailEncodingKey='UTF-8',
                             Firstname='Bruce',
                             Lastname='Wayne',
                             profileId=prof.Id,
                             LocaleSidKey='en_US',
                             LanguageLocaleKey='en_US',
                             Username = 'Tstdwaddwadw@kiran.com',
                             TimeZoneSidKey='America/Chicago');
        
        BET_BDD_Form__c bddform1 = new BET_BDD_Form__c();
        bddform1.BDD_Entity_Type__c = 'Counterparty';
        bddform1.BDD_Line_of_Business__c = 'SENA';
        bddform1.BDD_Onboard_Type__c = 'New Onboard';
        bddform1.BET_Status__c = 'Draft';
        bddform1.MDN_OI_BusLine_multi__c='COAL';
        bddform1.MDN_CR_BusLine__c='COAL';
        bddform1.MDN_BA_BusLine__c='COAL';
        //below 2 fields newly added in GT
        	bddform1.GT_Type_Of_RelationShip__c = 'Basic Customer';
        	bddform1.GT_Relationship__c = 'End User';
        bddform1.Assigned_COF__c =user1.Id;
        bddform1.OwnerId=user1.Id;
        insert bddform1;
        BET_BDD_Address__c bddAddress=new BET_BDD_Address__c(BDD_Form__c=bddform1.id);
        
        BET_BDD_Document__c bddDoc3 = new BET_BDD_Document__c(BET_Manual_Upload__c=false,BET_Source__c = 'Bankers Almanac',BET_Retry__c = false,BET_Upload_Status__c = 'Failed',BET_BDD_Form__c=bddform1.Id,BET_Section__c = 'MDN',BET_Document_Type__c='Other',BET_SharePoint_Fld_Name__c='HSBC Bank',RecordTypeId=docRecTypeIdSena);
        try{
            insert bddDoc3;}
        catch(Exception e){}
        
        bddDoc3.BET_Document__c = 'Financial Statement';
        insert bddDoc3;
        
        List<BET_BDD_Document__c> lstBDDDoc=new List<BET_BDD_Document__c>{bddDoc3};
            Map<Id, BET_BDD_Document__c> mapDocs=new Map<Id, BET_BDD_Document__c>();
        bddDoc3.BET_Retry__c=true;
        update bddDoc3;
        mapDocs.put(bddDoc3.id,bddDoc3);
        System.debug(mapDocs);
        System.debug(bddDoc3.id);
        
        
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis());
        system.runAs(user){
            
            
            BET_BDD_SharePointUploadController upCon=new BET_BDD_SharePointUploadController();
            BET_BDD_SharePointUploadController.enqueueEdpCallout(lstBDDDoc, mapDocs);
            
            BET_BDD_SharePointUpload_Queueable ad = new BET_BDD_SharePointUpload_Queueable(lstEndPtWrap);
            System.enqueueJob(ad);
            
            
        }	
        bddDoc2.BET_Retry__c=true;
        bddDoc2.BET_Upload_Status__c='Failed';
        try{
            update bddDoc2;}
        catch(Exception e){}
        
        Test.stopTest();
        
    }
    
	static testmethod void testbulkUploadRecordUpdate(){
        
        BET_BDD_Search_Controller.newBddFormCrResponse newForm=new BET_BDD_Search_Controller.newBddFormCrResponse();
        Test.setMock(HttpCalloutMock.class, new BET_BDD_MockHttpResp_Orbis());
        
        
        BET_BDD_Form__c bddForm=BET_BDD_SearchController_TestDataFactory.createBDDForm('WONA','Bank','New Onboard');
        BET_BDD_Form__c bddForm1=BET_BDD_SearchController_TestDataFactory.createBDDForm('STUSCO','Bank','New Onboard');
        BET_BDD_Form__c bddForm2=BET_BDD_SearchController_TestDataFactory.createBDDForm('SENA','Bank','New Onboard');
        BET_BDD_Form__c bddForm3=BET_BDD_SearchController_TestDataFactory.createBDDForm('WONA','Individual','New Onboard');
        BET_BDD_Form__c bddForm4=BET_BDD_SearchController_TestDataFactory.createBDDForm('STUSCO','Individual','New Onboard');
        BET_BDD_Form__c bddForm5=BET_BDD_SearchController_TestDataFactory.createBDDForm('SENA','Individual','New Onboard');
        BET_BDD_Form__c bddForm6=BET_BDD_SearchController_TestDataFactory.createBDDForm('WONA','Counterparty','New Onboard');
        BET_BDD_Form__c bddForm7=BET_BDD_SearchController_TestDataFactory.createBDDForm('STUSCO','Counterparty','New Onboard');
        BET_BDD_Form__c bddForm8=BET_BDD_SearchController_TestDataFactory.createBDDForm('SENA','Counterparty','New Onboard');
        BET_BDD_Form__c bddForm9=BET_BDD_SearchController_TestDataFactory.createBDDForm('GLOBAL','Vessel','New Onboard');
        
        
       
        
        Test.startTest();
        
        
        //Added by Ashish Jadhav
        BET_EdpResponse_WrapperClass.OrbisResult orbisRec = new BET_EdpResponse_WrapperClass.OrbisResult();
        orbisRec.bvdid ='adwad';
        orbisRec.name='test';
        orbisRec.namE_INTERNATIONAL='test';
        orbisRec.lei='test';
        orbisRec.entitY_TYPE='Counterparty';
        orbisRec.addresS_LINE1='test';
        orbisRec.addresS_LINE2='test';
        orbisRec.addresS_LINE3='test';
        orbisRec.city='test';
        
        
        BET_EdpResponse_WrapperClass.BankersResult bankerRec = new BET_EdpResponse_WrapperClass.BankersResult();
        bankerRec.bankersAlmanacId ='adwad';
        bankerRec.name='test';
        bankerRec.linkToFullDetails='test';
        bankerRec.lei='test';
        bankerRec.status='Counterparty';
        bankerRec.addressLine1='test';
        bankerRec.addressLine2='test';
        bankerRec.addressLine3='test';
        bankerRec.city='test';
        bankerRec.country='test';
        
        BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm,orbisRec,null,false,'','India',null,'','',true);
        BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap1 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm,orbisRec,bankerRec,false,'','India',null,'','',true);
        BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap2 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm1,orbisRec,bankerRec,false,'','India',null,'','',true);
        BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap3 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm2,orbisRec,bankerRec,false,'','India',null,'','',true);
        BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap4 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm3,orbisRec,bankerRec,false,'','India',null,'','',true);
    	BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap5 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm4,orbisRec,bankerRec,false,'','India',null,'','',true);
    	BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap6 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm5,orbisRec,bankerRec,false,'','India',null,'','',true);
    	BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap7 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm6,orbisRec,bankerRec,false,'','India',null,'','',true);
    	BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap8 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm7,orbisRec,bankerRec,false,'','India',null,'','',true);
    	BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap9 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm8,orbisRec,bankerRec,false,'','India',null,'','',true);
    	BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap10 = BET_BDD_Search_Controller.bulkUploadRecordUpdate(bddForm9,orbisRec,bankerRec,false,'','India',null,'','',true);
    	test.stopTest();
    }
    
    
}