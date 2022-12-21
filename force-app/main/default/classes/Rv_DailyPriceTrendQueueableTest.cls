@isTest
public class Rv_DailyPriceTrendQueueableTest{
    //AdditionalTestCoverage_12Jun2019_Soumyajit starts
    /*
    static testMethod void testMethod1(){
        Test.startTest();
        
        RV_SPCalculationControllerTest.pricecalculator();         
        //reuters Quote
      
        Test.stopTest();     
        
       
    }
    static testMethod void test1(){
          RV_ReutersQuoteTriggerTest.createReutersData();
    }
    
    static testMethod void test2(){
        
         Rv_DailyPriceTrendQueueable Obj = new Rv_DailyPriceTrendQueueable();
        Test.StartTest();
        System.enqueueJob(new Rv_DailyPriceTrendQueueable());
        Test.stopTest();
    }*/
    //AdditionalTestCoverage_12Jun2019_Soumyajit ends
    //Test method for Scheduler
    @isTest 
    static void testMethodforATPScheduler() {
        Test.StartTest();
        Rv_DailyPriceTrendScheduler priceTrndScheduler = new Rv_DailyPriceTrendScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('PriceTrend Scheduler', sch, priceTrndScheduler); 
        Test.stopTest();
    
    }
    //AdditionalTestCoverage_12Jun2019_Soumyajit starts
    @testSetup 
    static void setupData() 
    {
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
        insert locSrc;
        
       //Insert Account
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        Account accDmy = new Account();
        accDmy.RecordTypeId = RecordTypeIdAccount;
        accDmy.Name = 'Shell Revolution Special Co. (Dummy)';
        accDmy.Customer_Type__c = 'Sold To';
        accDmy.Has_MRC__c = true;
        accDmy.IWO_Member__c=true;
        insert accDmy;
        
        //Insert Account
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
        Id RecordTypeIdMrc = Schema.SObjectType.Mrc__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
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
        
        //Dummy Mrc MRCXXA002-000001
         Mrc__c mrDmyAgo= new Mrc__c();
        mrDmyAgo.Name='MRCXXA002-000001';
        mrDmyAgo.RecordTypeId=RecordTypeIdMrc;
        mrDmyAgo.Sold_To__c=accDmy.Id;
        mrDmyAgo.Plant__c=loc.Id;
        mrDmyAgo.Sales_Organization__c='DE01';
        mrDmyAgo.Handling_Type__c='EB';
        mrDmyAgo.PO_Type__c='TSFP';
        mrDmyAgo.Product__c=matAgo.Id;
  		mrDmyAgo.Shipping_Condition__c=10;
        mrDmyAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrDmyAgo.Valid_From_Date__c=system.today().addDays(-100);
        insert mrDmyAgo;
        
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
       
        //Freight Rate
        Freight_Rate__c routeAgo= new Freight_Rate__c(); 
        routeAgo=RV_TestHelperPhase2.insertFreightRate(routeAgo, locSrc, loc);
        routeAgo.Route_Utilization__c=100;
        routeAgo.Bio_Split__c=false;
        routeAgo.Third_Party__c=false;
        insert routeAgo;
        
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
        insert routeIgo;
        
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
        insert routeUlg;
        
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
        insert routeUlg3rd;

        //Hydrocarbon Formulas
        Third_Party_Contract_Master__c hydroThrdAgo= new Third_Party_Contract_Master__c();
        hydroThrdAgo=RV_TestHelperPhase2.hydrocarbonValuesAGOIGO(loc,hydroThrdAgo,false);
        insert hydroThrdAgo;
        system.debug('gradelocation==>'+hydroThrdAgo.GradeLocation__c);
        
        Third_Party_Contract_Master__c hydroThrdIgo= new Third_Party_Contract_Master__c();
        hydroThrdIgo=RV_TestHelperPhase2.hydrocarbonValuesIGO50ppm(loc,hydroThrdIgo,loc.Alt_Type__c);
        insert hydroThrdIgo;
        system.debug('gradelocation==>'+hydroThrdIgo.GradeLocation__c);
        
        Third_Party_Contract_Master__c hydroThrdUlg= new Third_Party_Contract_Master__c();
        hydroThrdUlg=RV_TestHelperPhase2.hydrocarbonValuesMOGAS(loc,hydroThrdUlg,true);
        insert hydroThrdUlg;
        system.debug('gradelocation==>'+hydroThrdUlg.GradeLocation__c);
        
        Third_Party_Contract_Master__c hydroThrdUlg3rd= new Third_Party_Contract_Master__c();
        hydroThrdUlg3rd=RV_TestHelperPhase2.hydrocarbonValuesMOGAS(loc,hydroThrdUlg3rd,true);
       // hydroThrdUlg3rd.Supply_Route_ID__c='MOGAS-E5_Shell_ARA_Barge_Ludwigshafen';
        insert hydroThrdUlg3rd;
        
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
        
        insert objEXLive1GLETCurr;
        insert objEXLive1GLETCurrEU;
        insert objGELT;
        
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
        prdctDiffeurope.Display_Name__c = '�/$ fixing';
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
        
        BSP_Trends__c bsp = new BSP_Trends__c();
        bsp.Mrc_No__c = label.Rv_Wesseling_AGO_MRC;
        bsp.Calcualated_MSP__c = 100;
        insert bsp;
        
        bsp = new BSP_Trends__c();
        bsp.Mrc_No__c = label.Rv_Wesseling_MOGAS_MRC;
        bsp.Calcualated_MSP__c = 100;
        insert bsp;

        /* added by Dharmendra for code coverage - Start */

        Location__c loc1 = new Location__c();
        RV_TestHelper.insertLocation(loc1);
        //insert loc1;

        Product_Catalogue__c productCat = new Product_Catalogue__c();
        RV_TestHelper.insertProductCat(productCat);
        insert productCat;

        Account accLst= new Account();
        RV_TestHelper.insertAccount(accLst);
        insert accLst;

        MRC__c insertmrc = new MRC__c();
        RV_TestHelper.insertMRC(insertmrc,accDmy,loc,matIGO50);
        insert insertmrc;

        SHT__c insertSHTRec = new SHT__c();
        RV_TestHelper.insertSHT(insertSHTRec,loc,accDmy,insertmrc);
        insert insertSHTRec;
        
        Freight_Rate__c routeIgo1= new Freight_Rate__c();
        routeIgo=RV_TestHelperPhase2.insertFreightRate(routeIgo1, locSrc, loc);
        routeIgo1.Route_Utilization__c=100;
        routeIgo1.Standard_Grade__c='AGO B7';
        routeIgo1.SubGrade_3P__c='IGO 50ppm';
        routeIgo1.Bio_Split__c=true;
        routeIgo1.Third_Party__c=false;
        routeIgo1.Source__c=locSrc.Id;
        routeIgo1.Destination__c=loc.Id;
        routeIgo1.Mode_Of_Transport__c='Barge';
        routeIgo1.Supplier__c='Shell';
        routeIgo1.Valid_From__c = System.today();
        routeIgo1.Valid_To__c = System.today().addDays(14);
        
        insert routeIgo1;
        
        List<RV_SPCalculationController.priceAuditWrap> priceAdtWrpLst = new List<RV_SPCalculationController.priceAuditWrap>();
        RV_SPCalculationController.priceAuditWrap paw = new RV_SPCalculationController.priceAuditWrap();

        paw.mrcNo =insertmrc.Name;
        paw.shtId=insertSHTRec.id;
        paw.salesOrg='';
        paw.materialId=productCat.id;
        paw.shippingCond = 1;
        paw.landedCostEuroMt =0;
        paw.depotSteer =0;
        paw.finalAMVEuroMt=0;
        paw.finalAMVEuro100L=0;
        paw.applyThroughput='';
        paw.throughputCost=0;
        paw.energyFees=0;
        paw.cso=0;
        paw.iwoMember=false;
        paw.unionFees=0;
        paw.calculatedBSP=0;
        paw.salesMargin=0;
        paw.minMargin=0;
        paw.calculatedMSP=0;
        paw.exchangeRate=0;

        List<RV_SPCalculationController.backboneAMVpriceCompWrap> prcBAMVLst = new List<RV_SPCalculationController.backboneAMVpriceCompWrap>();
        RV_SPCalculationController.backboneAMVpriceCompWrap baw = new RV_SPCalculationController.backboneAMVpriceCompWrap();

        baw.mrcNo=insertmrc.Name;
        baw.routeName='';
        baw.routeUtilizationPercent =0;
        baw.hcv=0;
        baw.coSteer=0;
        baw.freight=0;
        baw.freightPercentage=0;
        baw.freightQuoteValue=0;
        baw.freightToSource=0;
        baw.freightToDepot=0;
        baw.bioCost=0;
        baw.thirdParty=false;
        baw.bioSplit=false;
        baw.wasa=0;
        baw.additiveCost=0;
        baw.landedBAMVvalue=0;
        baw.finalBAMVvalue=0;
        baw.Depot=loc.id;

        prcBAMVLst.add(baw);

        paw.bavWrp = prcBAMVLst;

        priceAdtWrpLst.add(paw);

        Rv_PriceAuditController.insertPriceAuditWrap(priceAdtWrpLst);
        
       // Rv_PriceAuditController.insertPriceAuditWrap(priceAdtWrpLst);

        /* End */
    }
    
    @isTest
    static void doDailyPriceTrendTest()
    { 
        Rv_DailyPriceTrendQueueable Obj = new Rv_DailyPriceTrendQueueable();
        List<BSP_Trends__c> prcAdtBspTrndLst = [select id,Mrc_No__c,Calcualated_MSP__c from BSP_Trends__c];
        
        Test.StartTest();
        System.enqueueJob(new Rv_DailyPriceTrendQueueable());
        Rv_DailyPriceTrendQueueable.updateProductDifferentialAgoMogas8amValues(prcAdtBspTrndLst);
        Test.stopTest();
    }
    //AdditionalTestCoverage_12Jun2019_Soumyajit ends
}