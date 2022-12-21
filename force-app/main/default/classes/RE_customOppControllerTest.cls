@isTest(SeeAllData = False) 
public class RE_customOppControllerTest {     
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
    /*
    public static testmethod void calltest(){
        createTestData(); 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        RE_customOppController.exportReport('2021-03-07',false,true);
        Test.stopTest();
    }*/ 
   
    public static testmethod void testRE_MY_CustOpsCalculationController(){
        createTestData();   
        RE_Job_Run_Audit__c newContract= new RE_Job_Run_Audit__c();
        //RE_MY_CustOpsCalculationController.createfinalPriceBookData(newContract);
        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
        insertJob.RE_Run_Type__c='Manual';
        insertJob.RE_Job_Type__c = 'CustomerOps Output';
        insertJob.RE_User__c=UserInfo.getUserId();
        insertJob.RE_Run_Time__c=DateTime.now();
        insertJob.RE_Job_Run_Count__c = 0;
        insertJob.RE_IsSuccess__c = true;
        insertJob.RE_Job_Status__c = 'Processing';        
        insert insertJob;
        date filterdate = system.today().adddays(1);
        Test.startTest();
        RE_MY_CustOpsCalculationController.generateDailyData(insertJob);
        RE_MY_CustOpsCalculationController.genDirectdataOnFreqday();
        RE_MY_CustOpsCalculationController.todayCBUcustomOppsgenerate();
        RE_MY_CustOpsCalculationController.roundUpcustom(1.3);
        RE_MY_CustOpsCalculationController.getfrequencyTo();     
        RE_MY_CustOpsCalculationController.newPriceBookToMidDay(insertJob);
        RE_customOppController.getFilteredDate(String.valueOf(filterdate),false,'Reseller');
        RE_customOppController.getFilteredDate(String.valueOf(filterdate),false,'Direct');
        System.enqueueJob(new RE_updateCBUcustomerOpps());
        Test.stopTest();
        
    }
    
    public static testmethod void testRE_customOppController(){
        createTestData();   
        RE_Job_Run_Audit__c newContract= new RE_Job_Run_Audit__c();
        //RE_MY_CustOpsCalculationController.createfinalPriceBookData(newContract);
        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
        insertJob.RE_Run_Type__c='Manual';
        insertJob.RE_Job_Type__c = 'CustomerOps Output';
        insertJob.RE_User__c=UserInfo.getUserId();
        insertJob.RE_Run_Time__c=DateTime.now();
        insertJob.RE_Job_Run_Count__c = 0;
        insertJob.RE_IsSuccess__c = true;
        insertJob.RE_Job_Status__c = 'Processing';        
        insert insertJob;
        RE_MY_CustOpsCalculationController.generateDailyData(insertJob);
        RE_MY_CustOpsCalculationController.genDirectdataOnFreqday();
        date filterdate = system.today().adddays(1);
        List<String> approveId = new list<string>();
        List<RE_customerOppWrapper.pricebookdata> wrapPBDataList = new List<RE_customerOppWrapper.pricebookdata>();
        List<RT_Price_Book__c> pricBookMaping = RE_customOppController.getpricebookdata('',false);
        for(RT_Price_Book__c priceid : pricBookMaping){
            approveId.add(priceid.id);
        }
        Test.startTest();       
        Test.setMock(HttpCalloutMock.class, new RestMock());      
        RE_customOppController.getFilteredDate(string.valueOf(filterdate),false,'Reseller');
        RE_customOppController.getFilteredDate(string.valueOf(filterdate),false,'Direct');        
        RE_customOppController.submitforApproval(approveId,false,string.valueOf(filterdate),'Reseller');
        //RE_customOppController.submitforApproval(approveId,false,string.valueOf(filterdate),'Direct');
        //Level 1 approve STL
        RE_customOppController.approveReject(approveId, 'Approved', wrapPBDataList, false, string.valueOf(filterdate),'Reseller');
        //Level 2 approve PM
        RE_customOppController.approveReject(approveId, 'Approved', wrapPBDataList, false, string.valueOf(filterdate),'Reseller');
        //Level 1 approve BM
        RE_customOppController.approveReject(approveId, 'Approved', wrapPBDataList, false, string.valueOf(filterdate),'Reseller');
        
        RE_customOppController.exportReport(string.valueOf(filterdate), false, true);
        RE_customOppController.exportButtonContr();
        RE_customOppController.checkNewContractData();
        RE_customOppController.getMapPriceBook(pricBookMaping);
        RE_customOppController.convertToPriceBook(wrapPBDataList,false,string.valueOf(filterdate),'Reseller');
        RE_customOppController.convertToPriceBook(wrapPBDataList,false,string.valueOf(filterdate),'Direct');
        RE_customOppController.getpricebookOlddata('',false);
        
        for(RT_Price_Book__c priceid : pricBookMaping){
            priceid.RE_Is_CBU__c = true;
            priceid.RE_Custom_Opp_Approve__c = 'Approved';
            system.debug('--change data---');
        }
        update pricBookMaping;
        RE_customOppController.refreshCBU();
        RE_customOppController.getMarginForApproval(pricBookMaping[0], true);        
        RE_customOppController.getMarginForApproval(pricBookMaping[0], false);
        RE_customOppController.updateApprovalScheme(pricBookMaping[0] , pricBookMaping[0].RE_Contract_Master__r.RE_PH_Approval_Scheme__c , RE_customOppController.getMarginForApproval(pricBookMaping[0],true));
    	RE_customOppController.exportReport(string.valueOf(filterdate), true, true);
        Test.stopTest();
        
    }
    
    Public Static void createTestData(){
        //Country Data
        List<Country__c> count = new List<Country__c>();
        Country__c country = RE_UtilityClass.getCountryCode('Malaysia');
        count.add(country);
        
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn = RE_UtilityClass.getLocation('Labuan','LB','Malaysia');
        RE_Location__c loctn1 = RE_UtilityClass.getLocation('Bukom','BK','Malaysia');
        RE_Location__c loctn2 = RE_UtilityClass.getLocation('Pasir Gudang','LB','Malaysia');
        location.add(loctn);
        location.add(loctn1);
        location.add(loctn2);
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product = RE_UtilityClass.getProduct('Gasoil B7 0.05% S','Malaysia','MYR CTS/LTR');
        RE_Product__c product1 = RE_UtilityClass.getProduct('MOGAS 95','Malaysia','MYR CTS/LTR');
        prod.add(product);
        prod.add(product1);
        
        //Afternoon indication
        RE_Midday_Pricing__c AftIndication = new RE_Midday_Pricing__c();
        AftIndication.RE_Product__c = 'E5 GO B7';
        AftIndication.RE_Midday_Forecast_Price__c = 0.8;
        insert AftIndication;
        
        //Depot Pricing Backbone data
        List<RE_Depot_Pricing_Backbone__c> dPricing = new List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dP1 = RE_UtilityClass.createDPB('Malaysia','Pasir Gudang','Gasoil B7 0.05% S','MYR CTS/LTR');
        RE_Depot_Pricing_Backbone__c dP2 = RE_UtilityClass.createDPB('Malaysia','Labuan','Gasoil B7 0.05% S','MYR CTS/LTR');        
        RE_Depot_Pricing_Backbone__c dP3 = RE_UtilityClass.createDPB('Malaysia','Bukom','Gasoil B7 0.05% S','MYR CTS/LTR');
        
        dPricing.add(dP1);
        dPricing.add(dP2);
        dPricing.add(dP3);
        
        //RE_MOA__c data
        List<RE_MOA__c> moaList = new List<RE_MOA__c>();
        RE_MOA__c moaData1 = new RE_MOA__c(RE_Depot_Name__c = location[0].Id, RE_Product__c = prod[0].id, RE_IsLatest__c = True,RE_Today_s_BSP__c=23.2,RE_MC_Morning__c=143,RE_LDC_Morning__c=142,RE_Final_PSP__c=123,RE_Remark__c='abc');
        RE_MOA__c moaData2 = new RE_MOA__c(RE_Depot_Name__c = location[1].Id, RE_Product__c =prod[0].Id, RE_IsLatest__c = True,RE_Today_s_BSP__c=26.4,RE_MC_Morning__c=143,RE_LDC_Morning__c=142,RE_Final_PSP__c=123 ,RE_Remark__c='xyz');
        moaList.add(moaData1);
        moaList.add(moaData2);
        insert moaList;
        
        //RE_Midday_Pricing__c data  
        List<RE_Midday_Pricing__c> middaybLst = new  List<RE_Midday_Pricing__c>();
        RE_Midday_Pricing__c md1 = new  RE_Midday_Pricing__c(RE_Product_Name__c = prod[1].id,RE_Depot_Name__c = location[0].Id, RE_Shell_Price__c = 22.43,RE_IsLatest__c = True,RE_Product__c='GO B7');  
        RE_Midday_Pricing__c md2 = new  RE_Midday_Pricing__c(RE_Product_Name__c = prod[0].id, RE_Depot_Name__c = location[1].Id, RE_Shell_Price__c = 28.73,RE_IsLatest__c = True,RE_Product__c='GO B7'); 
        middaybLst.add(md1);
        middaybLst.add(md2);
        
        insert middaybLst;
        
        //creating contact for Email testing method RE_customOppController.sendEmail
        Contact emailTest= new Contact(FirstName = 'testing Email',LastName='Email',Email='test@gmail.com') ;
        insert emailTest;
        
        //Custom Calculation table
        List<RE_Custom_Ops_Configuration__c> CustomOpps = new List<RE_Custom_Ops_Configuration__c>();
        RE_Custom_Ops_Configuration__c Direct_Res_Price= RE_UtilityClass.creatConfig('Tier Discount (Reseller)','MY');
        CustomOpps.add(Direct_Res_Price);
        
        RE_Custom_Ops_Configuration__c Direct_Final_Price= RE_UtilityClass.creatConfig('Price Level (Direct without transport charge) - 1 week','MY');
        CustomOpps.add(Direct_Final_Price);
        
        RE_Custom_Ops_Configuration__c Direct_Price_Level= RE_UtilityClass.creatConfig('Price Level (Direct without transport charge) - 2 days validity','MY');
        CustomOpps.add(Direct_Price_Level);
        
        RE_Custom_Ops_Configuration__c Reseller_Final_Price= RE_UtilityClass.creatConfig('Price Level (Direct without transport charge) - 2 days validity','MY');
        CustomOpps.add(Reseller_Final_Price);
        
        RE_Custom_Ops_Configuration__c Direct_Final_Price_wed= RE_UtilityClass.creatConfig('Price Level (Direct with transport charge) - Eff Sat to Fri','MY');
        CustomOpps.add(Direct_Final_Price_wed);
        
        RE_Custom_Ops_Configuration__c Direct_Final_Price_daily = RE_UtilityClass.creatConfig('Direct As Reseller Price Adjustment (with transport charge)','MY');
        CustomOpps.add(Direct_Final_Price_daily);
       
        //create customer 
        List <Account> customer = new List<Account>();
        Id accountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_MY').getRecordTypeId();
        //Reseller Customer
        customer.add(RE_UtilityClass.createcustomer('Resller Sold To','Sold To','123456','Reseller','',accountRecordType));
        customer.add(RE_UtilityClass.createcustomer('Resller Ship To','Ship To','12345699','Reseller',customer[0].id,accountRecordType));
        //Direct Customer
        customer.add(RE_UtilityClass.createcustomer('Direct Sold To','Sold To','123456','Direct','',accountRecordType));
        customer.add(RE_UtilityClass.createcustomer('Direct Ship To','Ship To','12345699','Direct',customer[2].id,accountRecordType));
        
        Id salesOrgRecordType = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('MY_Code_Value_Mapping').getRecordTypeId();
        Id ApprovalRecordType = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('RE_Approval_Process').getRecordTypeId();
        
        List<RT_Setting__c> salesOrg = new List<RT_Setting__c>();
        salesOrg.add(new RT_Setting__c(Name ='MY052020'  ,Value__c ='MY052020' , recordTypeId = salesOrgRecordType ,Type__c ='MY Sales' ,Country__c='MY'));
        salesOrg.add(new RT_Setting__c(Name ='MY082020'  ,Value__c ='MY082020' , recordTypeId = salesOrgRecordType ,Type__c ='MY Sales' ,Country__c='MY'));
		//Adding Approval Process
         salesOrg.add(new RT_Setting__c(Name = 'Malaysia Approval Scheme',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'PM' , 
        											RE_Approver_Role_2__c = 'BM' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =-1000.00 ,
        											RE_Min_Margin__c =-100.01 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Rejected', Country__c = 'MY'));
        salesOrg.add(new RT_Setting__c(Name = 'Malaysia Approval Scheme',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'PM' , 
        											RE_Approver_Role_2__c = 'BM' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =1000.00 ,
        											RE_Min_Margin__c =100.01 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Rejected', Country__c = 'MY'));
        salesOrg.add(new RT_Setting__c(Name = 'Malaysia Approval Scheme',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'PM' , 
        											RE_Approver_Role_2__c = 'BM' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =-100.00 ,
        											RE_Min_Margin__c =-4.01 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Not Submitted', Country__c = 'MY'));
        salesOrg.add(new RT_Setting__c(Name = 'Malaysia Approval Scheme',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'PM' , 
        											RE_Approver_Role_2__c = 'BM' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =4.99 ,
        											RE_Min_Margin__c =-4.00 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Not Submitted', Country__c = 'MY'));
        salesOrg.add(new RT_Setting__c(Name = 'Malaysia Approval Scheme',RE_User_Name__c = UserInfo.getUserId() , RE_Approver_Role_1__c= 'PM' , 
        											RE_Approver_Role_2__c = 'BM' ,RE_Delegate_Approver__c= UserInfo.getUserId() ,RE_Max_Margin__c =100.00 ,
        											RE_Min_Margin__c =5.00 ,RecordTypeId = ApprovalRecordType ,RE_Approval_Status__c ='Auto Approved', Country__c = 'MY'));
       
        insert salesOrg;
        
        //Contract creation 
        List<REV_Contract_Master__c> contracts = new List<REV_Contract_Master__c>();
        contracts.add(RE_UtilityClass.createcontract(customer[1].id,'MY',CustomOpps[0].id,location[0].id,prod[0].id, salesOrg[0].id));
        contracts.add(RE_UtilityClass.createcontract(customer[3].id,'MY',CustomOpps[1].id,location[0].id,prod[0].id, salesOrg[0].id));
        contracts.add(RE_UtilityClass.createcontract(customer[1].id,'MY',CustomOpps[0].id,location[0].id,prod[0].id, salesOrg[1].id));
        contracts.add(RE_UtilityClass.createcontract(customer[3].id,'MY',CustomOpps[2].id,location[0].id,prod[0].id, salesOrg[1].id));
        contracts.add(RE_UtilityClass.createcontract(customer[3].id,'MY',CustomOpps[4].id,location[0].id,prod[0].id, salesOrg[1].id));
        contracts.add(RE_UtilityClass.createcontract(customer[3].id,'MY',CustomOpps[5].id,location[0].id,prod[0].id, salesOrg[1].id));
        
        Id intradayPricing = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('RE_Intraday_Pricing').getRecordTypeId();
        List<RT_Setting__c> intradaylist = new List<RT_Setting__c>();
        intradaylist.add(new RT_Setting__c(Name='IntraDay AGO',recordtypeID=intradayPricing, RE_Sales_Org__c = 'MY052020' , RE_Relevant_Product__c ='AGO',RE_Product__c=prod[0].id,RE_Location__c = location[0].id,Value__c ='0'));
        intradaylist.add(new RT_Setting__c(Name='IntraDay AGO 1',recordtypeID=intradayPricing, RE_Sales_Org__c = 'MY082020' , RE_Relevant_Product__c ='AGO',RE_Product__c=prod[1].id,RE_Location__c = location[1].id,Value__c ='0'));
        
        insert intradaylist;
        
        RE_UtilityClass.createReportConfig('Reseller','Peninsular','CRC-01');
        RE_UtilityClass.createReportConfig('Direct','Peninsular','CRC-02');
        
        RE_GSAP_Upload__c gsapMalaysia = new RE_GSAP_Upload__c();
        gsapMalaysia.Name = 'Malaysia';
        gsapMalaysia.RE_GSAP_Upload__c = true;
        
        insert gsapMalaysia;
        
        Fixed_Price_Staging_Table__c testdata = new Fixed_Price_Staging_Table__c(); 
        testdata.RE_Application__c = 'V';
        testdata.RE_Calculation_type__c='C';
        testdata.RE_Cond_table_no__c='611';
        testdata.RE_Cond_Usage_Table__c='A';
        testdata.RE_Currency_Unit__c='MYR';
        testdata.Customer_Name__c	='WCT CONSTRUCTION SDN BHD';
        testdata.RE_Valid_End_date__c='20210219';
        testdata.RE_Valid_start_date__c='20210217';
        testdata.RE_Value__c='24';
        testdata.RE_Varkey__c='MY0502021021964012408669000000000400006642';
        
        insert testdata;
        
        
        RE_Customer_Opps__c userAccess = new RE_Customer_Opps__c();
        userAccess.Name = 'Customer Operation';
        userAccess.RE_User_Access_Control__c= 'Not Submitted;Approved;Rejected;Auto Approved;Ready to Upload;Uploaded;Failed;Upload not allowed';
        userAccess.Email_ID__c = 'test@gmail.come';
        
        insert userAccess;
        
        RE_Job_Run_Audit__c myCBU= new RE_Job_Run_Audit__c();
        myCBU.RE_Run_Type__c='Manual';
        myCBU.RE_Job_Type__c = 'Malaysia Output';
        myCBU.RE_User__c=UserInfo.getUserId();
        myCBU.RE_Run_Time__c=DateTime.now();
        myCBU.RE_Job_Run_Count__c = 0;
        myCBU.RE_IsSuccess__c = true;
        myCBU.RE_Job_Status__c = 'Processing';        
        insert myCBU;
    }
    
}