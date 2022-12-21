/**************************************************************************************************
* Name: RE_CND_GenerateMVandMOAQueue
* Object: RE_Market_Quotes__c, RE_MOA__c, RE_MY_CostPrice__c
* Purpose: Generate Market Move and MOA against OPIS Spot Tikcer for Rev Canada
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-05-15
* Modify History: 
* 2022-05-15		Abhilash		Created
**************************************************************************************************/
public class RE_CND_GenerateMVandMOAQueue implements Queueable {

    private Date requestedDt;
    private Date effectiveFromDate;
    private Date effectiveToDate;
    private Date currOPISTikrDate;
    private Date currFxRateDate;
    private Decimal currFxRate;
    private Date prevOPISTikrDate;
    private Date prevFxRateDate;
    private Decimal prevFxRate;
    private Id jobRunAudId;
    private Datetime now;
    public static Boolean IsSuccessJobAudit = true;
    
    public RE_CND_GenerateMVandMOAQueue(Date requestedDt, Date effectiveFromDate, Date effectiveToDate, Date currOPISTikrDate, Date currFxRateDate, Decimal currFxRate, Date prevOPISTikrDate, Date prevFxRateDate, Decimal prevFxRate, Id jobRunAudId, Datetime now)
    {
        this.requestedDt = requestedDt;
        this.effectiveFromDate = effectiveFromDate;  
        this.effectiveToDate = effectiveToDate;  
        this.currOPISTikrDate = currOPISTikrDate;
        this.currFxRateDate = currFxRateDate;
        this.currFxRate = currFxRate;
        this.prevOPISTikrDate = prevOPISTikrDate;
        this.prevFxRateDate = prevFxRateDate;
        this.prevFxRate = prevFxRate;
        this.jobRunAudId = jobRunAudId;
        this.now = now;         
    }

    public void execute(QueueableContext context)
    {
        RE_CND_ExecuteDepoPricingController.executeMarketMveWrapper mvwrapper = new RE_CND_ExecuteDepoPricingController.executeMarketMveWrapper();
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit = [SELECT Id, RE_Job_Status__c, RE_Exception__c, Other_Comments__c FROM RE_Job_Run_Audit__c WHERE Id =: jobRunAudId];

        try
        {
            if(currOPISTikrDate == date.ValueOf('1990-01-01 00:00:00'))
                currOPISTikrDate = null;
            if((currFxRateDate == date.ValueOf('1990-01-01 00:00:00')) || (currFxRateDate != null && currFxRate == 0.00))
                currFxRateDate = null;
            if(prevOPISTikrDate == date.ValueOf('1990-01-01 00:00:00'))
                prevOPISTikrDate = null;
            if((prevFxRateDate == date.ValueOf('1990-01-01 00:00:00')) || (prevFxRateDate != null && prevFxRate == 0.00))
                prevFxRateDate = null;
            
            if(currFxRate == 0.00)
            	currFxRate = null;
            if(prevFxRate == 0.00)
            	prevFxRate = null;
            
            String mvDefaultUnitRate, epDefaultUnitRate;
            String BaseCurrency, ConvertedCurrency;    
            String fxLiveQuoteName;       
			Date todayDate = date.newinstance(now.year(), now.month(), now.day());
            Id opisSpotRecordTypeId = Schema.SObjectType.RE_Market_Quotes__c.getRecordTypeInfosByDeveloperName().get('Canada_OPIS_Spot_Ticker').getRecordTypeId();
            Id marktMveRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Market_Moves').getRecordTypeId();
            Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
            Map<String,Decimal> prvDayMVData = New Map<String,Decimal>();
            Map<String,String> prvDayMVBaseUnitRate = New Map<String,String>();
            Map<String,String> prvDayMVConvertdUnitRate = New Map<String,String>();
			List<RE_MOA__c> lstMaxMarketMoveDate = New List<RE_MOA__c>();
			List<RE_MOA__c> lstMaxMOADate = New List<RE_MOA__c>();
			Date lstMaxMarketMoveDt;
			Date lstMaxMOADt;
            Map<String,String> prvDayExePrBaseUnitRate = New Map<String,String>();
            Map<String,String> prvDayExePrConvertdUnitRate = New Map<String,String>();
			List<RE_MOA__c> oldMOALst = New List<RE_MOA__c>();
            List<RE_MOA__c> oldMVLst = New List<RE_MOA__c>();
            Set<Id> insertedMOAIds = New Set<Id>();
            List<RE_MOA__c> initialVersnLst = new List<RE_MOA__c>();                        
            Map<String,Decimal> mqPrice = New Map<String,Decimal>();
            Map<String,Decimal> mqChange = New Map<String,Decimal>();  
            Map<String,String> mqUnitRate = New Map<String,String>();  
            Datetime requestedFxStartDt, requestedFxEndDt;
            Id fxRateId;
            Decimal fxRate = 0.00;
            List<RE_FX_Rates__c> CurtFxLst = New List<RE_FX_Rates__c>();
            Decimal PrvsFxRate = 0.00;
            List<RE_MOA__c> newMOALst = New List<RE_MOA__c>();
            List<RE_MOA__c> newMVLst = New List<RE_MOA__c>();            

            // Get the default unit rate for Market Move & Price execution Calculation
            for(RE_Default_Unit_Rate_Settings__c dunitRate: [SELECT Type__c, Default_Unit_Rate__c FROM RE_Default_Unit_Rate_Settings__c
                                                             WHERE Country_Name__c =: 'Canada' AND Object_Name__c =: 'RE_MOA__c'
                                                             AND Type__c IN ('Market Move Calculation','Price Execution')
                                                             AND Is_Active__c =: TRUE])
            {
                if(dunitRate.Type__c == 'Market Move Calculation')
                    mvDefaultUnitRate = dunitRate.Default_Unit_Rate__c;
                else if(dunitRate.Type__c == 'Price Execution')
                    epDefaultUnitRate = dunitRate.Default_Unit_Rate__c;                        
            }
            
            // Get the Live Fx Rate Quote 
            for(RE_Zema_Quotes_Settings__c fxQuote: [SELECT Display_Name__c FROM RE_Zema_Quotes_Settings__c 
                                                     WHERE Country__c LIKE '%Canada%' AND Type__c =:'FX Rates' 
                                                     AND Frequency__c =: 'Live' AND Is_Active__c =: TRUE LIMIT 1])
            {
                fxLiveQuoteName = fxQuote.Display_Name__c;
            } 
            
            // Get all the current day's active Cost Price and Price Book records to set Redundant
            RE_CND_ExecuteDepoPricingController.currentDayExistingRecordsWrapper curDayRecrdWrapper = new RE_CND_ExecuteDepoPricingController.currentDayExistingRecordsWrapper(); 
            curDayRecrdWrapper = RE_CND_ExecuteDepoPricingController.getCurentDayAllMOAAndCostPriceAndPriceBkRecords(requestedDt);    

            // For Weekend Market Move Calculation
            if(currOPISTikrDate == null && currFxRateDate == null && prevOPISTikrDate != null && prevFxRateDate != null)
            {           
                List<RE_MY_CostPrice__c> oldMapCostPrice = new List<RE_MY_CostPrice__c>();
                List<RT_Price_Book__c> oldPriceBookLst = new List<RT_Price_Book__c>();
                Map<String,RE_MOA__c> currtDayOldMaktMove = New Map<String,RE_MOA__c>();
                Map<String,RE_MOA__c> currtDayOldExctePrice = New Map<String,RE_MOA__c>(); 
                
                oldMapCostPrice = curDayRecrdWrapper.currtDayMapCostPriceList;            
                oldPriceBookLst = curDayRecrdWrapper.currtDayPrcBookList;
                currtDayOldMaktMove = curDayRecrdWrapper.currtDayOldMaktMoveList;            
                currtDayOldExctePrice = curDayRecrdWrapper.currtDayOldExctePriceList;
				
				// Get Last Market Move Date
				lstMaxMarketMoveDate = [SELECT RE_Requested_Date__c FROM RE_MOA__c
										 WHERE RecordTypeId =: marktMveRecordTypeId 
										 AND RE_Requested_Date__c >=: prevOPISTikrDate AND RE_Requested_Date__c <: todayDate
                                         AND RE_IsLatest__c =: TRUE ORDER BY RE_Requested_Date__c DESC LIMIT 1];
				
				if(lstMaxMarketMoveDate.Size() > 0) 
				{
					for(RE_MOA__c mxReqDt: lstMaxMarketMoveDate)
					{
						lstMaxMarketMoveDt = mxReqDt.RE_Requested_Date__c;
					}                    
				}
				else
					lstMaxMarketMoveDt = todayDate;
				
				// Get Last MOA Date
				lstMaxMOADate = [SELECT RE_Requested_Date__c FROM RE_MOA__c
								  WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c >=: prevOPISTikrDate
								  AND RE_Requested_Date__c <: todayDate AND RE_IsLatest__c =: TRUE ORDER BY RE_Requested_Date__c DESC LIMIT 1];                
				
				if(lstMaxMOADate.Size() > 0) 
				{
					for(RE_MOA__c mxReqDt: lstMaxMOADate)
					{
						lstMaxMOADt = mxReqDt.RE_Requested_Date__c;
					}                      
				}
				else 				
					lstMaxMOADt = todayDate;
				
				// If last Market Move is same as Previous OPIS selected date
				if(lstMaxMarketMoveDt == prevOPISTikrDate)
				{
					// Get Previous Market Move records
					for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, RE_CND_Actual_Delta__c, 
										  RE_CND_Group__c, RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
										  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
										  AND RE_Requested_Date__c =: prevOPISTikrDate AND RE_IsLatest__c =: TRUE])
					{           
						prvDayMVData.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);
						prvDayMVBaseUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Base_Rate_Unit__c);
						prvDayMVConvertdUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Converted_Rate_Unit__c);
													
						if(prvMV.RE_CND_Marker_Name__c == 'Reuters Fx')
							PrvsFxRate = prvMV.RE_Price_Value__c;
						else
						{
							mqPrice.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);  
							mqChange.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_CND_Actual_Delta__c); 
							mqUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Converted_Rate_Unit__c);
							
							RE_MOA__c newMV = New RE_MOA__c();
							newMV.RecordTypeId = marktMveRecordTypeId;
							newMV.RE_CND_Marker_Name__c = prvMV.RE_CND_Marker_Name__c;
							newMV.RE_CND_Group__c = prvMV.RE_CND_Group__c;
							newMV.RE_Base_Rate_Unit__c = prvMV.RE_Base_Rate_Unit__c;
							newMV.RE_Converted_Rate_Unit__c = mvDefaultUnitRate;
							newMV.RE_Requested_Date__c = requestedDt;
							newMV.RE_CND_Effective_Date__c = now;
							newMV.RE_CND_Effective_From_Date__c = effectiveFromDate;
							newMV.RE_CND_Effective_To_Date__c = effectiveToDate; 
							newMV.RE_CND_Previous_OPIS_Selected_Date__c = prevOPISTikrDate;
							newMV.RE_CND_Previous_FxRate_Selected_Date__c = prevFxRateDate;                        
							newMV.RE_CND_Previous_FxRate__c = prevFxRate;
							newMV.RE_IsLatest__c = True;                        
							newMV.RE_Price_Value__c = prvMV.RE_Price_Value__c;                        
							newMV.RE_CND_Delta_Percentage__c = 0.00;
							newMV.RE_CND_Actual_Delta__c = 0.00;
							newMV.RE_CND_CAD_Delta_cpl__c = 0.00;
							newMV.RE_CND_PrvDay_Delta_Percentage__c = 0.00;
							newMVLst.add(newMV);
						}
					}

					// Get Previous MOA records
					for(RE_MOA__c oldMoa : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Market_Move__c, RE_CND_New_End_Price__c,RE_CND_Difference__c,  
											RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
											FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c =: prevOPISTikrDate
											AND RE_IsLatest__c =: TRUE ORDER BY RE_CND_Group__c,RE_CND_Rack__c LIMIT 24])
					{
						oldMOALst.add(oldMoa);
						prvDayExePrBaseUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Base_Rate_Unit__c);
						prvDayExePrConvertdUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Converted_Rate_Unit__c); 
						
						RE_MOA__c newMoa = New RE_MOA__c();
						newMoa.RecordTypeId = cadMOARecordTypeId;
						newMoa.RE_CND_Rack__c = oldMoa.RE_CND_Rack__c;					
						newMoa.RE_CND_Group__c = oldMoa.RE_CND_Group__c;
						newMoa.RE_Base_Rate_Unit__c = oldMoa.RE_Base_Rate_Unit__c;
						newMoa.RE_Converted_Rate_Unit__c = mvDefaultUnitRate;
						newMoa.RE_Requested_Date__c = requestedDt;
						newMoa.RE_CND_Effective_Date__c = now;
						newMoa.RE_CND_Effective_From_Date__c = effectiveFromDate;
						newMoa.RE_CND_Effective_To_Date__c = effectiveToDate; 
						newMoa.RE_CND_Previous_OPIS_Selected_Date__c = prevOPISTikrDate;
						newMoa.RE_CND_Previous_FxRate_Selected_Date__c = prevFxRateDate;                        
						newMoa.RE_CND_Previous_FxRate__c = prevFxRate;
						newMoa.RE_IsLatest__c = True;
						newMoa.RE_CND_Today_s_Price__c = oldMoa.RE_CND_New_End_Price__c;
						newMoa.RE_CND_Market_Move__c = 0.00;
						newMoa.RE_CND_Competitive_Adj__c = 0.00;
						newMoa.RE_CND_Net_Move__c = 0.00;
						newMoa.RE_CND_New_End_Price__c = oldMoa.RE_CND_New_End_Price__c;
						newMoa.RE_CND_Difference__c = oldMoa.RE_CND_Difference__c;
						newMOALst.add(newMoa);                  
					} 
					
				}
				else
				{
					// Get Last Market Move records
					for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, RE_CND_Actual_Delta__c, 
										  RE_CND_Group__c, RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
										  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
										  AND RE_Requested_Date__c =: lstMaxMarketMoveDt AND RE_IsLatest__c =: TRUE])
					{
						prvDayMVData.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);
						prvDayMVBaseUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Base_Rate_Unit__c);
						prvDayMVConvertdUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Converted_Rate_Unit__c);						  
					}
					
					// Get Previous Market Move records
					for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, RE_CND_Actual_Delta__c, 
										  RE_CND_Group__c, RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
										  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
										  AND RE_Requested_Date__c =: prevOPISTikrDate AND RE_IsLatest__c =: TRUE])
					{   					
						if(prvMV.RE_CND_Marker_Name__c == 'Reuters Fx')
							PrvsFxRate = prvMV.RE_Price_Value__c;
						else
						{
							mqPrice.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);  
							mqChange.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_CND_Actual_Delta__c); 
							mqUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Converted_Rate_Unit__c);
							
							RE_MOA__c newMV = New RE_MOA__c();
							newMV.RecordTypeId = marktMveRecordTypeId;
							newMV.RE_CND_Marker_Name__c = prvMV.RE_CND_Marker_Name__c;
							newMV.RE_CND_Group__c = prvMV.RE_CND_Group__c;
							newMV.RE_Base_Rate_Unit__c = prvMV.RE_Base_Rate_Unit__c;
							newMV.RE_Converted_Rate_Unit__c = mvDefaultUnitRate;
							newMV.RE_Requested_Date__c = requestedDt;
							newMV.RE_CND_Effective_Date__c = now;
							newMV.RE_CND_Effective_From_Date__c = effectiveFromDate;
							newMV.RE_CND_Effective_To_Date__c = effectiveToDate; 
							newMV.RE_CND_Previous_OPIS_Selected_Date__c = prevOPISTikrDate;
							newMV.RE_CND_Previous_FxRate_Selected_Date__c = prevFxRateDate;                        
							newMV.RE_CND_Previous_FxRate__c = prevFxRate;
							newMV.RE_IsLatest__c = True;                        
							newMV.RE_Price_Value__c = prvMV.RE_Price_Value__c;                        
							newMV.RE_CND_Delta_Percentage__c = 0.00;
							newMV.RE_CND_Actual_Delta__c = 0.00;
							newMV.RE_CND_CAD_Delta_cpl__c = 0.00;
							newMV.RE_CND_PrvDay_Delta_Percentage__c = 0.00;
							newMVLst.add(newMV);
						}
					}					
					
					// Get last MOA records
					for(RE_MOA__c oldMoa : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Market_Move__c, RE_CND_New_End_Price__c,RE_CND_Difference__c,  
											RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
											FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c =: lstMaxMOADt
											AND RE_IsLatest__c =: TRUE ORDER BY RE_CND_Group__c,RE_CND_Rack__c LIMIT 24])
					{
						oldMOALst.add(oldMoa);
						prvDayExePrBaseUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Base_Rate_Unit__c);
						prvDayExePrConvertdUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Converted_Rate_Unit__c); 
						
						RE_MOA__c newMoa = New RE_MOA__c();
						newMoa.RecordTypeId = cadMOARecordTypeId;
						newMoa.RE_CND_Rack__c = oldMoa.RE_CND_Rack__c;					
						newMoa.RE_CND_Group__c = oldMoa.RE_CND_Group__c;
						newMoa.RE_Base_Rate_Unit__c = oldMoa.RE_Base_Rate_Unit__c;
						newMoa.RE_Converted_Rate_Unit__c = mvDefaultUnitRate;
						newMoa.RE_Requested_Date__c = requestedDt;
						newMoa.RE_CND_Effective_Date__c = now;
						newMoa.RE_CND_Effective_From_Date__c = effectiveFromDate;
						newMoa.RE_CND_Effective_To_Date__c = effectiveToDate; 
						newMoa.RE_CND_Previous_OPIS_Selected_Date__c = lstMaxMOADt;
						newMoa.RE_CND_Previous_FxRate_Selected_Date__c = prevFxRateDate;                        
						newMoa.RE_CND_Previous_FxRate__c = prevFxRate;
						newMoa.RE_IsLatest__c = True;
						newMoa.RE_CND_Today_s_Price__c = oldMoa.RE_CND_New_End_Price__c;
						newMoa.RE_CND_Market_Move__c = 0.00;
						newMoa.RE_CND_Competitive_Adj__c = 0.00;
						newMoa.RE_CND_Net_Move__c = 0.00;
						newMoa.RE_CND_New_End_Price__c = oldMoa.RE_CND_New_End_Price__c;
						newMoa.RE_CND_Difference__c = oldMoa.RE_CND_Difference__c;
						newMOALst.add(newMoa);                  
					}
				}
				
				// Compare selected Previous Fx Rate is equal to MOA Previous FxRate
				if(prevFxRate == PrvsFxRate)
				{
					RE_MOA__c newMV = New RE_MOA__c();
					newMV.RecordTypeId = marktMveRecordTypeId;
					newMV.RE_CND_Marker_Name__c = 'Reuters Fx';
					newMV.RE_CND_Group__c = 'Fx Rate';
					newMV.RE_Base_Rate_Unit__c = 'USD';
					newMV.RE_Converted_Rate_Unit__c = mvDefaultUnitRate;
					newMV.RE_Requested_Date__c = requestedDt;
					newMV.RE_CND_Effective_Date__c = now;
					newMV.RE_CND_Effective_From_Date__c = effectiveFromDate;
					newMV.RE_CND_Effective_To_Date__c = effectiveToDate; 
					newMV.RE_CND_Previous_OPIS_Selected_Date__c = prevOPISTikrDate;
					newMV.RE_CND_Previous_FxRate_Selected_Date__c = prevFxRateDate;                        
					newMV.RE_CND_Previous_FxRate__c = prevFxRate;
					newMV.RE_IsLatest__c = True;                        
					newMV.RE_Price_Value__c = PrvsFxRate;                        
					newMV.RE_CND_Delta_Percentage__c = 0.00;
					newMV.RE_CND_Actual_Delta__c = 0.00;
					newMV.RE_CND_CAD_Delta_cpl__c = 0.00;
					newMV.RE_CND_PrvDay_Delta_Percentage__c = 0.00;
					newMVLst.add(newMV);   
					
					// Insert current day Market Move
					if(newMVLst.size() > 0)
					{         
						Set<Id> mqMOAInsrtdIds = New Set<Id>();
						Database.SaveResult[] newMVmoaList = Database.insert(newMVLst, false);
						mqMOAInsrtdIds = RE_CND_Utility.handleInsert('RE_CND_ExecuteDepoPricingController','generateMVandMOAFromOpisSpotTickrData-Inserted-MV-MOA',newMVmoaList,jrAudit);
						
						if(mqMOAInsrtdIds.size() > 0)
							insertedMOAIds.addAll(mqMOAInsrtdIds);               
					}
					
					system.debug('currentdayExecutePrice-->'+newMOALst);
					// Insert current day execute Price(MOA)
					if(newMOALst.size() > 0)
					{
						Set<Id> mqMOAUpdatedIds = New Set<Id>();
						Database.SaveResult[] newMoaList = Database.insert(newMOALst, false);
						mqMOAUpdatedIds = RE_CND_Utility.handleInsert('RE_CND_ExecuteDepoPricingController','generateMVandMOAFromOpisSpotTickrData-InsertedExecPrcMOA',newMoaList,jrAudit);
						
						if(mqMOAUpdatedIds.size() > 0)
							insertedMOAIds.addAll(mqMOAUpdatedIds);                
					}
					
					// Check existing MOA on the same day then update initial version
					if((insertedMOAIds.Size() > 0) && (((currtDayOldMaktMove != null) && (currtDayOldMaktMove.Size() > 0)) 
													   || ((currtDayOldExctePrice != null) && (currtDayOldExctePrice.Size() > 0))))                                            
						initialVersnLst = RE_CND_ExecuteDepoPricingController.updateInitialVersionInOlderMOA(insertedMOAIds,curDayRecrdWrapper); 
					else if(insertedMOAIds.Size() > 0)                           
						initialVersnLst = RE_CND_ExecuteDepoPricingController.updateInitialVersionInMOA(insertedMOAIds); 
					
					// Update initial version in MOA
					if(initialVersnLst.Size() > 0)
						update initialVersnLst;
					
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
				}
				// Compare selected Previous Fx Rate is not equal to MOA Previous FxRate
				else
				{                        
					requestedFxStartDt = (DateTime)prevFxRateDate;
					requestedFxEndDt = requestedFxStartDt.AddHours(23).AddMinutes(59).AddSeconds(59);
					Set<Id> mqProcessedIds = New Set<Id>();
					RE_CND_ExecuteDepoPricingController.executeMVandMOAWrapper execMvMoaWrapr = New RE_CND_ExecuteDepoPricingController.executeMVandMOAWrapper();
					
					// Get the Fx Rate
					for(RE_FX_Rates__c curfx: [SELECT Id, RE_Forex_Rate__c, RE_Pricing_Date__c FROM RE_FX_Rates__c WHERE RE_Quote_Name__c =: fxLiveQuoteName
											   AND RE_Trade_Type__c =: 'Exchange Rate' 
											   AND RE_Pricing_Date__c >=: requestedFxStartDt AND RE_Pricing_Date__c <=: requestedFxEndDt
											   LIMIT 1])
					{
						fxRateId = curfx.Id;
						fxRate = curfx.RE_Forex_Rate__c;
					}
					
					// FxRate not exist, hence creating the same
					if(fxRate == 0)
					{                            
						RE_FX_Rates__c curFx = New RE_FX_Rates__c();                    
						curFx.RE_Forex_Rate__c = prevFxRate;
						curFx.RE_Conversion_Unit__c = 'CAD';
						curFx.RE_Base_Unit__c = 'USD';
						curFx.RE_Forex_Name__c = 'CAD/USD';
						curFx.RE_Trade_Type__c = 'Exchange Rate';
						curFx.RE_Quote_Name__c = fxLiveQuoteName;
						curFx.RE_Pricing_Date__c = prevFxRateDate;
						CurtFxLst.add(curFx);
						execMvMoaWrapr.fxRateCreatUpdteStatus = 'Create';
					}
					// update FxRate, if not same
					else if(fxRate != prevFxRate)
					{
						RE_FX_Rates__c curFx = New RE_FX_Rates__c();
						curFx.Id = fxRateId;
						curFx.RE_Forex_Rate__c = prevFxRate;                    
						CurtFxLst.add(curFx);
						execMvMoaWrapr.fxRateCreatUpdteStatus = 'Update';
					}                        
					
					execMvMoaWrapr.mqPrice = mqPrice;
					execMvMoaWrapr.mqChange = mqChange;
					execMvMoaWrapr.mqUnitRate = mqUnitRate;
					execMvMoaWrapr.prvDayMVData = prvDayMVData;
					execMvMoaWrapr.oldMOALst = oldMOALst;
					execMvMoaWrapr.requestedDt = requestedDt;
					execMvMoaWrapr.effectiveDate = now;
					execMvMoaWrapr.effectiveFromDate = effectiveFromDate;                 
					execMvMoaWrapr.effectiveToDate = effectiveToDate;
					execMvMoaWrapr.currOPISTikrDate = null;
					execMvMoaWrapr.currFxRateDate = null;
					execMvMoaWrapr.currFxRate = null;
					execMvMoaWrapr.prevOPISTikrDate = prevOPISTikrDate;
					execMvMoaWrapr.prevFxRateDate = prevFxRateDate;
					execMvMoaWrapr.prevFxRate = prevFxRate;
					execMvMoaWrapr.mvDefaultUnitRate = mvDefaultUnitRate;
					execMvMoaWrapr.epDefaultUnitRate = epDefaultUnitRate;
					execMvMoaWrapr.prvDayMVBaseUnitRate = prvDayMVBaseUnitRate;
					execMvMoaWrapr.prvDayMVConvertdUnitRate = prvDayMVConvertdUnitRate;
					execMvMoaWrapr.prvDayExePrBaseUnitRate = prvDayExePrBaseUnitRate;
					execMvMoaWrapr.prvDayExePrConvertdUnitRate = prvDayExePrConvertdUnitRate; 
					execMvMoaWrapr.CurtFxLst = CurtFxLst;
											
					mvwrapper = RE_CND_ExecuteDepoPricingController.calculateMVandMOA(jrAudit, opisSpotRecordTypeId, marktMveRecordTypeId, cadMOARecordTypeId, execMvMoaWrapr, True, mqProcessedIds, curDayRecrdWrapper);                        
				}
            }			
			// For Future Day/Selected any Currentday OPIS Market Move Calculation
			else if(currOPISTikrDate != null && currFxRateDate != null && prevOPISTikrDate == null && prevFxRateDate == null)
			{
				requestedFxStartDt = (DateTime)currFxRateDate;
				requestedFxEndDt = requestedFxStartDt.AddHours(23).AddMinutes(59).AddSeconds(59);
				Set<Id> mqProcessedIds = New Set<Id>();
				Map<String,String> markerMappingsNameSettings = New Map<String,String>(); 
				Map<String,String> mqAllPrice = New Map<String,String>();
				Map<String,String> mqAllChange = New Map<String,String>(); 
				Boolean islowestVM = false;
                Decimal mvDiffValue = 0.00;
				RE_CND_ExecuteDepoPricingController.executeMVandMOAWrapper execMvMoaWrapr = New RE_CND_ExecuteDepoPricingController.executeMVandMOAWrapper();
				
				// Get all the Marker Name Mappings from Settings
				for(RE_Field_Value_Mappings__c mkNameMappngs: [SELECT Id, Source_Field_Value__c, Mapping_Field_Value__c FROM RE_Field_Value_Mappings__c 
															   WHERE Country_Name__c =: 'Canada' AND Purpose__c =:'Live OPIS Spot Ticker Import' 
															   AND Object_Name__c =: 'RE_MOA__c' AND Field_Name__c =: 'RE_CND_Marker_Name__c' 
															   AND Is_Active__c =: TRUE ORDER BY Mapping_Field_Value__c])
				{
					markerMappingsNameSettings.put(mkNameMappngs.Source_Field_Value__c, mkNameMappngs.Mapping_Field_Value__c);
				}                    
				
				// Get the Fx Rate
				for(RE_FX_Rates__c curfx: [SELECT Id, RE_Forex_Rate__c, RE_Pricing_Date__c FROM RE_FX_Rates__c WHERE RE_Quote_Name__c =: fxLiveQuoteName
										   AND RE_Trade_Type__c =: 'Exchange Rate' 
										   AND RE_Pricing_Date__c >=: requestedFxStartDt AND RE_Pricing_Date__c <=: requestedFxEndDt
										   LIMIT 1])
				{
					fxRateId = curfx.Id;
					fxRate = curfx.RE_Forex_Rate__c;
				}

				// FxRate not exist, hence creating the same for today
				if((fxRate == 0) && (currOPISTikrDate == requestedDt))
				{
					Date GMTDate = now.dateGMT();
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();                    
					curFx.RE_Forex_Rate__c = currFxRate;
					curFx.RE_Conversion_Unit__c = 'CAD';
					curFx.RE_Base_Unit__c = 'USD';
					curFx.RE_Forex_Name__c = 'CAD/USD';
					curFx.RE_Trade_Type__c = 'Exchange Rate';
					curFx.RE_Quote_Name__c = fxLiveQuoteName;
					curFx.RE_Pricing_Date__c = GMTDate;
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Create';
				}
				// FxRate not exist, hence creating the same for selected date
				else if((fxRate == 0) && (currOPISTikrDate != requestedDt))
				{					
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();                    
					curFx.RE_Forex_Rate__c = currFxRate;
					curFx.RE_Conversion_Unit__c = 'CAD';
					curFx.RE_Base_Unit__c = 'USD';
					curFx.RE_Forex_Name__c = 'CAD/USD';
					curFx.RE_Trade_Type__c = 'Exchange Rate';
					curFx.RE_Quote_Name__c = fxLiveQuoteName;
					curFx.RE_Pricing_Date__c = currOPISTikrDate;
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Create';
				}
				// update FxRate, if not same
				else if(fxRate != currFxRate)
				{
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();
					curFx.Id = fxRateId;
					curFx.RE_Forex_Rate__c = currFxRate;                    
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Update';
				}
				
				// Current OPIS Spot Ticker is same as Requested date
                if(currOPISTikrDate == requestedDt)
				{
					// Get Previous Market Move Date
					lstMaxMarketMoveDate = [SELECT RE_Requested_Date__c FROM RE_MOA__c
											 WHERE RecordTypeId =: marktMveRecordTypeId 
											 AND RE_Requested_Date__c <: currOPISTikrDate AND RE_Requested_Date__c <: todayDate 
											 AND RE_IsLatest__c =: TRUE ORDER BY RE_Requested_Date__c DESC LIMIT 1];
					
					if(lstMaxMarketMoveDate.Size() > 0) 
					{
						for(RE_MOA__c mxReqDt: lstMaxMarketMoveDate)
						{
							lstMaxMarketMoveDt = mxReqDt.RE_Requested_Date__c;
						}                    
					}
					else
						lstMaxMarketMoveDt = todayDate;

					// Get Previous Market Move records
					for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, 
										  RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
										  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
										  AND RE_Requested_Date__c =: lstMaxMarketMoveDt AND RE_IsLatest__c =: TRUE])
					{
						prvDayMVData.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);                 
						prvDayMVBaseUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Base_Rate_Unit__c);
						prvDayMVConvertdUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Converted_Rate_Unit__c);
					}

					// Get Previous MOA Date
					lstMaxMOADate = [SELECT RE_Requested_Date__c FROM RE_MOA__c
									  WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c <: currOPISTikrDate
									  AND RE_Requested_Date__c <: todayDate AND RE_IsLatest__c =: TRUE ORDER BY RE_Requested_Date__c DESC LIMIT 1];                
					
					if(lstMaxMOADate.Size() > 0) 
					{
						for(RE_MOA__c mxReqDt: lstMaxMOADate)
						{
							lstMaxMOADt = mxReqDt.RE_Requested_Date__c;
						}                      
					}
					else
						lstMaxMOADt = todayDate;				

					// Get Previous MOA records
					for(RE_MOA__c oldMoa : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Today_s_Price__c,RE_CND_Market_Move__c, RE_CND_Competitive_Adj__c,RE_CND_Net_Move__c, 
											RE_CND_New_End_Price__c,RE_CND_Difference__c, RE_CND_Effective_Date__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c, 
											RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
											FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c =: lstMaxMOADt
											AND RE_IsLatest__c =: TRUE
											ORDER BY RE_CND_Group__c,RE_CND_Rack__c LIMIT 24])
					{
						oldMOALst.add(oldMoa);
						prvDayExePrBaseUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Base_Rate_Unit__c);
						prvDayExePrConvertdUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Converted_Rate_Unit__c);
					}

                    // Get Live/Previous OPIS Spot Ticker records
                    for(RE_Market_Quotes__c liveOPIS: [SELECT Id, RE_Quote_Name__c, RE_Price__c, RE_Validity_Month__c, RE_Rate_Unit__c                                                   
                                                       FROM RE_Market_Quotes__c
                                                       WHERE RecordTypeId =: opisSpotRecordTypeId AND RE_CND_Validity_Date__c =: currOPISTikrDate
                                                       AND RE_Is_Processed__c =: FALSE
                                                       ORDER BY RE_Quote_Name__c])
                    {                   
                        mqProcessedIds.add(liveOPIS.Id);                  
                        
                        if((liveOPIS.RE_Quote_Name__c.toLowerCase().contains('change')) && (markerMappingsNameSettings.containsKey(liveOPIS.RE_Quote_Name__c)))                                    
                        {                  
                            if(String.isBlank(liveOPIS.RE_Validity_Month__c))
                            {
                                mqChange.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);
                                mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);
                            }
                            else
                            {
                                if(mqChange.containsKey(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)) 
                                   && mqAllChange.containsKey(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)))
                                {
                                    // Check this is lowest validity month data
                                    islowestVM = RE_CND_ExecuteDepoPricingController.isLowestOPISValidityMonth(mqAllChange.get(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)),liveOPIS.RE_Validity_Month__c);
                                    if(islowestVM)
                                    {
                                        // Remove higher validity month records
                                        mqChange.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
                                        mqAllChange.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
                                        mqUnitRate.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
                                        
                                        // Add lowest details in to the map
                                        mqChange.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);
                                        mqAllChange.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Validity_Month__c);
                                        mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);
                                    }                        
                                }
                                else
                                {
                                    mqChange.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);
                                    mqAllChange.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Validity_Month__c);
                                    mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);
                                }
                            }
                        }
                        else if (markerMappingsNameSettings.containsKey(liveOPIS.RE_Quote_Name__c))
                        {
                            if(liveOPIS.RE_Validity_Month__c == null)
                            {
                                mqPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);   
                                mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);   
                            }
                            else
                            {
                                if(mqPrice.containsKey(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)) 
                                   && mqAllPrice.containsKey(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)))
                                {
                                    // Check this is lowest validity month data
                                    islowestVM = RE_CND_ExecuteDepoPricingController.isLowestOPISValidityMonth(mqAllPrice.get(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)),liveOPIS.RE_Validity_Month__c);
                                    if(islowestVM)
                                    {
                                        // Remove higher validity month records
                                        mqPrice.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
                                        mqAllPrice.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
                                        mqUnitRate.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
                                        
                                        // Add lowest details in to the map
                                        mqPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);
                                        mqAllPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Validity_Month__c);
                                        mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);
                                    }                        
                                }
                                else
                                {
                                    mqPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);
                                    mqAllPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Validity_Month__c);
                                    mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);
                                }                            
                            }                 
                        }
                    }			
				}
				// Current OPIS Spot Ticker is not same as Requested date
				else
				{
					// Get Previous Market Move records
					for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, 
										  RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
										  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
										  AND RE_Requested_Date__c =: currOPISTikrDate AND RE_IsLatest__c =: TRUE])
					{
						prvDayMVData.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);                 
						prvDayMVBaseUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Base_Rate_Unit__c);
						prvDayMVConvertdUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Converted_Rate_Unit__c);                        
					}	
                    
					// Get Previous MOA Date
					lstMaxMOADate = [SELECT RE_Requested_Date__c FROM RE_MOA__c
									  WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c >=: currOPISTikrDate
									  AND RE_Requested_Date__c <: todayDate AND RE_IsLatest__c =: TRUE ORDER BY RE_Requested_Date__c DESC LIMIT 1];                
					
					if(lstMaxMOADate.Size() > 0) 
					{
						for(RE_MOA__c mxReqDt: lstMaxMOADate)
						{
							lstMaxMOADt = mxReqDt.RE_Requested_Date__c;
						}                      
					}
					else
						lstMaxMOADt = todayDate;
					
					// Get Previous MOA records
					for(RE_MOA__c oldMoa : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Today_s_Price__c,RE_CND_Market_Move__c, RE_CND_Competitive_Adj__c,RE_CND_Net_Move__c, 
											RE_CND_New_End_Price__c,RE_CND_Difference__c, RE_CND_Effective_Date__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c, 
											RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
											FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c =: lstMaxMOADt
											AND RE_IsLatest__c =: TRUE
											ORDER BY RE_CND_Group__c,RE_CND_Rack__c LIMIT 24])
					{
						oldMOALst.add(oldMoa);
						prvDayExePrBaseUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Base_Rate_Unit__c);
						prvDayExePrConvertdUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Converted_Rate_Unit__c);
					}                    
					
					// Get Previous Market Move records for Current selected OPIS 
					for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, RE_CND_Actual_Delta__c,
										  RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
										  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
										  AND RE_Requested_Date__c =: currOPISTikrDate AND RE_IsLatest__c =: TRUE])
					{
                        if(prvMV.RE_CND_Marker_Name__c != 'Reuters Fx')
                        {
                            mqPrice.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c); 					
                            mqUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Base_Rate_Unit__c);
                        }
					}
                    
					//Iterate through markerMappingsNameSettings
                    for(String keyName: mqPrice.Keyset())
					{ 
						mvDiffValue = 0.00;
				         //if mqMarkerName does have that key on Previous day
                        if(prvDayMVData.keyset().contains(keyName))
						{  
							mvDiffValue = mqPrice.get(keyName) - prvDayMVData.get(keyName);
							mqChange.put(keyName,mvDiffValue);							
						}
					}					
				}
           
				execMvMoaWrapr.mqPrice = mqPrice;
				execMvMoaWrapr.mqChange = mqChange;
				execMvMoaWrapr.mqUnitRate = mqUnitRate;
				execMvMoaWrapr.prvDayMVData = prvDayMVData;
				execMvMoaWrapr.oldMOALst = oldMOALst;
				execMvMoaWrapr.requestedDt = requestedDt;
				execMvMoaWrapr.effectiveDate = now;               
				execMvMoaWrapr.effectiveFromDate = effectiveFromDate;                 
				execMvMoaWrapr.effectiveToDate = effectiveToDate;
				execMvMoaWrapr.currOPISTikrDate = currOPISTikrDate;
				execMvMoaWrapr.currFxRateDate = currFxRateDate;
				execMvMoaWrapr.currFxRate = currFxRate;
				execMvMoaWrapr.prevOPISTikrDate = null;
				execMvMoaWrapr.prevFxRateDate = null;
				execMvMoaWrapr.prevFxRate = null;             
				execMvMoaWrapr.mvDefaultUnitRate = mvDefaultUnitRate;
				execMvMoaWrapr.epDefaultUnitRate = epDefaultUnitRate;
				execMvMoaWrapr.prvDayMVBaseUnitRate = prvDayMVBaseUnitRate;
				execMvMoaWrapr.prvDayMVConvertdUnitRate = prvDayMVConvertdUnitRate;
				execMvMoaWrapr.prvDayExePrBaseUnitRate = prvDayExePrBaseUnitRate;
				execMvMoaWrapr.prvDayExePrConvertdUnitRate = prvDayExePrConvertdUnitRate;   
                execMvMoaWrapr.CurtFxLst = CurtFxLst;
								   
				mvwrapper = RE_CND_ExecuteDepoPricingController.calculateMVandMOA(jrAudit, opisSpotRecordTypeId, marktMveRecordTypeId, cadMOARecordTypeId, execMvMoaWrapr, False, mqProcessedIds, curDayRecrdWrapper);                                                                
			}
			// For Special Day Market Move Calculation
			else if(currOPISTikrDate != null && currFxRateDate != null && prevOPISTikrDate != null && prevFxRateDate != null)
			{
				requestedFxStartDt = (DateTime)currFxRateDate;
				requestedFxEndDt = requestedFxStartDt.AddHours(23).AddMinutes(59).AddSeconds(59);
				DateTime requestedPrvFxStartDt = (DateTime)prevFxRateDate;
				DateTime requestedPrvFxEndDt = requestedPrvFxStartDt.AddHours(23).AddMinutes(59).AddSeconds(59);
				Set<Id> mqProcessedIds = New Set<Id>();
				Map<String,String> markerMappingsNameSettings = New Map<String,String>(); 
				Map<String,String> mqAllPrice = New Map<String,String>();
				Map<String,String> mqAllChange = New Map<String,String>(); 
				Boolean islowestVM = false;
				Id PrvFxRateId;
				Decimal prvfxRateVal = 0.00;
				Decimal mvDiffValue = 0.00;
								
				RE_CND_ExecuteDepoPricingController.executeMVandMOAWrapper execMvMoaWrapr = New RE_CND_ExecuteDepoPricingController.executeMVandMOAWrapper();
				
				// Get all the Marker Name Mappings from Settings
				for(RE_Field_Value_Mappings__c mkNameMappngs: [SELECT Id, Source_Field_Value__c, Mapping_Field_Value__c FROM RE_Field_Value_Mappings__c 
															   WHERE Country_Name__c =: 'Canada' AND Purpose__c =:'Live OPIS Spot Ticker Import' 
															   AND Object_Name__c =: 'RE_MOA__c' AND Field_Name__c =: 'RE_CND_Marker_Name__c' 
															   AND Is_Active__c =: TRUE ORDER BY Mapping_Field_Value__c])
				{
					markerMappingsNameSettings.put(mkNameMappngs.Source_Field_Value__c, mkNameMappngs.Mapping_Field_Value__c);
				}                    
				
				// Get the Current Fx Rate
				for(RE_FX_Rates__c curfx: [SELECT Id, RE_Forex_Rate__c, RE_Pricing_Date__c FROM RE_FX_Rates__c WHERE RE_Quote_Name__c =: fxLiveQuoteName
										   AND RE_Trade_Type__c =: 'Exchange Rate' 
										   AND RE_Pricing_Date__c >=: requestedFxStartDt AND RE_Pricing_Date__c <=: requestedFxEndDt
										   LIMIT 1])
				{
					fxRateId = curfx.Id;
					fxRate = curfx.RE_Forex_Rate__c;
				}
				
				// Current FxRate not exist, hence creating the same for current day
				if((fxRate == 0) && (currFxRateDate == requestedDt))
				{
					Date GMTDate = now.dateGMT();
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();                    
					curFx.RE_Forex_Rate__c = currFxRate;
					curFx.RE_Conversion_Unit__c = 'CAD';
					curFx.RE_Base_Unit__c = 'USD';
					curFx.RE_Forex_Name__c = 'CAD/USD';
					curFx.RE_Trade_Type__c = 'Exchange Rate';
					curFx.RE_Quote_Name__c = fxLiveQuoteName;
					curFx.RE_Pricing_Date__c = GMTDate;
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Create';
				}
				// Current FxRate not exist, hence creating the same for selected day
				else if((fxRate == 0) && (currFxRateDate != requestedDt))
				{					
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();                    
					curFx.RE_Forex_Rate__c = currFxRate;
					curFx.RE_Conversion_Unit__c = 'CAD';
					curFx.RE_Base_Unit__c = 'USD';
					curFx.RE_Forex_Name__c = 'CAD/USD';
					curFx.RE_Trade_Type__c = 'Exchange Rate';
					curFx.RE_Quote_Name__c = fxLiveQuoteName;
					curFx.RE_Pricing_Date__c = currFxRateDate;
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Create';
				}				
				// update Current FxRate, if not same
				else if(fxRate != currFxRate)
				{
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();
					curFx.Id = fxRateId;
					curFx.RE_Forex_Rate__c = currFxRate;                    
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Update';
				}
				
				// Get the Previous Fx Rate
				for(RE_FX_Rates__c prvfx: [SELECT Id, RE_Forex_Rate__c, RE_Pricing_Date__c FROM RE_FX_Rates__c WHERE RE_Quote_Name__c =: fxLiveQuoteName
										   AND RE_Trade_Type__c =: 'Exchange Rate' 
										   AND RE_Pricing_Date__c >=: requestedPrvFxStartDt AND RE_Pricing_Date__c <=: requestedPrvFxEndDt
										   LIMIT 1])
				{
					PrvFxRateId = prvfx.Id;
					prvfxRateVal = prvfx.RE_Forex_Rate__c;
				}  
				
				// Previous FxRate not exist, hence creating the same
				if((prvfxRateVal == 0) && (prevFxRateDate == requestedDt) && (prevFxRateDate != currFxRateDate))
				{                        
					Date GMTDate = now.dateGMT();
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();                    
					curFx.RE_Forex_Rate__c = prevFxRate;
					curFx.RE_Conversion_Unit__c = 'CAD';
					curFx.RE_Base_Unit__c = 'USD';
					curFx.RE_Forex_Name__c = 'CAD/USD';
					curFx.RE_Trade_Type__c = 'Exchange Rate';
					curFx.RE_Quote_Name__c = fxLiveQuoteName;
					curFx.RE_Pricing_Date__c = GMTDate;
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Create';
				}
				// Previous FxRate not exist, hence creating the same
				else if((prvfxRateVal == 0) && (prevFxRateDate != requestedDt) && (prevFxRateDate != currFxRateDate))
				{                        
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();                    
					curFx.RE_Forex_Rate__c = prevFxRate;
					curFx.RE_Conversion_Unit__c = 'CAD';
					curFx.RE_Base_Unit__c = 'USD';
					curFx.RE_Forex_Name__c = 'CAD/USD';
					curFx.RE_Trade_Type__c = 'Exchange Rate';
					curFx.RE_Quote_Name__c = fxLiveQuoteName;
					curFx.RE_Pricing_Date__c = prevFxRateDate;
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Create';
				}				
				// update Previous FxRate, if not same
				else if(prvfxRateVal != prevFxRate)
				{
					RE_FX_Rates__c curFx = New RE_FX_Rates__c();
					curFx.Id = PrvFxRateId;
					curFx.RE_Forex_Rate__c = prevFxRate;                    
					CurtFxLst.add(curFx);
					execMvMoaWrapr.fxRateCreatUpdteStatus = 'Update';
				} 
				
				// Get Previous Market Move records
				for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, 
									  RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
									  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
									  AND RE_Requested_Date__c =: prevOPISTikrDate AND RE_IsLatest__c =: TRUE])
				{
					prvDayMVData.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c);                 
					prvDayMVBaseUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Base_Rate_Unit__c);
					prvDayMVConvertdUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Converted_Rate_Unit__c);
				}
		
                // Current OPIS Spot Ticker is same as Requested date
                if(currOPISTikrDate == requestedDt)
				{
					// Get Previous MOA Date
					lstMaxMOADate = [SELECT RE_Requested_Date__c FROM RE_MOA__c
									  WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c <: currOPISTikrDate
									  AND RE_Requested_Date__c <: todayDate AND RE_IsLatest__c =: TRUE ORDER BY RE_Requested_Date__c DESC LIMIT 1];                
					
					if(lstMaxMOADate.Size() > 0) 
					{
						for(RE_MOA__c mxReqDt: lstMaxMOADate)
						{
							lstMaxMOADt = mxReqDt.RE_Requested_Date__c;
						}                      
					}
					else
						lstMaxMOADt = todayDate;
					
					// Get Previous MOA records
					for(RE_MOA__c oldMoa : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Today_s_Price__c,RE_CND_Market_Move__c, RE_CND_Competitive_Adj__c,RE_CND_Net_Move__c, 
											RE_CND_New_End_Price__c,RE_CND_Difference__c, RE_CND_Effective_Date__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c, 
											RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
											FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c =: lstMaxMOADt
											AND RE_IsLatest__c =: TRUE
											ORDER BY RE_CND_Group__c,RE_CND_Rack__c LIMIT 24])
					{
						oldMOALst.add(oldMoa);
						prvDayExePrBaseUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Base_Rate_Unit__c);
						prvDayExePrConvertdUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Converted_Rate_Unit__c);
					}

					// Get Live/Previous OPIS Spot Ticker records
					for(RE_Market_Quotes__c liveOPIS: [SELECT Id, RE_Quote_Name__c, RE_Price__c, RE_Validity_Month__c, RE_Rate_Unit__c                                                   
													   FROM RE_Market_Quotes__c
													   WHERE RecordTypeId =: opisSpotRecordTypeId AND RE_CND_Validity_Date__c =: currOPISTikrDate
													   AND RE_Is_Processed__c =: FALSE
													   ORDER BY RE_Quote_Name__c])
					{                   
						mqProcessedIds.add(liveOPIS.Id);    

						if((!(liveOPIS.RE_Quote_Name__c.toLowerCase().contains('change'))) && (markerMappingsNameSettings.containsKey(liveOPIS.RE_Quote_Name__c))) 
						{
							if(liveOPIS.RE_Validity_Month__c == null)
							{
								mqPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);   
								mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);   
							}
							else
							{
								if(mqPrice.containsKey(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)) 
								   && mqAllPrice.containsKey(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)))
								{
									// Check this is lowest validity month data
									islowestVM = RE_CND_ExecuteDepoPricingController.isLowestOPISValidityMonth(mqAllPrice.get(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c)),liveOPIS.RE_Validity_Month__c);
									if(islowestVM)
									{
										// Remove higher validity month records
										mqPrice.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
										mqAllPrice.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
										mqUnitRate.remove(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c));
										
										// Add lowest details in to the map
										mqPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);
										mqAllPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Validity_Month__c);
										mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);
									}                        
								}
								else
								{
									mqPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Price__c);
									mqAllPrice.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Validity_Month__c);
									mqUnitRate.put(markerMappingsNameSettings.get(liveOPIS.RE_Quote_Name__c), liveOPIS.RE_Rate_Unit__c);
								}                            
							}                 
						}
					}	
				}
				// Current OPIS Spot Ticker is not same as Requested date
				else
				{
					// Get Previous MOA Date
					lstMaxMOADate = [SELECT RE_Requested_Date__c FROM RE_MOA__c
									  WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c >=: currOPISTikrDate
									  AND RE_Requested_Date__c <: todayDate AND RE_IsLatest__c =: TRUE ORDER BY RE_Requested_Date__c DESC LIMIT 1];                
					
					if(lstMaxMOADate.Size() > 0) 
					{
						for(RE_MOA__c mxReqDt: lstMaxMOADate)
						{
							lstMaxMOADt = mxReqDt.RE_Requested_Date__c;
						}                      
					}
					else
						lstMaxMOADt = todayDate;
					
					// Get Previous MOA records
					for(RE_MOA__c oldMoa : [SELECT Id,RE_CND_Rack__c, RE_CND_Group__c, RE_CND_Today_s_Price__c,RE_CND_Market_Move__c, RE_CND_Competitive_Adj__c,RE_CND_Net_Move__c, 
											RE_CND_New_End_Price__c,RE_CND_Difference__c, RE_CND_Effective_Date__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c, 
											RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
											FROM RE_MOA__c WHERE RecordTypeId =: cadMOARecordTypeId AND RE_Requested_Date__c =: lstMaxMOADt
											AND RE_IsLatest__c =: TRUE
											ORDER BY RE_CND_Group__c,RE_CND_Rack__c LIMIT 24])
					{
						oldMOALst.add(oldMoa);
						prvDayExePrBaseUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Base_Rate_Unit__c);
						prvDayExePrConvertdUnitRate.put(oldMoa.RE_CND_Rack__c, oldMoa.RE_Converted_Rate_Unit__c);
					} 
					
					// Get Previous Market Move records for Current selected OPIS 
					for(RE_MOA__c prvMV: [SELECT Id, RE_CND_Marker_Name__c, RE_Price_Value__c, RE_CND_Actual_Delta__c,
										  RE_Base_Rate_Unit__c, RE_Converted_Rate_Unit__c
										  FROM RE_MOA__c WHERE RecordTypeId =: marktMveRecordTypeId 
										  AND RE_Requested_Date__c =: currOPISTikrDate AND RE_IsLatest__c =: TRUE])
					{
                        if(prvMV.RE_CND_Marker_Name__c != 'Reuters Fx')
                        {
                            mqPrice.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Price_Value__c); 					
                            mqUnitRate.put(prvMV.RE_CND_Marker_Name__c, prvMV.RE_Base_Rate_Unit__c);
                        }
					}		
				}
				
				//Iterate through markerMappingsNameSettings
				for(String keyName: mqPrice.Keyset())
				{ 
					mvDiffValue = 0.00;
					 //if mqMarkerName does have that key on Previous day
					if(prvDayMVData.keyset().contains(keyName))
					{  
						mvDiffValue = mqPrice.get(keyName) - prvDayMVData.get(keyName);
						mqChange.put(keyName,mvDiffValue);							
					}
				}					
			
				execMvMoaWrapr.mqPrice = mqPrice;
				execMvMoaWrapr.mqChange = mqChange;
				execMvMoaWrapr.mqUnitRate = mqUnitRate;
				execMvMoaWrapr.prvDayMVData = prvDayMVData;
				execMvMoaWrapr.oldMOALst = oldMOALst;
				execMvMoaWrapr.requestedDt = requestedDt;
				execMvMoaWrapr.effectiveDate = now;
				execMvMoaWrapr.effectiveFromDate = effectiveFromDate;                 
				execMvMoaWrapr.effectiveToDate = effectiveToDate;
				execMvMoaWrapr.currOPISTikrDate = currOPISTikrDate;
				execMvMoaWrapr.currFxRateDate = currFxRateDate;
				execMvMoaWrapr.currFxRate = currFxRate;
				execMvMoaWrapr.prevOPISTikrDate = prevOPISTikrDate;
				execMvMoaWrapr.prevFxRateDate = prevFxRateDate;
				execMvMoaWrapr.prevFxRate = prevFxRate;
				execMvMoaWrapr.mvDefaultUnitRate = mvDefaultUnitRate;
				execMvMoaWrapr.epDefaultUnitRate = epDefaultUnitRate;
				execMvMoaWrapr.prvDayMVBaseUnitRate = prvDayMVBaseUnitRate;
				execMvMoaWrapr.prvDayMVConvertdUnitRate = prvDayMVConvertdUnitRate;
				execMvMoaWrapr.prvDayExePrBaseUnitRate = prvDayExePrBaseUnitRate;
				execMvMoaWrapr.prvDayExePrConvertdUnitRate = prvDayExePrConvertdUnitRate;   
                execMvMoaWrapr.CurtFxLst = CurtFxLst;
				          
				mvwrapper = RE_CND_ExecuteDepoPricingController.calculateMVandMOA(jrAudit, opisSpotRecordTypeId, marktMveRecordTypeId, cadMOARecordTypeId, execMvMoaWrapr, False, mqProcessedIds, curDayRecrdWrapper); 	
			}                  
        }
        Catch(Exception ex)
        {      
            System.debug('generateMVandMOAFromOpisSpotTickrData-Error-->'+ex.getMessage());
            System.debug('generateMVandMOAFromOpisSpotTickrData-Error-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('CalculatingMarketMove',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_GenerateMVandMOAQueue','generateMVandMOAFromOpisSpotTickrData','Exception');            
            RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex);
        }         
    }
}