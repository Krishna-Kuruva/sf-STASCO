/*****************************************************************************
@Name:  BET_HTTPCallout     
@=========================================================================
@Purpose: HTTP Callout class for OLF
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    09-Sep-2020         INITIAL DEVELOPMENT

******************************************************************************/
public with sharing class BET_HTTPCallout {

    /*Mthod Name	: httpGet     
     *Developer		: Rahul Sharma
	 *Date			: 09-Sep-2020
	 *Description	: HTTP post callout*/
    public static HTTPCalloutWrap httpGet(String endpointUrl, String dataString, Map<String, String> headerMap, Integer timeOutInMillis){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        HTTPResponse response = new HTTPResponse();
        HTTPCalloutWrap calloutWrap = new HTTPCalloutWrap();
        if(timeOutInMillis == null)
            timeOutInMillis = 120000;
        request.setEndpoint(endpointUrl);
        request.setMethod('GET');
        request.setTimeout(timeOutInMillis);
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
                System.debug('BET_HTTPCallout >> httpGet: '+e.getMessage()+'. Line number: '+e.getLineNumber());
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
            System.debug('BET_HTTPCallout >> httpGet >> Unknown Exception. Message: '+e.getMessage());
            calloutWrap.statusCode = 000;
            calloutWrap.status = e.getMessage();
            calloutWrap.data = dataString;
            return calloutWrap;
        }
    }
    
	/*Mthod Name	: httpPost     
     *Developer		: Rahul Sharma
	 *Date			: 09-Sep-2020
	 *Description	: HTTP post callout*/
    public static HTTPCalloutWrap httpPost(String endpointUrl, String dataString, Map<String, String> headerMap, Integer timeOutInMillis){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        HTTPResponse response = new HTTPResponse();
        HTTPCalloutWrap calloutWrap = new HTTPCalloutWrap();
        if(timeOutInMillis == null)
            timeOutInMillis = 120000;
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setTimeout(timeOutInMillis);
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
                System.debug('BET_HTTPCallout >> httpPost: '+e.getMessage());
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
            System.debug('BET_HTTPCallout >> httpPost >> Unknown Exception. Message: '+e.getMessage()+'. Line number: '+e.getLineNumber());
            calloutWrap.statusCode = 000;
            calloutWrap.status = e.getMessage();
            calloutWrap.data = dataString;
            return calloutWrap;
        }
    }
    
    /*Mthod Name	: httpPut     
     *Developer		: Rahul Sharma
	 *Date			: 09-Sep-2020
	 *Description	: HTTP post callout*/
    public static HTTPCalloutWrap httpPut(String endpointUrl, String dataString, Map<String, String> headerMap, Integer timeOutInMillis){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        HTTPResponse response = new HTTPResponse();
        HTTPCalloutWrap calloutWrap = new HTTPCalloutWrap();
        if(timeOutInMillis == null)
            timeOutInMillis = 120000;
        request.setEndpoint(endpointUrl);
        request.setMethod('PUT');
        request.setTimeout(timeOutInMillis);
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
                System.debug('BET_HTTPCallout >> httpPut: '+e.getMessage()+'. Line number: '+e.getLineNumber());
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
            System.debug('BET_HTTPCallout >> httpPut >> Unknown Exception. Message: '+e.getMessage());
            calloutWrap.statusCode = 000;
            calloutWrap.status = e.getMessage();
            calloutWrap.data = dataString;
            return calloutWrap;
        }
    }
    
    /*Class Name	: CustomException     
     *Developer		: Rahul Sharma
	 *Date			: 09-Sep-2020
	 *Description	: Custom exception class*/
    public class CustomException extends Exception{}
    
    /*Class Name	: HTTPCalloutWrap     
     *Developer		: Rahul Sharma
	 *Date			: 09-Sep-2020
	 *Description	: Wrapper class to track HTTP Callout response*/
    public class HTTPCalloutWrap{
        public Integer statusCode;
        public String status;
        public String data;
        public String body; 
        public String header;
    }
}