public class RE_Depot_Based_Costing_TriggerHelper {  
    public static void onAfterAMVDepoCostOutput(List<RE_Depot_Based_Costing__c> amvNewList, Map<Id,RE_Depot_Based_Costing__c> amvNewMap){
        Id recordType= Schema.SObjectType.RE_Depot_Based_Costing__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        Map<String,RE_Depot_Based_Costing__c> amvMap = new Map<String,RE_Depot_Based_Costing__c>();
        for(RE_Depot_Based_Costing__c myAMVdata : [
            SELECT RE_Depot__c,Product__c,RE_IsLatest__c,CreatedDate,RE_BSP__c,RE_Comments__c,RE_Weighted_CO_Val__c
            FROM RE_Depot_Based_Costing__c
            WHERE Id IN : amvNewMap.keySet() AND recordtypeId =:recordType])
        {
            if(myAMVdata.RE_IsLatest__c == True && (myAMVdata.CreatedDate).Date() == System.today() && myAMVdata.RE_Depot__c != null
                    && myAMVdata.Product__c != null)
                amvMap.put(myAMVdata.RE_Depot__c+'_'+myAMVdata.Product__c,myAMVdata);
        }
 
        if(!amvMap.isEmpty())
        {
            // Creating Map for storing unique values
            List<RE_MOA__c> moaOldList = new List<RE_MOA__c>();
            Id recordTypeMYMOA= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
            // looping through RE_MOA__c records to create a map with product-depot combination as key
            for(RE_MOA__c moaValue: [
                SELECT Id,RE_Depot_Name__r.Name, RE_Product__r.Name,RE_Today_s_BSP__c,RE_Remark__c,RE_Final_CO_Value__c
                FROM RE_MOA__c WHERE RE_IsLatest__c = True AND recordtypeId =: recordTypeMYMOA])
            {
                String key = moaValue.RE_Depot_Name__r.Name+'_'+moaValue.RE_Product__r.Name;
                if(amvMap.containsKey(key)){
                    if(amvMap.get(key).RE_Comments__c != null && amvMap.get(key).RE_Comments__c != '')
                        moaValue.RE_Remark__c       = amvMap.get(key).RE_Comments__c;
                    if(amvMap.get(key).RE_Weighted_CO_Val__c != null)
                        moaValue.RE_Final_CO_Value__c   = amvMap.get(key).RE_Weighted_CO_Val__c;
                    moaValue.RE_Today_s_BSP__c      = amvMap.get(key).RE_BSP__c;
                }
                else{
                    moaValue.RE_Today_s_BSP__c      = null;
                }
                moaOldList.add(moaValue);
            }
            if(!moaOldList.isEmpty())
            {
                try{
                    update moaOldList;
                }
                catch(Exception ex){
                    System.debug('Error on updating BSP value in MOA object');
                }
            }
        }
    }
    
    public static void onAfterTHAMVDepoCostOutput(List<RE_Depot_Based_Costing__c> amvNewList, Map<Id,RE_Depot_Based_Costing__c> amvNewMap){
        Map<String,RE_Depot_Based_Costing__c> amvMap = new Map<String,RE_Depot_Based_Costing__c>();
        Id recordType= Schema.SObjectType.RE_Depot_Based_Costing__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
        for(RE_Depot_Based_Costing__c myAMVdata : [
            SELECT RE_Depot__c,Product__c,RE_IsLatest__c,CreatedDate,RE_BSP__c,RE_Comments__c,RE_Weighted_CO_Val__c
            FROM RE_Depot_Based_Costing__c
            WHERE Id IN : amvNewMap.keySet() AND recordtypeId =:recordType ])
        {
            if(myAMVdata.RE_IsLatest__c == True && (myAMVdata.CreatedDate).Date() == System.today() && myAMVdata.RE_Depot__c != null
               && myAMVdata.Product__c != null)
                amvMap.put(myAMVdata.RE_Depot__c+'_'+myAMVdata.Product__c,myAMVdata);
        }
        
        if(!amvMap.isEmpty()){
            // Creating Map for storing unique values
            List<RE_MOA__c> moaOldList = new List<RE_MOA__c>();
            Id recordTypeTHMOA= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
            // looping through RE_MOA__c records to create a map with product-depot combination as key
            for(RE_MOA__c moaValue: [
                SELECT Id,RE_Depot_Name__r.Name, RE_Product__r.Name,RE_Today_s_BSP__c,RE_Remark__c,RE_Final_CO_Value__c
                FROM RE_MOA__c WHERE RE_IsLatest__c = True AND recordtypeId =: recordTypeTHMOA])
            {
                String key = moaValue.RE_Depot_Name__r.Name+'_'+moaValue.RE_Product__r.Name;
                if(amvMap.containsKey(key)){
                    if(amvMap.get(key).RE_Comments__c != null && amvMap.get(key).RE_Comments__c != '')
                        moaValue.RE_Remark__c       = amvMap.get(key).RE_Comments__c;
                    if(amvMap.get(key).RE_Weighted_CO_Val__c != null)
                    	moaValue.RE_Final_CO_Value__c   = amvMap.get(key).RE_Weighted_CO_Val__c;
                    moaValue.RE_Today_s_BSP__c      = amvMap.get(key).RE_BSP__c;
                }
                else{
                    moaValue.RE_Today_s_BSP__c      = null;
                }
                moaOldList.add(moaValue);
            }
            if(!moaOldList.isEmpty())
            {
                try{
                    update moaOldList;
                }
                catch(Exception ex){
                    System.debug('Error on updating BSP value in MOA object');
                }
            }
        }
    }
}