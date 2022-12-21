/*************************************************************************************
@Name:  BET_BDD_DocumentTriggerHelper     
@=================================================================================
@Purpose: Helper class for BET_BDD_DocumentTrigger trigger
@=================================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    24-Aug-2020         INITIAL DEVELOPMENT

*************************************************************************************/
public with sharing class BET_BDD_DocumentTriggerHelper {
    
    /*Method Name   : BET_BDD_DocumentTriggerHelper
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : Default constructor
     */
    public BET_BDD_DocumentTriggerHelper(){
        
    }
    
    private static Map<String, Integer> thirdPartyRepCountMap = new Map<String, Integer>(); //Rahul Sharma | Date - 23-Nov-2020 : Added Map to retain 3rd party report count per BDD Form for document naming.
    private static List<BET_BDD_Supporting_Document_Map__mdt> bddDocSettingMapList = new List<BET_BDD_Supporting_Document_Map__mdt>();
    private static Map<ID,Schema.RecordTypeInfo> recTypeMap = new Map<ID,Schema.RecordTypeInfo>();
    
    /*Block Name    : static
      *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : static block for one time operation.
     */
    static{
        recTypeMap = BET_BDD_Document__c.sObjectType.getDescribe().getRecordTypeInfosById();
        bddDocSettingMapList = [SELECT Id,
                                       MasterLabel,
                                       Source__c,
                                       Source_ShortName__c,
                                       Section__c,
                                       Region__c,
                                       Document_Type__c,
                                       Document_Category__c FROM BET_BDD_Supporting_Document_Map__mdt LIMIT 50000];
    }
    
    /*Method Name   : onBeforeInsert
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : Call before insert methods here.
     */
    public static void onBeforeInsert(List<BET_BDD_Document__c> documentList){
        preventRecordUpdate(documentList);
        validateDuplicateDocument(documentList);
        updateDocumentFields(documentList);
    }
    public static void onBeforeDelete(List<BET_BDD_Document__c> docListOld){
        preventSubmitDelete(docListOld);
    }
    
    /*Method Name   : onBeforeUpdate
     *Date          : 09-Sep-20
     *Developer     : Rahul Sharma
     *Description   : Call after update methods here.
     */
    public static void onBeforeUpdate(List<BET_BDD_Document__c> docListNew, Map<Id, BET_BDD_Document__c> docMapNew, List<BET_BDD_Document__c> docListOld, Map<Id, BET_BDD_Document__c> docMapOld){
        initDocumentUpload(docListNew, docMapOld);
        preventRecordUpdate(docListNew);
    }
    
    /*Method Name   : onAfterInsert
     *Date          : 08-Sep-20
     *Developer     : Rahul Sharma
     *Description   : Call after insert methods here.
     */
    public static void onAfterInsert(List<BET_BDD_Document__c> docListNew){
        initDocumentUpload(docListNew, new Map<Id, BET_BDD_Document__c>());
    }
    
    /*Method Name   : onAfterUpdate
     *Date          : 09-Sep-20
     *Developer     : Rahul Sharma
     *Description   : Call after update methods here.
     */
    public static void onAfterUpdate(List<BET_BDD_Document__c> docListNew, Map<Id, BET_BDD_Document__c> docMapNew, List<BET_BDD_Document__c> docListOld, Map<Id, BET_BDD_Document__c> docMapOld){

    }
    
    /*Method Name   : updateDocumentFields
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : This method updates BDD Document object record missing fields from the BDD Document Map metadata records.
     */
    private static void updateDocumentFields(List<BET_BDD_Document__c> documentList){
        Set<Id> formRecIdSet = new Set<Id>();
        Map<Id, BET_BDD_Form__c> bddFormMap = new Map<Id, BET_BDD_Form__c>();
        for(BET_BDD_Document__c bddDoc : documentList){
            if(bddDoc.BET_BDD_Form__c != null)
                formRecIdSet.add(bddDoc.BET_BDD_Form__c);
        }
        bddFormMap = new Map<Id, BET_BDD_Form__c>([SELECT Id,
                                                          BDD_Entity_Type__c,
                                                          BDD_Onboard_Type__c,
                                                          GT_Legal_Name__c FROM BET_BDD_Form__c WHERE Id IN : formRecIdSet]);
        for(BET_BDD_Document__c doc : documentList){
            for(BET_BDD_Supporting_Document_Map__mdt docMap : bddDocSettingMapList){
                String docRecTypeName = recTypeMap.get(doc.RecordTypeId).getName();
                if(doc.BET_Document__c == docMap.Document_Category__c && doc.BET_Document_Type__c == docMap.Document_Type__c &&
                   docRecTypeName == docMap.Region__c && doc.BET_BDD_Form__c != null){
                       if(!doc.BET_Manual_Upload__c && doc.BET_Source__c != null && doc.BET_Source__c == docMap.Source__c){
                           doc.BET_Section__c = docMap.Section__c;
                           doc.BET_Source__c = docMap.Source__c;
                           //Update document name
                           doc.BET_Doc_Name__c = updateDocumentName(doc, docMap);
                           doc.BET_SharePoint_Fld_Name__c = updateSharePointFolder(bddFormMap.get(doc.BET_BDD_Form__c).BDD_Entity_Type__c, doc.Created_Date__c, bddFormMap.get(doc.BET_BDD_Form__c).GT_Legal_Name__c);
                       }
                       else if(doc.BET_Manual_Upload__c && docMap.Source__c == 'Other'){
                           doc.BET_Section__c = docMap.Section__c;
                           doc.BET_Source__c = docMap.Source__c;
                           //Update document name
                           doc.BET_Doc_Name__c = updateDocumentName(doc, docMap);
                           doc.BET_SharePoint_Fld_Name__c = updateSharePointFolder(bddFormMap.get(doc.BET_BDD_Form__c).BDD_Entity_Type__c, doc.Created_Date__c, bddFormMap.get(doc.BET_BDD_Form__c).GT_Legal_Name__c);
                       }
                   }
            }
            if(doc.BET_Section__c == null || doc.BET_Source__c == null || doc.BET_Document__c == null || doc.BET_Document_Type__c == null){
                if(doc.BET_Document_Type__c == null)
                    doc.addError('Document could not be created as the \'Document Type\' is not valid.');
                else
                    doc.addError('Document could not be created as the data is not valid.');
            }
        }
    }
    
    /*Method Name   : updateDocumentName
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : This method updates document name for the created document.
     */
    private static String updateDocumentName(BET_BDD_Document__c bddDoc, BET_BDD_Supporting_Document_Map__mdt docMap){
        String docName = '';
        if(bddDoc != null){
            if(bddDoc.Created_Date__c != null && bddDoc.BET_Document__c != null){
                Date createdDate = bddDoc.Created_Date__c;
                String day = String.valueOf(createdDate.Day());
                String month = String.valueOf(createdDate.Month());
                if(day.length() < 2)
                    day = '0' + day;
                if(month.length() < 2)
                    month = '0' + month;
                docName = month + day + String.valueOf(createdDate.Year()) + ' - ' + bddDoc.BET_Document__c;
                if(docMap != null && docMap.Source_ShortName__c != null){
                    docName += ' - ' + docMap.Source_ShortName__c;
                    //START - Rahul Sharma | Date - 23-Nov-2020 : Added logic to rename 3rd Party Report based on document count.
                    if(bddDoc.BET_Document__c == '3rd Party Report' && !thirdPartyRepCountMap.isEmpty() && thirdPartyRepCountMap.containsKey(bddDoc.BET_Docu_Unique_Key_Formula__c)){
                        Integer count = thirdPartyRepCountMap.get(bddDoc.BET_Docu_Unique_Key_Formula__c);
                        count++;
                        docName += ' (' + count + ')';
                    //END - Rahul Sharma | Date - 23-Nov-2020 : Added logic to rename 3rd Party Report based on document count.
                    }
                }
                System.debug('BET_BDD_DocumentTriggerHelper >> updateDocumentName() >> docName: '+docName);
            }
            else{
                System.debug('BET_BDD_DocumentTriggerHelper >> updateDocumentName(): BDD Document could be renamed');
            }
        }
        else{
            System.debug('BET_BDD_DocumentTriggerHelper >> updateDocumentName(): BDD Document is null.');
        }
        return docName;
    }
    
    /*Method Name   : updateSharePointFolder
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : This method updates folder named required for SharePoint upload.
     */
    public static String updateSharePointFolder(String entityType, Date createdDate, String legalName){
        String folderName = '';
        if(!String.isEmpty(entityType) && createdDate != null){
            String day = String.valueOf(createdDate.Day());
            String month = String.valueOf(createdDate.Month());
            if(day.length() < 2)
                day = '0' + day;
            if(month.length() < 2)
                month = '0' + month;
            if(!String.isEmpty(legalName)){
                folderName = legalName;
            }
            else{
                System.debug('BET_BDD_DocumentTriggerHelper >> updateSharePointFolder(): Legal Name is empty.');    
            }
            folderName += ' - ' + entityType + ' - ' + month + day + String.valueOf(createdDate.Year());
        }
        System.debug('BET_BDD_DocumentTriggerHelper >> updateSharePointFolder(): folderName: '+folderName); 
        return folderName;
    }
    
    /*Method Name   : updateSharePointFolder
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : This method initialize the document upload.
     */
    private static void initDocumentUpload(List<BET_BDD_Document__c> docListNew, Map<Id, BET_BDD_Document__c> docMapOld){
        //START - Upload/Retry upload to EDP
        BET_BDD_SharePointUploadController.enqueueEdpCallout(docListNew, docMapOld);
        //END - Upload/Retry upload to EDP
        //START - Manual Upload Retry here
        for(BET_BDD_Document__c bddDoc : docListNew){
            //limiting the number of documents uploads to 20 docMapOld.size() < 20
            if(bddDoc.BET_Manual_Upload__c && !docListNew.isEmpty() && !docMapOld.isEmpty()  ){
                if(bddDoc.BET_Retry__c){
                    if(!docMapOld.get(bddDoc.Id).BET_Retry__c && bddDoc.BET_Retry__c && bddDoc.BET_Upload_Status__c == 'Failed' && docMapOld.size() < 20){
                        System.debug('BET_BDD_DocumentTriggerHelper >> initDocumentUpload(): Document is uploaded manually.');
                        bddDoc.BET_Retry__c = false;
                        bddDoc.BET_Upload_Status__c = 'In Progress';
                        //Make Manual Upload Retry here.
                        BET_fileuplaodToSharepoint.indicateExternalSystem(bddDoc.Id);
                    }   
                    else{
                        bddDoc.addError('Document cannot be uploaded at this moment.please try again after some time');
                    }                 
                }
            } 
            else{

            }            
        } 
        //END - Manual Upload Retry here
    }

    /*Method Name   : validateDuplicateDocument
     *Date          : 15-Sep-20
     *Developer     : Rahul Sharma
     *Description   : Pervents creating duplicate document records.
     */
    private static void validateDuplicateDocument(List<BET_BDD_Document__c> docList){
        Set<String> docUniqNameSet = new Set<String>();
        Map<String, BET_BDD_Document__c> docNameVsDocMap = new Map<String, BET_BDD_Document__c>(); 
        for(BET_BDD_Document__c doc : docList){
            if(!docUniqNameSet.isEmpty() && docUniqNameSet.contains(doc.BET_Docu_Unique_Key_Formula__c))
                doc.addError('Document already exists in the system.');
            else
                docUniqNameSet.add(doc.BET_Docu_Unique_Key_Formula__c);
        }
        if(!docUniqNameSet.isEmpty()){
            for(BET_BDD_Document__c doc : [SELECT Id,
                                                  BET_Doc_Name__c,
                                                  BET_Docu_Unique_Key_Formula__c FROM BET_BDD_Document__c WHERE BET_Docu_Unique_Key_Formula__c IN : docUniqNameSet ORDER BY BET_Doc_Name__c ASC]){
                docNameVsDocMap.put(doc.BET_Docu_Unique_Key_Formula__c, doc);
            }
            if(!docNameVsDocMap.isEmpty()){
                for(BET_BDD_Document__c doc : docList){
                    if(docNameVsDocMap.containsKey(doc.BET_Docu_Unique_Key_Formula__c)){
                        //START - Rahul Sharma | Date - 23-Nov-2020 : Added logic to allow multiple 3rd Part Report and saving report count in map.
                        if(doc.BET_Document__c == '3rd Party Report'){
                            Integer count;
                            String countStr = docNameVsDocMap.get(doc.BET_Docu_Unique_Key_Formula__c).BET_Doc_Name__c.substringBetween('(', ')');
                            if(!String.isEmpty(countStr))
                                count  = Integer.valueOf(countStr);
                            if(count == null)
                                count = 1;
                            thirdPartyRepCountMap.put(doc.BET_Docu_Unique_Key_Formula__c, count);
                        }
                        else
                            doc.addError('Document already exists in the system.');
                        //END - Rahul Sharma | Date - 23-Nov-2020 : Added logic to allow multiple 3rd Part Report and saving report count in map.
                    }
                }
            }
        }        
    }
    public static void preventRecordUpdate(List<BET_BDD_Document__c> docListNew){
        Boolean hasPermission = FeatureManagement.checkPermission('Ignore_Validation_Rules');
        if(hasPermission != true && CheckRecursive.isRunningBatch == true){
        Map<Id, BET_BDD_Form__c> bddFormMap = new Map<Id, BET_BDD_Form__c>();
        set<Id> formRecId = new set<Id>();
        for(BET_BDD_Document__c docRecs :docListNew){
            formRecId.add(docRecs.BET_BDD_Form__c);
        }
         List<String> lockedStatusList = new List<String>{'Ready for BDD Approver','Ready for COF','Ready to Onboard','Submitted'};
        bddFormMap = new Map<Id, BET_BDD_Form__c>([SELECT Id,
                                                          BDD_Entity_Type__c,BET_Status__c,BDD_Onboard_Type__c,
                                                          GT_Legal_Name__c FROM BET_BDD_Form__c WHERE Id IN : formRecId]);
        for(BET_BDD_Document__c docRec : docListNew){
            BET_BDD_Form__c parentForm = bddFormMap.get(docRec.BET_BDD_Form__c);
            if(parentForm!= Null && lockedStatusList.contains(parentForm.BET_Status__c)){
              docRec.addError('Only ‘BET Status’ is editable at this stage.');  
            }
        }}
    }
    public static void preventSubmitDelete(List<BET_BDD_Document__c> docListOld){
         Map<Id, BET_BDD_Form__c> bddFormMap = new Map<Id, BET_BDD_Form__c>();
         Set<Id> formIds = new Set<Id>();
         for(BET_BDD_Document__c documentRec : docListOld){
             formIds.add(documentRec.BET_BDD_Form__c);
         }
        bddFormMap = new Map<Id, BET_BDD_Form__c>([SELECT Id,
                                                          BDD_Entity_Type__c,BET_Status__c,BDD_Onboard_Type__c,
                                                          GT_Legal_Name__c FROM BET_BDD_Form__c WHERE Id IN : formIds]);
        for(BET_BDD_Document__c docRec : docListOld){
            BET_BDD_Form__c parentForm = bddFormMap.get(docRec.BET_BDD_Form__c);
            System.debug('parentForm**'+parentForm);
            if(parentForm.BET_Status__c == 'Submitted' || parentForm.BET_Status__c == 'Ready to Onboard'){
                //docRec.addError('Cannot delete this Document since parent ‘BDD Form’ is locked');
                docRec.addError('Only ‘BET Status’ is editable at this stage.');
            } } }
}