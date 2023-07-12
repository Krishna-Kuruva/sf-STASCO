@isTest
public class TCP_ResendOrderControllerTest {
    
    @TestSetup
    static void createTestData() {       
    	List<Account> accList = TCP_TestDataUtilities.createAccounts(1, true);
        List<Order> ordList = TCP_TestDataUtilities.createOrders(1, accList[0]);
        TCP_TestDataUtilities.createOrderLineItems(2, ordList[0]); 
    }
    
    @isTest
    public static void testReProcessFailedGsapOrder1(){
        List<order> ordList = [SELECT id,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r) from Order];
        ordList[0].GSAP_Status__c ='Processed';
        update ordList;
        Test.startTest();
        String resp = TCP_ResendOrderController.reProcessFailedGsapOrder(ordList[0].Id);
        Test.stopTest();
        System.assert(resp!=null);
    }
    
    @isTest
    public static void testReProcessFailedGsapOrder2(){
        List<order> ordList = [SELECT id,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r) from Order];
        Test.startTest();
        String resp = TCP_ResendOrderController.reProcessFailedGsapOrder(ordList[0].Id);
        Test.stopTest();
        System.assert(resp!=null);
    }
    
    @isTest
    public static void testReProcessFailedGsapOrder3(){
        List<order> ordList = [SELECT id,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r) from Order];
        ordList[0].GSAP_Status__c ='Sent';
        update ordList;
        Test.startTest();
        String resp = TCP_ResendOrderController.reProcessFailedGsapOrder(ordList[0].Id);
        Test.stopTest();
        System.assert(resp!=null);
    }
    
    @isTest
    public static void testReProcessFailedGsapOrder4(){
        List<order> ordList = [SELECT id,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r) from Order];
        ordList[0].GSAP_Status__c ='Resent';
        update ordList;
        Test.startTest();
        String resp = TCP_ResendOrderController.reProcessFailedGsapOrder(ordList[0].Id);
        Test.stopTest();
        System.assert(resp!=null);
    }
    
    @isTest
    public static void testReProcessFailedGsapOrder5(){
        List<order> ordList = [SELECT id,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r) from Order];
        ordList[0].TCP_Order_Status__c ='Approved (M)';
        ordList[0].GSAP_Status__c ='Failed To Process';
        update ordList;
        Test.startTest();
        String resp = TCP_ResendOrderController.reProcessFailedGsapOrder(ordList[0].Id);
        Test.stopTest();
        System.assert(resp!=null);
    }
    
    @isTest
    public static void testReProcessFailedGsapOrder6(){
        List<order> ordList = [SELECT id,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r) from Order];
        ordList[0].TCP_Order_Status__c ='Cancelled';
        ordList[0].GSAP_Status__c ='Failed To Process';
        ordList[0].Sales_Order_Number__c ='1234';
        System.debug('===>orderline'+ordList[0].order_line_items__r);
        update ordList;
        Test.startTest();
        String resp = TCP_ResendOrderController.reProcessFailedGsapOrder(ordList[0].Id);
        Test.stopTest();
        System.assert(resp!=null);
    }
    
    @isTest
    public static void testReProcessFailedGsapOrder7(){
        List<order> ordList = [SELECT id,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r) from Order];
        ordList[0].TCP_Order_Status__c ='Approved';
        ordList[0].GSAP_Status__c ='Failed To Process';
        ordList[0].Sales_Order_Number__c ='';
        update ordList;
        Test.startTest();
        String resp = TCP_ResendOrderController.reProcessFailedGsapOrder(ordList[0].Id);
        Test.stopTest();
        System.assert(resp!=null);
    }
    
    @isTest
    public static void testReProcessFailedGsapOrderNegative(){
       
        Test.startTest();
        TCP_ResendOrderController.reProcessFailedGsapOrder(null);
        Test.stopTest();
    }
}