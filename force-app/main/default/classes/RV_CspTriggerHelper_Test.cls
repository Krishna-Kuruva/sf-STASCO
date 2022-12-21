/*****************************************************************************
@Name:  RV_CspTriggerHelper_Test     
@=========================================================================
@Purpose: Test class for RV_CspTriggerHelper
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    24-Feb-2020         INITIAL DEVELOPMENT

******************************************************************************/  
@isTest
public with sharing class RV_CspTriggerHelper_Test {

    @TestSetup
    static void testSetup(){
        //Create Sold-to customer account
        Account accSoldTo = RV_TestDataFactory.createSoldToCustomer('Test Sold-to Customer1', '12345678', true, true, true);
        insert accSoldTo;
        
        //Create Ship-to customer account
        Account accShipTo = RV_TestDataFactory.createShipToCustomer(accSoldTo, 'Test Ship-to Customer1', true, true, 'testEmail1@test.com', true, '23456789');
        insert accShipTo;
        
        //Create plant location
        Location__c loc = RV_TestDataFactory.createLocation('Ludwigshafen depot', 'D004');
        insert loc;
        
        //Create margin record
        Margin__c margin = RV_TestDataFactory.createMarginTruckITT(loc.Id, 'DE01');
        insert margin;
        
        //Create Customer Specific Pricing
        List<Customer_Specific_Pricing__c> cspList = new List<Customer_Specific_Pricing__c>();
        Customer_Specific_Pricing__c csp1 = RV_TestDataFactory.createCsp(accSoldTo.Id, loc.Id, 'AGO B7', 3.4, 'DE01', 'ATP1');
        cspList.add(csp1);
        Customer_Specific_Pricing__c csp2 = RV_TestDataFactory.createCsp(accSoldTo.Id, loc.Id, 'ULG95 E5', 3.5, 'DE01', 'ATP1');
        cspList.add(csp2);
        Customer_Specific_Pricing__c csp3 = RV_TestDataFactory.createCsp(accSoldTo.Id, loc.Id, 'IGO 50ppm', 3.6, 'DE01', 'ATP1');
        cspList.add(csp3);
        insert cspList;
    }

    @isTest
    static void testValidateCspOnInsertNegative(){
        Account acc = [SELECT Id FROM Account WHERE Rv_Olf_Customer_Email__c = 'testEmail1@test.com' AND 
                                                    Customer_Type__c = 'Ship To' LIMIT 1];
        Location__c loc = [SELECT Id FROM Location__c WHERE Name = 'Ludwigshafen depot' AND 
                                                            Plant_Code__c = 'D004' LIMIT 1];
        Margin__c margin = [SELECT Id FROM Margin__c WHERE Plant__c =: loc.Id AND
                                                           Sales_Org__c = 'DE01' LIMIT 1];
        List<Customer_Specific_Pricing__c> cspList = new List<Customer_Specific_Pricing__c>();
        Customer_Specific_Pricing__c csp1 = RV_TestDataFactory.createCsp(acc.Id, loc.Id, 'AGO B7', -13.4, 'DE01', 'ATP1');
        cspList.add(csp1);
        Customer_Specific_Pricing__c csp2 = RV_TestDataFactory.createCsp(acc.Id, loc.Id, 'ULG95 E5', -13.5, 'DE01', 'ATP1');
        cspList.add(csp2);
        Customer_Specific_Pricing__c csp3 = RV_TestDataFactory.createCsp(acc.Id, loc.Id, 'IGO 50ppm', -13.6, 'DE01', 'ATP1');
        cspList.add(csp3);
        Test.startTest(); 
        try{
            insert cspList;
        }
        catch(Exception e){
            System.assertEquals(true, ApexPages.hasMessages());
        }
        Test.stopTest();             
    }
    
    @isTest
    static void testValidateCspOnUpdatePositive(){
        Account acc = [SELECT Id FROM Account WHERE Rv_Olf_Customer_Email__c = 'testEmail1@test.com' AND 
                                                    Customer_Type__c = 'Ship To' LIMIT 1];
        Location__c loc = [SELECT Id FROM Location__c WHERE Name = 'Ludwigshafen depot' AND 
                                                            Plant_Code__c = 'D004' LIMIT 1];
        Margin__c margin = [SELECT Id FROM Margin__c WHERE Plant__c =: loc.Id AND
                                                           Sales_Org__c = 'DE01' LIMIT 1];
        List<Customer_Specific_Pricing__c> cspList = [SELECT Id,
                                                     		 Grade__c,
                                                     		 CSP_Eur_100L__c FROM Customer_Specific_Pricing__c LIMIT 10];
        Decimal i = 3.4;
        for(Customer_Specific_Pricing__c csp : cspList){
            csp.CSP_Eur_100L__c = i;
            i++;
        }
        Test.startTest();
        update cspList;
        Test.stopTest();             
    }
    
    @isTest
    static void testValidateCspOnUpdateNegative(){
        Account acc = [SELECT Id FROM Account WHERE Rv_Olf_Customer_Email__c = 'testEmail1@test.com' AND 
                                                    Customer_Type__c = 'Ship To' LIMIT 1];
        Location__c loc = [SELECT Id FROM Location__c WHERE Name = 'Ludwigshafen depot' AND 
                                                            Plant_Code__c = 'D004' LIMIT 1];
        Margin__c margin = [SELECT Id FROM Margin__c WHERE Plant__c =: loc.Id AND
                                                           Sales_Org__c = 'DE01' LIMIT 1];
        List<Customer_Specific_Pricing__c> cspList = [SELECT Id,
                                                     		 Grade__c,
                                                     		 CSP_Eur_100L__c FROM Customer_Specific_Pricing__c LIMIT 10];
        Decimal i = -16.4;
        for(Customer_Specific_Pricing__c csp : cspList){
            csp.CSP_Eur_100L__c = i;
            i--;
        }
        Test.startTest(); 
        try{
            update cspList;
        }
        catch(Exception e){
            System.assertEquals(true, ApexPages.hasMessages());
        }
        Test.stopTest();             
    }
}