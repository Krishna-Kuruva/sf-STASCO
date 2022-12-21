@isTest
public class Rv_DIDashboardControllerTest {
    
       @testSetup 
        static void setup() {
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
        EUUSDCurrency.Column__c = '';
        EUUSDCurrency.Display_Name__c = '';
        EUUSDCurrency.Frequency__c = 'Live';
        EUUSDCurrency.Price__c = 0.9914;
        EUUSDCurrency.RecordTypeId = dashboardRT;
        productDifferentialLst.add(EUUSDCurrency);
        
        Product_Differential__c prdctDiffeurope = new Product_Differential__c();
        prdctDiffeurope.Name = 'Europe_ECB_USD_to_EURO (Daily Spot)[USD/t]';
        prdctDiffeurope.Column__c = 'Left2';
        prdctDiffeurope.Display_Name__c = '€/$ fixing';
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
        prdctDiffnymexrbobGas.Name = 'NYMEX RBOB Gasoline (Ask)';
        prdctDiffnymexrbobGas.Column__c = 'Right2';
        prdctDiffnymexrbobGas.Display_Name__c = 'RBOB live cnt/gal';
        prdctDiffnymexrbobGas.Frequency__c = 'Live';
        prdctDiffnymexrbobGas.Price__c = 2.0718;
        prdctDiffnymexrbobGas.RecordTypeId = dashboardRT;
        productDifferentialLst.add(prdctDiffnymexrbobGas);
        
        insert productDifferentialLst;
    }
    
	@isTest
    static void testMethod1(){         
        Profile objProfile = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        User objUser = [Select Id, ProfileId from User where Id=: UserInfo.getUserId()];
        objUser.My_DE_Locations__c = 'D004';
        objUser.My_AT_Locations__c ='';
        List<String> channel= new List<String>();
        channel.add('DE01');
        List<String> MOT= new List<String>();
        MOT.add('Truck');
        
        system.runAs(objUser){
            test.startTest();
            Rv_DIDashboardController.getATPPriceforDashboard(channel,MOT,'myLoc','Taxed',false);
            Rv_DIDashboardController.getATPPriceforDashboard(channel,MOT,'All','Taxed',false);
            Rv_DIDashboardController.getATPPriceforDashboard(channel,MOT,'All','Taxed',true);
            Rv_DIDashboardController.getSessionId();
            test.stopTest();
        }
        
    }
}