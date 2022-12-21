/**************************************************************************************************
* Name: RE_PricingInputSTGTriggerHelper_Test
* Object: RE_Market_Quotes__c
* Purpose: Pricing Input Staging for Revolution Test Class
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-09-01
* Modify History: 
* 2021-09-01		Abhilash		Created
**************************************************************************************************/
@isTest
public class RE_PricingInputSTGTriggerHelper_Test {
    
    
    @testSetup static void setup() { 
      
    }
    
    @isTest
    static void procingPricingInputStgData_Competitor_Test()
    {
        Test.startTest();
        
        RE_JobControls__c jobControl =  RE_CND_TestDataFactory.createJobControlSetting('JC1','RE_CND_PricingInputStaging','processCompetitorData','Canada',true); 
        RE_Job_Run_Audit__c jra = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Competitor Data Processing','CA'); 
        RE_Field_Value_Mappings__c fmvPg =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Product_Group__c','Pre','Premium',True);
        RE_Field_Value_Mappings__c fmvPg1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvPg1','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Product_Group__c','Unl','RUG',True); 
        RE_Field_Value_Mappings__c fmvRk =  RE_CND_TestDataFactory.createFieldValueMappings('fmvRk','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Rack__c','EDMONTON','Edmonton',True);
        RE_Field_Value_Mappings__c fmvRk1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvRk1','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Rack__c','CALGARY','Calgary',True);      
        RE_Field_Value_Mappings__c fmvSupp1 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvSupp1','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Supplier1_Price__c','Supplier1','Esso Canada',True);
        RE_Field_Value_Mappings__c fmvSupp2 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvSupp2','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Supplier2_Price__c','Supplier2','Suncor',True);
        RE_Field_Value_Mappings__c fmvSupp3 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvSupp3','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Supplier3_Price__c','Supplier3','Valero',True);
        RE_Field_Value_Mappings__c fmvSupp4 =  RE_CND_TestDataFactory.createFieldValueMappings('fmvSupp4','Canada','Competitor Data Import','RE_MY_CostPrice__c','RE_CND_Supplier4_Price__c','Supplier4','Parkland',True);

        Id competitorRecordTypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByDeveloperName().get('Canada_Competitor').getRecordTypeId();
        List<RE_MY_CostPrice__c> newCostPriceDataList = RE_CND_TestDataFactory.createCostPriceData(); 
        List<RE_Pricing_Input_STG__c> newCompetitorDataList = RE_CND_TestDataFactory.createCompetitorData(); 
        
        List<RE_Pricing_Input_STG__c> newCompeDataList = [Select RE_CND_Daily_Racks_Raw_Date__c,RE_CND_City_Code__c, RE_CND_City_Name__c,RE_CND_Supplier_Name__c,RE_CND_Brand_Indicator__c,
                                                          RE_CND_Product_Group__c,RE_Price__c, RE_CND_Move_Value__c,RE_Pricing_Date__c,RE_Default_Currency__c,RE_Unit_of_Measure__c from RE_Pricing_Input_STG__c
                                                          where RecordTypeId =: competitorRecordTypeId];
        
        RE_CND_PricingInputStaging.processCompetitorData(newCompeDataList);
        
        Test.stopTest();
    }   
    
    @isTest
    static void processingLiveOPISSpotTicker_Test()
    {
        Test.startTest();
        Id opisRecordTypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByDeveloperName().get('Canada_OPIS_Spot_Ticker').getRecordTypeId(); 
        RE_JobControls__c jobControl1 =  RE_CND_TestDataFactory.createJobControlSetting('JC2','RE_CND_PricingInputStaging','processingLiveOPISSpotTicker','Canada',true); 
        RE_Job_Run_Audit__c jra1 = RE_CND_TestDataFactory.createJobRunAudit('Manual','Canada Live OPIS Spot Ticker Processing','CA'); 
        List<RE_Pricing_Input_STG__c> newCompetitorDataList = RE_CND_TestDataFactory.createOPISspotTickerData();       
        
        List<RE_Pricing_Input_STG__c> newOPISDataList = [Select RE_CND_Quote_Name__c,RE_Price__c,RE_Validity_Month__c,RE_Pricing_Date__c,
                                                         RE_Default_Currency__c,RE_Unit_of_Measure__c,RE_Quote_Type__c,RE_Quote_Source__c
                                                         from RE_Pricing_Input_STG__c where RecordTypeId =: opisRecordTypeId]; 
        
        RE_CND_PricingInputStaging.processingLiveOPISSpotTicker(newOPISDataList);        
        
        Test.stopTest(); 
    }  
    
}