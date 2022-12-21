/******************************************************************************************************************
className           :    BET_BDD_SovosCallout
Description         :    This class calls the external API to get the Sovos pdf file. Response file data in base64 format
*******************************************************************************************************************/
public class BET_BDD_SovosCallout {
    public static BET_BDD_WrapperClass.responseParametersPdfFiles getSovosData(String Name,String TinNumber,String TinType,String accessToken){
        String errorStr = '';
        String Status = '';
        String respBody = '';
        String userId = '';
        Integer statusCode = 0;
        
        BET_BDD_WrapperClass.responseParametersPdfFiles SovosPFDdata= new BET_BDD_WrapperClass.responseParametersPdfFiles();
        try{
            //if(accessToken == '' || accessToken == null){
                //accessToken = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize').access_token;
                BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
                authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
                if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                    System.debug('BET_BDD_SovosCallout >> getSovosData: Success!');
                    accessToken = authInfo.access_token;
                    userId = authInfo.user_id;
                }
                else{
                        try{
                            throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                        }
                        catch(Exception e){
                            System.debug('BET_BDD_SovosCallout >> getSovosData >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                        }
                }
            //}  
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BET_BDD/Sovos?Name='+Name.replaceAll(' ','%20')+'&TinNumber='+TinNumber+'&TinType='+TinType); 
            req.setMethod('GET');
            String headerStr = '';
            req.setHeader('access_token', accessToken);
            req.setHeader('user_id',userId);
            //req.setHeader('user_id', 'betedp.integration@shell.com.betdev');
            req.setTimeout(120000);
            
            system.debug('req body--'+req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Response Body = '+res.getBody());
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
            
            respBody  = res.getBody();
            statusCode = res.getStatusCode();
            
            if(statusCode == 200){
                SovosPFDdata = (BET_BDD_WrapperClass.responseParametersPdfFiles)JSON.deserializeStrict(respBody,BET_BDD_WrapperClass.responseParametersPdfFiles.class); 
            }else if(statusCode == 500 || statusCode == 400 || statusCode == 401){
                SovosPFDdata.responseCode = statusCode;
            }
            SovosPFDdata.accessToken = accessToken;
        }catch (exception ex){
            SovosPFDdata.accessToken = accessToken;
            system.debug('exception error--'+ex);
        }
        return SovosPFDdata;
    }
}