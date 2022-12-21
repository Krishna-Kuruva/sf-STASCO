/*=====================================================DESCRIPTION============================================================
	*Class Name 		: 	Export2ExcelDownloadController
	*Developer 		    : 	Rahul Sharma
	*Created Date   	:	29-Apr-2020
	*Purpose		    : 	Controller for Export2ExcelDownloader Page.
	===========================================MODIFICATION LOGS==============================================================
	*Developer	    	:	
	*Date			    :	
	*Description    	:	    
	==========================================================================================================================
*/
public with sharing class Export2ExcelDownloadController{
    
    public String userLocale {get;set;}
    public List<String> fields {get;set;}
    public List<String> columnName {get;set;}
    public List<sObject> recordList {get;set;}
    public List<List<sObject>> allRecords {get;set;}
    public List<Export2ExcelDownloadController.Columns> parserCol{get;set;}
    public String fileName {get;set;}
    public List<Columns> columns;
    
    public Export2ExcelDownloadController(){
        userLocale = UserInfo.getLocale();
        System.debug('UserLocale: '+userLocale);
    }
    public void fetchListviewRecords(){  
        
        columnName = new List<String>();
        fields = new List<String>();
        parserCol =  new List<Export2ExcelDownloadController.Columns>();
        recordList = new List<sObject>();
        allRecords = new List<List<sObject>>();
        try{
            String listid = apexpages.currentpage().getparameters().get('listid');
            String objectName = apexpages.currentpage().getparameters().get('objectName');
            String objectLabel = apexpages.currentpage().getparameters().get('objectLabel');
            String listName = apexpages.currentpage().getparameters().get('listName');
            fileName =  objectLabel.replace(' ', '_') +'__'+listName.replace(' ', '_') +'__'+ Datetime.now().format();
 
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            String endpointUrl = domainUrl+'/services/data/v32.0/sobjects/' +(objectName=='Person_Account' ? 'Account':objectName)+'/listviews/'+listid+'/describe';
            req.setEndpoint(endpointUrl);
            req.setMethod('GET');      
            Http h = new Http();
            HttpResponse res = h.send(req);
            Map<String,Object> root  = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
            for(Sobject sobj : Database.query((string)root.get('query'))){
                recordList.add(sobj);
                if(recordList.size() == 10000){
                    allRecords.add(recordList);
                    recordList = new List<sObject>();
                }
            }     
            if(recordList != null && !recordList.isEmpty())
                allRecords.add(recordList);  
    
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null){ 
                if(parser.getCurrentToken() == JSONToken.START_ARRAY) {       
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            Export2ExcelDownloadController.Columns le = (Export2ExcelDownloadController.Columns)parser.readValueAs(Export2ExcelDownloadController.Columns.class);
                            parserCol.add(le);
                            
                        }
                    }
                }
            }
            
            for(Export2ExcelDownloadController.Columns lc : parserCol){
                if(lc.hidden == false && lc.fieldNameOrPath != Null){
                    fields.add(lc.fieldNameOrPath);
                    columnName.add(lc.label);    
                }
            }
        }catch(Exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'There is some problem occurred."'));
        }
        
    }   
    
    public class Columns{       
        public String ascendingLabel;
        public String descendingLabel;
        public String fieldNameOrPath;
        public Boolean hidden;
        public String label;
        public String selectListItem;
        public String sortDirection;
        public Integer sortIndex;
        public Boolean sortable;
        public String type;
    }

}