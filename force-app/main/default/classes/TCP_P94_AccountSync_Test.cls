@isTest
private class TCP_P94_AccountSync_Test {

    @testSetup static void testSetupMethod(){
        string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
        TCP_P94_Staging_object__c tcpStaging = new TCP_P94_Staging_object__c();
        tcpStaging.Sold_To__c = '12990284';
		tcpStaging.Sales_Org__c = 'USN6';
		tcpStaging.Division__c = '02';
		tcpStaging.Distribution_Channel__c = '06';
		tcpStaging.Partner_Number__c = '12990284';
		tcpStaging.Partner_Function__c = 'SP';
		tcpStaging.Partner_Counter__c = '000';
		tcpStaging.Name = 'Americas Styrenics LLC';
		tcpStaging.Street__c = '1000 Main Street';
		tcpStaging.City__c = 'Texas';
		tcpStaging.Country__c = 'US';
		tcpStaging.Postal_Code__c = '77002-6336';
		tcpStaging.State__c = '';
		tcpStaging.Billing_Block__c = 'ZC';
		tcpStaging.Delivery_Block__c = 'DF';
		tcpStaging.Order_Block__c = '2';
		tcpStaging.Incoterms1__c = 'CPT';
		tcpStaging.Incoterms2__c = '';
		tcpStaging.Shipping_Conditions__c = '32';
		tcpStaging.Deletion_flag__c = false;
		tcpStaging.Data_type__c = 'CUST';
		tcpStaging.Payment_Terms__c = 'terms';
		tcpStaging.VAT_Reg_No__c = '23244';
		//tcpStaging.Date__c = '20230506';
		//tcpStaging.Time__c = '223222';
		tcpStaging.Full_Load__c = 'Y';
		tcpStaging.Sales_Area_External_Id__c = 'USN60602';
		tcpStaging.Cust_No_External_Id__c = '12990284USN6060212990284SP';
		tcpStaging.Is_Cust_Processed__c = false;
		tcpStaging.Sold_To_Account_Group__c = 'YSTP';
		tcpStaging.Partner_Account_Group__c = 'YSTP';
        insert tcpStaging;
        
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
			a.Partner_Function__c = 'SP';
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
        
    }
    
    @isTest
    private static void accSyncBatchTest(){        
        Test.startTest();
        	TCP_P94_AccountSyncBatch batchInstance = new TCP_P94_AccountSyncBatch();
        	Database.executeBatch(batchInstance);
        Test.stopTest();
    }
    
    @isTest
    private static void schedulerTest(){
        test.startTest();
         	String CRON_EXP = '0 0 * * * ?';
         	String jobId = System.schedule('testBasicScheduledApex',
      										CRON_EXP, 
         									new TCP_P94_AccountSyncBatchScheduler());
        test.stopTest();
    }
}