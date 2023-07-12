public class TCP_P94_CMIRSyncBatchHelper {
    
    //Constants
    static final String SelectString = 'SELECT';
    
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    
    /* Method to fetch all the staging records to be processed in the start method of the batch */
    public Static String getQuery(){
        Set<String> SobjectFields = Schema.getGlobalDescribe().get('TCP_P94_Staging_object__c').getDescribe().fields.getMap().keySet();
		//String P94DataTypeVal = 'CUST';        
        String query = SelectString + ' ' + String.join(new List<String>(SobjectFields), ',') + 
            	   	   ' FROM TCP_P94_Staging_object__c WHERE Is_CMIR_Processed__c=false AND Data_Type__c = \'CMIR\' Order By CreatedDate';
        return query;        
    }
    
    /* Method to upsert CMIR records based on P94 staging records */
    public static void upsertCMIR(List<TCP_P94_Staging_object__c> stagingRecords){ 
        
        //Get account list for NA region
    	List<Account> accountIds = new List<Account>();
        string shipToPartnerFun = 'SH';
        String strNA = 'NA';
        
        accountIds = [SELECT id, Name, AccountNumber,sales_Area__r.Sales_Org__c,sales_Area__r.Distribution_Channel__c, ParentId, Customer_Type__c, Partner_Function__c, TCP_P94_Cust_ExternalID__c, Sales_Area__c   FROM Account where recordtypeid =: tcpAccountRecTypeid  and Partner_Function__c = :shipToPartnerFun and  TCP_P94_Cust_ExternalID__c != null and Sales_Area__c != null and TCP_Sales_Area_text__c = :strNA and Active__c = TRUE Order By CreatedDate];
        Map<String,Account> accountMap = new Map<String,Account>();
            System.debug('Checking accountIds '+accountIds);
            if (accountIds != null){
                for(Account a : accountIds){
                    String key = a.AccountNumber + a.sales_Area__r.Sales_Org__c + a.sales_Area__r.Distribution_Channel__c;       
                    accountMap.put(key,a);
                    system.debug('accountMap===>'+accountMap);
                }    
            }
        
        //Get product list for P94
        List<Product2> productIds = new List<Product2>();
        
        productIds = [SELECT id, Name, ProductCode, Unit_of_Measure__c,Products_Sales_Line__r.Sales_Org__c, Products_Sales_Line__r.Distribution_Channel__c, Products_Sales_Line__c, IsActive, TCP_P94_Prod_ExternalId__c FROM Product2 WHERE TCP_P94_Prod_ExternalId__c != null AND IsActive = true  Order By CreatedDate];
        Map<String,Product2> productMap = new Map<String,Product2>();
            
            if (productIds != null){
                for(Product2 prd : productIds){
                    String key = prd.ProductCode + prd.Products_Sales_Line__r.Sales_Org__c + prd.Products_Sales_Line__r.Distribution_Channel__c;       
                    productMap.put(key,prd);
                    system.debug('productMap===>'+productMap);
                }    
            }
             
        
        Map<String,TCP_P94_Staging_object__c> stagingMap = new Map<String,TCP_P94_Staging_object__c>();
        List<TCP_P94_Staging_object__c> stagingProcessedRecords = new List<TCP_P94_Staging_object__c>();
        
        List<TCP_P94_Staging_object__c> updateCMIRExternalID = new List<TCP_P94_Staging_object__c>();
        //List<Account> accountParentIdUpdatedRecords = new List<account>();
        //
        for(TCP_P94_Staging_object__c stagingRec : stagingRecords){
            TCP_P94_Staging_object__c s = new TCP_P94_Staging_object__c();
            s.Id = stagingRec.Id;
            s.Customer_Number__c = stagingRec.Customer_Number__c.replaceFirst('^0+', '');
            s.Material_Number__c = stagingRec.Material_Number__c.replaceFirst('^0+', '');
            s.CMIR_External_Id__c = stagingRec.Customer_Number__c.replaceFirst('^0+', '') + stagingRec.Material_Number__c.replaceFirst('^0+', '') + stagingRec.Sales_Org__c + stagingRec.Distribution_Channel__c;
            updateCMIRExternalID.add(s);
        }
        
        Database.update(updateCMIRExternalID);
        
        List<TCP_P94_Staging_object__c> processStagingRecords =  new List<TCP_P94_Staging_object__c>();
        String CMIRDataType = 'CMIR';
        processStagingRecords = [SELECT Customer_Number__c, Sales_Org__c, Distribution_Channel__c, Date__c, Time__c, Full_Load__c, Material_Number__c, Deletion_flag__c, Data_type__c, Prod_Salesline_External_Id__c, CMIR_External_Id__c, Is_CMIR_Processed__c FROM TCP_P94_Staging_object__c WHERE CMIR_External_Id__c != NULL AND Data_Type__c =:CMIRDataType ORDER By CreatedDate ];
        
        if (processStagingRecords.size()>0){
        	for(TCP_P94_Staging_object__c stagingRec : processStagingRecords){
                if(stagingMap != Null && stagingMap.containsKey(stagingRec.CMIR_External_Id__c)){
                    TCP_P94_Staging_object__c s = stagingMap.get(stagingRec.CMIR_External_Id__c);
                    s.Is_CMIR_Processed__c = true;
                    stagingProcessedRecords.add(s);
                    stagingMap.put(stagingRec.CMIR_External_Id__c,stagingRec);                
                }
                else{
                    stagingMap.put(stagingRec.CMIR_External_Id__c,stagingRec);
                }
        	}    
        }
        
        List<TCP_Product_Customer__c> CMIRToUpsert = new List<TCP_Product_Customer__c>();
        List<TCP_P94_Staging_object__c> stagingRecsList = new List<TCP_P94_Staging_object__c>();
        
        for(TCP_P94_Staging_object__c stagingRec : stagingMap.values()){
            String accountKey = stagingRec.Customer_Number__c + stagingRec.Sales_Org__c + stagingRec.Distribution_Channel__c;
            system.debug('accountKey===>'+accountKey);
            String productKey = stagingRec.Material_Number__c + stagingRec.Sales_Org__c + stagingRec.Distribution_Channel__c;
            system.debug('productKey====>'+productKey);
            Account accRec =  accountMap.get(accountKey);
            system.debug('accRec====>'+accRec);
            Product2 prodRec = productMap.get(productKey);
            system.debug('prodRec====>'+prodRec);
            //for(Account acc : accountIds){
            //if (accRec != null || prodRec!= null){
            if (accRec != null ){
                if(prodRec!= null){
                    system.debug('inside null check ====>');
                    TCP_Product_Customer__c CMIR =  new TCP_Product_Customer__c();
                    CMIR.Active__c = true;
                    CMIR.Account__c = accRec.id;
                    CMIR.Product__c = prodRec.id;
                    CMIR.Partner_Function__c = 'SH';
                    CMIR.TCP_P94_CMIR_ExternalId__c = stagingRec.Customer_Number__c + stagingRec.Material_Number__c + stagingRec.Sales_Org__c + stagingRec.Distribution_Channel__c;
                    CMIRToUpsert.add(CMIR); 
                    stagingRecsList.add(stagingRec);
            	}
            }
            	
           // }           
            
            //CMIRToUpsert.add(CMIR);
            //stagingRecsList.add(stagingRec);
        }
        Schema.SObjectField ftoken = TCP_Product_Customer__c.Fields.TCP_P94_CMIR_ExternalId__c;
        
        //Processing Result
        Database.UpsertResult[] results = Database.upsert(CMIRToUpsert,ftoken,false);
        
        for(Integer i=0; i<results.size();i++){
            if(results[i].isSuccess()){
                TCP_P94_Staging_object__c s = new TCP_P94_Staging_object__c();
                s.Id = stagingRecsList[i].Id;
                s.Is_CMIR_Processed__c = true;
                stagingProcessedRecords.add(s);                
            }
            else if(!results[i].isSuccess()){
                system.debug('inside results failure======>');
                for(Database.Error e : results[i].getErrors()) {
                    system.debug('e.getMessage====>'+e.getMessage());
					TCP_ExceptionLogClass.insertExceptionRecord('Upsert CMIR records from P94 staging object',e.getMessage(),'TCP_P94_CMIRSyncBatchHelper','upsertCMIR','Exception');           
                }
            }
        }
        Database.update(stagingProcessedRecords); 
        
    }   

}