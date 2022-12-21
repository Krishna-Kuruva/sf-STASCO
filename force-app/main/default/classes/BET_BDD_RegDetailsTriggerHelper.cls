/*************************************************************************************
@Name:  BET_BDD_RegDetailsTriggerHelper     
@=================================================================================
@Purpose: Helper class for BET_BDD_RegDetailsTrigger trigger
@=================================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Naveen K N     ```````````````    28-Jan-2021         INITIAL DEVELOPMENT
*************************************************************************************/
public with sharing class BET_BDD_RegDetailsTriggerHelper {
    public static void OnBeforeInsert(List<BET_Registration_Details__c> RegDetailsList){
        BETFormRecordLock(RegDetailsList);
    }
    
    public static void OnBeforeUpdate(List<BET_Registration_Details__c> RegDetailsList){
        BETFormRecordLock(RegDetailsList);
    }
    
    public static void OnBeforeDelete(List<BET_Registration_Details__c> RegDetailsList, Map<Id,BET_Registration_Details__c> RegDetailsMap){
        BETFormRecordLock(RegDetailsList);
        markIsCompanyRegisteredTrue(RegDetailsMap);
        
    }
    
    public static void BETFormRecordLock(List<BET_Registration_Details__c> RegDetailsList){
        List<string> BETFormIds = new List<string>();
        Map<Id, String> BETIdsWithStatus = new Map<Id, String>();
        
        for(BET_Registration_Details__c RegDetail: RegDetailsList){
            BETFormIds.add(RegDetail.BDD_Form__c);
        }
        List<BET_BDD_Form__c> BETForms = [Select Id, BET_Status__c from BET_BDD_Form__c where Id IN :BETFormIds];
        for(BET_BDD_Form__c BETForm: BETForms){
            BETIdsWithStatus.put(BETForm.Id, BETForm.BET_Status__c);
        }
        
        for(BET_Registration_Details__c RegDetail: RegDetailsList){
            string BETStatus = BETIdsWithStatus.get(RegDetail.BDD_Form__c);
            if(BETStatus == 'Ready to Onboard' || BETStatus == 'Submitted'){
                RegDetail.addError('Only ‘BET Status’ is editable at this stage.');
            }
        }
    }
    
    public static void markIsCompanyRegisteredTrue(Map<Id,BET_Registration_Details__c> RegDetailsMap){
        Set<Id> formIdSet = new Set<Id>();
        List<BET_BDD_Form__c> formRecsUpdateList = new List<BET_BDD_Form__c>();
        for(BET_Registration_Details__c regDet : RegDetailsMap.values()){
            formIdSet.add(regDet.BDD_Form__c);
        }
        List<BET_BDD_Form__c> FormRecsList = new List<BET_BDD_Form__c>();
        FormRecsList = [Select Id,GT_Is_Comp_Reg__c,Name,(Select Id,Name,BDD_Form__c from BDD_Registration_Details__r) from BET_BDD_Form__c where Id IN :formIdSet];
        for(BET_BDD_Form__c formRec : FormRecsList) {
            List<BET_Registration_Details__c> regRecList = new List<BET_Registration_Details__c>();
            for( BET_Registration_Details__c regDet : formRec.BDD_Registration_Details__r ) {
                regRecList.add(regDet);
            }
            if(regRecList.size()==1 && RegDetailsMap.containsKey(regRecList.get(0).ID)){
                formRec.GT_Is_Comp_Reg__c = false;
                formRecsUpdateList.add(formRec);
            }}
        database.update(formRecsUpdateList, false);
    }
}