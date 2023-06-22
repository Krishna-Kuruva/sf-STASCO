/* Description - Batch Helper Class which will run every 2 hours for P94 Material Staging Records. This Staging Records will be a dump from GSAP system 
 * via DDF/Biztalk system as part of P94.
 * Date - 10-05-2023
 * Created By - Madhu Javvaji
 */

 /* Handler Class to process all the product staging records in a batch to create/update the relevent product records as part of
  * P94 Material master data Intgeration */
public class TCP_P94_ProductSyncBatchHelper {
    
    //Constants
    static final String SelectString = 'SELECT';
    
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    
    /* Method to fetch all the Material staging records to be processed in the start method of the batch */
    public Static String getQuery(){
        Set<String> SobjectFields = Schema.getGlobalDescribe().get('TCP_P94_Staging_object__c').getDescribe().fields.getMap().keySet();
		String P94DataTypeVal = 'MATR';        
        String query = SelectString + ' ' + String.join(new List<String>(SobjectFields), ',') + 
            	   	   ' FROM TCP_P94_Staging_object__c WHERE Is_Matr_Processed__c=false AND Data_Type__c = \'MATR\' AND  Prod_Salesline_External_Id__c != NULL AND Prod_External_Id__c != NULL Order By CreatedDate';
        system.debug('getQuery==============>'+query);        
        
        return query;        
    }
    
    /* Method to upsert Product records based on P94 staging records */
    public static void upsertProducts(List<TCP_P94_Staging_object__c> stagingRecords){ 
                    
    	Map<String,TCP_P94_Staging_object__c> stagingMap = new Map<String,TCP_P94_Staging_object__c>();
        List<TCP_P94_Staging_object__c> stagingProcessedRecords = new List<TCP_P94_Staging_object__c>();
        
		//filter staging records
        for(TCP_P94_Staging_object__c stagingRec : stagingRecords){
            if(stagingMap != Null && stagingMap.containsKey(stagingRec.Prod_External_Id__c)){
                TCP_P94_Staging_object__c s = stagingMap.get(stagingRec.Prod_External_Id__c);
                s.Is_Matr_Processed__c = true;
                stagingProcessedRecords.add(s);
                stagingMap.put(stagingRec.Prod_External_Id__c,stagingRec);
                system.debug('stagingMap in if ======>'+stagingMap);
            }
            else{
            	stagingMap.put(stagingRec.Prod_External_Id__c,stagingRec);
                system.debug('stagingMap in else ======>'+stagingMap);
                system.debug('stagingMap values in else ======>'+stagingMap.values());                
            }
        }  
        
        //upsert products
                        
        List<Product2> productsToUpsert = new List<Product2>();
        List<Product2> accountsParentIdUpdateList = new List<Product2>();
        List<TCP_P94_Staging_object__c> stagingRecsList = new List<TCP_P94_Staging_object__c>();
        list<Product2> finalUpsertAccountList =  new list<Product2>();
                      
                
        for(TCP_P94_Staging_object__c stagingRec : stagingMap.values()){
            
            string prodSalesLineExtID = stagingRec.Sales_Org__c + stagingRec.Distribution_Channel__c;
            
            //holds list of Product
            List<product2> lstProduct = new List<product2>();
    
            TCP_Products_Sales_Line__c psl = new TCP_Products_Sales_Line__c();
            psl.Sales_Org__c = stagingRec.Sales_Org__c;
            psl.Distribution_Channel__c = stagingRec.Distribution_Channel__c;
            psl.TCP_P94_ProdSL_ExternalID__c = prodSalesLineExtID;
            psl.Active__c = true;                
            upsert psl TCP_P94_ProdSL_ExternalID__c;
            
			Product2  prd = new Product2();
        	prd.ProductCode = stagingRec.Material_Number__c;
            prd.Name = stagingRec.Material_Description__c;
            prd.Unit_of_Measure__c = stagingRec.Unit_of_Measure__c;
            prd.Gross_Weight__c = stagingRec.Gross_Weight__c;
            prd.Net_Weight__c = stagingRec.Net_Weight__c;            
            prd.Products_Sales_Line__c = psl.Id;
            prd.IsActive = true;
            prd.TCP_P94_Prod_ExternalId__c = stagingRec.Material_Number__c + prodSalesLineExtID; //8000034ROTOD
            
            productsToUpsert.add(prd); 
            stagingRecsList.add(stagingRec);
        }
        
        Schema.SObjectField ftoken = Product2.Fields.TCP_P94_Prod_ExternalId__c;
                
        //Processing Result
        Database.UpsertResult[] results = Database.upsert(productsToUpsert,ftoken,false);
        
        for(Integer i=0; i<results.size();i++){
            if(results[i].isSuccess()){
                TCP_P94_Staging_object__c s = new TCP_P94_Staging_object__c();
                s.Id = stagingRecsList[i].Id;
                s.Is_Matr_Processed__c = true;
                stagingProcessedRecords.add(s);                
            }
            else if(!results[i].isSuccess()){
                system.debug('inside results failure======>');
                for(Database.Error e : results[i].getErrors()) {
                    system.debug('e.getMessage====>'+e.getMessage());
					TCP_ExceptionLogClass.insertExceptionRecord('Upsert the Productss from P94 staging object',e.getMessage(),'TCP_P94_ProductSyncBatchHelper','upsertProducts','Exception');           
                }
            }
        }
        Database.update(stagingProcessedRecords);        
    } 
}