public class BET_BDD_VIES_Callout {
    public static BET_BDD_WrapperClass.responseParametersPdfFiles getViesData(String VATNumber, String CountryCode, String accessToken){
        string errorStr = '';
        string Status;
        string respBody = '';
        String userId = '';
        integer statusCode = 0;
        //Blob vatPFDdata ;
        BET_BDD_WrapperClass.responseParametersPdfFiles vatPFDdata1 = new BET_BDD_WrapperClass.responseParametersPdfFiles();
        try{
            //if(accessToken == '' || accessToken == null){
                //accessToken = BET_AuthenticationInfo.getAccesstoken().access_token;
                BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
                authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
                if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                    System.debug('BET_BDD_VIES_Callout >> getViesData: Success!');
                    accessToken = authInfo.access_token;
                    userId = authInfo.user_id;
                }
                else{
                        try{
                            throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                        }
                        catch(Exception e){
                            System.debug('BET_BDD_VIES_Callout >> getViesData >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                        }
                }
           //}  
            
            HttpRequest req = new HttpRequest();
            string endPoint='callout:BET_BDD/Vies/GetVIESData?CountryCode='+CountryCode+'&VATNumber='+VATNumber;
            req.setEndpoint(endPoint); 
            req.setMethod('GET');
            String headerStr = '';
            req.setHeader('access_token', accessToken);
            req.setHeader('user_id',userId);
            //req.setHeader('user_id', 'betedp.integration@shell.com.betdev');
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            //System.debug('Response Body = '+res.getBody());
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
            
            respBody  = res.getBody();
            statusCode = res.getStatusCode();
            
            //blob newB;        
            if(statusCode == 200){
                vatPFDdata1 = (BET_BDD_WrapperClass.responseParametersPdfFiles)JSON.deserializeStrict
                    (respBody,BET_BDD_WrapperClass.responseParametersPdfFiles.class);
            }else if(statusCode == 500 || statusCode == 400 || statusCode == 401){
                vatPFDdata1.responseCode = statusCode;
            }
            vatPFDdata1.accessToken = accessToken;
            //newB = EncodingUtil.base64Decode(vatPFDdata1.resultPayload);
            //vatPFDdata = newB.toString();
            //vatPFDdata =newB;
            //system.debug('return data--'+vatPFDdata);
        }catch (exception ex){
            vatPFDdata1.accessToken = accessToken;
            system.debug('exception error--'+ex);
        }
        return vatPFDdata1;
    }
   /* public static BET_BDD_WrapperClass.responseParametersPdfFiles getViesData(String CountryCode,String VATNumber){
        String errorStr = '';
        string Status;
        string respBody = '';
        BET_BDD_WrapperClass.responseParametersPdfFiles vatPFDdata= new BET_BDD_WrapperClass.responseParametersPdfFiles();
        try{
            
            HttpRequest req = new HttpRequest();
            string endPoint='callout:BET_BDD/Vies/GetVIESData?CountryCode='+CountryCode+'&VATNumber='+VATNumber;
            req.setEndpoint(endPoint); 
            req.setMethod('GET');
            String headerStr = '';
            req.setHeader('access_token', BET_AuthenticationInfo.getAccesstoken().access_token);
            req.setHeader('user_id', 'betedp.integration@shell.com.betdev');
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            //System.debug('Response Body = '+res.getBody());
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
            
            respBody  = res.getBody();
            vatPFDdata = (BET_BDD_WrapperClass.responseParametersPdfFiles)JSON.deserializeStrict(respBody,BET_BDD_WrapperClass.responseParametersPdfFiles.class);
            system.debug('return data--'+vatPFDdata);
            
        }catch (exception ex){
            system.debug('exception error--'+ex);
        }
        return vatPFDdata;
    }
    */
}