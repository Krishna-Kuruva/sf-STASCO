@isTest
public Class OLF_UserAuthenticationTest{
    
    @TestSetup
    static void testData(){
        //Create Revolution Setting
        List<Revolution_Setting__c> revSettList = new List<Revolution_Setting__c>();
        Revolution_Setting__c setting1 = RV_TestDataFactory.createRevolutionSetting('OLF Connection Active', 'TRUE', false, null, null);
        Revolution_Setting__c setting2 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 1', 'ATP1', true, 0, 14);
        Revolution_Setting__c setting3 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 2', 'ATP2', true, 15, 28);
        Revolution_Setting__c setting4 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 3', 'ATP3', true, 29, 48);
        Revolution_Setting__c setting5 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 4', 'ATP4', true, 49, 61);
        revSettList.add(setting1);
        revSettList.add(setting2);
        revSettList.add(setting3);
        revSettList.add(setting4);
        revSettList.add(setting5);
        insert revSettList;
    }
    
    static testMethod void test1(){
        Account soldToAcc = RV_TestDataFactory.createSoldToCustomer('Test Sold-To Account', '11111111', true, true, true);
        insert soldToAcc;
        Account accInsert = RV_TestDataFactory.createShipToCustomer(soldToAcc, 'Test Ship-To Account', true, true, 'test@abc.com', true, '22222222');
        insert accInsert;
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(accInsert.Id);
        OLF_UserAuthentication.validateMRC(accIdSet);
        Contact c=new Contact();
        c.Email='test@abc.com';
        c.LastName='Con1';
        c.AccountId=accInsert.Id;
        insert c;
        System.Debug('conatct here:'+c);
        System.Debug('c.email:'+c.email);
        String conEmail=c.email;
        System.Debug('String value :'+conEmail);
        
        Product_Catalogue__c pc=new Product_Catalogue__c();
        pc=RV_TestHelper.insertProductCat(pc);
        insert pc;
        
        Location__c loc=new Location__C();
        loc=RV_TestHelper.insertLocation(loc);
        insert loc;
        
        MRC__c  mrc=new MRC__C();
        mrc=RV_TestHelper.insertMRC(mrc,accInsert ,loc,pc);
        mrc.Sold_To__c=soldToAcc.Id;
        mrc.Ship_To__c=accInsert.Id;
        mrc.Shipping_Condition__c=10;
        mrc.Valid_To_Date__c=System.Today();
        mrc.Rv_Available_for_OLF__c=true;
        insert mrc;
        
        //OLF_UserAuthentication.validateContact(conEmail);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   
        //String requestString=OLF_UpdateOlfDealOnSht.updateOlfNoOnSht(wrapDeal);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/OLF/' +conEmail;
        req.httpMethod = 'POST';
        //req.addHeader('httpMethod', 'POST');
        RestContext.request = req;
        RestContext.response=res;
        
        OLFWrapper.customerEmailWrap cust = new OLFWrapper.customerEmailWrap();
        cust.customerEmail = conEmail;
        req.requestBody = Blob.valueOf(JSON.serialize(cust));
        //START - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
        OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();
        olfTrancheWrap.tranche = 'ATP1';
        olfTrancheWrap.isOlfActive = true;
        olfTrancheWrap.startDay = 0;
        olfTrancheWrap.endDay = 14;
        OLF_UserAuthentication.getMRCData(new List<Account>{accInsert}, conEmail, olfTrancheWrap);
        //END - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
        Test.startTest();
        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];
        
        OLF_Utility.global_overrideChecks = true;
        
        System.RunAs(u){    
            OLF_UserAuthentication.get(); 
            System.debug(System.now());
        }
        Test.stopTest();
    }
    
    static testMethod void test2(){
        Account soldToAcc = RV_TestDataFactory.createSoldToCustomer('Test Sold-To Account', '11111111', true, true, true);
        insert soldToAcc;
        Account accInsert = RV_TestDataFactory.createShipToCustomer(soldToAcc, 'Test Ship-To Account', true, true, 'test@abc.com', true, '22222222');
        insert accInsert;
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(accInsert.Id);
        OLF_UserAuthentication.validateMRC(accIdSet);
        Contact c=new Contact();
        c.Email='test@abc.com';
        c.LastName='Con1';
        c.AccountId=accInsert.Id;
        insert c;
        System.Debug('conatct here:'+c);
        System.Debug('c.email:'+c.email);
        String conEmail=c.email;
        System.Debug('String value :'+conEmail);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   
        //String requestString=OLF_UpdateOlfDealOnSht.updateOlfNoOnSht(wrapDeal);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/OLF/' +'test@abc.com';
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response=res;
        
        OLFWrapper.customerEmailWrap cust = new OLFWrapper.customerEmailWrap();
        cust.customerEmail = conEmail;
        req.requestBody = Blob.valueOf(JSON.serialize(cust));
        //START - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
        OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();
        olfTrancheWrap.tranche = 'ATP1';
        olfTrancheWrap.isOlfActive = true;
        olfTrancheWrap.startDay = 0;
        olfTrancheWrap.endDay = 14;
        OLF_UserAuthentication.getMRCData(new List<Account>{accInsert}, conEmail, olfTrancheWrap);
        //END - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
        Test.startTest();  
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];  
        OLF_Utility.global_overrideChecks = true;
        
        System.RunAs(u){    
            OLF_UserAuthentication.get(); 
        }
        Test.stopTest();        
    }
    
    static testMethod void test3(){
        String conEmail = 'test@abc.com';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/OLF/' +conEmail;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response=res;        
        OLFWrapper.customerEmailWrap cust = new OLFWrapper.customerEmailWrap();
        cust.customerEmail = conEmail;
        req.requestBody = Blob.valueOf(JSON.serialize(cust));
        //START - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
		OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();
        olfTrancheWrap.tranche = 'ATP1';
        olfTrancheWrap.isOlfActive = true;
        olfTrancheWrap.startDay = 0;
        olfTrancheWrap.endDay = 14;
        OLF_UserAuthentication.getMRCData(new List<Account>(), conEmail, olfTrancheWrap);
        //END - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
        Test.startTest();        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];        
        OLF_Utility.global_overrideChecks = true;
        System.RunAs(u){    
            OLF_UserAuthentication.get(); 
            System.debug(System.now());
        }
        Test.stopTest();
    }
    
    static testMethod void test4(){
        Revolution_Setting__c setting = [SELECT Id FROM Revolution_Setting__c WHERE Name = 'OLF Connection Active'];
        delete setting;
        String conEmail = 'test@abc.com';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/OLF/' +conEmail;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response=res;        
        OLFWrapper.customerEmailWrap cust = new OLFWrapper.customerEmailWrap();
        cust.customerEmail = conEmail;
        req.requestBody = Blob.valueOf(JSON.serialize(cust));
        //START - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
		OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();
        olfTrancheWrap.tranche = 'ATP1';
        olfTrancheWrap.isOlfActive = true;
        olfTrancheWrap.startDay = 0;
        olfTrancheWrap.endDay = 14;
        OLF_UserAuthentication.getMRCData(new List<Account>(), conEmail, olfTrancheWrap);
        //END - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on getMRCData().
        Test.startTest();        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];        
        OLF_Utility.global_overrideChecks = true;
        System.RunAs(u){    
            OLF_UserAuthentication.get(); 
            System.debug(System.now());
        }
        Test.stopTest();
    }
    
}