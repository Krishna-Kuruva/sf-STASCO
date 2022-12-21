@isTest
public class RE_Depot_Based_Costing_TriggerHelperTest { 
    public static testmethod void testUtility()
    {
        //Country Data 
        Country__c country = new Country__c(Name='Malaysia');
        insert country;
        
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn =  new RE_Location__c(Name='Labuan',RE_Location_Code__c='LB',RE_Country__c = country.id);
        RE_Location__c loctn1 = new RE_Location__c(Name='Bagan Luar',RE_Location_Code__c='BK',RE_Country__c = country.id);
        location.add(loctn);
        location.add(loctn1);
        insert location;
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product = new RE_Product__c(Name='Gasoil B7 0.05% S',RE_Country__c= country.Id);
        RE_Product__c product1 = new RE_Product__c(Name='MOGAS 95',RE_Country__c= country.Id);
        RE_Product__c product2 = new RE_Product__c(Name='MOGAS 97',RE_Country__c= country.Id);
        prod.add(product);
        prod.add(product1);
        prod.add(product2);
        insert prod;
        
        //RE_Depot_Pricing_Backbone__c data
        List<RE_Depot_Pricing_Backbone__c> dpbLst = new  List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dpb1 = new  RE_Depot_Pricing_Backbone__c(RE_Country__c = country.Id,RE_Product_Name__c = prod[1].Id, RE_Depot_Name__c = location[0].Id,RE_Spot_Price_Adjustment__c= 2.23,RE_Target_Margin__c = 3.1,RE_Valid_From__c = System.Today(), RE_Valid_To__c = System.Today());  
        RE_Depot_Pricing_Backbone__c dpb2 = new  RE_Depot_Pricing_Backbone__c(RE_Country__c = country.Id,RE_Product_Name__c = prod[0].Id, RE_Depot_Name__c = location[1].Id,RE_Spot_Price_Adjustment__c= 1.23,RE_Target_Margin__c = 4.1,RE_Valid_From__c = System.Today(), RE_Valid_To__c = System.Today()); 
        dpbLst.add(dpb1);
        dpbLst.add(dpb2);
        insert dpbLst;
        
        //RE_MOA__c data
        List<RE_MOA__c> moaList = new List<RE_MOA__c>();
        RE_MOA__c moaData1 = new RE_MOA__c(RE_Depot_Name__c = location[0].Id, RE_Product__c = prod[1].Id, RE_IsLatest__c = True,RE_Today_s_BSP__c=3.45,RE_Remark__c='abc');
        RE_MOA__c moaData2 = new RE_MOA__c(RE_Depot_Name__c = location[1].Id, RE_Product__c = prod[0].Id, RE_IsLatest__c = True,RE_Today_s_BSP__c=7.45,RE_Remark__c='mbc');
        moaList.add(moaData1);
        moaList.add(moaData2);
        
        //Depot based costing data
        List<RE_Depot_Based_Costing__c> dpcLst = new  List<RE_Depot_Based_Costing__c>();
        RE_Depot_Based_Costing__c dpc1 = new  RE_Depot_Based_Costing__c(RE_HCV_Value__c= 24.45,RE_Bio_Value__c=16.73,RE_S_N_H_Cost__c= 33.26 ,RE_Spot_Price_Adjustment__c= 45.21 ,RE_Sales_Tax__c= 26.34 ,RE_Weighted_Avg__c= 12.64,RE_Comments__c='mno',RE_Depot_Pricing_Backbone__c= dpbLst[0].id,RE_IsLatest__c = True);  
        RE_Depot_Based_Costing__c dpc2 = new  RE_Depot_Based_Costing__c(RE_Comments__c='mps',RE_HCV_Value__c= 42.45,RE_Bio_Value__c=21.78,RE_S_N_H_Cost__c= 38.26 ,RE_Spot_Price_Adjustment__c= 24.27 ,RE_Sales_Tax__c= 35.21 ,RE_Weighted_Avg__c= 26.64,RE_Depot_Pricing_Backbone__c= dpbLst[1].id,RE_IsLatest__c = True);                                                                             
        dpcLst.add(dpc1);
        dpcLst.add(dpc2);
              
        Test.startTest();
        insert moaList;
        insert dpcLst;
        //System.debug('moaList@@@'+moaList);
        Test.stopTest();
    }
}