@istest
public class RE_TH_OilLossControllerTest {
    
    
    @istest static void olDataPreparationtest(){
        
        Country__c country_TH = RE_UtilityClass.getCountryCode('Thailand');
        RE_Location__c location1 = RE_UtilityClass.getLocation('TH NMIF','T11',country_TH.Name);
        Id reTHProductRecTypeId = Schema.getGlobalDescribe().get('RE_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Thailand').getRecordTypeId();
        RE_Product__c prod_Kero = RE_TestDataFactory.createREProduct('Kerosene', country_TH.Id, reTHProductRecTypeId);
        insert prod_Kero;       
        Id reTHDPBRecTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Thailand').getRecordTypeId();
        RE_Depot_Pricing_Backbone__c depotPricing = RE_TestDataFactory.createREDepotPricingBackBone(country_TH.Id, reTHDPBRecTypeId, location1.Id, prod_Kero.Id, System.today().addDays(-10), System.today().addDays(10));
        depotPricing.RE_TH_Oil_Loss_Percent__c = 2;
        insert depotPricing;
        
        
        RE_MY_FormulaFetchController.formulaWrapperTH mffc = new  RE_MY_FormulaFetchController.formulaWrapperTH();
        mffc.depoId = depotPricing.Id;
        mffc.finalUnit = 'Litre';
        mffc.country = 'Thailand';
        mffc.hcfObj = depotPricing;
        mffc.product = 'Kerosene';
        mffc.location = 'Peninsular';
        list<RE_MY_FormulaFetchController.formulaWrapperTH> mlft_list = new list<RE_MY_FormulaFetchController.formulaWrapperTH>{mffc};
            
            Map<Id, Double> finalhcval = new Map<Id,Double>{depotPricing.Id=>2.0};     
                
                RE_Product__c product1 = new  RE_Product__c();
        product1.Active__c = true;
        product1.Name = 'Kerosene';
        product1.RE_TH_Oil_Loss_Percent__c = 2;
        insert product1;
        
        list<RE_Product__c> productlst = new list<RE_Product__c>{product1}; 
            
            RE_TH_OilLossController ctrl = new RE_TH_OilLossController();
        
        test.startTest();
        RE_UtilitywrapperController.lineitemwraapper liwrapper = ctrl.olDataPreparation( mlft_list, finalhcval,productlst); 
        test.stopTest();
        
        system.assertEquals(liwrapper.finalval.get(depotPricing.Id), 0.04);
        
    }
    
}