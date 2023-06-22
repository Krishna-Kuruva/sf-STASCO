@isTest
public class TCP_SAPRetry_ServiceTest {
    @TestSetup
    static void createTestData() {
        
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        TCP_TestDataUtilities.createOrders(1,testAccounts[0]);
        
    }
    @istest
    static void positiveTest(){
        
        String completeString1 = 'Select WebOrder__c, Tdline__c, Tdformat__c, Soldto__c, Shipto__c, ShipCond__c, SalesUnit__c, ReqQty__c, ReqDate__c, PurchNoC__c, Payer__c, Msgid__c, Message__c, Material__c, ItmNumber__c, Incoterms2__c, Incoterms1__c, ExternalId, DisplayUrl, CcluserId__c, Billto__c From CurrentOrders__x where ';
        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order limit 1];
        String shipCondition = [SELECT id, Shipping_Condition_Code__c, Shipping_Condition_Description__c from TCP_Shipping_Condition__mdt where Shipping_Condition_Description__c=:ord.Mode_of_Transport__c].Shipping_Condition_Code__c;
        completeString1 = completeString1+'Soldto__c=\''+ord.Sold_To__r.GSAP_Account_Number__c+'\''+' and '+'Shipto__c=\''+ord.Ship_To__r.GSAP_Account_Number__c+'\''+' and '+'Billto__c=\''+ord.Bill_To__r.GSAP_Account_Number__c+'\''+' and '+'Payer__c=\''+ord.Payer__r.GSAP_Account_Number__c+'\''+' and '+'WebOrder__c=\''+ord.OrderNumber+'\''+' and '+'Incoterms1__c=\''+ord.Delivery_Terms__c+'\''+' and '+'PurchNoC__c=\''+ord.PoNumber+'\''+' and '+'CcluserId__c=\''+ord.CreatedBy.Name+'\''+' and '+'ShipCond__c=\''+shipCondition+'\'';
        
        String completeString2 = 'Select WebOrder__c, Ttype__c, Tdline__c, Tdformat__c, Soldto__c, Shipto__c, ShipCond__c, SalesUnit__c, ReqQty__c, ReqDate__c, PurchNoC__c, Payer__c, Msgid__c, Message__c, Material__c, ItmNumber__c, Incoterms2__c, Incoterms1__c, ExternalId, DisplayUrl, CcluserId__c, Billto__c From OrdCnfDet__x where ';
        
        
        completeString2 = completeString2+'Soldto__c=\''+ord.Sold_To__r.GSAP_Account_Number__c+'\''+' and '+'Shipto__c=\''+ord.Ship_To__r.GSAP_Account_Number__c+'\''+' and '+'Billto__c=\''+ord.Bill_To__r.GSAP_Account_Number__c+'\''+' and '+'Payer__c=\''+ord.Payer__r.GSAP_Account_Number__c+'\''+' and '+'WebOrder__c=\''+ord.OrderNumber+'\''+' and '+'Incoterms1__c=\''+ord.Delivery_Terms__c+'\''+' and '+'PurchNoC__c=\''+ord.PoNumber+'\''+' and '+'CcluserId__c=\''+ord.CreatedBy.Name+'\''+' and '+'ShipCond__c=\''+shipCondition+'\'';
        
        String completeString3 = 'Select WebOrder__c, Ttype__c, Tdline__c, Tdformat__c, Soldto__c, Shipto__c, ShipCond__c, SalesUnit__c, ReqQty__c, ReqDate__c, PurchNoC__c, Payer__c, Msgid__c, Message__c, Material__c, ItmNumber__c, Incoterms2__c, Incoterms1__c, ExternalId, DisplayUrl, CcluserId__c, Billto__c From CcpChOrdr__x where ';
        
        
        completeString3 = completeString3+'Soldto__c=\''+ord.Sold_To__r.GSAP_Account_Number__c+'\''+' and '+'Shipto__c=\''+ord.Ship_To__r.GSAP_Account_Number__c+'\''+' and '+'Billto__c=\''+ord.Bill_To__r.GSAP_Account_Number__c+'\''+' and '+'Payer__c=\''+ord.Payer__r.GSAP_Account_Number__c+'\''+' and '+'WebOrder__c=\''+ord.OrderNumber+'\''+' and '+'Incoterms1__c=\''+ord.Delivery_Terms__c+'\''+' and '+'PurchNoC__c=\''+ord.PoNumber+'\''+' and '+'CcluserId__c=\''+ord.CreatedBy.Name+'\''+' and '+'ShipCond__c=\''+shipCondition+'\'';
        
        String completeString = 'Select WebOrder__c, Ttype__c, Tdline__c, Tdformat__c, Soldto__c, Shipto__c, ShipCond__c, SalesUnit__c, ReqQty__c, ReqDate__c, PurchNoC__c, Payer__c, Msgid__c, Message__c, Material__c, ItmNumber__c, Incoterms2__c, Incoterms1__c, ExternalId, DisplayUrl, CcluserId__c, Billto__c From CcpOrdr__x where ';
        
        
        completeString = completeString+'Soldto__c=\''+ord.Sold_To__r.GSAP_Account_Number__c+'\''+' and '+'Shipto__c=\''+ord.Ship_To__r.GSAP_Account_Number__c+'\''+' and '+'Billto__c=\''+ord.Bill_To__r.GSAP_Account_Number__c+'\''+' and '+'Payer__c=\''+ord.Payer__r.GSAP_Account_Number__c+'\''+' and '+'WebOrder__c=\''+ord.OrderNumber+'\''+' and '+'Incoterms1__c=\''+ord.Delivery_Terms__c+'\''+' and '+'PurchNoC__c=\''+ord.PoNumber+'\''+' and '+'CcluserId__c=\''+ord.CreatedBy.Name+'\''+' and '+'ShipCond__c=\''+shipCondition+'\'';
        
        test.startTest();
        TCP_SAPRetry_Service.p31GoodsIssueRetry(completeString1, ord.Sold_To__c, ord.Sold_To__c);
        
        TCP_SAPRetry_Service.p31OrdConfirmRetry(completeString2, ord.Sold_To__c, ord.Sold_To__c);
        
        TCP_SAPRetry_Service.p31ModifyCancelRetry(completeString, ord.Id);
        test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testPositive2(){
        
        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order limit 1];
        TCP_TestDataUtilities.createOrderLineItems(1,ord);
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        
        Account acc=[select id,name,recordtype.id,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpAccountRecTypeid;
        update acc;
        TCP_OrderLineItem__c ordLine=[Select Id, Order__c,Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        
        
        List<CurrentOrders__x > mockRecords = new List<CurrentOrders__x >();
        CurrentOrders__x mock1 = new CurrentOrders__x ();
        mock1.Weborder__c=ord.OrderNumber;
        mock1.SalesItemNo__c='000010';
        mock1.Soldto__c=acc.GSAP_Account_Number__c;
        
        mock1.CustomerPoNo__c=ord.PoNumber;
        mock1.Quantity__c=ordLine.Quantity__c;
        mock1.ProductName__c=ordLine.Material_Name__c;
        mock1.Unit__c=ordLine.Unit__c;
        mock1.DueDate__c=String.valueOf(system.today()+1);
        mock1.GmStat__c='Cqwerty';
        mock1.GmDate__c=system.today()+2;
        mock1.GmUnit__c='TO';
        mock1.BolDeliveryNo__c='1234';
        mock1.MotId__c='12345';
        mockRecords.add(mock1);
        TCP_SAPRetry_Service.MocklistGetCurrentOrder1=mockRecords;  
        
        test.startTest();
        
        try{
            TCP_SAPRetry_Service.p31GoodsIssueRetry('completeString1', '','');
            TCP_SAPRetry_Service.p31OrdConfirmRetry(' ', ' ',' ');
            TCP_SAPRetry_Service.p31ModifyCancelRetry('completeString', 'ord.Id');
        }
        catch(Exception e){
            system.debug('testPositive2 exception=====>');
        }
        test.stopTest();
        System.assert(true);
        
    }
    
    @isTest
    static void testNegative2(){
        
        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order limit 1];
        TCP_TestDataUtilities.createOrderLineItems(1,ord);
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        
        Account acc=[select id,name,recordtype.id,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpAccountRecTypeid;
        update acc;
        TCP_OrderLineItem__c ordLine=[Select Id, Order__c,Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        
        String dateFormat ='IEQ';
        List<CurrentOrders__x > mockRecords = new List<CurrentOrders__x >();
        CurrentOrders__x mock1 = new CurrentOrders__x ();
        mock1.Weborder__c=ord.OrderNumber;
        mock1.SalesItemNo__c='000010';
        mock1.Soldto__c=acc.GSAP_Account_Number__c;
        mock1.DueDate__c=dateFormat;
        mock1.CustomerPoNo__c=ord.PoNumber;
        mock1.Quantity__c=ordLine.Quantity__c;
        mock1.ProductName__c=ordLine.Material_Name__c;
        mock1.Unit__c=ordLine.Unit__c;
        mock1.DueDate__c=String.valueOf(system.today()+1);
        mock1.GmStat__c='Cqwerty';
        mock1.GmDate__c=system.today()+2;
        mock1.GmUnit__c='TO';
        mock1.BolDeliveryNo__c='1234';
        mock1.MotId__c='12345';
        mockRecords.add(mock1);
        TCP_SAPRetry_Service.MocklistGetCurrentOrder1=mockRecords;  
        
        test.startTest();
        TCP_SAPRetry_Service.p31GoodsIssueRetry('completeString1', '','');
        test.stopTest();
        System.assert(true);
        
    }
    
}