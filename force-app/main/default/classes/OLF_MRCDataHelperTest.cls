@isTest
public class OLF_MRCDataHelperTest {
    
    @testSetup 
    static void setup() {   
        List<Location__c> locList = new List<Location__c>();
        //Insert loc
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
        //insert loc ==;
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
        Account accDmyShipTo = RV_TestDataFactory.createShipToCustomer(accDmy, 'Shell Revolution Special Co.(Dummy)', true, true, 'mrcdatahelper1@test.com', false, '11111111');
        insert accDmyShipTo;
        
        //Insert Account Sold To
        Account acc = RV_TestDataFactory.createSoldToCustomer('ADAM OMMERT MINERALOELHANDEL', '22222222', true, true, false);
        insert acc;
        
        //Insert Account Ship To
        Account accShipTo = RV_TestDataFactory.createShipToCustomer(acc, 'ADAM OMMERT MINERALOELHANDEL', true, true, 'mrcdatahelper2@test.com', false, '22222222');
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
        mrAgo.Plant__c=loc.Id;
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
        mrDmyAgo.Shipping_Condition__c=10;
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
        routeUlg3rd.Valid_To__c=System.today();
        routeUlg3rd.Valid_From__c=System.today().addDays(-10);
        //Fix_493485_Lakshmi_27Apr2020_Ends
        //insert routeUlg3rd;
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
        
    }
    static testMethod void getAtpforPlant(){
        Set<Id> accIdSet = new Set<Id>();
                for(Account acc : [Select Id from Account where Customer_Type__c ='Ship To']){
            accIdSet.add(acc.Id);
                                       
        }
         Set<String> plantCodeSet = new Set<String>();  
        Set<String> plantCodeSet2 = new Set<String>();       
        Set<String> plantCodeSet3= new Set<String>();       
       List<RV_SHT_CreateController.MRCDataWrap> mrcMasterData = OLF_MRCDataHelper.getMRCRecordsData('ATP1',accIdSet,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)));        
  		       List<RV_SHT_CreateController.MRCDataWrap> mrcMasterData2 = OLF_MRCDataHelper.getMRCRecordsData('ATP2',accIdSet,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)));        
       List<RV_SHT_CreateController.MRCDataWrap> mrcMasterData3 = OLF_MRCDataHelper.getMRCRecordsData('ATP3',accIdSet,String.valueOf(System.today()),String.valueOf(System.today().addDays(-1)));        

        for(RV_SHT_CreateController.MRCDataWrap wrp : mrcMasterData){
                plantCodeSet.add(wrp.location); 
            }
        for(RV_SHT_CreateController.MRCDataWrap wrp : mrcMasterData){
                plantCodeSet2.add(wrp.location); 
            }
        for(RV_SHT_CreateController.MRCDataWrap wrp : mrcMasterData){
                plantCodeSet3.add(wrp.location); 
            }
        Test.startTest();
               OLF_MRCDataHelper.getAtpforPlant(plantCodeSet, null, new List<String>{'ATP1'});
        OLF_MRCDataHelper.getAtpforPlant(plantCodeSet2, null, new List<String>{'ATP2'});
        OLF_MRCDataHelper.getAtpforPlant(plantCodeSet3, null, new List<String>{'ATP3'});
		Test.stopTest();
    }
    
    static testmethod void getMRCRecordsData(){
        List<Mrc__c> mrclst=[select id,name,Plant__c,Plant__r.Name,Plant_code__c,
                             Supply_Type__c,Product__c,Product__r.Name,Material_Description__c,Material_Name__c,PO_Type__c,
                             Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                             Ship_to_Name__c,Shipping_Condition__c from MRC__c];
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : [Select Id from Account where Customer_Type__c ='Ship To']){
            accIdSet.add(acc.Id);
        }       
   
        test.startTest();
                //OLF_MRCDataHelper.getMRCRecordsData('ATP1',accIdSet,String.valueOf(System.today().addDays(-10)),String.valueOf(System.today().addDays(5)));        

              test.stopTest();
    }
    
    static testmethod void sendEmailandDeactivate(){
        test.startTest();
        OLF_MRCDataHelper.sendEmailandDeactivate('OLFClass', 'Exception');
         test.stopTest();
    }
     
    
  
}