//AdditionalTestCoverage_12Jun2019_Soumyajit starts
@isTest
public class RV_DIDashnoardProductDiffBatchTest {
    @testSetup 
    static void setupData() 
    {
        Reuters_Quotes__c objGELT = new Reuters_Quotes__c();
        objGELT.Quote_Name__c='Brent Crude';
        objGELT.Quote_Display_Name__c ='Brent Crude';
        objGELT.CurrencyCode__c ='EUR';
        objGELT.Price__c = 21.23;
        objGELT.Unit_Of_Measure__c = 'T';
        insert objGELT;
    }
    
    @isTest
    static void doTest()
    {
        Test.startTest();
        RV_DIDashnoardProductDiffBatch obj = new RV_DIDashnoardProductDiffBatch();
        Database.executeBatch(obj);
        Test.stopTest();
    }
}
//AdditionalTestCoverage_12Jun2019_Soumyajit ends