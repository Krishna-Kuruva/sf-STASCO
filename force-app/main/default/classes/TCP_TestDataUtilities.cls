/**************************************************************************************************************************
 * Application  :   Trading and Supply Customer Portal (TCP)
 * Description  :   Test Data Utilities class for all the genric data creation.
***************************************************************************************************************************/
@isTest(SeeAllData=false)
public class TCP_TestDataUtilities {
     public static User createAdminUsers(){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name=:'System Administrator'].Id;
         Id roleId=[Select Id, Name from UserRole where Name=:'Administrator'].Id;
            User u = new User();
            u.Alias = 'test';
            u.EmailEncodingKey = 'UTF-8';            
            u.FirstName = 'Admin';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey = 'en_US';
            u.ProfileId = profileId;
            u.TimeZoneSidKey = 'America/Los_Angeles';
            u.Username = 'testuserAdminDataUtility@test.com';
            u.Email = 'testuser0021@test.com';
            u.LastName = 'Test2Admin';
            u.Is_First_Time_Login__c=false;
            u.UserRoleId=roleId;
            
            
            
        
        if(u!=null){
            insert u;
        }
        return u;
    }
    public static List<TCP_KeyValueSettings__c> createKeyValueSet(){
        List<TCP_KeyValueSettings__c> keyValueList=new List<TCP_KeyValueSettings__c>();
        TCP_KeyValueSettings__c keyValue=new TCP_KeyValueSettings__c();
        keyValue.TCP_ServiceName__c='https://MUNTSD-S-70965.europe.shell.com:8090/archive';
        keyValue.TCP_Value__c='Opentext';
        keyValue.Name='TCP_OpentextBackendURL';
        keyValueList.add(keyValue);
        TCP_KeyValueSettings__c keyValue1=new TCP_KeyValueSettings__c();
        keyValue1.TCP_ServiceName__c='https://api-dev.shell.com/tcp/orderfile/v1/archive';
        keyValue1.TCP_Value__c='Apigee';
        keyValue1.Name='TCP_ApigeeOpentextURL';
        keyValueList.add(keyValue1);
        insert keyValueList;
        return keyValueList;
    }
    // Parent Account creation
    public static Account createParentAccounts() {
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        TCP_Sales_Area__c testSalesArea=new TCP_Sales_Area__c();
        
            testSalesArea.Sales_Org__c='SETO';
        	testSalesArea.Sales_Region__c='EAST';
            testSalesArea.Division__c='DF';
            testSalesArea.Distribution_Channel__c='D';
      
            insert testSalesArea;
        
            Account acc = new Account();
            acc.Name = 'SampleAccount';
            acc.AccountNumber = String.valueOf(80026);
            acc.GSAP_Account_Number__c = String.valueOf(80026);
			acc.Sales_Area__c=testSalesArea.id;
        	acc.Active__c=true;
            acc.RecordTypeId=tcpAccountRecTypeid;
            acc.Customer_Type__c = 'Sold To';
        	acc.ShippingStreet = 'Test';
            acc.ShippingCity = 'Test';
            acc.ShippingState = 'Test';
            acc.ShippingCountry = 'Test';
            acc.ShippingPostalCode = '1234';
      
          Insert acc;  
        
        return acc;
    }
       public static List<Account> createParentAccountsBulk(integer noOfAccounts) {
             
           string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        TCP_Sales_Area__c testSalesArea=new TCP_Sales_Area__c();
        List<account> accList=new List<Account>();
            testSalesArea.Sales_Org__c='SETO';
        	testSalesArea.Sales_Region__c='EAST';
            testSalesArea.Division__c='DF';
            testSalesArea.Distribution_Channel__c='D';
             
            insert testSalesArea;
        
            for(integer i=0; i<noOfAccounts;i++) {
            Account acc = new Account();
            acc.Name = 'SampleAccount'+string.valueOf(i);
            acc.AccountNumber = String.valueOf(80026);
            acc.GSAP_Account_Number__c = String.valueOf(80026);
			acc.Sales_Area__c=testSalesArea.id;
        	acc.Active__c=true;
            acc.TCP_STNSAP_ExternalId1__c='1234'+string.valueOf(i)+testSalesArea.Sales_Org__c+testSalesArea.Distribution_Channel__c+testSalesArea.Division__c;
            acc.RecordTypeId=tcpAccountRecTypeid;
            acc.Customer_Type__c = 'Sold To';
        	acc.ShippingStreet = 'Test';
            acc.ShippingCity = 'Test';
            acc.ShippingState = 'Test';
            acc.ShippingCountry = 'Test';
            acc.ShippingPostalCode = '1234';
                accList.add(acc);
            }
          
        Insert accList;
           
        return accList;
    }
     public static List<Account> createAccountsWithExternalId(integer noOfAccounts) {
             
           string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        TCP_Sales_Area__c testSalesArea=new TCP_Sales_Area__c();
        List<account> accList=new List<Account>();
            testSalesArea.Sales_Org__c='SETO';
        	testSalesArea.Sales_Region__c='EAST';
            testSalesArea.Division__c='DF';
            testSalesArea.Distribution_Channel__c='D';
             
            insert testSalesArea;
        
            for(integer i=0; i<noOfAccounts;i++) {
            Account acc = new Account();
            acc.Name = 'SampleAccount'+string.valueOf(i);
            acc.AccountNumber = String.valueOf(80026);
            acc.GSAP_Account_Number__c = String.valueOf(80026);
			acc.Sales_Area__c=testSalesArea.id;
        	acc.Active__c=true;
            acc.TCP_STNSAP_ExternalId1__c='1234'+testSalesArea.Sales_Org__c+testSalesArea.Distribution_Channel__c+testSalesArea.Division__c;
            acc.RecordTypeId=tcpAccountRecTypeid;
            acc.Customer_Type__c = 'Sold To';
        	acc.ShippingStreet = 'Test';
            acc.ShippingCity = 'Test';
            acc.ShippingState = 'Test';
            acc.ShippingCountry = 'Test';
            acc.ShippingPostalCode = '1234';
                accList.add(acc);
            }
          
        Insert accList;
           
        return accList;
    }
    // Account creation for general SoldTo Accounts
    public static List<Account> createAccounts(Integer noOfAccounts, boolean SalesArea) {
         string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        TCP_Sales_Area__c testSalesArea=new TCP_Sales_Area__c();
        TCP_DistributionEmailList__c testDistList= new TCP_DistributionEmailList__c();
        if(SalesArea)
        {
            testSalesArea.Sales_Org__c='SETO';
            testSalesArea.Sales_Region__c='EAST';
            testSalesArea.Division__c='DF';
            testSalesArea.Distribution_Channel__c='D';
            
            insert testSalesArea;
        
            
            testDistList.TCP_Region__c='EAST';
            testDistList.TCP_Commops_Delivery_Lists__c='test@test.com';
            testDistList.Name='EAST';
            
             insert testDistList;
        
           
        }
        List<Account> accntList = new List<Account>();
        Account parentAcc=createParentAccounts();
            
        for(integer i=0; i<noOfAccounts;i++) {
            Account acc = new Account();
            acc.Name = 'SampleAccount'+string.valueOf(i);
            acc.AccountNumber = string.valueOf(80020+i);
            acc.GSAP_Account_Number__c = string.valueOf(80020+i);
            acc.ParentId = parentAcc.Id;
            acc.Customer_Type__c = 'Ship To';
            acc.Active__c=true;
            acc.ShippingStreet = 'Test';
            acc.RecordTypeId=tcpAccountRecTypeid;
            acc.ShippingCity = 'Test';
            acc.ShippingState = 'Test';
            acc.ShippingCountry = 'Test';
            acc.ShippingPostalCode = '1234';
            if(SalesArea){
                acc.Sales_Area__c=testSalesArea.id;
            }
            accntList.add(acc);
        }
       
        Insert accntList;
        
        return accntList;
    }
    
    // Contact creation 
    public static List<contact> createContacts(Integer noOfContact, Account Account) {
        List<contact> contactList = new List<contact>();
        for(integer i=0; i<noOfContact;i++) {
            contact testContact = new contact();
            testContact.LastName = 'SampleContact'+string.valueOf(i);
            testContact.email='ishaque.mohammad@shell.com';
            testContact.Phone='7777777777';
            testContact.TCP_Products__c='Glycol';
            testContact.AccountId =Account.Id;
            contactList.add(testContact);
        }
       
             Insert contactList;
        
       
        return contactList;
    }
    
    
    //create Order
    public static List<Order> createOrders(Integer noofOrders, Account account){
        //List<Contact> conList=createContacts(1,account);
        //List<user> userDetails=createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', conList[0]);
        
        //String UserName = userDetails.Id;
        string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
        List<Order> orderList = new List<Order>();
        for(Integer i=0; i<noOfOrders; i++){
            Order order = new Order(
                Name = 'Submitted Order ' + i,
                AccountId = account.Id,
                Sold_To__c=account.Id,
                Ship_To__c= account.Id,
                Bill_To__c=account.Id,
                Payer__c=account.Id,
                Sales_Order_Number__c='12345',
                EffectiveDate = System.today(),
                poNumber = '123123',
                Order_Other_Instructions__c = 'OtherInstructionOtherInstruction',
                Mode_of_Transport__c = 'Road Tank Truck',
                Delivery_Terms__c = 'FCA',
                TCP_Order_Status__c = 'Submitted',
                status='Draft',
                /*TCP_Modification_Requested_By__r = userDetails[0],
                TCP_Modification_Requested_Date__c = system.today(),
                TCP_Cancellation_Placed_By__r = userDetails[0],
                TCP_Cancellation_Requested_Date__c = system.today(),*/
                Recordtypeid=tcpOrderRecTypeid
            );
            Order order1 = new Order(
                Name = 'Approved Order ' + i,
                AccountId = account.Id,
                Sold_To__c=account.Id,
                Ship_To__c= account.Id,
                EffectiveDate = System.today(),
                poNumber = '123123',
                 Sales_Order_Number__c='12345',
                Order_Other_Instructions__c = 'OtherInstructionOtherInstruction',
                Mode_of_Transport__c = 'Road Tank Truck',
                Delivery_Terms__c = 'FCA',
                TCP_Order_Status__c = 'Approved (M)',
                status='Draft',
		     Recordtypeid=tcpOrderRecTypeid
            ); 
            Order order2 = new Order(
                Name = 'GSAP Approved Order ' + i,
                AccountId = account.Id,
                Sold_To__c=account.Id,
                Ship_To__c= account.Id,
                EffectiveDate = System.today(),
                poNumber = '123123',
                 Sales_Order_Number__c='12345',
                Order_Other_Instructions__c = 'OtherInstructionOtherInstruction',
                Mode_of_Transport__c = 'Road Tank Truck',
                Delivery_Terms__c = 'FCA',
                TCP_Order_Status__c = 'Approved',
                status='Draft',
                Is_Order_Confirmed__c=False,
                Chemical_GSAP_P_31__c=True,
		     Recordtypeid=tcpOrderRecTypeid
            ); 
            
            orderList.add(order);
            orderList.add(order1);
            orderList.add(order2);
        }
        Insert orderList;
        
        
        List<order> insertedOrders=new List<order>([select id,Name, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where id=:orderList[0].id or id=:orderList[1].id or id=:orderList[2].id]);
        return insertedOrders;
    }
	
    //Change Order iteams
    public static List<TCP_Change_Cancel_Request__c> createChangeOrders(Integer noofOrders, Order ord){
        List<TCP_Change_Cancel_Request__c> orderList = new List<TCP_Change_Cancel_Request__c>();
        for(Integer i=0; i<noOfOrders; i++){
            TCP_Change_Cancel_Request__c order = new TCP_Change_Cancel_Request__c(
                
                Customer_Name__c = 'customerName',
                Customer_PO__c='CustomerPO',
                Customer_PO_New__c= 'CustomerPo2',
                Delivery_Terms__c = '123123',
                Delivery_Terms_New__c = 'OtherInstructionOtherInstruction',
                Mode_of_Transport__c = 'Road Tank Truck',
                Mode_of_Transport_New__c = 'FCA',
                Other_Instruction__c = 'Draft',
                Other_Instruction_New__c='Draft',
                Status__c='Submitted',
                Type__c='Modification',
                Web_Order__c=ord.Id
            );
            orderList.add(order);
        }
        Insert orderList;
        
        return orderList;
    }
    
    //Change Order Line Iteam
    public static List<TCP_Change_Cancel_Order_Line_Items__c> createChangeOrdersIteams(Integer noofOrders, TCP_Change_Cancel_Request__c ord){
        List<TCP_Change_Cancel_Order_Line_Items__c> orderList = new List<TCP_Change_Cancel_Order_Line_Items__c>();
        for(Integer i=0; i<noOfOrders; i++){
            TCP_Change_Cancel_Order_Line_Items__c order = new TCP_Change_Cancel_Order_Line_Items__c(
                
                Change_Cancel_Request_Order__c = ord.Id,
                Delivery_Collection_Date__c=System.today(),
                Delivery_Collection_Date_New__c= System.today(),
                Instruction__c = '123123',
                Instruction_New__c = 'OtherInstructionOtherInstruction',
                Item_number__c = 'Road Tank Truck',
                Quantity__c = 456,
                Quantity_New__c = 6,
                Shell_Contract_No__c='Draft',
                Shell_Contract_No_New__c='Submitted',
                Type__c='Modification',
                Unit__c='Draft',
                Unit_New__c='Draft1'
            );
            orderList.add(order);
        }
        Insert orderList;
        
        return orderList;
    }
    
     //To create Order Line Items
    public static List<TCP_OrderLineItem__c> createOrderLineItems(Integer noOfOrdersLineItem,Order order){
        List<TCP_OrderLineItem__c> orderLineItemList = new List<TCP_OrderLineItem__c>();
        List<Product2> prodList=createProducts(1);
        for(Integer i=0; i < noOfOrdersLineItem; i++){
            TCP_OrderLineItem__c ordLineItem = new TCP_OrderLineItem__c(
                Order__c = order.id,
                Quantity__c = 2.0,
                Product__c=prodList[0].id,
                Unit__c = 'KG',
                Delivery_Collection_Date__c = Date.newInstance(2022, 12, 31),
                MaterialNumber__c = '470',
                Sales_Order_Line_Item_No__c='000010',
                Material_Name__c = 'Sample Product',
                Contract_No__c = '12345',
                Special_Price__c = '123',
                Other_Instruction__c = 'testinstructiontestinstructiontestinstructiontestinstruction'
            );
            orderLineItemList.add(ordLineItem);
        }
            Insert orderLineItemList;
        
        
        return orderLineItemList;
    }
    
    //create Document
    public static List<Document> createDocs(Integer noofDocs){
        List<Document> docList = new List<Document>();
        for(Integer i=0; i<noofDocs; i++){
            Document doc = new Document(
            	Body = Blob.valueOf('Some Text'),
    			ContentType = 'application/pdf',
    			DeveloperName = 'my_document',
    			IsPublic = true,
    			Name = 'Shell Logo1',
    			FolderId = [select id from folder where name = 'TCP Folder'].id
            );
            docList.add(doc);
        }
        Insert docList;
        
        
        return docList;
    }
    
    public static List<Product2> createProducts(Integer noOfProds){
        List<Product2> prodList = new List<Product2>();
        for(Integer i=0; i<noOfProds; i++){
            Product2 prod = new Product2(name ='sample product'+i, productCode = '12345'+i);
            prodList.add(prod);
        }
       
            insert prodList;
        
        
        return prodList;
    }
    
    public static Order createOrderWithGSAPData(String status){
        List<Account> accData = createAccounts(1,false);
            Order order = new Order(
                Name = 'Test Order ',
                AccountId = accData[0].id,
                Sold_To__c=accData[0].id,
                Ship_To__c= accData[0].id,
                EffectiveDate = System.today(),
                poNumber = '123123',
                Order_Other_Instructions__c = 'OtherInstructionOtherInstruction',
                Mode_of_Transport__c = 'Road Tank Truck',
                Delivery_Terms__c = 'FCA',
                TCP_Order_Status__c = status,
                Chemical_GSAP_P_31__c = true,
                Rush_Order__c = true,
                Third_Party__c=true,
                Late_Order__c=true,
                Last_Minute_Changes__c=true,
                status='Draft'
            );
       
            Insert order;
        
        
        return order;
    }
    //Create customer users with test data
    public static List<User> createcustomerUsers(Integer numberOfUsers, String profileName, contact con){
      
        List<User> userList = new List<user>();
        Id profileId = [SELECT Id FROM Profile WHERE Name=:profileName].Id;
        for(Integer i=0; i<numberOfUsers; i++){
            User u = new User();
            u.Alias = String.valueOf(i);
            u.EmailEncodingKey = 'UTF-8';            
            u.FirstName = String.valueOf(i);
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey = 'en_US';
            u.ProfileId = profileId;
            u.TCP_Role__c='End user';
            u.TimeZoneSidKey = 'America/Los_Angeles';
            u.Username = 'testuser2@test.com'+i;
            u.Email = 'testuser002@test.com';
            u.contactId=con.id;
            u.LastName = 'Test2';
            u.Is_First_Time_Login__c=false;
          
            
            userList.add(u);
            
        }
        if(userList.size()>0){
            insert userList;
        }
        return userList;
    }
    //Create Community User
    public static User createCommunityUser(contact con)
    {
       Profile p = [SELECT Id FROM Profile WHERE Name = 'TCPCustomerCommunityPlusUser' LIMIT 1];
		User usr = New User();
         	usr.UserName = 'test_' + math.random() + '@test.com';
            usr.FirstName = 'Test-First';
            usr.LastName = 'Test-Last';
            usr.Alias = 'test';
            usr.email = 'test' + math.random() + '@test.com';
            
            usr.ProfileID = p.id;
            usr.TimeZoneSidKey = 'America/New_York';
        
            usr.LocaleSidKey = 'en_US';
            usr.EmailEncodingKey = 'UTF-8'; 
            usr.LanguageLocaleKey = 'en_US';
            usr.ContactID = con.Id;
        insert usr;
        
        return usr;
    }
    //Create  users with test data
    public static List<Account_Contact_Relationship__c> createACRRecords(Account accnt, Contact con, Integer numberOfACRs){
        
        List<Account_Contact_Relationship__c> acrlist = new List<Account_Contact_Relationship__c>();
        for(Integer i=0; i<numberOfACRs; i++){
            Account_Contact_Relationship__c acr = new Account_Contact_Relationship__c();
            acr.Account__c=accnt.id;
            acr.Portal_User_Contact__c=con.id;
            acrlist.add(acr);
            
        }
        if(acrlist.size()>0){
           
                insert acrlist;
            
            
        }
        return acrlist;
    }
    public static TCP_ShellContactEmail__c createShellContacts(){
        TCP_ShellContactEmail__c shellConList=new TCP_ShellContactEmail__c();
        shellConList.Name='test Con';
        shellConList.Contact_Email__c='test@gmail.com';
        shellConList.Contact_Name__c='Testing 1';
        shellConList.Contact_Region__c='ROTO';
       
            insert  shellConList;
        
        
        return shellConList;
    }

}