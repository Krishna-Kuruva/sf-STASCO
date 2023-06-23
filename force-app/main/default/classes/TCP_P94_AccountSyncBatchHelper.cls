/* Description - Batch Helper Class which will run every 4 hours for P94 Account Staging Records. This Staging Records will be a dump from GSAP system 
 * via DDF/Biztalk system as part of P94.
 * Date - 02-05-2023
 * Created By - Madhu Javvaji
 */

 /* Handler Class to process all the account staging records in a batch to create/update the relevent Account records as part of
  * P94 Customer master data Intgeration */
public class TCP_P94_AccountSyncBatchHelper {
    
    //Constants
    static final String SelectString = 'SELECT';
    
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    
    /* Method to fetch all the Account staging records to be processed in the start method of the batch */
    public Static String getQuery(){
        Set<String> SobjectFields = Schema.getGlobalDescribe().get('TCP_P94_Staging_object__c').getDescribe().fields.getMap().keySet();
		String P94DataTypeVal = 'CUST';        
        String query = SelectString + ' ' + String.join(new List<String>(SobjectFields), ',') + 
            	   	   ' FROM TCP_P94_Staging_object__c WHERE Is_Cust_Processed__c=false AND Data_Type__c = \'CUST\' AND  Cust_No_External_Id__c != NULL AND Sales_Area_External_ID__c != NULL Order By CreatedDate';
                
        //include the filter "AND Data_Type__c = 'CUST'"AND Data_Type__c = \'CUST\'
        return query;        
    }
    
    /* Method to upsert Account records based on P94 Account staging records */
    public static void upsertAccounts(List<TCP_P94_Staging_object__c> stagingRecords){ 
    	Map<String,TCP_P94_Staging_object__c> stagingMap = new Map<String,TCP_P94_Staging_object__c>();
        List<TCP_P94_Staging_object__c> stagingProcessedRecords = new List<TCP_P94_Staging_object__c>();
        List<Account> accountParentIdUpdatedRecords = new List<account>();
		//filter staging records
        for(TCP_P94_Staging_object__c stagingRec : stagingRecords){
            if(stagingMap != Null && stagingMap.containsKey(stagingRec.Cust_No_External_Id__c)){
                TCP_P94_Staging_object__c s = stagingMap.get(stagingRec.Cust_No_External_Id__c);
                s.Is_Cust_Processed__c = true;
                stagingProcessedRecords.add(s);
                stagingMap.put(stagingRec.Cust_No_External_Id__c,stagingRec);                
            }
            else{
            	stagingMap.put(stagingRec.Cust_No_External_Id__c,stagingRec);
            }
        }  
        
        //upsert accounts
        
        List<TCP_Sales_Area__c> salesAreaData = new List<TCP_Sales_Area__c>();
        List<Account> accountParentId = new List<Account>();
        Map<String,TCP_Sales_Area__c> salesAreaMap = new Map<String,TCP_Sales_Area__c>();
        Map<String, Account> accMap = new Map<String, Account>();
        
        List<Account> accountsToUpsert = new List<Account>();
        List<Account> accountsParentIdUpdateList = new List<Account>();
        List<TCP_P94_Staging_object__c> stagingRecsList = new List<TCP_P94_Staging_object__c>();
        list<Account> finalUpsertAccountList =  new list<Account>();
        
        salesAreaData = [SELECT Id, Sales_Org__c, Distribution_Channel__c, Division__c, Name, Sales_Region__c FROM TCP_Sales_Area__c];
                    
        if (salesAreaData != null){
        	for(TCP_Sales_Area__c sArea : salesAreaData){
            	String key = sArea.Sales_Org__c + sArea.Distribution_Channel__c + sArea.Division__c;                
                salesAreaMap.put(key,sArea);
            }    
        } 
        
        for(TCP_P94_Staging_object__c stagingRec : stagingMap.values()){
            
            string salesAreaKey = stagingRec.Sales_Org__c + stagingRec.Distribution_Channel__c + stagingRec.Division__c;             
            TCP_Sales_Area__c salesArea =  salesAreaMap.get(salesAreaKey);
                        
        	Account a = new Account();
            a.Name = stagingRec.Name;           	
           	a.AccountNumber = stagingRec.Partner_Number__c;
            a.Sales_Area__c = salesArea.Id;
            a.TCP_Sales_Area_text__c = salesArea.Sales_Region__c;			
			a.TCP_P94_Partner_Account_Number__c = stagingRec.Partner_Number__c;
			a.Partner_Function__c = stagingRec.Partner_Function__c;
            if(stagingRec.Partner_Function__c == 'SP'){
            	a.Customer_Type__c = 'Sold To';    
            }else if (stagingRec.Partner_Function__c == 'SH'){
                a.Customer_Type__c = 'Ship To';    
            }else if (stagingRec.Partner_Function__c == 'BP'){
                a.Customer_Type__c = 'Bill To';    
            }else if (stagingRec.Partner_Function__c == 'PY'){
                a.Customer_Type__c = 'Payer';    
            }			
			a.Partner_Counter__c = stagingRec.Partner_Counter__c;
			a.ShippingStreet = stagingRec.Street__c;
			a.ShippingCity = stagingRec.City__c;
            a.ShippingState = stagingRec.State__c;
			a.ShippingCountry = stagingRec.Country__c;
            a.ShippingPostalCode = stagingRec.Postal_Code__c;
			a.Billing_Block__c = stagingRec.Billing_Block__c;
			a.Delivery_Block__c = stagingRec.Delivery_Block__c;
			a.Order_Block__c = stagingRec.Order_Block__c;            
			a.Incoterms1__c = stagingRec.Incoterms1__c;
			a.Incoterms2__c = stagingRec.Incoterms2__c;
			a.Mode_of_Transport__c = stagingRec.Shipping_Conditions__c;
            a.TCP_Payment_Terms__c = stagingRec.Payment_Terms__c;			
			a.VAT_Reg_No__c = stagingRec.VAT_Reg_No__c;
            a.TCP_P94_Cust_ExternalID__c = stagingRec.Cust_No_External_Id__c;
            a.RecordTypeId =  tcpAccountRecTypeid;
            a.Active__c = !(stagingRec.Deletion_flag__c);
            a.TCP_P94_Sold_To_Account_Group__c = stagingRec.Sold_To_Account_Group__c;
            a.TCP_P94_Partner_Account_Group__c = stagingRec.Partner_Account_Group__c;
			accountsToUpsert.add(a); 
            stagingRecsList.add(stagingRec);
        }
        Schema.SObjectField ftoken = Account.Fields.TCP_P94_Cust_ExternalID__c;
          
        //Processing Result
        Database.UpsertResult[] results = Database.upsert(accountsToUpsert,ftoken,false);
        accountParentId = [SELECT Id, Name, AccountNumber,Customer_Type__c,ParentId,TCP_P94_Cust_ExternalID__c FROM Account where Customer_Type__c = 'Sold To' AND TCP_P94_Cust_ExternalID__c != null];
        if(accountParentId != null){
        	for(Account acc : accountParentId){
            	accMap.put(acc.TCP_P94_Cust_ExternalID__c, acc); 
            }    
        }
        for(Integer i=0; i<results.size();i++){
            if(results[i].isSuccess()){                
                string soldToExternalId = stagingRecsList[i].Sold_To__c + stagingRecsList[i].Sales_Org__c + stagingRecsList[i].Distribution_Channel__c + stagingRecsList[i].Division__c + stagingRecsList[i].Sold_To__c + 'SP';
            	Account accSoldToExtId = accMap.get(soldToExternalId);
                                
                Account accParentId = new Account();
                accParentId.Id = results[i].Id;
                If(stagingRecsList[i].Partner_Function__c != 'SP'){
                	accParentId.ParentId = accSoldToExtId.Id;    
                }
                
                accountParentIdUpdatedRecords.add(accParentId);                
                
                TCP_P94_Staging_object__c s = new TCP_P94_Staging_object__c();
                s.Id = stagingRecsList[i].Id;
                s.Is_Cust_Processed__c = true;
                stagingProcessedRecords.add(s);               
            }
            else if(!results[i].isSuccess()){                
                for(Database.Error e : results[i].getErrors()) {                    
                    TCP_ExceptionLogClass.insertExceptionRecord('Upsert the Accounts from P94 staging object',e.getMessage(),'TCP_P94_AccountSyncBatchHelper','upsertAccounts','Exception');            
                   
                }
            }
        }
        Database.update(stagingProcessedRecords);  
        Database.update(accountParentIdUpdatedRecords);
    }    

}