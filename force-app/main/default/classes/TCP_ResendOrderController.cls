public with sharing class TCP_ResendOrderController {
    
    @AuraEnabled
    public static String reProcessFailedGsapOrder(String orderId){
        try{
            if(String.isNotBlank(orderId)){
                List<Order> orderList = [SELECT id,Account.AccountNumber,TCP_Latest_Approved_Modify_Cancel__c,TCP_GSAP_Account_Name__c,TCP_GSAP_Account_Number__c,Sales_Order_Number__c, GSAP_Status__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId, (select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r  where Cancelled_in_Submitted__c=false Order By Sales_Order_Line_Item_No__c) from Order where id =:orderId];
                if(orderList[0].GSAP_Status__c == 'Processed'){
                    return System.label.TCP_GSAPOrderProcessedMessage;
                }else if(String.isBlank(orderList[0].GSAP_Status__c)){
                    return System.label.TCP_ResendOrderDraftMessage;
                }else if(orderList[0].GSAP_Status__c == 'Sent'){
                    return System.label.TCP_GsapOrderAlreadySentMessage;
                }else if(orderList[0].GSAP_Status__c == 'Resent'){
                    return System.label.TCP_GsapOrderResentMessage;
                }else if(orderList[0].TCP_Order_Status__c == 'Approved (M)' || orderList[0].TCP_Order_Status__c == 'Approved (C)'){
                    return System.label.TCP_Approved_Mod_Can_Msg;
                }else{
                    if(String.isBlank(orderList[0].Sales_Order_Number__c)){
                        String hasError = TCP_GSAPDataService.GenerateGSAPQueryString(orderList[0], orderList[0].order_line_items__r,'Resent');
                        if(String.isNotBlank(hasError)){
                            return hasError;
                        }else{
                            return System.label.TCP_ResentOrderMessage;
                        }
                    }else if(String.isNotBlank(orderList[0].Sales_Order_Number__c)){
                        List<TCP_Change_Cancel_Order_Line_Items__c> approvedChangeOLI=new List<TCP_Change_Cancel_Order_Line_Items__c>([select id,Item_number__c,TCP_Modification_Cancellation_Status__c from TCP_Change_Cancel_Order_Line_Items__c where Change_Cancel_Request_Order__r.name=:orderList[0].TCP_Latest_Approved_Modify_Cancel__c and TCP_Modification_Cancellation_Status__c in ('Modified','Cancelled')]);
                		List<String> appOLIs=new List<String>();
                        List<TCP_OrderLineItem__c> appOLIsList=new List<TCP_OrderLineItem__c>();
                        
                        for(TCP_Change_Cancel_Order_Line_Items__c appChangeOLI : approvedChangeOLI){
                            if(appChangeOLI.TCP_Modification_Cancellation_Status__c=='Modified' || appChangeOLI.TCP_Modification_Cancellation_Status__c=='Cancelled'){
                             appOLIs.add(appChangeOLI.Item_number__c );
                            }
                        }
                        if(appOLIs.size()>0 && !appOLIs.isEmpty()){
                            appOLIsList=[Select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from TCP_OrderLineItem__c WHERE Name in:appOLIs order by Sales_Order_Line_Item_No__c];
                        }
                        
                        //List<TCP_OrderLineItem__c> ordLine = orderList[0].order_line_items__r;
                        /*if(orderList[0].TCP_Order_Status__c == 'Cancelled'){
                            for(TCP_OrderLineItem__c canOrdLineItem : ordLine)
                            {
                                //Temporarily setting the value to 0 as GSAP can process a cancelled order. No commit to system made.
                                canOrdLineItem.quantity__c=0.000;
                            }
                        }*/
                        String hasError = TCP_GSAPDataService.GenerateGSAPQueryStringForModifyCancel(orderList[0], appOLIsList,'Resent');
                        if(String.isNotBlank(hasError)){
                            return hasError;
                        }else{
                            return System.label.TCP_ResentOrderMessage;
                        }
                    }
                }
            }
            
        }catch(exception e){
            e.setMessage('Data exception, required data is not populated either in the order object or in the external GSAP system.');
            return e.getMessage();
        }
        return null;
    }
}