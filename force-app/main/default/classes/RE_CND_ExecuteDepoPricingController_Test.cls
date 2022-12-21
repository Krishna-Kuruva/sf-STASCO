/**************************************************************************************************
* Name: RE_CND_ExecuteDepoPricingController_Test
* Object: RE_Market_Quotes__c
* Purpose: Price Execution for Revolution Test Class
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-09-02
* Modify History: 
* 2021-09-02		Abhilash		Created
**************************************************************************************************/
@isTest
public class RE_CND_ExecuteDepoPricingController_Test {
    
    @testSetup static void setup() { 
        
        RE_Rate_Unit_Manager__c rum1 =RE_CND_TestDataFactory.createRateUnitManager('RUM1','CAD CTS/LTR','CAD CTS','LTR');
        RE_Rate_Unit_Manager__c rum2=RE_CND_TestDataFactory.createRateUnitManager('RUM2','CAD/LTR','CAD','LTR');
        RE_Rate_Unit_Manager__c rum3 =RE_CND_TestDataFactory.createRateUnitManager('RUM3','USD CTS/LTR','USD CTS','LTR');
        RE_Rate_Unit_Manager__c rum4=RE_CND_TestDataFactory.createRateUnitManager('RUM4','USD/LTR','USD','LTR');
        RE_Rate_Unit_Manager__c rum5=RE_CND_TestDataFactory.createRateUnitManager('RUM5','USD/BBL','USD','BBL');
        RE_Rate_Unit_Manager__c rum6=RE_CND_TestDataFactory.createRateUnitManager('RUM6','USD/GAL','USD','GAL');
        
        RE_CND_Base_Reference_Rack_Settings__c brr1=RE_CND_TestDataFactory.creatBaseRefRackSettingsManager('BRR-001','Ottawa','Toronto','Ottawa','Gasoline');
        RE_CND_Base_Reference_Rack_Settings__c brr2=RE_CND_TestDataFactory.creatBaseRefRackSettingsManager('BRR-002','Ottawa','Toronto','Ottawa','Gas Oil');
                      
        List<RE_Currency_Conversion__c> currConvr =  RE_CND_TestDataFactory.createCurrcyConver();
        List<RE_MY_VolumeConversion__c> volConvr =  RE_CND_TestDataFactory.createVolumeConver();
        
        List<RE_Zema_Quotes_Settings__c> quSettngs = RE_CND_TestDataFactory.createZemaQuotes();         
    }
    
    @isTest
    static void getFxRate_Test()
    {
        Test.startTest();        
        Datetime reqDateTime = system.now();
        Date reqDate =  date.newinstance(reqDateTime.year(), reqDateTime.month(), reqDateTime.day());
        RE_FX_Rates__c fxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.5,System.today(),'CAD');
        RE_CND_ExecuteDepoPricingController.getFxRate(reqDate);
        Test.stopTest();
    }
    
    @isTest
    static void getPrevDayBaseDifferentials_Test()
    {
        Test.startTest();
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
         
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        
        Id cndDepotPricingRecdTypId = Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Depot_Pricing_Backbone__c depo1 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                            RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD CTS/LTR',
                                                                            RE_CND_Is_Base_Product__c=false,RE_Location_Name__c=loc1.Id,RE_Product_Name__c=prod.Id,
                                                                            RE_CND_Product_Pricing_Basis__c=prod.Id,RE_CND_Plant_Pricing_Basis__c=loc1.Id,RE_CND_Group_Pricing_Basis__c='Unbranded');
              
        insert depo1;
        
        Id cpRecordID 	= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_MY_CostPrice__c cp1 =RE_CND_TestDataFactory.createCostPrice(cpRecordID,'Unbranded','Edmonton','Uploaded',100,prod.Id,loc1.Id,'40004-C123-Unbranded',FALSE,'CAD CTS/LTR',0,0,0);
       
        Map<String,RE_MY_CostPrice__c> prevCP = New Map<String,RE_MY_CostPrice__c>();
        prevCP.put(cp1.id,cp1);
      
        RE_CND_ExecuteDepoPricingController.getPrevDayBaseDifferentials(depo1,prevCP);
        
        Test.stopTest();
    }
    
    @isTest
    static void generateMVandMOAFromOPISData_Test()
    {
        Test.startTest();

        Datetime curreffctvDateTime = System.now();
        Datetime prveffctvDateTime = curreffctvDateTime.addDays(-1); 
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date effcFrmDate = reqDate.addDays(1); 
        
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','USD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','USD/LTR','Canada','RE_MOA__c',true);
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Market Move Calculation','CA'); 
       
        RE_Field_Value_Mappings__c fmvPg =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg1','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL) (Change)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg2 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg2','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB)','RBOB',True);
        RE_Field_Value_Mappings__c fmvPg3 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg3','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB) (Change)','RBOB',True);
        RE_Field_Value_Mappings__c fmvPg4 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg4','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST RBOB UNL NYHB','NYH RBOB Unl',True);
        RE_Field_Value_Mappings__c fmvPg5 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg5','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST RBOB UNL NYHB (Change)','NYH RBOB Unl',True);
        
        List<RE_Market_Quotes__c> opislve = RE_CND_TestDataFactory.createOPISLive(curreffctvDateTime);
        List<RE_MOA__c> mqOld = RE_CND_TestDataFactory.createMarketMoveData(prveffctvDateTime); 
        List<RE_MOA__c> expOld = RE_CND_TestDataFactory.createExecutPriceData(prveffctvDateTime);
       
        RE_CND_ExecuteDepoPricingController.generateMVandMOAFromOpisSpotTickrData(reqDate, effcFrmDate, effcFrmDate, reqDate, reqDate, 1.255, null, null, 0.00);       
        String jobStatus = RE_CND_ExecuteDepoPricingController.getJobRunAuditStatus(jra.Id);
        Test.stopTest();
    } 
    
    @isTest
    static void generateMVandMOAFromOPISData_Test1()
    {
        Test.startTest();

        Datetime curreffctvDateTime = System.now();
        Datetime prveffctvDateTime = curreffctvDateTime.addDays(-1); 
        Date prveffctvDate = date.newinstance(prveffctvDateTime.year(), prveffctvDateTime.month(), prveffctvDateTime.day());
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date effcFrmDate = reqDate.addDays(1);         
               
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','CAD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','CAD/LTR','Canada','RE_MOA__c',true);
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Market Move Calculation','CA'); 
        RE_Field_Value_Mappings__c fmvPg =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg1','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL) (Change)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg2 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg2','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB)','RBOB',True);
        RE_Field_Value_Mappings__c fmvPg3 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg3','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB) (Change)','RBOB',True);
      
        RE_FX_Rates__c prvfxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.255,prveffctvDate,'CAD');
        RE_CND_ExecuteDepoPricingController.checkOPISSpotTickerExistsOrNot(reqDate,false);
        RE_CND_ExecuteDepoPricingController.checkPreviousOPISSpotTickerExistsOrNot(prveffctvDate);
        List<RE_Market_Quotes__c> opislve = RE_CND_TestDataFactory.createOPISLive(curreffctvDateTime);
        List<RE_MOA__c> mqOld = RE_CND_TestDataFactory.createMarketMoveData(prveffctvDateTime); 
        List<RE_MOA__c> expOld = RE_CND_TestDataFactory.createExecutPriceData(prveffctvDateTime);
        
        RE_CND_ExecuteDepoPricingController.checkPreviousOPISSpotTickerExistsOrNot(prveffctvDate);
        RE_CND_ExecuteDepoPricingController.checkOPISSpotTickerExistsOrNot(reqDate,false);
        RE_CND_ExecuteDepoPricingController.generateMVandMOAFromOpisSpotTickrData(reqDate, effcFrmDate, effcFrmDate, null, null, 0.00, prveffctvDate, prveffctvDate, 1.2553);                     
        RE_CND_ExecuteDepoPricingController.generateMVandMOAFromOpisSpotTickrData(reqDate, effcFrmDate, effcFrmDate, null, null, 0.00, prveffctvDate, prveffctvDate, 1.5);                     
                              
        Test.stopTest();
    }    
    
    @isTest
    static void generateMVandMOAFromOPISData_Test2()
    {
        Test.startTest();

        Datetime curreffctvDateTime = System.now();
        Datetime prveffctvDateTime = curreffctvDateTime.addDays(-1); 
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date effcFrmDate = reqDate.addDays(1); 
        
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','CAD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','CAD/LTR','Canada','RE_MOA__c',true);
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Market Move Calculation','CA'); 
        RE_Field_Value_Mappings__c fmvPg =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg1','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL) (Change)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg2 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg2','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB)','RBOB',True);
        RE_Field_Value_Mappings__c fmvPg3 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg3','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB) (Change)','RBOB',True);

        RE_FX_Rates__c fxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.5,System.today(),'CAD');
        List<RE_Market_Quotes__c> opislve = RE_CND_TestDataFactory.createOPISLive(curreffctvDateTime);
        List<RE_MOA__c> expOld = RE_CND_TestDataFactory.createExecutPriceData(prveffctvDateTime);
        
        RE_CND_ExecuteDepoPricingController.generateMVandMOAFromOpisSpotTickrData(reqDate, effcFrmDate.addDays(-2), effcFrmDate, reqDate, reqDate, 1.255, null, null, 0.00);       
        
        Test.stopTest();
    }
    
    @isTest
    static void generateMVandMOAFromOPISData_Test3()
    {
        Test.startTest();

        Datetime curreffctvDateTime = System.now();
        Datetime prveffctvDateTime = curreffctvDateTime.addDays(-1); 
        Date prveffctvDate = date.newinstance(prveffctvDateTime.year(), prveffctvDateTime.month(), prveffctvDateTime.day());
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date effcFrmDate = reqDate.addDays(1);         
               
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','CAD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','CAD/LTR','Canada','RE_MOA__c',true);
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Market Move Calculation','CA'); 
        RE_Field_Value_Mappings__c fmvPg =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg1','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL) (Change)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg2 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg2','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB)','RBOB',True);
        RE_Field_Value_Mappings__c fmvPg3 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg3','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB) (Change)','RBOB',True);

        RE_FX_Rates__c prvfxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.255,prveffctvDate,'CAD');
        RE_FX_Rates__c fxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.5,System.today(),'CAD');        
        RE_CND_ExecuteDepoPricingController.checkOPISSpotTickerExistsOrNot(reqDate,false);
        RE_CND_ExecuteDepoPricingController.checkPreviousOPISSpotTickerExistsOrNot(prveffctvDate);
        List<RE_Market_Quotes__c> opislve = RE_CND_TestDataFactory.createOPISLive(curreffctvDateTime);
        List<RE_MOA__c> mqOld = RE_CND_TestDataFactory.createMarketMoveData(prveffctvDateTime); 
        List<RE_MOA__c> expOld = RE_CND_TestDataFactory.createExecutPriceData(prveffctvDateTime);        
                                    
        RE_CND_ExecuteDepoPricingController.generateMVandMOAFromOpisSpotTickrData(reqDate, effcFrmDate, effcFrmDate, reqDate, reqDate, 1.255, prveffctvDate, prveffctvDate, 1.2553);                     
                              
        Test.stopTest();
    }      
    
    @isTest
    static void generateMVandMOAFromOPISData_Test4()
    {
        Test.startTest();

        Datetime curreffctvDateTime = System.now();
        Datetime prveffctvDateTime = curreffctvDateTime.addDays(-1); 
        Date prveffctvDate = date.newinstance(prveffctvDateTime.year(), prveffctvDateTime.month(), prveffctvDateTime.day());
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date effcFrmDate = reqDate.addDays(1);         
               
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','CAD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','CAD/LTR','Canada','RE_MOA__c',true);
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Market Move Calculation','CA'); 
        RE_Field_Value_Mappings__c fmvPg =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg1','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','WTI (CL) (Change)','WTI',True);
        RE_Field_Value_Mappings__c fmvPg2 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg2','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB)','RBOB',True);
        RE_Field_Value_Mappings__c fmvPg3 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg3','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','RBOB (RB) (Change)','RBOB',True);

        RE_FX_Rates__c fxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.5,System.today(),'CAD');        
        RE_CND_ExecuteDepoPricingController.checkOPISSpotTickerExistsOrNot(reqDate,false);
        RE_CND_ExecuteDepoPricingController.checkPreviousOPISSpotTickerExistsOrNot(prveffctvDate);
        List<RE_Market_Quotes__c> opislve = RE_CND_TestDataFactory.createOPISLive(curreffctvDateTime);
        List<RE_MOA__c> mqOld = RE_CND_TestDataFactory.createMarketMoveData(prveffctvDateTime); 
        List<RE_MOA__c> expOld = RE_CND_TestDataFactory.createExecutPriceData(prveffctvDateTime);        
                                    
        RE_CND_ExecuteDepoPricingController.generateMVandMOAFromOpisSpotTickrData(reqDate, effcFrmDate, effcFrmDate, null, null, 0.00, prveffctvDate, prveffctvDate, 1.5);                     
                              
        Test.stopTest();
    }     
    
   @isTest
   static void getCurrentPricingDifferential_Test()
    {
        Test.startTest();
        
        List<RT_Setting__c> cuntrySettng = RE_CND_TestDataFactory.createCountrySettings();
        
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','USD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','USD/LTR','Canada','RE_MOA__c',true);

        id plantDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Plant Differential' Limit 1].Id;
        id productDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Product Differential' Limit 1].Id;
        id brandFeeId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Fee' Limit 1].Id;
        id brandDiscountId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Discount' Limit 1].Id;

       // RE_CND_ExecuteDepoPricingController.getCurrentPricingDifferential(cuntrySettng, plantDifferentialId, productDifferentialId, brandFeeId, brandDiscountId, 'USD/LTR', 1.255,null);
        Datetime curreffctvDateTime = System.now();
        List<RE_MOA__c> mqCurr = RE_CND_TestDataFactory.createMarketMoveData(curreffctvDateTime); 
        Set<Id> moaIds = New Set<Id>();
        Id moa = [Select Id from RE_MOA__c Limit 1].Id;
        moaIds.add(moa);
        
        Id cpRecordID 	= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_MY_CostPrice__c cp1=RE_CND_TestDataFactory.createCostPrice(cpRecordID,'Unbranded','Edmonton','Draft',100,null,null,'',TRUE,'CAD CTS/LTR',0,0,0);
        Set<Id> costpId = new Set<Id>();
        costpId.add(cp1.id);
        
        RE_CND_ExecuteDepoPricingController.updateInitialVersionInMOA(moaIds);
        RE_CND_ExecuteDepoPricingController.currentDayExistingRecordsWrapper curDayRecrdWrapper = new RE_CND_ExecuteDepoPricingController.currentDayExistingRecordsWrapper(); 
        RE_CND_ExecuteDepoPricingController.updateInitialVersionInOlderMOA(moaIds,curDayRecrdWrapper);  
        RE_CND_ExecuteDepoPricingController.updateInitialVersionInOlderCostPrice(costpId,null);
        RE_CND_ExecuteDepoPricingController.calDepotPricingUserAccessLevel();
        
        Test.stopTest();
    }
    
    @isTest
    static void getMOAGasolineDieselDetails_Test()
    {
        Test.startTest();
        Datetime curreffctvDateTime = System.now();
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());       
        RE_CND_ExecuteDepoPricingController.getMOAGasolineDieselDetails(reqDate);
        Test.stopTest();
    }
    
    @isTest
    static void startCalculatingDepoPricing_Test()
    {
        Test.startTest();

        Datetime curreffctvDateTime = System.now();
        Datetime prveffctvDateTime = curreffctvDateTime.addDays(-1); 
        date prveffctvDate = date.newinstance(prveffctvDateTime.year(), prveffctvDateTime.month(), prveffctvDateTime.day());
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date effcFrmDate = reqDate.addDays(1); 
        
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','CAD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','CAD/LTR','Canada','RE_MOA__c',true);
     
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Execute Depo Pricing','CA'); 
      
        List<RE_Field_Value_Mappings__c> markrName = RE_CND_TestDataFactory.createMarkerNameMappings();
        
        RE_FX_Rates__c prvfxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.25,prveffctvDate,'CAD');
        RE_FX_Rates__c fxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.5,System.today(),'CAD');
        
        List<RE_Market_Quotes__c> opislve = RE_CND_TestDataFactory.createOPISLive(curreffctvDateTime);
        List<RE_MOA__c> mqOld = RE_CND_TestDataFactory.createMarketMoveData(prveffctvDateTime); 
        List<RE_MOA__c> expOld = RE_CND_TestDataFactory.createExecutPriceData(prveffctvDateTime);
            
        List<RE_MOA__c> mqCurr = RE_CND_TestDataFactory.createMarketMoveData(curreffctvDateTime); 
        List<RE_MOA__c> expCurr = RE_CND_TestDataFactory.createExecutPriceData(curreffctvDateTime);
        
        List<RT_Setting__c> cuntrySettng = RE_CND_TestDataFactory.createCountrySettings();
        List<RE_Depot_Pricing_Backbone__c> depoDataList = RE_CND_TestDataFactory.createDepoPricingData(); 
        List<RE_MY_CostPrice__c> oldCostPriceDataList = RE_CND_TestDataFactory.createOldCostPriceData();
        
        RE_CND_ExecuteDepoPricingController.startCalculatingDepoPricing(reqDate, effcFrmDate, effcFrmDate, expCurr);

        RE_CND_ExecuteDepoPricingController.getExistingDepoPricingAndPriceBook(effcFrmDate);
        RE_CND_ExecuteDepoPricingController.getExistingMarketMoveAndMOA(effcFrmDate);
                
        RE_Holiday_Calendars__c reHc = RE_CND_TestDataFactory.createHolidyCalender('hc1', 'Monday', 'Newyear', effcFrmDate);
        RE_Holiday_Calendars__c reHc1 = RE_CND_TestDataFactory.createHolidyCalender('hc2','Tuesday', 'Newyear1', effcFrmDate.addDays(1));
        
        RE_CND_ExecuteDepoPricingController.getMOAGasolineDieselDetails(reqDate);
        
        Test.stopTest();
    }   
   
    @isTest
    static void startCalculatingDepoPricing_Test1()
    {
        Test.startTest();

        Datetime curreffctvDateTime = System.now();
        Datetime prveffctvDateTime = curreffctvDateTime.addDays(-1); 
        date prveffctvDate = date.newinstance(prveffctvDateTime.year(), prveffctvDateTime.month(), prveffctvDateTime.day());
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date effcFrmDate = reqDate.addDays(1); 
        
        RE_Default_Unit_Rate_Settings__c defaultunit = RE_CND_TestDataFactory.createDefaultUnit('DS1','Market Move Calculation','USD/LTR','Canada','RE_MOA__c',true);
        RE_Default_Unit_Rate_Settings__c defaultunit1 = RE_CND_TestDataFactory.createDefaultUnit('DS2','Price Execution','USD/LTR','Canada','RE_MOA__c',true);
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Execute Depo Pricing','CA'); 
        RE_Field_Value_Mappings__c fmvPg =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST ULS#2 NYHB','NYH ULS#2',True);
        RE_Field_Value_Mappings__c fmvPg1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg1','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST ULS#2 NYHB (Change)','NYH ULS#2',True);
        RE_Field_Value_Mappings__c fmvPg2 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg2','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST CBOB Chi.Comp','Chi CBOB',True);
        RE_Field_Value_Mappings__c fmvPg3 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg3','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST CBOB Chi.Comp (Change)','Chi CBOB',True);
        RE_Field_Value_Mappings__c fmvPg4 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg4','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST RBOB UNL NYHB','NYH RBOB Unl',True);
        RE_Field_Value_Mappings__c fmvPg5 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg5','Canada','Live OPIS Spot Ticker Import','RE_MOA__c','RE_CND_Marker_Name__c','EAST RBOB UNL NYHB (Change)','NYH RBOB Unl',True);
		         
        RE_FX_Rates__c prvFxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.25,prveffctvDate,'CAD');
        RE_FX_Rates__c fxRate= RE_CND_TestDataFactory.createFXRate('Live FX Rate',1.5,System.today(),'CAD');
        
        List<RE_Market_Quotes__c> opislve = RE_CND_TestDataFactory.createOPISLive(curreffctvDateTime);
        List<RE_MOA__c> expOld = RE_CND_TestDataFactory.createExecutPriceData(prveffctvDateTime);
             
        List<RE_MOA__c> mqCurr = RE_CND_TestDataFactory.createMarketMoveData(curreffctvDateTime); 
        List<RE_MOA__c> expCurr = RE_CND_TestDataFactory.createExecutPriceData(curreffctvDateTime);

        List<RT_Setting__c> cuntrySettng = RE_CND_TestDataFactory.createCountrySettings();
        List<RE_Depot_Pricing_Backbone__c> depoDataList = RE_CND_TestDataFactory.createDepoPricingData(); 
        List<RE_MY_CostPrice__c> oldCostPriceDataList = RE_CND_TestDataFactory.createOldCostPriceData_New();
        
        RE_CND_ExecuteDepoPricingController.startCalculatingDepoPricing(reqDate, effcFrmDate, effcFrmDate, expCurr);       
        
        Test.stopTest();
    } 
    
    @isTest
    static void getCurentDayAllCostPriceRecords_Test()
    {
        Test.startTest();
        
        Id accRecordId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Canada').getRecordTypeId();
        Account acc1=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc1',null,'Sold To','10001',TRUE);
        Account acc2=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc2',acc1.Id,'Ship To','20002',TRUE);
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
      
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceData(); 
        
        Id pbRecordId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        RT_Price_Book__c pb1=RE_CND_TestDataFactory.createPriceBook
            (pbRecordId,'Edmonton','Bronze','Draft',10,prod.Id,loc1.Id,'40004-C123-Unbranded',acc2.Id,acc1.Id,'CAD CTS/LTR',System.today(),System.today());
        
        Datetime curreffctvDateTime = System.now();
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        Date reqFrDate = reqDate.addDays(1);
        RE_CND_ExecuteDepoPricingController.getCurentDayAllCostPriceRecords(reqFrDate);        
        
        Test.stopTest();
    }
    
    @isTest
    static void getExistingDepoPricingAndPriceBook_Test()
    {
        Test.startTest();
        Datetime curreffctvDateTime = System.now();
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        RE_CND_ExecuteDepoPricingController.getExistingDepoPricingAndPriceBook(reqDate);
        Test.stopTest();
    }
    
    @isTest
    static void getAllPricingData_Test()
    {
        Test.startTest();
        Datetime curreffctvDateTime = System.now();
        curreffctvDateTime = curreffctvDateTime.addDays(1);
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
               
        List<RE_MOA__c> mqCurr = RE_CND_TestDataFactory.createMarketMoveData(curreffctvDateTime); 
        List<RE_MOA__c> expCurr = RE_CND_TestDataFactory.createExecutPriceData(curreffctvDateTime);
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createNewCostPriceData(); 
                
        Id accRecordId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Canada').getRecordTypeId();
        Account acc1=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc1',null,'Sold To','10001',TRUE);
        Account acc2=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc2',acc1.Id,'Ship To','20002',TRUE);
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);

        Id pbRecordId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        RT_Price_Book__c pb1=RE_CND_TestDataFactory.createPriceBook
            (pbRecordId,'Edmonton','Bronze','Draft',10,prod.Id,loc1.Id,'40004-C123-Unbranded',acc2.Id,acc1.Id,'CAD CTS/LTR',System.today(),System.today());
 
        RE_CND_ExecuteDepoPricingController.getCurentDayAllMOAAndCostPriceAndPriceBkRecords(reqDate);
        Test.stopTest();
    }
    
    @isTest
    static void getAllPricingData_Test_1()
    {
        Test.startTest();
        Datetime curreffctvDateTime = System.now();
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
               
        List<RE_MOA__c> mqCurr = RE_CND_TestDataFactory.createMarketMoveData(curreffctvDateTime); 
        List<RE_MOA__c> expCurr = RE_CND_TestDataFactory.createExecutPriceData(curreffctvDateTime);
                
        RE_CND_ExecuteDepoPricingController.getCurentDayAllMOAAndCostPriceAndPriceBkRecords(reqDate);
        Test.stopTest();
    }
    
    @isTest
    static void getAllPricingData_Test_2()
    {
        Test.startTest();
        Datetime curreffctvDateTime = System.now();
        curreffctvDateTime = curreffctvDateTime.addDays(1);
        Date reqDate =  date.newinstance(curreffctvDateTime.year(), curreffctvDateTime.month(), curreffctvDateTime.day());
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);

        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createNewCostPriceData(); 
        
        Map<String,RE_MY_CostPrice__c> currtDayMapCostPriceLst = New Map<String,RE_MY_CostPrice__c>();
        Set<Id> costPriceIds = New Set<Id>();
        for(RE_MY_CostPrice__c costprc : newCostPriceDataList)
        {
           costPriceIds.add(costprc.Id);            
           currtDayMapCostPriceLst.put('40004C123'+costprc.RE_CND_Rack__c+costprc.RE_CND_Product_Group__c+costprc.RE_CND_Group__c,costprc);
           currtDayMapCostPriceLst.put(costprc.RE_Product_Codes__c+costprc.RE_Depot_Code__c+costprc.RE_CND_Rack__c+costprc.RE_CND_Product_Group__c+costprc.RE_CND_Group__c,costprc);
        }
       
        RE_CND_ExecuteDepoPricingController.currentDayRecordsWrapper curDayRecrdWrapper = new RE_CND_ExecuteDepoPricingController.currentDayRecordsWrapper(); 
        curDayRecrdWrapper.currtDayMapCostPriceList = currtDayMapCostPriceLst;
        RE_CND_ExecuteDepoPricingController.updateInitialVersionInOlderCostPrice(costPriceIds,curDayRecrdWrapper);
        
        Test.stopTest();
    }
    
    @isTest
    Static void revContractMaster_ValidationTest1()
    {
        Test.startTest();
        REV_Contract_Master__c rev = new REV_Contract_Master__c();
        rev.Active__c=TRUE; 
        rev.Country_Name__c='CA'; 
        try{
        insert rev;
        }
        catch (Exception e)
        {
            System.Assert(e.getMessage().contains('Sold to Name is mandatory'));            
        }
        Test.stopTest();
    }
    
    @isTest
    Static void revContractMaster_ValidationTest2()
    {
        Test.startTest();
        Id accRecordId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Canada').getRecordTypeId();
        Account acc1=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc1',null,'Sold To','10001',TRUE);
        REV_Contract_Master__c rev = new REV_Contract_Master__c();
        rev.Active__c=TRUE; 
        rev.Country_Name__c='CA'; 
        rev.RT_Sold_to_Name__c = acc1.Id;
        try{
        insert rev;
        }
        catch (Exception e)
        {           
            System.Assert(e.getMessage().contains('Ship to Name is mandatory'));
        }
        Test.stopTest();  
        
    }
    
    @isTest
    Static void revContractMaster_ValidationTest3()
    {
        Test.startTest();
        Id accRecordId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Canada').getRecordTypeId();
        Account acc1=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc1',null,'Sold To','10001',TRUE);
        Account acc2=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc2',null,'Ship To','10002',TRUE);
        REV_Contract_Master__c rev = new REV_Contract_Master__c();
        rev.Active__c=TRUE; 
        rev.Country_Name__c='CA'; 
        rev.RT_Sold_to_Name__c = acc1.Id;
        rev.RT_Ship_to_Name__c = acc2.Id;
        try{
        insert rev;
        }
        catch (Exception e)
        {           
            System.Assert(e.getMessage().contains('Rack is mandatory'));
        }
        Test.stopTest();          
    }
    
    @isTest
    static void priceBookBatchUpdate_Test()
    {
        Test.startTest();
        
        Id accRecordId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Canada').getRecordTypeId();
        Account acc1=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc1',null,'Sold To','10001',TRUE);
        Account acc2=RE_CND_TestDataFactory.createAccount(accRecordId,'Acc2',acc1.Id,'Ship To','20002',TRUE);
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Execute Depo Pricing','CA'); 
        
        Id pbRecordId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
        RT_Price_Book__c pb1=RE_CND_TestDataFactory.createPriceBook
            (pbRecordId,'Edmonton','Bronze','Draft',10,prod.Id,loc1.Id,'40004-C123-Unbranded',acc2.Id,acc1.Id,'CAD CTS/LTR',System.today(),System.today());
  
        List<RT_Price_Book__c> pbLst = New List<RT_Price_Book__c>();
        for(RT_Price_Book__c lstpb: [Select Id, RE_Custom_Opp_Approve__c, RE_Is_Latest__c from RT_Price_Book__c where RecordTypeId =: pbRecordId])
        {
            RT_Price_Book__c pbUpdate = New RT_Price_Book__c();
            pbUpdate.Id = lstpb.Id;
            pbUpdate.RE_Is_Latest__c = FALSE;
            pbUpdate.RE_Custom_Opp_Approve__c = 'Redundant';
            pbLst.add(pbUpdate);            
        }
        
        RE_CND_PriceBookBatchUpdate updatePB = New RE_CND_PriceBookBatchUpdate(pbLst, jra, 'Processing', true);
        Database.executeBatch(updatePB);
        
        Test.stopTest();
    }
            
}