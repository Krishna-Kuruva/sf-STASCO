@isTest
public class RV_SHT_CreateControllerTest {
    
    @testSetup
    static void setup() {
        List<Location__c> locList = new List<Location__c>();
        //Insert location rec ========
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
        
        //insert====  loc;
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
        //insert  locAlt2;
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
        // locSrc.Related_Plant_Code__c
        //insert locSrc;
        locList.add(locSrc);
        insert locList;
        locList[0].Related_Plant__c = locList[1].Id;
        locList[1].Related_Plant__c = locList[2].Id;
        locList[2].Related_Plant__c = locList[0].Id;
        List<Location__c> locSrc1 = new List<Location__c>();
        locSrc1.add(locList[0]);
        locSrc1.add(locList[1]);
        locSrc1.add(locList[2]);
        update locSrc1;
        
        //Insert Account Sold To
        Account accDmy = RV_TestDataFactory.createSoldToCustomer('Shell Revolution Special Co.(Dummy)', '11111111', true, true, false);
        accDmy.Rv_Olf_Customer_Email__c = 'test@shell.com';
        accDmy.Rv_Online_Customer_Name__c = 'Shell Revolution Special Co.(Dummy)';
        
        insert accDmy;
        
        //Insert Account Ship To
        Account accDmyShipTo = RV_TestDataFactory.createShipToCustomer(accDmy, 'Shell Revolution Special Co.(Dummy)', true, true, 'abc1@test.com', false, '11111111');
        accDmyShipTo.Rv_Online_Customer_Name__c = 'Shell Revolution Special Co.(Dummy)';
        insert accDmyShipTo;
        
        //Insert Account Sold To
        Account acc = RV_TestDataFactory.createSoldToCustomer('ADAM OMMERT MINERALOELHANDEL', '22222222', true, true, false);
        acc.Rv_Online_Customer_Name__c = 'ADAM OMMERT MINERALOELHANDEL';
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
        matAgo.Additive_cost_EUR_100l__c=0.1;
        matAgo.Dyeing_cost_EUR_100l__c=0.3;
        matAgo.WASA_EUR_100l__c=0.4;
        matAgo.Online_Material_Name_Taxed__c = 'Diesel B7';
        matAgo.Online_Material_Name_UnTaxed__c = 'Diesel B7 (unversteuert)';
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
        matIgo50.WASA_EUR_100l__c=0.5;
        matAgo.Online_Material_Name_Taxed__c = 'Diesel B7';
        matAgo.Online_Material_Name_UnTaxed__c = 'Diesel B7 (unversteuert)';
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
        matAgo.Online_Material_Name_Taxed__c = 'Diesel B7';
        matAgo.Online_Material_Name_UnTaxed__c = 'Diesel B7 (unversteuert)';
        //insert matUlgE5;
        matList.add(matUlgE5);
        
        
        
        Product_Catalogue__c matUlg98 = new Product_Catalogue__c();
        matUlg98.Name = '400001555';
        matUlg98.Level_0__c = 'Gasoline';
        matUlg98.Commodity_Grade_L2__c = 'ULG98';
        matUlg98.Material_Name__c = 'TP ULG 95 10ppmS E5 Udy Umk Dealer Dose DE';
        matUlg98.Additive_cost_EUR_100l__c=0.1;
        matUlg98.Dyeing_cost_EUR_100l__c=0.2;
        matUlg98.WASA_EUR_100l__c=0.3;

        //insert matUlgE5;
        matList.add(matUlg98);

        insert matList;
        
        //Insert Mrcs
        List<MRC__c> mrcList = new List<MRC__c>();
        Id RecordTypeIdMrc = Schema.SObjectType.Mrc__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        //Insert Mrc AGO - 320076922-107004
        Mrc__c mrAgo= new Mrc__c();
        mrAgo.Name='0321539467-100050';
        mrAgo.RecordTypeId=RecordTypeIdMrc;
        mrAgo.Sold_To__c=acc.Id;
        mrAgo.Ship_To__c=accShipTo.Id;
        mrAgo.Plant__c=loc.Id;
        mrAgo.Sales_Organization__c='DE01';
        mrAgo.Handling_Type__c='EB';
        mrAgo.PO_Type__c='TSFP';
        mrAgo.Product__c=matAgo.Id;
        mrAgo.Shipping_Condition__c=10;
        mrAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrAgo.Valid_From_Date__c=system.today().addDays(-100);
        mrAgo.Ship_to_Number__c = '0012610307';
        mrAgo.Contract__c = '321799369';
        //insert mrAgo;
        mrcList.add(mrAgo);
        
        Mrc__c mrAgoObj= new Mrc__c();
        mrAgoObj.Name='0321539467-100050';
        mrAgoObj.RecordTypeId=RecordTypeIdMrc;
        mrAgoObj.Sold_To__c=acc.Id;
        mrAgoObj.Ship_To__c=accShipTo.Id;
        mrAgoObj.Plant__c=loc.Id;
        mrAgoObj.Sales_Organization__c='DE01';
        mrAgoObj.Handling_Type__c='EB';
        mrAgoObj.PO_Type__c='TSFP';
        mrAgoObj.Product__c=matAgo.Id;
        mrAgoObj.Shipping_Condition__c=10;
        mrAgoObj.Valid_To_Date__c=system.today().addDays(1000);
        mrAgoObj.Valid_From_Date__c=system.today().addDays(-100);
        mrAgoObj.Ship_to_Number__c = '0012610307';
        mrAgoObj.Contract__c = '321799369';
        mrcList.add(mrAgoObj);
        //insert mrAgo;
        //Dummy Mrc MRCXXA002-000001
        Mrc__c mrDmyAgo= new Mrc__c();
        mrDmyAgo.Name='MRCXXA002-000001';
        mrDmyAgo.RecordTypeId=RecordTypeIdMrc;
        mrDmyAgo.Sold_To__c=accDmy.Id;
        mrDmyAgo.Ship_To__c=accDmyShipTo.Id;
        mrDmyAgo.Plant__c=loc.Id;
        mrDmyAgo.Sales_Organization__c='DE01';
        mrDmyAgo.Handling_Type__c='EB';
        mrDmyAgo.PO_Type__c='TSFP';
        mrDmyAgo.Product__c=matAgo.Id;
        mrDmyAgo.Shipping_Condition__c=10;
        mrDmyAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrDmyAgo.Valid_From_Date__c=system.today().addDays(-100);
        mrDmyAgo.Contract__c = '321799369';
        //insert mrDmyAgo;
        mrcList.add(mrDmyAgo);
        //Insert Mrc IGO - 321492213-120004
        Mrc__c mrIgo= new Mrc__c();
        mrIgo.Name='000000000-100051';
        mrIgo.RecordTypeId=RecordTypeIdMrc;
        mrIgo.Sold_To__c=acc.Id;
        mrIgo.Ship_To__c=accShipTo.Id;
        mrIgo.Plant__c=loc.Id;
        mrIgo.Sales_Organization__c='DE01';
        mrIgo.Handling_Type__c='EB';
        mrIgo.PO_Type__c='TSFP';
        mrIgo.Product__c=matIgo50.Id;
        mrIgo.Shipping_Condition__c=10;
        mrIgo.Valid_To_Date__c=system.today().addDays(1000);
        mrIgo.Valid_From_Date__c=system.today().addDays(-100);
        mrIgo.Contract__c = '321799369';
        //insert mrIgo;
        mrcList.add(mrIgo);
        //Insert Mrc ULG95 E5 - 321751875-103004
        Mrc__c mrUlg= new Mrc__c();
        mrUlg.Name='000000000-100052';
        mrUlg.RecordTypeId=RecordTypeIdMrc;
        mrUlg.Sold_To__c=acc.Id;
        mrUlg.Ship_To__c=accShipTo.Id;
        mrUlg.Plant__c=loc.Id;
        mrUlg.Sales_Organization__c='DE01';
        mrUlg.Handling_Type__c='EB';
        mrUlg.PO_Type__c='TSFP';
        mrUlg.Product__c=matUlgE5.Id;
        mrUlg.Shipping_Condition__c=10;
        mrUlg.Valid_To_Date__c=system.today().addDays(1000);
        mrUlg.Valid_From_Date__c=system.today().addDays(-100);
        mrUlg.Ship_to_Number__c = '22222222';
        mrUlg.Contract__c = '321799369';
        //insert mrUlg;
        mrcList.add(mrUlg);
        
          //Insert Mrc ULG98 - 321751875-103004
        Mrc__c mrUlg98= new Mrc__c();
        mrUlg98.Name='000000000-100059';
        mrUlg98.RecordTypeId=RecordTypeIdMrc;
        mrUlg98.Sold_To__c=acc.Id;
        mrUlg98.Ship_To__c=accShipTo.Id;
        mrUlg98.Plant__c=loc.Id;
        mrUlg98.Sales_Organization__c='DE01';
        mrUlg98.Handling_Type__c='EB';
        mrUlg98.PO_Type__c='TSFP';
        mrUlg98.Product__c=matUlg98.Id;
        mrUlg98.Shipping_Condition__c=10;
        mrUlg98.Valid_To_Date__c=system.today().addDays(1000);
        mrUlg98.Valid_From_Date__c=system.today().addDays(-100);
        mrUlg98.Ship_to_Number__c = '22222222';
        mrUlg98.Contract__c = '321799369';
        //insert mrUlg;
        mrcList.add(mrUlg98);

        
        
        insert mrcList;
        
        //Freight Rate
        List<Freight_Rate__c> frList = new List<Freight_Rate__c>();
        Freight_Rate__c routeAgo= new Freight_Rate__c();
        routeAgo=RV_TestHelperPhase2.insertFreightRate(routeAgo, locSrc, loc);
        routeAgo.Route_Utilization__c=100;
        routeAgo.Bio_Split__c=false;
        routeAgo.Third_Party__c=false;
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
        routeUlg.Third_Party__c=false;
        //Fix_493485_Lakshmi_27Apr2020_Starts
        routeUlg.Source__c=locSrc.Id;
        routeUlg.Destination__c=loc.Id;
        routeUlg.Mode_Of_Transport__c='Barge';
        routeUlg.Supplier__c='Shell';
        //Fix_493485_Lakshmi_27Apr2020_Ends
        //insert routeUlg;
        frList.add(routeUlg);
        Freight_Rate__c routeUlg3rd= new Freight_Rate__c();
        routeUlg3rd=RV_TestHelperPhase2.insertFreightRate(routeUlg3rd, locSrc, loc);
        //routeUlg3rd.Name='MOGAS-E5_Shell_ARA_Barge_Ludwigshafen';//Fix_493485_Lakshmi_27Apr2020
        routeUlg3rd.Route_Utilization__c=100;
        routeUlg3rd.Standard_Grade__c='ULG95 E5';
        routeUlg3rd.SubGrade_3P__c='ULG95 E5';
        routeUlg3rd.Bio_Split__c=true;
        routeUlg3rd.Third_Party__c=true;
        //Fix_493485_Lakshmi_27Apr2020_Starts
        routeUlg3rd.Source__c=locSrc.Id;
        routeUlg3rd.Destination__c=loc.Id;
        routeUlg3rd.Mode_Of_Transport__c='Barge';
        routeUlg3rd.Supplier__c='Shell';
        //Fix_493485_Lakshmi_27Apr2020_Ends
        //insert routeUlg3rd;
        frList.add(routeUlg3rd);
        insert frList;
        
        //Hydrocarbon Formulas
        List<Third_Party_Contract_Master__c> hydroList = new List<Third_Party_Contract_Master__c>();
        Third_Party_Contract_Master__c hydroThrdAgo= new Third_Party_Contract_Master__c();
        hydroThrdAgo=RV_TestHelperPhase2.hydrocarbonValuesAGOIGO(loc,hydroThrdAgo,false);
        //insert hydroThrdAgo;
        hydroList.add(hydroThrdAgo);
        system.debug('gradelocation==>'+hydroThrdAgo.GradeLocation__c);
        Third_Party_Contract_Master__c hydroThrdIgo= new Third_Party_Contract_Master__c();
        hydroThrdIgo=RV_TestHelperPhase2.hydrocarbonValuesIGO50ppm(loc,hydroThrdIgo,loc.Alt_Type__c);
        //insert hydroThrdIgo;
        hydroList.add(hydroThrdIgo);
        system.debug('gradelocation==>'+hydroThrdIgo.GradeLocation__c);
        Third_Party_Contract_Master__c hydroThrdUlg= new Third_Party_Contract_Master__c();
        hydroThrdUlg=RV_TestHelperPhase2.hydrocarbonValuesMOGAS(loc,hydroThrdUlg,true);
        //insert hydroThrdUlg;
        hydroList.add(hydroThrdUlg);
        system.debug('gradelocation==>'+hydroThrdUlg.GradeLocation__c);
        Third_Party_Contract_Master__c hydroThrdUlg3rd= new Third_Party_Contract_Master__c();
        hydroThrdUlg3rd=RV_TestHelperPhase2.hydrocarbonValuesMOGAS(loc,hydroThrdUlg3rd,true);
        // hydroThrdUlg3rd.Supply_Route_ID__c='MOGAS-E5_Shell_ARA_Barge_Ludwigshafen';
        //insert hydroThrdUlg3rd;
        hydroList.add(hydroThrdUlg3rd);
        insert hydroList;
        
        //Location Steer
        Id RecordTypeIdLocStrSrc = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        Id RecordTypeIdLocStrDep = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
        List<Location_Steer__c> locStrList = new List<Location_Steer__c>();
        Location_Steer__c locSrcStrAgo = new Location_Steer__c();
        locSrcStrAgo=RV_TestHelperPhase2.insertsrcSteer(locSrcStrAgo,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrAgo.Scenario_Value__c=11;
        locSrcStrAgo.Manual_Adjustment__c=1;
        //insert locSrcStrAgo;
        locStrList.add(locSrcStrAgo);
        Location_Steer__c locSrcStrIgo = new Location_Steer__c();
        locSrcStrIgo=RV_TestHelperPhase2.insertsrcSteer1(locSrcStrIgo,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrIgo.Scenario_Value__c=12;
        locSrcStrIgo.Manual_Adjustment__c=1;
        //insert locSrcStrIgo;
        locStrList.add(locSrcStrIgo);
        Location_Steer__c locSrcStrUlg = new Location_Steer__c();
        locSrcStrUlg=RV_TestHelperPhase2.insertsrcSteer2(locSrcStrUlg,RecordTypeIdLocStrSrc,locSrc);
        locSrcStrUlg.Scenario_Value__c=10;
        locSrcStrUlg.Manual_Adjustment__c=1;
        //insert locSrcStrUlg;
        locStrList.add(locSrcStrUlg);
        Location_Steer__c locDepStrAgo = new Location_Steer__c();
        locDepStrAgo=RV_TestHelperPhase2.insertsrcSteer(locDepStrAgo,RecordTypeIdLocStrDep,loc);
        locDepStrAgo.MOT__c='Truck';
        locDepStrAgo.Depot_Steer__c=10;
        locDepStrAgo.Scenario__c='';
        //insert locDepStrAgo;
        locStrList.add(locDepStrAgo);
        Location_Steer__c locDepStrIgo = new Location_Steer__c();
        locDepStrIgo=RV_TestHelperPhase2.insertsrcSteer1(locDepStrIgo,RecordTypeIdLocStrDep,loc);
        locDepStrIgo.MOT__c='Truck';
        locDepStrIgo.Depot_Steer__c=11;
        locDepStrIgo.Scenario__c='';
        //insert locDepStrIgo;
        locStrList.add(locDepStrIgo);
        Location_Steer__c locDepStrUlg = new Location_Steer__c();
        locDepStrUlg=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlg,RecordTypeIdLocStrDep,loc);
        locDepStrUlg.MOT__c='Truck';
        locDepStrUlg.Depot_Steer__c=12;
        locDepStrUlg.Scenario__c='';
        //insert locDepStrUlg;
        locStrList.add(locDepStrUlg);
        Location_Steer__c locDepStrUlgOverRdn = new Location_Steer__c();
        locDepStrUlgOverRdn=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlgOverRdn,RecordTypeIdLocStrDep,loc);
        locDepStrUlgOverRdn.MOT__c='Truck';
        locDepStrUlgOverRdn.Depot_Steer__c=12;
        locDepStrUlgOverRdn.Scenario__c='';
        locDepStrUlgOverRdn.Valid_From__c=system.today().addDays(1);
        locDepStrUlgOverRdn.Valid_To__c=system.today().addDays(13);
        //insert locDepStrUlgOverRdn;
        locStrList.add(locDepStrUlgOverRdn);
        //BioAmv
        Bio_AMVs__c bio= new Bio_AMVs__c();
        bio=RV_TestHelperPhase2.insertBioAmv(bio,loc);
        insert bio;
        
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
        insert thpList;
        
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
        
        //ATP Insert
        atp__c atp = new atp__c();
        atp=RV_TestHelper.insertATPRecord(atp,loc);
        insert atp;
        
        RV_Trigger_Master_Data__c tmd = new RV_Trigger_Master_Data__c();
        tmd.Trigger_Month__c = 'Sep';
        tmd.Trigger_Year__c = '2022';
        tmd.Ship_To_Number__c = accShipTo.Ship_to_Number__c;
        tmd.Sold_to_Name__c = acc.Id;
        tmd.Sold_to_Number__c = acc.Sold_To_Number__c;
        tmd.MRC_Number__c = mrcList[0].MRC_Number__c;
        tmd.Max_number_of_triggers_per_month__c = 12;
        tmd.Max_Trigger_Volume__c = 500;
        tmd.Min_Trigger_Volume__c = 20;
        tmd.Monthly_volume__c = 300;
        tmd.Remaining_triggers__c = 10;
        tmd.Remaining_trigger_volume__c = 100;
        tmd.SHT__c = null;
        insert tmd;
        
        SHT__c newSHTObj = new SHT__c();
        newSHTObj.MRC__c = mrAgo.id;
        newSHTObj.MRC_Number__c = mrAgo.Name;
        newSHTObj.Customer__c = mrAgo.Sold_To__c;
        newSHTObj.Tranche__c = 'ATP1';
        newSHTObj.BSP__c=100;
        newSHTObj.MSP__c=100;
        newSHTObj.Status__c = 'Saved';
        newSHTObj.Select__c= true;
        newSHTObj.Sales_Type__c = 'Obam Sales';
        newSHTObj.Product_Category__c = 'AGO B7';
        newSHTObj.Contract_Start__c=System.today().addDays(15);
        newSHTObj.Contract_End_Date__c=system.today()+30;
        newSHTObj.Deal_Comment__c='test123';
        newSHTObj.Trigger_Master_Data__c = tmd.Id;
        newSHTObj.isOlfDeal__c = true;
        insert newSHTObj;
        
        SHT__c newSHTObj1 = new SHT__c();
        newSHTObj1.MRC__c = mrAgo.id;
        newSHTObj1.MRC_Number__c = mrAgo.Name;
        newSHTObj1.Customer__c = mrAgo.Sold_To__c;
        newSHTObj1.Tranche__c = 'ATP2';
        newSHTObj1.BSP__c=100;
        newSHTObj1.MSP__c=100;
        newSHTObj1.Status__c = 'Saved';
        newSHTObj1.Select__c= true;
        newSHTObj1.Trigger_Master_Data__c = tmd.Id;
        newSHTObj1.Sales_Type__c = 'Obam Sales';
        newSHTObj.Product_Category__c = 'ULG95 E0';
        newSHTObj1.Contract_Start__c=System.today().addDays(15);
        newSHTObj1.Contract_End_Date__c=system.today()+30;
        newSHTObj1.Deal_Comment__c='test122312';
        newSHTObj1.isOlfDeal__c = true;
        insert newSHTObj1;
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(newSHTObj1.Id, yesterday);
        SHT__c newSHTObj2 = new SHT__c();
        newSHTObj2.MRC__c = mrIgo.id;
        newSHTObj2.MRC_Number__c = mrIgo.Name;
        newSHTObj2.Customer__c = mrIgo.Sold_To__c;
        newSHTObj2.Tranche__c = 'ATP3';
        newSHTObj2.BSP__c=100;
        newSHTObj2.MSP__c=100;
        newSHTObj2.Status__c = 'Saved';
        newSHTObj2.Select__c= true;
        newSHTObj2.Sales_Type__c = 'Obam Sales';
        newSHTObj2.Contract_Start__c=System.today().addDays(15);
        newSHTObj2.Contract_End_Date__c=system.today()+30;
        newSHTObj2.Deal_Comment__c=null;
        newSHTObj2.Trigger_Master_Data__c = tmd.Id;
        newSHTObj2.isOlfDeal__c = true;
        insert newSHTObj2;
        
    }
    
    static testmethod void getMRCRecordsData(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : [Select Id from Account WHERE Customer_Type__c = 'Ship To']){
            accIdSet.add(acc.Id);
        }
        RV_SHT_CreateController.getMRCRecordsData('ATP1', '320076222', new Set<Id>(), '', true, true, true, true,'','','',String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),true);
        RV_SHT_CreateController.getMRCRecordsData('ATP1', '0Truck', new Set<Id>(), '', false, true, true, true,'','','',String.valueOf(System.today()),String.valueOf(System.today().addDays(14)),false);
        RV_SHT_CreateController.getMRCRecordsData('ATP2', mrclst[0].MRC_Number__c, new Set<Id>(), '', false, true, true, true,'','','',String.valueOf(System.today().addDays(15)),String.valueOf(System.today().addDays(28)),true);
        RV_SHT_CreateController.getMRCRecordsData('ATP3', mrclst[1].MRC_Number__c, new Set<Id>(), '', false, true, true, true,'','','',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false);
        // RV_SHT_CreateController.getMRCRecordsData('ATP1', '', accIdSet, '', true, true, true, true,'','','',String.valueOf(System.today().addDays(-10)),String.valueOf(System.today().addDays(5)),false);
        
        //String tranche ,String Mrcno ,Set<Id> accIdSet,String shipto,Boolean checked ,Boolean agoChk,
        //  Boolean igoChk,Boolean mogasChk,string poType,List<String> plant,string mot,string contractStartDate,
        //string contractEndDate,boolean callFromOlf
        //  RV_SHT_CreateControllerLWC.getMRCRecordsData('ATP1', '320076222', new Set<Id>(), '', false, true, true, true,'',new List<String>{mrclst[0].Plant__c},'',String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        //RV_SHT_CreateControllerLWC.getMRCRecordsData('ATP1', 'Truck', new Set<Id>(), '', false, true, true, true,'',new List<String>{mrclst[0].Plant__c},'',String.valueOf(System.today()),String.valueOf(System.today().addDays(14)),false);
        //  RV_SHT_CreateControllerLWC.getMRCRecordsData('ATP2', mrclst[0].MRC_Number__c, new Set<Id>(), '', false, true, true, true,'',new List<String>{mrclst[0].Plant__c},'',String.valueOf(System.today().addDays(15)),String.valueOf(System.today().addDays(28)),false);
        //  RV_SHT_CreateControllerLWC.getMRCRecordsData('ATP1', mrclst[0].MRC_Number__c, new Set<Id>(), '', false, true, true, true,'',new List<String>{mrclst[0].Plant__c},'',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false);
        //  RV_SHT_CreateControllerLWC.getMRCRecordsData('ATP1', mrclst[0].MRC_Number__c, accIdSet, '', false, true, true, true,'',new List<String>{mrclst[0].Plant__c},'',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false);
        // RV_SHT_CreateController.getMRCRecordsData   ('ATP1', mrclst[0].MRC_Number__c, accIdSet, '', true, true, true, true,'',new List<String>{mrclst[0].Plant__c},'',String.valueOf(System.today().addDays(-10)),String.valueOf(System.today().addDays(5)),false);
        // RV_SHT_CreateController.searchRecords('OMMERT');
        test.startTest();
        /*added by Dharmendra for code coverage - Start */
        RV_SHT_CreateController.getMRCRecordsData('ATP1', '', accIdSet, '', true, true, true, true,'TSFP',mrclst[0].Plant__c,'Truck-10',String.valueOf(System.today().addDays(-10)),String.valueOf(System.today().addDays(5)),False);
        RV_SHT_CreateController.getMRCRecordsData('ATP1', '', accIdSet, '', true, true, true, true,'TSFP','ARA/Arnheim Shell depot','Truck-10',String.valueOf(System.today().addDays(-10)),String.valueOf(System.today().addDays(5)),True);
        //String tranche ,String Mrcno ,Set<Id> accIdSet,String shipto,Boolean checked ,Boolean agoChk,
        //  Boolean igoChk,Boolean mogasChk,string poType,List<String> plant,string mot,string contractStartDate,
        //string contractEndDate,boolean callFromOlf
        // RV_SHT_CreateControllerLWC.getMRCRecordsData('ATP1', '320076222', accIdSet, '', true, true, true, true,'TSFP',new List<String>{mrclst[0].Plant__c},'Truck-10',String.valueOf(System.today().addDays(-10)),String.valueOf(System.today().addDays(5)),False);
        // RV_SHT_CreateControllerLWC.getMRCRecordsData('ATP1', '', accIdSet, '', true, true, true, true,'TSFP',new List<String>{mrclst[0].Plant__c},'Truck-10',String.valueOf(System.today().addDays(-10)),String.valueOf(System.today().addDays(5)),True);
        /*added by Dharmendra for code coverage - End */
        test.stopTest();
    }
    
    static testmethod void testGetMrcData(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        test.startTest();
        RV_SHT_CreateController.getMrcData('ATP1', mrclst[0].MRC_Number__c, mrclst[0].Sold_To__c, '', false, true, true, true,'','','',String.valueOf(System.today()),String.valueOf(System.today().addDays(14)),false, false);
        RV_SHT_CreateController.getMrcData('ATP2', mrclst[0].MRC_Number__c, mrclst[0].Sold_To__c, '', false, true, true, true,'','','',String.valueOf(System.today().addDays(15)),String.valueOf(System.today().addDays(28)),false, false);
        //  RV_SHT_CreateController.getMrcData('ATP1', mrclst[0].MRC_Number__c, mrclst[0].Sold_To__c, '', false, true, true, true,'','','',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false, true);
        RV_SHT_CreateController.getMrcData('ATP1', mrclst[0].MRC_Number__c, '', '', false, true, true, true,'','','',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false, true);
        RV_SHT_CreateController.getMrcData('ATP1', '', '', '22222222', false, true, true, true,'TSFP','','',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false, true);
        RV_SHT_CreateController.getMrcData('ATP1', '', '', '', false, true, true, true,'TSFP','','',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false, true);
        RV_SHT_CreateController.searchRecords('OMMERT');
        test.stopTest();
    }
    
    static testmethod void testGetMrcData_1(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        test.startTest();
        RV_SHT_CreateController.getMrcData('ATP1', '', '', '022222222', false, true, true, true,'TSFP',mrclst[0].Plant_code__c,'',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false, true);
        RV_SHT_CreateController.getMrcData('', '', '', '0022222222', false, true, true, true,'TSFP', '','Truck-10',String.valueOf(System.today().addDays(-1)),String.valueOf(System.today().addDays(-2)),false, true);
        /*(String tranche ,String Mrcno ,String accId,
String shipto,Boolean checked ,Boolean agoChk,
Boolean igoChk,Boolean mogasChk,String poType,
List<String> plant,string mot,String contractStartDate,
String contractEndDate,Boolean callFromOlf, Boolean OLFOnly)*/
        //RV_SHT_CreateControllerLWC.getMrcData('', '', '', '0022222222', true, true, true, true,'TSFP', new List<String>(),'Truck-10',String.valueOf(System.today().addDays(-1)),String.valueOf(System.today().addDays(-2)),false, true);
        //RV_SHT_CreateControllerLWC.getMrcData('ATP1', '', '','022222222',false,true, true, true,'TSFP',new List<String>(mrclst[0].Plant_code__c),'Truck-10',String.valueOf(System.today().addDays(61)),String.valueOf(System.today().addDays(100)),false, true);
        RV_SHT_CreateController.searchRecords('OMMERT');
        test.stopTest();
    }
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"TotalItems":"1","Status":"01","SHTItems":[{"SfItemShtNo":"SHT - 146960","SfHeaderShtNo":"1-122815","SapMrcItemNo":"101323","SalesPrice":"20.00","RejectionReason":"","QuantityUom":"CBM","Quantity":"10.00","PriceInd":"F","MaterialNo":"400002410","ItemCount":"1","DealCreationTime":"92815","DealCreationDate":"20210212","CurrencyKey":"EUR","CondUnit":"L15","CondType":"YP23","CondPUnt":"100"}],"SfHeaderShtNo":"1-122815","SapSalesContNo":"","SapMrcNo":"320076181-","SalesOrg":"DE01","POType":"TSFP","MsgTxt":"","InstanceURL":"T","ContStartDate":"20210212","ContEndDate":"20210225","Action":"C"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    static testmethod void saveSHTObjectRecord(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Mrc__C> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        List<SHT__c> shtList = [select id,name,MRC__c,MRC_Number__c,Customer__c,Tranche__c,BSP__c,MSP__c,Status__c,Select__c,Sales_Type__c,Contract_Start__c,Contract_End_Date__c,Deal_Comment__c,Product_Category__c from SHT__c];
        System.debug('inside method ::' +shtList.size());
        List<Account> accLst=[Select Id from Account WHERE Customer_Type__c = 'Sold To'];
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : [Select Id from Account WHERE Customer_Type__c = 'Ship To']){
            accIdSet.add(acc.Id);
        }
        List<RV_SHT_CreateController.MRCDataWrap> wrplst = new List<RV_SHT_CreateController.MRCDataWrap>();
        wrpLst=RV_SHT_CreateController.getMRCRecordsData('ATP1', mrclst[0].MRC_Number__c, new Set<Id>(), '', false, true, true, true,'','','',String.valueOf(System.today()),String.valueOf(System.today().addDays(14)),false);
        for(RV_SHT_CreateController.MRCDataWrap wrp :wrpLst){
            wrp.volumeCBM=100;
            wrp.pricePerVol=110;
            wrp.Comment='test';
        }
        RV_SHT_CreateController.saveResultsearchWrap srchwrp = new RV_SHT_CreateController.saveResultsearchWrap();
        
        string mrcdata= JSON.serialize(wrplst);
        test.startTest();
        RV_SHT_CreateController.searchDependentShipToMRC(accLst[0].id, '');
        RV_SHT_CreateController.searchDependentShipToMRC('', '11111111');
        RV_SHT_CreateController.searchDependentShipToMRC('', '011111111');
        RV_SHT_CreateController.searchDependentShipToMRC('', '0011111111');
        //RV_SHT_CreateController.getSelAccountPOTypeMRC(accLst[0].id,'TSFP', '');
        RV_SHT_CreateController.saveSHTObjectRecord(mrcdata,'ATP2',accLst[0].Id,'Obam Sales',string.valueof(system.today().addDays(15)),string.valueof(system.today().addDays(27)),false);
        srchwrp = RV_SHT_CreateController.saveSHTObjectRecord(mrcdata,'ATP1', accLst[0].Id,'Obam Sales',string.valueof(system.today().addDays(-10)),string.valueof(system.today().addDays(4)),true);
        List<RV_SHT_CreateController.SHTDisplayWrap> savedResult = srchwrp.savedResult;
        
        RV_SHT_CreateController.getContarctEndDate(string.valueof(system.today()));
        RV_SHT_CreateController.getContarctEndDate(string.valueof(system.today().addDays(-1)));
        RV_SHT_CreateController.getAllSHTDeals();
        string savedataList= JSON.serialize(savedResult);
        RV_SHT_CreateController.updateSHTObjectRecord(savedataList);
        RV_SHT_CreateController.cancelSHTDeal(savedResult[0].shtRecordId,'Saved','saved deal',mrcdata);
        RV_SHT_CreateController.getMinPossibleContractStartDate();
        RV_SHT_CreateController.getCompletedSHTDeal('Today', 'Saved', 'Me');
        RV_SHT_CreateController.getCompletedSHTDeal('LAST_DEAL_DATE', 'Saved', 'Me');
        RV_SHT_CreateController.getCompletedSHTDeal('LAST_WEEK', 'Saved', 'Me');
        RV_SHT_CreateController.getCompletedSHTDeal('THIS_WEEK', 'Saved', '');
        RV_SHT_CreateController.getCompletedSHTDeal('', 'Saved', '');
        RV_SHT_CreateController.updateDealComment(shtList[0].Id,'test123');
        RV_SHT_CreateController.updateDealComment(savedResult[1].shtRecordId,'');
        RV_SHT_CreateController.updateDealComment(savedResult[2].shtRecordId,null);
        //Fix_170853_13May2019_Soumyajit starts
        RV_SHT_CreateController.getLastDealDate('Completed');
        RV_SHT_CreateController.getUserList();
        String userId = String.valueOf(UserInfo.getUserId());
        RV_SHT_CreateController.getCompletedSHTDealWithAdvanceFilterWrap(string.valueof(system.today()),string.valueof(system.today()),'5','Completed', 'Me','','',false, ''); //270192_OLFDealCancel_08Jul2019_Soumyajit
        RV_SHT_CreateController.getCompletedSHTDealWithAdvanceFilterWrap(null,null,'5','Completed', 'ALL','23323','',false, '');
        
        RV_SHT_CreateController.getCompletedSHTDealWithAdvanceFilterWrap(string.valueof(system.today()),string.valueof(system.today()),'5','Completed',userId,'23323',mrclst[0].Name,false, '');
        RV_SHT_CreateController.getCompletedSHTDealWithAdvanceFilterWrap(string.valueof(system.today()),string.valueof(system.today().addDays(15)),'5','Completed',userId,'23323',mrclst[0].Name,false, '');
        //Fix_170853_13May2019_Soumyajit ends
        /* added by Dharmendra for code coverage - Start*/
        RV_SHT_CreateController.saveSHTObjectRecord(mrcdata,'ATP2',accLst[0].Id,'Obam Sales',string.valueof(system.today().addDays(-1)),string.valueof(system.today()),false);
        RV_SHT_CreateController.cancelSHTDeal(shtList[0].Id,'Completed','Wrong Product-Name',mrcdata);
        //RV_SHT_CreateController.cancelSHTDeal(shtList[0].Id,'Saved','Wrong-Product-Name',mrcdata);
        /* added by Dharmendra for code coverage - End*/
        test.stopTest();
    }
    
    @isTest
    static void test_calculateRetailMixPrice(){
        List<Mrc__C> mrclst = [SELECT Id,
                               Name,
                               Material_Description__c,
                               Sold_To__c,
                               Plant__c,
                               Plant__r.Name,
                               Plant_code__c,
                               Supply_Type__c,
                               Product__c,
                               Product__r.Name,
                               Product__r.Commodity_Grade_L2__c,
                               Product__r.BEHG_Value_100l__c,
                               Product__r.Current_BEHG_valid_from_date__c,
                               Product__r.Current_BEHG_valid_to_date__c,
                               Product__r.Future_BEHG_value_in_100l__c,
                               Product__r.Future_BEHG_valid_from_date__c,
                               Product__r.Future_BEHG_valid_to_date__c,
                               Material_Name__c,
                               PO_Type__c,
                               Sold_To__r.Name,
                               Handling_Type__c,
                               Sales_Organization__c,
                               MRC_Number__c,
                               Ship_to_Name__c,
                               Shipping_Condition__c,
                               Online_Location_Name__c,
                               Online_Material_Name_Taxed__c,
                               Online_Material_Name_UnTaxed__c,
                               Online_Customer_Name__c,
                               Ship_to_Number__c FROM Mrc__c];
        RV_SHT_CreateController.calculateRetailMixPrice(mrclst, String.valueOf(Date.today()), String.valueOf(Date.today()));
    }
    
    static testmethod void testmethod_lwc(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,Contract__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        
        Set<Id> accIdSet = new Set<Id>();
        List<Id> accShipToId = new List<Id>();
        List<Id> accSoldToId = new List<Id>();
        for(Account acc : [Select Id,Customer_Type__c from Account]){
            if(acc.Customer_Type__c=='Ship To'){
                accIdSet.add(acc.Id);
                accShipToId.add(acc.Id);
            }
            else if(acc.Customer_Type__c=='Sold To'){
                accSoldToId.add(acc.Id);
            }
        }
        List<Location__c> location = [select id,name from Location__c where name = 'Ludwigshafen depot'];
        List<String> plantId = new List<String>();
        for(Location__c loc:location){
            plantId.add(loc.id);
        }
        List<String> mot = new List<String>();
        mot.add('10');
        
        List<SHT__c> shtList = [select id,name,MRC__c,MRC_Number__c,Customer__c,Tranche__c,BSP__c,MSP__c,Status__c,Select__c,Sales_Type__c,Contract_Start__c,Contract_End_Date__c,Deal_Comment__c,Product_Category__c from SHT__c];
        List<String> shtIds = new List<String>();
        for(SHT__c sh : shtList){
            shtIds.add(sh.Id);
        }
        
        rv_sht_CreateControllerLWC.MRCDataWrap mrcwrap = new rv_sht_CreateControllerLWC.MRCDataWrap();
        mrcwrap.mrcId = mrclst[0].id;
        mrcwrap.mrcName = '0321539467-100052';
        mrcwrap.locationName = 'Godorf Shell Gantry';
        mrcwrap.grade = 'ULG95 E10';
        mrcwrap.atpLive = 100;
        mrcwrap.Comment = 'cancelled deal SHT -';
        mrcwrap.salesOrg = 'AT02';
        
        List<rv_sht_CreateControllerLWC.MRCDataWrap> searchList = new List<rv_sht_CreateControllerLWC.MRCDataWrap>();
        searchList.add(mrcwrap);
        string searchList1= JSON.serialize(searchList);
        
        rv_sht_CreateControllerLWC.MRCDataWrap mrcwrap1 = new rv_sht_CreateControllerLWC.MRCDataWrap();
        string contractStartDate = string.valueOf(system.today().addDays(-1));
        string contractEndDate = string.valueOf(system.today().addDays(15));
        string contractEndDate1 = string.valueOf(system.today().addDays(1));
        //string contractStartDate = '2022-04-20';
        //string contractEndDate = '2022-05-20';
        List<MRC__c> mrcUlg = [select id,name,Plant__c,Plant__r.Name,Plant_code__c,Contract__c,
                               Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                               Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                               Ship_to_Name__c,Shipping_Condition__c from MRC__c where name ='000000000-100052'];
        system.debug('mrcUlg in testclass:'+mrcUlg);
        system.debug('mrcUlg[0].Sold_To__c:'+mrcUlg[0].Sold_To__c);
        system.debug('accSoldToId[0]:'+accSoldToId[0]);
        mrcwrap1.mrcId = mrcUlg[0].id;
        mrcwrap1.accId = mrcUlg[0].Sold_To__c;
        mrcwrap1.mrcName = '000000000-100052';
        mrcwrap1.locationName = 'Godorf Shell Gantry';
        mrcwrap1.location = mrcUlg[0].Plant_code__c;
        mrcwrap1.shipToNumber = mrcUlg[0].Ship_to_Number__c; 
        mrcwrap1.grade = 'ULG95 E10';
        mrcwrap1.atpLive = 100;
        mrcwrap1.volumeCBM = 100;
        mrcwrap1.finalbspCal = 90;
        mrcwrap1.finalSalesPriceCal = 80;
        mrcwrap1.pricePerVol = 90;
        mrcwrap1.cancellationReason = 'Wrong Product';
        mrcwrap1.spPer100L = 100;
        mrcwrap1.msp = 100;
        mrcwrap1.bsp = 60;
        mrcwrap1.contractStartDate = contractStartDate;
        mrcwrap1.contractEndDate = contractEndDate;
        mrcwrap1.isPricingTaxed = true;
        mrcwrap1.pricingCondition = 'yes';
        mrcwrap1.atpVoltoBeReduced = true;
        mrcwrap1.isVolToBeHedged = true;
        mrcwrap1.isZeroPriceDeal = false;
        mrcwrap1.isGsapDealCreateOn = false;
        mrcwrap1.isGsapDealCancelOn = false;
        mrcwrap1.Comment = 'cancelled deal SHT -';
        mrcwrap1.salesOrg = 'AT02';
        List<rv_sht_CreateControllerLWC.MRCDataWrap> search2 = new List<rv_sht_CreateControllerLWC.MRCDataWrap>();
        search2.add(mrcwrap1);
        string search3= JSON.serialize(search2);
        String search4 = search3;
        search3 = search3.replace('[', '');
        search3 = search3.replace(']', '' );
        
        Set<Id> mrcIds = new Set<Id>();
        mrcIds.add(mrcUlg[0].id);
        test.startTest();
        rv_sht_CreateControllerLWC.getMRCRecordsData('ATP1', '0321539467',accIdSet,new List<String>{'0012610307'},true, true, true, true,'TSFP','AT01;DE01',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        //   rv_sht_CreateControllerLWC.getMRCRecordsData('ATP2', '0321539467',accIdSet,new List<String>{'0012610307'},true, true, true, true,'TSFP','AT01;DE01',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        
        //rv_sht_CreateControllerLWC.getMRCRecordsData('ATP2', '0321539467', accIdSet, '0012610307',true, true, true, true,'TSFP',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        //rv_sht_CreateControllerLWC.getMRCRecordsData('ATP3', '0321539467', accIdSet, '0012610307',true, true, true, true,'TSFP',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        rv_sht_CreateControllerLWC.updateDealComment(shtList[0].id,'Test1');
        rv_sht_CreateControllerLWC.cancelSHTDeal(shtList[0].id,'Saved','Wrong Product',searchList1);
        rv_sht_CreateControllerLWC.cancelSHTDeal(shtList[0].id,'Auto-Completed','Wrong Product',searchList1);
        rv_sht_CreateControllerLWC.cancelSHTDeal(shtList[0].id,'Completed','Wrong Product-Name',searchList1);
        
      //  rv_sht_CreateControllerLWC.saveCancelledDealLWC(search3);
        RV_SHT_CreateController.saveCancelledDealLWC(search3);
        rv_sht_CreateControllerLWC.saveResultsearchWrap saveResult = rv_sht_CreateControllerLWC.saveSHTObjectRecordLWC(search4,'ATP1',contractStartDate,contractEndDate, true);
        system.debug('saveResult in testclass:'+saveResult);
        String account = string.valueOf(accShipToId[0]);
        rv_sht_CreateControllerLWC.saveSHTObjectRecord(search4,'ATP1',account,'Obam Sales',contractStartDate,contractEndDate,true);
        
        rv_sht_CreateControllerLWC.getSavedDealPricePerMrc(mrcIds,contractStartDate, contractEndDate);
        rv_sht_CreateControllerLWC.searchDependentShipToMRC(account,'22222222');
        rv_sht_CreateControllerLWC.getShippingConditionMap();
        rv_sht_CreateControllerLWC.searchRecords(account);
        rv_sht_CreateControllerLWC.getAllSHTDeals();
        //rv_sht_CreateControllerLWC.updateSHTObjectRecord(search4);
        rv_sht_CreateControllerLWC.getLastDealDate('Saved');
        rv_sht_CreateControllerLWC.getUserList();
        rv_sht_CreateControllerLWC.getCompletedSHTDealWithAdvanceFilterWrap(contractStartDate,contractEndDate1,'5','Saved','ALL','','',false,'');
        rv_sht_CreateControllerLWC.getMinPossibleContractStartDate();
        rv_sht_CreateControllerLWC.getContarctEndDate(contractStartDate);
        rv_sht_CreateControllerLWC.getContarctEndDate(string.valueOf(system.today().addDays(-1)));
        rv_sht_CreateControllerLWC.getContarctEndDate(string.valueOf(system.today()));
        rv_sht_CreateControllerLWC.getMaxContractEndDate();
        rv_sht_CreateControllerLWC.getMrcData('ATP1', '0321539467', account, new List<String>{'0012610307'},true, true, true, true,'TSFP','AT01;DE01',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false,false);
        
        //rv_sht_CreateControllerLWC.getSHTDealsForPriceAndMarket
        rv_sht_CreateControllerLWC.retrySHTDealtoGSAP(shtIds);
        
        
        rv_sht_CreateControllerLWC.SHTDisplayWrap shtDispWrap = new rv_sht_CreateControllerLWC.SHTDisplayWrap();
        shtDispWrap.shtRecordId = shtList[0].id ;
        shtDispWrap.selected = false;
        shtDispWrap.shtNo='test';
        shtDispWrap.MrcNo = shtList[0].MRC_Number__c;
        shtDispWrap.MrcId = shtList[0].MRC__c;
        shtDispWrap.CustomerId = shtList[0].Customer__c;
        shtDispWrap.Customer = 'ADAM OMMERT MINERALOELHANDEL';
        shtDispWrap.shipToNumber = '0012610307';
        shtDispWrap.location ='Ludwigshafen depot';
        shtDispWrap.locationId=location[0].id;
        //shtDispWrap.locationCode='DE01';
        shtDispWrap.product=shtList[0].Product_Category__c;
        shtDispWrap.materialNo='1234';
        shtDispWrap.materialName='TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        shtDispWrap.volCbm=100;
        shtDispWrap.spPer100L=100;
        shtDispWrap.bsp=100;
        shtDispWrap.targetMargin=100;
        shtDispWrap.msp=100;
        shtDispWrap.contractStartDate = date.valueOf(contractStartDate);
        shtDispWrap.contractEndDate = date.valueOf(contractEndDate);
        shtDispWrap.dealStatus='Saved';
        shtDispWrap.cancellationReason='Wrong Product';
        shtDispWrap.Comment='Test';
        shtDispWrap.gsapContract='';
        shtDispWrap.isZeroPriceDeal=false;
        shtDispWrap.gsapError='Error';
        shtDispWrap.poType='TSFP';
        shtDispWrap.otm=100;
        shtDispWrap.salesPrice=100;
        
        List<rv_sht_CreateControllerLWC.SHTDisplayWrap> completedDeals = new List<rv_sht_CreateControllerLWC.SHTDisplayWrap>();
        completedDeals.add(shtDispWrap);
        //rv_sht_CreateControllerLWC.getSHTDealsForPriceAndMarket(completedDeals);
        
        
        RV_SHT_CreateController.SHTDisplayWrap rv_shtDispWrap = new RV_SHT_CreateController.SHTDisplayWrap();
        rv_shtDispWrap.shtRecordId = shtList[0].id ;
        rv_shtDispWrap.selected = false;
        rv_shtDispWrap.shtNo='test';
        rv_shtDispWrap.MrcNo = shtList[0].MRC_Number__c;
        rv_shtDispWrap.MrcId = shtList[0].MRC__c;
        rv_shtDispWrap.CustomerId = shtList[0].Customer__c;
        rv_shtDispWrap.Customer = 'ADAM OMMERT MINERALOELHANDEL';
        rv_shtDispWrap.shipToNumber = '0012610307';
        rv_shtDispWrap.location ='Ludwigshafen depot';
        rv_shtDispWrap.locationId=location[0].id;
        //rv_shtDispWrap.locationCode='DE01';
        rv_shtDispWrap.product=shtList[0].Product_Category__c;
        rv_shtDispWrap.materialNo='1234';
        rv_shtDispWrap.materialName='TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        rv_shtDispWrap.volCbm=100;
        rv_shtDispWrap.spPer100L=100;
        rv_shtDispWrap.bsp=100;
        rv_shtDispWrap.targetMargin=100;
        rv_shtDispWrap.msp=100;
        rv_shtDispWrap.contractStartDate = date.valueOf(contractStartDate);
        rv_shtDispWrap.contractEndDate = date.valueOf(contractEndDate);
        rv_shtDispWrap.dealStatus='Saved';
        rv_shtDispWrap.cancellationReason='Wrong Product';
        rv_shtDispWrap.Comment='Test';
        rv_shtDispWrap.gsapContract='';
        rv_shtDispWrap.isZeroPriceDeal=false;
        rv_shtDispWrap.gsapError='Error';
        rv_shtDispWrap.poType='TSFP';
        rv_shtDispWrap.otm=100;
        rv_shtDispWrap.salesPrice=100;
        
        RV_SHT_CreateController.SHTDisplayWrap rv_shtDispWrapObj = new RV_SHT_CreateController.SHTDisplayWrap();
        rv_shtDispWrapObj.shtRecordId = shtList[1].id ;
        rv_shtDispWrapObj.selected = false;
        rv_shtDispWrapObj.shtNo='test';
        rv_shtDispWrapObj.MrcNo = shtList[1].MRC_Number__c;
        rv_shtDispWrapObj.MrcId = shtList[1].MRC__c;
        rv_shtDispWrapObj.CustomerId = shtList[1].Customer__c;
        rv_shtDispWrapObj.Customer = 'ADAM OMMERT MINERALOELHANDEL';
        rv_shtDispWrapObj.shipToNumber = '0012610307';
        rv_shtDispWrapObj.location ='Ludwigshafen depot';
        rv_shtDispWrapObj.locationId=location[0].id;
        //rv_shtDispWrapObj.locationCode='DE01';
        rv_shtDispWrapObj.product=shtList[1].Product_Category__c;
        rv_shtDispWrapObj.materialNo='1234';
        rv_shtDispWrapObj.materialName='TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        rv_shtDispWrapObj.volCbm=100;
        rv_shtDispWrapObj.spPer100L=100;
        rv_shtDispWrapObj.bsp=100;
        rv_shtDispWrapObj.targetMargin=100;
        rv_shtDispWrapObj.msp=100;
        rv_shtDispWrapObj.contractStartDate = date.valueOf(contractStartDate);
        rv_shtDispWrapObj.contractEndDate = date.valueOf(contractEndDate);
        rv_shtDispWrapObj.dealStatus='Saved';
        rv_shtDispWrapObj.cancellationReason='Wrong Product';
        rv_shtDispWrapObj.Comment='Test';
        rv_shtDispWrapObj.gsapContract='';
        rv_shtDispWrapObj.isZeroPriceDeal=false;
        rv_shtDispWrapObj.gsapError='Error';
        rv_shtDispWrapObj.poType='TSFP';
        rv_shtDispWrapObj.otm=100;
        rv_shtDispWrapObj.salesPrice=100;
        
        List<RV_SHT_CreateController.SHTDisplayWrap> rv_completedDeals = new List<RV_SHT_CreateController.SHTDisplayWrap>();
        rv_completedDeals.add(rv_shtDispWrap);
        rv_completedDeals.add(rv_shtDispWrapObj);             
       // RV_SHT_CreateController.getSHTDealsForPriceAndMarket(rv_completedDeals);
        //retrySHTDealtoGSAP
        test.stopTest();
    }
    static testmethod void testmethod_lwc2(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,Contract__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        
        Set<Id> accIdSet = new Set<Id>();
        List<Id> accShipToId = new List<Id>();
        List<Id> accSoldToId = new List<Id>();
        for(Account acc : [Select Id,Customer_Type__c from Account]){
            if(acc.Customer_Type__c=='Ship To'){
                accIdSet.add(acc.Id);
                accShipToId.add(acc.Id);
            }
            else if(acc.Customer_Type__c=='Sold To'){
                accSoldToId.add(acc.Id);
            }
        }
        List<Location__c> location = [select id,name from Location__c where name = 'Ludwigshafen depot'];
        List<String> plantId = new List<String>();
        for(Location__c loc:location){
            plantId.add(loc.id);
        }
        List<String> mot = new List<String>();
        mot.add('10');
        
        List<SHT__c> shtList = [select id,name,MRC__c,MRC_Number__c,Customer__c,Tranche__c,BSP__c,MSP__c,Status__c,Select__c,Sales_Type__c,Contract_Start__c,Contract_End_Date__c,Deal_Comment__c,Product_Category__c from SHT__c where MRC__c =:mrclst[0].id];
        List<String> shtIds = new List<String>();
        for(SHT__c sh : shtList){
            shtIds.add(sh.Id);
        }
        
        rv_sht_CreateControllerLWC.MRCDataWrap mrcwrap1 = new rv_sht_CreateControllerLWC.MRCDataWrap();
        RV_SHT_CreateController.MRCDataWrap mrcwrap2 = new RV_SHT_CreateController.MRCDataWrap();
        string contractStartDate = string.valueOf(system.today());
        string contractEndDate = string.valueOf(system.today().addDays(15));
        string contractEndDate1 = string.valueOf(system.today().addDays(1));
        List<MRC__c> mrcUlg = [select id,name,Plant__c,Plant__r.Name,Plant_code__c,Contract__c,
                               Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                               Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                               Ship_to_Name__c,Shipping_Condition__c from MRC__c where name ='000000000-100052'];
        mrcwrap1.mrcId = mrcUlg[0].id;
        mrcwrap1.accId = mrcUlg[0].Sold_To__c;
        mrcwrap1.mrcName = '000000000-100052';
        mrcwrap1.locationName = 'Godorf Shell Gantry';
        mrcwrap1.location = mrcUlg[0].Plant_code__c;
        mrcwrap1.shipToNumber = mrcUlg[0].Ship_to_Number__c; 
        mrcwrap1.grade = 'ULG95 E10';
        mrcwrap1.atpLive = 100;
        mrcwrap1.volumeCBM = 100;
        mrcwrap1.finalbspCal = 90;
        mrcwrap1.finalSalesPriceCal = 80;
        mrcwrap1.pricePerVol = 90;
        mrcwrap1.cancellationReason = 'Wrong Product';
        mrcwrap1.spPer100L = 100;
        mrcwrap1.msp = 100;
        mrcwrap1.contractStartDate = contractStartDate;
        mrcwrap1.contractEndDate = contractEndDate;
        mrcwrap1.isPricingTaxed = true;
        mrcwrap1.pricingCondition = 'yes';
        mrcwrap1.atpVoltoBeReduced = true;
        mrcwrap1.isVolToBeHedged = true;
        mrcwrap1.isZeroPriceDeal = false;
        mrcwrap1.isGsapDealCreateOn = false;
        mrcwrap1.isGsapDealCancelOn = false;
        mrcwrap1.salesOrg ='AT02';

        List<rv_sht_CreateControllerLWC.MRCDataWrap> search2 = new List<rv_sht_CreateControllerLWC.MRCDataWrap>();
        search2.add(mrcwrap1);
        string search3= JSON.serialize(search2);
        String search4 = search3;
        
        mrcwrap2.mrcId = mrcUlg[0].id;
        mrcwrap2.accId = mrcUlg[0].Sold_To__c;
        mrcwrap2.mrcName = '000000000-100052';
        mrcwrap2.locationName = 'Godorf Shell Gantry';
        mrcwrap2.grade = 'ULG95 E10';
        mrcwrap2.atpLive = 100;
        mrcwrap2.volumeCBM = 100;
        mrcwrap2.finalbspCal = 90;
        mrcwrap2.finalSalesPriceCal = 80;
        mrcwrap2.pricePerVol = 90;
        mrcwrap2.cancellationReason = 'Wrong Product';
        mrcwrap2.spPer100L = 100;
        mrcwrap2.msp = 100;
        mrcwrap2.contractStartDate =  string.valueOf(system.today().addDays(-1));
        mrcwrap2.contractEndDate =  string.valueOf(system.today());
        mrcwrap2.isPricingTaxed = true;
        mrcwrap2.pricingCondition = 'yes';
        mrcwrap2.atpVoltoBeReduced = true;
        mrcwrap2.isVolToBeHedged = true;
        mrcwrap2.isZeroPriceDeal = false;
        mrcwrap2.isGsapDealCreateOn = false;
        mrcwrap2.isGsapDealCancelOn = false;
        mrcwrap2.salesOrg ='AT02';
        List<RV_SHT_CreateController.MRCDataWrap> search5 = new List<RV_SHT_CreateController.MRCDataWrap>();
        search5.add(mrcwrap2);
        string search6= JSON.serialize(search5);
        String search7= search6;
        Test.startTest();
        rv_sht_CreateControllerLWC.getMRCRecordsData('ATP2', '0321539467', accIdSet,new List<String>{'0012610307'},true, true, true, true,'TSFP',' ',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        rv_sht_CreateControllerLWC.getMRCRecordsData('ATP3', '0321539467', accIdSet,new List<String>{'0012610307'},true, true, true, true,'TSFP',' ',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        rv_sht_CreateControllerLWC.updateSHTObjectRecord(search4);
        RV_SHT_CreateController.updateSHTObjectRecord(search7);
        mrcwrap2.contractEndDate = string.valueOf(system.today().addDays(1));
        search5.add(mrcwrap2);
        search6= JSON.serialize(search5);
        search7= search6;
        RV_SHT_CreateController.updateSHTObjectRecord(search7);
        rv_sht_CreateControllerLWC.getCompletedSHTDeal('LAST_DEAL_DATE', 'Saved', 'ALL');
        //  rv_sht_CreateControllerLWC.getMRCRecordsData('ATP1', '0321539467',accIdSet,new List<String>{'0012610307'},true, true, true, true,'TSFP','AT01;DE01',plantId,mot,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)),false);
        
        try{
            rv_sht_CreateControllerLWC.checkMRC('321799369');
        }catch(Exception e){
            
        }
        Test.stopTest();
        
    }
    
    static testmethod void test_saveSHTObjectRecordLWC(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,Contract__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        
        Set<Id> accIdSet = new Set<Id>();
        List<Id> accShipToId = new List<Id>();
        List<Id> accSoldToId = new List<Id>();
        for(Account acc : [Select Id,Customer_Type__c from Account]){
            if(acc.Customer_Type__c=='Ship To'){
                accIdSet.add(acc.Id);
                accShipToId.add(acc.Id);
            }
            else if(acc.Customer_Type__c=='Sold To'){
                accSoldToId.add(acc.Id);
            }
        }
        List<Location__c> location = [select id,name from Location__c where name = 'Ludwigshafen depot'];
        List<String> plantId = new List<String>();
        for(Location__c loc:location){
            plantId.add(loc.id);
        }
        List<String> mot = new List<String>();
        mot.add('10');
        
        List<SHT__c> shtList = [select id,name,MRC__c,MRC_Number__c,Customer__c,Tranche__c,BSP__c,MSP__c,Status__c,Select__c,Sales_Type__c,Contract_Start__c,Contract_End_Date__c,Deal_Comment__c,Product_Category__c from SHT__c];
        List<String> shtIds = new List<String>();
        for(SHT__c sh : shtList){
            shtIds.add(sh.Id);
        }
        
        rv_sht_CreateControllerLWC.MRCDataWrap mrcwrap = new rv_sht_CreateControllerLWC.MRCDataWrap();
        mrcwrap.mrcId = mrclst[0].id;
        mrcwrap.mrcName = '0321539467-100052';
        mrcwrap.locationName = 'Godorf Shell Gantry';
        mrcwrap.location = mrclst[0].Plant_code__c;
        mrcwrap.shipToNumber = mrclst[0].Ship_to_Number__c; 
        mrcwrap.grade = 'ULG95 E10';
        mrcwrap.atpLive = 100;
        mrcwrap.Comment = 'cancelled deal SHT -';
        mrcwrap.salesOrg ='AT02';
        
        List<rv_sht_CreateControllerLWC.MRCDataWrap> searchList = new List<rv_sht_CreateControllerLWC.MRCDataWrap>();
        searchList.add(mrcwrap);
        string searchList1= JSON.serialize(searchList);
        
        rv_sht_CreateControllerLWC.MRCDataWrap mrcwrap1 = new rv_sht_CreateControllerLWC.MRCDataWrap();
        string contractStartDate = string.valueOf(system.today().addDays(-1));
        string contractEndDate = string.valueOf(system.today().addDays(15));
        string contractEndDate1 = string.valueOf(system.today().addDays(1));
        //string contractStartDate = '2022-04-20';
        //string contractEndDate = '2022-05-20';
        List<MRC__c> mrcUlg = [select id,name,Plant__c,Plant__r.Name,Plant_code__c,Contract__c,
                               Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                               Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                               Ship_to_Name__c,Shipping_Condition__c from MRC__c where name ='000000000-100052'];
        system.debug('mrcUlg in testclass:'+mrcUlg);
        system.debug('mrcUlg[0].Sold_To__c:'+mrcUlg[0].Sold_To__c);
        system.debug('accSoldToId[0]:'+accSoldToId[0]);
        mrcwrap1.mrcId = mrcUlg[0].id;
        mrcwrap1.accId = mrcUlg[0].Sold_To__c;
        mrcwrap1.mrcName = '000000000-100052';
        mrcwrap1.locationName = 'Godorf Shell Gantry';
        mrcwrap1.location = mrcUlg[0].Plant_code__c;
        mrcwrap1.shipToNumber = mrcUlg[0].Ship_to_Number__c; 
        mrcwrap1.grade = 'ULG95 E10';
        mrcwrap1.atpLive = 100;
        mrcwrap1.volumeCBM = 100;
        mrcwrap1.finalbspCal = 90;
        mrcwrap1.finalSalesPriceCal = 80;
        mrcwrap1.pricePerVol = 90;
        mrcwrap1.cancellationReason = 'Wrong Product';
        mrcwrap1.spPer100L = 100;
        mrcwrap1.msp = 100;
        mrcwrap1.bsp = 60;
        mrcwrap1.contractStartDate = contractStartDate;
        mrcwrap1.contractEndDate = contractEndDate;
        mrcwrap1.isPricingTaxed = true;
        mrcwrap1.pricingCondition = 'yes';
        mrcwrap1.atpVoltoBeReduced = true;
        mrcwrap1.isVolToBeHedged = true;
        mrcwrap1.isZeroPriceDeal = false;
        mrcwrap1.isGsapDealCreateOn = false;
        mrcwrap1.isGsapDealCancelOn = false;
        mrcwrap1.Comment = 'cancelled deal SHT -';
        mrcwrap1.salesOrg ='AT02';

        List<rv_sht_CreateControllerLWC.MRCDataWrap> search2 = new List<rv_sht_CreateControllerLWC.MRCDataWrap>();
        search2.add(mrcwrap1);
        string search3= JSON.serialize(search2);
        String search4 = search3;
        search3 = search3.replace('[', '');
        search3 = search3.replace(']', '' );
        
        Set<Id> mrcIds = new Set<Id>();
        mrcIds.add(mrcUlg[0].id);
        List<Account> accLst=[Select Id from Account WHERE Customer_Type__c = 'Sold To'];

        test.startTest();        
        rv_sht_CreateControllerLWC.saveResultsearchWrap saveResult = rv_sht_CreateControllerLWC.saveSHTObjectRecordLWC(search4,'ATP1',contractStartDate,contractEndDate, true);
        rv_sht_CreateControllerLWC.searchDependentShipToMRC('', '000000');
        rv_sht_CreateControllerLWC.searchDependentShipToMRC('', '012222');
        rv_sht_CreateControllerLWC.searchDependentShipToMRC('', '222222');

        test.stopTest();
    }
}