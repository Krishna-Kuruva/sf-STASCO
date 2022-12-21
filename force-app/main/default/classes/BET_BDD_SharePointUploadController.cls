/*************************************************************************************
    @Name:  BET_BDD_SharePointUploadController     
    @=================================================================================
    @Purpose: This class contains all the neccesary logics to upload BDD Documents to
              the SharePoint.
    @=================================================================================
    @History                                                            
    @---------                                                            
    @VERSION AUTHOR                            DATE                DETAIL                                 
    @1.0 - Rahul Sharma     ```````````````    09-Sep-2020         INITIAL DEVELOPMENT
    
*************************************************************************************/
public with sharing class BET_BDD_SharePointUploadController {

    private static String accessToken;
    private static String userId;
    
    /*Controller Name   : BET_BDD_SharePointUploadController
     *Date              : 09-Sep-2020
     *Developer         : Rahul Sharma
     *Description       : Default constructor
     */
    public BET_BDD_SharePointUploadController() {

    }

    /*Block Name    : static
     *Date          : 09-Sep-2020
     *Developer     : Rahul Sharma
     *Description   : static block for one time operation.
     */
    static{

    }

    /*Method Name   : enqueueEdpCallout
     *Date          : 09-Sep-2020
     *Developer     : Rahul Sharma
     *Description   : This method enqueue callout at EDP ednpoint.
     */
    public static void enqueueEdpCallout(List<BET_BDD_Document__c> docListNew, Map<Id, BET_BDD_Document__c> docMapOld){
        List<BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper> endPointVsDocWrapList = new List<BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper>();
        for(BET_BDD_Document__c bddDoc : docListNew){
            BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper endPointVsDocWrap = new BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper();
            if(!bddDoc.BET_Manual_Upload__c && bddDoc.BET_Source__c != 'Other' && !docListNew.isEmpty() && docMapOld.isEmpty() && !bddDoc.BET_Retry__c){
                System.debug('BET_BDD_SharePointUploadController >> enqueueEdpCallout(): Document is record is created automatically.');
                endPointVsDocWrap = BET_BDD_SharePointUploadController.determineEdpEndPoint(bddDoc);
            }
            
            //Retry Document Upload via EDP
            else if(!bddDoc.BET_Manual_Upload__c && bddDoc.BET_Source__c != 'Other' && bddDoc.BET_Retry__c && !docListNew.isEmpty() && !docMapOld.isEmpty()){
                System.debug('docMapOld.get(bddDoc.Id).BET_Retry__c'+docMapOld.get(bddDoc.Id).BET_Retry__c);
                System.debug('bddDoc.BET_Retry__c'+bddDoc.BET_Retry__c);
                if(!docMapOld.get(bddDoc.Id).BET_Retry__c && bddDoc.BET_Retry__c){
                    if(bddDoc.BET_Upload_Status__c == 'Failed'){
                        System.debug('BET_BDD_SharePointUploadController >> enqueueEdpCallout(): Retry Upload via EDP');
                        bddDoc.BET_Retry__c = false;
                        bddDoc.BET_Upload_Status__c = 'In Progress';
                        endPointVsDocWrap = BET_BDD_SharePointUploadController.determineEdpEndPoint(bddDoc);
                    }
                    else{
                        bddDoc.addError('Document cannot be uploaded at this moment.');
                    }
                }  
            }
            if(!String.isEmpty(endPointVsDocWrap.endPointURL) && endPointVsDocWrap.bddDoc != null)
                endPointVsDocWrapList.add(endPointVsDocWrap);
            }
            if(!endPointVsDocWrapList.isEmpty()){
                System.debug('BET_BDD_SharePointUploadController >> enqueueEdpCallout(): Job Enqueued.');
                BET_BDD_SharePointUpload_Queueable enqueueEdpCallout = new BET_BDD_SharePointUpload_Queueable(endPointVsDocWrapList);
                System.enqueueJob(enqueueEdpCallout);
        }
    }

    /*Method Name   : determineEdpEndPoint
     *Date          : 09-Sep-2020
     *Developer     : Rahul Sharma
     *Description   : This method identifies the EDP endpoint.
     */
    public static BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper determineEdpEndPoint(BET_BDD_Document__c bddDoc){
        String endPointURL = '';
        BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper endPointVsDocWrap = new BET_BDD_WrapperClass.EdpEndpointVsDocumentWrapper();
        for(BET_Integration_Setting__mdt calloutSetting : [SELECT MasterLabel,
                                                                    Active__c,
                                                                    Source__c,
                                                                    Document_Category__c,
                                                                    Document_Type__c,
                                                                    Endpoint_URL__c,
                                                                    URL_Extension__c FROM BET_Integration_Setting__mdt LIMIT 50000]){
            if(bddDoc.BET_Source__c == calloutSetting.Source__c && bddDoc.BET_Document__c == calloutSetting.Document_Category__c &&
                bddDoc.BET_Document_Type__c == calloutSetting.Document_Type__c && calloutSetting.Endpoint_URL__c != null && calloutSetting.URL_Extension__c != null){
                String thisURL = calloutSetting.Endpoint_URL__c + '?';
                List<String> inputParameters = calloutSetting.URL_Extension__c.split(';');
                for(String extension : inputParameters){
                    String[] params = extension.split(':');
                    if(params[1] == 'Created_Date__c' && bddDoc.Created_Date__c != null){
                        String thisDate = '';
                        Date createdDate = bddDoc.Created_Date__c;
                        String day = String.valueOf(createdDate.Day());
                        String month = String.valueOf(createdDate.Month());
                        if(day.length() < 2)
                            day = '0' + day;
                        if(month.length() < 2)
                            month = '0' + month;
                        thisDate = month + day + String.valueOf(createdDate.Year());
                        thisURL += params[0] + '=' + thisDate + '&';
                    }else if(params[1] == 'BET_Legal_Name__c' && bddDoc.BET_Legal_Name__c != null){
                        String legalName = bddDoc.get(params[1]).toString();
                        legalName = EncodingUtil.urlEncode(legalName, 'UTF-8');
                        thisURL += params[0] + '=' + legalName + '&';
                    }else if(bddDoc.get(params[1]) != null){
                        thisURL += params[0] + '=' + bddDoc.get(params[1]) + '&';
                    }  
                }
                
                endPointURL = thisURL.removeEnd('&');
                System.debug('BET_BDD_SharePointUploadController >> determineEdpEndPoint >> Endpoint: '+endPointURL);
            }
        }
        if(!String.isEmpty(endPointURL)){
            endPointVsDocWrap.endPointURL = endPointURL.replaceAll(' ','%20');
            System.debug('BET_BDD_SharePointUploadController >> determineEdpEndPoint >> Endpoint: '+endPointVsDocWrap.endPointURL);
            endPointVsDocWrap.bddDoc = bddDoc;
        }
        else
            System.debug('BET_BDD_SharePointUploadController >> determineEdpEndPoint: Enpoint URL is null');
        return endPointVsDocWrap;
    }

    /*Class Name   : CustomException
     *Date         : 09-Sep-20
     *Developer    : Rahul Sharma
     *Description  : Wrapper class for EDP Response.
     */
    public class CustomException extends Exception{

    }
}