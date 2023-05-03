/**************************************************************************************************
 * Class Name : TCP_ForgotPasswordController 
 * Description: An apex page controller that exposes the site forgot password functionality
 * Verion     : 1.0
 * **************************************************************************************************/
public without sharing class TCP_ForgotPasswordController {
    public String username {get; set;}
    public String emailid {get; set;}
    public boolean success;
    public PageReference pr{get;set;}
    public TCP_ForgotPasswordController () {}
    
    public PageReference forgotPassword() {
        Try{   
            List<User> usr = [select Id, Username,Email from User where Username =: username];

            if(usr.size() >0 )
            {
                emailid = usr[0].Email;
                system.debug('JMJ- email ##'+emailid);
                success = Site.forgotPassword(username);
            
                system.debug('inside if forgotpassword');
                pr = Page.TCP_ForgotPasswordConfirm;
                
                pr.getParameters().put('usrid',usr[0].Id);
                pr.setRedirect(true);
                
                if (success) {
                    system.debug('pr===>');
                    return pr;
                }
            }
            else
            {
                if(username == null || username == ''){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter a value in the Username Field'));
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Username'));
                }
            }
        } 
        catch(Exception e){
            system.debug('Forgot password: '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('Forgot password',e.getMessage(),'TCP_ForgotPasswordController','execute','Exception');
        }
        return null;
   
      }

}