/**************************************************************************************************
 * Class Name : TCP_ChangePasswordController 
 * Description: Functionality to set password and change password by the tcp commops and portal user
 * Verion     : 1.0
 * **************************************************************************************************/
public without sharing class TCP_ChangePasswordController {
    
    public string username {get; set;}
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    //IsPasswordExpired variable for differentiate the user change password from first time set password (or) from forgot password and from change password from site
    public String IsPasswordExpired {get; set;}
 	public String tcError {get; set;}
    public boolean displayPopup {get; set;}  
    public Boolean isChecked{ get; set; }
    public Boolean isItemSelected { get; set; }
    public Boolean isFirsttmelogin { get; set; }
    
	public TCP_ChangePasswordController () {
        User u1 = [SELECT name,Id,Is_First_Time_Login__c, Username FROM User WHERE Id =:UserInfo.getUserId()];
        username = u1.username;
        isItemSelected=false;
        isChecked=false;
        isFirsttmelogin=u1.Is_First_Time_Login__c;
    }
        
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    //To get agreed terms & conditions from popup
    public void agreedTC(){
        
		isChecked=true;
        
		displayPopup = false;
        if(isChecked==true && displayPopup==false){
            isItemSelected=true;
            
        }
    }
    //To store last acceptance date from commops or portal user
    public void updateContacts() {   
        Try{    
            User emailidOfuser = [SELECT name,Id,Email, Username FROM User WHERE Id =:userInfo.getUserId()];
            contact con=[select id,email,TCP_TandC__c,TCP_TandC_Accepted_Date__c from contact where email=:emailidOfuser.email limit 1];
            system.debug('----con'+con);
            if(con.id!=null){
                con.TCP_TandC__c=true;
                con.TCP_TandC_Accepted_Date__c=system.today();
                update con;
                system.debug('----conupdate::'+con);
            }
        }  
        catch(Exception e){
            system.debug('Set New Password/Change Password: '+e.getMessage()+'line : '+e.getLineNumber());
            TCP_ExceptionLogClass.insertExceptionRecord('Set New Password/Change Password',e.getMessage(),'TCP_ChangePasswordController','execute','Exception');
        }        
   
    }
    //To allow users to change the password if no errors
    public PageReference changePassword() {
        if(isItemSelected==true){
            isChecked=isItemSelected;
        }
        
        if(isChecked==true){
            if(!ApexPages.hasMessages()){
                updateContacts();
            }
        }
        PageReference pg;
        User usr = [SELECT name,Id,Username,Is_First_Time_Login__c,email FROM User WHERE Id =:UserInfo.getUserId()];
        system.debug('==='+usr);
        
        // get TCP_ForgotPasswordSuccessful email templete 	
        EmailTemplate forgotPasswordSuccessful_emailtemp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE DeveloperName ='TCP_ForgotPasswordSuccessful'];
        // get TCP_ChangePasswordSuccessful email templete 	
        EmailTemplate changePasswordSuccessful_emailtemp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE DeveloperName ='TCP_ChangePasswordSuccessful'];

        OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName like :Label.TCP_From_Email_Address Limit 1];
        
        //SingleEmailMessage for TCP_ForgotPasswordSuccessful email templete 
        list<Messaging.SingleEmailMessage> mailList = new  list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                                                
        mail.setTemplateId(forgotPasswordSuccessful_emailtemp.Id);
        mail.setSaveAsActivity(false); 
       	mail.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
        mail.setTargetObjectId(UserInfo.getUserId());
        mailList.add(mail);
        
        //SingleEmailMessage for TCP_ChangePasswordSuccessful email templete 
        list<Messaging.SingleEmailMessage> mailList1 = new  list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();                                                
        mail1.setTemplateId(changePasswordSuccessful_emailtemp.Id);
        mail1.setSaveAsActivity(false); 
       	mail1.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
        mail1.setTargetObjectId(UserInfo.getUserId());
        mailList1.add(mail1);
        
         // for password validation
		String RegualrExpression_Password = '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$';
        Pattern MyPattern = Pattern.compile(RegualrExpression_Password);
		Matcher NewPswdMatcher = MyPattern.matcher(newPassword);
        Matcher VefyNewPswdMatcher = MyPattern.matcher(verifyNewPassword);
        
        system.debug('IsPasswordExpired===='+IsPasswordExpired);
        //if IsPasswordExpired is true then the user try to change password from site then the old password validation also need to 
        if(IsPasswordExpired == 'true'){
            if((newPassword != null && newPassword != '') || (verifyNewPassword != null && verifyNewPassword != '') || (oldPassword != null && oldPassword != '')){
                if((newPassword != null && newPassword != '') || (verifyNewPassword != null && verifyNewPassword != '')){
                    if((oldPassword != null && oldPassword != '') || (verifyNewPassword != null && verifyNewPassword != '')){
                        if((oldPassword != null && oldPassword != '') || (newPassword != null && newPassword != '')){
                    if(newPassword != null && newPassword != ''){
                        if(verifyNewPassword != null && verifyNewPassword != ''){
                            if(oldPassword != null && oldPassword != ''){
                                if(NewPswdMatcher.matches() || VefyNewPswdMatcher.matches()){
                                     if(newPassword.equals(verifyNewPassword)){
                                         if(!newPassword.equals(oldPassword)){
                                            //if(isChecked==True){
                                             pg = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
                                             if(! ApexPages.hasMessages()){
                                    			 pg = Page.TCP_LoginConfirm;
                                                 //updateContacts(usr.email);
                                                 if(!mailList1.isEmpty()){
                                                     Messaging.sendEmail(mailList1);
                                                 }
                                                 pg.setRedirect(true);
                                                 //Update Contacts
                                                 //updateContacts();
                                                  }
                                   			} 
                                           /* else{
                                                system.debug('select false'+isChecked);
                                                tcError='Please agree terms and conditions';
                                                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot reuse this old password'));
                                            }  
                                              }*/
                                    
                                else{
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot reuse this old password'));
                                }  
                                          }
                                    
                                else{
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The password do not match'));
                                }  
                                  
                                }
                                
                                else{
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Your password must be at least 8 characters long and include numbers, uppercase and lowercase letters, and at least one of these special characters: !@#$%^&*()_+-={}[];:'+',.?/`~><"'));
                                }    
                            }
                            
                            else{
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter value in the Old Password Field'));
                            }    
                        }
                        
                        else{
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter a value in the Verify New Password Field'));
                        }
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter value in the New Password Field'));
                    }
                            }
                
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Value required in Old Password and New Password Fields'));
                }
                        }
                
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Value required in Old Password and Verify New Password Fields'));
                }
                }
                
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Value required in New Password and Verify New Password Fields'));
                }
            }
            
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Value required in Old Password, New Password and Verify New Password Fields'));
            }
        }
        // IsPasswordExpired is false, means user try to change password from first time set password (or) from forgot password so here no need to add old password validation
        else
        {
            if((newPassword != null && newPassword != '') || (verifyNewPassword != null && verifyNewPassword != '') ){
    if(newPassword != null && newPassword != ''){
        if(verifyNewPassword != null && verifyNewPassword != ''){
            if(NewPswdMatcher.matches() || VefyNewPswdMatcher.matches()){
				
                if(newPassword.equals(verifyNewPassword)){
					//If Terms & Conditions selected
					if(isChecked==True){					//  if(!newPassword.equals(oldPassword)){ 
						pg = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
						if(! ApexPages.hasMessages()){
							pg = Page.TCP_LoginConfirm;
                           
							//By default for the new users Is_First_Time_Login__c is true
							// Is_First_Time_Login__c field is false then only send the ForgotPasswordSuccessful
							if(!mailList.isEmpty() && usr.Is_First_Time_Login__c == false){
								Messaging.sendEmail(mailList);
								//Pass the parameter to the TCP_LoginConfirm page
								//when firstTimeLogin is no, if click on login button in login confirm page navigate to login page
								pg.getParameters().put('firstTimeLogin', 'no'); 
							}
							else{
								//when firstTimeLogin is yes, if click on login button in login confirm page navigate to home page
								pg.getParameters().put('firstTimeLogin', 'yes'); 
							}
							// once set password new user, Is_First_Time_Login__c is false then the user consider as not a first time reset password user
							usr.Is_First_Time_Login__c = false;
							update usr;
                            
                            // updateContacts(usr.email);
                            
							pg.setRedirect(true);
                            
                            //Update Contacts
                            //updateContacts();
						}
					}
                    //Show Error message if terms and conditions checkbox is not selected by the user
					else{
						tcError='Please agree terms and conditions';
						
					} 
					if(usr.Is_First_Time_Login__c == false && isChecked==false){					//  if(!newPassword.equals(oldPassword)){ 
						pg = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
						if(! ApexPages.hasMessages()){
							pg = Page.TCP_LoginConfirm;
                           
							//By default for the new users Is_First_Time_Login__c is true
							// Is_First_Time_Login__c field is false then only send the ForgotPasswordSuccessful
							if(!mailList.isEmpty() && usr.Is_First_Time_Login__c == false){
								Messaging.sendEmail(mailList);
								//Pass the parameter to the TCP_LoginConfirm page
								//when firstTimeLogin is no, if click on login button in login confirm page navigate to login page
								pg.getParameters().put('firstTimeLogin', 'no'); 
							}
							else{
								//when firstTimeLogin is yes, if click on login button in login confirm page navigate to home page
								pg.getParameters().put('firstTimeLogin', 'yes'); 
							}
							// once set password new user, Is_First_Time_Login__c is false then the user consider as not a first time reset password user
							usr.Is_First_Time_Login__c = false;
							update usr;
                            
                            // updateContacts(usr.email);
                            
							pg.setRedirect(true);
                            
                            //Update Contacts
                            //updateContacts();
						}
					}
                    
                }
                else{
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The password do not match'));
                    }  
                }
			else{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Your password must be at least 8 characters long and include numbers, uppercase and lowercase letters, and at least one of these special characters: !@#$%^&*()_+-={}[];:'+',.?/`~><"'));
			}    
                        
            }
                    
		else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter a value in the Verify New Password Field'));
		}
		}
	else{
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter value in the New Password Field'));
	}
	}
            
    else{
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Value required in New Password and Verify New Password Fields'));
    }
}
 
        
    return pg;
        
    }
    
    
    @AuraEnabled
    public static string doChangePassword(String newPassword, String verifyNewPassword, String oldPassword){
        try {
            
            ApexPages.PageReference pageRef  = Site.changePassword(newPassword, verifyNewPassword, oldPassword); 
            if(pageRef != null) 
                return pageRef.getUrl();
            else
                return null;
            
            
        } catch (Exception e) {
                system.debug('Change Password : '+e.getMessage()+'line : '+e.getLineNumber());
                TCP_ExceptionLogClass.insertExceptionRecord('Change Password',e.getMessage(),'TCP_ChangePasswordController','execute','Exception');
        }
        return null;   
            
    }
    
    public PageReference cancel() {
        return Network.communitiesLanding();
    }
}