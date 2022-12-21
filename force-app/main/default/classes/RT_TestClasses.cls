@isTest
public class RT_TestClasses {

    @testSetup
    static void createTestData()
    { 
        RT_Setting__c payTerm = new RT_Setting__c();
        payTerm.name = 'Z042';
        payTerm.RecordTypeId = RT_Util.codeSettRecTypeId;
        payTerm.Type__c = 'Payment Term';
        payTerm.Active__c = true;
        payTerm.Country__c = RT_Util.countryName;
        insert payTerm;
        
        RT_Setting__c condType = new RT_Setting__c();
        condType.name = RT_Util.yp04Condition;
        condType.RecordTypeId = RT_Util.codeSettRecTypeId;
        condType.Type__c = 'Condition Type';
        condType.Active__c = true;
        condType.Country__c = RT_Util.countryName;
        insert condType;
        
        Account soldToAcc = new Account();
        soldToAcc.recordtypeid = RT_Util.accRecTypeId;
        soldToAcc.name = 'TurkeyTestAccount';
        soldToAcc.AccountNumber = 'TurkeyTestAccount';
        soldToAcc.RT_Active__c = true;
        soldToAcc.type = RT_Util.accountType;
        soldToAcc.RT_Exception__c = RT_Util.includeExceptionAccount;
        soldToAcc.RT_PaymentTerm__c=payTerm.id;
        insert soldToAcc;
        
        RE_location__c depotLoc = new RE_location__c();
        depotLoc.recordtypeid = RT_Util.locRecTypeId;
        depotLoc.RT_Location_Type__c = RT_Util.depotLocType;
        depotLoc.RT_Active__c = true;
        depotLoc.name = 'TurkeyTestDepot';
        depotLoc.RE_Location_Code__c = 'TurkeyTestDepot';
        depotLoc.RT_Import_Terminal__c= RT_Util.restrictToImportTerminal;
        depotLoc.RT_ImportProductRatio__c = 1;
        insert depotLoc;
        
        RE_location__c refineryLoc = new RE_location__c();
        refineryLoc.recordtypeid = RT_Util.locRecTypeId;
        refineryLoc.RT_Location_Type__c = RT_Util.refineryLocType;
        refineryLoc.RT_Active__c = true;
        refineryLoc.name = 'TurkeyTestRefinery';
        refineryLoc.RE_Location_Code__c = 'TurkeyTestRefinery';
        insert refineryLoc;
        
        RE_location__c siteLoc = new RE_location__c();
        siteLoc.recordtypeid = RT_Util.locRecTypeId;
        siteLoc.RT_Location_Type__c = RT_Util.siteLocType;
        siteLoc.RT_Active__c = true;
        siteLoc.name = 'TurkeyTestSite';
        siteLoc.RE_Location_Code__c = 'TurkeyTestSite';
        insert siteLoc;
        
        RE_product__c gradeProd = new RE_product__c();
        gradeProd.recordtypeid = RT_Util.prodRecTypeId;
        gradeProd.RT_Product_Type__c = RT_Util.gradeProdType;
        gradeProd.Active__c = true;
        gradeProd.name = 'TurkeyGradeProduct';
        gradeProd.RT_Product_Code__c = 'TurkeyGradeProduct';
        insert gradeProd;
        
        RE_product__c subGradeProd = new RE_product__c();
        subGradeProd.recordtypeid = RT_Util.prodRecTypeId;
        subGradeProd.RT_Product_Type__c = RT_Util.subgradeProdType;
        subGradeProd.Active__c = true;
        subGradeProd.name = 'TurkeySubGradeProduct';
        subGradeProd.RT_Product_Code__c = 'TurkeySubGradeProduct';
        subGradeProd.RT_Parent_Product__c = gradeProd.id;
        insert subGradeProd;
        
        RE_product__c materialProd = new RE_product__c();
        materialProd.recordtypeid = RT_Util.prodRecTypeId;
        materialProd.RT_Product_Type__c = RT_Util.materialProdType;
        materialProd.Active__c = true;
        materialProd.name = 'TurkeyMaterialProduct';
        materialProd.RT_Product_Code__c = 'TurkeyMaterialProduct';
        materialProd.RT_Parent_Product__c = subGradeProd.id;
        insert materialProd;
        
        RE_Contract__c sapContract = new RE_Contract__c();
        sapContract.Active__c=true;
        sapContract.RT_Contract_Number__c='TestSAPcontract';
        sapContract.RT_Contract_Item__c = '10';
        sapContract.RT_Valid_From__c = System.Today()-30;
        sapContract.RT_Valid_To__c = System.Today()+30;
        sapContract.RT_Sold_To_Name__c = soldToAcc.id;
        sapContract.RT_Terms_of_Payment__c = payTerm.id;
        sapContract.RE_Product_Name__c = materialProd.Id;
        sapContract.recordtypeid = RT_Util.sapContractRecordTypeID;
        insert sapContract;
        
        RE_Route_Backbone__c route = new RE_Route_Backbone__c();
        route.RE_Depot_Name__c= depotLoc.id;
        route.RE_Product_Name__c = materialProd.id;
        route.RT_Active__c = true;
        route.RE_Source_Name__c = refineryLoc.id;
        route.recordtypeId = RT_Util.routeRecTypeId;
        insert route;
        
        RT_Price_Book__c fbsPrice = new RT_Price_Book__c();
        fbsPrice.recordtypeid = RT_Util.fbsRecTypeId;
        fbsPrice.RT_Product__c = subGradeProd.ID;
        fbsPrice.RT_Location__c = siteLoc.id;
        fbsPrice.RT_Active__c = true ;
        fbsPrice.RT_Effective_Date__c = System.today() - 30;
        fbsPrice.RT_Country__c = RT_Util.countryName;
        fbsPrice.RT_EMRAFEE__c = 100;
        fbsPrice.RT_SCT__c= 100;
        fbsPrice.RT_NET_SIP_EXP__c = 100;
        fbsPrice.RT_MP__c = 100;
        fbsPrice.RT_CRP__c = 100;
        insert fbsPrice;
        
        RT_Price_Book__c depotPrice = new RT_Price_Book__c();
        depotPrice.recordtypeid = RT_Util.depotPriceRecTypeId;
        depotPrice.RT_Product__c = gradeProd.ID;
        depotPrice.RT_Location__c = depotLoc.id;
        depotPrice.RT_Active__c = true ;
        depotPrice.RT_Effective_Date__c = System.today() - 30;
        depotPrice.RT_Country__c = RT_Util.countryName;
        depotPrice.RT_Depot_Price__c = 100;
        insert depotPrice;
        
        RT_Price_Book__c tuprasPrice = new RT_Price_Book__c();
        tuprasPrice.recordtypeid = RT_Util.refineryPriceRecTypeId;
        tuprasPrice.RT_Product__c = gradeProd.ID;
        tuprasPrice.RT_Location__c = refineryLoc.id;
        tuprasPrice.RT_Active__c = true ;
        tuprasPrice.RT_Effective_Date__c = System.today() - 30;
        tuprasPrice.RT_Country__c = RT_Util.countryName;
        tuprasPrice.RT_Refinery_Sale_Price__c =100;
        tuprasPrice.RT_Special_Consumption_Tax__c =100;
        tuprasPrice.RT_Income_Share__c = 100;
        insert tuprasPrice;
        
        RT_Setting__c accRoc = new RT_Setting__c();
        accRoc.Country__c = RT_Util.countryName;
        accRoc.Active__c = true;
        accRoc.Site_Name__c = siteLoc.id;
        accRoc.RT_Account__c = soldToAcc.id;
        accRoc.RecordTypeId = RT_Util.accountRocSettRecTypeId;
        insert accRoc;
    
        REV_Contract_Master__c aureus = new REV_Contract_Master__c();
        aureus.Active__c = true;
        aureus.RT_Sold_to_Name__c=soldToAcc.Id;
        aureus.RT_AMOUNT__c = 300;
        aureus.SAP_Contract__c = sapContract.Id;
        aureus.RT_Condition_Type__c = condType.Id;
        aureus.RT_Plant_Desc__c = depotLoc.Id;
        aureus.RT_Material_Desc__c = materialProd.Id;
        aureus.RT_Key_Value__c = 'TestKey';
        aureus.Country_Name__c = RT_Util.countryName;
        insert aureus;
        
        RT_PriceOutput__c priceYP04 = new RT_PriceOutput__c();
        priceYP04.Aureus_Data__c = aureus.id;
        priceYP04.AureusAmount__c = aureus.RT_AMOUNT__c;
        priceYP04.Amount__c = aureus.RT_AMOUNT__c;
        priceYP04.SoldToName__c = soldToAcc.id;
        priceYP04.DepotName__c = depotLoc.id;
        priceYP04.RefineryName__c = refineryLoc.id;
        priceYP04.SiteName__c = siteLoc.id;
        priceYP04.ProductName__c = materialProd.id;
        priceYP04.ProductSubGrade__c = subGradeProd.ID;
        priceYP04.ProductGrade__c = gradeProd.ID;
        priceYP04.PriceDate__c = System.today();
        priceYP04.RT_Country__c = RT_Util.countryName;
        priceYP04.Key_Value__c = 'TestKeyYP04';
        priceYP04.Condition_Type__c = RT_Util.yp04Condition;
        insert priceYP04;
        
        RT_PriceOutput__c priceYD07 = new RT_PriceOutput__c();
        priceYD07.Aureus_Data__c = aureus.id;
        priceYD07.AureusAmount__c = aureus.RT_AMOUNT__c;
        priceYD07.Amount__c = aureus.RT_AMOUNT__c;
        priceYD07.SoldToName__c = soldToAcc.id;
        priceYD07.DepotName__c = depotLoc.id;
        priceYD07.RefineryName__c = refineryLoc.id;
        priceYD07.SiteName__c = siteLoc.id;
        priceYD07.ProductName__c = materialProd.id;
        priceYD07.ProductSubGrade__c = subGradeProd.ID;
        priceYD07.ProductGrade__c = gradeProd.ID;
        priceYD07.PriceDate__c = System.today();
        priceYD07.RT_Country__c = RT_Util.countryName;
        priceYD07.Key_Value__c = 'TestKeyYD07';
        priceYD07.Condition_Type__c = RT_Util.yd07Condition;
        insert priceYD07;
        
        RT_PriceOutput__c priceYD06 = new RT_PriceOutput__c();
        priceYD06.Aureus_Data__c = aureus.id;
        priceYD06.AureusAmount__c = aureus.RT_AMOUNT__c;
        priceYD06.Amount__c = aureus.RT_AMOUNT__c;
        priceYD06.SoldToName__c = soldToAcc.id;
        priceYD06.DepotName__c = depotLoc.id;
        priceYD06.RefineryName__c = refineryLoc.id;
        priceYD06.SiteName__c = siteLoc.id;
        priceYD06.ProductName__c = materialProd.id;
        priceYD06.ProductSubGrade__c = subGradeProd.ID;
        priceYD06.ProductGrade__c = gradeProd.ID;
        priceYD06.PriceDate__c = System.today();
        priceYD06.RT_Country__c = RT_Util.countryName;
        priceYD06.Key_Value__c = 'TestKeyYD06';
        priceYD06.Condition_Type__c = RT_Util.yd06Condition;
        insert priceYD06;
        
        RT_PriceOutput__c price = new RT_PriceOutput__c();
        price.Aureus_Data__c = aureus.id;
        price.AureusAmount__c = aureus.RT_AMOUNT__c;
        price.Amount__c = aureus.RT_AMOUNT__c;
        price.SoldToName__c = soldToAcc.id;
        price.DepotName__c = depotLoc.id;
        price.RefineryName__c = refineryLoc.id;
        price.SiteName__c = siteLoc.id;
        price.ProductName__c = materialProd.id;
        price.ProductSubGrade__c = subGradeProd.ID;
        price.ProductGrade__c = gradeProd.ID;
        price.PriceDate__c = System.today();
        price.RT_Country__c = RT_Util.countryName;
        price.Key_Value__c = 'TestKeyYD05';
        price.Condition_Type__c = RT_Util.yd05Condition;
        insert price;

    }
    
    @isTest
    static void doPriceOutputControllerTest()
    { 
        RT_PriceOutputController.pageWrapper pw = RT_PriceOutputController.getPageData();

        RT_PriceOutputController.saveDailyAdjustment('125');
        
        List<RT_Util.priceWrapper> priceList= pw.priceData;
        RT_PriceOutputController.savePriceChange('amount',priceList[0].priceId,'100');
        
        RT_PriceOutputController.saveDailyAdjustment('120');
        
        RT_PriceOutputController.savePriceChange('approve',priceList[0].priceId,'');
        
        Test.startTest();
        	
            priceList = RT_PriceOutputController.submitForReview();
        	priceList = RT_PriceOutputController.matchAll();
            priceList = RT_PriceOutputController.approveRejectAll('reject');
            priceList = RT_PriceOutputController.approveRejectAll('approve');
        
        	RT_PriceOutputController.runPriceLogic();
        	
        Test.stopTest();
    }
}