@isTest
public Class OLF_FetchMrcFinalPriceTest{

static{
    
}

    static TestMethod void test1(){
        Account soldToAcc = RV_TestDataFactory.createSoldToCustomer('Test Sold-To Account', '11111111', true, true, true);
        insert soldToAcc;
        Account accInsert = RV_TestDataFactory.createShipToCustomer(soldToAcc, 'Test Ship-To Account', true, true, 'abc@test.com', true, '22222222');
        insert accInsert;
        Location__c loc=new Location__c();
        loc=RV_TestHelper.insertLocation(loc);
        insert loc;
        ATP__c atp1=new ATP__c();
        atp1=RV_TestHelper.insertATPRecord(atp1,loc);
        atp1.Volume_Cap_Customer__c = 100000;	//TestCovearge_340363_Soumyajit_21Oct2019
        insert atp1;
        Set<string> plantCode=new Set<String>();
        plantCode.add('D004');
        Set<String> plantCode1=new Set<String>();
        plantCode1.add('D004');
        Product_Catalogue__c productCat = new Product_Catalogue__c();
        productCat=RV_TestHelper.insertProductCat(productCat);
        insert productCat;
        MRC__c mrc = RV_TestDataFactory.createMRC(soldToAcc, accInsert, loc, productCat, 'DE01');
        insert mrc;
        
        
        List<OLFWrapper.MrcPriceWrap> w;        
        OLFWrapper.MrcPriceWrap testWrap=new OLFWrapper.MrcPriceWrap();
        testWrap.MRCNumber='TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        testWrap.Location=loc.Name;
        testWrap.MaterialName ='ULG95 E5';
        testWrap.availableVolume='10';
        testWrap.PricePerUnit='2';
        testWrap.StartDate =String.ValueOf(System.Today());
        testWrap.EndDate =String.ValueOf(System.Today()+1);
        testWrap.customerName=accInsert.Name;
        testWrap.contactEmail='test@abc.com';
        
        OLF_FetchMrcFinalPrice ofp=new OLF_FetchMrcFinalPrice();
        OLF_FetchMrcFinalPrice.getAtpforPlant(plantCode,soldToAcc.Id, new List<String>{'ATP1'});		//TestCovearge_340363_Soumyajit_21Oct2019
        atp1.Grade_Level2__c='ULG95 E5';
        update atp1;
        OLF_FetchMrcFinalPrice.getAtpforPlant(plantCode1,soldToAcc.Id, new List<String>{'ATP1'});
        //START - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on fetchPrice().
        OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();
        olfTrancheWrap.tranche = 'ATP1';
        olfTrancheWrap.isOlfActive = true;
        olfTrancheWrap.startDay = 0;
        olfTrancheWrap.endDay = 14;
        OLF_FetchMrcFinalPrice.fetchPrice(new List<Account>{accInsert}, 'abc@test.com', olfTrancheWrap);	//TestCovearge_340363_Soumyajit_21Oct2019        
    	//START - Rahul Sharma | Date - 13-Nov-2020 : Added OlfTrancheWrap wrapper as an input paramter on fetchPrice().
    }

}