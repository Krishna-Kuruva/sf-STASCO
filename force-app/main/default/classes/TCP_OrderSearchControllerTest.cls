@isTest
public class TCP_OrderSearchControllerTest{

    @TestSetup
    public static void createTestData() {
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        for(Account testAccount:testAccounts){
            TCP_TestDataUtilities.createContacts(1,testAccount);
            List<Order> testOrders=TCP_TestDataUtilities.createOrders(1,testAccount);
                for(Order testOrder:testOrders){
                    TCP_TestDataUtilities.createOrderLineItems(1,testOrder);
                }
        }
    }
    @isTest
    public static void testGetOrderDetailsBySearchKey(){
       
        List<Order> testOrderRec=new List<Order>([select id,ordernumber,Name,Sold_To__c,TCP_Order_Status__c,Accountid from order where TCP_Order_Status__c ='Submitted' limit 1]);
        List<string> soldToIds=new List<string>();
        soldToIds.add(testOrderRec[0].Sold_To__c);
        Test.startTest();
        List<TCP_OrderWrapper> resp = TCP_OrderSearchController.getOrderDetailsBySearchKey(soldToIds,testOrderRec[0].Name,'Draft;Submitted','Comm Ops User','Previous Orders');
        List<TCP_OrderWrapper> resp2 = TCP_OrderSearchController.getOrderDetailsBySearchKey(soldToIds,testOrderRec[0].Name,'Submitted','End User','Previous Orders');
        Test.stopTest();
        System.Assert(resp.size()>0);
        System.Assert(resp2.size()>0);
	
    }
}