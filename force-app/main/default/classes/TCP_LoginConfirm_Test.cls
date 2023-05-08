/**************************************************************************************************
 * Class Name : TCP_LoginConfirm_Test 
 * Description: To cover code percentage for login conformation page
 * Verion     : 1.0
 * **************************************************************************************************/
@IsTest 
public class TCP_LoginConfirm_Test {
    @TestSetup
    static void createTestData() {
        //UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Administrator' Limit 1];
		//User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
		//adminUser.UserRoleId = userRole.Id;
		//update adminUser;
       // System.runAs(adminUser){
          User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
            User usr = TCP_TestDataUtilities.createCommunityUser(testContact[0]);
        }
    }
    
    //To test login confirmed
    @IsTest 
    static void loginConfirmTest() {
      
        //User usr = Test_Utility.createCommunityUser();
        User user =[select id,name from user Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        PageReference ref = 
        new PageReference('/apex/TCP_LoginConfirm?firstTimeLogin=no'); 
    	Test.setCurrentPage(ref);
        TCP_LoginConfirm controller = new TCP_LoginConfirm();
        system.runAs(user){
            controller.urlPara = 'no';        
       }
        
    }
    //To test login confirmed
     @isTest static void loginConfirmTest1() {
        //User usr = Test_Utility.createCommunityUser();
         User usr =[select id,name from user Where Profile.Name='System Administrator' and isActive=true Limit 1];
         TCP_LoginConfirm controller = new TCP_LoginConfirm();
         PageReference ref = 
        new PageReference('/apex/TCP_LoginConfirm?firstTimeLogin=yes'); 
    	Test.setCurrentPage(ref); 
        system.runAs(usr){
            controller.urlPara = 'yes';        
        }
        
    }
}