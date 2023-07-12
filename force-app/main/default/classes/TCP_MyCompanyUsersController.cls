public with sharing class TCP_MyCompanyUsersController {
     public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    @AuraEnabled
    public static List<Id> getAccountDetailsOfComOps(){
        List<Id> accIds=new List<Id>();
        
        List<Account_Contact_Relationship__c> accountConData = new List<Account_Contact_Relationship__c>();
        try {  
            
            accountConData = [SELECT id, Account__r.name, Account__c FROM Account_Contact_Relationship__c WHERE Portal_User_Contact__r.Email =:userinfo.getUserEmail()];
            for(Account_Contact_Relationship__c acc:accountConData){
                accIds.add(acc.Account__c);
            }
            
            
        } catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getAccountDetailsOfComOps','Exception');
        }
        return accIds;
    }
    @auraEnabled
    public static List<ContactWrapper> getContacts(){
        List<ContactWrapper> conWrap=new List<ContactWrapper>();
        set<Id> conIds=new Set<Id>();
        List<Contact> conList=new List<Contact>();
        List<user> userList=new List<User>();
        
        List<Id> accIds=new List<Id>();
        
        try{
            User us=[select Id, Name,TCP_Role__C,ContactId,AccountId, Email from User where Id=:UserInfo.getUserId()];
            if(us.TCP_Role__C=='CommOpps user'){
                accIds=getAccountDetailsOfComOps();
            }
            else if(us.TCP_Role__C=='End user'){
                accIds.add(us.AccountId);
            }
            if(accIds.size()>0){
                conList=[select id from Contact where AccountId IN: accIds ]; 
                for(Contact con:conList){
                    conIds.add(con.Id);
                }
            }
            if(conIds.size()>0){
                userList= [SELECT Id,Name,Contact.Id,Contact.Name,Contact.TCP_Deletion_Request__c, Contact.Account.Name,Contact.Email, IsActive FROM User WHERE ContactId IN :conIds And IsActive=true];
            }
            for(User use:userList){
                ContactWrapper wrap=new ContactWrapper();
                wrap.Id=use.Contact.Id;
                wrap.Name=use.Contact.Name;
                wrap.Email=use.Contact.Email;
                wrap.Company=use.Contact.Account.Name;
                wrap.DeleteReason=use.Contact.TCP_Deletion_Request__c;
                if(use.isActive==true){
                    wrap.Status='Active';
                }
                conWrap.add(wrap);
            }
            System.debug('Check Wraap '+conWrap);
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getContacts','Exception');
        }
        return conWrap;
    }
    @AuraEnabled 
    public static List<TCP_ShellContactEmail__c> getShellContacts(String accountId){
        List<TCP_ShellContactEmail__c> conList=new List<TCP_ShellContactEmail__c>();
        List<Id> accIds=new list<Id>();
        try{
            User us=[select Id, Name,TCP_Role__C,ContactId,AccountId, Email from User where Id=:UserInfo.getUserId()];
            if(us.TCP_Role__C=='CommOpps user'){
                accIds=getAccountDetailsOfComOps();
            }
            else if(us.TCP_Role__C=='End user'){
                accIds.add(us.AccountId);
            }
            if(String.isNotBlank(accountId)){
                Account accSalesorg = [Select id,sales_area__r.Sales_Region__c from account where id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
                String AccountSalesorg=accSalesorg.sales_area__r.Sales_Region__c;
                
                conList=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Contact_Region__c=:AccountSalesorg ORDER By Name ASC];
                System.debug('Check the contacts '+conList);
            }
            if(String.isBlank(accountId) && accIds.size()>0){
                
                Account acc=[Select Id, Name, Sales_Area__c, Sales_Area__r.Sales_Region__c from Account where Id=:accIds[0] and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
                
                String AccountSalesorg=acc.Sales_Area__r.Sales_Region__c;
                system.debug('Check Org '+AccountSalesorg);
                conList=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Contact_Region__c=:AccountSalesorg AND Contact_Name__c!='Duplicate' ORDER By Name ASC ];
                System.debug('Check the contacts '+conList);
            }
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getShellContacts','Exception');
        }
        return conList;
    }
    
    @AuraEnabled(cacheable=false) 
    public static TCP_ShellContactEmail__c getNewRequestDetails(String accountId, String contactId, String firstName, String lastName, String phone, String email, String comments){
        System.debug('Check1 '+accountId);
        System.debug('Check2 '+contactId);
        System.debug('Check3 '+firstName);
        System.debug('Check4 '+lastName);
        System.debug('Check5 '+phone);
        System.debug('Check6 '+comments);
        
        
        TCP_ShellContactEmail__c con=new TCP_ShellContactEmail__c();
        Account acc=new Account();
        List<Id> accIds=new list<Id>();
        try{
            if(accountId==null){
                User us=[select Id, Name,TCP_Role__C,ContactId,AccountId, Email from User where Id=:UserInfo.getUserId()];
                if(us.TCP_Role__C=='CommOpps user'){
                    accIds=getAccountDetailsOfComOps();
                }
                else if(us.TCP_Role__C=='End user'){
                    accIds.add(us.AccountId);
                }
                if(accIds.size()>0){
                    acc=[Select Id, Name from Account where Id=:accIds[0] and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
                }
            }
            if(accountId!=null){
                acc=[Select Id, Name from Account where Id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
                system.debug('Check Company Name '+acc.Name);
            }
            System.debug('Check ContactId '+contactId);
            con=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Id=:contactId];
            if(con!=null && acc!=null){
               
                string[] toEmails = new string[] {con.Contact_Email__c,UserInfo.getUserEmail()};
                   
                TCP_ContactUsEmailService.sendEmailOnNewRequest(acc.Id,toEmails,firstName , lastName,phone, email, comments,acc.Name, con.Contact_Name__c,true);
            }   
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getNewRequestDetails','Exception');
        }
        return con;
    }
    
    @AuraEnabled(cacheable=false) 
    public static TCP_ShellContactEmail__c getComplaintDetails(String accountId, String contactId, String shellRefNumber, String customerPO, String description, String product){
        TCP_ShellContactEmail__c con=new TCP_ShellContactEmail__c();
        System.debug('Checking Customer PO'+ CustomerPo);
        try{
            Account acc=new Account();
            if(accountId!=null){
                acc=[Select Id, Name from Account where Id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
            }
            con=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Id=:contactId];
            if(con!=null && acc!=null){
               
                string[] toEmails = new string[] {con.Contact_Email__c,UserInfo.getUserEmail()};
                  
                TCP_ContactUsEmailService.sendEmailOnComplaintRequest(accountId,toEmails,customerPO, shellRefNumber,product,description,acc.Name,con.Contact_Name__c ,true);
            } 
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getComplaintDetails','Exception');
        }
        return con;
    }
    @AuraEnabled(cacheable=false) 
    public static TCP_ShellContactEmail__c getCommentDetails(String accountId, String contactId, String description){
        TCP_ShellContactEmail__c con=new TCP_ShellContactEmail__c();
        try{
            Account acc=new Account();
            if(accountId!=null){
                acc=[Select Id, Name from Account where Id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
            }
            con=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Id=:contactId];
            if(con!=null && acc!=null){
               
                string[] toEmails = new string[] {con.Contact_Email__c,UserInfo.getUserEmail()};
                   
                TCP_ContactUsEmailService.sendEmailOnCommentRequest(accountId,toEmails, description,acc.Name, con.Contact_name__c,true);
            }  
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getCommentDetails','Exception');
        }
        return con;
    }
    @AuraEnabled(cacheable=false) 
    public static TCP_ShellContactEmail__c getEnquiryDetails(String accountId, String contactId, String description){
        
        
        TCP_ShellContactEmail__c con=new TCP_ShellContactEmail__c();
        try{
            Account acc=new Account();
            if(accountId!=null){
                acc=[Select Id, Name from Account where Id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
            }
            con=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Id=:contactId];
            if(con!=null && acc!=null){
              
                string[] toEmails = new string[] {con.Contact_Email__c,UserInfo.getUserEmail()};
                  
                TCP_ContactUsEmailService.sendEmailOnInquiryRequest(accountId,toEmails, description,acc.Name, con.Contact_name__c,true);
            }  
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getEnquiryDetails','Exception');
        }
        return con;
    }
    @AuraEnabled(cacheable=false) 
    public static TCP_ShellContactEmail__c getUserEditDetails(String contactEmail, String companyName,String contactName,String requestedTo, String editDetails){
        
        
        TCP_ShellContactEmail__c conShell=new TCP_ShellContactEmail__c();
        User conUser=new User();
        try{
            if(contactEmail!=null){
                conUser=[select Contact.FirstName, Contact.accountId,Contact.LastName,Contact.Email, ContactId,Contact.Name, AccountId,Contact.Account.Name from User where Contact.Email=:contactEmail AND Contact.Name=:contactName];
            }
            conShell=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Id=:requestedTo];
            if(conShell!=null && conUser!=null){
                
                string[] toEmails = new string[] {conShell.Contact_Email__c,UserInfo.getUserEmail()};
                   
                TCP_MyCompanyUsersEmailService.sendEmailOnEditRequest(conUser.Contact.accountId, toEmails, conUser.Contact.FirstName, conUser.Contact.LastName, conUser.Contact.Email, editDetails, conUser.Contact.Account.Name, conShell.Contact_Name__c, true);
            }
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getUserEditDetails','Exception');
        }
        return conShell;
    }
    @AuraEnabled(cacheable=false) 
    public static TCP_ShellContactEmail__c getUserDeleteDetails(String contactEmail, String companyName,String contactName,String requestedTo, String description,String deletereason){
        
        
        TCP_ShellContactEmail__c conShell=new TCP_ShellContactEmail__c();
        User conUser=new User();
        try{
            
            if(contactEmail!=null){
                conUser=[select Contact.FirstName, Contact.LastName,Contact.Email,Contact.Id, ContactId, Contact.AccountId,Contact.Account.Name from User where Contact.Email=:contactEmail AND Contact.Name=:contactName];
            }
            System.debug('Ceck Contact Id '+conUser.Contact.Id);
            Contact con=new Contact();
            con=[Select Id, TCP_Deletion_Request__c from Contact where Id=:conUser.Contact.Id];
            if(con!=null){
                con.TCP_Deletion_Request__c='(Deletion Request Sent)';
                update con;
            }
            conShell=[select Id, name, Contact_Email__c, Contact_Name__c,Contact_Region__c,DLs__c from TCP_ShellContactEmail__c Where Id=:requestedTo];
            if(conShell!=null && conUser!=null){
              
                string[] toEmails = new string[] {conShell.Contact_Email__c,UserInfo.getUserEmail()};
                  
                TCP_MyCompanyUsersEmailService.sendEmailOnDeleteRequest(conUser.Contact.AccountId, toEmails, conUser.Contact.FirstName, conUser.Contact.LastName, conUser.Contact.Email, description,deletereason, conUser.Contact.Account.Name, conShell.Contact_Name__c, true);
            }
        }
        catch (Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Expection',ex.getMessage(),'TCP_MyCompanyUsersController','getUserDeleteDetails','Exception');
        }
        return conShell;
    }
    public class ContactWrapper{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String Email{get;set;}
        @AuraEnabled
        public String Status{get;set;}
        @AuraEnabled
        public String Company{get;set;}
        @AuraEnabled
        public String DeleteReason{get;set;}
    }
}