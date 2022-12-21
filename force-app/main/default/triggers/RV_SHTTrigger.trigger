/*****************************************************************************
@Name:  RV_SHTTrigger     
@=========================================================================
@Purpose: Trigger will execute on insert and update to calculate ATP_Live__c and Sales_8_30_17_30__c value                                                                                         
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      26/09/2017         INITIAL DEVELOPMENT
@1.1 - Rahul Sharma                      02/03/2021         Added onBeforeInsert helper. 
******************************************************************************/
trigger RV_SHTTrigger on SHT__c (after insert,after update, before insert, before update) {
    //Fix_170906_04Jun2019_Soumyajit starts
    if(Trigger.isBefore)
    {
        for(SHT__c sht: Trigger.new){
            if(Trigger.isInsert)
            {
                sht.Rv_LastModifiedById__c = sht.CreatedById;
            	sht.Rv_LastModifiedDate__c = sht.CreatedDate;
            }
            if(Trigger.isUpdate)
            {
                if(		(sht.SAP_Contract_Number__c!=NULL && sht.SAP_Contract_Number__c.equals(Trigger.oldMap.get(sht.id).SAP_Contract_Number__c))
                   	|| 	(sht.SAP_Contract_Number__c==NULL)
                  )
                {
                    sht.Rv_LastModifiedById__c = sht.LastModifiedById;
                    sht.Rv_LastModifiedDate__c = sht.LastModifiedDate;
                }
            }
        }
        //START - Rahul Sharma | Date - 02-Mar-2021 : Added before insert helper method.
        if(Trigger.isInsert){
            RV_SHTTriggerHelper.onBeforeInsert(Trigger.new);    
        }
        //END- Rahul Sharma | Date - 02-Mar-2021 : Added before insert helper method.
    }
    //Fix_170906_04Jun2019_Soumyajit ends
    if (Trigger.isInsert && Trigger.isAfter){ // on after insert
        RV_SHTTriggerHelper.onAfterInsertSHTTriggerHelper(Trigger.new,Trigger.oldMap);
    }
    //On after update
    if(Trigger.isUpdate && Trigger.isAfter){
        List<SHT__c> updateshtrecordsSAP=new List<SHT__c>();
        List<SHT__c> updateshtrecordsSHTDave=new List<SHT__c>();
        for(SHT__c sht: Trigger.new){
            SHT__c oldRecord=Trigger.oldMap.get(sht.id);
            if(sht.SAP_Contract_Number__c!=NULL && oldRecord.SAP_Contract_Number__c==NULL){
                updateshtrecordsSAP.add(sht);
            }
            else
                updateshtrecordsSHTDave.add(sht);
        }
        if(updateshtrecordsSAP.size()>0){ 
            //system.debug('#### Running GSAP Updates only ####');
            RV_CreateSHTSAP.processStagingRecord(Trigger.new,Trigger.oldMap);
        }
        if(updateshtrecordsSHTDave.size()>0){
            //system.debug('#### Running GSAP and ATP Updates ####');
            RV_SHTTriggerHelper.onAfterUpdateSHTTriggerHelper(Trigger.new,Trigger.newMap,Trigger.oldMap); 
            RV_CreateSHTSAP.processStagingRecord(Trigger.new,Trigger.oldMap);
        }
        //START - Rahul Sharma | Date - 26-Mar-2021 : Added helper method for after update operations.
        RV_SHTTriggerHelper.onAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        //END - Rahul Sharma | Date - 26-Mar-2021 : Added helper method for after update operations.
    }
}