/*****************************************************************************
* Purpose: Test class for TCP_ChangeCancelOrderController
* Verion : 1.0
* **************************************************************************/
@isTest
public class TCP_ChangeCancelOrderControllerTest {
    
    @TestSetup
    static void createTestData() {
          List<Account> testAccounts=new List<Account>();
        User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<Order> testOrder=TCP_TestDataUtilities.createOrders(1,testAccounts[0]);
        }
    }
    @isTest 
    static void getOrderNumberOnModify() {
        string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
        List<id> ordLineIds=new List<Id>();
        List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order limit 1];
        ord.recordtype.id=tcpOrderRecTypeid;
        update ord;
        List<TCP_OrderLineItem__c> ordLine1=TCP_TestDataUtilities.createOrderLineItems(1,ord);
        List<TCP_Change_Cancel_Request__c> ordIteams=TCP_TestDataUtilities.createChangeOrders(1,ord);
        List<TCP_Change_Cancel_Order_Line_Items__c> ordLineIteams=TCP_TestDataUtilities.createChangeOrdersIteams(1,ordIteams[0]);
        TCP_OrderLineItem__c ordLine=[Select Id, Order__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        
        User us=[Select Id, ContactId from User where Id=:listofusers[0].Id];
        TCP_Change_Cancel_Request__c chOrdIteams=[Select Id, Customer_Name__c, Customer_PO__c, Customer_PO_New__c, Delivery_Terms__c, Delivery_Terms_New__c, Mode_of_Transport__c, Mode_of_Transport_New__c, Other_Instruction__c, Other_Instruction_New__c, Status__c, Type__c, Web_Order__c from TCP_Change_Cancel_Request__c where Web_Order__c=:ord.Id];
        TCP_Change_Cancel_Order_Line_Items__c chOrdLineIteams=[Select Id, Change_Cancel_Request_Order__c, Delivery_Collection_Date__c, Delivery_Collection_Date_New__c, Instruction__c, Instruction_New__c, Item_number__c, Quantity__c, Quantity_New__c, Shell_Contract_No__c, Shell_Contract_No_New__c, Type__c, Unit__c, Unit_New__c from TCP_Change_Cancel_Order_Line_Items__c where Change_Cancel_Request_Order__c=:chOrdIteams.Id];    
        
        TCP_OrderWrapper wrap=new TCP_OrderWrapper();
        wrap.id=ord.Id;
        wrap.name=ord.Name;
        wrap.orderNumber=ord.OrderNumber;
        wrap.poNumber=ord.PoNumber;
        wrap.otherInstructions=ord.Order_Other_Instructions__c;
        wrap.modeOfTransport=ord.Mode_of_Transport__c;
        wrap.deliveryTerms=ord.Delivery_Terms__c;
        wrap.status=ord.TCP_Order_Status__c;
        
        
        TCP_OrderLineItemWrapper lineWrap=new TCP_OrderLineItemWrapper();
        lineWrap.Id=ordLine.Id;
        lineWrap.orderId=ordLine.Order__c;
        lineWrap.quantity=String.valueOf(ordLine.Quantity__c);
        lineWrap.unit=ordLine.Unit__c;
        lineWrap.deliveryCollDate=String.valueOf(ordLine.Delivery_Collection_Date__c);
        lineWrap.materialNumber=ordLine.MaterialNumber__c;
        lineWrap.materialName=ordLine.Material_Name__c;
        lineWrapList.add(lineWrap);
        ordLineIds.add(ordLine.Id);
        System.runas(listofusers[0]){
            test.startTest();
            Order ord1=TCP_ChangeCancelOrderController.getOrderNumberOnModify(wrap, lineWrapList, ordLineIds);
            TCP_ChangeCancelOrderController.getOrderId(wrap);
            test.stopTest();
            System.assertEquals(null, ord1);
        }
    }
    @isTest 
    static void getOrderNumberOnModifyPositive2() {
        string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
        List<id> ordLineIds=new List<Id>();
        List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where TCP_Order_Status__c='Approved' limit 1];
        ord.recordtype.id=tcpOrderRecTypeid;
        update ord;
        List<TCP_OrderLineItem__c> ordLinListe=TCP_TestDataUtilities.createOrderLineItems(1,ord);
        List<TCP_Change_Cancel_Request__c> ordIteams=TCP_TestDataUtilities.createChangeOrders(1,ord);
        List<TCP_Change_Cancel_Order_Line_Items__c> ordLineIteams=TCP_TestDataUtilities.createChangeOrdersIteams(1,ordIteams[0]);
        TCP_OrderLineItem__c ordLine=[Select Id, Order__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
        List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        User us=[Select Id, ContactId from User where Id=:listofusers[0].Id];
        TCP_Change_Cancel_Request__c chOrdIteams=[Select Id, Customer_Name__c, Customer_PO__c, Customer_PO_New__c, Delivery_Terms__c, Delivery_Terms_New__c, Mode_of_Transport__c, Mode_of_Transport_New__c, Other_Instruction__c, Other_Instruction_New__c, Status__c, Type__c, Web_Order__c from TCP_Change_Cancel_Request__c where Web_Order__c=:ord.Id];
        TCP_Change_Cancel_Order_Line_Items__c chOrdLineIteams=[Select Id, Change_Cancel_Request_Order__c, Delivery_Collection_Date__c, Delivery_Collection_Date_New__c, Instruction__c, Instruction_New__c, Item_number__c, Quantity__c, Quantity_New__c, Shell_Contract_No__c, Shell_Contract_No_New__c, Type__c, Unit__c, Unit_New__c from TCP_Change_Cancel_Order_Line_Items__c where Change_Cancel_Request_Order__c=:chOrdIteams.Id];    
        
        TCP_OrderWrapper wrap=new TCP_OrderWrapper();
        wrap.id=ord.Id;
        wrap.name=ord.Name;
        wrap.orderNumber=ord.OrderNumber;
        wrap.poNumber=ord.PoNumber;
        wrap.otherInstructions=ord.Order_Other_Instructions__c;
        wrap.modeOfTransport=ord.Mode_of_Transport__c;
        wrap.deliveryTerms=ord.Delivery_Terms__c;
        wrap.status=ord.TCP_Order_Status__c;
        
        
        TCP_OrderLineItemWrapper lineWrap=new TCP_OrderLineItemWrapper();
        lineWrap.Id=ordLine.Id;
        lineWrap.orderId=ordLine.Order__c;
        lineWrap.quantity=String.valueOf(ordLine.Quantity__c);
        lineWrap.unit=ordLine.Unit__c;
        lineWrap.deliveryCollDate=String.valueOf(ordLine.Delivery_Collection_Date__c);
        lineWrap.materialNumber=ordLine.MaterialNumber__c;
        lineWrap.materialName=ordLine.Material_Name__c;
        lineWrapList.add(lineWrap);
        ordLineIds.add(ordLine.Id);
        System.runas(listofusers[0]){
            test.startTest();
            Order ord1=TCP_ChangeCancelOrderController.getOrderNumberOnModify(wrap, lineWrapList, ordLineIds);
            TCP_ChangeCancelOrderController.getOrderId(wrap);
            test.stopTest();
            System.assertEquals(null, ord1);
        }
    }
    
    
}