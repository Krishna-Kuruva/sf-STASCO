public class RE_SOQLController {     
    //Getting Latest Market Quotes data   
    public List<RE_Market_Quotes__c> fetchMarketQuotesData(){
        Map<String, RE_Market_Quotes__c> marketquoteList = new Map<String, RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c 
            FROM RE_Market_Quotes__c
            WHERE RE_Quote_Type__c IN ('Settlement','Assessed Premium','Market Premium') 
            AND RE_Tracker__c = 'D'
            AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
            ORDER BY RE_Pricing_Date__c DESC]){
                if(!marketquoteList.containsKey(marketquoteData.RE_Quote_Name__c))
                    marketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
            }
        return marketquoteList.values();
    } 
    
    //Getting Latest Market Quotes data 
    public List<RE_Market_Quotes__c> fetchMiddayMarketQuotesData(){
        Map<String, RE_Market_Quotes__c> marketquoteList = new Map<String, RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,Id
            FROM RE_Market_Quotes__c
            WHERE RE_Quote_Type__c = 'Midday'
            AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
            AND createddate = Today
            ORDER BY RE_Pricing_Date__c DESC]){
                if(!marketquoteList.containsKey(marketquoteData.RE_Quote_Name__c))
                    marketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
            }
        return marketquoteList.values();
    }
    
    //Getting latest Bio Quotes data for Malaysia
    public List<RE_Bio_Quotes__c> fetchMalaysianBioQuotesData(){
       Map<String, RE_Bio_Quotes__c> bioquoteList = new Map<String, RE_Bio_Quotes__c>();
        for(RE_Bio_Quotes__c bioquoteData : 
            [SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Region__c,RE_Bio_Quotes_Name__c,RE_Bio_RateUnit__c
            FROM RE_Bio_Quotes__c WHERE recordtype.Name = 'Malaysia'
            ORDER BY RE_Pricing_Date__c DESC]){
                if(!bioquoteList.containsKey(bioquoteData.RE_Bio_Quotes_Name__c))
                    bioquoteList.put(bioquoteData.RE_Bio_Quotes_Name__c,bioquoteData);
            }
        return bioquoteList.values();
    }

    //Getting latest Bio Quotes data for Singapore 
    public List<RE_Bio_Quotes__c> fetchSingaporeBioQuotesData(){
        return(
            [SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Bio_RateUnit__c,RE_Region__c,RE_Bio_Quotes_Name__c
            FROM RE_Bio_Quotes__c
            ORDER BY RE_Pricing_Date__c DESC]
        );
    }
    //Fetching latest Depot Pricing Backbone data for Malaysia
    public List<RE_Depot_Pricing_Backbone__c> fetchMYDepotpricingData(){
        return(
            [SELECT RE_Backbone_Name__c,RE_Country__c,RE_Product_Name__r.Name, RE_Depot_Name__r.RE_Region_Name__c,RE_Snh_Cost__c,RE_Comments__c,
            RE_Depot_Name__r.Name,RE_Depot_Name__c,RE_Product_Name__c,RE_Country__r.Name,RE_Final_Price_Unit__c,RE_Spot_Price_Adjustment__c,
            RE_Primary_Transport_Cost__c,RE_Primary_Transport_Offset__c,RE_Primary_Transport_Unit__c,RE_SnH_Unit__c, RE_Spot_Price_Adjustment_Unit__c
            FROM  RE_Depot_Pricing_Backbone__c
            WHERE RE_Valid_From__c <= Today 
            AND RE_Valid_To__c >= Today  
            AND RE_Country__r.Name = 'Malaysia'
        ]);
    }
    
    //Fetching latest Depot Pricing Backbone data for Singapore
    public List<RE_Depot_Pricing_Backbone__c> fetchSGDepotpricingData(){
        return(
            [SELECT RE_Backbone_Name__c,RE_Country__c,RE_Product_Name__r.Name, RE_Depot_Name__r.RE_Region_Name__c,RE_Snh_Cost__c,RE_Fixed_Premium__c,RE_IsDistillisationRate__c,
            RE_Depot_Name__r.Name,RE_Depot_Name__c,RE_Product_Name__c,RE_Country__r.Name,RE_Final_Price_Unit__c,RE_Cost_Price_Adjustment_Unit__c,RE_Fixed_Premium_Percentage__c,
            RE_Primary_Transport_Cost__c,RE_Primary_Transport_Offset__c,RE_Primary_Transport_Unit__c,RE_SnH_Unit__c,RE_Cost_Price_Adjustment__c,RE_Fixed_Premium_Unit__c
            FROM  RE_Depot_Pricing_Backbone__c
            WHERE RE_Valid_From__c <= Today 
            AND RE_Valid_To__c >= Today  
            AND RE_Country__r.Name = 'Singapore'
        ]);
    }
            
    //Fetching Sales Tax data for Malaysia
    public Static List<RE_Sales_Tax__c> fetchsalesTaxData(){
        return([
            SELECT RE_Product_Type__c, RE_Tax_Value__c,RE_Tax_Unit__c,RE_Region__c
            FROM RE_Sales_Tax__c
            WHERE RE_Valid_From__c <= Today
            AND RE_Valid_To__c >= Today
            ORDER BY RE_Publish_Date__c
        ]);
    }
    
    //Fetching Product Data - Singapore
    public Static List<RE_Product__c> fetchSingaporeprodData(){
        return([
            Select RE_Additive_Cost__c,Name, RE_Product_Group__c,  RE_Product_Subgroup__c, RE_Additive_Cost_Unit__c,
            RE_Midday_MC0_Valid_From__c,RE_Midday_MC0_Valid_To__c,RE_Midday_MC0_Value__c,
            RE_Morning_MC0_Valid_From__c,RE_Morning_MC0_Valid_To__c,RE_Morning_MC0_Value__c
            FROM RE_Product__c
            WHERE RE_Country__r.Name = 'Singapore'
        ]);
    }
    
    //Fetching Product Data - Malaysia
    public Static List<RE_Product__c> fetchMalaysiaprodData(){
        return(
            [Select RE_Additive_Cost__c,Name, RE_Product_Group__c, RE_Product_Subgroup__c, RE_Additive_Cost_Unit__c
            FROM RE_Product__c
             WHERE RE_Country__r.Name = 'Malaysia'
        ]);
    }
    //Fetching Malaysia Route Backbone data
    public Static List<RE_Route_Backbone__c> fetchRouteBackboneData(){
        Id rectypeId = Schema.SObjectType.RE_Route_Backbone__c.getRecordTypeInfosByDeveloperName().get('Malaysia').getRecordTypeId();
        return(
            [SELECT Id,RE_Country__c,RE_Destination_Name__c,RE_Product_Name__c,RE_Product_Name__r.Name,RE_CO_Steer__c,RE_MY_Bio_Loss_Percentage__c,RE_MY_Freight_Charges__c,
             RE_MY_BreakBulk_Premium_Quote_Percentage__c,RE_Destination_Name__r.Name,RE_Country__r.Name,RE_Fixed_Premium_Unit__c,RE_Fixed_Premium__c,RE_MY_Freight_Charges_Unit__c,
             RE_MY_BreakBulk_Premium_Quote__c,RE_MY_Comments__c,RE_MY_CO_Steer_Unit__c,RE_MY_Market_Premium_Percentage__c,RE_MY_Market_Premium_Quote__c,RE_CO_Steer_Valid_From__c,
             RE_MY_MR_Cost_Percentage__c,RE_MY_MR_Demurrage_Unit__c,RE_MY_MR_Demurrage__c,RE_MY_MR_Frieght_Quote__c,RE_MY_Oil_Loss_Percentage__c,RE_MY_TP_Premium_Unit__c,
             RE_MY_Port_Charges_Unit__c,RE_MY_Port_Charges__c,RE_MY_Primary_Transport_Cost__c,RE_MY_Primary_Transport_Offset__c,RE_MY_Primary_Transport_Unit__c,RE_CO_Steer_Valid_To__c,
             RE_MY_Small_lot_percentage__c,RE_MY_Small_lot_premium_Unit__c,RE_MY_Small_lot_premium__c,RE_MY_Storage_Handling_Cost_OSP__c,RE_MY_Storage_Handling_Unit__c,
             RE_Route_Utilization__c,RE_Source_Code__c,RE_Source_Name__c,RE_Source_Name__r.Name,RE_Valid_From__c,RE_Valid_To__c , RE_MY_TP_Premium__c, RE_MY_TP_Premium_Percentage__c
             FROM RE_Route_Backbone__c 
             WHERE RecordtypeId =: rectypeId
             AND RE_Valid_From__c <= Today 
             AND RE_Valid_To__c >= Today
        ]);
    } 
    
     //Fetching Thailand Route Backbone data
    public Static List<RE_Route_Backbone__c> fetchTHRouteBackboneData(){
        Id rectypeId = Schema.SObjectType.RE_Route_Backbone__c.getRecordTypeInfosByDeveloperName().get('Thailand').getRecordTypeId();
        return(
            [SELECT Id,RE_Country__c,RE_Destination_Name__c,RE_Product_Name__c,RE_Product_Name__r.Name,RE_CO_Steer__c,RE_MY_Bio_Loss_Percentage__c,RE_MY_Freight_Charges__c,
             RE_MY_BreakBulk_Premium_Quote_Percentage__c,RE_Destination_Name__r.Name,RE_Country__r.Name,RE_Fixed_Premium_Unit__c,RE_Fixed_Premium__c,RE_MY_Freight_Charges_Unit__c,
             RE_MY_BreakBulk_Premium_Quote__c,RE_MY_Comments__c,RE_MY_CO_Steer_Unit__c,RE_MY_Market_Premium_Percentage__c,RE_MY_Market_Premium_Quote__c,RE_CO_Steer_Valid_From__c,
             RE_MY_MR_Cost_Percentage__c,RE_MY_MR_Demurrage_Unit__c,RE_MY_MR_Demurrage__c,RE_MY_MR_Frieght_Quote__c,RE_MY_Oil_Loss_Percentage__c,RE_MY_TP_Premium_Unit__c,
             RE_MY_Port_Charges_Unit__c,RE_MY_Port_Charges__c,RE_MY_Primary_Transport_Cost__c,RE_MY_Primary_Transport_Offset__c,RE_MY_Primary_Transport_Unit__c,RE_CO_Steer_Valid_To__c,
             RE_MY_Small_lot_percentage__c,RE_MY_Small_lot_premium_Unit__c,RE_MY_Small_lot_premium__c,RE_MY_Storage_Handling_Cost_OSP__c,RE_MY_Storage_Handling_Unit__c,
             RE_Route_Utilization__c,RE_Source_Code__c,RE_Source_Name__c,RE_Source_Name__r.Name,RE_Valid_From__c,RE_Valid_To__c , RE_MY_TP_Premium__c, RE_MY_TP_Premium_Percentage__c
             FROM RE_Route_Backbone__c 
             WHERE RecordtypeId =: rectypeId
             AND RE_Valid_From__c <= Today 
             AND RE_Valid_To__c >= Today
        ]);
    } 
    //Fetching Malaysia formula data from metadata
    public List<RE_Malaysian_Formula_Table__mdt> fetchMalaysiaformulaData(){
        return(
            [SELECT RE_MY_Bio_Loss_Percentage__c,RE_MY_Bio_Quote_1__c,RE_MY_Bio_Quote_2__c,
            RE_MY_Bio_Quote_3__c,RE_MY_Bio_Quote_Percentage__c,RE_MY_BreakBulk_Premium_Quote_Percentage__c,RE_MY_BreakBulk_Premium_Quote__c,
            RE_MY_HCV_Quote_Percentage__c,RE_MY_HCV_Quote__c,RE_MY_HCV_Surcharges__c,RE_MY_Market_Premium_Percentage__c,RE_MY_Fixed_Premium_Unit__c,
            RE_MY_Market_Premium_Quote__c,RE_MY_Oil_Loss_Percentage__c,RE_MY_Plant__c,RE_MY_Product__c,RE_MY_Region__c,RE_MY_Fixed_Premium__c,
            RE_MY_Small_lot_percentage__c,RE_MY_Small_lot_premium_Unit__c,RE_MY_Small_lot_premium__c,RE_MY_TP_Premium_Percentage__c,
            RE_MY_TP_Premium__c,RE_MY_MR_Cost_Percentage__c,RE_MY_MR_Demurrage_Unit__c,RE_MY_MR_Demurrage__c,RE_MY_MR_Frieght_Quote__c,
            RE_MY_Port_Charges__c,RE_MY_Port_Charges_Unit__c,RE_MY_Valid_From__c,RE_MY_Valid_To__c,RE_MY_TP_Premium_Unit__c
            FROM RE_Malaysian_Formula_Table__mdt 
            WHERE RE_MY_Valid_From__c <= Today 
            AND RE_MY_Valid_To__c >= Today
        ]);
    }
    //Fetching Singapore formula data from metadata    
    public List<RE_SG_Cost_Price_Manager__mdt> fetchSingaporeformulaData(){
        return(
            [SELECT RE_SG_HCV_Quote_1_Percent__c,RE_SG_HCV_Quote_1__c,RE_SG_HCV_Quote_2_Percent__c,RE_SG_HCV_Quote_2__c,
             RE_SG_Market_Premium_Percent__c,RE_SG_Market_Premium_Quote__c,RE_SG_Oil_Loss_Percent__c,RE_SG_Plant__c,RE_SG_Product__c,
             RE_SG_Valid_From__c, RE_SG_Valid_To__c, RE_SG_Dist_Disc_Quote__c, RE_SG_Dist_Disc_Percentage__c 
             FROM RE_SG_Cost_Price_Manager__mdt
             WHERE RE_SG_Valid_From__c <= Today
             AND RE_SG_Valid_To__c >= Today
        ]);
    }
    //Fetch Forex rate data
    public Map<String, Double> fetchLatestFxData(){
        Map<String, Double> curConvMap = new Map<String, Double>();
        for(RE_FX_Rates__c latestData : [
            SELECT RE_Conversion_Unit__c,RE_Base_Unit__c,RE_Forex_Rate__c,RE_Pricing_Date__c
            FROM RE_FX_Rates__c             
            WHERE RE_Trade_Type__c = 'Sell'
            AND RE_Tracker__c = 'D'
            ORDER BY RE_Pricing_Date__c DESC]){ 
            if(!curConvMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c))
                curConvMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c, latestData.RE_Forex_Rate__c);
        }
        return curConvMap;
    }
    
    //Fetch Midday Forex rate data for Singapore
    public Map<String, Double> fetchLatestMidFxData(){
        Map<String, Double> curConvMap = new Map<String, Double>();
        for(RE_FX_Rates__c latestData : [
            SELECT RE_Conversion_Unit__c,RE_Base_Unit__c,RE_Forex_Rate__c,RE_Pricing_Date__c
            FROM RE_FX_Rates__c             
            WHERE RE_Trade_Type__c = 'Sell'
            AND RE_Tracker__c = 'D+1'
            ORDER BY RE_Pricing_Date__c DESC]){ 
            if(!curConvMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c))
                curConvMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c, latestData.RE_Forex_Rate__c);
        }
        return curConvMap;
    }

    //Fetch Forex rate data for PH
    public Map<String, Double> fetchPHLatestFxData(String type){
        Map<String, Double> curConvMap = new Map<String, Double>();
        for(RE_FX_Rates__c latestData : [
            SELECT RE_Conversion_Unit__c,RE_Base_Unit__c,RE_Forex_Rate__c,RE_Pricing_Date__c
            FROM RE_FX_Rates__c             
            WHERE RE_Trade_Type__c = 'Sell'
            AND RE_Tracker__c =: type
            AND RE_Conversion_Unit__c = 'PHP'
            AND RE_Base_Unit__c = 'USD' 
            ORDER BY RE_Pricing_Date__c DESC]){ 
            if(!curConvMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c))
                curConvMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c, latestData.RE_Forex_Rate__c);
        }
        return curConvMap;
    }
    
    //Fetch Forex rate data SG
    public Double fetchSGFxData(){
       Double curConvMultiplier;
        for(RE_FX_Rates__c latestData : [
            SELECT RE_Forex_Rate__c FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'SGD'
            AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Tracker__c = 'D' ORDER BY RE_Pricing_Date__c DESC
            LIMIT 1]){            
            curConvMultiplier = latestData.RE_Forex_Rate__c;
        }
        return curConvMultiplier;
    }
    
    //Fetch Midday Forex rate data for Singapore
    public Double fetchSGFxDataforMidDay(){
        Double curConvMultiplier;
        for(RE_FX_Rates__c latestData : [
                SELECT RE_Forex_Rate__c FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'SGD'
                AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Tracker__c = 'D+1' ORDER BY RE_Pricing_Date__c DESC
                LIMIT 1]){
            curConvMultiplier = latestData.RE_Forex_Rate__c;
        }
        return curConvMultiplier;
    }
    
    //Fetch Forex rate data for Malaysia
    public Static Double fetchMYFxData(){
        Double curConvMultiplier;
        for(RE_FX_Rates__c latestData : [
                SELECT RE_Forex_Rate__c FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'MYR CTS'
                AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Tracker__c = 'D' ORDER BY RE_Pricing_Date__c DESC
                LIMIT 1]){
            curConvMultiplier = latestData.RE_Forex_Rate__c;
        }
        return curConvMultiplier;
    }

    //Fetch Midday Forex rate data for Malaysia
    public Static Double fetchMYFxDataforMidDay(){
        Double curConvMultiplier;
        for(RE_FX_Rates__c latestData : [
                SELECT RE_Forex_Rate__c FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'MYR CTS'
                AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Tracker__c = 'D+1' ORDER BY RE_Pricing_Date__c DESC
                LIMIT 1]){
            curConvMultiplier = latestData.RE_Forex_Rate__c;
        }
        return curConvMultiplier;
    }

    //Fetch Forex rate data
    public Double fetchLastMondayFxData(){
        Double distdiscrate = 0;
        Map<String, Double> curConvMap = new Map<String, Double>();              
        for(RE_FX_Rates__c latestData : [
            SELECT RE_Conversion_Unit__c,RE_Base_Unit__c,RE_Forex_Rate__c,RE_Pricing_Date__c,createddate
            FROM RE_FX_Rates__c             
            WHERE RE_Trade_Type__c = 'Sell'
            AND RE_Conversion_Unit__c = 'SGD'
            AND RE_Base_Unit__c = 'USD'
            ORDER BY RE_Pricing_Date__c desc
        ]){ 
            if(latestData.RE_Pricing_Date__c.format('EEEE') == 'Monday' && !curConvMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c)){
                curConvMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c, latestData.RE_Forex_Rate__c);
            }
                
        }
        if(!curConvMap.isEmpty())
            distdiscrate = curConvMap.get('SGD-USD');
        return distdiscrate;
    }
    
    //Fetch Forex rate data
    public Double fetchOldLastMondayFxData(){
        Double distdiscrate = 0;
        Map<String, Double> curConvMap = new Map<String, Double>(); 
        for(RE_FX_Rates__c latestData : [
            SELECT RE_Conversion_Unit__c,RE_Base_Unit__c,RE_Forex_Rate__c,RE_Pricing_Date__c,createddate
            FROM RE_FX_Rates__c             
            WHERE RE_Trade_Type__c = 'Sell'
            AND RE_Conversion_Unit__c = 'SGD'
            AND RE_Base_Unit__c = 'USD'
            AND Createddate < Today
            ORDER BY RE_Pricing_Date__c desc
        ]){ 
            if(latestData.RE_Pricing_Date__c.format('EEEE') == 'Monday' && !curConvMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c)){
                curConvMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c, latestData.RE_Forex_Rate__c);
            }               
        }
        if(!curConvMap.isEmpty())
            distdiscrate = curConvMap.get('SGD-USD');
        return distdiscrate;
    }
        
    public Static List<RE_Market_Quotes__c> fetchMarketQuotesSettlementData(){
        Map<String, RE_Market_Quotes__c> marketquoteList = new Map<String, RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c 
            FROM RE_Market_Quotes__c
            WHERE RE_Pricing_Date__c = LAST_N_DAYS:5
            AND RE_Quote_Type__c = 'Settlement'
            AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
            AND RE_Is_MTDWTD__c = False
            ORDER BY RE_Pricing_Date__c DESC]){
                if(!marketquoteList.containsKey(marketquoteData.RE_Quote_Name__c))
                    marketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
            }
        return marketquoteList.values();
    }

    public Static List<RE_Market_Quotes__c>  fetchforwardswapquotes(){
        return ([
                SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c
                FROM RE_Market_Quotes__c
                WHERE createddate = Today
                AND RE_Quote_Type__c = 'Forward Swap'
                ORDER BY RE_Pricing_Date__c ASC
                LIMIT 2
        ]);
    }
    
    public Static Map<String,Double> fetchlatestMYCostPrice(){
        Map<String,Double> costdatamap = new Map<String,Double>();
        for(RE_MY_CostPrice__c costdata : [
            SELECT Id, RE_Costprice_Marginal_Cost__c, RE_Depot_Name__c,RE_Depot_Name__r.Name, RE_Product_Name__c , RE_Product_Name__r.Name
            FROM RE_MY_CostPrice__c
            WHERE RE_IsLatest__c = True AND Recordtype.name='Malaysia' 
        ]){
            costdatamap.put(costdata.RE_Depot_Name__c+'_'+costdata.RE_Product_Name__c, costdata.RE_Costprice_Marginal_Cost__c);
        }
        return costdatamap;
    }
    
    public Static Map<String,Double> fetchlatestTHCostPrice(){
        Map<String,Double> costdatamap = new Map<String,Double>();
        for(RE_MY_CostPrice__c costdata : [
            SELECT Id, RE_Costprice_Marginal_Cost__c, RE_Costprice_Laid_Down_Cost__c,RE_Depot_Name__c,RE_Depot_Name__r.Name, RE_Product_Name__c , RE_Product_Name__r.Name
            FROM RE_MY_CostPrice__c
            WHERE RE_IsLatest__c = True AND Recordtype.name='Thailand' 
        ]){
            costdatamap.put(costdata.RE_Depot_Name__c+'_'+costdata.RE_Product_Name__c, costdata.RE_Costprice_Laid_Down_Cost__c);
        }
        return costdatamap;
    }
    
    public Static Map<String,REV_Contract_Master__c>  fetchPHActiveContracts(string country, String recordtype){
        Map<String,REV_Contract_Master__c> contractMap = new Map<String,REV_Contract_Master__c>();
        Id AccrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        Datetime valdate = System.today();
        String dayName = valdate.format('EEE');
        List<Account> acclist= [SELECT Id FROM Account WHERE RT_Active__c = True AND recordtypeId = : AccrectypeId];
        for(REV_Contract_Master__c contrct : [
            SELECT Active__c,Country_Name__c,RE_Sales_Org__r.Value__c ,List_Price_Tier__r.Value__c,RE_Customer_Name__c,RE_Round_Up__c,Name,RE_Account_Manager__c,RE_Rebate__c,
            RE_TransportCharges__c,RE_Transport_Charges__c,RE_Transport_Mode__c,RT_Comment__c,RT_Material_Desc__c,RT_Material_Desc__r.Name,RE_Material_Code__c,RE_Customer_Name__r.Type,
            RT_Plant_Desc__c,RT_Plant_Desc__r.Name,RT_Plant_Code__c,RT_Valid_From__c,RT_Valid_To__c,RE_Service_SurChg__c,RE_Aspired_Margin__c,RE_IsHedged__c,RE_Reference_Period__c,
           	RE_Customer_Name__r.Name,RE_Customer_Name__r.AccountNumber,RE_Calculation_Type__c,RE_Secondary_Transport_Cost__c,RE_Sold_To_Number__c,RE_Ship_To_Number__c
            FROM REV_Contract_Master__c
            WHERE Active__c = True
            AND Country_Name__c =: country
            AND RE_Customer_Name__c IN: acclist
            AND RT_Valid_From__c <= Today
            AND RT_Valid_To__c >= Today
        ]){
            //contractMap.put(contrct.RT_Plant_Code__c+'_'+contrct.RE_Material_Code__c+'_'+contrct.RE_Ship_To_Number__c+'_'+contrct.RE_Sold_To_Number__c,contrct);
            contractMap.put(contrct.id,contrct);
        }
        return contractMap;
    }
    
    public Static List<REV_Contract_Master__c> fetchActiveContracts(string custType){
        Id AccrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution MY').getRecordTypeId();
        //Id ContractrectypeId = Schema.SObjectType.REV_Contract_Master__c.getRecordTypeInfosByName().get('Revolution MY').getRecordTypeId();
        Datetime valdate = System.today();
        String dayName = valdate.format('EEE');
        List<Account> acclist= [SELECT Id FROM Account WHERE RT_Active__c = True AND recordtypeId = : AccrectypeId];
        return ([
            SELECT Active__c,Country_Name__c,RE_Sales_Org__r.Value__c ,List_Price_Tier__r.Value__c,RE_Customer_Name__c,RE_Round_Up__c,Name,RE_Account_Manager__c,RE_Rebate__c,RE_BDF__c,RE_ServiceSurChg__c,RE_Service_SurChg__c,RE_Custom_Ops_Calculation__r.RE_Editable_Field__c,
            RE_TransportCharges__c,RE_Transport_Charges__c,RE_Transport_Mode__c,RT_Comment__c,RT_Material_Desc__c,RT_Material_Desc__r.Name,RE_Customer_Name__r.Type,RE_Custom_Ops_Calculation__r.RE_Validity__c,
            RT_Plant_Desc__c,RT_Plant_Desc__r.Name,RT_Plant_Code__c,RT_Valid_From__c,RT_Valid_To__c,RE_Standard_Discount__c, RE_Std_Disc_Valid_From__c,RE_Custom_Ops_Calculation__c,RE_Custom_Ops_Calculation__r.Name,
            RE_Std_Disc_Valid_To__c,RE_Temporary_Discount__c,RE_Customer_Name__r.Name,RE_Customer_Name__r.AccountNumber,RE_Pricing_Levels__c,RE_DFOA_Charges__c
            FROM REV_Contract_Master__c
            WHERE Active__c = True
            //AND recordtypeId = : ContractrectypeId
            AND Country_Name__c = 'MY'
            AND RE_Customer_Name__c IN: acclist
            AND RT_Valid_From__c <= Today
            AND RT_Valid_To__c >= Today
            AND RE_Customer_Name__r.Type =: custType
            /*AND RE_Custom_Ops_Calculation__r.RE_Frequency__c INCLUDES (:dayName)*/]);
    }
    
     public Static List<REV_Contract_Master__c> fetchNewContracts(string custType){
        Id AccrectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution MY').getRecordTypeId();
         List<Account> acclist= [SELECT Id FROM Account WHERE RT_Active__c = True AND recordtypeId = : AccrectypeId];
         
        Map<Id, REV_Contract_Master__c> contractMap = new Map<Id, REV_Contract_Master__c>([
            SELECT Active__c,Country_Name__c,RE_Sales_Org__r.Value__c,RE_Customer_Name__c,List_Price_Tier__r.Value__c,RE_Round_Up__c,Name,RE_Account_Manager__c,RE_Rebate__c,RE_BDF__c,RE_ServiceSurChg__c,RE_Service_SurChg__c,RE_Custom_Ops_Calculation__r.RE_Editable_Field__c,
            RE_TransportCharges__c,RE_Transport_Charges__c,RE_Transport_Mode__c,RT_Comment__c,RT_Material_Desc__c,RT_Material_Desc__r.Name,RE_Customer_Name__r.Type,RE_Custom_Ops_Calculation__r.RE_Validity__c,
            RT_Plant_Desc__c,RT_Plant_Desc__r.Name,RT_Plant_Code__c,RT_Valid_From__c,RT_Valid_To__c,RE_Standard_Discount__c, RE_Std_Disc_Valid_From__c,RE_Custom_Ops_Calculation__c,RE_Custom_Ops_Calculation__r.Name,
            RE_Std_Disc_Valid_To__c,RE_Temporary_Discount__c,RE_Customer_Name__r.Name,RE_Customer_Name__r.AccountNumber,RE_Pricing_Levels__c,RE_DFOA_Charges__c
            FROM REV_Contract_Master__c
            WHERE Active__c = True
            AND createddate=today
            AND Country_Name__c = 'MY'
            AND RE_Customer_Name__c IN: acclist
            AND RT_Valid_From__c <= Today
            AND RT_Valid_To__c >= Today
            AND RE_Customer_Name__r.Type =: custType]);
        
         system.debug('-contractMap--'+contractMap.size());
         if(contractMap.size() > 0) {
             for(RT_Price_Book__c pbdadta : [select id ,RE_Contract_Master__c from RT_Price_Book__c where RE_Contract_Master__c IN : contractMap.keySet() ]){
                 if(contractMap.containsKey(pbdadta.RE_Contract_Master__c))
                     contractMap.remove(pbdadta.RE_Contract_Master__c);
             }
         }         
         return contractMap.values();
    }

    public Static List<RT_Setting__c> fetchIntraDayprcing(){
        Id recordType= Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByName().get('Intraday Pricing').getRecordTypeId() ;
        
        return ([SELECT Id, Value__c, RE_Location__r.name, RE_Sales_Org__c, RE_Relevant_Product__c, RE_Product__r.Name FROM RT_Setting__c where RecordtypeId =: recordType]);
    }    
    //Fetching Location Data - Malaysia 
    public Static Map<String,RE_Location__c>  fetchMalaysialocData(){
        Map<String,RE_Location__c> locmap = new Map<String,RE_Location__c>();
        for(RE_Location__c locdata : [
            Select RE_Abbreviated_Name__c,Name, RE_Location_Code__c, RE_Region_Name__c
            FROM RE_Location__c
            WHERE RE_Country__r.Name = 'Malaysia'
        ]){
             locmap.put(locdata.Name, locdata);                   
        }
        return locmap;
    }
    
     public Static List<RE_MOA__c>  fetchAMVoutputdata(){
         Id recordType= Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        return ([
            SELECT Id,RE_Depot_Name__c,RE_Depot_Name__r.RE_Region_Name__c,RE_Depot_Name__r.Name,RE_MC_Morning__c,RE_Prev_Mid_Day_price_out__c,
            RE_Today_s_BSP__c,RE_Target_Margin__c,RE_PSP__c,RE_Final_PSP__c,RE_Remark__c,RE_Spot_Price_Adj__c,RE_AM_Challenged_Price__c,RE_Agreed_PSP__c,
            RE_AM_Comments__c,RE_isDisabled__c,RE_Product__r.Name,RE_Product__c,RE_LDC_Morning__c,RE_Mid_Day_price_out__c,createddate, lastmodifieddate
            FROM  RE_MOA__c 
            WHERE RE_IsLatest__c = True
            AND RecordTypeId = :recordType
            ORDER BY RE_Depot_Name__r.RE_Region_Name__c]);
    }
    
    public Static Double fetchAfternoonIndication(){ 
        return( [
            SELECT RE_Product__c, RE_Midday_Forecast_Price__c FROM RE_Midday_Pricing__c
            WHERE RE_Product__c IN ('E5 GO B7')
            AND CREATEDDATE = Today
            order by CREATEDDATE desc
            LIMIT 1].RE_Midday_Forecast_Price__c);
    }
    
    public static Map<String,Double> fetchAfternoonIndicationMap(){
        Map<String,Double> indicationMap = new Map<String,Double>();
        for(RE_Midday_Pricing__c midDay :[SELECT RE_Product__c, RE_Depot_Name__r.Name,RE_Midday_Forecast_Price__c ,RE_Product_Name__r.Name FROM RE_Midday_Pricing__c WHERE CREATEDDATE = Today AND  RE_IsLatest__c = True order by CREATEDDATE desc] ){
            indicationMap.put(midDay.RE_Depot_Name__r.Name+'_'+midDay.RE_Product_Name__r.Name , midDay.RE_Midday_Forecast_Price__c);
        }
        
        return indicationMap;
    }
    
    //Fetching latest Formula Table data for Thailand
    public List<RE_Depot_Pricing_Backbone__c> fetchTHDepoPricingData(){
        return(
        [SELECT Id,RE_Country__c,RE_Country__r.Name,RE_Depot_Name__r.Name,RE_Product_Name__r.Name,RE_Final_Price_Unit__c,RE_TH_HCV_Quote1__c,RE_TH_HCV_Quote1_Percent__c,RE_TH_HCV_Quote2__c,RE_TH_HCV_Quote2_Percent__c,RE_Depot_Name__c,RE_Primary_Transport_Cost__c,RE_Primary_Transport_Unit__c,RE_Product_Name__c,RE_Snh_Cost__c,RE_SnH_Unit__c,Name,RE_Valid_To__c,RE_Valid_From__c,RE_Primary_Transport_Offset__c,RE_TH_Sales_Tax_Duty_5__c,RE_TH_HCV_Surcharges__c,HCV_Surcharges_UNIT__c,TH_15_to_30_factor__c,RE_TH_Oil_Loss_Percent__c,RE_TH_TP_Premium_HCV1__c,TP_Premium_HCV1_Unit__c,RE_TH_TP_Premium_HCV2__c,TP_Premium_HCV2_Unit__c,RE_Deem_Value__c,RE_Deem_Unit__c,RE_Insurance_Percentage__c,RE_Loss_Percentage__c,RE_IsTPFormula__c,RE_TH_Gantry_charge_Unit__c,RE_TH_Gantry_Charge__c,
        RE_TH_QP__c,RE_TH_QP_Unit__c,RE_TH_SP_Adt__c,RE_Comments__c,RE_TH_SP_Adt_Unit__c,RE_Spot_Price_Adjustment__c,RE_Spot_Price_Adjustment_Unit__c 
        FROM RE_Depot_Pricing_Backbone__c
        WHERE RE_Valid_From__c <= Today AND RE_Valid_To__c >= Today
        AND RecordType.Name='Thailand' order by RE_Product_Name__r.Name
        ]);
    }
    
     //Fetching latest Formula Table data for Phillipines
   public List<RE_Depot_Pricing_Backbone__c> fetchPHDepoPricingData(){
        return(
            [SELECT Id,RE_Country__c,RE_Country__r.Name,RE_Depot_Name__r.Name,RE_Product_Name__r.Name,RE_Final_Price_Unit__c,RE_TH_HCV_Quote1__c,RE_TH_HCV_Quote1_Percent__c,RE_Depot_Name__c,RE_Primary_Transport_Cost__c,RE_Primary_Transport_Unit__c,RE_Product_Name__c,RE_Valid_From__c,RE_Insurance_Percentage__c, RE_PH_Blend_Percentage__c, 
        RE_PH_Premium__c,RE_Fixed_Premium__c,RE_PH_Freight_Conversion_Factor__c,RE_PH_Freight_Quote__c,RE_PH_Freight_Charges__c,RE_PH_Bio_Percent__c,RE_PH_BIO_1__c,RE_PH_BIO_2__c,RE_PH_BIO_3__c,RE_PH_BIO_Fixed__c,RE_PH_Small_Lot__c,RE_PH_Freight_Shifting_Cost__c,RE_PH_Demurrage__c,RE_PH_FLC_Service_Fee__c,RE_PH_PT_Percentage__c,
        RE_PH_MISC_Brokerage_Fee__c,RE_PH_MISC_Hosehandling_Cost__c,RE_PH_MISC_Port_Charges__c,RE_PH_MISC_PQ_Cost__c,RE_PH_MISC_Shifting_Cost__c,RE_PH_MISC_Waterfront_Operations_Cost__c,RE_PH_Terminal_Cost__c,RE_PH_Wharfage_Cost__c,RE_PH_Fuel_Marking_Factor__c,RE_PH_MISC_Fuel_Marking_Fee__c,RE_PH_Ocean_Cost__c,RE_PH_S_H__c,
        RE_PH_Wharfage_Cost_Unit__c,RE_PH_MISC_Fuel_Marking_Fee_Unit__c,RE_Fixed_Premium_Unit__c,RE_PH_Freight_Charges_Unit__c,RE_PH_BIO_Fixed_Unit__c,RE_PH_Freight_Shifting_Cost_Unit__c,RE_PH_Demurrage_Unit__c,RE_PH_FLC_Service_Fee_Unit__c,RE_PH_MISC_Brokerage_Fee_Unit__c,RE_PH_MISC_Hosehandling_Cost_Unit__c,
        RE_PH_MISC_Port_Charges_Unit__c,RE_PH_MISC_PQ_Cost_Unit__c,RE_PH_MISC_Shifting_Cost_Unit__c, RE_PH_Waterfront_Operations_Cost_Unit__c, RE_PH_Terminal_Cost_Unit__c,RE_Snh_Cost__c,RE_SnH_Unit__c,RE_Reference_Product__c,RE_Reference_Product__r.Name,RE_Product_Name__r.RE_PH_Percent_Base_Fuel__c
        FROM RE_Depot_Pricing_Backbone__c
        WHERE RE_Valid_From__c <= Today AND RE_Valid_To__c >= Today
        AND RecordType.Name='Philippines' order by RE_Product_Name__r.Name
        ]);
    } 
    //Fetching Product Data - Thailand
    public Static List<RE_Product__c> fetchThailandprodData(String rcType){
        return(
            [Select RE_TH_HCV_Quote1_Percent__c,RE_TH_HCV_Quote2_Percent__c,TH_15_to_30_factor__c,RE_TH_TP_PremiumHCV__c,RE_TH_TP_PremiumHCV2__c,TH_TP_PremiumHCV2_UNIT__c,RE_Additive_Cost__c,Name, RE_Product_Group__c, RE_Product_Subgroup__c, RE_Additive_Cost_Unit__c, RE_Material__c,RE_TH_Oil_Loss_Percent__c,RE_Product_Code__c,RE_TH_TP_Premium__c,TP_Premium_Unit__c,RE_TH_Sales_Tax_Duty_1__c,RE_TH_Sales_Tax_Duty_2__c,RE_TH_Sales_Tax_Duty_3__c,RE_TH_Sales_Tax_Duty_4__c
            FROM RE_Product__c
             WHERE RecordType.Name =:rcType 
        ]);
    }
    //Fetching Product Data - PH - Map
    public Map<String, RE_Product__c> fetchPHprodDataMap(String rcType){
        Map<String, RE_Product__c> productMap = new Map<String, RE_Product__c>();
        for(RE_Product__c latestData : [
            Select RE_Additive_Cost__c,Name, RE_Product_Group__c, RE_Product_Subgroup__c, RE_Additive_Cost_Unit__c, RE_Material__c,RE_TH_Oil_Loss_Percent__c,RE_Product_Code__c,RE_TH_Sales_Tax_Duty_1__c,RE_TH_Sales_Tax_Duty_2__c,RE_TH_Sales_Tax_Duty_3__c,RE_TH_Sales_Tax_Duty_4__c,RE_Country__r.Name
            FROM RE_Product__c
            WHERE RecordType.Name =:rcType ]){ 
            if(!productMap.containsKey(latestData.Name))
                productMap.put(latestData.Name, latestData);
        }
        return productMap;
    }
    
    
    /*
    public Static List<RE_Sales_Tax__c> fetchsalesTaxData(String rcType){
        return([
            SELECT RE_Product_Type__c, RE_Tax_Value__c,RE_Tax_Unit__c,RE_Region__c
            FROM RE_Sales_Tax__c
            WHERE RE_Valid_From__c <= Today
            AND RE_Valid_To__c >= Today AND RecordTYpe.Name='rcType'
            ORDER BY RE_Publish_Date__c
        ]);
    }*/
    //Getting Latest Market Quotes data
    public List<RE_Market_Quotes__c> fetchMarketQuotesTHData(){
        Map<String, RE_Market_Quotes__c> marketquoteList = new Map<String, RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c marketquoteData : [
                SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c
                FROM RE_Market_Quotes__c
                WHERE RE_Quote_Type__c IN ('Settlement')
            	AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
                AND RE_Tracker__c = 'D' AND  RE_Quote_Name__c NOT IN('POME','Ethanol')
                ORDER BY RE_Pricing_Date__c DESC]){
            if(!marketquoteList.containsKey(marketquoteData.RE_Quote_Name__c))
                marketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
        }
        return marketquoteList.values();
    }
    //Getting Latest Market Quotes data
    public List<RE_Market_Quotes__c> fetchMarketQuotesPHData(String type){
        Map<String, RE_Market_Quotes__c> marketquoteList = new Map<String, RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c marketquoteData : [
                SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c
                FROM RE_Market_Quotes__c
                WHERE RE_Quote_Type__c IN ('Settlement','Freight','Market Premium')
                AND RE_Tracker__c =: type
            	AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
                ORDER BY RE_Pricing_Date__c DESC]){
            if(!marketquoteList.containsKey(marketquoteData.RE_Quote_Name__c))
                marketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
        }
        return marketquoteList.values();
    }
    //Getting latest TH Quotes data for Malaysia
    public List<RE_Bio_Quotes__c> fetchThailandQuotesData(String rcType){
        Map<String, RE_Bio_Quotes__c> bioquoteList = new Map<String, RE_Bio_Quotes__c>();
        for(RE_Bio_Quotes__c bioquoteData :
        [SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Region__c,RE_Bio_Quotes_Name__c,RE_Bio_RateUnit__c
        FROM RE_Bio_Quotes__c WHERE RecordType.Name=:rcType
        ORDER BY RE_Pricing_Date__c DESC]){
            if(!bioquoteList.containsKey(bioquoteData.RE_Bio_Quotes_Name__c))
                bioquoteList.put(bioquoteData.RE_Bio_Quotes_Name__c,bioquoteData);
        }
        return bioquoteList.values();
    }
    
    public Static Map<String, RE_Holiday_Calendar__c> fetchHolidayData(){
        Map<String, RE_Holiday_Calendar__c> holidayMap = new  Map<String, RE_Holiday_Calendar__c> ();
        for(RE_Holiday_Calendar__c hc : [SELECT Id, Name,RE_Holiday_Date__c from RE_Holiday_Calendar__c where Recordtype.Name = 'MY Holiday Calendar']){
            holidayMap.put(String.valueOf(hc.RE_Holiday_Date__c),hc);
        }
        return holidayMap;
    }
    public Static Map<String, RE_Holiday_Calendar__c> fetchPHHolidayData(){
        Map<String, RE_Holiday_Calendar__c> holidayMap = new  Map<String, RE_Holiday_Calendar__c> ();
        for(RE_Holiday_Calendar__c hc : [SELECT Id, Name,RE_Holiday_Date__c from RE_Holiday_Calendar__c where Recordtype.Name = 'PH Holiday Calendar']){
            holidayMap.put(String.valueOf(hc.RE_Holiday_Date__c),hc);
        }
        return holidayMap;
    }
    
}