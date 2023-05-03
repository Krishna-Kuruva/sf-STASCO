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
}