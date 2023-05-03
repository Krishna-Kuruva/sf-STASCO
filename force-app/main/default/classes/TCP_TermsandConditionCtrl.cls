/**************************************************************************************************
 * Class Name : TCP_TermsandConditionCtrl 
 * Description: To update last accepted date at contact level when customer accepts Terms & Conditions
 * Verion     : 1.0
 * **************************************************************************************************/
public with sharing class TCP_TermsandConditionCtrl {

@AuraEnabled(cacheable=true)
public static contact getCommUserContactId() {
    try{
        User u = [SELECT ContactId,email FROM User WHERE id = :userinfo.getUserId()];
        //Contact to get last accepted date
        contact con;
        if(u.ContactId!=null){
            con=[select id,TCP_TandC__c,TCP_TandC_Accepted_Date__c from contact where id=:u.ContactId];
            
        }
        else if(u.ContactId==null || u.ContactId==''){
            con=[select id,email,TCP_TandC__c,TCP_TandC_Accepted_Date__c from contact where email=:u.email];
        }   
        
        return con;
    }catch(Exception e){
        system.debug('TCP_TermsandConditionCtrl : '+e.getMessage()+'line : '+e.getLineNumber());
        TCP_ExceptionLogClass.insertExceptionRecord('Terms and Conditions',e.getMessage(),'TCP_TermsandConditionCtrl','execute','Exception');

    }
    return null;
    
	}   
}