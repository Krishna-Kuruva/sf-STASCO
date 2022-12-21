@isTest
private class RV_GSAPBatchTest {
    @isTest 
    static void testMethodforSAPResponseScheduler() {
        Test.StartTest();
        SAP_Staging__c s=new SAP_Staging__c(SfItemShtNo__c='SHT-0222',Deal_Created_Date__c=system.today());
        insert s;
        SF_SAP_DataSet__x mockedRequest = new SF_SAP_DataSet__x(SfHeaderShtNo__c='324435432', SfItemShtNo__c='SHT-0222', SapSalesContNo__c='32432432',Status__c='02',MsgTxt__c='test',Action__c='C');
    SF_SAP_DataSet__x request = RV_GSAPMockExternalRequestModel.findById(mockedRequest.Id);
        RV_SAPResponseScheduler SAPResponseScheduler = new RV_SAPResponseScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('SAPResponseScheduler', sch, SAPResponseScheduler); 
        Test.stopTest();
    } 
}