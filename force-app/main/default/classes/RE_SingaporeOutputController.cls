global class RE_SingaporeOutputController {
    Public Static Integer maxRunCount; 
    public Static Integer maxRunCountMethod(String type){
        List<RE_MY_Output__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_Output__c 
                                               WHERE RE_Pricing_Date__c = Today AND RE_Type__c =:type ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(!costDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
        return maxRunCount;
    }
    @AuraEnabled
    public Static void jobExecute(String country){
        RE_MalayasiaOutputController.jobExecute(country); 
    } 
    @AuraEnabled
    public Static Boolean getUserInfo(Id userId){
        Boolean validProfile = false;
        for(PermissionSetAssignment currentUserPerSet : [
            SELECT Id, PermissionSet.Name,AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId]){ 
                if(currentUserPerSet.PermissionSet.Name == 'RE_MY_Pricing_Desk' ||
                   currentUserPerSet.PermissionSet.Name == 'RE_SG_Business_Analyst'){
                       validProfile = true;
                       break;
                   }
            }
        return validProfile;
    }
    @AuraEnabled
    public Static Datetime lastJobRun(){
        return([SELECT RE_Run_Time__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c = 'Singapore Output' ORDER BY RE_Run_Time__c DESC LIMIT 1].RE_Run_Time__c);
    }
    
    @AuraEnabled
    public static List<FxDataWrapper> getFxData(){
        RE_SOQLController soqldata = new RE_SOQLController();        
        List<FxDataWrapper> fxdatawraplist = new List<FxDataWrapper>();
        List<RE_FX_Rates__c> fxListdatatoday = [
            SELECT RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c FROM RE_FX_Rates__c WHERE RE_Tracker__c  = 'D' AND RE_Conversion_Unit__c = 'SGD' 
            AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c IN ('Sell','Exchange Rate') ORDER BY RE_Trade_Type__c ];
        List<RE_FX_Rates__c> fxListdatayesterday = [
            SELECT RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c FROM RE_FX_Rates__c WHERE RE_Tracker__c  = 'D-1' AND RE_Conversion_Unit__c = 'SGD'
            AND RE_Base_Unit__c = 'USD'  AND RE_Trade_Type__c IN ('Sell','Exchange Rate')ORDER BY RE_Trade_Type__c ];          
        if(!fxListdatatoday.isEmpty()){
            for(RE_FX_Rates__c fxtoday : fxListdatatoday){
                FxDataWrapper fxWrapper = new FxDataWrapper();
                if(fxtoday.RE_Trade_Type__c == 'Sell'){
                    fxWrapper.dailyval = fxtoday.RE_Forex_Rate__c;
                    fxWrapper.item = 'Selling OD';
                    fxWrapper.diff = fxtoday.RE_Forex_Rate__c;
                    for(RE_FX_Rates__c fxyday : fxListdatayesterday){
                        if(fxtoday.RE_Trade_Type__c == fxyday.RE_Trade_Type__c){
                            fxWrapper.lastdayval = fxyday.RE_Forex_Rate__c;
                            fxWrapper.diff = fxtoday.RE_Forex_Rate__c - fxyday.RE_Forex_Rate__c;
                        }	
                    }
                }
                else{
                    fxWrapper.dailyval = soqldata.fetchLastMondayFxData();
                    fxWrapper.item = 'Distillation Disc Rate';
                    fxWrapper.lastdayval = soqldata.fetchOldLastMondayFxData();
                    fxWrapper.diff = fxWrapper.dailyval - fxWrapper.lastdayval;
                }
                fxdatawraplist.add(fxWrapper);
            }	
        }
        return fxdatawraplist;
    }

	@AuraEnabled
    public Static List<MOPSDataWrapper> getMobileMOPSData(){
        List<RE_Market_Quotes__c> latestmarketquoteList = new List<RE_Market_Quotes__c>();
        List<RE_Market_Quotes__c> oldmarketquoteList = new List<RE_Market_Quotes__c>();
		Double temperatureVal = 0.00;
		Double temperatureCTSLVal = 0.00;
		
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c,RE_Temperature_Gain_S_cent_l__c,RE_Temperature_Gain_USD_BB6__c 
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D','D-1')
            AND RE_Quote_Type__c IN ('Settlement','Market Premium')
            AND RE_Quote_Name__c IN ('Gasoil 0.25% S', 'Gasoil 0.05% S','Gasoil 0.005% S','Kero','MOGAS 95','MOGAS 97','Gasoil 0.001% S','Kero Premium','Gasoil 0.001% Premium')
            ORDER BY RE_Quote_Type__c ASC //RE_Quote_Name__c ASC
        ]){
            if(marketquoteData.RE_Tracker__c =='D'){
                latestmarketquoteList.add(marketquoteData);
				if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S'){
					temperatureVal	=	marketquoteData.RE_Temperature_Gain_USD_BB6__c;
					temperatureCTSLVal	=	marketquoteData.RE_Temperature_Gain_S_cent_l__c;
				}
			}        
            else{
                if(marketquoteData.RE_Tracker__c == 'D-1')
                    oldmarketquoteList.add(marketquoteData);
            }
        } 
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D','D-1')
            AND RE_Quote_Type__c IN ('Assessed Premium')
            AND RE_Quote_Name__c IN ('Distillation Discount')
        ]){
            if(marketquoteData.RE_Tracker__c =='D'){
                latestmarketquoteList.add(marketquoteData);	
            }
            else{
                if(marketquoteData.RE_Tracker__c == 'D-1')
                    oldmarketquoteList.add(marketquoteData);
            }
        }
        Integer index = 3;
		//temperature
        List<MOPSDataWrapper> mopsdatalist = new List<MOPSDataWrapper>();
        for(RE_Market_Quotes__c todaymops : latestmarketquoteList){
            MOPSDataWrapper mopdata = new MOPSDataWrapper();
            mopdata.item = todaymops.RE_Quote_Name__c;
            mopdata.dailyval = todaymops.RE_Price__c;
            mopdata.lastdayval = 0; 
			mopdata.diff = todaymops.RE_Price__c;
            mopdata.temperature	=	temperatureVal;
			mopdata.temperatureCTSL = temperatureCTSLVal;
			if(mopdata.item == 'Gasoil 0.001% S')
                mopdata.index = 1;
            else if(mopdata.item == 'Gasoil 0.001% Premium')
                mopdata.index = 2;
            else{
                mopdata.index = index;
                index = index + 1;
            }
            for(RE_Market_Quotes__c yesterdaymops : oldmarketquoteList){
                if(todaymops.RE_Quote_Name__c == yesterdaymops.RE_Quote_Name__c){                    
                    mopdata.lastdayval = yesterdaymops.RE_Price__c;  
                    mopdata.diff = todaymops.RE_Price__c - yesterdaymops.RE_Price__c;  
                }
            }
            mopsdatalist.add(mopdata);
        }
        mopsdatalist.sort();
        return mopsdatalist;
    }
    
    @AuraEnabled
    public Static List<MOPSDataWrapper> getMOPSData(){
        List<RE_Market_Quotes__c> latestmarketquoteList = new List<RE_Market_Quotes__c>();
        List<RE_Market_Quotes__c> oldmarketquoteList = new List<RE_Market_Quotes__c>();
		Double temperatureVal = 0.00;
		Double temperatureCTSLVal = 0.00;
		
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c,RE_Temperature_Gain_S_cent_l__c,RE_Temperature_Gain_USD_BB6__c 
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D','D-1')
            AND RE_Quote_Type__c IN ('Settlement','Market Premium')
            AND RE_Quote_Name__c IN ('Gasoil 0.25% S', 'Gasoil 0.05% S','Gasoil 0.005% S','Kero','MOGAS 95','MOGAS 97','Gasoil 0.001% S','Kero Premium','Gasoil 0.001% Premium')
            ORDER BY RE_Quote_Type__c ASC //RE_Quote_Name__c ASC
        ]){
            if(marketquoteData.RE_Tracker__c =='D'){
                latestmarketquoteList.add(marketquoteData);
				if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S'){
					temperatureVal	=	marketquoteData.RE_Temperature_Gain_USD_BB6__c;
					temperatureCTSLVal	=	marketquoteData.RE_Temperature_Gain_S_cent_l__c;
				}
			}        
            else{
                if(marketquoteData.RE_Tracker__c == 'D-1')
                    oldmarketquoteList.add(marketquoteData);
            }
        } 
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D','D-1')
            AND RE_Quote_Type__c IN ('Assessed Premium')
            AND RE_Quote_Name__c IN ('Distillation Discount')
        ]){
            if(marketquoteData.RE_Tracker__c =='D'){
                latestmarketquoteList.add(marketquoteData);
            }
            else{
                if(marketquoteData.RE_Tracker__c == 'D-1')
                    oldmarketquoteList.add(marketquoteData);
            }
        }
		//temperature
        List<MOPSDataWrapper> mopsdatalist = new List<MOPSDataWrapper>();
        for(RE_Market_Quotes__c todaymops : latestmarketquoteList){
            MOPSDataWrapper mopdata = new MOPSDataWrapper();
            mopdata.item = todaymops.RE_Quote_Name__c;
            mopdata.dailyval = todaymops.RE_Price__c;
            mopdata.lastdayval = 0; 
			mopdata.diff = todaymops.RE_Price__c;
            mopdata.temperature	=	temperatureVal;//((MOPS10PPM + SpotPrem10ppm - QTYPREMIAGBE37) * 0.016).setscale(3);
			mopdata.temperatureCTSL = temperatureCTSLVal;//((MOPS10PPMCTSL + SpotPrem10ppmCTSL - QTYPREMIAGBE37CTSL) * 0.016).setscale(3);
			
            for(RE_Market_Quotes__c yesterdaymops : oldmarketquoteList){
                if(todaymops.RE_Quote_Name__c == yesterdaymops.RE_Quote_Name__c){                    
                    mopdata.lastdayval = yesterdaymops.RE_Price__c;  
                    mopdata.diff = todaymops.RE_Price__c - yesterdaymops.RE_Price__c;  
                }
            }
            mopsdatalist.add(mopdata);
        }
        return mopsdatalist;
    }
    
    public static List<String> getSingProdData(){
        Integer maxRunCount;
        List<RE_SG_CostPrice__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_SG_CostPrice__c 
                                                  WHERE RE_Pricing_Date__c = Today ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(!costDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
        
        List<String> SingProdData = new List<String>();
        List<RE_SG_CostPrice__c> costList = [SELECT RE_Costprice_Laid_Down_Cost__c,RE_Costprice_Marginal_Cost__c,RE_Costprice_Unit__c,
                                             RE_Product_Name__r.Name,RE_FX_Laid_Down_Cost__c, RE_FX_Marginal_Cost__c
                                             FROM RE_SG_CostPrice__c 
                                             WHERE RE_Pricing_Date__c = Today
                                             AND RE_Job_Run_Count__c = :maxRunCount
                                             ORDER BY RE_Product_Name__r.Name];
        for(RE_SG_CostPrice__c c: costList)
        {
            SingProdData.add(c.RE_Product_Name__r.Name);
            
        } 
        return SingProdData;        
    }
    
    @AuraEnabled
    public static InitialDetailsWrapper getInitParameterDetails(Id userId){              
        
        InitialDetailsWrapper initialDetails = 	new InitialDetailsWrapper();
        initialDetails.validProfile 		 = 	getUserInfo(userId);
        initialDetails.lastJobRun			 =	(lastJobRun()).format('dd/MM/yyyy hh:mm a');
        initialDetails.mops					 =	getMOPSData();
        initialDetails.fxDatas		         =  getFxData();
        initialDetails.costingdata			 =	getSingOutput('Singapore Output');	
        //initialDetails.listProdName          =  getSingProdData();
        return initialDetails;
        
    }    
	
     @AuraEnabled
    public static InitialDetailsWrapper getInitParameterDetailsMobile(Id userId){              
        
        InitialDetailsWrapper initialDetails = 	new InitialDetailsWrapper();
        initialDetails.validProfile 		 = 	getUserInfo(userId);
        initialDetails.lastJobRun			 =	(lastJobRun()).format('dd/MM/yyyy hh:mm a');
        initialDetails.mops					 =	getMobileMOPSData();
        initialDetails.fxDatas		         =  getFxData();
        initialDetails.costingdata			 =	getSingOutput('Singapore Output');	
        //initialDetails.listProdName          =  getSingProdData();
        return initialDetails;
        
    }  
    
    @AuraEnabled
    public Static List<RE_Market_Quotes__c> fetchMarketQuoteMidday(){
        map<Integer,RE_Market_Quotes__c> marketquotemap = new Map<Integer, RE_Market_Quotes__c>();
        List<RE_Market_Quotes__c> finalmarketquotelist = new List<RE_Market_Quotes__c>();
        List<Integer> sortedlist = new List<Integer>();
        for(RE_Market_Quotes__c mqdata : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,Id,RE_Temperature_Gain_S_cent_l__c,RE_Temperature_Gain_USD_BB6__c 
            FROM RE_Market_Quotes__c
            WHERE RE_Quote_Type__c = 'Midday'
            AND createddate = Today
            AND RE_Quote_Name__c IN ('Gasoil 0.001% S','Gasoil 0.001% Premium','Kero','Kero Premium','Gasoil 0.05% S','Gasoil 0.25%S','Gasoil 0.005%S',
                                     'MOGAS 95','MOGAS 97','Distillation Discount')
            ORDER BY RE_Quote_Name__c]){
                if(mqdata.RE_Quote_Name__c == 'Gasoil 0.001% S')
                    marketquotemap.put(1, mqdata);
                if(mqdata.RE_Quote_Name__c == 'Gasoil 0.001% Premium')
                    marketquotemap.put(2, mqdata);
                if(mqdata.RE_Quote_Name__c == 'Gasoil 0.05% S')
                    marketquotemap.put(3, mqdata);
                if(mqdata.RE_Quote_Name__c == 'Kero')
                    marketquotemap.put(4, mqdata);
                if(mqdata.RE_Quote_Name__c == 'Kero Premium')
                    marketquotemap.put(5, mqdata);               
                if(mqdata.RE_Quote_Name__c == 'Gasoil 0.25% S')
                    marketquotemap.put(7, mqdata);
                if(mqdata.RE_Quote_Name__c == 'Gasoil 0.005% S')
                    marketquotemap.put(8, mqdata);
                if(mqdata.RE_Quote_Name__c == 'MOGAS 95')
                    marketquotemap.put(9, mqdata);
                if(mqdata.RE_Quote_Name__c == 'MOGAS 97')
                    marketquotemap.put(10, mqdata);
                if(mqdata.RE_Quote_Name__c == 'Distillation Discount')
                    marketquotemap.put(11, mqdata);
            }
        sortedlist.addAll(marketquotemap.keySet());
        sortedlist.sort();
        for(Integer i : sortedlist){
            finalmarketquotelist.add(marketquotemap.get(i));
        }
        return finalmarketquotelist;
    }
    
    @AuraEnabled
    public Static List<RE_Market_Quotes__c> fetchMiddayTemperatureGain(){
        return ([
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,Id,RE_Temperature_Gain_S_cent_l__c,RE_Temperature_Gain_USD_BB6__c 
            FROM RE_Market_Quotes__c
            WHERE RE_Quote_Type__c = 'Midday'
            AND createddate = Today
            AND RE_Quote_Name__c IN ('Gasoil 0.001% S')
        	LIMIT 1]);
    }
    
    @AuraEnabled
    public Static void updateMiddayRecords(List<RE_Market_Quotes__c> midmqlist){
        Double MOPS10PPM = 0.00;
        Double SpotPrem10ppm = 0.00;
        Double QTYPREMIAGBE37 = 0.00;
        Double MOPS10PPMCTSL = 0.00;
        Double SpotPrem10ppmCTSL = 0.00;
        Double QTYPREMIAGBE37CTSL = 0.00;
        RE_SOQLController soqldataset = new RE_SOQLController();
        Map<String, Double> sqldata = soqldataset.fetchLatestMidFxData();
        RE_unitConversion unitconv = new RE_unitConversion();
        Id mcq;
        try{
            for(RE_Market_Quotes__c marketquoteData : midmqlist){
                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S'){
                    mcq = marketquoteData.Id;
                    MOPS10PPM	=	marketquoteData.RE_Price__c;
                    MOPS10PPMCTSL	=	marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Gasoil 0.001% S',sqldata));
                }
                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% Premium'){
                    SpotPrem10ppm	=	marketquoteData.RE_Price__c;
                    SpotPrem10ppmCTSL	=	marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Gasoil 0.001% Premium',sqldata));		
                }
                if(marketquoteData.RE_Quote_Name__c == 'Distillation Discount'){
                    QTYPREMIAGBE37 = marketquoteData.RE_Price__c;
                    QTYPREMIAGBE37CTSL = marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Distillation Discount',sqldata));
                }		                
            }               
            
            if(mcq != null){
                for(RE_Market_Quotes__c marketquoteData : midmqlist){
                    if(mcq == marketquoteData.Id){
                     	marketquoteData.RE_Temperature_Gain_USD_BB6__c	=	((MOPS10PPM + SpotPrem10ppm + QTYPREMIAGBE37) * 0.016).setscale(3);
                		marketquoteData.RE_Temperature_Gain_S_cent_l__c = ((MOPS10PPMCTSL + SpotPrem10ppmCTSL + QTYPREMIAGBE37CTSL) * 0.016).setscale(3);   
                    }                	
                }
            }
            update midmqlist;
        }
        catch(Exception ex){System.debug('Error in updating midday market quotes' + ex.getMessage());}
    }
        
    @AuraEnabled
    public static List<RE_Margin_Aspiration__c> marginalspiration(Boolean IsMidday){
        List<RE_Margin_Aspiration__c> margaspList = [SELECT RE_Index__c,RE_Margins_USD_BBL__c, Id, RE_Price_Levels_SGD_CTS_LTR__c, RE_IsMidday__c 
                FROM RE_Margin_Aspiration__c 
                WHERE RE_IsMidday__c =:IsMidday 
                AND RE_IsLatest__c = True
                AND createddate = Today
                ORDER BY RE_Index__c];  
        if(margaspList.isEmpty()){
            return createmarginalspiration(IsMidday);
        }
        else
            return margaspList;        
	} 
    
    public static List<RE_Margin_Aspiration__c> createmarginaspirationonTrigger(List<RE_SG_CostPrice__c> SGCostList){
        Boolean IsMidday;
        for(RE_SG_CostPrice__c sgcostdata : SGCostList){
            IsMidday = sgcostdata.RE_IsMidday__c == True ? True : False;            
            break;                
        }
        return createmarginalspiration(IsMidday);
    }
    
    @AuraEnabled
	public static List<RE_Margin_Aspiration__c> createmarginalspiration(Boolean IsMidday){
        Double fxrate;
        String quotetype;
        List<RE_Margin_Aspiration__c> oldmarginaspirlist = new List<RE_Margin_Aspiration__c>();
        List<RE_Margin_Aspiration__c> todaymarginaspirlist = new List<RE_Margin_Aspiration__c>();
        for(RE_Margin_Aspiration__c masp : [SELECT id, RE_IsLatest__c FROM RE_Margin_Aspiration__c WHERE RE_IsLatest__c = True AND RE_IsMidday__c =:IsMidday AND createddate != Today] ){
            masp.RE_IsLatest__c = False;
            oldmarginaspirlist.add(masp);
        }
        for(RE_Margin_Aspiration__c maspdat : [SELECT id FROM RE_Margin_Aspiration__c WHERE createddate = Today AND RE_IsMidday__c =:IsMidday] ){
            todaymarginaspirlist.add(maspdat);
        }
        
        List<RE_Margin_Aspiration__c> marginaspirlist = new List<RE_Margin_Aspiration__c>();
        Map<Integer,Double> marginlabellist = new Map<Integer,Double>(); 
        Integer count = 3;
        for(String marginlabel : System.Label.RE_Margin_Aspiration.split(';')){
            marginlabellist.put(count,Double.valueOf(marginlabel));
            count = count +1;
        }             
        RE_SOQLController sql = new RE_SOQLController();
        if(IsMidday == True){
        	fxrate = sql.fetchSGFxDataforMidDay();
            quotetype = 'Midday';
        }  
        else{
            fxrate = sql.fetchSGFxData();	
            quotetype = 'Settlement';
        }
        List<RE_SG_CostPrice__c> igo10ppmdata = [
            SELECT RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c,RE_Location_Name__r.Name,RE_Location_Name__r.RE_Region_Name__c,
            RE_Costprice_Marginal_Cost__c,RE_Costprice_Laid_Down_Cost__c,RE_Product_Name__r.Name,RE_FX_Laid_Down_Cost__c,RE_FX_Marginal_Cost__c,RE_MC0_Diff__c
            FROM RE_SG_CostPrice__c 
            WHERE RE_Pricing_Date__c = Today            
            AND RE_IsLatest__c = True
            AND RE_IsMidday__c =: IsMidday 
            AND RE_Product_Name__r.Name = 'IGO 10ppm'
        ];
        
        List<RE_Market_Quotes__c> marketquoteData = [
            SELECT Id,NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c,RE_Temperature_Gain_USD_BB6__c 
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D')            
            AND RE_Quote_Name__c IN ('Gasoil 0.001% S')
            AND RE_Quote_Type__c =: quotetype
        ];
        
        if(!marketquoteData.isEmpty() && !igo10ppmdata.isEmpty() && fxrate != null){
            RE_Margin_Aspiration__c madata1 = new RE_Margin_Aspiration__c();   
            madata1.RE_Price_Levels_SGD_CTS_LTR__c = igo10ppmdata[0].RE_FX_Marginal_Cost__c;
            madata1.RE_Margins_USD_BBL__c = marketquoteData[0].RE_Temperature_Gain_USD_BB6__c;
            madata1.RE_Index__c = 2;
			madata1.RE_IsMidday__c = IsMidday;
            madata1.RE_IsLatest__c = True;
            marginaspirlist.add(madata1);
            RE_Margin_Aspiration__c madata2 = new RE_Margin_Aspiration__c();   
            madata2.RE_Price_Levels_SGD_CTS_LTR__c = igo10ppmdata[0].RE_MC0_Diff__c;
            madata2.RE_Margins_USD_BBL__c = marketquoteData[0].RE_Temperature_Gain_USD_BB6__c - ((igo10ppmdata[0].RE_FX_Marginal_Cost__c - igo10ppmdata[0].RE_MC0_Diff__c) * Double.valueOf(System.Label.RE_BBL_to_LTR)/(100 *fxrate));
            madata2.RE_Index__c = 1;
			madata2.RE_IsMidday__c = IsMidday;
            madata2.RE_IsLatest__c = True;
            marginaspirlist.add(madata2);
            for(Integer marginaldata : marginlabellist.keyset()){
                RE_Margin_Aspiration__c madata = new RE_Margin_Aspiration__c();  
                madata.RE_Margins_USD_BBL__c = marginlabellist.get(marginaldata);
                madata.RE_Price_Levels_SGD_CTS_LTR__c = igo10ppmdata[0].RE_FX_Marginal_Cost__c + ((madata.RE_Margins_USD_BBL__c - marketquoteData[0].RE_Temperature_Gain_USD_BB6__c)* 100 * fxrate/ Double.valueOf(System.Label.RE_BBL_to_LTR));
                madata.RE_Index__c = marginaldata;
				madata.RE_IsMidday__c = IsMidday;
                madata.RE_IsLatest__c = True;
                marginaspirlist.add(madata);
            }
        }
		if(!marginaspirlist.isEmpty()){
			try{
                if(!oldmarginaspirlist.isEmpty())
                    update oldmarginaspirlist;
                if(!todaymarginaspirlist.isEmpty())
                    delete todaymarginaspirlist;
				insert marginaspirlist;
			}
			catch(Exception ex)
            {System.debug('Error in inserting Margin Aspiration');}
		}
		return marginaspirlist;        
    }
    
    @AuraEnabled
    //getting MC and LDC values 
    public static list<mcldcWrap> getSingOutput(String type){  
        Map<String,RE_Product__c> productMap = new Map<String,RE_Product__c>();	
        Map<String,RE_SG_CostPrice__c> SGCostPriceMap = new Map<String,RE_SG_CostPrice__c>();	
		RE_MY_Output__c morningoutput = new RE_MY_Output__c();
        Integer jobruncount = maxRunCountMethod(type);
        
        if(type == 'Singapore Output'){
            for(RE_SG_CostPrice__c costprice : [
                SELECT RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c,RE_Location_Name__r.Name,RE_Product_Name__r.Name,RE_MC0_Diff__c
                FROM RE_SG_CostPrice__c 
                WHERE RE_Pricing_Date__c = Today            
                AND RE_IsLatest__c = True
                AND RE_IsMidday__c = False]){
                SGCostPriceMap.put(costprice.RE_Product_Name__r.Name,costprice);
            }
        }
        List<RE_MY_Output__c> outputLst=[
            SELECT RE_FuelSave95_MC_Diff__c,RE_FuelSave95_MC__c,RE_FuelSave98_MC_Diff__c,
            RE_FuelSave98_MC__c,RE_Fuelsave_Diesel_MC_Diff__c,RE_Fuelsave_Diesel_MC__c,RE_IGO_10ppm_MC_Diff__c,
            RE_IGO_10ppm_MC__c,RE_Kero_MC_Diff__c,RE_Kero_MC__c,RE_MGO_0_1_MC_Diff__c,RE_MGO_0_1_MC__c, RE_MGO_0_5_MC_Diff__c,RE_MGO_0_5_MC__c,
            RE_IGO_10ppm_LDC_Diff__c,RE_Depot_Name__c, RE_FuelSave95_LDC_Diff__c,RE_FuelSave95_LDC__c,RE_FuelSave98_LDC__c,RE_FuelSave98_LDC_Diff__c,
            RE_Fuelsave_Diesel_LDC_Diff__c,RE_Fuelsave_Diesel_LDC__c,RE_IGO_10ppm_LDC__c, RE_Kero_LDC_Diff__c,RE_Kero_LDC__c,RE_Vpower_MC_Diff__c,
            RE_MGO_0_1_LDC_Diff__c,RE_MGO_0_1_LDC__c,RE_MGO_0_5_LDC_Diff__c,RE_MGO_0_5_LDC__c,RE_Vpower_LDC_Diff__c,RE_Vpower_MC__c,                                        
            RE_Vpower_LDC__c  FROM RE_MY_Output__c WHERE RE_Pricing_Date__c = Today AND RE_IsLatest__c = True AND RE_Type__c =: type
        ];
        System.debug('outputLst '+outputLst);
        if(type == 'SG Midday Output'){
			 morningoutput = [
				SELECT RE_FuelSave95_MC__c,RE_FuelSave98_MC__c,RE_Fuelsave_Diesel_MC__c,
				RE_IGO_10ppm_MC__c,RE_Kero_MC__c,RE_MGO_0_1_MC__c,RE_MGO_0_5_MC__c,RE_Depot_Name__c, RE_Vpower_MC__c     
				FROM RE_MY_Output__c 
				WHERE RE_IsLatest__c = True
				AND RE_Type__c = 'Singapore Output'
				LIMIT 1
			];	
            for(RE_SG_CostPrice__c costprice : [
                SELECT RE_Pricing_Date__c,RE_Location_Name__c,RE_Product_Name__c,RE_Location_Name__r.Name,RE_Product_Name__r.Name,RE_MC0_Diff__c
                FROM RE_SG_CostPrice__c 
                WHERE RE_Pricing_Date__c = Today            
                AND RE_IsLatest__c = True
                AND RE_IsMidday__c = True]){
                SGCostPriceMap.put(costprice.RE_Product_Name__r.Name,costprice);
            }
		}
		
        for(RE_Product__c prod : [
            SELECT Name,Id,RE_Midday_MC0_Valid_From__c,RE_Midday_MC0_Valid_To__c,RE_Midday_MC0_Value__c,
            RE_Morning_MC0_Valid_From__c,RE_Morning_MC0_Valid_To__c,RE_Morning_MC0_Value__c
            FROM RE_Product__c 
            WHERE RE_Country__r.Name = 'Singapore'
        ]){
            productMap.put(prod.Name,prod);
        }
        
        List<mcldcWrap> lstWrap = new List<mcldcWrap>();
        if(! productMap.isEmpty() && morningoutput != null){
            for(RE_MY_Output__c singOutput: outputLst){
                if(productMap.containsKey('Kero')){
                    mcldcWrap objWrapKero = new mcldcWrap();
                    objWrapKero.prodName = productMap.get('Kero').Name;                    
                    objWrapKero.marginalCostSGD = singOutput.RE_Kero_MC__c == null ? 0 : singOutput.RE_Kero_MC__c;
                    objWrapKero.laidDownCostSGD = singOutput.RE_Kero_LDC__c == null ? 0 : singOutput.RE_Kero_LDC__c;
                    objWrapKero.mcDiff = singOutput.RE_Kero_MC_Diff__c == null ? 0 : singOutput.RE_Kero_MC_Diff__c;
					if(type == 'SG Midday Output')
						objWrapKero.middayDiff = objWrapKero.marginalCostSGD - morningoutput.RE_Kero_MC__c;
                    lstWrap.add(objWrapKero);
                }
                if(productMap.containsKey('MGO 0.1%')){
                    mcldcWrap objWrapMGO01 = new mcldcWrap();
                    objWrapMGO01.prodName  = productMap.get('MGO 0.1%').Name;
                    objWrapMGO01.marginalCostSGD = singOutput.RE_MGO_0_1_MC__c == null ? 0 : singOutput.RE_MGO_0_1_MC__c;
                    objWrapMGO01.laidDownCostSGD = singOutput.RE_MGO_0_1_LDC__c == null ? 0 : singOutput.RE_MGO_0_1_LDC__c;
                    objWrapMGO01.mcDiff = singOutput.RE_MGO_0_1_MC_Diff__c == null ? 0 : singOutput.RE_MGO_0_1_MC_Diff__c;
					if(type == 'SG Midday Output')
						objWrapMGO01.middayDiff = objWrapMGO01.marginalCostSGD - morningoutput.RE_MGO_0_1_MC__c;
                    lstWrap.add(objWrapMGO01);
                }
                if(productMap.containsKey('MGO 0.5%')){
                    mcldcWrap objWrapMGO05 = new mcldcWrap();
                    objWrapMGO05.prodName  = productMap.get('MGO 0.5%').Name;
                    objWrapMGO05.marginalCostSGD = singOutput.RE_MGO_0_5_MC__c == null ? 0 : singOutput.RE_MGO_0_5_MC__c;
                    objWrapMGO05.laidDownCostSGD = singOutput.RE_MGO_0_5_LDC__c == null ? 0 : singOutput.RE_MGO_0_5_LDC__c;
                    objWrapMGO05.mcDiff = singOutput.RE_MGO_0_5_MC_Diff__c == null ? 0 : singOutput.RE_MGO_0_5_MC_Diff__c;
					if(type == 'SG Midday Output')
						objWrapMGO05.middayDiff = objWrapMGO05.marginalCostSGD - morningoutput.RE_MGO_0_5_MC__c;
                    lstWrap.add(objWrapMGO05);
                }
                if(productMap.containsKey('Fuelsave Diesel')){
                    mcldcWrap objWrapFuelSav = new mcldcWrap();
                    objWrapFuelSav.prodName  = productMap.get('Fuelsave Diesel').Name;
                    objWrapFuelSav.marginalCostSGD = singOutput.RE_Fuelsave_Diesel_MC__c == null ? 0 : singOutput.RE_Fuelsave_Diesel_MC__c;
                    objWrapFuelSav.laidDownCostSGD = singOutput.RE_Fuelsave_Diesel_LDC__c == null ? 0 : singOutput.RE_Fuelsave_Diesel_LDC__c;
                    objWrapFuelSav.mcDiff = singOutput.RE_Fuelsave_Diesel_MC_Diff__c == null ? 0 : singOutput.RE_Fuelsave_Diesel_MC_Diff__c;
					if(type == 'SG Midday Output')
						objWrapFuelSav.middayDiff = objWrapFuelSav.marginalCostSGD - morningoutput.RE_Fuelsave_Diesel_MC__c;
                    lstWrap.add(objWrapFuelSav);
                }
                if(productMap.containsKey('FuelSave95')){
                    mcldcWrap objWrapFuelSav95 = new mcldcWrap();
                    objWrapFuelSav95.prodName  = productMap.get('FuelSave95').Name;
                    objWrapFuelSav95.marginalCostSGD = singOutput.RE_FuelSave95_MC__c == null ? 0 : singOutput.RE_FuelSave95_MC__c;
                    objWrapFuelSav95.laidDownCostSGD = singOutput.RE_FuelSave95_LDC__c == null ? 0 : singOutput.RE_FuelSave95_LDC__c;
                    objWrapFuelSav95.mcDiff = singOutput.RE_FuelSave95_MC_Diff__c == null ? 0 : singOutput.RE_FuelSave95_MC_Diff__c;
					if(type == 'SG Midday Output')
						objWrapFuelSav95.middayDiff = objWrapFuelSav95.marginalCostSGD - morningoutput.RE_FuelSave95_MC__c;
                    lstWrap.add(objWrapFuelSav95);
                }
                if(productMap.containsKey('Vpower')){
                    mcldcWrap objWrapVpower = new mcldcWrap();
                    objWrapVpower.prodName  = productMap.get('Vpower').Name;
                    objWrapVpower.marginalCostSGD = singOutput.RE_Vpower_MC__c == null ? 0 : singOutput.RE_Vpower_MC__c;
                    objWrapVpower.laidDownCostSGD = singOutput.RE_Vpower_LDC__c == null ? 0 : singOutput.RE_Vpower_LDC__c;
                    objWrapVpower.mcDiff = singOutput.RE_Vpower_MC_Diff__c == null ? 0 : singOutput.RE_Vpower_MC_Diff__c;
					if(type == 'SG Midday Output')
						objWrapVpower.middayDiff = objWrapVpower.marginalCostSGD - morningoutput.RE_Vpower_MC__c;
                    lstWrap.add(objWrapVpower);
                }
                if(productMap.containsKey('FuelSave98')){
                    mcldcWrap objWrapFuelSav98 = new mcldcWrap();
                    objWrapFuelSav98.prodName  = productMap.get('FuelSave98').Name;
                    objWrapFuelSav98.marginalCostSGD = singOutput.RE_FuelSave98_MC__c == null ? 0 : singOutput.RE_FuelSave98_MC__c;
                    objWrapFuelSav98.laidDownCostSGD = singOutput.RE_FuelSave98_LDC__c == null ? 0 : singOutput.RE_FuelSave98_LDC__c;
                    objWrapFuelSav98.mcDiff = singOutput.RE_FuelSave98_MC_Diff__c == null ? 0 : singOutput.RE_FuelSave98_MC_Diff__c;
					if(type == 'SG Midday Output')
						objWrapFuelSav98.middayDiff = objWrapFuelSav98.marginalCostSGD - morningoutput.RE_FuelSave98_MC__c;
                    lstWrap.add(objWrapFuelSav98);
                }
                if(productMap.containsKey('IGO 10ppm')){
                    mcldcWrap objWrapIGO = new mcldcWrap();
                    objWrapIGO.prodName  = productMap.get('IGO 10ppm').Name;
                    objWrapIGO.marginalCostSGD = singOutput.RE_IGO_10ppm_MC__c == null ? 0 : singOutput.RE_IGO_10ppm_MC__c;
                    objWrapIGO.laidDownCostSGD = singOutput.RE_IGO_10ppm_LDC__c == null ? 0 : singOutput.RE_IGO_10ppm_LDC__c;
                    objWrapIGO.mcDiff = singOutput.RE_IGO_10ppm_MC_Diff__c == null ? 0 : singOutput.RE_IGO_10ppm_MC_Diff__c;
                    objWrapIGO.mc0dipDisc = SGCostPriceMap.get('IGO 10ppm').RE_MC0_Diff__c;                    
					if(type == 'SG Midday Output')
						objWrapIGO.middayDiff = objWrapIGO.marginalCostSGD - morningoutput.RE_IGO_10ppm_MC__c;					
                    lstWrap.add(objWrapIGO);
                }                
            }            
        }
        return lstWrap;        
    }
    
    @AuraEnabled
    public static Boolean fetchmiddaydata(){
        List<RE_MY_Output__c> middaylist = [SELECT Id FROM RE_MY_Output__c WHERE RE_Pricing_Date__c = Today AND RE_Type__c = 'SG Midday Output'];
        if(!middaylist.isEmpty())
            return true;
        else
            return false;
    }
      
    
    public class InitialDetailsWrapper{
        @AuraEnabled 
        public Boolean 				  validProfile   { get; set; }
        
        @AuraEnabled
        public List<FxDataWrapper> 	  fxDatas 		 { get; set; }
        
        @AuraEnabled
        public List<MOPSDataWrapper>  mops 	  	  { get; set; }
        
        @AuraEnabled
        public List<mcldcWrap>  costingdata 	 { get; set; }
        
        @AuraEnabled
        public String 				 lastJobRun   { get; set; }
        
        @AuraEnabled 
        public List<String> 	  listProdName   { get; set; }
    }
       
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class FxDataWrapper{
        @AuraEnabled
        public String item{get;set;}
        @AuraEnabled
        public Double dailyval{get;set;}
        @AuraEnabled
        public Double lastdayval{get;set;}
        @AuraEnabled
        public Double diff{get;set;}        
    }
    
    global class MOPSDataWrapper implements Comparable{
        @AuraEnabled
        public String item{get;set;}
        @AuraEnabled
        public Double dailyval{get;set;}
        @AuraEnabled
        public Double lastdayval{get;set;}
        @AuraEnabled
        public Double diff{get;set;}
		@AuraEnabled
        public Double temperature{get;set;}
		@AuraEnabled
        public Double temperatureCTSL{get;set;}
        @AuraEnabled
        public Integer index {get;set;}
        global Integer compareTo(Object ObjToCompare) {
            MOPSDataWrapper mp = (MOPSDataWrapper)objToCompare;
            if (index == mp.index){
                return 0;
            }
            else if (index > mp.index){
                return 1;
            }
            else{
                return -1;        
            }
        }
    }
    
    public class mcldcWrap{
        @AuraEnabled
        public string prodName{get;set;}        
        @AuraEnabled
        public decimal marginalCostSGD{get;set;}        
        @AuraEnabled
        public decimal laidDownCostSGD{get;set;}
        @AuraEnabled
        public decimal mc0dipDisc{get;set;}
        @AuraEnabled
        public decimal mcDiff{get;set;}
        @AuraEnabled
        public decimal middayDiff{get;set;}
    }           
}