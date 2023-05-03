/**************************************************************************************************************************
 * Application  :   Trading and Supply Customer Portal (TCP)
 * Description  :   Test class for TCP_OrderController.
***************************************************************************************************************************/
@isTest(SeeAllData=false)
public class TCP_OrderControllerTest {

@TestSetup
static void createTestData() {
    List<User> listofusers=new List<user>();
    system.debug('Checking1' + listofusers);
     List<Account> testAccounts=new List<Account>();
      User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        
        testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c,Email,Name from contact limit 1]);
       	listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        }
            System.runAs(listofusers[0]) {
                 List<Order> testOrders=TCP_TestDataUtilities.createOrders(1,testAccounts[0]);
           		 List<TCP_OrderLineItem__c> testOrderLineItem=TCP_TestDataUtilities.createOrderLineItems(1,testOrders[0]);
            
              }
}
    
@isTest 
static void generatePDFTest() {
       List<Order> testOrderRec=new List<Order>([select id,ordernumber,Accountid from order limit 1]);
       Test.startTest();
       String positiveData=TCP_OrderController.generatePDF(testOrderRec[0].ordernumber,testOrderRec[0].Accountid);
       String NegativeData=TCP_OrderController.generatePDF(null,null);
       String NegativeData2=TCP_OrderController.generatePDF(testOrderRec[0].ordernumber,'randomValue');
       Test.stopTest();
       System.assertEquals(True, !string.isBlank(positiveData)?true:false);
       System.assertEquals(True, string.isBlank(NegativeData)?true:false);
       System.assertEquals(True, string.isBlank(NegativeData2)?true:false);
    }

@isTest 
static void getOrderReportEU() {
       List<Order> testOrderRecords=new List<Order>([select id,ordernumber,Accountid from order]);
       List<String> orderNumbers=new List<String>();
       for(order o:testOrderRecords){
            orderNumbers.add(o.ordernumber);
       }
       Test.startTest();
       List<TCP_OrderWrapper> positiveData=TCP_OrderController.getOrderEUReport(testOrderRecords[0].Accountid, orderNumbers);
       List<TCP_OrderWrapper> NegativeData=TCP_OrderController.getOrderEUReport(null,null);
       List<TCP_OrderWrapper> NegativeData2=TCP_OrderController.getOrderEUReport(testOrderRecords[0].Accountid,null);
       Test.stopTest();
       System.assertEquals(True, !positiveData.isEmpty()?true:false);
       System.assertEquals(null, NegativeData);
       System.assertEquals(null, NegativeData2);
    }


@isTest 
static void getOrderReportCU() {
       List<Order> testOrderRecords=new List<Order>([select id,ordernumber,Accountid from order]);
       List<String> orderNumbers=new List<String>();
       for(order o:testOrderRecords){
            orderNumbers.add(o.ordernumber);
       }
       Test.startTest();
       List<TCP_OrderWrapper> positiveData=TCP_OrderController.getOrderCUReport(testOrderRecords[0].Accountid, orderNumbers);
       List<TCP_OrderWrapper> NegativeData=TCP_OrderController.getOrderCUReport(null,null);
       List<TCP_OrderWrapper> NegativeData2=TCP_OrderController.getOrderCUReport(testOrderRecords[0].Accountid,null);
       Test.stopTest();
       System.assertEquals(True, !positiveData.isEmpty()?true:false);
       System.assertEquals(null, NegativeData);
       System.assertEquals(null, NegativeData2);
    }
    
    @isTest
	public static void testGetOrderDetailsBySoldToIdCU(){
    	List<Order> ordData =new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        Test.startTest();
        List<TCP_OrderWrapper> resp = TCP_OrderController.getOrderDetailsBySoldToIdCU(ordData[0].Accountid, 'Current Orders');
        List<TCP_OrderWrapper> resp1 = TCP_OrderController.getOrderDetailsBySoldToIdCU(ordData[0].Accountid, 'Order History');
		Test.stopTest();
        System.assert(resp.size()>0);
    }
    
    @isTest
	public static void testGetOrderDetailsBySoldToIdEU(){
    	List<Order> ordData =new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        Test.startTest();
        List<TCP_OrderWrapper> resp = TCP_OrderController.getOrderDetailsBySoldToIdEU(ordData[0].Accountid, 'Previous Orders');
		Test.stopTest();
        System.assert(resp.size()>0);
    }
    
    @isTest
	public static void testGetOrderLineItemsByOrderId(){
    	List<Order> ordData =new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        List<TCP_OrderLineItem__c> ordLineList = TCP_TestDataUtilities.createOrderLineItems(2, ordData[0]);
        Test.startTest();
        List<TCP_OrderLineItem__c> resp = TCP_OrderController.getOrderLineItemsByOrderId(ordData[0].Id);
        Test.stopTest();
		System.assert(resp.size()>0);
    }
   
    @isTest
	public static void testUpdateOrderGSAPReviewDetails(){
    	List<Order> ordData =new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        TCP_OrderWrapper ordWrap = new TCP_OrderWrapper();
        ordWrap.id = ordData[0].Id;
        ordWrap.status = 'Approved';
        //ordWrap.isThirdParty = true;
        ordWrap.isChemicalGSAP= true;
        ordWrap.isRushOrder = true;
        ordWrap.isLateOrder = true;
        ordWrap.isLastMinute = true;
        ordWrap.remarks = 'Approved the Order';
        Test.startTest();
        Order resp = TCP_OrderController.updateOrderReviewDetails(ordWrap);
        Test.stopTest();
        System.debug('Order response:'+resp);
		System.assertEquals(ordWrap.status, resp.TCP_Order_Status__c);
    }
    
    @isTest
	public static void testUpdateOrderRejectReviewDetails(){
    	List<Order> ordData =new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        TCP_OrderWrapper ordWrap = new TCP_OrderWrapper();
        ordWrap.id = ordData[0].Id;
        ordWrap.status = 'Rejected';
        ordWrap.isRushOrder = true;
        ordWrap.isLateOrder = true;
        ordWrap.isLastMinute = true;
        ordWrap.remarks = 'Reject the Order';
        Test.startTest();
        Order resp = TCP_OrderController.updateOrderReviewDetails(ordWrap);
        Test.stopTest();
        System.debug('Order response:'+resp);
		System.assertEquals(ordWrap.status, resp.TCP_Order_Status__c);
    }
    
    @isTest
	public static void testUpdateOrder3rdPartyRejectReviewDetails(){
    	List<Order> ordData =new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        TCP_OrderWrapper ordWrap = new TCP_OrderWrapper();
        ordWrap.id = ordData[0].Id;
        ordWrap.status = 'Approved';
        ordWrap.isThirdParty = true;
        ordWrap.isRushOrder = true;
        ordWrap.isLateOrder = true;
        ordWrap.isLastMinute = true;
        ordWrap.remarks = 'Approve the Order';
        Test.startTest();
        Order resp = TCP_OrderController.updateOrderReviewDetails(ordWrap);
        Test.stopTest();
        System.debug('Order response:'+resp);
		System.assertEquals(ordWrap.status, resp.TCP_Order_Status__c);
    }
    
    @isTest
	public static void testGetOrderDetailsByWONumber(){
    	List<Order> ordData =new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        List<TCP_OrderLineItem__c> ordLineList = TCP_TestDataUtilities.createOrderLineItems(2, ordData[0]);
        Test.startTest();
        List<TCP_OrderWrapper> resp = TCP_OrderController.getOrderDetailsByWONumber(ordData[0].ordernumber);
        Test.stopTest();
		System.assert(resp.size()>0);
    }
    
    @isTest
	public static void testGetOrderDetailsByFilter(){
    	Order ordData = TCP_TestDataUtilities.createOrderWithGSAPData('Approved');
        List<Product2> prodList = TCP_TestDataUtilities.createProducts(1);
        List<TCP_OrderLineItem__c> ordLineList = TCP_TestDataUtilities.createOrderLineItems(1, ordData);
        List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
       // List<User> listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        List<User> listofusers = new List<user>();
        listofusers  = [select Id,UserName, Email from user where UserName ='testuserAdminDataUtility@test.com'];
        System.debug('Checking list size '+listofusers.size());
        system.runas(listofusers[0]){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'TCP_Commercial_Operational_Permission_Set'];
        insert new PermissionSetAssignment(AssigneeId = listofusers[0].id, PermissionSetId = ps.Id);
        }   
        System.debug('Checking Id'+ [SELECT AssigneeId FROM PermissionSetAssignment WHERE Assignee.Username='testuserAdminDataUtility@test.com']);
        system.debug('Checking2' + listofusers);
        
        ordLineList[0].Product__c = prodList[0].Id;
        update ordLineList;
        TCP_OrderWrapper ordWrap = new TCP_OrderWrapper();
        TCP_OrderLineItemWrapper ordLineWrap = new TCP_OrderLineItemWrapper();
        ordWrap.soldToId = ordData.Accountid;
        ordWrap.shipToId = ordData.Accountid;
        ordWrap.poNumber = '123123';
        ordWrap.status = 'Submitted;Approved';
        ordWrap.deliveryTerms = 'FCA';
        ordWrap.modeOfTransport = 'Road Tank Truck';
        ordWrap.fullfilledBy = 'ChemicalGSAP';
        ordWrap.orderPriority = 'Rush Order';
        ordLineWrap.dateType = 'DeliveryDate';
        ordLineWrap.fromDate = '2022-12-20';
        ordLineWrap.toDate = '2022-12-31';
        ordLineWrap.productId = prodList[0].Id;
        
        TCP_OrderWrapper ordWrap2 = new TCP_OrderWrapper();
        ordWrap2.soldToId = ordData.Accountid;
        ordWrap2.shipToId = ordData.Accountid;
        ordWrap2.poNumber = '123123';
        ordWrap2.status = '';
        ordWrap2.deliveryTerms = 'FCA';
        ordWrap2.modeOfTransport = 'Road Tank Truck';
        ordWrap2.fullfilledBy = 'ThirdParty';
        ordWrap2.orderPriority = 'Late Order';
    	system.runas(listofusers[0]){
        Test.startTest();
        List<TCP_OrderWrapper> resp = TCP_OrderController.getOrderDetailsByFilter(ordWrap, ordLineWrap,'','End User','Previous Orders');
        List<TCP_OrderWrapper> resp2 = TCP_OrderController.getOrderDetailsByFilter(ordWrap2, ordLineWrap,'Approved','Comm Ops User','Previous Orders');
        Test.stopTest();
        
		//System.assert(resp.size()>0);
       	//System.assertEquals(ordWrap.poNumber, resp[0].poNumber);
        //System.assertEquals(ordWrap.deliveryTerms, resp[0].deliveryTerms);
        //System.assertEquals(ordWrap.modeOfTransport, resp[0].modeOfTransport);
        //System.assert(resp2.size()>0);
        //System.assertEquals(ordWrap2.deliveryTerms, resp2[0].deliveryTerms);
        //System.assertEquals(ordWrap2.modeOfTransport, resp2[0].modeOfTransport);
        }
    }
    
    @isTest
    public static void testValidateMappingReference(){
        try{
            List<account> accList = TCP_TestDataUtilities.createAccounts(1, true);
        	List<Order> ordData= TCP_TestDataUtilities.createOrders(1,accList[0]);
        	List<Product2> prodList = TCP_TestDataUtilities.createProducts(1);
        	List<TCP_OrderLineItem__c> ordLineList = TCP_TestDataUtilities.createOrderLineItems(1, ordData[0]);
        	ordLineList[0].Product__c = prodList[0].Id;
        	update ordLineList;
            Test.startTest();
            String resp = TCP_OrderController.validateMappingReference(ordData[0].Id);
            Test.stopTest();
        	System.assertEquals('Failed', resp);
            
            
        }catch(Exception e){
            
        }
        
    }
    
     @isTest
    public static void testFetchGSAPOrderConfirmationdetails(){
        List<Order> testOrderRec=new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        testOrderRec[0].Chemical_GSAP_P_31__c=true;
        testOrderRec[0].TCP_Order_Status__c='Approved';
        testOrderRec[0].Is_Order_Confirmed__c=false;
        Update testOrderRec;
         
        test.startTest();
        TCP_OrderController.fetchGSAPOrderConfirmationdetails(testOrderRec[0].Accountid);
        test.stopTest();
    }
    
    @isTest
    public static void testfetchGSAPCurrentOrders(){
        List<Order> testOrderRec=new List<Order>([select id,ordernumber,Accountid from order limit 1]);
        testOrderRec[0].Chemical_GSAP_P_31__c=true;
        testOrderRec[0].TCP_Order_Status__c='Approved';
        testOrderRec[0].Is_Order_Confirmed__c=false;
        Update testOrderRec;
         
        test.startTest();
        TCP_OrderController.fetchGSAPCurrentOrders(testOrderRec[0].Accountid);
        test.stopTest();
    }
}