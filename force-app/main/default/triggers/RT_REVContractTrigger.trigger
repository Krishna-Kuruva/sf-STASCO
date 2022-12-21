/**
* Created by Dharmendra.Singh2 on 8/6/2020.
*/
trigger RT_REVContractTrigger on REV_Contract_Master__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

   switch on Trigger.operationType 
    {
            when BEFORE_INSERT {
                RT_REVContractTriggerHandler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                RT_REVContractTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                RT_REVContractTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                RT_REVContractTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                RT_REVContractTriggerHandler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                RT_REVContractTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                RT_REVContractTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    if(!Trigger.isDelete && !Trigger.isUndelete) 
    {
        List<REV_Contract_Master__c> cndRevContrctMastrLst = new List<REV_Contract_Master__c>();
        Set<Id> cndRevProdctGrpMap = new Set<Id>();
        Set<Id> cndRevProdctCodeMap = new Set<Id>();
        Set<Id> cndRevLoctnMap = new Set<Id>();
    
        RT_REVContractTriggerHelper at = new RT_REVContractTriggerHelper();
        List<REV_Contract_Master__c> revConMasterList = new List<REV_Contract_Master__c>();
        Map<Id, REV_Contract_Master__c> revConMasterMap = new Map<Id, REV_Contract_Master__c>();
        for(REV_Contract_Master__c revContractMaster : Trigger.new){
            if(revContractMaster.Country_Name__c=='TU' && revContractMaster.Active__c==true && revContractMaster.RT_key_value__c !=null){
                revConMasterList.add(revContractMaster);
                revConMasterMap.put(revContractMaster.Id, revContractMaster);
            }
            else if(revContractMaster.Country_Name__c == 'CA') 
            {
                cndRevContrctMastrLst.add(revContractMaster); 
                cndRevProdctGrpMap.add(revContractMaster.RT_Material_Desc__c);
                cndRevProdctCodeMap.add(revContractMaster.RE_CND_Product_Pricing_Basis__c);
                cndRevLoctnMap.add(revContractMaster.RE_CND_Plant_Pricing_Basis__c);
            }        
        }
        System.debug('revContractMaster---------' +revConMasterList);
        System.debug('revConMasterMap---------' +revConMasterMap);
    
        if(Trigger.isBefore && revConMasterList.size()>0){
            RT_REVContractTriggerHelper.updateAureus(revConMasterList);
        } 
        if(Trigger.isAfter && revConMasterList.size()>0){
           // RT_REVContractTriggerHelper.upsertPriceOutPut(revConMasterList, revConMasterMap);
            RT_REVContractTriggerHelper.upsertPriceBooks(revConMasterList, revConMasterMap);
    
        }
        
        if(Trigger.isBefore && cndRevContrctMastrLst.Size() > 0)            
            RE_CND_RevContractTriggerHelper.updateCNDpricingBasis(cndRevContrctMastrLst,cndRevProdctGrpMap,cndRevProdctCodeMap,cndRevLoctnMap);  
    } 
        
}