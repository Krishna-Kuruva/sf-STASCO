/*****************************************************************************
@Name:  OLF_HTTP_Callout_Test     
@=========================================================================
@Purpose: Test class for OLF_HTTP_Callout class.
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    18-Mar-2021         INITIAL DEVELOPMENT

******************************************************************************/
@isTest
public class OLF_HTTP_Callout_Test{
    
    /*Method Name	:	test_httpGet
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpGet()
    */
    @isTest
    static void test_httpGet(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = 'http://test.com/OLF_HTTP_Callout_Test.test_httpGet';
        String data = 'Sample GET data.';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpGet(endPointUrl, data, headerMap);
        System.assertEquals(200, calloutWrap.statusCode);
    }
    
    /*Method Name	:	test_httpGet_excp
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpGet()
    */
    @isTest
    static void test_httpGet_excp(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = 'http://test.com/OLF_HTTP_Callout_Test.test_httpGet';
        String data = 'Sample GET data.';
        Map<String, String> headerMap = new Map<String, String>();
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpGet(endPointUrl, data, headerMap);
    }
    
    /*Method Name	:	test_httpGet_excp2
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpGet()
    */
    @isTest
    static void test_httpGet_excp2(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = '';
        String data = 'Sample GET data.';
        Map<String, String> headerMap = new Map<String, String>();
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpGet(endPointUrl, data, headerMap);
    }

    /*Method Name	:	test_httpPost
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpPost()
    */
    @isTest
    static void test_httpPost(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = 'http://test.com/OLF_HTTP_Callout_Test.test_httpPost';
        String data = 'Sample POST data.';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpPost(endPointUrl, data, headerMap);
        System.assertEquals(201, calloutWrap.statusCode);
    }
    
    /*Method Name	:	test_httpPost_excp
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpPost()
    */
    @isTest
    static void test_httpPost_excp(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = 'http://test.com/OLF_HTTP_Callout_Test.test_httpPost';
        String data = 'Sample POST data.';
        Map<String, String> headerMap = new Map<String, String>();
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpPost(endPointUrl, data, headerMap);
    }
    
    /*Method Name	:	test_httpPost_excp2
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpPost()
    */
    @isTest
    static void test_httpPost_excp2(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = '';
        String data = 'Sample POST data.';
        Map<String, String> headerMap = new Map<String, String>();
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpPost(endPointUrl, data, headerMap);
    }

    /*Method Name	:	test_httpPut
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpPut()
    */
    @isTest
    static void test_httpPut(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = 'http://test.com/OLF_HTTP_Callout_Test.test_httpPut';
        String data = 'Sample PUT data.';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpPut(endPointUrl, data, headerMap);
        System.assertEquals(200, calloutWrap.statusCode);
    }
    
    /*Method Name	:	test_httpPut_excp
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpPut()
    */
    @isTest
    static void test_httpPut_excp(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = 'http://test.com/OLF_HTTP_Callout_Test.test_httpPut';
        String data = 'Sample PUT data.';
        Map<String, String> headerMap = new Map<String, String>();
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpPut(endPointUrl, data, headerMap);
    }
    
    /*Method Name	:	test_httpPut_excp2
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for httpPut()
    */
    @isTest
    static void test_httpPut_excp2(){
        OLF_HTTP_Callout.HTTPCalloutWrap calloutWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
        String endPointUrl = '';
        String data = 'Sample PUT data.';
        Map<String, String> headerMap = new Map<String, String>();
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        calloutWrap = OLF_HTTP_Callout.httpPut(endPointUrl, data, headerMap);
    }
}