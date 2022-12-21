/******************************************************************************************************************
className           :    BET_BDD_Bankers_baidCallout
Description         :    This class calls the external API to get the Bankers baid details
*******************************************************************************************************************/
public class BET_BDD_Bankers_baidCallout {

    public static BET_BDD_Bankers_baidWrapper.responseParameterBaid getbaidData(String baidnumber,String accessToken){
        String errorStr = '';
        String Status = '';
        String respBody = '';
        String userId = '';
        Integer statusCode = 0;	
        
        BET_BDD_Bankers_baidWrapper.responseParameterBaid bankersbaid=new BET_BDD_Bankers_baidWrapper.responseParameterBaid();
		 
        try{
             //if(accessToken == '' || accessToken == null){
               BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
               authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
               if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                  System.debug('BET_BDD_Bankers_baidCallout >> getbaidData: Success!');
                  accessToken = authInfo.access_token;
                  userId = authInfo.user_id;
               }
               else{
                     try{
                        throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                     }
                     catch(Exception e){
                        System.debug('BET_BDD_Bankers_baidCallout >> getbaidData >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                     }
               }
            //}
        
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BET_BDD/Bankers/baid?baid='+baidnumber); 
            req.setMethod('GET');
            String headerStr = '';
            req.setHeader('access_token', accessToken);
            req.setHeader('user_id',userId);
            //req.setHeader('user_id', 'betedp.integration@shell.com.betdev');
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Response Body = '+res.getBody());
            System.debug('Response Status = '+res.getStatus());
            System.debug('Response StatusCode = '+res.getStatusCode());
            
            respBody  = res.getBody();
            statusCode = res.getStatusCode();
            
            if(statusCode == 200){
               bankersbaid = (BET_BDD_Bankers_baidWrapper.responseParameterBaid)JSON.deserializeStrict(respBody,BET_BDD_Bankers_baidWrapper.responseParameterBaid.class); 
            }else if(statusCode == 500 || statusCode == 400 || statusCode == 401){
               bankersbaid.responseCode = statusCode;
            }
            
            bankersbaid.accessToken = accessToken;
             
         }catch (exception ex){
            bankersbaid.accessToken = accessToken;
            system.debug('exception error--'+ex);
        }
        
        return bankersbaid;
        
        
    }
}