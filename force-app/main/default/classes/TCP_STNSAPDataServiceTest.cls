@isTest
public class TCP_STNSAPDataServiceTest {
	@TestSetup
    static void createTestData() {
        
        List<Account> testAccounts=TCP_TestDataUtilities.createAccountsWithExternalId(1);
        
    }
    @isTest
    static void fetchSTNSAPSoldToTest(){
        list<TCP_STNSAP_1stService__c> fulloadData =new List<TCP_STNSAP_1stService__c>();
        TCP_STNSAP_1stService__c test=new TCP_STNSAP_1stService__c();
        test.Full_Load__c='N';
        test.Name='SETO';
        test.Sales_Area__c='SETO';
        test.Last_call_timestamp__c=System.today();
        fulloadData.add(test);
        insert fulloadData;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
         List<ZST_TCP_CUST_OUT__x> mockRecords=new List<ZST_TCP_CUST_OUT__x>();
        ZST_TCP_CUST_OUT__x mock= new ZST_TCP_CUST_OUT__x();
         mock.FULL_LOAD__c='N';
        mock.DIVISION__c='DF';
        mock.DIST_CHNL__c='D';
        mock.PARTNER_FUNC__c='SP';
        mock.NAME__c='PayerAccount';
       // mock.PARTNER_CNT__c='123';
        mock.BILLING_BLK__c='test';
        mock.DELIVERY_BLK__c='test1';
        mock.ORDER_BLK__c='ord';
        mock.STREET__c='street';
        mock.STATE__c='state';
        mock.CITY__c='city';
        mock.COUNTRY__c='country';
        mock.POST_CODE__c='1234';
        
        mock.INCO1__c='inco1';
        mock.INCO2__c='inco2';
          mock.SHIP_COND__c='Bulk Cont. road/sea';
        mock.DELETION_FLAG__c=true;
        mock.STATUS__c='shipped';
        mock.SALESORG__c='SETO';
        mock.DIST_CHNL__c='D';
        mock.DIVISION__c='DF';
        mock.SOLD_TO__c='1234';
        mockRecords.add(mock);
        TCP_STNSAPDataService.MocklistCustomers=mockRecords;
        TCP_STNSAPDataService.fetchSTNSAPSoldTo(acc.Sales_Area__c);
       
    }
    @isTest
    static void fetchSTNSAPSoldToTest2(){
        list<TCP_STNSAP_1stService__c> fulloadData =new List<TCP_STNSAP_1stService__c>();
        TCP_STNSAP_1stService__c test=new TCP_STNSAP_1stService__c();
        test.Full_Load__c='Y';
        test.Name='SETO';
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
         List<ZST_TCP_CUST_OUT__x> mockRecords=new List<ZST_TCP_CUST_OUT__x>();
        ZST_TCP_CUST_OUT__x mock= new ZST_TCP_CUST_OUT__x();
         mock.FULL_LOAD__c='N';
        mock.DIVISION__c='DF';
        mock.DIST_CHNL__c='D';
        mock.PARTNER_FUNC__c='SH';
        mock.NAME__c='PayerAccount';
       // mock.PARTNER_CNT__c='123';
        mock.BILLING_BLK__c='test';
        mock.DELIVERY_BLK__c='test1';
        mock.ORDER_BLK__c='ord';
        mock.STREET__c='street';
        mock.STATE__c='state';
        mock.CITY__c='city';
        mock.COUNTRY__c='country';
        mock.POST_CODE__c='1234';
        
        mock.INCO1__c='inco1';
        mock.INCO2__c='inco2';
          mock.SHIP_COND__c='Bulk Cont. road/sea';
        mock.DELETION_FLAG__c=true;
        mock.STATUS__c='shipped';
        mock.SALESORG__c='SETO';
        mock.DIST_CHNL__c='D';
        mock.DIVISION__c='DF';
        mock.SOLD_TO__c='1234';
        mockRecords.add(mock);
        TCP_STNSAPDataService.MocklistCustomers=mockRecords;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        TCP_STNSAPDataService.fetchSTNSAPSoldTo(acc.Sales_Area__c);
    }
     @isTest
    static void fetchSTNSAPSoldToTest3(){
        list<TCP_STNSAP_1stService__c> fulloadData =new List<TCP_STNSAP_1stService__c>();
        TCP_STNSAP_1stService__c test=new TCP_STNSAP_1stService__c();
        test.Full_Load__c='Y';
        test.Last_call_timestamp__c=System.today();
        test.Name='SETO';
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
        List<ZST_TCP_CUST_OUT__x> mockRecords=new List<ZST_TCP_CUST_OUT__x>();
        ZST_TCP_CUST_OUT__x mock= new ZST_TCP_CUST_OUT__x();
         mock.FULL_LOAD__c='N';
        mock.DIVISION__c='DF';
        mock.DIST_CHNL__c='D';
        mock.PARTNER_FUNC__c='BP';
        mock.NAME__c='PayerAccount';
       // mock.PARTNER_CNT__c='123';
        mock.BILLING_BLK__c='test';
        mock.DELIVERY_BLK__c='test1';
        mock.ORDER_BLK__c='ord';
        mock.STREET__c='street';
        mock.STATE__c='state';
        mock.CITY__c='city';
        mock.COUNTRY__c='country';
        mock.POST_CODE__c='1234';
        mock.INCO1__c='inco1';
        mock.INCO2__c='inco2';
          mock.SHIP_COND__c='Bulk Cont. road/sea';
        mock.DELETION_FLAG__c=true;
        mock.STATUS__c='shipped';
        mock.SALESORG__c='SETO';
        mock.DIST_CHNL__c='D';
        mock.DIVISION__c='DF';
        mock.SOLD_TO__c='1234';
        mockRecords.add(mock);
        TCP_STNSAPDataService.MocklistCustomers=mockRecords;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        TCP_STNSAPDataService.fetchSTNSAPSoldTo(acc.Sales_Area__c);
    }
     @isTest
    static void fetchSTNSAPSoldToShipToTest(){
        list<TCP_STNSAP_2ndService__c> fulloadData =new List<TCP_STNSAP_2ndService__c>();
        TCP_STNSAP_2ndService__c test=new TCP_STNSAP_2ndService__c();
        test.Full_Load__c='N';
        test.Name='SETO';
        test.Last_call_timestamp__c=System.today();
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
       
         List<ZST_TCP_PAYR_OUT__x> mockRecords=new List<ZST_TCP_PAYR_OUT__x>();
        ZST_TCP_PAYR_OUT__x mock= new ZST_TCP_PAYR_OUT__x();
        mock.FULL_LOAD__c='N';
        mock.DIVISION__c='DF';
        mock.DIST_CHNL__c='D';
        mock.PARTNER_FUNC__c='SP';
        mock.NAME__c='PayerAccount';
        mock.PARTNER_CNT__c='123';
        mock.BILLING_BLK__c='test';
        mock.DELIVERY_BLK__c='test1';
        mock.ORDER_BLK__c='ord';
        mock.STREET__c='street';
        mock.STATE__c='state';
        mock.CITY__c='city';
        mock.COUNTRY__c='country';
        mock.POST_CODE__c='1234';
        mock.PARTNER_NO__c=acc.AccountNumber;
        mock.INCO1__c='inco1';
        mock.INCO2__c='inco2';
          mock.SHIP_COND__c='Bulk Cont. road/sea';
        mock.DELETION_FLAG__c=true;
        mock.STATUS__c='shipped';
        mock.SALESORG__c='SETO';
        mock.DIST_CHNL__c='D';
        mock.DIVISION__c='DF';
        mock.SOLD_TO__c='1234';
        mockRecords.add(mock);
        TCP_STNSAPDataService.MocklistPayers=mockRecords;
         TCP_STNSAPDataService.fetchSTNSAPSoldToShipTo(acc.Id);
    }
     @isTest
    static void fetchSTNSAPSoldToShipToTest2(){
        list<TCP_STNSAP_2ndService__c> fulloadData =new List<TCP_STNSAP_2ndService__c>();
        TCP_STNSAP_2ndService__c test=new TCP_STNSAP_2ndService__c();
        test.Full_Load__c='Y';
        test.Name='SETO';
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        TCP_STNSAPDataService.fetchSTNSAPSoldToShipTo(acc.Id);
    }
      @isTest
    static void fetchSTNSAPSoldToShipToTest3(){
        list<TCP_STNSAP_2ndService__c> fulloadData =new List<TCP_STNSAP_2ndService__c>();
        TCP_STNSAP_2ndService__c test=new TCP_STNSAP_2ndService__c();
        test.Full_Load__c='Y';
        test.Name='SETO';
        test.Last_call_timestamp__c=System.today();
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        TCP_STNSAPDataService.fetchSTNSAPSoldToShipTo(acc.Id);
    }
     @isTest
    static void fetchSTNSAPSoldToProductCMIRTest(){
        list<TCP_STNSAP_3rdService__c> fulloadData =new List<TCP_STNSAP_3rdService__c>();
        TCP_STNSAP_3rdService__c test=new TCP_STNSAP_3rdService__c();
        test.Full_Load__c='Y';
        test.Name='SETO';
        test.Last_call_timestamp__c=System.today();
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        TCP_STNSAPDataService.fetchSTNSAPSoldToProductCMIR(acc.Id);
    }
      @isTest
    static void fetchSTNSAPSoldToProductCMIRTest2(){
        list<TCP_STNSAP_3rdService__c> fulloadData =new List<TCP_STNSAP_3rdService__c>();
        TCP_STNSAP_3rdService__c test=new TCP_STNSAP_3rdService__c();
        test.Full_Load__c='N';
        test.Name='SETO';
        test.Last_call_timestamp__c=System.today();
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        TCP_STNSAPDataService.fetchSTNSAPSoldToProductCMIR(acc.Id);
    }  
     @isTest
    static void fetchSTNSAPSoldToProductCMIRTest3(){
        list<TCP_STNSAP_3rdService__c> fulloadData =new List<TCP_STNSAP_3rdService__c>();
        TCP_STNSAP_3rdService__c test=new TCP_STNSAP_3rdService__c();
        test.Full_Load__c='Y';
        test.Name='SETO';
        test.Sales_Area__c='SETO';
        fulloadData.add(test);
        insert fulloadData;
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
       
        TCP_STNSAPDataService.fetchSTNSAPSoldToProductCMIR(acc.Id);
    }
    @isTest
    static void trackStatusSTNSAPProductsTest(){
        Account acc=[select id,name,recordtype.id,Sales_Area__c,GSAP_Account_Number__c,AccountNumber from account where name='SampleAccount0' limit 1];
        List<ZST_TCP_PROD_OUT__x> mockRecords=new List<ZST_TCP_PROD_OUT__x>();
        ZST_TCP_PROD_OUT__x mock=new ZST_TCP_PROD_OUT__x();
        mock.FULL_LOAD__c='N';
        mock.DIST_CHNL__c='D';
        mock.PARTNER_FUNC__c='SP';
        mock.STATUS__c='shipped';
        mock.SALESORG__c='SETO';
        mock.DIST_CHNL__c='D';
        mockRecords.add(mock);
TCP_STNSAPManagementProcessor.trackStatusSTNSAPProducts(mockRecords,acc.AccountNumber,'Sold To','SETO', 'D');
    }
    
}