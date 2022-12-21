/*****************************************************************************
@Name:  OLF_HTTP_Callout     
@=========================================================================
@Purpose: HTTP Callout class for OLF
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    12-May-2020         INITIAL DEVELOPMENT

******************************************************************************/
public with sharing class OLF_HTTP_Callout {

    /*Mthod Name	: httpGet     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: HTTP post callout*/
    public static HTTPCalloutWrap httpGet(String endpointUrl, String dataString, Map<String, String> headerMap){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        HTTPResponse response = new HTTPResponse();
        HTTPCalloutWrap calloutWrap = new HTTPCalloutWrap();
        
        request.setEndpoint(endpointUrl);
        request.setMethod('GET');
        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                request.setHeader(key, headerMap.get(key));
            }            
        }
        else{
            try{
                throw new CustomException('setHeader method cannot be empty.');
            }
            catch(Exception e){
                System.debug('OLF_HTTP_Callout >> httpGet: '+e.getMessage()+'. Line number: '+e.getLineNumber());
            }
        }
        request.setBody(dataString);
        try{
            response = http.send(request); 
            calloutWrap.statusCode = response.getStatusCode();
            calloutWrap.status = response.getStatus();
            calloutWrap.data = dataString;
            calloutWrap.body = response.getBody();
            return calloutWrap;
        }
        catch(System.CalloutException e){
            System.debug('OLF_HTTP_Callout >> httpGet >> Unknown Exception. Message: '+e.getMessage());
            calloutWrap.statusCode = 000;
            calloutWrap.status = e.getMessage();
            calloutWrap.data = dataString;
            return calloutWrap;
        }
    }
    
	/*Mthod Name	: httpPost     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: HTTP post callout*/
    public static HTTPCalloutWrap httpPost(String endpointUrl, String dataString, Map<String, String> headerMap){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        HTTPResponse response = new HTTPResponse();
        HTTPCalloutWrap calloutWrap = new HTTPCalloutWrap();
        
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                request.setHeader(key, headerMap.get(key));
            }            
        }
        else{
            try{
                throw new CustomException('setHeader method cannot be empty.');
            }
            catch(Exception e){
                System.debug('OLF_HTTP_Callout >> httpPost: '+e.getMessage());
            }
        }
        request.setBody(dataString);
        try{
            response = http.send(request); 
            calloutWrap.statusCode = response.getStatusCode();
            calloutWrap.status = response.getStatus();
            calloutWrap.data = dataString;
            calloutWrap.body = response.getBody();
            return calloutWrap;
        }
        catch(System.CalloutException e){
            System.debug('OLF_HTTP_Callout >> httpPost >> Unknown Exception. Message: '+e.getMessage()+'. Line number: '+e.getLineNumber());
            calloutWrap.statusCode = 000;
            calloutWrap.status = e.getMessage();
            calloutWrap.data = dataString;
            return calloutWrap;
        }
    }
    
    /*Mthod Name	: httpPut     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: HTTP post callout*/
    public static HTTPCalloutWrap httpPut(String endpointUrl, String dataString, Map<String, String> headerMap){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        HTTPResponse response = new HTTPResponse();
        HTTPCalloutWrap calloutWrap = new HTTPCalloutWrap();
        
        request.setEndpoint(endpointUrl);
        request.setMethod('PUT');
        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                request.setHeader(key, headerMap.get(key));
            }            
        }
        else{
            try{
                throw new CustomException('setHeader method cannot be empty.');
            }
            catch(Exception e){
                System.debug('OLF_HTTP_Callout >> httpPut: '+e.getMessage()+'. Line number: '+e.getLineNumber());
            }
        }
        request.setBody(dataString);
        try{
            response = http.send(request); 
            calloutWrap.statusCode = response.getStatusCode();
            calloutWrap.status = response.getStatus();
            calloutWrap.data = dataString;
            calloutWrap.body = response.getBody();
            return calloutWrap;
        }
        catch(System.CalloutException e){
            System.debug('OLF_HTTP_Callout >> httpPut >> Unknown Exception. Message: '+e.getMessage());
            calloutWrap.statusCode = 000;
            calloutWrap.status = e.getMessage();
            calloutWrap.data = dataString;
            return calloutWrap;
        }
    }
    
    /*Class Name	: CustomException     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Custom exception class*/
    public class CustomException extends Exception{}
    
    /*Class Name	: HTTPCalloutWrap     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Wrapper class to track HTTP Callout response*/
    public class HTTPCalloutWrap{
        public Integer statusCode;
        public String status;
        public String data;
        public String body; 
        public String header;
    }
}