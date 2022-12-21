@isTest
public class RE_MYCostPrice_Covamo_TriggerHelperTest {	  
    public static testmethod void testUtility()
    {
        Country__c country1 = new Country__c(Name='Malaysia');
        insert country1;
        
        List<RE_Location__c> location = new List<RE_Location__c>();
        RE_Location__c loctn =  new RE_Location__c(Name='Labuan',RE_Location_Code__c='LB',RE_Country__c = country1.id);
        RE_Location__c loctn1 = new RE_Location__c(Name='Bagan Luar',RE_Location_Code__c='BK',RE_Country__c = country1.id);
        location.add(loctn);
        location.add(loctn1);
        
        insert location;
        RE_Product__c product = new RE_Product__c(Name='Kerosene',RE_Country__c= country1.Id);
        insert product;
        String rtId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Covamo Malaysia').getRecordTypeId();
        System.debug('rtId---- '+rtId);
        String rtId1 = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByName().get('Malaysia').getRecordTypeId();
        System.debug('rtId1---- '+rtId1);
        RE_MY_CostPrice__c cpDataCBU  = new RE_MY_CostPrice__c(RE_Depot_Name__c= location[0].Id, RE_Product_Name__c= product.Id,RE_Costprice_Marginal_Cost__c=3.414, RE_Country__c= country1.Id, recordtypeid= rtId1);
    	insert cpDataCBU;
        
        List<RE_MY_CostPrice__c> cpDataList = new List<RE_MY_CostPrice__c>();
        RE_MY_CostPrice__c cpDataCovamo  = new RE_MY_CostPrice__c(RE_Depot_Name__c= location[0].Id, RE_Product_Name__c= product.Id, RE_Country__c= country1.Id, recordtypeid= rtId, Master_Covamo__c= true);
        RE_MY_CostPrice__c cpDataCovamo1  = new RE_MY_CostPrice__c(RE_Depot_Name__c= location[1].Id, RE_Product_Name__c= product.Id, RE_Country__c= country1.Id, recordtypeid= rtId, Master_Covamo__c= false);
    	cpDataList.add(cpDataCovamo);
        cpDataList.add(cpDataCovamo1);
        
        Test.startTest();
        insert cpDataList;
        Test.stopTest();   
    }
}