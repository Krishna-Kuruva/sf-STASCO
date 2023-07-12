/************************************************************************************************
Description    :    This is trigger handler class for user object for TCP project
************************************************************************************************/

public with sharing class TCP_UserHandler{

    public static void handleAfterInsert(list<user> userlist){
        if(!userlist.isEmpty()){
            TCP_Controls__mdt isTriggerActive = TCP_Controls__mdt.getInstance('TCP_UserTigger');
            TCP_Controls__mdt isCIPMRegActive = TCP_Controls__mdt.getInstance('TCP_CIPMRegister');

            //check if trigger operations are active and CIPM register is active
            if(isTriggerActive.isactive__c && isCIPMRegActive.isActive__c){
            
                for(user u : userlist){
                    if(u.CIPM_Access__c)
                    TCP_CIPM_PreRegisterHandler.manageCIPMRegister(u.id);
                }
            }
        }
    }
}