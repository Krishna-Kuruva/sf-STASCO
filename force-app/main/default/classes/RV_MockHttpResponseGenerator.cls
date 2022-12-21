/*****************************************************************************
@Name:  RV_MockHttpResponseGenerator     
@=========================================================================
@Purpose: This is mock resposne generator for Revolution Germany callouts. 
          Identification of request is determined by the endpoint Url sent via request.
          Implment new mock reponse by identifying unique enpoint url.
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    18-Mar-2021         INITIAL DEVELOPMENT

******************************************************************************/
@isTest
global class RV_MockHttpResponseGenerator implements HttpCalloutMock{

    global static String customEndpoint;
    /*Method Name	:	respond
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	main method to generate response.
    */
    global HTTPResponse respond(HTTPRequest req){
        if(req != null){
            String endpoint = req.getEndpoint();
            HTTPResponse response = new HTTPResponse();
            if(!String.isBlank(endpoint)){
                //Mock response for OLF_HTTP_Callout.httpGet(String, String, Map<String, String>);
                if(endpoint == 'http://test.com/OLF_HTTP_Callout_Test.test_httpGet'){
                    response = mockHttpGetResponse(req);
                }
                //Mock response for OLF_HTTP_Callout.httpPost(String, String, Map<String, String>);
                else if(endpoint == 'http://test.com/OLF_HTTP_Callout_Test.test_httpPost'){
                    response = mockHttpPostResponse(req);
                }
                //Mock response for OLF_HTTP_Callout.httpPut(String, String, Map<String, String>);
                else if(endpoint == 'http://test.com/OLF_HTTP_Callout_Test.test_httpPut'){
                    response = mockHttpPutResponse(req);
                }
                else{
                    //If enpoint cannot be modifed within request body then initialize customEndpoint variable. Those reponse could be mocked below.
                    if(!String.isBlank(customEndpoint)){
                        if(customEndpoint == 'http://test.com/'){

                        }
                    }
                    else{
                        CalloutException excp = new CalloutException();
                        excp.setMessage('Endpoint URL is empty.');
                        throw excp;
                    }
                }   
            }
            else{
                CalloutException excp = new CalloutException();
                excp.setMessage('Endpoint URL is empty.');
                throw excp;
            }
            return response;
        }
        else{
            return null;
        }
    }

    /*Method Name	:	mockHttpGetResponse
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	create mock response for simple GET request.
    */
    private static HTTPResponse mockHttpGetResponse(HTTPRequest req){
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Get request successful.');
        return res;
    }

    /*Method Name	:	mockHttpPostResponse
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	create mock response for simple POST request.
    */
    private static HTTPResponse mockHttpPostResponse(HTTPRequest req){
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }

    /*Method Name	:	mockHttpPutResponse
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	create mock response for simple PUT request.
    */
    private static HTTPResponse mockHttpPutResponse(HTTPRequest req){
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
}