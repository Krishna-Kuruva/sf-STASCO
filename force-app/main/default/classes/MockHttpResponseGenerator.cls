@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock  {
    global HTTPResponse respond(HTTPRequest req) {  
     
        Http h = new Http(); 
        HttpResponse res = h.send(req);
        res.setStatusCode(200);
        String s = JSON.serialize('Deals updated Successfully');
        res.setBody(s);
        return res;
    }
    
      global HTTPResponse respondGet(HTTPRequest req) {  
     
        Http h = new Http(); 
        HttpResponse res = h.send(req);
        String s=JSON.serialize('Shell Online connection is disabled. Please contact Shell Support');
        res.setBody(s);
        res.setStatusCode(200);   
           
        return res;
    }
    
 
    
    global HTTPResponse respondGetRes1(HTTPRequest req) {  
     
        Http h = new Http(); 
        HttpResponse res = h.send(req);
        String s=JSON.serialize('No valid MRC Found');
        res.setBody(s);
        res.setStatusCode(200);   
           
        return res;
    }
}