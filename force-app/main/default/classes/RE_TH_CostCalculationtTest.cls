@isTest(SeeAllData = False)
public class RE_TH_CostCalculationtTest { 
    public static testmethod void testUtility()
    {
        //Country Data
        List<Country__c> count = new List<Country__c>();
        Country__c country = RE_UtilityClass.getCountryCode('Thailand');
        count.add(country);
        
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn = RE_UtilityClass.getLocation('Bandon','LB','Thailand');
        RE_Location__c loctn1 = RE_UtilityClass.getLocation('Chongnonsri','BK','Thailand');
        RE_Location__c loctn2 = RE_UtilityClass.getLocation('Lumlukka','LB','Thailand');
        location.add(loctn);
        location.add(loctn1);
        location.add(loctn2);
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product = RE_UtilityClass.getProduct('Kerosene','Thailand','STG/LTR');
        RE_Product__c product1 = RE_UtilityClass.getProduct('Fuel Oil A 2%S-80 CST','Thailand','STG/LTR');
        product.TP_Premium_Unit__c	=	'USD/BBL';
        product.RE_TH_TP_PremiumHCV__c=0;
        product.RE_TH_TP_Premium__c='1.8';
        product.TH_TP_PremiumHCV2_UNIT__c='USD/BBL';
        product.RE_TH_Oil_Loss_Percent__c=0.1;
        product1.TP_Premium_Unit__c	=	'USD/BBL';
        product1.RE_TH_TP_Premium__c='1.8';
        product1.RE_TH_TP_PremiumHCV2__c=0;
        product1.TH_TP_PremiumHCV2_UNIT__c='USD/BBL';
        product1.RE_TH_Oil_Loss_Percent__c=0.1;
        prod.add(product);
        prod.add(product1);
        update prod;
        //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();
        
        RE_ExternalQuoteMapping__c extQuote = new RE_ExternalQuoteMapping__c();
        extQuote.name='Kero';
        extQuote.External_Quote_Source__c = 'PP';
        extQuote.External_Quote_Type__c = 'M';
        extQuote.External_Quotation_Number__c = 'SING FOB KERO';
        extQuote.RE_Quote_Name__c = 'Kero';
        extQuote.RE_Quote_Type__c = 'Settlement';
        insert extQuote;
        
        //Market Quote Data
        List<RE_Market_Quotes__c> mQuotes = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(23.6560,'USD/TON','BBL','Marine FuelOil 180');
        createMQ1.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.05% S');
        createMQ2.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(54.4658,'USD/BBL','BBL','Kero');
        createMQ3.RE_Quote_Type__c = 'Settlement';       
        mQuotes.add(createMQ1);
        mQuotes.add(createMQ2);
        mQuotes.add(createMQ3);       
		update mQuotes;
        
        //Forex Rate Data
        //List<RE_FX_Rates__c> fRates = new List<RE_FX_Rates__c>();
        //RE_FX_Rates__c FXrate2 = RE_UtilityClass.createFXRecordsYday('THB/USD',4.3720,'USD','MYR','Thailand');
       // RE_FX_Rates__c FXrate1 = RE_UtilityClass.createFXRecordsYday('MYR CTS/USD',437.20,'USD','MYR CTS','Thailand');        
  
        //Bio Quote Data
		
        List<RE_Bio_Quotes__c> bQuotes = new List<RE_Bio_Quotes__c>();
        RE_Bio_Quotes__c bQ1 = RE_UtilityClass.getBioQuotes(76.4200,'USD/BBL','BBL','HDGO','Thailand');
        bQuotes.add(bQ1); 
       /* RE_Bio_Quotes__c bQ2 = RE_UtilityClass.getBioQuotes(75.4200,'MYR/TON','TON','POME (SBH)','Thailand');
        bQuotes.add(bQ2);
        RE_Bio_Quotes__c bQ3 = RE_UtilityClass.getBioQuotes(75.4200,'USD/BBL','BBL','Green Palm (SBH)','Thailand');  //'MYR/TON',
        bQuotes.add(bQ3);
        */
        //Depot Pricing Backbone data
        List<RE_Depot_Pricing_Backbone__c> dPricing = new List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dP = RE_UtilityClass.createDPB('Thailand','Chongnonsri','Kerosene','THB/LTR');
        RE_Depot_Pricing_Backbone__c dP1 = RE_UtilityClass.createDPB('Thailand','Chongnonsri','Kerosene','THB/LTR');
        dPricing.add(dP);
        dPricing.add(dP1);
        dp.RE_TH_HCV_Quote1__c = 'SING FOB KERO';
        dp.RE_TH_HCV_Quote2__c = null;
        
        update dp;
        System.debug('dP   '+dP);
      update product;         
        test.startTest();     
        RE_FX_Rates__c FXrate3 = RE_UtilityClass.createFXRecords('THB/USD',1.3629,'USD','THB','Thailand','D');
        RE_MalayasiaOutputController.jobExecute('Thailand Output'); 
        //RE_MalayasiaOutputController.AMVjobExecute();
        test.stopTest();        
    }
}