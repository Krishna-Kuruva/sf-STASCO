/**************************************************************************************************************************
 * Application  :   Trading and Supply  (TCP)
 * Description  :   Controller class for vf component TCP_OrderAckEmailTemplate 
 *                  built to send out order acknowledgement email 
 *              :   Added PDF generation functionality for place order confirmation               
***************************************************************************************************************************/

public with sharing class TCP_OrderAcknowEmailTemplateContrl {

    public list<Order> OrderDetails;
    public list<Order> OrderDetailsList;
    public list<TCP_OrderLineItem__c>LineItemDetails{get;set;}
    public List<ProdWrapper> ProdWrapperList;
    public String ContactName{get;set;} 
    public String UserName{get;set;}
    public String RecordId {get;set;}
    public String OrderNumber {get;set;}
    public Order OrderDetail;
    public string docId{get;set;}
    public string siteURL{get;set;}
    public string ordNumber {get;set;}
    public string firstName{get;set;}
    public static string tcpOrderRecTypeid = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('TCP_Orders').getRecordTypeId();
    
    public list<Order> getOrderDetails(){
     try{
        if(RecordId==null){
            RecordId = ApexPages.currentPage().getParameters().get('RecordId');
        }
        if(ContactName==null){
            ContactName = ApexPages.currentPage().getParameters().get('ContactName');
            firstName=ContactName;
        }
        if(OrderNumber==null){
            OrderNumber = ApexPages.currentPage().getParameters().get('OrderNumber');
        }
        if(UserName==null){
            UserName = ApexPages.currentPage().getParameters().get('UserName');
        }
        OrderDetails = new list<Order>([Select o.CreatedBy.Name,o.ordered_by__r.Name,o.TCP_Modification_Requested_By__r.name, o.TCP_Modification_Requested_Date__c, o.TCP_Cancellation_Placed_By__r.name, o.TCP_Cancellation_Requested_Date__c,o.CreatedBy.contact.name,o.CreatedBy.contact.firstname,o.TCP_Order_Status__c,o.CreatedBy.TCP_Region__c,o.account.TCP_Payment_Terms__c,o.Type,o.account.accountnumber,o.Sold_To__r.accountnumber,o.Sold_To_Address__c,o.Sales_Order_Number__c,o.TotalAmount, o.StatusCode, o.Status, o.Sold_To__c,o.TCP_Modify_Cancel_Remarks__c, o.Sold_To_Details__c, o.Ship_To__c, o.Ship_To_Details__c, o.Ship_To_Address__c, o.ShipToNo__c, o.Quantity__c, o.PoNumber, o.Payer__c, o.Payer_Details__c, o.PayerNo__c, o.OwnerId, o.Order_Other_Instructions__c, o.OriginalOrderId, o.OrderNumber, o.Name, o.Mode_of_Transport__c, o.IsReductionOrder, o.IsDeleted,  o.Id, o.GSAP_Status__c, o.EndDate, o.EffectiveDate, o.Description, o.Delivery_Terms__c, o.Customer_Name__c,  o.CustomerAuthorizedById, o.CreatedDate, o.CreatedById, o.ContractId, o.BillToNo__c, o.AccountId,o.Remarks__c,o.Sold_To__r.VAT_Reg_No__c From Order o where o.Id=: RecordId and o.recordtype.id=:tcpOrderRecTypeid]);         
        UserName=UserInfo.getName();
  	    LineItemDetails=getOrderLIDetails(); 
         
        //get site url
        list<Site> tcpSite = [select Id from Site where Name =: System.Label.TCP_Site_Name];
            if(!tcpSite.isEmpty()){
                list<SiteDetail> tcpSiteDetail = [select SecureURL from SiteDetail where DurableId = :tcpSite[0].Id];
                if(!tcpSiteDetail.isEmpty()){
                    siteURL = tcpSiteDetail[0].SecureURL+'?c__wonumber='+OrderDetails[0].OrderNumber;
                    ordNumber = OrderDetails[0].OrderNumber;
                }
            }
        return OrderDetails;
        }
	catch (Exception e) {
            throw e;
      }
    }
    
    public list<TCP_OrderLineItem__c> getOrderLIDetails(){
        try{
        list<TCP_OrderLineItem__c> orderLineItemDetails;
        orderLineItemDetails= [Select TCP_Modify_Cancel_Status__c,SICC_Code__c,Shipping_City__c,Shipping_Street__c,Shipping_Country__c,Shipping_Postcode__c,Unit__c,Net_Weight__c,Plant_Name__c,Shipping_Point__c,Shipping_Point_Name__c,Plant__c, Netweight_Unitprice__c, Expected_Dispatch_Date__c,Special_Price__c,Shell_Material_No__c, Quantity__c, Other_Instruction__c, Order__c, Name, Material_Name__c, MaterialNumber__c, Contract_No__c,Delivery_Collection_Date__c,Product__r.Net_Weight__c, Product__r.Product_Number__c,Product__r.Unit_of_Measure__c From TCP_OrderLineItem__c where Order__r.Id=: RecordId and quantity__c!=0];
        return orderLineItemDetails; 
        }
	  catch (Exception e) {
            throw e;
      }
    }
    
    public list<ProdWrapper> getProdWrapList(){    
        try{
        If(!LineItemDetails.isempty()){
            List<ProdWrapper> prodwrapList = new List<ProdWrapper>();
            for(TCP_OrderLineItem__c LI:LineItemDetails){
                ProdWrapper pwrp = new ProdWrapper();            
                pwrp.ProdName = LI.Material_Name__c;
                pwrp.ProdNumber = LI.MaterialNumber__c;
                pwrp.Qty = string.valueof(LI.Quantity__c);
                pwrp.Unit = LI.Unit__c;
                pwrp.CollectionDate=TCP_Utilities.getDateWithMonthName(LI.Delivery_Collection_Date__c);
                pwrp.OtherInstruction= LI.Other_Instruction__c;
                pwrp.ShellContractNo= LI.Contract_No__c;
                prodwrapList.add(pwrp);
            }
            return prodwrapList; 
            }
        return null;
        }
	  catch (Exception e) {
            throw e;
      }
    }
    
    public class ProdWrapper{
        public String ProdName{get;set;}
        public String ProdNumber{get;set;}
        public String Qty{get;set;}
        public String Unit{get;set;}
        public String CollectionDate{get;set;}
        public String OtherInstruction{get;set;}
        public String ShellContractNo{get;set;}
    } 
    
    
}