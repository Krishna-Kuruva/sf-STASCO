/**************************************************************************************************
* Name: RE_UtilityClass
* Object: Utility Class
* Purpose: Used for Rev Lite Utility
* Author:
* Create Date:
* Modify History:
* 2023-02-03		Abhilash		Modified - Performance improvement/Error Handling PBI#1651105
* 2023-02-03        Vishal Nigam    Added exception handling process PBI#1700749
**************************************************************************************************/
public without sharing class RE_UtilityClass {
    //Creation of Country Data
    public static Country__c getCountryCode(String sCountryName)
    {
        Country__c sCountry = new Country__c(Name= sCountryName);
        insert sCountry;
        return sCountry;
    }
    //Creation of Location Data
    public static RE_Location__c getLocation(String sNames,String AbbreviateName,String sCountryName)
    {
        Country__c ssCountry =  [SELECT Id from Country__c where Name=:sCountryName];
        // Id CountryRecordTypeId = Schema.SObjectType.RE_Location__c.getRecordTypeInfosByName().get(sCountryName).getRecordTypeId();
        RE_Location__c sLocation = new RE_Location__c(RE_Abbreviated_Name__c=AbbreviateName,Name=sNames,RE_Country__c=ssCountry.Id,RE_Region_Name__c='Peninsular');
        insert sLocation;
        return sLocation;
    }
     //Creation of Location Data
    public static RE_Location__c getSabahLocation(String sNames,String AbbreviateName,String sCountryName)
    {
        Country__c ssCountry =  [SELECT Id from Country__c where Name=:sCountryName];
        // Id CountryRecordTypeId = Schema.SObjectType.RE_Location__c.getRecordTypeInfosByName().get(sCountryName).getRecordTypeId();
        RE_Location__c sLocation = new RE_Location__c(RE_Abbreviated_Name__c=AbbreviateName,Name=sNames,RE_Country__c=ssCountry.Id,RE_Region_Name__c='Sabah');
        insert sLocation;
        return sLocation;
    }
    //Creation of Product Data
    public static RE_Product__c getProduct(String sName,String sCountryNme, String unit)
    {
        Country__c sCountryName = [SELECT Id,Name from Country__c where Name=:sCountryNme];
         Id ProductRecordTypeId= Schema.SObjectType.RE_Product__c.getRecordTypeInfosByName().get(sCountryName.Name).getRecordTypeId();
        RE_Product__c sProduct = new RE_Product__c(Name=sName,RE_Country__c=sCountryName.Id,RE_Additive_Cost_Unit__c=unit,RE_Additive_Cost__c=34.576,recordtypeId=ProductRecordTypeId);
        insert sProduct;
        return sProduct;
    }
    //Creation of MarketQuotes Data
    public static RE_Market_Quotes__c getMarketQuotes(Decimal sPrice,String sRateUnit,String sEnergyUnit,String sQuoteName)//sEnergyUnit value has not been assigned to any field(of no use)
    {
        RE_Market_Quotes__c sMarketQuote = new RE_Market_Quotes__c(RE_Price__c=sPrice,RE_Rate_Unit__c=sRateUnit,RE_Quote_Name__c=sQuoteName,RE_Pricing_Date__c = System.Today(),RE_Quote_Type__c='Settlement',RE_Country_Name__c = 'SG;PH;TH;MY');
        insert sMarketQuote;
        return sMarketQuote;
    }
    //Creation of MarketQuotes Data
    public static RE_Market_Quotes__c getMarketQuotes(Decimal sPrice,String sRateUnit,String sEnergyUnit,String sQuoteName,String sTracker)//sEnergyUnit value has not been assigned to any field(of no use)
    {
        RE_Market_Quotes__c sMarketQuote = new RE_Market_Quotes__c(RE_Price__c=sPrice,RE_Rate_Unit__c=sRateUnit,RE_Quote_Name__c=sQuoteName,RE_Pricing_Date__c = System.Today(),RE_Tracker__c = sTracker,RE_Country_Name__c = 'SG;PH;TH;MY');
        insert sMarketQuote;
        return sMarketQuote;
    }
    //Creation of MarketQuotes Data
    public static RE_Market_Quotes__c getMarketQuotesold(Decimal sPrice,String sRateUnit,String sEnergyUnit,String sQuoteName)//sEnergyUnit value has not been assigned to any field(of no use)
    {
        RE_Market_Quotes__c sMarketQuote = new RE_Market_Quotes__c(RE_Price__c=sPrice,RE_Rate_Unit__c=sRateUnit,RE_Quote_Name__c=sQuoteName,RE_Pricing_Date__c = System.Today()-1,RE_Country_Name__c = 'SG;PH;TH;MY');
        insert sMarketQuote;
        return sMarketQuote;
    }
    //Creation of BioQuotes Data
    public static RE_Bio_Quotes__c getBioQuotes(Decimal sPrice,String sRateUnit,String sEnergyUnit,String sQuoteName,String sCountryNme)
    {
        Country__c sCountryName= [SELECT Id from Country__c where Country__c.Name=:sCountryNme ];
        String resion='Sabah';
        resion	=	sCountryNme == 'Thailand' ? 'Thailand' : resion;
        String rctype  = Schema.SObjectType.RE_Bio_Quotes__c.getRecordTypeInfosByName().get(sCountryNme).getRecordTypeId() ;
        RE_Bio_Quotes__c sBioQuote = new RE_Bio_Quotes__c(RE_Price__c=sPrice,RE_Bio_Quotes_Name__c=sQuoteName,RE_Bio_RateUnit__c = sRateUnit,RE_Region__c=resion,RecordTypeId=rctype);
        insert sBioQuote;
        return sBioQuote;
    }
    //Creation of FXRates Data
    public static RE_FX_Rates__c createFXRecords(String sForexName, Decimal sForexRate,String sBaseUnit,String sConversionUnit,String sCountryNme,String sTracker)
    {
        Country__c sCountryName = [SELECT Name from Country__c where Country__c.Name=:sCountryNme];
        RE_FX_Rates__c sFXRates= new RE_FX_Rates__c(RE_Forex_Name__c=sForexName,
                                                    RE_Forex_Rate__c=sForexRate,
                                                    RE_Base_Unit__c=sBaseUnit,
                                                    RE_Conversion_Unit__c=sConversionUnit,
                                                    RE_Pricing_Date__c=System.now(),
                                                    RE_Trade_Type__c = 'Sell',
                                                    RE_Tracker__c = sTracker);
        insert sFXRates;
        return sFXRates;
    }
    //Creation of FXRates Data
    public static RE_FX_Rates__c createFXRecords(String sForexName, Decimal sForexRate,String sBaseUnit,String sConversionUnit,String sCountryNme)
    {
        Country__c sCountryName = [SELECT Name from Country__c where Country__c.Name=:sCountryNme];
        RE_FX_Rates__c sFXRates= new RE_FX_Rates__c(RE_Forex_Name__c=sForexName,
                                                    RE_Forex_Rate__c=sForexRate,
                                                    RE_Base_Unit__c=sBaseUnit,
                                                    RE_Conversion_Unit__c=sConversionUnit,
                                                    RE_Pricing_Date__c=System.now(),
                                                    RE_Trade_Type__c = 'Sell',
                                                    RE_Tracker__c = 'D');
        insert sFXRates;
        return sFXRates;
    }
    //Creation of FXRates Data
    public static RE_FX_Rates__c createFXRecordsYday(String sForexName, Decimal sForexRate,String sBaseUnit,String sConversionUnit,String sCountryNme)
    {
        Country__c sCountryName = [SELECT Name from Country__c where Country__c.Name=:sCountryNme];
        RE_FX_Rates__c sFXRates= new RE_FX_Rates__c(RE_Forex_Name__c=sForexName,
                                                    RE_Forex_Rate__c=sForexRate,
                                                    RE_Base_Unit__c=sBaseUnit,
                                                    RE_Conversion_Unit__c=sConversionUnit,
                                                    RE_Pricing_Date__c=System.Today()-1,
                                                    RE_Trade_Type__c = 'Sell',
                                                    RE_Tracker__c = 'D-1');
        insert sFXRates;
        return sFXRates;
    }


    //Creation of DepotPricingBackbone Data
    public static RE_Depot_Pricing_Backbone__c createDPB(String sCountry,String sLocName,String sProdName,String unit)
    {
        Country__c sCountryName = [SELECT Id,Name from Country__c where Name=:sCountry];
        // Id DPBRecordTypeId= Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByName().get(sCountryName.Name).getRecordTypeId();
        RE_Location__c sLocation = [SELECT Id from RE_Location__c where Name=:sLocName];
        RE_Product__c sProduct = [SELECT Id from RE_Product__c where Name=:sProdName];
        Id DPBRecordTypeId= Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByName().get(sCountryName.Name).getRecordTypeId();
        RE_Depot_Pricing_Backbone__c sDPB= new RE_Depot_Pricing_Backbone__c(RE_Country__c=sCountryName.Id,RE_Depot_Name__c=sLocation.Id,
                                                                            RE_Product_Name__c=sProduct.Id,RE_Final_Price_Unit__c=unit,
                                                                            RE_Valid_From__c=System.Today(),RE_Valid_To__c= System.Today(),RE_SnH_Unit__c=unit,
                                                                           RE_IsDistillisationRate__c = False,recordtypeId=DPBRecordTypeId);

        insert sDPB;
        sDPB = [SELECT RE_Backbone_Name__c,RE_Country__c,RE_Product_Name__r.Name, RE_Depot_Name__r.RE_Region_Name__c,RE_Snh_Cost__c,RE_Depot_Name__r.Name,RE_Depot_Name__c,
                RE_Product_Name__c,RE_Country__r.Name,RE_Final_Price_Unit__c,RE_IsDistillisationRate__c,RE_Fixed_Premium__c,
                RE_Primary_Transport_Cost__c,RE_Primary_Transport_Offset__c,RE_Primary_Transport_Unit__c,RE_SnH_Unit__c
        FROM  RE_Depot_Pricing_Backbone__c WHERE RE_Product_Name__r.Name =: sProdName order by createddate desc LIMIT 1];
        return sDPB;
    }

    //Creation of DepotPricingBackbone Data
    public static RE_Depot_Pricing_Backbone__c createDPBPH(String sCountry,String sLocName,String sProdName,String unit)
    {
        Country__c sCountryName = [SELECT Id,Name from Country__c where Name=:sCountry];
        // Id DPBRecordTypeId= Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByName().get(sCountryName.Name).getRecordTypeId();
        RE_Location__c sLocation = [SELECT Id from RE_Location__c where Name=:sLocName];
        RE_Product__c sProduct = [SELECT Id from RE_Product__c where Name=:sProdName];
        Id DPBRecordTypeId= Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByName().get(sCountryName.Name).getRecordTypeId();
        RE_Depot_Pricing_Backbone__c sDPB= new RE_Depot_Pricing_Backbone__c(RE_Country__c=sCountryName.Id,RE_Depot_Name__c=sLocation.Id,
                                                                            RE_Product_Name__c=sProduct.Id,RE_Final_Price_Unit__c=unit,
                                                                            RE_Valid_From__c=System.Today(),RE_Valid_To__c= System.Today(),RE_SnH_Unit__c=unit,
                                                                           RE_IsDistillisationRate__c = False,recordtypeId=DPBRecordTypeId);
        insert sDPB;
        return sDPB;
    }
    //Creation of Route Backbone Data
    public static RE_Route_Backbone__c createRouteBackbone(String sCountryNme,String sProdName,String sSource,String sDestination,Decimal sSteer,String sSteerUnit)
    {
        Country__c sCountryName = [SELECT Id from Country__c where Country__c.Name=:sCountryNme];
        RE_Location__c sSrce    = [SELECT Id from RE_Location__c where RE_Location__c.Name=:sSource];
        RE_Location__c sDstn    = [SELECT Id from RE_Location__c where RE_Location__c.Name=:sDestination];
        RE_Product__c sProduct  = [SELECT Id from RE_Product__c where Name=:sProdName];
        Id rectypeId = Schema.SObjectType.RE_Route_Backbone__c.getRecordTypeInfosByDeveloperName().get(sCountryNme).getRecordTypeId();
        RE_Route_Backbone__c sRBdata= new RE_Route_Backbone__c(RE_Country__c=sCountryName.Id,RE_Destination_Name__c=sDstn.Id,
                                                               RE_Source_Name__c=sSrce.Id,RE_Product_Name__c=sProduct.Id,RE_CO_Steer__c=sSteer,
                                                               RE_MY_CO_Steer_Unit__c=sSteerUnit,RE_Valid_From__c=System.Today(),
                                                               RE_Valid_To__c= System.Today(),RE_Route_Utilization__c=72, RecordtypeId = rectypeId);
        insert sRBdata;
        return sRBdata;
    }

    //Creation based Costing Data
     public static RE_Route_Based_Costing__c routeBasedCosting(Boolean sIsLatest)
     {
         RE_Route_Based_Costing__c sRBCostingdata= new RE_Route_Based_Costing__c(RE_IsLatest__c=sIsLatest);
         insert sRBCostingdata;
         return sRBCostingdata;
     }

    //Creation of RE_Malaysian_Formula_Table__mdt
    public static List<RE_Malaysian_Formula_Table__mdt> getMFTinput()
    {
        return(
            [SELECT RE_MY_Bio_Loss_Percentage__c,RE_MY_Bio_Quote_1__c,RE_MY_Bio_Quote_2__c,
             RE_MY_Bio_Quote_3__c,RE_MY_Bio_Quote_Percentage__c,RE_MY_BreakBulk_Premium_Quote_Percentage__c,RE_MY_BreakBulk_Premium_Quote__c,
             RE_MY_HCV_Quote_Percentage__c,RE_MY_HCV_Quote__c,RE_MY_HCV_Surcharges__c,RE_MY_Market_Premium_Percentage__c,RE_MY_Fixed_Premium_Unit__c,
             RE_MY_Market_Premium_Quote__c,RE_MY_Oil_Loss_Percentage__c,RE_MY_Plant__c,RE_MY_Product__c,RE_MY_Region__c,RE_MY_Fixed_Premium__c,
             RE_MY_Small_lot_percentage__c,RE_MY_Small_lot_premium_Unit__c,RE_MY_Small_lot_premium__c,RE_MY_TP_Premium_Percentage__c,
             RE_MY_TP_Premium__c,RE_MY_MR_Cost_Percentage__c,RE_MY_MR_Demurrage_Unit__c,RE_MY_MR_Demurrage__c,RE_MY_MR_Frieght_Quote__c,
             RE_MY_Port_Charges__c,RE_MY_Port_Charges_Unit__c,RE_MY_Valid_From__c,RE_MY_Valid_To__c,RE_MY_TP_Premium_Unit__c
             FROM RE_Malaysian_Formula_Table__mdt

            ]);
    }
    //Creation of Singapore formula data from metadata
    public static List<RE_SG_Cost_Price_Manager__mdt> fetchSingaporeformulaData(){
        return(
            [SELECT RE_SG_HCV_Quote_1_Percent__c,RE_SG_HCV_Quote_1__c,RE_SG_HCV_Quote_2_Percent__c,RE_SG_HCV_Quote_2__c,
             RE_SG_Market_Premium_Percent__c,RE_SG_Market_Premium_Quote__c,RE_SG_Oil_Loss_Percent__c,RE_SG_Plant__c,RE_SG_Product__c,
             RE_SG_Valid_From__c, RE_SG_Valid_To__c,RE_SG_Dist_Disc_Quote__c, RE_SG_Dist_Disc_Percentage__c
             FROM RE_SG_Cost_Price_Manager__mdt
             WHERE RE_SG_Valid_From__c <= Today
             AND RE_SG_Valid_To__c >= Today
            ]);

    }
      //Fetch Custom Setting Data For Rate Conversion
        public static void fetchRateUnitData(){
        List<RE_Rate_Unit_Manager__c> reUnitMagrCustSetting = new List<RE_Rate_Unit_Manager__c>();
        RE_Rate_Unit_Manager__c reUnitMagrCustSetting1 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting1.Name = 'USD/BBL';
        reUnitMagrCustSetting1.RE_Currency_Unit__c= 'USD';
        reUnitMagrCustSetting1.RE_Rate_Unit__c= 'USD/BBL';
        reUnitMagrCustSetting1.RE_Volume_Unit__c='BBL';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting1);

        RE_Rate_Unit_Manager__c reUnitMagrCustSetting2 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting2.Name = 'MYR CTS/LTR';
        reUnitMagrCustSetting2.RE_Currency_Unit__c= 'MYR CTS';
        reUnitMagrCustSetting2.RE_Rate_Unit__c= 'MYR CTS/LTR';
        reUnitMagrCustSetting2.RE_Volume_Unit__c='LTR';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting2);

        RE_Rate_Unit_Manager__c reUnitMagrCustSetting3 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting3.Name = 'MYR/TON';
        reUnitMagrCustSetting3.RE_Currency_Unit__c= 'MYR';
        reUnitMagrCustSetting3.RE_Rate_Unit__c= 'MYR/TON';
        reUnitMagrCustSetting3.RE_Volume_Unit__c='TON';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting3);

        RE_Rate_Unit_Manager__c reUnitMagrCustSetting4 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting4.Name = 'USD CTS/LTR';
        reUnitMagrCustSetting4.RE_Currency_Unit__c=     'USD CTS';
        reUnitMagrCustSetting4.RE_Rate_Unit__c= 'USD CTS/LTR';
        reUnitMagrCustSetting4.RE_Volume_Unit__c='LTR';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting4);

        RE_Rate_Unit_Manager__c reUnitMagrCustSetting5 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting5.Name = 'SGD CTS/LTR';
        reUnitMagrCustSetting5.RE_Currency_Unit__c=     'SGD CTS';
        reUnitMagrCustSetting5.RE_Rate_Unit__c= 'SGD CTS/LTR';
        reUnitMagrCustSetting5.RE_Volume_Unit__c='LTR';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting5);


        RE_Rate_Unit_Manager__c reUnitMagrCustSetting6 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting6.Name = 'THB/LTR';
        reUnitMagrCustSetting6.RE_Currency_Unit__c= 'THB';
        reUnitMagrCustSetting6.RE_Rate_Unit__c= 'THB/LTR';
        reUnitMagrCustSetting6.RE_Volume_Unit__c='LTR';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting6);
        RE_Rate_Unit_Manager__c reUnitMagrCustSetting7 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting7.Name = 'STG/LTR';
        reUnitMagrCustSetting7.RE_Currency_Unit__c= 'STG';
        reUnitMagrCustSetting7.RE_Rate_Unit__c= 'THB/LTR';
        reUnitMagrCustSetting7.RE_Volume_Unit__c='LTR';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting7);
        RE_Rate_Unit_Manager__c reUnitMagrCustSetting8 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting8.Name = 'PHP/LTR';
        reUnitMagrCustSetting8.RE_Currency_Unit__c= 'PHP';
        reUnitMagrCustSetting8.RE_Rate_Unit__c= 'PHP/LTR';
        reUnitMagrCustSetting8.RE_Volume_Unit__c='LTR';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting8);
        RE_Rate_Unit_Manager__c reUnitMagrCustSetting9 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting9.Name = 'PHP/TON';
        reUnitMagrCustSetting9.RE_Currency_Unit__c= 'PHP';
        reUnitMagrCustSetting9.RE_Rate_Unit__c= 'PHP/TON';
        reUnitMagrCustSetting9.RE_Volume_Unit__c='TON';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting9);
        RE_Rate_Unit_Manager__c reUnitMagrCustSetting10 = new RE_Rate_Unit_Manager__c();
        reUnitMagrCustSetting10.Name = 'USD/TON';
        reUnitMagrCustSetting10.RE_Currency_Unit__c= 'USD';
        reUnitMagrCustSetting10.RE_Rate_Unit__c= 'USD/TON';
        reUnitMagrCustSetting10.RE_Volume_Unit__c='TON';
        reUnitMagrCustSetting.add(reUnitMagrCustSetting10);
        insert reUnitMagrCustSetting;

     }
        //Fetch Custom Setting Data For Volume Conversion
        public static void fetchVolumeConversionData(){
        List<RE_MY_VolumeConversion__c> reVolumeConversion = new List<RE_MY_VolumeConversion__c>();
        RE_MY_VolumeConversion__c reVolumeCustSetting =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting.Name = 'VCU-1';
        reVolumeCustSetting.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting.RE_MY_Conversion_Rate__c = 1157.0000;
        reVolumeCustSetting.RE_MY_Country__c = 'Malaysia';
        reVolumeCustSetting.RE_MY_Volume_Unit__c = 'TON';
        reVolumeCustSetting.RE_MY_Product_Subgroup__c = 'Gasoil B7 0.05% S';
        reVolumeConversion.add(reVolumeCustSetting);
        RE_MY_VolumeConversion__c reVolumeCustSetting1 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting1.Name = 'VCU-2';
        reVolumeCustSetting1.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting1.RE_MY_Conversion_Rate__c = 1157.0000;
        reVolumeCustSetting1.RE_MY_Country__c = 'Singapore';
        reVolumeCustSetting1.RE_MY_Volume_Unit__c = 'TON';
        reVolumeCustSetting1.RE_MY_Product_Subgroup__c = 'Gasoil B7 0.05% S';
        reVolumeConversion.add(reVolumeCustSetting1);
        RE_MY_VolumeConversion__c reVolumeCustSetting2 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting2.Name = 'VCU-3';
        reVolumeCustSetting2.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting2.RE_MY_Conversion_Rate__c = 115.0000;
        reVolumeCustSetting2.RE_MY_Country__c = 'Malaysia';
        reVolumeCustSetting2.RE_MY_Volume_Unit__c = 'BBL';
        reVolumeConversion.add(reVolumeCustSetting2);
        RE_MY_VolumeConversion__c reVolumeCustSetting3 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting3.Name = 'VCU-4';
        reVolumeCustSetting3.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting3.RE_MY_Conversion_Rate__c = 115.0000;
        reVolumeCustSetting3.RE_MY_Country__c = 'Singapore';
        reVolumeCustSetting3.RE_MY_Volume_Unit__c = 'BBL';
        reVolumeConversion.add(reVolumeCustSetting3);
        RE_MY_VolumeConversion__c reVolumeCustSetting4 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting4.Name = 'VCU-5';
        reVolumeCustSetting4.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting4.RE_MY_Conversion_Rate__c = 1157.0000;
        reVolumeCustSetting4.RE_MY_Country__c = 'Malaysia';
        reVolumeCustSetting4.RE_MY_Volume_Unit__c = 'TON';
        reVolumeCustSetting4.RE_MY_Product_Subgroup__c = 'Biofuel';
        reVolumeConversion.add(reVolumeCustSetting4);

        RE_MY_VolumeConversion__c reVolumeCustSetting5 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting5.Name = 'VCU-6';
        reVolumeCustSetting5.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting5.RE_MY_Conversion_Rate__c = 158.9873;
        reVolumeCustSetting5.RE_MY_Country__c = 'Thailand';
        reVolumeCustSetting5.RE_MY_Volume_Unit__c = 'BBL';
        reVolumeConversion.add(reVolumeCustSetting5);
        RE_MY_VolumeConversion__c reVolumeCustSetting6 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting6.Name = 'VCU-7';
        reVolumeCustSetting6.RE_MY_Base_Volume_Unit__c = 'BBL';
        reVolumeCustSetting6.RE_MY_Conversion_Rate__c = 6.5585;
        reVolumeCustSetting6.RE_MY_Country__c = 'Thailand';
        reVolumeCustSetting6.RE_MY_Volume_Unit__c = 'TON';
        reVolumeCustSetting6.RE_MY_Product_Subgroup__c = 'Marine FuelOil 180';
        reVolumeConversion.add(reVolumeCustSetting6);
        RE_MY_VolumeConversion__c reVolumeCustSetting7 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting7.Name = 'VCU-8';
        reVolumeCustSetting7.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting7.RE_MY_Conversion_Rate__c = 158.9873;
        reVolumeCustSetting7.RE_MY_Country__c = 'Philippines';
        reVolumeCustSetting7.RE_MY_Volume_Unit__c = 'BBL';
        reVolumeConversion.add(reVolumeCustSetting7);
        RE_MY_VolumeConversion__c reVolumeCustSetting8 =  new RE_MY_VolumeConversion__c();
        reVolumeCustSetting8.Name = 'VCU-9';
        reVolumeCustSetting8.RE_MY_Base_Volume_Unit__c = 'LTR';
        reVolumeCustSetting8.RE_MY_Conversion_Rate__c = 1234;
        reVolumeCustSetting8.RE_MY_Country__c = 'Philippines';
        reVolumeCustSetting8.RE_MY_Volume_Unit__c = 'TON';
        reVolumeCustSetting8.RE_MY_Product_Subgroup__c = 'KERO';
        reVolumeConversion.add(reVolumeCustSetting8);
        insert reVolumeConversion;
     }

     public static RE_SG_CostPrice__c getCostPrice(){
        RE_SG_CostPrice__c  ob= new RE_SG_CostPrice__c (RE_Job_Run_Count__c=9,RE_Pricing_Date__c=System.Today());
        insert ob;
        return ob;
     }

     public static List<RE_MY_Output__c> getMYOutput(){
         List<RE_MY_Output__c> ls = new List<RE_MY_Output__c>();
        ls.add(new RE_MY_Output__c(RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78,RE_Region__c='Peninsular',RE_Job_Run_Count__c=0));
        ls.add(new RE_MY_Output__c(RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78,RE_Region__c='Sarawak',RE_Job_Run_Count__c=0));
        ls.add(new RE_MY_Output__c(RE_Gasoil_B7_0_05_S_LDC_Diff__c=156.78,RE_Region__c='Sabah',RE_Job_Run_Count__c=0));
        ls.add(new RE_MY_Output__c(RE_TH_AWD_DIFF__c=56.78, RE_TH_AWD_LDC__c = 231.21,RE_Region__c='Thailand',RE_Type__c= 'Thailand Output',RE_Job_Run_Count__c=0,RE_Pricing_Date__c= System.Today()));
        insert ls;
        return ls;
     }
    public static void weeklydatacreate(){
        List<RE_Weekly_Data__c> weeklyData = new List<RE_Weekly_Data__c>();
        RE_Weekly_Data__c weeklyData1 = new RE_Weekly_Data__c();
        weeklyData1.Name ='WD-0001';
        weeklyData1.RE_Month__c ='Dec';
        weeklyData1.RE_Valid_From__c = System.Today();
        weeklyData1.RE_Valid_To__c = System.Today()+5;
        weeklyData1.RE_Week_End_Date__c = System.Today()+5;
        weeklyData1.RE_Week_Number__c = '5';
        weeklyData1.RE_Week_Start_Date__c =System.Today();
        weeklyData1.RE_Year__c ='2019';
        weeklyData.add(weeklyData1);
        insert weeklyData;
    }

    public static void gainlosscreate(){
        RE_Gain_Loss_Audit__c glaudit = new RE_Gain_Loss_Audit__c();
        glaudit.RE_MOPS_Name__c = 'Gasoil 0.05% S';
        glaudit.RE_Type__c = 'D';
        glaudit.RE_WeekAverage__c = 3.67;
        glaudit.RE_MonthlyAverage__c = 33.6;
        insert glaudit;
    }

    //customer creation MY customer Opps
    public Static Account createcustomer(String Name,String CustomerType,String AccNumber,String AccType,String ParentAccID,String RecordType ){
        Account acc = new Account();
        acc.Name=Name;
        acc.Customer_Type__c=CustomerType;
        acc.AccountNumber = AccNumber;
        acc.Type=AccType;
        acc.RT_Active__c=true;
        acc.RecordTypeId=RecordType;
        if(ParentAccID != null && ParentAccID !='')
            acc.RE_Parent_Customer__c = ParentAccID;

        insert acc;

        return acc;
    }

    //Contract creation for MY customer Opps
    public Static REV_Contract_Master__c createcontract(string customerID,String country,String calculationConfig,String plant,String material,string salesOrg){
        REV_Contract_Master__c contrct = new REV_Contract_Master__c();
        contrct.RE_Customer_Name__c = customerID;
        contrct.Country_Name__c = country;
        contrct.RE_Custom_Ops_Calculation__c = calculationConfig;
        contrct.RT_Plant_Desc__c	= plant;
        contrct.RT_Material_Desc__c = material;
        contrct.Active__c = true;
        contrct.RT_Valid_From__c= system.today();
        contrct.RT_Valid_To__c = system.today().addMonths(3);
        contrct.RE_Sales_Org__c = salesOrg;
        contrct.RE_PH_Approval_Scheme__c = 'Malaysia Approval Scheme';

        insert contrct;
        return contrct;
    }
    //Configuration Table for calculation logic MY customer Opps
    public Static RE_Custom_Ops_Configuration__c creatConfig(String Name,String Country){
        RE_Custom_Ops_Configuration__c Config = new RE_Custom_Ops_Configuration__c();
        Config.Name=Name;
        Config.RE_Country__c=Country;
        Config.RE_Editable_Field__c='RE_Final_Price_Rebate__c';

        insert Config;
        return Config;
    }


    //Custom setting data creation for MY customer Opps access control
    public static RE_Customer_Opps__c creatAccessCon(String Name){
        RE_Customer_Opps__c accessContrl= new RE_Customer_Opps__c();
        accessContrl.Name=Name;
        accessContrl.RE_Approved__c=true;
        accessContrl.RE_Auto_Approved__c=true;
        accessContrl.RE_Not_Submitted__c = false;
        accessContrl.RE_Ready_to_Upload__c = true;
        accessContrl.RE_Rejected__c = true;
        accessContrl.RE_Submitted__c = false;
        accessContrl.Email_ID__c ='test@gmail.com';

        insert accessContrl;

        return accessContrl;
    }

    //Custom setting data creation for Report generation
    public static RE_CustomOpps_ReportConfiguration__c createReportConfig(String customerType,String region,string name){
        RE_CustomOpps_ReportConfiguration__c reportConfig = new RE_CustomOpps_ReportConfiguration__c();
        reportConfig.Name=name;
        reportConfig.RE_Application__c='V';
        reportConfig.RE_Calculation_Type__c='C';
        reportConfig.RE_Condition_Table__c='623';
        reportConfig.RE_Condition_Usage_Table__c='A';
        reportConfig.RE_Customer_Type__c=customerType;
        reportConfig.RE_Data_Type__c='RE_List_Price__c';
        reportConfig.RE_Quantity__c='100';
        reportConfig.RE_Region__c=region;
        reportConfig.RE_Scale_Type__c='A';
        reportConfig.RE_Unit__c='MYR';
        reportConfig.RE_UoM__c='L';
        reportConfig.RE_Is_Active__c = true;
        reportConfig.RE_Country_Name__c = 'Malaysia';
        reportConfig.RE_Varkey__c='RE_Sales_Org__c+RE_Customer_Group__c+RT_Location_Code__c+000000000+RE_Material_Code__c';

        Insert reportConfig;
        return reportConfig;
    }

    // User for storing RevLite exceptions into RV_Exception Object.
    public static String reInsertExceptionRecord(String errorType, String className,String methodName,String getErrorMessage,String  getStatusCode){
        String returnMsg = 'Success';
        try{
            RV_Exception__c rvExcep = new RV_Exception__c();
            rvExcep.Type__c = errorType;
            rvExcep.Apex_Class__c = className;
            rvExcep.Method_Name__c = methodName;
            rvExcep.RV_GetExceptionMessage__c = getErrorMessage;
            rvExcep.Status_Code__c = getStatusCode;
            insert rvExcep;
        }
        catch(Exception e){
            returnMsg = 'Failure';
        }

        return returnMsg;
    }

    // User for storing list of RevLite exceptions into RV_Exception Object.
    public static String reInsertExceptionRecord(List<RV_Exception__c> excpList){
        String returnMsg = 'Success';
        if(excpList.size()>0){
            try{
                insert excpList;
            }
            catch(Exception e){
                returnMsg = 'Failure';
            }
        }
        return returnMsg;
    }

    // Handling database upsert opertaion
    public static ProcessedCountWrapper reHandleUpsertRequest(String className,String methodName,Database.UpsertResult[] upsertResult,RE_Job_Run_Audit__c jobRunAudit)
    {
        ProcessedCountWrapper pcWrppr = New ProcessedCountWrapper();
        Integer successCount = 0;
        Integer failureCount = 0;

        List<RV_Exception__c> exceptionRecords = new List<RV_Exception__c>();
        for(Database.UpsertResult sr : upsertResult){
            if(sr.isSuccess()){
                successCount++;
            }
            else{
                failureCount++;
                for(Database.Error err : sr.getErrors()) {
                    exceptionRecords.add(new RV_Exception__c(
                        Type__c = 'Exception',
                        Apex_Class__c = className,
                        Method_Name__c = methodName,
                        Status_Code__c = String.valueof(err.getStatusCode()),
                        RV_GetExceptionMessage__c = jobRunAudit?.Id + '- Error-->' + err.getMessage()
                    ));
                }
            }
        }

        pcWrppr.successCount = successCount;
        pcWrppr.failureCount = failureCount;

        if(exceptionRecords.size()>0){
            reInsertExceptionRecord(exceptionRecords);
        }

        return pcWrppr;
    }

    public class ProcessedCountWrapper
    {
        public Integer successCount;
        public Integer failureCount;
    }

    public static string exceptionMessageFormatter(exception ex){
        return 'Message: ' + ex.getMessage() + ' Line: '+ex.getLineNumber() + ' Trace: '+ex.getStackTraceString();
    }

    public static Integer jobRunCount(String jobType){
        List<RE_Job_Run_Audit__c> lstMaxJobRunCount = [SELECT Id, RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c WHERE CreatedDate = TODAY and RE_Job_Type__c =: jobType ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        return lstMaxJobRunCount.isEmpty() ? 0 : Integer.valueOf(lstMaxJobRunCount[0].RE_Job_Run_Count__c) + 1;
    }


    //returns the status for the given job run audit id
    @auraEnabled
    public static map<string,string> checkJobRunStatus(Id jrId){
        map<string,string> resultmap = new map<string,string>();
        RE_Job_Run_Audit__c jra = [select RE_Job_Status__c,RE_Exception__c from RE_Job_Run_Audit__c where Id =:jrId];
        resultmap.put('Status',jra.RE_Job_Status__c);
        return resultmap;
    }

    //returns any existing job for the given job run audit Type
    @auraEnabled
    public static map<string,string> checkExistingJob(string jobType){
        map<string,string> resultmap = new map<string,string>();
        list<RE_Job_Run_Audit__c> jra_lst = new list<RE_Job_Run_Audit__c>();
        jra_lst = [select Name,createdDate from RE_Job_Run_Audit__c where
                   RE_Job_Type__c =:jobType and createdDate=today AND
                   RE_Job_Status__c = 'Processing' order by createdDate desc];
        if(jra_lst.size() > 0){
        	resultmap.put('ExistingJob','True');
            DateTime dt = jra_lst[0].createddate;
            resultmap.put('CreatedDate',dt.formatGmt('MMM dd, yyyy HH:mm'));
            resultmap.put('JobName',jra_lst[0].Name);
        } else{
            resultmap.put('ExistingJob','False');
        }
        return resultmap;
    }
}