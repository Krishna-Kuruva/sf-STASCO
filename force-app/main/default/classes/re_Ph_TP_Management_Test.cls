@isTest(SeeAllData = false)
private class re_Ph_TP_Management_Test {

    @TestSetup
    private static void testSetupData(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Revolution East (Platform)'];
        User u = new User();
        u.Alias = 'phtest';
        u.Email = 'phtestUser@shelltest.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName        = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey    = 'en_US';
        u.ProfileId       = p.Id;
        u.TimeZoneSidKey  = 'America/Los_Angeles';
        u.UserName        = 'phtestUser@shelltest.com';
        u.IsActive        = true;
        insert u;

        List<PermissionSet> rePHPermSets = [SELECT Id FROM PermissionSet WHERE Name IN ('RE_PH_Customer_Ops','RE_PH_Pricing_Desk') LIMIT 2];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment> ();
        for(PermissionSet ps : rePHPermSets){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId  = u.Id;
            psa.PermissionSetId = ps.Id;
            psaList.add(psa);
        }
        insert psaList;
    }

    @IsTest
    private static void checkProductDepotCombinationTest(){
        User phUser = [SELECT Id, Name FROM User WHERE UserName = 'phtestUser@shelltest.com' LIMIT 1];
        System.runAs(phUser){
            //Creating Country
            Country__c country_PH = RE_UtilityClass.getCountryCode('Philippines');
            
            //Creating RE_Locations
            RE_Location__c location1 = RE_UtilityClass.getLocation('PH NMIF','P11',country_PH.Name);

            //Creating RE_Products
            RE_Product__c prod_Kero = RE_UtilityClass.getProduct('Kerosene',country_PH.Name,'PHP/LTR');
            prod_Kero.RE_Product_Group__c = 'KERO';
            prod_Kero.RE_Material__c = '400008602';
            update prod_Kero;
            RE_Product__c prod_Gaso = RE_UtilityClass.getProduct('Gasoline',country_PH.Name,'PHP/LTR');
            prod_Gaso.RE_Product_Group__c = 'KERO';
            prod_Gaso.RE_Material__c = '400008601';
            update prod_Gaso;

            //Creating Depot Pricing Backbone records
            RE_Depot_Pricing_Backbone__c dP4 = RE_UtilityClass.createDPBPH(country_PH.Name,'PH NMIF',prod_Kero.Name,'PHP/LTR');
            dp4.RE_Final_Price_Unit__c = 'PHP/LTR';
            dp4.RE_TH_HCV_Quote1__c = 'Kero';
            dp4.RE_PH_BIO_2__c = 'ETHANOL';
            dp4.RE_PH_BIO_3__c = 'UCAP RBD CNO';
            dp4.RE_TH_HCV_Quote1_Percent__c = 100;
            dp4.RE_Primary_Transport_Cost__c = 15.5;
            dp4.RE_Primary_Transport_Unit__c = 'PHP/LTR';
            dp4.RE_Insurance_Percentage__c = 100;
            dp4.RE_PH_Blend_Percentage__c = 50;
            dp4.RE_PH_Premium__c = 'Kero Premium';
            dp4.RE_Fixed_Premium__c = 65;
            dp4.RE_Primary_Transport_Cost__c = 15.5;
            dp4.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
            dp4.RE_PH_Bio_Percent__c = 100;
            dp4.RE_PH_BIO_Fixed__c = 45;
            dp4.RE_PH_Freight_Shifting_Cost__c = 15.5;
            dp4.RE_PH_Demurrage__c = 15.5;
            dp4.RE_PH_FLC_Service_Fee__c = 28.23;
            dp4.RE_PH_PT_Percentage__c = 50;
            dp4.RE_PH_MISC_Brokerage_Fee__c = 30;
            dp4.RE_PH_MISC_Hosehandling_Cost__c = 65;
            dp4.RE_PH_MISC_Port_Charges__c = 15.5;
            dp4.RE_PH_MISC_PQ_Cost__c = 23.34;
            dp4.RE_PH_MISC_Shifting_Cost__c = 10.34;
            dp4.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
            dp4.RE_PH_Terminal_Cost__c = 65;
            dp4.RE_PH_Wharfage_Cost__c = 15.5;
            dp4.RE_PH_Fuel_Marking_Factor__c = 10;
            dp4.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
            dp4.RE_PH_Ocean_Cost__c = 15.5;
            dp4.RE_PH_S_H__c = 30;
            dp4.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
            dp4.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
            dp4.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
            dp4.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
            update dp4;
            Test.startTest();
            re_Ph_TP_Management.ProductDepotWrapper wrapper = re_Ph_TP_Management.checkProductDepotCombination(prod_Kero.Id,location1.Id);
            System.debug('Wrapper details in test class: '+wrapper);

            Id recordTypeId = re_Ph_TP_Management.getRecordTypeId('RE_Depot_Pricing_Backbone__c','Philippines');
            
            Id recordTypeId2 = re_Ph_TP_Management.getRecordTypeId('RE_Depot_Pricing_Backbone__c',null);
            
            re_Ph_TP_Management.ProductDepotWrapper prodDepotWrapper = re_Ph_TP_Management.checkForActiveCombination(prod_Kero.Id, location1.Id);
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void checkProductDepotCombinationTest2(){
        User phUser = [SELECT Id, Name FROM User WHERE UserName = 'phtestUser@shelltest.com' LIMIT 1];
        System.runAs(phUser){
            //Creating Country
            Country__c country_PH = RE_UtilityClass.getCountryCode('Philippines');
            
            //Creating RE_Locations
            RE_Location__c location1 = RE_UtilityClass.getLocation('PH NMIF','P11',country_PH.Name);

            //Creating RE_Products
            RE_Product__c prod_Kero = RE_UtilityClass.getProduct('Kerosene',country_PH.Name,'PHP/LTR');
            prod_Kero.RE_Product_Group__c = 'KERO';
            prod_Kero.RE_Material__c = '400008602';
            update prod_Kero;
            RE_Product__c prod_Gaso = RE_UtilityClass.getProduct('Gasoline',country_PH.Name,'PHP/LTR');
            prod_Gaso.RE_Product_Group__c = 'KERO';
            prod_Gaso.RE_Material__c = '400008601';
            update prod_Gaso;

            //Creating Depot Pricing Backbone records
            RE_Depot_Pricing_Backbone__c dP4 = RE_UtilityClass.createDPBPH(country_PH.Name,'PH NMIF',prod_Kero.Name,'PHP/LTR');
            dp4.RE_Final_Price_Unit__c = 'PHP/LTR';
            dp4.RE_TH_HCV_Quote1__c = 'Kero';
            dp4.RE_PH_BIO_2__c = 'ETHANOL';
            dp4.RE_PH_BIO_3__c = 'UCAP RBD CNO';
            dp4.RE_TH_HCV_Quote1_Percent__c = 100;
            dp4.RE_Primary_Transport_Cost__c = 15.5;
            dp4.RE_Primary_Transport_Unit__c = 'PHP/LTR';
            dp4.RE_Insurance_Percentage__c = 100;
            dp4.RE_PH_Blend_Percentage__c = 50;
            dp4.RE_PH_Premium__c = 'Kero Premium';
            dp4.RE_Fixed_Premium__c = 65;
            dp4.RE_Primary_Transport_Cost__c = 15.5;
            dp4.RE_PH_Freight_Quote__c = 'FREIGHT S2P01';
            dp4.RE_PH_Bio_Percent__c = 100;
            dp4.RE_PH_BIO_Fixed__c = 45;
            dp4.RE_PH_Freight_Shifting_Cost__c = 15.5;
            dp4.RE_PH_Demurrage__c = 15.5;
            dp4.RE_PH_FLC_Service_Fee__c = 28.23;
            dp4.RE_PH_PT_Percentage__c = 50;
            dp4.RE_PH_MISC_Brokerage_Fee__c = 30;
            dp4.RE_PH_MISC_Hosehandling_Cost__c = 65;
            dp4.RE_PH_MISC_Port_Charges__c = 15.5;
            dp4.RE_PH_MISC_PQ_Cost__c = 23.34;
            dp4.RE_PH_MISC_Shifting_Cost__c = 10.34;
            dp4.RE_PH_MISC_Waterfront_Operations_Cost__c = 67;
            dp4.RE_PH_Terminal_Cost__c = 65;
            dp4.RE_PH_Wharfage_Cost__c = 15.5;
            dp4.RE_PH_Fuel_Marking_Factor__c = 10;
            dp4.RE_PH_MISC_Fuel_Marking_Fee__c = 17;
            dp4.RE_PH_Ocean_Cost__c = 15.5;
            dp4.RE_PH_S_H__c = 30;
            dp4.RE_PH_Wharfage_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Fuel_Marking_Fee_Unit__c = 'PHP/LTR';
            dp4.RE_Fixed_Premium_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Freight_Charges_Unit__c = 'PHP/LTR';
            dp4.RE_PH_BIO_Fixed_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Freight_Shifting_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Demurrage_Unit__c = 'PHP/LTR';
            dp4.RE_PH_FLC_Service_Fee_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Brokerage_Fee_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Hosehandling_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Port_Charges_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_PQ_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_MISC_Shifting_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Waterfront_Operations_Cost_Unit__c = 'PHP/LTR';
            dp4.RE_PH_Terminal_Cost_Unit__c = 'PHP/LTR';
            update dp4;
            Test.startTest();
            re_Ph_TP_Management.ProductDepotWrapper wrapper2 = re_Ph_TP_Management.checkProductDepotCombination(prod_Kero.Id,null);
            System.debug('Wrapper details in test class22: '+wrapper2);
            re_Ph_TP_Management.ProductDepotWrapper prodDepotWrapper = re_Ph_TP_Management.checkForActiveCombination(prod_Gaso.Id, location1.Id);
            Test.stopTest();
        }
    }

    @isTest
    private static void checkForActiveCombinationTest(){
        User phUser = [SELECT Id, Name FROM User WHERE UserName = 'phtestUser@shelltest.com' LIMIT 1];
        System.runAs(phUser){
            //Creating Country
            Country__c country_PH = RE_UtilityClass.getCountryCode('Philippines');
            
            //Creating RE_Locations
            RE_Location__c location1 = RE_UtilityClass.getLocation('PH NMIF','P11',country_PH.Name);

            //Creating RE_Product__c
            Id rePHProductRecTypeId = Schema.getGlobalDescribe().get('RE_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Philippines').getRecordTypeId();
            RE_Product__c prod_Kero = RE_TestDataFactory.createREProduct('Kerosene', country_PH.Id, rePHProductRecTypeId);
            insert prod_Kero;

            RE_Product__c prod_Gasoline = RE_TestDataFactory.createREProduct('Gasoline', country_PH.Id, rePHProductRecTypeId);
            insert prod_Gasoline;

            Id rePHDPBRecTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Philippines').getRecordTypeId();

            //Active DPB Record
            RE_Depot_Pricing_Backbone__c dpb1 = RE_TestDataFactory.createREDepotPricingBackBone(country_PH.Id, rePHDPBRecTypeId, location1.Id, prod_Kero.Id, System.today().addDays(-10), System.today().addDays(10));
            insert dpb1;

            re_Ph_TP_Management.checkDPBForDateOverlapping(prod_Kero.Id, location1.Id, System.today(),System.today().addDays(2));
            re_Ph_TP_Management.checkDPBForDateOverlapping(prod_Kero.Id, location1.Id, System.today().addDays(2),System.today().addDays(10));
            
            //Small range future DPB Record
            RE_Depot_Pricing_Backbone__c dpb1A = RE_TestDataFactory.createREDepotPricingBackBone(country_PH.Id, rePHDPBRecTypeId, location1.Id, prod_Kero.Id, System.today().addDays(15), System.today().addDays(20));
            insert dpb1A;
            
            re_Ph_TP_Management.checkDPBForDateOverlapping(prod_Kero.Id, location1.Id, System.today(),System.today().addDays(30));

            //Future DPB Record
            RE_Depot_Pricing_Backbone__c dpb2 = RE_TestDataFactory.createREDepotPricingBackBone(country_PH.Id, rePHDPBRecTypeId, location1.Id, prod_Kero.Id, System.today().addDays(30), System.today().addDays(40));
            insert dpb2;

            re_Ph_TP_Management.downloadTPRecords();
        }
    }
    
}