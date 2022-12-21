/******************************************************************************************************************
className           :    BET_BDD_ORBIS_Callout
Description         :    This class calls the external API to get ORBIS data.
*******************************************************************************************************************/

public class BET_BDD_ORBIS_Callout {
    
    public static BET_BDD_WrapperClass.responseParametersORBIS getOrbisData(String name, String country, String accessToken){
        system.debug('name = '+name+ ';country = '+country);
        String errorStr = '';
        String Status = '';
        String respBody = '';
        String userId = '';
        Integer statusCode = 0;
        name = EncodingUtil.urlEncode(name,'UTF-8');
        country=EncodingUtil.urlEncode(country,'UTF-8');
        
        system.debug('encoded url ' + name);
        BET_BDD_WrapperClass.responseParametersORBIS orbisDdata= new BET_BDD_WrapperClass.responseParametersORBIS();
        
        BET_BDD_AuthInfo__c betBddAuthInfo=BET_BDD_AuthInfo__c.getOrgDefaults();
        String username=betBddAuthInfo.username__c;
        
        try{
            //if(accessToken == '' || accessToken == null){
                //accessToken = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize').access_token;
                BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
                authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
                if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                  System.debug('BET_BDD_ORBIS_Callout >> getOrbisData: Success!');
                  accessToken = authInfo.access_token;
                  userId = authInfo.user_id;
                }
                else{
                     try{
                        throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                     }
                     catch(Exception e){
                        System.debug('BET_BDD_ORBIS_Callout >> getOrbisData >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                     }
                }
            //}
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BET_BDD/Orbis?name='+name+'&country='+country); 
            req.setMethod('GET');
            String headerStr = '';
            req.setHeader('access_token', accessToken);
            req.setHeader('user_id',userId);
            //req.setHeader('user_id', 'betedp.integration@shell.com.betdev');
            req.setTimeout(120000);
            system.debug('req..--'+req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Response Body = '+res.getBody());
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
            
            respBody  = res.getBody();
            statusCode = res.getStatusCode();
            
            if(statusCode == 200){
                orbisDdata = (BET_BDD_WrapperClass.responseParametersORBIS)JSON.deserializeStrict(respBody,BET_BDD_WrapperClass.responseParametersORBIS.class); 
            }else if(statusCode == 500 || statusCode == 400 || statusCode == 401){
                orbisDdata.responseCode = statusCode;
            }
            
            system.debug('return data--'+orbisDdata);
            orbisDdata.accessToken = accessToken;
        }catch (exception ex){
            orbisDdata.accessToken = accessToken;
            system.debug('exception error--'+ex);
        }
        return orbisDdata;
    }  
}