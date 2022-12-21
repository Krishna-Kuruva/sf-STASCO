@isTest
public Class OLF_CreateDealTest{

    @testSetup
    static void testSetup(){
        Revolution_Setting__c revSett = new Revolution_Setting__c();
        revSett.Name = 'Lifting Window 1';
        revSett.Active__c = true;
        revSett.Start_Day__c = 0;
        revSett.End_Day__c = 14;
        revSett.Value__c = 'ATP1';
        insert revSett;
    }
   //test
    static testMethod void test1(){
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Credit_Available__c=10000000;
        accInsert.Rv_Available_for_OLF__c=true;
        accInsert.Rv_Credit_Utilized__c=10;
        accInsert.Customer_Type__c = 'Sold To';
        accInsert.RV_Available_Tranches__c ='ATP1;ATP2;ATP3;ATP4';
        insert accInsert;
        
        Account accInsert2 = new Account();
        Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Ship_To').getRecordTypeId();
        accInsert2 = RV_TestHelper.insertAccount(accInsert2);
        accInsert2.Rv_Available_for_OLF__c=true;
        accInsert2.Rv_Olf_Customer_Email__c='test@abc.com';
        accInsert2.Customer_Type__c = 'Ship To';
        accInsert2.recordTypeId = recTypeId;
        accInsert2.ParentId = accInsert.Id;
        insert accInsert2;
        
        Location__c loc=new Location__c();
        loc=RV_TestHelper.insertLocation(loc);
        insert loc;
        
        Product_Catalogue__c pc=new Product_Catalogue__c();
        pc=RV_TestHelper.insertProductCat(pc);
        pc.Online_Material_Name_Taxed__c='Diesel B7';
        pc.Online_Material_Name_UnTaxed__c='Diesel B7, unversteuert';
        pc.Commodity_Grade_L2__c='AGO B7';
        pc.Marketing_Cost__c = 0.014;	//Fix_394298_10Jan2020_Soumyajit
        insert pc;

        ATP__c atp1=new ATP__c();
        atp1=RV_TestHelper.insertATPRecord(atp1,loc);
        atp1.ATP1__c= 200000;
        atp1.Minimum_Daily_Split_Volume__c=100;
        atp1.Split_Volume__c=10;
        atp1.Minimum_Online_Volume__c=1000;
        atp1.Maximum_Online_Volume__c = 300000;
        atp1.Volume_Cap_Customer__c = 100000;	//TestCovearge_340363_Soumyajit_21Oct2019
        insert atp1;
        atp1 = RV_DAL.fetchAllATPRecord()[0];
        
        MRC__c  mrc=new MRC__C();
        mrc=RV_TestHelper.insertMRC(mrc,accInsert ,loc,pc);
        mrc.Sold_To__c=accInsert.Id;
        mrc.Ship_To__c=accInsert2.Id;
        mrc.Shipping_Condition__c=10;
        mrc.Rv_Available_for_OLF__c=true;
        insert mrc;
        
        MRC__c  mrc1=new MRC__C();
        mrc1=RV_TestHelper.insertMRC(mrc1,accInsert ,loc,pc);
        mrc1.Name='320076590-101003';
        mrc1.Sold_To__c=accInsert.Id;
        mrc1.Ship_To__c=accInsert2.Id;
        mrc1.Shipping_Condition__c=10;
        mrc1.Rv_Available_for_OLF__c=true;
        mrc1.PO_Type__c='TSFP';
        mrc1.Handling_Type__c='Others';
        insert mrc1;
       
        //AdditionalTestCoverage_12Jun2019_Soumyajit starts
        
        Location__c locSrc=new Location__c();
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
        
        Freight_Rate__c routeIgo= new Freight_Rate__c();
        routeIgo=RV_TestHelperPhase2.insertFreightRate(routeIgo, locSrc, loc);
        insert routeIgo;
        
        Third_Party_Contract_Master__c hydroThrdAgo= new Third_Party_Contract_Master__c();
        hydroThrdAgo=RV_TestHelperPhase2.hydrocarbonValuesAGOIGO(loc,hydroThrdAgo,false);
        insert hydroThrdAgo;
        
        Bio_AMVs__c bio= new Bio_AMVs__c();
        bio=RV_TestHelperPhase2.insertBioAmv(bio,loc);
        insert bio;  
        
        Throughput__c thputAgo= new Throughput__c();
        thputAgo=RV_TestHelperPhase2.insertThroughput(thputAgo,loc);
        insert thputAgo;
        
        Id RecordTypeIdMarginTruck = Schema.SObjectType.Margin__c.getRecordTypeInfosByName().get('Truck/ITT').getRecordTypeId();
        Margin__c mgn = new Margin__c();
		mgn=RV_TestHelperPhase2.insertMargin(mgn,loc,RecordTypeIdMarginTruck);
        mgn.Tranche__c = 'ATP1';
        insert mgn;
        
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
        
        //AdditionalTestCoverage_12Jun2019_Soumyajit ends
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
        
        List<RV_SPCalculationController.salesPriceWrap> swList=new List<RV_SPCalculationController.salesPriceWrap>();
        RV_SPCalculationController.salesPriceWrap sw=new RV_SPCalculationController.salesPriceWrap();
        sw.BSP=90;
        sw.OTM=110;
        sw.MSP=100;
        sw.landedCost=95;
        sw.mrcNo='320076590-101004';
        sw.totalTax=10;
        swList.add(sw);
                
        List<OLFWrapper.MrcPriceWrap> wrapList=new List<OLFWrapper.MrcPriceWrap>(); 
        //Success Condition
        OLFWrapper.MrcPriceWrap testWrap=new OLFWrapper.MrcPriceWrap();
        testWrap.MRCNumber=mrc.Name;
        testWrap.Location=loc.Name;
        testWrap.MaterialName=pc.Material_Name__c;
        testWrap.grade='AGO B7';
        testWrap.availableVolume=String.valueOf(atp1.ATP_Live__c);
        testWrap.PricePerUnit='100';
        testWrap.inputPricePerUnit='100';
        testWrap.inputVolume='100';
        testWrap.StartDate =String.ValueOf(System.Today());
        testWrap.EndDate =String.ValueOf(System.Today()+13);
        testWrap.customerName=accInsert2.Name;
        testWrap.contactEmail=accInsert2.Rv_Olf_Customer_Email__c;
        wrapList.add(testWrap);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/createDeal/';
        req.httpMethod = 'POST';
        req.addHeader('customerEmail', accInsert2.Rv_Olf_Customer_Email__c);
        req.addHeader('tranche', 'ATP1');
        req.requestBody = Blob.valueOf(JSON.serialize(wrapList));
        RestContext.request = req;
        RestContext.response= res;
        Set<String> mrcSet=new Set<String>();
        Set<String> mrcSet1=new Set<String>();
        Test.startTest();
        mrcSet.add(mrc.name);
        mrcSet.add(mrc1.name);
        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];
        
        OLF_Utility.global_overrideChecks = true;
        
        System.RunAs(u){
        OLF_CreateDeal.getMrcRecords(mrcSet);
        OLF_CreateDeal.insertOlfDealInSht(wrapList);
        OLF_CreateDeal.createOlfDeals();
        }
        
        //AdditionalTestCoverage_12Jun2019_Soumyajit starts
        
        List<OLFWrapper.MrcPriceWrap> wrapList2=new List<OLFWrapper.MrcPriceWrap>();
        
        OLFWrapper.MrcPriceWrap testWrap2=new OLFWrapper.MrcPriceWrap();
        testWrap2.MRCNumber=mrc1.Name;
        testWrap2.Location=loc.Name;
        testWrap2.MaterialName=pc.Material_Name__c;
        testWrap2.grade='AGO B7';
        testWrap2.availableVolume=String.valueOf(atp1.ATP_Live__c);
        testWrap2.PricePerUnit='100';
        testWrap2.inputPricePerUnit='100';
        testWrap2.inputVolume='1000000';
        testWrap2.StartDate =String.ValueOf(System.Today());
        testWrap2.EndDate =String.ValueOf(System.Today()+13);
        testWrap2.customerName=accInsert.Name;
        testWrap2.contactEmail=accInsert2.Rv_Olf_Customer_Email__c;
        wrapList2.add(testWrap2);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req2.requestURI = '/services/apexrest/createDeal/';
        req2.httpMethod = 'POST';
        req2.addHeader('customerEmail', accInsert2.Rv_Olf_Customer_Email__c);
        req2.addHeader('tranche', 'ATP1');
        req2.requestBody = Blob.valueOf(JSON.serialize(wrapList));
        RestContext.request = req2;
        RestContext.response= res2;

        System.RunAs(u){
        OLF_CreateDeal.insertOlfDealInSht(wrapList2);
        }
        
        //AdditionalTestCoverage_12Jun2019_Soumyajit ends
        
        Test.stopTest();
        
       
    }
    static testMethod void test2(){
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Credit_Available__c=10000000;
        accInsert.Rv_Available_for_OLF__c=true;
        accInsert.Rv_Credit_Utilized__c=10;
        accInsert.RV_Available_Tranches__c ='ATP1;ATP2;ATP3;ATP4';
        insert accInsert;
        System.debug('@@@@accInsert: '+accInsert);
        
        Account accInsert2 = new Account();
        Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Ship_To').getRecordTypeId();
        accInsert2 = RV_TestHelper.insertAccount(accInsert2);
        accInsert2.Rv_Available_for_OLF__c=true;
        accInsert2.Rv_Olf_Customer_Email__c='test@abc.com';
        accInsert2.Customer_Type__c = 'Ship To';
        accInsert2.recordTypeId = recTypeId;
        accInsert2.ParentId = accInsert.Id;
        insert accInsert2;
        System.debug('@@@@accInsert2: '+accInsert2);
        
        Location__c loc=new Location__c();
        loc=RV_TestHelper.insertLocation(loc);
        insert loc;
        
        
        Product_Catalogue__c pc=new Product_Catalogue__c();
        pc=RV_TestHelper.insertProductCat(pc);
        pc.Online_Material_Name_Taxed__c='Diesel B7';
        pc.Online_Material_Name_UnTaxed__c='Diesel B7, unversteuert';
        pc.Commodity_Grade_L2__c='AGO B7';
        pc.Marketing_Cost__c = 0.014;	//Fix_394298_10Jan2020_Soumyajit
        insert pc;
        
        ATP__c atp=new ATP__c();
        atp=RV_TestHelper.insertATPRecord(atp,loc);
        atp.ATP1__c= 200000;
        atp.Minimum_Daily_Split_Volume__c=100;
        atp.Split_Volume__c=10;
        atp.Minimum_Online_Volume__c=1000;
        atp.Maximum_Online_Volume__c = 300000;
        atp.Volume_Cap_Customer__c = 100000;	//TestCovearge_340363_Soumyajit_21Oct2019
        insert atp;
        atp = RV_DAL.fetchAllATPRecord()[0];
        
        
        MRC__c mrc1=new MRC__C();
        mrc1=RV_TestHelper.insertMRC(mrc1,accInsert ,loc,pc);
        mrc1.Sold_To__c=accInsert.Id;
        mrc1.Ship_To__c=accInsert2.Id;
        mrc1.Shipping_Condition__c=10;
        mrc1.Rv_Available_for_OLF__c=true;
        mrc1.name='320076590-101005';
        insert mrc1;
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
        
        List<RV_SPCalculationController.salesPriceWrap> swList=new List<RV_SPCalculationController.salesPriceWrap>();
        RV_SPCalculationController.salesPriceWrap sw=new RV_SPCalculationController.salesPriceWrap();
        sw.BSP=90;
        sw.OTM=110;
        sw.MSP=100;
        sw.landedCost=95;
        sw.mrcNo='320076590-101005';
        sw.totalTax=10;
        swList.add(sw);
                
		Map<String,RV_SPCalculationController.salesPriceWrap> mrcPrcWrp= new Map<String,RV_SPCalculationController.salesPriceWrap>(); 
        for(RV_SPCalculationController.salesPriceWrap spw :swList){
            mrcPrcWrp.put(spw.mrcNo,spw);
        }
         List<OLFWrapper.MrcPriceWrap> wrapList1=new List<OLFWrapper.MrcPriceWrap>();
        
       
  		//Error Condition  
        OLFWrapper.MrcPriceWrap testWrap1=new OLFWrapper.MrcPriceWrap();
        testWrap1.MRCNumber=mrc1.Name;
        testWrap1.Location=loc.Name;
        testWrap1.MaterialName=pc.Material_Name__c;
        testWrap1.grade='AGO B7';
        testWrap1.availableVolume=String.valueOf(atp.ATP_Live__c);
        testWrap1.PricePerUnit=String.valueOf(mrcPrcWrp.get(mrc1.Name).landedCost);
        testWrap1.inputPricePerUnit='100';
        testWrap1.inputVolume='10000';
        testWrap1.StartDate =String.ValueOf(System.Today());
        testWrap1.EndDate =String.ValueOf(System.Today()+13);
        testWrap1.customerName=accInsert.Name;
        testWrap1.contactEmail=accInsert2.Rv_Olf_Customer_Email__c;
        wrapList1.add(testWrap1);
     
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/createDeal/';
        req.httpMethod = 'POST';
        req.addHeader('customerEmail', accInsert2.Rv_Olf_Customer_Email__c);
        req.addHeader('tranche', 'ATP1');
        req.requestBody = Blob.valueOf(JSON.serialize(wrapList1));
        RestContext.request = req;
        RestContext.response= res;
        Set<String> mrcSet1=new Set<String>();
        Test.startTest();
        mrcSet1.add(mrc1.name);
        
        User u=[Select Id from User where Id=:UserInfo.getUserId() limit 1];
        
        OLF_Utility.global_overrideChecks = true;
        
        System.RunAs(u){
        OLF_CreateDeal.getMrcRecords(mrcSet1);
        OLF_CreateDeal.insertOlfDealInSht(wrapList1);
        OLF_CreateDeal.createOlfDeals();
        }
        Test.stopTest(); 
    }
    

}