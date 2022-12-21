public class RE_Midday_Pricing_TriggerHelper { 
    public static void onAfterShellPriceHelper(List<RE_Midday_Pricing__c> midDayPriceList, Map<Id,RE_Midday_Pricing__c> midDayPriceNewMap)
    {
        System.debug('inside trigger :'+midDayPriceNewMap);
		Map<String,RE_Midday_Pricing__c> midDayPricingMap = new Map<String,RE_Midday_Pricing__c>();	
        Map<String,RE_Midday_Pricing__c> U97midDayPricingMap = new Map<String,RE_Midday_Pricing__c>();	
		List<RE_MOA__c> moaOldList = new List<RE_MOA__c>();            						        
        
        for(RE_Midday_Pricing__c midDayvalue : [
			SELECT RE_Depot_Name__r.Name, RE_Product_Name__r.Name,RE_Product_Name__r.Re_material__c,RE_Shell_Price__c,CreatedDate,RE_IsLatest__c
			FROM RE_Midday_Pricing__c 
			WHERE ID IN: midDayPriceNewMap.KeySet()]){                 
            if(midDayvalue.RE_IsLatest__c == True && midDayvalue.RE_Shell_Price__c != null){
                if(midDayvalue.RE_Product_Name__r.Re_material__c == '400008265')
                    U97midDayPricingMap.put(midDayvalue.RE_Product_Name__r.Name,midDayvalue);
                else
					midDayPricingMap.put(middayValue.RE_Depot_Name__r.Name+'_'+middayValue.RE_Product_Name__r.Name,midDayvalue);
			}                            
        }
        system.debug('U97midDayPricingMap'+U97midDayPricingMap);
        if(!midDayPricingMap.values().isEmpty()){
			for(RE_MOA__c moaValue: [
				SELECT Id,RE_Depot_Name__r.Name,RE_Depot_Name__r.RE_Region_Name__c, RE_Product__r.Name, RE_Product__r.Re_material__c,RE_Today_s_BSP__c,RE_Remark__c, RE_Final_PSP__c, RE_Mid_Day_price_out__c
				FROM RE_MOA__c WHERE RE_IsLatest__c = True]){
                if(moaValue.RE_Product__r.Re_material__c == '400008265' && moaValue.RE_Depot_Name__r.RE_Region_Name__c == 'Peninsular' && U97midDayPricingMap.containskey(moaValue.RE_Product__r.Name)){
                	moaValue.RE_Final_PSP__c = 	U97midDayPricingMap.get(moaValue.RE_Product__r.Name).RE_Shell_Price__c; 
                    moaValue.RE_Mid_Day_price_out__c = U97midDayPricingMap.get(moaValue.RE_Product__r.Name).RE_Shell_Price__c;
                    moaOldList.add(moaValue);
                }
				else if(midDayPricingMap.containskey(moaValue.RE_Depot_Name__r.Name+'_'+moaValue.RE_Product__r.Name)) {
					moaValue.RE_Final_PSP__c = midDayPricingMap.get(moaValue.RE_Depot_Name__r.Name+'_'+moaValue.RE_Product__r.Name).RE_Shell_Price__c;	
                    moaValue.RE_Mid_Day_price_out__c = midDayPricingMap.get(moaValue.RE_Depot_Name__r.Name+'_'+moaValue.RE_Product__r.Name).RE_Shell_Price__c;	
                    moaOldList.add(moaValue);
				} 
			}
		}
        
        if(!moaOldList.isEmpty()){
        	try{          
                update moaOldList;
        	}
            catch(Exception ex) {
                System.debug('Error on updating record in RE_MOA__c');
            }  
        }        	        
	}
}