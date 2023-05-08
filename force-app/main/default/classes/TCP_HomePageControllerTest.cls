/*****************************************************************************
 * Purpose: Test class for TCP_HomePageController
 * Verion : 1.0
 * **************************************************************************/
@isTest
public class TCP_HomePageControllerTest {
    
	@TestSetup
    static void createTestData(){
         User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<Account_Contact_Relationship__c> testacr=TCP_TestDataUtilities.createACRRecords(testAccounts[0], testContact[0], 1);
   		List<Order> testOrder=TCP_TestDataUtilities.createOrders(1,testAccounts[0]);
         List<TCP_OrderLineItem__c> ordLine=TCP_TestDataUtilities.createOrderLineItems(1,testOrder[0]);
        }
    }
    
    @isTest
    static void PostiveTestCase(){
        string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
        List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
        Account acc=[select id, AccountNumber, ParentId,recordtype.id, name from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpOrderRecTypeid;
        update acc;
        Order ord=[select  id,Name, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from order where Sold_To__c=:acc.Id limit 1];
        TCP_OrderLineItem__c ordLine=[Select Id, Order__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        
        List<Account_Contact_Relationship__c>  acrRecList=[select id, account__c,Portal_User_Contact__c from Account_Contact_Relationship__c where account__c=:acc.id limit 1];
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
         TCP_OrderWrapper wrap=new TCP_OrderWrapper();
        wrap.id=ord.Id;
        wrap.name=ord.Name;
        wrap.orderNumber=ord.OrderNumber;
        wrap.poNumber=ord.PoNumber;
        wrap.otherInstructions=ord.Order_Other_Instructions__c;
        wrap.modeOfTransport=ord.Mode_of_Transport__c;
        wrap.deliveryTerms=ord.Delivery_Terms__c;
        wrap.status=ord.Status;
        wrap.soldToId=acc.Id;
        wrap.shipToId = acc.Id;
        wrap.billToId = acc.Id;
        wrap.shipToNumber = acc.AccountNumber;
        wrap.soldToName = acc.Name;
        wrap.billToNumber = acc.AccountNumber;
        wrap.shipToNumber = acc.AccountNumber;
        wrap.payerNumber = acc.AccountNumber;
        wrap.payerId = acc.Id;
        TCP_OrderLineItemWrapper lineWrap=new TCP_OrderLineItemWrapper();
        lineWrap.Id=ordLine.Id;
        lineWrap.shellContractNo = '12345';
        lineWrap.instructions = 'test';
        lineWrap.orderId=ordLine.Order__c;
        lineWrap.quantity=String.valueOf(ordLine.Quantity__c);
        lineWrap.unit=ordLine.Unit__c;
        lineWrap.deliveryCollDate=String.valueOf(ordLine.Delivery_Collection_Date__c);
        lineWrap.materialNumber=ordLine.MaterialNumber__c;
        lineWrap.materialName=ordLine.Material_Name__c;
        lineWrapList.add(lineWrap);
        System.runas(listofusers[0]){
        test.startTest();
        TCP_HomePageController.getAccountDataOfEndUser();
       TCP_HomePageController.getAccountDetails();
        TCP_HomePageController.getAccountDetailsOfComOps(listofusers[0]);
        TCP_HomePageController.loggedInAsTcpUser();
        TCP_HomePageController.getAccountId();
        TCP_HomePageController.getAccDetailsByParentId(acc.Id);
        TCP_HomePageController.getCustomerByAccountId(acc.Id);
        TCP_HomePageController.getProductDetails(acc.ParentId, acc.Id);
        TCP_HomePageController.getProductDetailsBySearchKey('searchKey', acc.ParentId, acc.Id);//Need check for searchKey
        TCP_HomePageController.getPickListValues('Order', 'Mode_of_Transport__c');
        TCP_HomePageController.getCountOfOrders(acc.Id, 'Draft');
        TCP_HomePageController.getCountOfOrdersEU(acc.ParentId);
        TCP_HomePageController.getCountOfOrdersCU(acc.ParentId);
        TCP_HomePageController.saveOrderLineItems(lineWrapList, ord.Id);
        TCP_HomePageController.getOrderedByUserId();
        TCP_HomePageController.getAllProductDetailsBySoldToId(acc.Id);
        TCP_HomePageController.getCustomerBySoldToAndType(acc.ParentId, 'Sold To');
        TCP_HomePageController.getOrderedBySoldToId(acc.ParentId);
        TCP_HomePageController.getOrderNumberOnSave(wrap,lineWrapList,null,false);
        
        Test.stopTest();
        }
       
    }
    
    @isTest
    static void NegativeTestCase(){
        string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
         List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
        Account acc=[select id, ParentId,recordtype.id, name from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpOrderRecTypeid;
        update acc;
        Order ord=[select  id,Name, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from order where Sold_To__c=:acc.Id limit 1];
        TCP_OrderLineItem__c ordLine=[Select Id, Order__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        
        List<Account_Contact_Relationship__c>  acrRecList=[select id, account__c,Portal_User_Contact__c from Account_Contact_Relationship__c where account__c=:acc.id limit 1];
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
         TCP_OrderWrapper wrap=new TCP_OrderWrapper();
        wrap.id=ord.Id;
        wrap.name=ord.Name;
        wrap.orderNumber=ord.OrderNumber;
        wrap.poNumber=ord.PoNumber;
        wrap.otherInstructions=ord.Order_Other_Instructions__c;
        wrap.modeOfTransport=ord.Mode_of_Transport__c;
        wrap.deliveryTerms=ord.Delivery_Terms__c;
        wrap.status=ord.Status;
        wrap.soldToId=acc.Id;
        TCP_OrderLineItemWrapper lineWrap=new TCP_OrderLineItemWrapper();
        lineWrap.Id=ordLine.Id;
        lineWrap.orderId=ordLine.Order__c;
        lineWrap.quantity=String.valueOf(ordLine.Quantity__c);
        lineWrap.unit=ordLine.Unit__c;
        lineWrap.deliveryCollDate=String.valueOf(ordLine.Delivery_Collection_Date__c);
        lineWrap.materialNumber=ordLine.MaterialNumber__c;
        lineWrap.materialName=ordLine.Material_Name__c;
        lineWrapList.add(lineWrap);
        System.runas(listofusers[0]){
        test.startTest();
        TCP_HomePageController.getAccountDataOfEndUser();
       	TCP_HomePageController.getAccountDetails();
        TCP_HomePageController.getAccountDetailsOfComOps(listofusers[0]);
        TCP_HomePageController.loggedInAsTcpUser();
        TCP_HomePageController.getAccountId();
        TCP_HomePageController.getAccDetailsByParentId('acc.ParentId');
        TCP_HomePageController.getCustomerByAccountId('acc.Id');
        TCP_HomePageController.getProductDetails('acc.ParentId', 'acc.Id');
        TCP_HomePageController.getProductDetailsBySearchKey('searchKey', 'acc.ParentId', 'acc.Id');//Need check for searchKey
        TCP_HomePageController.getPickListValues('Order', 'Mode_of_Transport__c');
        TCP_HomePageController.getCountOfOrders('acc.Id', 'Draft');
        TCP_HomePageController.getCountOfOrdersEU('acc.ParentId');
        TCP_HomePageController.getCountOfOrdersCU('acc.ParentId');
        TCP_HomePageController.saveOrderLineItems(lineWrapList, ord.Id);
        TCP_HomePageController.getOrderedByUserId();
        TCP_HomePageController.getAllProductDetailsBySoldToId('acc.ParentId');
        TCP_HomePageController.getCustomerBySoldToAndType('acc.ParentId', 'Sold To');
        TCP_HomePageController.getOrderedBySoldToId('acc.ParentId');
        TCP_HomePageController.getOrderNumberOnSave(wrap,lineWrapList,null,false);
        
        Test.stopTest();
        }
       
    }
    
    	@isTest
        public static void testGetOrderedBySoldToId(){
            Account acc=[select id, ParentId,recordtype.id, name from account where name='SampleAccount0' limit 1];
            Order ord=[select  id,Name, AccountId, OrderNumber, Ordered_By__c, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from order where Sold_To__c=:acc.Id limit 1];
            ord.Ordered_By__c = userInfo.getUserId();
            update ord;
            System.debug('sold to c print:'+ord.Sold_To__c);
            Test.startTest();
            	TCP_HomePageController.getOrderedBySoldToId(acc.Id);
            Test.stopTest();
        }

}