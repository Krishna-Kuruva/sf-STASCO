/*=====================================================DESCRIPTION============================================================
	*Class Name 		: 	Export2ExcelController_Test
	*Developer 	    	: 	Rahul Sharma
	*Created Date   	:	29-Apr-2020
	*Purpose		    : 	Test class for Export2ExcelController class.
	===========================================MODIFICATION LOGS==============================================================
	*Developer	    	:	
	*Date			    :	
	*Description    	:	
	==========================================================================================================================
*/
@isTest
public class Export2ExcelController_Test {
    
    @isTest
    static void testExport2ExcelController(){
        Test.startTest();
        PageReference pageRef = Page.Export2Excel;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('ObjectType', 'Account');
        Export2ExcelController controller = new Export2ExcelController();
        pageRef.getParameters().put('listId', controller.listViewOptions[0].getValue());
        controller.setListId();
        controller.updatePreviewParams();
        Test.stopTest();
    }
}