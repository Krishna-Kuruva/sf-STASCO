//AdditionalTestCoverage_12Jun2019_Soumyajit starts
@isTest
public class RV_DALTest {

    @testSetup 
    static void setupData() 
    {
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        ATP__c atpInsert = new ATP__c();
        atpInsert  = RV_TestHelper.insertATPRecord(atpInsert,insertLoc);
        insert atpInsert;
        
        Product_Catalogue__c insertProductCat = new Product_Catalogue__c();
        insertProductCat = RV_TestHelper.insertProductCat(insertProductCat);
        insert insertProductCat;
        
        Account accInsert = new Account();
        accInsert = RV_TestHelper.insertAccount(accInsert);
        insert accInsert;
        
        MRC__c insertMRC = new MRC__c();
        insertMRC = RV_TestHelper.insertMRC(insertMRC, accInsert, insertLoc, insertProductCat);
        insert insertMRC;
        
        SHT__c shtInsert = new SHT__c();
        shtInsert = RV_TestHelper.insertSHT(shtInsert,insertLoc,accInsert,insertMRC);
        insert shtInsert;
    }
    
    @isTest
    static void doTest()
    {
        List<String> fetchFinalATPLst = new List<String>();
        List<String> productset = new List<String>();
        List<String> locationset = new List<String>();
        //PBI_166252_DataCleanup_Lakshmi_1stOct2019==> Removed MOGAS_E5_Volume__c,MOGAS_E10_Volume__c,MOGAS_98_Volume__c,Quantitiy_CBM__c,Quantitiy_ATP2__c,Quantitiy_ATP3__c
        List<SHT__c> shtLst = [select id,Name,IsATPVolumeReduced__c,IsVolumeHedged__c ,Sales_Type__c,Status__c,Tranche__c,Volume_CBM__c,Contract_Start__c,Location__c,Product_Category__c from SHT__c];
        
        /*PBI_166252_DataCleanup_Lakshmi_1stOct2019==>Removed AGO_IGO_CBM_to_Ton__c,AGO_IGO_Ton_To_CBM__c,ATP_Input_Type__c,ATP1_Quantity_CBM__c,ATP2_Quantity_CBM__c
		ATP3_Quantity_CBM__c,ATP1_Status__c,ATP2_Status__c,ATP3_Status__c,ATP1_CBM__c,ATP2_CBM__c,ATP3_CBM__c,Min_Margin_T1_Euro_100L__c,Min_Margin_T1_USD_t__c,
		Min_Margin_T2_Euro_100L__c,Min_Margin_T2_USD_t__c,Min_Margin_T3_Euro_100L__c,Min_Margin_T3_USD_t__c,Published_Date__c
		*/
        
        List<ATP__c> atpLst = [Select  Location_Name__c,Location__r.Name, a.SystemModstamp, a.Sales_Region__c, a.Sales_8_30_17_30__c,
                a.Region__c, a.Refresh_ATP__c,a.Plant_Code__c, 
                a.OwnerId, a.Name, a.Mode_of_Transport_MOT__c,a.Location__c, a.LocType__c, a.Lifting_Window__c, 
                a.Lifting_Validity_From2__c, a.Lifting_Validity_From1__c, 
                a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.IsChanged__c, a.Id, a.Grade_Level2__c, a.Date__c,
                a.Current_Date__c, a.CreatedDate, a.CreatedById, a.Contract_Start__c, a.Company_Code__c,
                a.Comment_Prompt_Sales__c, a.Comment_Forward_Sales__c,a.ATP_Submit_Time__c, a.ATP_Live__c,a.ATP3__c, 
                a.ATP3_Live__c,a.ATP2__c,a.ATP2_Live__c, a.ATP1__c From ATP__c a];
        
        for(ATP__c atp : atpLst)
        {
            fetchFinalATPLst.add(String.valueof(atp.Id));
            productset.add(atp.Grade_Level2__c);
            locationset.add(atp.Location__c);
        }
        
        Test.StartTest();
        RV_DAL.fetchSHTRecord(shtLst);
        RV_DAL.fetchSHTRecordSHTDave(shtLst);
        RV_DAL.fetchATPRecord(productset,locationset);
        RV_DAL.fetchAllATPRecord();
        RV_DAL.fetchSelectedATPRecord(fetchFinalATPLst);
        Test.StopTest();
    }
}
//AdditionalTestCoverage_12Jun2019_Soumyajit ends