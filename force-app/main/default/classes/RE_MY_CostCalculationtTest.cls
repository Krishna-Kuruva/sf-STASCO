@isTest(SeeAllData = False) 
public class RE_MY_CostCalculationtTest {
    public static testmethod void testUtility()    
    {  
        //Country Data 
        List<Country__c> count = new List<Country__c>();
        Country__c country = RE_UtilityClass.getCountryCode('Malaysia');
        count.add(country);
         
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn = RE_UtilityClass.getSabahLocation('Labuan','LB','Malaysia');
        location.add(loctn);
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product = RE_UtilityClass.getProduct('Gasoil B7 0.05% S','Malaysia','MYR CTS/LTR');
        prod.add(product);
        
        //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();
        
        //Market Quote Data
        List<RE_Market_Quotes__c> mQuotes = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(23.6560,'USD/BBL','BBL','MID RON PREMIUM');
        createMQ1.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.05% S');
        createMQ2.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(54.4658,'USD/BBL','BBL','Kero Premium');
        createMQ3.RE_Quote_Type__c = 'Assessed Premium';       
        mQuotes.add(createMQ1);
        mQuotes.add(createMQ2);
        mQuotes.add(createMQ3);       
		update mQuotes;
        
        //Forex Rate Data
        List<RE_FX_Rates__c> fRates = new List<RE_FX_Rates__c>();
        RE_FX_Rates__c FXrate2 = RE_UtilityClass.createFXRecordsYday('MYR/USD',4.3720,'USD','MYR','Malaysia');
        RE_FX_Rates__c FXrate1 = RE_UtilityClass.createFXRecordsYday('MYR CTS/USD',437.20,'USD','MYR CTS','Malaysia');        
        RE_FX_Rates__c FXrate3 = RE_UtilityClass.createFXRecords('MYR/USD',4.3720,'USD','MYR','Malaysia','D');
        RE_FX_Rates__c FXrate4 = RE_UtilityClass.createFXRecords('MYR CTS/USD',437.20,'USD','MYR CTS','Malaysia','D');       
        
        //Bio Quote Data
        List<RE_Bio_Quotes__c> bQuotes = new List<RE_Bio_Quotes__c>();
        RE_Bio_Quotes__c bQ1 = RE_UtilityClass.getBioQuotes(76.4200,'USD/BBL','BBL','RBDPO','Malaysia');
        bQuotes.add(bQ1); 
        RE_Bio_Quotes__c bQ2 = RE_UtilityClass.getBioQuotes(75.4200,'MYR/TON','TON','POME (SBH)','Malaysia');
        bQuotes.add(bQ2);
        RE_Bio_Quotes__c bQ3 = RE_UtilityClass.getBioQuotes(75.4200,'USD/BBL','BBL','Green Palm (SBH)','Malaysia');  //'MYR/TON',
        bQuotes.add(bQ3);
        
        //Depot Pricing Backbone data
        List<RE_Depot_Pricing_Backbone__c> dPricing = new List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dP = RE_UtilityClass.createDPB('Malaysia','Labuan','Gasoil B7 0.05% S','MYR CTS/LTR');
        dPricing.add(dP);
        
        //Get Malaysia formula metadata
        List<RE_Malaysian_Formula_Table__mdt> myformulalist = RE_UtilityClass.getMFTinput();
        
        //Afternoon indication
        RE_Midday_Pricing__c AftIndication = new RE_Midday_Pricing__c();
        AftIndication.RE_Product__c = 'E5 GO B7';
        AftIndication.RE_Midday_Forecast_Price__c = 0.8;
        insert AftIndication;
        
        test.startTest();        
        RE_MalayasiaOutputController.jobExecute('Malaysia Output');                
        test.stopTest();        
    }
    
    public static testmethod void testUtilityPH(){
        //Country Data
        List<Country__c> count = new List<Country__c>();
        Country__c country = RE_UtilityClass.getCountryCode('Philippines');
        count.add(country);
        
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn = RE_UtilityClass.getLocation('PH NMIF','P11','Philippines');
        RE_Location__c loctn1 = RE_UtilityClass.getLocation('PH Anibong','P12','Philippines');
        location.add(loctn);
        location.add(loctn1);
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product = RE_UtilityClass.getProduct('Kerosene','Philippines','PHP/LTR');
        product.RE_Product_Group__c = 'KERO';
        RE_Product__c product1 = RE_UtilityClass.getProduct('LSFO','Philippines','PHP/LTR');
        product.RE_Product_Group__c = 'KERO';
        prod.add(product);
        prod.add(product1);
        update prod;
        
        //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();
        
        //Market Quote Data
        List<RE_Market_Quotes__c> mQuotes = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(3.6560,'USD/BBL','BBL','Kero Premium','D');
        createMQ1.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(3.6560,'USD/BBL','BBL','Small Lot Premium','D');
        createMQ2.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Kero','D');
        createMQ3.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ4  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','MOGAS 92','D');
        createMQ4.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ5  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.001% S','D');
        createMQ5.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ6  = RE_UtilityClass.getMarketQuotes(357.4658,'USD/TON','TON','Marine FuelOil 180','D');
        createMQ6.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ7  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','ETHANOL','D');
        createMQ7.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ8  = RE_UtilityClass.getMarketQuotes(5.4658,'USD/TON','TON','UCAP RBD CNO','D');
        createMQ8.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ9  = RE_UtilityClass.getMarketQuotes(4.4658,'USD/BBL','BBL','FREIGHT S2P01','D');
        createMQ9.RE_Quote_Type__c = 'Freight';
        mQuotes.add(createMQ1);
        mQuotes.add(createMQ2);
        mQuotes.add(createMQ3);  
        mQuotes.add(createMQ4);
        mQuotes.add(createMQ5);
        mQuotes.add(createMQ6);  
        mQuotes.add(createMQ7);
        mQuotes.add(createMQ8);
        mQuotes.add(createMQ9);  
		update mQuotes;
        
        RE_PH_ExecuteAutomateJob wm2 = new RE_PH_ExecuteAutomateJob();
        wm2.execute(null);
        
        //Forex Rate Data
        List<RE_FX_Rates__c> fRates = new List<RE_FX_Rates__c>();
        RE_FX_Rates__c FXrate2 = RE_UtilityClass.createFXRecordsYday('PHP/USD',43.720,'USD','PHP','Philippines');
        RE_FX_Rates__c FXrate3 = RE_UtilityClass.createFXRecords('PHP/USD',4.3720,'USD','PHP','Philippines','D');
        RE_FX_Rates__c FXrate4 = RE_UtilityClass.createFXRecords('PHP/USD',467.32,'USD','SGD CTS','Philippines','D');
        
        //Depot Pricing Backbone data
        List<RE_Depot_Pricing_Backbone__c> dPricing1 = new List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dP4 = RE_UtilityClass.createDPBPH('Philippines','PH NMIF','Kerosene','PHP/LTR'); //Blen=50
        dp4.RE_Final_Price_Unit__c = 'PHP/LTR';
        dp4.RE_TH_HCV_Quote1__c = 'Kero';
        dp4.RE_PH_BIO_2__c = 'ETHANOL';
        dp4.RE_PH_BIO_3__c = 'UCAP RBD CNO';
        dp4.RE_TH_HCV_Quote1_Percent__c = 100;
        dp4.RE_Primary_Transport_Cost__c = 15.5;
        dp4.RE_Primary_Transport_Unit__c = 'PHP/LTR';
        dp4.RE_Insurance_Percentage__c = 100;
        dp4.RE_PH_Blend_Percentage__c = 50;
        dp4.RE_PH_Premium__c = 'Kero Premium';
        dp4.RE_Fixed_Premium__c = 65;
        dp4.RE_Primary_Transport_Cost__c = 15.5;
        dp4.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
        dp4.RE_PH_Bio_Percent__c = 100;
        dp4.RE_PH_BIO_Fixed__c = 45;
        dp4.RE_PH_Freight_Shifting_Cost__c = 15.5;
        dp4.RE_PH_Demurrage__c = 15.5;
        dp4.RE_PH_FLC_Service_Fee__c = 28.23;
        dp4.RE_PH_PT_Percentage__c = 50;
        dp4.RE_PH_MISC_Brokerage_Fee__c = 30;
        dp4.RE_PH_MISC_Hosehandling_Cost__c = 65;
        dp4.RE_PH_MISC_Port_Charges__c = 15.5;
        dp4.RE_PH_MISC_PQ_Cost__c = 23.34;
        dp4.RE_PH_MISC_Shifting_Cost__c = 10.34;
        dp4.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
        dp4.RE_PH_Terminal_Cost__c = 65;
        dp4.RE_PH_Wharfage_Cost__c = 15.5;
        dp4.RE_PH_Fuel_Marking_Factor__c = 10;
        dp4.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
        dp4.RE_PH_Ocean_Cost__c = 15.5;
        dp4.RE_PH_S_H__c = 30;
        dp4.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
        dp4.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
        dp4.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
        dp4.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
        dp4.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
        System.debug('dPricing1--4'+dPricing1);
        System.debug('dp4--'+dp4.Id);
        dPricing1.add(dp4);
        
        RE_Depot_Pricing_Backbone__c dP2 = new RE_Depot_Pricing_Backbone__c();
        dP2 = RE_UtilityClass.createDPBPH('Philippines','PH Anibong','LSFO','PHP/LTR');//Blen=100
        dp2.RE_Final_Price_Unit__c = 'PHP/LTR';
        dp2.RE_Depot_Name__c = null;
        dp2.RE_TH_HCV_Quote1__c = 'Kero';
        dp2.RE_TH_HCV_Quote1_Percent__c = 100;
        dp2.RE_Primary_Transport_Cost__c = 15.5;
        dp2.RE_Primary_Transport_Unit__c = 'PHP/LTR';
        dp2.RE_Insurance_Percentage__c = 100;
        dp2.RE_PH_Blend_Percentage__c = 50;
        dp2.RE_PH_Premium__c = 'Kero Premium';
        dp2.RE_Fixed_Premium__c = 65;
        dp2.RE_Primary_Transport_Cost__c = 15.5;
        dp2.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
        dp2.RE_PH_Bio_Percent__c = 100;
        dp2.RE_PH_BIO_Fixed__c = 45;
        dp2.RE_PH_Freight_Shifting_Cost__c = 15.5;
        dp2.RE_PH_Demurrage__c = 15.5;
        dp2.RE_PH_FLC_Service_Fee__c = 28.23;
        dp2.RE_PH_PT_Percentage__c = 100;
        dp2.RE_PH_MISC_Brokerage_Fee__c = 30;
        dp2.RE_PH_MISC_Hosehandling_Cost__c = 65;
        dp2.RE_PH_MISC_Port_Charges__c = 15.5;
        dp2.RE_PH_MISC_PQ_Cost__c = 23.34;
        dp2.RE_PH_MISC_Shifting_Cost__c = 10.34;
        dp2.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
        dp2.RE_PH_Terminal_Cost__c = 65;
        dp2.RE_PH_Wharfage_Cost__c = 15.5;
        dp2.RE_PH_Fuel_Marking_Factor__c = 10;
        dp2.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
        dp2.RE_PH_Ocean_Cost__c = 15.5;
        dp2.RE_PH_S_H__c = 23.34;
        dp2.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
        dp2.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
        dp2.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
        dp2.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
        dp2.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
        System.debug('dPricing1--2'+dPricing1);
        System.debug('dp2--'+dp2.Id);
        dPricing1.add(dP2);
        
        RE_Depot_Pricing_Backbone__c dP3 = new RE_Depot_Pricing_Backbone__c();
        dP3 = RE_UtilityClass.createDPBPH('Philippines','PH NMIF','Kerosene','PHP/LTR');//Blen=50
        dp3.RE_Final_Price_Unit__c = 'PHP/LTR';
        dp3.RE_TH_HCV_Quote1__c = 'Kero';
        dp3.RE_TH_HCV_Quote1_Percent__c = 100;
        dp3.RE_Primary_Transport_Cost__c = 15.5;
        dp3.RE_Primary_Transport_Unit__c = 'PHP/LTR';
        dp3.RE_Insurance_Percentage__c = 100;
        dp3.RE_PH_Blend_Percentage__c = 50;
        dp3.RE_PH_Premium__c = 'Kero Premium';
        dp3.RE_Fixed_Premium__c = 65;
        dp3.RE_Primary_Transport_Cost__c = 15.5;
        dp3.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
        dp3.RE_PH_Bio_Percent__c = 100;
        dp3.RE_PH_BIO_Fixed__c = 45;
        dp3.RE_PH_Freight_Shifting_Cost__c = 15.5;
        dp3.RE_PH_Demurrage__c = 15.5;
        dp3.RE_PH_FLC_Service_Fee__c = 28.23;
        dp3.RE_PH_PT_Percentage__c = 50;
        dp3.RE_PH_MISC_Brokerage_Fee__c = 30;
        dp3.RE_PH_MISC_Hosehandling_Cost__c = 65;
        dp3.RE_PH_MISC_Port_Charges__c = 15.5;
        dp3.RE_PH_MISC_PQ_Cost__c = 23.34;
        dp3.RE_PH_MISC_Shifting_Cost__c = 10.34;
        dp3.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
        dp3.RE_PH_Terminal_Cost__c = 65;
        dp3.RE_PH_Wharfage_Cost__c = 15.5;
        dp3.RE_PH_Fuel_Marking_Factor__c = 10;
        dp3.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
        dp3.RE_PH_Ocean_Cost__c = 15.5;
        dp3.RE_PH_S_H__c = 23.34;
        dp3.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
        dp3.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
        dp3.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
        dp3.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
        dp3.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
        System.debug('dPricing1--3'+dPricing1);
        System.debug('dp3--'+dp3.Id);
        dPricing1.add(dP3);
        
        System.debug('dPricing1--'+dPricing1);
        update dPricing1;
        
        test.startTest();        
        RE_PH_ExecuteAutomateJob exajb = new RE_PH_ExecuteAutomateJob();
        exajb.execute(null);         
          
        RE_PH_WeekMonthScheduler wm1 = new RE_PH_WeekMonthScheduler();
        wm1.execute(null);
        test.stopTest();  
        RE_PH_OutputController.getInitParameterDetails(UserInfo.getUserId());
        
    }
}