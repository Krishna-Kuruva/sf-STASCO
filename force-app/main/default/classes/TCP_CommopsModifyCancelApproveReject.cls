/*******************************************************************************************
 * TCP_CommopsModifyCancelApproveReject - created to process the approve rejection of 
 * 										   modification from end user.
 * Createddate - 28 Nov 2022
********************************************************************************************/

public with sharing class TCP_CommopsModifyCancelApproveReject {
public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
 @AuraEnabled(cacheable=false) 
    public static Order getOrderOnCommopsApproval(TCP_OrderWrapper ordWrap){
        Order ordResp = new Order();
        try { 
        List<order> toBeApprovedOrderList = new List<order>([select id,Is_Order_Confirmed__c,ordernumber,Remarks__c,TCP_Order_Status__c,TCP_Latest_Approved_Modify_Cancel__c,TCP_Modify_Cancel_Remarks__c,(select id,name,Quantity__c,TCP_Modify_Cancel_Status__c from order_line_items__r),(select id,Name,Web_Order__c,Status__c,Type__c,Modify_Cancel_Remarks__c,createdby.contactId from Change_Cancel_Requests__r order by createddate desc limit 1) from order where ordernumber=: ordWrap.orderNumber and recordtype.id=:tcpOrderRecTypeid limit 1]);
        List<TCP_OrderLineItem__c> approvedOrdersLineItemList=new List<TCP_OrderLineItem__c>();
        List<TCP_Change_Cancel_Order_Line_Items__c> approvedChangeOLI=new List<TCP_Change_Cancel_Order_Line_Items__c>();
        List<String> appOLIs=new List<String>();
        
        if(!toBeApprovedOrderList.isEmpty()){
        Order toBeApprovedOrder=toBeApprovedOrderList[0];
            
            if(!toBeApprovedOrder.order_line_items__r.isEmpty()){
                    approvedOrdersLineItemList =toBeApprovedOrder.order_line_items__r;
              }
            
        	if(!toBeApprovedOrder.change_Cancel_Requests__r.isEmpty()){
        	  TCP_Change_Cancel_Request__c approvedChange=toBeApprovedOrder.change_Cancel_Requests__r[0];
                //latest approved change
                toBeApprovedOrder.TCP_Latest_Approved_Modify_Cancel__c=approvedChange.Name;
                toBeApprovedOrder.Reviewed_Date_Time__c = System.now();
                toBeApprovedOrder.Reviewed_By__c = UserInfo.getUserId();
                
                //latest approved change OLI
                approvedChangeOLI=[select id,Item_number__c,TCP_Modification_Cancellation_Status__c from TCP_Change_Cancel_Order_Line_Items__c where Change_Cancel_Request_Order__r.id=:approvedChange.id];
                 //Setting the modify status on orderline and change orderline       
                if(!approvedChangeOLI.isEmpty()){
                             for(TCP_OrderLineItem__c appOrdLineItem : approvedOrdersLineItemList){
                              for(TCP_Change_Cancel_Order_Line_Items__c appChangeOLI : approvedChangeOLI){
                                if(appOrdLineItem.name==appChangeOLI.Item_number__c){
                                    if(appOrdLineItem.TCP_Modify_Cancel_Status__c=='Modification'){
                                        appOrdLineItem.TCP_Modify_Cancel_Status__c='Modified';
                                        appChangeOLI.TCP_Modification_Cancellation_Status__c='Modified';
                                    }else if(appOrdLineItem.TCP_Modify_Cancel_Status__c=='Cancellation'){
                                        appOrdLineItem.TCP_Modify_Cancel_Status__c='Cancelled';
                                        appChangeOLI.TCP_Modification_Cancellation_Status__c='Cancelled';
                                    }
                                     
                                }
                            }
                             //to update the order line modification status, if multiple modifications are placed and one of the previous modification has a OLI cancelled.     
                             if(appOrdLineItem.TCP_Modify_Cancel_Status__c=='Cancellation' && appOrdLineItem.quantity__c==0){
                                        appOrdLineItem.TCP_Modify_Cancel_Status__c='Cancelled';
                                 		appOLIs.add(appOrdLineItem.Name);
                                    }
                         }
                         }
                    
                //Commops remarks
                if(String.isNotBlank(ordWrap.modifyCommopsRemarks)){
                    toBeApprovedOrder.TCP_Modify_Cancel_Remarks__c = ordWrap.modifyCommopsRemarks;
                    toBeApprovedOrder.Remarks__c =ordWrap.modifyCommopsRemarks;
                    approvedChange.Modify_Cancel_Remarks__c=ordWrap.modifyCommopsRemarks;
                }
                    if(toBeApprovedOrder.TCP_Order_Status__c=='Approved (M)'){
                        //Change Order fields
                        approvedChange.Status__c='Approved';
                        approvedChange.Type__c='Modification';
                        //Order fields
                        toBeApprovedOrder.TCP_Order_Status__c='Approved';
                        toBeApprovedOrder.Is_Order_Confirmed__c =false;
                        if(ordWrap.isRushOrder == true){
                            toBeApprovedOrder.Rush_Order__c = true;
                        }else{
                             toBeApprovedOrder.Rush_Order__c = false;
                        }
                        if(ordWrap.isLateOrder == true){
                            toBeApprovedOrder.Late_Order__c = true;
                        }
                        else{
                             toBeApprovedOrder.Late_Order__c = false;
                        }
                        if(ordWrap.isLastMinute == true){
                            toBeApprovedOrder.Last_Minute_Changes__c = true;
                        }
                        else{
                             toBeApprovedOrder.Last_Minute_Changes__c = false;
                        }
                    }
                Update toBeApprovedOrder;
                Update approvedOrdersLineItemList;
      		    Update approvedChange;
                Update approvedChangeOLI;
                
                ordResp = [SELECT id,TCP_GSAP_Account_Number__c,name,Sales_Order_Number__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId  FROM Order where id =: toBeApprovedOrder.id  and recordtype.id=:tcpOrderRecTypeid ];
                if((ordResp.TCP_Order_Status__c == 'Approved')||(ordResp.TCP_Order_Status__c == 'Cancelled')){
                    if(ordResp.Chemical_GSAP_P_31__c){
                        //List<TCP_OrderLineItem__c> ordLineList = TCP_OrderController.getOrderLineItemsByOrderId(ordResp.Id);
                        //TCP_GSAPDataService.GenerateGSAPQueryStringForModifyCancel(ordResp, ordLineList,'');
                        List<TCP_OrderLineItem__c> appOLIsList=new List<TCP_OrderLineItem__c>();
                        
                        for(TCP_Change_Cancel_Order_Line_Items__c appChangeOLI : ApprovedChangeOLI){
                            if(appChangeOLI.TCP_Modification_Cancellation_Status__c=='Modified' || appChangeOLI.TCP_Modification_Cancellation_Status__c=='Cancelled'){
                             appOLIs.add(appChangeOLI.Item_number__c );
                            }
                        }
                        if(appOLIs.size()>0 && !appOLIs.isEmpty()){
                            appOLIsList=[Select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from TCP_OrderLineItem__c WHERE Name in:appOLIs order by Sales_Order_Line_Item_No__c];
                        }
                         TCP_GSAPDataService.GenerateGSAPQueryStringForModifyCancel(ordResp, appOLIsList,''); 
                        }
                    if(ordResp.Third_Party__c){
                        //deleteModifyCancelledOLI3rdParty(ordResp.id);
                        }
                    if(ordResp.TCP_Order_Status__c == 'Approved'){
                      sendDynamicEmail(approvedChange.id, approvedChange.createdby.contactId, ordResp.AccountId);
                    }
                    
                }   
                 return ordResp;
                }
             }
        return null;
    }
    catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Commops Modification Approval',e.getMessage(),'TCP_CommopsModifyCancelApproveReject','getOrderOnCommopsApproval','Exception');
            throw new AuraHandledException(e.getMessage());
        }    
    }
    
    @AuraEnabled(cacheable=false) 
    public static Order getOrderOnCommopsRejection(TCP_OrderWrapper ordWrap){
        Order ordResp = new Order();
        try { 
        List<order> rejectedOrderList = new List<order>([select id,ordernumber,Remarks__c,TCP_Order_Status__c,TCP_Latest_Approved_Modify_Cancel__c,TCP_Modify_Cancel_Remarks__c,(select id,createdby.contactId,Name,Web_Order__c,Status__c,Type__c,Modify_Cancel_Remarks__c from Change_Cancel_Requests__r order by createddate desc limit 1),(select id, Name,Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,TCP_Modify_Cancel_Status__c from order_line_items__r Order By CreatedDate) from order where  ordernumber=: ordWrap.orderNumber and recordtype.id=:tcpOrderRecTypeid limit 1]);
            if(!rejectedOrderList.isEmpty()){
                 Order rejectedOrder=rejectedOrderList[0];
                 List<TCP_OrderLineItem__c> rejectedOrderLineItemList=new List<TCP_OrderLineItem__c>();
                 List<TCP_Change_Cancel_Order_Line_Items__c> rejectedChangeOLI=new List<TCP_Change_Cancel_Order_Line_Items__c>();
                 
                 if(!rejectedOrder.order_line_items__r.isEmpty()){
                      rejectedOrderLineItemList =rejectedOrder.order_line_items__r;
                 }
                
                //Updating the rejected change request and order status
                if(!rejectedOrder.change_Cancel_Requests__r.isEmpty()){
                    TCP_Change_Cancel_Request__c rejectedChange=rejectedOrder.change_Cancel_Requests__r[0];
                    rejectedOrder.Reviewed_Date_Time__c = System.now();
                    rejectedOrder.Reviewed_By__c = UserInfo.getUserId();
                    if(String.isNotBlank(ordWrap.modifyCommopsRemarks)){
                        rejectedOrder.TCP_Modify_Cancel_Remarks__c = ordWrap.modifyCommopsRemarks;
                        rejectedChange.Modify_Cancel_Remarks__c=ordWrap.modifyCommopsRemarks;
                        rejectedOrder.Remarks__c =ordWrap.modifyCommopsRemarks;
                    }
                    if(rejectedOrder.TCP_Order_Status__c=='Approved (M)'){
                        //Change Order fields
                        rejectedChange.Status__c='Rejected';
                        rejectedChange.Type__c='Modification';
                        //Change order line item fields
                        rejectedChangeOLI=[select id,TCP_Modification_Cancellation_Status__c,Item_number__c from TCP_Change_Cancel_Order_Line_Items__c where Change_Cancel_Request_Order__r.id=:rejectedChange.id];
                         if(!rejectedChangeOLI.isEmpty()){
                             for(TCP_OrderLineItem__c rejOrdLineItem : rejectedOrderLineItemList){
                              for(TCP_Change_Cancel_Order_Line_Items__c rejChangeOLI : rejectedChangeOLI){
                                if(rejOrdLineItem.name==rejChangeOLI.Item_number__c){
                                    rejChangeOLI.TCP_Modification_Cancellation_Status__c=rejOrdLineItem.TCP_Modify_Cancel_Status__c;
                                }
                            }
                         }
                         }
                        //Order fields
                        rejectedOrder.TCP_Order_Status__c='Approved';
                    }
                
                   
                //As the change request is rejected, reverting the values to previous approved change or oldest change.
                if(rejectedOrder.TCP_Latest_Approved_Modify_Cancel__c!=null){
                    List<TCP_Change_Cancel_Request__c> lastApprovedModifyCancelList =New List<TCP_Change_Cancel_Request__c>([SELECT Status__c, Type__c, Web_Order__c, Order_Name_New__c, Customer_PO_New__c, Delivery_Terms_New__c, Mode_of_Transport_New__c, Other_Instruction_New__c, Modify_Cancel_Remarks__c, Id, Name, CreatedDate, (select Id, CreatedDate, Delivery_Collection_Date_New__c, Type__c, Quantity_New__c, Unit_New__c, Shell_Contract_No_New__c, Instruction_New__c, Name, Item_number__c,TCP_Modification_Cancellation_Status__c,TCP_Line_Item_Modify_Cancel_Status__c  from Change_Cancel_Order_Line_Items__r)  FROM TCP_Change_Cancel_Request__c where Web_Order__c=:rejectedOrder.id and name=:rejectedOrder.TCP_Latest_Approved_Modify_Cancel__c ]);
                    if(!lastApprovedModifyCancelList.isEmpty()){
                        TCP_Change_Cancel_Request__c lastApprovedModifyCancel=lastApprovedModifyCancelList[0];
                        List<TCP_Change_Cancel_Order_Line_Items__c> changeOrderLineItemList =lastApprovedModifyCancel.Change_Cancel_Order_Line_Items__r;
                        //reverting the order object to latest approved change new values
                        rejectedOrder.PoNumber=lastApprovedModifyCancel.Customer_PO_New__c; //confirm if correct
                        rejectedOrder.Delivery_Terms__c=lastApprovedModifyCancel.Delivery_Terms_New__c;
                        rejectedOrder.Mode_of_Transport__c=lastApprovedModifyCancel.Mode_of_Transport_New__c;
                        rejectedOrder.Order_Other_Instructions__c=lastApprovedModifyCancel.Other_Instruction_New__c;
                        
                        //reverting the order line item to latest approved change line item new values if there is an approved change.
                        if(!rejectedOrderLineItemList.isEmpty()){
                        for(TCP_OrderLineItem__c rejOrdLineItem : rejectedOrderLineItemList){
                            for(TCP_Change_Cancel_Order_Line_Items__c chngeOrdLineItem : changeOrderLineItemList){
                                if(rejOrdLineItem.name==chngeOrdLineItem.Item_number__c){
                                    //Order line item values
                                    rejOrdLineItem.Delivery_Collection_Date__c=chngeOrdLineItem.Delivery_Collection_Date_New__c;
                                    rejOrdLineItem.Quantity__c=chngeOrdLineItem.Quantity_New__c;
                                    rejOrdLineItem.Unit__c=chngeOrdLineItem.Unit_New__c;
                                    rejOrdLineItem.Contract_No__c=chngeOrdLineItem.Shell_Contract_No_New__c;
                                    rejOrdLineItem.Other_Instruction__c=chngeOrdLineItem.Instruction_New__c;
                                    rejOrdLineItem.TCP_Modify_Cancel_Status__c=chngeOrdLineItem.TCP_Modification_Cancellation_Status__c;
                                }
                            }
                         }
                       }
                	}
            	} 
          	else
                {
                List<TCP_Change_Cancel_Request__c> firstModifyCancelList =New List<TCP_Change_Cancel_Request__c>([SELECT Id, Name, CreatedDate, Customer_PO__c, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, Order_Name__c, Type__c, Web_Order__c, Other_Instruction__c, Status__c, (select Id, CreatedDate, Delivery_Collection_Date__c, Type__c, Quantity__c, Unit__c, Shell_Contract_No__c, Instruction__c, Name, Item_number__c  from Change_Cancel_Order_Line_Items__r)  FROM TCP_Change_Cancel_Request__c where Web_Order__c=:rejectedOrder.id order by createddate asc limit 1 ]);
                if(!firstModifyCancelList.isEmpty())
                {
                    TCP_Change_Cancel_Request__c firstModifyCancel=firstModifyCancelList[0];
                    List<TCP_Change_Cancel_Order_Line_Items__c> changeOrderLineItemList =firstModifyCancel.Change_Cancel_Order_Line_Items__r;
                    //reverting the order object to oldest change old values
                    rejectedOrder.PoNumber=firstModifyCancel.Customer_PO__c; //confirm if correct
                    rejectedOrder.Delivery_Terms__c=firstModifyCancel.Delivery_Terms__c;
                    rejectedOrder.Mode_of_Transport__c=firstModifyCancel.Mode_of_Transport__c;
                    rejectedOrder.Order_Other_Instructions__c=firstModifyCancel.Other_Instruction__c;
                    
                    //reverting the order line item to oldest change line item old values
                    if(!rejectedOrderLineItemList.isEmpty()){
                    for(TCP_OrderLineItem__c rejOrdLineItem : rejectedOrderLineItemList){
                        for(TCP_Change_Cancel_Order_Line_Items__c chngeOrdLineItem : changeOrderLineItemList){
                            if(rejOrdLineItem.name==chngeOrdLineItem.Item_number__c){
                                //Change line item values
                                chngeOrdLineItem.TCP_Line_Item_Modify_Cancel_Status__c=rejOrdLineItem.TCP_Modify_Cancel_Status__c;
                                    
                                //Order line item values
                                rejOrdLineItem.Delivery_Collection_Date__c=chngeOrdLineItem.Delivery_Collection_Date__c;
                                rejOrdLineItem.Quantity__c=chngeOrdLineItem.Quantity__c;
                                rejOrdLineItem.Unit__c=chngeOrdLineItem.Unit__c;
                                rejOrdLineItem.Contract_No__c=chngeOrdLineItem.Shell_Contract_No__c;
                                rejOrdLineItem.Other_Instruction__c=chngeOrdLineItem.Instruction__c;
                                rejOrdLineItem.TCP_Modify_Cancel_Status__c=TCP_Constants.NO_CHANGE;
                            }
                        }
                    }
                  }
                }  
            }
            Update rejectedOrder;
            Update rejectedOrderLineItemList;
            Update rejectedChange;
            Update rejectedChangeOLI;
             ordResp = [SELECT id, name, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId  FROM Order where id =: rejectedOrder.id  and recordtype.id=:tcpOrderRecTypeid ];
             if(ordResp.TCP_Order_Status__c == 'Approved'){
                    sendDynamicEmail(rejectedChange.id, rejectedChange.createdby.contactId, ordResp.AccountId);
                }      
             return ordResp;
             } 
            }
        return null;
    	}
        catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('Commops Modification Rejection',e.getMessage(),'TCP_CommopsModifyCancelApproveReject','getOrderOnCommopsRejection','Exception');
                throw new AuraHandledException(e.getMessage());
        }    
    
}
    
    @AuraEnabled(cacheable=false) 
    public static Order getOrderOnCommopsCancellationApproval(TCP_OrderWrapper ordWrap){
        Order ordResp = new Order();
        try { 
        List<order> cancelledOrders = new List<order>([select id,Remarks__c,ordernumber,TCP_Order_Status__c,TCP_Latest_Approved_Modify_Cancel__c,TCP_Modify_Cancel_Remarks__c,(select id,name,Quantity__c,TCP_Modify_Cancel_Status__c from order_line_items__r) from order where Id=: ordWrap.Id  and recordtype.id=:tcpOrderRecTypeid limit 1]);
        List<TCP_OrderLineItem__c> cancelledOLIs=new List<TCP_OrderLineItem__c>();
        
        if(!CancelledOrders.isEmpty()){
        Order cancelledOrder=cancelledOrders[0];
            
            if(!cancelledOrder.order_line_items__r.isEmpty()){
                     cancelledOLIs =cancelledOrder.order_line_items__r;
                 }
            
        	if(!cancelledOLIs.isEmpty()){
        		 //Updating cancelled Order and OLI's
                if(cancelledOrder.TCP_Order_Status__c=='Approved (C)'){
                       cancelledOrder.TCP_Order_Status__c='Cancelled';
                       cancelledOrder.Reviewed_Date_Time__c = System.now();
                        cancelledOrder.Reviewed_By__c = UserInfo.getUserId();
                        //Commops remarks
                        if(String.isNotBlank(ordWrap.cancelCommopsRemarks)){
                            cancelledOrder.TCP_Modify_Cancel_Remarks__c = ordWrap.cancelCommopsRemarks;
                            cancelledOrder.Remarks__c= ordWrap.cancelCommopsRemarks;
                        }
                    	for(TCP_OrderLineItem__c canOrdLineItem : cancelledOLIs){
                                canOrdLineItem.TCP_Modify_Cancel_Status__c='Cancelled';
                    	}
                   }
                
                Update cancelledOrder;
                Update cancelledOLIs;
                
                ordResp = [SELECT id, name, Sales_Order_Number__c,Order_Other_Instructions__c,TCP_Cancellation_Requested_By__r.contactId,Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId  FROM Order where id =: cancelledOrder.id  and recordtype.id=:tcpOrderRecTypeid];
                if(ordResp.TCP_Order_Status__c == 'Cancelled'){
                    if(ordResp.Chemical_GSAP_P_31__c){
                        List<TCP_OrderLineItem__c> ordLineList = TCP_OrderController.getOrderLineItemsByOrderId(ordResp.Id);
                        if(!ordLineList.isempty()){
                            for(TCP_OrderLineItem__c canOrdLineItem : ordLineList)
                            {
                                //Temporarily setting the value to 0 as GSAP can process a cancelled order. No commit to system made.
                                canOrdLineItem.quantity__c=0.000;
                            }
                            TCP_GSAPDataService.GenerateGSAPQueryStringForModifyCancel(ordResp, ordLineList,'');
                        }
                    }
                     sendCancellationEmail(ordResp.id, ordResp.TCP_Cancellation_Requested_By__r.contactId, ordResp.AccountId);
                     return ordResp;
                    }
                    
                }
                }
                 
                return null; 
             }
		catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Commops Cancellation Approval',e.getMessage(),'TCP_CommopsModifyCancelApproveReject','getOrderOnCommopsCancellationApproval','Exception');
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
     @AuraEnabled(cacheable=false) 
    public static Order getOrderOnCommopsCancellationRejection(TCP_OrderWrapper ordWrap){
        Order ordResp = new Order();
         try { 
         List<order> cancellationRejectedList = new List<order>([select id,ordernumber,TCP_Order_Status__c,TCP_Latest_Approved_Modify_Cancel__c,TCP_Modify_Cancel_Remarks__c,(select id, Name,Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,TCP_Modify_Cancel_Status__c from order_line_items__r Order By CreatedDate) from order where id=: ordWrap.id  and recordtype.id=:tcpOrderRecTypeid limit 1]);
         if(!cancellationRejectedList.isEmpty()){
             Order cancellationRejectedOrd=cancellationRejectedList[0];
             List<TCP_OrderLineItem__c> cancellationRejectedOLIs=new List<TCP_OrderLineItem__c>();
             if(cancellationRejectedOrd.TCP_Order_Status__c=='Approved (C)'){
                List<TCP_Change_Cancel_Request__c> firstModifyCancelList =New List<TCP_Change_Cancel_Request__c>([SELECT Id, Name, CreatedDate, Customer_PO__c, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, Order_Name__c, Type__c, Web_Order__c, Other_Instruction__c, Status__c, (select Id, CreatedDate, Delivery_Collection_Date__c, Type__c, Quantity__c, Unit__c, Shell_Contract_No__c, Instruction__c, Name, Item_number__c  from Change_Cancel_Order_Line_Items__r)  FROM TCP_Change_Cancel_Request__c where Web_Order__c=:cancellationRejectedOrd.id order by createddate asc limit 1 ]);

                if(!cancellationRejectedOrd.order_line_items__r.isEmpty()){
                      cancellationRejectedOLIs =cancellationRejectedOrd.order_line_items__r;
                 }
                
                //Updating the Order.
                cancellationRejectedOrd.Reviewed_Date_Time__c = System.now();
                cancellationRejectedOrd.Reviewed_By__c = UserInfo.getUserId();
                cancellationRejectedOrd.TCP_Order_Status__c='Approved';
                if(String.isNotBlank(ordWrap.cancelCommopsRemarks)){
                        cancellationRejectedOrd.TCP_Modify_Cancel_Remarks__c = ordWrap.cancelCommopsRemarks;
                        cancellationRejectedOrd.Remarks__c=ordWrap.cancelCommopsRemarks;
                }
                
                //As the change request is rejected, reverting the values to previous approved change or oldest change'Old value or if no change just relavent status change.
                if(cancellationRejectedOrd.TCP_Latest_Approved_Modify_Cancel__c!=null){
                    List<TCP_Change_Cancel_Request__c> lastApprovedModifyCancelList =New List<TCP_Change_Cancel_Request__c>([SELECT Status__c, Type__c, Web_Order__c, Order_Name_New__c, Customer_PO_New__c, Delivery_Terms_New__c, Mode_of_Transport_New__c, Other_Instruction_New__c, Modify_Cancel_Remarks__c, Id, Name, CreatedDate, (select Id, CreatedDate, Delivery_Collection_Date_New__c, Type__c, Quantity_New__c, Unit_New__c, Shell_Contract_No_New__c, Instruction_New__c, Name, Item_number__c,TCP_Modification_Cancellation_Status__c,TCP_Line_Item_Modify_Cancel_Status__c  from Change_Cancel_Order_Line_Items__r)  FROM TCP_Change_Cancel_Request__c where Web_Order__c=:cancellationRejectedOrd.id and name=:cancellationRejectedOrd.TCP_Latest_Approved_Modify_Cancel__c ]);
                    if(!lastApprovedModifyCancelList.isEmpty()){
                        TCP_Change_Cancel_Request__c lastApprovedModifyCancel=lastApprovedModifyCancelList[0];
                        List<TCP_Change_Cancel_Order_Line_Items__c> changeOrderLineItemList =lastApprovedModifyCancel.Change_Cancel_Order_Line_Items__r;
                        //reverting the order object to latest approved change new values
                        cancellationRejectedOrd.PoNumber=lastApprovedModifyCancel.Customer_PO_New__c; //confirm if correct
                        cancellationRejectedOrd.Delivery_Terms__c=lastApprovedModifyCancel.Delivery_Terms_New__c;
                        cancellationRejectedOrd.Mode_of_Transport__c=lastApprovedModifyCancel.Mode_of_Transport_New__c;
                        cancellationRejectedOrd.Order_Other_Instructions__c=lastApprovedModifyCancel.Other_Instruction_New__c;
                        
                        //reverting the order line item to latest approved change line item new values if there is an approved change.
                        if(!cancellationRejectedOLIs.isEmpty()){
                        for(TCP_OrderLineItem__c rejOrdLineItem : cancellationRejectedOLIs){
                            for(TCP_Change_Cancel_Order_Line_Items__c chngeOrdLineItem : changeOrderLineItemList){
                                if(rejOrdLineItem.name==chngeOrdLineItem.Item_number__c){
                                    //Order line item values
                                    rejOrdLineItem.Delivery_Collection_Date__c=chngeOrdLineItem.Delivery_Collection_Date_New__c;
                                    rejOrdLineItem.Quantity__c=chngeOrdLineItem.Quantity_New__c;
                                    rejOrdLineItem.Unit__c=chngeOrdLineItem.Unit_New__c;
                                    rejOrdLineItem.Contract_No__c=chngeOrdLineItem.Shell_Contract_No_New__c;
                                    rejOrdLineItem.Other_Instruction__c=chngeOrdLineItem.Instruction_New__c;
                                    rejOrdLineItem.TCP_Modify_Cancel_Status__c=chngeOrdLineItem.TCP_Modification_Cancellation_Status__c;
                                }
                            }
                         }
                    }
                	}
            
            	} 
                else if(firstModifyCancelList.isEmpty()){
                        //As no previous modification request, We can change statuses to revert back.
                         if(!cancellationRejectedOLIs.isEmpty()){
                             for(TCP_OrderLineItem__c rejOrdLineItem : cancellationRejectedOLIs){
                                    rejOrdLineItem.TCP_Modify_Cancel_Status__c='No Change';
                             }
                         }
                }
                else if(!firstModifyCancelList.isEmpty()){
                    TCP_Change_Cancel_Request__c firstModifyCancel=firstModifyCancelList[0];
                    List<TCP_Change_Cancel_Order_Line_Items__c> changeOrderLineItemList =firstModifyCancel.Change_Cancel_Order_Line_Items__r;
                    //reverting the order object to oldest change old values
                    cancellationRejectedOrd.PoNumber=firstModifyCancel.Customer_PO__c; //confirm if correct
                    cancellationRejectedOrd.Delivery_Terms__c=firstModifyCancel.Delivery_Terms__c;
                    cancellationRejectedOrd.Mode_of_Transport__c=firstModifyCancel.Mode_of_Transport__c;
                    cancellationRejectedOrd.Order_Other_Instructions__c=firstModifyCancel.Other_Instruction__c;
                    
                    //reverting the order line item to oldest change line item old values
                    if(!cancellationRejectedOLIs.isEmpty()){
                    for(TCP_OrderLineItem__c rejOrdLineItem : cancellationRejectedOLIs){
                        for(TCP_Change_Cancel_Order_Line_Items__c chngeOrdLineItem : changeOrderLineItemList){
                            if(rejOrdLineItem.name==chngeOrdLineItem.Item_number__c){
                                //Change line item values
                                chngeOrdLineItem.TCP_Line_Item_Modify_Cancel_Status__c=rejOrdLineItem.TCP_Modify_Cancel_Status__c;
                                    
                                //Order line item values
                                rejOrdLineItem.Delivery_Collection_Date__c=chngeOrdLineItem.Delivery_Collection_Date__c;
                                rejOrdLineItem.Quantity__c=chngeOrdLineItem.Quantity__c;
                                rejOrdLineItem.Unit__c=chngeOrdLineItem.Unit__c;
                                rejOrdLineItem.Contract_No__c=chngeOrdLineItem.Shell_Contract_No__c;
                                rejOrdLineItem.Other_Instruction__c=chngeOrdLineItem.Instruction__c;
                                rejOrdLineItem.TCP_Modify_Cancel_Status__c='No Change';
                            }
                        }
                    }
                  }
                }  
                
                Update cancellationRejectedOrd;
                Update cancellationRejectedOLIs;
                    
                ordResp = [SELECT id, name, Order_Other_Instructions__c,TCP_Cancellation_Requested_By__r.contactId, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId  FROM Order where id =: cancellationRejectedOrd.id  and recordtype.id=:tcpOrderRecTypeid];
             	if(ordResp.TCP_Order_Status__c == 'Approved'){
                    sendCancellationEmail(ordResp.id, ordResp.TCP_Cancellation_Requested_By__r.contactId, ordResp.AccountId);
                }
                    
             return ordResp;
            }
            } 
         return null;
    	}
        catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('Commops Cancellation Rejection',e.getMessage(),'TCP_CommopsModifyCancelApproveReject','getOrderOnCommopsCancellationRejection','Exception');
                throw new AuraHandledException(e.getMessage());
        }    
    
}
    
    @future
    public static void sendDynamicEmail(Id recordId, Id recipientId, Id accountId){
        try{
            if(!Test.isRunningTest()){
            TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_Order_Commops_Modify_Cancel_EN_US',true);
            }
        }
        catch(Exception excptn) {
           throw excptn;
        }
    }
    
     @future
    public static void sendCancellationEmail(Id recordId, Id recipientId, Id accountId){
        try{
            if(!Test.isRunningTest()){
            TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_Order_Cancellation_EN_US',true);
             }
        }
        catch(Exception excptn) {
            throw excptn;
        }
    }
    
    public static void deleteModifyCancelledOLI3rdParty(String orderId){
        try{
            if(orderId!=null){
                List <TCP_OrderLineItem__c> toBedeletedOLI=new List<TCP_OrderLineItem__c>([select id from TCP_OrderLineItem__c where Order__r.id=:orderId and quantity__c=0 and TCP_Modify_Cancel_Status__c='Cancelled' and Order__r.Third_Party__c=true]);
                if(!toBedeletedOLI.isEmpty()){
                    delete toBedeletedOLI;
                }
            }
        }
        catch(Exception excptn) {
            throw excptn;
        }
    }
}