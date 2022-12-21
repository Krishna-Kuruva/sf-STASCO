/*****************************************************************************
@Name:  RV_TestHelper     
@=========================================================================
@Purpose: test helper class to insert test data of RV sobjects
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      27/09/2017         INITIAL DEVELOPMENT

******************************************************************************/
public class RV_TestHelper {
    
    public static Location__c insertLocation(Location__c loc){
        loc.Name = 'Ludwigshafen depot';
        loc.Plant_Code__c = 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'South West';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Shell Own Location';
        loc.Alt_Type__c='Alternate1';
        loc.Region_Name__c = 'East';
        loc.Products_Availability__c='AGO B7;IGO 50ppm;ULG95 E5';
        loc.Depot_MOT__c='Barge;ITT;Rail;TRuck';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        return loc;
    }
     public static Product_Catalogue__c insertProductCat(Product_Catalogue__c productCat){
        productCat.Name = '400001685';
        productCat.Level_0__c = 'Gasoil';
        productCat.Commodity_Grade_L2__c = 'AGO B7';
        productCat.Material_Name__c = 'TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        return productCat;
    }
    public static Account insertAccount(Account accLst){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        accLst.RecordTypeId = RecordTypeIdAccount;
        accLst.Name = 'ADAM OMMERT MINERALOELHANDEL';
        accLst.Customer_Type__c = 'Sold To';
        accLst.Sold_To_Number__c='12345678';
        accLst.Has_MRC__c = true;
        accLst.IWO_Member__c=true;
        return accLst;
    }  
    public static MRC__c insertMRC(MRC__c insertmrc,Account accLst,Location__c loc,Product_Catalogue__c productCat){
        insertmrc.Name = '320076590-101004';
        insertmrc.Valid_To_Date__c  = System.today().addYears(15);
        insertmrc.Valid_From_Date__c  = System.today().addYears(-1);
        insertmrc.Sold_To__c = accLst.Id;
        insertmrc.Plant__c = loc.Id;
        insertmrc.Product__c = productCat.Id;
        insertmrc.Sales_Organization__c = 'DE01';
        insertmrc.Ship_to_Number__c = '11175980';
        insertmrc.Ship_to_Name__c = 'WINKLER GMBH & CO KG';
        insertmrc.Ship_to_Street__c = 'ROBERT-BOSCH-STR. 6';
        insertmrc.Ship_to_City__c  = 'VIERNHEIM';
        insertmrc.Ship_to_State__c  = '6';
        insertmrc.Plant_Description__c = 'DE1002 Ludwigshafen depot';
        insertmrc.Handling_Type__c = 'CA';
        insertmrc.PO_Type__c='TSFP';
        return insertmrc;
    }
    
    public static SHT__c insertSHT(SHT__c insertSHTRec,Location__c loc,Account accLst,MRC__c insertmrc){   
        insertSHTRec.Location__c = loc.Id;
        insertSHTRec.Status__c = 'Saved';
        insertSHTRec.Contract_Start__c = System.today();
        insertSHTRec.Contract_End_Date__c = System.today().addDays(14);
        insertSHTRec.Customer__c = accLst.Id;
        insertSHTRec.Tranche__c = 'ATP1';
        insertSHTRec.Volume_CBM__c = 100;
        insertSHTRec.MRC__c = insertmrc.Id;
        insertSHTRec.Sales_Type__c = 'Obam Sales';
        insertSHTRec.Product_Category__c = 'AGO B7';
        insertSHTRec.Select__c = true;
        insertSHTRec.MRC_Number__c=insertmrc.name;
        return insertSHTRec;
    }
    
    public static SHT__c insertSHTULG(SHT__c insertSHTRec,Location__c loc,Account accLst,MRC__c insertmrc){
        
        insertSHTRec.Location__c = loc.Id;
        insertSHTRec.Status__c = 'Saved';
        insertSHTRec.Contract_Start__c = System.today();
        insertSHTRec.Contract_End_Date__c = System.today().addDays(14);
        insertSHTRec.Customer__c = accLst.Id;
        insertSHTRec.Tranche__c = 'ATP1';
        insertSHTRec.Volume_CBM__c = 100;
        insertSHTRec.MRC__c = insertmrc.Id;
        insertSHTRec.Sales_Type__c = 'Obam Sales';
        insertSHTRec.Product_Category__c = 'ULG95 E5';
        insertSHTRec.Select__c = true;
        insertSHTRec.MRC_Number__c=insertmrc.name;
        return insertSHTRec;
    }
    
    public static ATP__c insertATPRecord(ATP__c atpDataInsertAGO,Location__c locationData){
        
        atpDataInsertAGO.Location__c = locationData.Id;
        atpDataInsertAGO.Grade_Level2__c = Label.AGO_B7;
        atpDataInsertAGO.ATP1__c = 1000;
        atpDataInsertAGO.ATP2__c = 1000;
        atpDataInsertAGO.ATP3__c = 1000;
        atpDataInsertAGO.ATP_Live__c = 1000;
        atpDataInsertAGO.ATP2_Live__c  = 1000;
        atpDataInsertAGO.ATP3_Live__c  = 1000;   
        atpDataInsertAGO.Sales_8_30_17_30__c = 0;
        atpDataInsertAGO.Sales_15_28__c = 0;
        atpDataInsertAGO.Sales_29_61__c = 0;
        atpDataInsertAGO.Lifting_Validity_From1__c=system.today();
        atpDataInsertAGO.Lifting_Validity_From2__c=system.today();
        atpDataInsertAGO.Lifting_Validity_From3__c=system.today();
        atpDataInsertAGO.Comment_Forward_Sales__c='test';
        atpDataInsertAGO.Comment_Prompt_Sales__c='test1';
        atpDataInsertAGO.Comment_Forward2_Sales__c='test2';
        return atpDataInsertAGO;
    }
    public static ATP__c insertATPRecordULG(ATP__c atpDataInsertAGO,Location__c locationData){
        
        atpDataInsertAGO.Location__c = locationData.Id;
        atpDataInsertAGO.Grade_Level2__c = 'ULG95 E5';
        atpDataInsertAGO.ATP1__c = 1000;
        atpDataInsertAGO.ATP2__c = 1000;
        atpDataInsertAGO.ATP3__c = 1000;
        atpDataInsertAGO.ATP_Live__c = 1000;
        atpDataInsertAGO.ATP2_Live__c  = 1000;
        atpDataInsertAGO.ATP3_Live__c  = 1000;   
        atpDataInsertAGO.Sales_8_30_17_30__c = 0;
        atpDataInsertAGO.Sales_15_28__c = 0;
        atpDataInsertAGO.Sales_29_61__c = 0;
        return atpDataInsertAGO;
    }
    
    public static SHT_Dave_Master__c insertSHTDaveMasterAGO(SHT_Dave_Master__c insertSHTDaveMasterAGO){
        
        insertSHTDaveMasterAGO.Name = 'AGO B7';
        insertSHTDaveMasterAGO.Total_Exposure_Factors__c =0;
        insertSHTDaveMasterAGO.Hedged__c = 0;
       
        return insertSHTDaveMasterAGO;
    }
    
    public static SHT_Dave_Master__c insertSHTDaveMasterULG(SHT_Dave_Master__c insertSHTDaveMasterULG){
        
        insertSHTDaveMasterULG.Name = 'ULG95 E5';
        insertSHTDaveMasterULG.Total_Exposure_Factors__c =0;
        insertSHTDaveMasterULG.Hedged__c = 0;
        
        return insertSHTDaveMasterULG;
    }
    
    public static SHT_Dave_Master__c insertSHTDaveMasterMOGAS(SHT_Dave_Master__c insertSHTDaveMasterULG){
        
        insertSHTDaveMasterULG.Name = 'MOGAS';
        insertSHTDaveMasterULG.Total_Exposure_Factors__c =0;
        insertSHTDaveMasterULG.Hedged__c = 0;
        
        return insertSHTDaveMasterULG;
    }
    
    public static SHT_Dave__c insertSHTDave(SHT_Dave__c insertSHTDave,SHT_Dave_Master__c shtDaveMaster){
        insertSHTDave.SHT_Dave_Master__c = shtDaveMaster.Id;
        insertSHTDave.Product_Name__c = 'AGO B7';
        insertSHTDave.Transactions__c = 'Sales';
        insertSHTDave.Created_Date__c = System.now();
        insertSHTDave.Mass_CBM__c = 100;
        insertSHTDave.Mass_MT__c = insertSHTDave.Mass_CBM__c * 0.845;
        insertSHTDave.Exposure_Factor__c = 0.00;
        return insertSHTDave;
    }
    
    public static SHT_Dave__c insertSHTDaveHedge(SHT_Dave__c insertSHTDaveHedge,SHT_Dave_Master__c shtDaveMaster){
        insertSHTDaveHedge.SHT_Dave_Master__c = shtDaveMaster.Id;
        insertSHTDaveHedge.Product_Name__c = 'AGO B7';
        insertSHTDaveHedge.Transactions__c = 'Hedge';
        insertSHTDaveHedge.Hedge__c = 100;
        insertSHTDaveHedge.Hedging_Date__c = System.now();
        return insertSHTDaveHedge;
    }
   /* public static SHT__c insertSHTRecordATP1Complete(Product_Catalogue__c productCat,Location__c locationData){
        SHT__c shtDataInsertATP1 = new SHT__c();
        shtDataInsertATP1.Product_Category__c = 'AGO B7';
        shtDataInsertATP1.Location__c = locationData.Id;
        shtDataInsertATP1.Volume_CBM__c = 100;
        shtDataInsertATP1.Status__c = Label.SHT_Status_Completed;
        shtDataInsertATP1.Tranche__c = Label.ATP1;
        return shtDataInsertATP1;
    }
    
    public static SHT__c insertSHTRecordATP2Complete(Product_Catalogue__c productCat,Location__c locationData){    
        SHT__c shtDataInsertATP2 = new SHT__c();
        shtDataInsertATP2.Product_Category__c = 'AGO B7';
        shtDataInsertATP2.Location__c = locationData.Id;
        shtDataInsertATP2.Volume_CBM__c = 100;
        shtDataInsertATP2.Status__c = Label.SHT_Status_Completed;
        shtDataInsertATP2.Tranche__c = Label.ATP2;
        return shtDataInsertATP2;
    }
    public static SHT__c insertSHTRecordATP3Complete(Product_Catalogue__c productCat,Location__c locationData){
        SHT__c shtDataInsertATP3 = new SHT__c();
        shtDataInsertATP3.Product_Category__c = 'AGO B7';
        shtDataInsertATP3.Location__c = locationData.Id;
        shtDataInsertATP3.Volume_CBM__c = 100;
        shtDataInsertATP3.Status__c = Label.SHT_Status_Completed;
        shtDataInsertATP3.Tranche__c = Label.ATP3;
        return shtDataInsertATP3;
    }
    
    public static SHT__c insertSHTRecordATP1Cancel(Product_Catalogue__c productCat,Location__c locationData){
        SHT__c shtDataInsertATP1 = new SHT__c();
        shtDataInsertATP1.Product_Category__c = 'AGO B7';
        shtDataInsertATP1.Location__c = locationData.Id;
        shtDataInsertATP1.Volume_CBM__c = 100;
        shtDataInsertATP1.Status__c = Label.SHT_Status_Cancelled;
        shtDataInsertATP1.Tranche__c = Label.ATP1;
        return shtDataInsertATP1;
    }
    
    public static SHT__c insertSHTRecordATP2Cancel(Product_Catalogue__c productCat,Location__c locationData){    
        SHT__c shtDataInsertATP2 = new SHT__c();
        shtDataInsertATP2.Product_Category__c = 'AGO B7';
        shtDataInsertATP2.Location__c = locationData.Id;
        shtDataInsertATP2.Volume_CBM__c = 100;
        shtDataInsertATP2.Status__c = Label.SHT_Status_Cancelled;
        shtDataInsertATP2.Tranche__c = Label.ATP2;
        return shtDataInsertATP2;
    }
    public static SHT__c insertSHTRecordATP3Cancel(Product_Catalogue__c productCat,Location__c locationData){
        SHT__c shtDataInsertATP3 = new SHT__c();
        shtDataInsertATP3.Product_Catalogue__c = productCat.Id;
        shtDataInsertATP3.Location__c = locationData.Id;
        shtDataInsertATP3.Volume_CBM__c = 100;
        shtDataInsertATP3.Status__c = Label.SHT_Status_Cancelled;
        shtDataInsertATP3.Tranche__c = Label.ATP3;
        return shtDataInsertATP3;
    }
    
    
    public static List<ATP__c> insertATPRecord(Location__c locationData){
        
        List<ATP__c> atpDataInsertLst = new List<ATP__c>();
        
        ATP__c atpDataInsertAGO = new ATP__c();
        atpDataInsertAGO.Location__c = locationData.Id;
        atpDataInsertAGO.Grade_Level2__c = Label.AGO_B7;
        atpDataInsertLst.add(atpDataInsertAGO);
        
        ATP__c atpDataInsertIGO = new ATP__c();
        atpDataInsertIGO.Location__c = locationData.Id;
        atpDataInsertIGO.Grade_Level2__c = Label.IGO_50ppm;
        atpDataInsertLst.add(atpDataInsertIGO);
        
        
        
        return atpDataInsertLst;
    }
    
     public static List<Product_Catalogue__c> insertproductCatalogueRecord(){
        List<Product_Catalogue__c> productLst = new List<Product_Catalogue__c>();
         
        Product_Catalogue__c prdctDataInsertAGO = new Product_Catalogue__c();
        prdctDataInsertAGO.Name = Label.AGO_B7;
        prdctDataInsertAGO.Level_0__c = 'Gasoil';
        productLst.add(prdctDataInsertAGO);
         
        Product_Catalogue__c prdctDataInsertIGO = new Product_Catalogue__c();
        prdctDataInsertIGO.Name = Label.IGO_50ppm;
        prdctDataInsertIGO.Level_0__c = 'Gasoil';
        productLst.add(prdctDataInsertIGO);
         
        Product_Catalogue__c prdctDataInsertM98 = new Product_Catalogue__c();
        prdctDataInsertM98.Name = Label.MOGAS_98;
        prdctDataInsertM98.Level_0__c = 'Gasoil';
        productLst.add(prdctDataInsertM98);
         
        Product_Catalogue__c prdctDataInsertME10 = new Product_Catalogue__c();
        prdctDataInsertME10.Name = Label.MOGAS_E10;
        prdctDataInsertME10.Level_0__c = 'Gasoil';
        productLst.add(prdctDataInsertME10);
         
        Product_Catalogue__c prdctDataInsertUgl95 = new Product_Catalogue__c();
        prdctDataInsertUgl95.Name = Label.UGL95_E5;
        prdctDataInsertUgl95.Level_0__c = 'Gasoil';
        productLst.add(prdctDataInsertUgl95);
         
        return productLst;
    }
    
     public static List<Location__c> insertLocationRecord(){
         
        List<Location__c> locationlst = new List<Location__c>();
         
        Location__c LocDataInsert = new Location__c();
        LocDataInsert.Plant_Code__c = 'N489'; 
        LocDataInsert.Name = 'ARA'; 
        locationlst.add(LocDataInsert);
         
        Location__c LocDataInsertlud = new Location__c();
        LocDataInsertlud.Plant_Code__c = 'D004'; 
        LocDataInsertlud.Name = 'Ludwigshafen'; 
        locationlst.add(LocDataInsertlud);
        
        Location__c LocDataInsertPCK = new Location__c();
        LocDataInsertPCK.Plant_Code__c = 'D028'; 
        LocDataInsertPCK.Name = 'PCK'; 
        locationlst.add(LocDataInsertPCK);
         
        Location__c LocDataInsertHamburg = new Location__c();
        LocDataInsertHamburg.Plant_Code__c = 'D033'; 
        LocDataInsertHamburg.Name = 'Hamburg'; 
        locationlst.add(LocDataInsertHamburg);
         
        Location__c LocDataInsertHannover = new Location__c();
        LocDataInsertHannover.Plant_Code__c = 'D361'; 
        LocDataInsertHannover.Name = 'Hannover'; 
        locationlst.add(LocDataInsertHannover);

        return locationlst;
    }
    
    public static List<Location__c> insertRailandTruck3rdParty(){
        
        List<Location__c> locationlst = new List<Location__c>();
        Location__c LocDataInserttotalLeuna = new Location__c();
        LocDataInserttotalLeuna.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInserttotalLeuna.Plant_Code__c = Label.Total_Leuna_Trains; 
        LocDataInserttotalLeuna.Name = 'Shell/Total Leuna'; 
        locationlst.add(LocDataInserttotalLeuna);
        
        Location__c LocDataInsertVohburg = new Location__c();
        LocDataInsertVohburg.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertVohburg.Plant_Code__c = Label.Varo_Vohburg; 
        LocDataInsertVohburg.Name = 'Shell/BO Vohburg'; 
        locationlst.add(LocDataInsertVohburg);
        
        Location__c LocDataInsertNeustadt  = new Location__c();
        LocDataInsertNeustadt.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertNeustadt.Plant_Code__c = Label.ENI_Neustadt; 
        LocDataInsertNeustadt.Name = 'Shell/BO Neustadt'; 
        locationlst.add(LocDataInsertNeustadt);
        
        Location__c LocDataInsertGunvor  = new Location__c();
        LocDataInsertGunvor.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertGunvor.Plant_Code__c = Label.Gunvor_Ingolstadt; 
        LocDataInsertGunvor.Name = 'Shell/Gunvor Ingolstadt'; 
        locationlst.add(LocDataInsertGunvor);
        
        Location__c LocDataInsertGelsenk  = new Location__c();
        LocDataInsertGelsenk.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertGelsenk.Plant_Code__c = Label.BP_Gelsenkirchen; 
        LocDataInsertGelsenk.Name = 'Shell/BP Gelsenk Transt'; 
        locationlst.add(LocDataInsertGelsenk);
        
        Location__c LocDataInsertduisburg = new Location__c();
        LocDataInsertduisburg.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertduisburg.Plant_Code__c = Label.Total_Duisburg; 
        LocDataInsertduisburg.Name = 'Shell/Total Duisburg'; 
        locationlst.add(LocDataInsertduisburg);
        
        Location__c LocDataInsertKassel = new Location__c();
        LocDataInsertKassel.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertKassel.Plant_Code__c = Label.BP_Kassel; 
        LocDataInsertKassel.Name = 'Shell/BP Kassel'; 
        locationlst.add(LocDataInsertKassel);
        
        Location__c LocDataInsertBremen = new Location__c();
        LocDataInsertBremen.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertBremen.Plant_Code__c = Label.Bremen_HGM; 
        LocDataInsertBremen.Name = 'Shell/HGM Bremen'; 
        locationlst.add(LocDataInsertBremen);
        
        Location__c LocDataInsertholborn = new Location__c();
        LocDataInsertholborn.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertholborn.Plant_Code__c = Label.Holborn; 
        LocDataInsertholborn.Name = 'Shell/Holborn Hamburg'; 
        locationlst.add(LocDataInsertholborn);
        
        Location__c LocDataInsertLeunatruck= new Location__c();
        LocDataInsertLeunatruck.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertLeunatruck.Plant_Code__c = Label.Total_Leuna_Trucks; 
        LocDataInsertLeunatruck.Name = 'Shell/Total Leuna'; 
        locationlst.add(LocDataInsertLeunatruck);
        
        Location__c LocDataInsertHartmannsdorf= new Location__c();
        LocDataInsertHartmannsdorf.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertHartmannsdorf.Plant_Code__c = Label.Hartmannsdorf; 
        LocDataInsertHartmannsdorf.Name = 'Hartmannsdorf'; 
        locationlst.add(LocDataInsertHartmannsdorf);
        
        Location__c LocDataInsertStuttgart = new Location__c();
        LocDataInsertStuttgart.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertStuttgart.Plant_Code__c = Label.Stuttgart; 
        LocDataInsertStuttgart.Name = 'Stuttgart'; 
        locationlst.add(LocDataInsertStuttgart);
        
        Location__c LocDataInsertLingen = new Location__c();
        LocDataInsertLingen.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertLingen.Plant_Code__c = Label.BP_Lingen; 
        LocDataInsertLingen.Name = 'BP Lingen'; 
        locationlst.add(LocDataInsertLingen);
        
        Location__c LocDataInsertHeide = new Location__c();
        LocDataInsertHeide.Location_Type__c =Label.X3rd_Party_Rail;
        LocDataInsertHeide.Plant_Code__c = Label.Heide; 
        LocDataInsertHeide.Name = 'Heide'; 
        locationlst.add(LocDataInsertHeide);
        
        return locationlst;
    }
    
    public static List<SHT_Dave__c> insertSHTDave(){
        
        List<SHT_Dave__c> shtDaveInsertlst = new List<SHT_Dave__c>();
        
        SHT_Dave__c shtDaveInsert = new SHT_Dave__c();
        shtDaveInsert.Product_Name__c = Label.AGO_B7;
        shtDaveInsert.Exposure_Factor__c = 100.00;
        shtDaveInsert.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsert);
        
        SHT_Dave__c shtDaveInsertIGO = new SHT_Dave__c();
        shtDaveInsertIGO.Product_Name__c = Label.IGO_50ppm;
        shtDaveInsertIGO.Exposure_Factor__c = 0.00;
        shtDaveInsertIGO.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertIGO);
        
        SHT_Dave__c shtDaveInsertm98 = new SHT_Dave__c();
        shtDaveInsertm98.Product_Name__c = Label.MOGAS_98;
        shtDaveInsertm98.Exposure_Factor__c = 100.00;
        shtDaveInsertm98.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertm98);
        
        SHT_Dave__c shtDaveInsertME10 = new SHT_Dave__c();
        shtDaveInsertME10.Product_Name__c = Label.MOGAS_E10;
        shtDaveInsertME10.Exposure_Factor__c = 0.00;
        shtDaveInsertME10.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertME10);
        
         SHT_Dave__c shtDaveInsertUGL95 = new SHT_Dave__c();
        shtDaveInsertUGL95.Product_Name__c = Label.UGL95_E5;
        shtDaveInsertUGL95.Exposure_Factor__c = 0.00;
        shtDaveInsertUGL95.Hedging_Date__c = System.today();
        shtDaveInsertlst.add(shtDaveInsertUGL95);
        
        return shtDaveInsertlst;
    }
    
 
    
    */
}