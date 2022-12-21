@isTest

public Class OLF_UtilityTest{

    @TestSetup
    static void testData(){
        //Create Revolution Setting
        List<Revolution_Setting__c> revSettList = new List<Revolution_Setting__c>();
        Revolution_Setting__c setting1 = RV_TestDataFactory.createRevolutionSetting('OLF Connection Active', 'TRUE', false, null, null);
        Revolution_Setting__c setting2 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 1', 'ATP1', true, 0, 14);
        Revolution_Setting__c setting3 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 2', 'ATP2', true, 15, 28);
        Revolution_Setting__c setting4 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 3', 'ATP3', true, 29, 48);
        Revolution_Setting__c setting5 = RV_TestDataFactory.createRevolutionSetting('Lifting Window 4', 'ATP4', true, 49, 61);
        revSettList.add(setting1);
        revSettList.add(setting2);
        revSettList.add(setting3);
        revSettList.add(setting4);
        revSettList.add(setting5);
        insert revSettList;
    }

    static testMethod void test1(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Integration Profile']; //Fix_513491_lakshmi
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Europe/Moscow', UserName='revuser@testorg1.com');
        
        Map<String, String> headerMap= new Map<String, String>();
        headerMap.put('CustomerEmail','abc@test.com');
        Test.startTest();
        Account soldToAcc = RV_TestDataFactory.createSoldToCustomer('Test Sold-To Account', '11111111', true, true, true);
        insert soldToAcc;
        Account accInsert = RV_TestDataFactory.createShipToCustomer(soldToAcc, 'Test Ship-To Account', true, true, 'abc@test.com', true, '22222222');
        insert accInsert;
        Location__c loc=new Location__c();
        loc=RV_TestHelper.insertLocation(loc);
        insert loc;
        Customer_Sales_Management__c csm = RV_TestDataFactory.createCSM(soldToAcc, loc, 'IGO 50ppm', 0);
        insert csm;
        ATP__c atp=new ATP__c();
        atp=RV_TestHelper.insertATPRecord(atp,loc);
        atp.Volume_Cap_Customer__c = 100000;	//TestCovearge_340363_Soumyajit_21Oct2019
        insert atp;
        Set<string> plantCode=new Set<String>();
        plantCode.add('D004');
        Map<String,Decimal> atpMap = new Map<String,Decimal>();

        //TestCovearge_340363_Soumyajit_21Oct2019 starts
        Product_Catalogue__c productCat = new Product_Catalogue__c();
        productCat=RV_TestHelper.insertProductCat(productCat);
        insert productCat;
        MRC__c insertmrc = new MRC__c();
        insertmrc=RV_TestDataFactory.createMRC(soldToAcc, accInsert, loc, productCat, 'DE01');
        insert insertmrc;
        SHT__c insertSHTRec = new SHT__c();
        insertSHTRec=RV_TestHelper.insertSHT(insertSHTRec,loc,accInsert,insertmrc);
        insertSHTRec.Status__c = 'Completed';
        insertSHTRec.Tranche__c = 'ATP1';
        insert insertSHTRec;
        List<Product_Name_Mapping__mdt> pdtNameMapLst=[Select Id,Product_Name__c,MasterLabel from Product_Name_Mapping__mdt];
        Map<String,String> gradeMap= new Map<String,String>();
            for(Product_Name_Mapping__mdt pnm :pdtNameMapLst){gradeMap.put(pnm.MasterLabel,pnm.Product_Name__c);}
        Map<String,String> plantIdCodeMap=new Map<String,String>();
            plantIdCodeMap.put(insertmrc.Plant__c,insertmrc.Plant_Code__c);
        list<SHT__c> shtLst = new list<SHT__c>();
        shtLst.add(insertSHTRec);
        Test.stopTest();
        //TestCovearge_340363_Soumyajit_21Oct2019 ends
        
        OLF_Utility.global_overrideChecks = true;
        
        System.runAs(u) {
            OLF_Utility.auditOlfApiLogin(headerMap,'createDeal',system.now());
            OLF_Utility.connectionAllowed();//292153_OLFConnectionTime_11Jul2019_Soumyajit
            OLF_Utility.queryForCustomerDetail(headerMap.get('CustomerEmail'), 'ATP1');	//Rahul Sharma | Date - 13-Nov-2020 : Fix. Added tranche parameter.
            
            //TestCovearge_340363_Soumyajit_21Oct2019 starts
            atpMap = OLF_FetchMrcFinalPrice.getAtpforPlant(plantCode,accInsert.Id, new List<String>{'ATP1'});
            OLF_Utility.makeEntryInCustomerSalesManagement(shtLst,accInsert.id,gradeMap,plantIdCodeMap);
            OLF_Utility.checkOLFConnectionStatus('ATP1');	//Rahul Sharma | Date - 13-Nov-2020 : Fix. Added tranche parameter.
            //TestCovearge_340363_Soumyajit_21Oct2019 ends
        }
    }

    static testMethod void updateCreditForCustomer_Test(){
        Account soldToAcc = RV_TestDataFactory.createSoldToCustomer('Test Sold-To Account', '11111111', true, true, true);
        insert soldToAcc;
        Account shipToAcc = RV_TestDataFactory.createShipToCustomer(soldToAcc, 'Test Ship-To Account', true, true, 'abc@test.com', true, '22222222');
        insert shipToAcc;
        Account thisAcc = [SELECT Id, 
                                  Name, 
                                  Parent.Rv_Credit_Limit__c,
                                  Parent.Rv_Credit_Available__c,
                                  Parent.Rv_Credit_Utilized__c FROM Account WHERE Id =: shipToAcc.Id];
        OLF_Utility.updateCreditForCustomer(thisAcc, 10);
    }
    
    /*Method Name	:	getContractDateWindow_test
    * Date			:	18-Feb-2021
    * Developer		:	Rahul Sharma
    * Description	:	Test method for getContractDateWindow() method*/
    @isTest
    static void getContractDateWindow_test(){
        OLFWrapper.ContractDateWindowWrap dateWrap = OLF_Utility.getContractDateWindow(0, 14);
        System.assertEquals(Date.today(), dateWrap.contractStartDate);
        System.assertEquals(Date.today().addDays(14), dateWrap.contractEndDate);
    }
    
    /*Method Name	:	getOnilineTranche_test
    * Date			:	18-Feb-2021
    * Developer		:	Rahul Sharma
    * Description	:	Test method for getOnilineTranche() method*/
    @isTest
    static void getOnilineTranche_test(){
        Map<String, String> atpWindowList = OLF_Utility.getOnilineTranche(new List<Date>{Date.today()});
    }
    
    /*Method Name	:	queryForCustomerDetail_test
    * Date			:	18-Feb-2021
    * Developer		:	Rahul Sharma
    * Description	:	Test method for queryForCustomerDetail() method*/
    @isTest
    static void fsf(){
        Account soldToAcc = RV_TestDataFactory.createSoldToCustomer('Test Sold-To Account', '11111111', true, true, true);
        insert soldToAcc;
        Account accInsert = RV_TestDataFactory.createShipToCustomer(soldToAcc, 'Test Ship-To Account', true, true, 'abc@test.com', true, '22222222');
        insert accInsert;
		List<Account> accList = OLF_Utility.queryForCustomerDetail('abc@test.com');   
    }
}