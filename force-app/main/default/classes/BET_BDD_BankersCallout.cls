/******************************************************************************************************************
className           :    BET_BDD_BankersCallout
Description         :    This class calls the external API to get Bankers data.
*******************************************************************************************************************/
public class BET_BDD_BankersCallout {
    
    public static BET_BDD_BankersWrapper.responseParametersBankers getBankersData(String name, String countryCode, String accessToken){
        String errorStr = '';
        String Status = '';
        String respBody = '';
        String userId = '';
        Integer statusCode = 0;
        name = EncodingUtil.urlEncode(name, 'UTF-8');
        BET_BDD_BankersWrapper.responseParametersBankers BankersDdata= new BET_BDD_BankersWrapper.responseParametersBankers();    
        try{ 
           //if(accessToken == '' || accessToken == null){
                //accessToken = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize').access_token;
                BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
                authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
                if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                  System.debug('BET_BDD_BankersCallout >> getBankersData: Success!');
                  accessToken = authInfo.access_token;
                  userId = authInfo.user_id;
                }
                else{
                     try{
                        throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                     }
                     catch(Exception e){
                        System.debug('BET_BDD_BankersCallout >> getBankersData >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                     }
                }
            //}
            system.debug('bankers callout >> country code ' + countryCode);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BET_BDD/Bankers?name='+name.replaceAll(' ','%20')+'&country='+countryCode);  
            req.setMethod('GET');
            String headerStr = '';
            req.setHeader('access_token', accessToken);
            req.setHeader('user_id',userId);
           // req.setHeader('user_id', 'betedp.integration@shell.com.betdev');
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Response Body = '+res.getBody());
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
            
            respBody  = res.getBody();
            statusCode = res.getStatusCode();
            
            
            if(statusCode == 200){
                BankersDdata = (BET_BDD_BankersWrapper.responseParametersBankers)JSON.deserializeStrict(respBody,BET_BDD_BankersWrapper.responseParametersBankers.class); 
            }else if(statusCode == 500 || statusCode == 400 || statusCode == 401 || statusCode == 404 || statusCode == 429){
                BankersDdata.responseCode = statusCode;
            }
            
            system.debug('return data--'+BankersDdata);
            BankersDdata.accessToken = accessToken;
            
        }catch (exception ex){
            BankersDdata.accessToken = accessToken;
            system.debug('exception error--'+ex);
        }
        
        return BankersDdata;
    }
}