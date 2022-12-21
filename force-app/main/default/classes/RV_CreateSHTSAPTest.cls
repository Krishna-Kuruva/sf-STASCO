@isTest
public class RV_CreateSHTSAPTest {
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
	static testMethod void RV_CreateSHTSAPTestInsert(){

      	Test.setMock(HttpCalloutMock.class, new RestMock());
             
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        Test.startTest();
        
       	SHT__c shtRecord = new SHT__c();
        shtRecord = RV_TestHelper.insertSHT(shtRecord,insertLoc,accInsert,insertMRC);
        insert shtRecord;
        shtRecord.Status__c = 'Completed';
        shtRecord.IsGsapDealCreateOn__c=TRUE;
      	update shtRecord;
        
        SHT__c shtInsert1 = new SHT__c();
        shtInsert1 = RV_TestHelper.insertSHT(shtInsert1,insertLoc,accInsert,insertMRC);
        insert shtInsert1;
        shtInsert1.Status__c = 'Cancelled';
        shtInsert1.IsGsapDealCancelOn__c=FALSE;
        shtInsert1.Cancellation_Reason__c='Z4';
        update shtInsert1;
        
        SAP_Staging__c stagingRecord=new SAP_Staging__c();
        insert stagingRecord;
        stagingrecord.Processing_Indicator__c='02';
        stagingRecord.SapSalesContNo__c='98896578';
        Update stagingRecord;
        
        Test.StopTest();

    }
    
}