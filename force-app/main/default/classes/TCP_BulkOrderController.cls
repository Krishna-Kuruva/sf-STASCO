public with sharing class TCP_BulkOrderController {
    public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Relationship__c> getCustomerDetails(){
        List<Account_Contact_Relationship__c> acrList = new List<Account_Contact_Relationship__c>();
        try {
            User userData = TCP_Utilities.getLoggedInUserDetails();
            if(userData.TCP_Role__C == 'CommOpps user'){
                acrList = [SELECT id, Account__r.name, Account__r.Active__c, Account__c,  Account__r.AccountNumber, Account__r.ShippingAddress FROM Account_Contact_Relationship__c WHERE Account__r.recordtypeid =: tcpAccountRecTypeid AND Portal_User_Contact__r.Email =:userData.Email AND Account__r.Active__c = true order by CreatedDate ASC];
                if(acrList.size()>0){
                    return acrList;
                }
            }
            
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Bulk order exception',e.getMessage(),'TCP_BulkOrderController','getCustomerDetails','Exception');
            throw new AuraHandledException(e.getMessage());
        }
        return acrList;
    }

    @AuraEnabled
    public static List<user> getContactsByCustomerId(String soldToId){
        try {
            return [Select Id, Name, ContactId, Contact.Name, IsActive from user where IsActive = true AND Contact.AccountId =: soldToId order by Contact.Name];
            
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Bulk order exception',e.getMessage(),'TCP_BulkOrderController','getContactsByCustomerId','Exception');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Order> saveBulkOrderDetails(List<TCP_OrderWrapper> ordWrapList){
        List<Order> orderList = new List<Order>();
        List<TCP_OrderLineItem__c> ordLineItemList = new List<TCP_OrderLineItem__c>();
        Map<String,List<TCP_OrderLineItemWrapper>> orderLineMap = new Map<String,List<TCP_OrderLineItemWrapper>>();
        try {
            if(ordWrapList.size()>0){
                List<Id> orderIds = new List<Id>();
                List<Id> requestedByIds = new List<Id>();
                List<Id> accountIds = new List<Id>();
                for(TCP_OrderWrapper orderWrapper: ordWrapList){
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
                        accountIds.add(orderWrapper.soldToId);
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
                    if(String.isNotBlank(orderWrapper.requestedById)){
                        orderObj.TCP_Bulk_Order_Requested_by__c = orderWrapper.requestedById;
                    }
                    orderObj.EffectiveDate = System.today();
                    orderObj.Ordered_By__c = UserInfo.getUserId();
                    String randomNumber = String.valueOf(Integer.valueof((Math.random() * 100000)));
                    orderObj.TCP_System_BulkOrderNumber__c = randomNumber;
                    orderLineMap.put(randomNumber, orderWrapper.orderLineItemWrapList);
                    orderObj.recordtypeid = tcpOrderRecTypeid;
                    requestedByIds.add(orderWrapper.requestedById);
                    orderList.add(orderObj);
                   
                }
                if(orderList.size()>0){
                    Database.insert(orderList, true);
                }
                for(Order ord : orderList){
                    if(orderLineMap.containsKey(ord.TCP_System_BulkOrderNumber__c)){
                        orderIds.add(ord.Id);
                        ordLineItemList.addAll(saveOrderLineItems(orderLineMap.get(ord.TCP_System_BulkOrderNumber__c), ord.Id));
                    }
                }
                if(ordLineItemList.size()>0){
                    Insert ordLineItemList;
                }
                if(orderIds.size()>0 && orderIds.size()<=10){
                    sendOrderAcknowledgement(orderIds, requestedByIds, accountIds, UserInfo.getUserId());
                }else if(orderIds.size()>10 && orderIds.size()<=20){
                    List<Id> orderIdChunk1 = new List<Id>();
                    List<Id> requestedByIdChunk1  = new List<Id>();
                    List<Id> accountIdChunk1  = new List<Id>();
                    for(Integer i=0;i<10;i++){
                        orderIdChunk1.add(orderIds[i]);
                        requestedByIdChunk1.add(requestedByIds[i]);
                        accountIdChunk1.add(accountIds[i]);
                    }
                    if(orderIdChunk1.size()>0){
                        sendOrderAcknowledgement(orderIdChunk1, requestedByIdChunk1, accountIdChunk1, UserInfo.getUserId());
                    }
                    List<Id> orderIdChunk2 = new List<Id>();
                    List<Id> requestedByIdChunk2  = new List<Id>();
                    List<Id> accountIdChunk2  = new List<Id>();
                    
                    for(Integer i=10;i<orderIds.size();i++){
                        orderIdChunk2.add(orderIds[i]);
                        requestedByIdChunk2.add(requestedByIds[i]);
                        accountIdChunk2.add(accountIds[i]);
                    }
                    if(orderIdChunk2.size()>0){
                        sendOrderAcknowledgement(orderIdChunk2, requestedByIdChunk2, accountIdChunk2, UserInfo.getUserId());
                    }

                }else if(orderIds.size()>20 && orderIds.size()<=30){
                    //chunk 1
                    List<Id> orderIdChunk1 = new List<Id>();
                    List<Id> requestedByIdChunk1  = new List<Id>();
                    List<Id> accountIdChunk1  = new List<Id>();
                    for(Integer i=0;i<10;i++){
                        orderIdChunk1.add(orderIds[i]);
                        requestedByIdChunk1.add(requestedByIds[i]);
                        accountIdChunk1.add(accountIds[i]);
                    }
                    if(orderIdChunk1.size()>0){
                        sendOrderAcknowledgement(orderIdChunk1, requestedByIdChunk1, accountIdChunk1, UserInfo.getUserId());
                    }
                    // chunk 2
                    List<Id> orderIdChunk2 = new List<Id>();
                    List<Id> requestedByIdChunk2  = new List<Id>();
                    List<Id> accountIdChunk2  = new List<Id>();
                    
                    for(Integer i=10;i<20;i++){
                        orderIdChunk2.add(orderIds[i]);
                        requestedByIdChunk2.add(requestedByIds[i]);
                        accountIdChunk2.add(accountIds[i]);
                    }
                    if(orderIdChunk2.size()>0){
                        sendOrderAcknowledgement(orderIdChunk2, requestedByIdChunk2, accountIdChunk2, UserInfo.getUserId());
                    }
                    //chunk 3
                    List<Id> orderIdChunk3 = new List<Id>();
                    List<Id> requestedByIdChunk3  = new List<Id>();
                    List<Id> accountIdChunk3  = new List<Id>();
                    
                    for(Integer i=20;i<orderIds.size();i++){
                        orderIdChunk3.add(orderIds[i]);
                        requestedByIdChunk3.add(requestedByIds[i]);
                        accountIdChunk3.add(accountIds[i]);
                    }
                    if(orderIdChunk3.size()>0){
                        sendOrderAcknowledgement(orderIdChunk3, requestedByIdChunk3, accountIdChunk3, UserInfo.getUserId());
                    }

                }
            }
        } catch (Exception e) {
            TCP_ExceptionLogClass.insertExceptionRecord('Bulk order exception',e.getMessage(),'TCP_BulkOrderController','saveBulkOrderDetails','Exception');
            throw new AuraHandledException(e.getMessage());
        }
        return orderList;
    }

    public static List<TCP_OrderLineItem__c> saveOrderLineItems(List<TCP_OrderLineItemWrapper> orderLineWrapList, String orderId){
        List<TCP_OrderLineItem__c> OrdLineItemList = new List<TCP_OrderLineItem__c>();
        try{ 
            if(orderLineWrapList != null){  
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
                    salesItemNo += 10;
                    OrdLineItemList.add(objData);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return OrdLineItemList;
    }

    @future
    public static void sendOrderAcknowledgement(List<Id> recordId, List<Id> recipientId, List<Id> accountId, Id recipientUserId){
        try{
            for(Integer i=0; i<recordId.size();i++){
                sendBulkEmail(recordId[i],recipientId[i],accountId[i],recipientUserId,'TCP_Order_acknowledgement_EN_US',true);
            }
        }
        catch(Exception excptn) {
            throw excptn;
        }
    }

    public static void sendBulkEmail(Id recordId, Id recipientId, id accountId, id recipientUserId, String templateName,Boolean useOrgAddress) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(String.isNotEmpty(templateName))
            {
                
                EmailTemplate emailtemplate = [SELECT DeveloperName, Id, TemplateType FROM EmailTemplate WHERE DeveloperName =:templateName];
                mail.setTemplateId(emailtemplate.id);
            }
            if(useOrgAddress)
            {
                
                OrgWideEmailAddress OrgWideEmail = [Select id From OrgWideEmailAddress o where o.DisplayName= :Label.TCP_From_Email_Address];
          	  mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
            }
            if(accountId!=null)
            {
               
                Account accSalesorg = [Select id,sales_area__r.Sales_Region__c from account where id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
          	    String AccountSalesRegion=accSalesorg.sales_area__r.Sales_Region__c;
                System.debug('after accsales::'+AccountSalesRegion);
                if(AccountSalesRegion!=null){
                     System.debug('inside accsales::');
                    TCP_DistributionEmailList__c ccListBasedOnRegion = TCP_DistributionEmailList__c.getValues(AccountSalesRegion);
                    System.debug('inside accsales  adsds::'+ccListBasedOnRegion);
                        if(ccListBasedOnRegion!=null){
                           List<string> ccEmailList=ccListBasedOnRegion.TCP_Commops_Delivery_Lists__c.split(';'); 
                           mail.setCcAddresses(ccEmailList);
                        }
                }
            }
            if(recipientId!=null)
            {
                mail.settargetObjectId(Id.valueof(recipientId));
                mail.setSaveAsActivity(false);
            }
            else
            {
                mail.settargetObjectId(Id.valueof(recipientUserId));
                mail.setSaveAsActivity(false);
            }
            mail.setWhatId(Id.valueof(recordId));
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		 mails.add(mail);
            if(!mails.isempty()){
                if(!Test.isRunningTest()){
                	Messaging.sendEmail(mails);
                }
            }
        }
        catch(Exception excptn) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP EmailService',excptn.getMessage(),'TCP_EmailService','sendEmail','Exception');
            throw excptn;
        }
    }
}