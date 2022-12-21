/**************************************************************************************************
* Name: RV_MetadataCoverageTest
* Purpose: Test Class of Custom MetaData coverage
* Create Date: 2022-10-20
**************************************************************************************************/
@isTest
public class RV_MetadataCoverageTest {
    static testmethod void testMetadataCoverageMethod(){
        List<SObject> metadataCoverageRecords;
        Test.startTest();
                 metadataCoverageRecords = new RV_MetadataCoverage().getMetadataCoverageRecords('SELECT EMAIL_CC__c,EMAIL_TO__c,EMAIL_SUBJECT__c FROM OLF_EmailTemplate__mdt'); 
        Test.stopTest();

        
    }
    public static void setMetadata(String query, List<SObject> records){
        RV_MetadataCoverage.MetadataCoverageRecordsMap.put(query, records);
    }
}