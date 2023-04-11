@isTest
public class RV_TermTriggerTest {

    public static testmethod void getPicklistvaluesMonthTest(){
        //Insert Account Sold  TO
        Account acc = RV_TestDataFactory.createSoldToCustomer('ADAM OMMERT MINERALOELHANDEL', '22222222', true, true, false);
        insert acc;
        //Insert Account Ship To
        Account accShipTo = RV_TestDataFactory.createShipToCustomer(acc, 'ADAM OMMERT MINERALOELHANDEL', true, true, 'abc2@test.com', false, '22222222');
        insert accShipTo;
        /*List<Location__c> locList = new List<Location__c>();
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
insert locList;*/

        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
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
        //insert matUlgE5;
        matList.add(matUlgE5);

        Product_Catalogue__c matUlg98 = new Product_Catalogue__c();
        matUlg98.Name = '400001698';
        matUlg98.Level_0__c = 'Gasoline';
        matUlg98.Commodity_Grade_L2__c = 'ULG98';
        matUlg98.Material_Name__c = 'TP ULG 98 Udy Umk Low Dose DE';
        matUlg98.Additive_cost_EUR_100l__c=0.3;
        matUlg98.Dyeing_cost_EUR_100l__c=0.4;
        matUlg98.WASA_EUR_100l__c=0.2;
        //insert matUlgE5;
        matList.add(matUlg98);

        Product_Catalogue__c matUlg95E10 = new Product_Catalogue__c();
        matUlg95E10.Name = '400001610';
        matUlg95E10.Level_0__c = 'Gasoline';
        matUlg95E10.Commodity_Grade_L2__c = 'ULG95 E10';
        matUlg95E10.Material_Name__c = 'TP ULG95 E10 Udy Umk Low Dose DE';
        matUlg95E10.Additive_cost_EUR_100l__c=0.3;
        matUlg95E10.Dyeing_cost_EUR_100l__c=0.4;
        matUlg95E10.WASA_EUR_100l__c=0.2;
        //insert matUlgE5;
        matList.add(matUlg95E10);
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
        mrAgo.Plant__c=insertLoc.Id;
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
        mrDmyAgo.Sold_To__c=acc.Id;
        mrDmyAgo.Ship_To__c=accShipTo.Id;
        mrDmyAgo.Plant__c=insertLoc.Id;
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
        mrIgo.Ship_To__c=accShipTo.Id;
        mrIgo.Plant__c=insertLoc.Id;
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
        mrUlg.Plant__c=insertLoc.Id;
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


        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	//OLFCustomerCreditChk_01Aug2019_Soumyajit
        accInsert.Ship_to_Number__c='0022222222';
        insert accInsert;



        /*Product_Catalogue__c matUlgE5 = new Product_Catalogue__c();
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
insert matUlgE5;*/
        List<MRC__c> insertMRCLst = new List<MRC__c>();
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, matUlgE5);
        //insertMRCLst.add(insertMRC);

        MRC__c insertMRC1 = new MRC__c();
        insertMRC1 = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, matUlg98);
        //insertMRCLst.add(insertMRC1);

        MRC__c insertMRC2 = new MRC__c();
        insertMRC2 = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, matUlg95E10);
        insertMRCLst.add(insertMRC2);
        insert insertMRC;

        MRC__c insertmrcRecord = new MRC__c();
        insertmrcRecord.Name = '320076590-101004';
        insertmrcRecord.Valid_To_Date__c  = system.today().addDays(6);
        insertmrcRecord.Valid_From_Date__c  = system.today().addDays(5);
        insertmrcRecord.Sold_To__c = accInsert.Id;
        insertmrcRecord.Plant__c = insertLoc.Id;
        insertmrcRecord.Product__c = matUlg95E10.Id;
        insertmrcRecord.Sales_Organization__c = 'DE01';
        insertmrcRecord.Ship_to_Number__c = '0022222222';
        insertmrcRecord.Ship_to_Name__c = 'WINKLER GMBH & CO KG';
        insertmrcRecord.Ship_to_Street__c = 'ROBERT-BOSCH-STR. 6';
        insertmrcRecord.Ship_to_City__c  = 'VIERNHEIM';
        insertmrcRecord.Ship_to_State__c  = '6';
        insertmrcRecord.Plant_Description__c = 'DE1002 Ludwigshafen depot';
        insertmrcRecord.Handling_Type__c = 'CA';
        insertmrcRecord.PO_Type__c='TSFP';
        insertmrcRecord.Contract__c='320076590';
        insertmrcRecord.Mode_Of_Transport__c=10;
        insertmrcRecord.Shipping_Condition__c=10;
        insert insertmrcRecord;



        MRC__c tmrc = [Select Id, Name,Contract__c,Material_Description__c,Mode_Of_Transport__c,PO_Type__c,Sales_Organization__c,Plant__c,Ship_to_Number__c from MRC__c where  Id =: insertmrcRecord.id];
        RV_Trigger_Master_Data__c tmd = new RV_Trigger_Master_Data__c();
        tmd.Trigger_Month__c = 'Sep';
        tmd.Trigger_Year__c = '2022';
        tmd.Ship_To_Number__c = '0022222222';
        tmd.Sold_to_Name__c = accInsert.Id;
        tmd.Sold_to_Number__c = accInsert.Sold_To_Number__c;
        tmd.MRC_Number__c = tmrc.Id;
        tmd.Max_number_of_triggers_per_month__c = 12;
        tmd.Max_Trigger_Volume__c = 500;
        tmd.Min_Trigger_Volume__c = 20;
        tmd.Monthly_volume__c = 300;
        insert tmd;

        RV_Trigger_Master_Data__c triggerMaster = [Select Id,MRC_Number__r.Ship_to_Number__c,MRC_Number__r.PO_Type__c,
                                                   MRC_Number__r.Contract__c,MRC_Number__r.Material_Description__c,
                                                   MRC_Number__r.Mode_Of_Transport__c,MRC_Number__r.Sales_Organization__c
                                                   from RV_Trigger_Master_Data__c where  Id =: tmd.id];

        system.assertEquals(tmrc.Ship_to_Number__c, triggerMaster.MRC_Number__r.Ship_to_Number__c);
        system.assertEquals(tmrc.PO_Type__c, triggerMaster.MRC_Number__r.PO_Type__c );
        system.assertEquals(tmrc.Contract__c, triggerMaster.MRC_Number__r.Contract__c );
        system.assertEquals('ULG95 E10', triggerMaster.MRC_Number__r.Material_Description__c);
        system.assertEquals(10, triggerMaster.MRC_Number__r.Mode_Of_Transport__c );
        system.assertEquals('DE01', triggerMaster.MRC_Number__r.Sales_Organization__c );

        SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c  = true;
        shtInsert.Trigger_Master_Data__c = tmd.Id;
        insert shtInsert;

        system.debug('tmd::'+tmd.MRC_Number__c+'-1-'+tmd.Sold_to_Name__c+'-2-'+tmd.MRC_Number__r.Contract__c);
        system.debug('tmd1::'+tmd.MRC_Number__r.Material_Description__c+'-1-'+tmd.MRC_Number__r.Mode_Of_Transport__c+'-2-'+tmd.MRC_Number__r.PO_Type__c);
        system.debug('tmd2::'+tmd.MRC_Number__r.Plant__c+'-1-'+tmd.MRC_Number__r.Sales_Organization__c+'-2-'+tmd.Trigger_Month__c+'-3-'+tmd.Trigger_Year__c);
        //RV_Trigger_Master_Data__c where Sold_to_Name__c =:soldToAccId AND MRC_Number__r.Contract__c IN: mrcNumbersList AND MRC_Number__r.Material_Description__c in:finalProductName AND MRC_Number__r.Mode_Of_Transport__c in:motIntegerLst
        //AND MRC_Number__r.PO_Type__c =: poType AND MRC_Number__r.Plant__c IN: plantId AND MRC_Number__r.Sales_Organization__c in:salesOrgLst AND Trigger_Month__c IN :monthset AND Trigger_Year__c =: startYear
        List<String> salesOrg = new List<String>();
        salesOrg.add('DE01');
        //salesOrg.add('AT01');
        test.startTest();
        List<RV_TermTriggerClass.termTriggerWrapperData> ttwraperLst = new List<RV_TermTriggerClass.termTriggerWrapperData>();
        RV_TermTriggerClass.termTriggerWrapperData ttwraper = new RV_TermTriggerClass.termTriggerWrapperData();
        ttwraper.TriggerVolume1 = 30;
        ttwraper.TriggersLeft = 2;
        ttwraper.TriggerComment1 = 'Test';
        ttwraper.Max_number_of_triggers_per_month = 12;
        ttwraper.Max_Trigger_Volume = 500;
        ttwraper.Min_Trigger_Volume = 20;
        ttwraper.Monthly_volume = 300;
        ttwraper.MRC_Number = insertMRC.Id;
        ttwraper.shipToNumber = accInsert.Ship_to_Number__c;
        ttwraper.Sold_to_Name = accInsert.Id;
        ttwraper.MRC_Number_Contract =insertMRC.Contract__c;
        String smrc = insertMRC.Name;
        List<String> lstsmrc = smrc.split('-');
        ttwraper.MRC_Number_Id =lstsmrc[0];
        ttwraper.MRC_Number_Material_Description = 'ULG95 E10';
        ttwraper.MRC_Number_Mode_Of_Transport = 10;
        ttwraper.MRC_Number_Name = insertMRC.Name;
        ttwraper.MRC_Number_Plant = insertMRC.Plant__c;
        ttwraper.MRC_Number_Plant_Name = insertMRC.Plant_Name__c;
        ttwraper.MRC_Number_Plant_Plant_Code = 'D004';//insertMRC.Plant__r.Plant_Code__c;
        ttwraper.MRC_Number_PO_Type = 'TTTT';
        ttwraper.MRC_Number_Product = insertMRC.Product__c;
        ttwraper.MRC_Number_Product_Name = insertMRC.Product__r.Name;
        ttwraper.MRC_Number_Ship_to_Number = insertMRC.Ship_to_Number__c;
        ttwraper.Remaining_trigger_volume = 10;
        ttwraper.Remaining_triggers = 2;
        ttwraper.salesOrg = 'DE01';
        ttwraper.shipToNumber = insertMRC.Ship_to_Number__c;
        ttwraper.Trigger_Month = 'Aug';
        ttwraper.Trigger_Year = '2022';
        ttwraper.TriggerComment1 = 'testing';
        ttwraper.TriggersLeft = 3;
        ttwraper.TriggerVolume1= 90;
        ttwraper.Id = tmd.Id;
        ttwraper.Sold_to_Number = accInsert.Sold_To_Number__c;
        ttwraper.isGsapDealCreateOn = true;
        ttwraper.retroAtpVoltoBeReduced = true;
        ttwraper.retroVolToBeHedged = true;
        ttwraper.retroGsapDealCreateOn = true;
        ttwraper.retroGsapDealCancelOn = true;
        system.debug('####'+ttwraper.Sold_to_Name+ttwraper.shipToNumber+ttwraper.MRC_Number_Plant_Plant_Code+'ULG95 E5');
        ttwraperLst.add(ttwraper);

        String triggerDataString = JSON.serialize(ttwraperLst);



        RV_TermTriggerClass.getPickListValuesMonth('RV_Trigger_Master_Data__c','Trigger_Month__c');
        RV_TermTriggerClass.fetchTermTriggerDeal1(acc.Id,new List<String>{lstsmrc[0]},new List<String>{accShipTo.Ship_to_Number__c},new List<String>{'10'},
                                                  'taxed',new List<String>{'AGO','IGO','Mogas'} , 'TTTT', new List<String>{insertMRC.Plant__c},
                                                  salesOrg,String.valueOf(system.today().addDays(6)),String.valueOf(system.today().addDays(7)),false);
        RV_TermTriggerClass.fetchTermTriggerDeal1(acc.Id,new List<String>{lstsmrc[0]},new List<String>{accShipTo.Ship_to_Number__c},new List<String>{'10'},
                                                  'taxed',new List<String>{'AGO','IGO','Mogas'} , 'TTTT', new List<String>{insertMRC.Plant__c},
                                                  salesOrg,String.valueOf(system.today().addDays(5)),String.valueOf(system.today().addDays(6)),true);
        RV_TermTriggerClass.fetchTermTriggerDeal1(accInsert.Id,new List<String>{lstsmrc[0]},new List<String>{tmd.Ship_to_Number__c},new List<String>{'10'},
                                                  'taxed',new List<String>{'AGO','IGO','Mogas'} , 'TSFP', new List<String>{insertMRC.Plant__c},
                                                  salesOrg,String.valueOf(system.today().addDays(5)),String.valueOf(system.today().addDays(6)),true);
        /* prod deployment */
        RV_TermTriggerClass.saveTermTriggerDeal1(triggerDataString,String.valueOf(system.today().addDays(-10)),String.valueOf(system.today().addDays(-9)),false,'ATP1');
        RV_TermTriggerClass.confirmTermTriggerDeal(new List<SHT__c>{shtInsert});
        RV_TermTriggerClass.deleteTermTriggerDeal(shtInsert.Id);
        RV_TermTriggerClass.getUserList();
        RV_TermTriggerClass.getMonth('01');
        RV_TermTriggerClass.getMonth('02');
        RV_TermTriggerClass.getMonth('03');
        RV_TermTriggerClass.getMonth('06');
        RV_TermTriggerClass.getMonth('07');
        RV_TermTriggerClass.getMonth('08');
        RV_TermTriggerClass.getMonth('09');
        RV_TermTriggerClass.getMonth('10');
        RV_TermTriggerClass.getMonth('11');
        RV_TermTriggerClass.getMonth('12');
        test.stopTest();
    }
    @isTest public static void testSaveTermTriggerDealScenario1(){
        test.startTest();

        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;
        accInsert.Ship_to_Number__c='0022222222';
        insert accInsert;

        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;

        List<Product_Catalogue__c> matList = new List<Product_Catalogue__c>();
        Product_Catalogue__c matUlg95E10 = new Product_Catalogue__c();
        matUlg95E10.Name = '400001610';
        matUlg95E10.Level_0__c = 'Gasoline';
        matUlg95E10.Commodity_Grade_L2__c = 'ULG95 E10';
        matUlg95E10.Material_Name__c = 'TP ULG95 E10 Udy Umk Low Dose DE';
        matUlg95E10.Additive_cost_EUR_100l__c=0.3;
        matUlg95E10.Dyeing_cost_EUR_100l__c=0.4;
        matUlg95E10.WASA_EUR_100l__c=0.2;
        matList.add(matUlg95E10);

        Product_Catalogue__c matUlgE5 = new Product_Catalogue__c();
        matUlgE5.Name = '400001637';
        matUlgE5.Level_0__c = 'Gasoline';
        matUlgE5.Commodity_Grade_L2__c = 'ULG95 E5';
        matUlgE5.Material_Name__c = 'TP ULG 95 10ppmS E5 Udy Umk Low Dose DE';
        matUlgE5.Additive_cost_EUR_100l__c=0.3;
        matUlgE5.Dyeing_cost_EUR_100l__c=0.4;
        matUlgE5.WASA_EUR_100l__c=0.2;
        matList.add(matUlgE5);

        Product_Catalogue__c matULG98 = new Product_Catalogue__c();
        matULG98.Name = '400001637';
        matULG98.Level_0__c = 'Gasoline';
        matULG98.Commodity_Grade_L2__c = 'ULG98';
        matULG98.Material_Name__c = 'TP ULG 95 10ppmS E5 Udy Umk Low Dose DE';
        matULG98.Additive_cost_EUR_100l__c=0.3;
        matULG98.Dyeing_cost_EUR_100l__c=0.4;
        matULG98.WASA_EUR_100l__c=0.2;
        matList.add(matULG98);

        insert matList;

        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, matUlgE5);
        insert insertMRC;

        MRC__c insertMRC1 = new MRC__c();
        insertMRC1.Name = '320076590-101004';
        insertMRC1.Valid_To_Date__c  = system.today().addDays(6);
        insertMRC1.Valid_From_Date__c  = system.today().addDays(5);
        insertMRC1.Sold_To__c = accInsert.Id;
        insertMRC1.Plant__c = insertLoc.Id;
        insertMRC1.Product__c = matULG98.Id;
        insertMRC1.Sales_Organization__c = 'DE01';
        insertMRC1.Ship_to_Number__c = '0022222222';
        insertMRC1.Ship_to_Name__c = 'WINKLER GMBH & CO KG';
        insertMRC1.Ship_to_Street__c = 'ROBERT-BOSCH-STR. 6';
        insertMRC1.Ship_to_City__c  = 'VIERNHEIM';
        insertMRC1.Ship_to_State__c  = '6';
        insertMRC1.Plant_Description__c = 'DE1002 Ludwigshafen depot';
        insertMRC1.Handling_Type__c = 'CA';
        insertMRC1.PO_Type__c='TSFP';
        insertMRC1.Contract__c='320076590';
        insertMRC1.Mode_Of_Transport__c=10;
        insertMRC1.Shipping_Condition__c=10;
        insert insertMRC1;

        MRC__c insertmrcRecord = new MRC__c();
        insertmrcRecord.Name = '320076590-101004';
        insertmrcRecord.Valid_To_Date__c  = system.today().addDays(6);
        insertmrcRecord.Valid_From_Date__c  = system.today().addDays(5);
        insertmrcRecord.Sold_To__c = accInsert.Id;
        insertmrcRecord.Plant__c = insertLoc.Id;
        insertmrcRecord.Product__c = matUlg95E10.Id;
        insertmrcRecord.Sales_Organization__c = 'DE01';
        insertmrcRecord.Ship_to_Number__c = '0022222222';
        insertmrcRecord.Ship_to_Name__c = 'WINKLER GMBH & CO KG';
        insertmrcRecord.Ship_to_Street__c = 'ROBERT-BOSCH-STR. 6';
        insertmrcRecord.Ship_to_City__c  = 'VIERNHEIM';
        insertmrcRecord.Ship_to_State__c  = '6';
        insertmrcRecord.Plant_Description__c = 'DE1002 Ludwigshafen depot';
        insertmrcRecord.Handling_Type__c = 'CA';
        insertmrcRecord.PO_Type__c='TSFP';
        insertmrcRecord.Contract__c='320076590';
        insertmrcRecord.Mode_Of_Transport__c=10;
        insertmrcRecord.Shipping_Condition__c=10;
        insert insertmrcRecord;



        MRC__c tmrc = [Select Id, Name,Contract__c,Material_Description__c,Mode_Of_Transport__c,PO_Type__c,Sales_Organization__c,Plant__c,Ship_to_Number__c from MRC__c where  Id =: insertmrcRecord.id];
        RV_Trigger_Master_Data__c tmd = new RV_Trigger_Master_Data__c();
        tmd.Trigger_Month__c = 'Sep';
        tmd.Trigger_Year__c = '2022';
        tmd.Ship_To_Number__c = '0022222222';
        tmd.Sold_to_Name__c = accInsert.Id;
        tmd.Sold_to_Number__c = accInsert.Sold_To_Number__c;
        tmd.MRC_Number__c = tmrc.Id;
        tmd.Max_number_of_triggers_per_month__c = 12;
        tmd.Max_Trigger_Volume__c = 500;
        tmd.Min_Trigger_Volume__c = 20;
        tmd.Monthly_volume__c = 300;
        insert tmd;

        List<RV_TermTriggerClass.termTriggerWrapperData> ttwraperLst = new List<RV_TermTriggerClass.termTriggerWrapperData>();
        RV_TermTriggerClass.termTriggerWrapperData ttwraper = new RV_TermTriggerClass.termTriggerWrapperData();
        ttwraper.TriggerVolume1 = 30;
        ttwraper.TriggersLeft = 2;
        ttwraper.TriggerComment1 = 'Test';
        ttwraper.Max_number_of_triggers_per_month = 12;
        ttwraper.Max_Trigger_Volume = 500;
        ttwraper.Min_Trigger_Volume = 20;
        ttwraper.Monthly_volume = 300;
        ttwraper.MRC_Number = insertMRC.Id;
        ttwraper.shipToNumber = accInsert.Ship_to_Number__c;
        ttwraper.Sold_to_Name = accInsert.Id;
        ttwraper.MRC_Number_Contract =insertMRC.Contract__c;
        String smrc = insertMRC.Name;
        List<String> lstsmrc = smrc.split('-');
        ttwraper.MRC_Number_Id =lstsmrc[0];
        ttwraper.MRC_Number_Material_Description = 'ULG95 E10';
        ttwraper.MRC_Number_Mode_Of_Transport = 10;
        ttwraper.MRC_Number_Name = tmrc.Name;
        ttwraper.MRC_Number_Plant = insertMRC.Plant__c;
        ttwraper.MRC_Number_Plant_Name = insertMRC.Plant_Name__c;
        ttwraper.MRC_Number_Plant_Plant_Code = 'D004';//insertMRC.Plant__r.Plant_Code__c;
        ttwraper.MRC_Number_PO_Type = 'TTTT';
        ttwraper.MRC_Number_Product = insertMRC.Product__c;
        ttwraper.MRC_Number_Product_Name = insertMRC.Product__r.Name;
        ttwraper.MRC_Number_Ship_to_Number = insertMRC.Ship_to_Number__c;
        ttwraper.Remaining_trigger_volume = 10;
        ttwraper.Remaining_triggers = 2;
        ttwraper.salesOrg = 'DE01';
        ttwraper.shipToNumber = insertMRC.Ship_to_Number__c;
        ttwraper.Trigger_Month = 'Aug';
        ttwraper.Trigger_Year = '2022';
        ttwraper.TriggerComment1 = 'testing';
        ttwraper.TriggersLeft = 3;
        ttwraper.TriggerVolume1 = 90;
        ttwraper.Id = tmd.Id;
        ttwraper.Sold_to_Number = accInsert.Sold_To_Number__c;
        ttwraper.isGsapDealCreateOn = true;
        ttwraper.isGsapDealCancelOn = false;
        ttwraper.retroAtpVoltoBeReduced = true;
        ttwraper.retroVolToBeHedged = true;
        ttwraper.retroGsapDealCreateOn = true;
        ttwraper.retroGsapDealCancelOn = true;
        ttwraper.atpVoltoBeReduced = true;
        ttwraper.isVolToBeHedged = true;
        ttwraper.isZeroPriceDeal = false;
        ttwraperLst.add(ttwraper);

        String triggerDataString = JSON.serialize(ttwraperLst);
        RV_TermTriggerClass.saveTermTriggerDeal1(triggerDataString,String.valueOf(system.today().addDays(-10)),String.valueOf(system.today().addDays(-9)),true,'ATP1');
        test.stopTest();

    }

     @isTest public static void testSaveTermTriggerDealScenario2(){
        test.startTest();

        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;
        accInsert.Ship_to_Number__c='0022222222';
        insert accInsert;

        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;

        List<Product_Catalogue__c> matList = new List<Product_Catalogue__c>();
        Product_Catalogue__c matUlg95E10 = new Product_Catalogue__c();
        matUlg95E10.Name = '400001610';
        matUlg95E10.Level_0__c = 'Gasoline';
        matUlg95E10.Commodity_Grade_L2__c = 'ULG95 E10';
        matUlg95E10.Material_Name__c = 'TP ULG95 E10 Udy Umk Low Dose DE';
        matUlg95E10.Additive_cost_EUR_100l__c=0.3;
        matUlg95E10.Dyeing_cost_EUR_100l__c=0.4;
        matUlg95E10.WASA_EUR_100l__c=0.2;
        matList.add(matUlg95E10);

        Product_Catalogue__c matUlgE5 = new Product_Catalogue__c();
        matUlgE5.Name = '400001637';
        matUlgE5.Level_0__c = 'Gasoline';
        matUlgE5.Commodity_Grade_L2__c = 'ULG95 E5';
        matUlgE5.Material_Name__c = 'TP ULG 95 10ppmS E5 Udy Umk Low Dose DE';
        matUlgE5.Additive_cost_EUR_100l__c=0.3;
        matUlgE5.Dyeing_cost_EUR_100l__c=0.4;
        matUlgE5.WASA_EUR_100l__c=0.2;
        matList.add(matUlgE5);

        Product_Catalogue__c matULG98 = new Product_Catalogue__c();
        matULG98.Name = '400001637';
        matULG98.Level_0__c = 'Gasoline';
        matULG98.Commodity_Grade_L2__c = 'ULG98';
        matULG98.Material_Name__c = 'TP ULG 95 10ppmS E5 Udy Umk Low Dose DE';
        matULG98.Additive_cost_EUR_100l__c=0.3;
        matULG98.Dyeing_cost_EUR_100l__c=0.4;
        matULG98.WASA_EUR_100l__c=0.2;
        matList.add(matULG98);

        insert matList;

        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, matULG98);
        insert insertMRC;



        MRC__c insertmrcRecord = new MRC__c();
        insertmrcRecord.Name = '320076590-101004';
        insertmrcRecord.Valid_To_Date__c  = system.today().addDays(6);
        insertmrcRecord.Valid_From_Date__c  = system.today().addDays(5);
        insertmrcRecord.Sold_To__c = accInsert.Id;
        insertmrcRecord.Plant__c = insertLoc.Id;
        insertmrcRecord.Product__c = matUlg95E10.Id;
        insertmrcRecord.Sales_Organization__c = 'DE01';
        insertmrcRecord.Ship_to_Number__c = '0022222222';
        insertmrcRecord.Ship_to_Name__c = 'WINKLER GMBH & CO KG';
        insertmrcRecord.Ship_to_Street__c = 'ROBERT-BOSCH-STR. 6';
        insertmrcRecord.Ship_to_City__c  = 'VIERNHEIM';
        insertmrcRecord.Ship_to_State__c  = '6';
        insertmrcRecord.Plant_Description__c = 'DE1002 Ludwigshafen depot';
        insertmrcRecord.Handling_Type__c = 'CA';
        insertmrcRecord.PO_Type__c='TSFP';
        insertmrcRecord.Contract__c='320076590';
        insertmrcRecord.Mode_Of_Transport__c=10;
        insertmrcRecord.Shipping_Condition__c=10;
        insert insertmrcRecord;



        MRC__c tmrc = [Select Id, Name,Contract__c,Material_Description__c,Mode_Of_Transport__c,PO_Type__c,Sales_Organization__c,Plant__c,Ship_to_Number__c from MRC__c where  Id =: insertmrcRecord.id];
        RV_Trigger_Master_Data__c tmd = new RV_Trigger_Master_Data__c();
        tmd.Trigger_Month__c = 'Sep';
        tmd.Trigger_Year__c = '2022';
        tmd.Ship_To_Number__c = '0022222222';
        tmd.Sold_to_Name__c = accInsert.Id;
        tmd.Sold_to_Number__c = accInsert.Sold_To_Number__c;
        tmd.MRC_Number__c = tmrc.Id;
        tmd.Max_number_of_triggers_per_month__c = 12;
        tmd.Max_Trigger_Volume__c = 500;
        tmd.Min_Trigger_Volume__c = 20;
        tmd.Monthly_volume__c = 300;
        insert tmd;

        List<RV_TermTriggerClass.termTriggerWrapperData> ttwraperLst = new List<RV_TermTriggerClass.termTriggerWrapperData>();
        RV_TermTriggerClass.termTriggerWrapperData ttwraper = new RV_TermTriggerClass.termTriggerWrapperData();
        ttwraper.TriggerVolume1 = 30;
        ttwraper.TriggersLeft = 2;
        ttwraper.TriggerComment1 = 'Test';
        ttwraper.Max_number_of_triggers_per_month = 12;
        ttwraper.Max_Trigger_Volume = 500;
        ttwraper.Min_Trigger_Volume = 20;
        ttwraper.Monthly_volume = 300;
        ttwraper.MRC_Number = insertMRC.Id;
        ttwraper.shipToNumber = accInsert.Ship_to_Number__c;
        ttwraper.Sold_to_Name = accInsert.Id;
        ttwraper.MRC_Number_Contract =insertMRC.Contract__c;
        String smrc = insertMRC.Name;
        List<String> lstsmrc = smrc.split('-');
        ttwraper.MRC_Number_Id =lstsmrc[0];
        ttwraper.MRC_Number_Material_Description = 'ULG95 E10';
        ttwraper.MRC_Number_Mode_Of_Transport = 10;
        ttwraper.MRC_Number_Name = tmrc.Name;
        ttwraper.MRC_Number_Plant = insertMRC.Plant__c;
        ttwraper.MRC_Number_Plant_Name = insertMRC.Plant_Name__c;
        ttwraper.MRC_Number_Plant_Plant_Code = 'D004';//insertMRC.Plant__r.Plant_Code__c;
        ttwraper.MRC_Number_PO_Type = 'TTTT';
        ttwraper.MRC_Number_Product = insertMRC.Product__c;
        ttwraper.MRC_Number_Product_Name = insertMRC.Product__r.Name;
        ttwraper.MRC_Number_Ship_to_Number = insertMRC.Ship_to_Number__c;
        ttwraper.Remaining_trigger_volume = 10;
        ttwraper.Remaining_triggers = 2;
        ttwraper.salesOrg = 'DE01';
        ttwraper.shipToNumber = insertMRC.Ship_to_Number__c;
        ttwraper.Trigger_Month = 'Aug';
        ttwraper.Trigger_Year = '2022';
        ttwraper.TriggerComment1 = 'testing';
        ttwraper.TriggersLeft = 3;
        ttwraper.TriggerVolume1 = 90;
        ttwraper.Id = tmd.Id;
        ttwraper.Sold_to_Number = accInsert.Sold_To_Number__c;
        ttwraper.isGsapDealCreateOn = true;
        ttwraper.isGsapDealCancelOn = false;
        ttwraper.retroAtpVoltoBeReduced = true;
        ttwraper.retroVolToBeHedged = true;
        ttwraper.retroGsapDealCreateOn = true;
        ttwraper.retroGsapDealCancelOn = true;
        ttwraper.atpVoltoBeReduced = true;
        ttwraper.isVolToBeHedged = true;
        ttwraper.isZeroPriceDeal = false;
        ttwraper.BSP = 0;
        ttwraper.MSP = 0;
        ttwraperLst.add(ttwraper);

        String triggerDataString = JSON.serialize(ttwraperLst);
        RV_TermTriggerClass.saveTermTriggerDeal1(triggerDataString,String.valueOf(system.today().addDays(-10)),String.valueOf(system.today().addDays(-9)),true,'ATP1');
        test.stopTest();

    }
}