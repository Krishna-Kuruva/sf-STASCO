public with sharing class RE_GainLossClass { 

    @AuraEnabled (cacheable = false)
    public static list<RE_Product__c> fetchMC0Data(){
        return ([
            SELECT Id,RE_Midday_MC0_Valid_From__c,RE_Midday_MC0_Valid_To__c,RE_Midday_MC0_Value__c,
            RE_Morning_MC0_Valid_From__c,RE_Morning_MC0_Valid_To__c,RE_Morning_MC0_Value__c
            FROM RE_Product__c
            WHERE Name = 'IGO 10ppm'
        ]);
    }
    
    @AuraEnabled
    public static void updateRecords(List<RE_Product__c> mc0List){   
        System.debug('mc0List'+mc0List);
        try {
           update mc0List;
        } catch (Exception e) {
            
        }
    }
        
}