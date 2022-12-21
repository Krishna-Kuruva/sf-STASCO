@isTest
private class RV_MRCCheckOnAccountTest {
    @testSetup 
    static void setup() {
    }
    
    static testmethod void testExposureValueDailyBatch() {
        Location__c loc = new Location__c();
        loc.Name = 'Ludwigshafen depot';
        loc.Plant_Code__c = 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        //loc.OMR_Region__c = 'South-West';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Shell Own Location';
        
        loc.Region_Name__c = 'East';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        insert loc;
        
        Account acc = new Account();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Name = 'ADAM OMMERT MINERALOELHANDEL';
        acc.Customer_Type__c = 'Sold To';
        acc.Sold_To_Number__c = '11223344';
        acc.Has_MRC__c = true;
        insert acc;
        
        Product_Catalogue__c productCat = new Product_Catalogue__c();
        productCat.Name = '400001952';
        productCat.Level_0__c = 'GasOil';
   
        
        productCat.Commodity_Grade_L2__c = 'ULG100 VP';
        productCat.Name = '400001952';
        productCat.Material_Name__c = 'SH ULG 100 10ppmS E5 Udy Umk V-Power DE';
        
        insert productCat;
        
        MRC__c insertmrc = new MRC__c();
        insertmrc.Name = '320076590-101004';
        insertmrc.Valid_To_Date__c  = System.today().addYears(15);
        insertmrc.Pricing_Date__c  = System.today().addYears(-9);
        insertmrc.Valid_From_Date__c  = System.today().addYears(-9);
        insertmrc.Sales_Document__c  = 320076590;
        insertmrc.Sold_To__c = acc.Id;
        insertmrc.Plant__c = loc.Id;
        
        insertmrc.Sold_To_Number_XLS__c = acc.Sold_To_Number__c;
        insertmrc.Plant_Code_XLS__c = loc.Plant_Code__c;
        insertmrc.Material_No_XLS__c = productCat.Name;
        
        insertmrc.Sales_Document_Item__c = 101004;
        insertmrc.UOM__c= 'M15';    
        insertmrc.Product__c = productCat.Id;
        insertmrc.Sales_Organization__c = 'DE01';
        insertmrc.Distribution_Channel__c = 2;
        insertmrc.Division__c = 2;
        insertmrc.Sales_Doc_Type__c = 'ZCM';
        insertmrc.Ship_to_Number__c = '11175980';
        insertmrc.Ship_to_Name__c = 'WINKLER GMBH & CO KG';
        insertmrc.Ship_to_Customer_group__c = 1;
        insertmrc.Ship_to_Street__c = 'ROBERT-BOSCH-STR. 6';
        insertmrc.Ship_to_City__c  = 'VIERNHEIM';
        insertmrc.Ship_to_State__c  = '6';
        insertmrc.Customer_Payment_Term__c = 'Z011';
        insertmrc.Plant_Description__c = 'DE1002 Ludwigshafen depot';
        insertmrc.Handling_Type__c = 'CA';
        
        insert insertmrc;
    }
}