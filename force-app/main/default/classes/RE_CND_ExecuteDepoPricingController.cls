/**************************************************************************************************
* Name: RE_CND_ExecuteDepoPricingController
* Object: RE_Market_Quotes__c, RE_MOA__c, RE_MY_CostPrice__c, RE_Depot_Pricing_Backbone__c
* Purpose: Execute Market Move and Depo Pricing for Revolution Canada
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-06-09
* Modify History: 
* 2021-06-09		Abhilash		Created
**************************************************************************************************/
public with sharing class RE_CND_ExecuteDepoPricingController {
    
    public static Boolean IsSuccessJobAudit = true;   
    
    // Get the Fx Rate Value
    @AuraEnabled
    public static Decimal getFxRate(Date requestedFxDt)
    {
        Datetime requestedStartFxDt = (DateTime)requestedFxDt;
        datetime requestedEndFxDt = requestedStartFxDt.AddHours(23).AddMinutes(59).AddSeconds(59);                
        String fxLiveQuoteName;
        Decimal fxRateValue = 0.00;
        
        for(RE_Zema_Quotes_Settings__c fxQuote: [SELECT Display_Name__c FROM RE_Zema_Quotes_Settings__c 
                                                 WHERE Country__c LIKE '%Canada%' AND Type__c =:'FX Rates' 
                                                 AND Frequency__c =: 'Live' AND Is_Active__c =: TRUE LIMIT 1])
        {
            fxLiveQuoteName = fxQuote.Display_Name__c;
        }
        
        if(fxLiveQuoteName !=null)
        {
            for(RE_FX_Rates__c fx: [SELECT RE_Forex_Rate__c FROM RE_FX_Rates__c WHERE RE_Quote_Name__c =: fxLiveQuoteName
                                    AND RE_Trade_Type__c =: 'Exchange Rate' 
                                    AND RE_Pricing_Date__c >=: requestedStartFxDt AND RE_Pricing_Date__c <=: requestedEndFxDt LIMIT 1])
            {
                fxRateValue = fx.RE_Forex_Rate__c;
            }  
        }
        
        return fxRateValue;
    }
    
    // check Previous OPIS SpotTicker records exists or not
    @AuraEnabled
    public static String checkPreviousOPISSpotTickerExistsOrNot(Date requestedOpisRecevdDt)    
    {
        Id marktMveRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Market_Moves').getRecordTypeId();
        Map<string,RE_Field_Value_Mappings__c> markerMappingsNameSettings = new Map<string,RE_Field_Value_Mappings__c> ();
        Map<String,Decimal> prvDayMVData = New Map<String,Decimal>();
        String status;
        
        for(RE_Field_Value_Mappings__c mkNameMappngs: [SELECT Id, Source_Field_Value__c, Mapping_Field_Value__c FROM RE_Field_Value_Mappings__c 
                                                       WHERE Country_Name__c =: 'Canada' AND Purpose__c =:'Live OPIS Spot Ticker Import' 
                                                       AND Object_Name__c =: 'RE_MOA__c' AND Field_Name__c =: 'RE_CND_Marker_Name__c' 
                                                       AND Is_Active__c =: TRUE ORDER BY Mapping_Field_Value__c])
        {
            markerMappingsNameSettings.put(mkNameMappngs.Mapping_Field_Value__c, mkNameMappngs);
        }        
        
        // Get Previous Market Move records
        for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c
                              FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
                              AND RE_Requested_Date__c =: requestedOpisRecevdDt AND RE_IsLatest__c =: TRUE])
        {
            prvDayMVData.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);        
        } 
        
        //Iterate through markerMappingsNameSettings
        if(markerMappingsNameSettings.Size() > 0 && prvDayMVData.Size() > 0)
        {       
            status = 'received data'; 
            for(String keyName: markerMappingsNameSettings.Keyset()){    
                //if prvDayMVData does not have that key
                if(!prvDayMVData.keyset().contains(keyName)){ 
                    System.debug('Previous-Missing-OPIS-MarkerName-->'+keyName);
                    status = 'missing data';
                }    
            } 
        }
        else
            status = 'not received data';          
        
        return status;
    }
    
    // check OPIS SpotTicker records exists or not
    @AuraEnabled
    public static String checkOPISSpotTickerExistsOrNot(Date requestedOpisRecevdDt, Boolean isProcessed)
    {
        Map<string,RE_Field_Value_Mappings__c> markerMappingsNameSettings = new Map<string,RE_Field_Value_Mappings__c> ();
        Map<string,RE_Market_Quotes__c> markerMappingsName = new Map<string,RE_Market_Quotes__c> ();
        String status;        
        Id opisSpotRecordTypeId = Schema.SObjectType.RE_Market_Quotes__c.getRecordTypeInfosByDeveloperName().get('Canada_OPIS_Spot_Ticker').getRecordTypeId();
        
        for(RE_Field_Value_Mappings__c mkNameMappngs: [SELECT Id, Source_Field_Value__c, Mapping_Field_Value__c FROM RE_Field_Value_Mappings__c 
                                                       WHERE Country_Name__c =: 'Canada' AND Purpose__c =:'Live OPIS Spot Ticker Import' 
                                                       AND Object_Name__c =: 'RE_MOA__c' AND Field_Name__c =: 'RE_CND_Marker_Name__c' 
                                                       AND Is_Active__c =: TRUE ORDER BY Mapping_Field_Value__c])
        {
            markerMappingsNameSettings.put(mkNameMappngs.Source_Field_Value__c, mkNameMappngs);
        }
        
        // Get all the OPIS Marker Names on the OPIS Spot Ticker date
        for(RE_Market_Quotes__c importedMQ: [SELECT Id, RE_Quote_Name__c, RE_Price__c, RE_CND_Validity_Date__c 
                                             FROM RE_Market_Quotes__c
                                             WHERE RecordTypeId =: opisSpotRecordTypeId AND RE_CND_Validity_Date__c =: requestedOpisRecevdDt
                                             AND RE_Is_Processed__c =: isProcessed ORDER BY RE_Quote_Name__c])
        {
            markerMappingsName.put(importedMQ.RE_Quote_Name__c, importedMQ);
        }
        
        //Iterate through markerMappingsNameSettings
        if(markerMappingsNameSettings.Size() > 0 && markerMappingsName.Size() > 0)
        {       
            status = 'received data'; 
            for(String keyName: markerMappingsNameSettings.Keyset()){    
                //if markerMappingsName does not have that key
                if(!markerMappingsName.keyset().contains(keyName)){ 
                    System.debug('Live-Missing-OPIS-MarkerName-->'+keyName);
                    status = 'missing data';
                }    
            } 
        }
        else
            status = 'not received data';    
        
        return status;        
    }
    
    @AuraEnabled
    // Get the Job Audit Run status
    public static String getJobRunAuditStatus(Id jobRunAudId)
    {      
        String jobStatus = [SELECT RE_Job_Status__c FROM RE_Job_Run_Audit__c WHERE Id =: jobRunAudId].RE_Job_Status__c;
        
        return jobStatus;
    }
    
    @AuraEnabled
    public static jobRunStatusWrapper getStatusOfJobRunAudit(String jobType)
    {         
        jobRunStatusWrapper jobRunStat = New jobRunStatusWrapper();        
        RE_Job_Run_Audit__c[] jra = [SELECT Id, Name, RE_Run_Time__c, RE_Job_Status__c, RE_Batch_Job_Ids__c, Other_Comments__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c =: jobType AND CreatedDate = Today	ORDER BY CreatedDate DESC LIMIT 1];
        if(jra.Size() > 0)
        {
            if(jra[0].RE_Job_Status__c == 'Processing')
            {
                jobRunStat.jobRunName = jra[0].Name;
                jobRunStat.jobStartDateTime = jra[0].RE_Run_Time__c;
                jobRunStat.jobRunId = jra[0].Id;
                jobRunStat.batchJobIds = jra[0].RE_Batch_Job_Ids__c;
                jobRunStat.otherComments = jra[0].Other_Comments__c;
                // This indicate that already job started processing
                jobRunStat.totalRecordCount = 3;                
            }
            else      
                // This indicate that no job running with status as processing
                jobRunStat.totalRecordCount = 0;  
        }
        else             
             // This indicate that no job running with status as processing
             jobRunStat.totalRecordCount = 0;             
                
        return jobRunStat;
    }

    @AuraEnabled
    // Generate Market Move and MOA against OPIS Spot Tikcer - New
    public static executeMarketMveWrapper generateMVandMOAFromOpisSpotTickrData(Date requestedDt, Date effectiveFromDate, Date effectiveToDate, Date currOPISTikrDate, Date currFxRateDate, Decimal currFxRate, Date prevOPISTikrDate, Date prevFxRateDate, Decimal prevFxRate)
    {
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        executeMarketMveWrapper mvwrapper = new executeMarketMveWrapper();
        try
        {
            Datetime now = System.now();
            jrAudit.RE_Run_Time__c = now;
            jrAudit.RE_Run_Type__c = 'Manual';
            jrAudit.RE_Job_Type__c = 'Canada Market Move Calculation';
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c = 'Processing';
            jrAudit.RE_Country_Name__c='CA';
            insert jrAudit; 
            
            // Queueable Class
            RE_CND_GenerateMVandMOAQueue calcMVandMOAQue = New RE_CND_GenerateMVandMOAQueue(requestedDt, effectiveFromDate, effectiveToDate, currOPISTikrDate, currFxRateDate, currFxRate, prevOPISTikrDate, prevFxRateDate, prevFxRate, jrAudit.Id, now);
            // Enqueue the job for processing
            ID jobID = System.enqueueJob(calcMVandMOAQue); 
            
            mvwrapper.jobRunAuditId = jrAudit.Id;
            mvwrapper.executionStatus = 'success';           
            return mvwrapper;         
        }
        Catch(Exception ex)
        {      
            System.debug('generateMVandMOAFromOpisSpotTickrData-Error-->'+ex.getMessage());
            System.debug('generateMVandMOAFromOpisSpotTickrData-Error-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('CalculatingMarketMove',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','generateMVandMOAFromOpisSpotTickrData','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);
            mvwrapper.executionStatus = 'failed';
            mvwrapper.errorMsg = 'Failed while Calculating Market Move';  
            mvwrapper.jobRunAuditId = jrAudit.Id;
            return mvwrapper; 
        }         
    }
    
    public class executeMVandMOAWrapper 
    {       
        public Map<String,Decimal> mqPrice {get;set;}        
        public Map<String,Decimal> mqChange {get;set;}  
        public Map<String,String> mqUnitRate {get;set;}
        public Map<String,Decimal> prvDayMVData {get;set;}       
        public List<RE_MOA__c> oldMOALst {get;set;}
        public Date requestedDt {get;set;}
        public DateTime effectiveDate {get;set;}
        public Date effectiveFromDate {get;set;}
        public Date effectiveToDate {get;set;}        
        public Date currOPISTikrDate {get;set;}
        public Date currFxRateDate {get;set;}
        public Decimal currFxRate {get;set;} 
        public Date prevOPISTikrDate {get;set;}
        public Date prevFxRateDate {get;set;}
        public Decimal prevFxRate {get;set;}
        public String mvDefaultUnitRate {get;set;}
        public String epDefaultUnitRate {get;set;}
        public Map<String,String> prvDayMVBaseUnitRate {get;set;}
        public Map<String,String> prvDayMVConvertdUnitRate {get;set;}
        public Map<String,String> prvDayExePrBaseUnitRate {get;set;}
        public Map<String,String> prvDayExePrConvertdUnitRate {get;set;}  
        public String fxRateCreatUpdteStatus {get;set;}  
        public List<RE_FX_Rates__c> CurtFxLst {get;set;}  
    }    
    
    public static executeMarketMveWrapper calculateMVandMOA(RE_Job_Run_Audit__c jrAudit, Id opisSpotRecordTypeId, Id marktMveRecordTypeId, Id cadMOARecordTypeId, executeMVandMOAWrapper excMVMOAWrapr, Boolean isOnlyFxRateChanged, Set<Id> mqProcessedIds, currentDayExistingRecordsWrapper curDayRecrdWrapper)
    {
        executeMarketMveWrapper mvwrapper = new executeMarketMveWrapper();
        try
        {            
            Map<String,Decimal> prvDayMVData = New Map<String,Decimal>();
            List<RE_MOA__c> oldMOALst = New List<RE_MOA__c>();
            Map<String,Decimal> mqPrice = New Map<String,Decimal>();
            Map<String,Decimal> mqChange = New Map<String,Decimal>();  
            Map<String,String> mqUnitRate = New Map<String,String>();  
            Map<String,String> expUnitRate = New Map<String,String>();
            Decimal fxActual_Delta = 0.00;
            Decimal fxDelta_Percentage = 0.00;    
            List<RE_MOA__c> newMarktMveData = new List<RE_MOA__c>();
            String BaseCurrency, ConvertedCurrency;
            Map<String,String> prvDayMVBaseUnitRate = New Map<String,String>();
            Map<String,String> prvDayMVConvertdUnitRate = New Map<String,String>();
            Map<String,Decimal> newCADDelta = New Map<String,Decimal>();
            List<RE_MOA__c> newUpdtMarktMveData = new List<RE_MOA__c>();
            List<RE_MOA__c> newMOAData = new List<RE_MOA__c>();            
            Map<String,Decimal> baseRackMV = New Map<String,Decimal>();
            Map<String,String> prvDayExePrBaseUnitRate = New Map<String,String>();
            Map<String,String> prvDayExePrConvertdUnitRate = New Map<String,String>();  
            Decimal torontoGasolineNewEnd = 0.00;
            Decimal EdmontonGasolineNewEnd = 0.00;                    
            Decimal torontoDieselNewEnd = 0.00;
            Decimal EdmontonDieselNewEnd = 0.00;               
            List<RE_MOA__c> updatedMOA = New List<RE_MOA__c>();
            List<RE_Market_Quotes__c> updatedPrcssdStatus = New List<RE_Market_Quotes__c>(); 
            List<RE_FX_Rates__c> CurtFxLst = New List<RE_FX_Rates__c>();
            Set<Id> insertedMOAIds = New Set<Id>();              
            List<RE_MOA__c> initialVersnLst = new List<RE_MOA__c>(); 
            Decimal currFxRateToUse = 0.00;
            Decimal ltrToBblRate = 0.00;
            Decimal ltrToGalRate = 0.00;
            
            mqPrice = excMVMOAWrapr.mqPrice;
            mqChange = excMVMOAWrapr.mqChange;
            mqUnitRate = excMVMOAWrapr.mqUnitRate;
            prvDayMVData = excMVMOAWrapr.prvDayMVData;
            oldMOALst = excMVMOAWrapr.oldMOALst;
            prvDayMVBaseUnitRate = excMVMOAWrapr.prvDayMVBaseUnitRate;
            prvDayMVConvertdUnitRate = excMVMOAWrapr.prvDayMVConvertdUnitRate;
            prvDayExePrBaseUnitRate = excMVMOAWrapr.prvDayExePrBaseUnitRate;
            prvDayExePrConvertdUnitRate = excMVMOAWrapr.prvDayExePrConvertdUnitRate;   
            CurtFxLst = excMVMOAWrapr.CurtFxLst;  
            
            List<RE_MY_CostPrice__c> oldMapCostPrice = new List<RE_MY_CostPrice__c>();
            List<RT_Price_Book__c> oldPriceBookLst = new List<RT_Price_Book__c>();
            Map<String,RE_MOA__c> currtDayOldMaktMove = New Map<String,RE_MOA__c>();
            Map<String,RE_MOA__c> currtDayOldExctePrice = New Map<String,RE_MOA__c>(); 
            
            oldMapCostPrice = curDayRecrdWrapper.currtDayMapCostPriceList;            
            oldPriceBookLst = curDayRecrdWrapper.currtDayPrcBookList;
            currtDayOldMaktMove = curDayRecrdWrapper.currtDayOldMaktMoveList;            
            currtDayOldExctePrice = curDayRecrdWrapper.currtDayOldExctePriceList;   
            
            for(RE_MY_VolumeConversion__c vConver : RE_MY_VolumeConversion__c.getall().values())
            {
                if((vConver.RE_MY_Country__c == 'Canada') && (vConver.RE_MY_Base_Volume_Unit__c == 'LTR')
                   && (vConver.RE_MY_Volume_Unit__c == 'BBL'))
                {
                    ltrToBblRate = vConver.RE_MY_Conversion_Rate__c;
                }
                else if((vConver.RE_MY_Country__c == 'Canada') && (vConver.RE_MY_Base_Volume_Unit__c == 'LTR')
                        && (vConver.RE_MY_Volume_Unit__c == 'GAL'))
                {
                    ltrToGalRate = vConver.RE_MY_Conversion_Rate__c;
                }
            }
            
            RE_MOA__c newFxrate = New RE_MOA__c();	
            newFxrate.RecordTypeId = marktMveRecordTypeId;            
            newFxrate.RE_CND_Effective_Date__c = excMVMOAWrapr.effectiveDate;
            newFxrate.RE_Requested_Date__c = excMVMOAWrapr.requestedDt;
            newFxrate.RE_CND_Effective_From_Date__c = excMVMOAWrapr.effectiveFromDate;
            newFxrate.RE_CND_Effective_To_Date__c = excMVMOAWrapr.effectiveToDate;       
            newFxrate.RE_CND_Current_OPIS_Selected_Date__c = excMVMOAWrapr.currOPISTikrDate; 
            newFxrate.RE_CND_Previous_OPIS_Selected_Date__c = excMVMOAWrapr.prevOPISTikrDate; 
            newFxrate.RE_CND_Current_FxRate_Selected_Date__c = excMVMOAWrapr.currFxRateDate; 
            newFxrate.RE_CND_Previous_FxRate_Selected_Date__c = excMVMOAWrapr.prevFxRateDate;             
            newFxrate.RE_CND_Current_FxRate__c = excMVMOAWrapr.currFxRate; 
            newFxrate.RE_CND_Previous_FxRate__c = excMVMOAWrapr.prevFxRate; 
            newFxrate.RE_CND_Group__c = 'Fx Rate';
            newFxrate.RE_CND_Marker_Name__c = 'Reuters Fx';
            
            if(isOnlyFxRateChanged)
            {
                newFxrate.RE_Price_Value__c = excMVMOAWrapr.prevFxRate;   
                currFxRateToUse = excMVMOAWrapr.prevFxRate;
            }
            else
            {
                newFxrate.RE_Price_Value__c = excMVMOAWrapr.currFxRate; 
                currFxRateToUse = excMVMOAWrapr.currFxRate;
            }
            
            newFxrate.RE_Base_Rate_Unit__c = 'USD';
            newFxrate.RE_Converted_Rate_Unit__c = excMVMOAWrapr.mvDefaultUnitRate;  
            
            if(excMVMOAWrapr.currFxRate != null && excMVMOAWrapr.prevFxRate != null)
            {
                newFxrate.RE_CND_Actual_Delta__c = (excMVMOAWrapr.currFxRate - excMVMOAWrapr.prevFxRate).setScale(6);                                       
                newFxrate.RE_CND_Delta_Percentage__c = (((excMVMOAWrapr.currFxRate - excMVMOAWrapr.prevFxRate) / excMVMOAWrapr.prevFxRate)*100).setScale(2);                                     
                fxActual_Delta = newFxrate.RE_CND_Actual_Delta__c;
                fxDelta_Percentage = newFxrate.RE_CND_Delta_Percentage__c;
                newFxrate.RE_CND_PrvDay_Delta_Percentage__c = newFxrate.RE_CND_Delta_Percentage__c;
            }
            else
            {
                system.debug('prvDayMVData-->'+prvDayMVData);
                if(prvDayMVData.containsKey('Reuters Fx'))                            
                {       
                    if(isOnlyFxRateChanged)
                    {
                        newFxrate.RE_CND_Actual_Delta__c = (excMVMOAWrapr.prevFxRate - prvDayMVData.get('Reuters Fx')).setScale(6);                                       
                        newFxrate.RE_CND_Delta_Percentage__c = (((excMVMOAWrapr.prevFxRate - prvDayMVData.get('Reuters Fx')) / prvDayMVData.get('Reuters Fx'))*100).setScale(2);                                    
                    }
                    else
                    {
                        newFxrate.RE_CND_Actual_Delta__c = (excMVMOAWrapr.currFxRate - prvDayMVData.get('Reuters Fx')).setScale(6);                                       
                        newFxrate.RE_CND_Delta_Percentage__c = (((excMVMOAWrapr.currFxRate - prvDayMVData.get('Reuters Fx')) / prvDayMVData.get('Reuters Fx'))*100).setScale(2);                     
                    }
                    
                    fxActual_Delta = newFxrate.RE_CND_Actual_Delta__c;
                    fxDelta_Percentage = newFxrate.RE_CND_Delta_Percentage__c;
                    newFxrate.RE_CND_PrvDay_Delta_Percentage__c = newFxrate.RE_CND_Delta_Percentage__c;                 
                }                
            }            
            
            newMarktMveData.add(newFxrate);    
            
            RE_unitConversion unitConv = New RE_unitConversion();
            system.debug('mqPrice-->'+mqPrice);
            
            //Iterate through markerMappingsNameSettings
            for(String keyName: mqPrice.Keyset())
            { 
                //if mqMarkerName does have that key
                if(mqChange.keyset().contains(keyName))
                {                         
                    RE_MOA__c newOpis = New RE_MOA__c();
                    newOpis.RecordTypeId = marktMveRecordTypeId;
                    newOpis.RE_CND_Marker_Name__c = keyName;
                    newOpis.RE_CND_Effective_Date__c = excMVMOAWrapr.effectiveDate; 
                    newOpis.RE_Requested_Date__c = excMVMOAWrapr.requestedDt;                                       
                    newOpis.RE_CND_Effective_From_Date__c = excMVMOAWrapr.effectiveFromDate;
                    newOpis.RE_CND_Effective_To_Date__c = excMVMOAWrapr.effectiveToDate;       
                    newOpis.RE_CND_Current_OPIS_Selected_Date__c = excMVMOAWrapr.currOPISTikrDate; 
                    newOpis.RE_CND_Previous_OPIS_Selected_Date__c = excMVMOAWrapr.prevOPISTikrDate; 
                    newOpis.RE_CND_Current_FxRate_Selected_Date__c = excMVMOAWrapr.currFxRateDate; 
                    newOpis.RE_CND_Previous_FxRate_Selected_Date__c = excMVMOAWrapr.prevFxRateDate;             
                    newOpis.RE_CND_Current_FxRate__c = excMVMOAWrapr.currFxRate; 
                    newOpis.RE_CND_Previous_FxRate__c = excMVMOAWrapr.prevFxRate;  
                    newOpis.RE_Converted_Rate_Unit__c = excMVMOAWrapr.mvDefaultUnitRate;
                    newOpis.RE_Base_Rate_Unit__c = mqUnitRate.get(keyName);
                    newOpis.RE_Price_Value__c = mqPrice.get(keyName);
                    newOpis.RE_CND_Actual_Delta__c = mqChange.get(keyName);                    
                    newOpis.RE_CND_Delta_Percentage__c = ((mqChange.get(keyName) / (mqPrice.get(keyName) - mqChange.get(keyName)))*100).setScale(2);                        
                    expUnitRate.put(keyName,excMVMOAWrapr.mvDefaultUnitRate);
                    
                    Map<String,Double> currfxRateMap = New Map<String,Double>();
                    Map<String,Double> prevfxRateMap = New Map<String,Double>();
                    
                    if(mqUnitRate.get(keyName) != excMVMOAWrapr.mvDefaultUnitRate)
                    {
                        // Current day Base & Converted Unit Rate
                        BaseCurrency = RE_unitConversion.unitBreakUp(mqUnitRate.get(keyName))[0];                           
                        ConvertedCurrency = RE_unitConversion.unitBreakUp(excMVMOAWrapr.mvDefaultUnitRate)[0]; 
                        
                        if(isOnlyFxRateChanged)
                            currfxRateMap.put('CAD CTS-USD',excMVMOAWrapr.prevFxRate);
                        // currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.prevFxRate);                      
                        else
                            currfxRateMap.put('CAD CTS-USD',excMVMOAWrapr.currFxRate); 
                        //  currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.currFxRate);                      
                    }
                    else
                    {
                        if(isOnlyFxRateChanged)
                            currfxRateMap.put('CAD CTS-USD',excMVMOAWrapr.prevFxRate);                      
                        else
                            currfxRateMap.put('CAD CTS-USD',excMVMOAWrapr.currFxRate);                         
                    }
                    
                    // Previous day Base & Converted Unit Rate
                    if(prvDayMVBaseUnitRate.containsKey(keyName))
                        BaseCurrency = RE_unitConversion.unitBreakUp(prvDayMVBaseUnitRate.get(keyName))[0];
                    else
                        BaseCurrency = 'USD';
                    
                    if(prvDayMVConvertdUnitRate.containsKey(keyName))
                        ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayMVConvertdUnitRate.get(keyName))[0];
                    else
                        ConvertedCurrency = 'CAD';
                    
                    if(excMVMOAWrapr.prevFxRate != null)
                        prevfxRateMap.put('CAD CTS-USD',excMVMOAWrapr.prevFxRate);
                    else
                    {
                        if(prvDayMVData.containsKey('Reuters Fx'))
                            prevfxRateMap.put('CAD CTS-USD',prvDayMVData.get('Reuters Fx')); 
                        else
                            prevfxRateMap.put('CAD CTS-USD',1);
                    }
                    
                    if(mqUnitRate.get(keyName) == excMVMOAWrapr.mvDefaultUnitRate)  
                    {                       
                        if((keyName == 'WTI') && (isOnlyFxRateChanged))
                        {                            
                            newOpis.RE_CND_CAD_Delta_cpl__c = (((mqPrice.get(keyName) * currFxRateToUse) - 
                                                                ((mqPrice.get(keyName) - 0.00) 
                                                                 * (currFxRateToUse - fxActual_Delta)))/ltrToBblRate*100).setScale(3);                            
                        }
                        else if((keyName == 'WTI') && !(isOnlyFxRateChanged))
                        {                            
                            newOpis.RE_CND_CAD_Delta_cpl__c = (((mqPrice.get(keyName) * currFxRateToUse) - 
                                                                ((mqPrice.get(keyName) - newOpis.RE_CND_Actual_Delta__c) 
                                                                 * (currFxRateToUse - fxActual_Delta)))/ltrToBblRate*100).setScale(3);                            
                        }
                        else if((keyName != 'WTI') && (isOnlyFxRateChanged))
                        {                            
                            newOpis.RE_CND_CAD_Delta_cpl__c = (((mqPrice.get(keyName) * currFxRateToUse) - 
                                                                ((mqPrice.get(keyName) - 0.00) 
                                                                 * (currFxRateToUse - fxActual_Delta)))/ltrToGalRate*100).setScale(3);                             
                        }
                        else if((keyName != 'WTI') && !(isOnlyFxRateChanged))
                        {                            
                            newOpis.RE_CND_CAD_Delta_cpl__c = (((mqPrice.get(keyName) * currFxRateToUse) - 
                                                                ((mqPrice.get(keyName) - newOpis.RE_CND_Actual_Delta__c) 
                                                                 * (currFxRateToUse - fxActual_Delta)))/ltrToGalRate*100).setScale(3);                             
                        }
                    }                                           
                    else if(mqUnitRate.get(keyName) != excMVMOAWrapr.mvDefaultUnitRate)
                    {                
                        newOpis.RE_CND_CAD_Delta_cpl__c = ((mqPrice.get(keyName) * unitConv.unitConversionMultiplier(mqUnitRate.get(keyName),excMVMOAWrapr.mvDefaultUnitRate,'Canada',null,currfxRateMap)) -
                                                           ((mqPrice.get(keyName) - newOpis.RE_CND_Actual_Delta__c) * unitConv.unitConversionMultiplier(prvDayMVBaseUnitRate.get(keyName),prvDayMVConvertdUnitRate.get(keyName),'Canada',null,prevfxRateMap))).setScale(3);                                                                                                                               
                    }
                    
                    if((keyName == 'WTI') || (keyName == 'RBOB') || (keyName == 'NYH RBOB Unl') || (keyName == 'NYH CBOB') || (keyName == 'Chi Rbob') || (keyName == 'Chi CBOB') || (keyName == 'USG CBOB') || (keyName == 'PNW CARBOB'))
                        newOpis.RE_CND_Group__c = 'Gasoline';
                    else
                        newOpis.RE_CND_Group__c = 'Gas Oil';
                    
                    newCADDelta.put(keyName,newOpis.RE_CND_CAD_Delta_cpl__c);
                    
                    if(prvDayMVData.containsKey(keyName))
                    {     
                        if(mqUnitRate.get(keyName) == prvDayMVBaseUnitRate.get(keyName))    
                        {                  
                            if(isOnlyFxRateChanged)
                                newOpis.RE_CND_PrvDay_Delta_Percentage__c = 0.00;
                            else
                                newOpis.RE_CND_PrvDay_Delta_Percentage__c = (((mqPrice.get(keyName) - prvDayMVData.get(keyName)) / prvDayMVData.get(keyName))*100).setScale(2);                                                                                                    
                        }
                        else
                        {                               
                            Map<String,Double> prevfxRateMapData = New Map<String,Double>();
                            // Previous day Base & Converted Unit Rate
                            if(prvDayMVBaseUnitRate.containsKey(keyName))
                                BaseCurrency = RE_unitConversion.unitBreakUp(prvDayMVBaseUnitRate.get(keyName))[0];
                            else
                                BaseCurrency = 'USD';
                            
                            if(prvDayMVConvertdUnitRate.containsKey(keyName))
                                ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayMVConvertdUnitRate.get(keyName))[0];
                            else
                                ConvertedCurrency = 'CAD';
                            
                            if(prvDayMVData.containsKey('Reuters Fx'))
                                prevfxRateMapData.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));                            
                            else
                                prevfxRateMapData.put(ConvertedCurrency+'-'+BaseCurrency,1);
                            
                            if(isOnlyFxRateChanged)
                                newOpis.RE_CND_PrvDay_Delta_Percentage__c = 0.00;
                            else
                                newOpis.RE_CND_PrvDay_Delta_Percentage__c = (((mqPrice.get(keyName) - (prvDayMVData.get(keyName) * unitConv.unitConversionMultiplier(prvDayMVBaseUnitRate.get(keyName),prvDayMVConvertdUnitRate.get(keyName),'Canada',null,prevfxRateMapData))) / (prvDayMVData.get(keyName) * unitConv.unitConversionMultiplier(prvDayMVBaseUnitRate.get(keyName),prvDayMVConvertdUnitRate.get(keyName),'Canada',null,prevfxRateMapData)))*100).setScale(2);                                                                                               
                        }
                    }              
                    
                    newMarktMveData.add(newOpis);                         
                }    
            }     
            
            system.debug('newMarktMveData-->'+newMarktMveData);
            for(RE_MOA__c setupMV: newMarktMveData)
            {
                RE_MOA__c newOpis = New RE_MOA__c();
                newOpis.RecordTypeId = marktMveRecordTypeId;
                newOpis.RE_CND_Group__c = setupMV.RE_CND_Group__c;
                newOpis.RE_CND_Marker_Name__c = setupMV.RE_CND_Marker_Name__c;
                newOpis.RE_Requested_Date__c  = setupMV.RE_Requested_Date__c;
                newOpis.RE_CND_Effective_Date__c = setupMV.RE_CND_Effective_Date__c;
                newOpis.RE_CND_Effective_From_Date__c = setupMV.RE_CND_Effective_From_Date__c;
                newOpis.RE_CND_Effective_To_Date__c = setupMV.RE_CND_Effective_To_Date__c;                
                newOpis.RE_CND_Current_OPIS_Selected_Date__c = setupMV.RE_CND_Current_OPIS_Selected_Date__c; 
                newOpis.RE_CND_Previous_OPIS_Selected_Date__c = setupMV.RE_CND_Previous_OPIS_Selected_Date__c; 
                newOpis.RE_CND_Current_FxRate_Selected_Date__c = setupMV.RE_CND_Current_FxRate_Selected_Date__c; 
                newOpis.RE_CND_Previous_FxRate_Selected_Date__c = setupMV.RE_CND_Previous_FxRate_Selected_Date__c;             
                newOpis.RE_CND_Current_FxRate__c = setupMV.RE_CND_Current_FxRate__c; 
                newOpis.RE_CND_Previous_FxRate__c = setupMV.RE_CND_Previous_FxRate__c;                
                newOpis.RE_Converted_Rate_Unit__c = setupMV.RE_Converted_Rate_Unit__c;
                newOpis.RE_Base_Rate_Unit__c = setupMV.RE_Base_Rate_Unit__c;
                newOpis.RE_Price_Value__c = setupMV.RE_Price_Value__c;
                
                if(newOpis.RE_CND_Marker_Name__c == 'Reuters Fx')
                {
                    newOpis.RE_CND_Actual_Delta__c = setupMV.RE_CND_Actual_Delta__c;                    
                    newOpis.RE_CND_Delta_Percentage__c = setupMV.RE_CND_Delta_Percentage__c;
                    newOpis.RE_CND_PrvDay_Delta_Percentage__c = setupMV.RE_CND_PrvDay_Delta_Percentage__c;
                    newOpis.RE_CND_CAD_Delta_cpl__c = setupMV.RE_CND_CAD_Delta_cpl__c;    
                }
                else if(isOnlyFxRateChanged)
                {
                    newOpis.RE_CND_Actual_Delta__c = 0.00;                    
                    newOpis.RE_CND_Delta_Percentage__c = 0.00;
                    newOpis.RE_CND_PrvDay_Delta_Percentage__c = setupMV.RE_CND_PrvDay_Delta_Percentage__c;
                    newOpis.RE_CND_CAD_Delta_cpl__c = setupMV.RE_CND_CAD_Delta_cpl__c;
                }                
                else
                {
                    newOpis.RE_CND_Actual_Delta__c = setupMV.RE_CND_Actual_Delta__c;                    
                    newOpis.RE_CND_Delta_Percentage__c = setupMV.RE_CND_Delta_Percentage__c;
                    newOpis.RE_CND_PrvDay_Delta_Percentage__c = setupMV.RE_CND_PrvDay_Delta_Percentage__c;
                    newOpis.RE_CND_CAD_Delta_cpl__c = setupMV.RE_CND_CAD_Delta_cpl__c;
                }
                
                newUpdtMarktMveData.add(newOpis);
            }  
            
            system.debug('oldMOALst-->'+oldMOALst);
            // for the Base Rack's Market Move
            for(RE_MOA__c oldMOA : oldMOALst)
            {                  
                if(((oldMOA.RE_CND_Rack__c == 'Montreal') || (oldMOA.RE_CND_Rack__c == 'Edmonton') || (oldMOA.RE_CND_Rack__c == 'Vancouver')) && ((oldMOA.RE_CND_Group__c == 'Gasoline') || (oldMOA.RE_CND_Group__c == 'Gas Oil')))
                {                        
                    RE_MOA__c lstMOA = New RE_MOA__c();
                    lstMOA.RE_CND_Rack__c = oldMOA.RE_CND_Rack__c;
                    lstMOA.RE_CND_Group__c = oldMOA.RE_CND_Group__c;                     
                    lstMOA.RE_CND_Effective_Date__c = excMVMOAWrapr.effectiveDate; 
                    lstMOA.RE_Requested_Date__c = excMVMOAWrapr.requestedDt;                                       
                    lstMOA.RE_CND_Effective_From_Date__c = excMVMOAWrapr.effectiveFromDate;
                    lstMOA.RE_CND_Effective_To_Date__c = excMVMOAWrapr.effectiveToDate;       
                    lstMOA.RE_CND_Current_OPIS_Selected_Date__c = excMVMOAWrapr.currOPISTikrDate; 
                    lstMOA.RE_CND_Previous_OPIS_Selected_Date__c = excMVMOAWrapr.prevOPISTikrDate; 
                    lstMOA.RE_CND_Current_FxRate_Selected_Date__c = excMVMOAWrapr.currFxRateDate; 
                    lstMOA.RE_CND_Previous_FxRate_Selected_Date__c = excMVMOAWrapr.prevFxRateDate;             
                    lstMOA.RE_CND_Current_FxRate__c = excMVMOAWrapr.currFxRate; 
                    lstMOA.RE_CND_Previous_FxRate__c = excMVMOAWrapr.prevFxRate;                     
                    lstMOA.RecordTypeId = cadMOARecordTypeId;
                    lstMOA.RE_CND_Competitive_Adj__c = 0.00;                        
                    lstMOA.RE_Converted_Rate_Unit__c = excMVMOAWrapr.epDefaultUnitRate;
                    
                    Map<String,Double> currfxRateMap = New Map<String,Double>();
                    Map<String,Double> prevfxRateMap = New Map<String,Double>();                 
                    
                    if((lstMOA.RE_CND_Rack__c == 'Montreal') && (lstMOA.RE_CND_Group__c == 'Gasoline') && (newCADDelta.containsKey('NYH RBOB Unl')))
                    {                      
                        // Market Move Unit Rate is not same as Execute Pricing Unit Rate
                        if(expUnitRate.get('NYH RBOB Unl') != excMVMOAWrapr.epDefaultUnitRate)
                        {                        
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('NYH RBOB Unl');
                            BaseCurrency = RE_unitConversion.unitBreakUp(expUnitRate.get('NYH RBOB Unl'))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(excMVMOAWrapr.epDefaultUnitRate)[0];
                            
                            if(isOnlyFxRateChanged)
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.prevFxRate);
                            else
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.currFxRate);                                
                            
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('NYH RBOB Unl') * unitConv.unitConversionMultiplier(expUnitRate.get('NYH RBOB Unl'),excMVMOAWrapr.epDefaultUnitRate,'Canada',null,currfxRateMap);                        
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            // Old Execute Pricing Unit Rate is same as Today's Execute Pricing
                            if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            {                                    
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            }   
                            // Old Execute Pricing Unit Rate is not same as Today's Execute Pricing
                            else
                            {                                    
                                BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                                
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                     
                            }
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);  
                        }
                        // Market Move Unit Rate is same as Execute Pricing Unit Rate
                        else
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('NYH RBOB Unl');
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('NYH RBOB Unl');
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                            
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }                            
                    }
                    else if((lstMOA.RE_CND_Rack__c == 'Montreal') && (lstMOA.RE_CND_Group__c == 'Gas Oil') && (newCADDelta.containsKey('NYH ULS#2')))
                    {                    
                        // Market Move Unit Rate is not same as Execute Pricing Unit Rate
                        if(expUnitRate.get('NYH ULS#2') != excMVMOAWrapr.epDefaultUnitRate)
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('NYH ULS#2');
                            BaseCurrency = RE_unitConversion.unitBreakUp(expUnitRate.get('NYH ULS#2'))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(excMVMOAWrapr.epDefaultUnitRate)[0];
                            
                            if(isOnlyFxRateChanged)
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.prevFxRate);
                            else
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.currFxRate); 
                            
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('NYH ULS#2') * unitConv.unitConversionMultiplier(expUnitRate.get('NYH ULS#2'),excMVMOAWrapr.epDefaultUnitRate,'Canada',null,currfxRateMap);                        
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);                                                            
                            
                            // Old Execute Pricing Unit Rate is same as Today's Execute Pricing
                            if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            {                                    
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            }   
                            // Old Execute Pricing Unit Rate is not same as Today's Execute Pricing
                            else
                            {                                    
                                BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                                
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                     
                            }
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                            baseRackMV.put('Toronto'+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c); 
                        }
                        // Market Move Unit Rate is same as Execute Pricing Unit Rate
                        else
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('NYH ULS#2');
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('NYH ULS#2');
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                            
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                            baseRackMV.put('Toronto'+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c); 
                        } 
                    }
                    else if((lstMOA.RE_CND_Rack__c == 'Edmonton') && (lstMOA.RE_CND_Group__c == 'Gasoline') && (newCADDelta.containsKey('Chi CBOB')))
                    {                        
                        // Market Move Unit Rate is not same as Execute Pricing Unit Rate
                        if(expUnitRate.get('Chi CBOB') != excMVMOAWrapr.epDefaultUnitRate)
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('Chi CBOB');
                            BaseCurrency = RE_unitConversion.unitBreakUp(expUnitRate.get('Chi CBOB'))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(excMVMOAWrapr.epDefaultUnitRate)[0];
                            
                            if(isOnlyFxRateChanged)
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.prevFxRate);
                            else
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.currFxRate); 
                            
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('Chi CBOB') * unitConv.unitConversionMultiplier(expUnitRate.get('Chi CBOB'),excMVMOAWrapr.epDefaultUnitRate,'Canada',null,currfxRateMap);                        
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            // Old Execute Pricing Unit Rate is same as Today's Execute Pricing
                            if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            {                                    
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            }   
                            // Old Execute Pricing Unit Rate is not same as Today's Execute Pricing
                            else
                            {                                    
                                BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                                
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                     
                            }
                            
                            EdmontonGasolineNewEnd = lstMOA.RE_CND_New_End_Price__c;
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }
                        // Market Move Unit Rate is same as Execute Pricing Unit Rate
                        else
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('Chi CBOB');
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('Chi CBOB');
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;                                
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            
                            EdmontonGasolineNewEnd = lstMOA.RE_CND_New_End_Price__c;
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }                            
                    }
                    else if((lstMOA.RE_CND_Rack__c == 'Edmonton') && (lstMOA.RE_CND_Group__c == 'Gas Oil') && (newCADDelta.containsKey('Chi ULS#2')))
                    {                        
                        // Market Move Unit Rate is not same as Execute Pricing Unit Rate
                        if(expUnitRate.get('Chi ULS#2') != excMVMOAWrapr.epDefaultUnitRate)
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('Chi ULS#2');
                            BaseCurrency = RE_unitConversion.unitBreakUp(expUnitRate.get('Chi ULS#2'))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(excMVMOAWrapr.epDefaultUnitRate)[0];
                            
                            if(isOnlyFxRateChanged)
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.prevFxRate);
                            else
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.currFxRate); 
                            
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('Chi ULS#2') * unitConv.unitConversionMultiplier(expUnitRate.get('Chi ULS#2'),excMVMOAWrapr.epDefaultUnitRate,'Canada',null,currfxRateMap);                        
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            // Old Execute Pricing Unit Rate is same as Today's Execute Pricing
                            if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            {                                    
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            }   
                            // Old Execute Pricing Unit Rate is not same as Today's Execute Pricing
                            else
                            {                                    
                                BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                                
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                     
                            }
                            
                            EdmontonDieselNewEnd = lstMOA.RE_CND_New_End_Price__c;
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }
                        // Market Move Unit Rate is same as Execute Pricing Unit Rate
                        else
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('Chi ULS#2');
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('Chi ULS#2');
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            
                            EdmontonDieselNewEnd = lstMOA.RE_CND_New_End_Price__c;
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }
                    }
                    else if((lstMOA.RE_CND_Rack__c == 'Vancouver') && (lstMOA.RE_CND_Group__c == 'Gasoline') && (newCADDelta.containsKey('PNW CARBOB')))
                    {                        
                        // Market Move Unit Rate is not same as Execute Pricing Unit Rate
                        if(expUnitRate.get('PNW CARBOB') != excMVMOAWrapr.epDefaultUnitRate)
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('PNW CARBOB');
                            BaseCurrency = RE_unitConversion.unitBreakUp(expUnitRate.get('PNW CARBOB'))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(excMVMOAWrapr.epDefaultUnitRate)[0];
                            
                            if(isOnlyFxRateChanged)
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.prevFxRate);
                            else
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.currFxRate);
                            
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('PNW CARBOB') * unitConv.unitConversionMultiplier(expUnitRate.get('PNW CARBOB'),excMVMOAWrapr.epDefaultUnitRate,'Canada',null,currfxRateMap);                        
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            // Old Execute Pricing Unit Rate is same as Today's Execute Pricing
                            if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            {                                    
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            }   
                            // Old Execute Pricing Unit Rate is not same as Today's Execute Pricing
                            else
                            {                                    
                                BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                                
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                     
                            }
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }
                        // Market Move Unit Rate is same as Execute Pricing Unit Rate
                        else
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('PNW CARBOB');
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('PNW CARBOB');
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);   
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }
                    }
                    else if((lstMOA.RE_CND_Rack__c == 'Vancouver') && (lstMOA.RE_CND_Group__c == 'Gas Oil') && (newCADDelta.containsKey('PNW ULS#2')))
                    {                       
                        // Market Move Unit Rate is not same as Execute Pricing Unit Rate
                        if(expUnitRate.get('PNW ULS#2') != excMVMOAWrapr.epDefaultUnitRate)
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('PNW ULS#2');
                            BaseCurrency = RE_unitConversion.unitBreakUp(expUnitRate.get('PNW ULS#2'))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(excMVMOAWrapr.epDefaultUnitRate)[0];
                            
                            if(isOnlyFxRateChanged)
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.prevFxRate);
                            else
                                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,excMVMOAWrapr.currFxRate); 
                            
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('PNW ULS#2') * unitConv.unitConversionMultiplier(expUnitRate.get('PNW ULS#2'),excMVMOAWrapr.epDefaultUnitRate,'Canada',null,currfxRateMap);                        
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            // Old Execute Pricing Unit Rate is same as Today's Execute Pricing
                            if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            {                                    
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2); 
                            }   
                            // Old Execute Pricing Unit Rate is not same as Today's Execute Pricing
                            else
                            {                                    
                                BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                                prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                                
                                lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                                lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                     
                            }
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }
                        // Market Move Unit Rate is same as Execute Pricing Unit Rate
                        else
                        {                                
                            lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('PNW ULS#2');
                            lstMOA.RE_CND_Market_Move__c = newCADDelta.get('PNW ULS#2');
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c;
                            
                            lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                            
                            lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);   
                            
                            baseRackMV.put(lstMOA.RE_CND_Rack__c+lstMOA.RE_CND_Group__c,lstMOA.RE_CND_Market_Move__c);                                    
                        }
                    }                    
                    
                    newMOAData.add(lstMOA);
                }                         
            }       
            
            // for the derived Rack's Market Move
            for(RE_MOA__c oldMOA : oldMOALst)
            {       
                if((oldMOA.RE_CND_Rack__c == 'Ottawa') || (oldMOA.RE_CND_Rack__c == 'Toronto') || (oldMOA.RE_CND_Rack__c == 'Sarnia') || (oldMOA.RE_CND_Rack__c == 'Thunder Bay') || (oldMOA.RE_CND_Rack__c == 'Kamloops')
                   || (oldMOA.RE_CND_Rack__c == 'Belleville') || (oldMOA.RE_CND_Rack__c == 'Kingston') || (oldMOA.RE_CND_Rack__c == 'Sault Ste Marie') || (oldMOA.RE_CND_Rack__c == 'London'))
                {
                    RE_MOA__c lstMOA = New RE_MOA__c();
                    lstMOA.RE_CND_Rack__c = oldMOA.RE_CND_Rack__c;
                    lstMOA.RE_CND_Group__c = oldMOA.RE_CND_Group__c; 
                    lstMOA.RE_CND_Effective_Date__c = excMVMOAWrapr.effectiveDate; 
                    lstMOA.RE_Requested_Date__c = excMVMOAWrapr.requestedDt;                                       
                    lstMOA.RE_CND_Effective_From_Date__c = excMVMOAWrapr.effectiveFromDate;
                    lstMOA.RE_CND_Effective_To_Date__c = excMVMOAWrapr.effectiveToDate;       
                    lstMOA.RE_CND_Current_OPIS_Selected_Date__c = excMVMOAWrapr.currOPISTikrDate; 
                    lstMOA.RE_CND_Previous_OPIS_Selected_Date__c = excMVMOAWrapr.prevOPISTikrDate; 
                    lstMOA.RE_CND_Current_FxRate_Selected_Date__c = excMVMOAWrapr.currFxRateDate; 
                    lstMOA.RE_CND_Previous_FxRate_Selected_Date__c = excMVMOAWrapr.prevFxRateDate;             
                    lstMOA.RE_CND_Current_FxRate__c = excMVMOAWrapr.currFxRate; 
                    lstMOA.RE_CND_Previous_FxRate__c = excMVMOAWrapr.prevFxRate;                      
                    lstMOA.RecordTypeId = cadMOARecordTypeId;
                    lstMOA.RE_CND_Competitive_Adj__c = 0.00;                       
                    lstMOA.RE_Converted_Rate_Unit__c = excMVMOAWrapr.epDefaultUnitRate;                               
                    
                    if(((lstMOA.RE_CND_Rack__c == 'Ottawa') || (lstMOA.RE_CND_Rack__c == 'Toronto') || (lstMOA.RE_CND_Rack__c == 'Sarnia') || (lstMOA.RE_CND_Rack__c == 'Belleville') || (lstMOA.RE_CND_Rack__c == 'Kingston') || (lstMOA.RE_CND_Rack__c == 'Sault Ste Marie') || (lstMOA.RE_CND_Rack__c == 'London')) 
                       && (lstMOA.RE_CND_Group__c == 'Gasoline') && (baseRackMV.containsKey('MontrealGasoline')))
                    {                        
                        if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c; 
                        else
                        {                            
                            Map<String,Double> prevfxRateMap = New Map<String,Double>(); 
                            BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                            
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                        }
                        
                        lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('NYH RBOB Unl');
                        lstMOA.RE_CND_Market_Move__c = baseRackMV.get('MontrealGasoline');   
                        
                        lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                        
                        lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                                            							                                                   
                    }
                    else if(((lstMOA.RE_CND_Rack__c == 'Thunder Bay') || (lstMOA.RE_CND_Rack__c == 'Kamloops')) && (lstMOA.RE_CND_Group__c == 'Gasoline') && (baseRackMV.containsKey('EdmontonGasoline')))
                    {                        
                        if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c; 
                        else
                        {                            
                            Map<String,Double> prevfxRateMap = New Map<String,Double>(); 
                            BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                            
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                        }
                        
                        lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('Chi CBOB');
                        lstMOA.RE_CND_Market_Move__c = baseRackMV.get('EdmontonGasoline');   
                        
                        lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                        
                        lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                                                            
                    }
                    else if(((lstMOA.RE_CND_Rack__c == 'Ottawa') || (lstMOA.RE_CND_Rack__c == 'Toronto') || (lstMOA.RE_CND_Rack__c == 'Sarnia') || (lstMOA.RE_CND_Rack__c == 'Belleville') || (lstMOA.RE_CND_Rack__c == 'Kingston') || (lstMOA.RE_CND_Rack__c == 'Sault Ste Marie') || (lstMOA.RE_CND_Rack__c == 'London')) 
                            && (lstMOA.RE_CND_Group__c == 'Gas Oil') && (baseRackMV.containsKey('TorontoGas Oil')))
                    {                        
                        if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c; 
                        else
                        {                            
                            Map<String,Double> prevfxRateMap = New Map<String,Double>(); 
                            BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                            
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                        }
                        
                        lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('NYH ULS#2');
                        lstMOA.RE_CND_Market_Move__c = baseRackMV.get('TorontoGas Oil');                          
                        
                        lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);
                        
                        lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);   
                    }
                    else if(((lstMOA.RE_CND_Rack__c == 'Thunder Bay') || (lstMOA.RE_CND_Rack__c == 'Kamloops')) && (lstMOA.RE_CND_Group__c == 'Gas Oil') && (baseRackMV.containsKey('EdmontonGas Oil')))
                    {                        
                        if(oldMOA.RE_Converted_Rate_Unit__c == excMVMOAWrapr.epDefaultUnitRate)
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c; 
                        else
                        {                            
                            Map<String,Double> prevfxRateMap = New Map<String,Double>(); 
                            BaseCurrency = RE_unitConversion.unitBreakUp(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            ConvertedCurrency = RE_unitConversion.unitBreakUp(prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c))[0];
                            prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvDayMVData.get('Reuters Fx'));
                            
                            lstMOA.RE_CND_Today_s_Price__c = oldMOA.RE_CND_New_End_Price__c * unitConv.unitConversionMultiplier(prvDayExePrBaseUnitRate.get(lstMOA.RE_CND_Rack__c),prvDayExePrConvertdUnitRate.get(lstMOA.RE_CND_Rack__c),'Canada',null,prevfxRateMap);
                        }
                        
                        lstMOA.RE_Base_Rate_Unit__c = expUnitRate.get('Chi ULS#2');
                        lstMOA.RE_CND_Market_Move__c = baseRackMV.get('EdmontonGas Oil');  
                        
                        lstMOA.RE_CND_Net_Move__c = (lstMOA.RE_CND_Market_Move__c).setScale(1, RoundingMode.HALF_UP);                            
                        
                        lstMOA.RE_CND_New_End_Price__c = (lstMOA.RE_CND_Today_s_Price__c + lstMOA.RE_CND_Net_Move__c).setScale(2);                             
                    } 
                    
                    if((lstMOA.RE_CND_Rack__c == 'Toronto') && (lstMOA.RE_CND_Group__c == 'Gasoline'))                        
                        torontoGasolineNewEnd = lstMOA.RE_CND_New_End_Price__c;                  
                    else if((lstMOA.RE_CND_Rack__c == 'Toronto') && (lstMOA.RE_CND_Group__c == 'Gas Oil'))                        
                        torontoDieselNewEnd = lstMOA.RE_CND_New_End_Price__c;                                
                    
                    newMOAData.add(lstMOA);
                }                      
            }
            
            system.debug('newMOAData-->'+newMOAData);
            for(RE_MOA__c nwMoa: newMOAData)
            {                    
                RE_MOA__c newMOA = New RE_MOA__c();
                newMOA.RE_CND_Rack__c = nwMoa.RE_CND_Rack__c;               
                newMOA.RE_CND_Group__c = nwMoa.RE_CND_Group__c;
                newMOA.RE_CND_Effective_Date__c = nwMoa.RE_CND_Effective_Date__c; 
                newMOA.RE_Requested_Date__c = nwMoa.RE_Requested_Date__c;                                       
                newMOA.RE_CND_Effective_From_Date__c = nwMoa.RE_CND_Effective_From_Date__c;
                newMOA.RE_CND_Effective_To_Date__c = nwMoa.RE_CND_Effective_To_Date__c;       
                newMOA.RE_CND_Current_OPIS_Selected_Date__c = nwMoa.RE_CND_Current_OPIS_Selected_Date__c; 
                newMOA.RE_CND_Previous_OPIS_Selected_Date__c = nwMoa.RE_CND_Previous_OPIS_Selected_Date__c; 
                newMOA.RE_CND_Current_FxRate_Selected_Date__c = nwMoa.RE_CND_Current_FxRate_Selected_Date__c; 
                newMOA.RE_CND_Previous_FxRate_Selected_Date__c = nwMoa.RE_CND_Previous_FxRate_Selected_Date__c;             
                newMOA.RE_CND_Current_FxRate__c = nwMoa.RE_CND_Current_FxRate__c; 
                newMOA.RE_CND_Previous_FxRate__c = nwMoa.RE_CND_Previous_FxRate__c;           
                newMOA.RecordTypeId = cadMOARecordTypeId;
                newMOA.RE_CND_Competitive_Adj__c = nwMoa.RE_CND_Competitive_Adj__c; 
                newMOA.RE_Base_Rate_Unit__c = nwMoa.RE_Base_Rate_Unit__c;
                newMOA.RE_Converted_Rate_Unit__c = excMVMOAWrapr.epDefaultUnitRate; 
                
                newMOA.RE_CND_Today_s_Price__c = nwMoa.RE_CND_Today_s_Price__c;             
                newMOA.RE_CND_Market_Move__c = nwMoa.RE_CND_Market_Move__c;
                newMOA.RE_CND_Net_Move__c = nwMoa.RE_CND_Net_Move__c;
                newMOA.RE_CND_New_End_Price__c = ((nwMoa.RE_CND_New_End_Price__c == null) ? 0.00 : nwMoa.RE_CND_New_End_Price__c);                                       
                
                if((nwMoa.RE_CND_Rack__c == 'Ottawa') && (nwMoa.RE_CND_Group__c == 'Gasoline'))                                
                    newMOA.RE_CND_Difference__c = (((nwMoa.RE_CND_New_End_Price__c == null) ? 0.00 : nwMoa.RE_CND_New_End_Price__c) - ((torontoGasolineNewEnd == null) ? 0.00: torontoGasolineNewEnd));
                else if((nwMoa.RE_CND_Rack__c == 'Ottawa') && (nwMoa.RE_CND_Group__c == 'Gas Oil'))                                
                    newMOA.RE_CND_Difference__c = (((nwMoa.RE_CND_New_End_Price__c == null) ? 0.00 : nwMoa.RE_CND_New_End_Price__c) - ((torontoDieselNewEnd == null) ? 0.00 : torontoDieselNewEnd));
                else if((nwMoa.RE_CND_Rack__c == 'Thunder Bay') && (nwMoa.RE_CND_Group__c == 'Gasoline'))                                
                    newMOA.RE_CND_Difference__c = (((nwMoa.RE_CND_New_End_Price__c == null) ? 0.00 : nwMoa.RE_CND_New_End_Price__c) - ((EdmontonGasolineNewEnd == null) ? 0.00 : EdmontonGasolineNewEnd));
                else if((nwMoa.RE_CND_Rack__c == 'Thunder Bay') && (nwMoa.RE_CND_Group__c == 'Gas Oil'))                                
                    newMOA.RE_CND_Difference__c = (((nwMoa.RE_CND_New_End_Price__c == null) ? 0.00 : nwMoa.RE_CND_New_End_Price__c) - ((EdmontonDieselNewEnd == null) ? 0.00 : EdmontonDieselNewEnd));                       
                else if((nwMoa.RE_CND_Rack__c == 'Kamloops') && (nwMoa.RE_CND_Group__c == 'Gasoline'))
                    newMOA.RE_CND_Difference__c = (((nwMoa.RE_CND_New_End_Price__c == null) ? 0.00 : nwMoa.RE_CND_New_End_Price__c) - ((EdmontonGasolineNewEnd == null) ? 0.00 : EdmontonGasolineNewEnd));                                        
                else if((nwMoa.RE_CND_Rack__c == 'Kamloops') && (nwMoa.RE_CND_Group__c == 'Gas Oil'))                                
                    newMOA.RE_CND_Difference__c = (((nwMoa.RE_CND_New_End_Price__c == null) ? 0.00 : nwMoa.RE_CND_New_End_Price__c) - ((EdmontonDieselNewEnd == null) ? 0.00 : EdmontonDieselNewEnd));
                
                updatedMOA.add(newMOA);                                
            }
            
            // Update Processed to True for OPIS Spot Ticker uploaded records
            for(Id idvalue: mqProcessedIds)
            {
                RE_Market_Quotes__c updateOpisStatus = new RE_Market_Quotes__c();
                updateOpisStatus.Id = idvalue;
                updateOpisStatus.RE_Is_Processed__c = TRUE;
                updatedPrcssdStatus.add(updateOpisStatus);
            }     
            
            system.debug('currentdayMarketMove-->'+newUpdtMarktMveData);
            // Insert current day Market Move
            if(newUpdtMarktMveData.size() > 0)
            {         
                Set<Id> mqMOAInsrtdIds = New Set<Id>();
                Database.SaveResult[] cpList = Database.insert(newUpdtMarktMveData, false);
                mqMOAInsrtdIds = RE_CND_Utility.handleInsert('RE_CND_ExecuteDepoPricingController','calculateMVandMOA-InsertedMOA',cpList,jrAudit);
                
                if(mqMOAInsrtdIds.size() > 0)
                    insertedMOAIds.addAll(mqMOAInsrtdIds);               
            }   
            
            system.debug('currentdayExecutePrice-->'+updatedMOA);
            // Insert current day execute Price(MOA)
            if(updatedMOA.size() > 0)
            {
                Set<Id> mqMOAUpdatedIds = New Set<Id>();
                Database.SaveResult[] moaList = Database.insert(updatedMOA, false);
                mqMOAUpdatedIds = RE_CND_Utility.handleInsert('RE_CND_ExecuteDepoPricingController','calculateMVandMOA-InsertedExecPrcMOA',moaList,jrAudit);
                
                if(mqMOAUpdatedIds.size() > 0)
                    insertedMOAIds.addAll(mqMOAUpdatedIds);                
            }   
            
            // Insert current day Fx
            if((excMVMOAWrapr.fxRateCreatUpdteStatus == 'Create') && (CurtFxLst.Size() > 0))
            {
                Set<Id> currFxInsertdIds = New Set<Id>();
                Database.SaveResult[] fxList = Database.insert(CurtFxLst, false);
                currFxInsertdIds = RE_CND_Utility.handleInsert('RE_CND_ExecuteDepoPricingController','calculateMVandMOA-InsertFxRate',fxList,jrAudit);                      
            }
            // Update current day Fx if it's changed in Price Execution
            else if((excMVMOAWrapr.fxRateCreatUpdteStatus == 'Update') && (CurtFxLst.Size() > 0))
            {
                Boolean updateSuccess = False;
                Database.SaveResult[] fxList = Database.update(CurtFxLst, false);                       
                updateSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_ExecuteDepoPricingController','calculateMVandMOA-UpdateFxRate',fxList,false, jrAudit);                   
            }            
            
            // Check existing MOA on the same day then update initial version
            if((insertedMOAIds.Size() > 0) && (((currtDayOldMaktMove != null) && (currtDayOldMaktMove.Size() > 0)) 
                                               || ((currtDayOldExctePrice != null) && (currtDayOldExctePrice.Size() > 0))))                                            
                initialVersnLst = updateInitialVersionInOlderMOA(insertedMOAIds,curDayRecrdWrapper); 
            else if(insertedMOAIds.Size() > 0)                           
                initialVersnLst = updateInitialVersionInMOA(insertedMOAIds); 
            
            // Update initial version in MOA
            if(initialVersnLst.Size() > 0)
                update initialVersnLst;
            
            // Update OPIS Spot Ticket Processed as true
            if(updatedPrcssdStatus.Size() > 0)                                         
                update updatedPrcssdStatus;                       
            
            // Update Old Draft & Ready to upload become Redundant in Cost Price & PriceBook
            if(((oldMapCostPrice != null) && (oldMapCostPrice.Size() > 0)) 
               || ((oldPriceBookLst != null) && (oldPriceBookLst.Size() > 0))) 
            {
                RE_CND_CostPriceBatchUpdate updateCp = New RE_CND_CostPriceBatchUpdate(oldMapCostPrice, oldPriceBookLst, jrAudit, jrAudit.RE_Job_Status__c, IsSuccessJobAudit);
                Database.executeBatch(updateCp);
            }              
            
            // Update Audit Job Status
            if(jrAudit.RE_Job_Status__c == 'Processing')
            {
                jrAudit.RE_Job_Status__c ='Completed';               
                update jrAudit;
                mvwrapper.executionStatus = 'success';
                mvwrapper.errorMsg = '';
                mvwrapper.jobRunAuditId = jrAudit.Id;
            }
            else
            {             
                mvwrapper.executionStatus = 'failed';
                mvwrapper.errorMsg = 'Issue while generating Canada Market Move';
                mvwrapper.jobRunAuditId = jrAudit.Id;
                String comments='Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
                RE_CND_Utility.updateJobAuditPartialSuccess(jrAudit,'Issue while generating Canada Market Move Job',comments);                
            }       
            
            system.debug('mvwrapper-final-->'+mvwrapper);
            return mvwrapper;
        }
        Catch(Exception ex)
        {      
            System.debug('calculateMVandMOA-Error-->'+ex.getMessage());
            System.debug('calculateMVandMOA-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('calculateMVandMOA',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','calculateMVandMOA','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);
            mvwrapper.executionStatus = 'failed';
            mvwrapper.errorMsg = 'Failed while Calculating Market Move';  
            mvwrapper.jobRunAuditId = jrAudit.Id;
            return mvwrapper;           
        }   
    }
    
    // Consider the lowest Validity month records for OPIS Spot Ticker calculation
    public static Boolean isLowestOPISValidityMonth(String prevValidMonth, String newValidMonth)        
    {       
        Boolean oldTobeDeleted = false;
        if(prevValidMonth.toLowerCase().trim() == newValidMonth.toLowerCase().trim())
            oldTobeDeleted = true;
        else
        {
            Map<String,Integer> monthNo = New Map<String,Integer>();
            String[] prevValidMonthLst;
            String[] newValidMonthLst;
            Integer prevValidYear = 0;
            Integer newValidYear = 0;
            
            monthNo.put('jan',1);
            monthNo.put('feb',2);
            monthNo.put('mar',3);
            monthNo.put('apr',4);
            monthNo.put('may',5);
            monthNo.put('jun',6);
            monthNo.put('jul',7);
            monthNo.put('aug',8);
            monthNo.put('sep',9);
            monthNo.put('oct',10);
            monthNo.put('nov',11);
            monthNo.put('dec',12);            
            
            prevValidMonthLst = prevValidMonth.split('\\-');            
            newValidMonthLst = newValidMonth.split('\\-');
            
            if(prevValidMonthLst[0] != prevValidMonth && prevValidMonthLst[0].IsNumeric()
               && newValidMonthLst[0] != newValidMonth && newValidMonthLst[0].IsNumeric())
            {
                prevValidYear = Integer.valueOf(prevValidMonthLst[0]);
                newValidYear = Integer.valueOf(newValidMonthLst[0]);
                
                if(newValidYear < prevValidYear)                
                    oldTobeDeleted = true;
                else if(newValidYear > prevValidYear)
                    oldTobeDeleted = false;
                else if(monthNo.get(prevValidMonthLst[1].toLowerCase()) < monthNo.get(newValidMonthLst[1].toLowerCase()))
                    oldTobeDeleted = false;
                else if(monthNo.get(prevValidMonthLst[1].toLowerCase()) > monthNo.get(newValidMonthLst[1].toLowerCase()))
                    oldTobeDeleted = true;        
            }
            else if(prevValidMonthLst[0] != prevValidMonth && prevValidMonthLst[1].IsNumeric()
                    && newValidMonthLst[0] != newValidMonth && newValidMonthLst[1].IsNumeric())
            {
                prevValidYear = Integer.valueOf(prevValidMonthLst[1]);
                newValidYear = Integer.valueOf(newValidMonthLst[1]);                
                
                if(newValidYear < prevValidYear)                
                    oldTobeDeleted = true;
                else if(newValidYear > prevValidYear)
                    oldTobeDeleted = false;
                else if(monthNo.get(prevValidMonthLst[0].toLowerCase()) < monthNo.get(newValidMonthLst[0].toLowerCase()))
                    oldTobeDeleted = false;
                else if(monthNo.get(prevValidMonthLst[0].toLowerCase()) > monthNo.get(newValidMonthLst[0].toLowerCase()))
                    oldTobeDeleted = true;      
            }      
        }
        
        return oldTobeDeleted;
    }
    
    // To update the InitialVersion same as Name in MOA for both execute Price & Market Quotes for the first time in a day
    public static list<RE_MOA__c> updateInitialVersionInMOA(Set<Id> moaIds)
    {
        List<RE_MOA__c> initialVersnLst = new List<RE_MOA__c>();
        for(RE_MOA__c iniVer : [SELECT Id, Name, RE_Initial_Version__c, RE_IsLatest__c FROM RE_MOA__c
                                WHERE Id in : moaIds])
        {                
            iniVer.RE_Initial_Version__c = iniVer.Name;
            iniVer.RE_IsLatest__c = TRUE;
            initialVersnLst.add(iniVer);
        }
        
        return initialVersnLst;       
    }
    
    // Get current day's all the records from MOA, Cost price and Price Book
    public static currentDayExistingRecordsWrapper getCurentDayAllMOAAndCostPriceAndPriceBkRecords(date request_Date)
    {
        currentDayExistingRecordsWrapper cDRWrapper = new currentDayExistingRecordsWrapper();   
        Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndPriceBookRecdTypId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        Id marktMveRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Market_Moves').getRecordTypeId();
        Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
        
        List<RE_MY_CostPrice__c> oldMapCostPrice = new List<RE_MY_CostPrice__c>();
        List<RT_Price_Book__c> oldPriceBookLst = new List<RT_Price_Book__c>();
        Map<String,RE_MOA__c> currtDayOldMaktMove = New Map<String,RE_MOA__c>();
        Map<String,RE_MOA__c> currtDayOldExctePrice = New Map<String,RE_MOA__c>();
        
        // Market Move on same day
        for(RE_MOA__c mvData: [SELECT Id, RE_CND_Marker_Name__c, RE_CND_Group__c, RE_Initial_Version__c, RE_IsLatest__c
                               FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId
                               AND RE_Requested_Date__c =: request_Date
                               AND RE_IsLatest__c =: TRUE])
        {
            currtDayOldMaktMove.put(mvData.RE_CND_Marker_Name__c+mvData.RE_CND_Group__c,mvData);
        }
        
        // Execute Price on same day
        for(RE_MOA__c exprcData: [SELECT Id, RE_CND_Rack__c, RE_CND_Group__c, RE_Initial_Version__c, RE_IsLatest__c
                                  FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId
                                  AND RE_Requested_Date__c =: request_Date
                                  AND RE_IsLatest__c =: TRUE])
        {
            currtDayOldExctePrice.put(exprcData.RE_CND_Rack__c+exprcData.RE_CND_Group__c,exprcData);
        }
        
        // Cost Price on same day
        for(RE_MY_CostPrice__c costPrice : [SELECT Id, RE_IsLatest__c, RE_Status__c
                                            FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId 
                                            AND RE_IsLatest__c =: TRUE AND RE_Status__c IN ('Draft', 'Ready to Upload')
                                            AND RE_Requested_Date__c =: request_Date])
        {         
            RE_MY_CostPrice__c costRecord = new RE_MY_CostPrice__c();
            costRecord.Id = costPrice.Id;
            costRecord.RE_Status__c = 'Redundant';
            costRecord.RE_IsLatest__c = FALSE;
            oldMapCostPrice.add(costRecord);
        }
        
        // PriceBook/SFJ on dame day
        for(RT_Price_Book__c prcBk  : [SELECT Id, RE_Is_Latest__c, RE_Custom_Opp_Approve__c                                      
                                       FROM RT_Price_Book__c WHERE RecordTypeId =: cndPriceBookRecdTypId
                                       AND RE_Is_Latest__c =: TRUE AND RE_Custom_Opp_Approve__c IN ('Draft', 'Ready to Upload')
                                       AND RT_Effective_Date__c =: request_Date])
        {      
            RT_Price_Book__c prcRecord = new RT_Price_Book__c();
            prcRecord.Id = prcBk.Id;
            prcRecord.RE_Custom_Opp_Approve__c = 'Redundant';
            prcRecord.RE_Is_Latest__c = FALSE;
            oldPriceBookLst.add(prcRecord);
        }      
        
        cDRWrapper.currtDayMapCostPriceList = oldMapCostPrice;
        cDRWrapper.currtDayPrcBookList = oldPriceBookLst;
        cDRWrapper.currtDayOldMaktMoveList = currtDayOldMaktMove;
        cDRWrapper.currtDayOldExctePriceList = currtDayOldExctePrice;
        
        return cDRWrapper;
    }
    
    public class currentDayExistingRecordsWrapper {      
        @AuraEnabled
        public List<RE_MY_CostPrice__c> currtDayMapCostPriceList {get;set;} 
        @AuraEnabled
        public List<RT_Price_Book__c> currtDayPrcBookList {get;set;}  
        @AuraEnabled            
        public Map<String,RE_MOA__c> currtDayOldMaktMoveList {get;set;}   
        @AuraEnabled
        public Map<String,RE_MOA__c> currtDayOldExctePriceList {get;set;} 
    }
    
    // Get Older records MOA records on same day for setting up initial version
    public static list<RE_MOA__c> updateInitialVersionInOlderMOA(Set<Id> insertedMOAIds, currentDayExistingRecordsWrapper curDayRecrdWrapper)
    {
        List<RE_MOA__c> updateInitialVersnLst = new List<RE_MOA__c>();   
        try
        {
            RE_MOA__c oldExecPrce = new RE_MOA__c();
            RE_MOA__c oldMarkMov = new RE_MOA__c();
            Id marktMveRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Market_Moves').getRecordTypeId();
            Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
            
            if(curDayRecrdWrapper.currtDayOldMaktMoveList.Size() > 0)
            {
                for(RE_MOA__c iniVerMQ : [SELECT Id, RE_CND_Marker_Name__c, RE_CND_Group__c, RE_Initial_Version__c, RE_IsLatest__c
                                          FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId AND Id in : insertedMOAIds])
                {
                    // Get the previous is latest = true from MOA Execute Price Values, if exists 
                    if(curDayRecrdWrapper.currtDayOldMaktMoveList.containsKey(iniVerMQ.RE_CND_Marker_Name__c+iniVerMQ.RE_CND_Group__c))   
                    {
                        oldMarkMov = curDayRecrdWrapper.currtDayOldMaktMoveList.get(iniVerMQ.RE_CND_Marker_Name__c+iniVerMQ.RE_CND_Group__c);
                        RE_MOA__c excPricNew = new RE_MOA__c();
                        excPricNew.Id = iniVerMQ.Id;
                        excPricNew.RE_Initial_Version__c = oldMarkMov.RE_Initial_Version__c;   
                        excPricNew.RE_IsLatest__c = TRUE; 
                        updateInitialVersnLst.add(excPricNew);
                        
                        RE_MOA__c excPricOld = new RE_MOA__c();
                        excPricOld.Id = oldMarkMov.Id;
                        excPricOld.RE_IsLatest__c = FALSE;                  
                        updateInitialVersnLst.add(excPricOld);						
                    }
                }
            }
            
            if(curDayRecrdWrapper.currtDayOldExctePriceList.Size() > 0)
            {
                for(RE_MOA__c iniVerExc : [SELECT Id, RE_CND_Rack__c, RE_CND_Group__c, RE_Initial_Version__c, RE_IsLatest__c
                                           FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId AND Id in : insertedMOAIds])
                {
                    // Get the previous is latest = true from MOA Market Move Values, if exists 
                    if(curDayRecrdWrapper.currtDayOldExctePriceList.containsKey(iniVerExc.RE_CND_Rack__c+iniVerExc.RE_CND_Group__c))   
                    {
                        oldExecPrce = curDayRecrdWrapper.currtDayOldExctePriceList.get(iniVerExc.RE_CND_Rack__c+iniVerExc.RE_CND_Group__c);
                        RE_MOA__c excPricNew = new RE_MOA__c();
                        excPricNew.Id = iniVerExc.Id;
                        excPricNew.RE_Initial_Version__c = oldExecPrce.RE_Initial_Version__c;  
                        excPricNew.RE_IsLatest__c = TRUE; 
                        updateInitialVersnLst.add(excPricNew);
                        
                        RE_MOA__c excPricOld = new RE_MOA__c();
                        excPricOld.Id = oldExecPrce.Id;
                        excPricOld.RE_IsLatest__c = FALSE;                  
                        updateInitialVersnLst.add(excPricOld);						
                    }
                }
            }
            
            return updateInitialVersnLst;
        }
        Catch(Exception ex)
        {        
            system.debug('updateInitialVersionInOlderMOA-->'+ex.getMessage());
            IsSuccessJobAudit = false;
            RV_ClassException.insertExceptionRecord('CalculatingDepoPricing',ex.getMessage(),'RE_CND_ExecuteDepoPricingController','updateInitialVersionInOlderMOA','Exception');            
            return updateInitialVersnLst;
        }  
    }
    
    @AuraEnabled 
    // Check Market Move and MOA exist or not in same date
    public static jobRunStatusWrapper getExistingMarketMoveAndMOA(date requested_Date)
    {
        jobRunStatusWrapper jobRunStat = New jobRunStatusWrapper();
        Id marktMveRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Market_Moves').getRecordTypeId();
        Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
        Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndPriceBookRecdTypId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
                
        Integer totalRecords = 0;
        // Check Job already existing 
        jobRunStat = getStatusOfJobRunAudit('Canada Market Move Calculation');
        
        // If already job started processing
        if(jobRunStat.totalRecordCount == 3)                    
            return jobRunStat;        
        else
        {            
            totalRecords = [SELECT count() FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                            AND RE_Status__c IN ('Uploaded', 'Failed', 'Upload not allowed') AND RE_IsLatest__c =: TRUE 
                            AND RE_Requested_Date__c =: requested_Date];   
            
            if(totalRecords == 0)        
            {
                totalRecords = [SELECT count() FROM RT_Price_Book__c WHERE RecordTypeId =: cndPriceBookRecdTypId
                                AND RE_Custom_Opp_Approve__c IN ('Uploaded', 'Failed', 'Upload not allowed') AND RE_Is_Latest__c =: TRUE 
                                AND RT_Effective_Date__c =: requested_Date];           
            }
            
            // Already few records get uploaded 
            if(totalRecords > 0)
            {
                jobRunStat.totalRecordCount = 2;                
                return jobRunStat;
            }
            else
            {
                totalRecords = [SELECT count() FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                AND RE_Status__c IN ('Draft', 'Ready to Upload') AND RE_IsLatest__c =: TRUE 
                                AND RE_Requested_Date__c =: requested_Date];    
                
                if(totalRecords == 0)
                {
                    totalRecords = [SELECT count() FROM RT_Price_Book__c WHERE RecordTypeId =: cndPriceBookRecdTypId
                                    AND RE_Custom_Opp_Approve__c IN ('Draft', 'Ready to Upload') AND RE_Is_Latest__c =: TRUE 
                                    AND RT_Effective_Date__c =: requested_Date];                
                }
                
                if(totalRecords == 0)
                {
                    totalRecords = [SELECT count() FROM RE_MOA__c WHERE (RecordTypeId =: marktMveRecordTypeId OR RecordTypeId =: cadMOARecordTypeId)
                                    AND RE_Requested_Date__c =: requested_Date AND RE_IsLatest__c =: TRUE];                  
                }
                
                // Already MOA/Cost Price/Price Book records exists
                if(totalRecords > 0)
                {
                    jobRunStat.totalRecordCount = 1;                
                    return jobRunStat;
                }
                else
                    // No records exists and it's a fresh start
                    jobRunStat.totalRecordCount = 0;                                               
            }
        }
                
        return jobRunStat;
    }
    
    public class jobRunStatusWrapper {
        @AuraEnabled
        public Integer totalRecordCount;
        @AuraEnabled
        public DateTime jobStartDateTime;
        @AuraEnabled
        public String jobRunName;  
        @AuraEnabled
        public Id jobRunId;
        @AuraEnabled
        public String batchJobIds;
        @AuraEnabled
        public String otherComments;
    }
    
    public class executeMarketMveWrapper {
        @AuraEnabled
        public String executionStatus {get;set;}
        @AuraEnabled
        public String errorMsg {get;set;}   
        @AuraEnabled
        public Id jobRunAuditId {get;set;} 
    }
    
    @AuraEnabled  
    public static executePricingScreenWrapper getMOAGasolineDieselDetails(Date requestedStartDt)   
    {      
        system.debug('requestedStartDt-->'+requestedStartDt);        
        Date requestedDateOnly = requestedStartDt;
        
        executePricingScreenWrapper epswrapper = new executePricingScreenWrapper();
        Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
        Id cadMVRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Market_Moves').getRecordTypeId();
        List<RE_MOA__c> moaGasolineDieselList = New List<RE_MOA__c>();
        Date effctvFromDt, effctvToDt;
        Boolean isCalExcRecodExist = false;
        
        epswrapper.isCalExcRecodExist = false;
        
        for(RE_MOA__c mvData : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Today_s_Price__c,RE_CND_Market_Move__c, RE_CND_Competitive_Adj__c,RE_CND_Net_Move__c, 
                                RE_CND_New_End_Price__c,RE_CND_Difference__c, RE_Requested_Date__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c 
                                FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId 
                                AND RE_Requested_Date__c =: requestedStartDt AND RE_IsLatest__c =: TRUE
                                ORDER BY RE_CND_Effective_From_Date__c,RE_CND_Group__c,RE_CND_Rack__c LIMIT 24])
        {
            moaGasolineDieselList.add(mvData);
            effctvFromDt = mvData.RE_CND_Effective_From_Date__c;
            effctvToDt = mvData.RE_CND_Effective_To_Date__c;
            epswrapper.isCalExcRecodExist = True;
            epswrapper.isBothBtnDisable = false;
        }
        
        epswrapper.moaGasolineDieselList = moaGasolineDieselList;
        
        epswrapper.hasPriceExecuteAccess = calDepotPricingUserAccessLevel();
        
        String fxLiveQuoteName;
        epswrapper.currtFx = 0.00;
        epswrapper.prvFx = 0.00;    
        datetime maxPrevMaxFxDate;
        
        if(epswrapper.moaGasolineDieselList.Size() <= 0)
        {
            Datetime currentDateTime = System.now();
            String dayOfWeek = currentDateTime.format('EEEE'); 
            system.debug('dayOfWeek-->'+dayOfWeek);
            if(dayOfWeek.toLowerCase() == 'friday')
            {                
                epswrapper.fromDate = requestedStartDt.addDays(1);
                epswrapper.toDate = requestedStartDt.addDays(2);
            }
            else
            {
                epswrapper.fromDate = requestedStartDt.addDays(1);                    
                integer addDaysCount = 1;
                
                // get the holiday of Canada to adjust the to date
                for(RE_Holiday_Calendars__c hc: [SELECT Holiday_Date__c from RE_Holiday_Calendars__c
                                                 WHERE Country_Name__c =: 'Canada' AND Is_Active__c =: TRUE 
                                                 AND Holiday_Date__c >=: requestedDateOnly
                                                 ORDER BY Holiday_Date__c])
                {
                    
                    if(hc.Holiday_Date__c == requestedStartDt.addDays(addDaysCount))                                            
                        addDaysCount= addDaysCount + 1;                    
                }
                
                if(addDaysCount > 1)
                    epswrapper.toDate = requestedStartDt.addDays(addDaysCount);  
                else
                    epswrapper.toDate = epswrapper.fromDate;   
            }           
        }
        
        system.debug('epswrapper.fromDate-->'+epswrapper.fromDate);
        system.debug('epswrapper.toDate-->'+epswrapper.toDate);
        
        epswrapper.marketMoveList = [SELECT Id, RE_CND_Group__c, RE_Price_Value__c, RE_CND_Marker_Name__c,
                                     RE_CND_Delta_Percentage__c, RE_CND_Actual_Delta__c, RE_CND_CAD_Delta_cpl__c, RE_CND_PrvDay_Delta_Percentage__c                                    
                                     FROM RE_MOA__c WHERE RecordTypeId =: cadMVRecordTypeId 
                                     AND RE_Requested_Date__c =: requestedStartDt                                      
                                     AND RE_CND_Group__c IN ('Gasoline', 'Gas Oil', 'Fx Rate') AND RE_IsLatest__c =: TRUE
                                     ORDER BY RE_CND_Group__c LIMIT 15];        
        
        for(RE_Zema_Quotes_Settings__c fxQuote: [SELECT Display_Name__c FROM RE_Zema_Quotes_Settings__c 
                                                 WHERE Country__c LIKE '%Canada%' AND Type__c =:'FX Rates' 
                                                 AND Frequency__c =: 'Live' AND Is_Active__c =: TRUE LIMIT 1])
        {
            fxLiveQuoteName = fxQuote.Display_Name__c;
        }
        
        epswrapper.currtFx = 0;
        epswrapper.prvFx = 0;
        Boolean isCurrentFx = true;
        
        // Get last two Fx Rates
        for(RE_FX_Rates__c fx: [SELECT RE_Forex_Rate__c, RE_Pricing_Date__c FROM RE_FX_Rates__c WHERE RE_Quote_Name__c =: fxLiveQuoteName
                                AND RE_Trade_Type__c =: 'Exchange Rate' 
                                ORDER BY RE_Pricing_Date__c DESC LIMIT 2])                               
        {
            if(isCurrentFx)
            {
                epswrapper.currtFx = fx.RE_Forex_Rate__c;                
                Datetime gmtPricngDate = fx.RE_Pricing_Date__c;
                // epswrapper.currtFxDay = gmtPricngDate.format('dd-MMM-YYYY');
                epswrapper.currtFxDay = gmtPricngDate.formatGmt('dd-MMM-YYYY');
                isCurrentFx = false;
            }
            else
            {
                epswrapper.prvFx = fx.RE_Forex_Rate__c;
                Datetime gmtPricngDate = fx.RE_Pricing_Date__c;
                epswrapper.prvFxDay = gmtPricngDate.formatGmt('dd-MMM-YYYY');
                // epswrapper.prvFxDay = gmtPricngDate.format('dd-MMM-YYYY');                
            }     
        }
        
        epswrapper.isCalMVBttnActive = false;
        epswrapper.isCalExcRecodExist = True;
        epswrapper.isBothBtnDisable = false;
        
        if(effctvFromDt == null && effctvToDt == null)
        {
            for(RE_MOA__c mvData : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Today_s_Price__c,RE_CND_Market_Move__c, RE_CND_Competitive_Adj__c,RE_CND_Net_Move__c, 
                                    RE_CND_New_End_Price__c,RE_CND_Difference__c, RE_Requested_Date__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c 
                                    FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId 
                                    AND RE_CND_Effective_From_Date__c <=: requestedStartDt AND RE_CND_Effective_To_Date__c >: requestedStartDt 
                                    AND RE_IsLatest__c =: TRUE LIMIT 1])
            {            
                effctvFromDt = mvData.RE_CND_Effective_From_Date__c;
                effctvToDt = mvData.RE_CND_Effective_To_Date__c;
                epswrapper.isBothBtnDisable = true;
                epswrapper.isCalExcRecodExist = true;
                epswrapper.isCalMVBttnActive = true;  
            }
            
            if(effctvFromDt == null && effctvToDt == null)
            {
                epswrapper.isBothBtnDisable = false;
                epswrapper.isCalExcRecodExist = false;
                epswrapper.isCalMVBttnActive = false;
            }            
        }
        else
        {        
            if(effctvFromDt <= requestedStartDt && effctvToDt >= requestedStartDt)
                epswrapper.isCalMVBttnActive = True;
            else
                epswrapper.isCalMVBttnActive = false;
        }
        
        system.debug('epswrapper.isCalMVBttnActive-->'+epswrapper.isCalMVBttnActive);
        return epswrapper;
    }
    
    public class executePricingScreenWrapper {
        @AuraEnabled
        public Boolean hasPriceExecuteAccess {get;set;}
        @AuraEnabled
        public List<RE_MOA__c> moaGasolineDieselList {get;set;} 
        @AuraEnabled
        public Date fromDate {get;set;}
        @AuraEnabled
        public Date toDate {get;set;}
        @AuraEnabled
        public List<RE_MOA__c> marketMoveList {get;set;} 
        @AuraEnabled
        public String prvFxDay {get;set;}
        @AuraEnabled
        public Decimal prvFx {get;set;}
        @AuraEnabled
        public String currtFxDay {get;set;}
        @AuraEnabled
        public Decimal currtFx {get;set;} 
        @AuraEnabled
        public Boolean isCalMVBttnActive {get;set;}
        @AuraEnabled
        public Boolean isCalExcRecodExist {get;set;} 
        @AuraEnabled
        public Boolean isBothBtnDisable {get;set;}  
    }    
    
    // User can do Calculate Depo pricing or not
    public static Boolean calDepotPricingUserAccessLevel(){
        List<PermissionSetAssignment> permlst = [SELECT Id, PermissionSet.Name, PermissionSet.Profile.Name FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId()];
        for(PermissionSetAssignment perm:permlst){           
            if(perm.PermissionSet.Name == 'RE_CND_Pricing_Permission'){     
                return true;
            }
        } 
        return false;   
    }
    
    @AuraEnabled 
    // Check DepoPricing and Pricebook exist or not in Cost price with Uploaded, Failed and Upload not allowed Status in same date
    public static jobRunStatusWrapper getExistingDepoPricingAndPriceBook(date request_Date)
    {
        system.debug('request_Date-->'+request_Date);
        jobRunStatusWrapper jobRunStat = New jobRunStatusWrapper();
        Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndPriceBookRecdTypId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        Integer totalRecords = 0;
        
        // Check Job already existing 
        jobRunStat = getStatusOfJobRunAudit('Canada Execute Depo Pricing');
                
        // If already job started processing
        if(jobRunStat.totalRecordCount == 3)
            return jobRunStat;        
        else
        {        
            totalRecords = [SELECT count() FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                            AND RE_Status__c IN ('Uploaded', 'Failed', 'Upload not allowed') AND RE_IsLatest__c =: TRUE 
                            AND RE_Requested_Date__c =: request_Date];   
            
            if(totalRecords == 0)        
            {                
                totalRecords = [SELECT count() FROM RT_Price_Book__c WHERE RecordTypeId =: cndPriceBookRecdTypId
                                AND RE_Custom_Opp_Approve__c IN ('Uploaded', 'Failed', 'Upload not allowed') AND RE_Is_Latest__c =: TRUE 
                                AND RT_Effective_Date__c =: request_Date];           
            }
            
            // Already few records get uploaded
            if(totalRecords > 0)
            {                
                jobRunStat.totalRecordCount = 2;                
                return jobRunStat;
            }
            else
            {                
                totalRecords = [SELECT count() FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                AND RE_Status__c IN ('Draft', 'Ready to Upload') AND RE_IsLatest__c =: TRUE 
                                AND RE_Requested_Date__c =: request_Date];    
                
                if(totalRecords == 0)
                {                    
                    totalRecords = [SELECT count() FROM RT_Price_Book__c WHERE RecordTypeId =: cndPriceBookRecdTypId
                                    AND RE_Custom_Opp_Approve__c IN ('Draft', 'Ready to Upload') AND RE_Is_Latest__c =: TRUE 
                                    AND RT_Effective_Date__c =: request_Date];                
                }
                
                // Already Cost Price/Price Book records are exists
                if(totalRecords > 0)
                {                    
                    jobRunStat.totalRecordCount = 1;                    
                    return jobRunStat;
                }
                else
                    // No records exists and it's a fresh start
                    jobRunStat.totalRecordCount = 0;  
            }
        }
                
        return jobRunStat;
    }
    
    public class priceExecuteWrapper {
        @AuraEnabled
        public String pricExecStatus {get;set;}        
        @AuraEnabled
        public Id jobRunAuditId {get;set;} 
    }
    
    @AuraEnabled
    // Start Price Execution- New
    public static priceExecuteWrapper startCalculatingDepoPricing(date request_Date, date effectiveFromDate, date effectiveToDate, List<RE_MOA__c> updatedMOA)
    {
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        priceExecuteWrapper pexecWrpr = New priceExecuteWrapper();       
        
        try
        {     
            Datetime requestdDate = system.now(); 
            Map<String,Decimal> moaDiffChange = new Map<String,Decimal>();
            List<RE_MOA__c> updatedMOALst = new List<RE_MOA__c>();   
            Boolean updateSuccess = False;
            Map<String,Decimal> latestNtMveGasoline = new Map<String,Decimal>();
            Map<String,Decimal> latestNtMveDiesel = new Map<String,Decimal>(); 
            
            jrAudit.RE_Run_Time__c = requestdDate;
            jrAudit.RE_Run_Type__c = 'Manual';
            jrAudit.RE_Job_Type__c = 'Canada Execute Depo Pricing';
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c = 'Processing';
            jrAudit.RE_Country_Name__c='CA';
            insert jrAudit;     
            
            // Set exact effective from & to date in MOA       
            if(updatedMOA.size() > 0)
            {
                // Get current NetMove for gasoline for all Execute Price
                for(RE_MOA__c lstVal : updatedMOA)
                {                   
                    // Get current NetMove for gasoline 
                    if(lstVal.RE_CND_Group__c == 'Gasoline')
                        latestNtMveGasoline.put(lstVal.RE_CND_Rack__c + ' ' +lstVal.RE_CND_Group__c,lstVal.RE_CND_Net_Move__c);
                    // Get current NetMove for Gas Oil
                    else if(lstVal.RE_CND_Group__c == 'Gas Oil')
                        latestNtMveDiesel.put(lstVal.RE_CND_Rack__c + ' ' +lstVal.RE_CND_Group__c,lstVal.RE_CND_Net_Move__c);
                    
                    if((lstVal.RE_CND_Rack__c == 'Ottawa') || (lstVal.RE_CND_Rack__c == 'Thunder Bay') || (lstVal.RE_CND_Rack__c == 'Kamloops')
                       || (lstVal.RE_CND_Rack__c == 'Edmonton') || (lstVal.RE_CND_Rack__c == 'Toronto'))
                    {
                        moaDiffChange.put(lstVal.RE_CND_Rack__c + ' ' +lstVal.RE_CND_Group__c,lstVal.RE_CND_New_End_Price__c);
                    }
                }
                
                for(RE_MOA__c moa: updatedMOA)
                {
                    moa.RE_Requested_Date__c = request_Date;                   
                    moa.RE_CND_Effective_Date__c = requestdDate;
                    moa.RE_CND_Effective_From_Date__c = effectiveFromDate;
                    moa.RE_CND_Effective_To_Date__c = effectiveToDate;
                    
                    if((moa.RE_CND_Rack__c == 'Ottawa') && (moa.RE_CND_Group__c == 'Gasoline'))   
                        moa.RE_CND_Difference__c = (((moa.RE_CND_New_End_Price__c == null) ? 0.00 : moa.RE_CND_New_End_Price__c) - ((moaDiffChange.get('Toronto Gasoline') == null) ? 0.00: moaDiffChange.get('Toronto Gasoline')));
                    else if((moa.RE_CND_Rack__c == 'Ottawa') && (moa.RE_CND_Group__c == 'Gas Oil'))                                
                        moa.RE_CND_Difference__c = (((moa.RE_CND_New_End_Price__c == null) ? 0.00 : moa.RE_CND_New_End_Price__c) - ((moaDiffChange.get('Toronto Gas Oil') == null) ? 0.00 : moaDiffChange.get('Toronto Gas Oil')));
                    else if((moa.RE_CND_Rack__c == 'Thunder Bay') && (moa.RE_CND_Group__c == 'Gasoline'))                                
                        moa.RE_CND_Difference__c = (((moa.RE_CND_New_End_Price__c == null) ? 0.00 : moa.RE_CND_New_End_Price__c) - ((moaDiffChange.get('Edmonton Gasoline') == null) ? 0.00 : moaDiffChange.get('Edmonton Gasoline')));
                    else if((moa.RE_CND_Rack__c == 'Thunder Bay') && (moa.RE_CND_Group__c == 'Gas Oil'))                                
                        moa.RE_CND_Difference__c = (((moa.RE_CND_New_End_Price__c == null) ? 0.00 : moa.RE_CND_New_End_Price__c) - ((moaDiffChange.get('Edmonton Gas Oil') == null) ? 0.00 : moaDiffChange.get('Edmonton Gas Oil')));                       
                    else if((moa.RE_CND_Rack__c == 'Kamloops') && (moa.RE_CND_Group__c == 'Gasoline'))
                        moa.RE_CND_Difference__c = (((moa.RE_CND_New_End_Price__c == null) ? 0.00 : moa.RE_CND_New_End_Price__c) - ((moaDiffChange.get('Edmonton Gasoline') == null) ? 0.00 : moaDiffChange.get('Edmonton Gasoline')));                                        
                    else if((moa.RE_CND_Rack__c == 'Kamloops') && (moa.RE_CND_Group__c == 'Gas Oil'))                                
                        moa.RE_CND_Difference__c = (((moa.RE_CND_New_End_Price__c == null) ? 0.00 : moa.RE_CND_New_End_Price__c) - ((moaDiffChange.get('Edmonton Gas Oil') == null) ? 0.00 : moaDiffChange.get('Edmonton Gas Oil')));
                    
                    updatedMOALst.add(moa);
                }
            }
            
            // Update adjustment data in MOA
            if(updatedMOALst.size() > 0)
            {               
                Database.SaveResult[] updateList = Database.update(updatedMOALst, false);
                updateSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_ExecuteDepoPricingController','startCalculatingDepoPricing-UpdateMOA',updateList,false, jrAudit);                                                           
            }
            
            // Queueable Class
            RE_CND_StartCalculatingDepoPricingQueue calcDepotPricngQue = New RE_CND_StartCalculatingDepoPricingQueue(requestdDate, request_Date, effectiveFromDate, effectiveToDate, jrAudit.Id, latestNtMveGasoline, latestNtMveDiesel);
            // Enqueue the job for processing
            ID jobID = System.enqueueJob(calcDepotPricngQue); 
            
            pexecWrpr.jobRunAuditId = jrAudit.Id;
            pexecWrpr.pricExecStatus = 'success';           
            return pexecWrpr;
        }
        catch(Exception ex)
        {       
            System.debug('startCalculatingDepoPricing-Main-->'+ex.getMessage());
            System.debug('startCalculatingDepoPricing-Main-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('CalculatingDepoPricing',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','startCalculatingDepoPricing-Main','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);    
            pexecWrpr.pricExecStatus = 'failed';
            return pexecWrpr;
        }  
    }
    
    // To update the InitialVersion for the older in CostPrice
    public static list<RE_MY_CostPrice__c> updateInitialVersionInOlderCostPrice(Set<Id> costPriceIds, currentDayRecordsWrapper curDayRecrdWrapr)
    {
        List<RE_MY_CostPrice__c> updateInitialVersnLst = new List<RE_MY_CostPrice__c>();        
        
        try
        {
            RE_MY_CostPrice__c oldCostPrice = new RE_MY_CostPrice__c();                  
            if(curDayRecrdWrapr.currtDayMapCostPriceList.Size() > 0)
            {
                for(RE_MY_CostPrice__c iniVer : [SELECT Id, Name, RE_Initial_Version__c, RE_IsLatest__c, RE_Status__c,
                                                 RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Rack__c, RE_CND_Product_Group__c, RE_CND_Group__c
                                                 FROM RE_MY_CostPrice__c WHERE Id in : costPriceIds])
                {                    
                    // Get the previous is latest = true from Cost Price Values, if exists 
                    if(curDayRecrdWrapr.currtDayMapCostPriceList.containsKey(iniVer.RE_Product_Codes__c+iniVer.RE_Depot_Code__c+iniVer.RE_CND_Rack__c+iniVer.RE_CND_Product_Group__c+iniVer.RE_CND_Group__c))                                                
                    {                        
                        oldCostPrice = curDayRecrdWrapr.currtDayMapCostPriceList.get(iniVer.RE_Product_Codes__c+iniVer.RE_Depot_Code__c+iniVer.RE_CND_Rack__c+iniVer.RE_CND_Product_Group__c+iniVer.RE_CND_Group__c);                        
                        RE_MY_CostPrice__c costprcNew = new RE_MY_CostPrice__c();
                        costprcNew.Id = iniVer.Id;
                        costprcNew.RE_Initial_Version__c = oldCostPrice.RE_Initial_Version__c;                        
                        updateInitialVersnLst.add(costprcNew);                      
                    }
                    else
                    {
                        // Set name into Initial Version for the non-matching records
                        RE_MY_CostPrice__c costprcNew = new RE_MY_CostPrice__c();
                        costprcNew.Id = iniVer.Id;
                        costprcNew.RE_Initial_Version__c = iniVer.Name;                        
                        updateInitialVersnLst.add(costprcNew);                       
                    }                    
                }
            }
            
            // Set all Old records with same day as Redundant
            if(curDayRecrdWrapr.currtDayCostPrcList.Size() > 0)
            {
                for(RE_MY_CostPrice__c oldCP: curDayRecrdWrapr.currtDayCostPrcList)
                {
                    RE_MY_CostPrice__c costprcOld = new RE_MY_CostPrice__c();
                    costprcOld.Id = oldCP.Id;
                    costprcOld.RE_IsLatest__c = FALSE;  
                    costprcOld.RE_Status__c = 'Redundant';
                    updateInitialVersnLst.add(costprcOld);
                }
            }
            
            return updateInitialVersnLst;
        }
        Catch(Exception ex)
        {
            System.debug('updateInitialVersionInCostPrice-->'+ex.getMessage());
            System.debug('updateInitialVersionInCostPrice-LN-->'+ex.getLineNumber());
            IsSuccessJobAudit = false;
            RV_ClassException.insertExceptionRecord('CalculatingDepoPricing',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','updateInitialVersionInCostPrice','Exception');            
            return updateInitialVersnLst;
        }       
    }
    
    // To update the InitialVersion same as Name in CostPrice for the first time in a day
    public static list<RE_MY_CostPrice__c> updateInitialVersionInCostPrice(Set<Id> costPriceIds)
    {
        Map<Id, String> cstPricUpdatedIds = New Map<Id, String>();
        List<RE_MY_CostPrice__c> initialVersnLst = new List<RE_MY_CostPrice__c>();
        
        for(RE_MY_CostPrice__c iniVer : [SELECT Id, Name, RE_Initial_Version__c FROM RE_MY_CostPrice__c
                                         WHERE Id in : costPriceIds])
        {                
            if(!cstPricUpdatedIds.containsKey(iniVer.Id))
            {
                iniVer.RE_Initial_Version__c = iniVer.Name;
                initialVersnLst.add(iniVer);
                cstPricUpdatedIds.put(iniVer.Id,iniVer.Name);
            }
        }
        
        return initialVersnLst;        
    }
    
    // Execute pricing Logic
    public static RE_MY_CostPrice__c calculatePricingLogic(date request_Date, RE_Depot_Pricing_Backbone__c depotPricing, List<RT_Setting__c> cndActivePricngDiff, Map<String,RE_MY_CostPrice__c> prevDayCostPrice, datetime requestdDate, date effectiveFromDate, date effectiveToDate, Boolean isExecuteBase, Decimal netMoveValue, Boolean isDrivedProducts, Decimal newBaseValue, Decimal currtFxRate, String moaUnitRate, String baseProdctUnitRate,Map<Id,String> diffType, Map<Id,Decimal> diffValue, Map<Id,String> diffUnit,
                                                           Decimal rackBaseDiff, String refBaseRack, List<RE_MOA__c> updatedMOAData)
    {        
        Decimal currntGasolineDieselNetMove = 0.00;        
        pricingDifferentialWrapper prcngdiff = new pricingDifferentialWrapper();
        RE_MY_CostPrice__c prvCostPrice = new RE_MY_CostPrice__c();
        List<RE_MY_CostPrice__c> prvCostPriceLst = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c currCostPrice = new RE_MY_CostPrice__c();
        Map<String,Decimal> currentNtMveGasoline = new Map<String,Decimal>();
        Map<String,Decimal> currentNtMveDiesel = new Map<String,Decimal>();
        Map<String,Double> currfxRateMap = New Map<String,Double>();
        Map<String,Double> prevfxRateMap = New Map<String,Double>();
        String BaseCurrency,ConvertedCurrency;      
        
        try
        {
            RE_unitConversion unitConv = New RE_unitConversion();
            
            // This is for base products
            if(!String.isBlank(baseProdctUnitRate) && (moaUnitRate != depotPricing.RE_Final_Price_Unit__c))
            {             
                // Current day Base & Converted Unit Rate
                BaseCurrency =  (RE_unitConversion.unitBreakUp(moaUnitRate) == null) ? 'USD' : RE_unitConversion.unitBreakUp(moaUnitRate)[0];                    
                ConvertedCurrency = (RE_unitConversion.unitBreakUp(depotPricing.RE_Final_Price_Unit__c) == null) ? 'CAD' : RE_unitConversion.unitBreakUp(depotPricing.RE_Final_Price_Unit__c)[0];                
                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,currtFxRate);                
                netMoveValue = netMoveValue * unitConv.unitConversionMultiplier(moaUnitRate,depotPricing.RE_Final_Price_Unit__c,'Canada',depotPricing.RE_Product_Name__r.RE_Product_Group__c,currfxRateMap);
                newBaseValue = newBaseValue * unitConv.unitConversionMultiplier(moaUnitRate,depotPricing.RE_Final_Price_Unit__c,'Canada',depotPricing.RE_Product_Name__r.RE_Product_Group__c,currfxRateMap);                
            }
            // This is for derived products
            else if(!String.isBlank(baseProdctUnitRate) && (baseProdctUnitRate != depotPricing.RE_Final_Price_Unit__c))
            {           
                // Current day Base & Converted Unit Rate
                BaseCurrency = (RE_unitConversion.unitBreakUp(baseProdctUnitRate) == null) ? 'USD' : RE_unitConversion.unitBreakUp(baseProdctUnitRate)[0];                 
                ConvertedCurrency = (RE_unitConversion.unitBreakUp(depotPricing.RE_Final_Price_Unit__c) == null) ? 'CAD' : RE_unitConversion.unitBreakUp(depotPricing.RE_Final_Price_Unit__c)[0];
                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,currtFxRate); 
                netMoveValue = netMoveValue * unitConv.unitConversionMultiplier(baseProdctUnitRate,depotPricing.RE_Final_Price_Unit__c,'Canada',depotPricing.RE_Product_Name__r.RE_Product_Group__c,currfxRateMap);
                newBaseValue = newBaseValue * unitConv.unitConversionMultiplier(baseProdctUnitRate,depotPricing.RE_Final_Price_Unit__c,'Canada',depotPricing.RE_Product_Name__r.RE_Product_Group__c,currfxRateMap);                        
            }
            
            // Get current NetMove for gasoline & Gasoil for all base products
            if((updatedMOAData.Size() > 0)&& (!isDrivedProducts))
            {
                for(RE_MOA__c lstVal : updatedMOAData)
                {
                    // Get current NetMove for gasoline
                    if((lstVal.RE_CND_Group__c == 'Gasoline') && (moaUnitRate == depotPricing.RE_Final_Price_Unit__c))
                        currentNtMveGasoline.put(lstVal.RE_CND_Rack__c + ' ' +lstVal.RE_CND_Group__c, lstVal.RE_CND_Net_Move__c);
                    else if((lstVal.RE_CND_Group__c == 'Gasoline') && (moaUnitRate != depotPricing.RE_Final_Price_Unit__c))
                        currentNtMveGasoline.put(lstVal.RE_CND_Rack__c + ' ' +lstVal.RE_CND_Group__c, lstVal.RE_CND_Net_Move__c  * unitConv.unitConversionMultiplier(moaUnitRate,depotPricing.RE_Final_Price_Unit__c,'Canada',null,currfxRateMap));
                    // Get current NetMove for Gas Oil
                    else if((lstVal.RE_CND_Group__c == 'Gas Oil') && (moaUnitRate == depotPricing.RE_Final_Price_Unit__c)) 
                        currentNtMveDiesel.put(lstVal.RE_CND_Rack__c + ' ' +lstVal.RE_CND_Group__c, lstVal.RE_CND_Net_Move__c); 
                    else if((lstVal.RE_CND_Group__c == 'Gas Oil') && (moaUnitRate != depotPricing.RE_Final_Price_Unit__c))
                        currentNtMveDiesel.put(lstVal.RE_CND_Rack__c + ' ' +lstVal.RE_CND_Group__c,lstVal.RE_CND_Net_Move__c  * unitConv.unitConversionMultiplier(moaUnitRate,depotPricing.RE_Final_Price_Unit__c,'Canada',null,currfxRateMap));
                }               
            }
            
            // Get current Pricing Differential Values
            if(isDrivedProducts)
            {                
                prcngdiff = getCurrentPricingDifferential(diffType, diffValue, diffUnit,depotPricing.RE_CND_Plant_Differential__c, depotPricing.RE_CND_Product_Differentials__c,
                                                          depotPricing.RE_CND_Brand_Fees__c, depotPricing.RE_CND_Brand_Discount__c, depotPricing.RE_Final_Price_Unit__c, currtFxRate,depotPricing.RE_Product_Name__r.RE_Product_Group__c);               
            }    
            
            // Get current NetMove Values
            if(isExecuteBase)
            {                
                if(currentNtMveGasoline.containsKey(depotPricing.RE_CND_Differential_Basis__c))                             
                    currntGasolineDieselNetMove = currentNtMveGasoline.get(depotPricing.RE_CND_Differential_Basis__c);          
                else if(currentNtMveDiesel.containsKey(depotPricing.RE_CND_Differential_Basis__c))             
                    currntGasolineDieselNetMove = currentNtMveDiesel.get(depotPricing.RE_CND_Differential_Basis__c);        
            }        
            else      
                currntGasolineDieselNetMove = netMoveValue;
            
            // get the Previous day's cost price for base & derived products
            if(prevDayCostPrice.size() > 0)
            {        
                // Get Previous Cost Price Values, if exists 
                if(prevDayCostPrice.containsKey(depotPricing.RE_Product_Name__r.RT_Product_Code__c+'-'+depotPricing.RE_Location_Name__r.RE_Location_Code__c+'-'+depotPricing.RE_CND_Group__c))                                  
                    prvCostPrice = prevDayCostPrice.get(depotPricing.RE_Product_Name__r.RT_Product_Code__c+'-'+depotPricing.RE_Location_Name__r.RE_Location_Code__c+'-'+depotPricing.RE_CND_Group__c);
                else
                    // if no previous day cost price then get the base products values to set as old base for this product
                    prvCostPrice = getPrevDayBaseDifferentials(depotPricing,prevDayCostPrice);  
                
                if(prvCostPrice != null)
                    prvCostPriceLst.add(prvCostPrice);
            }        
            
            currCostPrice.RecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            currCostPrice.RE_Pricing_Date__c = requestdDate;
            currCostPrice.RE_Requested_Date__c = request_Date;
            currCostPrice.RE_CND_Effective_From_Date__c = effectiveFromDate;
            currCostPrice.RE_CND_Effective_To_Date__c = effectiveToDate;
            currCostPrice.RE_Product_Name__c = depotPricing.RE_Product_Name__c;
            currCostPrice.RE_Depot_Name__c = depotPricing.RE_Location_Name__c;  
            currCostPrice.RE_CND_Group__c = depotPricing.RE_CND_Group__c;
            
            if(isDrivedProducts)
            {
                currCostPrice.RE_CND_Differential_Basis__c = '';
                currCostPrice.RE_CND_Pricing_Basis__c = depotPricing.RE_CND_Pricing_Basis__c;
            }
            else
            {
                currCostPrice.RE_CND_Differential_Basis__c = depotPricing.RE_CND_Differential_Basis__c; 
                currCostPrice.RE_CND_Pricing_Basis__c = ''; 
            }               
            
            currCostPrice.RE_CND_Rack__c = depotPricing.RE_CND_Rack__c;
            currCostPrice.RE_CND_Product_Group__c = depotPricing.RE_CND_Product_Group__c;                   
            currCostPrice.RE_CND_Parent_Rack__c = depotPricing.RE_CND_Parent_Rack__c;
            currCostPrice.RE_CND_Parent_Rack_Group__c = depotPricing.RE_CND_Parent_Rack_Group__c;  
            currCostPrice.RE_CND_Notify_Users__c = depotPricing.RE_CND_Notify_Users__c;
            currCostPrice.RE_CND_Is_only_applicable_to_SFJ__c = depotPricing.RE_CND_Is_only_applicable_to_SFJ__c;
            
            if((depotPricing.RE_CND_Required_CanadianDailyRack__c) || (depotPricing.RE_CND_Required_CanadianDailyRack7Day__c))
            {
                currCostPrice.RE_CND_Required_CanadianDailyRack__c = depotPricing.RE_CND_Required_CanadianDailyRack__c;
                currCostPrice.RE_CND_Required_CanadianDailyRack7Day__c = depotPricing.RE_CND_Required_CanadianDailyRack7Day__c;                          
                currCostPrice.RE_CND_CanadianDailyRack_Location__c = depotPricing.RE_CND_CanadianDailyRack_Location__c;
                currCostPrice.RE_CND_PA_loc_code__c = depotPricing.RE_CND_PA_loc_code__c;
                currCostPrice.RE_CND_DEX_loc_code__c = depotPricing.RE_CND_DEX_loc_code__c;
                currCostPrice.RE_CND_DEX_Products__c = depotPricing.RE_CND_DEX_Products__c;
                currCostPrice.RE_CND_DEX_product_code__c = depotPricing.RE_CND_DEX_product_code__c;
                currCostPrice.RE_CND_PA_Product_code__c = depotPricing.RE_CND_PA_Product_code__c;
                currCostPrice.RE_CND_PA__c = depotPricing.RE_CND_PA__c;            
            }
            
            if(depotPricing.RE_CND_Required_CanadianDailyRack__c) 
                currCostPrice.RE_CND_CanadianDailyRack_DEX__c = depotPricing.RE_CND_CanadianDailyRack_DEX__c;     
            
            if(depotPricing.RE_CND_Required_CanadianDailyRack7Day__c) 
                currCostPrice.RE_CND_CanadianDailyRack7Day_DEX__c = depotPricing.RE_CND_CanadianDailyRack7Day_DEX__c;          
            
            currCostPrice.RE_CND_Adjustment_Value__c = 0.00;                   
            
            if(!isDrivedProducts)
                currCostPrice.RE_CND_Market_Move__c = ((currntGasolineDieselNetMove == null) ? 0.00 : currntGasolineDieselNetMove.setScale(4)); 
            else                
                currCostPrice.RE_CND_Market_Move__c = ((netMoveValue == null) ? 0.00 : netMoveValue.setScale(4));  
            
            if((prvCostPriceLst.Size() > 0 && !prvCostPriceLst.isEmpty()) && (!isDrivedProducts)) 
            {     
                if(prvCostPrice.RE_Costprice_Unit__c == depotPricing.RE_Final_Price_Unit__c)
                {                   
                    currCostPrice.RE_CND_Old_Base_Value__c = (prvCostPrice.RE_CND_Final_Value__c == null) ? 0.00 : prvCostPrice.RE_CND_Final_Value__c.setScale(4);                 
                    currCostPrice.RE_CND_New_Base_Value__c = (((prvCostPrice.RE_CND_Final_Value__c == null) ? 0.00 : prvCostPrice.RE_CND_Final_Value__c) + (currntGasolineDieselNetMove == null ? 0.00 : currntGasolineDieselNetMove));           
                    currCostPrice.RE_CND_New_Base_Value__c = currCostPrice.RE_CND_New_Base_Value__c.setScale(4);                    
                }
                else
                {
                    BaseCurrency = RE_unitConversion.unitBreakUp(prvCostPrice.RE_Costprice_Unit__c)[0];                    
                    ConvertedCurrency = RE_unitConversion.unitBreakUp(depotPricing.RE_Final_Price_Unit__c)[0];                    
                    prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvCostPrice.RE_Fx_Rate__c);                    
                    
                    currCostPrice.RE_CND_Old_Base_Value__c = (prvCostPrice.RE_CND_Final_Value__c == null) ? 0.00 : (prvCostPrice.RE_CND_Final_Value__c * unitConv.unitConversionMultiplier(BaseCurrency,ConvertedCurrency,'Canada',null,prevfxRateMap)).setScale(4);                 
                    currCostPrice.RE_CND_New_Base_Value__c = (((prvCostPrice.RE_CND_Final_Value__c == null) ? 0.00 : prvCostPrice.RE_CND_Final_Value__c * unitConv.unitConversionMultiplier(BaseCurrency,ConvertedCurrency,'Canada',null,prevfxRateMap)) + (currntGasolineDieselNetMove == null ? 0.00 : currntGasolineDieselNetMove));           
                    currCostPrice.RE_CND_New_Base_Value__c = currCostPrice.RE_CND_New_Base_Value__c.setScale(4);                    
                }
            }
            else if((prvCostPriceLst.Size() > 0 && !prvCostPriceLst.isEmpty()) && (isDrivedProducts)) 
            { 
                if(prvCostPrice.RE_Costprice_Unit__c == depotPricing.RE_Final_Price_Unit__c)
                {                    
                    currCostPrice.RE_CND_Old_Base_Value__c = (prvCostPrice.RE_CND_Final_Value__c == null) ? 0.00 : prvCostPrice.RE_CND_Final_Value__c.setScale(4);                 
                    currCostPrice.RE_CND_New_Base_Value__c = ((newBaseValue == null) ? 0.00 : newBaseValue.setScale(4));                     
                }
                else
                {
                    BaseCurrency = RE_unitConversion.unitBreakUp(prvCostPrice.RE_Costprice_Unit__c)[0];
                    ConvertedCurrency = RE_unitConversion.unitBreakUp(depotPricing.RE_Final_Price_Unit__c)[0];
                    prevfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,prvCostPrice.RE_Fx_Rate__c);    
                    
                    currCostPrice.RE_CND_Old_Base_Value__c = (prvCostPrice.RE_CND_Final_Value__c == null) ? 0.00 : prvCostPrice.RE_CND_Final_Value__c * unitConv.unitConversionMultiplier(BaseCurrency,ConvertedCurrency,'Canada',null,prevfxRateMap);                 
                    currCostPrice.RE_CND_Old_Base_Value__c = currCostPrice.RE_CND_Old_Base_Value__c.setScale(4);
                    currCostPrice.RE_CND_New_Base_Value__c = ((newBaseValue == null) ? 0.00 : newBaseValue.setScale(4));                     
                }
            }
            else
            {   
                if(isDrivedProducts)
                {                    
                    currCostPrice.RE_CND_New_Base_Value__c = ((newBaseValue == null) ? 0.00 : newBaseValue.setScale(4));
                    currCostPrice.RE_CND_Old_Base_Value__c = 0.00;             
                }
                else
                {             
                    if(moaUnitRate != depotPricing.RE_Final_Price_Unit__c)
                    {                        
                        // Current day Base & Converted Unit Rate
                        BaseCurrency = RE_unitConversion.unitBreakUp(moaUnitRate)[0];
                        ConvertedCurrency = RE_unitConversion.unitBreakUp(depotPricing.RE_Final_Price_Unit__c)[0];
                        currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,currtFxRate); 
                        
                        currCostPrice.RE_CND_New_Base_Value__c = (currCostPrice.RE_CND_Old_Base_Value__c * unitConv.unitConversionMultiplier(BaseCurrency,ConvertedCurrency,'Canada',null,currfxRateMap))+ ((currntGasolineDieselNetMove == null) ? 0.00 : currntGasolineDieselNetMove);
                        currCostPrice.RE_CND_Old_Base_Value__c = 0.00;                        
                    }
                    else
                    {                        
                        currCostPrice.RE_CND_New_Base_Value__c = currCostPrice.RE_CND_Old_Base_Value__c + ((currntGasolineDieselNetMove == null) ? 0.00 : currntGasolineDieselNetMove);
                        currCostPrice.RE_CND_Old_Base_Value__c = 0.00;                        
                    }
                }             
            }
            
            currCostPrice.RE_CND_Reference_Rack__c = refBaseRack;
            currCostPrice.RE_CND_Rack_Basis_Differential__c = rackBaseDiff;
            currCostPrice.RE_Comments__c = depotPricing.RE_Comments__c;           
            currCostPrice.RE_CND_Special_Adjustment__c = (depotPricing.RE_CND_Special_Adjustment__c == null) ? 0.00 : depotPricing.RE_CND_Special_Adjustment__c;
            
            currCostPrice.RE_CND_Product_Differential__c = (prcngdiff.productDifferentialValue == null) ? 0.00 : prcngdiff.productDifferentialValue;
            currCostPrice.RE_CND_Brand_Fee__c = (prcngdiff.brandFeeValue == null) ? 0.00 : prcngdiff.brandFeeValue;
            currCostPrice.RE_CND_Plant_Differential__c = (prcngdiff.plantDifferentialValue == null) ? 0.00 : prcngdiff.plantDifferentialValue; 
            currCostPrice.RE_CND_Brand_Discount__c = (prcngdiff.brandDiscountValue == null) ? 0.00 : prcngdiff.brandDiscountValue;
            currCostPrice.RE_CND_New_Base_Value__c = currCostPrice.RE_CND_New_Base_Value__c.setScale(4);
            currCostPrice.RE_CND_Final_Value__c = currCostPrice.RE_CND_New_Base_Value__c + currCostPrice.RE_CND_Product_Differential__c + currCostPrice.RE_CND_Brand_Fee__c + currCostPrice.RE_CND_Plant_Differential__c + currCostPrice.RE_CND_Brand_Discount__c + currCostPrice.RE_CND_Special_Adjustment__c + currCostPrice.RE_CND_Rack_Basis_Differential__c; 
            currCostPrice.RE_CND_Final_Value__c = currCostPrice.RE_CND_Final_Value__c.setScale(4);
            
            currCostPrice.RE_CND_Is_Base_Product__c = depotPricing.RE_CND_Is_Base_Product__c;
            currCostPrice.RE_CND_Supplier1_Price__c = 0.00;
            currCostPrice.RE_CND_Supplier2_Price__c = 0.00;
            currCostPrice.RE_CND_Supplier3_Price__c = 0.00;
            currCostPrice.RE_CND_Supplier4_Price__c = 0.00;
            currCostPrice.RE_Costprice_Unit__c = depotPricing.RE_Final_Price_Unit__c;
            currCostPrice.RE_Fx_Rate__c = currtFxRate.setScale(4);
            currCostPrice.RE_IsLatest__c = TRUE;
            currCostPrice.RE_Status__c = 'Draft';
            currCostPrice.RE_CND_NewRack_Or_NewBAPP_File__c = depotPricing.RE_CND_NewRack_Or_NewBAPP_File__c;
            currCostPrice.RE_CND_Required_in_Rack_Prices__c = depotPricing.RE_CND_Required_in_Rack_Prices__c;
            currCostPrice.RE_CND_Rack_Prices_Location__c = depotPricing.RE_CND_Rack_Prices_Location__c;
            currCostPrice.RE_CND_Rack_Prices_Product__c = depotPricing.RE_CND_Rack_Prices_Product__c;
            currCostPrice.RE_CND_Req_in_DailyRackChange_Notifi__c = depotPricing.RE_CND_Req_in_DailyRackChange_Notifi__c;
            currCostPrice.RE_CND_Required_in_OPIS_Comparison__c = depotPricing.RE_CND_Required_in_OPIS_Comparison__c;
            
            return currCostPrice;
        }
        Catch(Exception ex)
        {         
            IsSuccessJobAudit = false;
            System.debug('calculatePricingLogic-SubMethod-Error-->'+ex.getLineNumber());  
            System.debug('calculatePricingLogic-SubMethod-Error-LN-->'+ex.getMessage());  
            System.debug('prvCostPriceLst-->'+prvCostPriceLst);
            if(Limits.getDmlStatements() < 100)
                RV_ClassException.insertExceptionRecord('CalculatingDepoPricing',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','calculatePricingLogic-SubMethod','Exception');
            return currCostPrice;
        }
    }
    
    // Get all the Active Canada Pricing Differential
    public static differentialRecordsWrapper getActiveCNDPricngDifferential(Id cndPricngDiffRecdTypId)
    {
        differentialRecordsWrapper diffRecod = New differentialRecordsWrapper();
        Map<Id,String> diffType = New Map<Id,String>();
        Map<Id,Decimal> diffValue = New Map<Id,Decimal>();
        Map<Id,String> diffUnit = New Map<Id,String>();
        
        for(RT_Setting__c pricngDiff: [SELECT Id, RE_CND_Differential_Type__c, RE_Value__c, RE_Rate_Unit__c
                                       FROM RT_Setting__c 
                                       WHERE RecordTypeId =: cndPricngDiffRecdTypId AND Active__c =: TRUE]) 
        {
            diffType.put(pricngDiff.Id,pricngDiff.RE_CND_Differential_Type__c);
            diffValue.put(pricngDiff.Id,pricngDiff.RE_Value__c);
            diffUnit.put(pricngDiff.Id,pricngDiff.RE_Rate_Unit__c);
        }
        
        diffRecod.diffRecordType = diffType; 
        diffRecod.diffRecordValue = diffValue; 
        diffRecod.diffRecordUnit = diffUnit; 
        
        return diffRecod;        
    }
    
    public class differentialRecordsWrapper {      
        @AuraEnabled
        public Map<Id,String> diffRecordType {get;set;} 
        @AuraEnabled
        public Map<Id,Decimal> diffRecordValue {get;set;} 
        @AuraEnabled
        public Map<Id,String> diffRecordUnit {get;set;} 
    }
    
    // Get previous days cost price for base & derived product records 
    public static RE_MY_CostPrice__c getPrevDayBaseDifferentials(RE_Depot_Pricing_Backbone__c depotPricing, Map<String,RE_MY_CostPrice__c> prevDayCostPrice)
    {
        RE_MY_CostPrice__c prvCostPrice = new RE_MY_CostPrice__c();   
        for(string idValue : prevDayCostPrice.keyset())
        {          
            RE_MY_CostPrice__c prevCP = prevDayCostPrice.get(idValue);
            
            if((prevCP.RE_CND_Pricing_Basis__c == depotPricing.RE_CND_Pricing_Basis__c) &&                  
               (depotPricing.RE_CND_Is_Base_Product__c == FALSE))
            {             
                prvCostPrice = prevCP;   
                return prvCostPrice;
            }
            
            if((prevCP.RE_CND_Group__c == depotPricing.RE_CND_Group__c) && (prevCP.RE_CND_Rack__c == depotPricing.RE_CND_Rack__c)
               && (prevCP.RE_CND_Product_Group__c == depotPricing.RE_CND_Product_Group__c) && (depotPricing.RE_CND_Is_Base_Product__c == TRUE))                  
            {
                prvCostPrice = prevCP;
                return prvCostPrice;
            }   
        }              
        
        return prvCostPrice;
    }
    
    // Get the current PricingDifferential Values    
    public static pricingDifferentialWrapper getCurrentPricingDifferential(Map<Id,String> diffType, Map<Id,Decimal> diffValue, Map<Id,String> diffUnit, Id plantDifferentialId, Id productDifferentialId, Id brandFeeId, Id brandDiscountId, String depoUnitRate, Decimal currtFxRate, String prodctGrp)
    {
        pricingDifferentialWrapper prcngdiff = new pricingDifferentialWrapper();
        
        try
        {     
            if(productDifferentialId != null && diffType.containsKey(productDifferentialId) && diffType.get(productDifferentialId) == 'Product Differential'
               && diffUnit.get(productDifferentialId) != null && diffUnit.get(productDifferentialId) == depoUnitRate)                
            {
                prcngdiff.productDifferentialValue = diffValue.get(productDifferentialId).setScale(4);              
            }
            else if(productDifferentialId != null && diffType.containsKey(productDifferentialId) && diffType.get(productDifferentialId) == 'Product Differential'
                    && diffUnit.get(productDifferentialId) != null && diffUnit.get(productDifferentialId) != depoUnitRate)  
            {
                String BaseCurrency, ConvertedCurrency;
                RE_unitConversion unitConv = New RE_unitConversion();                
                Map<String,Double> currfxRateMap = New Map<String,Double>();
                
                // Current day Base & Converted Unit Rate
                BaseCurrency = (RE_unitConversion.unitBreakUp(diffUnit.get(productDifferentialId)) == null) ? 'USD' : RE_unitConversion.unitBreakUp(diffUnit.get(productDifferentialId))[0];
                ConvertedCurrency = (RE_unitConversion.unitBreakUp(depoUnitRate) == null) ? 'CAD' : RE_unitConversion.unitBreakUp(depoUnitRate)[0];
                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,currtFxRate);        
                prcngdiff.productDifferentialValue = (diffValue.get(productDifferentialId) * unitConv.unitConversionMultiplier(diffUnit.get(productDifferentialId),depoUnitRate,'Canada',prodctGrp,currfxRateMap)).setScale(4); 
            }
            
            if(brandFeeId != null && diffType.containsKey(brandFeeId) && diffType.get(brandFeeId) == 'Brand Fee'
               && diffUnit.get(brandFeeId) != null && diffUnit.get(brandFeeId) == depoUnitRate) 
            {
                prcngdiff.brandFeeValue = diffValue.get(brandFeeId).setScale(4); 
            }
            else if(brandFeeId != null && diffType.containsKey(brandFeeId) && diffType.get(brandFeeId) == 'Brand Fee'
                    && diffUnit.get(brandFeeId) != null && diffUnit.get(brandFeeId) != depoUnitRate) 
            {
                String BaseCurrency, ConvertedCurrency;
                RE_unitConversion unitConv = New RE_unitConversion();                
                Map<String,Double> currfxRateMap = New Map<String,Double>();
                
                // Current day Base & Converted Unit Rate
                BaseCurrency = (RE_unitConversion.unitBreakUp(diffUnit.get(brandFeeId)) == null) ? 'USD' : RE_unitConversion.unitBreakUp(diffUnit.get(brandFeeId))[0];
                ConvertedCurrency = (RE_unitConversion.unitBreakUp(depoUnitRate) == null) ? 'CAD' : RE_unitConversion.unitBreakUp(depoUnitRate)[0];
                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,currtFxRate);        
                prcngdiff.brandFeeValue = (diffValue.get(brandFeeId) * unitConv.unitConversionMultiplier(diffUnit.get(brandFeeId),depoUnitRate,'Canada',null,currfxRateMap)).setScale(4); 
            }
            
            if(brandDiscountId != null && diffType.containsKey(brandDiscountId) && diffType.get(brandDiscountId) == 'Brand Discount'
               && diffUnit.get(brandDiscountId) != null && diffUnit.get(brandDiscountId) == depoUnitRate) 
            {
                prcngdiff.brandDiscountValue = diffValue.get(brandDiscountId).setScale(4); 
            }
            else if(brandDiscountId != null && diffType.containsKey(brandDiscountId) && diffType.get(brandDiscountId) == 'Brand Discount'
                    && diffUnit.get(brandDiscountId) != null && diffUnit.get(brandDiscountId) != depoUnitRate)
            {
                String BaseCurrency, ConvertedCurrency;
                RE_unitConversion unitConv = New RE_unitConversion();                
                Map<String,Double> currfxRateMap = New Map<String,Double>();
                
                // Current day Base & Converted Unit Rate
                BaseCurrency = (RE_unitConversion.unitBreakUp(diffUnit.get(brandDiscountId)) == null) ? 'USD' : RE_unitConversion.unitBreakUp(diffUnit.get(brandDiscountId))[0];
                ConvertedCurrency = (RE_unitConversion.unitBreakUp(depoUnitRate) == null) ? 'CAD' : RE_unitConversion.unitBreakUp(depoUnitRate)[0];
                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,currtFxRate);        
                prcngdiff.brandDiscountValue = (diffValue.get(brandDiscountId) * unitConv.unitConversionMultiplier(diffUnit.get(brandDiscountId),depoUnitRate,'Canada',null,currfxRateMap)).setScale(4); 
            }
            
            if(plantDifferentialId != null && diffType.containsKey(plantDifferentialId) && diffType.get(plantDifferentialId) == 'Plant Differential'
               && diffUnit.get(plantDifferentialId) != null && diffUnit.get(plantDifferentialId) == depoUnitRate) 
            {
                prcngdiff.plantDifferentialValue = diffValue.get(plantDifferentialId).setScale(4);  
            }
            else if(plantDifferentialId != null && diffType.containsKey(plantDifferentialId) && diffType.get(plantDifferentialId) == 'Plant Differential'
                    && diffUnit.get(plantDifferentialId) != null && diffUnit.get(plantDifferentialId) != depoUnitRate) 
            {               
                String BaseCurrency, ConvertedCurrency;
                RE_unitConversion unitConv = New RE_unitConversion();
                Map<String,Double> currfxRateMap = New Map<String,Double>();
                
                // Current day Base & Converted Unit Rate
                BaseCurrency = (RE_unitConversion.unitBreakUp(diffUnit.get(plantDifferentialId)) == null) ? 'USD' : RE_unitConversion.unitBreakUp(diffUnit.get(plantDifferentialId))[0];
                ConvertedCurrency = (RE_unitConversion.unitBreakUp(depoUnitRate) == null) ? 'CAD' : RE_unitConversion.unitBreakUp(depoUnitRate)[0];
                currfxRateMap.put(ConvertedCurrency+'-'+BaseCurrency,currtFxRate);        
                prcngdiff.plantDifferentialValue = (diffValue.get(plantDifferentialId) * unitConv.unitConversionMultiplier(diffUnit.get(plantDifferentialId),depoUnitRate,'Canada',null,currfxRateMap)).setScale(4); 
            }
            
            return prcngdiff;
        }
        Catch(Exception ex)
        {            
            System.debug('getCurrentPricingDifferential-->'+ex.getMessage());
            System.debug('getCurrentPricingDifferential-LN-->'+ex.getLineNumber());
            IsSuccessJobAudit = false;
            RV_ClassException.insertExceptionRecord('CalculatingDepoPricing',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','getCurrentPricingDifferential','Exception');
            return prcngdiff;
        }        
    }
    
    public class pricingDifferentialWrapper
    {
        @AuraEnabled
        public Decimal productDifferentialValue {get;set;}
        @AuraEnabled
        public Decimal brandFeeValue {get;set;}
        @AuraEnabled
        public Decimal plantDifferentialValue {get;set;} 
        @AuraEnabled
        public Decimal brandDiscountValue {get;set;} 
    }
    
    // Get all the Active Canada Depot Pricing with active Products and Locations(Plants)
    public static cndDepotPricingRecordWrapper getActiveAllCNDDepotPricing(Id cndDepotPricingRecdTypId)
    {
        cndDepotPricingRecordWrapper DepoPricngWrp = new cndDepotPricingRecordWrapper();
        Id cndProductRecdTypId = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndLocationRecdTypId = Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        
        List<RE_Depot_Pricing_Backbone__c> unbrandedExecutePriceBaseProduct  = new List<RE_Depot_Pricing_Backbone__c>();
        List<RE_Depot_Pricing_Backbone__c> unbrandedAndBrandedDerivedProduct  = new List<RE_Depot_Pricing_Backbone__c>();
        
        for(RE_Depot_Pricing_Backbone__c depotPricng: [SELECT Id, RE_Location_Name__c, RE_Location_Name__r.RE_Location_Code__c, RE_Product_Name__c, RE_Product_Name__r.RT_Product_Code__c,
                                                       RE_CND_Rack__c, RE_CND_Product_Group__c, RE_CND_Group__c, RE_CND_Is_Base_Product__c, RE_CND_Differential_Basis__c, RE_CND_Notify_Users__c,                                                        
                                                       RE_CND_Parent_Rack__c, RE_CND_Parent_Rack_Group__c, RE_CND_Pricing_Basis__c, RE_Product_Name__r.RE_Product_Classification_L0__c,
                                                       RE_CND_Group_Pricing_Basis__c,  RE_Product_Name__r.RE_Product_Group__c,RE_CND_Special_Adjustment__c, RE_Comments__c,                                                       
                                                       RE_CND_Plant_Differential__c, RE_CND_Product_Differentials__c, RE_CND_Brand_Fees__c, RE_CND_Brand_Discount__c, RE_Final_Price_Unit__c,                                                     
                                                       RE_CND_NewRack_Or_NewBAPP_File__c, RE_CND_Required_in_Rack_Prices__c, RE_CND_Rack_Prices_Location__c, RE_CND_Rack_Prices_Product__c, RE_CND_Req_in_DailyRackChange_Notifi__c,
                                                       RE_CND_PA_loc_code__c, RE_CND_CanadianDailyRack_Location__c, RE_CND_DEX_loc_code__c, RE_CND_DEX_Products__c, RE_CND_DEX_product_code__c, RE_CND_PA_Product_code__c,	
                                                       RE_CND_PA__c, RE_CND_CanadianDailyRack_DEX__c, RE_CND_CanadianDailyRack7Day_DEX__c, RE_CND_Required_CanadianDailyRack__c, RE_CND_Required_CanadianDailyRack7Day__c, 
                                                       RE_CND_Required_in_OPIS_Comparison__c, RE_CND_Is_only_applicable_to_SFJ__c
                                                       FROM RE_Depot_Pricing_Backbone__c WHERE RecordTypeId =: cndDepotPricingRecdTypId AND RE_Is_Active__c =: TRUE
                                                       AND RE_CND_Group__c IN ('unbranded', 'branded')
                                                       AND(RE_Product_Name__r.RecordTypeId =: cndProductRecdTypId AND RE_Product_Name__r.Active__c =: TRUE)
                                                       AND(RE_Location_Name__r.RecordTypeId =: cndLocationRecdTypId AND RE_Location_Name__r.RT_Active__c =: TRUE)]) {  
                                                           
                                                           // Unbranded Execute Base Products  
                                                           if((depotPricng.RE_CND_Group__c.toLowercase() == 'unbranded') && (depotPricng.RE_CND_Is_Base_Product__c == TRUE) && (!String.isBlank(depotPricng.RE_CND_Differential_Basis__c)))
                                                               unbrandedExecutePriceBaseProduct.add(depotPricng);                               
                                                           // Unbranded/Branded Derived Products 
                                                           else if(((depotPricng.RE_CND_Group__c.toLowercase() == 'unbranded') || (depotPricng.RE_CND_Group__c.toLowercase() == 'branded')) && (depotPricng.RE_CND_Is_Base_Product__c == FALSE) && (!String.isBlank(depotPricng.RE_CND_Pricing_Basis__c)))
                                                               unbrandedAndBrandedDerivedProduct.add(depotPricng);  
                                                       }        
        
        DepoPricngWrp.unbrandedExecutePriceBaseProduct = unbrandedExecutePriceBaseProduct;        
        DepoPricngWrp.unbrandedAndBrandedDerivedProduct = unbrandedAndBrandedDerivedProduct;
        
        return DepoPricngWrp;
    }
    
    public class cndDepotPricingRecordWrapper{
        @AuraEnabled
        public List<RE_Depot_Pricing_Backbone__c> unbrandedExecutePriceBaseProduct = new List<RE_Depot_Pricing_Backbone__c>();        
        @AuraEnabled
        public List<RE_Depot_Pricing_Backbone__c> unbrandedAndBrandedDerivedProduct = new List<RE_Depot_Pricing_Backbone__c>();
    }
    
    // Get latest cost price details
    public static Map<String,RE_MY_CostPrice__c> getLatestCostPriceRecords(date request_Date)
    {              
        Map<String,RE_MY_CostPrice__c> latestCostPrice = new Map<String,RE_MY_CostPrice__c>();
        date maxReqdCostPriceDt;        
        List<RE_MY_CostPrice__c> maxCostPriceReqDate = New List<RE_MY_CostPrice__c>();
        Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        
        try
        {        
            //get the latest Cost Price Requested Date 
            maxCostPriceReqDate = [SELECT RE_Requested_Date__c FROM RE_MY_CostPrice__c 
                                   WHERE RecordTypeId =: cndCostPriceRecdTypId AND RE_Status__c NOT IN ('Redundant')
                                   AND RE_IsLatest__c =: TRUE AND RE_Requested_Date__c <: request_Date
                                   ORDER BY RE_Requested_Date__c DESC LIMIT 1];            
            
            if(maxCostPriceReqDate.Size() > 0)
            {
                for(RE_MY_CostPrice__c mxPrcngReqDt: maxCostPriceReqDate)
                {
                    maxReqdCostPriceDt = mxPrcngReqDt.RE_Requested_Date__c;
                }                  
            }
            else
                maxReqdCostPriceDt = System.today();
            
            //get previous cost price records
            latestCostPrice = getPrevDayAllCostPriceRecords(cndCostPriceRecdTypId,maxReqdCostPriceDt);         
            
            return latestCostPrice;
        }
        Catch(Exception ex)
        {
            System.debug('getLatestCostPriceRecords-->'+ex.getMessage());
            System.debug('getLatestCostPriceRecords-LN-->'+ex.getLineNumber());
            IsSuccessJobAudit = false;
            RV_ClassException.insertExceptionRecord('CalculatingDepoPricing',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_ExecuteDepoPricingController','getLatestCostPriceRecords','Exception');
            return latestCostPrice;
        }
    }
    
    // Get Previous day's Base Products records from Cost price     
    public static Map<String,RE_MY_CostPrice__c> getPrevDayAllCostPriceRecords(Id cndCostPriceRecdTypId, Date maxReqdCostPriceDt)
    {     
        Map<String,RE_MY_CostPrice__c> prevDayCostPrice = new Map<String,RE_MY_CostPrice__c>();
        
        for(RE_MY_CostPrice__c costPrice : [SELECT Id,RE_CND_Old_Base_Value__c,RE_CND_Market_Move__c,RE_CND_New_Base_Value__c,RE_CND_Final_Value__c,
                                            RE_Product_Codes__c, RE_Depot_Code__c,RE_CND_Rack__c,RE_CND_Product_Group__c,RE_CND_Group__c,
                                            RE_CND_Parent_Rack__c, RE_CND_Parent_Rack_Group__c,RecordTypeId, RE_CND_Pricing_Basis__c,
                                            RE_Costprice_Unit__c, RE_Fx_Rate__c
                                            FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId
                                            AND RE_IsLatest__c =: TRUE AND RE_Status__c NOT IN ('Redundant') 
                                            AND RE_Requested_Date__c =: maxReqdCostPriceDt])
        {       
            prevDayCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);           
        }
        
        return prevDayCostPrice;
    }
    
    // Get current day's all the records from Cost price 
    public static currentDayRecordsWrapper getCurentDayAllCostPriceRecords(date request_Date)
    {
        currentDayRecordsWrapper cDRWrapper = new currentDayRecordsWrapper();   
        Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndPriceBookRecdTypId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        Map<String,RE_MY_CostPrice__c> oldMapCostPrice = new Map<String,RE_MY_CostPrice__c>();
        List<RT_Price_Book__c> oldPriceBookLst = new List<RT_Price_Book__c>();
        List<RE_MY_CostPrice__c> oldCostPrceLst = new List<RE_MY_CostPrice__c>();
        
        for(RE_MY_CostPrice__c costPrice : [SELECT Id, Name, RE_Initial_Version__c, RE_IsLatest__c, RE_Status__c, 
                                            RE_Product_Codes__c, RE_Depot_Code__c, RE_CND_Rack__c, RE_CND_Product_Group__c, RE_CND_Group__c
                                            FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId                                                     
                                            AND RE_Requested_Date__c =: request_Date])
        {  
            if(costPrice.RE_IsLatest__c == TRUE && ((costPrice.RE_Status__c == 'Draft') || (costPrice.RE_Status__c == 'Ready to Upload')))
            {
                RE_MY_CostPrice__c cpRecord = new RE_MY_CostPrice__c();
                cpRecord.Id = costPrice.Id;
                cpRecord.RE_IsLatest__c = FALSE;
                cpRecord.RE_Status__c = 'Redundant';
                oldCostPrceLst.add(cpRecord);  
            }
            
            oldMapCostPrice.put(costPrice.RE_Product_Codes__c+'-'+costPrice.RE_Depot_Code__c+'-'+costPrice.RE_CND_Group__c, costPrice);
        }
        
        for(RT_Price_Book__c prcBk  : [SELECT Id, RE_Is_Latest__c, RE_Custom_Opp_Approve__c                                       
                                       FROM RT_Price_Book__c WHERE RecordTypeId =: cndPriceBookRecdTypId
                                       AND RE_Is_Latest__c =: TRUE AND RE_Custom_Opp_Approve__c IN ('Draft', 'Ready to Upload')
                                       AND RT_Effective_Date__c =: request_Date])
        {      
            RT_Price_Book__c prcRecord = new RT_Price_Book__c();
            prcRecord.Id = prcBk.Id;
            prcRecord.RE_Is_Latest__c = FALSE;
            prcRecord.RE_Custom_Opp_Approve__c = 'Redundant';
            oldPriceBookLst.add(prcRecord);
        }      
        
        cDRWrapper.currtDayMapCostPriceList = oldMapCostPrice;
        cDRWrapper.currtDayPrcBookList = oldPriceBookLst;
        cDRWrapper.currtDayCostPrcList = oldCostPrceLst;
        
        return cDRWrapper;
    }
    
    public class currentDayRecordsWrapper {      
        @AuraEnabled
        public Map<String,RE_MY_CostPrice__c> currtDayMapCostPriceList {get;set;} 
        @AuraEnabled
        public List<RT_Price_Book__c> currtDayPrcBookList {get;set;}     
        @AuraEnabled
        public List<RE_MY_CostPrice__c> currtDayCostPrcList {get;set;}        
    }
    
}