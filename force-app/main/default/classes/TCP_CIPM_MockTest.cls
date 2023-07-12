@isTest
global class TCP_CIPM_MockTest implements HttpCalloutMock {
    string statuscode;
    string tempbody;
    global TCP_CIPM_MockTest(string statCode, string body){
        statuscode = statCode;
        tempbody = body;
    }
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{"uuid": "123abc"}');
        response.setBody(tempbody);
        response.setStatusCode(integer.valueOf(statuscode));
        return response; 
    }
    
}