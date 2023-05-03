/*******************************************************************************************
* Created by Madhu Javvaji on 21-Sep-22.
* Connect APIGEE via ODATA 
********************************************************************************************/

public with sharing class TCP_OrderManagementProcessor {

public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();    
    
    // method to track status of tcp place order in gsap(Called from a future method in TCP_GSAPDataService Class)
    //public static void trackStatusGSAPOrder(String orderId,Boolean orderCreated,Boolean responseRcvd, Boolean ErrorInData, String salesOrderNum){
    public static void trackStatusGSAPOrder(String orderId,Boolean orderCreated, Boolean ErrorInData, String salesOrderNum, Boolean responseRcvd){
        try{           
            system.debug('orderCreated=====>'+orderCreated);
            system.debug('salesOrderNum=====>'+salesOrderNum);
            Order savedOrder = new Order();
            savedOrder = [select id, GSAP_Status__c, Sales_Order_Number__c, OrderNumber, ShipToNo__c, CreatedDate,Account.AccountNumber, AccountId,CreatedBy.Name, CreatedById from order where id =:orderId];
            string TableBody;
            if(!ErrorInData){
                if(orderCreated){
                    savedOrder.GSAP_Status__c = 'Processed';
                    savedOrder.Sales_Order_Number__c = salesOrderNum;
                    
                }else{
                    savedOrder.GSAP_Status__c = 'Failed to Process';
                }

                if(responseRcvd){
                    savedOrder.GSAP_Status__c = 'No GSAP Response';
                }
                
            }else{
                savedOrder.GSAP_Status__c = 'Sent Failed';                
            }
            
            update savedOrder;
            
            /* Delete the Order Line Items which are cancelled with Req qty value as "0" while mofication request is placed and approved by commops
            if(savedOrder.Sales_Order_Number__c!=null && savedOrder.GSAP_Status__c == 'Processed'){
                system.debug('delete orderline item ============>'+savedOrder.Sales_Order_Number__c);
                List <TCP_OrderLineItem__c> toBedeletedOLI=new List<TCP_OrderLineItem__c>([select id from TCP_OrderLineItem__c where Order__r.Sales_Order_Number__c=:savedOrder.Sales_Order_Number__c and Order__r.id =:savedOrder.id and quantity__c=0 and TCP_Modify_Cancel_Status__c='Cancelled']);
                if(!toBedeletedOLI.isEmpty()){
                delete toBedeletedOLI;
                }
            }*/
            
        }
        catch(NullPointerException excptn) {
            throw excptn;
        }
        catch(ListException excptn) {
            throw excptn;
        }catch( exception ex){
            throw ex;
        }
    }
        
    
    // method to track status of tcp get current orders(goods issue) in gsap(Called from a future method in TCP_GSAPDataService Class)
    public static void trackCurrentOrderFromsGSAP(list<CurrentOrders__x> getCurrentOrdersResp, string soldtono, string stnsapSoldToNo){  
               
        integer size = getCurrentOrdersResp.size();        
        
        map<String,order> OrdersListMap = new map<String,order>();
        
        map<string,list<CurrentOrders__x>> currentOrderMap = new map<string,list<CurrentOrders__x>>();
        
        for (CurrentOrders__x co : getCurrentOrdersResp){
            system.debug('co data <><><><><><><><><>'+ co);
            if (co.Soldto__c == soldtono){               
                if(currentOrderMap.containskey(co.Weborder__c)){                    
                    list<CurrentOrders__x> tmpList = currentOrderMap.get(co.Weborder__c);
                    tmpList.add(co);
                    currentOrderMap.put(co.Weborder__c,tmpList);
                }
                else{
                    currentOrderMap.put(co.Weborder__c, new list<CurrentOrders__x>{co} );   
                }
            }            
        }
        list<order> finalOrderList = [select id,OrderNumber,Name,PoNumber,Sales_Order_Number__c,(select id,Order_Line_Status__c,TCP_Modify_Cancel_Status__c,Sales_Order_Line_Item_No__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c,GSAP_Goods_Issue_Date__c,GSAP_Dispatch_Date__c,GSAP_Due_Date__c from order_line_items__r) from order where TCP_Order_Status__c = 'Approved' and Account.AccountNumber =:stnsapSoldToNo AND recordtypeid =: tcpOrderRecTypeid ORDER BY OrderNumber DESC];
        list<Order> finalOrders =  new list<Order>();
        list<TCP_OrderLineItem__c> finalOrderLineItems = new list<TCP_OrderLineItem__c>();
        list<CurrentOrders__x> tmpList1 =  new list<CurrentOrders__x>();
        
        for(order ord : finalOrderList){
            if(currentOrderMap.containskey(ord.OrderNumber)){
                list<CurrentOrders__x> tmpList = currentOrderMap.get(ord.OrderNumber);
                
                ord.Sales_Order_Number__c = tmpList[0].SalesOrder__c;
                ord.GSAP_Status__c = 'Processed';
                //ord.TCP_Order_Status__c = 'Shipped'; //this order status should get updated to shippedpnly when all the products in the orderline item have status has shipped.
                
                Boolean allLineItemsShipped = true;
                for(TCP_OrderLineItem__c li : ord.order_line_items__r){
                    
                    for(CurrentOrders__x ops : tmplist){
                        System.debug('Checking Sales Item Number '+li.Sales_Order_Line_Item_No__c + '---'+ops.SalesItemNo__c);
                        if(li.Sales_Order_Line_Item_No__c == ops.SalesItemNo__c){                            
                            li.GSAP_Goods_Issue_Value__c = ops.GmQuan__c;                            
                            if (ops.GmDate__c != NULL){
                            	li.GSAP_Goods_Issue_Date__c = Date.valueOf(ops.GmDate__c);  
                            }
                            if (ops.GmDate__c != NULL){
                            	li.GSAP_Dispatch_Date__c =  Date.valueOf(ops.GmDate__c);   
                            }
                            if (string.isNotBlank(ops.DueDate__c)){
                            	li.GSAP_Due_Date__c =  Date.valueOf(ops.DueDate__c);   
                            }
                            if (string.isNotBlank(ops.GmStat__c)){								
								li.GSAP_Goods_Issue_Status__c = ops.GmStat__c;
                                li.Order_Line_Status__c = 'Shipped';
                            }
                            if (string.isNotBlank(ops.GmUnit__c)){                            	
                            	li.GSAP_Goods_Issue_Unit__c = ops.GmUnit__c;  
                            }
                            if (string.isNotBlank(ops.BolDeliveryNo__c)){                            	 
                            	li.GSAP_Bol_Delivery__c = ops.BolDeliveryNo__c;  
                            }                                                  
                            if (string.isNotBlank(ops.MotId__c)){								  
								li.GSAP_Mode_of_Transport_ID__c = ops.MotId__c;                              
                            }         
                        }
                    }
                    if((li.Order_Line_Status__c != 'Shipped')&&(li.TCP_Modify_Cancel_Status__c != 'Cancelled')){
                        allLineItemsShipped=false;
                    }
                    finalOrderLineItems.add(li);                   
                }
                if(allLineItemsShipped){
                    ord.TCP_Order_Status__c = 'Shipped';
                }
                finalOrders.add(ord);                
            }
        }            
        update finalOrders;
        update finalOrderLineItems; 
                
    }
    
    //method to process order confirmation data and update orders and line items accordingly
    public static void updateOrderConfirmationDetails(list<OrdCnfDet__x> OrdConfirmData, string soldtono, string stnsapSoldToNo){  
        system.debug('in updateOrderConfirmationDetails ');       
        try{
            map<string,list<OrdCnfDet__x>> OrdConfMap = new map<string,list<OrdCnfDet__x>>();
            list<Order> finalOrders =  new list<Order>();
            list<TCP_OrderLineItem__c> finalOrderLineItems = new list<TCP_OrderLineItem__c>();
            for (OrdCnfDet__x co : OrdConfirmData){
                system.debug('co data <><><><><><><><><>'+ co);
                if (co.Soldto__c == soldtono){               
                    if(OrdConfMap.containskey(co.Weborder__c)){                    
                        list<OrdCnfDet__x> tmpList = OrdConfMap.get(co.Weborder__c);
                        tmpList.add(co);
                        OrdConfMap.put(co.Weborder__c,tmpList);
                    }
                    else{
                        OrdConfMap.put(co.Weborder__c, new list<OrdCnfDet__x>{co} );   
                    }
                }            
            }
            list<order> finalOrderList = [select id,OrderNumber,Name,PoNumber,Sales_Order_Number__c,TCP_Order_Status__c,Is_Order_Confirmed__c,GSAP_Status__c,(select id,Sales_Order_Line_Item_No__c,Material_Name__c,MaterialNumber__c,Expected_Dispatch_Date__c,SICC_Code__c,Net_Weight__c,Netweight_Unitprice__c,Plant__c,Shipping_Point__c,Plant_Name__c,Shipping_Point_Name__c,Shipping_City__c,Shipping_Country__c,Shipping_Postcode__c,Shipping_Street__c from order_line_items__r) from order where Is_Order_Confirmed__c = FALSE AND TCP_Order_Status__c != 'shipped' AND TCP_Order_Status__c = 'Approved' and Account.AccountNumber =:stnsapSoldToNo AND OrderNumber IN: OrdConfMap.keyset() AND recordtypeid =: tcpOrderRecTypeid ORDER BY OrderNumber DESC];
            
            if(!finalOrderList.isEmpty()){
                system.debug('inside if '+finalOrderList.size());
                map<string,list<TCP_OrderLineItem__c>> orderlineitemsByorderNumberMap = new map<string,list<TCP_OrderLineItem__c>>();
                map<string,order> orderbyWebOrdMap = new map<string,order>();
                for(order tempOrd : finalOrderList){
                    list<TCP_OrderLineItem__c> tmplineitmlist = tempOrd.order_line_items__r;
                    orderlineitemsByorderNumberMap.put(tempOrd.OrderNumber,tmplineitmlist);
                    orderbyWebOrdMap.put(tempOrd.OrderNumber,tempOrd);
                    System.debug('orderlineitemsByorderNumberMap '+orderlineitemsByorderNumberMap);
                    System.debug('orderbyWebOrdMap '+orderbyWebOrdMap);
                }
                
                //loop thru response data and update line items
                set<id> tempLineitems = new set<id>();
                for(OrdCnfDet__x tempExtData : OrdConfirmData){
                    system.debug('in for 1');
                    if(!orderlineitemsByorderNumberMap.isEmpty() && orderlineitemsByorderNumberMap.containskey(tempExtData.Weborder__c)){
                    system.debug('webordernumber '+tempExtData.Weborder__c);
                        list<TCP_OrderLineItem__c> tempList = orderlineitemsByorderNumberMap.get(tempExtData.Weborder__c);
                        if(!tempList.isEmpty()){
                            for(TCP_OrderLineItem__c tempItem : tempList){
                                string tempitemNo;
                                if(tempExtData.SalesItemNo__c.length()==5){
                                    tempitemNo = '0'+tempExtData.SalesItemNo__c;
                                }
                                else{
                                    tempitemNo = tempExtData.SalesItemNo__c;
                                }
                                system.debug('tempitemNo '+tempitemNo);
                                System.debug('Checking item order item No '+tempItem.Sales_Order_Line_Item_No__c+'----'+tempitemNo+'------'+tempLineitems);
                                //if(string.isNotBlank(tempExtData.SalesItemNo__c) && tempExtData.SalesItemNo__c.length()==5 && tempExtData.SalesItemNo__c.contains(tempItem.Sales_Order_Line_Item_No__c)){
                                if(tempItem.Sales_Order_Line_Item_No__c == tempitemNo && !tempLineitems.contains(tempItem.id)){  
                                	system.debug('inside Sales_Order_Line_Item_No__c if '+tempitemNo + 'order '+tempExtData.Weborder__c); 
                                    //if(string.isNotBlank(tempExtData.MatDes__c))
                                      //  tempItem.Material_Name__c = tempExtData.MatDes__c;
                                    //if(string.isNotBlank(tempExtData.ProductId__c))
                                     //   tempItem.MaterialNumber__c = tempExtData.ProductId__c;
                                    if(string.isNotBlank(string.valueOf(tempExtData.LoadDate__c)))
                                        tempItem.Expected_Dispatch_Date__c = date.valueOf(tempExtData.LoadDate__c) ;
                                    if(string.isNotBlank(tempExtData.SiccCode__c))
                                        tempItem.SICC_Code__c = tempExtData.SiccCode__c;
                                    if(string.isNotBlank(string.valueOf(tempExtData.NetWeight__c)))
                                        tempItem.Net_Weight__c = tempExtData.NetWeight__c;
                                    if(string.isNotBlank(tempExtData.WUnit__c))
                                        tempItem.Netweight_Unitprice__c = tempExtData.WUnit__c;
                                    if(string.isNotBlank(tempExtData.PlantId__c))
                                        tempItem.Plant__c = tempExtData.PlantId__c;
                                    if(string.isNotBlank(tempExtData.ShipPnt__c))
                                        tempItem.Shipping_Point__c = tempExtData.ShipPnt__c;
                                    if(string.isNotBlank(tempExtData.WerkNam__c))
                                        tempItem.Plant_Name__c = tempExtData.WerkNam__c;
                                    if(string.isNotBlank(tempExtData.SlocNam__c))
                                        tempItem.Shipping_Point_Name__c = tempExtData.SlocNam__c;
                                    if(string.isNotBlank(tempExtData.SlcCity__c))
                                        tempItem.Shipping_City__c = tempExtData.SlcCity__c;
                                    if(string.isNotBlank(tempExtData.SlcCtry__c))
                                        tempItem.Shipping_Country__c = tempExtData.SlcCtry__c;
                                    if(string.isNotBlank(tempExtData.SlcPost__c))
                                        tempItem.Shipping_Postcode__c = tempExtData.SlcPost__c;
                                    if(string.isNotBlank(tempExtData.SlcStrt__c))
                                        tempItem.Shipping_Street__c = tempExtData.SlcStrt__c;
                                    
                                    
                                    finalOrderLineItems.add(tempItem);
                                    tempLineitems.add(tempItem.id);
                                    break; 
                                }
                                
                            }
                        }	
                        
                    }
                }
                
                //loop thru response data and update order data
                set<string> webOrders = new set<string>();
                for(OrdCnfDet__x tempExtData : OrdConfirmData){
                    system.debug('in for 2');
                    Boolean statuscheck;
                    
                    if(!webOrders.contains(tempExtData.Weborder__c)){
                        
                        for(OrdCnfDet__x tempExtData2 : OrdConfMap.get(tempExtData.Weborder__c)){
                    
                        //check if all status is confirmed and update order as confirmed
                        
                            if(string.isNotBlank(tempExtData2.PlantId__c) && string.isNotBlank(tempExtData2.ShipPnt__c)){
                                statuscheck = true;
                            }
                            else{
                                statuscheck = false;
                            }
                        }
                        if(orderbyWebOrdMap.containskey(tempExtData.Weborder__c)){
                            order temporder = orderbyWebOrdMap.get(tempExtData.Weborder__c);
                            system.debug('temporder val '+temporder);
                            if(string.isNotBlank(tempExtData.Salesorder__c) && string.isBlank(temporder.Sales_Order_Number__c)){
                            //if(string.isNotBlank(tempExtData.Salesorder__c)){
                                temporder.Sales_Order_Number__c = tempExtData.Salesorder__c;
                            	temporder.GSAP_Status__c = 'Processed';
                            }
                            if(statuscheck && !temporder.Is_Order_Confirmed__c && temporder.GSAP_Status__c == 'Processed'){
                            //if(statuscheck && !temporder.Is_Order_Confirmed__c){
                                temporder.Is_Order_Confirmed__c = True;
                                
                            }
                            finalOrders.add(temporder);
                            webOrders.add(tempExtData.Weborder__c);
                        }
                        
                    }//if ends
                }//for ends
                
            }
            system.debug('finalOrders '+finalOrders);
            system.debug('finalOrderLineItems '+finalOrderLineItems);
            if(!finalOrders.isEmpty()){
                update finalOrders;
            }
            if(!finalOrderLineItems.isEmpty()){
                update finalOrderLineItems;
            }
        }
        catch(Exception e){
            system.debug('in updateOrderConfirmationDetails catch : '+e.getCause()+'message '+e.getmessage()+'line '+e.getLineNumber());
        	TCP_ExceptionLogClass.insertExceptionRecord('updateOrderConfirmationDetails exception',e.getMessage(),'TCP_OrderManagementProcessor','updateOrderConfirmationDetails','Exception');
        } 
                
    }
    
    // method to track status of tcp get current orders in gsap(Called from a future method in TCP_GSAPDataService Class)
    //public static void fetchFilesFromGSAP(list<Filenet__x> getFileNetResp){  
    public static List<TCP_GSAPFileWrapper> fetchFilesFromGSAP(list<Filenet__x> getFileNetResp){ 
        List<TCP_GSAPFileWrapper> wrapFilesList = new List<TCP_GSAPFileWrapper>();
        System.debug('getFileNetResp===>'+getFileNetResp);        
        integer size = getFileNetResp.size();
        system.debug('size====>'+size); 
        
        for (Filenet__x fn : getFileNetResp){
        	TCP_GSAPFileWrapper fnWrap = new TCP_GSAPFileWrapper();
            fnWrap.Document = fn.Document__c;
            fnWrap.Outputtype = fn.Outputtype__c;
            fnWrap.Outputdesc = fn.Outputdesc__c;
            fnWrap.Filenetid = fn.Filenetid__c;
            fnWrap.Reserve = fn.Reserve__c;
            fnWrap.Application = fn.Application__c;
            fnWrap.Coa = fn.Coa__c;
            fnWrap.Uri = fn.Uri__c;
            fnWrap.Zsectyp = fn.Zsectyp__c;
            
            wrapFilesList.add(fnWrap);
        }
        System.debug('wrapFilesList========>'+wrapFilesList);
        return wrapFilesList;
    }
}