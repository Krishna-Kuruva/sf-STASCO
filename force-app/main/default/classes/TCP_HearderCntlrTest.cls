@isTest
public class TCP_HearderCntlrTest{

    @TestSetup
    static void createTestData() {
    	List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,true);
        TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
    }
    
    @isTest
    public static void testGetorgId(){
        try{
            TCP_HearderCntlr.getorgId();
        }catch(exception e){
            system.debug('testGetorgId exception');
        }
    }

    @isTest
    public static void testGetUrl(){
        try{
			TCP_HearderCntlr.geturl();            
        }catch(exception e){
            system.debug('testGetUrl exception');
        }
        
    }
    
    @isTest
    public static void testGetOrgDomainUrl(){
         try{
             TCP_HearderCntlr.getOrgDomainUrl();      
        }catch(exception e){
            system.debug('testGetOrgDomainUrl exception');
        }
        
    }
    
    @isTest
    public static void testLogonastcp(){
         try{
            List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
            List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
            System.runAs(userList[0]){
                TCP_HearderCntlr.logonastcp();
            }
            
        }catch(exception e){
            system.debug('testLogonastcp exception');
        }
        
    }
    
    @isTest
    public static void testGetContactId(){
         try{
            	List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
                List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
                System.runAs(userList[0]){
                    TCP_HearderCntlr.getcontactid();
                }
        }catch(exception e){
            system.debug('testGetContactId exception');
        }
        
    }
    
    @isTest
    public static void testGetPortalUser(){
        try{
            List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
            List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
            System.runAs(userList[0]){
                TCP_HearderCntlr.getportaluser(conList[0].Id);
                TCP_HearderCntlr.getportaluser('test');
            }
        }catch(Exception e){
            system.debug('testGetPortalUser exception');
        }
    }
    
    @isTest
    public static void testGetuserrecordid(){
         try{
             	List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
        		List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
        		System.runAs(userList[0]){
            		TCP_HearderCntlr.getuserrecordid();
        		}
            
        }catch(exception e){
            system.debug('testGetuserrecordid exception');
        }
        
    }
    
    @isTest
    public static void testGetNetworkid(){
         try{
            List<Contact> conList = [Select id, name, email from contact where email='ishaque.mohammad@shell.com'];
        	List<User> userList = TCP_TestDataUtilities.createcustomerUsers(1,'TCPCustomerCommunityPlusUser', conList[0]);
        	System.runAs(userList[0]){
            	TCP_HearderCntlr.getNetworkid();
        	}
        }catch(exception e){
            system.debug('testGetNetworkid exception');
        }
        
    }
    
    

}