public class RE_ProductTriggerHelper {
    public static void onAfterMC0Dipupdate(List<RE_Product__c> mc0List){
        RE_SOQLController sqldata = new RE_SOQLController();
        List<RE_SG_CostPrice__c> costpricelist = [
            SELECT Id,RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c,RE_Location_Name__r.Name,RE_Product_Name__r.Name,RE_MC0_Diff__c,RE_IsMidday__c,RE_FX_Marginal_Cost__c
            FROM RE_SG_CostPrice__c 
            WHERE RE_Pricing_Date__c = Today            
            AND RE_IsLatest__c = True            
        	AND RE_Product_Name__r.Name = 'IGO 10ppm'
        ];
        System.debug('@@@costpricelist'+costpricelist);
        for(RE_SG_CostPrice__c costData : costpricelist){
            System.debug('@@@costData'+costData);
            for(RE_Product__c igoprod : mc0List){
                if(costData.RE_IsMidday__c == False){
                    if(igoprod.RE_Morning_MC0_Value__c != null && 
						   igoprod.RE_Morning_MC0_Valid_From__c <= System.today() && 
						   igoprod.RE_Morning_MC0_Valid_To__c >= System.today()){
							costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c - igoprod.RE_Morning_MC0_Value__c * sqldata.fetchSGFxData() * 100/Double.valueOf(System.Label.RE_BBL_to_LTR);
						}	
                    else{
                        costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c;
                    }        
                }
                else{
                    if(igoprod.RE_Midday_MC0_Value__c != null && 
						   igoprod.RE_Midday_MC0_Valid_From__c <= System.today() && 
						   igoprod.RE_Midday_MC0_Valid_To__c >= System.today()){
							costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c - igoprod.RE_Midday_MC0_Value__c * sqldata.fetchSGFxDataforMidDay() * 100/Double.valueOf(System.Label.RE_BBL_to_LTR);
						}	
                    else{
                        costData.RE_MC0_Diff__c = costData.RE_FX_Marginal_Cost__c;
                    }  
                }
            }    
        }
        try{
            if(!costpricelist.isEmpty())
            	update costpricelist;
        }
        catch(Exception ex){
            System.debug('Failed to update RE_SG_CostPrice__c');
        }
    }
    public static void updateTHDepoPricing(List<RE_Product__c> prodList){
        
        Map<Id,RE_Product__c> productMap =  new Map<Id,RE_Product__c>();
        List<RE_Depot_Pricing_Backbone__c> depoDatasets = new List<RE_Depot_Pricing_Backbone__c>();
        try{
            for(RE_Product__c prd :prodList){
                if(prd.recordtype.Name == 'Thailand'){
                    productMap.put(prd.Id,prd);
                }
            }
            for(RE_Depot_Pricing_Backbone__c depos:[SELECT Id,RE_TH_Oil_Loss_Percent__c,TH_15_to_30_factor__c,RE_Product_Name__c FROM RE_Depot_Pricing_Backbone__c WHERE Recordtype.Name='Thailand' AND RE_Product_Name__c IN: productMap.keyset()]){
                if(productMap.containsKey(depos.RE_Product_Name__c)){
                    RE_Product__c pr = productMap.get(depos.RE_Product_Name__c);
                    Double TP_HCV1 = 0.00;
                    Double TP_HCV2 = 0.00;
                    String prodVals = pr.RE_TH_TP_Premium__c!=null ? pr.RE_TH_TP_Premium__c : '0.00';
               		TP_HCV1 = (prodVals != 'EX REF PRICE' && prodVals != 'Actual Purchasing Price' && prodVals != 'Slow moving Price') ? (Double.valueOf(prodVals)) : (pr.RE_TH_TP_PremiumHCV__c != null ? pr.RE_TH_TP_PremiumHCV__c : 0.00);
					TP_HCV2	=	pr.RE_TH_TP_PremiumHCV2__c != null ? pr.RE_TH_TP_PremiumHCV2__c : 0.00;
                    depoDatasets.add(new RE_Depot_Pricing_Backbone__c(Id=depos.Id,RE_TH_Oil_Loss_Percent__c = pr.RE_TH_Oil_Loss_Percent__c,TH_15_to_30_factor__c=pr.TH_15_to_30_factor__c,RE_TH_HCV_Quote1_Percent__c=pr.RE_TH_HCV_Quote1_Percent__c,RE_TH_HCV_Quote2_Percent__c=pr.RE_TH_HCV_Quote2_Percent__c,
                                                                     RE_TH_TP_Premium_HCV1__c =TP_HCV1 , TP_Premium_HCV1_Unit__c=pr.TP_Premium_Unit__c,RE_TH_TP_Premium_HCV2__c=TP_HCV2,TP_Premium_HCV2_Unit__c=pr.TH_TP_PremiumHCV2_UNIT__c));
                }
            }
            
            Database.Update(depoDatasets);
        }
        catch(Exception ex){
            System.debug('Failed to update RE_Depot_Pricing_Backbone__c');
        }
    }
}