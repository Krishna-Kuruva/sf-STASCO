/*******************************************************************************************************************************************************-*********
@ Class:          RE_MalayasiaOutputControllerTest
@ Version:        1.0
@ Author:         Seemesh Patel (seemesh.patel@shell.com)
@ Purpose:        Test classes for RE_MalayasiaOutputController.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.01.2020 / Seemesh Patel / Created the class.
@ Change history: 02.09.2022 / Nandeeswara Raju (n.kondur@shell.com) / Created the class.
@ Change history: 01-Sep-2022 / K. Nandeeswara Raju / Created testSetupData method.
@ Change history: 05-Sep-2022 / K. Nandeeswara Raju / Created thailandOutPutCtrlTest method.
******************************************************************************************************************************************************************/
@isTest 
public class RE_MalayasiaOutputControllerTest {
    
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
        
        List<PermissionSet> reTHPermSets = [SELECT Id FROM PermissionSet WHERE Name LIKE 'RE_TH%' LIMIT 10];
        masterPSList.addAll(reTHPermSets);
        
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment> ();
        for(PermissionSet ps : masterPSList){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId  = u.Id;
            psa.PermissionSetId = ps.Id;
            psaList.add(psa);
        }
        insert psaList;
    }
    
    /*******************************************************************************************************************************************************-*********
    @ Class:          InitialDetailsTest
    @ Version:        1.0
    @ Author:         Seemesh Patel (seemesh.patel@shell.com)
    @ Purpose:        InitialDetailsTest to cover Test coverage for RE_MalayasiaOutputController class.
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.01.2020 / Seemesh Patel / Created the class.
    ******************************************************************************************************************************************************************/
    
    static testmethod void InitialDetailsTest(){ 
        
        /**************** Test Start  *******************/
        Test.startTest();
        
        
        RE_Market_Quotes__c createMQ1  = RE_UtilityClass.getMarketQuotes(23.6560,'USD','BBL','MID RON PREMIUM');
        RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD','BBL','Gasoil 0.05% S');
        RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(57.4658,'USD','BBL','Kero');
        RE_UtilityClass.getCountryCode('Singapore');
        RE_UtilityClass.getCountryCode('Malaysia');
        RE_UtilityClass.getCountryCode('Thailand');
        RE_FX_Rates__c FXrate2 =  RE_UtilityClass.createFXRecords('SGD/USD',1.3520,'USD','SGD','Singapore');
        RE_FX_Rates__c FXrate1 =  RE_UtilityClass.createFXRecords('SGD CTS/USD',135.20,'USD','SGD CTS','Singapore');
        RE_FX_Rates__c FXrate3 =  RE_UtilityClass.createFXRecords('MYR/USD',4.3520,'USD','MYR','Malaysia');
        RE_FX_Rates__c FXrate4 =  RE_UtilityClass.createFXRecords('MYR CTS/USD',435.20,'USD','MYR CTS','Malaysia');
        RE_FX_Rates__c FXrate5 =  RE_UtilityClass.createFXRecords('THB/USD',415.2014,'USD','THB','Thailand');
        List<RE_MY_Output__c> ls = RE_UtilityClass.getMYOutput();
        
        RE_MalayasiaOutputController.getLDCCostData(ls[0]);
        RE_MalayasiaOutputController.getMCCostData(ls[0]);
        RE_MalayasiaOutputController.getUserInfo(Userinfo.getUserId());
        RE_MalayasiaOutputController.jobExecute('Malaysia Output');
        RE_MalayasiaOutputController.maxRunCountMethod();
        RE_MalayasiaOutputController.lastJobRun();
        RE_MalayasiaOutputController.getMOPSData();
        RE_MalayasiaOutputController.getFxData();
        RE_MalayasiaOutputController.getCostingDataPeninsular();
        RE_MalayasiaOutputController.getCostingDataSabah();
        RE_MalayasiaOutputController.getCostingDataSarawak();
        RE_MalayasiaOutputController.getInitParameterDetails(Userinfo.getUserId());

        //Coverage of RE_SingaporeOutputController methods is moved to RE_SG_CostCalculationTest
        
        RE_UtilityClass.getCostPrice();
        
        List<RE_Market_Quotes__c> mk = new List<RE_Market_Quotes__c>();
        RE_Market_Quotes__c obr= new RE_Market_Quotes__c(Id=createMQ2.Id,RE_Quote_Type__c='Settlement',RE_Pricing_Date__c =System.Now());
        RE_Market_Quotes__c obr1= new RE_Market_Quotes__c(Id=createMQ3.Id,RE_Quote_Type__c='Settlement',RE_Pricing_Date__c =System.Now(),RE_Tracker__c='D');
        mk.add(obr);
        mk.add(obr1);
        update mk;
        RE_FX_Rates__c fxData = new RE_FX_Rates__c(Id = FXrate5.Id,RE_Tracker__c ='D',RE_Conversion_Unit__c='THB',RE_Base_Unit__c = 'USD',RE_Trade_Type__c = 'Sell');
        update fxData;
        
        //All Thailand methods are moved to a different method in this test class
        
        /**************** Test Stop *******************/
        Test.stopTest();
    }
    
    /*******************************************************************************************************************************************************-*********
    @ Method    : testMethod2
    @ Version   : 1.0
    @ Author    : K. Nandeeswara Raju (n.kondur@shell.com)
    @ Purpose   : testMethod2 to cover Test coverage for RE_MalayasiaOutputController class.
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 01-Sep-2022 / K. Nandeeswara Raju / Created the method.
    ******************************************************************************************************************************************************************/
    @IsTest
    public static void testMethod2(){
        User testUser = [SELECT Id, Name, Email FROM User WHERE Username = 'revolutioneasttest@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
            reMyOp1.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp1.RE_Region__c='Peninsular';
            reMyOp1.RE_Job_Run_Count__c = 1;
            reMyOp1.RE_Type__c  = 'Malaysia Output';
            reMyOp1.RE_Depot_Name__c    = 'Bagan Luar';
            reMyOp1.RE_Pricing_Date__c  = System.today();
            reMyOp1.RE_Gasoil_B0_0_05_S_MC_Diff__c = 13.766;
            reMyOp1.RE_Kerosene_MC__c   = 338.9902;
            reMyOp1.RE_Kerosene_MC_Diff__c  = 10.16;
            reMyOp1.RE_Gasoil_B7_0_05_S_MC__c = 93.46;
            reMyOp1.RE_Gasoil_B0_0_05_S_MC__c = 90.123;
            reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 406.98;
            reMyOp1.RE_Gasoil_B7_0_001_S_MC_Diff__c = 23.73;
            reMyOp1.RE_MOGAS_95_MC__c       = 370.12;
            reMyOp1.RE_MOGAS_95_MC_Diff__c  = 20.72;
            reMyOp1.RE_MOGAS_97_MC__c       = 369.23;
            reMyOp1.RE_MOGAS_97_MC_Diff__c  = 20.71;
            reMyOp1.RE_Gasoil_E2_B10_MC__c  = 441.22;
            reMyOp1.RE_Gasoil_E2_B10_MC_Diff__c = 20.414;
            reMyOp1.RE_Gasoil_E5_B10_MC__c  = 421.80;
            reMyOp1.RE_Gasoil_E5_B10_MC_Diff__c = 22.96;
            reMyOp1.RE_Gasoil_B0_0_001_S_MC__c  = 400.42;
            reMyOp1.RE_Gasoil_B0_0_001_S_MC_Diff__c = 25.52;
            insert reMyOp1;
            
            Integer maxRunCount = RE_MalayasiaOutputController.maxRunCountMethod();
            System.assertEquals(1, maxRunCount, 'Success');
            
            RE_Job_Run_Audit__c jra1 =new RE_Job_Run_Audit__c();
            jra1.RE_Run_Type__c='Manual';
            jra1.RE_Job_Type__c = 'Malaysia AMV Output';
            jra1.RE_User__c=UserInfo.getUserId();
            jra1.RE_Run_Time__c=DateTime.now();
            jra1.RE_Job_Run_Count__c = 0;
            jra1.RE_IsSuccess__c = true;
            jra1.RE_Job_Status__c = 'Processing';
            insert jra1;
            
            RE_MalayasiaOutputController.AMVjobExecute();
            RE_MalayasiaOutputController.jobExecute('Malaysia AMV Output');
            
            List<RE_Market_Quotes__c> lstMQs = new List<RE_Market_Quotes__c> ();
            RE_Market_Quotes__c createMQ2  = RE_UtilityClass.getMarketQuotes(57.4658,'USD','BBL','Gasoil 0.001% S');
            RE_Market_Quotes__c mq1= new RE_Market_Quotes__c(Id=createMQ2.Id,RE_Quote_Type__c='Settlement',RE_Pricing_Date__c =System.Now(),RE_Tracker__c='D');
            lstMQs.add(mq1);
            
            RE_Market_Quotes__c createMQ3  = RE_UtilityClass.getMarketQuotes(57.4658,'USD','BBL','Gasoil 0.05% S');
            RE_Market_Quotes__c mq2= new RE_Market_Quotes__c(Id=createMQ3.Id,RE_Quote_Type__c='Settlement',RE_Pricing_Date__c =System.Now(),RE_Tracker__c='D-1');
            lstMQs.add(mq2);
            update lstMQs;
            RE_MalayasiaOutputController.getMOPSData();
            RE_ThailandOutputController.getMOPSData();//This method uses exact same data as above.
            
            RE_MalayasiaOutputController.fetchmiddaydata();
            
            Country__c country1 = RE_UtilityClass.getCountryCode('Singapore');
            RE_FX_Rates__c fxRate1 =  RE_UtilityClass.createFXRecords('SGD CTS/USD',135.20,'USD','MYR','Singapore');
            fxRate1.RE_Tracker__c   = 'D';
            update fxRate1;
            
            RE_FX_Rates__c fxRate2 =  RE_UtilityClass.createFXRecords('SGD/USD',1.3520,'USD','MYR','Singapore');
            fxRate1.RE_Tracker__c   = 'D-1';
            update fxRate2;
            RE_MalayasiaOutputController.getFxData();
            
            List<RE_MY_Output__c> lstOfMyOP = new List<RE_MY_Output__c> ();
            RE_MY_Output__c reMyOp01 = new RE_MY_Output__c();
            reMyOp01.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp01.RE_Region__c='Peninsular';
            reMyOp01.RE_Job_Run_Count__c = 1;
            reMyOp01.RE_Type__c  = 'Malaysia Output';
            reMyOp01.RE_Depot_Name__c    = 'Bagan Luar';
            reMyOp01.RE_Pricing_Date__c  = System.today();
            reMyOp01.RE_Gasoil_B0_0_05_S_MC_Diff__c = 13.766;
            reMyOp01.RE_Kerosene_MC__c   = 338.9902;
            reMyOp01.RE_Kerosene_MC_Diff__c  = 10.16;
            reMyOp01.RE_Gasoil_B7_0_05_S_MC__c = 93.46;
            reMyOp01.RE_Gasoil_B0_0_05_S_MC__c = 90.123;
            reMyOp01.RE_Gasoil_B7_0_001_S_MC__c = 406.98;
            reMyOp01.RE_Gasoil_B7_0_001_S_MC_Diff__c = 23.73;
            reMyOp01.RE_MOGAS_95_MC__c       = 370.12;
            reMyOp01.RE_MOGAS_95_MC_Diff__c  = 20.72;
            reMyOp01.RE_MOGAS_97_MC__c       = 369.23;
            reMyOp01.RE_MOGAS_97_MC_Diff__c  = 20.71;
            reMyOp01.RE_Gasoil_E2_B10_MC__c  = 441.22;
            reMyOp01.RE_Gasoil_E2_B10_MC_Diff__c = 20.414;
            reMyOp01.RE_Gasoil_E5_B10_MC__c  = 421.80;
            reMyOp01.RE_Gasoil_E5_B10_MC_Diff__c = 22.96;
            reMyOp01.RE_Gasoil_B0_0_001_S_MC__c  = 400.42;
            reMyOp01.RE_Gasoil_B0_0_001_S_MC_Diff__c = 25.52;
            lstOfMyOP.add(reMyOp01);
            
            RE_MY_Output__c reMyOp2 = new RE_MY_Output__c();
            reMyOp2.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp2.RE_Region__c='Sabah';
            reMyOp2.RE_Job_Run_Count__c = 1;
            reMyOp2.RE_Type__c  = 'Malaysia Output';
            reMyOp2.RE_Depot_Name__c    = 'Bagan Luar';
            reMyOp2.RE_Pricing_Date__c  = System.today();
            reMyOp2.RE_Gasoil_B0_0_05_S_MC_Diff__c = 13.766;
            reMyOp2.RE_Kerosene_MC__c   = 338.9902;
            reMyOp2.RE_Kerosene_MC_Diff__c  = 10.16;
            reMyOp2.RE_Gasoil_B7_0_05_S_MC__c = 93.46;
            reMyOp2.RE_Gasoil_B0_0_05_S_MC__c = 90.123;
            reMyOp2.RE_Gasoil_B7_0_001_S_MC__c = 406.98;
            reMyOp2.RE_Gasoil_B7_0_001_S_MC_Diff__c = 23.73;
            reMyOp2.RE_MOGAS_95_MC__c       = 370.12;
            reMyOp2.RE_MOGAS_95_MC_Diff__c  = 20.72;
            reMyOp2.RE_MOGAS_97_MC__c       = 369.23;
            reMyOp2.RE_MOGAS_97_MC_Diff__c  = 20.71;
            reMyOp2.RE_Gasoil_E2_B10_MC__c  = 441.22;
            reMyOp2.RE_Gasoil_E2_B10_MC_Diff__c = 20.414;
            reMyOp2.RE_Gasoil_E5_B10_MC__c  = 421.80;
            reMyOp2.RE_Gasoil_E5_B10_MC_Diff__c = 22.96;
            reMyOp2.RE_Gasoil_B0_0_001_S_MC__c  = 400.42;
            reMyOp2.RE_Gasoil_B0_0_001_S_MC_Diff__c = 25.52;
            lstOfMyOP.add(reMyOp2);
            
            RE_MY_Output__c reMyOp3 = new RE_MY_Output__c();
            reMyOp3.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp3.RE_Region__c='Sarawak';
            reMyOp3.RE_Job_Run_Count__c = 1;
            reMyOp3.RE_Type__c  = 'Malaysia Output';
            reMyOp3.RE_Depot_Name__c    = 'Bagan Luar';
            reMyOp3.RE_Pricing_Date__c  = System.today();
            reMyOp3.RE_Gasoil_B0_0_05_S_MC_Diff__c = 13.766;
            reMyOp3.RE_Kerosene_MC__c   = 338.9902;
            reMyOp3.RE_Kerosene_MC_Diff__c  = 10.16;
            reMyOp3.RE_Gasoil_B7_0_05_S_MC__c = 93.46;
            reMyOp3.RE_Gasoil_B0_0_05_S_MC__c = 90.123;
            reMyOp3.RE_Gasoil_B7_0_001_S_MC__c = 406.98;
            reMyOp3.RE_Gasoil_B7_0_001_S_MC_Diff__c = 23.73;
            reMyOp3.RE_MOGAS_95_MC__c       = 370.12;
            reMyop3.RE_MOGAS_95_MC_Diff__c  = 20.72;
            reMyop3.RE_MOGAS_97_MC__c       = 369.23;
            reMyop3.RE_MOGAS_97_MC_Diff__c  = 20.71;
            reMyop3.RE_Gasoil_E2_B10_MC__c  = 441.22;
            reMyop3.RE_Gasoil_E2_B10_MC_Diff__c = 20.414;
            reMyop3.RE_Gasoil_E5_B10_MC__c  = 421.80;
            reMyop3.RE_Gasoil_E5_B10_MC_Diff__c = 22.96;
            reMyOp3.RE_Gasoil_B0_0_001_S_MC__c  = 400.42;
            reMyOp3.RE_Gasoil_B0_0_001_S_MC_Diff__c = 25.52;
            lstOfMyOP.add(reMyOp3);
            
            insert lstOfMyOP;
            
            RE_MalayasiaOutputController.getCostingDataPeninsular();
            RE_MalayasiaOutputController.getCostingDataSabah();
            RE_MalayasiaOutputController.getCostingDataSarawak();
        }
    }
    
    /*******************************************************************************************************************************************************-*********
    @ Method    : ThailandOutPutCtrlTest
    @ Version   : 1.0
    @ Author    : K. Nandeeswara Raju (n.kondur@shell.com)
    @ Purpose   : To cover Test coverage for RE_ThailandOutputController class.
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 05-Sep-2022 / K. Nandeeswara Raju / Created the method.
    ******************************************************************************************************************************************************************/
    @isTest
    public static void thailandOutPutCtrlTest(){
        User testUser = [SELECT Id, Name, Email FROM User WHERE Username = 'revolutioneasttest@shelltest.com' LIMIT 1];
        System.runAs(testUser){
            RE_MY_Output__c reMyOp1 = new RE_MY_Output__c();
            reMyOp1.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp1.RE_Region__c='Peninsular';
            reMyOp1.RE_Job_Run_Count__c = 1;
            reMyOp1.RE_Type__c  = 'Thailand Output';
            reMyOp1.RE_Depot_Name__c    = 'Bagan Luar';
            reMyOp1.RE_Pricing_Date__c  = System.today();
            reMyOp1.RE_Gasoil_B0_0_05_S_MC_Diff__c = 13.766;
            reMyOp1.RE_Kerosene_MC__c   = 338.9902;
            reMyOp1.RE_Kerosene_MC_Diff__c  = 10.16;
            reMyOp1.RE_Gasoil_B7_0_05_S_MC__c = 93.46;
            reMyOp1.RE_Gasoil_B0_0_05_S_MC__c = 90.123;
            reMyOp1.RE_Gasoil_B7_0_001_S_MC__c = 406.98;
            reMyOp1.RE_Gasoil_B7_0_001_S_MC_Diff__c = 23.73;
            reMyOp1.RE_MOGAS_95_MC__c       = 370.12;
            reMyOp1.RE_MOGAS_95_MC_Diff__c  = 20.72;
            reMyOp1.RE_MOGAS_97_MC__c       = 369.23;
            reMyOp1.RE_MOGAS_97_MC_Diff__c  = 20.71;
            reMyOp1.RE_Gasoil_E2_B10_MC__c  = 441.22;
            reMyOp1.RE_Gasoil_E2_B10_MC_Diff__c = 20.414;
            reMyOp1.RE_Gasoil_E5_B10_MC__c  = 421.80;
            reMyOp1.RE_Gasoil_E5_B10_MC_Diff__c = 22.96;
            reMyOp1.RE_Gasoil_B0_0_001_S_MC__c  = 400.42;
            reMyOp1.RE_Gasoil_B0_0_001_S_MC_Diff__c = 25.52;
            insert reMyOp1;
            
            Integer maxRunCount = RE_ThailandOutputController.maxRunCountMethod();
            System.assertEquals(1, maxRunCount, 'Success');
            
            RE_Job_Run_Audit__c jra1 =new RE_Job_Run_Audit__c();
            jra1.RE_Run_Type__c='Manual';
            jra1.RE_Job_Type__c = 'Thailand AMV Output';
            jra1.RE_User__c=UserInfo.getUserId();
            jra1.RE_Run_Time__c=DateTime.now();
            jra1.RE_Job_Run_Count__c = 0;
            jra1.RE_IsSuccess__c = true;
            jra1.RE_Job_Status__c = 'Processing';
            insert jra1;
            System.debug('Calling AMVjobExecute from RE_MalaysiaOPControllerTest');
            RE_ThailandOutputController.AMVjobExecute();
            
            RE_ThailandOutputController.jobExecute('Thailand AMV Output');
            
            RE_Job_Run_Audit__c jra2 =new RE_Job_Run_Audit__c();
            jra2.RE_Run_Type__c='Manual';
            jra2.RE_Job_Type__c = 'Thailand Output';
            jra2.RE_User__c=UserInfo.getUserId();
            jra2.RE_Run_Time__c=DateTime.now();
            jra2.RE_Job_Run_Count__c = 0;
            jra2.RE_IsSuccess__c = true;
            jra2.RE_Job_Status__c = 'Processing';
            insert jra2;
            RE_ThailandOutputController.lastJobRun();
            RE_ThailandOutputController.getUserInfo(Userinfo.getUserId());

            Country__c thailandCountry = RE_UtilityClass.getCountryCode('Thailand');
            RE_FX_Rates__c fxRate1 =  RE_UtilityClass.createFXRecords('THB/USD',36.9,'USD','THB',thailandCountry.Name);
            fxRate1.RE_Tracker__c   = 'D+1';
            update fxRate1;
            RE_ThailandOutputController.getFxData();

            RE_MY_Output__c reMyOp2 = new RE_MY_Output__c();
            reMyOp2.RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78;
            reMyOp2.RE_Region__c='Thailand';
            reMyOp2.RE_Job_Run_Count__c = 1;
            reMyOp2.RE_Type__c  = 'Thailand Output';
            reMyOp2.RE_Depot_Name__c    = 'Bagan Luar';
            reMyOp2.RE_Pricing_Date__c  = System.today();
            reMyOp2.RE_Kerosene_LDC__c = 15.335;
            reMyOp2.RE_Kerosene_LDC_Diff__c = 15.335;
            reMyOp2.RE_TH_AWD_LDC__c = 25.377;
            reMyOp2.RE_TH_AWD_DIFF__c = 0;
            reMyOp2.RE_TH_Com_B0_LDC__c = 18.519;
            reMyOp2.RE_TH_Com_B0_DIFF__c = -0.188;
            reMyOp2.RE_TH_Com_B7_LDC__c = 17.331;
            reMyOp2.RE_TH_Com_B7_DIFF__c = -0.175;
            reMyOp2.RE_TH_Com_B10_LDC__c = 13.388;
            reMyOp2.RE_TH_Com_B10_DIFF__c = -0.17;
            reMyOp2.RE_TH_Com_B20_LDC__c = 9.998;
            reMyOp2.RE_TH_Com_B20_DIFF__c = -0.152;
            reMyOp2.RE_TH_FOA_LDC__c = 10.224;
            reMyOp2.RE_TH_FOA_DIFF__c = -0.119;
            reMyOp2.RE_TH_FOA_X_LDC__c = 10.325;
            reMyOp2.RE_TH_FOA_X_DIFF__c = -0.119;
            reMyOp2.RE_TH_FOC_LDC__c = 10.14;
            reMyOp2.RE_TH_FOC_DIFF__c = -0.107;
            reMyOp2.RE_TH_FOC_X_LDC__c = 10.007;
            reMyOp2.RE_TH_FOC_X_DIFF__c = -0.107;
            reMyOp2.RE_TH_FSD_B7_LDC__c = 17.403;
            reMyOp2.RE_TH_FSD_B7_DIFF__c = -0.175;
            reMyOp2.RE_TH_FSD_B10_LDC__c = 13.459;
            reMyOp2.RE_TH_FSD_B10_DIFF__c = -0.17;
            reMyOp2.RE_TH_G91_E10_LDC__c = 16.433;
            reMyOp2.RE_TH_G91_E10_DIFF__c = -0.166;
            reMyOp2.RE_TH_G95_E10_LDC__c = 16.653;
            reMyOp2.RE_TH_G95_E10_DIFF__c = -0.166;
            reMyOp2.RE_TH_G95_E20_LDC__c = 11.826;
            reMyOp2.RE_TH_G95_E20_DIFF__c = -0.148;
            reMyOp2.RE_TH_LPP_LDC__c = 15.316;
            reMyOp2.RE_TH_LPP_DIFF__c = -0.112;
            reMyOp2.RE_TH_PSFD_LDC__c = 23.834;
            reMyOp2.RE_TH_PSFD_DIFF__c = 0;
            reMyOp2.RE_TH_U91_E0_LDC__c = 24.012;
            reMyOp2.RE_TH_U91_E0_DIFF__c = -0.183;
            reMyOp2.RE_TH_U95_E0_LDC__c = 24.194;
            reMyOp2.RE_TH_U95_E0_DIFF__c = -0.183;
            reMyOp2.RE_TH_ULSD_LDC__c = 25.24;
            reMyOp2.RE_TH_ULSD_DIFF__c = 0;
            reMyOp2.RE_TH_VPD_B7_LDC__c = 17.342;
            reMyOp2.RE_TH_VPD_B7_DIFF__c = -0.175;
            reMyOp2.RE_TH_VPG_E10_LDC__c = 16.741;
            reMyOp2.RE_TH_VPG_E10_DIFF__c = -0.166;
            reMyOp2.RE_TH_LSFO_80_DIFF__c = 0.001;
            reMyOp2.RE_TH_LSFO_80_LDC__c = -151.698;
            reMyOp2.RE_TH_LSFO_380_DIFF__c = -0.204;
            reMyOp2.RE_TH_LSFO_380_LDC__c = 21.817;
            reMyOp2.RE_TH_MGO_0_1_DIFF__c = -0.19;
            reMyOp2.RE_TH_MGO_0_1_LDC__c = 10.044;
            insert reMyOp2;
            RE_ThailandOutputController.getCostingDataThailand();

            RE_Bio_Quotes__c bQ1 = RE_UtilityClass.getBioQuotes(76.4200,'USD/BBL','BBL','HDGO','Thailand');
            RE_ThailandOutputController.getInitParameterDetails(Userinfo.getUserId());
        }
    }
}