public with sharing class RV_SearchLookupController{

    public RV_SearchLookupController(){

    }

    @AuraEnabled(cacheable = true)
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm, String findInField, String filterQuery){
        String searchKeyword = searchTerm + '*';
        String inSearchGroup;
        String returningQuery = '';
        if(!String.isEmpty(findInField))
            inSearchGroup = findInField;
        else
            inSearchGroup = 'ALL';
        returningQuery = objectName+' ( Id, '+String.join(fields,',');
        if(String.isEmpty(filterQuery))
            returningQuery += ')';
        else
            returningQuery +=  ' WHERE ' + filterQuery + ')';
        String query = 'FIND :searchKeyword IN ' + inSearchGroup + ' FIELDS RETURNING '+returningQuery+' LIMIT 2000';
        System.debug('Query: '+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        return searchRecords.get(0);
    }
}