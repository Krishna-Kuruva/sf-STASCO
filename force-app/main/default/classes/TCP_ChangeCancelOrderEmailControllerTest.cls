/*****************************************************************************
* Purpose: Test class for TCP_ChangeCancelOrderEmailController
* Verion : 1.0
* ***************************************************************************/
@isTest
public class TCP_ChangeCancelOrderEmailControllerTest {
    @TestSetup
    static void createTestData() {
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<Order> testOrder=TCP_TestDataUtilities.createOrders(1,testAccounts[0]);
        TCP_TestDataUtilities.createOrderLineItems(1,testOrder[0]);
        List<TCP_Change_Cancel_Request__c> ordIteams=TCP_TestDataUtilities.createChangeOrders(1,testOrder[0]);
        TCP_TestDataUtilities.createChangeOrdersIteams(1,ordIteams[0]);
    }
   /* @isTest 
    static void getOrderNumberOnModify() {
        Order ord=[select id,Name, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order limit 1];
        TCP_Change_Cancel_Request__c chOrdIteams=[Select Id, Customer_Name__c, Customer_PO__c, Customer_PO_New__c, Delivery_Terms__c, Delivery_Terms_New__c, Mode_of_Transport__c, Mode_of_Transport_New__c, Other_Instruction__c, Other_Instruction_New__c, Status__c, Type__c, Web_Order__c from TCP_Change_Cancel_Request__c where Web_Order__c=:ord.Id];   
        List<TCP_Change_Cancel_Request__c> chOrdList=new list<TCP_Change_Cancel_Request__c>();
        chOrdList.add(chOrdIteams);
        test.startTest();
        TCP_ChangeCancelOrderEmailController classObj=new TCP_ChangeCancelOrderEmailController(); 
        classObj.RecordId=chOrdIteams.Id;
        //classObj.getChangeProdWrapList();
        test.stopTest();
        system.assert(true);
    }*/
}