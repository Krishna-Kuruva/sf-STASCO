@isTest
public class RV_SPCalculationControllerTest {


    @testSetup
    static void setup() {
        List<Location__c> locList = new List<Location__c>();
        //Insert location
        location__c loc= new location__c();
        loc.Name = 'Ludwigshafen depot';
        loc.Plant_Code__c = 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'South West';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Shell Own Location';
        loc.Alt_Type__c='';
        loc.Region_Name__c = 'East';
        loc.Products_Availability__c='AGO B7;IGO 50ppm;ULG95 E5';
        loc.Depot_MOT__c='Barge;ITT;Rail;TRuck';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        //insert loc;
        locList.add(loc);


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
        //insert locAlt2;
        locList.add(locAlt2);

        //Insert Source Loc
        Location__c locSrc = new Location__c();
        locSrc.Name = 'ARA/Arnheim Shell depot';
        locSrc.Plant_Code__c = 'D127';
        locSrc.Quote_Region__c='Cargo';
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
        //insert locSrc;
        locList.add(locSrc);
        insert locList;

        //Insert Account Sold To
        Account accDmy = RV_TestDataFactory.createSoldToCustomer('Shell Revolution Special Co.(Dummy)', '11111111', true, true, true);
        insert accDmy;

        //Insert Account Ship To
        Account accDmyShipTo = RV_TestDataFactory.createShipToCustomer(accDmy, 'Shell Revolution Special Co.(Dummy)', true, true, 'abc1@test.com', false, '11111111');
        insert accDmyShipTo;

        //Insert Account Sold To
        Account acc = RV_TestDataFactory.createSoldToCustomer('ADAM OMMERT MINERALOELHANDEL', '22222222', true, true, false);
        insert acc;

        //Insert Account Ship To
        Account accShipTo = RV_TestDataFactory.createShipToCustomer(acc, 'ADAM OMMERT MINERALOELHANDEL', true, true, 'abc2@test.com', false, '22222222');
        insert accShipTo;

        //Material Insert
        List<Product_Catalogue__c> matList = new List<Product_Catalogue__c>();
        //AGO B7- 400001685
        Product_Catalogue__c matAgo = new Product_Catalogue__c();
        matAgo.Name = '400001685';
        matAgo.Level_0__c = 'Gasoil';
        matAgo.Commodity_Grade_L2__c = 'AGO B7';
        matAgo.Material_Name__c = 'TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        matAgo.BEHG_Value_100l__c=10.0000;
        matAgo.Future_BEHG_value_in_100l__c=11.0000;
        matAgo.Current_BEHG_valid_from_date__c=System.today().addDays(-11);
        matAgo.Current_BEHG_valid_to_date__c=System.today().addDays(10);
        matAgo.Future_BEHG_valid_from_date__c=System.today().addDays(3);
        matAgo.Future_BEHG_valid_to_date__c=System.today().addDays(10);
        matAgo.Additive_cost_EUR_100l__c=0.1;
        matAgo.Dyeing_cost_EUR_100l__c=0.3;
        matAgo.WASA_EUR_100l__c=0.4;
        //insert matAgo;
        matList.add(matAgo);
        //IGO 50ppm -400002410
        Product_Catalogue__c matIgo50 = new Product_Catalogue__c();
        matIgo50.Name = '400002410';
        matIgo50.Level_0__c = 'Gasoil';
        matIgo50.Commodity_Grade_L2__c = 'IGO 50ppm';
        matIgo50.Material_Name__c = 'BF IGO 50ppmS B0 Dye Mkd Germany';
        matIgo50.Additive_cost_EUR_100l__c=0.2;
        matIgo50.Dyeing_cost_EUR_100l__c=0.1;
           matIgo50.BEHG_Value_100l__c=10.0000;
        matIgo50.Future_BEHG_value_in_100l__c=11.0000;
        matIgo50.Current_BEHG_valid_from_date__c=System.today().addDays(1);
        matIgo50.Current_BEHG_valid_to_date__c=System.today().addDays(10);
        matIgo50.Future_BEHG_valid_from_date__c=System.today().addDays(11);
        matIgo50.Future_BEHG_valid_to_date__c=System.today().addDays(10);
        matIgo50.Additive_cost_EUR_100l__c=0.1;
        matIgo50.WASA_EUR_100l__c=0.5;
        //insert matIgo50;
        matList.add(matIgo50);
        //ULG95 E5 -400001637
        Product_Catalogue__c matUlgE5 = new Product_Catalogue__c();
        matUlgE5.Name = '400001637';
        matUlgE5.Level_0__c = 'Gasoline';
        matUlgE5.Commodity_Grade_L2__c = 'ULG95 E5';
        matUlgE5.Material_Name__c = 'TP ULG 95 10ppmS E5 Udy Umk Low Dose DE';
        matUlgE5.Additive_cost_EUR_100l__c=0.3;
        matUlgE5.Dyeing_cost_EUR_100l__c=0.4;
        matUlgE5.WASA_EUR_100l__c=0.2;
          matUlgE5.BEHG_Value_100l__c=10.0000;
        matUlgE5.Future_BEHG_value_in_100l__c=11.0000;
        matUlgE5.Current_BEHG_valid_from_date__c=System.today().addDays(-11);
        matUlgE5.Current_BEHG_valid_to_date__c=System.today().addDays(10);
        matUlgE5.Future_BEHG_valid_from_date__c=System.today().addDays(2);
        matUlgE5.Future_BEHG_valid_to_date__c=System.today().addDays(10);


        //insert matUlgE5;
        matList.add(matUlgE5);
        insert matList;

        //Insert Mrcs
        List<MRC__c> mrcList = new List<MRC__c>();
        Id RecordTypeIdMrc = Schema.SObjectType.Mrc__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        //Insert Mrc AGO - 320076922-107004
        Mrc__c mrAgo= new Mrc__c();
        mrAgo.Name='000000000-100050';
        mrAgo.RecordTypeId=RecordTypeIdMrc;
        mrAgo.Sold_To__c=acc.Id;
        mrAgo.Ship_To__c=accShipTo.Id;
        mrAgo.Plant__c=locAlt2.Id;
        mrAgo.Rv_Available_for_OLF__c=true;
        mrAgo.Sales_Organization__c='DE01';
        mrAgo.Handling_Type__c='EB';
        mrAgo.PO_Type__c='TSFP';
        mrAgo.Product__c=matAgo.Id;
        mrAgo.Shipping_Condition__c=10;
        mrAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrAgo.Valid_From_Date__c=system.today().addDays(-100);
        //insert mrAgo;
        mrcList.add(mrAgo);
        //Dummy Mrc MRCXXA002-000001
        Mrc__c mrDmyAgo= new Mrc__c();
        mrDmyAgo.Name='MRCXXA002-000001';
        mrDmyAgo.RecordTypeId=RecordTypeIdMrc;
        mrDmyAgo.Sold_To__c=accDmy.Id;
        mrDmyAgo.Rv_Available_for_OLF__c=true;
        mrDmyAgo.Ship_To__c=accDmyShipTo.Id;
        mrDmyAgo.Plant__c=loc.Id;
        mrDmyAgo.Sales_Organization__c='DE01';
        mrDmyAgo.Handling_Type__c='EB';
        mrDmyAgo.PO_Type__c='TSFP';
        mrDmyAgo.Product__c=matAgo.Id;
        mrDmyAgo.Shipping_Condition__c=21;
        mrDmyAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrDmyAgo.Valid_From_Date__c=system.today().addDays(-100);
        //insert mrDmyAgo;
        mrcList.add(mrDmyAgo);
        //Insert Mrc IGO - 321492213-120004
        Mrc__c mrIgo= new Mrc__c();
        mrIgo.Name='000000000-100051';
        mrIgo.RecordTypeId=RecordTypeIdMrc;
        mrIgo.Sold_To__c=acc.Id;
        mrIgo.Rv_Available_for_OLF__c=true;
        mrIgo.Ship_To__c=accShipTo.Id;
        mrIgo.Plant__c=loc.Id;
        mrIgo.Sales_Organization__c='DE01';
        mrIgo.Handling_Type__c='EB';
        mrIgo.PO_Type__c='TSFP';
        mrIgo.Product__c=matIgo50.Id;
        mrIgo.Shipping_Condition__c=10;
        mrIgo.Valid_To_Date__c=system.today().addDays(1000);
        mrIgo.Valid_From_Date__c=system.today().addDays(-100);
        //insert mrIgo;
        mrcList.add(mrIgo);
        //Insert Mrc ULG95 E5 - 321751875-103004
        Mrc__c mrUlg= new Mrc__c();
        mrUlg.Name='000000000-100052';
        mrUlg.RecordTypeId=RecordTypeIdMrc;
        mrUlg.Sold_To__c=acc.Id;
        mrUlg.Ship_To__c=accShipTo.Id;
        mrUlg.Plant__c=loc.Id;
        mrUlg.Rv_Available_for_OLF__c=true;
        mrUlg.Sales_Organization__c='DE01';
        mrUlg.Handling_Type__c='EB';
        mrUlg.PO_Type__c='TSFP';
        mrUlg.Product__c=matUlgE5.Id;
        mrUlg.Shipping_Condition__c=10;
        mrUlg.Valid_To_Date__c=system.today().addDays(1000);
        mrUlg.Valid_From_Date__c=system.today().addDays(-100);
        //insert mrUlg;
        mrcList.add(mrUlg);
        insert mrcList;

        //Freight Rate
        List<Freight_Rate__c> frList = new List<Freight_Rate__c>();
        Freight_Rate__c routeAgo= new Freight_Rate__c();
        routeAgo=RV_TestHelperPhase2.insertFreightRate(routeAgo, locSrc, loc);
        routeAgo.Route_Utilization__c=100;
        routeAgo.Bio_Split__c=false;
        routeAgo.Third_Party__c=false;

        routeAgo.Valid_To__c=System.today();
        routeAgo.Valid_From__c=System.today().addDays(-10);
        //insert routeAgo;
        frList.add(routeAgo);
        Freight_Rate__c routeIgo= new Freight_Rate__c();
        routeIgo=RV_TestHelperPhase2.insertFreightRate(routeIgo, locSrc, loc);
        //routeIgo.Name='IGO-50_Shell_ARA_Barge_Ludwigshafen';//Fix_493485_Lakshmi_27Apr2020
        routeIgo.Route_Utilization__c=100;
        routeIgo.Standard_Grade__c='IGO 50ppm';
        routeIgo.SubGrade_3P__c='IGO 50ppm';
        routeIgo.Bio_Split__c=false;
        routeIgo.Third_Party__c=false;
        //Fix_493485_Lakshmi_27Apr2020_Starts
        routeIgo.Source__c=locSrc.Id;
        routeIgo.Destination__c=loc.Id;
        routeIgo.Mode_Of_Transport__c='Barge';
        routeIgo.Supplier__c='Shell';
        routeIgo.Valid_To__c=System.today();
        routeIgo.Valid_From__c=System.today().addDays(-10);
        //Fix_493485_Lakshmi_27Apr2020_Ends
        //insert routeIgo;
        frList.add(routeIgo);
        Freight_Rate__c routeUlg= new Freight_Rate__c();
        routeUlg=RV_TestHelperPhase2.insertFreightRate(routeUlg, locSrc, loc);
        //routeUlg.Name='MOGAS-E5_Shell_ARA_Barge_Ludwigshafen';//Fix_493485_Lakshmi_27Apr2020
        routeUlg.Route_Utilization__c=100;
        routeUlg.Standard_Grade__c='ULG95 E5';
        routeUlg.SubGrade_3P__c='ULG95 E5';
        routeUlg.Bio_Split__c=false;
        routeUlg.Third_Party__c=true;
        //Fix_493485_Lakshmi_27Apr2020_Starts
        routeUlg.Source__c=locSrc.Id;
        routeUlg.Destination__c=loc.Id;
        routeUlg.Mode_Of_Transport__c='Barge';
        routeUlg.Supplier__c='Shell';
        routeUlg.Valid_To__c=System.today();
		routeUlg.Valid_From__c=System.today().addDays(-10);
        frList.add(routeUlg);
        Freight_Rate__c routeUlg3rd= new Freight_Rate__c();
        routeUlg3rd=RV_TestHelperPhase2.insertFreightRate(routeUlg3rd, locSrc, loc);
        routeUlg3rd.Route_Utilization__c=100;
        routeUlg3rd.Standard_Grade__c='ULG95 E5';
        routeUlg3rd.SubGrade_3P__c='ULG95 E5';
        routeUlg3rd.Bio_Split__c=true;
        routeUlg3rd.Third_Party__c=true;
        routeUlg3rd.Source__c=locSrc.Id;
        routeUlg3rd.Destination__c=loc.Id;
        routeUlg3rd.Mode_Of_Transport__c='Barge';
        routeUlg3rd.Supplier__c='Shell';
        routeUlg3rd.Valid_To__c=System.today();
        routeUlg3rd.Valid_From__c=System.today().addDays(-10);
        frList.add(routeUlg3rd);
		insert frList;

        //Hydrocarbon Formulas
        List<Third_Party_Contract_Master__c> hydroList = new List<Third_Party_Contract_Master__c>();
        Third_Party_Contract_Master__c hydroThrdAgo= new Third_Party_Contract_Master__c();
        hydroThrdAgo=RV_TestHelperPhase2.hydrocarbonValuesAGOIGO(loc,hydroThrdAgo,false);
        hydroThrdAgo.Valid_From__c=System.today();
        //insert hydroThrdAgo;
        hydroList.add(hydroThrdAgo);
        system.debug('gradelocation==>'+hydroThrdAgo.GradeLocation__c);
        Third_Party_Contract_Master__c hydroThrdIgo= new Third_Party_Contract_Master__c();
        hydroThrdIgo=RV_TestHelperPhase2.hydrocarbonValuesIGO50ppm(loc,hydroThrdIgo,loc.Alt_Type__c);
        hydroThrdIgo.Valid_From__c=System.today();
        //insert hydroThrdIgo;
        hydroList.add(hydroThrdIgo);

        system.debug('gradelocation==>'+hydroThrdIgo.GradeLocation__c);
        Third_Party_Contract_Master__c hydroThrdUlg= new Third_Party_Contract_Master__c();
        hydroThrdUlg=RV_TestHelperPhase2.hydrocarbonValuesMOGAS(loc,hydroThrdUlg,true);
        hydroThrdUlg.Valid_From__c=System.today();
        hydroThrdUlg.MoT_Purchase__c='Barge';
        //insert hydroThrdUlg;
        hydroList.add(hydroThrdUlg);

        system.debug('gradelocation==>'+hydroThrdUlg.GradeLocation__c);
        Third_Party_Contract_Master__c hydroThrdUlg3rd= new Third_Party_Contract_Master__c();
        hydroThrdUlg3rd=RV_TestHelperPhase2.hydrocarbonValuesMOGAS(loc,hydroThrdUlg3rd,true);
        hydroThrdUlg3rd.Valid_From__c=System.today();
        hydroList.add(hydroThrdUlg3rd);

        Third_Party_Contract_Master__c hydro=new Third_Party_Contract_Master__c();
        hydro.Additive_provider__c='Shell';
        hydro.Additive_surcharge__c=0.63;
        hydro.Depot__c=loc.Id;
        hydro.Source__c=loc.Id;
        hydro.Alternate_Type__c='';
        hydro.Average_Multiplier_Quote__c='';
        hydro.Average_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Average_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Base_Quote_1_Percent__c=93.2;
        hydro.Base_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Bio_Quotes__c='Argus Biodiesel RED FAME -10°C CFPP FOB ARA (ask)';
        hydro.Bio_Quote__c=6.8;
        hydro.Bio_surcharge__c=9;
        hydro.Contract__c='';
        hydro.Differential_Quote_1_Percent__c=0;
        hydro.Differential_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Differential_Quote_2_Percent__c=0;
        hydro.Differential_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Differential_Quote_3_Percent__c=0;
        hydro.Differential_Quote_3__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Differential_Quote_4_Percent__c=0;
        hydro.Differential_Quote_4__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
   		hydro.Frieight_Quote_per__c=100;
    	hydro.Frieight_Quote__c='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne';
 		hydro.Future_Calculation__c='';
 		hydro.Grade__c='ULG95 E5';
 		hydro.isThirdParty__c=true;
 		hydro.Loc_Diff__c=11.5;
 		hydro.MoT_Purchase__c='Truck';
 		hydro.Product_sub_grade__c='MOGAS';
 		hydro.SalesOrg_Customer__c='DE01';
        hydro.Supply_Route_ID__c ='DE01';
 		hydro.Shell_Owned_Type__c='';
 		hydro.Supplement_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
 		hydro.Supplement_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
 		hydro.Supplier__c='Shell';
 		hydro.Thruput_charge__c=0;
	 	hydro.Valid_From__c=System.today();
 		hydro.Valid_To__c=System.today()+1;
         system.debug('gradelocation==>'+hydro.GradeLocation__c);
        hydroList.add(hydro);

        Third_Party_Contract_Master__c hydro1=new Third_Party_Contract_Master__c();
        hydro1.Additive_provider__c='Shell';
        hydro1.Additive_surcharge__c=0.63;
        hydro1.Depot__c=loc.Id;
        hydro1.Source__c=loc.Id;
        hydro1.Alternate_Type__c='';
        hydro1.Average_Multiplier_Quote__c='';
        hydro1.Average_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro1.Average_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro1.Base_Quote_1_Percent__c=93.2;
        hydro1.Base_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro1.Bio_Quotes__c='Platts FOB R'+'\''+'dam Ethanol T2 (€) (high)';
        hydro1.Bio_Quote__c=6.10;
        hydro1.Bio_surcharge__c=9;
        hydro1.Contract__c='';
        hydro1.Differential_Quote_1_Percent__c=0;
        hydro1.Differential_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro1.Differential_Quote_2_Percent__c=0;
        hydro1.Differential_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro1.Differential_Quote_3_Percent__c=0;
        hydro1.Differential_Quote_3__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro1.Differential_Quote_4_Percent__c=0;
        hydro1.Differential_Quote_4__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
   		hydro1.Frieight_Quote_per__c=100;
    	hydro1.Frieight_Quote__c='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne';
 		hydro1.Future_Calculation__c='';
 		hydro1.Grade__c='AGO B7';
 		hydro1.isThirdParty__c=true;
 		hydro1.Loc_Diff__c=11.5;
 		hydro1.MoT_Purchase__c='Truck';
 		hydro1.Product_sub_grade__c='MOGAS1';
 		hydro1.SalesOrg_Customer__c='AT01';
        hydro1.Supply_Route_ID__c ='DE01';
 		hydro1.Shell_Owned_Type__c='';
 		hydro1.Supplement_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
 		hydro1.Supplement_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
 		hydro1.Supplier__c='Total';
 		hydro1.Thruput_charge__c=0;
	 	hydro1.Valid_From__c=System.today();
 		hydro1.Valid_To__c=System.today()+1;
        hydroList.add(hydro1);
        insert hydroList;

        List<Reuters_Quotes__c> quotesList = new List<Reuters_Quotes__c>();
        Reuters_Quotes__c objLive = new Reuters_Quotes__c();
        objLive.Quote_Name__c='Platts';
        objLive.Quote_Display_Name__c='Argus Biodiesel RED FAME -10°C CFPP FOB ARA (mean)';
        objLive.CurrencyCode__c ='EU';
        objLive.Price__c = 1;
        objLive.Unit_Of_Measure__c = 'US';
        objLive.Valid_From_Date__c=System.today();
        objLive.Valid_To_Date__c=System.today()+14;
        objLive.Valid_Month__c = 'JAN20';
        quotesList.add(objLive);

        Reuters_Quotes__c objLive1 = new Reuters_Quotes__c();
        objLive1.Quote_Name__c='Platts';
        objLive1.Quote_Display_Name__c='EUR/USD';
        objLive1.CurrencyCode__c ='EU';
        objLive1.Price__c = 1;
        objLive1.Unit_Of_Measure__c = 'US';
        objLive1.Valid_From_Date__c=System.today();
        objLive1.Valid_To_Date__c=System.today()+14;
        objLive1.Valid_Month__c = 'JAN20';
        quotesList.add(objLive1);
        insert quotesList;
        //Location Steer
        Id RecordTypeIdLocStrSrc = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        Id RecordTypeIdLocStrDep = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
        List<Location_Steer__c> locStrList = new List<Location_Steer__c>();
        Location_Steer__c locSrcStrAgo = new Location_Steer__c();
        locSrcStrAgo=RV_TestHelperPhase2.insertsrcSteer(locSrcStrAgo,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrAgo.Valid_From__c=System.today().addDays(-11);
        locSrcStrAgo.Scenario_Value__c=11;
        locSrcStrAgo.Manual_Adjustment__c=1;
        insert locSrcStrAgo;
        locStrList.add(locSrcStrAgo);
        Location_Steer__c locSrcStrIgo = new Location_Steer__c();
        locSrcStrIgo=RV_TestHelperPhase2.insertsrcSteer1(locSrcStrIgo,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrAgo.Valid_To__c=System.today().addDays(3);
        locSrcStrIgo.Scenario_Value__c=12;
        locSrcStrIgo.Manual_Adjustment__c=1;
        insert locSrcStrIgo;
        locStrList.add(locSrcStrIgo);
        Location_Steer__c locSrcStrUlg = new Location_Steer__c();
        locSrcStrUlg=RV_TestHelperPhase2.insertsrcSteer2(locSrcStrUlg,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrAgo.Valid_From__c=System.today().addDays(-11);
        locSrcStrUlg.Scenario_Value__c=10;
        locSrcStrUlg.Manual_Adjustment__c=1;
        insert locSrcStrUlg;
        locStrList.add(locSrcStrUlg);
        Location_Steer__c locDepStrAgo = new Location_Steer__c();
        locDepStrAgo=RV_TestHelperPhase2.insertsrcSteer(locDepStrAgo,RecordTypeIdLocStrDep,loc);
      locSrcStrAgo.Valid_From__c=System.today().addDays(-11);
        locDepStrAgo.MOT__c='Truck';
        locDepStrAgo.Depot_Steer__c=10;
        locDepStrAgo.Scenario__c='';
        insert locDepStrAgo;
        locStrList.add(locDepStrAgo);
        Location_Steer__c locDepStrIgo = new Location_Steer__c();
        locDepStrIgo=RV_TestHelperPhase2.insertsrcSteer1(locDepStrIgo,RecordTypeIdLocStrDep,loc);
        locSrcStrAgo.Valid_From__c=System.today().addDays(-11);
        locDepStrIgo.MOT__c='Truck';
        locDepStrIgo.Depot_Steer__c=11;
        locDepStrIgo.Scenario__c='';
        insert locDepStrIgo;
        locStrList.add(locDepStrIgo);
        Location_Steer__c locDepStrUlg = new Location_Steer__c();
        locDepStrUlg=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlg,RecordTypeIdLocStrDep,loc);
        locSrcStrAgo.Valid_From__c=System.today().addDays(-11);
        locDepStrUlg.MOT__c='Truck';
        locDepStrUlg.Depot_Steer__c=12;
        locDepStrUlg.Scenario__c='';
        insert locDepStrUlg;
        locStrList.add(locDepStrUlg);
        Location_Steer__c locDepStrUlgOverRdn = new Location_Steer__c();
        locDepStrUlgOverRdn=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlgOverRdn,RecordTypeIdLocStrDep,loc);
        locDepStrUlgOverRdn.MOT__c='Truck';
        locDepStrUlgOverRdn.Depot_Steer__c=12;
        locDepStrUlgOverRdn.Scenario__c='';
        locDepStrUlgOverRdn.Valid_From__c=system.today().addDays(1);
        locDepStrUlgOverRdn.Valid_To__c=system.today().addDays(13);
        insert locDepStrUlgOverRdn;
        locStrList.add(locDepStrUlgOverRdn);
        //BioAmv
        Bio_AMVs__c bio= new Bio_AMVs__c();
        bio=RV_TestHelperPhase2.insertBioAmv(bio,loc);
        insert bio;


        Bio_AMVs__c bio2= new Bio_AMVs__c();
        bio2=RV_TestHelperPhase2.insertBioAmv(bio2,loc);
        bio2.Prompt_valid_To__c =  System.today().addDays(-9);
        bio2.Future_Valid_From__c = System.today().addDays(-6);
        insert bio2;
    	 Bio_AMVs__c bio5= new Bio_AMVs__c();
        //bio5=RV_TestHelperPhase2.insertBioAmv(bio5,loc);
        bio5.Plant__c=loc.id;
        bio5.AGO_B7_m_Future__c=10;
        bio5.AGO_B7_m_Prompt__c=9;
        bio5.Sales_Org__c='DE01';
        bio5.ULG_95_E10_m_Future__c=8;
        bio5.ULG_95_E10_m_Prompt__c=9;
        bio5.ULG_95_E5_m_Future__c=10;
        bio5.ULG_95_E5_m_Prompt__c=9;
        bio5.ULG_98_m_Future__c=7;
        bio5.ULG_98_m_Prompt__c=11;
        bio5.Future_Valid_From__c = System.today().addDays(-11);
        bio5.Future_Valid_To__c = System.today().addDays(10);
        bio5.Prompt_Valid_From__c = System.today().addDays(-3);
        bio5.Prompt_valid_To__c=  System.today();
        insert bio5;
         Bio_AMVs__c bio6= new Bio_AMVs__c();
        bio6=RV_TestHelperPhase2.insertBioAmv(bio6,locAlt2);
              bio6.Future_Valid_From__c = System.today().addDays(-11);
        bio6.Future_Valid_To__c = System.today().addDays(10);
        bio6.Prompt_Valid_From__c = System.today().addDays(-3);
        bio6.Prompt_valid_To__c=  System.today();
        insert bio6;
        //Throughput
        List<Throughput__c> thpList = new List<Throughput__c>();
        Throughput__c thputAgo= new Throughput__c();
        thputAgo=RV_TestHelperPhase2.insertThroughput(thputAgo,loc);
        //insert thputAgo;
        thpList.add(thputAgo);
        Throughput__c thputIgo= new Throughput__c();
        thputIgo=RV_TestHelperPhase2.insertThroughput(thputIgo,loc);
        thputIgo.Standard_grade__c='IGO 50ppm';
        thputIgo.Product_Sub_Grade__c='IGO 50ppm';
        //insert thputIgo;
        thpList.add(thputIgo);
        Throughput__c thputUlg= new Throughput__c();
        thputUlg=RV_TestHelperPhase2.insertThroughput(thputUlg,loc);
        thputUlg.Standard_grade__c='ULG95 E5';
        thputUlg.Product_Sub_Grade__c='ULG95 E5';
        //insert thputUlg;
        thpList.add(thputUlg);
      //  insert thpList;

        //Margin
        Id RecordTypeIdMarginTruck = Schema.SObjectType.Margin__c.getRecordTypeInfosByName().get('Truck/ITT').getRecordTypeId();
               Id RecordTypeIdMarginMeans = Schema.SObjectType.Margin__c.getRecordTypeInfosByName().get('Massive Means').getRecordTypeId();

        Margin__c mgn2 = new Margin__c();
        mgn2=RV_TestHelperPhase2.insertMargin(mgn2,loc,RecordTypeIdMarginTruck);
        insert mgn2;

        Margin__c mgn = new Margin__c();
          mgn.Plant__c=loc.Id;
        mgn.Margin_Type__c='MASSIVE MEANS';
        mgn.RecordTypeId=RecordTypeIdMarginMeans;
        mgn.AGO_B0_Sales_Margin__c=0.3;
        mgn.AGO_B7_Sales_Margin__c=0.4;
        mgn.AGO_CH_Sales_Margin__c=0.1;
        mgn.Default__c=true;
        mgn.Fixed_Surcharge_GTL_B0__c=0.2;
        mgn.IGO_1000_Sales_Margin__c=0.4;
        mgn.IGO_50_Sales_Margin__c=0.3;
        mgn.Min_Mgn_AGO_B7__c=0.2;
        mgn.Min_Mgn_IGO_50ppm__c=0.5;
        mgn.Min_Mgn_ULG95_E5__c=0.4;
        mgn.MOGAS_98_Sales_Margin__c=0.2;
        mgn.MOGAS_BOB10_Sales_Margin__c=0.4;
        mgn.MOGAS_BOB5_Sales_Margin__c=0.2;
        mgn.MOGAS_E0_Sales_Margin__c=0.6;
        mgn.Sales_Mgn_AGO_B7__c=0.1;
        mgn.Sales_Mgn_IGO_50ppm__c=0.2;
        mgn.Sales_Mgn_ULG95_E5__c=0.3;
        mgn.Sales_Org__c='DE01';
        mgn.Valid_From__c=system.today().addDays(-11);
        mgn.Valid_To__c=system.today().addDays(12);
        insert mgn;

      Margin__c mgnOverriden = new Margin__c();
        mgnOverriden=RV_TestHelperPhase2.insertMargin(mgnOverriden,loc,RecordTypeIdMarginTruck);
        mgnOverriden.Valid_From__c=system.today().addDays(-11);
        mgnOverriden.Valid_To__c=system.today().addDays(12);
        insert mgnOverriden;
        //ATP Insert
        atp__c atp = new atp__c();
        atp=RV_TestHelper.insertATPRecord(atp,loc);
        insert atp;

    }


    static testmethod void getMRCRecordsData(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant__r.Country__c,Plant_code__c,
                Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Material_Description__c,Material_Name__c,PO_Type__c,
                 Sold_To__c,Sold_To__r.Name,Sold_To__r.Rv_Olf_Customer_Email__c,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                 Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,Online_Material_Name_Taxed__c,
                 Online_Material_Name_UnTaxed__c,Online_Customer_Name__c from MRC__c];
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : [Select Id from Account where Customer_Type__c ='Ship To']){
            accIdSet.add(acc.Id);
        }

        test.startTest();
                RV_SPCalculationController.getCalulatedSp(mrcLst,System.today().addDays(-10),System.today().addDays(5));
                RV_SPCalculationController.getCalulatedSp(mrcLst,System.today().addDays(15),System.today().addDays(28));
                RV_SPCalculationController.getCalulatedSp(mrcLst,System.today().addDays(29),System.today().addDays(60));
                RV_SPCalculationController.getCalulatedSp(mrcLst,System.today(),System.today().addDays(100));

              test.stopTest();
    }

}