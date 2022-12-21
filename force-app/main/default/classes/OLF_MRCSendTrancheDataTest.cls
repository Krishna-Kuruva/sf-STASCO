@isTest
public class OLF_MRCSendTrancheDataTest {
                   
    @testSetup
    static void testSetup(){
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
         RV_OLF_MRC_Data__c olf1 = new RV_OLF_MRC_Data__c();
    olf1.RV_MrcId__c='03245-123';
    olf1.RV_ContractEndDate__c='23/03/2022';
    olf1.RV_ContractStartDate__c='02/03/2022';
    olf1.RV_LocationName__c='Loc1';
    olf1.RV_MaterialName__c='Mat1';
    olf1.RV_Grade__c='Grade1';
    olf1.RV_VolumeCBM__c=23.4;
    olf1.RV_PricePerVol__c=201;
    olf1.tranche__c='ATP1';
    insert olf1;
    }
    static testMethod void getData(){


        
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   
        OLFWrapper.customerEmailWrap customerEmailWrapper = new OLFWrapper.customerEmailWrap();
        customerEmailWrapper.customerEmail='All';
        customerEmailWrapper.tranche='ATP1';
        String jsonBody = JSON.serialize(customerEmailWrapper);
        //String requestString=OLF_UpdateOlfDealOnSht.updateOlfNoOnSht(wrapDeal);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/OLFMRCData/';
        req.requestBody=Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        //req.addHeader('httpMethod', 'POST');
        RestContext.request = req;
        RestContext.response=res;
        
         Test.startTest();
        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];
        OLF_Utility.global_overrideChecks = true;
        
        System.RunAs(u){    
            OLF_MRCSendTrancheData.get(); 
            System.debug(System.now());
        }
        Test.stopTest();
       
    }
    static testMethod void data(){
                 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   

         OLFWrapper.customerEmailWrap customerEmailWrapper2 = new OLFWrapper.customerEmailWrap();
        customerEmailWrapper2.customerEmail='abc@gmail.com;bcd@gmail.com';
        customerEmailWrapper2.tranche='ATP1';
        String jsonBody2 = JSON.serialize(customerEmailWrapper2);
        //String requestString=OLF_UpdateOlfDealOnSht.updateOlfNoOnSht(wrapDeal);
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req2.requestURI = '/services/apexrest/OLFMRCData/';
        req2.requestBody=Blob.valueOf(jsonBody2);
        req2.httpMethod = 'POST';
        //req.addHeader('httpMethod', 'POST');
        RestContext.request = req2;
        RestContext.response=res2;
        
         Test.startTest();
        
        User u2=[Select Id from User where Id=:UserInfo.getUserId() limit 1];
        OLF_Utility.global_overrideChecks = true;
        
        System.RunAs(u2){    
            OLF_MRCSendTrancheData.get(); 
            System.debug(System.now());
        }
        Test.stopTest();
    }
    
}