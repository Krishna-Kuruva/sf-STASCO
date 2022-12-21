public class RE_MYCostPrice_Covamo_TriggerHelper {         
    public static Map<ID,Schema.RecordTypeInfo> rt_Map = RE_MY_CostPrice__c.sObjectType.getDescribe().getRecordTypeInfosById();
    public Static Boolean firstcall = false;
    public static void updateSecondaryRecords(List<RE_MY_CostPrice__c> costPrice){
        
        List<RE_MY_CostPrice__c> costPriceCovamo = [select id,name,RE_Depot_Name__c,RE_Depot_Name__r.name,RE_Depot_Name__r.RE_Region_Name__c,RE_Product_Name__c,RE_Product_Name__r.name,Master_Covamo__c,recordtype.name,RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c,RE_Freight_Pipeline_Charges__c,RE_Hydrocarbon_Value__c,RE_Market_Premium__c,RE_FX_Laid_Down_Cost__c,RE_Oil_Loss__c,RE_Breakbulk_Premium__c,RE_Marketing_Selling_Tariff__c,RE_Mark_Up_Credit_Charge__c,RE_Small_Lot_Premium__c,RE_Transfer_Price_Premium__c,RE_Primary_Transport_Cost__c,RE_Bio_Cost__c,RE_Additive_Cost__c,RE_Bio_Loss__c,RE_MR_Freight_Cost__c,RE_Port_Charges_Cost__c,RE_Storage_Handling_Cost__c,RE_Recovery_Sales_Tax__c,RE_Costprice_Unit__c,RE_Job_Run_Count__c from RE_MY_CostPrice__c where recordtype.name='Covamo Malaysia'];
       // System.debug('costPriceCovamo----'+costPriceCovamo);
        List<RE_MY_CostPrice__c> listToAdd = new List<RE_MY_CostPrice__c>();
        if(firstcall == false){
            List<String> depotIdList = new List<String>();
            Map<Id,String> regionMap = new Map<Id,String>();
            for(RE_MY_CostPrice__c cpData1 : costPrice){
                depotIdList.add(cpData1.RE_Depot_Name__c);
            }
            for(RE_Location__c reg: [select id,name,RE_Region_Name__c from RE_Location__c where id IN : depotIdList]){
                regionMap.put(reg.Id,reg.RE_Region_Name__c);
            }
        for(RE_MY_CostPrice__c cpData : costPrice){
            
            for(Integer i=0;i<costPriceCovamo.size();i++){
                //System.debug('check region---'+cpData.RE_Depot_Name__c+'  '+costPriceCovamo[i].RE_Depot_Name__c);
               // System.debug('check product---'+cpData.RE_Product_Name__c+'  '+costPriceCovamo[i].RE_Product_Name__c);
                //System.debug('record type---'+rt_map.get(cpData.recordTypeID).getName());
			if(rt_map.containsKey(cpData.recordTypeID))	
			if(costPriceCovamo[i].RE_Product_Name__c == cpData.RE_Product_Name__c && costPriceCovamo[i].RE_Depot_Name__c == cpData.RE_Depot_Name__c && rt_map.get(cpData.recordTypeID).getName() == 'Malaysia')
			{
                //System.debug('cpData.RE_Market_Premium__c');
				costPriceCovamo[i].Id = costPriceCovamo[i].Id;
				costPriceCovamo[i].RE_Costprice_Marginal_Cost__c = cpData.RE_Costprice_Marginal_Cost__c;
                costPriceCovamo[i].RE_Costprice_Laid_Down_Cost__c = cpData.RE_Costprice_Laid_Down_Cost__c;
                costPriceCovamo[i].RE_Freight_Pipeline_Charges__c = cpData.RE_Freight_Pipeline_Charges__c;
                costPriceCovamo[i].RE_Market_Premium__c = cpData.RE_Market_Premium__c;
                costPriceCovamo[i].RE_FX_Laid_Down_Cost__c = cpData.RE_FX_Laid_Down_Cost__c;
                costPriceCovamo[i].RE_Oil_Loss__c = cpData.RE_Oil_Loss__c;
                costPriceCovamo[i].RE_Breakbulk_Premium__c = cpData.RE_Breakbulk_Premium__c;
                costPriceCovamo[i].RE_Marketing_Selling_Tariff__c = cpData.RE_Marketing_Selling_Tariff__c;
                costPriceCovamo[i].RE_Mark_Up_Credit_Charge__c = cpData.RE_Mark_Up_Credit_Charge__c;
                costPriceCovamo[i].RE_Small_Lot_Premium__c = cpData.RE_Small_Lot_Premium__c;
                costPriceCovamo[i].RE_Transfer_Price_Premium__c = cpData.RE_Transfer_Price_Premium__c;
                costPriceCovamo[i].RE_Primary_Transport_Cost__c = cpData.RE_Primary_Transport_Cost__c;
                costPriceCovamo[i].RE_Bio_Cost__c = cpData.RE_Bio_Cost__c;
                costPriceCovamo[i].RE_Additive_Cost__c = cpData.RE_Additive_Cost__c;
                costPriceCovamo[i].RE_MR_Freight_Cost__c = cpData.RE_MR_Freight_Cost__c;
                costPriceCovamo[i].RE_Port_Charges_Cost__c = cpData.RE_Port_Charges_Cost__c;
                costPriceCovamo[i].RE_Storage_Handling_Cost__c = cpData.RE_Storage_Handling_Cost__c;
                costPriceCovamo[i].RE_Recovery_Sales_Tax__c = cpData.RE_Recovery_Sales_Tax__c;
                costPriceCovamo[i].RE_Costprice_Unit__c = cpData.RE_Costprice_Unit__c;
                costPriceCovamo[i].RE_Job_Run_Count__c = cpData.RE_Job_Run_Count__c;
                
                
                listToAdd.add(costPriceCovamo[i]);
			}
			if(rt_map.containsKey(cpData.recordTypeID))	
             if(costPriceCovamo[i].RE_Product_Name__c == cpData.RE_Product_Name__c && rt_map.get(cpData.recordTypeID).getName() == 'Covamo Malaysia' && cpData.Master_Covamo__c == true){
                costPriceCovamo[i].Id = costPriceCovamo[i].Id;    
                costPriceCovamo[i].RE_Hydrocarbon_Value__c = cpData.RE_Hydrocarbon_Value__c;
				//costPriceCovamo[i].RE_Bio_Cost__c = cpData.RE_Bio_Cost__c;
                
                listToAdd.add(costPriceCovamo[i]);
            }
				firstcall = true;
            }
   
        }
             //System.debug('listToAdd---'+listToAdd);
         MAP<Id,RE_MY_CostPrice__c> costPriceUpdate = new MAP<Id,RE_MY_CostPrice__c>();
            costPriceUpdate.putall(listToAdd);
            if(costPriceUpdate.size()>0){
                update costPriceUpdate.values();
            }
        }
    }
    public static void onDataUpdateForCovamo(List<RE_MY_CostPrice__c> costPrice){
        List<RE_MY_CostPrice__c> costPriceCBU = [select id,name,Master_Covamo__c,RecordType.name,RE_Depot_Name__c,RE_Depot_Name__r.name,RE_Product_Name__r.name,RE_Product_Name__c,RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c,RE_Freight_Pipeline_Charges__c,RE_Hydrocarbon_Value__c,RE_Market_Premium__c,RE_FX_Laid_Down_Cost__c,RE_Oil_Loss__c,RE_Breakbulk_Premium__c,RE_Marketing_Selling_Tariff__c,RE_Mark_Up_Credit_Charge__c,RE_Small_Lot_Premium__c,RE_Transfer_Price_Premium__c,RE_Primary_Transport_Cost__c,RE_Bio_Cost__c,RE_Additive_Cost__c,RE_Bio_Loss__c,RE_MR_Freight_Cost__c,RE_Port_Charges_Cost__c,RE_Storage_Handling_Cost__c,RE_Recovery_Sales_Tax__c,RE_Costprice_Unit__c,RE_Job_Run_Count__c from RE_MY_CostPrice__c where createdDate= today AND Recordtype.name='Malaysia'];
        List<String> productIdList = new List<String>();
        List<String> depotIdList = new List<String>();
        if(firstcall == false){
            for(RE_MY_CostPrice__c cpData1 : costPrice){
                productIdList.add(cpData1.RE_Product_Name__c);
                depotIdList.add(cpData1.RE_Depot_Name__c);
            }
               
            Map<String,Id> productMap = new Map<String,Id>();
            Map<String,Id> regionMap = new Map<String,Id>();
            for(RE_Product__c prod: [select id,name from RE_Product__c where id IN : productIdList]){
                productMap.put(prod.Name,prod.Id);
            }
           // System.debug('productMap----'+productMap);
            for(RE_Location__c reg: [select id,name,RE_Region_Name__c from RE_Location__c where id IN : depotIdList]){
                regionMap.put(reg.RE_Region_Name__c,reg.Id);
            }
            //System.debug('regionMap----'+regionMap);
            Map<String,Double> mdtMap = new Map<String,Double>();
            for(RE_Malaysian_Formula_Table__mdt metadataMap: [select id, RE_MY_HCV_Quote_Percentage__c, RE_MY_Product__c, RE_MY_Region__c from RE_Malaysian_Formula_Table__mdt]){
                 mdtMap.put(metadataMap.RE_MY_Product__c+'-'+metadataMap.RE_MY_Region__c, metadataMap.RE_MY_HCV_Quote_Percentage__c);
            }
            //System.debug('mdtMap======='+mdtMap);
            
			Map<String,Double> finalMap= new Map<String,Double>();
            for(String st: mdtMap.keySet()){
                	String ps= st.split('-')[0];
					String ls= st.split('-')[1];
                	finalMap.put((productMap.get(ps)+'-'+regionMap.get(ls)),mdtMap.get(st));
            }
           // System.debug('finalMap====='+finalMap);
            for(RE_MY_CostPrice__c cpData : costPrice){
			if(rt_map.containsKey(cpData.recordTypeID))	
            if(cpData.RE_Depot_Name__c != null && cpData.RE_Product_Name__c != null && rt_map.get(cpData.recordTypeID).getName() == 'Covamo Malaysia' && cpData.Master_Covamo__c == true)
			{
				//System.debug('test 1');
                				
                if(cpData.RE_Hydrocarbon_Value__c != null){
                    for(String mapKey: finalMap.keySet()){
                        if(mapKey == cpData.RE_Product_Name__c+'-'+cpData.RE_Depot_Name__c){
                           // System.debug('mapKey---'+finalMap.get(mapKey));
                    cpData.RE_Hydrocarbon_Value__c = (cpData.RE_Hydrocarbon_Value__c*finalMap.get(mapKey))/100;
                        }
                    }
                    
				}
				
                for(Integer i=0;i<costPriceCBU.size();i++){
                    if(costPriceCBU[i].RE_Product_Name__c == cpData.RE_Product_Name__c && costPriceCBU[i].RE_Depot_Name__c == cpData.RE_Depot_Name__c){
                        //System.debug('costPriceCBU[i].RE_Bio_Cost__c    '+costPriceCBU[i].RE_Bio_Cost__c+'    cpData   '+cpData.RE_Bio_Cost__c);
                        //System.debug('map vals----'+rt_map.get(cpData.recordTypeID));

                        cpData.RE_Costprice_Marginal_Cost__c = costPriceCBU[i].RE_Costprice_Marginal_Cost__c;
                        cpData.RE_Costprice_Laid_Down_Cost__c = costPriceCBU[i].RE_Costprice_Laid_Down_Cost__c;
                        cpData.RE_Freight_Pipeline_Charges__c = costPriceCBU[i].RE_Freight_Pipeline_Charges__c;
                        cpData.RE_Market_Premium__c = costPriceCBU[i].RE_Market_Premium__c;
                        cpData.RE_FX_Laid_Down_Cost__c = costPriceCBU[i].RE_FX_Laid_Down_Cost__c;
                        cpData.RE_Oil_Loss__c = costPriceCBU[i].RE_Oil_Loss__c;
                        cpData.RE_Breakbulk_Premium__c = costPriceCBU[i].RE_Breakbulk_Premium__c;
                        cpData.RE_Marketing_Selling_Tariff__c = costPriceCBU[i].RE_Marketing_Selling_Tariff__c;
                        cpData.RE_Mark_Up_Credit_Charge__c = costPriceCBU[i].RE_Mark_Up_Credit_Charge__c;
                        cpData.RE_Small_Lot_Premium__c = costPriceCBU[i].RE_Small_Lot_Premium__c;
                        cpData.RE_Transfer_Price_Premium__c = costPriceCBU[i].RE_Transfer_Price_Premium__c;
                        cpData.RE_Primary_Transport_Cost__c = costPriceCBU[i].RE_Primary_Transport_Cost__c;
                        cpData.RE_Bio_Cost__c = costPriceCBU[i].RE_Bio_Cost__c;
                        cpData.RE_Additive_Cost__c = costPriceCBU[i].RE_Additive_Cost__c;
                        cpData.RE_MR_Freight_Cost__c = costPriceCBU[i].RE_MR_Freight_Cost__c;
                        cpData.RE_Port_Charges_Cost__c = costPriceCBU[i].RE_Port_Charges_Cost__c;
                        cpData.RE_Storage_Handling_Cost__c = costPriceCBU[i].RE_Storage_Handling_Cost__c;
                        cpData.RE_Recovery_Sales_Tax__c = costPriceCBU[i].RE_Recovery_Sales_Tax__c;
                        cpData.RE_Costprice_Unit__c = costPriceCBU[i].RE_Costprice_Unit__c;
                        cpData.RE_Job_Run_Count__c = costPriceCBU[i].RE_Job_Run_Count__c;
                        
                    }
                }
                }
            
            }
        }
    }
}