/*******************************************************************************************
 * Created by Madhu Javvaji on 18-Sep-22.
 * Connect APIGEE via ODATA 
********************************************************************************************/

global with sharing class APIGEE_AuthProvider extends Auth.AuthProviderPluginClass {
    
    private String customMetadataTypeApiName = 'APIGEE_Provider__mdt';
    public String redirectURL;
    private String key;
    private String secret;
    private String authUrl;
    private String accessTokenUrl;
    private String userInfoUrl;
    private String scope;
    private String callbackUrl;
    private String authProviderName = 'apigee';
    private String tokenUrl;
    private String clientId;
  private String clientSecret;
        
    global String getCustomMetadataType(){
        return customMetadataTypeApiName;
    }
    
	/*step 1*/   
    global PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropogate){   	
               
    	/*key          =  authProviderConfiguration.get('Consumer_Key__c');
        authUrl		 =  authProviderConfiguration.get('Auth_URL__c');
        scope    	 =  authProviderConfiguration.get('Scope__c');
        redirectURL	 =  authProviderConfiguration.get('Callback_URL__c');
        String urlToRedirect = authUrl+'?client_id='+key+'&redirect_url='+redirectURL+'&scope='+scope+
            				  '&state='+stateToPropagate+'&allow_signup=true';
            
        PageReference pageRef = new PageReference(urlToRedirect);
        retuen pageRef; */  
        
        callbackUrl = authProviderConfiguration.get('Callback_URL__c');
    	callbackUrl += +'?state=' + stateToPropogate;

    	return new PageReference(callbackUrl); 
    }
    
    /*step 2*/
    global Auth.AuthProviderTokenResponse handleCallback(Map<string, string> authProviderConfiguration,Auth.AuthProviderCallbackState state) {
    	String authCode = state.queryParameters.get('code'); //get the authorization code received in 1st step
        String sfdcState = state.queryParameters.get('state');
        
        String access_token = retrieveToken(authProviderConfiguration);
        
        return new Auth.AuthProviderTokenResponse(
          authProviderName,
          access_token,
          access_token,
          state.queryParameters.get('state')
        );

    	/*return new Auth.AuthProviderTokenResponse(
      		authProviderName,
      		tokenResponseObject.access_token,
      		tokenResponseObject.refresh_token,
      		state.queryParameters.get('state')
    	);*/
  	}  
    
    /****** refresh the token ******/
    
    global override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfiguration, String refreshToken) {
    	String access_token = retrieveToken(authProviderConfiguration);
    	return new Auth.OAuthRefreshResult(access_token, access_token);
  	}
    
    global Auth.UserData getUserInfo( Map<string, string> authProviderConfiguration,Auth.AuthProviderTokenResponse response) {
    	return new Auth.UserData('fakeId','first','last','full','email','link',null,null,null,null,null);
    }
    
    private String retrieveToken(Map<string, string> authProviderConfiguration) {
    
    tokenUrl = authProviderConfiguration.get('Token_URL__c');   
        

    clientId = authProviderConfiguration.get('Consumer_Key__c');
    clientSecret = authProviderConfiguration.get('Consumer_Secret__c');
    scope = authProviderConfiguration.get('scope__c');

    Http http = new Http();
    HttpRequest request = new HttpRequest();

    request.setEndpoint(tokenUrl);
    request.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
    request.setMethod('POST'); 

    String body = 'client_id=' + clientId;
    body += '&client_secret=' + clientSecret;
    body += '&grant_type=client_credentials';
    body += '&scope=' + scope;

    request.setBody(body);

    HttpResponse response = http.send(request);
    ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(),ResponseWrapper.class);

    return responseWrapper.access_token;
  }
    
    /****** Response wrapper class **********/
    
    public class ResponseWrapper {
    	public String access_token;
    	public String token_type;
    	public String expires_in;
  	}

}