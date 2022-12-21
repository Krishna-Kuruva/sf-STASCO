@isTest(SeeAllData = False)  
public class Rev_GSAPStagingTableClassTest {
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
    public static testmethod void onafterInsertRev_GSAPStaging(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
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
        
        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
        insertJob.RE_Run_Type__c='Manual';
        insertJob.RE_Job_Type__c = 'MY Export Report';
        insertJob.RE_User__c=UserInfo.getUserId();
        insertJob.RE_Run_Time__c=DateTime.now();
        insertJob.RE_Job_Run_Count__c = 0;
        insertJob.RE_Job_Status__c = 'Processing';
        
        insert insertJob;
        
        List<id> bacthIds= new list<Id>();
        bacthIds.add(testdata.id);
        Test.startTest();
        FixedPriceDataInsertBatch fdp = new FixedPriceDataInsertBatch( bacthIds,0,'Malaysia',insertJob);
        Database.executebatch(fdp,200);
        Test.stopTest();
    }
    
        public static testmethod void onafterInsertRev_GSAPStaging_CND(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Fixed_Price_Staging_Table__c testdata = new Fixed_Price_Staging_Table__c(); 
        testdata.RE_Application__c = 'V';
        testdata.RE_Calculation_type__c='C';
        testdata.RE_Cond_table_no__c='629';
        testdata.RE_Cond_Usage_Table__c='A';
        testdata.RE_Currency_Unit__c='CAD';
        testdata.Customer_Name__c	='Canada Customer';
        testdata.RE_Valid_End_date__c='20210219';
        testdata.RE_Valid_start_date__c='20210217';
        testdata.RE_Value__c='120';
        testdata.RE_Varkey__c='CA4802020010069279000000000400004656';
        
        insert testdata;
        
        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
        insertJob.RE_Run_Type__c='Manual';
        insertJob.RE_Job_Type__c = 'Canada GSAP Upload';
        insertJob.RE_User__c=UserInfo.getUserId();
        insertJob.RE_Run_Time__c=DateTime.now();
        insertJob.RE_Job_Run_Count__c = 0;
        insertJob.RE_Job_Status__c = 'Processing';
        
        insert insertJob;
        
        List<id> bacthIds= new list<Id>();
        bacthIds.add(testdata.id);
        Test.startTest();
        FixedPriceDataInsertBatch fdp = new FixedPriceDataInsertBatch( bacthIds,0,'Canada',insertJob);
        Database.executebatch(fdp,200);
        Test.stopTest();
    }
}