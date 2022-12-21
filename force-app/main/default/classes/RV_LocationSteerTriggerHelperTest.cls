@isTest
public class RV_LocationSteerTriggerHelperTest {
        
    static testmethod void testLocationSteer1(){
         List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,Select_CO_Steer__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt];
         System.debug('----------->'+locationSteerLst);
         
         
         String depotRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
         String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
         String orgRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Origination Steer').getRecordTypeId();
         System.debug('------depotRecordTypeId----->'+depotRecordTypeId+'--------------->'+sourceRecordTypeId+'----orgRecordTypeId-------->'+orgRecordTypeId);
         
         Location_Steer__c orgSteerARAAGO = new Location_Steer__c();
         orgSteerARAAGO = RV_TestHelperPhase2.insertorgSteerARAAGO(orgSteerARAAGO,orgRecordTypeId);
         insert orgSteerARAAGO;
         
         Location_Steer__c orgSteerARAIGO = new Location_Steer__c();
         orgSteerARAIGO = RV_TestHelperPhase2.insertorgSteerARAIGO(orgSteerARAIGO,orgRecordTypeId);
         insert orgSteerARAIGO;
         
         Location_Steer__c orgSteerHarburgAGO = new Location_Steer__c();
         orgSteerHarburgAGO = RV_TestHelperPhase2.insertorgSteerHarburgAGO(orgSteerHarburgAGO,orgRecordTypeId);
         insert orgSteerHarburgAGO;
         
         Location_Steer__c orgSteerHarburgIGO = new Location_Steer__c();
         orgSteerHarburgIGO = RV_TestHelperPhase2.insertorgSteerHarburgIGO(orgSteerHarburgIGO,orgRecordTypeId);
         insert orgSteerHarburgIGO;
         
         Location__c locinsert = new Location__c();
         locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
         locinsert.Abbreviated_Name__c = 'Ludwigshafen';
         locinsert.Source_Location__c = true;
         insert locinsert;
        
         Location__c locinsert1 = new Location__c();
         locinsert1 = RV_TestHelperPhase2.insertLocationKarlsruhe(locinsert1);
         locinsert1.Abbreviated_Name__c = 'Karlsruhe';
         locinsert1.Source_Location__c = true;
         insert locinsert1;
        
         Freight_Rate__c freightRateInsert = new Freight_Rate__c();
         freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locinsert1, locinsert);
         insert freightRateInsert;
        
         Location_Steer__c srcSteer = new Location_Steer__c();
         srcSteer = RV_TestHelperPhase2.insertsrcSteer(srcSteer,sourceRecordTypeId,locinsert);
         try{
            insert srcSteer;
         }catch(Exception de){
             
         }
        
        //AdditionalTestCoverage_12Jun2019_Soumyajit starts
        try{
            update srcSteer;
            doRecalcAllTest();
         }catch(Exception de){
             
         }
        //AdditionalTestCoverage_12Jun2019_Soumyajit ends
         
     }
    static testmethod void testLocationSteer(){
        
        List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,Select_CO_Steer__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt];
         System.debug('----------->'+locationSteerLst);
         
         
        
         String depotRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
         String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        
         Location__c locinsert1 = new Location__c();
         locinsert1 = RV_TestHelperPhase2.insertLocationKarlsruhe(locinsert1);
         locinsert1.Abbreviated_Name__c = 'Karlsruhe';
         locinsert1.Source_Location__c = true;
         insert locinsert1;
         
         Location__c locinsert = new Location__c();
         locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
         locinsert.Abbreviated_Name__c = 'Ludwigshafen';
         locinsert.Source_Location__c = true;
         insert locinsert;
         
         Freight_Rate__c freightRateInsert = new Freight_Rate__c();
         freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locinsert1, locinsert);
         insert freightRateInsert;
        
         Location_Steer__c srcSteer1 = new Location_Steer__c();
         srcSteer1 = RV_TestHelperPhase2.insertsrcSteer1(srcSteer1,sourceRecordTypeId,locinsert1);
         try{
            insert srcSteer1;
         }catch(Exception de){
             
         }
         System.debug('-------srcSteer1----'+srcSteer1);
         try{
         update srcSteer1;}
         catch(Exception e){
         
         }
     }
    static testmethod void testLocationSteerReuter(){
        
         List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,Select_CO_Steer__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt];
         System.debug('----------->'+locationSteerLst);
         
         
        
         String depotRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
         String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
         //SELECT Id, Price__c, Price_USD__c, Pricing_Date__c, CurrencyCode__c, Unit_Of_Measure__c, Quote_Name__c 
         //FROM Reuters_Quotes__c
         Reuters_Quotes__c reuterQuoteInsert = new Reuters_Quotes__c();
         reuterQuoteInsert.Price__c = 1.1519;
         reuterQuoteInsert.Pricing_Date__c = System.today();
         reuterQuoteInsert.CurrencyCode__c = 'EU';
         reuterQuoteInsert.Unit_Of_Measure__c = 'US';
         reuterQuoteInsert.Quote_Name__c = 'EU/USD Currency';
         insert reuterQuoteInsert;
        
         Reuters_Quotes__c reuterQuoteInsert1 = new Reuters_Quotes__c();
         reuterQuoteInsert1.Price__c = 749.7500;
         reuterQuoteInsert1.Pricing_Date__c = System.today();
         reuterQuoteInsert1.CurrencyCode__c = 'USD';
         reuterQuoteInsert1.Unit_Of_Measure__c = 't';
         reuterQuoteInsert1.Quote_Name__c = 'EUSCAN_NWE_CIF_Cargo_ULG95_10ppm_Spot_H (Daily Spot)[USD/t]';
        
         insert reuterQuoteInsert1;
        
         Reuters_Quotes__c reuterQuoteInsert2 = new Reuters_Quotes__c();
         reuterQuoteInsert2.Price__c = 749.7500;
         reuterQuoteInsert2.Pricing_Date__c = System.today();
         reuterQuoteInsert2.CurrencyCode__c = 'USD';
         reuterQuoteInsert2.Unit_Of_Measure__c = 't';
         reuterQuoteInsert2.Quote_Name__c = 'EUSCAN_Rdam_FOB_Barge_EuroBOB_Spot_H (Daily Spot)[USD/t]';
         insert reuterQuoteInsert2;
        
         Location__c locinsert1 = new Location__c();
         locinsert1 = RV_TestHelperPhase2.insertLocationKarlsruhe(locinsert1);
         locinsert1.Abbreviated_Name__c = 'Karlsruhe';
         locinsert1.Source_Location__c = true;
         insert locinsert1;
         
         Location__c locinsert = new Location__c();
         locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
         locinsert.Abbreviated_Name__c = 'Ludwigshafen';
         locinsert.Source_Location__c = true;
         insert locinsert;
         
         Freight_Rate__c freightRateInsert = new Freight_Rate__c();
         freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locinsert1, locinsert);
         insert freightRateInsert;
        
         Location_Steer__c srcSteer1 = new Location_Steer__c();
         srcSteer1 = RV_TestHelperPhase2.insertsrcSteer2(srcSteer1,sourceRecordTypeId,locinsert1);
         try{
            insert srcSteer1;
         }catch(Exception de){
             
         }
    }
    static testmethod void testValidationAvailability(){
        List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,Select_CO_Steer__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt];
         System.debug('----------->'+locationSteerLst);
         
         
        
         String depotRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
         String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        
         Location__c locinsert1 = new Location__c();
         locinsert1 = RV_TestHelperPhase2.insertLocationKarlsruhe(locinsert1);
         locinsert1.Abbreviated_Name__c = 'Karlsruhe';
         locinsert1.Source_Location__c = true;
         locinsert1.Scenario_Type__c = 'Import';
         insert locinsert1;
         
         Location__c locinsert = new Location__c();
         locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
         locinsert.Abbreviated_Name__c = 'Ludwigshafen';
         locinsert.Source_Location__c = true;
         locinsert.Scenario_Type__c = 'Import';
         insert locinsert;
         
         Freight_Rate__c freightRateInsert = new Freight_Rate__c();
         freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locinsert1, locinsert);
         insert freightRateInsert;
        
         Location_Steer__c srcSteer1 = new Location_Steer__c();
         srcSteer1 = RV_TestHelperPhase2.insertsrcSteer1(srcSteer1,sourceRecordTypeId,locinsert1);
         try{
            insert srcSteer1;
         }catch(Exception de){
             
         }
         
         locinsert1.Scenario_Type__c = '';
         update locinsert1;
         Location_Steer__c srcSteer2 = new Location_Steer__c();
         srcSteer2 = RV_TestHelperPhase2.insertsrcSteer1(srcSteer1,sourceRecordTypeId,locinsert1);
         try{
            insert srcSteer2;
         }catch(Exception de){
             
         }
         
         locinsert1.Depot_MOT__c = '';
         Location_Steer__c orgSteer = new Location_Steer__c();
         orgSteer = RV_TestHelperPhase2.insertOrgSteer1(srcSteer1,depotRecordTypeId,locinsert1);
         try{
            insert orgSteer;
         }catch(Exception de){
             
         }
         
         locinsert1.Depot_MOT__c = 'Truck';
         update locinsert1;
         Location_Steer__c orgSteerTruck = new Location_Steer__c();
         orgSteerTruck = RV_TestHelperPhase2.insertOrgSteer1(srcSteer1,depotRecordTypeId,locinsert1);
         try{
            insert orgSteerTruck ;
         }catch(Exception de){
             
         }
         
         locinsert1.Products_Availability__c = 'ULG95 E5';
         update locinsert1;
         Location_Steer__c orgSteerPrdct = new Location_Steer__c();
         orgSteerPrdct = RV_TestHelperPhase2.insertOrgSteer1(srcSteer1,depotRecordTypeId,locinsert1);
         try{
            insert orgSteerPrdct ;
         }catch(Exception de){
             
         }
    }
     static testmethod void testOverLappingDateValidationSrc(){
        
        List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,Select_CO_Steer__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt];
         System.debug('----------->'+locationSteerLst);
         
         
        
         String depotRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
         String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        
         Location__c locinsert1 = new Location__c();
         locinsert1 = RV_TestHelperPhase2.insertLocationKarlsruhe(locinsert1);
         locinsert1.Abbreviated_Name__c = 'Karlsruhe';
         locinsert1.Source_Location__c = true;
         insert locinsert1;
         
         Location__c locinsert = new Location__c();
         locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
         locinsert.Abbreviated_Name__c = 'Ludwigshafen';
         locinsert.Source_Location__c = true;
         insert locinsert;
         
         Freight_Rate__c freightRateInsert = new Freight_Rate__c();
         freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locinsert1, locinsert);
         insert freightRateInsert;
         
         List<Location_Steer__c> locationSteerinsertLst = new List<Location_Steer__c> ();
         for(integer i=0;i<=10;i++){
             Location_Steer__c srcSteer1 = new Location_Steer__c();
             srcSteer1 = RV_TestHelperPhase2.insertsrcSteer1(srcSteer1,sourceRecordTypeId,locinsert1);
             srcSteer1.Default__c = false;
             locationSteerinsertLst.add(srcSteer1);
             
         }
         try{
                insert locationSteerinsertLst;
         }catch(Exception de){
                 
         }
         
         List<Location_Steer__c> locationSteerinsertLst2 = new List<Location_Steer__c> ();
         for(integer i=0;i<=10;i++){
             Location_Steer__c srcSteer1 = new Location_Steer__c();
             srcSteer1 = RV_TestHelperPhase2.insertsrcSteer1(srcSteer1,sourceRecordTypeId,locinsert1);
             srcSteer1.Default__c = false;
             locationSteerinsertLst2.add(srcSteer1);
             
         }
         try{
                insert locationSteerinsertLst2;
         }catch(Exception de){
                 
         }
     }
    static testmethod void testOverLappingDateValidationDestination(){
        
        List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,Select_CO_Steer__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt];
         System.debug('----------->'+locationSteerLst);
         
         
        
         String depotRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
         String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        
         Location__c locinsert1 = new Location__c();
         locinsert1 = RV_TestHelperPhase2.insertLocationKarlsruhe(locinsert1);
         locinsert1.Abbreviated_Name__c = 'Karlsruhe';
         locinsert1.Source_Location__c = true;
         insert locinsert1;
         
         Location__c locinsert = new Location__c();
         locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
         locinsert.Abbreviated_Name__c = 'Ludwigshafen';
         locinsert.Source_Location__c = true;
         insert locinsert;
         
         Freight_Rate__c freightRateInsert = new Freight_Rate__c();
         freightRateInsert = RV_TestHelperPhase2.insertFreightRate(freightRateInsert, locinsert1, locinsert);
         insert freightRateInsert;
         
         List<Location_Steer__c> locationSteerinsertLst = new List<Location_Steer__c> ();
         for(integer i=0;i<=10;i++){
             Location_Steer__c srcSteer1 = new Location_Steer__c();
             srcSteer1 = RV_TestHelperPhase2.insertsrcSteer1(srcSteer1,depotRecordTypeId,locinsert1);
             srcSteer1.Default__c = false;
             locationSteerinsertLst.add(srcSteer1);
             
         }
         try{
                insert locationSteerinsertLst;
         }catch(Exception de){
                 
         }
         
         List<Location_Steer__c> locationSteerinsertLst2 = new List<Location_Steer__c> ();
         for(integer i=0;i<=10;i++){
             Location_Steer__c srcSteer1 = new Location_Steer__c();
             srcSteer1 = RV_TestHelperPhase2.insertsrcSteer1(srcSteer1,depotRecordTypeId,locinsert1);
             srcSteer1.Default__c = false;
             locationSteerinsertLst2.add(srcSteer1);
             
         }
         try{
                insert locationSteerinsertLst2;
         }catch(Exception de){
                 
         }
     }
    static void doRecalcAllTest()
    {
        RV_LocationSteerTriggerHelper.recalcAllSourceSteers();
    }
}