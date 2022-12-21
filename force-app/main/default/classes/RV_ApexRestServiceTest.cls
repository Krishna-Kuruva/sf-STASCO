@isTest
private class RV_ApexRestServiceTest {


static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    List<SHT_Dave_Master__c> shtDaveMasterInsertlst = new List<SHT_Dave_Master__c>();
    
    Location__c loc = new Location__c();
    loc.Name = 'Ludwigshafen depot';
    loc.Plant_Code__c = 'D004';
    loc.Source_Location__c = true;
    loc.Company_Code__c = 'DE01';
    insert loc;
    
    SHT_Dave_Master__c shtMasterDaveAGOInsert = new SHT_Dave_Master__c();
    shtMasterDaveAGOInsert.Name = Label.AGO_B7;
    shtMasterDaveAGOInsert.Hedged__c = 1.2;
    shtMasterDaveAGOInsert.Total_Exposure_Factors__c = 1.4;
    shtDaveMasterInsertlst.add(shtMasterDaveAGOInsert);
    insert shtDaveMasterInsertlst;
    
    String shtDaveMstID =shtDaveMasterInsertlst.get(0).id;
    req.requestURI = System.Label.Salesforce_URL+'/services/apexrest/SHTDave/shtDaveMstID';  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    
    RV_SHTDaveWebserviceClass.doGet();
    
    

}

}