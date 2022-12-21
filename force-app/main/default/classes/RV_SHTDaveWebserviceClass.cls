@RestResource(urlMapping='/SHTDave/*')
global with sharing class RV_SHTDaveWebserviceClass {

    
    @HttpGet
    global static List<SHT_Dave_Master__c> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<SHT_Dave_Master__c> resultLst = new List<SHT_Dave_Master__c>();
        String shtDaveMstID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //System.debug('%%%%%%%shtDaveMstID%%%%%%'+shtDaveMstID);
        if(shtDaveMstID <> 'SHTDave'){
        	 resultLst = [SELECT Id,Name from SHT_Dave_Master__c where Name=:shtDaveMstID];
            //System.debug('%%%%%%%resultLst%%%%%%'+resultLst);
        }else{
             resultLst = [SELECT Id,Name,Total_Exposure_Factors__c,Final_Exposure_Factor__c,Hedged__c
                          from SHT_Dave_Master__c where Name='AGO B7' OR Name='MOGAS' OR Name = 'IGO 50ppm'];
            //System.debug('%%%%%%%resultLst%%%%%%'+resultLst);
        }
        //System.debug('%%%%%%%resultLst%%%%%%'+resultLst);
        return resultLst;
    }
    
    

}