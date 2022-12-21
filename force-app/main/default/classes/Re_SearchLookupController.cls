/**************************************************************************************************
 * Class Name: Re_SearchLookupController
 * Test Class: Re_SearchLookupControllerTest
 * Object: Any sObject
 * Purpose: This is the controller for custom re-usable LWC lookup search (reSearchLookup) component
 * Author: K. Nandeeswara Raju
 * Create Date: 
 * Modify History:
 * 09-Aug-2022        n.kondur@shell.com        Created lookupRecords method
 * 29-Aug-2022        n.kondur@shell.com        Reduced the LIMIT value to 6 from 10 (BUG-#1438650)
 **************************************************************************************************/
public with sharing class Re_SearchLookupController {
    @AuraEnabled(cacheable = true)
    public static List<sObject> lookupRecords(String objectName, List<String> fields, String searchTerm, String findInField, String filterQuery){
        System.debug('objectName: ' + objectName+'; select fields: '+fields+' search term: '+searchTerm+' findInFields: '+findInField+' filterquery: '+filterQuery);
        
        String searchKeyword = String.escapeSingleQuotes(searchTerm);
        if(String.isBlank(searchKeyword)){
            String soqlQuery = 'SELECT '+String.join(fields,',')+' FROM '+objectName;
            soqlQuery += ' WHERE '+filterQuery+ ' ORDER BY LastModifiedDate DESC LIMIT 6';
            System.debug('SOQL Query: ' + soqlQuery);
            List<SObject> result = Database.query(soqlQuery);
            System.debug('count in if: ' + result.size());
            return result;
        }
        else{
            String inSearchGroup = 'ALL';
            String returningQuery = '';
            returningQuery = objectName+' ( '+String.join(fields,',');
            if(String.isEmpty(filterQuery)){
                returningQuery += ')';
            }
            else{
                returningQuery +=  ' WHERE ' + filterQuery + ')';
            }
            String query = 'FIND \'*'+searchKeyWord+'*\' IN '+inSearchGroup+' FIELDS RETURNING '+returningQuery+' LIMIT 6';
            System.debug('SOSL Query: '+query);
            List<List<sObject>> searchRecords = Search.Query(Query);
            return searchRecords.get(0);
        }
    }
}