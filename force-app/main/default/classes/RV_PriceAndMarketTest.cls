@isTest
public class RV_PriceAndMarketTest {
    @testSetup 
    static void setup(){  
        //RV_TestDataFactory testData ======= new RV_TestDataFactory();
        Location__c loc = RV_TestDataFactory.createLocation('Godorf Shell Gantry', 'D004');
        insert loc;
        
        Location__c loc1 = RV_TestDataFactory.createLocation('Godorf Shell Gantry', 'D229');
        insert loc1;
       
        Account accDmy = RV_TestDataFactory.createSoldToCustomer('Shell Revolution Special Co.(Dummy)', '11111111', true, true, true);
        insert accDmy;
        
        //Insert  Account Ship To 
        Account accDmyShipTo = RV_TestDataFactory.createShipToCustomer(accDmy, 'Shell Revolution Special Co.(Dummy)', true, true, 'abc1@test.com', false, '11111111');
        insert accDmyShipTo;
        
        //Insert Account Sold To
        Account acc = RV_TestDataFactory.createSoldToCustomer('ADAM OMMERT MINERALOELHANDEL', '22222222', true, true, false);
        insert acc;
        
        //Insert Account Ship To
        Account accShipTo = RV_TestDataFactory.createShipToCustomer(acc, 'ADAM OMMERT MINERALOELHANDEL', true, true, 'abc2@test.com', false, '22222222');
        insert accShipTo;
        
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
        
        Product_Catalogue__c matULG95 = new Product_Catalogue__c();       
        matULG95.Name = '400002410';
        matULG95.Level_0__c = 'Gasoil';
        matULG95.Commodity_Grade_L2__c = 'ULG95 E5';
        matULG95.Material_Name__c = 'BF ULG95 E5 B0 Dye Mkd Germany';
        matULG95.Additive_cost_EUR_100l__c=0.2;
        matULG95.Dyeing_cost_EUR_100l__c=0.1;
        matULG95.BEHG_Value_100l__c=10.0000;
        matULG95.Future_BEHG_value_in_100l__c=11.0000;
        matULG95.Current_BEHG_valid_from_date__c=System.today().addDays(1);
        matULG95.Current_BEHG_valid_to_date__c=System.today().addDays(10);
        matULG95.Future_BEHG_valid_from_date__c=System.today().addDays(11);
        matULG95.Future_BEHG_valid_to_date__c=System.today().addDays(10);
        matULG95.Additive_cost_EUR_100l__c=0.1;
        matULG95.WASA_EUR_100l__c=0.5;
        matList.add(matULG95);
       	
        Product_Catalogue__c matULG98 = new Product_Catalogue__c();       
        matULG98.Name = '400002410';
        matULG98.Level_0__c = 'Gasoil';
        matULG98.Commodity_Grade_L2__c = 'ULG98';
        matULG98.Material_Name__c = 'BF ULG98 E5 B0 Dye Mkd Germany';
        matULG98.Additive_cost_EUR_100l__c=0.2;
        matULG98.Dyeing_cost_EUR_100l__c=0.1;
        matULG98.BEHG_Value_100l__c=10.0000;
        matULG98.Future_BEHG_value_in_100l__c=11.0000;
        matULG98.Current_BEHG_valid_from_date__c=System.today().addDays(1);
        matULG98.Current_BEHG_valid_to_date__c=System.today().addDays(10);
        matULG98.Future_BEHG_valid_from_date__c=System.today().addDays(11);
        matULG98.Future_BEHG_valid_to_date__c=System.today().addDays(10);
        matULG98.Additive_cost_EUR_100l__c=0.1;
        matULG98.WASA_EUR_100l__c=0.5;
        matList.add(matULG98);
        
       	insert matList;
        
        //Insert Mrcs
        List<MRC__c> mrcList = new List<MRC__c>();
        Id RecordTypeIdMrc = Schema.SObjectType.Mrc__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        //Insert Mrc AGO - 320076922-107004
        Mrc__c mrAgo= new Mrc__c();
        mrAgo.Name='0320078090-111229';
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
        mrAgo.Ship_to_Number__c = '0011176945';
        //insert mrAgo;
        mrcList.add(mrAgo);
        //Dummy Mrc MRCXXA002-000001
        Mrc__c mrDmyAgo= new Mrc__c();
        mrDmyAgo.Name='MRCDMYAGO-000001';
        mrDmyAgo.RecordTypeId=RecordTypeIdMrc;
        mrDmyAgo.Sold_To__c=acc.Id;
        mrDmyAgo.Rv_Available_for_OLF__c=true;
        mrDmyAgo.Ship_To__c=accDmyShipTo.Id;
        mrDmyAgo.Plant__c=loc.Id;
        mrDmyAgo.Sales_Organization__c='DE01';
        mrDmyAgo.Handling_Type__c='EB';
        mrDmyAgo.PO_Type__c='TSFP';
        mrDmyAgo.Product__c=matIgo50.Id;
        mrDmyAgo.Shipping_Condition__c=10;
        mrDmyAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrDmyAgo.Valid_From_Date__c=system.today().addDays(-100);
        mrDmyAgo.Ship_to_Number__c = '0011176945';
        //insert mrDmyAgo;
        mrcList.add(mrDmyAgo);
        
        Mrc__c mrULG95= new Mrc__c();
        mrULG95.Name='MRCULG95-000001';
        mrULG95.RecordTypeId=RecordTypeIdMrc;
        mrULG95.Sold_To__c=acc.Id;
        mrULG95.Rv_Available_for_OLF__c=true;
        mrULG95.Ship_To__c=accDmyShipTo.Id;
        mrULG95.Plant__c=loc.Id;
        mrULG95.Sales_Organization__c='DE01';
        mrULG95.Handling_Type__c='EB';
        mrULG95.PO_Type__c='TSFP';
        mrULG95.Product__c=matULG95.Id;
        mrULG95.Shipping_Condition__c=10;
        mrULG95.Valid_To_Date__c=system.today().addDays(1000);
        mrULG95.Valid_From_Date__c=system.today().addDays(-100);
        mrULG95.Ship_to_Number__c = '0011176945';
        mrcList.add(mrULG95);
        
        Mrc__c mrULG98= new Mrc__c();
        mrULG98.Name='MRCULG98-000001';
        mrULG98.RecordTypeId=RecordTypeIdMrc;
        mrULG98.Sold_To__c=acc.Id;
        mrULG98.Rv_Available_for_OLF__c=true;
        mrULG98.Ship_To__c=accDmyShipTo.Id;
        mrULG98.Plant__c=loc.Id;
        mrULG98.Sales_Organization__c='DE01';
        mrULG98.Handling_Type__c='EB';
        mrULG98.PO_Type__c='TSFP';
        mrULG98.Product__c=matULG98.Id;
        mrULG98.Shipping_Condition__c=10;
        mrULG98.Valid_To_Date__c=system.today().addDays(1000);
        mrULG98.Valid_From_Date__c=system.today().addDays(-100);
        mrULG98.Ship_to_Number__c = '0011176946';
        mrcList.add(mrULG98);
        
        Mrc__c objMRC= new Mrc__c();
        objMRC.Name='RCULG95-1000001';
        objMRC.RecordTypeId=RecordTypeIdMrc;
        objMRC.Sold_To__c=acc.Id;
        objMRC.Rv_Available_for_OLF__c=true;
        objMRC.Ship_To__c=accDmyShipTo.Id;
        objMRC.Plant__c=loc.Id;
        objMRC.Sales_Organization__c='DE01';
        objMRC.Handling_Type__c='EB';
        objMRC.PO_Type__c='TSFP';
        objMRC.Product__c=matULG95.Id;
        objMRC.Shipping_Condition__c=10;
        objMRC.Valid_To_Date__c=system.today().addDays(1000);
        objMRC.Valid_From_Date__c=system.today().addDays(-100);
        objMRC.Ship_to_Number__c = '0011176945';
        mrcList.add(objMRC);
        
        insert mrcList;
        
        ATP__c atp = new ATP__c();
        atp.Location__c = loc.Id; 
        atp.Grade_Level2__c = 'AGO B7';
        atp.Sales_8_30_17_30__c = 100;
        atp.ATP_Live__c = 20;
        atp.Live_Online_00_14__c = 25;
        insert atp;
    }
    static testmethod void testPriceAndMarketMethod(){
        RV_PriceAndMarket pm = new RV_PriceAndMarket();
        Account acc = [Select Id from Account where name ='ADAM OMMERT MINERALOELHANDEL' limit 1];
        List<Mrc__c> mrcList=[select id,name,Plant__c,Plant__r.Name,Plant__r.Country__c,Plant_code__c,
                Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Material_Description__c,Material_Name__c,PO_Type__c,
                 Sold_To__c,Sold_To__r.Name,Sold_To__r.Rv_Olf_Customer_Email__c,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                 Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,Online_Material_Name_Taxed__c,
                 Online_Material_Name_UnTaxed__c,Online_Customer_Name__c,Sold_To_Number__c from MRC__c];
        List<String> mrcNumber = New List<String>();
        for(Mrc__c mrc:mrcList){
            mrcNumber.add(mrc.MRC_Number__c);
        }
        String soldToAccId = acc.Id;
        String shipToAccNum='0011176945';
      	List<String> mot = new List<String>();
        mot.add('10');
        mot.add('80');
        String energyTax = 'Taxed';
        List<String> productName = new List<String>();
        productName.add('AGO');
        productName.add('MOGAS');
        productName.add('IGO');
        
        String poType='TSFP';
        
        List<Location__c> location = [select id,name from Location__c where name = 'Godorf Shell Gantry'];
        List<String> plantId = new List<String>();
        for(Location__c loc:location){
            plantId.add(loc.id);
        }
      	List<String> salesOrg = new List<String>();
        salesOrg.add('DE01');
        salesOrg.add('AT01');
        
        Date myDate = Date.today();
        Date startDate1 = Date.today()-1;
        system.debug('startDate1:'+startDate1);
        Date endDate1 = Date.today()+13;
        system.debug('endDate1:'+endDate1);
        
        String startDate = startDate1.year() + '-' + startDate1.month() + '-' + startDate1.day();
		system.debug('startDate:'+startDate);
        String endDate = endDate1.year() + '-' + endDate1.month() + '-' + endDate1.day();
		system.debug('startDate:'+startDate);
        Boolean callFromOlf = false;
        
        String mrcNo1 = string.valueof(mrcList[0].MRC_Number__c);
        string shipToNum = string.valueof(mrcList[0].Ship_to_Number__c);
        string plantCode = 'D229';
        Decimal bsp = 74.35;
        Decimal finalOtm=120.35;
        Decimal offerValue=118;
        String mrcLineItem = string.valueof('111229');
        String shipToName = string.valueof(mrcList[0].Ship_to_Name__c);
        String soldTo = string.valueof(mrcList[0].Sold_To__c);
        String soldToNumber = string.valueof(mrcList[0].Sold_To_Number__c);
        String tranche = string.valueof('ATP1');
        
        Decimal offerVolume=100;
        Boolean checked=true;
        String grade = 'AGO B7';
        String salesOrg1 ='DE01';
	 	RV_PriceAndMarket.offerTrackingWrap offerWrap = new RV_PriceAndMarket.offerTrackingWrap();        
        offerWrap.mrcNo = mrcNo1;
        offerWrap.shipToNum = shipToNum;
        offerWrap.plantCode = plantCode;
        offerWrap.bsp = bsp;
        offerWrap.finalOtm = finalOtm;
        offerWrap.offerValue = offerValue;
        offerWrap.mrcLineItem = mrcLineItem;
        offerWrap.shipToName = shipToName;
        offerWrap.soldTo = soldTo;
        offerWrap.soldToNumber = soldToNumber;
        offerWrap.tranche = tranche;
        offerWrap.startDate = startDate;
        offerWrap.endDate = endDate;
        offerWrap.offerVolume = offerVolume;
        offerWrap.checked = checked;
        offerWrap.grade = grade;
        offerWrap.salesOrg = salesOrg1;
        
        List<RV_PriceAndMarket.offerTrackingWrap> offerTrackingList = new List<RV_PriceAndMarket.offerTrackingWrap>();
        offerTrackingList.add(offerWrap);
        
        
        RV_PriceAndMarket.offerTrackingWrap offerWrap1 = new RV_PriceAndMarket.offerTrackingWrap();        
        offerWrap1.mrcNo = mrcNo1;
        offerWrap1.shipToNum = shipToNum;
        offerWrap1.plantCode = 'D004';
        offerWrap1.bsp = bsp;
        offerWrap1.finalOtm = finalOtm;
        offerWrap1.offerValue = offerValue;
        offerWrap1.mrcLineItem = mrcLineItem;
        offerWrap1.shipToName = shipToName;
        offerWrap1.soldTo = soldTo;
        offerWrap1.soldToNumber = soldToNumber;
        offerWrap1.tranche = tranche;
        offerWrap1.startDate = startDate;
        offerWrap1.endDate = endDate;
        offerWrap1.offerVolume = offerVolume;
        offerWrap1.checked = true;
        offerWrap1.grade = 'ULG95 E10';
        offerWrap1.salesOrg = 'DE01';
        List<RV_PriceAndMarket.offerTrackingWrap> offerTrackingList1 = new List<RV_PriceAndMarket.offerTrackingWrap>();
        offerTrackingList1.add(offerWrap1);
                
        String jsonstring = Json.serialize(offerTrackingList); 
        String jsonstring1 = Json.serialize(offerTrackingList1);
        test.startTest();
        List<RV_PriceAndMarket.MRCDataWrap > mrcWrap = RV_PriceAndMarket.getMRCDataPriceAndMarket(soldToAccId,mrcNumber,new List<String>{'0011176945'},mot,energyTax,productName,poType,plantId,'DE01;AT01',startDate,endDate, callFromOlf,true);
        productName.clear();
        startDate1 = Date.today();
        system.debug('startDate1:'+startDate1);
        endDate1 = Date.today()-1;
        startDate = startDate1.year() + '-' + startDate1.month() + '-' + startDate1.day();		
        endDate = endDate1.year() + '-' + endDate1.month() + '-' + endDate1.day();
        productName.add('MOGAS');
        mrcNumber.clear();
        mrcNumber.add(string.valueof(mrcList[1].MRC_Number__c));
        List<RV_PriceAndMarket.MRCDataWrap > mrcWrapMOGASProduct = RV_PriceAndMarket.getMRCDataPriceAndMarket(soldToAccId,mrcNumber,new List<String>{'11176945'},mot,energyTax,productName,poType,plantId,'DE01;AT01',startDate,endDate, callFromOlf,true);
        endDate = startDate;
        startDate1 = Date.today()-1;
        startDate = startDate1.year() + '-' + startDate1.month() + '-' + startDate1.day();		         
        productName.clear();
        productName.add('IGO');
        mrcNumber.clear();
        mrcNumber.add(string.valueof(mrcList[2].MRC_Number__c));
        List<RV_PriceAndMarket.MRCDataWrap > mrcWrapIGOProduct = RV_PriceAndMarket.getMRCDataPriceAndMarket(soldToAccId,mrcNumber,new List<String>{'011176945'},mot,energyTax,productName,poType,plantId,'DE01;AT01',startDate,endDate, true,true);
        System.debug('mrcWrap::' +mrcWrap);
        
        mrcNumber.clear();
        mrcNumber.add(string.valueof(mrcList[4].MRC_Number__c));
        List<RV_PriceAndMarket.MRCDataWrap > mrcWrapp = RV_PriceAndMarket.getMRCDataPriceAndMarket(soldToAccId,mrcNumber,new List<String>{'0011176945'},mot,energyTax,productName,poType,plantId,'DE01;AT01',startDate,endDate, true,true);
        
        RV_PriceAndMarket.getTableDataForPriceAndMarket(mrcWrap);
        RV_PriceAndMarket.saveOfferTrackDetails(jsonstring,checked);
        RV_PriceAndMarket.saveOfferTrackDetails(jsonstring1,true);
        test.stopTest();
    }
}