public class REV_FormulaPricingTriggerClass {
    public static void onafterinsert(List<Rev_Formula_Price_Staging_Table__c> revContractMaster){
        List<String> gsapContractmasterLst = new List<String>();
        for(Rev_Formula_Price_Staging_Table__c contrctMaster : revContractMaster){
            gsapContractmasterLst.add(contrctMaster.Id);
        }
        CreateFrmlaPricingGSAPInterface(gsapContractmasterLst);
    }
    
     @future (callout=true)
    public static void CreateFrmlaPricingGSAPInterface(List<String> gsapContractmasterLst){
        
        List<Revolution_Deal_GSAP_Config__mdt> revDealGSAPLst = [Select Id,MasterLabel,DeveloperName,
                                                                 Client_Id__c,Client_Secret__c,
                                                                 Content_Type__c,Endpoint__c,Method__c from 
                                                                 Revolution_Deal_GSAP_Config__mdt ];
        
        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap = new Map<String,Revolution_Deal_GSAP_Config__mdt>();
        for(Revolution_Deal_GSAP_Config__mdt revDealGSAPConfig : revDealGSAPLst){
            revDealGSAPMap.put(revDealGSAPConfig.MasterLabel,revDealGSAPConfig);
        }
        String access_Token = RV_DealGSAPMulesoft.basicAuthCallout(revDealGSAPMap);
        System.debug('--------access_Token-----'+access_Token);
        Rev_FormulaPricingGSAPInterface.callGSAPforFrmulaPricing(access_Token,gsapContractmasterLst,revDealGSAPMap);
    }
}