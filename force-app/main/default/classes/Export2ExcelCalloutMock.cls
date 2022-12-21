/*=====================================================DESCRIPTION============================================================
	*Page Name 		: 	Export2ExcelCalloutMock
	*Developer 		: 	Rahul Sharma
	*Created Date	:	29-Apr-2020
	*Purpose		: 	Mock callout class for ListView API.
	===========================================MODIFICATION LOGS==============================================================
	*Developer		:	
	*Date			:	
	*Description	:	
	==========================================================================================================================
*/
@isTest
global class Export2ExcelCalloutMock implements HttpCalloutMock{
	
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"query":"Select Id from Account","columns":[ {"ascendingLabel" : "Z-A","label" : "Account Name","fieldNameOrPath" : "Account Name","hidden":false}]}');
        res.setStatusCode(200);
        return res;
    }
}