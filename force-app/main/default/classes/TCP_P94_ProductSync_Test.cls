@isTest
private class TCP_P94_ProductSync_Test {

    @testSetup static void testSetupMethod(){
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        TCP_P94_Staging_object__c tcpStaging = new TCP_P94_Staging_object__c();        
        tcpStaging.Sales_Org__c = 'USN6';
		tcpStaging.Distribution_Channel__c = '06';
		//tcpStaging.Date__c = 
		//tcpStaging.Time__c
		tcpStaging.Full_Load__c = 'N';
		tcpStaging.Material_Number__c = '400011500';
		tcpStaging.Material_Description__c = 'INT CHEM Styrene Monomer LD US';
		tcpStaging.Name = 'INT CHEM Styrene Monomer LD US';
		tcpStaging.Unit_of_Measure__c = 'KG';
		tcpStaging.Gross_Weight__c = 1.000;
		tcpStaging.Net_Weight__c = 1.000;
		tcpStaging.Deletion_flag__c = false;
		tcpStaging.Data_type__c = 'MATR';
		tcpStaging.Prod_Salesline_External_Id__c = 'USN606';
		tcpStaging.Prod_External_Id__c = '400011500USN606';
		tcpStaging.Is_Matr_Processed__c = false;     
        
        insert tcpStaging;
        
        TCP_Products_Sales_Line__c psl =  new TCP_Products_Sales_Line__c();
        psl.Sales_Org__c = 'USN6';
        psl.Distribution_Channel__c = '06';
        psl.TCP_P94_ProdSL_ExternalID__c = 'USN606';
        psl.Active__c = true;                
        insert psl;
        
        Product2  prd = new Product2();
        prd.ProductCode = tcpStaging.Material_Number__c;
        prd.Name = tcpStaging.Material_Description__c;
        prd.Unit_of_Measure__c = 'KG';
        prd.Gross_Weight__c = tcpStaging.Gross_Weight__c;
        prd.Net_Weight__c = tcpStaging.Net_Weight__c;            
        prd.Products_Sales_Line__c = psl.Id;
        prd.IsActive = true;
        prd.TCP_P94_Prod_ExternalId__c = tcpStaging.Material_Number__c + psl.TCP_P94_ProdSL_ExternalID__c;
		insert prd;
         
        
    }
    
    @isTest
    private static void prodSyncBatchTest(){        
        Test.startTest();
        	TCP_P94_ProductSyncBatch batchInstance = new TCP_P94_ProductSyncBatch();
        	Database.executeBatch(batchInstance);
        Test.stopTest();
    }
    
    @isTest
    private static void schedulerTest(){
        test.startTest();
         	String CRON_EXP = '0 0 * * * ?';
         	String jobId = System.schedule('testBasicScheduledApex',
      										CRON_EXP, 
         									new TCP_P94_ProductSyncBatchScheduler());
        test.stopTest();
    }
}