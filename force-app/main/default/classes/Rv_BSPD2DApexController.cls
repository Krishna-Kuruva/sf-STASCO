public class Rv_BSPD2DApexController {

    //START - Rahul Sharma | Date - 08-Jan-2021 : changed variables from final static to static.
    public static String igoGrade = 'IGO 50ppm';
    public static String agoGrade = 'AGO B7';
    public static String mogasGrade = 'ULG95 E5';
    public static Map<String,Decimal> gradeDensityMap = new Map<String,Decimal>{igoGrade => 0.845,
                                                                                agoGrade => 0.845,
                                                                                mogasGrade => 0.755};
    //END - Rahul Sharma | Date - 08-Jan-2021 : changed variables from final static to static.
    
    public static Date tday = System.today();
    public static Date yday = System.today() - 1;
    
    @AuraEnabled
    public static pageWrapper getPageData(String yDayInput, String tDayInput, String tranche, String salesChannel)   //Rahul Sharma | Date - 25-Nov-2020 : Added addtional tranche parameter to filter records based on tranches.
    {
        System.debug('----yDayInput---'+yDayInput);
        System.debug('----tDayInput---'+tDayInput);
        if(yDayInput != null && tDayInput !=null) {
            if (yDayInput.length() > 0)
                try {
                    yDay = Date.valueOf(yDayInput);
                } catch (Exception e) {
                    System.debug(e);
                    yday = System.today() - 1;
                }

            if (tDayInput.length() > 0)
                try {
                    tday = Date.valueOf(tDayInput);
                } catch (Exception e) {
                    System.debug(e);
                    tday = System.today();
                }
        }
        //START - Rahul Sharma | Date - 08-Jan-2021 : Added logic to replace MOGAS grade from 'ULG95 E5' to 'ULG95 E10' if sales channel is Germany(DE).
        if(!String.isEmpty(salesChannel)){
            salesChannel += '%';
            if(salesChannel.startsWithIgnoreCase('DE')){
                gradeDensityMap.remove(mogasGrade);
                mogasGrade = 'ULG95 E10';
                gradeDensityMap.put(mogasGrade, 0.755);
            }
        }
        //END - Rahul Sharma | Date - 08-Jan-2021 : Added logic to replace MOGAS grade from 'ULG95 E5' to 'ULG95 E10' if sales channel is Germany(DE).
        pageWrapper returnPageWrapper = new pageWrapper();
        Boolean responseStatus = true;
        String errMsg = '';
    	List<deltaPriceWrapper> returnPriceDeltaLst = new List<deltaPriceWrapper>();
        
        map<String,priceWrapper> priceTodayMap = new map<String,priceWrapper>();
        map<String,priceWrapper> priceYesterdayMap = new map<String,priceWrapper>();
        map<String,priceWrapper> priceDeltaMap = new map<String,priceWrapper>();
        //START - Rahul Sharma | Date - 25-Nov-2020 : Updated query to filter records based on tranche.
        Backbone_Trends__c[] backTrendLst = [SELECT Id, 
                                                    CreatedDate,
                                                    Daily_BSP_Trends__r.Location_Name__r.name,
                                                    Daily_BSP_Trends__r.Plant_Code__c,
                                                    Daily_BSP_Trends__r.Sales_Org__c, 
                                                    Daily_BSP_Trends__r.Material__r.Commodity_Grade_L2__c,
                                                    Daily_BSP_Trends__r.Calcualated_BSP__c, 
                                                    Route_Utilization__c,HCV__c, Bio_Cost__c, 
                                                    CO_Steer__c, 
                                                    FreightToDepot__c, 
                                                    Daily_BSP_Trends__r.Depot_Steer__c, 
                                                    Daily_BSP_Trends__r.Min_Margin__c FROM Backbone_Trends__c WHERE CreatedDate >= :yday AND 
                                                                                                                    CreatedDate<= :tday + 1 AND 
                                                                                                                    Daily_BSP_Trends__r.Material__r.Commodity_Grade_L2__c in :gradeDensityMap.keySet() AND 
                                                                                                                    Route_Utilization__c != 0 AND 
                                                                                                                    Daily_BSP_Trends__r.Shipping_Condition__c = 10 AND
                                                                                                                    Tranche__c =: tranche AND 
                                                                                                                    Daily_BSP_Trends__r.Sales_Org__c LIKE : salesChannel ORDER BY Daily_BSP_Trends__r.Location_Name__r.name, 
                                                                                                                                                                                  Daily_BSP_Trends__r.Plant_Code__c, 
                                                                                                                                                                                  Daily_BSP_Trends__r.Sales_Org__c];
        //END - Rahul Sharma | Date - 25-Nov-2020 : Updated query to filter records based on tranche.
        System.debug('BSP Trend List: '+backTrendLst);
        System.debug('salesChannel: '+salesChannel);
        for(Backbone_Trends__c bt : backTrendLst)
        {
            String plantName = bt.Daily_BSP_Trends__r.Location_Name__r.name;
            String plantCode = bt.Daily_BSP_Trends__r.Plant_Code__c;
            String salesOrg =  bt.Daily_BSP_Trends__r.Sales_Org__c;
            String grade = bt.Daily_BSP_Trends__r.Material__r.Commodity_Grade_L2__c;
            String rowKey = plantCode + salesOrg + grade;
            Decimal density = gradeDensityMap.containsKey(grade) ? gradeDensityMap.get(grade) : 0;
            
            priceWrapper pw = new priceWrapper();
            pw.plantName = plantName;
            pw.plantCode = plantCode;
            pw.salesOrg = salesOrg;
            pw.grade = grade;

            bspWrapper bsp = new bspWrapper();
            bsp.hcv= ((((bt.Route_Utilization__c/100) * bt.HCV__c * density)*10)/10).setscale(2);
            bsp.coSteer= (((((bt.Route_Utilization__c/100) * bt.CO_Steer__c * density)*10)/10) + ((((bt.Route_Utilization__c/100) * bt.Daily_BSP_Trends__r.Depot_Steer__c * density)*10)/10)).setscale(2);
            bsp.bioSteer= ((((bt.Route_Utilization__c/100) * bt.Bio_Cost__c * density)*10)/10).setscale(2);
            bsp.freight= ((((bt.Route_Utilization__c/100) * bt.FreightToDepot__c * density)*10)/10).setscale(2);

            if(bt.CreatedDate.isSameDay(yday) && priceYesterdayMap.containsKey(rowKey))
            {
                priceWrapper pwYday = priceYesterdayMap.get(rowKey);
                if(pwYday.bspMap.containsKey(grade))
                {
                    bsp.hcv += pwYday.bspMap.get(grade).hcv;
                    bsp.coSteer += pwYday.bspMap.get(grade).coSteer;
					bsp.bioSteer += pwYday.bspMap.get(grade).bioSteer;
                    bsp.freight += pwYday.bspMap.get(grade).freight;
                }
            }
            
            if(bt.CreatedDate.isSameDay(tday) && priceTodayMap.containsKey(rowKey))
            {
                priceWrapper pwTday = priceTodayMap.get(rowKey);
                if(pwTday.bspMap.containsKey(grade))
                {
                    bsp.hcv += pwTday.bspMap.get(grade).hcv;
                    bsp.coSteer += pwTday.bspMap.get(grade).coSteer;
					bsp.bioSteer += pwTday.bspMap.get(grade).bioSteer;
                    bsp.freight += pwTday.bspMap.get(grade).freight;
                }
            }  
            pw.bspMap.put(grade,bsp);
            
            pspWrapper psp = new pspWrapper();
            psp.margin = bt.Daily_BSP_Trends__r.Min_Margin__c;
            pw.pspMap.put(grade,psp);
            
            if(bt.CreatedDate.isSameDay(yday))
                priceYesterdayMap.put(rowKey,pw);
            if(bt.CreatedDate.isSameDay(tday))
                priceTodayMap.put(rowKey,pw);
        }
        
        if(priceYesterdayMap.size()>0)
        {
            if(priceTodayMap.size()>0)
            {
                for(String key : priceTodayMap.keySet())
                {
                    priceWrapper pwTday = priceTodayMap.get(key);
                    priceWrapper pwYday = priceYesterdayMap.containsKey(key) ? priceYesterdayMap.get(key) : new priceWrapper();
                    
                    if(pwYday != null)
                    {
                        priceWrapper pwDelta = new priceWrapper();
                        pwDelta.plantName = priceTodayMap.get(key).plantName;
                        pwDelta.plantCode = priceTodayMap.get(key).plantCode;
                        pwDelta.salesOrg = priceTodayMap.get(key).salesOrg;
                        pwDelta.grade = priceTodayMap.get(key).grade;
                        
                        for(String grade : pwTday.bspMap.keyset())
                        {
                            bspWrapper bsp = new bspWrapper();
                            if(pwYday.bspMap.containsKey(grade))
                            {
                                //UAT-Testing-Changes
                                bsp.hcv = ((pwTday.bspMap.get(grade).hcv - pwYday.bspMap.get(grade).hcv)/10).setscale(2);
                                bsp.coSteer = ((pwTday.bspMap.get(grade).coSteer - pwYday.bspMap.get(grade).coSteer)/10).setscale(2);
                                bsp.bioSteer = ((pwTday.bspMap.get(grade).bioSteer - pwYday.bspMap.get(grade).bioSteer)/10).setscale(2);
                                bsp.freight = ((pwTday.bspMap.get(grade).freight - pwYday.bspMap.get(grade).freight)/10).setscale(2);
                            }
                            pwDelta.bspMap.put(grade,bsp);
                        }
                        
                        for(String grade : pwTday.pspMap.keyset())
                        {
                            pspWrapper psp = new pspWrapper();
                            if(pwYday.pspMap.containsKey(grade))
                                psp.margin = (pwTday.pspMap.get(grade).margin - pwYday.pspMap.get(grade).margin).setscale(2);//UAT-Testing-Changes
                            pwDelta.pspMap.put(grade,psp);
                        }

                        priceDeltaMap.put(key,pwDelta);
                    }
                }
                
                map<String,deltaPriceWrapper> dpwMap = new map<String,deltaPriceWrapper>();
                for(String key : priceDeltaMap.keySet())
                {
                    priceWrapper pwDelta = priceDeltaMap.get(key);
                    
                    deltaPriceWrapper dp = new deltaPriceWrapper();
                    dp.rowKey = pwDelta.plantCode + pwDelta.salesOrg;
                    dp.plantName = pwDelta.plantName;
                    dp.plantCode = pwDelta.plantCode;
                    dp.salesOrg = pwDelta.salesOrg;
                    
                    dp.deltaPrice.bspIGO = pwDelta.bspMap.containsKey(igoGrade) ? pwDelta.bspMap.get(igoGrade) : new bspWrapper();
                    dp.deltaPrice.bspAGO = pwDelta.bspMap.containsKey(agoGrade) ? pwDelta.bspMap.get(agoGrade) : new bspWrapper();
                    dp.deltaPrice.bspMOGAS = pwDelta.bspMap.containsKey(mogasGrade) ? pwDelta.bspMap.get(mogasGrade) : new bspWrapper();
                    dp.deltaPrice.pspIGO = pwDelta.pspMap.containsKey(igoGrade) ? pwDelta.pspMap.get(igoGrade) : new pspWrapper();
                    dp.deltaPrice.pspAGO = pwDelta.pspMap.containsKey(agoGrade) ? pwDelta.pspMap.get(agoGrade) : new pspWrapper();
                    dp.deltaPrice.pspMOGAS = pwDelta.pspMap.containsKey(mogasGrade) ? pwDelta.pspMap.get(mogasGrade) : new pspWrapper();
                    
                    dp.deltaPrice.totalIGO = getGradeTotal(dp.deltaPrice,igoGrade);
                    dp.deltaPrice.totalAGO = getGradeTotal(dp.deltaPrice,agoGrade);
                    dp.deltaPrice.totalMOGAS = getGradeTotal(dp.deltaPrice,mogasGrade);
                    
                    if(priceTodayMap.containskey(key))
                    {
                        priceWrapper pwTday = priceTodayMap.get(key);
                        dp.tDayPrice.bspIGO = pwTday.bspMap.containsKey(igoGrade) ? pwTday.bspMap.get(igoGrade) : new bspWrapper();
                        dp.tDayPrice.bspAGO = pwTday.bspMap.containsKey(agoGrade) ? pwTday.bspMap.get(agoGrade) : new bspWrapper();
                        dp.tDayPrice.bspMOGAS = pwTday.bspMap.containsKey(mogasGrade) ? pwTday.bspMap.get(mogasGrade) : new bspWrapper();
                        dp.tDayPrice.pspIGO = pwTday.pspMap.containsKey(igoGrade) ? pwTday.pspMap.get(igoGrade) : new pspWrapper();
                        dp.tDayPrice.pspAGO = pwTday.pspMap.containsKey(agoGrade) ? pwTday.pspMap.get(agoGrade) : new pspWrapper();
                        dp.tDayPrice.pspMOGAS = pwTday.pspMap.containsKey(mogasGrade) ? pwTday.pspMap.get(mogasGrade) : new pspWrapper();
                        
                        dp.tDayPrice.totalIGO = getGradeTotal(dp.tDayPrice,igoGrade);
                        dp.tDayPrice.totalAGO = getGradeTotal(dp.tDayPrice,agoGrade);
                        dp.tDayPrice.totalMOGAS = getGradeTotal(dp.tDayPrice,mogasGrade);
                    }
                    
                    if(priceYesterdayMap.containskey(key))
                    {
                        priceWrapper pwYday = priceYesterdayMap.get(key);
                        dp.yDayPrice.bspIGO = pwYday.bspMap.containsKey(igoGrade) ? pwYday.bspMap.get(igoGrade) : new bspWrapper();
                        dp.yDayPrice.bspAGO = pwYday.bspMap.containsKey(agoGrade) ? pwYday.bspMap.get(agoGrade) : new bspWrapper();
                        dp.yDayPrice.bspMOGAS = pwYday.bspMap.containsKey(mogasGrade) ? pwYday.bspMap.get(mogasGrade) : new bspWrapper();
                        dp.yDayPrice.pspIGO = pwYday.pspMap.containsKey(igoGrade) ? pwYday.pspMap.get(igoGrade) : new pspWrapper();
                        dp.yDayPrice.pspAGO = pwYday.pspMap.containsKey(agoGrade) ? pwYday.pspMap.get(agoGrade) : new pspWrapper();
                        dp.yDayPrice.pspMOGAS = pwYday.pspMap.containsKey(mogasGrade) ? pwYday.pspMap.get(mogasGrade) : new pspWrapper();
                        
                        dp.yDayPrice.totalIGO = getGradeTotal(dp.yDayPrice,igoGrade);
                        dp.yDayPrice.totalAGO = getGradeTotal(dp.yDayPrice,agoGrade);
                        dp.yDayPrice.totalMOGAS = getGradeTotal(dp.yDayPrice,mogasGrade);
                    }
                    
                    if(dpwMap.containskey(dp.rowKey))
                    {
                        deltaPriceWrapper dpExist = dpwMap.get(dp.rowKey);
                        
                        if(pwDelta.grade.equalsIgnoreCase(igoGrade))
                        {
                            dpExist.deltaPrice.bspIGO = dp.deltaPrice.bspIGO;
                            dpExist.deltaPrice.pspIGO = dp.deltaPrice.pspIGO;
                            dpExist.deltaPrice.totalIGO = dp.deltaPrice.totalIGO;
                            
                            if(priceTodayMap.containskey(key))
                            {
                                priceWrapper pwTday = priceTodayMap.get(key);
                                dpExist.tDayPrice.bspIGO = dp.tDayPrice.bspIGO;
                                dpExist.tDayPrice.pspIGO = dp.tDayPrice.pspIGO;
                                dpExist.tDayPrice.totalIGO = dp.tDayPrice.totalIGO;
                            }
                            
                            if(priceYesterdayMap.containskey(key))
                            {
                                priceWrapper pwYday = priceYesterdayMap.get(key);
                                dpExist.yDayPrice.bspIGO = dp.yDayPrice.bspIGO;
                                dpExist.yDayPrice.pspIGO = dp.yDayPrice.pspIGO;
                                dpExist.yDayPrice.totalIGO = dp.yDayPrice.totalIGO;
                            }
                        }
                        if(pwDelta.grade.equalsIgnoreCase(agoGrade))
                        {
                            dpExist.deltaPrice.bspAGO = dp.deltaPrice.bspAGO;
                            dpExist.deltaPrice.pspAGO = dp.deltaPrice.pspAGO;
                            dpExist.deltaPrice.totalAGO = dp.deltaPrice.totalAGO;
                            
                            if(priceTodayMap.containskey(key))
                            {
                                priceWrapper pwTday = priceTodayMap.get(key);
                                dpExist.tDayPrice.bspAGO = dp.tDayPrice.bspAGO;
                                dpExist.tDayPrice.pspAGO = dp.tDayPrice.pspAGO;
                                dpExist.tDayPrice.totalAGO = dp.tDayPrice.totalAGO;
                            }
                            
                            if(priceYesterdayMap.containskey(key))
                            {
                                priceWrapper pwYday = priceYesterdayMap.get(key);
                                dpExist.yDayPrice.bspAGO = dp.yDayPrice.bspAGO;
                                dpExist.yDayPrice.pspAGO = dp.yDayPrice.pspAGO;
                                dpExist.yDayPrice.totalAGO = dp.yDayPrice.totalAGO;
                            }
                        }
                        if(pwDelta.grade.equalsIgnoreCase(mogasGrade))
                        {
                            dpExist.deltaPrice.bspMOGAS = dp.deltaPrice.bspMOGAS;
                            dpExist.deltaPrice.pspMOGAS = dp.deltaPrice.pspMOGAS;
                            dpExist.deltaPrice.totalMOGAS = dp.deltaPrice.totalMOGAS;

                            if(priceTodayMap.containskey(key))
                            {
                                priceWrapper pwTday = priceTodayMap.get(key);
                                dpExist.tDayPrice.bspMOGAS = dp.tDayPrice.bspMOGAS;
                                dpExist.tDayPrice.pspMOGAS = dp.tDayPrice.pspMOGAS;
                                dpExist.tDayPrice.totalMOGAS = dp.tDayPrice.totalMOGAS;
                            }
                            
                            if(priceYesterdayMap.containskey(key))
                            {
                                priceWrapper pwYday = priceYesterdayMap.get(key);
                                dpExist.yDayPrice.bspMOGAS = dp.yDayPrice.bspMOGAS;
                                dpExist.yDayPrice.pspMOGAS = dp.yDayPrice.pspMOGAS;
                                dpExist.yDayPrice.totalMOGAS = dp.yDayPrice.totalMOGAS;
                            }
                        }
                        dpwMap.put(dp.rowKey,dpExist);
                    }
                    else
                      dpwMap.put(dp.rowKey,dp);
                }
                
                returnPriceDeltaLst.addAll(dpwMap.values());
            }
            else
            {
                responseStatus = false;
				errMsg = 'Unable to find Daily BSP Trends data for Day 2';
            }
        }
        else
        {
            responseStatus = false;
			errMsg = 'Unable to find Daily BSP Trends data for Day 1';
        }
        system.debug('----------'+returnPriceDeltaLst);
        returnPageWrapper.priceTable = returnPriceDeltaLst;
        returnPageWrapper.responseStatus = responseStatus;
        returnPageWrapper.error = errMsg;
        
        return returnPageWrapper;
    }
    
    static Double getGradeTotal(gradePriceWrapper gpw, String grade)
    {
        Double returnTotal = 0.00;
        
        if(grade.equalsIgnoreCase(igoGrade))
        {
            returnTotal = gpw.totalIGO;
            returnTotal += gpw.bspIGO.hcv 
                		+ gpw.bspIGO.coSteer 
                        + gpw.bspIGO.bioSteer 
                        + gpw.bspIGO.freight
                        + gpw.pspIGO.margin;
        }
        
        if(grade.equalsIgnoreCase(agoGrade))
        {
            returnTotal = gpw.totalAGO;
            returnTotal += gpw.bspAGO.hcv 
                		+ gpw.bspAGO.coSteer 
                        + gpw.bspAGO.bioSteer 
                        + gpw.bspAGO.freight
                        + gpw.pspAGO.margin;
        }
        
        if(grade.equalsIgnoreCase(mogasGrade))
        {
            returnTotal = gpw.totalMOGAS;
            returnTotal += gpw.bspMOGAS.hcv 
                		+ gpw.bspMOGAS.coSteer 
                        + gpw.bspMOGAS.bioSteer 
                        + gpw.bspMOGAS.freight
                        + gpw.pspMOGAS.margin;
        }
        
        return returnTotal;
    }
    
    public class bspWrapper
    {
        @AuraEnabled
        public Decimal hcv = 0;
        @AuraEnabled
        public Decimal coSteer = 0;
        @AuraEnabled
        public Decimal bioSteer = 0;
        @AuraEnabled
        public Decimal freight = 0;
    }
    
    public class pspWrapper
    {
        @AuraEnabled
        public Decimal margin = 0;
    }
    
    public class priceWrapper
    {
        public String plantName;
        public String plantCode;
        public String salesOrg;
        public String grade;
        public map<String,bspWrapper> bspMap = new map<String,bspWrapper>();
        public map<String,pspWrapper> pspMap = new map<String,pspWrapper>();
    }
    
    public class gradePriceWrapper
    {
        @AuraEnabled
        public bspWrapper bspIGO;
        @AuraEnabled
        public bspWrapper bspAGO;
        @AuraEnabled
        public bspWrapper bspMOGAS;
        @AuraEnabled
        public pspWrapper pspIGO;
        @AuraEnabled
        public pspWrapper pspAGO;
        @AuraEnabled
        public pspWrapper pspMOGAS;
        @AuraEnabled
        public Decimal totalIGO = 0;
        @AuraEnabled
        public Decimal totalAGO = 0;
        @AuraEnabled
        public Decimal totalMOGAS = 0;
    }
    
    public class deltaPriceWrapper
    {
        @AuraEnabled
        public String rowKey;
        @AuraEnabled
        public String plantName;
        @AuraEnabled
        public String plantCode;
        @AuraEnabled
        public String salesOrg;
        @AuraEnabled
        public gradePriceWrapper deltaPrice = new gradePriceWrapper();
        @AuraEnabled
        public gradePriceWrapper tDayPrice = new gradePriceWrapper();
        @AuraEnabled
        public gradePriceWrapper yDayPrice = new gradePriceWrapper();
    }
    
    public class pageWrapper
    {
        @AuraEnabled
        public List<deltaPriceWrapper> priceTable;
        @AuraEnabled
        public Boolean responseStatus;
        @AuraEnabled
        public String error;
    }
}