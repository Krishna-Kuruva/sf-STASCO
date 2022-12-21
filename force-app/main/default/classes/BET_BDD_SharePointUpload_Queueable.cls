/*************************************************************************************
    @Name:  BET_BDD_SharePointUpload_Queueable     
    @=================================================================================
    @Purpose: Queueable class to upload SharePoint documents.
    @=================================================================================
    @History                                                            
    @---------                                                            
    @VERSION AUTHOR                            DATE                DETAIL                                 
    @1.0 - Rahul Sharma     ```````````````    10-Sep-2020         INITIAL DEVELOPMENT
    
*************************************************************************************/
public with sharing class BET_BDD_SharePointUpload_Queueable implements Queueable,  Database.AllowsCallouts{

    private String accessToken;
    private String userId;
    private List<BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper> endPointVsDocWrapList = new List<BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper>();
    BET_BDD_WrapperClass.OAuth2AccessToken sfdcAuthInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
    /*Constructor Name   : BET_BDD_SharePointUpload_Queueable
     *Date               : 10-Sep-2020
     *Developer          : Rahul Sharma
     *Description        : Default constructor
     */
    public BET_BDD_SharePointUpload_Queueable() {

    }

    /*Constructor Name   : BET_BDD_SharePointUpload_Queueable
     *Date               : 10-Sep-2020
     *Developer          : Rahul Sharma
     *Description        : Contructor for upload via EDP
     */
    public BET_BDD_SharePointUpload_Queueable(List<BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper> endPointVsDocWrapList) {
        this.endPointVsDocWrapList = endPointVsDocWrapList;
        this.accessToken = endPointVsDocWrapList[0].accessToken;
        this.userId = endPointVsDocWrapList[0].userId;
    }

    /*Method Name   : execute
     *Date          : 10-Sep-2020
     *Developer     : Rahul Sharma
     *Description   : Main method.
     */
    public void execute(QueueableContext qc){
        //Upload Document via EDP
        List<BET_BDD_Document__c> bddDocList = new List<BET_BDD_Document__c>();
        if(!endPointVsDocWrapList.isEmpty()){
            if(String.isEmpty(accessToken) || String.isEmpty(userId))
                authorizeEDP();
            for(BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper edpUploadWrap : endPointVsDocWrapList){
                BET_HTTPCallout.HTTPCalloutWrap responseWrap = new BET_HTTPCallout.HTTPCalloutWrap();
                BET_BDD_WrapperClass.EdpResponseWrapper edpRespWrap = new BET_BDD_WrapperClass.EdpResponseWrapper();
                BET_BDD_Document__c bddDoc = new BET_BDD_Document__c();
                Map<String, String> headerMap = new Map<String, String>();
                headerMap.put('access_token', accessToken);
                headerMap.put('user_id', userId);
                responseWrap = BET_HTTPCallout.httpPost(edpUploadWrap.endPointURL, '', headerMap, 120000);
                if(responseWrap.body != null)
                    edpRespWrap = (BET_BDD_WrapperClass.EdpResponseWrapper)JSON.deserializeStrict(responseWrap.body, BET_BDD_WrapperClass.EdpResponseWrapper.class);
                if(responseWrap.statusCode == 200){
                    System.debug('BET_BDD_SharePointUpload_Queueable >> execute: Document is Uploaded successfully! PayLoad: ' + edpRespWrap.resultPayload);
                    if(edpRespWrap.resultPayload != null){
                        bddDoc.BET_IDD_Link__c = edpRespWrap.resultPayload[0];
                        bddDoc.BET_Upload_Status__c = 'Success';
                        bddDoc.Id = edpUploadWrap.bddDoc.Id;
                    }
                    else{
                        bddDoc.BET_Upload_Status__c = 'Failed';
                        bddDoc.Id = edpUploadWrap.bddDoc.Id;
                        bddDoc.Error_Message__c = 'Error: Status Code - ' + responseWrap.statusCode + ' | Message: Document not found.';
                    }
                }
                else{
                    System.debug('BET_BDD_SharePointUpload_Queueable >> execute: Upload Failed!. Response: ' + responseWrap.body + ' Status Code: ' + responseWrap.statusCode);
                    bddDoc.BET_Upload_Status__c = 'Failed';
                    bddDoc.Id = edpUploadWrap.bddDoc.Id;
                    bddDoc.Error_Message__c = 'Error: Status Code - ' + responseWrap.statusCode + ' | Message: ';
                    if(edpRespWrap.responseMessage != null)
                        bddDoc.Error_Message__c += edpRespWrap.responseMessage;
                    else
                        bddDoc.Error_Message__c += responseWrap.status;
                }
                bddDocList.add(bddDoc);
            }
            if(!bddDocList.isEmpty()){
                Database.update(bddDocList);
            }
        }
    }

    /*Method Name   : authorizeEDP
     *Date          : 09-Sep-2020
     *Developer     : Rahul Sharma
     *Description   : This method authorize the EDP by sending access token.
     */
    private void authorizeEDP(){
        BET_BDD_WrapperClass.OAuth2AccessToken authInfo = new BET_BDD_WrapperClass.OAuth2AccessToken();
        authInfo = BET_AuthenticationInfo.getAccesstoken('BET_EDP_Self_Authorize');
        if(authInfo != null && authInfo.access_token != null && authInfo.user_id != null){
            System.debug('BET_BDD_SharePointUploadController >> authorizeEDP: Success!');
            accessToken = authInfo.access_token;
            userId = authInfo.user_id;
        }
        else{
            try{
                throw new BET_BDD_SharePointUploadController.CustomException('Authentication Failed! Response: ' + authInfo);
            }
            catch(Exception e){
                System.debug('BET_BDD_SharePointUploadController >> authorizeEDP >> Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            }
        }
    }

}