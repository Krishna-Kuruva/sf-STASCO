@isTest
public class Rv_PriceAuditControllerTest {
    @isTest
    static void doTest()
    {
        Location__c loc = new Location__c();
        RV_TestHelper.insertLocation(loc);
        insert loc;

     	Product_Catalogue__c productCat = new Product_Catalogue__c();
        RV_TestHelper.insertProductCat(productCat);
        insert productCat;
         
    	Account accLst= new Account(); 
        RV_TestHelper.insertAccount(accLst);
        insert accLst;

    	MRC__c insertmrc = new MRC__c();
        RV_TestHelper.insertMRC(insertmrc,accLst,loc,productCat);
        insert insertmrc;
        
        SHT__c insertSHTRec = new SHT__c();
        RV_TestHelper.insertSHT(insertSHTRec,loc,accLst,insertmrc);
        insert insertSHTRec;
        
        
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
    }

}