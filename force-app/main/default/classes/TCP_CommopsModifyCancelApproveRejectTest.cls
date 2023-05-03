/**************************************************************************************************************************
 * Application  :   Trading and Supply Customer Portal (TCP)
 * Description  :   Test class for TCP_CommopsModifyCancelApproveReject.
***************************************************************************************************************************/
@isTest(SeeAllData=false)
public class TCP_CommopsModifyCancelApproveRejectTest {

    @TestSetup
    static void createTestData() {
        List<Account> testAccounts=new List<Account>();
        User us=TCP_TestDataUtilities.createAdminUsers();
        System.runAs(us){
        testAccounts=TCP_TestDataUtilities.createAccounts(1,true);
        }
        for(Account testAccount:testAccounts){
            System.runAs(us){
            List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccount);
            }
            List<User> listofusers=new List<User>();
             List<contact> testCons=new List<contact> ([select id,TCP_TandC__c, Email, Name from contact limit 1]);
       	 	     System.runAs(us){
            listofusers=TCP_TestDataUtilities.createcustomerUsers(1, 'TCPCustomerCommunityPlusUser', testCons[0]);
        		
                 }
            System.runAs(listofusers[0]) {
                    
                    //Processing Modification request for submitted and approved orders
                        List<Order> toModifyOrders=TCP_TestDataUtilities.createOrders(1,testAccount);
                        
                        for(Order modifyOrder:toModifyOrders){
                            system.debug('modifyOrder'+modifyOrder);
                            List<TCP_OrderLineItem__c> testOrderLineItem=TCP_TestDataUtilities.createOrderLineItems(1,modifyOrder);
                            List<TCP_OrderLineItem__c> deletedOLI=TCP_TestDataUtilities.createOrderLineItems(1,modifyOrder);
                            List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
                            
                            TCP_OrderWrapper wrap=new TCP_OrderWrapper();
                            wrap.id=modifyOrder.Id;
                            wrap.orderNumber=modifyOrder.OrderNumber;
                            wrap.name='Updated Name';
                            wrap.poNumber='123123';
                            wrap.otherInstructions='Updated Instruction';
                            wrap.modeOfTransport='Rail Road';
                            wrap.deliveryTerms='FCA';
                            wrap.status=modifyOrder.TCP_Order_Status__c;
                           
                            
                            TCP_OrderLineItemWrapper lineWrap=new TCP_OrderLineItemWrapper();
                            lineWrap.Id=testOrderLineItem[0].Id;
                            lineWrap.orderId=testOrderLineItem[0].Order__c;
                            lineWrap.quantity='55';
                            lineWrap.unit='KG';
                            lineWrap.deliveryCollDate=String.valueOf(testOrderLineItem[0].Delivery_Collection_Date__c);
                            lineWrapList.add(lineWrap);
                            
                            //OLI is deleted.
                            List<Id> delOLI=new List<Id>();
                            delOLI.add(deletedOLI[0].id);
                            
                            //Modifying
                            TCP_ChangeCancelOrderController.getOrderNumberOnModify(wrap,lineWrapList,delOLI);
                            }   
                    
            
            			//Processing Cancellation request for submitted and approved orders
                        List<Order> toCancelOrders=TCP_TestDataUtilities.createOrders(1,testAccount);
                        system.debug(toCancelOrders.size());
                        for(Order cancelOrder:toCancelOrders){
                            system.debug('cancelOrder'+cancelOrder);
                            List<TCP_OrderLineItem__c> testOrderLineItem=TCP_TestDataUtilities.createOrderLineItems(2,cancelOrder);
                            cancelOrder.TCP_Order_Status__c='Approved (C)'; 
                            cancelOrder.TCP_Cancellation_Requested_By__c=listofusers[0].id;
                            
                        }
                       Update toCancelOrders;
                     
                    } 
            
        }
        
        List<order> testOrdersListAfter=new List<order>([select id,ordernumber,Accountid,TCP_Order_Status__c from order]);
        for(Order o:testOrdersListAfter){
            system.debug('***'+o);
        }
    }
    
    //Used to mimic a complete flow of modify/cancel's approval and rejection.
    @isTest 
        static void approveModificationRequest() {
            
			Order ord=[select id,Name, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where TCP_Order_Status__c='Approved (M)' limit 1];
            ord.Chemical_GSAP_P_31__c=true;
            update ord;
            String ordNum=ord.OrderNumber;
            TCP_OrderWrapper commopswrap=new TCP_OrderWrapper();
            commopswrap.orderNumber=ord.OrderNumber;
            commopswrap.isRushOrder=true;
            commopswrap.isLateOrder=true;
            commopswrap.isLastMinute=true;
            commopswrap.id=ord.id;
            commopswrap.modifyCommopsRemarks='test Remarks';
            
            test.startTest();
            
            //Modify Placed
            List<Order> euModifyPlaced1=[select OrderNumber, TCP_Order_Status__c from order where OrderNumber=:ordNum];
            system.Assertequals('Approved (M)',euModifyPlaced1[0].TCP_Order_Status__c);
            
            //Modification Approved
            TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsApproval(commopswrap);
            List<Order> modApprovedOrderList=[select OrderNumber,Name,Description,Sold_To__c,Delivery_Terms__c,Sales_Order_Number__c,PoNumber,Order_Other_Instructions__c,GSAP_Status__c,Remarks__c,Mode_of_Transport__c,
                              TCP_Order_Status__c,Customer_Name__c, (select id, Name,Quantity__c, Product__r.Name,Unit__c, TCP_Modify_Cancel_Status__c,Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from order where OrderNumber=:ordNum];
            system.Assertequals('Approved',modApprovedOrderList[0].TCP_Order_Status__c);   
            Order toBeModifiedOrder=modApprovedOrderList[0];
            system.debug('errorLogmodApproved'+toBeModifiedOrder.order_line_items__r[0]);
            
            //Modification Placed
            ModifyCancelRequest(True, False,modApprovedOrderList[0],toBeModifiedOrder.order_line_items__r[0],null);
			List<Order> euModifyPlaced2=[select OrderNumber, TCP_Order_Status__c from order where OrderNumber=:ordNum];
            Order euModify2=euModifyPlaced2[0];
            system.Assertequals('Approved (M)',euModifyPlaced2[0].TCP_Order_Status__c);
			            
             List<Order> errorLogmodPlaced=[select OrderNumber,Name,Description,Sold_To__c,Delivery_Terms__c,Sales_Order_Number__c,PoNumber,Order_Other_Instructions__c,GSAP_Status__c,Remarks__c,Mode_of_Transport__c,
                              TCP_Order_Status__c,Customer_Name__c, (select id, Name,Quantity__c, Product__r.Name,Unit__c, TCP_Modify_Cancel_Status__c,Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from order where OrderNumber=:ordNum];
            system.debug('errorLogmodPlaced'+errorLogmodPlaced[0].order_line_items__r[0]);
            
            
            //Modification Rejected
            TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsRejection(commopswrap);
            List<Order> modRejectedOrderList=[select OrderNumber,Name,Description,Sold_To__c,Delivery_Terms__c,Sales_Order_Number__c,PoNumber,Order_Other_Instructions__c,GSAP_Status__c,Remarks__c,Mode_of_Transport__c,
                              TCP_Order_Status__c,Customer_Name__c, (select id, Name,Quantity__c, Product__r.Name,Unit__c, TCP_Modify_Cancel_Status__c,Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from order where OrderNumber=:ordNum];
            system.Assertequals('Approved',modRejectedOrderList[0].TCP_Order_Status__c);
            Order toBeCancelledOrder1=modRejectedOrderList[0];
            system.debug('errorLogModRej'+toBeCancelledOrder1.order_line_items__r[0]);
            
            //Cancellation Placed
            ModifyCancelRequest(False, true,modRejectedOrderList[0],null,null);
            List<Order> euCancelPlaced1=[select OrderNumber, TCP_Order_Status__c from order where OrderNumber=:ordNum];
            system.Assertequals('Approved (C)',euCancelPlaced1[0].TCP_Order_Status__c);
            
            List<Order> errorLog=[select OrderNumber,Name,Description,Sold_To__c,Delivery_Terms__c,Sales_Order_Number__c,PoNumber,Order_Other_Instructions__c,GSAP_Status__c,Remarks__c,Mode_of_Transport__c,
                              TCP_Order_Status__c,Customer_Name__c, (select id, Name,Quantity__c, Product__r.Name,Unit__c, TCP_Modify_Cancel_Status__c,Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from order where OrderNumber=:ordNum];
            system.debug('errorLog'+errorLog[0].order_line_items__r[0]);
             
            //Cancellation Rejected
            TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsCancellationRejection(commopswrap);
            List<Order> canRejectedOrderList=[select OrderNumber,Name,Description,Sold_To__c,Delivery_Terms__c,Sales_Order_Number__c,PoNumber,Order_Other_Instructions__c,GSAP_Status__c,Remarks__c,Mode_of_Transport__c,
                              TCP_Order_Status__c,Customer_Name__c, (select id, Name,Quantity__c, Product__r.Name,Unit__c, TCP_Modify_Cancel_Status__c,Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from order where OrderNumber=:ordNum];
            system.Assertequals('Approved',canRejectedOrderList[0].TCP_Order_Status__c);
            Order toBeCancelledOrder2=canRejectedOrderList[0];
           
            //Cancellation Placed
            ModifyCancelRequest(False, true,canRejectedOrderList[0],null,null);
            List<Order> euCancelPlaced2=[select OrderNumber, TCP_Order_Status__c from order where OrderNumber=:ordNum];
            system.Assertequals('Approved (C)',euCancelPlaced2[0].TCP_Order_Status__c);
            
            //Cancellation Approved
			TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsCancellationApproval(commopswrap);
            List<Order> canApprovedOrderList=[select OrderNumber,Name,Description,Sold_To__c,Delivery_Terms__c,Sales_Order_Number__c,PoNumber,Order_Other_Instructions__c,GSAP_Status__c,Remarks__c,Mode_of_Transport__c,
                              TCP_Order_Status__c,Customer_Name__c, (select id, Name,Quantity__c, Product__r.Name,Unit__c, TCP_Modify_Cancel_Status__c,Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from order where OrderNumber=:ordNum];
            system.Assertequals('Cancelled',canApprovedOrderList[0].TCP_Order_Status__c);
            
		 test.stopTest();
        }
    
    @isTest 
        static void rejectModificationRequest() {
			Order ord=[select id,Name,TCP_Latest_Approved_Modify_Cancel__c, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where TCP_Order_Status__c='Approved (M)' limit 1];
           
            
            TCP_OrderWrapper commopswrap=new TCP_OrderWrapper();
            commopswrap.orderNumber=ord.OrderNumber;
            commopswrap.modifyCommopsRemarks='test Rejection Remarks';
            test.startTest();
            Order respOrder=TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsRejection(commopswrap);
            system.Assertequals('Approved',respOrder.TCP_Order_Status__c);
		 	test.stopTest();
        }
    
    @isTest 
        static void Approve3rdPartyModificationRequest() {
			Order ord=[select id,Name,Third_Party__c,TCP_Latest_Approved_Modify_Cancel__c, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where TCP_Order_Status__c='Approved (M)' limit 1];
            ord.Third_Party__c=true;
            update ord;
            
            TCP_OrderWrapper commopswrap=new TCP_OrderWrapper();
            commopswrap.orderNumber=ord.OrderNumber;
            commopswrap.modifyCommopsRemarks='test Rejection Remarks';
            test.startTest();
            Order respOrder=TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsApproval(commopswrap);
            system.Assertequals('Approved',respOrder.TCP_Order_Status__c);
		 	test.stopTest();
        }
  
     @isTest  
        static void approveCancellationRequest() {
			Order ord=[select id,Name,TCP_Latest_Approved_Modify_Cancel__c, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where TCP_Order_Status__c='Approved (C)' limit 1];
            ord.Chemical_GSAP_P_31__c=true;
            update ord;
            
            TCP_OrderWrapper commopswrap=new TCP_OrderWrapper();
            commopswrap.orderNumber=ord.OrderNumber;
            commopswrap.cancelCommopsRemarks='test Approval Remarks';
            commopswrap.id=ord.id;
            test.startTest();
            Order respOrder=TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsCancellationApproval(commopswrap);
			system.Assertequals('Cancelled',respOrder.TCP_Order_Status__c);
		 	test.stopTest();
        }
    
     @isTest  
        static void RejectCancellationRequest() {
			Order ord=[select id,Name,TCP_Latest_Approved_Modify_Cancel__c, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where TCP_Order_Status__c='Approved (C)' limit 1];
            ord.Third_Party__c=true;
            update ord;
            
            TCP_OrderWrapper commopswrap=new TCP_OrderWrapper();
            commopswrap.orderNumber=ord.OrderNumber;
            commopswrap.cancelCommopsRemarks='test Rejection Remarks';
            commopswrap.id=ord.id;
            test.startTest();
            Order respOrder=TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsCancellationRejection(commopswrap);
			system.Assertequals('Approved',respOrder.TCP_Order_Status__c);
		 	test.stopTest();
        }
    
     @isTest  
        static void RejectCancellationWithChangeRequest() {
			Order ord=[select id,Name,TCP_Latest_Approved_Modify_Cancel__c, AccountId, OrderNumber, Sold_To__c, Ship_To__c, EffectiveDate, poNumber, Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status from Order where TCP_Order_Status__c='Approved (C)' limit 1];
            List<TCP_Change_Cancel_Request__c> createdChnOrd=TCP_TestDataUtilities.createChangeOrders(1,ord);
             ord.TCP_Latest_Approved_Modify_Cancel__c=createdChnOrd[0].id;    
        
            update ord;
            
            TCP_OrderWrapper commopswrap=new TCP_OrderWrapper();
            commopswrap.orderNumber=ord.OrderNumber;
            commopswrap.cancelCommopsRemarks='test Rejection Remarks';
            commopswrap.id=ord.id;
            test.startTest();
            Order respOrder=TCP_CommopsModifyCancelApproveReject.getOrderOnCommopsCancellationRejection(commopswrap);
			system.Assertequals('Approved',respOrder.TCP_Order_Status__c);
		 	test.stopTest();
        }
    
    static void ModifyCancelRequest(boolean Modify, boolean Cancel, Order modifyCancelOrder,TCP_OrderLineItem__c testOrderLineItem,TCP_OrderLineItem__c deleteOLIItem){
       	List<User> testUsers=new List<User> ([select id from User where username='testuser2@test.com0' limit 1]);
        System.runAs(testUsers[0]) {	 
        If(Modify){
                TCP_OrderWrapper wrap=new TCP_OrderWrapper();
                wrap.id=modifyCancelOrder.Id;
                wrap.orderNumber=modifyCancelOrder.OrderNumber;
                wrap.name='Updated Name';
                wrap.poNumber='123123';
                wrap.otherInstructions='Updated Instruction';
                wrap.modeOfTransport='Rail Road';
                wrap.deliveryTerms='FCA';
                wrap.status=modifyCancelOrder.TCP_Order_Status__c;
                
                List<TCP_OrderLineItemWrapper> lineWrapList=new List<TCP_OrderLineItemWrapper>();
                TCP_OrderLineItemWrapper lineWrap=new TCP_OrderLineItemWrapper();
                lineWrap.Id=testOrderLineItem.Id;
                lineWrap.orderId=testOrderLineItem.Order__c;
                lineWrap.quantity='55';
                lineWrap.unit='KG';
                lineWrap.deliveryCollDate=String.valueOf(testOrderLineItem.Delivery_Collection_Date__c);
                lineWrapList.add(lineWrap);
                
                //OLI is deleted.
                List<Id> delOLI=new List<Id>();
                if(deleteOLIItem!=null){
                    delOLI.add(deleteOLIItem.id);
                }
                //Modifying
                TCP_ChangeCancelOrderController.getOrderNumberOnModify(wrap,lineWrapList,delOLI);
        }
        If(Cancel){
                TCP_OrderWrapper wrap=new TCP_OrderWrapper();
                wrap.id=modifyCancelOrder.Id;
                wrap.orderNumber=modifyCancelOrder.OrderNumber;
                //Cancelling
                TCP_ChangeCancelOrderController.getOrderId(wrap);
        }
    }
    }
}