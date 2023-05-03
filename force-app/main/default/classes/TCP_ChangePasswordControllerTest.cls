@isTest
public class TCP_ChangePasswordControllerTest {
     @TestSetup
    static void createTestData() {
        User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,true);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        }
    }
    //To cover Terms and Conditions functionality
    @isTest static void popupTestScenarios(){
        TCP_ChangePasswordController closepop=new TCP_ChangePasswordController();
        Test.startTest();
            closepop.closePopup();
            closepop.showPopup();
            closepop.agreedTC();
        	//closepop.changePassword();
        Test.stopTest();
    }
    
    @isTest static void testFirstTimePassword(){
         
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
        
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        System.runAs(listofusers[0]) {
        Test.StartTest(); 
	    PageReference pageRef = Page.TCP_ChangePassword; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        TCP_ChangePasswordController changePasswordControl  = new TCP_ChangePasswordController();
        changePasswordControl.oldPassword='Password@123';
        changePasswordControl.verifyNewPassword='Password@1234';
        changePasswordControl.newPassword='Password@1234';
        changePasswordControl.changePassword(); 
        System.assert(!ApexPages.hasMessages(ApexPages.SEVERITY.ERROR)); 
        Test.StopTest();
        }
    }
    
     @isTest static void testExpiredPassword(){
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
       	testCons[0].email='testuser002@test.com';
        update testCons;
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        System.runAs(listofusers[0]) {
            Test.StartTest(); 
            for(integer i=0;i<2;i++){
              PageReference pageRef = Page.TCP_ChangePassword; // Add your VF page Name here
              Test.setCurrentPage(pageRef);
              TCP_ChangePasswordController changePasswordControl  = new TCP_ChangePasswordController();
              changePasswordControl.oldPassword='';
              changePasswordControl.verifyNewPassword='';
              changePasswordControl.newPassword='';
              if(i==1){
              changePasswordControl.IsPasswordExpired='true';
              changePasswordControl.isChecked=true;
              }
              changePasswordControl.updateContacts(); 
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR)); 
              
              changePasswordControl.oldPassword='Password@123';
              changePasswordControl.verifyNewPassword='';
              changePasswordControl.newPassword='';
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR)); 
              
              changePasswordControl.oldPassword='';
              changePasswordControl.verifyNewPassword='Password@123';
              changePasswordControl.newPassword='';
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR)); 
                    
              changePasswordControl.oldPassword='';
              changePasswordControl.verifyNewPassword='';
              changePasswordControl.newPassword='Password@123';      
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));  
                    
              changePasswordControl.oldPassword='Password@123';
              changePasswordControl.verifyNewPassword='';
              changePasswordControl.newPassword='Password@123';      
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
                    
              changePasswordControl.oldPassword='';
              changePasswordControl.verifyNewPassword='Password@123';
              changePasswordControl.newPassword='Password@123';      
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
              
              changePasswordControl.oldPassword='Password@123';
              changePasswordControl.verifyNewPassword='Password@123';
              changePasswordControl.newPassword='Password@123';      
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
              
              changePasswordControl.oldPassword='Password@123';
              changePasswordControl.verifyNewPassword='Passwo';
              changePasswordControl.newPassword='Passwo';      
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
                
              changePasswordControl.oldPassword='Password@123';
              changePasswordControl.verifyNewPassword='Password@1234';
              changePasswordControl.newPassword='Password@12345';      
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
              
              changePasswordControl.oldPassword='Password@123';
              changePasswordControl.verifyNewPassword='Password@123';
              changePasswordControl.newPassword='';     
              changePasswordControl.changePassword(); 
              changePasswordControl.cancel();
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR)); 
                    
              changePasswordControl.verifyNewPassword='Password@1234';    
              changePasswordControl.oldPassword='FiveYesdfs!1'; 
              changePasswordControl.newPassword='Password@1234'; 
              changePasswordControl.changePassword(); 
              System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR)); 
           } 
            Test.StopTest();
        }
    }
    
     @isTest static void testExpiredPasswordPositive(){
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
       	testCons[0].email='testuser002@test.com';
        update testCons;
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        System.runAs(listofusers[0]) {
          Test.StartTest();
          PageReference pageRef = Page.TCP_ChangePassword; // Add your VF page Name here
          Test.setCurrentPage(pageRef);
          TCP_ChangePasswordController changePasswordControl  = new TCP_ChangePasswordController();
          changePasswordControl.oldPassword='Password@123';
          changePasswordControl.verifyNewPassword='Password@1234';
          changePasswordControl.newPassword='Password@1234';
          changePasswordControl.changePassword(); 
          System.assert(!ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));  
          Test.StopTest();
       }
     }
     
    @isTest static void testDoChangePassword(){
       Test.StartTest(); 
	  PageReference pageRef = Page.TCP_ChangePassword; // Add your VF page Name here
      TCP_ChangePasswordController.doChangePassword('Password@1234','Password@1234','Password@1234');
      String error;
      TCP_ChangePasswordController.doChangePassword(error,'Password@1234','Password@1234'); 
      Test.StopTest();
    }
      
}