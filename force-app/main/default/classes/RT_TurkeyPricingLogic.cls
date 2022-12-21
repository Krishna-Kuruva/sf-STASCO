public class RT_TurkeyPricingLogic {
    
    public static List<RT_Util.priceWrapper> calculateDailyPrice(List<RT_Util.priceWrapper> priceWrap)
    {
        System.debug('got = ' + priceWrap.size());
        
		List<RT_Util.priceWrapper> returnWrap = new List<RT_Util.priceWrapper>();
        map<String,RT_Util.priceWrapper> returnMap = new map<String,RT_Util.priceWrapper>();
        
        map<String,map<String,RT_Util.priceWrapper>> priceMap = new map<String,map<String,RT_Util.priceWrapper>>();
        
        List<ID> soldToList = new List<ID>();
        List<ID> refineryList = new List<ID>();
        List<ID> depotList = new List<ID>();
        List<ID> siteList = new List<ID>();
        List<ID> productList = new List<ID>();
        List<ID> subgradeList = new List<ID>();
        List<ID> gradeList = new List<ID>();
        List<ID> locList = new List<ID>();
        
        for(RT_Util.priceWrapper pw:priceWrap)
        {
            if(!soldToList.contains(pw.soldToID))
            	soldToList.add(pw.soldToID);
            if(!depotList.contains(pw.plantID))
            	depotList.add(pw.plantID);
            if(!productList.contains(pw.materialID))
            	productList.add(pw.materialID);
            if(!subgradeList.contains(pw.materialSubGradeID))
            	subgradeList.add(pw.materialSubGradeID);
            if(!gradeList.contains(pw.materialGradeID))
            	gradeList.add(pw.materialGradeID);
            
            String key1 = String.valueof(pw.soldToID) + String.valueof(pw.plantID) + String.valueof(pw.materialID);
            String key2 = pw.condType;
            
            map<String,RT_Util.priceWrapper> priceCondMap = new map<String,RT_Util.priceWrapper>();
            if(priceMap.containskey(key1))
                priceCondMap = priceMap.get(key1);
            
            priceCondMap.put(key2,pw);
            priceMap.put(key1,priceCondMap);
        }
        
        map<ID,ID> accSiteMap = getAccountSiteMap(soldToList);
        map<String,ID> plantProdRefMap = getPlantProductRefineryMap(depotList,productList);
        
        for(ID key: accSiteMap.keySet())
        {
            if(!siteList.contains(accSiteMap.get(key)))
                siteList.add(accSiteMap.get(key));
        }
        
        for(String key: plantProdRefMap.keySet())
        {
            if(!refineryList.contains(plantProdRefMap.get(key)))
                refineryList.add(plantProdRefMap.get(key));
        }
        
        List<ID> depotProdList = new List<ID>();
        depotProdList.addAll(gradeList);
        depotProdList.addAll(subgradeList);
        
        map<String,RT_Price_Book__c> refineryPriceMap = getPriceMap(refineryList,gradeList,RT_Util.refineryPriceRecTypeId);
        map<String,RT_Price_Book__c> depotPriceMap = getPriceMap(depotList,depotProdList,RT_Util.depotPriceRecTypeId);
        map<String,RT_Price_Book__c> pumpPriceMap = getPriceMap(siteList,subgradeList,RT_Util.fbsRecTypeId);
        
        locList.addAll(refineryList);
        locList.addAll(siteList);
        map<ID,RE_Location__c> locMap = getLocationMap(locList);
        
        for(RT_Util.priceWrapper pw:priceWrap){
            Boolean includePrice = true;
            String priceMapKey = String.valueof(pw.soldToID) + String.valueof(pw.plantID) + String.valueof(pw.materialID);
            
            System.debug('Key= ' + String.valueof(pw.soldToID) 
                         + '_' + String.valueof(pw.plantID) 
                         + '_' + String.valueof(pw.materialID)
                         + '_' + pw.condType
                         + '_' + pw.keyVal);
            
            // Get All Price starts
            if(depotPriceMap.containsKey(pw.plantID + '_' + pw.materialGradeID) && includePrice)
                pw.definedDepotPrice = depotPriceMap.get(pw.plantID + '_' + pw.materialGradeID).RT_Depot_Price__c;
            else if(depotPriceMap.containsKey(pw.plantID + '_' + pw.materialSubGradeID) && includePrice)
                pw.definedDepotPrice = depotPriceMap.get(pw.plantID + '_' + pw.materialSubGradeID).RT_Depot_Price__c;
            else
                includePrice = false;
               
            if(includePrice)
                	System.debug('Found definedDepotPrice =' + pw.definedDepotPrice);
            
            if(plantProdRefMap.containsKey(pw.plantID + '_' + pw.materialID) && includePrice)
            {
                pw.refineryID = plantProdRefMap.get(pw.plantID + '_' + pw.materialID);
                if(locMap.containsKey(pw.refineryID) && includePrice)
                {
                    pw.refineryName = locMap.get(pw.refineryID).name;
                    pw.refineryCode = locMap.get(pw.refineryID).RE_Location_Code__c;
                }
                else
                	includePrice = false;
                
                if(includePrice)
                	System.debug('Found Refinery = ' + pw.refineryID);
                
            	if(refineryPriceMap.containsKey(pw.refineryID + '_' + pw.materialGradeID) && includePrice)
            		pw.definedRefineryPrice = refineryPriceMap.get(pw.refineryID + '_' + pw.materialGradeID).RT_Sales_Price_Excluding_KDV__c;
                else
                	includePrice = false;
            }
            else
                includePrice = false;
            
            if(includePrice)
                	System.debug('Found definedRefineryPrice=' + pw.definedRefineryPrice);
            
            if(accSiteMap.containsKey(pw.soldToID) && includePrice)
            {
                pw.siteID = accSiteMap.get(pw.soldToID);
                if(locMap.containsKey(pw.siteID) && includePrice)
                {
                    pw.siteName = locMap.get(pw.siteID).name;
                    pw.siteCode = locMap.get(pw.siteID).RE_Location_Code__c;
                }
                else
                	includePrice = false;
                
                if(includePrice)
                	System.debug('Found Site = ' + pw.siteID);
                
            	String priceKey = pw.siteID + '_' + pw.materialSubGradeID;
            	if(pumpPriceMap.containsKey(priceKey) && includePrice)
                {
                    pw.emra = 1000 * pumpPriceMap.get(priceKey).RT_EMRAFEE__c;
            		pw.sct = 1000 * pumpPriceMap.get(priceKey).RT_SCT__c;
                    pw.depotPrice = 1000 * pumpPriceMap.get(priceKey).RT_NET_SIP_EXP__c;
                    pw.depotPrice_woTax = pw.depotPrice - pw.emra - pw.sct;
                    pw.refineryPrice_woTax= 1000 * pumpPriceMap.get(priceKey).RT_MP__c;
                    pw.refineryPrice = pw.refineryPrice_woTax + pw.emra + pw.sct;
                    pw.pumpPrice = (1000 * pumpPriceMap.get(priceKey).RT_CRP__c) / 1.18;
                    pw.pumpPrice_woTax = pw.pumpPrice - pw.emra - pw.sct;
                    
                    pw.depotRefineryDiff = pw.depotPrice - pw.refineryPrice;
            		pw.pumpRefineryDiff = pw.pumpPrice - pw.refineryPrice;
                }
                else
                	includePrice = false;
            }
            else
                includePrice = false;
            
            if(includePrice)
                	System.debug('Found pumpPrice');
            
            // Get All Price ends
            
           if(includePrice) 
           {
				// Calculate Shell Margin starts
				
               System.debug('Found amount='+pw.amount);
               
               	if(pw.pumpRefineryDiff != 0)
					pw.shellMargin=(pw.depotRefineryDiff/pw.pumpRefineryDiff)*100;
               
				System.debug('Found shellMargin='+pw.shellMargin);
				// Calculate Shell Margin ends
				
				//Find Condition Type starts
				Boolean isYP04 = (pw.condType==RT_Util.yp04Condition) ? true : false;
				Boolean isYD05 = (pw.condType==RT_Util.yd05Condition) ? true : false;
				Boolean isYD07 = (pw.condType == RT_Util.yd07Condition) ? true : false;
                Boolean isYD06 = (pw.condType == RT_Util.yd06Condition) ? true : false;
				//Find Condition Type ends
				
				//Find Discount Type starts
				if(isYP04)
				{
					if(pw.amount<1.5 && pw.amount>1)
						pw.discountType = 'YP04 - Percentage';
					else if (pw.amount==0.01)
						pw.discountType = 'YP04 - Tupras Flat';
					else
						pw.discountType = 'YP04 - Unit';
				}
				else if(isYD05)
					pw.discountType = 'YD05 - Percentage';
				else if(isYD07)
					pw.discountType = 'YD07 - Unit';
               else if(isYD06)
					pw.discountType = 'YD06 - Unit';
				else
					pw.discountType = 'No Discount';
				//Find Discount Type ends
				
				// Calculate CF Margin starts
				Decimal cfPrice = 0;
				Decimal cfMargin = 0;
				
				if(isYP04)
				{
					if(pw.discountType == 'YP04 - Percentage')
						cfPrice = ( pw.amount * ( pw.definedRefineryPrice - pw.emra ) ) + pw.emra;
					else if(pw.discountType == 'YP04 - Unit')
						cfPrice = pw.definedRefineryPrice + pw.amount;
					else if(pw.discountType == 'YP04 - Tupras Flat')
						cfPrice = pw.definedRefineryPrice;
					else
						cfPrice = 0;
				}
				
				if(isYD05 || isYD07 || isYD06)
				{
					if(isYD05)
						cfPrice = ((100 + pw.amount) / 100) * ( pw.definedDepotPrice - pw.emra );
					if (isYD07)
						cfPrice = pw.amount + pw.definedDepotPrice;
                    if (isYD06)
                    {
                        if(priceMap.containskey(priceMapKey))
                        {
                            
                            if(priceMap.get(priceMapKey).containskey(RT_Util.yd07Condition))
                            {
                                pw.yd06Amount = pw.amount + priceMap.get(priceMapKey).get(RT_Util.yd07Condition).amount;
                                pw.discountType = 'YD07_YD06 - Unit';
                    			pw.hideYd06Amount = false;
                                pw.hideTotalPostDiscount = true;
                                pw.hideCfMarginAfterDiscount = true;
                                pw.hideAdjustment = true;
                                
                                priceMap.get(priceMapKey).get(RT_Util.yd07Condition).yd06Amount = pw.yd06Amount;
                                priceMap.get(priceMapKey).get(RT_Util.yd07Condition).hideYd06Amount = false;
                            }
                            else
                                pw.yd06Amount = pw.amount;
                        }
                        
                        cfPrice = pw.yd06Amount + pw.definedDepotPrice;
                    }
				}

               if(cfPrice>0 && pw.pumpRefineryDiff!=0)
                   cfMargin= (cfPrice-pw.refineryPrice) / pw.pumpRefineryDiff;
               
                System.debug('Found cfPrice='+cfPrice);
               	System.debug('Found cfMargin='+cfMargin);
               
				pw.cfMargin= cfMargin*100;
               
				// Calculate CF Margin ends
			
               
				//Find Best Amount starts
				pw.suggestedAmount = 0;
               	Decimal marginPercentage = (RT_Util.marginPercentage)/100;
               
				if(pw.cfMargin.setScale(2) > RT_Util.marginPercentage.setScale(2))
				{
                    pw.isMatch = false;
                    Decimal tempCfPrice = 0;
                    
					if(isYP04)
                    {
                        tempCfPrice = (marginPercentage * pw.pumpRefineryDiff) + pw.refineryPrice;
                        
                        if(pw.discountType == 'YP04 - Percentage')
                            pw.suggestedAmount = (tempCfPrice.setScale(2) - pw.emra) / ( pw.definedRefineryPrice - pw.emra );
                        else if(pw.discountType == 'YP04 - Unit')
                            pw.suggestedAmount = tempCfPrice.setScale(2) - pw.definedRefineryPrice;
                        else if(pw.discountType == 'YP04 - Tupras Flat')
                            pw.suggestedAmount = 0;
                        else 
                            pw.suggestedAmount = 0;
                    }
                    
                    if(isYD05)
                    {
                        tempCfPrice = (marginPercentage * pw.pumpRefineryDiff) + pw.refineryPrice;
                        pw.suggestedAmount = (( tempCfPrice.setScale(2) / ( pw.definedDepotPrice - pw.emra )) * 100) - 100;
                    }
                    
                    if (isYD07)
                    {
                        tempCfPrice =  (marginPercentage * pw.pumpRefineryDiff) + pw.refineryPrice;
                        pw.suggestedAmount =  tempCfPrice.setScale(2) - pw.definedDepotPrice;
                    }
                    
                    if (isYD06)
                    {
                        tempCfPrice =  (marginPercentage * pw.pumpRefineryDiff) + pw.refineryPrice;
                        pw.suggestedAmount = tempCfPrice.setScale(2) - pw.definedDepotPrice;
                        
                        if(priceMap.get(priceMapKey).containskey(RT_Util.yd07Condition))
                            pw.suggestedAmount -= priceMap.get(priceMapKey).get(RT_Util.yd07Condition).amount;
                    }
                    
                    System.debug('suggestedAmount =' + pw.suggestedAmount);
				}
				//Find Best Amount Ends
				  
               
				// Calculate Total Discount starts
               
				if(pw.importRatio>0)
				{
					Decimal discount = 0;
					Decimal marginAfterDiscount = 0;
					Decimal finalDiscount = 0;
					
					if(isYP04)
					{
						if(pw.discountType == 'YP04 - Unit' || pw.discountType == 'YP04 - Tupras Flat')
						{
							discount = pw.adjustment*pw.importRatio;
							
							if(discount != 0 && pw.pumpRefineryDiff!=0)
								marginAfterDiscount = (cfPrice+discount-pw.refineryPrice)/pw.pumpRefineryDiff;
							
							if(marginAfterDiscount>marginPercentage)
								finalDiscount = marginPercentage*pw.pumpRefineryDiff-pw.amount;
							else
								finalDiscount = discount;
						}
						
						if(pw.discountType == 'YP04 - Percentage')				
						{
                            if((pw.definedRefineryPrice-pw.emra-pw.sct)!=0)
								discount=pw.adjustment*pw.importRatio/(pw.definedRefineryPrice-pw.emra);
							
							if(discount!=0 && pw.pumpRefineryDiff!=0)
								marginAfterDiscount =((((discount+pw.amount)*(pw.definedRefineryPrice-pw.emra))+pw.emra)-pw.refineryPrice)/pw.pumpRefineryDiff;
							
							if(marginAfterDiscount>marginPercentage)
								finalDiscount=(((marginPercentage*pw.pumpRefineryDiff)+pw.refineryPrice-pw.emra)/(pw.definedRefineryPrice-pw.emra))-pw.amount;
							else
								finalDiscount=discount;
						}
                        pw.totalPostDiscount= finalDiscount + pw.amount;
					}
					
					if(isYD05)
					{
						discount=(pw.adjustment*pw.importRatio)/(pw.definedDepotPrice-pw.emra-pw.sct);
						
						if(pw.pumpRefineryDiff!=0)
							marginAfterDiscount=(((1+(discount+(pw.amount/100)))*(pw.definedDepotPrice-pw.emra-pw.sct))-pw.refineryPrice_woTax)/pw.pumpRefineryDiff;
						
						if(marginAfterDiscount>marginPercentage)
							finalDiscount=((((marginPercentage*pw.pumpRefineryDiff)+pw.refineryPrice-pw.emra)/(pw.definedDepotPrice-pw.emra))-1)*100-pw.amount;
						else
						   finalDiscount=discount;
                        
                        pw.totalPostDiscount= finalDiscount + pw.amount;
					}
                    
                    if(isYD06)
					{
                        discount=pw.adjustment*pw.importRatio;
							
						if(discount!=0 && pw.pumpRefineryDiff!=0)
							marginAfterDiscount=(cfPrice+discount-pw.refineryPrice)/pw.pumpRefineryDiff;

						if(marginAfterDiscount>marginPercentage)
							finalDiscount=marginPercentage*pw.pumpRefineryDiff+pw.refineryPrice-pw.definedDepotPrice-pw.amount;
						else
						   finalDiscount=discount;
                        
                        pw.totalPostDiscount= finalDiscount + pw.yd06Amount;
					}
                    
                    if(isYD07)
					{
						discount=pw.adjustment*pw.importRatio;
                        
						if(discount!=0 && pw.pumpRefineryDiff!=0)
							marginAfterDiscount=(cfPrice+discount-pw.refineryPrice)/pw.pumpRefineryDiff;

						if(marginAfterDiscount>marginPercentage)
							finalDiscount=marginPercentage*pw.pumpRefineryDiff+pw.refineryPrice-pw.definedDepotPrice-pw.amount;
						else
						   finalDiscount=discount;
                        
                        pw.totalPostDiscount= finalDiscount + pw.amount;
					}
                    
                    System.debug('discount='+discount);
                    System.debug('marginAfterDiscount='+marginAfterDiscount);
                    System.debug('finalDiscount='+finalDiscount);
                    System.debug('Found totalPostDiscount='+pw.totalPostDiscount);
                    
                    //Find Margin Post Discount
                    Decimal cfPrice_postDiscount = 0;
					Decimal cfMargin_postDiscount = 0;
                    
                    if(isYP04)
                    {
                        if(pw.discountType == 'YP04 - Percentage')
                            cfPrice_postDiscount = ( pw.totalPostDiscount * ( pw.definedRefineryPrice - pw.emra ) ) + pw.emra;
                        else if(pw.discountType == 'YP04 - Unit')
                            cfPrice_postDiscount = pw.definedRefineryPrice + pw.totalPostDiscount;
                        else if(pw.discountType == 'YP04 - Tupras Flat')
                            cfPrice_postDiscount = pw.definedRefineryPrice + pw.totalPostDiscount;
                        else
                            cfPrice_postDiscount = 0;
                    }
                        
                    if(isYD05)
                        cfPrice_postDiscount = ((100 + pw.totalPostDiscount) / 100) * ( pw.definedDepotPrice - pw.emra );
                    if (isYD07)
                        cfPrice_postDiscount = pw.totalPostDiscount + pw.definedDepotPrice;
                    if (isYD06)
                        cfPrice_postDiscount = pw.totalPostDiscount + pw.definedDepotPrice;
                        
                    if(cfPrice_postDiscount>0 && pw.pumpRefineryDiff!=0)
                        cfMargin_postDiscount= (cfPrice_postDiscount-pw.refineryPrice) / pw.pumpRefineryDiff;
                    
                    pw.cfMarginAfterDiscount = cfMargin_postDiscount*100;
                    
				}
				// Calculate Total Discount ends
				
               if(pw.materialGrade != 'AGO')
               {
                   pw.hideAdjustment = true;
                   pw.hideYd06Amount = true;
                   pw.hideTotalPostDiscount = true;
                   pw.hideCfMarginAfterDiscount = true;
               }
				//returnWrap.add(pw);
               	returnMap.put(pw.keyVal + pw.condType,pw);
                
                if(priceMap.containskey(priceMapKey))
                {
                    if(priceMap.get(priceMapKey).containskey(pw.condType))
                        priceMap.get(priceMapKey).put(pw.condType,pw);
                }
            }
        }
        
        System.debug('return = ' + returnMap.size());
        
        if(returnMap.size()>0)
            returnWrap.addAll(returnMap.values());
        
        return returnWrap;
    }
    
    public static map<ID,ID> getAccountSiteMap(List<ID> accounList)
    {
		map<ID,ID> accSiteMap = new map<ID,ID>();

        RT_Setting__c[] siteAccList = [select id, Site_Name__c, RT_Account__c from RT_Setting__c 
                                      where RT_Account__c in :accounList
                                     	and Country__c = :RT_Util.countryName and Active__c = true
                                       	and Site_Name__r.RT_Active__c = true and RT_Account__r.RT_Active__c = true
                                      	and recordtypeid= : RT_Util.accountRocSettRecTypeId];
        
        for(RT_Setting__c sett : siteAccList)
            accSiteMap.put(sett.RT_Account__c,sett.Site_Name__c);
        
		return accSiteMap;       
    }

    public static map<String,ID> getPlantProductRefineryMap(List<ID> plantList, List<ID> productList)
    {
        map<String,ID> plantProdRefMap = new map<String,ID>();
        
        RE_Route_Backbone__c[] plantProdRefList = [select id,RE_Source_Name__c,RE_Depot_Name__c,RE_Product_Name__c from RE_Route_Backbone__c
                                                  where RE_Depot_Name__c in :plantList and RE_Product_Name__c in :productList
                                                  and RT_Active__c = true and RE_Depot_Name__r.RT_Active__c = true
                                                  and RE_Product_Name__r.Active__c = true and RE_Source_Name__r.RT_Active__c = true
                                                  and recordtypeId = :RT_Util.routeRecTypeId];
        
        for(RE_Route_Backbone__c route:plantProdRefList)
            plantProdRefMap.put(route.RE_Depot_Name__c + '_' + route.RE_Product_Name__c, route.RE_Source_Name__c);
            
        return plantProdRefMap;
    }
    
    public static map<String,RT_Price_Book__c> getPriceMap(List<ID> locationList, List<ID> productList, ID recType)
    {
        map<String,RT_Price_Book__c> priceMap = new map<String,RT_Price_Book__c>();
        
        RT_Price_Book__c[] priceList = [select id, RT_Location__c, RT_Product__c 
                                        ,RT_CRP__c, RT_Cur__c, RT_Depot_Price__c, RT_Effective_Date__c, RT_EMRAFEE__c
                                        ,RT_Income_Share__c, RT_KDV__c, RT_MP__c, RT_NET_SIP__c, RT_NET_SIP_EXP__c
                                        ,RT_Refinery_Sale_Price__c, RT_Sale_Price_Including_KDV__c, RT_Sales_Price_Excluding_KDV__c
                                        ,RT_SCT__c, RT_Special_Consumption_Tax__c
                                        from RT_Price_Book__c
                                       where recordtypeid = :recType and RT_Product__c in :productList
                                       and RT_Location__c in :locationList
                                       and RT_Product__r.Active__c = true and RT_Location__r.RT_Active__c = true
                                       and RT_Active__c = true and RT_Effective_Date__c <= Today
                                       and RT_Country__c = :RT_Util.countryName];
        
        for(RT_Price_Book__c price : priceList)
        {
            String key = price.RT_Location__c + '_' + price.RT_Product__c;
            if(priceMap.containsKey(key))
            {
                if(price.RT_Effective_Date__c > priceMap.get(key).RT_Effective_Date__c)
                    priceMap.put(key,price);
            }
            else
            	priceMap.put(key,price);
        }
            
        return priceMap;
    }
    
    public static map<ID,RE_Location__c> getLocationMap (List<ID> locationList)
    {
        map<ID,RE_Location__c> locMap = new map<ID,RE_Location__c>();
        
        RE_Location__c[] locLst = [select id,RE_Abbreviated_Name__c,RE_Location_Code__c, Name, RT_Location_Type__c
                                   ,RT_ImportProductRatio__c,RT_Import_Terminal__c from RE_Location__c
                                  where RT_Active__c = true and recordtypeid = :RT_Util.locRecTypeId];
        
        for(RE_Location__c loc : locLst)
            locMap.put(loc.id,loc);
        
        return locMap;
    }
}