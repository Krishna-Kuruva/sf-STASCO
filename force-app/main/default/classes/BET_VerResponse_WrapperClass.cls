public class BET_VerResponse_WrapperClass {
    @AuraEnabled
    public string resultPayload {get;set;}
    @AuraEnabled
    public string responseMessage {get;set;}
    @AuraEnabled
    public string isSuccess {get;set;}
    @AuraEnabled
    public integer responseCode {get;set;} 
    @AuraEnabled
    public string accessToken{get;set;}
    @AuraEnabled
    public string verificationSource{get;set;}
}