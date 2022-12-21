public class RE_MarketQuotesTriggerHelper { 
    private static Boolean run = True;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }

    //Check coutry specific data
    public static Boolean checkCountry(List<RE_Market_Quotes__c> marketQuotesList ){
        Boolean isEastData = true;        
        for(RE_Market_Quotes__c marketQu : marketQuotesList ){
            if(marketQu.RE_Country_Name__c != null && marketQu.RE_Country_Name__c.contains( 'CA' )){
                isEastData = false;
            }
        }
        return isEastData;    
    }
    
    //Remove duplicate data from system
    public static void onBeforeTriggerHelper(List<RE_Market_Quotes__c> newMopsLst
                                             ,Map<ID,RE_Market_Quotes__c> oldMopsMap
                                             ,Map<ID,RE_Market_Quotes__c> newMopsMap)
    {
        list<RE_Market_Quotes__c> oldmarketDeletelist = new list<RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c oldmarketData : [
            SELECT Id,RE_Pricing_Date__c,RE_Quote_Name__c,RE_Quote_Type__c, RE_Tracker__c FROM RE_Market_Quotes__c 
            WHERE RE_Pricing_Date__c = LAST_N_DAYS:5 AND ID NOT IN: newMopsLst AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') ORDER BY RE_Pricing_Date__c DESC
        ]){
            for(RE_Market_Quotes__c newdata : newMopsLst){ 
                if(newdata.RE_Pricing_Date__c == oldmarketData.RE_Pricing_Date__c 
                   && newdata.RE_Quote_Name__c == oldmarketData.RE_Quote_Name__c
                   && newdata.RE_Quote_Type__c == oldmarketData.RE_Quote_Type__c
                   && (newdata.RE_Quote_Type__c =='Settlement' || newdata.RE_Quote_Type__c =='Assessed Premium' || newdata.RE_Quote_Type__c =='Market Premium' || newdata.RE_Quote_Type__c =='Midday' || newdata.RE_Quote_Type__c =='Freight')
                   && newdata.RE_Is_MTDWTD__c == False){
                       oldmarketDeletelist.add(oldmarketData);
                       newdata.RE_Tracker__c = oldmarketData.RE_Tracker__c;
                   }
                if(newdata.RE_Pricing_Date__c == oldmarketData.RE_Pricing_Date__c 
                   && newdata.RE_Quote_Name__c == oldmarketData.RE_Quote_Name__c
                   && newdata.RE_Quote_Type__c == oldmarketData.RE_Quote_Type__c
                   && newdata.RE_Is_MTDWTD__c == True 
                   && newdata.RE_Tracker__c == oldmarketData.RE_Tracker__c){
                       oldmarketDeletelist.add(oldmarketData);
                   }
            }                                 
        }
        
        if(!oldmarketDeletelist.isEmpty())
        {
            try{delete oldmarketDeletelist;}
            catch(Exception e)
            {System.debug('Failed while delete to Market Quotes '+e.getMessage());}
        }
    }    
    public static void temperaturegaincalculation(){
       //condition is added in CBU Execute automate jon only.
       
        /*Boolean isMops;
        for(RE_Market_Quotes__c mqdata : newMopsLst){
            if(mqdata.RE_Quote_Type__c == 'Settlement' || mqdata.RE_Quote_Type__c == 'Market Premium' || mqdata.RE_Quote_Type__c == 'Assessed Premium' ){
                isMops = True;
            }
            else{
                isMops = False;
                break;
            }
        }*/
       // if(isMops){
            Double MOPS10PPM = 0.00;
            Double SpotPrem10ppm = 0.00;
            Double QTYPREMIAGBE37 = 0.00;
            Double MOPS10PPMCTSL = 0.00;
            Double SpotPrem10ppmCTSL = 0.00;
            Double QTYPREMIAGBE37CTSL = 0.00;
            Double MOPS10PPMCTMYRL = 0.00;
            Double SpotPrem10ppmCTMYRL = 0.00;
            Double QTYPREMIAGBE37CTMYRL = 0.00;
            RE_SOQLController soqldataset = new RE_SOQLController();
            Map<String, Double> sqldata = soqldataset.fetchLatestFxData();
            RE_unitConversion unitconv = new RE_unitConversion();
            RE_Market_Quotes__c mcq;
            Integer i = 0;
            for(RE_Market_Quotes__c marketquoteData : [
                SELECT Id,NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c,RE_Quote_Type__c 
                FROM RE_Market_Quotes__c
                WHERE createddate = Today
                AND RE_Quote_Type__c IN ('Settlement','Market Premium','Assessed Premium')
                AND RE_Quote_Name__c IN ('Gasoil 0.001% S', 'Gasoil 0.001% Premium','Distillation Discount')
                AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
                ORDER BY RE_Quote_Type__c ASC])
            {			                
                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S'){
                    mcq = new RE_Market_Quotes__c();
                    mcq.Id= marketquoteData.Id;
                    MOPS10PPM	=	marketquoteData.RE_Price__c;
                    MOPS10PPMCTSL	=	marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Gasoil 0.001% S',sqldata));
                    //MOPS10PPMCTMYRL =   marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','MYR CTS/LTR','Malaysia','Gasoil 0.001% S',sqldata));
                    i=i+1;
                }
                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% Premium'){
                    SpotPrem10ppm	=	marketquoteData.RE_Price__c;
                    SpotPrem10ppmCTSL	=	marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Gasoil 0.001% Premium',sqldata));	
                    //SpotPrem10ppmCTMYRL =   marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','MYR CTS/LTR','Malaysia','Gasoil 0.001% Premium',sqldata));	
                    i=i+1;
                }
                if(marketquoteData.RE_Quote_Name__c == 'Distillation Discount'){
                    QTYPREMIAGBE37 = marketquoteData.RE_Price__c;
                    QTYPREMIAGBE37CTSL = marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','SGD CTS/LTR','Singapore','Distillation Discount',sqldata));
                   // QTYPREMIAGBE37CTMYRL = marketquoteData.RE_Price__c * (unitconv.unitConversionMultiplier('USD/BBL','MYR CTS/LTR','Malaysia','Distillation Discount',sqldata));
                    i=i+1;
                }		
                
            }    
			System.debug('i-->'+i);            
            if(mcq != null && i == 3){
                mcq.RE_Temperature_Gain_USD_BB6__c	=	((MOPS10PPM + SpotPrem10ppm + QTYPREMIAGBE37) * 0.016).setscale(3);
                mcq.RE_Temperature_Gain_S_cent_l__c = ((MOPS10PPMCTSL + SpotPrem10ppmCTSL + QTYPREMIAGBE37CTSL) * 0.016).setscale(3);
                mcq.Temperature_Gain_MY_cent_l__c =   (mcq.RE_Temperature_Gain_USD_BB6__c * (unitconv.unitConversionMultiplier('USD/BBL','MYR CTS/LTR','Malaysia','Distillation Discount',sqldata))).setscale(3);
                   // ((MOPS10PPMCTMYRL + SpotPrem10ppmCTMYRL + QTYPREMIAGBE37CTMYRL) * 0.016).setscale(3);
                try{
                    Update mcq;
                }
                Catch(Exception ex){
                    System.debug('Failed to update Temperature Data in Mops '+ex.getMessage());
                }
                
                // Insert the Temp Gain value into My Output Object for Charting purpose(PBI#1448628) - Start
                try
                {
                    Id myOutputRecdTypId = Schema.SObjectType.RE_MY_Output__c.getRecordTypeInfosByDeveloperName().get('RE_Malaysia').getRecordTypeId();
                    DateTime currDateTme = System.now();
                    Date currDateOnly = Date.newInstance(currDateTme.year(), currDateTme.month(), currDateTme.day());
                    
                    RE_MY_Output__c myOP = New RE_MY_Output__c();
                    myOP.RecordTypeId = myOutputRecdTypId;
                    myOP.RE_Type__c = 'MY Temp Gain';
                    myOP.RE_Pricing_Date__c = currDateOnly;
                    myOP.RE_Temperature_Gain_MY_cent_l__c = mcq.Temperature_Gain_MY_cent_l__c;
                    Insert myOP;
                }
                Catch(Exception exInsert)
                {
                    System.debug('temperaturegaincalculation-MyoutputCreation-Error-->'+exInsert.getMessage());
                    System.debug('temperaturegaincalculation-MyoutputCreation-LN-->'+exInsert.getLineNumber());
                    RV_ClassException.insertExceptionRecord('temperaturegaincalculation-MyoutputCreation',exInsert.getMessage()+'-'+exInsert.getLineNumber(),'RE_MarketQuotesTriggerHelper','temperaturegaincalculation-MyoutputCreation','Exception');                                     
                } 
                // Insert the Temp Gain value into My Output Object for Charting purpose(PBI#1448628) - End        
            }     
        //}        
    }
    public static void onAfterTriggerHelper(List<RE_Market_Quotes__c> newMopsLst, Map<ID,RE_Market_Quotes__c> oldMopsMap,Map<ID,RE_Market_Quotes__c> newMopsMap){												         
        AggregateResult fscount = [SELECT count(Id) cont FROM RE_Market_Quotes__c WHERE createddate = Today AND RE_Quote_Type__c = 'Forward Swap'];
        System.debug('count '+fscount.get('cont') );
        if(fscount.get('cont') == 2 ){
            RE_MidDayPricingController a = new RE_MidDayPricingController();
            a.finalMidDayOutput();
        }
              
    }
    public static void middayoutputgenerate(List<RE_Market_Quotes__c> newMopsLst){
        Boolean isMiddayupdate = False;
        for(RE_Market_Quotes__c middayquoteData : newMopsLst){            
            if(middayquoteData.RE_Quote_Type__c == 'Forward Swap' && middayquoteData.createddate.date() == System.today()){
                isMiddayupdate = True;                
            } 
            else{
                isMiddayupdate = False;   
                break;
            }                
        } 
        System.debug('isMiddayupdate--'+isMiddayupdate);
        if(isMiddayupdate){
            AggregateResult fscount = [SELECT count(Id) cont FROM RE_Market_Quotes__c WHERE createddate = Today AND RE_Quote_Type__c = 'Forward Swap'];
            System.debug('count '+fscount.get('cont') );
            if(fscount.get('cont') == 2 ){
                RE_MidDayPricingController a = new RE_MidDayPricingController();
                a.finalMidDayOutput();
            }
        }
    }
    
    public static void onAfterMiddayInsertion(List<RE_Market_Quotes__c> newMopsLst, Map<ID,RE_Market_Quotes__c> oldMopsMap, Map<ID,RE_Market_Quotes__c> newMopsMap){
        Boolean isMidday = False;
        for(RE_Market_Quotes__c middayquoteData : newMopsLst){
            if(middayquoteData.RE_Quote_Type__c == 'Midday' && middayquoteData.RE_Pricing_Date__c == System.today()){
                isMidday = True;                
            } 
            else{
                isMidday = False;   
                break;
            }                
        }    
        System.debug('isMidday'+isMidday);
        if(isMidday)
            RE_MalayasiaOutputController.jobExecute('SG Midday Output'); 
    }
    
    public Static Boolean checkMTDWTD(List<RE_Market_Quotes__c> newMopsLst){
        Boolean isMTDWTD = False;
        for(RE_Market_Quotes__c quotes : newMopsLst){
            if(quotes.RE_Is_MTDWTD__c){
                isMTDWTD = True;
                break;
            }
		}
        return isMTDWTD;
    }
    
    public static void afterW1M1QuoteInsert(List<RE_Market_Quotes__c> newMopsLst){
        List<RE_FX_Rates__c> fxdata = new List<RE_FX_Rates__c>();
        List<String> typelist = new List<String>();
        for(RE_Market_Quotes__c quotes : newMopsLst){
            if(quotes.RE_Tracker__c != null && !typelist.contains(quotes.RE_Tracker__c)){
                typelist.add(quotes.RE_Tracker__c);
            }            
        }
        if(typelist.contains('W-1')){
            for( AggregateResult fx : [
				SELECT avg(RE_Forex_Rate__c) fxavgval FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'PHP' 
				AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Pricing_Date__c = LAST_WEEK AND RE_Is_MTDWTD__c = False
			]){
				RE_FX_Rates__c FXDataCTS   = new RE_FX_Rates__c();
				FXDataCTS.RE_Conversion_Unit__c = 'PHP';
				FXDataCTS.RE_Base_Unit__c  =  'USD'; 
				FXDataCTS.RE_Forex_Name__c = 'PHP/USD';
				FXDataCTS.RE_Trade_Type__c = 'Sell';
				FXDataCTS.RE_Pricing_Date__c = System.today();
				FXDataCTS.RE_Forex_Rate__c = (Decimal) fx.get('fxavgval');
				FXDataCTS.RE_Tracker__c = 'W-1';
                FXDataCTS.RE_Is_MTDWTD__c = True;
				fxdata.add(FXDataCTS);
			}
        }
        if(typelist.contains('M-1')){
            for( AggregateResult fx : [
				SELECT avg(RE_Forex_Rate__c) fxavgval FROM RE_FX_Rates__c WHERE RE_Conversion_Unit__c = 'PHP' 
				AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Pricing_Date__c = LAST_MONTH AND RE_Is_MTDWTD__c = False
			]){
				RE_FX_Rates__c FXDataCTS   = new RE_FX_Rates__c();
				FXDataCTS.RE_Conversion_Unit__c = 'PHP';
				FXDataCTS.RE_Base_Unit__c  =  'USD'; 
				FXDataCTS.RE_Forex_Name__c = 'PHP/USD';
				FXDataCTS.RE_Trade_Type__c = 'Sell';
				FXDataCTS.RE_Pricing_Date__c = System.today();
				FXDataCTS.RE_Forex_Rate__c = (Decimal) fx.get('fxavgval');
				FXDataCTS.RE_Tracker__c = 'M-1';
                FXDataCTS.RE_Is_MTDWTD__c = True;
				fxdata.add(FXDataCTS);
			}
        }
        if(!fxdata.isEmpty()){
            try{insert fxdata;}
            catch(Exception ex){System.debug(ex.getCause());}
        }
    }    
}