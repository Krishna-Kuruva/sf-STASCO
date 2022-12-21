@isTest
public class RV_SHTTriggerHelperTest { 
    
    static testMethod void RV_SHTTriggerHelperTestInsert(){//Saved and expired
        RV_SHTTriggerHelper.isOlfDeal = true;
        RV_SHTTriggerHelper.recursion = true;
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	//OLFCustomerCreditChk_01Aug2019_Soumyajit
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        RV_SHTTriggerHelper.recursion = true;
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        atpInsert.Sales_8_30_17_30__c = null;
        atpInsert.Sales_15_28__c = null;
        atpInsert.Sales_29_61__c = null;
        atpInsert.Live_Online_ATP2__c = null;
        atpInsert.Live_Online_ATP3__c = null; 
        atpInsert.Live_Online_00_14__c = null;
        atpInsert.ATP2_Live__c = -100;
        atpInsert.ATP_Live__c = 0;        
        insert atpInsert;
                
        SHT__c shtInsert1 = new SHT__c();
        shtInsert1 = RV_TestHelper.insertSHT(shtInsert1,insertLoc,accInsert,insertMRC);
        shtInsert1.IsATPVolumeReduced__c = true;
        shtInsert1.IsVolumeHedged__c  = true;
        shtInsert1.Tranche__c = 'ATP1'; 
        shtInsert1.Status__c = 'Cancelled';
        insert shtInsert1; 
  
        
        SHT__c shtInsertATP2 = new SHT__c();
        shtInsertATP2 = RV_TestHelper.insertSHT(shtInsertATP2,insertLoc,accInsert,insertMRC);
        shtInsertATP2.IsATPVolumeReduced__c = true;
        shtInsertATP2.IsVolumeHedged__c  = true;
        shtInsertATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertATP2.Status__c = 'Cancelled';
        shtInsertATP2.Tranche__c = 'ATP2';
        insert shtInsertATP2;
                        
        SHT__c shtInsertLF2 = new SHT__c();
        shtInsertLF2 = RV_TestHelper.insertSHT(shtInsertLF2,insertLoc,accInsert,insertMRC);
        shtInsertLF2.IsATPVolumeReduced__c = true;
        shtInsertLF2.IsVolumeHedged__c  = true;
        shtInsertLF2.Contract_Start__c = System.today().addDays(15);
        shtInsertLF2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertLF2.Tranche__c = 'ATP2';
        shtInsertLF2.Status__c = 'Completed';
        insert shtInsertLF2;
        shtInsertLF2.Status__c = 'Auto-Completed';
        update shtInsertLF2;
        
        SHT__c shtInsertLF3 = new SHT__c();
        shtInsertLF3 = RV_TestHelper.insertSHT(shtInsertLF3,insertLoc,accInsert,insertMRC);
        shtInsertLF3.IsATPVolumeReduced__c = true;
        shtInsertLF3.IsVolumeHedged__c  = true;
        shtInsertLF3.Contract_Start__c = System.today().addDays(15);
        shtInsertLF3.Contract_End_Date__c = System.today().addDays(28);
        shtInsertLF3.Tranche__c = 'ATP3';
        shtInsertLF3.Status__c = 'Cancelled';
        insert shtInsertLF3;
       
        SHT__c shtInsertATP3 = new SHT__c();
        shtInsertATP3 = RV_TestHelper.insertSHT(shtInsertATP3,insertLoc,accInsert,insertMRC);
        shtInsertATP3.IsATPVolumeReduced__c = true;
        shtInsertATP3.IsVolumeHedged__c  = true;
        shtInsertATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertATP3.Tranche__c = 'ATP3';
        shtInsertATP3.Status__c = 'Completed';
        insert shtInsertATP3;
        
        ATP__c atpInsertULG = new ATP__c();
        atpInsertULG  = RV_TestHelper.insertATPRecordULG(atpInsertULG,insertLoc);
        atpInsertULG.Live_Online_00_14__c = null;
        insert atpInsertULG;        
        
        SHT__c shtInsertULGATP12 = new SHT__c();
        shtInsertULGATP12 = RV_TestHelper.insertSHTULG(shtInsertULGATP12,insertLoc,accInsert,insertMRC);
        shtInsertULGATP12.IsATPVolumeReduced__c = true;
        shtInsertULGATP12.IsVolumeHedged__c  = true;
        shtInsertULGATP12.Tranche__c = 'ATP1';
        shtInsertULGATP12.Status__c = 'Completed';
        insert shtInsertULGATP12;
        
        SHT__c shtInsertULGATP2 = new SHT__c();
        shtInsertULGATP2 = RV_TestHelper.insertSHTULG(shtInsertULGATP2,insertLoc,accInsert,insertMRC);
        shtInsertULGATP2.IsATPVolumeReduced__c = true;
        shtInsertULGATP2.IsVolumeHedged__c  = true;
        shtInsertULGATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP2.Tranche__c = 'ATP2';
        shtInsertULGATP2.Status__c = 'Completed';
        insert shtInsertULGATP2;
        
        SHT__c shtInsertULGATP21 = new SHT__c();
        shtInsertULGATP21 = RV_TestHelper.insertSHTULG(shtInsertULGATP21,insertLoc,accInsert,insertMRC);
        shtInsertULGATP21.IsATPVolumeReduced__c = true;
        shtInsertULGATP21.IsVolumeHedged__c  = true;
        shtInsertULGATP21.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP21.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP21.Tranche__c = 'ATP2';
        shtInsertULGATP21.Status__c = 'Cancelled';
        insert shtInsertULGATP21;
        
       
        
        SHT__c shtInsertULGATP3 = new SHT__c();
        shtInsertULGATP3 = RV_TestHelper.insertSHTULG(shtInsertULGATP3,insertLoc,accInsert,insertMRC);
        shtInsertULGATP3.IsATPVolumeReduced__c = true;
        shtInsertULGATP3.IsVolumeHedged__c  = true;
        shtInsertULGATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP3.Tranche__c = 'ATP3';
        shtInsertULGATP3.Status__c = 'Cancelled';
        insert shtInsertULGATP3;
        
        SHT__c shtInsertULGATP131 = new SHT__c();
        shtInsertULGATP131 = RV_TestHelper.insertSHTULG(shtInsertULGATP131,insertLoc,accInsert,insertMRC);
        shtInsertULGATP131.IsATPVolumeReduced__c = true;
        shtInsertULGATP131.IsVolumeHedged__c  = true;
        shtInsertULGATP131.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP131.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP131.Tranche__c = 'ATP1';
        shtInsertULGATP131.Status__c = 'Cancelled';
        insert shtInsertULGATP131;

        //OLFCustomerCreditChk_01Aug2019_Soumyajit starts
        RV_SHTTriggerHelper.accountAlreadyUpdated = false;
        SHT__c shtInsertOLF = new SHT__c();
        shtInsertOLF = RV_TestHelper.insertSHT(shtInsertOLF,insertLoc,accInsert,insertMRC);
        shtInsertOLF.IsATPVolumeReduced__c = true;
        shtInsertOLF.Tranche__c = 'ATP1';
        shtInsertOLF.IsVolumeHedged__c  = true;
        shtInsertOLF.Status__c = 'Cancelled';
        shtInsertOLF.SP_100L__c = 100;
        shtInsertOLF.Volume_CBM__c = 10;
        insert shtInsertOLF;        
        //OLFCustomerCreditChk_01Aug2019_Soumyajit ends  
         SHT__c shtInsertULGATP13 = new SHT__c();
        shtInsertULGATP13 = RV_TestHelper.insertSHTULG(shtInsertULGATP13,insertLoc,accInsert,insertMRC);
        shtInsertULGATP13.IsATPVolumeReduced__c = true;
        shtInsertULGATP13.IsVolumeHedged__c  = true;
        shtInsertULGATP13.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP13.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP13.Tranche__c = 'ATP3';
        shtInsertULGATP13.Status__c = 'Completed';
        insert shtInsertULGATP13; 
        
    }    
     
    static testMethod void RV_SHTTriggerHelperTestInsert1(){//Saved and expired
        RV_SHTTriggerHelper.isOlfDeal = false;
        RV_SHTTriggerHelper.recursion = true;
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	//OLFCustomerCreditChk_01Aug2019_Soumyajit
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        atpInsert.Sales_8_30_17_30__c = null;
        atpInsert.Sales_15_28__c = null;
        atpInsert.Sales_29_61__c = null;
        atpInsert.Live_Online_ATP2__c = null;
        atpInsert.Live_Online_ATP3__c = null; 
        atpInsert.Live_Online_00_14__c = null;
        atpInsert.ATP2_Live__c = -100;
        atpInsert.ATP_Live__c = 0;        
        insert atpInsert;
        
        
       	SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c  = true;
        shtInsert.Tranche__c = 'ATP1'; 
        shtInsert.Status__c = 'Cancelled';
        insert shtInsert; 
        
        SHT__c shtInsert1 = new SHT__c();
        shtInsert1 = RV_TestHelper.insertSHT(shtInsert1,insertLoc,accInsert,insertMRC);
        shtInsert1.IsATPVolumeReduced__c = true;
        shtInsert1.IsVolumeHedged__c  = true;
        shtInsert1.Tranche__c = 'ATP1'; 
        shtInsert1.Status__c = 'Auto-Completed';
        insert shtInsert1; 
  
        
        SHT__c shtInsertATP2 = new SHT__c();
        shtInsertATP2 = RV_TestHelper.insertSHT(shtInsertATP2,insertLoc,accInsert,insertMRC);
        shtInsertATP2.IsATPVolumeReduced__c = true;
        shtInsertATP2.IsVolumeHedged__c  = true;
        shtInsertATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertATP2.Status__c = 'Cancelled';
        shtInsertATP2.Tranche__c = 'ATP2';
        insert shtInsertATP2;
                
        SHT__c shtInsertatp1 = new SHT__c();
        shtInsertatp1 = RV_TestHelper.insertSHT(shtInsertatp1,insertLoc,accInsert,insertMRC);
        shtInsertatp1.IsATPVolumeReduced__c = true;
        shtInsertatp1.IsVolumeHedged__c  = true;
        shtInsertatp1.Contract_Start__c = System.today().addDays(15);
        shtInsertatp1.Contract_End_Date__c = System.today().addDays(28);
        shtInsertatp1.Tranche__c = 'ATP1';
        shtInsertatp1.Status__c = 'Completed';
        insert shtInsertatp1;
        shtInsertatp1.Status__c = 'Auto-Completed';
        update shtInsertatp1;
        
        SHT__c shtInsertLF2 = new SHT__c();
        shtInsertLF2 = RV_TestHelper.insertSHT(shtInsertLF2,insertLoc,accInsert,insertMRC);
        shtInsertLF2.IsATPVolumeReduced__c = true;
        shtInsertLF2.IsVolumeHedged__c  = true;
        shtInsertLF2.Contract_Start__c = System.today().addDays(15);
        shtInsertLF2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertLF2.Tranche__c = 'ATP2';
        shtInsertLF2.Status__c = 'Completed';
        insert shtInsertLF2;
        shtInsertLF2.Status__c = 'Auto-Completed';
        update shtInsertLF2;
        
        SHT__c shtInsertLF3 = new SHT__c();
        shtInsertLF3 = RV_TestHelper.insertSHT(shtInsertLF3,insertLoc,accInsert,insertMRC);
        shtInsertLF3.IsATPVolumeReduced__c = true;
        shtInsertLF3.IsVolumeHedged__c  = true;
        shtInsertLF3.Contract_Start__c = System.today().addDays(15);
        shtInsertLF3.Contract_End_Date__c = System.today().addDays(28);
        shtInsertLF3.Tranche__c = 'ATP3';
        shtInsertLF3.Status__c = 'Completed';
        insert shtInsertLF3;
        shtInsertLF3.Status__c = 'Auto-Completed';
        update shtInsertLF3;
        
         shtInsertLF3.Status__c = 'Cancelled';
        update shtInsertLF3;
        
        
      
        SHT__c shtInsertATP3 = new SHT__c();
        shtInsertATP3 = RV_TestHelper.insertSHT(shtInsertATP3,insertLoc,accInsert,insertMRC);
        shtInsertATP3.IsATPVolumeReduced__c = true;
        shtInsertATP3.IsVolumeHedged__c  = true;
        shtInsertATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertATP3.Tranche__c = 'ATP3';
        shtInsertATP3.Status__c = 'Completed';
        insert shtInsertATP3;
        
        ATP__c atpInsertULG = new ATP__c();
        atpInsertULG  = RV_TestHelper.insertATPRecordULG(atpInsertULG,insertLoc);
        atpInsert.Sales_8_30_17_30__c = null;
        atpInsert.Sales_15_28__c = null;
        atpInsert.Sales_29_61__c = null;
        atpInsert.Live_Online_ATP2__c = null;
        atpInsert.Live_Online_ATP3__c = null;
        atpInsert.Live_Online_00_14__c = null;
        atpInsertULG.Live_Online_00_14__c = null;
        insert atpInsertULG;
        
      

        SHT__c shtInsertULGATP2 = new SHT__c();
        shtInsertULGATP2 = RV_TestHelper.insertSHTULG(shtInsertULGATP2,insertLoc,accInsert,insertMRC);
        shtInsertULGATP2.IsATPVolumeReduced__c = true;
        shtInsertULGATP2.IsVolumeHedged__c  = true;
        shtInsertULGATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP2.Tranche__c = 'ATP2';
        shtInsertULGATP2.Status__c = 'Completed';
        insert shtInsertULGATP2;
        
        SHT__c shtInsertULGATP21 = new SHT__c();
        shtInsertULGATP21 = RV_TestHelper.insertSHTULG(shtInsertULGATP21,insertLoc,accInsert,insertMRC);
        shtInsertULGATP21.IsATPVolumeReduced__c = true;
        shtInsertULGATP21.IsVolumeHedged__c  = true;
        shtInsertULGATP21.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP21.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP21.Tranche__c = 'ATP2';
        shtInsertULGATP21.Status__c = 'Cancelled';
        insert shtInsertULGATP21;
        
       
        
        SHT__c shtInsertULGATP3 = new SHT__c();
        shtInsertULGATP3 = RV_TestHelper.insertSHTULG(shtInsertULGATP3,insertLoc,accInsert,insertMRC);
        shtInsertULGATP3.IsATPVolumeReduced__c = true;
        shtInsertULGATP3.IsVolumeHedged__c  = true;
        shtInsertULGATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP3.Tranche__c = 'ATP3';
        shtInsertULGATP3.Status__c = 'Cancelled';
        insert shtInsertULGATP3;

        //OLFCustomerCreditChk_01Aug2019_Soumyajit starts
        RV_SHTTriggerHelper.accountAlreadyUpdated = false;
        SHT__c shtInsertOLF = new SHT__c();
        shtInsertOLF = RV_TestHelper.insertSHT(shtInsertOLF,insertLoc,accInsert,insertMRC);
        shtInsertOLF.IsATPVolumeReduced__c = true;
        shtInsertOLF.Tranche__c = 'ATP1';
        shtInsertOLF.IsVolumeHedged__c  = true;
        shtInsertOLF.Status__c = 'Completed';
        shtInsertOLF.SP_100L__c = 100;
        shtInsertOLF.Volume_CBM__c = 10;
        insert shtInsertOLF;        
        //OLFCustomerCreditChk_01Aug2019_Soumyajit ends  
        SHT__c shtInsertULGATP13 = new SHT__c();
        shtInsertULGATP13 = RV_TestHelper.insertSHTULG(shtInsertULGATP13,insertLoc,accInsert,insertMRC);
        shtInsertULGATP13.IsATPVolumeReduced__c = true;
        shtInsertULGATP13.IsVolumeHedged__c  = true;
        shtInsertULGATP13.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP13.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP13.Tranche__c = 'ATP3';
        shtInsertULGATP13.Status__c = 'Completed';
        insert shtInsertULGATP13;     
    }    
  
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"TotalItems":"1","Status":"01","SHTItems":[{"SfItemShtNo":"SHT - 146960","SfHeaderShtNo":"1-122815","SapMrcItemNo":"101323","SalesPrice":"20.00","RejectionReason":"","QuantityUom":"CBM","Quantity":"10.00","PriceInd":"F","MaterialNo":"400002410","ItemCount":"1","DealCreationTime":"92815","DealCreationDate":"20210212","CurrencyKey":"EUR","CondUnit":"L15","CondType":"YP23","CondPUnt":"100"}],"SfHeaderShtNo":"1-122815","SapSalesContNo":"","SapMrcNo":"320076181-","SalesOrg":"DE01","POType":"TSFP","MsgTxt":"","InstanceURL":"T","ContStartDate":"20210212","ContEndDate":"20210225","Action":"C"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    static testMethod void RV_SHTTriggerHelperTestUpdate(){//Completed and cancelled
        RV_SHTTriggerHelper.recursion = true;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	//OLFCustomerCreditChk_01Aug2019_Soumyajit
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        /*added by Dharmendra - Start*/
        Product_Catalogue__c insertProductCat2 = new Product_Catalogue__c();
        insertProductCat2 = RV_TestHelper.insertProductCat(insertProductCat2);
        insertProductCat2.Name = '400001680';
        insert insertProductCat2;
        
        MRC__c insertMRC2 = new MRC__c();
        insertMRC2 = RV_TestHelper.insertMRC(insertMRC2, accInsert, insertLoc, insertProductCat2);
        insert insertMRC2;
        
        SHT__c shtInsert2 = new SHT__c();
        shtInsert2 = RV_TestHelper.insertSHT(shtInsert2,insertLoc,accInsert,insertMRC2);
        shtInsert2.IsATPVolumeReduced__c = true;
        shtInsert2.IsVolumeHedged__c  = true;
        shtInsert2.Tranche__c = 'ATP3';
        
        /*added by Dharmendra - End*/
                
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        atpInsert.Sales_8_30_17_30__c = null;
        atpInsert.Sales_15_28__c = null;
        atpInsert.Sales_29_61__c = null;
        atpInsert.Live_Online_ATP2__c = null;
        atpInsert.Live_Online_ATP3__c = null; 
        atpInsert.Live_Online_00_14__c = null;
        atpInsert.ATP2_Live__c = -100;
        atpInsert.ATP_Live__c = 0;        
        insert atpInsert;
        
       	SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c  = true;
        test.startTest();
        insert shtInsert;
        insert shtInsert2; // added by Dharmendra
        shtInsert.Status__c = 'Completed';
        shtInsert.IsGsapDealCreateOn__c=TRUE;
        shtInsert2.Status__c = 'Completed'; // added by Dharmendra
        shtInsert2.IsGsapDealCreateOn__c=TRUE; // added by Dharmendra
        shtInsert.SAP_Contract_Number__c = '111111';
        shtInsert.OLF_Deal_Number__c = '112121';
        update shtInsert;
        update shtInsert2;
        shtInsert.Status__c = 'Cancelled';
        shtInsert.Cancellation_Reason__c='Z4';
        shtInsert.IsGsapDealCancelOn__c=TRUE;
        update shtInsert;
        
         test.stopTest();
        
        SHT__c shtInsertATP2 = new SHT__c();
        shtInsertATP2 = RV_TestHelper.insertSHT(shtInsertATP2,insertLoc,accInsert,insertMRC);
        shtInsertATP2.IsATPVolumeReduced__c = true;
        shtInsertATP2.IsVolumeHedged__c  = true;
        shtInsertATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertATP2.Tranche__c = 'ATP2';
        insert shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Completed';
        update shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Cancelled';
        update shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Auto-Completed';
        update shtInsertATP2;
        
        SHT__c shtInsertATP3 = new SHT__c();
        shtInsertATP3 = RV_TestHelper.insertSHT(shtInsertATP3,insertLoc,accInsert,insertMRC);
        shtInsertATP3.IsATPVolumeReduced__c = true;
        shtInsertATP3.IsVolumeHedged__c  = true;
        shtInsertATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertATP3.Tranche__c = 'ATP3';
        insert shtInsertATP3;
        
        shtInsertATP3.Status__c = 'Completed';
        update shtInsertATP3;
        shtInsertATP3.Status__c = 'Cancelled';
        update shtInsertATP3;
        
        ATP__c atpInsertULG = new ATP__c();
        atpInsertULG  = RV_TestHelper.insertATPRecordULG(atpInsertULG,insertLoc);
        insert atpInsertULG;
        
        SHT__c shtInsertULGATP1 = new SHT__c();
        shtInsertULGATP1 = RV_TestHelper.insertSHTULG(shtInsertULGATP1,insertLoc,accInsert,insertMRC);
        shtInsertULGATP1.IsATPVolumeReduced__c = true;
        shtInsertULGATP1.IsVolumeHedged__c  = true;
        shtInsertULGATP1.Tranche__c = 'ATP1';
        insert shtInsertULGATP1;
        
        shtInsertULGATP1.Status__c = 'Completed';
        update shtInsertULGATP1;
        shtInsertULGATP1.Status__c = 'Cancelled';
        update shtInsertULGATP1;
        shtInsertULGATP1.Status__c = 'Expired';
        update shtInsertULGATP1;
        
        SHT__c shtInsertULGATP2 = new SHT__c();
        shtInsertULGATP2 = RV_TestHelper.insertSHTULG(shtInsertULGATP2,insertLoc,accInsert,insertMRC);
        shtInsertULGATP2.IsATPVolumeReduced__c = true;
        shtInsertULGATP2.IsVolumeHedged__c  = true;
        shtInsertULGATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP2.Tranche__c = 'ATP2';
        insert shtInsertULGATP2;
        
        shtInsertULGATP2.Status__c = 'Completed';
        update shtInsertULGATP2;
        
        shtInsertULGATP2.Status__c = 'Cancelled';
        update shtInsertULGATP2;
        
        SHT__c shtInsertULGATP3 = new SHT__c();
        shtInsertULGATP3 = RV_TestHelper.insertSHTULG(shtInsertULGATP3,insertLoc,accInsert,insertMRC);
        shtInsertULGATP3.IsATPVolumeReduced__c = true;
        shtInsertULGATP3.IsVolumeHedged__c  = true;
        shtInsertULGATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP3.Tranche__c = 'ATP3';
        insert shtInsertULGATP3;
        
        shtInsertULGATP3.Status__c = 'Completed';
        update shtInsertULGATP3;
        
        shtInsertULGATP3.Status__c = 'Cancelled';
        update shtInsertULGATP3;
       
        //OLFCustomerCreditChk_01Aug2019_Soumyajit starts
        RV_SHTTriggerHelper.accountAlreadyUpdated = false;
        SHT__c shtInsertOLF = new SHT__c();
        shtInsertOLF = RV_TestHelper.insertSHT(shtInsertOLF,insertLoc,accInsert,insertMRC);
        shtInsertOLF.IsATPVolumeReduced__c = true;
        shtInsertOLF.IsVolumeHedged__c  = true;
        shtInsertOLF.Status__c = 'Completed';
        shtInsertOLF.SP_100L__c = 100;
        shtInsertOLF.Volume_CBM__c = 10;
         shtInsertOLF.Tranche__c = 'ATP2';
        insert shtInsertOLF;
        shtInsertOLF.Status__c = 'Cancelled';
        update shtInsertOLF;
        shtInsertOLF.Status__c = 'Auto-Completed';
        update shtInsertOLF;
        shtInsertOLF.Status__c = 'Expired';
        update shtInsertOLF;
        //OLFCustomerCreditChk_01Aug2019_Soumyajit ends
                
        /* added by Dharmendra for code coverage - Start */
       
        SHT__c shtInsertULGATP4 = new SHT__c();
        shtInsertULGATP4 = RV_TestHelper.insertSHTULG(shtInsertULGATP4,insertLoc,accInsert,insertMRC);
        shtInsertULGATP4.IsATPVolumeReduced__c = false;
        shtInsertULGATP4.IsVolumeHedged__c = true;
        shtInsertULGATP4.SAP_Contract_Number__c = '1234';
        shtInsertULGATP4.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP4.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP4.Tranche__c = 'ATP3';
        shtInsertULGATP4.isOlfDeal__c = true;
        shtInsertULGATP4.Status__c = 'Auto-Completed';
        insert shtInsertULGATP4;
        
        shtInsertULGATP4.Status__c = 'Completed';
        update shtInsertULGATP4;
        delete shtInsertULGATP4;
        
        SHT__c shtInsertOLF1 = new SHT__c();
        accInsert.name='DHARAM';
        update accInsert;
        shtInsertOLF1 = RV_TestHelper.insertSHT(shtInsertOLF1,insertLoc,accInsert,insertMRC);
        shtInsertOLF1.IsATPVolumeReduced__c = true;
        shtInsertOLF1.IsVolumeHedged__c  = true;
        shtInsertOLF1.Status__c = 'Completed';
        shtInsertOLF1.SP_100L__c = 100;
        shtInsertOLF1.Volume_CBM__c = 10;
        insert shtInsertOLF1;
        shtInsertOLF1.SAP_Contract_Number__c = '111111';
        shtInsertOLF1.OLF_Deal_Number__c = '112121';
        //shtInsertOLF.Status__c = 'Cancelled';
        update shtInsertOLF1;
       
        SAP_Staging__c stagingRecord=new SAP_Staging__c();
        stagingRecord.SapSalesContNo__c=shtInsert.Name;
        insert stagingRecord;
        stagingrecord.Processing_Indicator__c='02';
        stagingRecord.SapSalesContNo__c=shtInsert.Name;
        Update stagingRecord;
        
        SAP_Staging__c stagingRecord1=new SAP_Staging__c();
        stagingRecord1.SapSalesContNo__c='111111';
        stagingRecord1.SfItemShtNo__c=shtInsertOLF1.Name;
        stagingRecord1.SHTId__c = shtInsertOLF1.Id;
        stagingRecord1.OLF_Deal_Number__c = null;
        insert stagingRecord1;
        stagingRecord1.Processing_Indicator__c='02';
        Update stagingRecord1;

        /* added by Dharmendra for code coverage - End */
    }
    
    static testMethod void RV_SHTTriggerHelperTestUpdate1(){//Completed and cancelled
        RV_SHTTriggerHelper.recursion = true;
        RV_SHTTriggerHelper.isOlfDeal = true;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	//OLFCustomerCreditChk_01Aug2019_Soumyajit
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        /*added by Dharmendra - Start*/
        Product_Catalogue__c insertProductCat2 = new Product_Catalogue__c();
        insertProductCat2 = RV_TestHelper.insertProductCat(insertProductCat2);
        insertProductCat2.Name = '400001680';
        insert insertProductCat2;
        
        MRC__c insertMRC2 = new MRC__c();
        insertMRC2 = RV_TestHelper.insertMRC(insertMRC2, accInsert, insertLoc, insertProductCat2);
        insert insertMRC2;
        
        SHT__c shtInsert2 = new SHT__c();
        shtInsert2 = RV_TestHelper.insertSHT(shtInsert2,insertLoc,accInsert,insertMRC2);
        shtInsert2.IsATPVolumeReduced__c = true;
        shtInsert2.IsVolumeHedged__c  = true;
        shtInsert2.Tranche__c = 'ATP3';
        
        /*added by Dharmendra - End*/
                
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        atpInsert.Sales_8_30_17_30__c = null;
        atpInsert.Sales_15_28__c = null;
        atpInsert.Sales_29_61__c = null;
        atpInsert.Live_Online_ATP2__c = null;
        atpInsert.Live_Online_ATP3__c = null; 
        atpInsert.Live_Online_00_14__c = null;
        atpInsert.ATP2_Live__c = -100;
        atpInsert.ATP_Live__c = 0;        
        insert atpInsert;
        
       	SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c  = true;
        test.startTest();
        insert shtInsert;
        insert shtInsert2; // added by Dharmendra
        shtInsert.Status__c = 'Completed';
        shtInsert.IsGsapDealCreateOn__c=TRUE;
        shtInsert2.Status__c = 'Completed'; // added by Dharmendra
        shtInsert2.IsGsapDealCreateOn__c=TRUE; // added by Dharmendra
        shtInsert.SAP_Contract_Number__c = '111111';
        shtInsert.OLF_Deal_Number__c = '112121';
        update shtInsert;
        update shtInsert2;
        shtInsert.Status__c = 'Cancelled';
        shtInsert.Cancellation_Reason__c='Z4';
        shtInsert.IsGsapDealCancelOn__c=TRUE;
        update shtInsert;
        
         test.stopTest();
        
        SHT__c shtInsertATP2 = new SHT__c();
        shtInsertATP2 = RV_TestHelper.insertSHT(shtInsertATP2,insertLoc,accInsert,insertMRC);
        shtInsertATP2.IsATPVolumeReduced__c = true;
        shtInsertATP2.IsVolumeHedged__c  = true;
        shtInsertATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertATP2.Tranche__c = 'ATP2';
        insert shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Completed';
        update shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Cancelled';
        update shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Auto-Completed';
        update shtInsertATP2;
        
        SHT__c shtInsertATP3 = new SHT__c();
        shtInsertATP3 = RV_TestHelper.insertSHT(shtInsertATP3,insertLoc,accInsert,insertMRC);
        shtInsertATP3.IsATPVolumeReduced__c = true;
        shtInsertATP3.IsVolumeHedged__c  = true;
        shtInsertATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertATP3.Tranche__c = 'ATP3';
        insert shtInsertATP3;
        
        shtInsertATP3.Status__c = 'Completed';
        update shtInsertATP3;
        shtInsertATP3.Status__c = 'Cancelled';
        update shtInsertATP3;
        
        ATP__c atpInsertULG = new ATP__c();
        atpInsertULG  = RV_TestHelper.insertATPRecordULG(atpInsertULG,insertLoc);
        insert atpInsertULG;
        
        SHT__c shtInsertULGATP1 = new SHT__c();
        shtInsertULGATP1 = RV_TestHelper.insertSHTULG(shtInsertULGATP1,insertLoc,accInsert,insertMRC);
        shtInsertULGATP1.IsATPVolumeReduced__c = true;
        shtInsertULGATP1.IsVolumeHedged__c  = true;
        shtInsertULGATP1.Tranche__c = 'ATP1';
        insert shtInsertULGATP1;
        
        shtInsertULGATP1.Status__c = 'Completed';
        update shtInsertULGATP1;
        shtInsertULGATP1.Status__c = 'Cancelled';
        update shtInsertULGATP1;
        shtInsertULGATP1.Status__c = 'Expired';
        update shtInsertULGATP1;
        
        SHT__c shtInsertULGATP2 = new SHT__c();
        shtInsertULGATP2 = RV_TestHelper.insertSHTULG(shtInsertULGATP2,insertLoc,accInsert,insertMRC);
        shtInsertULGATP2.IsATPVolumeReduced__c = true;
        shtInsertULGATP2.IsVolumeHedged__c  = true;
        shtInsertULGATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP2.Tranche__c = 'ATP2';
        insert shtInsertULGATP2;
        
        shtInsertULGATP2.Status__c = 'Completed';
        update shtInsertULGATP2;
        
        shtInsertULGATP2.Status__c = 'Cancelled';
        update shtInsertULGATP2;
        
        SHT__c shtInsertULGATP3 = new SHT__c();
        shtInsertULGATP3 = RV_TestHelper.insertSHTULG(shtInsertULGATP3,insertLoc,accInsert,insertMRC);
        shtInsertULGATP3.IsATPVolumeReduced__c = true;
        shtInsertULGATP3.IsVolumeHedged__c  = true;
        shtInsertULGATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP3.Tranche__c = 'ATP3';
        insert shtInsertULGATP3;
        
        shtInsertULGATP3.Status__c = 'Completed';
        update shtInsertULGATP3;
        
        shtInsertULGATP3.Status__c = 'Cancelled';
        update shtInsertULGATP3;
       
        //OLFCustomerCreditChk_01Aug2019_Soumyajit starts
        RV_SHTTriggerHelper.accountAlreadyUpdated = false;
        SHT__c shtInsertOLF = new SHT__c();
        shtInsertOLF = RV_TestHelper.insertSHT(shtInsertOLF,insertLoc,accInsert,insertMRC);
        shtInsertOLF.IsATPVolumeReduced__c = true;
        shtInsertOLF.IsVolumeHedged__c  = true;
        shtInsertOLF.Status__c = 'Completed';
        shtInsertOLF.SP_100L__c = 100;
        shtInsertOLF.Volume_CBM__c = 10;
         shtInsertOLF.Tranche__c = 'ATP2';
        insert shtInsertOLF;
        shtInsertOLF.Status__c = 'Cancelled';
        update shtInsertOLF;
        shtInsertOLF.Status__c = 'Auto-Completed';
        update shtInsertOLF;
        shtInsertOLF.Status__c = 'Expired';
        update shtInsertOLF;
        //OLFCustomerCreditChk_01Aug2019_Soumyajit ends
                
        /* added by Dharmendra for code coverage - Start */
       
        SHT__c shtInsertULGATP4 = new SHT__c();
        shtInsertULGATP4 = RV_TestHelper.insertSHTULG(shtInsertULGATP4,insertLoc,accInsert,insertMRC);
        shtInsertULGATP4.IsATPVolumeReduced__c = false;
        shtInsertULGATP4.IsVolumeHedged__c = true;
        shtInsertULGATP4.SAP_Contract_Number__c = '1234';
        shtInsertULGATP4.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP4.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP4.Tranche__c = 'ATP3';
        shtInsertULGATP4.isOlfDeal__c = true;
        shtInsertULGATP4.Status__c = 'Auto-Completed';
        insert shtInsertULGATP4;
        
        shtInsertULGATP4.Status__c = 'Completed';
        update shtInsertULGATP4;
        delete shtInsertULGATP4;
        
        SHT__c shtInsertOLF1 = new SHT__c();
        accInsert.name='DHARAM';
        update accInsert;
        shtInsertOLF1 = RV_TestHelper.insertSHT(shtInsertOLF1,insertLoc,accInsert,insertMRC);
        shtInsertOLF1.IsATPVolumeReduced__c = true;
        shtInsertOLF1.IsVolumeHedged__c  = true;
        shtInsertOLF1.Status__c = 'Completed';
        shtInsertOLF1.SP_100L__c = 100;
        shtInsertOLF1.Volume_CBM__c = 10;
        insert shtInsertOLF1;
        shtInsertOLF1.SAP_Contract_Number__c = '111111';
        shtInsertOLF1.OLF_Deal_Number__c = '112121';
        //shtInsertOLF.Status__c = 'Cancelled';
        update shtInsertOLF1;
       
        SAP_Staging__c stagingRecord=new SAP_Staging__c();
        stagingRecord.SapSalesContNo__c=shtInsert.Name;
        insert stagingRecord;
        stagingrecord.Processing_Indicator__c='02';
        stagingRecord.SapSalesContNo__c=shtInsert.Name;
        Update stagingRecord;
        
        SAP_Staging__c stagingRecord1=new SAP_Staging__c();
        stagingRecord1.SapSalesContNo__c='111111';
        stagingRecord1.SfItemShtNo__c=shtInsertOLF1.Name;
        stagingRecord1.SHTId__c = shtInsertOLF1.Id;
        stagingRecord1.OLF_Deal_Number__c = null;
        insert stagingRecord1;
        stagingRecord1.Processing_Indicator__c='02';
        Update stagingRecord1;

        /* added by Dharmendra for code coverage - End */
    }
    static testMethod void RV_SHTTriggerHelperTestUpdate2(){//Completed and cancelled
        RV_SHTTriggerHelper.recursion = true;
        RV_SHTTriggerHelper.isOlfDeal = true;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	//OLFCustomerCreditChk_01Aug2019_Soumyajit
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        /*added by Dharmendra - Start*/
        Product_Catalogue__c insertProductCat2 = new Product_Catalogue__c();
        insertProductCat2 = RV_TestHelper.insertProductCat(insertProductCat2);
        insertProductCat2.Name = '400001680';
        insert insertProductCat2;
        
        MRC__c insertMRC2 = new MRC__c();
        insertMRC2 = RV_TestHelper.insertMRC(insertMRC2, accInsert, insertLoc, insertProductCat2);
        insert insertMRC2;
        
        SHT__c shtInsert2 = new SHT__c();
        shtInsert2 = RV_TestHelper.insertSHT(shtInsert2,insertLoc,accInsert,insertMRC2);
        shtInsert2.IsATPVolumeReduced__c = true;
        shtInsert2.IsVolumeHedged__c  = true;
        shtInsert2.Tranche__c = 'ATP3';
        
        /*added by Dharmendra - End*/
                
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        atpInsert.Sales_8_30_17_30__c = null;
        atpInsert.Sales_15_28__c = null;
        atpInsert.Sales_29_61__c = null;
        atpInsert.Live_Online_ATP2__c = null;
        atpInsert.Live_Online_ATP3__c = null; 
        atpInsert.Live_Online_00_14__c = null;
        atpInsert.ATP2_Live__c = -100;
        atpInsert.ATP_Live__c = 0;        
        insert atpInsert;
        
       	SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c  = true;
        test.startTest();
        insert shtInsert;
        insert shtInsert2; // added by Dharmendra
        shtInsert.Status__c = 'Expired';
        shtInsert.IsGsapDealCreateOn__c=TRUE;
        shtInsert2.Status__c = 'Expired'; // added by Dharmendra
        shtInsert2.IsGsapDealCreateOn__c=TRUE; // added by Dharmendra
        shtInsert.SAP_Contract_Number__c = '111111';
        shtInsert.OLF_Deal_Number__c = '112121';
        update shtInsert;
        update shtInsert2;
        shtInsert.Status__c = 'Expired';
        shtInsert.Cancellation_Reason__c='Z4';
        shtInsert.IsGsapDealCancelOn__c=TRUE;
        update shtInsert;
        
         test.stopTest();
        
        SHT__c shtInsertATP2 = new SHT__c();
        shtInsertATP2 = RV_TestHelper.insertSHT(shtInsertATP2,insertLoc,accInsert,insertMRC);
        shtInsertATP2.IsATPVolumeReduced__c = true;
        shtInsertATP2.IsVolumeHedged__c  = true;
        shtInsertATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertATP2.Tranche__c = 'ATP2';
        insert shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Expired';
        update shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Expired';
        update shtInsertATP2;
        
        
        SHT__c shtInsertATP3 = new SHT__c();
        shtInsertATP3 = RV_TestHelper.insertSHT(shtInsertATP3,insertLoc,accInsert,insertMRC);
        shtInsertATP3.IsATPVolumeReduced__c = true;
        shtInsertATP3.IsVolumeHedged__c  = true;
        shtInsertATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertATP3.Tranche__c = 'ATP3';
        insert shtInsertATP3;
        
        shtInsertATP3.Status__c = 'Completed';
        update shtInsertATP3;
        shtInsertATP3.Status__c = 'Expired';
        update shtInsertATP3;
        
        ATP__c atpInsertULG = new ATP__c();
        atpInsertULG  = RV_TestHelper.insertATPRecordULG(atpInsertULG,insertLoc);
        insert atpInsertULG;
        
        SHT__c shtInsertULGATP1 = new SHT__c();
        shtInsertULGATP1 = RV_TestHelper.insertSHTULG(shtInsertULGATP1,insertLoc,accInsert,insertMRC);
        shtInsertULGATP1.IsATPVolumeReduced__c = true;
        shtInsertULGATP1.IsVolumeHedged__c  = true;
        shtInsertULGATP1.Tranche__c = 'ATP1';
        insert shtInsertULGATP1;
        
        shtInsertULGATP1.Status__c = 'Completed';
        update shtInsertULGATP1;
        shtInsertULGATP1.Status__c = 'Cancelled';
        update shtInsertULGATP1;
        shtInsertULGATP1.Status__c = 'Expired';
        update shtInsertULGATP1;
        
        SHT__c shtInsertULGATP2 = new SHT__c();
        shtInsertULGATP2 = RV_TestHelper.insertSHTULG(shtInsertULGATP2,insertLoc,accInsert,insertMRC);
        shtInsertULGATP2.IsATPVolumeReduced__c = true;
        shtInsertULGATP2.IsVolumeHedged__c  = true;
        shtInsertULGATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP2.Tranche__c = 'ATP2';
        insert shtInsertULGATP2;
        
        shtInsertULGATP2.Status__c = 'Completed';
        update shtInsertULGATP2;
        
        shtInsertULGATP2.Status__c = 'Expired';
        update shtInsertULGATP2;
        
        SHT__c shtInsertULGATP3 = new SHT__c();
        shtInsertULGATP3 = RV_TestHelper.insertSHTULG(shtInsertULGATP3,insertLoc,accInsert,insertMRC);
        shtInsertULGATP3.IsATPVolumeReduced__c = true;
        shtInsertULGATP3.IsVolumeHedged__c  = true;
        shtInsertULGATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP3.Tranche__c = 'ATP3';
        insert shtInsertULGATP3;
        
        shtInsertULGATP3.Status__c = 'Completed';
        update shtInsertULGATP3;
        
        shtInsertULGATP3.Status__c = 'Expired';
        update shtInsertULGATP3;
       
        //OLFCustomerCreditChk_01Aug2019_Soumyajit starts
        RV_SHTTriggerHelper.accountAlreadyUpdated = false;
        SHT__c shtInsertOLF = new SHT__c();
        shtInsertOLF = RV_TestHelper.insertSHT(shtInsertOLF,insertLoc,accInsert,insertMRC);
        shtInsertOLF.IsATPVolumeReduced__c = true;
        shtInsertOLF.IsVolumeHedged__c  = true;
        shtInsertOLF.Status__c = 'Completed';
        shtInsertOLF.SP_100L__c = 100;
        shtInsertOLF.Volume_CBM__c = 10;
         shtInsertOLF.Tranche__c = 'ATP2';
        insert shtInsertOLF;
        shtInsertOLF.Status__c = 'Cancelled';
        update shtInsertOLF;
        shtInsertOLF.Status__c = 'Auto-Completed';
        update shtInsertOLF;
        shtInsertOLF.Status__c = 'Expired';
        update shtInsertOLF;
        //OLFCustomerCreditChk_01Aug2019_Soumyajit ends
                
        /* added by Dharmendra for code coverage - Start */
       
        SHT__c shtInsertULGATP4 = new SHT__c();
        shtInsertULGATP4 = RV_TestHelper.insertSHTULG(shtInsertULGATP4,insertLoc,accInsert,insertMRC);
        shtInsertULGATP4.IsATPVolumeReduced__c = false;
        shtInsertULGATP4.IsVolumeHedged__c = true;
        shtInsertULGATP4.SAP_Contract_Number__c = '1234';
        shtInsertULGATP4.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP4.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP4.Tranche__c = 'ATP3';
        shtInsertULGATP4.isOlfDeal__c = true;
        shtInsertULGATP4.Status__c = 'Auto-Completed';
        insert shtInsertULGATP4;
        
        shtInsertULGATP4.Status__c = 'Expired';
        update shtInsertULGATP4;
        delete shtInsertULGATP4;
        
        SHT__c shtInsertOLF1 = new SHT__c();
        accInsert.name='DHARAM';
        update accInsert;
        shtInsertOLF1 = RV_TestHelper.insertSHT(shtInsertOLF1,insertLoc,accInsert,insertMRC);
        shtInsertOLF1.IsATPVolumeReduced__c = true;
        shtInsertOLF1.IsVolumeHedged__c  = true;
        shtInsertOLF1.Status__c = 'Completed';
        shtInsertOLF1.SP_100L__c = 100;
        shtInsertOLF1.Volume_CBM__c = 10;
        insert shtInsertOLF1;
        shtInsertOLF1.SAP_Contract_Number__c = '111111';
        shtInsertOLF1.OLF_Deal_Number__c = '112121';
        //shtInsertOLF.Status__c = 'Cancelled';
        update shtInsertOLF1;
       
        SAP_Staging__c stagingRecord=new SAP_Staging__c();
        stagingRecord.SapSalesContNo__c=shtInsert.Name;
        insert stagingRecord;
        stagingrecord.Processing_Indicator__c='02';
        stagingRecord.SapSalesContNo__c=shtInsert.Name;
        Update stagingRecord;
        
        SAP_Staging__c stagingRecord1=new SAP_Staging__c();
        stagingRecord1.SapSalesContNo__c='111111';
        stagingRecord1.SfItemShtNo__c=shtInsertOLF1.Name;
        stagingRecord1.SHTId__c = shtInsertOLF1.Id;
        stagingRecord1.OLF_Deal_Number__c = null;
        insert stagingRecord1;
        stagingRecord1.Processing_Indicator__c='02';
        Update stagingRecord1;

        /* added by Dharmendra for code coverage - End */
    }
    
    
    static testMethod void RV_SHTTriggerHelperTestSHTDaveInsert(){//Saved and expired
        RV_SHTTriggerHelper.recursion = true;
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        RV_SHTTriggerHelper.recursion = true;
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        insert atpInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterAGOInsert = new SHT_Dave_Master__c();       
        insertSHTDaveMasterAGOInsert = RV_TestHelper.insertSHTDaveMasterAGO(insertSHTDaveMasterAGOInsert);
        insert insertSHTDaveMasterAGOInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterULGInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterULGInsert = RV_TestHelper.insertSHTDaveMasterULG(insertSHTDaveMasterULGInsert);
        insert insertSHTDaveMasterULGInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterMOGASInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterMOGASInsert = RV_TestHelper.insertSHTDaveMasterMOGAS(insertSHTDaveMasterMOGASInsert);
        insert insertSHTDaveMasterMOGASInsert;
        
        
        SHT_Dave__c insertSHTDaveULG = new SHT_Dave__c();
        insertSHTDaveULG = RV_TestHelper.insertSHTDave(insertSHTDaveULG,insertSHTDaveMasterULGInsert);
        insertSHTDaveULG.Product_Name__c = 'ULG95 E5';
        insertSHTDaveULG.Mass_MT__c = insertSHTDaveULG.Mass_CBM__c * 0.755;
        insert insertSHTDaveULG;
        
       	SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c = true;
        test.startTest();
        insert shtInsert;
        
        shtInsert.Status__c = 'Completed';
        update shtInsert;
        
        shtInsert.Status__c = 'Cancelled';
        update shtInsert;
        test.stopTest();
        SHT__c shtInsertATP2 = new SHT__c();
        shtInsertATP2 = RV_TestHelper.insertSHT(shtInsertATP2,insertLoc,accInsert,insertMRC);
        shtInsertATP2.IsATPVolumeReduced__c = true;
        shtInsertATP2.IsVolumeHedged__c = true;
        shtInsertATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertATP2.Tranche__c = 'ATP2';
        insert shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Completed';
        update shtInsertATP2;
        
        shtInsertATP2.Status__c = 'Cancelled';
        update shtInsertATP2;
        
        SHT__c shtInsertATP3 = new SHT__c();
        shtInsertATP3 = RV_TestHelper.insertSHT(shtInsertATP3,insertLoc,accInsert,insertMRC);
        shtInsertATP3.IsATPVolumeReduced__c = true;
        shtInsertATP3.IsVolumeHedged__c = true;
        shtInsertATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertATP3.Tranche__c = 'ATP3';
        insert shtInsertATP3;
        
        shtInsertATP3.Status__c = 'Completed';
        update shtInsertATP3;
        
        ATP__c atpInsertULG = new ATP__c();
        atpInsertULG  = RV_TestHelper.insertATPRecordULG(atpInsertULG,insertLoc);
        atpInsert.Sales_8_30_17_30__c = null;
        atpInsert.Sales_15_28__c = null;
        atpInsert.Sales_29_61__c = null;
        atpInsert.Live_Online_ATP2__c = null;
        atpInsert.Live_Online_ATP3__c = null;
        insert atpInsertULG;
        
        SHT__c shtInsertULGATP1 = new SHT__c();
        shtInsertULGATP1 = RV_TestHelper.insertSHTULG(shtInsertULGATP1,insertLoc,accInsert,insertMRC);
        shtInsertULGATP1.IsATPVolumeReduced__c = true;
        shtInsertULGATP1.IsVolumeHedged__c = true;
        insert shtInsertULGATP1;
        
        shtInsertULGATP1.Status__c = 'Completed';
        update shtInsertULGATP1;
        
        SHT__c shtInsertULGATP2 = new SHT__c();
        shtInsertULGATP2 = RV_TestHelper.insertSHTULG(shtInsertULGATP2,insertLoc,accInsert,insertMRC);
        shtInsertULGATP2.IsATPVolumeReduced__c = true;
        shtInsertULGATP2.IsVolumeHedged__c = true;
        shtInsertULGATP2.Contract_Start__c = System.today().addDays(15);
        shtInsertULGATP2.Contract_End_Date__c = System.today().addDays(28);
        shtInsertULGATP2.Tranche__c = 'ATP2';
        insert shtInsertULGATP2;
        
        shtInsertULGATP2.Status__c = 'Completed';
        update shtInsertULGATP2;
        
        SHT__c shtInsertULGATP3 = new SHT__c();
        shtInsertULGATP3 = RV_TestHelper.insertSHTULG(shtInsertULGATP3,insertLoc,accInsert,insertMRC);
        shtInsertULGATP3.IsATPVolumeReduced__c = true;
        shtInsertULGATP3.IsVolumeHedged__c = true;
        shtInsertULGATP3.Contract_Start__c = System.today().addDays(29);
        shtInsertULGATP3.Contract_End_Date__c = System.today().addDays(61);
        shtInsertULGATP3.Tranche__c = 'ATP3';
        insert shtInsertULGATP3;
        
        shtInsertULGATP3.Status__c = 'Completed';
        update shtInsertULGATP3;
       
    }
    
        static testMethod void RV_SHTTriggerHelperTestSHTDaveInsertCancelled(){//Saved and expired
        
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        RV_SHTTriggerHelper.recursion = true;
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        insert atpInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterAGOInsert = new SHT_Dave_Master__c();       
        insertSHTDaveMasterAGOInsert = RV_TestHelper.insertSHTDaveMasterAGO(insertSHTDaveMasterAGOInsert);
        insert insertSHTDaveMasterAGOInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterULGInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterULGInsert = RV_TestHelper.insertSHTDaveMasterULG(insertSHTDaveMasterULGInsert);
        insert insertSHTDaveMasterULGInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterMOGASInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterMOGASInsert = RV_TestHelper.insertSHTDaveMasterMOGAS(insertSHTDaveMasterMOGASInsert);
        insert insertSHTDaveMasterMOGASInsert;
        
        
        SHT_Dave__c insertSHTDaveAGOInsert = new SHT_Dave__c();       
        insertSHTDaveAGOInsert = RV_TestHelper.insertSHTDave(insertSHTDaveAGOInsert,insertSHTDaveMasterAGOInsert);
        insertSHTDaveAGOInsert.Product_Name__c = 'ULG98';
        insert insertSHTDaveAGOInsert;
        
       	SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c = true;
        test.startTest();
        insert shtInsert;
        
        shtInsert.Status__c = 'Cancelled';
        update shtInsert;
        
        shtInsert.Status__c = 'Cancelled';
        update shtInsert;
        test.stopTest();
    }
    static testMethod void RV_SHTTriggerHelperTestSHTDaveInsertAutoCompleted(){//Saved and expired
        
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        accInsert.Rv_Available_for_OLF__c = true;	
        insert accInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        RV_SHTTriggerHelper.recursion = true;
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        insert atpInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterAGOInsert = new SHT_Dave_Master__c();       
        insertSHTDaveMasterAGOInsert = RV_TestHelper.insertSHTDaveMasterAGO(insertSHTDaveMasterAGOInsert);
       
        insert insertSHTDaveMasterAGOInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterULGInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterULGInsert = RV_TestHelper.insertSHTDaveMasterULG(insertSHTDaveMasterULGInsert);
        insert insertSHTDaveMasterULGInsert;
        
        SHT_Dave_Master__c insertSHTDaveMasterMOGASInsert = new SHT_Dave_Master__c();
        insertSHTDaveMasterMOGASInsert = RV_TestHelper.insertSHTDaveMasterMOGAS(insertSHTDaveMasterMOGASInsert);
        insert insertSHTDaveMasterMOGASInsert;
        
        
        SHT_Dave__c insertSHTDaveULG = new SHT_Dave__c();
        insertSHTDaveULG = RV_TestHelper.insertSHTDave(insertSHTDaveULG,insertSHTDaveMasterAGOInsert);
        insertSHTDaveULG.Product_Name__c = 'ULG98';
        insertSHTDaveULG.Mass_MT__c = insertSHTDaveULG.Mass_CBM__c * 0.755;
        insert insertSHTDaveULG;
        
       	SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        shtInsert.IsATPVolumeReduced__c = true;
        shtInsert.IsVolumeHedged__c = true;
        test.startTest();
        insert shtInsert;
        
        shtInsert.Status__c = 'Auto-Completed';
        update shtInsert;
        
        shtInsert.Status__c = 'Auto-Completed';
        update shtInsert;
        test.stopTest();
    }
  /*  @isTest
    public static void saveNewTxIdTest(){
        RV_SHTTriggerHelper.saveNewTxId(new RV_Settings__c());        
    } */
}