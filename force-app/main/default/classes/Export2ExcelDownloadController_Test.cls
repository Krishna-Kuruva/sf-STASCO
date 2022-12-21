/*=====================================================DESCRIPTION============================================================
	*Class Name 		: 	Export2ExcelDownloadController_Test
	*Developer 	    	: 	Rahul Sharma
	*Created Date   	:	29-Apr-2020
	*Purpose	    	: 	Test class for Export2ExcelDownloadController.
	===========================================MODIFICATION LOGS==============================================================
	*Developer		    :	
	*Date		    	:	
	*Description    	:	
	==========================================================================================================================
*/
@isTest
public class Export2ExcelDownloadController_Test {
	
    @isTest
    static void testExport2ExcelDownloadController(){
        String objectName = 'Account';
        
        Test.startTest();
        ListView lstView = [SELECT Id, Name FROM ListView WHERE SObjectType =: objectName ORDER BY Name ASC LIMIT 1];
        
        PageReference pageRef = Page.Export2ExcelDownloader;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('listid', String.valueOf(lstView.Id));
        pageRef.getParameters().put('listName', String.valueOf(lstView.Name));
        pageRef.getParameters().put('objectName', objectName);
        pageRef.getParameters().put('objectLabel', objectName);
        
        Test.setMock(HttpCalloutMock.class, new Export2ExcelCalloutMock());
        
        Export2ExcelDownloadController controller = new Export2ExcelDownloadController();
        controller.fetchListviewRecords();
        Test.stopTest();
    }
}