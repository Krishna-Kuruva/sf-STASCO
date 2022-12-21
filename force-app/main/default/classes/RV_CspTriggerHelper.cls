public with sharing class RV_CspTriggerHelper {
/*****************************************************************************
@Name:  RV_CspTriggerHelper     
@=========================================================================
@Purpose: Helper class for RV_CspTrigger.trg
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    12-Feb-2020         INITIAL DEVELOPMENT

******************************************************************************/  

    //On before insert
    public static void onBeforeInsert(List<Customer_Specific_Pricing__c> cspListNew){
        validateCsp(cspListNew);
    }

    //On before update
    public static void onBeforeUpdate(List<Customer_Specific_Pricing__c> cspListOld, List<Customer_Specific_Pricing__c> cspListNew, 
                                      Map<Id, Customer_Specific_Pricing__c> cspOldMap, Map<Id, Customer_Specific_Pricing__c> cspNewMap){
        validateCsp(cspListNew);
    }

    //On before delete
    public static void onBeforeDelete(List<Customer_Specific_Pricing__c> cspListOld, Map<Id, Customer_Specific_Pricing__c> cspOldMap){

    }
    
    //on after insert
    public static void onAfterInsert(List<Customer_Specific_Pricing__c> cspListNew, Map<Id, Customer_Specific_Pricing__c> cspNewMap){

    }
    
    //on after update
    public static void onAfterUpdate(List<Customer_Specific_Pricing__c> cspListOld, List<Customer_Specific_Pricing__c> cspListNew,
                                     Map<Id, Customer_Specific_Pricing__c> cspOldMap, Map<Id, Customer_Specific_Pricing__c> cspNewMap){

    }


    public static void validateCsp(List<Customer_Specific_Pricing__c> cspList){
        Set<Id> locationIdSet = new Set<Id>();
        Set<String> salesOrgSet = new Set<String>();
        Id marginRecordTypeId = Schema.SObjectType.Margin__c.getRecordTypeInfosByDeveloperName().get('Truck_ITT').getRecordTypeId();

        for(Customer_Specific_Pricing__c csp : cspList){
            locationIdSet.add(csp.Plant__c);
            salesOrgSet.add(csp.Sales_Org__c);
        }
        if(!locationIdSet.isEmpty() && !salesOrgSet.isEmpty()){
        //START - Rahul Sharma | Date: 02-Nov-20 : Updated logic to include margins for all tranches.
            List<Margin__c> marginList = [SELECT Id,
                                                 Sales_Org__c,
                                                 Plant__c,
                                                 Sales_Mgn_AGO_B7__c,
                                                 Sales_Mgn_IGO_50ppm__c,
                                          		 Tranche__c,
                                                 Sales_Mgn_ULG95_E5__c FROM Margin__c WHERE Sales_Org__c IN : salesOrgSet AND 
                                                                                            Plant__c IN : locationIdSet AND 
                                                                                            RecordTypeId =: marginRecordTypeId];
            System.debug('RV_CspTriggerHelper >> validateCsp >> marginList: '+marginList);
            if(!marginList.isEmpty()){
                for(Customer_Specific_Pricing__c csp : cspList){
                    for(Margin__c margin : marginList){
                        if(margin.Sales_Org__c == csp.Sales_Org__c && margin.Plant__c == csp.Plant__c && margin.Tranche__c == csp.Tranche__c){
        //END - Rahul Sharma | Date: 02-Nov-20 : Updated logic to include margins for all tranches.
                            //START - Rahul Sharma | Date: 20-Janv-21 : Fixed null pointer exception.
                            Decimal cspPrice = 0;
                            if(csp.CSP_Eur_100L__c != null)
                                cspPrice = csp.CSP_Eur_100L__c;
                            if(margin.Sales_Mgn_AGO_B7__c == null)
                                margin.Sales_Mgn_AGO_B7__c = 0;
                            if(margin.Sales_Mgn_IGO_50ppm__c == null)
                                margin.Sales_Mgn_IGO_50ppm__c = 0;
                            if(margin.Sales_Mgn_ULG95_E5__c == null)
                                margin.Sales_Mgn_ULG95_E5__c = 0;
                            //END - Rahul Sharma | Date: 20-Janv-21 : Fixed null pointer exception.
                            System.debug('RV_CspTriggerHelper >> validateCsp >> cspPrice: '+cspPrice+' csp.Grade__c: '+csp.Grade__c);
                            System.debug('RV_CspTriggerHelper >> validateCsp >> margin.Sales_Mgn_AGO_B7__c: '+margin.Sales_Mgn_AGO_B7__c+' margin.Sales_Mgn_IGO_50ppm__c: '+margin.Sales_Mgn_IGO_50ppm__c+' margin.Sales_Mgn_ULG95_E5__c'+margin.Sales_Mgn_ULG95_E5__c);
                            if(csp.Grade__c == 'AGO B7' && (csp.CSP_Eur_100L__c + margin.Sales_Mgn_AGO_B7__c) < 0){
                                csp.addError('Invalid input. Addition of Sales Margin and Customer Specific Pricing cannot be less than zero.');
                            }
                            else if(csp.Grade__c == 'IGO 50ppm' && (csp.CSP_Eur_100L__c + margin.Sales_Mgn_IGO_50ppm__c) < 0){
                                csp.addError('Invalid input. Addition of Sales Margin and Customer Specific Pricing cannot be less than zero.');
                            }
                            else if(csp.Grade__c == 'ULG95 E5' && (csp.CSP_Eur_100L__c + margin.Sales_Mgn_ULG95_E5__c) < 0){
                                csp.addError('Invalid input. Addition of Sales Margin and Customer Specific Pricing cannot be less than zero.');
                            }
                        }
                    }
                }
            }
        }
    }

}