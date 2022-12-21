public with sharing class RV_GSAPMockExternalRequestModel {

    @TestVisible private static List<SF_SAP_DataSet__x> mockedRequests = new List<SF_SAP_DataSet__x>();
    public static SF_SAP_DataSet__x findById(Id requestId) {
        List<SF_SAP_DataSet__x> requests = (!mockedRequests.isEmpty()) ? mockedRequests :[
            SELECT  id,SfHeaderShtNo__c, SfItemShtNo__c, SapSalesContNo__c,Status__c,MsgTxt__c,Action__c
            FROM SF_SAP_DataSet__x
            WHERE Id =: requestId
        ];
        return (requests.size() > 0) ? requests[0] : null;
    }
}