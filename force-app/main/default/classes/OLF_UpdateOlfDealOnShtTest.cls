@isTest
public Class OLF_UpdateOlfDealOnShtTest{

    static TestMethod void test1(){
        
        Location__c loc = new Location__c();
        loc=RV_TestHelper.insertLocation(loc);
        insert loc;
        Product_Catalogue__c productCat = new Product_Catalogue__c();
        productCat=RV_TestHelper.insertProductCat(productCat);
        insert productCat;
        Account accLst = new Account();
        accLst=RV_TestHelper.insertAccount(accLst);
        insert accLst;
        MRC__c insertmrc = new MRC__c();
        insertmrc=RV_TestHelper.insertMRC(insertmrc,accLst,loc,productCat);
        insert insertmrc;
        SHT__c insertSHTRec = new SHT__c();
        insertSHTRec=RV_TestHelper.insertSHT(insertSHTRec,loc,accLst,insertmrc);
        insertSHTRec.Status__c = 'Completed';
        insert insertSHTRec;
        SHT__c sht = [select Id, Name from SHT__c where id = : insertSHTRec.id];
        
        List<OLFWrapper.shtAndOlfDealNumberWrap> wrapDeal=new List<OLFWrapper.shtAndOlfDealNumberWrap>();
        OLFWrapper.shtAndOlfDealNumberWrap dw=new OLFWrapper.shtAndOlfDealNumberWrap();
        dw.sfdcDealNumber =sht.name;
        dw.olfDealNumber ='OLF000001';
        wrapDeal.add(dw);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());    
        //String requestString=OLF_UpdateOlfDealOnSht.updateOlfNoOnSht(wrapDeal);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/updateDealNo/' + '/abc@test.com';
        req.httpMethod = 'POST';
        req.addHeader('CustomerEmail', 'abc@test.com');
        req.requestBody = Blob.valueOf(JSON.serialize(wrapDeal));
        RestContext.request = req;
        RestContext.response= res;
        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];
        
        OLF_Utility.global_overrideChecks = true;
        
        Test.startTest();
        System.RunAs(u){
        OLF_UpdateOlfDealOnSht.updateOlfDealNoOnSht();
        }  
        Test.stopTest();
       
    }

}