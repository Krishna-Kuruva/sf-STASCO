@isTest 
public class RV_RoutesInvalidEmailBatchTest {

    static testMethod void routesInvalidEmailBatchStartTest() 
    {
        List<Freight_Rate__c> lstFrightRateRec= new List<Freight_Rate__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Freight_Rate__c objFR = new Freight_Rate__c();
            objFR.Valid_To__c = System.today().addDays(7);
            lstFrightRateRec.add(objFR);
        }
        
        insert lstFrightRateRec;
        Test.startTest();

            RV_RoutesInvalidEmailBatch obj = new RV_RoutesInvalidEmailBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    } 
}