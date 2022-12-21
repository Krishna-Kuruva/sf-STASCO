/******************************************************************************************************************
className           :    BET_fileUpload_triggerHelper
Description         :    This trigger will notify the external system when the file is uploaded to the BET_BDD_Document__c object.  
*******************************************************************************************************************/
public class BET_fileUpload_triggerHelper {
    
    public static void onAfterInsert(List<ContentVersion> BddDoucment){
        //considering array index 0 because only one document will upload at a time for the object BDD Document.    
        system.debug('BddDoucment--'+BddDoucment);
        id  checkforObject;
        
        if(BddDoucment.size() == 1){
            if(BddDoucment[0].FirstPublishLocationId != null || BddDoucment[0].BET_BDD_Document_ID__c != null){
                if(BddDoucment[0].FirstPublishLocationId != null)
                    checkforObject=BddDoucment[0].FirstPublishLocationId;
                else 
                    checkforObject=BddDoucment[0].BET_BDD_Document_ID__c;
                
                //check if the document is uploaded to BDD Document object
                if(checkforObject.getSObjectType().getDescribe().getName() == 'BET_BDD_Document__c'){
                    BET_fileuplaodToSharepoint.indicateExternalSystem(checkforObject);
                }
            }
        }       
    }
    
    
    public static void onBeforeinsert(List<ContentVersion> BddDoucmentNew){
        
        //considering array index 0 because only one document will upload at a time for the object BDD Document.          
        if(BddDoucmentNew.size() == 1){
            if(BddDoucmentNew[0].FirstPublishLocationId != null ){
                id  checkforObject=BddDoucmentNew[0].FirstPublishLocationId;
                //check if the document is uploaded to BDD Document object
                if(checkforObject.getSObjectType().getDescribe().getName() == 'BET_BDD_Document__c' && BddDoucmentNew[0].BET_BDD_Document_ID__c == null ){
                    //update the BDD Doucment ID to BET_BDD_Document_ID__c field in contentVersion
                    BddDoucmentNew[0].BET_BDD_Document_ID__c=BddDoucmentNew[0].FirstPublishLocationId; 
                }
            }
        }
    }
}