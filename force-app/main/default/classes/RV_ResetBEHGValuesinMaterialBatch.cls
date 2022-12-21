global class RV_ResetBEHGValuesinMaterialBatch implements Database.Batchable<sObject>{
	 global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String queryFromMaterial = 'SELECT Id,Name,BEHG_Value_100l__c,Current_BEHG_valid_from_date__c,Current_BEHG_valid_to_date__c,'+
            'Future_BEHG_valid_from_date__c,Future_BEHG_valid_to_date__c,Future_BEHG_value_in_100l__c from Product_Catalogue__c where '+
            'Current_BEHG_valid_to_date__c = TODAY';
        return Database.getQueryLocator(queryFromMaterial);
    }
    global void execute(Database.BatchableContext bc, List<Product_Catalogue__c	> records){
        // process each batch of records
        List<Product_Catalogue__c> prdctCatUpdatelst = new List<Product_Catalogue__c>();
        for(Product_Catalogue__c productCateg : records){
            if(productCateg.Current_BEHG_valid_to_date__c != null){
                if(productCateg.Current_BEHG_valid_to_date__c == System.today()){
                    productCateg.Current_BEHG_valid_from_date__c = productCateg.Future_BEHG_valid_from_date__c;
                    productCateg.Current_BEHG_valid_to_date__c = productCateg.Future_BEHG_valid_to_date__c;
                    productCateg.BEHG_Value_100l__c = productCateg.Future_BEHG_value_in_100l__c;
                    productCateg.Future_BEHG_valid_from_date__c = null;
                    productCateg.Future_BEHG_valid_to_date__c = null;
                    productCateg.Future_BEHG_value_in_100l__c = 0;
                    prdctCatUpdatelst.add(productCateg);
                }
            }
        }
        if(!prdctCatUpdatelst.isEmpty()){
            try{
                update prdctCatUpdatelst;
            }catch(Exception de){
                System.debug('========de========='+de);
            }
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}