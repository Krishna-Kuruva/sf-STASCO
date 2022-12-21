@isTest
public Class OLF_SendEmailTest{
    static testMethod void test1(){
    
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Olf_Customer_Email__c = 'test@abc.com';
        accInsert.Rv_Available_for_OLF__c = true;
        accInsert.Rv_Olf_EmailID__c = 'test1@abc.com;test2@abc.com;';
        insert accInsert;
        Location__c loc=new Location__c();
        loc=RV_TestHelper.insertLocation(loc);
        insert loc;
        ATP__c atp1=new ATP__c();
        atp1=RV_TestHelper.insertATPRecord(atp1,loc);
        insert atp1;
        Set<string> plantCode=new Set<String>();
        plantCode.add('D031');
        Set<String> plantCode1=new Set<String>();
        plantCode1.add(atp1.plant_Code__C);
        atp1.Grade_Level2__c='ULG95 E5';
        update atp1;
        
        List<OLFWrapper.MrcPriceWrap> wrapList=new List<OLFWrapper.MrcPriceWrap>();        
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
        wrapList.add(testWrap);
        OLF_SendEmail.sendEmailtoCustomer(wrapList);
    }          

}