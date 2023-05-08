/**************************************************************************************************
 * Class Name : TCP_TermsandConditionCtrl 
 * Description: To display my shell contacts for end users and commops users
 * Verion     : 1.0
 * **************************************************************************************************/
public with sharing class TCP_MyShellContactsCtrl {

    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getShellContacts(string accId){
      List<Id> accIds=new List<Id>();
     
      List<Account_Contact_Relationship__c> acrData = new List<Account_Contact_Relationship__c>();
      List<ContactWrapper> conWrap=new List<ContactWrapper>();
      try {  
          //To fetch associated contacts from customer 
          acrData = [SELECT id, Account__r.name, Account__c,Portal_User_Contact__r.Email,Portal_User_Contact__r.Phone,Portal_User_Contact__r.name,Portal_User_Contact__r.TCP_Products__c FROM Account_Contact_Relationship__c WHERE Account__c=:accId order by CreatedDate ASC];//Portal_User_Contact__r.Email =: us.Email AND 
          if(!acrData.isEmpty()){
              for(Account_Contact_Relationship__c acr:acrData){
                  ContactWrapper wrap=new ContactWrapper();
                  wrap.product=acr.Portal_User_Contact__r.TCP_Products__c;
                  wrap.Name=acr.Portal_User_Contact__r.Name;
                  wrap.Email=acr.Portal_User_Contact__r.Email;
                  wrap.Phone=acr.Portal_User_Contact__r.Phone;
                  conWrap.add(wrap);
              }
              return conWrap;
          }
          
         
      }catch(Exception e){
        system.debug('My Shell Contacts : '+e.getMessage()+'line : '+e.getLineNumber());
        TCP_ExceptionLogClass.insertExceptionRecord('My Shell Contacts',e.getMessage(),'TCP_MyShellContactsCtrl','execute','Exception');
    }
    return null;
  }
 
  public class ContactWrapper{
      @AuraEnabled
      public String Name{get;set;}
      @AuraEnabled
      public String product{get;set;}
      @AuraEnabled
      public String Email{get;set;}
      @AuraEnabled
      public String Phone{get;set;}
  
  }
}