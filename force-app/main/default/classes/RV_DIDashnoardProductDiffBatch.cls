/***********************************************************************************
 * Created By   : Dhriti Krishna Ghosh Moulick
 * Created Date : 04/09/2018
 * Description  : This batch will run every 15 seconds, fetch the specific quote name from 
 * 				 ProductDifferentialDashboard custom metadata and upsert quote name and price in 
 * 				 product differential object.
 * Last Modified By:
 * Last Modified Date :
 * *********************************************************************************/
global class RV_DIDashnoardProductDiffBatch implements Database.Batchable<sObject>{
    	
		global Database.QueryLocator start(Database.BatchableContext BC){
            Set<String> quoteName = new Set<String>();
            for(ProductDifferentialDashboard__mdt quote : [select id,MasterLabel,DeveloperName from ProductDifferentialDashboard__mdt]){ // fetching quote name from custom metadata)
                quoteName.add(quote.MasterLabel);
            } 
            String queryFromReuter = 'select id,Quote_Display_Name__c,Price__c from Reuters_Quotes__c '+
                                      'where Quote_Display_Name__c IN :quoteName AND LastmodifiedDate = LAST_N_DAYS:4 '+
									  'Order by LastModifiedDate DESC'; // String query to fetch price from Reuter quote
            /*String queryFromReuter ='Select  id,Quote_Name__c,Valid_Month__c,Max(CreatedDate) maxCreatedDate   from Reuters_Quotes__c'+
									'where Valid_Month__c!=null or Quote_Name__c in:quoteName group by Quote_Name__c,Valid_Month__c';*/
            return Database.getQueryLocator(queryFromReuter);
        }
    
    	global void execute(Database.BatchableContext BC, List<Reuters_Quotes__c> reuterQuoteLst){ 
            Map<String,Reuters_Quotes__c> mapOfReuter = new Map<String,Reuters_Quotes__c>();
            if(!reuterQuoteLst.isEmpty()){
                for(Reuters_Quotes__c reuter : reuterQuoteLst){
                    if(!mapOfReuter.containskey(reuter.Quote_Display_Name__c)){
                       mapOfReuter.put(reuter.Quote_Display_Name__c,reuter);
                    }
                }
            }
        	System.debug('%%%%%mapOfReuter%%%%%'+mapOfReuter);
            List<Product_Differential__c> productDiffLst = new List<Product_Differential__c>();
            String recTypeId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByDeveloperName().get('Dashboard').getRecordTypeId();

            if(!mapOfReuter.isEmpty()){
                for(Reuters_Quotes__c reuterQuote : mapOfReuter.values()){ //Iterate Reuter quote
                    Product_Differential__c productDiff = new Product_Differential__c();
                    productDiff.Name = reuterQuote.Quote_Display_Name__c;
                    productDiff.Price__c = reuterQuote.Price__c;
                    productDiff.RecordTypeId = recTypeId;
                    productDiffLst.add(productDiff);
                }
            }
            if(!productDiffLst.isEmpty()){
                Schema.SObjectField f = Product_Differential__c.Fields.Id;
                Database.UpsertResult [] cr = Database.upsert(productDiffLst, f, false);
                system.debug('Success ------->' + cr);
                for (Database.UpsertResult sr : cr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully upserted Product Differential records ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            RV_ClassException.getInstance();
                            RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'RV_DIDashnoardProductDiffBatch', 'execute','Exception');
                        }
                    }
                }
            }
        }
    
    	global void finish(Database.BatchableContext BC){
            Datetime sysTime = System.now();
            sysTime = sysTime.addMinutes(1);
            //String chron_exp = '' + 0 + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + 
            //    				sysTime.month() + ' ? ' + sysTime.year();
           // System.schedule('Snapshot-' + sysTime.getTime(), chron_exp, new RV_SnapshotScheduler());
        }
}