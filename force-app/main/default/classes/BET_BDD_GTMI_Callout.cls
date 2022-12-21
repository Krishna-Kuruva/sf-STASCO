public class BET_BDD_GTMI_Callout {
    public static BET_BDD_GTMI_WrapperClass getGTMIData(String searchCounterParty, String searchIMO, Integer count, String accessToken){
        system.debug('Attributes from UI: searchCounterParty='+searchCounterParty+ ';IMONum='+searchIMO+';accessToken='+accessToken);
        String respBody = '';
        String userId ='';
        Integer statusCode = 0;
        BET_BDD_GTMI_WrapperClass gtmiData = new BET_BDD_GTMI_WrapperClass();
        searchCounterParty = EncodingUtil.urlEncode(searchCounterParty, 'UTF-8');
        try{
            //if(accessToken == '' || accessToken == null){
                //accessToken = BET_AuthenticationInfo.getAccesstoken().access_token;
                BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
                authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
            	System.debug('Here'+authInfo);
                if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                    System.debug('BET_BDD_GTMI_Callout >> getGTMIData: Success!');
                    accessToken = authInfo.access_token;
                    userId = authInfo.user_id;
                }
                else{
                        try{
                            throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                        }
                        catch(Exception e){
                            System.debug('BET_BDD_GTMI_Callout >> getGTMIData >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                        }
                }
            //}
            
            HttpRequest req = new HttpRequest();
            if(searchCounterParty == '' || searchCounterParty == null){
                req.setEndpoint('callout:BET_BDD_GTMI/GTMI?IMONumber='+searchIMO+'&RecordCount='+count);
                    System.debug('req.setEndpoint----'+req);
            }else if(searchIMO == '' || searchIMO == null){
                req.setEndpoint('callout:BET_BDD_GTMI/GTMI?CounterParty='+searchCounterParty+'&RecordCount='+count); 
            }
            
            req.setMethod('GET');
            String headerStr = '';
            req.setHeader('access_token', accessToken);
            req.setHeader('user_id', userId);
            req.setTimeout(120000);
            System.debug('req---'+req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
           	System.debug('Response Body = '+res.getBody());
            
            statusCode = res.getStatusCode(); 
            
            if(statusCode == 200){
                respBody  = res.getBody();
            	gtmiData = (BET_BDD_GTMI_WrapperClass)JSON.deserializeStrict(respBody,BET_BDD_GTMI_WrapperClass.class);
            }else if(statusCode == 204 || statusCode == 400 || statusCode == 401 || statusCode == 401 || statusCode == 500){
                gtmiData.responseCode = statusCode;
            }

            gtmiData.accessToken = accessToken;
            
            System.debug('responseCode--'+gtmiData.responseCode);
            System.debug('return gtmi data--'+gtmiData);
        }catch (exception ex){
            system.debug('exception error--'+ex);
            gtmiData.accessToken = accessToken;
        }
        return gtmiData;
    }

}