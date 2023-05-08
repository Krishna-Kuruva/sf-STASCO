public with sharing class TCP_OrderController{
    //Account Record Type    
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
    
        @AuraEnabled
        public static List<TCP_OrderWrapper> getOrderDetailsBySoldToIdCU(String soldToId, String selectedTile){
            List<Order> orderData = new List<Order>();
            List<TCP_OrderWrapper> ordWrapList = new List<TCP_OrderWrapper>();
           
            try {
                List<string> selectedStatuses=TCP_Utilities.getStatusForSelectedTile(selectedTile,true);
                
                If(selectedStatuses!=null){
                    String query='SELECT Id,Sold_To__c, TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c,Sales_Order_Number__c, Account.ShippingAddress,Account.Shippingcity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name,ordered_by__c, CreatedDate, TCP_Order_Status__c,Chemical_GSAP_P_31__c,Third_Party__c,Late_Order__c,Rush_Order__c,Last_Minute_Changes__c,Reviewed_By__r.Name,Reviewed_Date_Time__c,Remarks__c, Ordered_By__r.Name, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_Value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from Order where Sold_To__c =: soldToId and tcp_order_status__c In:selectedStatuses and recordtype.id=:tcpOrderRecTypeid';
                    Integer queryNoOfDays=TCP_Utilities.getQueryDaysForSelectedTile(selectedTile); 
                        if(queryNoOfDays!=null){
                             query +=TCP_Constants.CREATEDDATE_LASTNDAYS+queryNoOfDays+TCP_Constants.ORD_BY_CREATEDDATE;
                         }else{
                              query +=TCP_Constants.ORD_BY_CREATEDDATE;
                         }
                     OrderData=Database.query(query);
                     
                     for(Order ordObj : orderData){
                        List<TCP_OrderLineItem__c> ordLineList = ordObj.order_line_items__r;
                        ordWrapList.add(prepareOrderWrapperCU(ordObj,ordLineList));
                     }
                 }
             } catch (Exception e) {
                 TCP_ExceptionLogClass.insertExceptionRecord('Order Details for CU',e.getMessage(),'TCP_OrderController','getOrderDetailsBySoldToIdCU','Exception');
               throw new AuraHandledException(e.getMessage());
             }
             return ordWrapList;
         }
    
        public static TCP_OrderWrapper prepareOrderWrapperCU(Order ordData, List<TCP_OrderLineItem__c> ordLineList){
            TCP_OrderWrapper ordWrap = new TCP_OrderWrapper();
            ordWrap.id = ordData.id;
            ordWrap.orderNumber = ordData.OrderNumber;
            ordWrap.name = ordData.name;
            ordWrap.poNumber = ordData.PoNumber;
            ordWrap.deliveryTerms = ordData.Delivery_Terms__c;
            ordWrap.modeOfTransport = ordData.Mode_of_Transport__c;
            ordWrap.otherInstructions = ordData.Order_Other_Instructions__c;
            ordWrap.soldToName = ordData.Customer_Name__c;
            ordWrap.shipToName = ordData.Ship_To__r.Name;
            ordWrap.billToName = ordData.Bill_To__r.Name;
            ordWrap.orderedBy = ordData.Ordered_By__r.Name;
            ordWrap.salesordernumber = ordData.Sales_Order_Number__c;
            if(ordData.Account.Shippingcity!=null){
                ordWrap.soldToCity=ordData.Account.Shippingcity;
            }
            if(ordData.Account.ShippingAddress!=null){
            ordWrap.soldToNameWithAddr = formatAddress(ordData.Account.ShippingAddress, ordData.Customer_Name__c);
            }
            if(ordData.Ship_To__r.ShippingAddress!=null){
            ordWrap.shipToNameWithAddr = formatAddress(ordData.Ship_To__r.ShippingAddress, ordData.Ship_To__r.Name);
            }
            if(ordData.Bill_To__r.ShippingAddress!=null){
            ordWrap.billToNameWithAddr = formatAddress(ordData.Bill_To__r.ShippingAddress, ordData.Bill_To__r.Name);
            } 
            ordWrap.status = ordData.TCP_Order_Status__c;
            ordWrap.orderLineItemList = ordLineList;
            if(ordData.Third_Party__c == True && ordData.Chemical_GSAP_P_31__c == FALSE){
                ordWrap.fullfilledBy = System.Label.TCP_Third_Party;
            }
            if(ordData.Third_Party__c == FALSE && ordData.Chemical_GSAP_P_31__c == TRUE){
                ordWrap.fullfilledBy = System.Label.TCP_Chemical_GSAP_P_31;
            }
            if(ordData.Late_Order__c == TRUE){
                ordWrap.isLateOrderVal = 'Yes';
            }
            else{
                ordWrap.isLateOrderVal = 'No';
            }
    
            if(ordData.Rush_Order__c == TRUE){
                ordWrap.isRushOrderVal = 'Yes';
            }
            else{
                ordWrap.isRushOrderVal = 'No';
            }
    
            if(ordData.Last_Minute_Changes__c == TRUE){
                ordWrap.isLastMinuteChangeVal = 'Yes';
            }
            else{
                ordWrap.isLastMinuteChangeVal = 'No';
            }
            ordWrap.reviewedBy = ordData.Reviewed_By__r.Name;
            
            if(ordData.Reviewed_Date_Time__c!=null){
                    ordWrap.reviewedDateTime = TCP_Utilities.getDateWithMonthName(ordData.Reviewed_Date_Time__c.Date())+' '+ordData.Reviewed_Date_Time__c.format('HH:mm:ss'); 
            }
            ordWrap.remarks = ordData.Remarks__c;
            ordWrap.orderedDate=TCP_Utilities.getDateWithMonthName(ordData.Createddate.Date());
            if(ordData.TCP_Modification_Requested_By__r.name!=null){
                    ordWrap.modificationBy=ordData.TCP_Modification_Requested_By__r.name;
            }
            if(ordData.TCP_Modification_Requested_Date__c!=null){
                 ordWrap.modificationDate=TCP_Utilities.getDateWithMonthName(ordData.TCP_Modification_Requested_Date__c);
            }
            if(ordData.TCP_Cancellation_Placed_By__r.name!=null){
                 ordWrap.cancellationBy=ordData.TCP_Cancellation_Placed_By__r.name;
            }
            if(ordData.TCP_Cancellation_Requested_Date__c!=null){
                ordWrap.cancellationDate=TCP_Utilities.getDateWithMonthName(ordData.TCP_Cancellation_Requested_Date__c);
            }
            return ordWrap;
        } 
    
        @AuraEnabled
        public static List<TCP_OrderWrapper> getOrderDetailsBySoldToIdEU(String soldToId, String selectedTile){
            List<Order> orderData = new List<Order>();
            List<TCP_OrderWrapper> ordWrapList = new List<TCP_OrderWrapper>();
            try {
               List<string> selectedStatuses=TCP_Utilities.getStatusForSelectedTile(selectedTile,false);
               
               If(selectedStatuses!=null){
                String query='SELECT Id, Sales_Order_Number__c, Ordered_By__r.Name, TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c, Account.ShippingAddress,Account.ShippingCity, Ship_To__c, Bill_To__c, Sold_To__c, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c,Chemical_GSAP_P_31__c,Third_Party__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name, CreatedDate, TCP_Order_Status__c,Remarks__c, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Mode_of_Transport_ID__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c ,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_Value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r  where quantity__c!=0  Order By CreatedDate) from Order where Sold_To__c =: soldToId and tcp_order_status__c In:selectedStatuses  and recordtype.id=:tcpOrderRecTypeid';
                   Integer queryNoOfDays=TCP_Utilities.getQueryDaysForSelectedTile(selectedTile);
                       if(queryNoOfDays!=null){
                            query +=TCP_Constants.CREATEDDATE_LASTNDAYS+queryNoOfDays+TCP_Constants.ORD_BY_CREATEDDATE;
                        }else{
                             query +=TCP_Constants.ORD_BY_CREATEDDATE;
                        }
                    OrderData=Database.query(query);
                    for(Order ordObj : orderData){
                        List<TCP_OrderLineItem__c> ordLineList = ordObj.order_line_items__r;
                        ordWrapList.add(prepareOrderWrapperEU(ordObj,ordLineList));
                    }
                }
            } catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('Order Details for EU',e.getMessage(),'TCP_OrderController','getOrderDetailsBySoldToIdEU','Exception');
              throw new AuraHandledException(e.getMessage());
            }
            return ordWrapList;
        }
    
        public static TCP_OrderWrapper prepareOrderWrapperEU(Order ordData, List<TCP_OrderLineItem__c> ordLineList){
            TCP_OrderWrapper ordWrap = new TCP_OrderWrapper();
            ordWrap.id = ordData.id;
            ordWrap.orderNumber = ordData.OrderNumber;
            ordWrap.name = ordData.name;
            ordWrap.poNumber = ordData.PoNumber;
            ordWrap.deliveryTerms = ordData.Delivery_Terms__c;
            ordWrap.modeOfTransport = ordData.Mode_of_Transport__c;
            ordWrap.otherInstructions = ordData.Order_Other_Instructions__c;
            ordWrap.soldToName = ordData.Customer_Name__c;
            ordWrap.shipToName = ordData.Ship_To__r.Name;
            ordWrap.billToName = ordData.Bill_To__r.Name;
            ordWrap.soldToId = ordData.Sold_To__c;
            ordWrap.shipToId = ordData.Ship_To__c;
            ordWrap.billToId = ordData.Bill_To__c;
            ordWrap.salesordernumber = ordData.Sales_Order_Number__c;
            ordWrap.orderedBy = ordData.Ordered_By__r.Name;
            ordWrap.remarks = ordData.Remarks__c;
            if(ordData.Account.Shippingcity!=null){
                ordWrap.soldToCity=ordData.Account.Shippingcity;
            }
            if(ordData.Account.ShippingAddress!=null){
            ordWrap.soldToNameWithAddr = formatAddress(ordData.Account.ShippingAddress, ordData.Customer_Name__c);
            }
            if(ordData.Ship_To__r.ShippingAddress!=null){
            ordWrap.shipToNameWithAddr = formatAddress(ordData.Ship_To__r.ShippingAddress, ordData.Ship_To__r.Name);
            }
            if(ordData.Bill_To__r.ShippingAddress!=null){
            ordWrap.billToNameWithAddr = formatAddress(ordData.Bill_To__r.ShippingAddress, ordData.Bill_To__r.Name);
            }
            if(ordData.Third_Party__c == True && ordData.Chemical_GSAP_P_31__c == FALSE){
                ordWrap.fullfilledBy = System.Label.TCP_Third_Party;
            }
            ordWrap.status = ordData.TCP_Order_Status__c;
            ordWrap.orderLineItemList = ordLineList;
            ordWrap.orderedDate=TCP_Utilities.getDateWithMonthName(ordData.Createddate.Date());
            if(ordData.TCP_Modification_Requested_By__r.name!=null){
                    ordWrap.modificationBy=ordData.TCP_Modification_Requested_By__r.name;
            }
            if(ordData.TCP_Modification_Requested_Date__c!=null){
                 ordWrap.modificationDate=TCP_Utilities.getDateWithMonthName(ordData.TCP_Modification_Requested_Date__c);
            }
            if(ordData.TCP_Cancellation_Placed_By__r.name!=null){
                 ordWrap.cancellationBy=ordData.TCP_Cancellation_Placed_By__r.name;
            }
            if(ordData.TCP_Cancellation_Requested_Date__c!=null){
                ordWrap.cancellationDate=TCP_Utilities.getDateWithMonthName(ordData.TCP_Cancellation_Requested_Date__c);
            }
            return ordWrap;
        } 
    
        @AuraEnabled
        public static List<TCP_OrderLineItem__c> getOrderLineItemsByOrderId(String orderId){
            List<TCP_OrderLineItem__c> orderLineList = new List<TCP_OrderLineItem__c>();
            try {
                orderLineList = [select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from TCP_OrderLineItem__c WHERE  Order__c =: orderId  order by Sales_Order_Line_Item_No__c];
                
            } catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('OLI by order Id',e.getMessage(),'TCP_OrderController','getOrderLineItemsByOrderId','Exception');
               throw new AuraHandledException(e.getMessage());
            }
            return orderLineList;
        }
    
        public static String formatAddress(Address ordData, String prefix){
            return prefix + ( string.ISBLANK(ordData.getStreet())?'':', '+ordData.getStreet())+ ( string.ISBLANK(ordData.getCity())?'':', '+ordData.getCity())+ ( string.ISBLANK(ordData.getState())?'':', '+ordData.getState())+ ( string.ISBLANK(ordData.getPostalCode())?'':', '+ordData.getPostalCode())+( string.ISBLANK(ordData.getCountry())?'':', '+ordData.getCountry());
        }
    
        @AuraEnabled(cacheable=false)
        public static Order updateOrderReviewDetails(TCP_OrderWrapper ordWrap){
            Order ordResp = new Order();
            try {
                if(ordWrap != null){
                    Order ord = new Order();
                    if(String.isNotBlank(ordWrap.status)){
                        ord.TCP_Order_Status__c = ordWrap.status;
                    }
                    if(ordWrap.isChemicalGSAP == true){
                        ord.Chemical_GSAP_P_31__c = true;
                    }
                    if(ordWrap.isThirdParty == true){
                        ord.Third_Party__c = true;
                        if(ord.TCP_Order_Status__c == 'Approved'){
                            ord.Sales_Order_Number__c = ordWrap.orderNumber + 'TP';
                        }
                    }
                    if(ordWrap.isRushOrder == true){
                        ord.Rush_Order__c = true;
                    }
                    if(ordWrap.isLateOrder == true){
                        ord.Late_Order__c = true;
                    }
                    if(ordWrap.isLastMinute == true){
                        ord.Last_Minute_Changes__c = true;
                    }
                    if(String.isNotBlank(ordWrap.remarks)){
                        ord.Remarks__c = ordWrap.remarks;
                    }
                    if(String.isNotBlank(ordWrap.id)){
                        ord.id = ordWrap.id;
                        ord.Reviewed_Date_Time__c = System.now();
                        ord.Reviewed_By__c = UserInfo.getUserId();
                        update ord;
                    }
                    ordResp = [SELECT id, TCP_Bulk_Order_Requested_by__c, name,Is_Order_Confirmed__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId  FROM Order where id =: ord.id  and recordtype.id=:tcpOrderRecTypeid];
                    Id recipientId;
                    if(String.isNotBlank(ordResp.TCP_Bulk_Order_Requested_by__c)){
                        recipientId = Id.valueOf(ordResp.TCP_Bulk_Order_Requested_by__c);
                        System.debug('recipientId ==>'+ recipientId);
                    }else{
                        recipientId = ordResp.createdby.contactId;
                        System.debug('recipientId else ==>'+ recipientId);
                    }
                    if(ordResp.TCP_Order_Status__c == 'Approved'){
                        if(ordResp.Chemical_GSAP_P_31__c){
                            List<TCP_OrderLineItem__c> ordLineList = getOrderLineItemsByOrderId(ordResp.Id);
                            TCP_GSAPDataService.GenerateGSAPQueryString(ordResp, ordLineList,'');
                            sendOrderApproval(ordResp.id, recipientId, ordResp.AccountId);
    
                            //Order confiwrmation when order is approved by CommOps if fulfillment part is GSAP P31
                            //sendOrderConfirmation(ordResp.id, ordResp.createdby.contactId, ordResp.AccountId);
                        }else if(ordResp.Third_Party__c){
                            send3rdPartyOrderApproval(ordResp.id, recipientId, ordResp.AccountId);
                        } 
                    }else if(ordResp.TCP_Order_Status__c == 'Rejected'){
                        sendOrderRejection(ordResp.id, recipientId, ordResp.AccountId);
                    }
                   else if(ordResp.Is_Order_Confirmed__c == True){
                        sendOrderConfirmation(ordResp.id, recipientId, ordResp.AccountId);
                    } 
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            return ordResp;
        }
    
        @AuraEnabled
        public static String validateMappingReference(String orderId){
            try {
                List<Order> ordList = [SELECT id, OrderNumber, Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c, (select id, Product__r.Product_Number__c from order_line_items__r where quantity__c!=0 Order By CreatedDate)  from Order WHERE id=:orderId];
                if(String.isBlank(ordList[0].Sold_To__r.GSAP_Account_Number__c) || String.isBlank(ordList[0].Ship_To__r.GSAP_Account_Number__c) || String.isBlank(ordList[0].Bill_To__r.GSAP_Account_Number__c) || String.isBlank(ordList[0].Payer__r.GSAP_Account_Number__c)){
                    return 'Failed';
                }else if(validateProductMappingReference(ordList[0].order_line_items__r)){
                    return 'Failed';    
                }else{
                    return 'Success';
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        public static boolean validateProductMappingReference(List<TCP_OrderLineItem__c> ordLineList){
            if(ordLineList.size()>0){
                for(TCP_OrderLineItem__c ordLine : ordLineList){
                    if(String.isBlank(ordLine.Product__r.Product_Number__c)){
                        return true;
                    }
                }
            }
            return false;
        }
    
        @future
        public static void sendOrderApproval(Id recordId, Id recipientId, Id accountId){
            try{
                if(!Test.isRunningTest()){
                TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_Order_Approval_EN_US',true);
                }
            }
            catch(Exception excptn) {
                throw excptn;
            }
        }
    
        @future
        public static void sendOrderRejection(Id recordId, Id recipientId, Id accountId){
            try {
                if(!Test.isRunningTest()){
                TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_Order_Rejection_EN_US',true);
                }
            }
            catch(Exception excptn) {
                throw excptn;
            }
        }
    
        @future
        public static void send3rdPartyOrderApproval(Id recordId, Id recipientId, Id accountId){
          try{
              if(!Test.isRunningTest()){
                TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_Order_Approval_3rd_Party_EN_US',true);
              }
            }
            catch(Exception excptn) {
                throw excptn;
            }
        }
        
        @future
        public static void sendOrderConfirmation(Id recordId, Id recipientId, Id accountId){
          try{	
                TCP_EmailService.sendEmail(recordId,recipientId,accountId,null,'TCP_ET_Place_Order_Confirmation_with_PDF',true);
    
            }
            catch(Exception excptn) {
                throw excptn;
            }
        }
    
        @AuraEnabled(cacheable=false)
        public static string fetchGSAPCurrentOrders(String soldToId){
            List<Account> accountList = new List<Account>();
            accountList = [SELECT id, AccountNumber, GSAP_Account_Number__c, toLabel(Customer_Type__c) FROM Account where id=: soldToId and RecordTypeId=:tcpAccountRecTypeid  LIMIT 1];
                      
            try {
                if(String.isNotBlank(soldToId) && accountList.size()>0){                
                    String gsapSoldToNo = accountList[0].GSAP_Account_Number__c;
                    String stnsapSoldToAccNo = accountList[0].AccountNumber;
                    //check if there are orders awaiting for goods issue data and then make callouts based on it
                    list<order> pendingOrders = [select id,createddate from order where TCP_Order_Status__c != 'shipped' AND Chemical_GSAP_P_31__c=True AND TCP_Order_Status__c = 'Approved' AND Account.AccountNumber =:stnsapSoldToAccNo order by createddate ASC]; 
                    if(String.isNotBlank(gsapSoldToNo) && !pendingOrders.isEmpty()){
                        String dateFormat ='IEQ';
                        Date lastCallDate = date.valueOf(pendingOrders[0].createddate);
                        String lastCallDateFormat =  String.valueOf(lastCallDate.year()) + String.valueOf(lastCallDate.month()).leftpad(2,'0') + String.valueOf(lastCallDate.Day()).leftpad(2,'0');
                        dateFormat += lastCallDateFormat;                          
                        string completeString = 'Select Soldto__c,Ztype__c,Weborder__c,SalesOrder__c,SalesItemNo__c,GmQuan__c,GmDate__c,Months__c,DueDate__c,GmStat__c,GmUnit__c,BolDelItemNo__c,BolDeliveryNo__c,CustomerPoNo__c,DeliverOn__c,DeliverTo__c,DisplayUrl,TotVatAmount__c,TotGrossAmount__c,InvoiceAmount__c,InvoiceItm__c,InvoiceNo__c,InvoiceType__c,Mot__c,MotId__c,MotKey__c,OrderCreatedOn__c,Ordername__c,ProductId__c,ProductName__c,Quantity__c,ShipDspOn__c,Status__c,Unit__c,Terms__c,Currency__c from CurrentOrders__x where ';
                        completeString = completeString+'Soldto__c=\''+gsapSoldToNo+'\''+' and '+'DueDate__c=\''+dateFormat+'\'';                    
                        system.debug('completeString=====>'+completeString);
                        TCP_GSAPDataService.GetCurrentOrdersFromGsap(completeString, gsapSoldToNo, stnsapSoldToAccNo);     
                      }else{
                        System.debug('ERROR ==> missing GSAP Sold to Mapping reference');
                    }                
                }  
            } catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('Fetch GSAP Current Orders',e.getMessage(),'TCP_OrderController','fetchGSAPCurrentOrders','Exception');
                throw new AuraHandledException(e.getMessage());
            }
            return null;
        }
        
        //method to handle order confirmation service
        @AuraEnabled(cacheable=false)
        public static string fetchGSAPOrderConfirmationdetails(String soldToId){
            List<Account> accountList = new List<Account>();
            accountList = [SELECT id, AccountNumber, GSAP_Account_Number__c, toLabel(Customer_Type__c) FROM Account where id=: soldToId and RecordTypeId=:tcpAccountRecTypeid  LIMIT 1];
                      
            try {
                if(String.isNotBlank(soldToId) && accountList.size()>0){                
                    String gsapSoldToNo = accountList[0].GSAP_Account_Number__c;
                    String stnsapSoldToAccNo = accountList[0].AccountNumber;
                    //check if there are orders awaiting for confirmation data and then make callouts based on it
                    list<order> pendingOrders = [select id,createddate from order where Is_Order_Confirmed__c=False AND Chemical_GSAP_P_31__c=True AND TCP_Order_Status__c != 'shipped' AND TCP_Order_Status__c = 'Approved' and Account.AccountNumber =:stnsapSoldToAccNo order by createddate ASC ]; 
                    if(String.isNotBlank(gsapSoldToNo) && !pendingOrders.isEmpty()){
                        String dateFormat ='IGT';
                        Date lastCallDate = date.valueOf(pendingOrders[0].createddate-1);
                        String lastCallDateFormat =  String.valueOf(lastCallDate.year()) + String.valueOf(lastCallDate.month()).leftpad(2,'0') + String.valueOf(lastCallDate.Day()).leftpad(2,'0');
                        dateFormat += lastCallDateFormat;                          
                        string completeString = 'SELECT Id, ExternalId, DisplayUrl, DelvDate__c, Descrs__c, LoadDate__c, MatDes__c, NetWeight__c, OrdDate__c, PlantId__c, ProductId__c, SalesItemNo__c, Salesorder__c, ShipPnt__c, SiccCode__c, Soldto__c, Status__c, WUnit__c, Weborder__c, Inco1__c, Inco2__c, PayTerm__c, SlcCity__c, SlcCtry__c, SlcPost__c, SlcStrt__c, Slcadnam__c, SlocNam__c, WerCity__c, WerCtry__c, WerPost__c, WerStrt__c, Weradnam__c, WerkNam__c FROM OrdCnfDet__x where ';
                        completeString = completeString+'Soldto__c=\''+gsapSoldToNo+'\''+' and '+' Weradnam__c=\''+dateFormat+'\'';                    
                        system.debug('completeString=====>'+completeString);
                        TCP_GSAPDataService.GetOrderConfirmationFromGsap(completeString, gsapSoldToNo, stnsapSoldToAccNo);     
                    }else{
                        System.debug('ERROR ==> missing GSAP Sold to Mapping reference');
                    }                
                }  
            } catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('Fetch GSAP Order Confirmation',e.getMessage(),'TCP_OrderController','fetchGSAPOrderConfirmationdetails','Exception');
                throw new AuraHandledException(e.getMessage());
            }
            return null;
        }
    
        @AuraEnabled
        public static String  generatePDF(String orderNumber, String soldToId){
            try {
                if(String.isNotBlank(orderNumber) && String.isNotBlank(soldToId)){
                List<order> selectedOrderPDF=new List<order>([select id,createdby.firstname,ordernumber from order where ordernumber=:orderNumber and accountid=:soldToId  and recordtype.id=:tcpOrderRecTypeid limit 1]);
                    if(!selectedOrderPDF.isEmpty()){
                    PageReference pdfPage = Page.TCP_OrderAckPDF;
                    pdfPage.getParameters().put('RecordId',selectedOrderPDF[0].id);
                    pdfPage.getParameters().put('ContactName',selectedOrderPDF[0].createdby.firstname);
                    pdfPage.getParameters().put('OrderNumber',selectedOrderPDF[0].ordernumber);
                    blob pdfBlob;
                    if(Test.isRunningTest()) { 
                        pdfBlob = blob.valueOf('Unit.Test');
                    } 
                    else{
                        pdfBlob = pdfPage.getContent();
                    }
                    String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
                    return base64Pdf;
                    }
                }
                return null;
            } catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('TCP Generate PDF',e.getMessage(),'TCP_OrderController','generatePDF','Exception');
                throw new AuraHandledException(e.getMessage());
            }
            
        }   
        
        @AuraEnabled
        public static List<TCP_OrderWrapper> getOrderEUReport(String soldToId, List<String> ordersInReport){
            try {
                if(String.isNotBlank(soldToId) && ordersInReport!=null && !ordersInReport.isEmpty()){
                    List<Order> ordersToDownload=new List<order>([SELECT Id,TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c,Sold_To__c, Sales_Order_Number__c, Ordered_By__r.Name, Account.ShippingAddress,Account.shippingcity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c,Third_Party__c,Chemical_GSAP_P_31__c,Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name, CreatedDate, TCP_Order_Status__c,Remarks__c, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_Value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r where quantity__c!=0 Order By CreatedDate) from Order where Sold_To__c =: soldToId and OrderNumber In:ordersInReport  and recordtype.id=:tcpOrderRecTypeid order by createddate desc]);
                    List<TCP_OrderWrapper> ordWrapList = new List<TCP_OrderWrapper>();
                    if(!ordersToDownload.isEmpty()){
                        for(Order ordObj : ordersToDownload){
                            List<TCP_OrderLineItem__c> ordLineList = ordObj.order_line_items__r;
                            ordWrapList.add(prepareOrderWrapperEU(ordObj,ordLineList));
                        }system.debug('ordWrapList'+ordWrapList);
                        return ordWrapList;
                    }
                }
                return null;
                }
            catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('TCP EU Report',e.getMessage(),'TCP_OrderController','getOrderEUReport','Exception');
                throw new AuraHandledException(e.getMessage());
            }
            
        }   
        
        @AuraEnabled
        public static List<TCP_OrderWrapper>  getOrderCUReport(String soldToId,List<String> ordersInReportCU){
           try {
               if(String.isNotBlank(soldToId) && ordersInReportCU!=null && !ordersInReportCU.isEmpty()){
                   List<Order> ordersToDownloadCU=new List<order>([SELECT Id,Sold_To__c, TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c,Sales_Order_Number__c, Account.ShippingAddress,Account.Shippingcity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name,ordered_by__c, CreatedDate, TCP_Order_Status__c,Chemical_GSAP_P_31__c,Third_Party__c,Late_Order__c,Rush_Order__c,Last_Minute_Changes__c,Reviewed_By__r.Name,Reviewed_Date_Time__c,Remarks__c, Ordered_By__r.Name, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r where quantity__c!=0 Order By CreatedDate)  from Order where Sold_To__c =: soldToId and OrderNumber In:ordersInReportCU and recordtype.id=:tcpOrderRecTypeid  order by createddate desc]);
                   List<TCP_OrderWrapper> ordWrapListCU = new List<TCP_OrderWrapper>();
                   if(!ordersToDownloadCU.isEmpty()){
                       for(Order ordObj : ordersToDownloadCU){
                           List<TCP_OrderLineItem__c> ordLineList = ordObj.order_line_items__r;
                           ordWrapListCU.add(prepareOrderWrapperCU(ordObj,ordLineList));
                       }
                       return ordWrapListCU;
                   }
               }
               return null;
               }
            catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('TCP CU Report',e.getMessage(),'TCP_OrderController','getOrderCUReport','Exception');
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        @AuraEnabled
        public static List<TCP_OrderWrapper> getOrderDetailsByFilter(TCP_OrderWrapper ordWrap, TCP_OrderLineItemWrapper ordLineWrap, String defaultStatus, String userType, String selectedTile){
            List<TCP_OrderWrapper> ordWrapList = new List<TCP_OrderWrapper>();
            try {
                if(ordWrap.soldToId != null){
                    List<Order> ordList = new List<Order>();
                    String queryString = 'SELECT Id,Sold_To__c, TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c, Sales_Order_Number__c, Account.ShippingCity, Account.ShippingAddress, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name,ordered_by__c, CreatedDate, TCP_Order_Status__c,Chemical_GSAP_P_31__c,Third_Party__c,Late_Order__c,Rush_Order__c,Last_Minute_Changes__c,Reviewed_By__r.Name,Reviewed_Date_Time__c,Remarks__c, Ordered_By__r.Name, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r Order By CreatedDate) from Order where recordtypeid=:tcpOrderRecTypeid and Sold_To__c='+'\''+ordWrap.soldToId+'\'';
                    if(String.isNotBlank(userType) && userType == 'Comm Ops User'){
                        queryString = 'SELECT Id,Sold_To__c,TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c, Sales_Order_Number__c, Account.ShippingAddress,Account.Shippingcity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name,ordered_by__c, CreatedDate, TCP_Order_Status__c,Chemical_GSAP_P_31__c,Third_Party__c,Late_Order__c,Rush_Order__c,Last_Minute_Changes__c,Reviewed_By__r.Name,Reviewed_Date_Time__c,Remarks__c, Ordered_By__r.Name, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r Order By CreatedDate) from Order where recordtypeid=:tcpOrderRecTypeid and TCP_Order_Status__c!=\'Draft\' and Sold_To__c='+'\''+ordWrap.soldToId+'\'';
                    }else if(String.isNotBlank(userType) && userType == 'End User'){
                        queryString = 'SELECT Id, Sold_To__c,TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c,Sales_Order_Number__c, Ordered_By__r.Name, Account.ShippingAddress,Account.ShippingCity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name, CreatedDate, TCP_Order_Status__c,Remarks__c,Chemical_GSAP_P_31__c,Third_Party__c, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from order_line_items__r Order By CreatedDate) from Order where recordtypeid=:tcpOrderRecTypeid AND Sold_To__c='+'\''+ordWrap.soldToId+'\'';
                    } 
                    Integer queryNoOfDays=TCP_Utilities.getQueryDaysForSelectedTile(selectedTile); 
                    if(queryNoOfDays!=null){
                        queryString +=TCP_Constants.CREATEDDATE_LASTNDAYS+queryNoOfDays;
                    }    
                    
                    Boolean executeOrderQuery = false;
                    Boolean executeOrdLineQuery = false;
                    if(String.isNotBlank(ordWrap.poNumber)){
                        queryString += ' AND PoNumber='+'\''+ordWrap.poNumber+'\'';
                        executeOrderQuery = true;
                    }
                    if(String.isNotBlank(ordWrap.shipToId)){
                        queryString += ' AND Ship_To__c='+'\''+ordWrap.shipToId+'\'';
                        executeOrderQuery = true;
                    }
                    String orderStatus = String.isNotBlank(ordWrap.status) ? ordWrap.status : defaultStatus;
                    if(String.isNotBlank(orderStatus)){
                        if(orderStatus.contains(';')){
                            String[] statusList = orderStatus.split(';');
                            String status = '';
                            for(String ordStatus : statusList){
                                if(String.isNotBlank(status)){
                                    status += ',';
                                }
                                status += '\''+ordStatus+'\'';
                                
                            }
                            queryString += ' AND TCP_Order_Status__c IN ('+status+')';
                        }else{
                            queryString += ' AND TCP_Order_Status__c='+'\''+orderStatus+'\'';
                        }
                        executeOrderQuery = true;
                    }
                    if(String.isNotBlank(ordWrap.deliveryTerms)){
                        queryString += ' AND Delivery_Terms__c='+'\''+ordWrap.deliveryTerms+'\'';
                        executeOrderQuery = true;
                    }
                    if(String.isNotBlank(ordWrap.modeOfTransport)){
                        queryString += ' AND Mode_of_Transport__c='+'\''+ordWrap.modeOfTransport+'\'';
                        executeOrderQuery = true;
                    }
                    if(String.isNotBlank(ordWrap.orderedBy)){
                        queryString += ' AND Ordered_By__c='+'\''+ordWrap.orderedBy+'\'';
                        executeOrderQuery = true;
                    }
                    if(String.isNotBlank(ordWrap.fullfilledBy)){
                        executeOrderQuery = true;
                        if(ordWrap.fullfilledBy == 'ChemicalGSAP'){
                            queryString += ' AND Chemical_GSAP_P_31__c = true';
                        }else if(ordWrap.fullfilledBy == 'ThirdParty'){
                            queryString += ' AND Third_Party__c=true'; 
                        }
                    }
                    if(String.isNotBlank(ordWrap.orderPriority)){
                        executeOrderQuery = true;
                        switch on ordWrap.orderPriority {
                            when 'Rush Order' {
                                queryString += ' AND Rush_Order__c=true';
                            }
                            when 'Late Order' {
                                queryString += ' AND Late_Order__c=true';
                            }
                            when 'Last Minute' {
                                queryString += ' AND Last_Minute_Changes__c=true';
                            }
                            when else {
                                executeOrderQuery = true;
                            }
                        }
                    }
    
                    String lineQueryString = 'SELECT Order__c FROM TCP_OrderLineItem__c where Order__r.Sold_To__c ='+'\''+ordWrap.soldToId+'\'';
                    if(String.isNotBlank(ordLineWrap.productId)){
                        String ordProduct=ordLineWrap.productId;
                        system.debug('Checking ordProduct '+ordProduct);
                        if(ordProduct.contains(';')){
                            system.debug('Coming inside if');
                            String[] prodList = ordProduct.split(';');
                            String prod = '';
                            system.debug('Checking prodlist '+prodList);
                            for(String pro : prodList){
                                if(String.isNotBlank(prod)){
                                    prod += ',';
                                }
                                prod += '\''+pro+'\'';
                                
                            }
                            system.debug('Checking prod '+prod);
                            lineQueryString += ' AND Product__c IN ('+prod+')';
                        }else{
                            lineQueryString += ' AND Product__c='+'\''+ordProduct+'\'';
                        }
                        executeOrdLineQuery = true;
                        //lineQueryString += ' AND Product__c='+'\''+ordLineWrap.productId+'\'';
                        system.debug('Checking Line Query String '+lineQueryString);
                    }
                    
                    if(String.isNotBlank(ordLineWrap.dateType) && String.isNotBlank(ordLineWrap.fromDate) && String.isNotBlank(ordLineWrap.toDate)){
                            
                            switch on ordLineWrap.dateType {
                                when 'DueDate' {
                                    executeOrdLineQuery = true;
                                    lineQueryString += ' AND GSAP_Due_Date__c >='+ordLineWrap.fromDate+ ' AND GSAP_Due_Date__c <='+ordLineWrap.toDate;
                                }
                                when 'DeliveryDate' {
                                    executeOrdLineQuery = true;
                                    lineQueryString += ' AND Delivery_Collection_Date__c >='+ordLineWrap.fromDate+ ' AND Delivery_Collection_Date__c <='+ordLineWrap.toDate;
                                }
                                when 'DispatchDate' {
                                    executeOrdLineQuery = true;
                                    lineQueryString += ' AND GSAP_Dispatch_Date__c >='+ordLineWrap.fromDate + ' AND GSAP_Dispatch_Date__c <='+ordLineWrap.toDate;
                                }
                                when else {
                                    executeOrdLineQuery = true;
                                }
                            }
                        }
                    if(executeOrdLineQuery){
                        lineQueryString = ' AND Id IN (' + lineQueryString +')';
                        queryString += lineQueryString;   
                    }
                    if(executeOrderQuery || executeOrdLineQuery){
                        queryString +=TCP_Constants.ORD_BY_CREATEDDATE;
                        System.debug('==>output:'+queryString);
                        ordList = Database.query(queryString);
                    }
                    for(Order ordObj : ordList){
                        List<TCP_OrderLineItem__c> ordLineList = ordObj.order_line_items__r;
                        if(String.isNotBlank(userType) && userType == 'End User'){
                            ordWrapList.add(prepareOrderWrapperEU(ordObj,ordLineList));
                        }else if(String.isNotBlank(userType) && userType == 'Comm Ops User'){
                            ordWrapList.add(prepareOrderWrapperCU(ordObj,ordLineList));
                        } 
                    }  
                }   
            } catch (Exception e) {
                TCP_ExceptionLogClass.insertExceptionRecord('TCP Filter',e.getMessage(),'TCP_OrderController','getOrderDetailsByFilter','Exception');
                throw new AuraHandledException(e.getMessage());
            }
            return ordWrapList;
        }
        
        @AuraEnabled(cacheable=true)
        public static List<TCP_OrderWrapper> getOrderDetailsByWONumber(String woNumber){
            List<Order> orderData = new List<Order>();
            List<TCP_OrderWrapper> ordWrapList = new List<TCP_OrderWrapper>();
            try {
                
                     String query='SELECT Id,Sold_To__c,TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c, Sales_Order_Number__c, Account.ShippingAddress,Account.Shippingcity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name,ordered_by__c, CreatedDate, TCP_Order_Status__c,Chemical_GSAP_P_31__c,Third_Party__c,Late_Order__c,Rush_Order__c,Last_Minute_Changes__c,Reviewed_By__r.Name,Reviewed_Date_Time__c,Remarks__c, Ordered_By__r.Name, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r Order By CreatedDate) from Order where OrderNumber =:woNumber and recordtype.id=:tcpOrderRecTypeid';               
                   
                     OrderData=Database.query(query);
                    for(Order ordObj : orderData){
                        List<TCP_OrderLineItem__c> ordLineList = ordObj.order_line_items__r;
                        ordWrapList.add(prepareOrderWrapperCU(ordObj,ordLineList));
                    }
            } catch (Exception e) {
                system.debug('getOrderDetailsByWONumber exception '+e.getMessage() + e.getCause());
                TCP_ExceptionLogClass.insertExceptionRecord('Order details by woNumber',e.getMessage(),'TCP_OrderController','getOrderDetailsByWONumber','Exception');
            throw new AuraHandledException(e.getMessage());
            }
            if(!ordWrapList.isEmpty()){
                return ordWrapList;
            }else{
                return null;
            }
            
        }
    }