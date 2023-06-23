public class TCP_OrderWrapper{

    @AuraEnabled
    public String id{get;set;}
    @AuraEnabled
    public String orderNumber{get;set;}
    @AuraEnabled
    public String name{get;set;}
    @AuraEnabled
    public String poNumber{get;set;}
    @AuraEnabled
    public String deliveryTerms{get;set;}
    @AuraEnabled
    public String modeOfTransport{get;set;}
    @AuraEnabled
    public String otherInstructions{get;set;}
    @AuraEnabled
    public String soldToId{get;set;}
    @AuraEnabled
    public String shipToId{get;set;}
    @AuraEnabled
    public String billToId{get;set;}
    @AuraEnabled
    public String payerId{get;set;}
    @AuraEnabled
    public String payerNumber{get;set;}
    @AuraEnabled
    public String soldToNumber{get;set;}
    @AuraEnabled
    public String shipToNumber{get;set;}
    @AuraEnabled
    public String billToNumber{get;set;}
    @AuraEnabled
    public String status{get;set;}
    @AuraEnabled
    public String soldToName{get;set;}
    @AuraEnabled
    public String soldToCity{get;set;}
    @AuraEnabled
    public String shipToName{get;set;}
    @AuraEnabled
    public String billToName{get;set;}
    @AuraEnabled
    public String soldToNameWithAddr{get;set;}
    @AuraEnabled
    public String shipToNameWithAddr{get;set;}
    @AuraEnabled
    public String billToNameWithAddr{get;set;}
    @AuraEnabled
    public Boolean isChemicalGSAP{get;set;}
    @AuraEnabled
    public Boolean isThirdParty{get;set;}
    @AuraEnabled
    public Boolean isRushOrder{get;set;}
    @AuraEnabled
    public Boolean isLateOrder{get;set;}
    @AuraEnabled
    public Boolean isLastMinute{get;set;}
    @AuraEnabled
    public String remarks{get;set;}
    @AuraEnabled
    public String salesordernumber{get;set;}
    @AuraEnabled
    public String orderedBy{get;set;}
    @AuraEnabled
    public String fullfilledBy{get;set;}
    @AuraEnabled
    public String isLateOrderVal{get;set;}
    @AuraEnabled
    public String isRushOrderVal{get;set;}
    @AuraEnabled
    public String isLastMinuteChangeVal{get;set;}
    @AuraEnabled
    public String reviewedBy{get;set;}
    @AuraEnabled
    public String reviewedDateTime{get;set;}
    @AuraEnabled
    public String orderPriority{get;set;}
    @AuraEnabled
    public String Description{get;set;}
    @AuraEnabled
    public String modifyCommopsRemarks{get;set;}
    @AuraEnabled
    public String cancelCommopsRemarks{get;set;}
    @AuraEnabled
    public String requestedById{get;set;}
    @AuraEnabled
    public String orderedDate{get;set;}
    @AuraEnabled
    public String modificationBy{get;set;}
    @AuraEnabled
    public String modificationDate{get;set;}
    @AuraEnabled
    public String cancellationBy{get;set;}
    @AuraEnabled
    public String cancellationDate{get;set;}
    @AuraEnabled
    public String accountNumber{get;set;}
    @AuraEnabled
    public String gsapSoldToNumber{get;set;}
    @AuraEnabled
    public String gsapSoldToName{get;set;}
    @AuraEnabled
    public List<TCP_OrderLineItem__c> orderLineItemList{get;set;}
    @AuraEnabled
    public List<TCP_OrderLineItemWrapper> orderLineItemWrapList{get;set;}
    @AuraEnabled
    public List<String> soldToIdList{get;set;}
    
}