@isTest
public class TCP_GSAPDataServiceTest {
    
    
    @TestSetup
    static void createTestData() {
        
        List<Account> testAccounts=TCP_TestDataUtilities.createAccounts(1,false);
        TCP_TestDataUtilities.createContacts(1,testAccounts[0]);
        List<Order> testOrder=TCP_TestDataUtilities.createOrders(3,testAccounts[0]);
        TCP_TestDataUtilities.createOrderLineItems(1,testOrder[0]);
        List<TCP_KeyValueSettings__c> createKeyValueSet=TCP_TestDataUtilities.createKeyValueSet();
        
    }
    
    @istest
    static void getCurrentOrdersFromGsapTest(){
        
        Order ord=[select id,Name,recordtype.id,createddate, AccountId, OrderNumber,Sales_Order_Number__c, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order where TCP_Order_Status__c='Approved' limit 1];
        
        TCP_TestDataUtilities.createOrderLineItems(1,ord);
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        Account acc=[select id,name,recordtype.id,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpAccountRecTypeid;
        update acc;
        TCP_OrderLineItem__c ordLine=[Select Id, Order__c,Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        String dateFormat ='IEQ';
        Date lastCallDate = date.valueOf(ord.createddate);
        String lastCallDateFormat =  String.valueOf(lastCallDate.year()) + String.valueOf(lastCallDate.month()).leftpad(2,'0') + String.valueOf(lastCallDate.Day()).leftpad(2,'0');
        dateFormat += lastCallDateFormat; 
        List<CurrentOrders__x > mockRecords = new List<CurrentOrders__x >();
        CurrentOrders__x mock1 = new CurrentOrders__x ();
        CurrentOrders__x mock2 = new CurrentOrders__x ();
        mock1.Weborder__c=ord.OrderNumber;
        mock1.SalesItemNo__c='000010';
        mock1.Soldto__c=acc.GSAP_Account_Number__c;
        mock1.SalesOrder__c=ord.Sales_Order_Number__c;
        mock1.CustomerPoNo__c=ord.PoNumber;
        mock1.Quantity__c=ordLine.Quantity__c;
        mock1.ProductName__c=ordLine.Material_Name__c;
        mock1.Unit__c=ordLine.Unit__c;
        mock1.DueDate__c=String.valueOf(system.today()+1);
        mock1.GmStat__c='C';
        mock1.GmDate__c=system.today()+2;
        mock1.GmUnit__c='TO';
        mock1.BolDeliveryNo__c='1234';
        mock1.MotId__c='12345';
        
        mockRecords.add(mock1);
        mock2=mock1;
        mock2.GmStat__c='A';
        mockRecords.add(mock2);
        TCP_GSAPDataService.MocklistGetCurrentOrder1=mockRecords;
        
        
        string completeString = 'Select Soldto__c,Ztype__c,Weborder__c,SalesOrder__c,SalesItemNo__c,GmQuan__c,GmDate__c,Months__c,DueDate__c,GmStat__c,GmUnit__c,BolDelItemNo__c,BolDeliveryNo__c,CustomerPoNo__c,DeliverOn__c,DeliverTo__c,DisplayUrl,TotVatAmount__c,TotGrossAmount__c,InvoiceAmount__c,InvoiceItm__c,InvoiceNo__c,InvoiceType__c,Mot__c,MotId__c,MotKey__c,OrderCreatedOn__c,Ordername__c,ProductId__c,ProductName__c,Quantity__c,ShipDspOn__c,Status__c,Unit__c,Terms__c,Currency__c from CurrentOrders__x where ';
        completeString = completeString+'Soldto__c=\''+acc.GSAP_Account_Number__c+'\''+' and '+'DueDate__c=\''+dateFormat+'\'';                    
        
        test.startTest();
        try{
            TCP_GSAPDataService.GetCurrentOrdersFromGsap(completeString, acc.GSAP_Account_Number__c, acc.AccountNumber);  
            TCP_GSAPDataService.getAccessToken();
            TCP_GSAPDataService.getPDFURL();
        }
        catch(Exception e){
            system.debug('getCurrentOrdersFromGsapTest exception=====>');
        }
        
        test.stopTest();
    } 
   
    
    @istest
    static void getOrderConfirmationFromGsapTest(){
        
        Order ord=[select id,Name,recordtype.id,createddate, AccountId, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order where TCP_Order_Status__c='Approved' AND Is_Order_Confirmed__c=False Limit 1];
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        Account acc=[select id,name,recordtype.id,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpAccountRecTypeid;
        update acc;
        TCP_TestDataUtilities.createOrderLineItems(1,ord);
        List<Product2> productsList=TCP_testDataUtilities.createProducts(1);
        
        String dateFormat ='IGT';
        Date lastCallDate = date.valueOf(ord.createddate-1);
        String lastCallDateFormat =  String.valueOf(lastCallDate.year()) + String.valueOf(lastCallDate.month()).leftpad(2,'0') + String.valueOf(lastCallDate.Day()).leftpad(2,'0');
        dateFormat += lastCallDateFormat; 
        List<OrdCnfDet__x> mockRecords=new List<OrdCnfDet__x>();
        OrdCnfDet__x mock1=new OrdCnfDet__x();
        mock1.Weborder__c=ord.OrderNumber;
        mock1.Soldto__c=acc.GSAP_Account_Number__c;
        mock1.Weradnam__c=dateFormat;
        mock1.SalesItemNo__c='00010';
        mock1.MatDes__c='testing';
        mock1.ProductId__c=productsList[0].Id;
        mock1.LoadDate__c=System.today()+1;
        mock1.SiccCode__c='124';
        mock1.NetWeight__c=1000;
        
        mock1.PlantId__c='1233';
        mock1.ShipPnt__c='qwer';
        mock1.WerkNam__c='testing';
        mock1.SlocNam__c='1234';
        mock1.SlcCity__c='123456';
        mock1.SlcCtry__c='france';
        mock1.SlcPost__c='524002';
        mock1.SlcStrt__c='traget';
        
        mockRecords.add(mock1);
        TCP_GSAPDataService.MocklistGetOrderConfirmation1=mockRecords;       
        
        string completeString = 'SELECT Id, ExternalId, DisplayUrl, DelvDate__c, Descrs__c, LoadDate__c, MatDes__c, NetWeight__c, OrdDate__c, PlantId__c, ProductId__c, SalesItemNo__c, Salesorder__c, ShipPnt__c, SiccCode__c, Soldto__c, Status__c, WUnit__c, Weborder__c, Inco1__c, Inco2__c, PayTerm__c, SlcCity__c, SlcCtry__c, SlcPost__c, SlcStrt__c, Slcadnam__c, SlocNam__c, WerCity__c, WerCtry__c, WerPost__c, WerStrt__c, Weradnam__c, WerkNam__c FROM OrdCnfDet__x where ';
        completeString = completeString+'Soldto__c=\''+acc.GSAP_Account_Number__c+'\''+' and '+' Weradnam__c=\''+dateFormat+'\'';                    
        
        test.startTest();
        try{
            TCP_GSAPDataService.GetOrderConfirmationFromGsap(completeString, acc.GSAP_Account_Number__c, acc.AccountNumber);  
        }
        catch(Exception e){
            system.debug('completeString exception=====>');
        }
        test.stopTest();
        
    }
    
    @istest
    static void getDeliveryDetailsFromGsapTest(){
        
        Order ord=[select id,Name,recordtype.id,createddate, AccountId, OrderNumber,Sales_Order_Number__c, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order where TCP_Order_Status__c='Approved' limit 1];
        
        TCP_TestDataUtilities.createOrderLineItems(1,ord);
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        Account acc=[select id,name,recordtype.id,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        acc.recordtype.id=tcpAccountRecTypeid;
        update acc;
        TCP_OrderLineItem__c ordLine=[Select Id, GSAP_Goods_Issue_Unit__c,GSAP_Due_Date__c,GSAP_Dispatch_Date__c,GSAP_Goods_Issue_Date__c,GSAP_Goods_Issue_Status__c,GSAP_Goods_Issue_Value__c,Sales_Order_Line_Item_No__c,GSAP_Bol_Delivery__c,GSAP_Mode_of_Transport_ID__c,Order__c,Quantity__c, Unit__c, Delivery_Collection_Date__c, MaterialNumber__c, Material_Name__c, Contract_No__c, Special_Price__c, Other_Instruction__c from TCP_OrderLineItem__c where Order__c=:ord.Id];
        Date lastCallDate = date.valueOf(ord.createddate);
        integer monthsDiff = lastCallDate.monthsBetween(system.today()); 
        List<CurrentOrdersDelivery__x > mockRecords = new List<CurrentOrdersDelivery__x >();
        CurrentOrdersDelivery__x mock1 = new CurrentOrdersDelivery__x ();
        CurrentOrdersDelivery__x mock2 = new CurrentOrdersDelivery__x ();
        mock1.Weborder__c=ord.OrderNumber;
        mock1.SalesItemNo__c='000010';
        mock1.Soldto__c=acc.GSAP_Account_Number__c;
        mock1.SalesOrder__c=ord.Sales_Order_Number__c;
        mock1.CustomerPoNo__c=ord.PoNumber;
        mock1.Quantity__c=ordLine.Quantity__c;
        mock1.ProductName__c=ordLine.Material_Name__c;
        mock1.Unit__c=ordLine.Unit__c;
        mock1.DueDate__c=String.valueOf(system.today()+1);
        mock1.BolDeliveryNo__c='1234';
        mock1.MotId__c='12345';
        
        mockRecords.add(mock1);
        mock2=mock1;
        mock2.BolDeliveryNo__c=null;
        mockRecords.add(mock2);
        TCP_GSAPDataService.MocklistGetOrderDeliverys1=mockRecords;
        
        
        string completeString = 'SELECT Soldto__c,SalesItemNo__c,BolDeliveryNo__c,Status__c,Weborder__c,BolDelItemNo__c,MotId__c, mot__c FROM CurrentOrdersDelivery__x where ';
        completeString = completeString+'Soldto__c=\''+acc.GSAP_Account_Number__c+'\' '+' and '+' Months__c=\''+string.valueof(monthsDiff)+'\' and '+' (Status__c=\'Confirmed\' or Status__c=\'Shipped\')';                    

        test.startTest();
        try{
            TCP_GSAPDataService.getDeliveryDetailsAsync(completeString, acc.GSAP_Account_Number__c, acc.AccountNumber);  
          }
        catch(Exception e){
            system.debug('getDeliveryDetailsAsync exception=====>');
        }
        
        test.stopTest();
    } 
    
    @istest
    static void generateGSAPQueryStringForModifyCancelTest(){
        
        
        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order limit 1];
        List<TCP_OrderLineItem__c> ordLine1=TCP_TestDataUtilities.createOrderLineItems(1,ord);
        
        
        List<CcpOrdr__x> mockRecords=new List<CcpOrdr__x>();
        CcpOrdr__x mock1=new CcpOrdr__x();
        mock1.Weborder__c=ord.Id;
        mock1.Msgid__c='12345';
        mock1.Message__c='Order NOT Processed';
        mockRecords.add(mock1);
        TCP_GSAPDataService.MockOrder=mock1;
        TCP_GSAPDataService.MocklstOrder1=mockRecords;       
        
        test.startTest();
        try{
            TCP_GSAPDataService.GenerateGSAPQueryStringForModifyCancel(Ord, ordLine1, 'ResentRequest');
        }
        catch(Exception e){
            System.debug('Exception in GenerateGSAPQueryStringForModifyCancelTest');
        }
        test.stopTest();
        
    } 
    @istest
    static void generateGSAPQueryStringTest(){
        
        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Sales_Order_Number__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order limit 1];
        List<TCP_OrderLineItem__c> ordLine1=TCP_TestDataUtilities.createOrderLineItems(3,ord);
        
        list<Filenet__x> mockRecords = new list<Filenet__x>();
        Filenet__x mockfetchFiles1  = new Filenet__x();
        mockfetchFiles1.Document__c='1002109791';
        mockfetchFiles1.Filenetid__c='005056B271671EED9FA2F57D108468EE';
        mockfetchFiles1.Outputdesc__c='Order Confirmation';
        mockfetchFiles1.Outputtype__c='OCEA';
        mockfetchFiles1.Reserve__c='PDF';
        mockfetchFiles1.Uri__c='https://MUNTSD-S-70964.europe.shell.com:8090/archive?get&pVersion=0045&contRep=6A&docId=005056B271671EED9FA2F57D108468EE&compId=data&accessMode=r&authId=CN%3DP31%252COU%3DShellChemicals%252COU%3DShell%252CO%3DmySAP.comWorkplace%252CC%3DDE&expiration=20230109091322&secKey=MIIBUAYJKoZIhvcNAQcCoIIBQTCCAT0CAQExCzAJBgUrDgMCGgUAMAsGCSqGSIb3DQEHATGCARwwggEYAgEBMG4wYzELMAkGA1UEBhMCREUxHDAaBgNVBAoTE215U0FQLmNvbSBXb3JrcGxhY2UxDjAMBgNVBAsTBVNoZWxsMRgwFgYDVQQLEw9TaGVsbCBDaGVtaWNhbHMxDDAKBgNVBAMTA1AzMQIHIBEIFRIpWTAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjMwMTA5MDcxMzIyWjAjBgkqhkiG9w0BCQQxFgQUaM5eTnZJPIAREwoYtMp0UGVxDVswCQYHKoZIzjgEAwQuMCwCFDTo7gjPQhJXiymMoyTSAn1RXr2zAhRx1MSBw69mieMqVYZ6GI%2F%2FNkUC8g%3D%3D';
        mockRecords.add(mockfetchFiles1);
        TCP_GSAPDataService.MocklstofFiles=mockRecords;
        test.startTest();
        try{
            TCP_GSAPDataService.GenerateGSAPQueryString(Ord, ordLine1, 'ResentRequest');
            TCP_GSAPDataService.GetListofFilesFromGsap('completeString');
            
        }
        catch(Exception e){
            System.debug('Exception in GenerateGSAPQueryStringTest');
        }
        
        TCP_GSAPDataService.saveDocIdToCS('1002109700');
        test.stopTest();
        
    }
    
    @istest
    static void trackStatusGSAPOrderTest(){
        

        Order ord=[select id,Name,recordtype.id, AccountId, OrderNumber, Sold_To__c, Ship_To__c,Payer__c,Sales_Order_Number__c,Bill_To__c, EffectiveDate,Ship_To__r.GSAP_Account_Number__c,Sold_To__r.GSAP_Account_Number__c,Bill_To__r.GSAP_Account_Number__c, poNumber, Payer__r.GSAP_Account_Number__c,Order_Other_Instructions__c, Mode_of_Transport__c, Delivery_Terms__c, TCP_Order_Status__c, status,CreatedBy.Name from Order limit 1];
        
        TCP_OrderManagementProcessor.trackStatusGSAPOrder(ord.Id,true, false, ord.Sales_Order_Number__c,false);
        TCP_OrderManagementProcessor.trackStatusGSAPOrder(ord.Id,false, true, ord.Sales_Order_Number__c,false);
        
    }
    
    
    @isTest
    public static void testFetchFilesFromGSAP(){
        try{
            TCP_GSAPDataService.fetchFilesFromGSAP('sales', 'boldel', '');
            TCP_GSAPDataService.fetchFilesFromGSAP('sales', '', '');
        }catch(Exception e){
            System.debug('Exception in testFetchFilesFromGSAP');
        }
    } 
           @isTest
    public static void testgetPDFURL(){
        TCP_MockHttpResponseGenerator mock=new TCP_MockHttpResponseGenerator();
        test.setMock(HttpCalloutMock.class, mock);
     
        TCP_GSAPdataService.getAccessToken();
      
    } 
    
    
    @isTest
    public static void testGenerateGSAPQueryStringForModifyCancel(){
        List<Order> ordList = [SELECT id, name,Sales_Order_Number__c, Order_Other_Instructions__c, Sold_To__c,Sold_To__r.GSAP_Account_Number__c, Ship_To__r.GSAP_Account_Number__c, Bill_To__r.GSAP_Account_Number__c, Payer__r.GSAP_Account_Number__c,  CreatedBy.Name, Chemical_GSAP_P_31__c, Third_Party__c, Sold_To__r.AccountNumber, Delivery_Terms__c, Mode_of_Transport__c,  ShipToNo__c, BillToNo__c, Payer__c, PayerNo__c,  PoNumber,   TCP_Order_Status__c, OrderNumber, AccountId, createdby.contactId  FROM Order];
        List<TCP_OrderLineItem__c> ordLine = [select id,TCP_Modify_Cancel_Status__c, Product__r.Product_Number__c, Sales_Order_Line_Item_No__c, Quantity__c, Unit__c, Delivery_Collection_Date__c, Contract_No__c, Other_Instruction__c, Order__c, Product__c, Material_Name__c, MaterialNumber__c from TCP_OrderLineItem__c];
        
        List<CcpOrdr__x> mockRecords=new List<CcpOrdr__x>();
        CcpOrdr__x mock1=new CcpOrdr__x();
        mock1.Weborder__c=ordList[0].Id;
        mock1.Msgid__c='12345';
        mock1.Message__c='Order Processed';
        mockRecords.add(mock1);
        TCP_GSAPDataService.MockOrder=mock1;
        TCP_GSAPDataService.MocklstOrder1=mockRecords;
        
        Test.startTest();
        TCP_GSAPDataService.GenerateGSAPQueryStringForModifyCancel(ordList[0], ordLine, 'Resent');
        Test.stopTest();
    }
}