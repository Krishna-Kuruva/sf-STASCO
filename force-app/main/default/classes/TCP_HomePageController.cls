public with sharing class TCP_HomePageController {
    public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    @AuraEnabled(cacheable=true)
    public static Account getAccountDataOfEndUser(){
        Account accData= new account();
        try{
            Map<String,String> accountDetailsMap = new Map<String,String>();
            ID accountId = getAccountId();
            accData = [SELECT Id, Name, Active__c FROM Account where Active__c = true AND recordtypeid =: tcpAccountRecTypeid AND id=:accountId];
          
        } catch(Exception e){
            TCP_ExceptionLogClass.insertExceptionRecord('Account data exception',e.getMessage(),'TCP_HomePageController','getAccountDataOfEndUser','Exception');
           // throw new AuraHandledException(e.getMessage());
        }
          return accData;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getAccountDetails(){
        List<AccountWrapper> accWrap = new List<AccountWrapper>();
        try {
            User userData = TCP_Utilities.getLoggedInUserDetails();
            if(userData.TCP_Role__C == 'CommOpps user'){
                List<Account_Contact_Relationship__c> accList = getAccountDetailsOfComOps(userData);
                if(accList.size()>0){
                    for(Account_Contact_Relationship__c account : accList){
                        AccountWrapper wrap = new AccountWrapper();
                        wrap.Id = account.Account__c;  
                        wrap.Name = account.Account__r.Name;
                        accWrap.add(wrap);
                    }
                }
            }else if(userData.TCP_Role__C == 'End user'){
                AccountWrapper wrap = new AccountWrapper();
                Account accountData = getAccountDataOfEndUser();
                wrap.Id = accountData.Id;
                wrap.Name = accountData.Name;
                accWrap.add(wrap);
            }
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Account data exception',e.getMessage(),'TCP_HomePageController','getAccountDetails','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return accWrap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Relationship__c> getAccountDetailsOfComOps(User userData){
        List<Account_Contact_Relationship__c> accountData = new List<Account_Contact_Relationship__c>();
        try{  
            accountData = [SELECT id, Account__r.name, Account__r.Active__c,Account__c FROM Account_Contact_Relationship__c WHERE Account__r.recordtypeid =: tcpAccountRecTypeid AND  Account__r.Active__c = true AND Portal_User_Contact__r.Email =: userData.Email order by CreatedDate ASC];
        }catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return accountData;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean loggedInAsTcpUser(){
        try{
            User userData = [SELECT Id,FirstName, TCP_Role__C, LastName,Email,ContactId,Logon_as_TCP_User__c FROM User where Id =: UserInfo.getUserId()];
            if(userData.TCP_Role__C == 'CommOpps user'){
                return true;
            }else if(userData.TCP_Role__C == 'End user'){
                return false;
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('user details exception',e.getMessage(),'TCP_HomePageController','loggedInAsTcpUser','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return false;
    }

    public static ID getAccountId(){
        ID contactId = [SELECT ContactId FROM User where id =:UserInfo.getUserId()].contactId;
        return [SELECT AccountID FROM Contact where id =: contactid].AccountId;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccDetailsByParentId(String parentAccId){
        try{
            if(String.isNotBlank(parentAccId)){
                List<Account> childAccDetails = new List<Account>();
                List<Account> accList = [SELECT id ,(SELECT id, Name, AccountNumber, ShippingAddress, toLabel(Customer_Type__c) FROM ChildAccounts) FROM Account where Active__c = true AND recordtypeid =: tcpAccountRecTypeid AND id =:parentAccId];
                childAccDetails.addAll(accList[0].ChildAccounts);
                if(childAccDetails.size()>0){
                    return childAccDetails;
                } 
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Account details exception',e.getMessage(),'TCP_HomePageController','getAccDetailsByParentId','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getCustomerByAccountId(String accountId){
        try{
            List<Account> accData = [SELECT id, AccountNumber,Active__c, Name, ShippingAddress FROM Account where Active__c = true AND recordtypeid =: tcpAccountRecTypeid AND id=:accountId];
            if(accData.size()>0){
                return accData;
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Account details exception',e.getMessage(),'TCP_HomePageController','getCustomerByAccountId','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<TCP_Product_Customer__c> getProductDetails(String soldToId, String shipToId){
        try{
            if(String.isNotBlank(soldToId) && String.isNotBlank(shipToId)){
                Set<String> accountIds = new Set<String>{soldToId,shipToId};
                List<TCP_Product_Customer__c> productList = [SELECT id, Active__c, Product__r.ProductCode, Account__r.Id, Product__r.Id, Product__r.Name FROM TCP_Product_Customer__c WHERE Account__r.Id IN :accountIds AND Active__c = true AND Product__r.IsActive = true  order by  Account__r.Customer_Type__c desc];
                // if(productList.size()>0){
                //     return productList;
                // }
                Map<Id,TCP_Product_Customer__c> prodMap = new  Map<Id,TCP_Product_Customer__c>();
                for(TCP_Product_Customer__c prodCust : productList){
                    if(!prodMap.containsKey(prodCust.Product__r.Id)){
                        prodMap.put(prodCust.Product__r.Id,prodCust);
                    }
                }
                return prodMap.values();
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('product details exception',e.getMessage(),'TCP_HomePageController','getProductDetails','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return null;       
    }

    @AuraEnabled(cacheable=true)
    public static List<TCP_Product_Customer__c> getProductDetailsBySearchKey(String searchKey, String soldToId, String shipToId){
        try{
            if(String.isNotBlank(soldToId) && String.isNotBlank(shipToId) && String.isNotBlank(searchKey)){
                Set<String> accountIds = new Set<String>{soldToId,shipToId};
                searchKey = '%' + searchKey + '%';
                List<TCP_Product_Customer__c> productList = [SELECT id, Active__c, Account__r.Id, Product__r.Id, Product__r.Name FROM TCP_Product_Customer__c WHERE Account__r.Id IN :accountIds AND Product__r.Name LIKE :searchKey AND Active__c = true AND Product__r.IsActive = true order by Product__r.Name];
                if(productList.size()>0){
                    return productList;
                }
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('product search exception',e.getMessage(),'TCP_HomePageController','getProductDetailsBySearchKey','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListValues(String objectApiName, String fieldApiName){
        List<String> pickListValuesList =new List<String>();
        try{
            
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldApiName).getDescribe().getPickListValues();
            for (Schema.PicklistEntry a : pick_list_values) { 
                pickListValuesList.add(a.getValue());
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Picklist exception',e.getMessage(),'TCP_HomePageController','getPickListValues','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }

    @AuraEnabled(cacheable=false) 
    public static Order getOrderNumberOnSave(TCP_OrderWrapper orderWrapper, List<TCP_OrderLineItemWrapper> orderLineWrapList, List<String> draftOLINotToBeDeleted, boolean isResumeDraftOrder){
        try {
            system.debug('****draftOLINotToBeDeleted'+draftOLINotToBeDeleted);
            if(orderWrapper != null){
                if((isResumeDraftOrder==true) && (String.isNotBlank(orderWrapper.status)) && (String.valueOf(orderWrapper.Id)!=null)){
                    system.debug('****'+draftOLINotToBeDeleted);
                   List<TCP_OrderLineItem__c> olistobeDeleted=new List<TCP_OrderLineItem__c>([select id from TCP_OrderLineItem__c where id NOT in:draftOLINotToBeDeleted and order__c=:orderWrapper.Id]);
                    system.debug('****'+olistobeDeleted);
                    delete olistobeDeleted;
                }
                Order orderObj = new Order();
                if(String.isNotBlank(orderWrapper.name)){
                    orderObj.Name = orderWrapper.name;
                }
                if(String.isNotBlank(orderWrapper.poNumber)){
                    orderObj.PoNumber = orderWrapper.poNumber;
                }
                if(String.isNotBlank(orderWrapper.deliveryTerms)){
                    orderObj.Delivery_Terms__c = orderWrapper.deliveryTerms;
                }
                if(String.isNotBlank(orderWrapper.modeOfTransport)){
                    orderObj.Mode_of_Transport__c = orderWrapper.modeOfTransport;
                }
                if(String.isNotBlank(orderWrapper.otherInstructions)){
                    orderObj.Order_Other_Instructions__c = orderWrapper.otherInstructions;
                }
                if(String.isNotBlank(orderWrapper.soldToId)){
                    orderObj.Sold_To__c = orderWrapper.soldToId;
                    orderObj.AccountId = orderWrapper.soldToId;
                }
                if(String.isNotBlank(orderWrapper.shipToId)){
                    orderObj.Ship_To__c = orderWrapper.shipToId;
                }
                if(String.isNotBlank(orderWrapper.billToId)){
                    orderObj.Bill_To__c = orderWrapper.billToId;
                }
                // if(String.isNotBlank(orderWrapper.soldToNumber)){
                //     orderObj.AccountNumber = orderWrapper.soldToNumber;
                // }
                if(String.isNotBlank(orderWrapper.shipToNumber)){
                    orderObj.ShipToNo__c = orderWrapper.shipToNumber;
                }
                if(String.isNotBlank(orderWrapper.soldToName)){
                    orderObj.Customer_Name__c = orderWrapper.soldToName;
                }
                if(String.isNotBlank(orderWrapper.billToNumber)){
                    orderObj.BillToNo__c = orderWrapper.billToNumber;
                }
                if(String.isNotBlank(orderWrapper.payerId)){
                    orderObj.Payer__c = orderWrapper.payerId;
                }
                if(String.isNotBlank(orderWrapper.payerNumber)){
                    orderObj.PayerNo__c = orderWrapper.payerNumber;
                }
                if(String.isNotBlank(orderWrapper.status)){
                    orderObj.Status = 'Draft';
                    orderObj.TCP_Order_Status__c = orderWrapper.status;
                }
                if(String.isNotBlank(orderWrapper.id)){
                    orderObj.Id = orderWrapper.id;
                }
                if(orderObj != null){
                    orderObj.EffectiveDate = System.today();
                    String userId = getOrderedByUserId();
                    orderObj.Ordered_By__c = userId;
                    orderObj.recordtypeid = tcpOrderRecTypeid;
                    Upsert orderObj;
                    Order orderDetails = [SELECT id,TCP_Order_Status__c, OrderNumber,AccountId,createdby.contactId,createdbyId FROM Order where id=:orderObj.ID];
                    saveOrderLineItems(orderLineWrapList, orderDetails.Id);
                    if(orderDetails.TCP_Order_Status__c == 'Submitted'){
                        sendOrderAcknowledgement(orderDetails.id, orderDetails.createdby.contactId,orderDetails.AccountId,Orderdetails.createdbyId);
                    }
                    return orderDetails;
                }
            }       
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('place order exception',e.getMessage(),'TCP_HomePageController','getOrderNumberOnSave','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static String getCountOfOrders(String soldToId, String status){    
        List<Order> ordData = new List<Order>();
        try {
            ordData = [Select id, orderNumber, TCP_Order_Status__c from Order where Sold_To__c =: soldToId AND TCP_Order_Status__c=: status AND recordtypeid =: tcpOrderRecTypeid];
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('order count exception',e.getMessage(),'TCP_HomePageController','getCountOfOrders','Exception');
            //throw new AuraHandledException(e.getMessage());
            
        }
        return ordData.Size()+'';
    }
    
    @AuraEnabled
    public static Map<String,String> getCountOfOrdersEU(String soldToId){    
        Map<String,String> ordCountData = new Map<String,String>();
        try {
            List<String> euTilesList=new List<string>{system.label.TCP_CurrentOrderLabel+system.label.TCP_OrderLabel,system.label.TCP_RejectLabel+system.label.TCP_CancelledOrderLabel,system.label.TCP_PreviousOrdersLabel};
            for(String tileName:euTilesList)
            {
              List<string> selectedStatuses=TCP_Utilities.getStatusForSelectedTile(tileName,false);
              If(selectedStatuses!=null){
               String query='SELECT count() from Order where Sold_To__c =: soldToId and tcp_order_status__c In:selectedStatuses';
               Integer queryNoOfDays=TCP_Utilities.getQueryDaysForSelectedTile(tileName); 
                     
               if(queryNoOfDays!=null){
                        query +=' and createddate=LAST_N_DAYS:'+queryNoOfDays;
                }
                query += ' AND recordtypeid =' + '\''+tcpOrderRecTypeid+'\'';
                String countOfRecords=string.valueOf(Database.countQuery(query));
                if(countOfRecords.length()==1)
                {
                    countOfRecords='0'+countOfRecords;
                }
                ordCountData.put(tileName,countOfRecords);
            }
            }
            
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('order count exception',e.getMessage(),'TCP_HomePageController','getCountOfOrdersEU','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
       return ordCountData;
    }

    @AuraEnabled
    public static Map<String,String> getCountOfOrdersCU(String soldToId){    
        Map<String,String> ordCountData = new Map<String,String>();
        try {
            List<String> cuTilesList=new List<string>{system.label.TCP_ReviewOrApprovalLabel+system.label.TCP_ApprovalLabel,system.label.TCP_ModificationOrCancelLabel+system.label.TCP_CancellationReqLabel,system.label.TCP_CurrentOrderCULabel,system.label.TCP_PreviousOrdersLabel};
            for(String tileName:cuTilesList)
            {
              List<string> selectedStatuses=TCP_Utilities.getStatusForSelectedTile(tileName,true);
              If(selectedStatuses!=null){
               String query='SELECT count() from Order where Sold_To__c =: soldToId and tcp_order_status__c In:selectedStatuses';
               Integer queryNoOfDays=TCP_Utilities.getQueryDaysForSelectedTile(tileName); 
                  
               if(queryNoOfDays!=null){
                        query +=' and createddate=LAST_N_DAYS:'+queryNoOfDays;
                }
                query += ' AND recordtypeid =' + '\''+tcpOrderRecTypeid+'\'';
                String countOfRecords=string.valueOf(Database.countQuery(query));
                if(countOfRecords.length()==1)
                {
                    countOfRecords='0'+countOfRecords;
                }
                ordCountData.put(tileName,countOfRecords);
            }
            }
            
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('order count exception',e.getMessage(),'TCP_HomePageController','getCountOfOrdersCU','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
       return ordCountData;
    }

    @AuraEnabled(cacheable=false) 
    public static void saveOrderLineItems(List<TCP_OrderLineItemWrapper> orderLineWrapList, String orderId){
        try{ 
            if(orderLineWrapList != null){
                List<TCP_OrderLineItem__c> OrdLineItemList = new List<TCP_OrderLineItem__c>();
                Integer salesItemNo = 10;
                for(TCP_OrderLineItemWrapper wrap: orderLineWrapList){
                    TCP_OrderLineItem__c objData = new TCP_OrderLineItem__c();
                    objData.Sales_Order_Line_Item_No__c = String.valueOf(salesItemNo).leftPad(6, '0');
                    if(String.isNotBlank(wrap.shellContractNo)){
                        objData.Contract_No__c = wrap.shellContractNo;
                    }
                    if(String.isNotBlank(wrap.deliveryCollDate)){
                        objData.Delivery_Collection_Date__c = Date.valueOf(wrap.deliveryCollDate);
                    }
                    
                    if(String.isNotBlank(wrap.materialName)){
                        objData.Material_Name__c = wrap.materialName;
                    }
                    if(String.isNotBlank(wrap.materialNumber)){
                        objData.MaterialNumber__c = wrap.materialNumber;
                    }
                    if(String.isNotBlank(wrap.materialNumber)){
                        objData.MaterialNumber__c = wrap.materialNumber;
                    }
                    if(String.isNotBlank(orderId)){
                        objData.Order__c = orderId;   
                    }
                    if(String.isNotBlank(wrap.productId)){
                        objData.Product__c = wrap.productId;
                    }
                    if(String.isNotBlank(wrap.quantity)){
                        objData.Quantity__c = decimal.valueOf(wrap.quantity);
                    }
                    if(String.isNotBlank(wrap.unit)){
                        objData.Unit__c = wrap.unit;
                    }
                    if(String.isNotBlank(wrap.instructions)){
                        objData.Other_Instruction__c = wrap.instructions;
                    }
                    if(String.isNotBlank(wrap.id)){
                        objData.Id = wrap.id;
                    }
                    salesItemNo += 10;
                    OrdLineItemList.add(objData);
                }
                if(OrdLineItemList.size()>0){
                    Upsert OrdLineItemList;
                }
            }

        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
    }
    
    @future
    public static void sendOrderAcknowledgement(Id recordId, Id recipientId, Id accountId, Id recipientUserId){
      try {
       		 TCP_EmailService.sendEmail(recordId,recipientId,accountId,recipientUserId,'TCP_Order_acknowledgement_EN_US',true);
          }
        catch(Exception excptn) {
            throw excptn;
        }
    }

    public class AccountWrapper{
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
    }

    public static String getOrderedByUserId(){
        String userId;
        try{
            list<AuthSession> sessions = [SELECT Id, LoginType, UsersId, IsCurrent, UserType from AuthSession where UsersId=: UserInfo.getUserId() AND LoginType = 'Chatter Communities External User' AND IsCurrent = true];
            if(sessions.size()>0 && sessions[0].UserType == 'PowerCustomerSuccess'){
                userId = UserInfo.getUserId();
            }else{
                User userObj = [SELECT Id,Name,Email, Profile.Name,ContactId FROM User where Id =: UserInfo.getUserId()]; 
                if(userObj.ContactId!=null){
                Contact contactObj = [SELECT Id,Name,TCP_User_Clicked__c,TCP_User_Clicked__r.Name FROM Contact where Id =: userObj.ContactId];
                 userId = contactObj.TCP_User_Clicked__c;
                }
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('order by exception',e.getMessage(),'TCP_HomePageController','getOrderedByUserId','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return userId;
    }

    @AuraEnabled(cacheable=true)
    public static List<TCP_Product_Customer__c> getAllProductDetailsBySoldToId(String soldToId){
        
        try{
            if(String.isNotBlank(soldToId)){
                Set<String> accountIds = new Set<String>{soldToId};
                List<Account> accList = getAccDetailsByParentId(soldToId);
                if(accList.size()>0){
                    for(Account acc: accList){
                        if(acc.Customer_Type__c == 'Ship To'){
                            accountIds.add(acc.Id);
                        }
                    }
                }
                List<TCP_Product_Customer__c> productList = [SELECT id, Active__c, Product__r.ProductCode, Account__r.Id, Product__r.Id, Product__r.Name FROM TCP_Product_Customer__c WHERE Account__r.Id IN :accountIds AND Active__c = true AND Product__r.IsActive = true order by Product__r.Name];
                Map<String,TCP_Product_Customer__c> prodMap = new Map<String,TCP_Product_Customer__c>();
                for(TCP_Product_Customer__c prodObj : productList){
                    prodMap.put(prodObj.Product__r.Id,prodObj);
                }
                if(prodMap.size()>0){
                    return prodMap.values();
                }
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('product details exception',e.getMessage(),'TCP_HomePageController','getAllProductDetailsBySoldToId','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return null;       
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getCustomerBySoldToAndType(String parentAccId, String type){
        try{
            if(String.isNotBlank(parentAccId)){
                List<Account> childAccDetails = new List<Account>();
                List<Account> accList = [SELECT id ,(SELECT id, Name, AccountNumber, ShippingAddress, toLabel(Customer_Type__c) FROM ChildAccounts) FROM Account where Active__c = true AND recordtypeid =: tcpAccountRecTypeid AND id =:parentAccId];
            
                for(Account accObj : accList[0].ChildAccounts){
                    if(accObj.Customer_Type__c == type){
                        childAccDetails.add(accObj);
                    }
                }
                
                if(childAccDetails.size()>0){
                    return childAccDetails;
                } 
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Account details exception',e.getMessage(),'TCP_HomePageController','getCustomerBySoldToAndType','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
            return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Order> getOrderedBySoldToId(String soldToId){
        try{
            if(String.isNotBlank(soldToId)){
            List<Order> orderList = [SELECT  Sold_To__c, Ordered_By__c, Ordered_By__r.Id, Ordered_By__r.Name from Order where Sold_To__c =:soldToId  AND Ordered_By__c  != null];
            if(orderList.size()>0){
                Map<Id,Order> ordMap = new Map<Id, Order>();
                for(Order ordObj: orderList){
                    ordMap.put(ordObj.Ordered_By__r.Id,ordObj);
                }
                if(ordMap.size()>0){
                    return ordMap.values();
                }
            }
            
            }
        }catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Ordered by exception',e.getMessage(),'TCP_HomePageController','getOrderedBySoldToId','Exception');
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }



    
}