trigger RV_CheckMRCOnAccount on MRC__c (before insert, after insert, before update, after delete) {
    
    if(trigger.isAfter){
        if( trigger.isUpdate || trigger.isInsert){
            RV_MRCCheckOnAccountHelper.checkMRCOnInsert(trigger.new);
        }
        //START - Rahul Sharma | Date - 21-Apr-2020 : Added method to update Ship-To Name lookup on MRC
        if(trigger.isInsert){
            RV_MRCCheckOnAccountHelper.updateShipToAccount(trigger.new);
        }
        //END - Rahul Sharma | Date - 21-Apr-2020 : Added method to update Ship-To Name lookup on MRC
    }
}