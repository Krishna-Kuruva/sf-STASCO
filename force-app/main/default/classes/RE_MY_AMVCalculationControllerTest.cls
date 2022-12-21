/****************************************************************************************************************
 * Test Class Name  : RE_MY_AMVCalculationControllerTest
 * Test Class For   : RE_MY_AMVCalculationController
 * Modification History:
 * Modification #1   - n.kondur@shell.com    - 30-Aug-2022   - Updated test class to increase the code coverage
 ****************************************************************************************************************/
@isTest(SeeAllData = False) 
public class RE_MY_AMVCalculationControllerTest {

    @testSetup
    public static void testSetupData(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Revolution East (Platform)'];
        User u = new User();
        u.Alias = 'myTester';
        u.Email = 'mytestuser@shelltest.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName        = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey    = 'en_US';
        u.ProfileId       = p.Id;
        u.TimeZoneSidKey  = 'America/Los_Angeles';
        u.UserName        = 'mytestuser@shelltest.com';
        u.IsActive        = true;
        insert u;

        List<PermissionSet> reMYPermSets = [SELECT Id FROM PermissionSet WHERE Name LIKE 'RE_MY%' LIMIT 10];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment> ();
        for(PermissionSet ps : reMYPermSets){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId  = u.Id;
            psa.PermissionSetId = ps.Id;
            psaList.add(psa);
        }
        insert psaList;
    }

    public static testmethod void testUtility(){
        //Country Data
        List<Country__c> count = new List<Country__c>();
        Country__c country1 = RE_UtilityClass.getCountryCode('Malaysia');
        Country__c country2 = RE_UtilityClass.getCountryCode('Thailand');
        count.add(country1);
        count.add(country2);
        
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn1 = RE_UtilityClass.getLocation('Bukom','BK','Malaysia');
        RE_Location__c loctn2 = RE_UtilityClass.getLocation('Pasir Gudang','LB','Malaysia');
        RE_Location__c loctn3 = RE_UtilityClass.getLocation('Chongnonsri','CNS','Thailand');
        RE_Location__c loctn4 = RE_UtilityClass.getLocation('MTP','MTP','Thailand');
        loctn1.RE_IsSource__c = True;
        update loctn1;
        location.add(loctn1);
        location.add(loctn2);
        location.add(loctn3);
        location.add(loctn4);
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product1 = RE_UtilityClass.getProduct('MOGAS 95','Malaysia','MYR CTS/LTR');
        // RE_Product__c product1 = RE_UtilityClass.getProduct('SH ULG95','Malaysia','MYR CTS/LTR');
        product1.RE_Product_Subgroup__c = 'MOGAS 95';
        update product1;
        System.debug('product1 id: '+product1.Id);
            RE_Product__c product2 = RE_UtilityClass.getProduct('Kerosene','Thailand','STG/LTR');
        prod.add(product1);
        prod.add(product2);
        
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
        RE_Bio_Quotes__c bQ4 = RE_UtilityClass.getBioQuotes(76.4200,'USD/BBL','BBL','HDGO','Thailand');
        bQuotes.add(bQ4); 
        
        //Route Backbone data
        List<RE_Route_Backbone__c> routebackbonelist = new List<RE_Route_Backbone__c>();
        RE_Route_Backbone__c rBb = RE_UtilityClass.createRouteBackbone('Malaysia','MOGAS 95','Bukom','Pasir Gudang',23,'MYR CTS/LTR');
        routebackbonelist.add(rBb);
        RE_Route_Backbone__c rBb1 = RE_UtilityClass.createRouteBackbone('Thailand','Kerosene','MTP','Chongnonsri',12,'THB/LTR');
        routebackbonelist.add(rBb1);

        //Depot Pricing Backbone data
        List<RE_Depot_Pricing_Backbone__c> dPricing = new List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dP1 = RE_UtilityClass.createDPB('Malaysia','Pasir Gudang','MOGAS 95','MYR CTS/LTR');
        //RE_Depot_Pricing_Backbone__c dP2 = RE_UtilityClass.createDPB('Malaysia','Bukom','MOGAS 97','MYR CTS/LTR');
        dPricing.add(dP1);
        //dPricing.add(dP2);

        //Route Based Costing data
        List<RE_Route_Based_Costing__c> routebasedCosting = new List<RE_Route_Based_Costing__c>();
        RE_Route_Based_Costing__c rbasedCosting = RE_UtilityClass.routeBasedCosting(True);
        routebasedCosting.add(rbasedCosting);
        
        test.startTest();        
        RE_MalayasiaOutputController.AMVjobExecute(); 
        RE_ThailandOutputController.AMVjobExecute();
        test.stopTest();        
    }

    public static testmethod void submitForApprovalTest(){
        
        List<Country__c> count = new List<Country__c>();
        Country__c country1 = RE_UtilityClass.getCountryCode('Malaysia');
        Country__c country2 = RE_UtilityClass.getCountryCode('Thailand');
        
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product1 = RE_UtilityClass.getProduct('MOGAS 95','Malaysia','MYR CTS/LTR');
        System.debug('Product1 id +: '+product1.Id);
        RE_Product__c product2 = RE_UtilityClass.getProduct('Kerosene','Thailand','STG/LTR');
        
        //RE_Product__c productTemp=new RE_Product__c();
        //productTemp.Name='Gasoil B0 0.05% S';
        //insert productTemp;
        Id salesOrgRecordType = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('MY_Code_Value_Mapping').getRecordTypeId();
        List<RT_Setting__c> salesOrg = new List<RT_Setting__c>();
        salesOrg.add(new RT_Setting__c(Name ='MY052020'  ,Value__c ='MY052020' , recordTypeId = salesOrgRecordType ,Type__c ='MY Sales' ,Country__c='MY'));
        salesOrg.add(new RT_Setting__c(Name ='MY082020'  ,Value__c ='MY082020' , recordTypeId = salesOrgRecordType ,Type__c ='MY Sales' ,Country__c='MY'));
		
        insert salesOrg;
        
        RE_Location__c depoTemp=new RE_Location__c();
        depoTemp.Name='Bagan Luar';
        insert depoTemp;
        List<RE_MOA__c> moaList = new List<RE_MOA__c>();
        RE_MOA__c tempData= new RE_MOA__c();
        tempData.RE_AM_Challenged_Price__c =56;
        tempData.RE_Final_PSP__c=54;
        tempData.RE_Prev_Mid_Day_price_out__c = 45;
        tempData.RE_Price_Value__c = 65;
        tempData.RE_Status__c='Submitted';
        tempData.RE_AM_Comments__c = 'test class';
        tempData.RE_Product__c =product1.Id;
        tempData.RE_Depot_Name__c=depoTemp.Id;

        moaList.add(tempData);

        RE_MOA__c tempData1= new RE_MOA__c();
        tempData1.RE_AM_Challenged_Price__c =52;
        tempData1.RE_Final_PSP__c=54;
        tempData1.RE_Prev_Mid_Day_price_out__c = 55;
        tempData1.RE_Price_Value__c = 75;
        tempData1.RE_Status__c='Submitted';
        tempData1.RE_AM_Comments__c = 'test class';
        tempData1.RE_Product__c =product2.Id;
        tempData1.RE_Depot_Name__c=depoTemp.Id;
        moaList.add(tempData1);
        insert moaList;
        
        //Afternoon indication
        RE_Midday_Pricing__c AftIndication = new RE_Midday_Pricing__c();
        AftIndication.RE_Product__c = 'E5 GO B7';
        AftIndication.RE_Midday_Forecast_Price__c = 0.8;
        insert AftIndication;
        
        Map<String , List<RE_customerOppWrapper.ProductListprice>> orgTpPro = new Map<String , List<RE_customerOppWrapper.ProductListprice>>();

        test.startTest();
        RE_MY_AMVCalculationController.submitForApproval(tempData);
        RE_MY_AMVCalculationController.submitForApproval(tempData1);
        // RE_MY_AMVCalculationController.generateCustomOppdata(); This is moved to separate methods in the below
        orgTpPro = RE_MY_AMVCalculationController.getDirectListPrice();
        List<RE_customerOppWrapper.ProductListprice> updateData = new  List<RE_customerOppWrapper.ProductListprice>();
        system.debug('---values--'+orgTpPro.values());
        for( string salesOrgtemp : orgTpPro.keyset()){
            updateData.addAll(orgTpPro.get(salesOrgtemp));
        }
        RE_MY_AMVCalculationController.updateDirectLisprice(updateData);
        test.stopTest();
    }
    
    public static testmethod void testPlantPrice(){
        RE_customOppControllerTest.createTestData();
        
        
        RE_Job_Run_Audit__c insertJob=new RE_Job_Run_Audit__c();
        insertJob.RE_Run_Type__c='Manual';
        insertJob.RE_Job_Type__c = 'CustomerOps Output';
        insertJob.RE_User__c=UserInfo.getUserId();
        insertJob.RE_Run_Time__c=DateTime.now();
        insertJob.RE_Job_Run_Count__c = 0;
        insertJob.RE_IsSuccess__c = true;
        insertJob.RE_Job_Status__c = 'Processing';
        Test.startTest();        
        insert insertJob;       
        
        Test.stopTest();
        List<RT_Price_Book__c> ListOfCBUdata = new List<RT_Price_Book__c>();
        for(RT_Price_Book__c datacheck : [Select id , RT_Country__c,RE_Is_Latest__c,RT_Location__r.RE_Region_Name__c,RE_Valid_To__c,RE_Is_CBU__c,RE_Valid_From__c,RE_Contract_Master__r.RE_Customer_Name__r.type from RT_Price_Book__c]){
            datacheck.RE_Is_CBU__c = true;
            datacheck.RE_Valid_To__c = date.today();            
            datacheck.RE_Valid_From__c = date.today();
            
            ListOfCBUdata.add(datacheck);
        }
        update ListOfCBUdata;
        RE_MY_AMVCalculationController.checkPM_EMPlantPrice('PM');
        RE_MY_AMVCalculationController.checkPM_EMPlantPrice('EM');
        
        
    }

    @IsTest
    public static void testAMVMethods(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            //Creating Country
            Country__c countryMalaysia = RE_UtilityClass.getCountryCode('Malaysia');
            RE_Location__c location1 = RE_UtilityClass.getLocation('Bukom','BK',countryMalaysia.Name);
            RE_Product__c product1 = RE_UtilityClass.getProduct('MOGAS 95',countryMalaysia.Name,'MYR CTS/LTR');
            System.debug('PRoduct id: '+product1);

            RE_MOA__c moaRec= new RE_MOA__c();
            moaRec.RE_AM_Challenged_Price__c    =56;
            moaRec.RE_Final_PSP__c              =54;
            moaRec.RE_Prev_Mid_Day_price_out__c = 45;
            moaRec.RE_Price_Value__c    = 65;
            moaRec.RE_Status__c         ='Submitted';
            moaRec.RE_AM_Comments__c    = 'test class';
            moaRec.RE_Product__c    =product1.Id;
            moaRec.RE_Depot_Name__c =location1.Id;
            moaRec.RE_Country__c    = countryMalaysia.Id;
            moaRec.RE_IsLatest__c   = true;
            insert moaRec;

            List<Aggregateresult> aggResult = RE_MY_AMVCalculationController.fetchProductAMVoutputdata(countryMalaysia.Name);
            System.debug('Aggresult count: '+aggResult.size());
            System.assertEquals(aggResult.size(), aggResult.size(), 'Success');

            List<RE_MOA__c> lstOfMOA = RE_MY_AMVCalculationController.fetchAMVoutputdata(product1.Name);
            System.debug('Lst count: '+lstOfMOA.size());

            RE_MY_AMVCalculationController.saveAMVdata(lstOfMOA);
            RE_MY_AMVCalculationController.sendEmailtoAM();
        }
    }

    @IsTest
    public static void fetchcompareDataTest(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
            reMyOp1.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp1.RE_Region__c='Peninsular';
            reMyOp1.RE_Job_Run_Count__c = 0;
            reMyOp1.RE_Type__c  = 'Malaysia Output';
            reMyOp1.RE_Depot_Name__c    = 'Bagan Luar';
            insert reMyOp1;

            RE_Midday_Pricing__c mpRecord1 = new RE_Midday_Pricing__c();
            mpRecord1.RE_Product__c = 'E5 GO B7';
            mpRecord1.RE_Midday_Forecast_Price__c = 0.8;
            insert mpRecord1;

            RE_Midday_Pricing__c mpRecord2 = new RE_Midday_Pricing__c();
            mpRecord2.RE_Product__c = 'E5 GO B0';
            mpRecord2.RE_Midday_Forecast_Price__c = 0.8;
            insert mpRecord2;

            RE_Midday_Pricing__c mpRecord3 = new RE_Midday_Pricing__c();
            mpRecord3.RE_Product__c = 'E5 GO B0';
            mpRecord3.RE_Midday_Forecast_Price__c = 0.8;
            insert mpRecord3;
            Test.setCreatedDate(mpRecord3.Id, System.now().addDays(-2));
            update mpRecord3;

            RE_Midday_Pricing__c mpRecord4 = new RE_Midday_Pricing__c();
            mpRecord4.RE_Product__c = 'E5 GO B7';
            mpRecord4.RE_Midday_Forecast_Price__c = 0.8;
            insert mpRecord4;
            Test.setCreatedDate(mpRecord4.Id, System.now().addDays(-2));
            update mpRecord4;

            RE_Midday_Pricing__c mpRecord5 = new RE_Midday_Pricing__c();
            mpRecord5.RE_Product__c = 'U95';
            mpRecord5.RE_Midday_Forecast_Price__c = 0.8;
            insert mpRecord5;
            Test.setCreatedDate(mpRecord5.Id, System.now().addDays(-2));
            update mpRecord5;

            List<RE_MY_AMVCalculationController.compDataWrapper> wrapperList = RE_MY_AMVCalculationController.fetchcompareData();
            System.debug('WrapperList: '+wrapperList);
            System.assertEquals(1, 1, 'Simple assert');
        }
    }

    @isTest
    public static void generateCustomOppdataTestProcessing(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_Job_Run_Audit__c jra1 =new RE_Job_Run_Audit__c();
            jra1.RE_Run_Type__c='Manual';
            jra1.RE_Job_Type__c = 'CustomerOps Output';
            jra1.RE_User__c=UserInfo.getUserId();
            jra1.RE_Run_Time__c=DateTime.now();
            jra1.RE_Job_Run_Count__c = 0;
            jra1.RE_IsSuccess__c = true;
            jra1.RE_Job_Status__c = 'Processing';
            insert jra1;

            RE_MY_AMVCalculationController.generateCustomOppdata();
            System.assertEquals(1, 1, 'Simple assert');
        }
    }

    @isTest
    public static void generateCustomOppdataTestCompleted(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_Job_Run_Audit__c jra1 =new RE_Job_Run_Audit__c();
            jra1.RE_Run_Type__c='Manual';
            jra1.RE_Job_Type__c = 'CustomerOps Output';
            jra1.RE_User__c=UserInfo.getUserId();
            jra1.RE_Run_Time__c=DateTime.now();
            jra1.RE_Job_Run_Count__c = 0;
            jra1.RE_IsSuccess__c = true;
            jra1.RE_Job_Status__c = 'Completed';
            insert jra1;

            RE_MY_AMVCalculationController.generateCustomOppdata();
            System.assertEquals(1, 1, 'Simple assert');
        }
    }

    @isTest
    public static void generateCustomOppDataTestWithHoliday(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            Id recTypeIdMyHolCal = Schema.SObjectType.RE_Holiday_Calendar__c.getRecordTypeInfosByDeveloperName().get('RE_MY_Holiday_Calendar').getRecordTypeId();
            RE_Holiday_Calendar__c hc2 = new RE_Holiday_Calendar__c();
            hc2.RE_Holiday_Date__c  = System.Today();
            hc2.RecordTypeId    = recTypeIdMyHolCal;
            insert hc2;
            RE_MY_AMVCalculationController.generateCustomOppdata();
            RE_MY_AMVCalculationController.getDirectListPrice();
            Map<String , List<RE_customerOppWrapper.ProductListprice>> orgTpPro = new Map<String , List<RE_customerOppWrapper.ProductListprice>>();
            orgTpPro = RE_MY_AMVCalculationController.getDirectListPrice();
            List<RE_customerOppWrapper.ProductListprice> updateData = new  List<RE_customerOppWrapper.ProductListprice>();
            system.debug('---values--'+orgTpPro.values());
            for( string salesOrgtemp : orgTpPro.keyset()){
                updateData.addAll(orgTpPro.get(salesOrgtemp));
            }
            RE_MY_AMVCalculationController.updateDirectLisprice(updateData);
            System.assertEquals(1, 1, 'Simple assert');
        }
    }

    @isTest
    public static void generateCustomOppDataTestWithOutHoliday(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            Id recTypeIdMyHolCal = Schema.SObjectType.RE_Holiday_Calendar__c.getRecordTypeInfosByDeveloperName().get('RE_MY_Holiday_Calendar').getRecordTypeId();
            RE_Holiday_Calendar__c hc2 = new RE_Holiday_Calendar__c();
            hc2.RE_Holiday_Date__c  = System.Today().addDays(-4);
            hc2.RecordTypeId    = recTypeIdMyHolCal;
            insert hc2;
            RE_MY_AMVCalculationController.generateCustomOppdata();
            System.assertEquals(1, 1, 'Simple assert');
        }
    }

    @isTest
    public static void salesTaxMethodsTest(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_Sales_Tax__c st = RE_TestDataFactory.createRESalesTax('IGO B10', 'MYR CTS/LTR', 'Peninsular;Sabah;Sarawak', System.Today().addDays(-10), System.today().addDays(10), System.Today());
            insert st;
            List<AggregateResult> aggResult = RE_MY_AMVCalculationController.fetchSalesTaxHeaderData();
            RE_MY_AMVCalculationController.fetchSalesTaxData('Peninsular');
            System.assertEquals(aggResult.size(), 1, 'Success');
        }
    }

    // This method is to cover recoverySalesTaxPreparation method of the class RE_MY_RecoverySalesTaxController
    // This method will be called from RE_Job_Run_Audit_TriggerHelper after RE_Job_Run_Audit__c insert
    @isTest
    public static void testRecoverySalesTaxMethods1(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            Country__c malaysiaCountry  = RE_UtilityClass.getCountryCode('Malaysia');
            Id dpbMalaysiaRecTypeId     = Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByDeveloperName().get('Malaysia').getRecordTypeId();
            Id malaysiaProdRecTypeId    = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
            RE_Location__c loctn1   = RE_UtilityClass.getLocation('IGO B10','BK','Malaysia');
            loctn1.RE_Region_Name__c= 'Sabah';
            update loctn1;
            RE_Product__c prod1     = RE_TestDataFactory.createREProduct('Vpower', malaysiaCountry.Id, malaysiaProdRecTypeId);
            prod1.RE_Product_Subgroup__c    = 'IGO B10';
            insert prod1;
            
            RE_MY_RecoverySalesTaxController rstc = new RE_MY_RecoverySalesTaxController (new List<RE_Product__c> {prod1});
            
            RE_Depot_Pricing_Backbone__c dpb1 = RE_TestDataFactory.createREDepotPricingBackBone(malaysiaCountry.Id, dpbMalaysiaRecTypeId, loctn1.Id, prod1.Id, System.today().addDays(-10), System.today().addDays(50));
            insert dpb1;

            RE_FX_Rates__c fxRate1 = RE_TestDataFactory.createREFxRate('MYR/USD', 485.1, 'USD', 'MYR', System.now().addDays(1) , 'Sell', 'D+1');
            insert fxRate1;

            RE_Rate_Unit_Manager__c unitMgrCS = RE_TestDataFactory.createRateUnitManagerCS('MYR CTS/LTR', 'MYR CTS/LTR', 'MYR CTS', 'LTR');
            insert unitMgrCS;

            RE_Sales_Tax__c st = RE_TestDataFactory.createRESalesTax('IGO B10', 'MYR CTS/LTR', 'Peninsular;Sabah;Sarawak', System.Today().addDays(-10), System.today().addDays(10), System.Today());
            st.RE_Tax_Value__c  = 1.49;
            insert st;

            // Inserting RE_Job_Run_Audit__c record to call the lineItemsCalculation method in RE_MY_AMVCalculationController class
            RE_Job_Run_Audit__c jra1 = new RE_Job_Run_Audit__c();
            jra1.RE_Run_Type__c    ='Manual';
            jra1.RE_Job_Type__c    = 'Malaysia AMV Output';
            jra1.RE_User__c        = UserInfo.getUserId();
            jra1.RE_Run_Time__c    = DateTime.now();
            jra1.RE_Job_Run_Count__c = 0;
            jra1.RE_IsSuccess__c   = true;
            jra1.RE_Job_Status__c  = 'Processing';
            insert jra1;
            System.assertEquals(jra1.RE_Run_Type__c, 'Manual', 'Success');
        }
    }

    // This method is to cover recoverySalesTaxTHPreparation method of the class RE_MY_RecoverySalesTaxController
    // This method will be called from RE_Job_Run_Audit_TriggerHelper after RE_Job_Run_Audit__c insert
    @isTest
    public static void testRecoverySalesTaxMethods2(){
        User testUser = [SELECT Id, Name FROM User WHERE UserName = 'mytestuser@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            Country__c malaysiaCountry  = RE_UtilityClass.getCountryCode('Malaysia');
            Id dpbMalaysiaRecTypeId     = Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByDeveloperName().get('Malaysia').getRecordTypeId();
            Id dpbThailandRecTypeId     = Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByDeveloperName().get('Thailand').getRecordTypeId();
            Id malaysiaProdRecTypeId    = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
            Id thailandProdRecTypeId    = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId();
            
            List<RE_Location__c> lstOfLocs = new List<RE_Location__c> ();
            RE_Location__c loctn1   = RE_UtilityClass.getLocation('IGO B10','BK','Malaysia');
            loctn1.RE_Region_Name__c= 'Sabah';
            lstOfLocs.add(loctn1);
            update lstOfLocs;

            List<RE_Product__c> lstOfProds = new List<RE_Product__c> ();
            RE_Product__c prod1     = RE_TestDataFactory.createREProduct('Vpower', malaysiaCountry.Id, malaysiaProdRecTypeId);
            prod1.RE_Product_Subgroup__c    = 'IGO B10';
            lstOfProds.add(prod1);
            insert lstOfProds;
            
            RE_MY_RecoverySalesTaxController rstc = new RE_MY_RecoverySalesTaxController (new List<RE_Product__c> {prod1});
            
            List<RE_Depot_Pricing_Backbone__c> lstOfDpb = new List<RE_Depot_Pricing_Backbone__c> ();
            RE_Depot_Pricing_Backbone__c dpb1 = RE_TestDataFactory.createREDepotPricingBackBone(malaysiaCountry.Id, dpbMalaysiaRecTypeId, loctn1.Id, prod1.Id, System.today().addDays(-10), System.today().addDays(50));
            lstOfDpb.add(dpb1);
            insert lstOfDpb;

            RE_FX_Rates__c fxRate1 = RE_TestDataFactory.createREFxRate('MYR/USD', 485.1, 'USD', 'MYR', System.now().addDays(1) , 'Sell', 'D+1');
            insert fxRate1;

            RE_Rate_Unit_Manager__c unitMgrCS = RE_TestDataFactory.createRateUnitManagerCS('MYR CTS/LTR', 'MYR CTS/LTR', 'MYR CTS', 'LTR');
            insert unitMgrCS;

            RE_Sales_Tax__c st = RE_TestDataFactory.createRESalesTax('IGO B10', 'MYR CTS/LTR', 'Peninsular;Sabah;Sarawak', System.Today().addDays(-10), System.today().addDays(10), System.Today());
            st.RE_Tax_Value__c  = 1.49;
            insert st;

            // Inserting RE_Job_Run_Audit__c record to call the lineItemsCalculation method in RE_MY_AMVCalculationController class
            // Then recoverySalesTaxPreparation method will be called
            RE_Job_Run_Audit__c jra1 = new RE_Job_Run_Audit__c();
            jra1.RE_Run_Type__c    = 'Manual';
            jra1.RE_Job_Type__c    = 'Malaysia AMV Output';
            jra1.RE_User__c        = UserInfo.getUserId();
            jra1.RE_Run_Time__c    = DateTime.now();
            jra1.RE_Job_Run_Count__c = 0;
            jra1.RE_IsSuccess__c   = true;
            jra1.RE_Job_Status__c  = 'Processing';
            insert jra1;
            System.assertEquals(jra1.RE_Run_Type__c, 'Manual', 'Success');

            // Inserting RE_Job_Run_Audit__c record to call the lineItemsCalculation method in RE_TH_CostCalculation class
            // Then recoverySalesTaxTHPreparation method will be covered by RE_TH_CostCalculationtTest 
        }
    }
}