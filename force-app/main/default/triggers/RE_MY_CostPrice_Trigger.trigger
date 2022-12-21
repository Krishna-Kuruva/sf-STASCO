//trigger to insert/update the lastest morning CBU data from cost price malaysia object to MOA object 
trigger RE_MY_CostPrice_Trigger on RE_MY_CostPrice__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    Id MalaysiaRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
    Id CovamoMalaysiaRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Covamo Malaysia').getRecordTypeId();
    Boolean malaysiaRecords =false;
   // Boolean nonMalaysiaRecords =false;
    If(trigger.isInsert || trigger.isUpdate)
    {
        for(RE_MY_CostPrice__c rec : Trigger.new)
        {
            If(rec.RecordTypeId == MalaysiaRecordTypeId || rec.RecordTypeId == CovamoMalaysiaRecordTypeId)
            {
                malaysiaRecords = true;
                break;
            }
           /* else {
                nonMalaysiaRecords = true; 
            }*/
        }  
    }
    
    /*
    RE_Cost_Price_Trigger_Handler obj = new RE_Cost_Price_Trigger_Handler(nonMalaysiaRecords);
    switch on Trigger.operationType 
    {
        when BEFORE_INSERT {
            RE_Cost_Price_Trigger_Handler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            RE_Cost_Price_Trigger_Handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when BEFORE_DELETE {
            RE_Cost_Price_Trigger_Handler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_INSERT {
            RE_Cost_Price_Trigger_Handler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            RE_Cost_Price_Trigger_Handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_DELETE {
            RE_Cost_Price_Trigger_Handler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            RE_Cost_Price_Trigger_Handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
    */
    
    If( !trigger.isDelete && !trigger.isUndelete)
    {
        Boolean isEastData = RE_MY_CostPrice_TriggerHelper.checkCountry(trigger.new);
        System.debug('isEastData--'+isEastData);
        if(trigger.isInsert && trigger.isAfter)
        {
            if(isEastData){
                System.debug('inside trigger');
                RE_MY_CostPrice_TriggerHelper.onAfterMorningCBUHelper(trigger.new,trigger.newMap);
                RE_TH_CostPriceTriggerHelper.onAfterMorningTHCBUHelper(trigger.new,trigger.newMap);
                Boolean runonce = RE_MY_CostPrice_TriggerHelper.runOnce();
                System.debug('runonce '+ runonce);
                if(runonce)
                    RE_MY_CostPrice_TriggerHelper.onAfterMorningCBUHelperPH(Trigger.new,  Trigger.newMap);              
                else
                    RE_MY_CostPrice_TriggerHelper.onAfterBlendedCostDataInsert(Trigger.new, Trigger.newMap);  
            }
        }
        
        
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            
            if(malaysiaRecords){                
                RE_MYCostPrice_Covamo_TriggerHelper.onDataUpdateForCovamo(trigger.new);
            }
        }
        if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
            if(malaysiaRecords){
                RE_MYCostPrice_Covamo_TriggerHelper.updateSecondaryRecords(trigger.new);
            }
        }
    }   
}