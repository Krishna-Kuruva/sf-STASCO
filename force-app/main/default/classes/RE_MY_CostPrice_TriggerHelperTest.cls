@isTest  
public class RE_MY_CostPrice_TriggerHelperTest {    
    public static testmethod void testUtility()
    {
              //Country Data
		List<Country__c> count = new List<Country__c>();
        Country__c country1 = new Country__c(Name='Malaysia');
		Country__c country2 = new Country__c(Name='Thailand');
        count.add(country1);
		count.add(country2);
        insert count;
        
        //Location Data
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn =  new RE_Location__c(Name='Labuan',RE_Location_Code__c='LB',RE_Country__c = count[0].id);
        RE_Location__c loctn1 = new RE_Location__c(Name='Bagan Luar',RE_Location_Code__c='BK',RE_Country__c = count[0].id);
		RE_Location__c loctn2 = new RE_Location__c(Name='Chongnonsri',RE_Location_Code__c='CNS',RE_Country__c = count[1].id);
        location.add(loctn);
        location.add(loctn1);
		location.add(loctn2);
        insert location;
        
        //Product Data
        List<RE_Product__c> prod = new List<RE_Product__c>();
        RE_Product__c product = new RE_Product__c(Name='Gasoil B7 0.05% S',RE_Country__c= country1.Id);
        RE_Product__c product1 = new RE_Product__c(Name='MOGAS 95',RE_Country__c= country1.Id);
        RE_Product__c product2 = new RE_Product__c(Name='MOGAS 97',RE_Country__c= country1.Id);
		RE_Product__c product3 = new RE_Product__c(Name='Kerosene',RE_Country__c= country2.Id);
        prod.add(product);
        prod.add(product1);
        prod.add(product2);
		prod.add(product3);
        insert prod;
        
        //MY_Cost_Price data creation
        List<RE_MY_CostPrice__c> mycostList = new List<RE_MY_CostPrice__c>();
        String rtId1 = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
		String rtId2 = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId();
        RE_MY_CostPrice__c mycostdata1  = new RE_MY_CostPrice__c(recordtypeid= rtId1,RE_Depot_Name__c= location[0].Id, RE_Product_Name__c= prod[1].Id, RE_IsLatest__c= True,RE_Costprice_Marginal_Cost__c=3.414, RE_Country__c= country1.Id);
        RE_MY_CostPrice__c mycostdata2  = new RE_MY_CostPrice__c(recordtypeid= rtId1,RE_Depot_Name__c= location[1].Id, RE_Product_Name__c= prod[0].Id, RE_IsLatest__c= True,RE_Costprice_Marginal_Cost__c=7.414, RE_Country__c= country1.Id);
		RE_MY_CostPrice__c mycostdata3  = new RE_MY_CostPrice__c(recordtypeid= rtId2,RE_Depot_Name__c= location[2].Id, RE_Product_Name__c= prod[0].Id, RE_IsLatest__c= True,RE_Costprice_Laid_Down_Cost__c= 8.4,RE_Costprice_Marginal_Cost__c=7.414, RE_Country__c= country2.Id);
        mycostList.add(mycostdata1);
        mycostList.add(mycostdata2);
		mycostList.add(mycostdata3);
        //System.debug('mycostList@@--'+ mycostList);
        
        
        //RE_MOA__c data
        List<RE_MOA__c> moaList = new List<RE_MOA__c>();
		String rtId3 = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
		String rtId4 = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByName().get('Thailand').getRecordTypeId();
        RE_MOA__c moaData1 = new RE_MOA__c(RE_Depot_Name__c = location[0].Id, RE_Product__c = prod[1].id, RE_IsLatest__c = True,RE_Today_s_BSP__c=23.2,RE_Remark__c='abc',recordtypeid= rtId3);
        RE_MOA__c moaData2 = new RE_MOA__c(RE_Depot_Name__c = location[1].Id, RE_Product__c =prod[0].Id, RE_IsLatest__c = True,RE_Today_s_BSP__c=26.4,RE_Remark__c='xyz',recordtypeid= rtId3);
		RE_MOA__c moaData3 = new RE_MOA__c(RE_Depot_Name__c = location[2].Id, RE_Product__c =prod[2].Id, RE_IsLatest__c = True,RE_Today_s_BSP__c=26.4,RE_Remark__c='xyz',recordtypeid= rtId4);
        moaList.add(moaData1);
        moaList.add(moaData2);
		moaList.add(moaData3);
        System.debug('moaList@@--'+ moaList);   
        //Test.setCreatedDate(moaData1.id,System.today());
        //Test.setCreatedDate(moaData2.id,System.today());
        
        
        //RE_Depot_Pricing_Backbone__c data
        List<RE_Depot_Pricing_Backbone__c> dpbLst = new  List<RE_Depot_Pricing_Backbone__c>();
        RE_Depot_Pricing_Backbone__c dpb1 = new  RE_Depot_Pricing_Backbone__c(RE_Country__c = country1.Id,RE_Product_Name__c = prod[1].Id, RE_Depot_Name__c = location[0].Id,RE_Spot_Price_Adjustment__c= 2.23,RE_Target_Margin__c = 3.1,RE_Valid_From__c = System.Today(), RE_Valid_To__c = System.Today());  
        RE_Depot_Pricing_Backbone__c dpb2 = new  RE_Depot_Pricing_Backbone__c(RE_Country__c = country1.Id,RE_Product_Name__c = prod[0].id, RE_Depot_Name__c = location[1].Id,RE_Spot_Price_Adjustment__c= 1.23,RE_Target_Margin__c = 4.1,RE_Valid_From__c = System.Today(), RE_Valid_To__c = System.Today()); 
		RE_Depot_Pricing_Backbone__c dpb3 = new  RE_Depot_Pricing_Backbone__c(RE_Country__c = country2.Id,RE_Product_Name__c = prod[2].id, RE_Depot_Name__c = location[2].Id,RE_Spot_Price_Adjustment__c= 1.23,RE_Target_Margin__c = 4.1,RE_Valid_From__c = System.Today(), RE_Valid_To__c = System.Today()); 
        dpbLst.add(dpb1);
        dpbLst.add(dpb2);
		dpbLst.add(dpb3);
        //System.debug('dpbLst@@--'+ dpbLst);
        
        
        //RE_Midday_Pricing__c data  
        List<RE_Midday_Pricing__c> middaybLst = new  List<RE_Midday_Pricing__c>();
        RE_Midday_Pricing__c md1 = new  RE_Midday_Pricing__c(RE_Product_Name__c = prod[1].id,RE_Depot_Name__c = location[0].Id, RE_Shell_Price__c = 22.43,RE_IsLatest__c = True);  
        RE_Midday_Pricing__c md2 = new  RE_Midday_Pricing__c(RE_Product_Name__c = prod[0].id, RE_Depot_Name__c = location[1].Id, RE_Shell_Price__c = 28.73,RE_IsLatest__c = True); 
        middaybLst.add(md1);
        middaybLst.add(md2);
                                                                                  
        //Afternoon indication
        RE_Midday_Pricing__c AftIndication = new RE_Midday_Pricing__c();
        AftIndication.RE_Product__c = 'E5 GO B7';
        AftIndication.RE_Midday_Forecast_Price__c = 0.8;
        insert AftIndication;
        
        Test.startTest();
        insert dpbLst;
        insert middaybLst;
        insert mycostList;
        Test.stopTest();   
        
    }
    
}