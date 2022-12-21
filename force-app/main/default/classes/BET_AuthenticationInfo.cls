/******************************************************************************************************************
className           :    BET_AuthenticationInfo
Description         :    This class return salesforce Authenticate details (access token,instance_url, etc.)  
*******************************************************************************************************************/
public class BET_AuthenticationInfo {
    
    public static BET_BDD_WrapperClass.OAuth2AccessToken getAccesstoken(String namedCredential){
        BET_BDD_WrapperClass.OAuth2AccessToken authInfo= new BET_BDD_WrapperClass.OAuth2AccessToken();
        if(!String.isEmpty(namedCredential)){
            BET_Integration_Setting__mdt authSetting = [SELECT Id, 
                                                               MasterLabel,
                                                               DeveloperName,
                                                               Active__c,
                                                               Client_Id__c,
                                                               Integration_Username__c,
                                                               Client_Secret__c FROM BET_Integration_Setting__mdt WHERE DeveloperName =: namedCredential AND 
                                                                                                                        Active__c = true
                                                                                                                        LIMIT 1];
            if(authSetting != null){
                String username = authSetting.Integration_Username__c;
                String clientId = authSetting.Client_Id__c;
                String clientSecret = authSetting.Client_Secret__c;  
                Http http= new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setEndpoint('callout:' + namedCredential);
                String reqbody = 'grant_type=password&client_id=' + clientId+'&client_secret=' + clientSecret + '&username={!$Credential.UserName}&password={!$Credential.Password}';
                req.setBody(reqbody);
                req.setMethod('POST');  
                try{
                    res = http.send(req);
                }   
                catch(Exception e){
                    System.debug('BET_AuthenticationInfo >> getAccesstoken >> Exception: ' + e.getMessage());    
                }                  
                System.debug('BET_AuthenticationInfo >> getAccesstoken >> Response Body: ' + res.getBody());
                if(res.getStatusCode() == 200){
                    authInfo = (BET_BDD_WrapperClass.OAuth2AccessToken)JSON.deserialize(res.getbody(), BET_BDD_WrapperClass.OAuth2AccessToken.class);
                    authInfo.status_code = res.getStatusCode();
                    authInfo.user_id = username;
                } 
            }
            else{
                System.debug('BET_AuthenticationInfo >> getAccesstoken >> Integration Setting either not found or it is not active.');
            }             
        }
        else{
            System.debug('BET_AuthenticationInfo >> getAccesstoken >> Name Credential is null/empty');
        }
        return authInfo;
    }
}