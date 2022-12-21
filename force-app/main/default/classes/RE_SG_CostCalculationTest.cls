@isTest
public class RE_SG_CostCalculationTest{
    
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
    
    // public static testmethod void TestUtility(){ 
    //     //Fetch Custom Setting Data For Rate 
    //     RE_UtilityClass.fetchRateUnitData();
        
    //     //Fetch Custom Setting Data For Volume
    //     RE_UtilityClass.fetchVolumeConversionData();
        
    //     //Creating Country data
    //     List<Country__c> sCountry = new List<Country__c>();
    //     Country__c createCtry1 = RE_UtilityClass.getCountryCode('Singapore');
    //     sCountry.add(createCtry1);
        
    //     //Creation of Location Data
    //     List<RE_Location__c> sLocation = new List<RE_Location__c>();
    //     RE_Location__c createLoc1 = RE_UtilityClass.getLocation('Pandan','Pandan','Singapore');
    //     sLocation.add(createLoc1);
        
    //     //Creation of Product Data
    //     List<RE_Product__c> sProduct = new List<RE_Product__c>();
    //     RE_Product__c createProd1 = RE_UtilityClass.getProduct('Vpower','Singapore','USD CTS/LTR');
    //     RE_Product__c createProd2 = RE_UtilityClass.getProduct('Kero','Singapore','USD CTS/LTR');
    //     RE_Product__c createProd3 = RE_UtilityClass.getProduct('IGO 10ppm','Singapore','USD CTS/LTR');
    //     sProduct.add(createProd1);
    //     sProduct.add(createProd2);
    //     sProduct.add(createProd3);
        
    //     //Creating Latest Market Quotes data
    //     List<RE_Market_Quotes__c> sMarketQuotes = new List<RE_Market_Quotes__c>();
    //     RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(23.6560,'USD/BBL','BBL','Gasoil 0.001% Premium','D');
    //     RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.001% S','D');
    //     RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Distillation Discount','D');
    //     RE_Market_Quotes__c createMQ4  = RE_UtilityClass.getMarketQuotes(57.4658,'USD/BBL','BBL','Gasoil 0.05% S','D');
    //     createMQ4.RE_Quote_Type__c = 'Settlement';
    //     // createMQ4.RE_Temperature_Gain_USD_BB6__c = 0.0;
    //     createMQ2.RE_Quote_Type__c = 'Settlement';
    //     // createMQ2.RE_Temperature_Gain_USD_BB6__c = 2.8;
    //     createMQ1.RE_Quote_Type__c = 'Market Premium';
    //     // createMQ1.RE_Temperature_Gain_USD_BB6__c = 2.2;
    //     createMQ3.RE_Quote_Type__c = 'Assessed Premium';
    //     // createMQ3.RE_Temperature_Gain_USD_BB6__c = 2.0;
    //     sMarketQuotes.add(createMQ1);
    //     sMarketQuotes.add(createMQ2);
    //     sMarketQuotes.add(createMQ3);
    //     update sMarketQuotes;
    //     // Creating Latest Depot Pricing Backbone data for Singapore
    //     List<RE_Depot_Pricing_Backbone__c> dpb = new List<RE_Depot_Pricing_Backbone__c>();
    //     RE_Depot_Pricing_Backbone__c dpb1 = RE_UtilityClass.createDPB('Singapore','Pandan','Vpower','USD CTS/LTR');
    //     dpb1.RE_Cost_Price_Adjustment__c = 42.65;
    //     dpb1.RE_Fixed_Premium__c = 0.98;
    //     dpb1.RE_Cost_Price_Adjustment_Unit__c = 'USD CTS/LTR';
    //     update dpb1;
    //     RE_Depot_Pricing_Backbone__c dpb2 = RE_UtilityClass.createDPB('Singapore','Pandan','Kero','USD CTS/LTR');
    //     dpb2.RE_Cost_Price_Adjustment__c = 25.62;
    //     dpb2.RE_Cost_Price_Adjustment_Unit__c = 'USD CTS/LTR';
    //     dpb2.RE_Fixed_Premium__c = 0.98;
    //     update dpb2;
    //     RE_Depot_Pricing_Backbone__c dpb3 = RE_UtilityClass.createDPB('Singapore','Pandan','IGO 10ppm','USD CTS/LTR');
    //     dpb3.RE_Cost_Price_Adjustment__c = 25.62;
    //     dpb3.RE_Cost_Price_Adjustment_Unit__c = 'USD CTS/LTR';
    //     dpb3.RE_Fixed_Premium__c = 0.98;
    //     update dpb3;
    //     dpb.add(dpb2);
    //     dpb.add(dpb1);
        
    //     //Creating Singapore formula data from metadata
    //     List<RE_SG_Cost_Price_Manager__mdt> sgcostpricelist = RE_UtilityClass.fetchSingaporeformulaData();
        
    //     //Fetch Forex rate data
    //     List<RE_FX_Rates__c> sFXrate = new List<RE_FX_Rates__c>();
    //     RE_FX_Rates__c fX1 = RE_UtilityClass.createFXRecords('SGD CTS/USD',136.2900,'USD','SGD CTS','Singapore'); 
    //     RE_FX_Rates__c fX2 = RE_UtilityClass.createFXRecords('SGD/USD',1.3629,'USD','SGD','Singapore'); 
    //     RE_FX_Rates__c fX3 = RE_UtilityClass.createFXRecordsYday('SGD CTS/USD',136.2900,'USD','SGD CTS','Singapore'); 
    //     RE_FX_Rates__c fX4 = RE_UtilityClass.createFXRecordsYday('SGD/USD',1.3629,'USD','SGD','Singapore'); 
    //     sFXrate.add(fX1);
    //     sFXrate.add(fX2);
    //     RE_MarketQuotesTriggerHelper.onAfterTriggerHelper(sMarketQuotes,null,null);
    //     Test.startTest();
    //     RE_Sales_Tax__c st = new RE_Sales_Tax__c();
    //     st.RE_Publish_Date__c   = System.Today();
    //     st.RE_Product_Type__c   = 'IGO B10';
    //     st.RE_Tax_Unit__c       = 'MYR CTS/LTR';
    //     st.RE_Region__c         = 'Peninsular;Sabah;Sarawak';
    //     st.RE_Valid_From__c     = System.Today().addDays(-10);
    //     st.RE_Valid_To__c       = System.today().addDays(10);
    //     insert st;
    //     RE_MalayasiaOutputController.jobExecute('Singapore Output');        
    //     RE_Job_Run_Audit__c jra = [SELECT Id,RE_Job_Type__c,RE_Job_Run_Count__c  FROM RE_Job_Run_Audit__c WHERE  RE_Job_Type__c = 'Singapore Output' LIMIT 1];
    //     RE_SG_CostCalculation sgCostCalc = new RE_SG_CostCalculation();
    //     sgCostCalc.depotpricinglist = dpb;
    //     sgCostCalc.sgformulalist    = sgcostpricelist;
    //     sgCostCalc.productlist    = sProduct;
    //     RE_SOQLController soqldata = new RE_SOQLController(); 
    //     Map<String,Double> mao=soqldata.fetchLatestFxData();
    //     sgCostCalc.lineItemsCalculation(jra);
    //     //MarkUpCreditChargeCalculation markUpCalc = new MarkUpCreditChargeCalculation();
    //     RE_SingaporeOutputController.getSingProdData();
        
    //     RE_SingaporeOutputController.getInitParameterDetails(System.UserInfo.getUserId());
        
    //     RE_SingaporeOutputController.FxDataWrapper fx = new RE_SingaporeOutputController.FxDataWrapper();
    //     RE_SingaporeOutputController.InitialDetailsWrapper init = new RE_SingaporeOutputController.InitialDetailsWrapper();
    //     //RE_SingaporeOutputController.marginalaspirwrap masp  = new RE_SingaporeOutputController.marginalaspirwrap();
    //     RE_SingaporeOutputController.mcldcWrap mcdata = new RE_SingaporeOutputController.mcldcWrap();
    //     RE_SingaporeOutputController.MOPSDataWrapper mopsd = new RE_SingaporeOutputController.MOPSDataWrapper();
    //     Test.stopTest();
    //     createProd3.RE_Morning_MC0_Value__c= 2;
    //     createProd3.RE_Morning_MC0_Valid_From__c= System.Today();
    //     createProd3.RE_Morning_MC0_Valid_To__c = System.today();
    //     createProd3.RE_Midday_MC0_Value__c= 1;
    //     createProd3.RE_Midday_MC0_Valid_From__c= System.Today();
    //     createProd3.RE_Midday_MC0_Valid_To__c= System.Today();
    //     update createProd3;
    //     RE_SingaporeOutputController.getSingOutput('Singapore Output');
    // }
    
    @isTest
    public static void testRESingaporeOutputController(){
        User testUser = [SELECT Id, Name, Email FROM User WHERE UserName ='revolutioneasttest@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
            reMyOp1.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp1.RE_Region__c='Peninsular';
            reMyOp1.RE_Job_Run_Count__c = 1;
            reMyOp1.RE_Type__c  = 'Singapore Output';
            reMyOp1.RE_Depot_Name__c    = 'Pandan';
            reMyOp1.RE_Pricing_Date__c  = System.today();
            insert reMyOp1;
            
            Integer maxRunCount = RE_SingaporeOutputController.maxRunCountMethod('Singapore Output');
            System.assertEquals(1, reMyOp1.RE_Job_Run_Count__c, 'Success');
            
            RE_SingaporeOutputController.jobExecute('Singapore');
            
            RE_Job_Run_Audit__c jra1 =new RE_Job_Run_Audit__c();
            jra1.RE_Run_Type__c = 'Manual';
            jra1.RE_Job_Type__c = 'Singapore Output';
            jra1.RE_User__c     = UserInfo.getUserId();
            jra1.RE_Run_Time__c = DateTime.now();
            jra1.RE_Job_Run_Count__c    = 0;
            jra1.RE_IsSuccess__c        = true;
            jra1.RE_Job_Status__c       = 'Processing';
            insert jra1;
            
            // getFxData() >> This method will be covered through getInitParameterDetails
            // getMobileMOPSData() >> This method will be covered through getInitParameterDetails
            // getUserInfo() >> This method will be covered through getInitParameterDetails
            // lastJobRun() >> This method will be covered through getInitParameterDetails
            // getSingOutput(String type) >> This method will be covered through getInitParameterDetails
            
            Country__c singaporeCountry = RE_UtilityClass.getCountryCode('Singapore');
            
            //Creating RE_FX_Rates__c records
            RE_FX_Rates__c fxRate1 = RE_UtilityClass.createFXRecordsYday('SGD/USD',1.4026,'USD','SGD',singaporeCountry.Name);
            fxRate1.RE_Trade_Type__c    = 'Exchange Rate';
            update fxRate1;
            RE_FX_Rates__c fxRate2 = RE_UtilityClass.createFXRecordsYday('SGD/USD',1.4025,'USD','SGD',singaporeCountry.Name);
            fxRate2.RE_Trade_Type__c    = 'Sell';
            update fxRate2;
            RE_FX_Rates__c fxRate3 = RE_UtilityClass.createFXRecords('SGD/USD',1.4027,'USD','SGD',singaporeCountry.Name,'D');
            fxRate3.RE_Trade_Type__c    = 'Exchange Rate';
            update fxRate3;
            RE_FX_Rates__c fxRate4 = RE_UtilityClass.createFXRecords('SGD/USD',1.4028,'USD','SGD',singaporeCountry.Name,'D');
            fxRate4.RE_Trade_Type__c    = 'Sell';
            update fxRate4;
            
            //Creating Latest Market Quotes data
            List<RE_Market_Quotes__c> lstOfMarketQuotes = new List<RE_Market_Quotes__c>();
            RE_Market_Quotes__c createMQ1 = RE_TestDataFactory.createREMarketQuote(23.6560, 'Gasoil 0.001% S', System.today(), 'D');
            createMQ1.RE_Quote_Type__c  = 'Settlement';
            createMQ1.RE_Temperature_Gain_S_cent_l__c   = 2.03;
            createMQ1.RE_Temperature_Gain_USD_BB6__c    = 2.644;
            lstOfMarketQuotes.add(createMQ1);
            
            RE_Market_Quotes__c createMQ2  = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.05% S', System.today().addDays(-1), 'D-1');
            createMQ2.RE_Quote_Type__c  = 'Market Premium';
            lstOfMarketQuotes.add(createMQ2);
            
            RE_Market_Quotes__c createMQ3  = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.001% Premium', System.today(), 'D');
            createMQ3.RE_Quote_Type__c  = 'Assessed Premium';
            createMQ3.RE_Quote_Name__c  = 'Distillation Discount';
            lstOfMarketQuotes.add(createMQ3);
            
            RE_Market_Quotes__c createMQ4  = RE_TestDataFactory.createREMarketQuote(57.4658, 'Kero', System.today().addDays(-1), 'D-1');
            createMQ4.RE_Quote_Type__c  = 'Assessed Premium';
            createMQ4.RE_Quote_Name__c  = 'Distillation Discount';
            lstOfMarketQuotes.add(createMQ4);
            insert lstOfMarketQuotes;
            
            Id singaporeProdRecTypeId = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByName().get('Singapore').getRecordTypeId();
            Id singaporeLocRecTypeId = Schema.SObjectType.RE_Location__c.getRecordTypeInfosByName().get('Singapore').getRecordTypeId();
            
            List<RE_Product__c> lstOfProd = new List<RE_Product__c> ();
            RE_Product__c prod1 = RE_TestDataFactory.createREProduct('MGO 0.1%', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod1);
            
            RE_Product__c prod2 = RE_TestDataFactory.createREProduct('Kero', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod2);
            RE_Product__c prod3 = RE_TestDataFactory.createREProduct('MGO 0.5%', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod3);
            RE_Product__c prod4 = RE_TestDataFactory.createREProduct('Fuelsave Diesel', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod4);
            RE_Product__c prod5 = RE_TestDataFactory.createREProduct('FuelSave95', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod5);
            RE_Product__c prod6 = RE_TestDataFactory.createREProduct('Vpower', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod6);
            RE_Product__c prod7 = RE_TestDataFactory.createREProduct('FuelSave98', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod7);
            RE_Product__c prod8 = RE_TestDataFactory.createREProduct('IGO 10ppm', singaporeCountry.Id, singaporeProdRecTypeId);
            lstOfProd.add(prod8);
            insert lstOfProd;
            
            List<RE_SG_CostPrice__c> lstSgcp = new List<RE_SG_CostPrice__c> ();
            Date todaysDate = System.today();
            RE_SG_CostPrice__c sgcp1 = RE_TestDataFactory.createRESGCostPrice(true, System.now());
            sgcp1.RE_IsMidday__c        = false;
            sgcp1.RE_Product_Name__c    = prod1.Id;
            lstSgcp.add(sgcp1);
            
            RE_SG_CostPrice__c sgcp2 = RE_TestDataFactory.createRESGCostPrice(true, System.now());
            sgcp2.RE_IsMidday__c        = true;
            sgcp2.RE_Product_Name__c    = prod1.Id;
            lstSgcp.add(sgcp2);
            
            RE_SG_CostPrice__c sgcp3 = RE_TestDataFactory.createRESGCostPrice(true, System.now());
            sgcp3.RE_IsMidday__c        = false;
            sgcp3.RE_Product_Name__c    = prod8.Id;
            sgcp3.RE_MC0_Diff__c        = 152.96;
            sgcp3.RE_FX_Marginal_Cost__c= 116.89;
            lstSgcp.add(sgcp3);
            
            insert lstSgcp;
            
            RE_MY_Output__c op1 = RE_TestDataFactory.createREMyOutput('Sabah', 1, 'Singapore Output', 'Bintulu', true, Date.newInstance(todaysDate.year(), todaysDate.month(), todaysDate.day()));
            insert op1;
            
            System.debug('During SG Midday Output');
            RE_SingaporeOutputController.getSingOutput('SG Midday Output');
            System.debug('After SG Midday Output');
            RE_SingaporeOutputController.getInitParameterDetails(UserInfo.getUserId());
            RE_SingaporeOutputController.getInitParameterDetailsMobile(UserInfo.getUserId());
            
            RE_SingaporeOutputController.getSingProdData();
            
            List<RE_Market_Quotes__c> lstOfMidayMQs = new List<RE_Market_Quotes__c> ();
            RE_Market_Quotes__c midayMQ1 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.001% S', Date.today(), 'D');
            midayMQ1.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ1);
            
            RE_Market_Quotes__c midayMQ2 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.001% Premium', Date.today(), 'D');
            midayMQ2.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ2);
            
            RE_Market_Quotes__c midayMQ3 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.05% S', Date.today(), 'D');
            midayMQ3.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ3);
            
            RE_Market_Quotes__c midayMQ4 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Kero', Date.today(), 'D');
            midayMQ4.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ4);
            
            RE_Market_Quotes__c midayMQ5 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Kero Premium', Date.today(), 'D');
            midayMQ5.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ5);
            
            RE_Market_Quotes__c midayMQ6 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.25% S', Date.today(), 'D');
            midayMQ6.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ6);
            
            RE_Market_Quotes__c midayMQ7 = RE_TestDataFactory.createREMarketQuote(57.4658, 'MOGAS 95', Date.today(), 'D');
            midayMQ7.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ7);
            
            RE_Market_Quotes__c midayMQ8 = RE_TestDataFactory.createREMarketQuote(57.4658, 'MOGAS 97', Date.today(), 'D');
            midayMQ8.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ8);

            RE_Market_Quotes__c midayMQ9 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Distillation Discount', Date.today(), 'D');
            midayMQ9.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ9);
            
            RE_Market_Quotes__c midayMQ10 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.005% S', Date.today(), 'D');
            midayMQ10.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ10);
            insert lstOfMidayMQs;
            
            RE_SingaporeOutputController.fetchMarketQuoteMidday();
            RE_SingaporeOutputController.fetchMiddayTemperatureGain();
            RE_SingaporeOutputController.updateMiddayRecords(lstOfMidayMQs);
            
            RE_SingaporeOutputController.fetchmiddaydata();
            
            List<RE_Margin_Aspiration__c> lstRMA = new List<RE_Margin_Aspiration__c> ();
            RE_Margin_Aspiration__c mAsp1 = new RE_Margin_Aspiration__c ();
            mAsp1.RE_IsMidday__c    = true;
            mAsp1.RE_IsLatest__c    = true;
            lstRMA.add(mAsp1);

            RE_Margin_Aspiration__c mAsp2 = new RE_Margin_Aspiration__c ();
            mAsp2.RE_IsMidday__c    = true;
            mAsp2.RE_IsLatest__c    = true;
            lstRMA.add(mAsp2);
            insert lstRMA;

            Test.setCreatedDate(mAsp2.Id, Datetime.now().addDays(-2));
            
            RE_SingaporeOutputController.createmarginaspirationonTrigger(lstSgcp);
            RE_SingaporeOutputController.marginalspiration(true);
        }
    }

    @isTest
    public static void testUpdateMiddayRecords2(){
        User testUser = [SELECT Id, Name, Email FROM User WHERE UserName ='revolutioneasttest@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            Date todaysDate = Date.today();
            RE_MY_Output__c op1 = RE_TestDataFactory.createREMyOutput('Sabah', 1, 'SG Midday Output', 'Bintulu', true, Date.newInstance(todaysDate.year(), todaysDate.month(), todaysDate.day()));
            insert op1;
            
            RE_SingaporeOutputController.fetchmiddaydata();

            List<RE_Market_Quotes__c> lstOfMidayMQs = new List<RE_Market_Quotes__c> ();
            RE_Market_Quotes__c midayMQ2 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Gasoil 0.001% Premium', Date.today(), 'D');
            midayMQ2.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ2);

            RE_SingaporeOutputController.updateMiddayRecords(lstOfMidayMQs);

            RE_Margin_Aspiration__c mAsp1 = new RE_Margin_Aspiration__c ();
            mAsp1.RE_IsMidday__c    = true;
            mAsp1.RE_IsLatest__c    = false;
            insert mAsp1;

            RE_SingaporeOutputController.marginalspiration(true);
        }
    }

    @isTest
    public static void testUpdateMiddayRecords3(){
        User testUser = [SELECT Id, Name, Email FROM User WHERE UserName ='revolutioneasttest@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            List<RE_Market_Quotes__c> lstOfMidayMQs = new List<RE_Market_Quotes__c> ();

            RE_Market_Quotes__c midayMQ9 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Distillation Discount', Date.today(), 'D');
            midayMQ9.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ9);

            RE_SingaporeOutputController.updateMiddayRecords(lstOfMidayMQs);
        }
    }

    @isTest
    public static void testUpdateMiddayRecords4(){
        User testUser = [SELECT Id, Name, Email FROM User WHERE UserName ='revolutioneasttest@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            List<RE_Market_Quotes__c> lstOfMidayMQs = new List<RE_Market_Quotes__c> ();

            RE_Market_Quotes__c midayMQ9 = RE_TestDataFactory.createREMarketQuote(57.4658, 'Distillation Discount', Date.today(), 'D');
            midayMQ9.RE_Quote_Type__c   = 'Midday';
            lstOfMidayMQs.add(midayMQ9);

            RE_SingaporeOutputController.updateMiddayRecords(lstOfMidayMQs);
        }
    }
    
    @istest static void lineItemsCalculationTest1(){
        Country__c country_TH = RE_UtilityClass.getCountryCode('Singapore');
        RE_Location__c location1 = RE_UtilityClass.getLocation('TH NMIF','T11',country_TH.Name);
        Id reTHProductRecTypeId = Schema.getGlobalDescribe().get('RE_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Singapore').getRecordTypeId();
        RE_Product__c prod_Kero = RE_TestDataFactory.createREProduct('Kerosene', country_TH.Id, reTHProductRecTypeId);
        RE_Product__c igo_10 = RE_TestDataFactory.createREProduct('IGO 10ppm', country_TH.Id, reTHProductRecTypeId);
        igo_10.RE_Morning_MC0_Value__c=1.5;
        igo_10.RE_Morning_MC0_Valid_From__c = system.today()-10;
        igo_10.RE_Morning_MC0_Valid_To__c = system.today()+10;
        insert new list<RE_Product__c>{prod_Kero,igo_10};
        
        Id reTHDPBRecTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Singapore').getRecordTypeId();
        RE_Depot_Pricing_Backbone__c depotPricing = RE_TestDataFactory.createREDepotPricingBackBone(country_TH.Id, reTHDPBRecTypeId, location1.Id, prod_Kero.Id, System.today().addDays(-10), System.today().addDays(10));
        RE_Depot_Pricing_Backbone__c depotPricing1 = RE_TestDataFactory.createREDepotPricingBackBone(country_TH.Id, reTHDPBRecTypeId, location1.Id, igo_10.Id, System.today().addDays(-10), System.today().addDays(10));
        depotPricing.RE_TH_Oil_Loss_Percent__c = 2;
        insert new list<RE_Depot_Pricing_Backbone__c>{depotPricing,depotPricing1};
        
        RE_SG_CostPrice__c cprice2 = new RE_SG_CostPrice__c(RE_IsLatest__c=true, RE_IsMidday__c=false);
        insert cprice2;
        //RE_UtilityClass.createFXRecords('SGD/USD', 1.406,'USD','SGD','Singapore');
        
        RE_FX_Rates__c fxRate1 = RE_UtilityClass.createFXRecordsYday('SGD/USD',1.4025,'USD','SGD',country_TH.Name);
        fxRate1.RE_Trade_Type__c    = 'Sell';
        update fxRate1;
        RE_FX_Rates__c fxRate2 = RE_UtilityClass.createFXRecords('SGD/USD',1.4028,'USD','SGD',country_TH.Name,'D');
        fxRate2.RE_Trade_Type__c    = 'Sell';
        update fxRate2;
           
        Test.startTest(); 
        	RE_Job_Run_Audit__c jobRunAudit = new RE_Job_Run_Audit__c(RE_Country_Name__c = 'SG',RE_Job_Type__c = 'Singapore Output');
        	insert jobRunAudit;
        	
        	RE_SG_CostCalculation sgc = new RE_SG_CostCalculation();
        	sgc.lineItemsCalculation(jobRunAudit);
        	sgc.errormessage = '';
        	sgc.finalCostingData(jobRunAudit);
        Test.stopTest();
        
        system.assertEquals(3	, [Select count() from RE_SG_CostPrice__c]);
        
    }
    
    @istest static void lineItemsCalculationTest2(){
        Country__c country_TH = RE_UtilityClass.getCountryCode('Singapore');
        RE_Location__c location1 = RE_UtilityClass.getLocation('TH NMIF','T11',country_TH.Name);
        Id reTHProductRecTypeId = Schema.getGlobalDescribe().get('RE_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Singapore').getRecordTypeId();
        RE_Product__c prod_Kero = RE_TestDataFactory.createREProduct('Kerosene', country_TH.Id, reTHProductRecTypeId);
        RE_Product__c igo_10 = RE_TestDataFactory.createREProduct('IGO 10ppm', country_TH.Id, reTHProductRecTypeId);
        igo_10.RE_Midday_MC0_Value__c=1.5;
        igo_10.RE_Midday_MC0_Valid_From__c = system.today()-10;
        igo_10.RE_Midday_MC0_Valid_To__c = system.today()+10;
        insert new list<RE_Product__c>{prod_Kero,igo_10};
        
        Id reTHDPBRecTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Singapore').getRecordTypeId();
        RE_Depot_Pricing_Backbone__c depotPricing = RE_TestDataFactory.createREDepotPricingBackBone(country_TH.Id, reTHDPBRecTypeId, location1.Id, prod_Kero.Id, System.today().addDays(-10), System.today().addDays(10));
        RE_Depot_Pricing_Backbone__c depotPricing1 = RE_TestDataFactory.createREDepotPricingBackBone(country_TH.Id, reTHDPBRecTypeId, location1.Id, igo_10.Id, System.today().addDays(-10), System.today().addDays(10));
        depotPricing.RE_TH_Oil_Loss_Percent__c = 2;
        insert new list<RE_Depot_Pricing_Backbone__c>{depotPricing,depotPricing1};
        
       	RE_SG_CostPrice__c cprice1 = new RE_SG_CostPrice__c(RE_IsLatest__c=true, RE_IsMidday__c=true);
        insert cprice1;
        
        RE_FX_Rates__c fxRate1 = RE_UtilityClass.createFXRecordsYday('SGD/USD',1.4025,'USD','SGD',country_TH.Name);
        fxRate1.RE_Trade_Type__c    = 'Sell';
        update fxRate1;
        RE_FX_Rates__c fxRate2 = RE_UtilityClass.createFXRecords('SGD/USD',1.4028,'USD','SGD',country_TH.Name,'D');
        fxRate2.RE_Trade_Type__c    = 'Sell';
        update fxRate2;
           
        Test.startTest(); 
        	RE_Job_Run_Audit__c jobRunAudit = new RE_Job_Run_Audit__c(RE_Country_Name__c = 'SG',RE_Job_Type__c = 'SG Midday Output');
        	insert jobRunAudit;
        	
        	RE_SG_CostCalculation sgc = new RE_SG_CostCalculation();
        	sgc.lineItemsCalculation(jobRunAudit);
        	sgc.errormessage = '';
        	sgc.finalCostingData(jobRunAudit);
        Test.stopTest();
        
        system.assertEquals(3, [Select count() from RE_SG_CostPrice__c]);
        
    }
}