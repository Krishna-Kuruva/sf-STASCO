@isTest
public class RV_TriggerStagingControllerTest {
    public static testmethod void testmethod1(){
        Account acc = RV_TestDataFactory.createSoldToCustomer('ADAM OMMERT MINERALOELHANDEL', '11117474', true, true, false);
        insert acc;
        
        //Insert Account Ship To
        Account accShipTo = RV_TestDataFactory.createShipToCustomer(acc, 'ADAM OMMERT MINERALOELHANDEL', true, true, 'abc2@test.com', false, '12486077');
        insert accShipTo;
        
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Product_Catalogue__c matAgo = new Product_Catalogue__c();
        matAgo.Name = '400003805';
        matAgo.Level_0__c = 'Gasoil';
        matAgo.Commodity_Grade_L2__c = 'AGO B7';
        matAgo.Material_Name__c = 'TP AGO 10ppmS B7 UdUm Low Dose dealer DE';
        matAgo.Additive_cost_EUR_100l__c=0.1;
        matAgo.Dyeing_cost_EUR_100l__c=0.3;
        matAgo.WASA_EUR_100l__c=0.4;
        insert matAgo;
        
        
        //Insert Mrcs
        List<MRC__c> mrcList = new List<MRC__c>();
        Id RecordTypeIdMrc = Schema.SObjectType.Mrc__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        Mrc__c mrAgo= new Mrc__c();
        mrAgo.Name='000000000-100050';
        mrAgo.RecordTypeId=RecordTypeIdMrc;
        mrAgo.Sold_To__c=acc.Id;
        mrAgo.Ship_To__c=accShipTo.Id;
        mrAgo.Plant__c=insertLoc.Id;
        mrAgo.Sales_Organization__c='DE01';
        mrAgo.Handling_Type__c='EB';
        mrAgo.PO_Type__c='TSFP';
        mrAgo.Product__c=matAgo.Id;
        mrAgo.Shipping_Condition__c=10;
        mrAgo.Valid_To_Date__c=system.today().addDays(1000);
        mrAgo.Valid_From_Date__c=system.today().addDays(-100);
        mrAgo.Ship_to_Number__c = '12486077';
        insert mrAgo;
        
        List<MRC__c> mrcListqry = [Select Id,rv_MRC_Unique_Key__c from MRC__c where ID=: mrAgo.Id];
        test.startTest();
        RV_Trigger_Staging__c triggerStaging = new RV_Trigger_Staging__c();
        triggerStaging.rv_Sold_to_No__c = '11117474';
        triggerStaging.rv_Contract_Start_Date__c = '2023-01-01';
        triggerStaging.rv_Contract_End_Date__c =  '2023-12-31';
        triggerStaging.rv_Ship_to_No__c =  '12486077';
        triggerStaging.rv_Plant_GSAP__c = 'D004'; 
        triggerStaging.rv_Material__c = '400003805';
        triggerStaging.rv_External_Id__c = '1111747412486077D00440000380511220236665';
        triggerStaging.rv_Plan_Jan_month__c = '100.10';
        insert triggerStaging;
        test.stopTest();
        
    }
}