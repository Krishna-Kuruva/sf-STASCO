@isTest
public class RE_MiddayPricingControllerTest { 

    @testSetup
    public static void testSetupData(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Revolution East (Platform)'];
        User u = new User();
        u.Alias = 'myTester';
        u.Email = 'revolutioneasttest@shelltest.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName        = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey    = 'en_US';
        u.ProfileId       = p.Id;
        u.TimeZoneSidKey  = 'America/Los_Angeles';
        u.UserName        = 'revolutioneasttest@shelltest.com';
        u.IsActive        = true;
        insert u;
        
        List<PermissionSet> masterPSList = new List<PermissionSet> ();
        List<PermissionSet> reMYPermSets = [SELECT Id FROM PermissionSet WHERE Name LIKE 'RE_MY%' LIMIT 10];
        masterPSList.addAll(reMYPermSets);
        
        List<PermissionSet> reSGPermSets = [SELECT Id FROM PermissionSet WHERE Name LIKE 'RE_SG%' LIMIT 10];
        masterPSList.addAll(reSGPermSets);
        
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment> ();
        for(PermissionSet ps : masterPSList){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId  = u.Id;
            psa.PermissionSetId = ps.Id;
            psaList.add(psa);
        }
        insert psaList;
    }
    
    public static testmethod void testtomiddaypricing(){
        //Fetch Custom Setting Data For Rate
        RE_UtilityClass.fetchRateUnitData();
        
        //Fetch Custom Setting Data For Volume
        RE_UtilityClass.fetchVolumeConversionData();
        
        Country__c createCtry1 = RE_UtilityClass.getCountryCode('Malaysia');
        Country__c createCtry2 = RE_UtilityClass.getCountryCode('Singapore');
        RE_Location__c createLoc1 = RE_UtilityClass.getLocation('Pandan','Pandan','Singapore');
        //Creating Latest Market Quotes data
        List<RE_Market_Quotes__c> quotelist = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.05% S','D');
        createMQ2.RE_Quote_Type__c = 'Settlement';
        quotelist.add(createMQ2);
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(33.6560,'USD/BBL','BBL','Gasoil 0.001% S','D');
        createMQ3.RE_Quote_Type__c = 'Settlement';
        createMQ3.RE_Temperature_Gain_USD_BB6__c = 0.44;
        RE_Market_Quotes__c createMQ4  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','Gasoil 0.25% S','D');
        createMQ4.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ5  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','Gasoil 0.001% Premium','D');
        createMQ5.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ6  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Kero','D');
        createMQ6.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ7  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','MOGAS 97','D');
        createMQ7.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ8  = RE_UtilityClass.getMarketQuotes(27.4658,'USD/BBL','BBL','MOGAS 95','D');
        createMQ8.RE_Quote_Type__c = 'Settlement';
        RE_Market_Quotes__c createMQ9  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Kero Premium','D');
        createMQ9.RE_Quote_Type__c = 'Market Premium';
        RE_Market_Quotes__c createMQ10  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','Distillation Discount','D');
        createMQ10.RE_Quote_Type__c = 'Assessed Premium';
        RE_Market_Quotes__c createMQ11  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','FuelSave95 Premium','D');
        createMQ11.RE_Quote_Type__c = 'Assessed Premium';
        RE_Market_Quotes__c createMQ12  = RE_UtilityClass.getMarketQuotes(17.4658,'USD/BBL','BBL','FuelSave98 Premium','D');
        createMQ12.RE_Quote_Type__c = 'Assessed Premium';
        quotelist.add(createMQ3);
        quotelist.add(createMQ4);
        quotelist.add(createMQ5);
        quotelist.add(createMQ6);
        quotelist.add(createMQ7);
        quotelist.add(createMQ8);
        quotelist.add(createMQ9);
        quotelist.add(createMQ10);
        quotelist.add(createMQ11);
        quotelist.add(createMQ12);
        update quotelist;
        List<RE_FX_Rates__c> fxratelist = new List<RE_FX_Rates__c>();
        RE_FX_Rates__c sFXRates= new RE_FX_Rates__c(RE_Forex_Name__c='MYR CTS/USD',
                                                    RE_Forex_Rate__c=135.235,
                                                    RE_Base_Unit__c='USD',
                                                    RE_Conversion_Unit__c='MYR CTS',
                                                    RE_Pricing_Date__c=System.now()+1,
                                                    RE_Trade_Type__c = 'Sell',
                                                    RE_Tracker__c = 'D+1');
        fxratelist.add(sFXRates);
        
        RE_FX_Rates__c sFXRates1= new RE_FX_Rates__c(RE_Forex_Name__c='SGD CTS/USD',
                                                     RE_Forex_Rate__c=135.235,
                                                     RE_Base_Unit__c='USD',
                                                     RE_Conversion_Unit__c='SGD CTS',
                                                     RE_Pricing_Date__c=System.now()-1,
                                                     RE_Trade_Type__c = 'Sell',
                                                     RE_Tracker__c = 'D+1');
        fxratelist.add(sFXRates1);
        RE_FX_Rates__c sFXRates4= new RE_FX_Rates__c(RE_Forex_Name__c='SGD CTS/USD',
                                                     RE_Forex_Rate__c=135.235,
                                                     RE_Base_Unit__c='USD',
                                                     RE_Conversion_Unit__c='SGD CTS',
                                                     RE_Pricing_Date__c=System.now()-2,
                                                     RE_Trade_Type__c = 'Sell',
                                                     RE_Tracker__c = 'D+1');
        fxratelist.add(sFXRates4);
        RE_FX_Rates__c sFXRates2 = new RE_FX_Rates__c(RE_Forex_Name__c='SGD/USD',
                                                      RE_Forex_Rate__c=1.235,
                                                      RE_Base_Unit__c='USD',
                                                      RE_Conversion_Unit__c='SGD',
                                                      RE_Pricing_Date__c=System.now()-1,
                                                      RE_Trade_Type__c = 'Sell',
                                                      RE_Tracker__c = 'D+1');
        fxratelist.add(sFXRates2) ;
        RE_FX_Rates__c sFXRates3 = new RE_FX_Rates__c(RE_Forex_Name__c='SGD/USD',
                                                      RE_Forex_Rate__c=1.235,
                                                      RE_Base_Unit__c='USD',
                                                      RE_Conversion_Unit__c='SGD',
                                                      RE_Pricing_Date__c=System.now()-2,
                                                      RE_Trade_Type__c = 'Sell',
                                                      RE_Tracker__c = 'D+1');
        fxratelist.add(sFXRates3) ; 
        insert fxratelist;
        
        RE_FX_Rates__c fX1 = RE_UtilityClass.createFXRecords('MYR CTS/USD',136.2900,'USD','MYR CTS','Malaysia','D'); 
        RE_FX_Rates__c fX2 = RE_UtilityClass.createFXRecords('MYR/USD',1.3629,'USD','MYR','Malaysia','D');
        RE_FX_Rates__c fX3 = RE_UtilityClass.createFXRecords('SGD CTS/USD',136.2900,'USD','SGD CTS','Singapore','D'); 
        RE_FX_Rates__c fX4 = RE_UtilityClass.createFXRecords('SGD/USD',1.3629,'USD','SGD','Singapore','D');
        Test.startTest();
        RE_Product__c createProd1 = RE_UtilityClass.getProduct('Vpower','Singapore','USD CTS/LTR');
        RE_Product__c createProd2 = RE_UtilityClass.getProduct('Kero','Singapore','USD CTS/LTR');
        RE_Product__c createProd3 = RE_UtilityClass.getProduct('IGO 10ppm','Singapore','USD CTS/LTR');
        createProd3.RE_Morning_MC0_Value__c = 4.45;
        createProd3.RE_Midday_MC0_Value__c = 5.6;
        createProd3.RE_Midday_MC0_Valid_From__c = System.today();
        createProd3.RE_Midday_MC0_Valid_To__c = System.today();
        createProd3.RE_Morning_MC0_Valid_To__c = System.today();
        createProd3.RE_Morning_MC0_Valid_From__c = System.today();
        update createProd3;
        RE_Product__c createProd4 = RE_UtilityClass.getProduct('FuelSave95','Singapore','USD CTS/LTR');
        RE_Product__c createProd5 = RE_UtilityClass.getProduct('FuelSave98','Singapore','USD CTS/LTR');
        RE_Product__c createProd6 = RE_UtilityClass.getProduct('MGO 0.1%','Singapore','USD CTS/LTR');
        RE_Product__c createProd7 = RE_UtilityClass.getProduct('MGO 0.5%','Singapore','USD CTS/LTR');
        RE_Product__c createProd8 = RE_UtilityClass.getProduct('Fuelsave Diesel','Singapore','USD CTS/LTR');
        
        
        // Creating Latest Depot Pricing Backbone data for Singapore
        List<RE_Depot_Pricing_Backbone__c> dpb = new List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dpb1 = RE_UtilityClass.createDPB('Singapore','Pandan','Vpower','USD CTS/LTR');
        dpb1.RE_Cost_Price_Adjustment__c = 42.65;
        dpb1.RE_Cost_Price_Adjustment_Unit__c = 'USD CTS/LTR';
        RE_Depot_Pricing_Backbone__c dpb2 = RE_UtilityClass.createDPB('Singapore','Pandan','Kero','USD CTS/LTR');
        dpb2.RE_Cost_Price_Adjustment__c = 25.62;
        dpb2.RE_Cost_Price_Adjustment_Unit__c = 'USD CTS/LTR';
        RE_Depot_Pricing_Backbone__c dpb3 = RE_UtilityClass.createDPB('Singapore','Pandan','IGO 10ppm','USD CTS/LTR');
        dpb3.RE_Cost_Price_Adjustment__c = 25.62;
        dpb3.RE_Cost_Price_Adjustment_Unit__c = 'USD CTS/LTR';
        RE_Depot_Pricing_Backbone__c dpb4 = RE_UtilityClass.createDPB('Singapore','Pandan','FuelSave95','USD CTS/LTR');        
        RE_Depot_Pricing_Backbone__c dpb5 = RE_UtilityClass.createDPB('Singapore','Pandan','FuelSave98','USD CTS/LTR');        
        RE_Depot_Pricing_Backbone__c dpb6 = RE_UtilityClass.createDPB('Singapore','Pandan','Fuelsave Diesel','USD CTS/LTR');
        RE_Depot_Pricing_Backbone__c dpb7 = RE_UtilityClass.createDPB('Singapore','Pandan','MGO 0.1%','USD CTS/LTR');        
        RE_Depot_Pricing_Backbone__c dpb8 = RE_UtilityClass.createDPB('Singapore','Pandan','MGO 0.5%','USD CTS/LTR');
        
        dpb.add(dpb2);
        dpb.add(dpb1);
        dpb.add(dpb3);
        update dpb;
        
        List<RE_Market_Quotes__c> marlist = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c sMarketQuote = new RE_Market_Quotes__c(RE_Price__c=212.22,RE_Rate_Unit__c='USD/BBL',RE_Quote_Name__c='IGO 10 ppm',RE_Pricing_Date__c = System.Today(),RE_Quote_Type__c='Forward Swap');
        marlist.add(sMarketQuote);
        RE_Market_Quotes__c sMarketQuote1 = new RE_Market_Quotes__c(RE_Price__c=212.22,RE_Rate_Unit__c='USD/BBL',RE_Quote_Name__c='IGO 10 ppm',RE_Pricing_Date__c = System.Today(),RE_Quote_Type__c='Forward Swap');
        marlist.add(sMarketQuote1);
        insert marlist;

        RE_Midday_Pricing__c miday = new RE_Midday_Pricing__c();
        miday.RE_IsLatest__c    = true;
        miday.RE_Region__c      = 'EM';
        miday.RE_Index__c       = 1;
        insert miday;

        RE_MidDay_Helper__c csRec = new RE_MidDay_Helper__c ();
        csRec.Name  = 'MD-0001';
        csRec.RE_Depot_Name__c  = 'Bukom';
        csRec.RE_Product__c     = 'MOGAS 95';
        csRec.RE_Multiplier__c  = 1;
        csRec.RE_Index__c       = 15;
        csRec.RE_MidDayOutput__c= 'BL';
        insert csRec;

        // List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn1 = RE_UtilityClass.getLocation('Bukom','BK','Malaysia');
        RE_Location__c loctn2 = RE_UtilityClass.getLocation('Pasir Gudang','LB','Malaysia');

        RE_Product__c product1 = RE_UtilityClass.getProduct('MOGAS 95','Malaysia','MYR CTS/LTR');

        List<RE_MY_CostPrice__c> mycostList = new List<RE_MY_CostPrice__c>();
        Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        RE_MY_CostPrice__c mycostdata1  = new RE_MY_CostPrice__c(recordtypeid= rectypeId,RE_Depot_Name__c= loctn1.Id, RE_Product_Name__c= product1.Id, RE_IsLatest__c= True,RE_Costprice_Marginal_Cost__c=3.414, RE_Country__c= createCtry1.Id);
        mycostList.add(mycostdata1);
        RE_MY_CostPrice__c mycostdata2  = new RE_MY_CostPrice__c(recordtypeid= rectypeId,RE_Depot_Name__c= loctn2.Id, RE_Product_Name__c= product1.Id, RE_IsLatest__c= True,RE_Costprice_Marginal_Cost__c=7.414, RE_Country__c= createCtry1.Id);
        mycostList.add(mycostdata2);
        insert mycostList;

        RE_MidDayPricingController a = new RE_MidDayPricingController();
        a.finalMidDayOutput();
        List<RE_Midday_Pricing__c> lstOfMPBL = RE_MidDayPricingController.fetchMidDayOutput('BL');
        RE_MidDayPricingController.updateMiddayRecords(lstOfMPBL);
        RE_MY_Output__c ast = new RE_MY_Output__c();
        ast.RE_Pricing_Date__c = System.Today ();
        ast.RE_IsLatest__c = True; 
        ast.RE_Type__c = 'Singapore Output';
        ast.RE_Job_Run_Count__c = 0;
        ast.RE_Kero_MC__c = 12.22;
        ast.RE_IGO_10ppm_MC__c =13.33;
        ast.RE_Vpower_MC__c = 11.11;
        ast.RE_FuelSave95_MC__c = 9;
        ast.RE_FuelSave98_MC__c = 8;
        ast.RE_Fuelsave_Diesel_MC__c = 7;
        ast.RE_MGO_0_1_MC__c = 5;
        ast.RE_MGO_0_5_MC__c = 5;
        insert ast;
        RE_MalayasiaOutputController.jobExecute('SG Midday Output'); 
        //RE_UtilityClass.getCostPrice(createProd3.Id);  
        //RE_MalayasiaOutputController.jobExecute('Singapore Output'); 
        Test.stopTest();
        createProd3.RE_Morning_MC0_Value__c= 2;
        createProd3.RE_Morning_MC0_Valid_From__c= System.Today();
        createProd3.RE_Morning_MC0_Valid_To__c = System.today();
        createProd3.RE_Midday_MC0_Value__c= 1;
        createProd3.RE_Midday_MC0_Valid_From__c= System.Today();
        createProd3.RE_Midday_MC0_Valid_To__c= System.Today();
        update createProd3;
        
        //Coverage of RE_SingaporeOutputController methods is moved to RE_SG_CostCalculationTest
    }

    @isTest
    public static void testMethods2(){
        User testUser = [SELECT Id, Name, Email FROM User WHERE UserName ='revolutioneasttest@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_MidDay_ActualSource__c csRec = new RE_MidDay_ActualSource__c ();
            csRec.Name = 'Bintulu E5M GO B7';
            csRec.RE_Actual_Difference__c = 12;
            csRec.RE_Actual_Product__c = 'GO B7';
            csRec.RE_Actual_Source__c = 'Bintulu';
            csRec.RE_Target_Product__c = 'E5M GO B7';
            csRec.RE_Target_Source__c = 'Bintulu';
            insert csRec;
            List<RE_MidDay_ActualSource__c> lstOfCS = RE_MidDayPricingController.fetchActSrcData();
            System.assertEquals(lstOfCS.size(), 1, 'Success!');

            List<RE_Market_Quotes__c> marlist = new List<RE_Market_Quotes__c>();
            RE_Market_Quotes__c sMarketQuote = new RE_Market_Quotes__c(RE_Price__c=212.22,RE_Rate_Unit__c='USD/BBL',RE_Quote_Name__c='IGO 10 ppm',RE_Pricing_Date__c = System.Today(),RE_Quote_Type__c='Forward Swap');
            marlist.add(sMarketQuote);
            RE_Market_Quotes__c sMarketQuote1 = new RE_Market_Quotes__c(RE_Price__c=212.22,RE_Rate_Unit__c='USD/BBL',RE_Quote_Name__c='IGO 10 ppm',RE_Pricing_Date__c = System.Today(),RE_Quote_Type__c='Forward Swap');
            marlist.add(sMarketQuote1);
            // insert marlist;

            RE_MidDayPricingController.inputmarketRecords(marlist);

            Country__c malaysiaCountry = RE_UtilityClass.getCountryCode('Malaysia');

            RE_Location__c loctn1 = RE_UtilityClass.getLocation('Bukom','BK','Malaysia');
            RE_Product__c product1 = RE_UtilityClass.getProduct('MOGAS 95','Malaysia','MYR CTS/LTR');
            
            List<RE_MY_CostPrice__c> mycostList = new List<RE_MY_CostPrice__c>();
            Id rectypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
            RE_MY_CostPrice__c mycostdata1  = new RE_MY_CostPrice__c(recordtypeid= rectypeId,RE_Depot_Name__c= loctn1.Id, RE_Product_Name__c= product1.Id, RE_IsLatest__c= True,RE_Costprice_Marginal_Cost__c=3.414, RE_Country__c= malaysiaCountry.Id);
            mycostList.add(mycostdata1);
            RE_MY_CostPrice__c mycostdata2  = new RE_MY_CostPrice__c(recordtypeid= rectypeId,RE_Depot_Name__c= loctn1.Id, RE_Product_Name__c= product1.Id, RE_IsLatest__c= True,RE_Costprice_Marginal_Cost__c=7.414, RE_Country__c= malaysiaCountry.Id);
            mycostList.add(mycostdata2);
            insert mycostList;

            RE_Midday_Pricing__c miday = new RE_Midday_Pricing__c();
            miday.RE_IsLatest__c    = true;
            miday.RE_Region__c      = 'EM';
            miday.RE_Index__c       = 1;
            miday.RE_Depot_Name__c  = loctn1.Id;
            miday.RE_Product_Name__c= product1.Id;
            insert miday;
            RE_MidDayPricingController.recalculateMidDayOutput();
        }
    }
}