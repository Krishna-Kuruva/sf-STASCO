public class RE_TH_CostPriceTriggerHelper { 
    public static void onAfterMorningTHCBUHelper(List<RE_MY_CostPrice__c> MYmorningCBU,Map<Id,RE_MY_CostPrice__c> MYMorningCBUnew){
        Map<String,RE_MY_CostPrice__c> morningCBUMap = new Map<String,RE_MY_CostPrice__c>();
        Id recordType= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
        system.debug('inside TH MOA');
        for(RE_MY_CostPrice__c myCBU : [SELECT RE_Depot_Name__r.Name,RE_Product_Name__r.Name,RE_IsLatest__c,RE_Costprice_Marginal_Cost__c,
                                        CreatedDate,RE_Country__c,RE_Depot_Name__c,RE_Product_Name__c,RE_Costprice_Laid_Down_Cost__c,RE_Depot_Name__r.RE_Region_Name__c
                                        FROM RE_MY_CostPrice__c
                                        WHERE Id IN : MYMorningCBUnew.keySet() AND recordtypeId=:recordType ])
        {
            //eligibility check for records
            if(myCBU.RE_IsLatest__c== True && (myCBU.CreatedDate).Date()== System.today() && myCBU.RE_Depot_Name__c!=null 
               && myCBU.RE_Product_Name__c!=null && myCBU.RE_Costprice_Laid_Down_Cost__c!=null)            
                morningCBUMap.put(myCBU.RE_Depot_Name__r.Name+'_'+myCBU.RE_Product_Name__r.Name,myCBU);                            
        }
        system.debug('--MOA map--'+morningCBUMap);
        if(!morningCBUMap.isEmpty()) //if map is not empty 
        {
            // Creating Map for storing unique values for RE_MOA__c,RE_Depot_Pricing_Backbone__c
            List<RE_MOA__c> moaOldList = new List<RE_MOA__c>();
            Map<String,RE_MOA__c> moaMap = new Map<String,RE_MOA__c>(); 
            Map<String,RE_Depot_Pricing_Backbone__c> dpbMap = new Map<String,RE_Depot_Pricing_Backbone__c>();
            Id recordTypeTHMOA= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId() ;
            
            for(RE_MOA__c moaValue: [SELECT RE_Depot_Name__r.Name, RE_Product__r.Name,RE_Target_Margin__c,RE_Spot_Price_Adj__c,RE_MC_Morning__c,RE_LDC_Morning__c,RE_Prev_Mid_Day_price_out__c From RE_MOA__c WHERE recordtypeId=:recordTypeTHMOA AND RE_IsLatest__c = True AND CreatedDate = Today])
            {
                moaMap.put(moaValue.RE_Depot_Name__r.Name+'_'+moaValue.RE_Product__r.Name,moaValue);
            }
            
            // looping through old RE_MOA__c records to create a map with product-depot combination as key for removing RE_IsLatest__c for old data 
            for(RE_MOA__c moaOldValue: [SELECT RE_IsLatest__c From RE_MOA__c WHERE recordtypeId=:recordTypeTHMOA AND RE_IsLatest__c = True AND CreatedDate != Today])
            {
                moaOldValue.RE_IsLatest__c = False;
                moaOldList.add(moaOldValue);
            }
            
            // looping through RE_Depot_Pricing_Backbone__c records to create a map with product-depot combination as key sice we need spot price adj
            for(RE_Depot_Pricing_Backbone__c dpbData : [SELECT RE_Product_Name__r.Name,RE_Depot_Name__r.Name,RE_Spot_Price_Adjustment__c,RE_Target_Margin__c
                                                        FROM RE_Depot_Pricing_Backbone__c 
                                                        WHERE RE_Valid_From__c <= Today 
                                                        AND RE_Valid_To__c >= Today  
                                                        AND RE_Country__r.Name = 'Thailand'] )
            {
                dpbMap.put(dpbData.RE_Depot_Name__r.Name+'_'+dpbData.RE_Product_Name__r.Name,dpbData);
            }
            
            // creating a list to store all the records that need to be updated/inserted
            List<RE_MOA__c> moaUpsertList = new List<RE_MOA__c>(); 
            
            //looping through all the RE_MY_CostPrice__c data
            for(RE_MY_CostPrice__c morningCBU :morningCBUMap.values()) 
            { 
                String key = morningCBU.RE_Depot_Name__r.Name+'_'+morningCBU.RE_Product_Name__r.Name;
                if(moaMap.containsKey(key)) //updation (if recalculation is done changing some value on the same day)
                {
                    if(morningCBUMap.containsKey(key)){
                        // moaMap.get(key).RE_MC_Morning__c            = morningCBUMap.get(key).RE_Costprice_Marginal_Cost__c;
                        moaMap.get(key).RE_LDC_Morning__c            = morningCBUMap.get(key).RE_Costprice_Laid_Down_Cost__c;
                    }                                              
                    if(dpbMap.containsKey(key)){
                        moaMap.get(key).RE_Spot_Price_Adj__c        = dpbMap.get(key).RE_Spot_Price_Adjustment__c; 
                        moaMap.get(key).RE_Target_Margin__c         = dpbMap.get(key).RE_Target_Margin__c;
                    }
                    else
                    {
                        moaMap.get(key).RE_Spot_Price_Adj__c        = null;  
                        moaMap.get(key).RE_Target_Margin__c         = null;
                    }                  
                } 
                else //insertion of new data
                {
                    RE_MOA__c newRecordInsert = new RE_MOA__c();
                    newRecordInsert.RecordTypeId=recordTypeTHMOA;
                    newRecordInsert.RE_Depot_Name__c             = morningCBU.RE_Depot_Name__c;  
                    newRecordInsert.RE_Product__c                = morningCBU.RE_Product_Name__c;
                    newRecordInsert.RE_Country__c                = morningCBU.RE_Country__c;
                    newRecordInsert.RE_LDC_Morning__c		 	 = morningCBU.RE_Costprice_Laid_Down_Cost__c;
                    newRecordInsert.RE_IsLatest__c               = True;     
                    if(dpbMap.containsKey(key)){
                        newRecordInsert.RE_Target_Margin__c			= dpbMap.get(key).RE_Target_Margin__c;  
                        newRecordInsert.RE_Spot_Price_Adj__c   		= dpbMap.get(key).RE_Spot_Price_Adjustment__c;                            
                    }
                    moaMap.put(key,newRecordInsert);
                }
            }
            
            System.debug('moaMap  to update'+moaMap);
            try{
                if(!moaMap.isEmpty()) //only if our final map is not empty
                {
                    if(!moaOldList.isEmpty()) 
                        update moaOldList; //old data having is_latest=false have to be updated
                    upsert moaMap.values(); 
                }
            }
            catch(Exception ex)
            {
                System.debug('Error on inserting record in RE_MOA__c');
            } 
        }
    }
}