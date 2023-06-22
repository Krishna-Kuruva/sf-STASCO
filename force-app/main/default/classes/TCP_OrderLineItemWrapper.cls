public class TCP_OrderLineItemWrapper{
    
    @AuraEnabled
    public String id{get;set;}
    @AuraEnabled
    public String shellContractNo{get;set;}
    @AuraEnabled
    public String deliveryCollDate{get;set;}
    @AuraEnabled
    public String deliveryCollDateMonth{get;set;}
    @AuraEnabled
    public String materialName{get;set;}
    @AuraEnabled
    public String materialNumber{get;set;}
    @AuraEnabled
    public String orderId{get;set;}
    @AuraEnabled
    public String productId{get;set;}
    @AuraEnabled
    public String quantity{get;set;}
    @AuraEnabled
    public String unit{get;set;}
    @AuraEnabled
    public String instructions{get;set;}
    @AuraEnabled
    public String fromDate{get;set;}
    @AuraEnabled
    public String toDate{get;set;}
    @AuraEnabled
    public String dateType{get;set;}
    @AuraEnabled
    public Boolean quantityCheck{get;set;}
    @AuraEnabled
    public Integer sno{get;set;}
    
    @AuraEnabled
    public List<TCP_OrderLineItem__c> orderLineItemList{get;set;}
}