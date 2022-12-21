/******************************************************************************************************************
className           :    BET_fileUpload
Description         :    This trigger will notify the external system when the file is uploaded to the BET_BDD_Document__c object.  
*******************************************************************************************************************/
trigger BET_fileUpload on ContentVersion (after insert,after update,before insert) {
    
    if(Trigger.isBefore){
        //Before insert
        if(Trigger.isInsert){
            BET_fileUpload_triggerHelper.onBeforeinsert(trigger.new);
        }
        //Before update
        if(Trigger.isUpdate){
        }
        //Before delete
        if(Trigger.isDelete){
            //
        }
    }
    if(Trigger.isAfter){
        //After insert
        if(Trigger.isInsert){
            BET_fileUpload_triggerHelper.onAfterInsert(Trigger.new);
        }
        //After Update
        if(Trigger.isUpdate){
        }
    }
    
   
    
}