/**
* An apex page controller that exposes the site forgot password functionality
*/

@IsTest public with sharing class TCP_ForgotPasswordController_Test {
    @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        User usr = Test_Utility.createCommunityUser();
        TCP_ForgotPasswordController controller = new TCP_ForgotPasswordController();
        controller.username = usr.Username;   
        controller.emailid = usr.Email; 
        
        System.assertEquals(controller.forgotPassword(),null); 
        
    }
    @IsTest(SeeAllData=false) public static void testForgotPasswordControllerNegative() {
        // Instantiate a new controller with all parameters in the page
        User usr = Test_Utility.createCommunityUser();
        TCP_ForgotPasswordController controller = new TCP_ForgotPasswordController();
        //controller.username = usr.Username;   
        controller.emailid = '';
        Test.StartTest();
        system.runAs(usr){
            controller.forgotPassword();
        }
        Test.StopTest();
        System.assertEquals(ApexPages.getMessages().get(0).getDetail(), 'Enter a value in the Username Field'); 
    }
}