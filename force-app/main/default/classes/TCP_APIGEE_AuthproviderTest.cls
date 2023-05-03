@IsTest
private class TCP_APIGEE_AuthproviderTest {
  /*private static String callbackUrl = 'https://stasco--uat.sandbox.my.salesforce.com/s...';
  private static String tokenEndpoint = 'https://api-dev.shell.com/v1/oauth/token';
  private static String clientId = '12';
  private static String clientSecret = '34';
  private static String scope = 'scope';
  private static String authProviderName = 'apigee';
  private static final String ACCESS_TOKEN = 'token';

  private static Map<String, String> setupAuthProviderConfig() {
    Map<String, String> authProviderConfiguration = new Map<String, String>();

    authProviderConfiguration.put('Callback_URL__c', callbackUrl);
    authProviderConfiguration.put('Token_URL__c', tokenEndpoint);
    //authProviderConfiguration.put('tokenEndpointProd__c', tokenEndpoint);
    authProviderConfiguration.put('Consumer_Key__c', clientId);
    authProviderConfiguration.put('Consumer_Secret__c', clientSecret);
    authProviderConfiguration.put('scope__c', scope);

    return authProviderConfiguration;
  }

  @IsTest
  static void testInitiateMethod() {
    String stateToPropagate = 'state';
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    APIGEE_AuthProvider tempAuthProvider = new APIGEE_AuthProvider();
    //tempAuthProvider.getCustomMetadataType();
    tempAuthProvider.callbackUrl = authProviderConfiguration.get(
      'Callback_URL__c'
    );

    PageReference expectedUrl = new PageReference(
      callbackUrl +
      '?state=' +
      stateToPropagate
    );

    PageReference actualUrl = PingAuthProvider.initiate(
      authProviderConfiguration,
      stateToPropagate
    );
    System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
  }

  @IsTest
  static void testHandleCallback() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    AuthProvider pingAuthProvider = new AuthProvider();
    Test.setMock(
      HttpCalloutMock.class,
      new PingAuthProviderMockHttpResponseGenerator()
    );

    Map<String, String> queryParams = new Map<String, String>();

    queryParams.put('state', authProviderConfiguration.get('State_c'));

    Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(
      null,
      null,
      queryParams
    );
    Auth.AuthProviderTokenResponse actualAuthProvResponse = PingAuthProvider.handleCallback(
      authProviderConfiguration,
      cbState
    );
    Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(
      authProviderName,
      ACCESS_TOKEN,
      ACCESS_TOKEN,
      null
    );

    System.assertEquals(
      expectedAuthProvResponse.provider,
      actualAuthProvResponse.provider
    );
    System.assertEquals(
      expectedAuthProvResponse.oauthToken,
      actualAuthProvResponse.oauthToken
    );
    System.assertEquals(
      expectedAuthProvResponse.oauthSecretOrRefreshToken,
      actualAuthProvResponse.oauthSecretOrRefreshToken
    );
    System.assertEquals(
      expectedAuthProvResponse.state,
      actualAuthProvResponse.state
    );

    Auth.OAuthRefreshResult expectedRefreshResult = new Auth.OAuthRefreshResult(
      ACCESS_TOKEN,
      ACCESS_TOKEN
    );
    Auth.OAuthRefreshResult actualRefreshResult = PingAuthProvider.refresh(
      authProviderConfiguration,
      'token'
    );
    system.assertEquals(
      expectedRefreshResult.accessToken,
      actualRefreshResult.accessToken
    );
  }

  @IsTest
  static void testUserInfo() {
    APIGEE_AuthProvider pingAuthProvider = new APIGEE_AuthProvider();
    APIGEE_AuthProvider.getUserInfo(
      new Map<String, String>(),
      new Auth.AuthProviderTokenResponse('1', '2', '3', null)
    );
  }

  public class PingAuthProviderMockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      APIGEE_AuthProvider.ResponseWrapper responseWrapper = new APIGEE_AuthProvider.ResponseWrapper();
      responseWrapper.access_token = 'token';
      responseWrapper.expires_in = '7199';
      responseWrapper.token_type = 'Bearer';

      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(200);
      res.setBody(JSON.serialize(responseWrapper));

      return res;
    }
  }*/
}