@isTest
public class TCP_HearderCntlrTest{

    @TestSetup
    static void createTestData() {
    	List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,true);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
    }
    
    @isTest
    public static void testGetorgId(){
        try{
            String resp = TCP_HearderCntlr.getorgId();
        }catch(exception e){
            
        }
    }

    @isTest
    public static void testGetUrl(){
        try{
			String resp = TCP_HearderCntlr.geturl();            
        }catch(exception e){
            
        }
        
    }
    
    @isTest
    public static void testGetOrgDomainUrl(){
         try{
             String resp = TCP_HearderCntlr.getOrgDomainUrl();      
        }catch(exception e){
            
        }
        
    }
    
    @isTest
    public static void testLogonastcp(){
         try{
            List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
            List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
            System.runAs(userList[0]){
                boolean resp = TCP_HearderCntlr.logonastcp();
            }
            
        }catch(exception e){
            
        }
        
    }
    
    @isTest
    public static void testGetContactId(){
         try{
            	List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
                List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
                System.runAs(userList[0]){
                    String resp = TCP_HearderCntlr.getcontactid();
                }
        }catch(exception e){
            
        }
        
    }
    
    @isTest
    public static void testGetPortalUser(){
        try{
            List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
            List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
            System.runAs(userList[0]){
                String resp = TCP_HearderCntlr.getportaluser(conList[0].Id);
                String resp2 = TCP_HearderCntlr.getportaluser('test');
            }
        }catch(Exception e){
                
        }
    }
    
    @isTest
    public static void testGetuserrecordid(){
         try{
             	List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
        		List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
        		System.runAs(userList[0]){
            		String resp = TCP_HearderCntlr.getuserrecordid();
        		}
            
        }catch(exception e){
            
        }
        
    }
    
    @isTest
    public static void testGetNetworkid(){
         try{
            List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
        	List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
        	System.runAs(userList[0]){
            	String resp = TCP_HearderCntlr.getNetworkid();
        	}
        }catch(exception e){
            
        }
        
    }
    
    

}