//AdditionalTestCoverage_12Jun2019_Soumyajit starts
@isTest
public class RV_MarginTriggerHelperTest {

    @TestSetup
    public static void setupData()
    {
        Location__c insertLoc = new Location__c();
        insertLoc = RV_TestHelper.insertLocation(insertLoc);
        insert insertLoc;
        
        Id RecordTypeIdMarginTruck = Schema.SObjectType.Margin__c.getRecordTypeInfosByName().get('Truck/ITT').getRecordTypeId();  
        Margin__c mgn = new Margin__c();
		mgn=RV_TestHelperPhase2.insertMargin(mgn,insertLoc,RecordTypeIdMarginTruck);
        insert mgn;
    }
 
    @isTest
    static void doTest()
    {
        List<Margin__c> onBeforeNewLst = [select id,Valid_From__c,Valid_To__c,SalesOrgPlantCodeMot__c from Margin__c];
        
        List<Margin__c> onUpdLst = onBeforeNewLst;
        for(Margin__c m:onUpdLst)
        {
            m.Valid_From__c = system.today().addDays(1);
            m.Valid_To__c=system.today().addDays(12);
        }
        update onUpdLst;
        
        Map<String,List<Margin__c>> mapOfInsertedMargin = new Map<String,List<Margin__c>>();
        mapOfInsertedMargin = RV_MarginTriggerHelper.createMap(onUpdLst);
        RV_MarginTriggerHelper.validationRule(onBeforeNewLst,mapOfInsertedMargin);
    }
}
//AdditionalTestCoverage_12Jun2019_Soumyajit ends