/*****************************************************************************************************
ClassName   :   TCP_PlaceOrderConfirmationCtrlTest
Description :   This class is to test code coverage
*****************************************************************************************************/
@isTest
public class TCP_PlaceOrderConfirmationCtrlTest {
@TestSetup
static void createTestData() {
    List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
    for(Account testAccount:testAccounts){
        TCP_TestDataUtilities.createContacts(1,testAccount);
        List<Order> testOrders=TCP_TestDataUtilities.createOrders(1,testAccount);
            for(Order testOrder:testOrders){
           		TCP_TestDataUtilities.createOrderLineItems(1,testOrder);
            }
    }
    TCP_TestDataUtilities.createDocs(1);
}

@isTest 
    static void emailTemplateDataTest() {
       List<Order> testOrderRec=new List<Order> ([select id from order limit 1]);
       List<Document> testDocs=new List<Document> ([select id,name from document where name='Shell Logo1' limit 1]);
       Test.startTest();
       TCP_PlaceOrderConfirmationCtrl templateClass=new TCP_PlaceOrderConfirmationCtrl();
       templateClass.RecordId=testOrderRec[0].id;
       
       list<Order> orderDetails=templateClass.getOrderDetails();
       list<TCP_OrderLineItem__c> orderLineDetails=templateClass.getOrderLIDetails();
       list<TCP_PlaceOrderConfirmationCtrl.ProdWrapper> prodWrapperDetails=templateClass.getProdWrapList();
       Test.stopTest();
       System.assertEquals(1, orderDetails.size());
       System.assertEquals(1, orderLineDetails.size());
       System.assertEquals(1, prodWrapperDetails.size());
    }

}