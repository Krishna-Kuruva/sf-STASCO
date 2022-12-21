/*****************************************************************************
@Name:  RV_DIDashboardControllerFutureTest     
@=========================================================================
@Purpose: Test class for DI Dashboard future and snapshot functionality
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/08/2018         INITIAL DEVELOPMENT

******************************************************************************/
@isTest
private class RV_DIDashboardControllerFutureTest {
	 @testSetup static void setup() {
        /*RV_SPCalculationControllerTest.pricecalculator();
        List<MRC__c> mrcList =[select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                           	   Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                       		Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                           Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        String plantId = mrcList.get(0).Plant__c;*/
         location__c loc= new location__c();
        loc.Name = 'Ludwigshafen depot';
        loc.Plant_Code__c = 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'South West';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Shell Own Location';
        loc.Alt_Type__c='Alternate1';
        loc.Region_Name__c = 'East';
        loc.Products_Availability__c='AGO B7;IGO 50ppm;ULG95 E5';
        loc.Depot_MOT__c='Barge;ITT;Rail;TRuck';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        insert loc;
        
        //Location with aletrnate2
        Location__c locAlt2 = new Location__c();
        locAlt2.Name = 'Altmannshofen Shell Depot';
        locAlt2.Plant_Code__c = 'D002';
        locAlt2.Quote_Region__c='Barge';
        locAlt2.Source_Location__c = false;
        locAlt2.Company_Code__c = 'DE01';
        locAlt2.OMR_Region__c = 'South West';
        locAlt2.Sales_Region__c = 'South';
        locAlt2.Location_Type__c = 'Shell Own Location';
        locAlt2.Alt_Type__c='Alternate2';
        locAlt2.Region_Name__c = 'East';
        locAlt2.Products_Availability__c='AGO B7;IGO 50ppm;ULG95 E5';
        locAlt2.Depot_MOT__c='Barge;ITT;Rail;TRuck';
        locAlt2.Custom_Record_Type__c = 'Revolution';
        locAlt2.Scenario_Type__c = 'Import;Export;Balanced';
        insert locAlt2;
        
        //Insert Source Loc
        Location__c locSrc = new Location__c();
        locSrc.Name = 'ARA/Arnheim Shell depot';
        locSrc.Plant_Code__c = 'D127';
        locSrc.Quote_Region__c='Barge';
        locSrc.Source_Location__c = true;
        locSrc.Company_Code__c = 'DE01';
        locSrc.OMR_Region__c = 'South West';
        locSrc.Sales_Region__c = 'South';
        locSrc.Location_Type__c = 'Shell Own Location';
        locSrc.Alt_Type__c='Alternate1';
        locSrc.Region_Name__c = 'East';
        locSrc.Products_Availability__c='AGO B7;IGO 50ppm;ULG95 E5';
        locSrc.Depot_MOT__c='Barge;ITT;Rail;TRuck';
        locSrc.Custom_Record_Type__c = 'Revolution';
        locSrc.Scenario_Type__c = 'Import;Export;Balanced';
        insert locSrc;
        
       //Insert Account
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Name = 'ADAM OMMERT MINERALOELHANDEL';
        acc.Customer_Type__c = 'Sold To';
        acc.Has_MRC__c = true;
        acc.IWO_Member__c=true;
        insert acc;
        
        //Material Insert
        //AGO B7- 400001685
        Product_Catalogue__c matAgo = new Product_Catalogue__c();
        matAgo.Name = '400001685';
        matAgo.Level_0__c = 'Gasoil';
        matAgo.Commodity_Grade_L2__c = 'AGO B7';
        matAgo.Material_Name__c = 'TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        matAgo.Additive_cost_EUR_100l__c=0.1;
        matAgo.Dyeing_cost_EUR_100l__c=0.3;
        matAgo.WASA_EUR_100l__c=0.4;
        insert matAgo;
        
		//IGO 50ppm -400002410 
		Product_Catalogue__c matIgo50 = new Product_Catalogue__c();       
        matIgo50.Name = '400002410';
        matIgo50.Level_0__c = 'Gasoil';
        matIgo50.Commodity_Grade_L2__c = 'IGO 50ppm';
        matIgo50.Material_Name__c = 'BF IGO 50ppmS B0 Dye Mkd Germany';
        matIgo50.Additive_cost_EUR_100l__c=0.2;
        matIgo50.Dyeing_cost_EUR_100l__c=0.1;
        matIgo50.WASA_EUR_100l__c=0.5;
        insert matIgo50;
        
        //ULG95 E5 -400001637 
		Product_Catalogue__c matUlgE5 = new Product_Catalogue__c();       
        matUlgE5.Name = '400001637';
        matUlgE5.Level_0__c = 'Gasoline';
        matUlgE5.Commodity_Grade_L2__c = 'ULG95 E5';
        matUlgE5.Material_Name__c = 'TP ULG 95 10ppmS E5 Udy Umk Low Dose DE';
        matUlgE5.Additive_cost_EUR_100l__c=0.3;
        matUlgE5.Dyeing_cost_EUR_100l__c=0.4;
        matUlgE5.WASA_EUR_100l__c=0.2;
        insert matUlgE5;
        
        //Insert Mrc AGO - 320076922-107004
        Id RecordTypeIdMrc = Schema.SObjectType.Mrc__c.getRecordTypeInfosByName().get('DI-Dashboard').getRecordTypeId();
        Mrc__c mrAgo= new Mrc__c();
        mrAgo.Name='000000000-100050';
        mrAgo.RecordTypeId=RecordTypeIdMrc;
        mrAgo.Sold_To__c=acc.Id;
        mrAgo.Plant__c=loc.Id;
        mrAgo.Sales_Organization__c='DE01';
        mrAgo.Handling_Type__c='EB';
        mrAgo.PO_Type__c='TSFP';
        mrAgo.Product__c=matAgo.Id;
  		mrAgo.Shipping_Condition__c=10;
        mrAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrAgo.Valid_From_Date__c=system.today().addDays(-100);
        insert mrAgo;
        
      //Insert Mrc IGO - 321492213-120004 
        Mrc__c mrIgo= new Mrc__c();
        mrIgo.Name='000000000-100051';
        mrIgo.RecordTypeId=RecordTypeIdMrc;
        mrIgo.Sold_To__c=acc.Id;
        mrIgo.Plant__c=loc.Id;
        mrIgo.Sales_Organization__c='DE01';
        mrIgo.Handling_Type__c='EB';
        mrIgo.PO_Type__c='TSFP';
        mrIgo.Product__c=matIgo50.Id;
  		mrIgo.Shipping_Condition__c=10;
        mrIgo.Valid_To_Date__c=system.today().addDays(1000);
        mrIgo.Valid_From_Date__c=system.today().addDays(-100);
        insert mrIgo;
      
        //Insert Mrc ULG95 E5 - 321751875-103004
        Mrc__c mrUlg= new Mrc__c();
        mrUlg.Name='000000000-100052';
        mrUlg.RecordTypeId=RecordTypeIdMrc;
        mrUlg.Sold_To__c=acc.Id;
        mrUlg.Plant__c=loc.Id;
        mrUlg.Sales_Organization__c='DE01';
        mrUlg.Handling_Type__c='EB';
        mrUlg.PO_Type__c='TSFP';
        mrUlg.Product__c=matUlgE5.Id;
  		mrUlg.Shipping_Condition__c=10;
        mrUlg.Valid_To_Date__c=system.today().addDays(1000);
        mrUlg.Valid_From_Date__c=system.today().addDays(-100);
        insert mrUlg;

        List<Mrc__C> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                           Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                       Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                           Ship_to_Name__c,Shipping_Condition__c from MRC__c];
       
        //Freight Rate
        Freight_Rate__c routeAgo= new Freight_Rate__c(); 
        routeAgo=RV_TestHelperPhase2.insertFreightRate(routeAgo, locSrc, loc);
        routeAgo.Route_Utilization__c=100;
        routeAgo.Bio_Split__c=false;
        routeAgo.Third_Party__c=false;
        insert routeAgo;
        
        Freight_Rate__c routeIgo= new Freight_Rate__c();
        routeIgo=RV_TestHelperPhase2.insertFreightRate(routeIgo, locSrc, loc);
        routeIgo.Route_Utilization__c=100;
        routeIgo.Standard_Grade__c='IGO 50ppm';
        routeIgo.SubGrade_3P__c='IGO 50ppm';
        routeIgo.Bio_Split__c=false;
        routeIgo.Third_Party__c=false;
        insert routeIgo;
        
        Freight_Rate__c routeUlg= new Freight_Rate__c();
        routeUlg=RV_TestHelperPhase2.insertFreightRate(routeUlg, locSrc, loc);
        routeUlg.Route_Utilization__c=100;
        routeUlg.Standard_Grade__c='ULG95 E5';
        routeUlg.SubGrade_3P__c='ULG95 E5';
        routeUlg.Bio_Split__c=false;
        routeUlg.Third_Party__c=true;
        insert routeUlg;
        
        
        //Location Steer
        Id RecordTypeIdLocStrSrc = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        Id RecordTypeIdLocStrDep = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
        
        Location_Steer__c locSrcStrAgo = new Location_Steer__c();
        locSrcStrAgo=RV_TestHelperPhase2.insertsrcSteer(locSrcStrAgo,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrAgo.Scenario_Value__c=11;
        locSrcStrAgo.Manual_Adjustment__c=1;
        insert locSrcStrAgo;
        
        Location_Steer__c locSrcStrIgo = new Location_Steer__c();
        locSrcStrIgo=RV_TestHelperPhase2.insertsrcSteer1(locSrcStrIgo,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrIgo.Scenario_Value__c=12;
        locSrcStrIgo.Manual_Adjustment__c=1;
        insert locSrcStrIgo;
        
        Location_Steer__c locSrcStrUlg = new Location_Steer__c();
        locSrcStrUlg=RV_TestHelperPhase2.insertsrcSteer2(locSrcStrUlg,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrUlg.Scenario_Value__c=10;
        locSrcStrUlg.Manual_Adjustment__c=1;
        insert locSrcStrUlg;
        
        Location_Steer__c locDepStrAgo = new Location_Steer__c();
        locDepStrAgo=RV_TestHelperPhase2.insertsrcSteer(locDepStrAgo,RecordTypeIdLocStrDep,loc);
        locDepStrAgo.MOT__c='Truck';
        locDepStrAgo.Depot_Steer__c=10;
        locDepStrAgo.Scenario__c='';
        insert locDepStrAgo;
        
        Location_Steer__c locDepStrIgo = new Location_Steer__c();
        locDepStrIgo=RV_TestHelperPhase2.insertsrcSteer1(locDepStrIgo,RecordTypeIdLocStrDep,loc);
        locDepStrIgo.MOT__c='Truck';
        locDepStrIgo.Depot_Steer__c=11;
        locDepStrIgo.Scenario__c='';
        insert locDepStrIgo;
        
        Location_Steer__c locDepStrUlg = new Location_Steer__c();
        locDepStrUlg=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlg,RecordTypeIdLocStrDep,loc);
        locDepStrUlg.MOT__c='Truck';
        locDepStrUlg.Depot_Steer__c=12;
        locDepStrUlg.Scenario__c='';
        insert locDepStrUlg;
        
        Location_Steer__c locDepStrUlgOverRdn = new Location_Steer__c();
        locDepStrUlgOverRdn=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlgOverRdn,RecordTypeIdLocStrDep,loc);
        locDepStrUlgOverRdn.MOT__c='Truck';
        locDepStrUlgOverRdn.Depot_Steer__c=12;
        locDepStrUlgOverRdn.Scenario__c='';
        locDepStrUlgOverRdn.Valid_From__c=system.today().addDays(1);
        locDepStrUlgOverRdn.Valid_To__c=system.today().addDays(13);
        insert locDepStrUlgOverRdn;
        
        //BioAmv
        Bio_AMVs__c bio= new Bio_AMVs__c();
        bio=RV_TestHelperPhase2.insertBioAmv(bio,loc);
        insert bio;
        
        
        
        //Throughput
        Throughput__c thputAgo= new Throughput__c();
        thputAgo=RV_TestHelperPhase2.insertThroughput(thputAgo,loc);
        insert thputAgo;
        
        Throughput__c thputIgo= new Throughput__c();
        thputIgo=RV_TestHelperPhase2.insertThroughput(thputIgo,loc);
        thputIgo.Standard_grade__c='IGO 50ppm';
        thputIgo.Product_Sub_Grade__c='IGO 50ppm';
        insert thputIgo;
        
        Throughput__c thputUlg= new Throughput__c();
        thputUlg=RV_TestHelperPhase2.insertThroughput(thputUlg,loc);
        thputUlg.Standard_grade__c='ULG95 E5';
        thputUlg.Product_Sub_Grade__c='ULG95 E5';
        insert thputUlg;
        
        //Margin
        Id RecordTypeIdMarginTruck = Schema.SObjectType.Margin__c.getRecordTypeInfosByName().get('Truck/ITT').getRecordTypeId();
        Margin__c mgn = new Margin__c();
		mgn=RV_TestHelperPhase2.insertMargin(mgn,loc,RecordTypeIdMarginTruck);
        insert mgn;
        
        Margin__c mgnOverriden = new Margin__c();
        mgnOverriden=RV_TestHelperPhase2.insertMargin(mgnOverriden,loc,RecordTypeIdMarginTruck); 
        mgnOverriden.Valid_From__c=system.today().addDays(1);
        mgnOverriden.Valid_To__c=system.today().addDays(12);
        insert mgnOverriden;  
        String dashboardRT = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();

        Revolution_Dashboard__c revDashboard = new Revolution_Dashboard__c();
        revDashboard.Plant_Name__c = loc.Id;
        revDashboard.RecordTypeId = dashboardRT;
        revDashboard.Sales_Channel__c = 'DE01';
        //AdditionalTestCoverage_12Jun2019_Soumyajit starts
        //revDashboard.UniqueKey__c = 'DE01'+revDashboard.Plant_Name__c+'10.0';
        revDashboard.UniqueKey__c = 'DE01'+revDashboard.Plant_Name__c+'10';
        //AdditionalTestCoverage_12Jun2019_Soumyajit ends
        revDashboard.MOT__c = 'Truck';
        revDashboard.BSP_IGO__c = 34;
        revDashboard.PSP_IGO__c = 45;
        revDashboard.OTM_IGO__c = 55;
        revDashboard.ATP1_Live_IGO__c = 1000;
        revDashboard.ATP2_Live_IGO__c = 1000;
        revDashboard.ATP3_Live_IGO__c = 1000;
        
        revDashboard.BSP_AGO__c = 40;
        revDashboard.PSP_AGO__c = 43;
        revDashboard.OTM_AGO__c = 58;
        revDashboard.ATP1_Live_AGO__c = 1003;
        revDashboard.ATP2_Live_AGO__c = 1000;
        revDashboard.ATP3_Live_AGO__c = 1000;
        
        revDashboard.BSP_MOGAS__c = 37;
        revDashboard.PSP_MOGAS__c = 49;
        revDashboard.OTM_MOGAS__c = 56;
         
        revDashboard.ATP1_Live_MOGAS__c = 1004;
        revDashboard.ATP2_Live_AGO__c = 1000;
        revDashboard.ATP3_Live_AGO__c = 1000;
         
        insert revDashboard;
        
        System.debug('-----revDashboard------'+revDashboard);
        
    }
    
    
    //Test method for Snapshot Batch(4 hours)
    @isTest static void testMethodDIDashboardSnapshotBatch() {
        List<Revolution_Dashboard__c> bioAMV = [SELECT Id,Plant_Name__c,RecordTypeId,BSP_IGO__c,PSP_IGO__c,
                                     OTM_IGO__c,ATP1_Live_IGO__c,BSP_AGO__c,PSP_AGO__c,OTM_AGO__c,ATP1_Live_AGO__c,
                                      BSP_MOGAS__c,PSP_MOGAS__c,OTM_MOGAS__c,ATP1_Live_MOGAS__c FROM Revolution_Dashboard__c];
         RV_DI_Dashboard_Snapshot diDashboardbatch = new RV_DI_Dashboard_Snapshot();
         database.executeBatch(diDashboardbatch);
    }
    
     //Test method for DI Dashboard Batch(30 seconds)
    @isTest static void testMethodDIDashboardBatch() {
        List<MRC__c> mrcList = [select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                           Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                       Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                           Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        List<Revolution_Dashboard__c> revDashboard = [SELECT Id,Plant_Name__c,RecordTypeId,BSP_IGO__c,PSP_IGO__c,
                                     OTM_IGO__c,ATP1_Live_IGO__c,BSP_AGO__c,PSP_AGO__c,OTM_AGO__c,ATP1_Live_AGO__c,
                                      BSP_MOGAS__c,PSP_MOGAS__c,OTM_MOGAS__c,ATP1_Live_MOGAS__c FROM Revolution_Dashboard__c];
         RV_DI_DashboardBatch diDashboardbatch = new RV_DI_DashboardBatch();
         database.executeBatch(diDashboardbatch);
    }
    
    @isTest static void testMethodDIDashControllerFuture() {
        List<MRC__c> mrcList = [select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                           Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                       Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                           Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        System.debug('------mrcList-----'+mrcList);
        List<Revolution_Dashboard__c> revDashboardLst = [SELECT Id,UniqueKey__c,Plant_Name__c,RecordTypeId,BSP_IGO__c,PSP_IGO__c,
                                     OTM_IGO__c,ATP1_Live_IGO__c,BSP_AGO__c,PSP_AGO__c,OTM_AGO__c,ATP1_Live_AGO__c,
                                      BSP_MOGAS__c,PSP_MOGAS__c,OTM_MOGAS__c,ATP1_Live_MOGAS__c FROM Revolution_Dashboard__c];
        System.debug('------revDashboardLst----'+revDashboardLst); 
        String channel = 'DE01';
         String channelName = apexpages.currentpage().getparameters().put('channel' , channel);
         String  motName    = ApexPages.currentPage().getParameters().put('mot','Truck');
         String  startDate   = ApexPages.currentPage().getParameters().put('contractStartDate',String.valueof(System.today()));
         String  endDate     = ApexPages.currentPage().getParameters().put('contractEndDate',String.valueof(System.today().addDays(15)));
         String  showLocType = ApexPages.currentPage().getParameters().put('showLocType','myLoc');
         String  taxType     = ApexPages.currentPage().getParameters().put('taxType','Untaxed');
        Test.startTest(); //AdditionalTestCoverage_12Jun2019_Soumyajit
         RV_DIDashboardControllerFuture futureController = new RV_DIDashboardControllerFuture();
         futureController.refreshedTime = '';
         futureController.refreshPage();
        Test.stopTest(); //AdditionalTestCoverage_12Jun2019_Soumyajit
    }
    
    @isTest static void testMethodDIDashControllerFuture1() {
        List<Revolution_Dashboard__c> bioAMV = [SELECT Id,Plant_Name__c,RecordTypeId,BSP_IGO__c,PSP_IGO__c,
                                     OTM_IGO__c,ATP1_Live_IGO__c,BSP_AGO__c,PSP_AGO__c,OTM_AGO__c,ATP1_Live_AGO__c,
                                      BSP_MOGAS__c,PSP_MOGAS__c,OTM_MOGAS__c,ATP1_Live_MOGAS__c FROM Revolution_Dashboard__c];
         String channel = 'DE01';
         String channelName = apexpages.currentpage().getparameters().put('channel' , channel);
         String  motName    = ApexPages.currentPage().getParameters().put('mot','Truck');
         String  startDate   = ApexPages.currentPage().getParameters().put('contractStartDate',String.valueof(System.today().addDays(15)));
         String  endDate     = ApexPages.currentPage().getParameters().put('contractEndDate',String.valueof(System.today().addDays(28)));
         String  showLocType = ApexPages.currentPage().getParameters().put('showLocType','myLoc');
         String  taxType     = ApexPages.currentPage().getParameters().put('taxType','Taxed');
         RV_DIDashboardControllerFuture futureController = new RV_DIDashboardControllerFuture();
         futureController.refreshedTime = '';
         futureController.refreshPage();
    }
    @isTest static void testMethodDIDashControllerFuture2() {
        List<Revolution_Dashboard__c> bioAMV = [SELECT Id,Plant_Name__c,RecordTypeId,BSP_IGO__c,PSP_IGO__c,
                                     OTM_IGO__c,ATP1_Live_IGO__c,BSP_AGO__c,PSP_AGO__c,OTM_AGO__c,ATP1_Live_AGO__c,
                                      BSP_MOGAS__c,PSP_MOGAS__c,OTM_MOGAS__c,ATP1_Live_MOGAS__c FROM Revolution_Dashboard__c];
         String channel = 'DE01';
         String channelName = apexpages.currentpage().getparameters().put('channel' , channel);
         String  motName    = ApexPages.currentPage().getParameters().put('mot','Truck');
         String  startDate   = ApexPages.currentPage().getParameters().put('contractStartDate',String.valueof(System.today().addDays(29)));
         String  endDate     = ApexPages.currentPage().getParameters().put('contractEndDate',String.valueof(System.today().addDays(42)));
         String  showLocType = ApexPages.currentPage().getParameters().put('showLocType','myLoc');
         String  taxType     = ApexPages.currentPage().getParameters().put('taxType','Untaxed');
         RV_DIDashboardControllerFuture futureController = new RV_DIDashboardControllerFuture();
         futureController.refreshedTime = '';
         futureController.refreshPage();
    }
    //AdditionalTestCoverage_12Jun2019_Soumyajit starts 
    @isTest static void testMethodDIDashControllerFuture3() {
        Test.startTest();
        List<Revolution_Dashboard__c> bioAMV = [SELECT Id,Plant_Name__c,RecordTypeId,BSP_IGO__c,PSP_IGO__c,
                                     OTM_IGO__c,ATP1_Live_IGO__c,BSP_AGO__c,PSP_AGO__c,OTM_AGO__c,ATP1_Live_AGO__c,
                                      BSP_MOGAS__c,PSP_MOGAS__c,OTM_MOGAS__c,ATP1_Live_MOGAS__c FROM Revolution_Dashboard__c];

         String channelName = apexpages.currentpage().getparameters().put('channel' , 'AT01,DE01');
         String  motName    = ApexPages.currentPage().getParameters().put('mot','Truck,Rail');
         String  startDate   = ApexPages.currentPage().getParameters().put('contractStartDate',String.valueof(System.today().addDays(29)));
         String  endDate     = ApexPages.currentPage().getParameters().put('contractEndDate',String.valueof(System.today().addDays(42)));
         String  showLocType = ApexPages.currentPage().getParameters().put('showLocType','myLoc');
         String  taxType     = ApexPages.currentPage().getParameters().put('taxType','Taxed');
         
         RV_DIDashboardControllerFuture futureController = new RV_DIDashboardControllerFuture();
         futureController.taxType = 'Taxed';
         futureController.refreshedTime = '';
         futureController.refreshPage();
         futureController.getRefreshedTime();
         futureController.setRefreshedTime('');
        Test.stopTest();
    }
    //AdditionalTestCoverage_12Jun2019_Soumyajit ends 
    
}