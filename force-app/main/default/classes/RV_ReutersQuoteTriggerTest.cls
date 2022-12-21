@isTest
public class RV_ReutersQuoteTriggerTest {
	
    public static void productDiff()
    {
         String dashboardRT = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
        List<Product_Differential__c> productDifferentialLst=new List<Product_Differential__c>();
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
        insert productDifferentialLst;
    }
    
    
    @testSetup 
    static void setup() {
        productDiff();
        //create custom setting data 
        Reuters_ICE_Calculation__c setting = new Reuters_ICE_Calculation__c();
		setting.Name = 'LGO';
        setting.Display_Name__c = 'ICE LCO Brent Crude Oil (Ask)';
        setting.ProdDiff_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
		setting.Quote_Name__c = 'ICE LCO Brent Crude Oil';
        setting.Product_Differential__c=true;
        setting.frequency__c = 'Live';
        insert setting;
        
         setting = new Reuters_ICE_Calculation__c();
		setting.Name = 'LGO';
        setting.Display_Name__c = 'Reuters (PJK) Rhine Freight Gasoil ARA-Cologne (Mean)';
     //   setting.ProdDiff_Display_Name__c='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne (Mean)';
		setting.Quote_Name__c = 'Reuters (PJK) Rhine Freight Gasoil ARA-Cologne (Mean)';
       // setting.Product_Differential__c=true;
        setting.frequency__c = 'Daily';
        insert setting;
        
        
                setting = new Reuters_ICE_Calculation__c();
		setting.Name = 'LGO';
        setting.Display_Name__c = 'ICE LCO Brent Crude Oil (Ask)';
        setting.ProdDiff_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
		setting.Quote_Name__c = 'Brent Crude';
        setting.Product_Differential__c=true;
        setting.frequency__c = 'Live';
        insert setting;
        
        Reuters_ICE_Calculation__c setting1 = new Reuters_ICE_Calculation__c();
		setting1.Name = 'PJK05';
        setting1.Display_Name__c = 'GELT_Barge_IGO_NL_Rotterdam_to_CH_Basle_FR (Daily Spot)[CHF/t]';
		setting1.Quote_Name__c = 'Reuters (PJK) Rhine Freight Gasoil ARA-BasleSFR';
        setting.Product_Differential__c=true;
        setting1.Gelt_Other_Currency__c=true;
        setting1.frequency__c = 'Daily';
        insert setting1;
        
        Reuters_ICE_Calculation__c setting2 = new Reuters_ICE_Calculation__c();
		setting2.Name = 'PJK06';
        setting2.Quote_Name__c = 'GELT_Barge_IGO_NL_Rotterdam_to_DE_Karlsruhe_FR (Daily Spot)[EUR/t]';
		setting2.Display_Name__c = 'Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        setting2.frequency__c = 'Daily';
        insert setting2;
        
        
          Reuters_Quotes__c objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='Brent Crude EOD';
        objBrentEOD.Quote_Display_Name__c='ICE LCO Brent Crude Oil';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        objBrentEOD.Unit_Of_Measure__c = 'L';
        insert objBrentEOD;
        
       
        
        Reuters_Quotes__c objGELTPast = new Reuters_Quotes__c();
        objGELTPast.Quote_Display_Name__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        objGELTPast.Quote_Name__c ='GELT_Barge_IGO_NL_Rotterdam_to_DE_Karlsruhe_FR (Daily Spot)[EUR/t]';
        objGELTPast.CurrencyCode__c ='EUR';
        objGELTPast.Price__c = 21.23;
        objGELTPast.Unit_Of_Measure__c = 'T';
        insert objGELTPast;
        Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(objGELTPast.Id, yesterday);
    }
    
   
public static void createReutersData()
{
     Reuters_Quotes__c objGELT = new Reuters_Quotes__c();
        objGELT.Quote_Name__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        objGELT.Quote_Display_Name__c ='GELT_Barge_IGO_NL_Rotterdam_to_DE_Karlsruhe_FR (Daily Spot)[EUR/t]';
        objGELT.CurrencyCode__c ='EUR';
        objGELT.Price__c = 21.23;
        objGELT.Unit_Of_Measure__c = 'T';
      
        
    
    
        //LIVE Exchange
        Reuters_Quotes__c objEXLive1GLETCurrEU = new Reuters_Quotes__c();
        objEXLive1GLETCurrEU.Quote_Name__c='EU/USD Currency';
        objEXLive1GLETCurrEU.Quote_Display_Name__c='EUR/USD';
        objEXLive1GLETCurrEU.CurrencyCode__c ='EU';
        objEXLive1GLETCurrEU.Price__c = 1.23;
        objEXLive1GLETCurrEU.Unit_Of_Measure__c = 'US';
       
        //LIVE Exchange
        Reuters_Quotes__c objEXLive1GLETCurr = new Reuters_Quotes__c();
        objEXLive1GLETCurr.Quote_Name__c='CHF/USD Currency';
        objEXLive1GLETCurr.Quote_Display_Name__c='EUR/CHF';
        objEXLive1GLETCurr.CurrencyCode__c ='CHF';
        objEXLive1GLETCurr.Price__c = 1.27;
        objEXLive1GLETCurr.Unit_Of_Measure__c = 'US';
       List<Reuters_Quotes__c> rutersList=new List<Reuters_Quotes__c>();
        rutersList.add(objEXLive1GLETCurr);
        rutersList.add(objEXLive1GLETCurrEU);
        rutersList.add(objGELT);
        
        insert rutersList;
        
        Reuters_Quotes__c objGELT2 = new Reuters_Quotes__c();
        objGELT2.Quote_Name__c='GELT_Barge_IGO_NL_Rotterdam_to_DE_Karlsruhe_FR (Daily Spot)[EUR/t]';
        objGELT2.Quote_Display_Name__c ='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        objGELT2.CurrencyCode__c ='EUR';
        objGELT2.Price__c = 21.23;
        objGELT2.Unit_Of_Measure__c = 'T';
        insert objGELT2;
    
         objGELT2 = new Reuters_Quotes__c();
        objGELT2.Quote_Name__c='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne';
        objGELT2.Quote_Display_Name__c ='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne';
        objGELT2.CurrencyCode__c ='EUR';
        objGELT2.Price__c = 21.23;
        objGELT2.Unit_Of_Measure__c = 'T';
        insert objGELT2;
    
    
    
      objGELT2 = new Reuters_Quotes__c();
        objGELT2.Quote_Name__c='Argus Biodiesel RED FAME -10°C CFPP FOB ARA (mean)';
        objGELT2.Quote_Display_Name__c ='Argus Biodiesel RED FAME -10°C CFPP FOB ARA (mean)';
        objGELT2.CurrencyCode__c ='EUR';
        objGELT2.Price__c = 21.23;
        objGELT2.Unit_Of_Measure__c = 'T';
        insert objGELT2;
        
   
    
    
        //EOD
        Reuters_Quotes__c objBrentEOD = new Reuters_Quotes__c();
        objBrentEOD.Quote_Name__c='Brent Crude EOD';
        objBrentEOD.Quote_Display_Name__c='ICE LCO Brent Crude Oil';
        objBrentEOD.CurrencyCode__c ='USD';
        objBrentEOD.Price__c = 21.23;
        
        objBrentEOD.Unit_Of_Measure__c = 'L';
        insert objBrentEOD;
        //LIVE Exchange
        Reuters_Quotes__c objEXLive = new Reuters_Quotes__c();
        objEXLive.Quote_Name__c='EU/USD Currency';
        objEXLive.Quote_Display_Name__c='EUR/USD';
        objEXLive.CurrencyCode__c ='EU';
        objEXLive.Price__c = 1.23;
        objEXLive.Unit_Of_Measure__c = 'US';
        insert objEXLive;
        //LIVE Exchange
        Reuters_Quotes__c objEXLive1 = new Reuters_Quotes__c();
        objEXLive1.Quote_Name__c='CHF/USD Currency';
        objEXLive1.Quote_Display_Name__c='EUR/CHF';
        objEXLive1.CurrencyCode__c ='CHF';
        objEXLive1.Price__c = 1.27;
        objEXLive1.Unit_Of_Measure__c = 'US';
        insert objEXLive1;
        
        Reuters_Quotes__c objLive = new Reuters_Quotes__c();
        objLive.Quote_Name__c='Brent Crude';
        objLive.Quote_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objLive.CurrencyCode__c ='EU';
        objLive.Price__c = 1.23;
        objLive.Unit_Of_Measure__c = 'US';
        objLive.Valid_From_Date__c=System.today()-2;
        objLive.Valid_To_Date__c=System.today()+5;
        //objLive.Valid_From_Date__c = system.now();
        objLive.Valid_Month__c = 'MAY18';
        //objLive.Valid_To_Date__c = system.now();
        insert objLive;
   
           objLive = new Reuters_Quotes__c();
        objLive.Quote_Name__c='Brent Crude';
        objLive.Quote_Display_Name__c='ICE LCO Brent Crude Oil (Ask)';
        objLive.CurrencyCode__c ='EU';
        objLive.Price__c = 1.23;
        objLive.Unit_Of_Measure__c = 'US';
        objLive.Valid_From_Date__c=System.today()-2;
        objLive.Valid_To_Date__c=System.today()+5;
        //objLive.Valid_From_Date__c = system.now();
        objLive.Valid_Month__c = 'MAY18';
        //objLive.Valid_To_Date__c = system.now();
        insert objLive;
    
    	//Fix_403664_06Jan2020_Soumyajit starts
    	objLive = new Reuters_Quotes__c();
        objLive.Quote_Name__c='Platts';
        objLive.Quote_Display_Name__c='Platts CIF Cargo NWE Gasoline 10ppm (high)';
        objLive.CurrencyCode__c ='EU';
        objLive.Price__c = 1;
        objLive.Unit_Of_Measure__c = 'US';
        objLive.Valid_From_Date__c=System.today();
        objLive.Valid_To_Date__c=System.today()+14;
        objLive.Valid_Month__c = 'JAN20';
        insert objLive;
    	//Fix_403664_06Jan2020_Soumyajit ends

}
    
    static testMethod void testTriggerInsert(){
        Test.startTest();
        createReutersData();
        Test.stopTest();
    }
}