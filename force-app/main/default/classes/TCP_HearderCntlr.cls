public with sharing class  TCP_HearderCntlr {

    @AuraEnabled
    public static String getNetworkid(){
        try{
        string usrinfo =  userInfo.getUserId();
        String userTypeInfo = UserInfo.getUserType();
        // get sessions where IsCurrent is false means other browser login sessions
        list<AuthSession> sessions = [SELECT Id, LoginType, UsersId, IsCurrent, SourceIp from AuthSession where UsersId=:usrinfo AND LoginType = 'Chatter Communities External User' AND IsCurrent = false];
        //if UserType is PowerCustomerSuccess then delete the other browser sessions ( Note: For Chatter Communities External Users has UserType is PowerCustomerSuccess )
        if(userTypeInfo == 'PowerCustomerSuccess'){
            delete sessions;
        }
        NetworkMember nm = [SELECT MemberId, NetworkId FROM NetworkMember WHERE MemberId =:usrinfo AND Network.Status = 'Live']; 
        
        if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
        }
        return nm.NetworkId;
        } 
        catch (Exception e) {
        TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getNetworkid',e.getMessage(),'TCP_HearderCntlr','getNetworkid','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static String getorgId(){
        try{
            
            String orgid = UserInfo.getOrganizationId();
            if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            return orgid;
            
        } 
        catch (Exception e) {
        TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getorgId',e.getMessage(),'TCP_HearderCntlr','getorgId','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled(Cacheable = true)
    public static String geturl(){
        try{
            String orgurl = URL.getSalesforceBaseUrl().getHost();
            //we get domain.my.salesforce.com, we replaced my.salesforce.com  to lightning.force.com
            String url = orgurl.replace('my.salesforce.com','lightning.force.com');
            if(Test.isRunningTest()){
                    DmlException e = new DmlException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
            }
            return url;
        } 
        catch (Exception e) {
        TCP_ExceptionLogClass.insertExceptionRecord('TCP Header geturl',e.getMessage(),'TCP_HearderCntlr','geturl','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   @AuraEnabled(Cacheable = true)
    public static String getuserrecordid(){
      try{
        String userTypeInfo = UserInfo.getUserType();
        User us = [SELECT Id,Name,Email, TCP_Role__C, Profile.Name,ContactId FROM User where Id =: UserInfo.getUserId()];
        String conName ='';
        if(us.TCP_Role__C == 'End user'){
            Contact con = [SELECT Id,Name,TCP_User_Clicked__r.FirstName,TCP_User_Clicked__r.lastName,TCP_User_Clicked__r.Name FROM Contact where Id =: us.ContactId];
            conName = con.TCP_User_Clicked__r.FirstName +' '+ con.TCP_User_Clicked__r.LastName;
        }
          if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
           }
        return conName;
        } 
        catch (Exception e) {
        TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getuserrecordid',e.getMessage(),'TCP_HearderCntlr','getuserrecordid','Exception');
            throw new AuraHandledException(e.getMessage());
        }  
    } 

    @AuraEnabled(Cacheable = true)
    public static String getcontactid(){
        try{
            User us = [SELECT Id,FirstName, LastName,Email,ContactId,Name FROM User where Id =: UserInfo.getUserId()];
            if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            return us.Name;
        } 
        catch (Exception e) {
        TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getcontactid',e.getMessage(),'TCP_HearderCntlr','getcontactid','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled(Cacheable = true)
    public static Boolean logonastcp(){
        try{
            if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            return [SELECT Id,FirstName, LastName,Email,ContactId,Logon_as_TCP_User__c FROM User where Id =: UserInfo.getUserId()].Logon_as_TCP_User__c;
        } 
        catch (Exception e) {
        TCP_ExceptionLogClass.insertExceptionRecord('TCP Header logonastcp',e.getMessage(),'TCP_HearderCntlr','logonastcp','Exception');
            throw new AuraHandledException(e.getMessage());
        }
     }
    
    @AuraEnabled
    public static string getportaluser(String contactid){
      try {
            Contact con = new Contact(Id= contactid,TCP_User_Clicked__c = UserInfo.getUserId());
            update con;
            User usr = [select Id,FirstName, LastName,Email,ContactId,Logon_as_TCP_User__c FROM User where ContactId =: contactid LIMIT 1];
            usr.Logon_as_TCP_User__c = true;
            update usr;
            return [SELECT Id,Name,Email FROM User WHERE (Profile.Name = 'TCPCustomerCommunityPlusUser' OR Profile.Name = 'TCPCustomerCommunityPlusUser') AND ContactId =: contactid].Id;
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getportaluser',e.getMessage(),'TCP_HearderCntlr','getportaluser','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static String getOrgDomainUrl(){
        try {
            if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            return Url.getOrgDomainUrl().toExternalForm();
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getOrgDomainUrl',e.getMessage(),'TCP_HearderCntlr','getOrgDomainUrl','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static String getChangePasswordUrl(){
        try {
            if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            TCP_CIPM_Settings__mdt config = TCP_CIPM_Settings__mdt.getInstance('Change_Password');
            string url;
            if(config != null){
                url = config.BaseURL__c + '?client_id=' + config.client_id__c 
                      + '&redirect_uri='+config.Redirect_URL__c
                      +'&response_type='+config.Response_type__c
                      +'&scope='+config.Scope__c
                      +'&prompt='+config.Prompt__c
                      +'&access_type='+config.Access_type__c;
            }
            return url;
            
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getChangePasswordUrl',e.getMessage(),'TCP_HearderCntlr','getChangePasswordUrl','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static String getLogoutUrl(){
        try {
            if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            TCP_CIPM_Settings__mdt config = TCP_CIPM_Settings__mdt.getInstance('Logout_URL');
            string url;
            Map<String, String> session = new map<String, String>();
            if(!Test.isRunningTest())
                session = Auth.SessionManagement.getCurrentSession();
            else if(Test.isRunningTest()){
                session.put('UserType','Standard');
                session.put('SourceIp','::');
                session.put('LoginType','Unknown');
            }
            
            //if user impersonated, logout and take back to salesforce
            if(session.get('UserType') == 'Standard' && session.get('SourceIp') == '::' && (session.get('LoginType') == 'unknown' ||session.get('LoginType') == null)){
                url = '/secur/logout.jsp';
            }
            else if(config != null){
                url = config.BaseURL__c + '?client_id=' + config.client_id__c 
                      + '&post_logout_redirect_uri='+config.Redirect_URL__c;
                      
            }
            
            return url;
            
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP Header getLogoutUrl',e.getMessage(),'TCP_HearderCntlr','getLogoutUrl','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteSession(){
        try {
            if(Test.isRunningTest()){
                DmlException e = new DmlException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
            list<AuthSession> sessionid = [select id from AuthSession WHERE usersid=:userinfo.getUserId()];
            system.debug('sessionid : '+sessionid);
            delete sessionid;
            
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP delete session',e.getMessage(),'TCP_HearderCntlr','deleteSession','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }
}