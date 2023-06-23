public with sharing class TCP_OrderSearchController{
    public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
    @AuraEnabled
    public static List<TCP_OrderWrapper> getOrderDetailsBySearchKey(List<String> soldToIds, String searchKey, String defaultStatus, String userType, String selectedTile){
        List<TCP_OrderWrapper> ordWrapList = new List<TCP_OrderWrapper>();
        try {
            
            if(soldToIds.size()>0 && searchKey.length()>2){
                searchKey = '%' + searchKey + '%';
                List<Order> ordList = new List<Order>();
                List<Order> ordList2 = new List<Order>();
                
                String queryString = '';
                String queryStringForLineItem = '';
                if(String.isNotBlank(userType) && userType == 'Comm Ops User'){
                    queryString = 'SELECT Id,Sold_To__c,TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c, Sales_Order_Number__c, Account.ShippingAddress,Account.Shippingcity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name,ordered_by__c, CreatedDate, TCP_Order_Status__c,Chemical_GSAP_P_31__c,Third_Party__c,Late_Order__c,Rush_Order__c,Last_Minute_Changes__c,Reviewed_By__r.Name,Reviewed_Date_Time__c,Remarks__c, Ordered_By__r.Name, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_value__c,GSAP_Goods_Issue_Unit__c,GSAP_Goods_Issue_Status__c from order_line_items__r Order By CreatedDate) from Order where TCP_Order_Status__c!=\'Draft\' and Sold_To__c IN: soldToIds';
                }else if(String.isNotBlank(userType) && userType == 'End User'){
                    queryString = 'SELECT Id,Sold_To__c, TCP_Modification_Requested_By__r.name, TCP_Modification_Requested_Date__c, TCP_Cancellation_Placed_By__r.name, TCP_Cancellation_Requested_Date__c, Sales_Order_Number__c, Ordered_By__r.Name, Account.ShippingAddress,Account.ShippingCity, Ship_To__r.ShippingAddress, Bill_To__r.ShippingAddress, Customer_Name__c, Delivery_Terms__c, Mode_of_Transport__c, PoNumber, Order_Other_Instructions__c,OrderNumber, Name, Ship_To__r.Name, Bill_To__r.Name, CreatedDate, TCP_Order_Status__c,Remarks__c,Chemical_GSAP_P_31__c,Third_Party__c, (select id, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c, GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c from order_line_items__r Order By CreatedDate) from Order where Sold_To__c IN: soldToIds';
                } 
                Integer queryNoOfDays=TCP_Utilities.getQueryDaysForSelectedTile(selectedTile); 
                if(queryNoOfDays!=null){
                    queryString +=' and createddate=LAST_N_DAYS:'+queryNoOfDays;
                }

                queryString += ' AND recordtypeid =' + '\''+tcpOrderRecTypeid+'\'';

                if(String.isNotBlank(defaultStatus)){
                    if(defaultStatus.contains(';')){
                        String[] statusList = defaultStatus.split(';');
                        String status = '';
                        for(String ordStatus : statusList){
                            if(String.isNotBlank(status)){
                                status += ',';
                            }
                            status += '\''+ordStatus+'\'';
                            
                        }
                        queryString += ' AND TCP_Order_Status__c IN ('+status+')';
                    }else{
                        queryString += ' AND TCP_Order_Status__c='+'\''+defaultStatus+'\'';
                    }
                }

                queryStringForLineItem = queryString;

                queryString += ' AND ('+ 'OrderNumber' + ' LIKE ' + '\''+searchKey+'\'';
                queryString += formQueryString('Customer_Name__c', searchKey);
                queryString += formQueryString('Ship_To__r.Name', searchKey);
                queryString += formQueryString('Bill_To__r.Name', searchKey);
                queryString += formQueryString('Name', searchKey);
                queryString += formQueryString('TCP_Order_Status__c', searchKey);
                queryString += formQueryString('PoNumber', searchKey);
                queryString += formQueryString('Sales_Order_Number__c', searchKey);
                queryString += formQueryString('Mode_of_Transport__c', searchKey);
                queryString += formQueryString('Delivery_Terms__c', searchKey);
                queryString += formQueryString('Ordered_By__r.Name', searchKey);
                queryString += formQueryString('Reviewed_By__r.Name', searchKey);
                queryString += ') ';
                
                String lineQueryString = 'SELECT Order__c FROM TCP_OrderLineItem__c where Order__r.Sold_To__c IN: soldToIds';
                lineQueryString += ' AND ('+ 'Product__r.Name' + ' LIKE ' + '\''+searchKey+'\'';
                lineQueryString += formQueryString('MaterialNumber__c', searchKey);
                lineQueryString += formQueryString('Contract_No__c', searchKey);
                lineQueryString += formQueryString('Other_Instruction__c', searchKey);
                lineQueryString += formQueryString('GSAP_Mode_of_Transport_ID__c', searchKey);
                lineQueryString += formQueryString('GSAP_Bol_Delivery__c', searchKey);
                lineQueryString += ')';
                lineQueryString = ' AND Id IN (' + lineQueryString +')';
                queryStringForLineItem += lineQueryString;
                System.debug('Query String :=>'+queryString);
                ordList = Database.query(queryString);
                ordList2 = Database.query(queryStringForLineItem);
                ordList.addAll(ordList2);
                
                Map<Id, Order> orderMap = new Map<Id, Order>();
                for(Order ordObj : ordList){
                    orderMap.put(ordObj.Id, ordObj);
                }
                for(Order ordObj : orderMap.values()){
                    List<TCP_OrderLineItem__c> ordLineList = ordObj.order_line_items__r;
                    if(String.isNotBlank(userType) && userType == 'End User'){
                        ordWrapList.add(TCP_OrderController.prepareOrderWrapperEU(ordObj,ordLineList));
                    }else if(String.isNotBlank(userType) && userType == 'Comm Ops User'){
                        ordWrapList.add(TCP_OrderController.prepareOrderWrapperCU(ordObj,ordLineList));
                    } 
                }  
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Order Search exception',e.getMessage(),'TCP_OrderSearchController','getOrderDetailsBySearchKey','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return ordWrapList;
    }

    public static String formQueryString(String fieldName, String searchKey){
        return ' OR '+ fieldName + ' LIKE ' + '\''+searchKey+'\'';
    }
                
}