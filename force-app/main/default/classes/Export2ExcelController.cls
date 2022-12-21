/*=====================================================DESCRIPTION============================================================
	*Class Name 		: 	Export2ExcelController
	*Developer 	    	: 	Rahul Sharma
	*Created Date	    :	29-Apr-2020
	*Purpose		    : 	Controller for Export2Excel Page.
	===========================================MODIFICATION LOGS==============================================================
	*Developer	    	:	
	*Date		    	:	
	*Description	    :	
	==========================================================================================================================
*/
public with sharing class Export2ExcelController{
    
    public SelectOption objectName{get;set;}
    public String listObjName{get;set;}
    public String selectedValue{get;set;}
    public String filterId{get;set;}
    public List<SelectOption> listViewOptions{get;set;}
    
    public Export2ExcelController(){
        String objectType = Apexpages.currentPage().getParameters().get('ObjectType');
        objectName = getObjectName(objectType);
        listObjName = objectName.getValue();
        if(listObjName != null){
            listViewOptions = getListViews(objectName.getValue());
        }
    }
    
     public PageReference setListId(){
        Id selectedFilter = Apexpages.currentPage().getParameters().get('listId');
        selectedValue = selectedFilter;
        System.debug('Export2ExcelController >> setListId >> ListId: '+selectedValue);
        return null;
    }
    
    public SelectOption getObjectName(String objectType){
        System.debug('Export2ExcelController >> getObjectName >> Object Code: '+objectType);
        try{
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectType});
            SelectOption objectName = new SelectOption(describeSobjectsResult[0].getName(), describeSobjectsResult[0].getLabel());
            System.debug('Export2ExcelController >> getObjectName >> Object Name: '+objectName);
            return objectName;
        }
        catch(Exception e){
            System.debug('Export2ExcelController >> getObjectName >> Exception: '+e.getMessage()+' Line Number: '+e.getLineNumber()+' Trace: '+e.getStackTraceString());
            return null;
        }
    }
    
    public List<SelectOption> getListViews(String objectName){
        List<SelectOption> listViewOptions = new List<SelectOption>();
        for(ListView lstView : [SELECT Id, Name FROM ListView WHERE SObjectType =: objectName ORDER BY Name ASC]){
            listViewOptions.add(new SelectOption(lstView.Id, lstView.Name)); 
        }
        return listViewOptions;
    }
    
    public PageReference updatePreviewParams(){
        System.debug('selectedValue### '+selectedValue);
        String selectedFilter = selectedValue.substring(0, 15);
        System.debug('selectedFilter### '+selectedFilter);
        filterId = selectedFilter;
        listObjName = null;
        return null;
    }
}