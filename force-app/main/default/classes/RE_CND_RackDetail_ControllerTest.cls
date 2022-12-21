/******************************************************************************************************************
className           :    RE_CND_RackDetail_ControllerTest
Description         :    Test class for RE_CND_RackDetail_Controller
Author              :    Aasiya Siraj
Date				:	 31-Aug-2021 
*******************************************************************************************************************/
@isTest
public class RE_CND_RackDetail_ControllerTest {
    
    @testSetup 
    static void setup() {
        RE_Default_Settings__c defSettRec =new RE_Default_Settings__c();
        defSettRec.Name = 'RDS-001';
        defSettRec.Country_Name__c = 'Canada';
        defSettRec.Is_Active__c = true;
        defSettRec.Type__c = 'GSAP To Date Extension';
        defSettRec.Value__c = '14';
        insert defSettRec;
        RE_Record_Id_Mappings__c recMap=RE_CND_TestDataFactory.createRecMap('00O8E0000015McRUAU' ,'OPIS Comparison','RIM-0005',true,'Canada');
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Pricing Recalculation','CA'); 
        
        Id accRecordId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Canada').getRecordTypeId();
        Account acc1=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc1',null,'Sold To','10001',TRUE);
        Account acc2=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc2',acc1.Id,'Ship To','20002',TRUE);
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        
        Id cpRecordID 	= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_MY_CostPrice__c cp1=RE_CND_TestDataFactory.createCostPriceToday(cpRecordID,'Unbranded','Edmonton','Draft',100,prod.Id,loc1.Id,'',TRUE,'CAD CTS/LTR',0,0,0);
        RE_MY_CostPrice__c cp4=RE_CND_TestDataFactory.createCostPriceToday(cpRecordID,'Unbranded','Edmonton','Draft',100,prod.Id,loc2.Id,'',TRUE,'CAD CTS/LTR',0,0,0);
        RE_MY_CostPrice__c cp2 =RE_CND_TestDataFactory.createCostPriceToday(cpRecordID,'Branded','Edmonton','Draft',100,prod.Id,loc1.Id,'40004-C123-Unbranded',FALSE,'CAD CTS/LTR',0,0,0);
        RE_MY_CostPrice__c cp3 =RE_CND_TestDataFactory.createCostPriceToday(cpRecordID,'Branded','Edmonton','Uploaded',100,prod.Id,loc2.Id,'40004-C123-Unbranded',FALSE,'CAD CTS/LTR',0,0,0);
        
        Id pbRecordId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        RT_Price_Book__c pb1=RE_CND_TestDataFactory.createPriceBookToday
            (pbRecordId,'Edmonton','Bronze','Draft',10,prod.Id,loc1.Id,'40004-C123-Unbranded',acc1.Id,acc2.Id,'CAD CTS/LTR',System.today(),System.today());
        RT_Price_Book__c pb2=RE_CND_TestDataFactory.createPriceBookToday
            (pbRecordId,'Edmonton','Bronze','Uploaded',10,prod.Id,loc1.Id,'40004-C234-Unbranded',acc1.Id,acc2.Id,'CAD CTS/LTR',System.today(),System.today());
        
        RT_Price_Book__c pb3=RE_CND_TestDataFactory.createPriceBookToday
            (pbRecordId,'Edmonton','Bronze','Uploaded',5,prod.Id,loc1.Id,'40004-C123-Unbranded',acc1.Id,acc2.Id,'CAD CTS/LTR',System.today()-2,System.today()-2);
        RT_Price_Book__c pb4=RE_CND_TestDataFactory.createPriceBookToday
            (pbRecordId,'Edmonton','Bronze','Uploaded',5,prod.Id,loc1.Id,'40004-C234-Unbranded',acc1.Id,acc2.Id,'CAD CTS/LTR',System.today()-2,System.today()-2);
        
        
        REV_Contract_Master__c revMaster =RE_CND_TestDataFactory.createRevMaster(pbRecordId,'Edmonton','Bronze',prod.Id,loc2.Id,acc1.Id,acc2.Id,loc1.Id,prod.Id,'CAD CTS/LTR');
        REV_Contract_Master__c revMaster2 =RE_CND_TestDataFactory.createRevMaster(pbRecordId,'Edmonton','Bronze',prod.Id,loc1.Id,acc1.Id,acc2.Id,loc1.Id,prod.Id,'CAD/LTR');        
        RE_Rate_Unit_Manager__c rum1 =RE_CND_TestDataFactory.createRateUnitManager('RUM1','CAD CTS/LTR','CAD CTS','LTR');
        RE_Rate_Unit_Manager__c rum2=RE_CND_TestDataFactory.createRateUnitManager('RUM2','CAD/LTR','CAD','LTR');
        
        RE_CustomOpps_ReportConfiguration__c rc1 =RE_CND_TestDataFactory.createOppConfig('CRC-1','623','Branded','RE_MY_CostPrice__c','CA48020201+RE_Depot_Code__c+000000000+RE_Product_Codes__c');
        RE_CustomOpps_ReportConfiguration__c rc2 =RE_CND_TestDataFactory.createOppConfig('CRC-2','629','SFJ','RT_Price_Book__c','CA480202+Account_Number+000000000+RT_Product_Code__c');
        RE_CustomOpps_ReportConfiguration__c rc3 =RE_CND_TestDataFactory.createOppConfig('CRC-3','622','Unbranded','RE_MY_CostPrice__c','CA480202+RE_Depot_Code__c+000000000+RE_Product_Codes__c');
        
        RE_GSAP_Upload__c gsap =RE_CND_TestDataFactory.createGSAPUpload();   
        
        Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
        List<RE_MOA__c> expList = New List<RE_MOA__c>();
        
        RE_MOA__c exp1 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Edmonton', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp1);
        
        RE_MOA__c exp2 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Montreal', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp2);
        
        RE_MOA__c exp3 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Vancouver', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp3);
        
        RE_MOA__c exp4 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Kamloops', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp4);
        
        RE_MOA__c exp5 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Ottawa', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp5);
        
        RE_MOA__c exp6 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Sarnia', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp6);
        
        RE_MOA__c exp7 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Thunder Bay', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp7);
        
        RE_MOA__c exp8 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Toronto', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp8);
        
        RE_MOA__c exp9 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Edmonton', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp9);
        
        RE_MOA__c exp10 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Montreal', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp10);
        
        RE_MOA__c exp11 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Vancouver', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp11);
        
        RE_MOA__c exp12 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Kamloops', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp12);
        
        RE_MOA__c exp13 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Ottawa', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp13);
        
        RE_MOA__c exp14 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Sarnia', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp14);
        
        RE_MOA__c exp15 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Thunder Bay', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp15);
        
        RE_MOA__c exp16 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Toronto', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=System.today(),RE_CND_Effective_To_Date__c=System.today(),
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp16);
        
        insert expList;
    }
    
    @isTest
    static  void getCanadaFiltersTest(){
        Test.startTest(); 
        RE_CND_RackDetail_Controller.CanadaRackWrapper cw = new RE_CND_RackDetail_Controller.CanadaRackWrapper (); 
        cw =RE_CND_RackDetail_Controller.getCanadaFilters(System.today());
        System.debug('cw--'+cw);
        Test.stopTest();
    }
    
    @isTest
    static  void getAllDataTest(){
        Test.startTest(); 
        RE_CND_RackDetail_Controller.getAllData(System.today());
        Test.stopTest();
    }
    
    @isTest
    static  void generateSFJPricesTest(){
        Test.startTest(); 
        RE_CND_RackDetail_Controller.generateSFJPrices(System.today());
        Test.stopTest();
    }
    
    @isTest
    static  void saveTest(){
        Test.startTest(); 
        RE_CND_RackDetail_Controller.AllDataWrapper adr=RE_CND_RackDetail_Controller.getAllData(System.today());
        System.debug('adr--'+adr);
        List<RE_CND_RackDetail_Controller.saveWrapper> swList= new List<RE_CND_RackDetail_Controller.saveWrapper>();
        for(RE_CND_RackDetail_Controller.CostPriceWrapper cpw :adr.cppbRecords)
        {
            RE_CND_RackDetail_Controller.saveWrapper sw= new RE_CND_RackDetail_Controller.saveWrapper();
            if(cpw.pbRecord==null)
            {
                sw.recordId=cpw.cpRecord.Id;
                sw.Adjustment=cpw.cpRecord.RE_CND_Adjustment_Value__c;
                sw.finalValue=cpw.cpRecord.RE_CND_Final_Value__c;
                sw.Comment=cpw.cpRecord.RE_Submitter_Comments__c; 
                sw.custType=cpw.cpRecord.RE_CND_Group__c; 
                swList.add(sw);
            }
            else if(cpw.cpRecord==null)
            {
                sw.recordId=cpw.pbRecord.Id;
                sw.Adjustment=cpw.pbRecord.RE_CND_Adjustment_Value__c;
                sw.finalValue=cpw.pbRecord.RE_CND_Final_Value__c;
                sw.Comment=cpw.pbRecord.RE_Submitter_Comments__c; 
                sw.custType='SFJ'; 
                swList.add(sw); 
            }
        }
        RE_CND_RackDetail_Controller.saveRecords(JSON.serialize(swList),System.today());
        Test.stopTest();
    }
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"TotalItems":"1","Status":"01","SHTItems":[{"SfItemShtNo":"SHT - 146960","SfHeaderShtNo":"1-122815","SapMrcItemNo":"101323","SalesPrice":"20.00","RejectionReason":"","QuantityUom":"CBM","Quantity":"10.00","PriceInd":"F","MaterialNo":"400002410","ItemCount":"1","DealCreationTime":"92815","DealCreationDate":"20210212","CurrencyKey":"EUR","CondUnit":"L15","CondType":"YP23","CondPUnt":"100"}],"SfHeaderShtNo":"1-122815","SapSalesContNo":"","SapMrcNo":"320076181-","SalesOrg":"DE01","POType":"TSFP","MsgTxt":"","InstanceURL":"T","ContStartDate":"20210212","ContEndDate":"20210225","Action":"C"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static  void uploadToGSAPTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest(); 
        List<RE_MY_CostPrice__c> cpList = new List<RE_MY_CostPrice__c>();
        List<RT_Price_Book__c> pbList = new List<RT_Price_Book__c>();
        
        for(RE_MY_CostPrice__c cp :[SELECT Id,RE_Status__c FROM RE_MY_CostPrice__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            cp.RE_Status__c='Ready to Upload';
            cpList.add(cp);
        }
        
        for(RT_Price_Book__c pb : [SELECT Id,RE_Custom_Opp_Approve__c FROM RT_Price_Book__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            pb.RE_Custom_Opp_Approve__c='Ready to Upload';
            pbList.add(pb);
        }
        update cpList;
        update pbList;
        RE_CND_RackDetail_Controller.AllDataWrapper adr=RE_CND_RackDetail_Controller.getAllData(System.today());
        System.debug('adr--'+adr);
        List<string> listToUpload=new List<String>();
        listToUpload.add('Branded');
        listToUpload.add('Unbranded');
        listToUpload.add('SFJ');
        RE_CND_RackDetail_Controller.uploadToGSAP(listToUpload,System.today(),'Upload to SAP');
        RE_CND_RackDetail_Controller.getGSAPJobStatus();
        RE_CND_RackDetail_Controller.getGSAPUploadStatus(System.today());
        Test.stopTest();
    }
    @isTest
    static  void versionTest(){
        RE_MY_CostPrice__c cp =[SELECT Id,Name FROM RE_MY_CostPrice__c WHERE RE_CND_Rack__c='Edmonton' LIMIT 1];
        cp.RE_Initial_Version__c=cp.Name;
        update cp;
        
        RT_Price_Book__c pb = [SELECT Id,Name FROM RT_Price_Book__c WHERE RE_CND_Rack__c='Edmonton' LIMIT 1];
        pb.RE_Initial_Version__c=pb.Name;
        update pb;
        
        RE_CND_RackDetail_Controller.getVersionRecords(cp.Name,'Branded');
        RE_CND_RackDetail_Controller.getVersionRecords(pb.Name,'SFJ');
    }
    
    @isTest
    static  void hasFutureRecordTest(){
        
        RE_CND_RackDetail_Controller.checkFutureRecord();
        RE_CND_RackDetail_Controller.saveReturnWrapper srw =RE_CND_RackDetail_Controller.getSaveStatus();
    }
    
    @isTest
    static  void priceExecutnDataIntegrityChecksTest()
    {
        Test.startTest();        
        Datetime reqDateTime = system.now();
        Date reqDate =  date.newinstance(reqDateTime.year(), reqDateTime.month(), reqDateTime.day());
        RE_CND_RackDetail_Controller.priceExecutnDataIntegrityChecks(reqDate);
        Test.stopTest();        
    }
  
    @isTest
    static  void downloadSAPDataTest()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest(); 
        List<RE_MY_CostPrice__c> cpList = new List<RE_MY_CostPrice__c>();
        List<RT_Price_Book__c> pbList = new List<RT_Price_Book__c>();
        
        for(RE_MY_CostPrice__c cp :[SELECT Id,RE_Status__c FROM RE_MY_CostPrice__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            cp.RE_Status__c='Ready to Upload';
            cpList.add(cp);
        }
        
        for(RT_Price_Book__c pb : [SELECT Id,RE_Custom_Opp_Approve__c FROM RT_Price_Book__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            pb.RE_Custom_Opp_Approve__c='Ready to Upload';
            pbList.add(pb);
        }
        update cpList;
        update pbList;
        RE_CND_RackDetail_Controller.AllDataWrapper adr=RE_CND_RackDetail_Controller.getAllData(System.today());
        List<string> listToUpload=new List<String>();
        listToUpload.add('Branded');        
        RE_CND_RackDetail_Controller.sapDowldWrappr sapDowld = New RE_CND_RackDetail_Controller.sapDowldWrappr();       
        sapDowld = RE_CND_RackDetail_Controller.getSAPdownloadData(listToUpload,System.today());     
        Test.stopTest();
    }   
    
    @isTest
    static  void downloadSAPDataUnbrndedTest()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest(); 
        List<RE_MY_CostPrice__c> cpList = new List<RE_MY_CostPrice__c>();
        List<RT_Price_Book__c> pbList = new List<RT_Price_Book__c>();
        
        for(RE_MY_CostPrice__c cp :[SELECT Id,RE_Status__c FROM RE_MY_CostPrice__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            cp.RE_Status__c='Ready to Upload';
            cpList.add(cp);
        }
        
        for(RT_Price_Book__c pb : [SELECT Id,RE_Custom_Opp_Approve__c FROM RT_Price_Book__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            pb.RE_Custom_Opp_Approve__c='Ready to Upload';
            pbList.add(pb);
        }
        update cpList;
        update pbList;
        RE_CND_RackDetail_Controller.AllDataWrapper adr=RE_CND_RackDetail_Controller.getAllData(System.today());
        List<string> listToUpload=new List<String>();        
        listToUpload.add('Unbranded');        
        RE_CND_RackDetail_Controller.sapDowldWrappr sapDowld = New RE_CND_RackDetail_Controller.sapDowldWrappr();
        sapDowld = RE_CND_RackDetail_Controller.getSAPdownloadData(listToUpload,System.today());     
        Test.stopTest();
    } 
    
    @isTest
    static  void downloadSAPDataSFJTest()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest(); 
        List<RE_MY_CostPrice__c> cpList = new List<RE_MY_CostPrice__c>();
        List<RT_Price_Book__c> pbList = new List<RT_Price_Book__c>();
        
        for(RE_MY_CostPrice__c cp :[SELECT Id,RE_Status__c FROM RE_MY_CostPrice__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            cp.RE_Status__c='Ready to Upload';
            cpList.add(cp);
        }
        
        for(RT_Price_Book__c pb : [SELECT Id,RE_Custom_Opp_Approve__c FROM RT_Price_Book__c WHERE RE_CND_Rack__c='Edmonton'])
        {
            pb.RE_Custom_Opp_Approve__c='Ready to Upload';
            pbList.add(pb);
        }
        update cpList;
        update pbList;
        RE_CND_RackDetail_Controller.AllDataWrapper adr=RE_CND_RackDetail_Controller.getAllData(System.today());
        List<string> listToUpload=new List<String>();
        listToUpload.add('SFJ');
        RE_CND_RackDetail_Controller.sapDowldWrappr sapDowld = New RE_CND_RackDetail_Controller.sapDowldWrappr();
        sapDowld = RE_CND_RackDetail_Controller.getSAPdownloadData(listToUpload,System.today());     
        Test.stopTest();
    } 
    
}