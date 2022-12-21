/******************************************************************************************************************
className           :    BET_fileuplaodToSharepoint
Description         :    This class notifies the external system with the file details uploaded in BDD Document object.  
*******************************************************************************************************************/
global class BET_fileuplaodToSharepoint {
    
    //wrapper class for file details
    public class ParametersPdfFiles{
        public string recordName {get;set;}
        public string linktodownload {get;set;}
        public String sharepointFolderName {get;set;}
        public string sharePointFileName {get;set;} 
        public string documentID {get;set;}   
        
    } 
    
    public class responseFileDetails{
        public List<String> resultPayload;
        public String responseMessage;
        public Boolean isSuccess;
        public Integer responseCode;
    }
    
    
    //This method will notify only one file detail to external system
    @future (callout=true)
    public static void indicateExternalSystem(id bddDocumentID){
        String errorStr='';
        String respBody = '';
        String userId = '';
        String accessToken = '';
        Integer statusCode = 0;	
        BET_fileuplaodToSharepoint.ParametersPdfFiles jsondata= new  BET_fileuplaodToSharepoint.ParametersPdfFiles();
        BET_fileuplaodToSharepoint.responseFileDetails responseData= new  BET_fileuplaodToSharepoint.responseFileDetails();
        
        BET_BDD_Document__c fileDetails;
        ContentVersion  fileuploaded;
        try{
            fileDetails=[select Id ,BET_Upload_Status__c,BET_Source__c,BET_Manual_Upload__c, Name,BET_Document__c,BET_SharePoint_Fld_Name__c,BET_Doc_Name__c from BET_BDD_Document__c where id=:bddDocumentID limit 1];
            BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
            authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
            if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
                System.debug('BET_BDD_VIES_Callout >> indicateExternalSystem: Success!');
                accessToken = authInfo.access_token;
                userId = authInfo.user_id;
            }
            else{
                    try{
                        throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
                    }
                    catch(Exception e){
                        System.debug('BET_BDD_VIES_Callout >> indicateExternalSystem >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
                    }
            }
            system.debug('BET_fileuplaodToSharepoint >> indicateExternalSystem ');
            
            //document details
            fileuploaded=[SELECT id ,FileExtension,ContentDocumentId,FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId=:bddDocumentID OR BET_BDD_Document_ID__c=:bddDocumentID limit 1];        
            //JSON creation 
            jsondata.recordName=fileDetails.Name;
            jsondata.sharepointFolderName=fileDetails.BET_SharePoint_Fld_Name__c;
            jsondata.sharePointFileName= fileDetails.BET_Doc_Name__c + '.' + fileuploaded.FileExtension;
            jsondata.linktodownload='/services/data/v49.0/sobjects/ContentVersion/'+fileuploaded.Id+'/VersionData';
            jsondata.documentID=bddDocumentID;
            
            
            //indicating to an external system
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            req.setHeader('appName', 'BET');
            req.setHeader('user_id',userId);
            req.setHeader('access_token', accessToken);            
            req.setMethod('POST');
            req.setEndpoint('callout:BET_BDD/SharePointService'); 
            req.setTimeout(120000);
            String JsonString=JSON.serialize(jsondata);
            req.setBody(JsonString);
            system.debug(JsonString); 
            //Http response method 
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            respBody=res.getBody();
            statusCode=res.getStatusCode();
            if(statusCode == 200){
                responseData = (BET_fileuplaodToSharepoint.responseFileDetails)JSON.deserializeStrict(res.getBody(),BET_fileuplaodToSharepoint.responseFileDetails.class); 
                if(responseData.resultPayload != null || !responseData.resultPayload.isEmpty())
                    fileDetails.BET_IDD_Link__c=responseData.resultPayload[0];
                else
                    errorStr=responseData.responseMessage;
            }
            else{
                errorStr=String.valueOf(statusCode);
            }
            
        }
        catch (exception ex){
            system.debug('exception error--'+ex);
            errorStr=ex.getmessage();
        }finally{
            
            fileDetails.BET_Manual_Upload__c=true;
            if(errorStr == ''){
                fileDetails.BET_Upload_Status__c='Success';
                system.debug('fileuploaded.id+'+fileuploaded.id);
                //deleting the document in salesforce on successful upload to SharePoint 
                try{
                    ContentDocument deleteDoc=[SELECT Id,  LatestPublishedVersionId FROM ContentDocument where id=:fileuploaded.ContentDocumentId];
                    
                    delete deleteDoc;
                }catch (exception ex){
                    system.debug('exception error--'+ex);
                    errorStr=ex.getmessage();
                }
            }
            else{
                fileDetails.BET_Upload_Status__c='Failed'; 
                fileDetails.Error_Message__c=errorStr;                
            }
            
            update fileDetails;
        }
    }
}