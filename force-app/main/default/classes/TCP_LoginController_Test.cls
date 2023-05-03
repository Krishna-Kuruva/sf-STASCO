/**************************************************************************************************
 * Class Name : TCP_LoginController_Test 
 * Description: To cover code percentage for login form
 * Verion     : 1.0
 * **************************************************************************************************/

@IsTest 
public with sharing class TCP_LoginController_Test {
    
    /* Data Setup for community user*/
    @TestSetup
    static void createTestData() {
         User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
       List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
       List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        }
    }
    
    @IsTest(SeeAllData=false) 
    public static void testLoginController() {
        //User usr = TCP_TestDataUtilities.createcustomerUsers();
        TCP_LoginController controller = new TCP_LoginController();
        controller.username = 'test@saleforce.com';   
        controller.password = 'salesforce@1234'; 
        
        System.assertEquals(controller.doLogin(),null); 
    }
    
    // Instantiate a new controller with all parameters in the login page
     @IsTest(SeeAllData=false) public static void testLoginController1() {
        //User usr = Test_Utility.createCommunityUser();
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c from contact limit 1]);
        List<User> usr = TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser',testCons[0]);
        TCP_LoginController controller = new TCP_LoginController();
        controller.username = usr[0].username;   
        controller.password = 'Test@1234'; 
        //controller.landingPage = Site.login(usr.username,'Test@1234',null);
        System.assertEquals(controller.doLogin(),controller.landingPage); 
        
    }
    
    @IsTest(SeeAllData=false) 
    public static void testLoginController2() { 
    TCP_LoginController controller = new TCP_LoginController();
        controller.username = '';   
        controller.password = ''; 
        Test.StartTest(); 
        	controller.doLogin(); 
        Test.StopTest();
    	System.assertEquals(ApexPages.getMessages().get(0).getDetail(), 'Enter values in the Username & Password Field'); 
  	} 
  
    @IsTest(SeeAllData=false)
    public static void testLoginController3() { 
    TCP_LoginController controller = new TCP_LoginController();
        controller.username = 'test@saleforce.com';   
        controller.password = ''; 
        Test.StartTest(); 
        	controller.doLogin(); 
        Test.StopTest();
    	System.assertEquals(ApexPages.getMessages().get(0).getDetail(), 'Enter a value in the Password Field'); 
  	} 
    
    @IsTest(SeeAllData=false) 
    public static void testLoginController4() { 
    TCP_LoginController controller = new TCP_LoginController();
        controller.username = '';   
        controller.password = 'Test@1234'; 
        Test.StartTest(); 
        	controller.doLogin(); 
        Test.StopTest();
    	System.assertEquals(ApexPages.getMessages().get(0).getDetail(), 'Enter a value in the Username Field'); 
  	} 

    @IsTest(SeeAllData=false) 
    public static void verifyAuthSessionTest() {
        //AuthSession sessions = Test_Utility.getsession();
        Test.StartTest(); 
            TCP_LoginController.verifyAuthSession(); 
            TCP_LoginController setauth=new TCP_LoginController();
            setauth.closePopup();
            setauth.showPopup();
        Test.StopTest();
        //System.assertEquals(TCP_LoginController.verifyAuthSession(),false); 
    } 
  }