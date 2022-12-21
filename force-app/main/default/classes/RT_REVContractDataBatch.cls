/*
 Created by Dharmendra.Singh2 on 08/01/2020.
*/

public class RT_REVContractDataBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {	
        //ID auID = 'a3F3G0000008dvYUAQ';
        String query = 'Select Id, RT_AMOUNT__c, Active__c, RT_Sold_to_Name__c, RT_Plant_Desc__c,RT_Material_Desc__c,RT_Key_Value__c,RT_Condition_Type_Name__c '
            			+ ' From REV_Contract_Master__c Where Active__c=true'
            			+ ' and RT_Sold_to_Name__c!= null and RT_Plant_Desc__c!= null and RT_Material_Desc__c!=null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<REV_Contract_Master__c> scope) {
        Set<Id> auIDSet = new Set<Id>();
       // List<RT_PriceOutput__c> priceOutPutList = new List<RT_PriceOutput__c>();
        Map<Id, REV_Contract_Master__c> contractMasterMap = new Map<Id, REV_Contract_Master__c>();

        for(REV_Contract_Master__c aContractMaster : scope){
            auIDSet.add(aContractMaster.Id);
            contractMasterMap.put(aContractMaster.Id, aContractMaster);
        }
        System.debug('scope = ' + scope.size());
        System.debug('contractMasterMap = '+contractMasterMap.size());
        if (scope.size() > 0 && contractMasterMap.size() > 0) {
            RT_REVContractTriggerHelper.upsertPriceOutPut(scope, contractMasterMap);
        }
    }
    
    public void finish(Database.BatchableContext BC) {}

}