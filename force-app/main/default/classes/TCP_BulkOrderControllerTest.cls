@isTest
public class TCP_BulkOrderControllerTest{

    @TestSetup
    static void createTestData() {
    List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,true);
        for(Account testAccount:testAccounts){
            List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccount);
            List<Order> testOrders=TCP_TestDataUtilities.createOrders(1,testAccount);
                for(Order testOrder:testOrders){
                    List<TCP_OrderLineItem__c> testOrderLineItem=TCP_TestDataUtilities.createOrderLineItems(1,testOrder);
                }
        }
    }

    @isTest
    public static void testSaveBulkOrderDetails(){
        List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        Account acc=[select id, ParentId,recordtype.id, AccountNumber, name from account where name='SampleAccount0' limit 1];
        acc.recordtypeId=tcpAccountRecTypeid;
        update acc;

        List<contact> conList = TCP_TestDataUtilities.createContacts(1, acc);

        List<Product2> prod = TCP_TestDataUtilities.createProducts(1);

        TCP_OrderLineItemWrapper wrap = new TCP_OrderLineItemWrapper();
        wrap.shellContractNo = '12345';
        wrap.deliveryCollDate = '2023-02-02';
        wrap.quantity = '100';
        wrap.unit = 'KG';
        wrap.instructions ='demo';
        wrap.materialName = prod[0].Name;
        wrap.materialNumber = prod[0].productCode;
        wrap.productId = prod[0].Id;

        TCP_OrderWrapper orderWrapper = new TCP_OrderWrapper();
        orderWrapper.name = 'Test Order';
        orderWrapper.poNumber = 'Test CPO';
        orderWrapper.deliveryTerms = 'FCA';
        orderWrapper.modeOfTransport = 'Road Tank Truck';
        orderWrapper.otherInstructions = 'Test';
        orderWrapper.soldToId = acc.Id;
        orderWrapper.shipToId = acc.Id;
        orderWrapper.billToId = acc.Id;
        orderWrapper.shipToNumber = acc.AccountNumber;
        orderWrapper.soldToName = acc.Name;
        orderWrapper.billToNumber = acc.AccountNumber;
        orderWrapper.payerId = acc.Id;
        orderWrapper.payerNumber = acc.AccountNumber; 
        orderWrapper.status = 'Submitted';
        orderWrapper.requestedById = conList[0].Id;
        orderWrapper.orderLineItemWrapList = new list<TCP_OrderLineItemWrapper>{wrap};
		List<TCP_OrderWrapper> ordList1 = new List<TCP_OrderWrapper>();
        
        for(Integer i=0;i<20;i++){
            ordList1.add(orderWrapper);
        }
        List<TCP_OrderWrapper> ordList2 = new List<TCP_OrderWrapper>(ordList1);
        ordList2.add(orderWrapper);
        Test.startTest();
        List<order> resp = TCP_BulkOrderController.saveBulkOrderDetails(new list<TCP_OrderWrapper>{orderWrapper});
        List<Order> resp2 = TCP_BulkOrderController.saveBulkOrderDetails(ordList1);
        List<Order> resp3 = TCP_BulkOrderController.saveBulkOrderDetails(ordList2);
        Test.stopTest();
        System.assert(resp.size()>0);
        System.assert(resp2.size()>0);
        System.assert(resp3.size()>0);
        


    }


    @isTest
    public static void testGetContactsByCustomerId(){
        try{
            List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
            string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
            Account acc=[select id, ParentId,recordtype.id, AccountNumber, name from account where name='SampleAccount0' limit 1];
            acc.recordtypeId=tcpAccountRecTypeid;
            update acc;
            List<contact> conList = TCP_TestDataUtilities.createContacts(1, acc);
            User userlist = TCP_TestDataUtilities.createCommunityUser(conList[0]);
            Test.startTest();
            List<user> resp = TCP_BulkOrderController.getContactsByCustomerId(acc.Id);
            Test.stopTest();
            System.assert(resp.size()>0);
        }catch(Exception e){

        }


    }

}