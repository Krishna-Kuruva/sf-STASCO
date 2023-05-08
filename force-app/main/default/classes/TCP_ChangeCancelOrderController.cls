public with sharing class TCP_ChangeCancelOrderController {
    public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();

    @AuraEnabled(cacheable=false) 
    public static Order getOrderNumberOnModify(TCP_OrderWrapper orderWrapper, List<TCP_OrderLineItemWrapper> orderLineWrapList, List<Id> deletedProducts){
        List<order> oldorderList=new List<order>();
        List<order> updateorderList=new List<order>();
        list<TCP_OrderLineItem__c> updateOrderLIList=new List<TCP_OrderLineItem__c>();
        list<TCP_OrderLineItem__c> deleteOrderLIList=new List<TCP_OrderLineItem__c>();
        Set<Id> ordIds=new Set<Id>();
        List<TCP_Change_Cancel_Request__c> chOrderlist=new List<TCP_Change_Cancel_Request__c>();
        List<TCP_Change_Cancel_Request__c> updateChOrderlist=new List<TCP_Change_Cancel_Request__c>();
        List<TCP_Change_Cancel_Request__c> checkChOrderlist=new List<TCP_Change_Cancel_Request__c>();
        List<TCP_Change_Cancel_Order_Line_Items__c> chOrdLineIteamList=new List<TCP_Change_Cancel_Order_Line_Items__c>();
        Map<Id,Id> chOrdNewOrdMap=new Map<Id,Id>();
        Set<Id> chOrdIds=new Set<Id>();
        Id changeOrderId;
        Map<Id,String> chOrdNewOrdNameMap=new Map<Id,String>();
        List<TCP_OrderLineItem__c> deletedList=new List<TCP_OrderLineItem__c>();
        try {
            
            //get all order and order line item relavent details from order object with ordernumber from modified order wrapper
            
            if(orderWrapper!= null){
                oldorderList=[select OrderNumber,Name,Description,Sold_To__c,Delivery_Terms__c,Sales_Order_Number__c,PoNumber,Order_Other_Instructions__c,GSAP_Status__c,Remarks__c,Mode_of_Transport__c,
                              TCP_Order_Status__c,Customer_Name__c, (select id, Name,Quantity__c, Product__r.Name,Unit__c, TCP_Modify_Cancel_Status__c,Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r Order By CreatedDate) from order where OrderNumber=:orderWrapper.OrderNumber  and recordtype.id=:tcpOrderRecTypeid];
                
                //create change order object
                
                if(oldorderList!=null){
                    for(Order oldOrder:oldorderList){
                        ordIds.add(oldOrder.Id);   
                    }
                    if(deletedProducts.size()>0){
                        Set<Id> deletedLineItemIds = new Set<Id>(deletedProducts);
                        deletedList=[select id, Name,Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, 
                                     Order__c, Product__c,Product__r.Name, Material_Name__c, MaterialNumber__c from TCP_OrderLineItem__c where Id IN:deletedLineItemIds];
                    }
                    checkChOrderlist=[Select Id,Customer_Name__c,Customer_PO__c,Customer_PO_New__c,Delivery_Terms__c,Delivery_Terms_New__c,Mode_of_Transport__c,Mode_of_Transport_New__c,Order_Name__c,
                                      Order_Name_New__c,Other_Instruction__c,Other_Instruction_New__c,Sales_Order__c,Status__c,Type__c,Web_Order__c from TCP_Change_Cancel_Request__c
                                      where Web_Order__c IN :ordIds AND Status__c='Submitted'];
                    
                    /** Make the status of previous change order as not applicable when the EU modifying 
the order multiple times which is in Approved(M) status **/
                    
                    if(checkChOrderlist.size()>0){
                        for(Order oldOrder:oldorderList){
                            
                            for(TCP_Change_Cancel_Request__c cancelOrder:checkChOrderlist){
                                if(cancelOrder.Web_Order__c==oldOrder.Id){
                                    TCP_Change_Cancel_Request__c updateChOrder=new TCP_Change_Cancel_Request__c();
                                    updateChOrder.Id=cancelOrder.Id;
                                    updateChOrder.Status__c='Not Applicable';
                                    updateChOrderlist.add(updateChOrder);
                                }
                            }
                        }
                        if(updateChOrderlist.size()>0){
                            Database.SaveResult[] results = Database.update(updateChOrderlist, false);
                            
                            for (Database.SaveResult result : results) {
                                if (result.isSuccess()) {
                                    
                                    System.debug('Change Order Successfully Updated, Updated Change Order Id is: ' + result.getId());
                                }
                                else {
                                    
                                    for(Database.Error error : result.getErrors()) {
                                        
                                        System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                                     ' updateChOrderlist Fields that affected the error: ' + error.getFields());
                                        
                                    }
                                }
                            }
                        }
                    }
                }/***End Updated the previous change order status to not applicable **/
                
                /** Insert the change order record **/
                
                for(Order oldOrder:oldorderList){
                    TCP_Change_Cancel_Request__c chOrder=new TCP_Change_Cancel_Request__c();
                    chOrder.Customer_Name__c=oldorder.Customer_Name__c;
                    chOrder.Customer_PO__c =oldorder.PoNumber;
                    chOrder.Customer_PO_New__c=orderWrapper.poNumber;
                    chOrder.Delivery_Terms__c=oldorder.Delivery_Terms__c;
                    chOrder.Delivery_Terms_New__c=orderWrapper.deliveryTerms;
                    chOrder.Mode_of_Transport__c=oldorder.Mode_of_Transport__c;
                    chOrder.Mode_of_Transport_New__c=orderWrapper.modeOfTransport;
                    chOrder.Order_Name__c=oldorder.Name;
                    chOrder.Order_Name_New__c=orderWrapper.name;
                    chOrder.Other_Instruction__c=oldorder.Order_Other_Instructions__c;
                    chOrder.Other_Instruction_New__c=orderWrapper.otherInstructions;
                    Chorder.Sales_Order__c=oldorder.Sales_Order_Number__c;
                    if(oldorder.TCP_Order_Status__c=='Submitted'){
                        Chorder.Status__c='Approved';
                    }
                    else{
                        Chorder.Status__c='Submitted';
                    }
                    chOrder.Type__c='Modification';
                    chOrder.Web_Order__c=oldorder.Id;
                    chOrderlist.add(chOrder);
                    
                }
                
                if(chOrderlist.size()>0){
                    Database.SaveResult[] results = Database.insert(chOrderlist, false);
                    
                    for (Database.SaveResult result : results) {
                        if (result.isSuccess()) {
                            changeOrderId=result.getId();
                            chOrdIds.add(result.getId());
                        }
                        else {
                            
                            for(Database.Error error : result.getErrors()) {
                                
                                System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                             ' chOrderlist Fields that affected the error: ' + error.getFields());
                                
                            }
                        }
                    }
                    /** END Inserted Change Order Record **/
                    
                    
                    /*** Creating Map for orderId and Change Order Id
Map for OrderId and Change Order name **/
                    
                    List<TCP_Change_Cancel_Request__c> insertedChOrderlist=new List<TCP_Change_Cancel_Request__c>();
                    insertedChOrderlist=[Select Id,Web_Order__c, Name from TCP_Change_Cancel_Request__c where Id IN:chOrdIds];
                    for(TCP_Change_Cancel_Request__c ChOrdR:insertedChOrderlist){
                        chOrdNewOrdMap.put(ChOrdR.Web_Order__c,ChOrdR.Id);
                        chOrdNewOrdNameMap.put(ChOrdR.Web_Order__c,ChOrdR.Name);
                    }
                } /** End **/
                
                
                /** create change order line object **/
                
                for(TCP_OrderLineItemWrapper lineWrapper:orderLineWrapList){
                    for(Order oldOrder:oldorderList){
                        for(TCP_OrderLineItem__c OrderLI:oldorder.order_line_items__r){
                            TCP_Change_Cancel_Order_Line_Items__c changeLineItem=new TCP_Change_Cancel_Order_Line_Items__c();
                            System.debug('Checking changLineItem '+OrderLI.id+'  '+lineWrapper.id);
                            if(OrderLI.id==lineWrapper.id){
                                if(OrderLI.Delivery_Collection_Date__c!=null){
                                    changeLineItem.Delivery_Collection_Date__c=OrderLI.Delivery_Collection_Date__c;
                                }
                                if(String.isNotBlank(lineWrapper.deliveryCollDate)){
                                    changeLineItem.Delivery_Collection_Date_New__c=Date.valueOf(lineWrapper.deliveryCollDate);
                                }
                                changeLineItem.Instruction__c=OrderLI.Other_Instruction__c;
                                changeLineItem.Instruction_New__c=lineWrapper.instructions;
                                changeLineItem.Item_number__c=OrderLI.Name;
                                changeLineItem.Product_Name__c=OrderLI.Product__r.Name;
                                changeLineItem.Material_Number__c=OrderLI.MaterialNumber__c;
                                changeLineItem.Quantity__c=OrderLI.Quantity__c;
                                changeLineItem.Quantity_New__c=Decimal.valueOf(lineWrapper.quantity);
                                changeLineItem.Shell_Contract_No__c=OrderLI.Contract_No__c;
                                changeLineItem.Shell_Contract_No_New__c=lineWrapper.shellContractNo;
                                changeLineItem.Type__c='Modification';
                                changeLineItem.Unit__c=OrderLI.Unit__c;
                                changeLineItem.Unit_New__c=lineWrapper.unit;
                                changeLineItem.Change_Cancel_Request_Order__c=chOrdNewOrdMap.get(OrderLI.Order__c);
                                
                                if( (OrderLI.Contract_No__c!=lineWrapper.shellContractNo)||(OrderLI.Delivery_Collection_Date__c!=changeLineItem.Delivery_Collection_Date_New__c) ||(OrderLI.Quantity__c!=changeLineItem.Quantity_New__c) || (OrderLI.Unit__c!=lineWrapper.unit) ||(OrderLI.Other_Instruction__c!=lineWrapper.instructions) ){
                                    if(oldOrder.TCP_Order_Status__c=='Submitted'){
                                        changeLineItem.TCP_Modification_Cancellation_Status__c='Modified';
                                    }
                                }
                                else{
                                    changeLineItem.TCP_Modification_Cancellation_Status__c='No Change';
                                }
                                chOrdLineIteamList.add(changeLineItem);
                            }
                            
                        }
                    }
                }
                
                /** looping to deleted line items to make the quantity as zero and the status to cancelled **/
                
                for(TCP_OrderLineItem__c deletedItem:deletedList){
                    for(Order oldOrder:oldorderList){
                        for(TCP_OrderLineItem__c OrderLI:oldorder.order_line_items__r){
                            TCP_Change_Cancel_Order_Line_Items__c changeLineItem=new TCP_Change_Cancel_Order_Line_Items__c();
                            if(OrderLI.id==deletedItem.id){
                                if(OrderLI.Delivery_Collection_Date__c!=null){
                                    changeLineItem.Delivery_Collection_Date__c=OrderLI.Delivery_Collection_Date__c;
                                    changeLineItem.Delivery_Collection_Date_New__c=OrderLI.Delivery_Collection_Date__c;
                                }
                                
                                changeLineItem.Instruction__c=deletedItem.Other_Instruction__c;
                                changeLineItem.Instruction_New__c=deletedItem.Other_Instruction__c;
                                changeLineItem.Item_number__c=deletedItem.Name;
                                changeLineItem.Product_Name__c=deletedItem.Product__r.Name;
                                changeLineItem.Material_Number__c=OrderLI.MaterialNumber__c;
                                changeLineItem.Quantity__c=deletedItem.Quantity__c;
                                changeLineItem.Quantity_New__c=0;
                                changeLineItem.Shell_Contract_No__c=deletedItem.Contract_No__c;
                                changeLineItem.Shell_Contract_No_New__c=deletedItem.Contract_No__c;
                                changeLineItem.Type__c='Modification';
                                changeLineItem.Unit__c=deletedItem.Unit__c;
                                changeLineItem.Unit_New__c=deletedItem.Unit__c;
                                changeLineItem.Change_Cancel_Request_Order__c=chOrdNewOrdMap.get(deletedItem.Order__c);
                                if(oldOrder.TCP_Order_Status__c=='Submitted'){
                                    changeLineItem.TCP_Modification_Cancellation_Status__c='Cancelled';
                                }
                                chOrdLineIteamList.add(changeLineItem);
                            }
                            
                        }
                    }
                }
                if(chOrdLineIteamList.size()>0){
                    
                    Database.SaveResult[] results = Database.insert(chOrdLineIteamList, false);
                    
                    for (Database.SaveResult result : results) {
                        if (result.isSuccess()) {
                            
                            System.debug('ChOrdLineItemList Successfully inserted, ChOrdLineItem Id is: ' + result.getId());
                        }
                        else {
                            
                            for(Database.Error error : result.getErrors()) {
                                
                                System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                             ' chOrdLineIteamList Fields that affected the error: ' + error.getFields());
                                
                            }
                        }
                    }
                }
                
                //update the current order and order line items.
                if(oldorderList!=null){
                    for(Order oldOrder:oldorderList){
                        Order updateOrder=new Order();
                        updateOrder.id=oldOrder.id;
                        updateOrder.Delivery_Terms__c= orderWrapper.deliveryTerms;
                        updateOrder.Name=orderWrapper.name;
                        updateOrder.PoNumber=orderWrapper.poNumber;
                        updateOrder.Order_Other_Instructions__c=orderWrapper.otherInstructions;
                        updateOrder.Mode_of_Transport__c=orderWrapper.modeOfTransport;
                        updateOrder.TCP_Modification_Requested_By__c=TCP_HomePageController.getOrderedByUserId();
                        updateOrder.TCP_Modification_Requested_Date__c=date.today();
                        
                        if(orderWrapper.status=='Submitted'){
                            updateOrder.TCP_Order_Status__c='Submitted';
                            updateOrder.TCP_Latest_Approved_Modify_Cancel__c=chOrdNewOrdNameMap.get(oldOrder.Id);
                        }
                        if(orderWrapper.status=='Approved'||orderWrapper.status=='Approved (M)'||orderWrapper.status=='Approved (C)'){
                            updateOrder.TCP_Order_Status__c='Approved (M)';
                        }
                        updateorderList.add(updateOrder);
                    }
                }
                if(updateorderList.size()>0){
                    
                    Database.SaveResult[] results = Database.update(updateorderList, false);
                    
                    for (Database.SaveResult result : results) {
                        if (result.isSuccess()) {
                            
                            System.debug('updateorderList Successfully inserted, updated Order Id is: ' + result.getId());
                        }
                        else {
                            
                            for(Database.Error error : result.getErrors()) {
                                
                                System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                             ' updateorderList Fields that affected the error: ' + error.getFields());
                                
                            }
                        }
                    }
                }
                for(TCP_OrderLineItemWrapper lineWrapper:orderLineWrapList){
                    for(Order oldOrder:oldorderList){
                        for(TCP_OrderLineItem__c OrderLI:oldorder.order_line_items__r){
                            
                            TCP_OrderLineItem__c updateLineItem=new TCP_OrderLineItem__c();
                            if(OrderLI.id==lineWrapper.id){
                                updateLineItem.id=lineWrapper.id;
                                updateLineItem.Contract_No__c=lineWrapper.shellContractNo;
                                updateLineItem.Delivery_Collection_Date__c=Date.valueOf(lineWrapper.deliveryCollDate);
                                updateLineItem.Quantity__c=Decimal.valueOf(lineWrapper.quantity);
                                updateLineItem.Unit__c=lineWrapper.unit;
                                updateLineItem.Other_Instruction__c=lineWrapper.instructions;
                                if((OrderLI.Contract_No__c!=lineWrapper.shellContractNo)||(OrderLI.Delivery_Collection_Date__c!=updateLineItem.Delivery_Collection_Date__c) ||(OrderLI.Quantity__c!=updateLineItem.Quantity__c) || (OrderLI.Unit__c!=lineWrapper.unit) ||(OrderLI.Other_Instruction__c!=lineWrapper.instructions) ){
                                    if(oldOrder.TCP_Order_Status__c=='Submitted'){
                                        updateLineItem.TCP_Modify_Cancel_Status__c='Modified';
                                    }
                                    else{
                                        updateLineItem.TCP_Modify_Cancel_Status__c='Modification';
                                    }
                                }
                                
                                updateOrderLIList.add(updateLineItem);
                            }
                            
                        }
                    }
                }
                for(TCP_OrderLineItem__c deletedItem:deletedList){
                    for(Order oldOrder:oldorderList){
                        for(TCP_OrderLineItem__c OrderLI:oldorder.order_line_items__r){
                            TCP_OrderLineItem__c deleteLineItem=new TCP_OrderLineItem__c();
                            TCP_OrderLineItem__c updateLineItem=new TCP_OrderLineItem__c();
                            if(OrderLI.id==deletedItem.id){
                                
                                updateLineItem.Quantity__c=0;
                                if(oldOrder.TCP_Order_Status__c=='Submitted'){
                                    deleteLineItem.Id=deletedItem.id;
                                    deleteOrderLIList.add(deleteLineItem);
                                }
                                else{
                                    updateLineItem.id=deletedItem.id;
                                    updateLineItem.TCP_Modify_Cancel_Status__c='Cancellation';
                                    updateOrderLIList.add(updateLineItem);
                                }
                                
                                
                            }
                            
                        }
                    }
                }
                if(updateOrderLIList.size()>0){
                    Database.SaveResult[] results = Database.update(updateOrderLIList, false);
                    
                    for (Database.SaveResult result : results) {
                        if (result.isSuccess()) {
                            
                            System.debug('updateOrderLIList Successfully inserted, updateOrderLI Id is: ' + result.getId());
                        }
                        else {
                            
                            for(Database.Error error : result.getErrors()) {
                                
                                System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                             ' updateOrderLIList Fields that affected the error: ' + error.getFields());
                                
                            }
                        }
                    }
                }
                if(deleteOrderLIList.size()>0){
                    delete deleteOrderLIList;
                }
                if(updateOrderLIList.size()>0 && updateorderList.size()>0 && chOrdLineIteamList.size()>0 && chOrderlist.size()>0){
                    TCP_Change_Cancel_Request__c chOrd=[select Id, Web_Order__r.AccountId,createdby.Name,createdby.contactId from TCP_Change_Cancel_Request__c where Id=:changeOrderId];
                    sendModifiedOrder(chOrd.Id,chOrd.createdby.contactId,chOrd.Web_Order__r.AccountId);
                } 
            }
            
        }       
        catch (Exception ex) {
           TCP_ExceptionLogClass.insertExceptionRecord('Modify order exception',ex.getMessage(),'TCP_ChangeCancelOrderController','getOrderNumberOnModify','Exception');
        }
        return null;
    }
    @future
    public static void sendModifiedOrder(Id recordId, Id recipientId, Id accountId){
        try{
            TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_Order_EndUser_Modify_Cancel_EN_US',true);
        }
        catch(Exception ex) {
            TCP_ExceptionLogClass.insertExceptionRecord('Modify order exception',ex.getMessage(),'TCP_ChangeCancelOrderController','sendModifiedOrder','Exception');
        }
    }
    
    @AuraEnabled(cacheable=false) 
    public static Order getOrderId(TCP_OrderWrapper orderData){
         Id userId=UserInfo.getUserId();
         User us=[select id, ContactId from User where Id=:userId];
        // Prepare a set of Order Ids with the orderList
        List<Order> cancelOrderList=new list<Order>();
        List<Order> updateOrderList=new list<Order>();
        List<TCP_OrderLineItem__c> cancelOrderLIList=new list<TCP_OrderLineItem__c>();
        List<TCP_Change_Cancel_Request__c> changeCancelReqList=new list<TCP_Change_Cancel_Request__c>();
     
        // Query the orders using set of Order Ids
        try{
            if(orderData!=null){
       
        cancelOrderList=[select Id,OrderNumber,Name,AccountId,TCP_Order_Status__c,(select id, Name,Quantity__c,TCP_Modify_Cancel_Status__c,Order__c from order_line_items__r Order By CreatedDate),
                         (select id,Name,Web_Order__c,Status__c,Type__c,Modify_Cancel_Remarks__c from Change_Cancel_Requests__r where Status__c='Submitted') from order where OrderNumber=:orderData.OrderNumber and recordtype.id=:tcpOrderRecTypeid];
          
            }        
        // iterate the loop and update the status of order to Approved(c) if the previous status is in Approved or Approved (M).
        for(Order cancelOrd:cancelOrderList){
            Order updateOrd=new Order();
            updateOrd.Id=cancelOrd.Id;
            updateOrd.TCP_Cancellation_Requested_By__c=userId;
            updateOrd.TCP_Cancellation_Placed_By__c=TCP_HomePageController.getOrderedByUserId();
            updateOrd.TCP_Cancellation_Requested_Date__c=Date.today();
            if(cancelOrd.TCP_Order_Status__c=='Submitted'){
                updateOrd.TCP_Order_Status__c='Cancelled';
                
            }
            else if(cancelOrd.TCP_Order_Status__c=='Approved' || cancelOrd.TCP_Order_Status__c=='Approved (M)' ){
                updateOrd.TCP_Order_Status__c='Approved (C)';
            }
            updateOrderList.add(updateOrd);
            
        }
           Id orderId;
        if(updateOrderList.size()>0){
            Database.SaveResult[] results = Database.update(updateOrderList, false);
            for (Database.SaveResult result : results) {
                        if (result.isSuccess()) {
                            orderId=result.getId();
                        }
                        else {
                            
                            for(Database.Error error : result.getErrors()) {
                                
                                System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                             ' updateOrderList Fields that affected the error: ' + error.getFields());
                                
                            }
                        }
                    }
        }
        // Update the order status to Cancelled if the previous status is Submitted.
        // Update the orderLine Item status to cancellation.
        
        for(Order cancelOrd:cancelOrderList){
            for(TCP_OrderLineItem__c OrderLI:cancelOrd.order_line_items__r){
                TCP_OrderLineItem__c cancelLI=new TCP_OrderLineItem__c();
                cancelLI.Id=OrderLI.Id;
                if(cancelOrd.TCP_Order_Status__c=='Submitted'){
                cancelLI.TCP_Modify_Cancel_Status__c='Cancelled';
                
            }
            else if(cancelOrd.TCP_Order_Status__c=='Approved' || cancelOrd.TCP_Order_Status__c=='Approved (M)' ){
                if(OrderLI.Quantity__c!=0 && OrderLI.TCP_Modify_Cancel_Status__c!='Cancelled'){
                cancelLI.TCP_Modify_Cancel_Status__c='Cancellation';
                }
            }
            cancelOrderLIList.add(cancelLI);
            
        }
           
        }
        if(cancelOrderLIList.size()>0){
            update cancelOrderLIList;
               
            }
            // if order status is submitted then update the status of Change Order to Not Applicable
         for(Order cancelOrd:cancelOrderList){
             if(cancelOrd.Change_Cancel_Requests__r.size()>0){
             for(TCP_Change_Cancel_Request__c chOrder:cancelOrd.Change_Cancel_Requests__r){
                 TCP_Change_Cancel_Request__c chCanReq=new TCP_Change_Cancel_Request__c();
                 chCanReq.Id=chOrder.Id;
                 if(chOrder.Status__c=='Submitted' && cancelOrd.TCP_Order_Status__c=='Approved (M)'){
                   chCanReq.Id=chOrder.Id;
                   chCanReq.Status__c='Not Applicable';
                     
                     changeCancelReqList.add(chCanReq);
 					
                 }                
             }
                
             }
 
         }
            if(changeCancelReqList.size()>0){
               update changeCancelReqList;
            }
            if(cancelOrderLIList.size()>0 && updateOrderList.size()>0){
                Order ordDetails=[select Id, AccountId from Order where Id=:orderId and recordtype.id=:tcpOrderRecTypeid];
                if(us.ContactId!=null){
                sendCancelledOrder(ordDetails.Id,us.ContactId,ordDetails.AccountId);
                }
                
            }
        // Update the order Line Item status to Cancelled if the status of the order is submitted.
        }
         catch (Exception ex) {
           TCP_ExceptionLogClass.insertExceptionRecord('Cancel order exception',ex.getMessage(),'TCP_ChangeCancelOrderController','getOrderId','Exception');
        }
        return null;
    }
     @future
    public static void sendCancelledOrder(Id recordId, Id recipientId, Id accountId){
        try{
            TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_EndUserOrderCancellationAckEmail',true);
        }
        catch(Exception ex) {
           TCP_ExceptionLogClass.insertExceptionRecord('Cancel order exception',ex.getMessage(),'TCP_ChangeCancelOrderController','sendCancelledOrder','Exception');
        }
    }
}