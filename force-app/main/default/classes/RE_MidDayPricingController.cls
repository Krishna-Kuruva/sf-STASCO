public class RE_MidDayPricingController {
    public Double finalMidGO10Val;
    public Double finalMidGO500Val;
	public List<RE_Market_Quotes__c> middayquotelist = RE_SOQLController.fetchforwardswapquotes();
    public Static Map<String, RE_Market_Quotes__c > mopsMap = new Map<String, RE_Market_Quotes__c >();    
    public Map<Id, Double> midpricemap = new Map<Id, Double>();    
    
    public static Double getDailyStructor(Date dts){    
		Date dtSt= Date.newInstance(1900,01,01);    
        Integer day_val 	= dts.day();
        Integer month_val 	= dts.month();
        Date 	startDate 	= dts.toStartOfMonth(); 
		Date 	c_endDate 	= startDate.addMonths(1).addDays(-1);
        Date 	n_endDate 	= startDate.addMonths(2).addDays(-1);
        Date 	n_n_endDate = startDate.addMonths(3).addDays(-1);
		
        Date 	lastdayBalM	= day_val <= 15 ? c_endDate	: n_endDate;
		
        Date 	midDayM1	= day_val <= 15 ? (Date.newInstance(n_endDate.year(), n_endDate.month(), 15))	: (Date.newInstance(n_n_endDate.year(), n_n_endDate.month(), 15));
		Double startDate_number = dtSt.daysBetween(dts);
        Double lastdayBalM_number = dtSt.daysBetween(lastdayBalM);
        Double midDayM1_number	=	dtSt.daysBetween(midDayM1);
        Double balMonth_number	=	day_val <= 15 ? (startDate_number + ((lastdayBalM_number - startDate_number + 1)/2)) : (dtSt.daysBetween(Date.newInstance(n_endDate.year(), n_endDate.month(), 15)));
        
        System.debug(day_val+'    '+lastdayBalM_number+'    '+balMonth_number+'  '+midDayM1_number+'  ==>'+(midDayM1_number - balMonth_number));
        
        return (midDayM1_number - balMonth_number);
    }
    
    public static Double getMidStripM1(Date dts){
            Date dtSt= Date.newInstance(1900,01,01);
        Double mid_day	=	dts.day();
        Date 	startDate 	= dts.toStartOfMonth(); 
		Date 	c_endDate 	= startDate.addMonths(1).addDays(-1);
        Date 	n_endDate 	= startDate.addMonths(2).addDays(-1);
        Double mid_strip_val	=	dtSt.daysBetween(dts) + 22.50;
        
        Double mid_bal_val	=	mid_day <= 15 ?    (dtSt.daysBetween(dts) + ((31-mid_day)/2)): (dtSt.daysBetween(Date.newInstance(n_endDate.Year(), n_endDate.month(), 15))); 
        return math.abs(mid_bal_val - mid_strip_val);
    }
    
    public void getmiddayindication(){
        Double currMonGO10Val;
        Double nextMonGO10Val;
        Double currMonGO500Val;
        Double nextMonGO500Val;        
        Boolean isCurrent = false;
        Double dailyStructureVal = getDailyStructor(System.today());
        Double midStriptoMidVal = getMidStripM1(System.today());

        RE_SOQLController soqldata = new RE_SOQLController();
        for(RE_Market_Quotes__c mopsdata : soqldata.fetchMarketQuotesData()){
            if(!mopsMap.containsKey(mopsdata.RE_Quote_Name__c))
            	mopsMap.put(mopsdata.RE_Quote_Name__c,mopsdata);
        }
        System.debug('mopsMap'+mopsMap);
        Double MOPSspreadquote = mopsMap.get('Gasoil 0.001% S').RE_Price__c - mopsMap.get('Gasoil 0.05% S').RE_Price__c;        
       
       	if(!middayquotelist.isEmpty() && MOPSspreadquote != null && dailyStructureVal != null && midStriptoMidVal != null){
            for(RE_Market_Quotes__c quotedata : middayquotelist){
                if(isCurrent == true){
                    nextMonGO10Val = quotedata.RE_Price__c;
                    nextMonGO500Val = nextMonGO10Val - MOPSspreadquote;
                }
                else{
                    currMonGO10Val = quotedata.RE_Price__c;
                    currMonGO500Val = currMonGO10Val - MOPSspreadquote;
                    isCurrent = true;
                }
            }
            finalMidGO10Val = currMonGO10Val + (((nextMonGO10Val - currMonGO10Val)/dailyStructureVal) * midStriptoMidVal) + mopsMap.get('Gasoil 0.001% Premium').RE_Price__c;
			finalMidGO500Val = currMonGO500Val + (((nextMonGO500Val - currMonGO500Val)/dailyStructureVal) * midStriptoMidVal) + mopsMap.get('Gasoil 0.001% Premium').RE_Price__c;            
            midpricemap.put(mopsMap.get('Gasoil 0.05% S').Id, finalMidGO500Val);
            midpricemap.put(mopsMap.get('Gasoil 0.001% S').Id, finalMidGO10Val);
            midpricemap.put(mopsMap.get('Gasoil 0.25% S').Id, finalMidGO10Val-(mopsMap.get('Gasoil 0.001% S').RE_Price__c - mopsMap.get('Gasoil 0.25% S').RE_Price__c)) ;
            midpricemap.put(mopsMap.get('Kero').Id, finalMidGO10Val - (mopsMap.get('Gasoil 0.001% S').RE_Price__c - mopsMap.get('Kero').RE_Price__c));
            midpricemap.put(mopsMap.get('MOGAS 95').Id, mopsMap.get('MOGAS 95').RE_Price__c);
            midpricemap.put(mopsMap.get('MOGAS 97').Id, mopsMap.get('MOGAS 97').RE_Price__c);
            midpricemap.put(mopsMap.get('Kero Premium').Id, mopsMap.get('Kero Premium').RE_Price__c);
            midpricemap.put(mopsMap.get('Distillation Discount').Id, mopsMap.get('Distillation Discount').RE_Price__c);   
            midpricemap.put(mopsMap.get('Gasoil 0.001% Premium').Id, mopsMap.get('Gasoil 0.001% Premium').RE_Price__c);
            midpricemap.put(mopsMap.get('FuelSave95 Premium').Id, mopsMap.get('FuelSave95 Premium').RE_Price__c);            	
            midpricemap.put(mopsMap.get('FuelSave98 Premium').Id, mopsMap.get('FuelSave98 Premium').RE_Price__c);
    	}
        
    } 
    
    public Double getIndicationMovement(){
        Double indicationMovement;
        Double volconvValue;
        RE_SOQLController sqldata = new RE_SOQLController();  
        for(RE_MY_VolumeConversion__c conversionRate : RE_MY_VolumeConversion__c.getall().values()){
            if(conversionRate.RE_MY_Base_Volume_Unit__c == 'LTR' &&
               conversionRate.RE_MY_Country__c == 'Malaysia' &&
               conversionRate.RE_MY_Volume_Unit__c == 'BBL'){
                   volconvValue = conversionRate.RE_MY_Conversion_Rate__c;                                              
               }      
        }
        
        if(volconvValue != null && finalMidGO500Val != null){
            indicationMovement = 0.93 * ((finalMidGO500Val * RE_SOQLController.fetchMYFxDataforMidDay() - mopsMap.get('Gasoil 0.05% S').RE_Price__c * RE_SOQLController.fetchMYFxData())/volconvValue);
            updatemops(midpricemap); 
            System.debug('midpricemap '+midpricemap);             
        }        	
        return indicationMovement;
    }
    
    public static void updatemops(Map<Id,Double> midpricemap){
        Double MOPS10PPM = 0.00;
        Double SpotPrem10ppm = 0.00;
        Double QTYPREMIAGBE37 = 0.00;
        Double MOPS10PPMCTSL = 0.00;
        Double SpotPrem10ppmCTSL = 0.00;
        Double QTYPREMIAGBE37CTSL = 0.00;
        List<RE_Market_Quotes__c> marketlist = new List<RE_Market_Quotes__c>();
        RE_SOQLController soqldataset = new RE_SOQLController();
        Map<String, Double> sqldata = soqldataset.fetchLatestMidFxData();
        RE_unitConversion unitconv = new RE_unitConversion();
        try{
            List<RE_Market_Quotes__c> oldmiddayquotelist = [Select Id,RE_Price__c,RE_Quote_Name__c,RE_Quote_Type__c,RE_Pricing_Date__c,RE_Rate_Unit__c
                                                   from RE_Market_Quotes__c where RE_Pricing_Date__c = Today and RE_Quote_Type__c = 'Midday' AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')];
            for(RE_Market_Quotes__c middayprice : [Select Id,RE_Price__c,RE_Quote_Name__c,RE_Quote_Type__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Country_Name__c
                                                   from RE_Market_Quotes__c where Id IN: midpricemap.keyset()]){
                if(midpricemap.containskey(middayprice.Id)){
                    RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();
                    markQuote.RE_Country_Name__c = middayprice.RE_Country_Name__c;
                    markQuote.RE_Quote_Name__c = middayprice.RE_Quote_Name__c;
                    markQuote.RE_Quote_Type__c = 'Midday';   
                    markQuote.RE_Tracker__c = 'D';
                    markQuote.RE_Rate_Unit__c = middayprice.RE_Rate_Unit__c;
                    markQuote.RE_Pricing_Date__c = System.today();
                    markQuote.RE_Price__c = Decimal.valueOf(midpricemap.get(middayprice.Id)).setScale(4);
                    if(markQuote.RE_Quote_Name__c == 'Gasoil 0.001% S'){                        
                        MOPS10PPM	=	markQuote.RE_Price__c;
                        MOPS10PPMCTSL	=	markQuote.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Gasoil 0.001% S',sqldata));
                    }
                    if(markQuote.RE_Quote_Name__c == 'Gasoil 0.001% Premium'){
                        SpotPrem10ppm	=	markQuote.RE_Price__c;
                        SpotPrem10ppmCTSL	=	markQuote.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Gasoil 0.001% Premium',sqldata));		
                    }
                    if(markQuote.RE_Quote_Name__c == 'Distillation Discount'){
                        QTYPREMIAGBE37 = markQuote.RE_Price__c;
                        QTYPREMIAGBE37CTSL = markQuote.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Distillation Discount',sqldata));
                    }
                    marketlist.add(markQuote);
                }                    
            }            
            
            for(RE_Market_Quotes__c marketquoteData : marketlist){		
                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S'){  
            		marketquoteData.RE_Temperature_Gain_USD_BB6__c	=	((MOPS10PPM + SpotPrem10ppm + QTYPREMIAGBE37) * 0.016).setscale(3);
                	marketquoteData.RE_Temperature_Gain_S_cent_l__c = ((MOPS10PPMCTSL + SpotPrem10ppmCTSL + QTYPREMIAGBE37CTSL) * 0.016).setscale(3);			                    
                }
            }                            
                
            if(!marketlist.isEmpty()){
                if(!oldmiddayquotelist.isEmpty())
                    delete oldmiddayquotelist;
                insert marketlist;
            }
                
        }
        catch(Exception e){
            System.debug('error on updating market quotes '+e.getMessage());
        }        
    }
    
    public void finalMidDayOutput(){
        getmiddayindication();
        Double indicationMovement = getIndicationMovement();
        system.debug('indicationMovement'+indicationMovement);
        Map<String,Double> oldShellValue = new Map<String,Double>();
        List<RE_Midday_Pricing__c> midaydatalist = new List<RE_Midday_Pricing__c>();
        List<RE_Midday_Pricing__c> oldmidaydatalist = new List<RE_Midday_Pricing__c>();
        for(RE_Midday_Pricing__c oldmiddayoutput : [Select Id,RE_IsLatest__c from RE_Midday_Pricing__c where RE_IsLatest__c = True and createddate = Today]){
            oldmiddayoutput.RE_IsLatest__c = False;
            oldmidaydatalist.add(oldmiddayoutput);
        }
        Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        List<RE_MY_CostPrice__c> latestcostprice = [
            SELECT Id, RE_Costprice_Marginal_Cost__c, RE_Depot_Name__c,RE_Depot_Name__r.Name, RE_Product_Name__c , RE_Product_Name__r.Name
            FROM RE_MY_CostPrice__c
            WHERE recordtypeId = : rectypeId AND RE_IsLatest__c = True
        ];
        
        for(RE_MidDay_Helper__c middaycsdata : RE_MidDay_Helper__c.getall().values()){
            for(RE_MY_CostPrice__c mycostdata : latestcostprice){
                if(mycostdata.RE_Depot_Name__r.Name == middaycsdata.RE_Depot_Name__c && mycostdata.RE_Product_Name__r.Name == middaycsdata.RE_Product__c){
                    RE_Midday_Pricing__c middaydata = new RE_Midday_Pricing__c(); 
                    middaydata.RE_IsLatest__c = True;
                    middaydata.RE_Product_Name__c = mycostdata.RE_Product_Name__c;
                    middaydata.RE_Depot__c = middaycsdata.RE_MidDayOutput__c;
                    middaydata.RE_Depot_Name__c = mycostdata.RE_Depot_Name__c;
                    middaydata.RE_Region__c = middaycsdata.RE_Region__c;
                    middaydata.RE_Product__c = middaycsdata.RE_Product_Code__c;
                    middaydata.RE_Index__c = middaycsdata.RE_Index__c;
                    middaydata.RE_Morning_Marginal_Cost__c = mycostdata.RE_Costprice_Marginal_Cost__c.setscale(2);
                    middaydata.RE_Midday_Forecast_Price__c = (indicationMovement / middaycsdata.RE_Multiplier__c).setscale(2);                                    
                    midaydatalist.add(middaydata);
                }
            }
        }
        
        try{
        	if(!midaydatalist.isEmpty()){            
                if(!oldmidaydatalist.isEmpty())
                    update oldmidaydatalist;
                insert midaydatalist;
            }
        }
        catch(Exception e){
            System.debug('Error on creating Malaysia midday output '+e.getMessage());
        }        
    }
    
    @AuraEnabled(cacheable = false)
    public Static List<RE_Midday_Pricing__c> fetchMidDayOutput(String region){
        List<RE_Midday_Pricing__c> middaylist = [
            SELECT RE_Product_Name__r.Name, RE_Depot__c, RE_Shell_Price__c, RE_Morning_Marginal_Cost__c,RE_Index__c,
            RE_Midday_Forecast_Price__c,Id,RE_Estimated_Margin__c,RE_Market_Price__c,RE_Region__c,RE_Product__c
            FROM RE_Midday_Pricing__c 
            WHERE createddate = Today
            AND RE_IsLatest__c = True
            AND RE_Region__c =: region
            ORDER BY RE_Index__c
        ];
        System.debug('middaylist '+middaylist);
        if(!middaylist.isEmpty())
            return middaylist;
        else 
             return null;           
    }    

    @AuraEnabled
    public Static void updateMiddayRecords(List<RE_Midday_Pricing__c> mc0List){
        try{
            update mc0List;
        }
        catch(Exception ex){

        }        
    }
    
    @Auraenabled
    public Static List<RE_MidDay_ActualSource__c> fetchActSrcData(){
        return RE_MidDay_ActualSource__c.getall().values();         
    }   
    
    @AuraEnabled
    public Static void inputmarketRecords(List<RE_Market_Quotes__c> marketquoteList){
        System.debug('marketquoteList'+marketquoteList);
        try{
            insert marketquoteList;
        }
        catch(Exception ex){

        }        
    }
    
    @AuraEnabled(cacheable = false)
    public Static List<RE_Midday_Pricing__c> recalculateMidDayOutput(){
        List<RE_Midday_Pricing__c> finalMiddayList = new List<RE_Midday_Pricing__c>();
        Map<String,RE_MY_CostPrice__c> costMap = new Map<String,RE_MY_CostPrice__c>();
        Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId() ;
        for(RE_MY_CostPrice__c latestcostprice : [
            SELECT Id, RE_Costprice_Marginal_Cost__c, RE_Depot_Name__c,RE_Depot_Name__r.Name, RE_Product_Name__c , RE_Product_Name__r.Name
            FROM RE_MY_CostPrice__c
            WHERE recordtypeId = : rectypeId AND RE_IsLatest__c = True
        ]){
            costMap.put(latestcostprice.RE_Depot_Name__c+'_'+latestcostprice.RE_Product_Name__c, latestcostprice);
        }
        for(RE_Midday_Pricing__c middayData: [
            SELECT RE_Product_Name__r.Name, RE_Depot__c, RE_Shell_Price__c, RE_Morning_Marginal_Cost__c,RE_Index__c,RE_Depot_Name__c,
            RE_Midday_Forecast_Price__c,Id,RE_Estimated_Margin__c,RE_Market_Price__c,RE_Region__c,RE_Product_Name__c
            FROM RE_Midday_Pricing__c 
            WHERE createddate = Today
            AND RE_IsLatest__c = True
        ]){
            if(costMap.containsKey(middayData.RE_Depot_Name__c+'_'+middayData.RE_Product_Name__c)){
                middayData.RE_Morning_Marginal_Cost__c = costMap.get(middayData.RE_Depot_Name__c+'_'+middayData.RE_Product_Name__c).RE_Costprice_Marginal_Cost__c;
                finalMiddayList.add(middayData);
            } 
        }
        if(!finalMiddayList.isEmpty()){
            try{update finalMiddayList;}
            catch(Exception ex){System.debug(ex.getCause());}
        }
        return finalMiddayList;
    }
  
}