public class BET_BDD_OFAC_Callout {
    public static BET_BDD_OFAC_WrapperClass getOFACData(String imoNumber, String entityName, String searchType, String accessToken){
        System.debug('imoNumber'+imoNumber+entityName+searchType);
        String respBody = '';
        String userId = '';
        Integer statusCode = 0;
        BET_BDD_OFAC_WrapperClass ofacData = new BET_BDD_OFAC_WrapperClass();
        try{
            //if(accessToken == '' || accessToken == null){
                //accessToken = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize').access_token;
                BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
                authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
                if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                  System.debug('BET_BDD_OFAC_Callout >> getOFACData: Success!');
                  accessToken = authInfo.access_token;
                  userId = authInfo.user_id;
                }
                else{
                     try{
                        throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                     }
                     catch(Exception e){
                        System.debug('BET_BDD_OFAC_Callout >> getOFACData >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                     }
                }
            //}
            HttpRequest req = new HttpRequest();
            if(searchType == 'i' || searchType == 'I'){
            req.setEndpoint('callout:BET_BDD/Ofac?imoNumber='+imoNumber+'&searchType='+searchType);
            }else if(searchType == 'e' || searchType == 'E'){
               req.setEndpoint('callout:BET_BDD/Ofac?entityName='+entityName+'&searchType='+searchType); 
            }
            
            req.setMethod('GET');
            req.setHeader('access_token', accessToken);
            req.setHeader('user_id', userId);
            req.setTimeout(120000);
            System.debug('req---'+req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
           	System.debug('Response Body = '+res.getBody());

            respBody  = res.getBody();
            statusCode = res.getStatusCode();
			
            if(statusCode == 200){
                ofacData = (BET_BDD_OFAC_WrapperClass)JSON.deserializeStrict(respBody,BET_BDD_OFAC_WrapperClass.class);
            }else if(statusCode == 500 || statusCode == 400 || statusCode == 401 || statusCode == 404){
                ofacData.responseCode = statusCode;
            }
            ofacData.accessToken = accessToken;
            system.debug('ofacData :'+ofacData);
        }catch (exception ex){
            ofacData.accessToken = accessToken;
            system.debug('exception error ofac--'+ex);
        }
        return ofacData;
    }
}