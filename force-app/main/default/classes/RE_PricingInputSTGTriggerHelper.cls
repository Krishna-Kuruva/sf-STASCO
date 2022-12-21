/**************************************************************************************************
* Name: RE_PricingInputSTGTriggerHelper
* Object: RE_Market_Quotes__c
* Purpose: Pricing Input Staging for Revolution
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-07-24
* Modify History: 
* 2021-07-24		Abhilash		Created
**************************************************************************************************/
public class RE_PricingInputSTGTriggerHelper {
    
    public static void processingPricingInputStgData(List<RE_Pricing_Input_STG__c> newList)
    {        
        List<RE_Pricing_Input_STG__c> cndCompetitorData = New List<RE_Pricing_Input_STG__c>();
        List<RE_Pricing_Input_STG__c> cndLiveOPISData = New List<RE_Pricing_Input_STG__c>();
        
        Id opisSptTickrRecordTypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByDeveloperName().get('Canada_OPIS_Spot_Ticker').getRecordTypeId();
        Id competitorRecordTypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByDeveloperName().get('Canada_Competitor').getRecordTypeId();
        
        for(RE_Pricing_Input_STG__c rpis :newList)
        {
            if(rpis.RecordTypeId == opisSptTickrRecordTypeId)
            {
               cndLiveOPISData.add(rpis);
            }
            
            if(rpis.RecordTypeId == competitorRecordTypeId)
            {
                cndCompetitorData.add(rpis);
            }
        }
        
        // Process Revolution Canada Live OPIS Spot Ticker
        if(cndLiveOPISData.Size() > 0)        
           RE_CND_PricingInputStaging.processingLiveOPISSpotTicker(cndLiveOPISData);        
        
        // Process Revolution Canada Competitor
        if(cndCompetitorData.Size() > 0)
			RE_CND_PricingInputStaging.processCompetitorData(cndCompetitorData);
    }
}