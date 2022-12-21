public class RE_MY_CostPrice_TriggerHelper {    
    //Check coutry specific data
    public static Boolean checkCountry(List<RE_MY_CostPrice__c> costpriceList ){
        Boolean isEastData = false;
        Id recordTypemy = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        Id recordTypeph = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
        for(RE_MY_CostPrice__c costdata : costpriceList ){
            if(costdata.recordtypeId == recordTypemy || costdata.recordtypeId == recordTypeph){
                isEastData = true;
            }
        }
        return isEastData;    
    }
    public static void onAfterMorningCBUHelper(List<RE_MY_CostPrice__c> MYmorningCBU,Map<Id,RE_MY_CostPrice__c> MYMorningCBUnew){
        Map<String,RE_MY_CostPrice__c> morningCBUMap = new Map<String,RE_MY_CostPrice__c>();
        Id recordType= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        //fetching the data from RE_MY_CostPrice__c since trigger.new was unable to fetch lookup field's data
        for(RE_MY_CostPrice__c myCBU : [SELECT RE_Depot_Name__r.Name,RE_Product_Name__r.Name,RE_IsLatest__c,RE_Costprice_Marginal_Cost__c,
                                        CreatedDate,RE_Country__c,RE_Depot_Name__c,RE_Product_Name__c,RE_Costprice_Laid_Down_Cost__c,RE_Depot_Name__r.RE_Region_Name__c
                                        FROM RE_MY_CostPrice__c
                                        WHERE Id IN : MYMorningCBUnew.keySet() AND recordtypeId=:recordType ])
        {
            //eligibility check for records
            if(myCBU.RE_IsLatest__c== True && (myCBU.CreatedDate).Date()== System.today() && myCBU.RE_Depot_Name__c!=null 
               && myCBU.RE_Product_Name__c!=null && myCBU.RE_Costprice_Marginal_Cost__c!=null)            
                morningCBUMap.put(myCBU.RE_Depot_Name__r.Name+'_'+myCBU.RE_Product_Name__r.Name,myCBU);                            
        }
        if(!morningCBUMap.isEmpty()) //if map is not empty 
        {    
            // Creating Map for storing unique values for RE_MOA__c,RE_Depot_Pricing_Backbone__c,RE_Midday_Pricing__c object
            List<RE_MOA__c> moaOldList = new List<RE_MOA__c>();
            Map<String,RE_MOA__c> moaMap = new Map<String,RE_MOA__c>(); 
            Map<String,RE_Depot_Pricing_Backbone__c> dpbMap = new Map<String,RE_Depot_Pricing_Backbone__c>();
            Map<String,RE_Midday_Pricing__c> middayMap = new Map<String,RE_Midday_Pricing__c>();
            Map<String,RE_Midday_Pricing__c> U97midDayPricingMap = new Map<String,RE_Midday_Pricing__c>();
            Id recordTypeMYMOA= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
            Boolean IsCBUGenerated = False;
            // looping through RE_MOA__c records to create a map with product-depot combination as key
            for(RE_MOA__c moaValue: [SELECT RE_Depot_Name__r.Name, RE_Product__r.Name,RE_Target_Margin__c,RE_Spot_Price_Adj__c,RE_MC_Morning__c,RE_LDC_Morning__c,RE_Prev_Mid_Day_price_out__c From RE_MOA__c WHERE RE_IsLatest__c = True AND CreatedDate = Today AND recordtypeId=:recordTypeMYMOA])
            {
                IsCBUGenerated = True;
                moaMap.put(moaValue.RE_Depot_Name__r.Name+'_'+moaValue.RE_Product__r.Name,moaValue);
                //System.debug('@@moaMap'+moaMap);
            }
            // looping through old RE_MOA__c records to create a map with product-depot combination as key for removing RE_IsLatest__c for old data 
            for(RE_MOA__c moaOldValue: [SELECT RE_IsLatest__c From RE_MOA__c WHERE RE_IsLatest__c = True AND CreatedDate != Today AND recordtypeId=:recordTypeMYMOA])
            {
                moaOldValue.RE_IsLatest__c = False;
                moaOldList.add(moaOldValue);
            }
            // looping through RE_Depot_Pricing_Backbone__c records to create a map with product-depot combination as key sice we need spot price adj
            for(RE_Depot_Pricing_Backbone__c dpbData : [SELECT RE_Product_Name__r.Name,RE_Depot_Name__r.Name,RE_Spot_Price_Adjustment__c,RE_Target_Margin__c
                                                        FROM RE_Depot_Pricing_Backbone__c 
                                                        WHERE RE_Valid_From__c <= Today 
                                                        AND RE_Valid_To__c >= Today  
                                                        AND RE_Country__r.Name = 'Malaysia'] )
            {
                dpbMap.put(dpbData.RE_Depot_Name__r.Name+'_'+dpbData.RE_Product_Name__r.Name,dpbData);
                //System.debug('@@dpb'+dpbMap);
            }
            
            // looping through RE_Midday_Pricing__c last 7 days records to create a map with product-depot combination as key since we need RE_Shell_Price__c
            for(RE_Midday_Pricing__c middayValue: [SELECT RE_Depot_Name__r.Name, RE_Product_Name__r.Name,RE_Shell_Price__c,CreatedDate 
                                                   From RE_Midday_Pricing__c 
                                                   WHERE RE_Depot_Name__r.Name !=null AND RE_IsLatest__c = True AND CreatedDate = LAST_N_DAYS : 7 ORDER BY CREATEDDATE DESC])
            {
                if(midDayvalue.RE_Product_Name__r.Name == 'MOGAS 97')
                    U97midDayPricingMap.put(midDayvalue.RE_Product_Name__r.Name,midDayvalue);
                if(!middayMap.containsKey(middayValue.RE_Depot_Name__r.Name+'_'+middayValue.RE_Product_Name__r.Name)) //only when the map is empty insert record else not(for storing latest previous day data)
                    middayMap.put(middayValue.RE_Depot_Name__r.Name+'_'+middayValue.RE_Product_Name__r.Name,middayValue);       
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
                        moaMap.get(key).RE_MC_Morning__c            = morningCBUMap.get(key).RE_Costprice_Marginal_Cost__c;
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
                    if(morningCBU.RE_Product_Name__r.Name == 'MOGAS 97'  && morningCBU.RE_Depot_Name__r.RE_Region_Name__c == 'Peninsular' && U97midDayPricingMap.containsKey(morningCBU.RE_Product_Name__r.Name))
                        moaMap.get(key).RE_Prev_Mid_Day_price_out__c = U97midDayPricingMap.get(morningCBU.RE_Product_Name__r.Name).RE_Shell_Price__c;
                    if(middayMap.containsKey(key))
                        moaMap.get(key).RE_Prev_Mid_Day_price_out__c= middayMap.get(key).RE_Shell_Price__c;                    
                } 
                else //insertion of new data
                {
                    RE_MOA__c newRecordInsert = new RE_MOA__c();
                     newRecordInsert.RecordTypeId=recordTypeMYMOA;
                    newRecordInsert.RE_Depot_Name__c             = morningCBU.RE_Depot_Name__c;  
                    newRecordInsert.RE_Product__c                = morningCBU.RE_Product_Name__c;
                    newRecordInsert.RE_Country__c                = morningCBU.RE_Country__c;
                    newRecordInsert.RE_MC_Morning__c             = morningCBU.RE_Costprice_Marginal_Cost__c;
                    newRecordInsert.RE_LDC_Morning__c            = morningCBU.RE_Costprice_Laid_Down_Cost__c;
                    newRecordInsert.RE_IsLatest__c               = True;     
                    if(dpbMap.containsKey(key)){
                        newRecordInsert.RE_Target_Margin__c         = dpbMap.get(key).RE_Target_Margin__c;  
                        newRecordInsert.RE_Spot_Price_Adj__c        = dpbMap.get(key).RE_Spot_Price_Adjustment__c;                            
                    }
                    if(morningCBU.RE_Product_Name__r.Name == 'MOGAS 97' && morningCBU.RE_Depot_Name__r.RE_Region_Name__c == 'Peninsular' && U97midDayPricingMap.containsKey(morningCBU.RE_Product_Name__r.Name))
                        newRecordInsert.RE_Prev_Mid_Day_price_out__c = U97midDayPricingMap.get(morningCBU.RE_Product_Name__r.Name).RE_Shell_Price__c;
                    if(middayMap.containsKey(key))//only if the map has data(mandatory step)
                        newRecordInsert.RE_Prev_Mid_Day_price_out__c = middayMap.get(key).RE_Shell_Price__c;   
                    moaMap.put(key,newRecordInsert);
                }
            } 
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
            //Updating price book data with the Marginal cost to Customer Opps Records
            //Check holiday or Sunday / Monday (There is no CBU on Sunday, Monday and day after public holiday)
            List<String> holidaysDate= new List<String>();
            for(RE_Holiday_Calendar__c nextholidays :[SELECT Name ,Id, RE_Holiday_Date__c  FROM RE_Holiday_Calendar__c  where (RE_Holiday_Date__c =NEXT_WEEK OR RE_Holiday_Date__c =THIS_WEEK) AND Recordtype.Name = 'MY Holiday Calendar' ])
                holidaysDate.add(string.valueof((Datetime)nextholidays.RE_Holiday_Date__c));
            Datetime currentDay = (DateTime)System.today();
            Datetime D_1 = currentDay.adddays(-1);
            String dayOfWeek = currentDay.format('EEEE');
            boolean checkNotHoliday = true;
            if( dayOfWeek == 'Monday' || dayOfWeek == 'Sunday' || holidaysDate.contains(string.valueof(D_1)))
               checkNotHoliday = false;
            
            if(!IsCBUGenerated && checkNotHoliday)
                System.enqueueJob(new RE_updateCBUcustomerOpps());
                    
        }
    }
    
    public static void onAfterMorningCBUHelperPH(List<RE_MY_CostPrice__c> MYmorningCBU,Map<Id,RE_MY_CostPrice__c> MYMorningCBUnew){
        Map<String,RE_MY_CostPrice__c> costpriceMap = new Map<String,RE_MY_CostPrice__c>();
        Id recordType= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
        String datatype = MYmorningCBU[0].RE_Type__c;
        for(RE_MY_CostPrice__c costpriceValue : [
            SELECT RE_Depot_Name__c,RE_Product_Name__c,RE_Hydrocarbon_Value__c,RE_Bio_Cost__c,RE_Job_Run_Count__c,RE_Costprice_Laid_Down_Cost__c,
            RE_PH_PT_Cost__c,RE_PH_Small_LOT__c,RE_PH_Freight_Shifting_Cost__c,RE_PH_Demurrage__c,RE_Country__c,RE_Data__c,RE_Effective_Date__c,
            RE_PH_FLC_Service_Fee__c,RE_PH_MISC_Brokerage_Fee__c,RE_PH_MISC_Hosehandling_Cost__c,RE_Product_Name__r.Name,RE_Recovery_Sales_Tax__c,RE_Market_Premium__c,
            RE_PH_MISC_Port_Charges__c,RE_PH_MISC_PQ_Cost__c, RE_PH_MISC_Shifting_Cost__c,RE_Type__c,RE_Costprice_Unit__c,RE_Additive_Cost__c,RE_Freight_Pipeline_Charges__c,
            RE_PH_MISC_Waterfront_Operations_Cost__c,RE_PH_Terminal_Cost__c,RE_PH_Wharfage_Cost__c,RE_Depot_Name__r.Name,RE_Storage_Handling_Cost__c,
            RE_PH_MISC_Fuel_Marking_Fee__c,RE_Blend_Percent__c FROM RE_MY_CostPrice__c
            WHERE RE_IsLatest__c = True AND RE_PH_Is_Blend__c = True AND RE_PH_Is_Today__c = True  AND recordtypeId=:recordType AND CREATEDDATE= Today AND RE_Type__c =:datatype
        ]){
            datatype = costpriceValue.RE_Type__c;
            //if Blend% != 100
            String key = costpriceValue.RE_Depot_Name__c != null ? (costpriceValue.RE_Depot_Name__r.Name+'_'+costpriceValue.RE_Product_Name__r.Name) :  costpriceValue.RE_Product_Name__r.Name;
            if(costpriceMap.containskey(key))
            {   
                //Hydrocarbon Value
                costpriceMap.get(key).RE_Hydrocarbon_Value__c = 
                    costpriceMap.get(key).RE_Hydrocarbon_Value__c + costpriceValue.RE_Hydrocarbon_Value__c * costpriceValue.RE_Blend_Percent__c / 100;
                //Bio Cost                            
                costpriceMap.get(key).RE_Bio_Cost__c = 
                    costpriceMap.get(key).RE_Bio_Cost__c + costpriceValue.RE_Bio_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
                //Small Lot Cost
                costpriceMap.get(key).RE_PH_Small_LOT__c = 
                    costpriceMap.get(key).RE_PH_Small_LOT__c + costpriceValue.RE_PH_Small_LOT__c * costpriceValue.RE_Blend_Percent__c / 100;
                
                //Demmurage Cost
                costpriceMap.get(key).RE_PH_Demurrage__c = 
                    costpriceMap.get(key).RE_PH_Demurrage__c + costpriceValue.RE_PH_Demurrage__c * costpriceValue.RE_Blend_Percent__c / 100;
                // FLC Service Fee
                costpriceMap.get(key).RE_PH_FLC_Service_Fee__c = 
                    costpriceMap.get(key).RE_PH_FLC_Service_Fee__c + costpriceValue.RE_PH_FLC_Service_Fee__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Brokerage Fee
                costpriceMap.get(key).RE_PH_MISC_Brokerage_Fee__c = 
                    costpriceMap.get(key).RE_PH_MISC_Brokerage_Fee__c + costpriceValue.RE_PH_MISC_Brokerage_Fee__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Hosehandling Cost
                costpriceMap.get(key).RE_PH_MISC_Hosehandling_Cost__c = 
                    costpriceMap.get(key).RE_PH_MISC_Hosehandling_Cost__c + costpriceValue.RE_PH_MISC_Hosehandling_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Port Charges
                costpriceMap.get(key).RE_PH_MISC_Port_Charges__c = 
                    costpriceMap.get(key).RE_PH_MISC_Port_Charges__c + costpriceValue.RE_PH_MISC_Port_Charges__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC PQ Cost
                costpriceMap.get(key).RE_PH_MISC_PQ_Cost__c = 
                    costpriceMap.get(key).RE_PH_MISC_PQ_Cost__c + costpriceValue.RE_PH_MISC_PQ_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Shifting Cost
                costpriceMap.get(key).RE_PH_MISC_Shifting_Cost__c =
                    costpriceMap.get(key).RE_PH_MISC_Shifting_Cost__c + costpriceValue.RE_PH_MISC_Shifting_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Waterfront Operations Cost
                costpriceMap.get(key).RE_PH_MISC_Waterfront_Operations_Cost__c =
                    costpriceMap.get(key).RE_PH_MISC_Waterfront_Operations_Cost__c + costpriceValue.RE_PH_MISC_Waterfront_Operations_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Terminal Cost
                costpriceMap.get(key).RE_PH_Terminal_Cost__c = 
                    costpriceMap.get(key).RE_PH_Terminal_Cost__c+ costpriceValue.RE_PH_Terminal_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Wharfage Cost
                costpriceMap.get(key).RE_PH_Wharfage_Cost__c = 
                    costpriceMap.get(key).RE_PH_Wharfage_Cost__c+ costpriceValue.RE_PH_Wharfage_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
                //MISC Fuel Marking Fee
                costpriceMap.get(key).RE_PH_MISC_Fuel_Marking_Fee__c = 
                    costpriceMap.get(key).RE_PH_MISC_Fuel_Marking_Fee__c+ costpriceValue.RE_PH_MISC_Fuel_Marking_Fee__c * costpriceValue.RE_Blend_Percent__c / 100;
                //Sales Tax
                costpriceMap.get(key).RE_Recovery_Sales_Tax__c = 
                    costpriceMap.get(key).RE_Recovery_Sales_Tax__c+ costpriceValue.RE_Recovery_Sales_Tax__c * costpriceValue.RE_Blend_Percent__c / 100;    
                costpriceMap.get(key).RE_Market_Premium__c = 
                    costpriceMap.get(key).RE_Market_Premium__c + costpriceValue.RE_Market_Premium__c * costpriceValue.RE_Blend_Percent__c / 100;
                costpriceMap.get(key).RE_Freight_Pipeline_Charges__c = 
                    costpriceMap.get(key).RE_Freight_Pipeline_Charges__c + costpriceValue.RE_Freight_Pipeline_Charges__c * costpriceValue.RE_Blend_Percent__c / 100;
                //Laid Down Cost
                costpriceMap.get(key).RE_Costprice_Laid_Down_Cost__c = 
                    costpriceMap.get(key).RE_Costprice_Laid_Down_Cost__c + costpriceValue.RE_Costprice_Laid_Down_Cost__c * costpriceValue.RE_Blend_Percent__c / 100;
            }
            else
            {
                //Calculating the weighted avg 
                RE_MY_CostPrice__c weightavgCalc = weightedavg(costpriceValue);
                costpriceMap.put(key,weightavgCalc);                    
            }     
        }
        //inserting the weighted values
        if(!costpriceMap.isEmpty())
        {
            try{
                insert costpriceMap.values();               
            }
            catch(Exception ex){
                System.debug(ex.getCause());
            }
        }     
        
    }
    //Logic after blended product's cost data insertion. Mrginal and Laiddown cost update and parent cosstprice id population.
    public Static void onAfterBlendedCostDataInsert(List<RE_MY_CostPrice__c> MYmorningCBU,Map<Id,RE_MY_CostPrice__c> MorningCBUBlended){
        RE_unitConversion conv = new RE_unitConversion();
        Map<String,Double> curConvMap = new Map<String,Double>();
        Id recordType= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId();
        Map<String , RE_MY_CostPrice__c> newcostpricedataMap = new Map<String , RE_MY_CostPrice__c>();
        List<RE_MY_CostPrice__c> updateCostList = new List<RE_MY_CostPrice__c>();
        String keydata;
        String datatype;
        String type = MYmorningCBU[0].RE_Type__c;
        for(RE_MY_CostPrice__c costdata: [
            SELECT Id, RE_Depot_Name__c, RE_Depot_Name__r.Name, RE_Product_Name__c, RE_Product_Name__r.Name,RE_Type__c,RE_Costprice_Laid_Down_Cost__c,RE_Costprice_Unit__c,
            RE_Costprice_Marginal_Cost__c,RE_PH_PT_Cost__c,RE_Additive_Cost__c,RE_Storage_Handling_Cost__c,RE_Product_Name__r.RE_Product_Group__c,RE_Country__r.Name,RE_Product_Name__r.RE_PH_Percent_Base_Fuel__c
            FROM RE_MY_CostPrice__c WHERE RE_PH_Is_Today__c = True AND recordtypeId=:recordType and RE_PH_Is_Blend__c = False AND RE_IsLatest__c = True AND CREATEDDATE= Today AND RE_Type__c =:type
        ]){
            if(MorningCBUBlended.keySet().contains(costdata.Id)){
                datatype = costdata.RE_Type__c;    
                keydata = costdata.RE_Depot_Name__c != null ? (costdata.RE_Depot_Name__r.Name+'_'+costdata.RE_Product_Name__r.Name) :  costdata.RE_Product_Name__r.Name;
                newcostpricedataMap.put(keydata,costdata);
            }
            if(costdata.RE_Costprice_Marginal_Cost__c == null){
                costdata.RE_Costprice_Marginal_Cost__c = costdata.RE_Costprice_Laid_Down_Cost__c + (costdata.RE_PH_PT_Cost__c != null ? costdata.RE_PH_PT_Cost__c : 0) + 
                    (costdata.RE_Storage_Handling_Cost__c != null ? costdata.RE_Storage_Handling_Cost__c : 0);
                updateCostList.add(costdata);
            }            
        }
        //updating the parent id in child record
        for(RE_MY_CostPrice__c childrecord : [Select Id, RE_Depot_Name__r.Name, RE_Depot_Name__c,RE_Product_Name__r.Name,RE_PH_Is_Today__c,RE_Type__c,RE_PH_Parent_Cost_price__c
            FROM RE_MY_CostPrice__c WHERE RE_IsLatest__c = True AND RE_PH_Is_Blend__c = True AND RE_PH_Is_Today__c = True AND recordtypeId=:recordType AND RE_Type__c =:type and createddate = today])
        {
            
            String childkey = childrecord.RE_Depot_Name__c != null ? (childrecord.RE_Depot_Name__r.Name+'_'+childrecord.RE_Product_Name__r.Name) :  childrecord.RE_Product_Name__r.Name;
            if(newcostpricedataMap.containsKey(childkey)){
                childrecord.RE_Type__c = '';
                childrecord.RE_PH_Is_Today__c = False;
                childrecord.RE_PH_Parent_Cost_price__c = newcostpricedataMap.get(childkey).Id;
                updateCostList.add(childrecord);
            }
        }
        if(!updateCostList.isEmpty()){
            try{
                run = True;
                update updateCostList;}
            catch(Exception ex){System.debug(ex.getCause());}
        }
    }
    
    //Calculate weighted average for blended products
    public Static RE_MY_CostPrice__c  weightedavg(RE_MY_CostPrice__c costpriceValue){
        RE_MY_CostPrice__c updatedCost = new RE_MY_CostPrice__c();
        updatedCost.RE_Type__c = costpriceValue.RE_Type__c;
        updatedCost.recordtypeId=Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Philippines').getRecordTypeId() ;
        updatedCost.RE_Job_Run_Count__c = costpriceValue.RE_Job_Run_Count__c;
        updatedCost.RE_PH_Is_Today__c = True;
        updatedCost.RE_IsLatest__c = True;
        updatedCost.RE_Country__c = costpriceValue.RE_Country__c;
        updatedCost.RE_Depot_Name__c = costpriceValue.RE_Depot_Name__c;
        updatedCost.RE_Product_Name__c = costpriceValue.RE_Product_Name__c;
        updatedCost.RE_Costprice_Unit__c = costpriceValue.RE_Costprice_Unit__c;
        updatedCost.RE_Pricing_Date__c = System.today();
        updatedCost.RE_PH_Is_Blend__c = False; 
        updatedCost.RE_Hydrocarbon_Value__c =  (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_Hydrocarbon_Value__c / 100);
        updatedCost.RE_Bio_Cost__c          = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_Bio_Cost__c / 100);
        updatedCost.RE_PH_PT_Cost__c        = costpriceValue.RE_PH_PT_Cost__c;
        updatedCost.RE_PH_Small_LOT__c      = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_Small_LOT__c / 100);
        updatedCost.RE_PH_Demurrage__c            =  (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_Demurrage__c / 100);        
        updatedCost.RE_PH_FLC_Service_Fee__c      = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_FLC_Service_Fee__c / 100);        
        updatedCost.RE_PH_MISC_Brokerage_Fee__c   = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_MISC_Brokerage_Fee__c / 100);        
        updatedCost.RE_PH_MISC_Hosehandling_Cost__c =(costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_MISC_Hosehandling_Cost__c / 100);        
        updatedCost.RE_PH_MISC_Port_Charges__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_MISC_Port_Charges__c / 100);        
        updatedCost.RE_PH_MISC_PQ_Cost__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_MISC_PQ_Cost__c / 100);        
        updatedCost.RE_PH_MISC_Shifting_Cost__c =  (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_MISC_Shifting_Cost__c / 100);        
        updatedCost.RE_PH_MISC_Waterfront_Operations_Cost__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_MISC_Waterfront_Operations_Cost__c / 100);        
        updatedCost.RE_PH_Terminal_Cost__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_Terminal_Cost__c / 100);        
        updatedCost.RE_PH_Wharfage_Cost__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_Wharfage_Cost__c / 100);        
        updatedCost.RE_PH_MISC_Fuel_Marking_Fee__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_PH_MISC_Fuel_Marking_Fee__c / 100);  
        updatedCost.RE_Recovery_Sales_Tax__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_Recovery_Sales_Tax__c / 100);  
        updatedCost.RE_Costprice_Laid_Down_Cost__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_Costprice_Laid_Down_Cost__c / 100);
        updatedCost.RE_Additive_Cost__c = costpriceValue.RE_Additive_Cost__c;
        updatedCost.RE_Storage_Handling_Cost__c = costpriceValue.RE_Storage_Handling_Cost__c;
        updatedCost.RE_Freight_Pipeline_Charges__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_Freight_Pipeline_Charges__c / 100);
        updatedCost.RE_Market_Premium__c = (costpriceValue.RE_Blend_Percent__c * costpriceValue.RE_Market_Premium__c / 100);
        updatedCost.RE_Data__c = costpriceValue.RE_Data__c;
        updatedCost.RE_Effective_Date__c = costpriceValue.RE_Effective_Date__c;
        return updatedCost;
    }
    
    public Static Boolean costDataTracker(String datatype, Id rectypeId){               
        Map<String, RE_MY_CostPrice__c> latestcostList = new Map<String, RE_MY_CostPrice__c>();
        Map<String, RE_MY_CostPrice__c> oldcostList = new Map<String, RE_MY_CostPrice__c>();
       
        List<RE_MY_CostPrice__c> prevcostList = new List<RE_MY_CostPrice__c>();
        List<RE_MY_CostPrice__c> finalcostList = new List<RE_MY_CostPrice__c>();
        String keydata;
        String depokey;
        Map<String,RE_Depot_Pricing_Backbone__c> depoMap  = new Map<String,RE_Depot_Pricing_Backbone__c>();
        for(RE_Depot_Pricing_Backbone__c depodata: [
            SELECT Id,RE_Country__c,RE_Country__r.Name,RE_Depot_Name__c,RE_Product_Name__c
            FROM RE_Depot_Pricing_Backbone__c
            WHERE RE_Valid_From__c <= Today AND RE_Valid_To__c >= Today
            AND RecordType.Name='Philippines'
        ]){
            depoMap.put(depodata.RE_Depot_Name__c+'_'+depodata.RE_Product_Name__c,depodata);
        }
        List<String> datatypeList = new List<String>();
        if(datatype == 'D-1'){
            datatypeList.add('D-1');
            datatypeList.add('D-2');
        }            
        if(datatype == 'W-1'){
            datatypeList.add('W-1');
            datatypeList.add('W-2');
        }
        if(datatype == 'M-1'){
            datatypeList.add('M-1');
            datatypeList.add('M-2');
        }
        
        for(RE_MY_CostPrice__c costData : [
            SELECT RE_Type__c,RE_IsLatest__c,RE_PH_Is_Today__c, RE_Depot_Name__r.Name,RE_Product_Name__r.Name,Createddate ,RE_Pricing_Date__c
            FROM RE_MY_CostPrice__c 
            WHERE recordtypeId = : rectypeId AND RE_IsLatest__c = True  AND RE_PH_Is_Blend__c = False AND RE_Type__c IN: datatypeList AND RE_Country__r.Name = 'Philippines'
            ORDER BY RE_Pricing_Date__c DESC
        ]){
            depokey = costdata.RE_Depot_Name__c != null ? costdata.RE_Depot_Name__c+'_'+costdata.RE_Product_Name__c :  costdata.RE_Product_Name__c;
            keydata = costdata.RE_Depot_Name__c != null ? costdata.RE_Depot_Name__c+'_'+costdata.RE_Product_Name__c :  costdata.RE_Product_Name__c;
            if(costData.RE_Type__c !=  ''){
                costData.RE_Type__c = '';
                prevcostList.add(costData);                
            }
            if(!latestcostList.containsKey(keydata) && depoMap.containsKey(depokey)){
                    costData.RE_Type__c = datatypeList[0];
                    latestcostList.put(keydata,costData);
            }
            else{
                if(!oldcostList.containsKey(keydata) && depoMap.containsKey(depokey)){
                    costData.RE_PH_Is_Today__c = False;
                    costData.RE_Type__c = datatypeList[1];
                    oldcostList.put(keydata,costData);
                }    
            }
        }       
        if(!latestcostList.isEmpty())
            finalcostList.addAll(latestcostList.values());
        if(!oldcostList.isEmpty())
            finalcostList.addAll(oldcostList.values());
        
        if(!prevcostList.isEmpty()){
            for(RE_MY_CostPrice__c costData : prevcostList){
                if(!finalcostList.contains(costData))
                    finalcostList.add(costData);
            }
        }
        if(!finalcostList.isEmpty()){
            try{
                update finalcostList;                
                }
            catch(Exception e){
                return false;
            } 
        }
        return true;        
    }
    
    private static Boolean run = True;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}