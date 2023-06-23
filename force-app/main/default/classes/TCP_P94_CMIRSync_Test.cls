@isTest
public class TCP_P94_CMIRSync_Test {
    
    @testSetup static void testSetupMethod(){
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        TCP_P94_Staging_object__c tcpStaging = new TCP_P94_Staging_object__c();        
        tcpStaging.Sales_Org__c = 'USN6';
		tcpStaging.Distribution_Channel__c = '06';
        //tcpStaging.Date__c = 
		//tcpStaging.Time__c
		tcpStaging.Full_Load__c = 'N';
		tcpStaging.Material_Number__c = '400011500';
		//tcpStaging.Material_Description__c = 'INT CHEM Styrene Monomer LD US';
		tcpStaging.Name = 'INT CHEM Styrene Monomer LD US';
		tcpStaging.Unit_of_Measure__c = 'KG';
		tcpStaging.Customer_Number__c = '12990284';		
		tcpStaging.Deletion_flag__c = false;
		tcpStaging.Data_type__c = 'CMIR';	
        tcpStaging.CMIR_External_Id__c = '12990284400011500USN606';
		tcpStaging.Is_CMIR_Processed__c = false;  
        
        insert tcpStaging;
        
        TCP_P94_Staging_object__c tcpStaging1 = new TCP_P94_Staging_object__c();        
        tcpStaging1.Sales_Org__c = 'USN6';
		tcpStaging1.Distribution_Channel__c = '06';
        //tcpStaging.Date__c = 
		//tcpStaging.Time__c
		tcpStaging1.Full_Load__c = 'N';
		tcpStaging1.Material_Number__c = '400011500';
		//tcpStaging.Material_Description__c = 'INT CHEM Styrene Monomer LD US';
		tcpStaging1.Name = 'INT CHEM Styrene Monomer LD US';
		tcpStaging1.Unit_of_Measure__c = 'KG';
		tcpStaging1.Customer_Number__c = '12990284';		
		tcpStaging1.Deletion_flag__c = false;
		tcpStaging1.Data_type__c = 'CMIR';		
		tcpStaging1.Is_CMIR_Processed__c = true;  
        
        insert tcpStaging1;
        
        TCP_Sales_Area__c sa = new TCP_Sales_Area__c();
        sa.Sales_Org__c = 'USN6';
        sa.Distribution_Channel__c = '06';
        sa.Division__c = '02';
        sa.Sales_Region__c = 'NA';
        insert sa;
        
        Account a = new Account();
        	a.Name = 'Americas Styrenics LLC';           	
           	a.AccountNumber = '12990284';
            a.Sales_Area__c = sa.Id;
            a.TCP_Sales_Area_text__c = 'NA';			
			a.TCP_P94_Partner_Account_Number__c = '12990284';
			a.Partner_Function__c = 'SH';
            if(a.Partner_Function__c == 'SP'){
            	a.Customer_Type__c = 'Sold To';    
            }else if (a.Partner_Function__c == 'SH'){
                a.Customer_Type__c = 'Ship To';    
            }else if (a.Partner_Function__c == 'BP'){
                a.Customer_Type__c = 'Bill To';    
            }else if (a.Partner_Function__c == 'PY'){
                a.Customer_Type__c = 'Payer';    
            } 		
			a.Partner_Counter__c = '000';
			a.ShippingStreet = '1000 Main Street';
			a.ShippingCity = '';
            a.ShippingState = 'Texas';
			a.ShippingCountry = 'US';
            a.ShippingPostalCode = '77002-6336';
			a.Billing_Block__c = 'ZC';
			a.Delivery_Block__c = 'DF';
			a.Order_Block__c = '2';            
			a.Incoterms1__c = 'CPT';
			a.Incoterms2__c = '';
			a.Mode_of_Transport__c = '32';
            a.TCP_Payment_Terms__c = '';			
			a.VAT_Reg_No__c = '123456';
            a.TCP_P94_Cust_ExternalID__c = '12990284USN6060212990284SP';
            a.RecordTypeId =  tcpAccountRecTypeid;
            a.Active__c = true;            
            a.TCP_P94_Sold_To_Account_Group__c = 'YSTP';
            a.TCP_P94_Partner_Account_Group__c = 'YSTP';
			insert a; 
        
        TCP_Products_Sales_Line__c psl =  new TCP_Products_Sales_Line__c();
        psl.Sales_Org__c = 'USN6';
        psl.Distribution_Channel__c = '06';
        psl.TCP_P94_ProdSL_ExternalID__c = 'USN606';
        psl.Active__c = true;                
        insert psl;
        
        Product2  prd = new Product2();
        prd.ProductCode = tcpStaging.Material_Number__c;
        prd.Name = 'test material';
        prd.Unit_of_Measure__c = 'KG';
        prd.Gross_Weight__c = tcpStaging.Gross_Weight__c;
        prd.Net_Weight__c = tcpStaging.Net_Weight__c;            
        prd.Products_Sales_Line__c = psl.Id;
        prd.IsActive = true;
        prd.TCP_P94_Prod_ExternalId__c = tcpStaging.Material_Number__c + psl.TCP_P94_ProdSL_ExternalID__c;
		insert prd;
        
        TCP_Product_Customer__c CMIR =  new TCP_Product_Customer__c(); 
        CMIR.Active__c = true;
        CMIR.Account__c = a.id;
        CMIR.Product__c = prd.id;
        CMIR.Partner_Function__c = 'SH';
        CMIR.TCP_P94_CMIR_ExternalId__c  = '12990284400011500USN606';
        insert CMIR;
        
    }
    
    @isTest
    private static void CMIRSyncBatchTest(){        
        Test.startTest();
        	TCP_P94_CMIRSyncBatch batchInstance = new TCP_P94_CMIRSyncBatch();
        	Database.executeBatch(batchInstance);
        Test.stopTest();
    }
    
    @isTest
    private static void schedulerTest(){
        test.startTest();
         	String CRON_EXP = '0 0 * * * ?';
         	String jobId = System.schedule('testBasicScheduledApex',
      										CRON_EXP, 
         									new TCP_P94_CMIRSyncBatchScheduler());
        test.stopTest();
    }

}