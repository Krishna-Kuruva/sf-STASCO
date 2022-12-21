public class RE_ExternalTriggerHelper {
	public Static String rateUnitValue(String currencydata, String uom){
		String rateUnit;
		for(RE_External_Unit_Mapping__c conversionRate : RE_External_Unit_Mapping__c.getall().values()){ 
			if(conversionRate.RE_External_Currency_Unit__c == currencydata && conversionRate.RE_External_Volume_Unit__c == uom){
				rateUnit = conversionRate.RE_Rate_Unit__c;
			}
		}   
		return rateUnit;
	}
	   
	public Static Datetime convertToDate(String quoteDate, String obj){
		Datetime myDateFormatted;
        List<String> quotedatelist;
        if(quoteDate.contains('/'))
		quotedatelist = quoteDate.split('/');
        else if(quoteDate.contains('.'))
            quotedatelist = quoteDate.split('\\.');
        else if(quoteDate.contains('-'))
            quotedatelist = quoteDate.split('-');
        Integer year;
        Integer day;
        Integer month;
        if(!quotedatelist.isEmpty()){
            if(obj == 'MOPS'){
                year = Integer.valueOf(quotedatelist[2]);                
                month = Integer.valueOf(quotedatelist[1]);
                day = Integer.valueOf(quotedatelist[0]);
            }	
            if(obj == 'FX'){
                year = Integer.valueOf(quotedatelist[2]);                
                month = Integer.valueOf(quotedatelist[1]);
                day = Integer.valueOf(quotedatelist[0]);
            }	
            if(obj == 'ExMOPS'){
                year = Integer.valueOf(quotedatelist[0]);                
                month = Integer.valueOf(quotedatelist[1]);
                day = Integer.valueOf(quotedatelist[2]);
            }	
            if(obj == 'ExFX'){
                year = Integer.valueOf(quotedatelist[0]);                
                month = Integer.valueOf(quotedatelist[1]);
                day = Integer.valueOf(quotedatelist[2]);
            }
			myDateFormatted = DateTime.newInstance(year,month,day);
        }
		return myDateFormatted;	
	}
    public Static Boolean mopsDataTracker(){               
        Map<String, RE_Market_Quotes__c> latestmarketquoteList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldmarketquoteList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> latestmarketpremList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldmarketpremList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> latestassessedpremList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldassessedpremList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> latestmiddayList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldmiddayList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> latestfreightList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldfreightList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> weeklyMap = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> monthlyMap = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldweeklyMap = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldmonthlyMap = new Map<String, RE_Market_Quotes__c>();
        
        List<RE_Market_Quotes__c> weeklyList = new List<RE_Market_Quotes__c>();
        List<RE_Market_Quotes__c> monthlyList = new List<RE_Market_Quotes__c>();
        List<RE_Market_Quotes__c> prevmarketquoteList = new List<RE_Market_Quotes__c>();
        List<RE_Market_Quotes__c> finalmarketquoteList = new List<RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT RE_Price__c,RE_Pricing_Date__c,RE_Quote_Name__c,RE_Tracker__c,RE_Quote_Type__c
            FROM RE_Market_Quotes__c
           	WHERE RE_Tracker__c IN ('D','D-1','W-1','W-2','M-1','M-2')  
            AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
            ORDER BY RE_Pricing_Date__c DESC
        ]){            
            if(marketquoteData.RE_Tracker__c == 'D' || marketquoteData.RE_Tracker__c == 'D-1'){
                marketquoteData.RE_Tracker__c = '';
                prevmarketquoteList.add(marketquoteData);                
            }
            else if(marketquoteData.RE_Tracker__c == 'W-1' || marketquoteData.RE_Tracker__c == 'W-2'){
                marketquoteData.RE_Tracker__c = '';
                weeklyList.add(marketquoteData);                
            }
            else if(marketquoteData.RE_Tracker__c == 'M-1' || marketquoteData.RE_Tracker__c == 'M-2'){
                marketquoteData.RE_Tracker__c = '';
                monthlyList.add(marketquoteData);                
            }
        }
        for(RE_Market_Quotes__c marketquoteData : prevmarketquoteList){
            if(marketquoteData.RE_Quote_Type__c == 'Settlement'){
                if(!latestmarketquoteList.containsKey(marketquoteData.RE_Quote_Name__c)){
                    marketquoteData.RE_Tracker__c = 'D';
                    latestmarketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                }
                else{
                    if(!oldmarketquoteList.containsKey(marketquoteData.RE_Quote_Name__c)){
                        marketquoteData.RE_Tracker__c = 'D-1';
                        oldmarketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                    }    
                }
            } 
            if(marketquoteData.RE_Quote_Type__c == 'Market Premium'){ 
                if( !latestmarketpremList.containsKey(marketquoteData.RE_Quote_Name__c)){
                    marketquoteData.RE_Tracker__c = 'D';
                    latestmarketpremList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                }
                else{
                    if(!oldmarketpremList.containsKey(marketquoteData.RE_Quote_Name__c)){
                        marketquoteData.RE_Tracker__c = 'D-1';
                        oldmarketpremList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                    }    
                }
            }
            if(marketquoteData.RE_Quote_Type__c == 'Assessed Premium'){
                if(!latestassessedpremList.containsKey(marketquoteData.RE_Quote_Name__c)){
                    marketquoteData.RE_Tracker__c = 'D';
                    latestassessedpremList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                }
                else{
                    if(!oldassessedpremList.containsKey(marketquoteData.RE_Quote_Name__c)){
                        marketquoteData.RE_Tracker__c = 'D-1';
                        oldassessedpremList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                    }    
                }
            }
            if(marketquoteData.RE_Quote_Type__c == 'Midday'){
                if(!latestmiddayList.containsKey(marketquoteData.RE_Quote_Name__c)){
                    marketquoteData.RE_Tracker__c = 'D';
                    latestmiddayList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                }
                else{
                    if(!oldmiddayList.containsKey(marketquoteData.RE_Quote_Name__c)){
                        marketquoteData.RE_Tracker__c = 'D-1';
                        oldmiddayList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                    }    
                }
            } 
            if(marketquoteData.RE_Quote_Type__c == 'Freight'){
                if(!latestfreightList.containsKey(marketquoteData.RE_Quote_Name__c)){
                    marketquoteData.RE_Tracker__c = 'D';
                    latestfreightList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                }
                else{
                    if(!oldfreightList.containsKey(marketquoteData.RE_Quote_Name__c)){
                        marketquoteData.RE_Tracker__c = 'D-1';
                        oldfreightList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                    }    
                }
            } 
        }
        
        for(RE_Market_Quotes__c quotedata : weeklyList){
            if(!weeklyMap.containsKey(quotedata.RE_Quote_Name__c)){
                quotedata.RE_Tracker__c = 'W-1';
                weeklyMap.put(quotedata.RE_Quote_Name__c,quotedata);
            }
            else{
                if(!oldweeklyMap.containsKey(quotedata.RE_Quote_Name__c)){
                    quotedata.RE_Tracker__c = 'W-2';
                    oldweeklyMap.put(quotedata.RE_Quote_Name__c,quotedata);
                }    
            }
        }
        
        for(RE_Market_Quotes__c quotedata : monthlyList){
            if(!monthlyMap.containsKey(quotedata.RE_Quote_Name__c)){
                quotedata.RE_Tracker__c = 'M-1';
                monthlyMap.put(quotedata.RE_Quote_Name__c,quotedata);
            }
            else{
                if(!oldmonthlyMap.containsKey(quotedata.RE_Quote_Name__c)){
                    quotedata.RE_Tracker__c = 'M-2';
                    oldmonthlyMap.put(quotedata.RE_Quote_Name__c,quotedata);
                }    
            }
        }
        
        if(!latestmarketquoteList.isEmpty())
        	finalmarketquoteList.addAll(latestmarketquoteList.values());
        if(!oldmarketquoteList.isEmpty())
        	finalmarketquoteList.addAll(oldmarketquoteList.values());
        if(!latestmarketpremList.isEmpty())
        	finalmarketquoteList.addAll(latestmarketpremList.values());
        if(!oldmarketpremList.isEmpty())
        	finalmarketquoteList.addAll(oldmarketpremList.values());
        if(!latestassessedpremList.isEmpty())
        	finalmarketquoteList.addAll(latestassessedpremList.values());
        if(!oldassessedpremList.isEmpty())
        	finalmarketquoteList.addAll(oldassessedpremList.values());   
        if(!latestmiddayList.isEmpty())
        	finalmarketquoteList.addAll(latestmiddayList.values());
        if(!oldmiddayList.isEmpty())
        	finalmarketquoteList.addAll(oldmiddayList.values()); 
        if(!latestfreightList.isEmpty())
        	finalmarketquoteList.addAll(latestfreightList.values());
        if(!oldfreightList.isEmpty())
        	finalmarketquoteList.addAll(oldfreightList.values()); 
        
        if(!weeklyMap.isEmpty())
        	finalmarketquoteList.addAll(weeklyMap.values());
        if(!oldweeklyMap.isEmpty())
        	finalmarketquoteList.addAll(oldweeklyMap.values());
        if(!monthlyMap.isEmpty())
        	finalmarketquoteList.addAll(monthlyMap.values());
        if(!oldmonthlyMap.isEmpty())
        	finalmarketquoteList.addAll(oldmonthlyMap.values());
        
        if(!prevmarketquoteList.isEmpty()){
            for(RE_Market_Quotes__c marketquote : prevmarketquoteList){
            	if(!finalmarketquoteList.contains(marketquote))
              		finalmarketquoteList.add(marketquote);
        	}
        }
        
        if(!monthlyList.isEmpty()){
            for(RE_Market_Quotes__c marketquote : monthlyList){
            	if(!finalmarketquoteList.contains(marketquote))
              		finalmarketquoteList.add(marketquote);
        	}
        }
        
        if(!weeklyList.isEmpty()){
            for(RE_Market_Quotes__c marketquote : weeklyList){
            	if(!finalmarketquoteList.contains(marketquote))
              		finalmarketquoteList.add(marketquote);
        	}
        }
        
        if(!finalmarketquoteList.isEmpty()){
            try{
                update finalmarketquoteList;                
                }
            catch(Exception e){
                system.debug('---data--'+e.getCause());
                return false;
            } 
        }
        return true;        
    }

    public Static Boolean fxDataTracker(){
        Map<String, RE_FX_Rates__c> curConvMap = new Map<String, RE_FX_Rates__c>();
        Map<String, RE_FX_Rates__c> oldcurConvMap = new Map<String, RE_FX_Rates__c>();
        Map<String, RE_FX_Rates__c> oldcurConvMapd2 = new Map<String, RE_FX_Rates__c>();
        Map<String, RE_FX_Rates__c> oldcurConvMapd3 = new Map<String, RE_FX_Rates__c>();
        Map<String, RE_FX_Rates__c> weeklyMap = new Map<String, RE_FX_Rates__c>();
        Map<String, RE_FX_Rates__c> monthlyMap = new Map<String, RE_FX_Rates__c>();
        Map<String, RE_FX_Rates__c> oldweeklyMap = new Map<String, RE_FX_Rates__c>();
        Map<String, RE_FX_Rates__c> oldmonthlyMap = new Map<String, RE_FX_Rates__c>();
       
        List<RE_FX_Rates__c> weeklyList = new List<RE_FX_Rates__c>();
        List<RE_FX_Rates__c> monthlyList = new List<RE_FX_Rates__c>();
        List<RE_FX_Rates__c> prevfxList = new List<RE_FX_Rates__c>();
        List<RE_FX_Rates__c> finalfxList = new List<RE_FX_Rates__c>();

        for(RE_FX_Rates__c latestData : [
            SELECT RE_Conversion_Unit__c,RE_Base_Unit__c,RE_Forex_Rate__c,RE_Tracker__c,RE_Pricing_Date__c,RE_Trade_Type__c
            FROM RE_FX_Rates__c             
           	WHERE RE_Tracker__c IN ('D','D+1','D-1','D-2','W-1','W-2','M-1','M-2')
            ORDER BY RE_Pricing_Date__c DESC
        ]){
            if(latestData.RE_Tracker__c == 'D+1' || latestData.RE_Tracker__c == 'D' || latestData.RE_Tracker__c == 'D-1' || latestData.RE_Tracker__c == 'D-2'){
                latestData.RE_Tracker__c = '';
                prevfxList.add(latestData);
            }
            else if(latestData.RE_Tracker__c == 'W-1' || latestData.RE_Tracker__c == 'W-2'){
                latestData.RE_Tracker__c = '';
                weeklyList.add(latestData);                
            }
            else if(latestData.RE_Tracker__c == 'M-1' || latestData.RE_Tracker__c == 'M-2'){
                latestData.RE_Tracker__c = '';
                monthlyList.add(latestData);                
            }
           
        }
        for(RE_FX_Rates__c latestData  : prevfxList){
            if(!curConvMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                latestData.RE_Tracker__c = 'D+1';
                curConvMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c, latestData);
            }
            else
                if(!oldcurConvMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                    latestData.RE_Tracker__c = 'D';
                    oldcurConvMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c, latestData);
                }
            else
                if(!oldcurConvMapd2.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                    latestData.RE_Tracker__c = 'D-1';
                    oldcurConvMapd2.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c, latestData);
                }
            else
                if(!oldcurConvMapd3.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                    latestData.RE_Tracker__c = 'D-2';
                    oldcurConvMapd3.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c, latestData);
                }
        }
        
        for(RE_FX_Rates__c latestData : weeklyList){
            if(!weeklyMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                latestData.RE_Tracker__c = 'W-1';
                weeklyMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c,latestData);
            }
            else{
                if(!oldweeklyMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                    latestData.RE_Tracker__c = 'W-2';
                    oldweeklyMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c,latestData);
                }    
            }
        }
        
        for(RE_FX_Rates__c latestData : monthlyList){
            if(!monthlyMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                latestData.RE_Tracker__c = 'M-1';
                monthlyMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c,latestData);
            }
            else{
                if(!oldmonthlyMap.containsKey(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c)){
                    latestData.RE_Tracker__c = 'M-2';
                    oldmonthlyMap.put(latestData.RE_Conversion_Unit__c+'-'+latestData.RE_Base_Unit__c+'-'+latestData.RE_Trade_Type__c,latestData);
                }    
            }
        }
        
        if(!curConvMap.isEmpty())
            finalfxList.addAll(curConvMap.values());
        if(!oldcurConvMap.isEmpty())
            finalfxList.addAll(oldcurConvMap.values());
        if(!oldcurConvMapd2.isEmpty())
            finalfxList.addAll(oldcurConvMapd2.values());
        if(!oldcurConvMapd3.isEmpty())
            finalfxList.addAll(oldcurConvMapd3.values());
        
        if(!weeklyMap.isEmpty())
            finalfxList.addAll(weeklyMap.values());
        if(!oldweeklyMap.isEmpty())
            finalfxList.addAll(oldweeklyMap.values());
        if(!monthlyMap.isEmpty())
            finalfxList.addAll(monthlyMap.values());
        if(!oldmonthlyMap.isEmpty())
            finalfxList.addAll(oldmonthlyMap.values());
       
        if(!prevfxList.isEmpty()){
            for(RE_FX_Rates__c fxrate : prevfxList){
                if(!finalfxList.contains(fxrate))
                    finalfxList.add(fxrate);
            }
        }

        if(!monthlyList.isEmpty()){
            for(RE_FX_Rates__c fxrate : monthlyList){
            	if(!finalfxList.contains(fxrate))
              		finalfxList.add(fxrate);
        	}
        }
        
        if(!weeklyList.isEmpty()){
            for(RE_FX_Rates__c fxrate : weeklyList){
            	if(!finalfxList.contains(fxrate))
              		finalfxList.add(fxrate);
        	}
        }
        
        if(!finalfxList.isEmpty()){
            try{
                update finalfxList;
            }
            catch(Exception e){
                return false;
            }
        }
        return true;
    }
    
     public Static List<RE_Gain_Loss_Audit__c> createweeklyLagData(String RE_Conversion_Unit, String RE_Final_Unit, String Country){
        List<RE_Gain_Loss_Audit__c> WeeklygainlostDataList = new List<RE_Gain_Loss_Audit__c>();
        RE_unitConversion uncv = new RE_unitConversion();
        List<RE_Weekly_Data__c> weeklydata = RE_Weekly_Data__c.getall().values();
        MAP<Datetime, Double> fxdatalastweek = new MAP<Datetime, Double>();
        AggregateResult fxdata = [
           SELECT avg(RE_Forex_Rate__c) fxavgval FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c =: RE_Conversion_Unit 
            AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Pricing_Date__c = LAST_N_DAYS : 8
            AND RE_Pricing_Date__c < LAST_N_DAYS : 3
        ];
        
        for(AggregateResult mopsdatalastweek : [
            SELECT AVG(RE_Price__c) pravgval,RE_Quote_Name__c,RE_Rate_Unit__c
            FROM RE_Market_Quotes__c 
            WHERE CREATEDDATE = LAST_N_DAYS : 7
            AND RE_Quote_Type__c = 'Settlement'
            AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
            AND RE_Is_MTDWTD__c = False
            GROUP BY RE_Quote_Name__c,RE_Rate_Unit__c
        ]){
            RE_Gain_Loss_Audit__c glaudit = new RE_Gain_Loss_Audit__c();
            glaudit.RE_Type__c = 'W-1';
            glaudit.RE_Price__c = (Decimal) mopsdatalastweek.get('pravgval') * (Decimal) fxdata.get('fxavgval')
                /uncv.convertVolumeMultiplier((String)mopsdatalastweek.get('RE_Quote_Name__c'),RE_unitConversion.unitBreakUp((String)mopsdatalastweek.get('RE_Rate_Unit__c'))[1],
                                              RE_unitConversion.unitBreakUp(RE_Final_Unit)[1],Country);
            glaudit.RE_MOPS_Name__c = (String)mopsdatalastweek.get('RE_Quote_Name__c');
            glaudit.RE_Published_Date__c = System.today();            
            for(RE_Weekly_Data__c wd : weeklydata){
                if(wd.RE_Valid_From__c <= System.today() &&  wd.RE_Valid_To__c >= System.today()){
                    glaudit.RE_Month__c = wd.RE_Month__c;
                    glaudit.RE_Year__c = String.valueof(wd.RE_Year__c);
                    glaudit.RE_Week_Number__c = String.valueof(wd.RE_Week_Number__c); 
					glaudit.recordtypeId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get(Country).getRecordTypeId() ;
               
                }
            }
            WeeklygainlostDataList.add(glaudit);
        }      
        return WeeklygainlostDataList;
    }
    
    public Static List<RE_Gain_Loss_Audit__c> createmonthlyLagData(String RE_Conversion_Unit, String RE_Final_Unit, String Country){
        List<RE_Gain_Loss_Audit__c> monthlygainlostDataList = new List<RE_Gain_Loss_Audit__c>();
        RE_unitConversion uncv = new RE_unitConversion();
        List<RE_Weekly_Data__c> weeklydata = RE_Weekly_Data__c.getall().values();
        MAP<Datetime, Double> fxdatalastweek = new MAP<Datetime, Double>();
        AggregateResult fxdata = [
            SELECT AVG(RE_Forex_Rate__c) fxavgval FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c =: RE_Conversion_Unit
            AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Pricing_Date__c = LAST_MONTH 
        ];
        
        for(AggregateResult mopsdatalastweek : [
            SELECT AVG(RE_Price__c) pravgval,RE_Quote_Name__c,RE_Rate_Unit__c
            FROM RE_Market_Quotes__c 
            WHERE RE_Pricing_Date__c = LAST_MONTH
            AND RE_Quote_Type__c = 'Settlement'
            AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
            AND RE_Is_MTDWTD__c = False
            GROUP BY RE_Quote_Name__c,RE_Rate_Unit__c
        ]){
            RE_Gain_Loss_Audit__c glaudit = new RE_Gain_Loss_Audit__c();
            glaudit.RE_Type__c = 'M-1';
            glaudit.RE_Price__c = (Decimal) mopsdatalastweek.get('pravgval') * (Decimal) fxdata.get('fxavgval')
                /uncv.convertVolumeMultiplier((String)mopsdatalastweek.get('RE_Quote_Name__c'),RE_unitConversion.unitBreakUp((String)mopsdatalastweek.get('RE_Rate_Unit__c'))[1],
                                              RE_unitConversion.unitBreakUp(RE_Final_Unit)[1],Country);
            glaudit.RE_MOPS_Name__c = (String)mopsdatalastweek.get('RE_Quote_Name__c');
            glaudit.RE_Published_Date__c = System.today();            
            for(RE_Weekly_Data__c wd : weeklydata){
                if(wd.RE_Valid_From__c <= System.today() &&  wd.RE_Valid_To__c >= System.today()){
                    glaudit.RE_Month__c = wd.RE_Month__c;
                    glaudit.RE_Year__c = String.valueof(wd.RE_Year__c);  
					glaudit.recordtypeId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get(Country).getRecordTypeId() ;
					
                }
            }
            monthlygainlostDataList.add(glaudit);
        }      
        return monthlygainlostDataList;
    }
    
    public Static void CreateLagAuditData(){
        List<RE_Gain_Loss_Audit__c> gainlostDataList = new List<RE_Gain_Loss_Audit__c>();
        Datetime dt = (DateTime)System.today();
        String dayOfWeek = dt.format('EEEE');
        Integer day = dt.day();
		       if(dayOfWeek == 'Monday'){//Monday
            gainlostDataList.addall(createweeklyLagData('MYR CTS','MYR CTS/LTR','Malaysia'));
			gainlostDataList.addall(createweeklyLagData('THB','THB/LTR','Thailand'));

        } 
        if(day == 1){
            gainlostDataList.addall(createmonthlyLagData('MYR CTS','MYR CTS/LTR','Malaysia'));
			gainlostDataList.addall(createmonthlyLagData('THB','THB/LTR','Thailand'));

        }
        if(!gainlostDataList.isEmpty()){
            try{
                insert gainlostDataList;
				
            }
            catch(Exception ex){
                
            }
        }
    }
    public Static void createDailyLagAuditData(String RE_Final_Unit, String Country){    //RE_MY_Final_Unit Malaysia   MYR CTS
       // CreateLagAuditData();
        RE_unitConversion uncv = new RE_unitConversion();
        RE_SOQLController soqldata = new RE_SOQLController();
        List<RE_Weekly_Data__c> weeklydata = RE_Weekly_Data__c.getall().values();
        List<RE_Gain_Loss_Audit__c> gainlostDataList = new List<RE_Gain_Loss_Audit__c>();        
       	Map<String,Double> monthlygldata = new Map<String,Double>();
        Map<String,Double> weeklygldata = new Map<String,Double>();
		Map<String,String> weeklydataIDMAP = new Map<String,String>();
		Map<String,String> monthlydataIDMAP = new Map<String,String>();
        Datetime dt = (DateTime)System.today();
        String dayOfWeek = dt.format('EEEE');
        Integer day = dt.day();
		date myDate = date.today();
		String weeknumber='';
        date weekStart = myDate.toStartofWeek();
		for(RE_Gain_Loss_Audit__c gldata : [
            SELECT Id,RE_Price__c,RE_MOPS_Name__c,RE_Month__c,RE_Week_Number__c, RE_Year__c, RE_Type__c,RE_Published_Date__c 
            FROM RE_Gain_Loss_Audit__c 
            WHERE RE_Type__c IN ('W-1') 
            AND RE_Published_Date__c = THIS_Week AND Recordtype.Name=: Country 
            ORDER BY RE_Published_Date__c DESC
        ]){
            	if(gldata.RE_Type__c == 'W-1')
                weeklygldata.put(gldata.RE_MOPS_Name__c,gldata.RE_Price__c);  
				
				
				if(weekStart == gldata.RE_Published_Date__c){
					weeklydataIDMAP.put(gldata.RE_MOPS_Name__c,gldata.Id);
				}
        }
        for(RE_Gain_Loss_Audit__c gldata : [
            SELECT Id,RE_Price__c,RE_MOPS_Name__c,RE_Month__c,RE_Week_Number__c, RE_Year__c, RE_Type__c,RE_Published_Date__c 
            FROM RE_Gain_Loss_Audit__c 
            WHERE RE_Type__c IN ('M-1') 
            AND RE_Published_Date__c = THIS_MONTH AND Recordtype.Name=: Country 
            ORDER BY RE_Published_Date__c DESC
        ]){//RE_Quote_Name__c
            if(gldata.RE_Type__c == 'M-1')
                monthlygldata.put(gldata.RE_MOPS_Name__c+'-'+gldata.RE_Year__c+'-'+gldata.RE_Month__c,gldata.RE_Price__c);            
				monthlydataIDMAP.put(gldata.RE_MOPS_Name__c,gldata.Id);
        } 
        for(RE_Market_Quotes__c mopsdatatoday : RE_SOQLController.fetchMarketQuotesSettlementData()){
            if(mopsdatatoday.RE_Rate_Unit__c == 'USD/BBL'){
                RE_Gain_Loss_Audit__c auditdata = new RE_Gain_Loss_Audit__c();            
                auditdata.RE_Type__c = 'D';
                auditdata.recordtypeId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get(Country).getRecordTypeId() ;
                auditdata.RE_Price__c = mopsdatatoday.RE_Price__c * 
                    uncv.unitConversionMultiplier(mopsdatatoday.RE_Rate_Unit__c,RE_Final_Unit,
                                                  Country,mopsdatatoday.RE_Quote_Name__c,soqldata.fetchLatestFxData());
                auditdata.RE_Quote_Name__c = mopsdatatoday.Id;
                auditdata.RE_MOPS_Name__c = mopsdatatoday.RE_Quote_Name__c;
                auditdata.RE_Published_Date__c = System.today();
                for(RE_Weekly_Data__c wd : weeklydata){
                    if(wd.RE_Valid_From__c <= System.today() &&  wd.RE_Valid_To__c >= System.today()){
                        auditdata.RE_Month__c = wd.RE_Month__c;
                        auditdata.RE_Year__c = String.valueof(wd.RE_Year__c);
                        auditdata.RE_Week_Number__c = String.valueof(wd.RE_Week_Number__c);  
                        weeknumber=auditdata.RE_Week_Number__c ;
                    }
                }
                if(weeklygldata.containsKey(mopsdatatoday.RE_Quote_Name__c))
                    auditdata.RE_WeekAverage__c = weeklygldata.get(mopsdatatoday.RE_Quote_Name__c) - auditdata.RE_Price__c;
                if(monthlygldata.containsKey(mopsdatatoday.RE_Quote_Name__c+'-'+auditdata.RE_Year__c+'-'+auditdata.RE_Month__c))
                    auditdata.RE_MonthlyAverage__c = monthlygldata.get(mopsdatatoday.RE_Quote_Name__c+'-'+auditdata.RE_Year__c+'-'+auditdata.RE_Month__c) - auditdata.RE_Price__c;
                gainlostDataList.add(auditdata);
            }
        }
        if(!gainlostDataList.isEmpty()){
            try{
                insert gainlostDataList;
            }
            catch(Exception ex){
                
            }
        }
		
		gainlostDataList = new List<RE_Gain_Loss_Audit__c>();
        if(day == 1){
            for(AggregateResult ref: [SELECT RE_Quote_Name__c,avg(RE_Price__c) average from RE_Market_Quotes__c where RE_Pricing_Date__c = LAST_MONTH  AND RE_Quote_Type__c = 'Settlement' AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') AND RE_Rate_Unit__c = 'USD/BBL' AND RE_Is_MTDWTD__c = False GROUP BY RE_Quote_Name__c]){
			//System.debug(String.valueOf(ref.get('RE_Quote_Name__c'))+'   '+monthlydataIDMAP.get(String.valueOf(ref.get('RE_Quote_Name__c'))));
                if(monthlydataIDMAP.containsKey(String.valueOf(ref.get('RE_Quote_Name__c')))){
                    gainlostDataList.add(new RE_Gain_Loss_Audit__c(Id=monthlydataIDMAP.get(String.valueOf(ref.get('RE_Quote_Name__c'))),RE_Months_AVG__c=Decimal.valueOf(ref.get('average')+'')));//,RE_MonthlyAverage__c
                }
            }
        }
        else{
            for(AggregateResult ref: [SELECT RE_Quote_Name__c,avg(RE_Price__c) average from RE_Market_Quotes__c where RE_Pricing_Date__c = THIS_MONTH  AND RE_Quote_Type__c = 'Settlement' AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') AND RE_Rate_Unit__c = 'USD/BBL' AND RE_Is_MTDWTD__c = False GROUP BY RE_Quote_Name__c]){
                //System.debug(String.valueOf(ref.get('RE_Quote_Name__c'))+'   '+monthlydataIDMAP.get(String.valueOf(ref.get('RE_Quote_Name__c'))));
                if(monthlydataIDMAP.containsKey(String.valueOf(ref.get('RE_Quote_Name__c')))){
                    gainlostDataList.add(new RE_Gain_Loss_Audit__c(Id=monthlydataIDMAP.get(String.valueOf(ref.get('RE_Quote_Name__c'))),RE_Months_AVG__c=Decimal.valueOf(ref.get('average')+'')));//,RE_MonthlyAverage__c
                }
            }
        }
		
        System.debug(weeklydataIDMAP.keyset());
		for(AggregateResult ref: [SELECT RE_Quote_Name__c,avg(RE_Price__c) average from RE_Market_Quotes__c where RE_Pricing_Date__c = LAST_WEEK  AND RE_Quote_Type__c = 'Settlement' AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') AND RE_Rate_Unit__c = 'USD/BBL'  AND RE_Is_MTDWTD__c = False GROUP BY RE_Quote_Name__c]){
			System.debug(ref.get('RE_Quote_Name__c'));
			if(weeklydataIDMAP.containsKey(String.valueOf(ref.get('RE_Quote_Name__c')))){
				gainlostDataList.add(new RE_Gain_Loss_Audit__c(Id=weeklydataIDMAP.get(String.valueOf(ref.get('RE_Quote_Name__c'))),RE_Weeks_AVG__c=Decimal.valueOf(ref.get('average')+''),RE_Week_Number__c=weeknumber));
			}
		}
		System.debug('sam  '+gainlostDataList);
		if(!gainlostDataList.isEmpty()){
            try{
                update gainlostDataList;
                legGainlegLoss(Country);
            }
            catch(Exception ex){
                
            }
        }

    }
    
    @future
    public static void legGainlegLoss(String Country){
        if(Country=='Malaysia'){            
            RE_ExternalTriggerHelper.insertleggainlegloss(System.label.MTD_Search_Filter,'Malaysia');//SING FOB GO 0.05%	: Gasoil 0.05% S
        }
        if(Country=='Thailand'){
          RE_ExternalTriggerHelper.insertleggainlegloss('Gasoil 0.05% S','Thailand');
        RE_ExternalTriggerHelper.insertleggainlegloss('Marine FuelOil 180','Thailand');//SING FOB FO 180     : Marine FuelOil 180  
        }		
    }
	
	public static void insertleggainlegloss(String MTD_Search_Filter, String Country){
 		List<RE_MY_Output__c> myOutputs= new List<RE_MY_Output__c>();
        List<RE_MY_Output__c> myUpdatedOutputs= new List<RE_MY_Output__c>();
        List<RE_MY_Output__c> finalUpdatedOutputs= new List<RE_MY_Output__c>();
        Decimal count= 0.0;
		Decimal RE_LAG_GAIN_LOSS_W_1_GO = 0.0;
		Decimal RE_LAG_GAIN_LOSS_M_1_GO = 0.0;
		for(Object ob: RE_GainLossController.fetchGainLossData(MTD_Search_Filter, Country)){
           
            RE_GainLossController.glWrap obj = (RE_GainLossController.glWrap)ob;
           // for(RE_MY_Output__c obRef: myOutputs){
             //   RE_MY_Output__c myOps = obRef;
                RE_LAG_GAIN_LOSS_W_1_GO	=	obj.weeklydifference;
                RE_LAG_GAIN_LOSS_M_1_GO		=	obj.monthlydifference;
            //    myUpdatedOutputs.add(myOps);
            //}
        }
		
        for(Object ob: RE_GainLossController.gainLossDetails(MTD_Search_Filter, Country)){
            RE_GainLossController.GainLossWrapper obj = (RE_GainLossController.GainLossWrapper)ob;
            myOutputs.add(new RE_MY_Output__c(RE_Month_Avg__c=obj.monthAverage,
                RE_Lifting_Date__c=obj.liftingDate,
                RE_Week__c=obj.weeks,
                RE_W_1__c=obj.week_1,
                RE_Difference__c=obj.Differences,
                RE_Position__c=obj.Position,
				RE_Product_Name__c = MTD_Search_Filter,
				recordtypeId	=	Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByName().get(Country).getRecordTypeId(), 
                //RE_MTD_Position_Money_for_the_month__c= obj.monthlydifference,
                RE_Type__c='MTD Position',
				RE_LAG_GAIN_LOSS_W_1_GO__c	=	RE_LAG_GAIN_LOSS_W_1_GO,
				RE_LAG_GAIN_LOSS_M_1_GO__c	=	RE_LAG_GAIN_LOSS_M_1_GO
				
				));
            count = count + (obj.Differences);
        }
       
        for(RE_MY_Output__c obRef: myOutputs){
                RE_MY_Output__c myOps = obRef;
            	myOps.RE_MTD_Position_Money_for_the_month__c=count.setScale(2);
           		finalUpdatedOutputs.add(myOps);
            System.debug(myOps);
        }
        try{

            System.debug(count+' -- **  MTD Position  '+finalUpdatedOutputs);
            if(!finalUpdatedOutputs.isEmpty()){
                Insert finalUpdatedOutputs;
            }
        }catch(Exception e){}
	}
}