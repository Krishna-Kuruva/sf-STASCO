/**************************************************************************************************
 * Class Name : TCP_LoginController 
 * Description: To display login page and validation for user credentials 
 * Verion     : 1.0
 * **************************************************************************************************/
public without sharing class TCP_LoginController {

    public PageReference landingPage{get;set;}
    public boolean displayPopup {get; set;}
    public String password { get; set; }
    public String username { get; set; }     

    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }

    public PageReference doLogin() {
        try {	
                        
            String userNameWithSufx;
            if(username !='' && username!=null) 
            {
                 userNameWithSufx = username.trim();
            } 
            string startUrl = ApexPages.currentPage().getParameters().get('startURL');
            landingPage = Site.login(userNameWithSufx,password.trim(),startUrl);
            System.debug('landing page===='+landingPage);
            List<User> usersList = [SELECT Id, UserName  FROM User WHERE Username =: userNameWithSufx];
            usersList[0].Logon_as_TCP_User__c = false;
            update usersList[0];
                        
            return landingPage;
        }
        catch(Exception excptn) { 
            
            System.debug('##Exception: '+excptn);
            if((username =='' || username==null) && (password =='' || password ==null)) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter values in the Username & Password Field')); 
                
            }
            else if(password =='' || password ==null) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter a value in the Password Field'));    
            }
            else if(username =='' || username==null ){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter a value in the Username Field'));
            }
            else{
                
            }
            
            return null;
        }

    }
    // To verify authntication 
    public static Boolean verifyAuthSession(){ 
        try{  	   
            String userid = UserInfo.getUserId(); 
            Boolean isCurrentFlag = false;
            //Get session based on login user
            AuthSession sessions = [SELECT CreatedDate,Id,IsCurrent,LastModifiedDate,LoginGeoId,LoginHistoryId,LoginType,LogoutUrl,NumSecondsValid,ParentId,SessionSecurityLevel,SessionType,SourceIp,UsersId,UserType  from AuthSession where UsersId=:userid];
            system.debug('sessions===>'+sessions);	
            isCurrentFlag = sessions.IsCurrent;
            return isCurrentFlag;
        }catch(Exception e){
            system.debug('Authentication issue: '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('Login Page',e.getMessage(),'TCP_LoginController','execute','Exception');
        }
        return null;
    }

}