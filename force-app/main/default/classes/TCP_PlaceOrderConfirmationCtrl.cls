/*****************************************************************************************************
ClassName   :   TCP_PlaceOrderConfirmationCtrl
Description :   This class manages pdf for order confirmation
*****************************************************************************************************/
public with sharing class TCP_PlaceOrderConfirmationCtrl {
 
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
    Map<String, Decimal> changeQuantityMap = new Map<String, Decimal>(); 
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
        //To map shell logo in place order confirmation PDF
        Document doc=[select id,name from document where name='Shell Logo1' limit 1];
        docId='/servlet/servlet.FileDownload?file='+doc.id;
        OrderDetails = new list<Order>([Select o.CreatedBy.Name,o.CreatedBy.contact.name,o.CreatedBy.contact.firstname,o.TCP_Order_Status__c,o.CreatedBy.TCP_Region__c,o.account.TCP_Payment_Terms__c,o.Type,o.account.accountnumber,o.Sold_To__r.accountnumber,o.Sold_To_Address__c,o.Sales_Order_Number__c,o.TotalAmount, o.StatusCode, o.Status, o.Sold_To__c,o.TCP_Modify_Cancel_Remarks__c, o.Sold_To_Details__c, o.Ship_To__c, o.Ship_To_Details__c, o.Ship_To_Address__c, o.ShipToNo__c, o.Quantity__c, o.PoNumber, o.Payer__c, o.Payer_Details__c, o.PayerNo__c, o.OwnerId, o.Order_Other_Instructions__c, o.OriginalOrderId, o.OrderNumber, o.Name, o.Mode_of_Transport__c, o.IsReductionOrder, o.IsDeleted,  o.Id, o.GSAP_Status__c, o.EndDate, o.EffectiveDate, o.Description, o.Delivery_Terms__c, o.Customer_Name__c,  o.CustomerAuthorizedById, o.CreatedDate, o.CreatedById, o.ContractId, o.BillToNo__c, o.AccountId,o.Remarks__c,o.Sold_To__r.VAT_Reg_No__c From Order o where o.Id=: RecordId and o.recordtype.id=:tcpOrderRecTypeid]);         
        UserName=UserInfo.getName();
  	  	LineItemDetails=getOrderLIDetails(); 
         
        if(!string.isEmpty(OrderDetails[0].Id)){
        changeQuantityMap=getchangeQuantityMap(OrderDetails[0].Id);
        }
         
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
    
    public Map<String, Decimal> getchangeQuantityMap(String orderid){
        try{
        Map<String, Decimal> changeOLIMap = new Map<String, Decimal>(); 
        for(TCP_Change_Cancel_Order_Line_Items__c  changeOLI : [select Quantity__c,TCP_Modification_Cancellation_Status__c, Quantity_New__c,Item_number__c from TCP_Change_Cancel_Order_Line_Items__c where Change_Cancel_Request_Order__r.Web_Order__c =:orderid and TCP_Modification_Cancellation_Status__c='Cancelled' order by createddate desc ])
            {	
                if(!changeOLIMap.containsKey(changeOLI.Item_number__c)){
                changeOLIMap.put(changeOLI.Item_number__c ,changeOLI.Quantity__c);
                }
            }
            if(!changeOLIMap.isEmpty()) {
                return changeOLIMap;
            }   
        return null; 
        }
	  catch (Exception e) {
            throw e;
      }
    }
    
    public list<TCP_OrderLineItem__c> getOrderLIDetails(){
        try{
        list<TCP_OrderLineItem__c> orderLineItemDetails;
        orderLineItemDetails= [Select TCP_Modify_Cancel_Status__c,SICC_Code__c,Shipping_City__c,Shipping_Street__c,Shipping_Country__c,Shipping_Postcode__c,Unit__c,Net_Weight__c,Plant_Name__c,Shipping_Point__c,Shipping_Point_Name__c,Plant__c, Netweight_Unitprice__c, Expected_Dispatch_Date__c,Special_Price__c,Shell_Material_No__c, Quantity__c, Other_Instruction__c, Order__c, Name, Material_Name__c, MaterialNumber__c, Contract_No__c,Delivery_Collection_Date__c,Product__r.Net_Weight__c, Product__r.Product_Number__c,Product__r.Unit_of_Measure__c From TCP_OrderLineItem__c where Order__r.Id=: RecordId and Cancelled_in_Submitted__c=false Order By Sales_Order_Line_Item_No__c];
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
                pwrp.SICCcode = LI.SICC_Code__c;
                pwrp.Prodnumber = LI.MaterialNumber__c;
                pwrp.Unit = LI.Unit__c; 
                pwrp.CollectionDate=LI.Delivery_Collection_Date__c;
                pwrp.DispatchDate=LI.Expected_Dispatch_Date__c;
                pwrp.SpecialPrice = LI.Special_Price__c;
                pwrp.OtherInstruction= LI.Other_Instruction__c;
                pwrp.ShellContractNo= LI.Contract_No__c;
                pwrp.ProductNetweight=string.valueOf(LI.Net_Weight__c);
                pwrp.Productmeasurment=LI.Netweight_Unitprice__c;
                pwrp.Plant = LI.Plant__c;
                pwrp.PlantName= LI.Plant_Name__c;
                pwrp.ShippingPoint= LI.Shipping_Point__c;
                pwrp.ShippingPointName= LI.Shipping_Point_Name__c;
                pwrp.City = LI.Shipping_City__c;
                pwrp.Street= LI.Shipping_Street__c;
                pwrp.Postcode= LI.Shipping_Postcode__c;
                pwrp.Country= LI.Shipping_Country__c;
                pwrp.CancelledItem= LI.TCP_Modify_Cancel_Status__c;
                if(LI.TCP_Modify_Cancel_Status__c=='Cancelled' && LI.Quantity__c==0){
                    if(!changeQuantityMap.isEmpty()) {
                        pwrp.Qty = string.valueof(changeQuantityMap.get(LI.Name));
                    }
                }else{
                     pwrp.Qty = string.valueof(LI.Quantity__c);
                }
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
        public String Productmeasurment{get;set;}
        public String SICCcode{get;set;}
        public String Qty{get;set;}
        public String Unit{get;set;}
        public DateTime CollectionDate{get;set;}
        public DateTime DispatchDate{get;set;}
        public String SpecialPrice{get;set;}
        public String OtherInstruction{get;set;}
        public String ShellContractNo{get;set;}
        public String ProductNetweight{get;set;}
        public String Plant{get;set;}
        public String PlantName{get;set;}
        public String ShippingPoint{get;set;}
        public String ShippingPointName{get;set;}
        public String City{get;set;}
        public String Street{get;set;}
        public String Postcode{get;set;}
        public String Country{get;set;}
        public String CancelledItem{get;set;}  
    } 
    
}