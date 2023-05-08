@isTest
public class TCP_OrdrManagementProcessorTest {
@TestSetup
    static void createTestData() {
        
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        List<contact> testContact=TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<Order> testOrder=TCP_TestDataUtilities.createOrders(1,testAccounts[0]);
        
    }
     @istest
    static void trackStatusGSAPOrderTest(){
         string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        Account acc=[select id,name,recordtype.id,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpAccountRecTypeid;
        update acc;
        Order ord=[select id,Name,recordtype.id,createddate, AccountId,Sales_Order_Number__c, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order where TCP_Order_Status__c='Submitted' limit 1];
  /**CurrentOrders__x cuOrd=new CurrentOrders__x();
        cuOrd.Soldto__c=ord.Sold_To__r.GSAP_Account_Number__c;
        cuOrd.Weborder__c=ord.Id;
        cuOrd.Unit__c='KG';
         cuOrd.Terms__c='Terms';
        insert cuOrd;**/
        
        List<CurrentOrders__x> cuOrdList=[Select Id,Soldto__c,Weborder__c,Unit__c,Terms__c from CurrentOrders__x where Weborder__c=:ord.Id ];
        TCP_OrderManagementProcessor.trackStatusGSAPOrder(ord.Id,true, false, ord.Sales_Order_Number__c,false);
         TCP_OrderManagementProcessor.trackStatusGSAPOrder(ord.Id,false, true, ord.Sales_Order_Number__c,false);
        TCP_OrderManagementProcessor.trackCurrentOrderFromsGSAP(cuOrdList,ord.Sold_To__r.GSAP_Account_Number__c,acc.AccountNumber);
    }
}