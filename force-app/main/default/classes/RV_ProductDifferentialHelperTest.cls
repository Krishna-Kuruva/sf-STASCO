/*****************************************************************************
@Name:  RV_ProductDifferentialHelperTest     
@=========================================================================
@Purpose: Test class for Product Differential functionality
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/08/2018         INITIAL DEVELOPMENT

******************************************************************************/
@isTest
private class RV_ProductDifferentialHelperTest {

    @testSetup static void setup() {
        List<ProductDifferentialDashboard__mdt> prodctDiffLst = [select id,Plant_Code__c,Quote_Name1__c,Quote_Name2__c,
                                                                 Quote_Name3__c,Quote_Name4__c,Quote_Type__c,Type__c 
                                                                 from ProductDifferentialDashboard__mdt	where Type__c='Product Differential'];
        List<ProductDifferentialDashboard__mdt> quoteNameLst  = [select id,Plant_Code__c,Quote_Name1__c,Quote_Name2__c,
                                                                 Quote_Name3__c,Quote_Name4__c,Quote_Type__c,Type__c 
                                                                 from ProductDifferentialDashboard__mdt	where Type__c='Quote Name'];
        
        Location__c loc = new Location__c();        
        loc.Name = 'Harburg Zenith depot';
        loc.Plant_Code__c = 'D228';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'North';
        loc.Sales_Region__c = 'North';
        loc.Location_Type__c = 'Shell Own Location';
        loc.Region_Name__c = 'North';
        loc.Products_Availability__c = 'AGO B7;IGO 50ppm;ULG95 E5';
        loc.Custom_Record_Type__c = 'Infokiosk';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        insert loc;
        
        Bio_AMVs__c bioAMV = new Bio_AMVs__c();
        bioAMV.Sales_Org__c = 'DE01';
        bioAMV.Plant__c = loc.Id;
        bioAMV.Frequency__c = 'Daily';
        bioAMV.AGO_B7_m_Prompt__c = 19.20;
        bioAMV.ULG_95_E5_m_Prompt__c = 8.60;
        bioAMV.ULG_95_E10_m_Prompt__c = -0.25;
        bioAMV.ULG_98_m_Prompt__c = 5;
        insert bioAMV;
        
        Location__c locGodorf = new Location__c();        
        locGodorf.Name = 'Godorf Shell gantry';
        locGodorf.Plant_Code__c = 'D229';
        locGodorf.Source_Location__c = true;
        locGodorf.Company_Code__c = 'DE01';
        locGodorf.OMR_Region__c = 'West';
        locGodorf.Sales_Region__c = 'West';
        locGodorf.Location_Type__c = 'Shell Own Location';
        locGodorf.Region_Name__c = 'West';
        locGodorf.Products_Availability__c = 'AGO B7;IGO 50ppm;ULG95 E5';
        locGodorf.Custom_Record_Type__c = 'Infokiosk';
        locGodorf.Scenario_Type__c = 'Import;Export;Balanced';
        insert locGodorf;
    	
        Bio_AMVs__c bioAMVGodorf = new Bio_AMVs__c();
        bioAMVGodorf.Sales_Org__c = 'DE01';
        bioAMVGodorf.Plant__c = locGodorf.Id;
        bioAMVGodorf.Frequency__c = 'Daily';
        bioAMVGodorf.AGO_B7_m_Prompt__c = 19.20;
        bioAMVGodorf.ULG_95_E5_m_Prompt__c = 8.60;
        bioAMVGodorf.ULG_95_E10_m_Prompt__c = -0.25;
        bioAMVGodorf.ULG_98_m_Prompt__c = 5;
        insert bioAMVGodorf;
		String revdashboardRT = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();

		Revolution_Dashboard__c revDashboard = new Revolution_Dashboard__c();
        revDashboard.Plant_Name__c = locGodorf.Id;
        revDashboard.RecordTypeId = revdashboardRT;
        revDashboard.Sales_Channel__c = 'DE01';
        revDashboard.UniqueKey__c = 'DE01'+revDashboard.Plant_Name__c+'10.0';
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
        
        String dashboardRT = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
		List<Product_Differential__c> productDifferentialLst = new List<Product_Differential__c>();
        
        Product_Differential__c prdctDiffBrentCrude = new Product_Differential__c();
        prdctDiffBrentCrude.Name = 'Brent Crude EOD';
        prdctDiffBrentCrude.Column__c = 'Right1';
        prdctDiffBrentCrude.Display_Name__c = 'Brent 16:30 $/bbl';
        prdctDiffBrentCrude.Frequency__c = 'Daily';
        prdctDiffBrentCrude.Price__c = 84.8900;
        prdctDiffBrentCrude.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffBrentCrude);
        
        Product_Differential__c chfUSDcurrency = new Product_Differential__c();
        chfUSDcurrency.Name = 'CHF/USD Currency';
        chfUSDcurrency.Column__c = '';
        chfUSDcurrency.Display_Name__c = '';
        chfUSDcurrency.Frequency__c = 'Live';
        chfUSDcurrency.Price__c = 0.9914;
        chfUSDcurrency.RecordTypeId = dashboardRT;
        productDifferentialLst.add(chfUSDcurrency);
        
        Product_Differential__c EUUSDCurrency = new Product_Differential__c();
        EUUSDCurrency.Name = 'EU/USD Currency';
        EUUSDCurrency.Column__c = 'Left2';
        EUUSDCurrency.Display_Name__c = Label.RV_Live_Euro_to_USD;
        EUUSDCurrency.Frequency__c = 'Live';
        EUUSDCurrency.Price__c = 0.9914;
        EUUSDCurrency.RecordTypeId = dashboardRT;
        productDifferentialLst.add(EUUSDCurrency);
        
        Product_Differential__c prdctDiffeurope = new Product_Differential__c();
        prdctDiffeurope.Name = 'Europe_ECB_USD_to_EURO (Daily Spot)[USD/t]';
        prdctDiffeurope.Column__c = 'Left2';
        prdctDiffeurope.Display_Name__c = Label.RV_Euro_to_USD_Fixing;
        prdctDiffeurope.Frequency__c = 'Daily';
        prdctDiffeurope.Price__c = 1.1634;
        prdctDiffeurope.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffeurope);
        
        Product_Differential__c prdctDifflondon = new Product_Differential__c();
        prdctDifflondon.Name = 'EUSCAN_London_1630_ULSD_M_P (Daily Spot)[USD/t]';
        prdctDifflondon.Column__c = 'Left1';
        prdctDifflondon.Display_Name__c = 'ICE 16:30 yesterday $/to';
        prdctDifflondon.Frequency__c = 'Daily';
        prdctDifflondon.Price__c = 741.2500;
        prdctDifflondon.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDifflondon);
        
        Product_Differential__c prdctDiffago = new Product_Differential__c();
        prdctDiffago.Name = 'EUSCAN_NWE_CIF_Cargo_AGO_10ppm_12.5kt_Spot_H (Daily Spot)[USD/t]';
        prdctDiffago.Column__c = '';
        prdctDiffago.Display_Name__c = 'Platts CIF Cargo NWE ULSD 10ppm (high)';
        prdctDiffago.Frequency__c = 'Daily';
        prdctDiffago.Price__c = 741.2500;
        prdctDiffago.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffago);
        
        Product_Differential__c prdctDiffagospot = new Product_Differential__c();
        prdctDiffagospot.Name = 'EUSCAN_Rdam_FOB_Barge_AGO_10ppm_Spot_H (Daily Spot)[USD/t]';
        prdctDiffagospot.Column__c = '';
        prdctDiffagospot.Display_Name__c = 'Platts FOB Barge R\'/dam Diesel 10ppm (high)';
        prdctDiffagospot.Frequency__c = 'Daily';
        prdctDiffagospot.Price__c = 741.5000;
        prdctDiffagospot.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffagospot);
        
        Product_Differential__c prdctDiffeurobob = new Product_Differential__c();
        prdctDiffeurobob.Name = 'EUSCAN_Rdam_FOB_Barge_EuroBOB_Spot_H (Daily Spot)[USD/t]';
        prdctDiffeurobob.Column__c = '';
        prdctDiffeurobob.Display_Name__c = 'Eurobob 16:30 $/to';
        prdctDiffeurobob.Frequency__c = 'Daily';
        prdctDiffeurobob.Price__c = 730.2500;
        prdctDiffeurobob.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffeurobob);
        
        Product_Differential__c prdctDiffigoSpot = new Product_Differential__c();
        prdctDiffigoSpot.Name = 'EUSCAN_Rdam_FOB_Barge_IGO_0.1pct_Spot_H (Daily Spot)[USD/t]';
        prdctDiffigoSpot.Column__c = '';
        prdctDiffigoSpot.Display_Name__c = 'Platts FOB Barge R\'/dam Gasoil 0.1% (high)';
        prdctDiffigoSpot.Frequency__c = 'Daily';
        prdctDiffigoSpot.Price__c = 731.5000;
        prdctDiffigoSpot.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffigoSpot);
        
        Product_Differential__c prdctDiffigo50Spot = new Product_Differential__c();
        prdctDiffigo50Spot.Name = 'EUSCAN_Rdam_FOB_Barge_IGO_50ppm_Spot_H (Daily Spot)[USD/t]';
        prdctDiffigo50Spot.Column__c = '';
        prdctDiffigo50Spot.Display_Name__c = 'Platts FOB Barge R\'/dam Gasoil 50ppm (high)';
        prdctDiffigo50Spot.Frequency__c = 'Daily';
        prdctDiffigo50Spot.Price__c = 739.7500;
        prdctDiffigo50Spot.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffigo50Spot);
        
        Product_Differential__c prdctDiffICELCO = new Product_Differential__c();
        prdctDiffICELCO.Name = 'ICE LCO Brent Crude Oil (Ask)';
        prdctDiffICELCO.Column__c = 'Right1';
        prdctDiffICELCO.Display_Name__c = 'Brent Live $/bbl';
        prdctDiffICELCO.Frequency__c = 'Live';
        prdctDiffICELCO.Price__c = 83.1200;
        prdctDiffICELCO.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffICELCO);
        
        Product_Differential__c prdctDiffIceRBOB = new Product_Differential__c();
        prdctDiffIceRBOB.Name = 'NYMEX RBOB Gasoline (Ask)';
        prdctDiffIceRBOB.Column__c = 'Right1';
        prdctDiffIceRBOB.Display_Name__c = 'RBOB live cnt/gal';
        prdctDiffIceRBOB.Frequency__c = 'Live';
        prdctDiffIceRBOB.Price__c = 83.1200;
        prdctDiffIceRBOB.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffIceRBOB);
        
        Product_Differential__c prdctDiffICELCOsulfur = new Product_Differential__c();
        prdctDiffICELCOsulfur.Name = 'ICE LGO Low Sulfur Gasoil (Ask)';
        prdctDiffICELCOsulfur.Column__c = 'Left1';
        prdctDiffICELCOsulfur.Display_Name__c = 'ICE Price Live $/to';
        prdctDiffICELCOsulfur.Frequency__c = 'Live';
        prdctDiffICELCOsulfur.Price__c = 729;
        prdctDiffICELCOsulfur.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffICELCOsulfur);
        
        Product_Differential__c prdctDiffnymexrbob = new Product_Differential__c();
        prdctDiffnymexrbob.Name = 'NYMEX RBOB (unleaded gasoline) EOD';
        prdctDiffnymexrbob.Column__c = 'Right2';
        prdctDiffnymexrbob.Display_Name__c = 'RBOB 16:30 cnt/gal';
        prdctDiffnymexrbob.Frequency__c = 'daily';
        prdctDiffnymexrbob.Price__c = 2.1011;
        prdctDiffnymexrbob.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffnymexrbob);
        
        Product_Differential__c prdctDiffnymexrbobGas = new Product_Differential__c();
        prdctDiffnymexrbobGas.Name = 'ICE LGO Low Sulfur Gasoil (Ask)';
        prdctDiffnymexrbobGas.Column__c = 'Right2';
        prdctDiffnymexrbobGas.Display_Name__c = 'RBOB live cnt/gal';
        prdctDiffnymexrbobGas.Frequency__c = 'Live';
        prdctDiffnymexrbobGas.Price__c = 2.0718;
        prdctDiffnymexrbobGas.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffnymexrbobGas);
        
        Product_Differential__c prdctDiffAgoIgoHcvLive = new Product_Differential__c();
        prdctDiffAgoIgoHcvLive.Name = 'Wesseling AGO/IGO HCV Live';
        prdctDiffAgoIgoHcvLive.Column__c = 'Right2';
        prdctDiffAgoIgoHcvLive.Display_Name__c = 'Wesseling AGO/IGO HCV Live';
        prdctDiffAgoIgoHcvLive.Frequency__c = 'Live';
        prdctDiffAgoIgoHcvLive.Price__c = 2.0718;
        prdctDiffAgoIgoHcvLive.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffAgoIgoHcvLive);
        
        Product_Differential__c prdctDiffMogasHcvLive = new Product_Differential__c();
        prdctDiffMogasHcvLive.Name = 'Wesseling MOGAS HCV Live';
        prdctDiffMogasHcvLive.Column__c = 'Right2';
        prdctDiffMogasHcvLive.Display_Name__c = 'Wesseling MOGAS HCV Live';
        prdctDiffMogasHcvLive.Frequency__c = 'Live';
        prdctDiffMogasHcvLive.Price__c = 2.0718;
        prdctDiffMogasHcvLive.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffMogasHcvLive);
        
        Product_Differential__c prdctDiffMogasHcvLivesecond = new Product_Differential__c();
        prdctDiffMogasHcvLivesecond.Name = 'Wesseling AGO/IGO HCV Live';
        prdctDiffMogasHcvLivesecond.Column__c = 'Right2';
        prdctDiffMogasHcvLivesecond.Display_Name__c = 'Wesseling AGO/IGO HCV Live';
        prdctDiffMogasHcvLivesecond.Frequency__c = 'Live';
        prdctDiffMogasHcvLivesecond.Price__c = 2.0718;
        prdctDiffMogasHcvLivesecond.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffMogasHcvLivesecond);
        
        Product_Differential__c prdctDiffAGOIGOHCV = new Product_Differential__c();
        prdctDiffAGOIGOHCV.Name = 'AGO/IGO Live vs 8:00 €/100l';
        prdctDiffAGOIGOHCV.Column__c = 'Left1';
        prdctDiffAGOIGOHCV.Display_Name__c = 'AGO/IGO Live vs 8:00 €/100l';
        prdctDiffAGOIGOHCV.Frequency__c = 'Live';
        prdctDiffAGOIGOHCV.Price__c = 83.1200;
        prdctDiffAGOIGOHCV.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffAGOIGOHCV);

              
        
        insert productDifferentialLst;
        
        String snapshotdashboardRT = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Snapshot').getRecordTypeId();

        Product_Differential__c prdctDiffSnapshot1 = new Product_Differential__c();
        prdctDiffSnapshot1.Name = 'Wesseling AGO/IGO HCV 8 AM';
        prdctDiffSnapshot1.Column__c = 'Left1';
        prdctDiffSnapshot1.Display_Name__c = 'Wesseling AGO/IGO HCV 8 AM';
        prdctDiffSnapshot1.Frequency__c = 'Live';
        prdctDiffSnapshot1.Price__c = 83.1200;
        prdctDiffSnapshot1.RecordTypeId = snapshotdashboardRT;
        insert prdctDiffSnapshot1;
        
        Product_Differential__c prdctDiffSnapshot = new Product_Differential__c();
        prdctDiffSnapshot.Name = 'Wesseling AGO/IGO HCV 8 AM';
        prdctDiffSnapshot.Column__c = 'Left1';
        prdctDiffSnapshot.Display_Name__c = 'ICE Price Live $/to';
        prdctDiffSnapshot.Frequency__c = 'Live';
        prdctDiffSnapshot.Price__c = 83.1200;
        prdctDiffSnapshot.RecordTypeId = snapshotdashboardRT;
        insert prdctDiffSnapshot;
        
        Product_Differential__c prdctDiffMOGASLive = new Product_Differential__c();
        prdctDiffMOGASLive.Name = 'Wesseling MOGAS HCV 8 AM';
        prdctDiffMOGASLive.Column__c = 'Left1';
        prdctDiffMOGASLive.Display_Name__c = 'Wesseling MOGAS HCV 8 AM';
        prdctDiffMOGASLive.Frequency__c = 'Live';
        prdctDiffMOGASLive.Price__c = 83.1200;
        prdctDiffMOGASLive.RecordTypeId = snapshotdashboardRT;
        productDifferentialLst.add(prdctDiffMOGASLive);  
        
        //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit starts
        Location__c  locWesseling = new Location__c(name='TestLocation',Plant_Code__c = 'D230');
        insert locWesseling;
        System.debug('location Id ::' +locWesseling);
        Id revRcdTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        Account  acc = new Account(name='TestAccount',RecordTypeId = revRcdTypId,Customer_Type__c = 'Sold To');
        insert acc;
        
        Product_Catalogue__c mat = new Product_Catalogue__c(name='000000000400001685',Commodity_Grade_L2__c='AGO B7',Level_1__c='AGO',Level_0__c='Gasoil');
        insert mat;
        
       
        
        MRC__c mrcWesselingAGO = new MRC__c(name=System.label.Rv_Wesseling_AGO_MRC_Dashboard,
                                            Sold_To__c = acc.id, Plant__c = locWesseling.id, Product__c=mat.id);
                                            
        insert mrcWesselingAGO;
        
        MRC__c mrcWesselingMOGAS = new MRC__c(name=System.label.Rv_Wesseling_MOGAS_MRC_Dashboard,
                                            Sold_To__c = acc.id, Plant__c = locWesseling.id, Product__c=mat.id);
        insert mrcWesselingMOGAS;
        
        
        //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit ends
        Freight_Rate__c freightRateInsert = new Freight_Rate__c();
        freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locWesseling, locWesseling);
        freightRateInsert.Freight_Quotation__c = 'Reuters (PJK) Rhine Freight Gasoline ARA-Karlsruhe';
        freightRateInsert.Valid_To__c = System.today();
        freightRateInsert.Valid_From__c = System.today();
        freightRateInsert.Bio_Split__c= false;
        freightRateInsert.Third_Party__c = true;
        freightRateInsert.Marker__c = 102500;
        insert freightRateInsert;
        
        Freight_Rate__c objFreightRateInsert = new Freight_Rate__c();
        objFreightRateInsert = RV_TestHelperPhase2.insertFreightRate(objFreightRateInsert, locWesseling, locWesseling);
        objFreightRateInsert.Freight_Quotation__c = 'Reuters (PJK) Rhine Freight Gasoline ARA-Karlsruhe';
        objFreightRateInsert.Valid_To__c = System.today();
        objFreightRateInsert.Valid_From__c = System.today();
        objFreightRateInsert.Bio_Split__c= false;
        objFreightRateInsert.Third_Party__c = false;
        objFreightRateInsert.Marker__c = 102500;
        insert objFreightRateInsert;        
    }
    
    //Test method for Batch
    @isTest static void testMethodProdDiffBatch() {
        List<Product_Differential__c> prodDiffLst = [SELECT Id,Name,Display_Name__c,Column__c,Frequency__c,RecordTypeId,Barges__c,Cargoes__c,Price__c FROM 
                                                     Product_Differential__c];
        Test.startTest();
        RV_DIDashboardProductDiff_Snapshot prdctdiff = new RV_DIDashboardProductDiff_Snapshot();
        database.executeBatch(prdctdiff);
        Test.stopTest();
    }
    
	//Test method for Triggers
    @isTest static void testMethodTrigger() {
        
        List<Product_Differential__c> prodDiffLst = [SELECT Id,Name,Display_Name__c,Column__c,Frequency__c,RecordTypeId,Barges__c,Cargoes__c,Price__c FROM 
                                                     Product_Differential__c];
        update prodDiffLst;   
    }
    
    //Test method for Triggers
    @isTest static void testMethodTriggerAfterUpdateTest() {
        
        List<Product_Differential__c> prodDiffLst = [SELECT Id,Name,Display_Name__c,Column__c,Frequency__c,RecordTypeId,Barges__c,Cargoes__c,Price__c FROM 
                                                     Product_Differential__c];
        for(Product_Differential__c objPD : prodDiffLst){
            objPD.Price__c = 0;
        }
        update prodDiffLst;
        
    }
    
    @isTest static void testMethoddisplaydata() {
        
        List<Product_Differential__c> prodDiffLst = [SELECT Id,Name,Barges__c,Cargoes__c,Price__c FROM 
                                                     Product_Differential__c];
         List<Revolution_Dashboard__c> revDashboardLst = [SELECT Id,UniqueKey__c,Plant_Name__c,RecordTypeId,BSP_IGO__c,PSP_IGO__c,
                                     OTM_IGO__c,ATP1_Live_IGO__c,BSP_AGO__c,PSP_AGO__c,OTM_AGO__c,ATP1_Live_AGO__c,
                                      BSP_MOGAS__c,PSP_MOGAS__c,OTM_MOGAS__c,ATP1_Live_MOGAS__c FROM Revolution_Dashboard__c];
        System.debug('------revDashboardLst----'+revDashboardLst); 
        List<String> channelLst = new List<String>{'DE01'};
        List<String> motLst = new List<String>{'Truck'};
        Rv_DIDashboardController.getATPPriceforDashboard(channelLst,motLst,String.valueof(System.today()),String.valueof(System.today().addDays(15)),true);
        
    }
    
    //Test method for Scheduler
    @isTest static void testMethodScheduler() {
        
        List<Product_Differential__c> prodDiffLst = [SELECT Id,Name,Barges__c,Cargoes__c,Price__c FROM 
                                                     Product_Differential__c];
        
        Test.StartTest();

        RV_DIDashBoardProductDiffScheduler proddiff = new RV_DIDashBoardProductDiffScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Product Differential', sch, proddiff); 
        //System.enqueueJob(new RV_DIDashboardProductDiff_Snapshot());
        Test.stopTest();
    
    }
    @isTest
    public static void calculateLiveVs8amHCVTest(){
        String dashboardRT = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByDeveloperName().get('Dashboard').getRecordTypeId();
        List<Product_Differential__c> productDifferentialLst = new List<Product_Differential__c>();
        Product_Differential__c prdctDiffAgoIgoHcvLive = new Product_Differential__c();
        prdctDiffAgoIgoHcvLive.Name = 'Wesseling AGO/IGO HCV Live';
        prdctDiffAgoIgoHcvLive.Column__c = 'Right2';
        prdctDiffAgoIgoHcvLive.Display_Name__c = 'Wesseling AGO/IGO HCV Live';
        prdctDiffAgoIgoHcvLive.Frequency__c = 'Live';
        prdctDiffAgoIgoHcvLive.Price__c = 2.0718;
        prdctDiffAgoIgoHcvLive.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffAgoIgoHcvLive);

        Product_Differential__c prdctDiffMOGASHCV8 = new Product_Differential__c();
        prdctDiffMOGASHCV8.Name = 'Wesseling MOGAS HCV 8 AM';
        prdctDiffMOGASHCV8.Column__c = 'Left1';
        prdctDiffMOGASHCV8.Display_Name__c = 'Wesseling MOGAS HCV 8 AM';
        prdctDiffMOGASHCV8.Frequency__c = 'Live';
        prdctDiffMOGASHCV8.Price__c = 83.1200;
        prdctDiffMOGASHCV8.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffMOGASHCV8);             
        insert productDifferentialLst;        
        RV_ProductDifferentialHelper.calculateLiveVs8amHCV(productDifferentialLst);
    }
    
    @isTest
    public static void calculateLiveVs8amHCVTestScenario(){
        String dashboardRT = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
		List<Product_Differential__c> productDifferentialLst = new List<Product_Differential__c>();
        Product_Differential__c EUUSDCurrency = new Product_Differential__c();
        EUUSDCurrency.Name = 'EU/USD Currency';
        EUUSDCurrency.Column__c = 'Left2';
        EUUSDCurrency.Display_Name__c = Label.RV_Live_Euro_to_USD;
        EUUSDCurrency.Frequency__c = 'Live';
        EUUSDCurrency.Price__c = 0.9914;
        EUUSDCurrency.RecordTypeId = dashboardRT;
        productDifferentialLst.add(EUUSDCurrency);  
        
        Product_Differential__c prdctDiffICELCOsulfur = new Product_Differential__c();
        prdctDiffICELCOsulfur.Name = 'ICE LGO Low Sulfur Gasoil (Ask)';
        prdctDiffICELCOsulfur.Column__c = 'Left1';
        prdctDiffICELCOsulfur.Display_Name__c = 'ICE Price Live $/to';
        prdctDiffICELCOsulfur.Frequency__c = 'Live';
        prdctDiffICELCOsulfur.Price__c = 729;
        prdctDiffICELCOsulfur.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffICELCOsulfur);
        insert productDifferentialLst;               
        RV_ProductDifferentialHelper.calculateLiveVs8amHCV(productDifferentialLst);
    }
    
    @isTest
    public static void calculateLiveVs8amHCVTestThird(){
        String dashboardRT = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByDeveloperName().get('Dashboard').getRecordTypeId();
        List<Product_Differential__c> productDifferentialLst = new List<Product_Differential__c>();
        Product_Differential__c prdctDiffAGOIGOHCV = new Product_Differential__c();
        prdctDiffAGOIGOHCV.Name = 'AGO/IGO Live vs 8:00 €/100l';
        prdctDiffAGOIGOHCV.Column__c = 'Left1';
        prdctDiffAGOIGOHCV.Display_Name__c = 'AGO/IGO Live vs 8:00 €/100l';
        prdctDiffAGOIGOHCV.Frequency__c = 'Live';
        prdctDiffAGOIGOHCV.Price__c = 83.1200;
        prdctDiffAGOIGOHCV.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffAGOIGOHCV); 

        Product_Differential__c prdctDiffMOGASLiveSecond = new Product_Differential__c();
        prdctDiffMOGASLiveSecond.Name = 'MOGAS Live vs 8:00 €/100l';
        prdctDiffMOGASLiveSecond.Column__c = 'Left1';
        prdctDiffMOGASLiveSecond.Display_Name__c = 'MOGAS Live vs 8:00 €/100l';
        prdctDiffMOGASLiveSecond.Frequency__c = 'Live';
        prdctDiffMOGASLiveSecond.Price__c = 83.1200;
        prdctDiffMOGASLiveSecond.RecordTypeId = dashboardRT; 
        productDifferentialLst.add(prdctDiffMOGASLiveSecond); 
        insert productDifferentialLst;        
        RV_ProductDifferentialHelper.calculateLiveVs8amHCV(productDifferentialLst);
    }
}