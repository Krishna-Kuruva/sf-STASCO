public class BET_BDD_OFAC_WrapperClass {
    @AuraEnabled
    public string resultPayload {get;set;}
    @AuraEnabled
    public string responseMessage {get;set;}
    @AuraEnabled
    public String isSuccess {get;set;}
    @AuraEnabled
    public Integer responseCode {get;set;} 
    @AuraEnabled
    public String accessToken{get;set;}
}