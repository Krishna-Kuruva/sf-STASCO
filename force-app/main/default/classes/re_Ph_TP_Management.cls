/**************************************************************************************************
* Class Name: re_Ph_TP_Management
* Test Class: re_Ph_TP_Management_Test
* Object	: RE_Depot_Pricing_Backbone__c
* Purpose	: This is used as the controller for TP Management screen for Philippines
* Author	: Nandeeswara Raju Kondur (n.kondur@shell.com)
* Create Date: 09-Aug-2022
* Modify History:
* 09-Aug-2022        K.Nandeeswara Raju        Created
* 13-Oct-2022        K.Nandeeswara Raju        Added checkForActiveCombination method
* 13-Oct-2022        K.Nandeeswara Raju        Modified checkProductDepotCombination method to re-usable select query
* 19-Oct-2022        K.Nandeeswara Raju        Modified checkProductDepotCombination method
**************************************************************************************************/
public inherited sharing class re_Ph_TP_Management {
    
    
    @AuraEnabled(cacheable=true)
    public static ProductDepotWrapper checkProductDepotCombination(Id productId, Id locationId){
        ProductDepotWrapper wrapper = new ProductDepotWrapper();
        wrapper.dpbRecords  = new List<RE_Depot_Pricing_Backbone__c> ();
        wrapper.recordCount = 0;
        Id rePHRecordTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Philippines').getRecordTypeId();
        if(Schema.SObjectType.RE_Depot_Pricing_Backbone__c.isAccessible()){
            String queryStrSelect = 'SELECT Id, Name, RE_PH_Blend_Percentage__c, RE_Product_Name__c, RE_Depot_Name__c, RE_TH_HCV_Quote1_Percent__c, RE_TH_HCV_Quote1__c,'+
                'RE_PH_Premium__c, RE_Fixed_Premium__c, RE_PH_Freight_Conversion_Factor__c, RE_PH_Freight_Quote__c, RE_PH_Freight_Charges__c, RE_PH_Bio_Percent__c,'+
                'RE_PH_BIO_1__c, RE_PH_BIO_2__c, RE_PH_BIO_3__c, RE_PH_BIO_Fixed__c, RE_PH_BIO_Fixed_Unit__c, RE_Primary_Transport_Cost__c, RE_PH_Small_Lot__c, RE_PH_Demurrage__c, '+
                'RE_PH_FLC_Service_Fee__c, RE_PH_Terminal_Cost__c, RE_PH_Wharfage_Cost__c, RE_PH_Fuel_Marking_Factor__c, RE_PH_MISC_Fuel_Marking_Fee__c, RE_PH_Ocean_Cost__c,'+
                'RE_Valid_From__c, RE_PH_S_H__c, RE_Snh_Cost__c, RE_PH_PT_Percentage__c, RE_Insurance_Percentage__c, RE_Valid_To__c,RE_Final_Price_Unit__c,'+
                'RE_Fixed_Premium_Unit__c, RE_PH_MISC_Hosehandling_Cost__c, RE_PH_MISC_Hosehandling_Cost_Unit__c, RE_PH_MISC_PQ_Cost__c, RE_PH_MISC_PQ_Cost_Unit__c,'+
                'RE_PH_MISC_Brokerage_Fee__c, RE_PH_MISC_Brokerage_Fee_Unit__c, RE_PH_MISC_Port_Charges__c, RE_PH_MISC_Port_Charges_Unit__c, RE_PH_Wharfage_Cost_Unit__c,'+
                'RE_PH_MISC_Fuel_Marking_Fee_Unit__c, RE_PH_MISC_Shifting_Cost__c, RE_PH_MISC_Shifting_Cost_Unit__c, RE_PH_MISC_Waterfront_Operations_Cost__c, RE_PH_Waterfront_Operations_Cost_Unit__c,'+
                'RE_PH_Demurrage_Unit__c, RE_PH_FLC_Service_Fee_Unit__c, RE_PH_Freight_Charges_Unit__c, CreatedDate '+
                'FROM RE_Depot_Pricing_Backbone__c ';
            String queryStrWhere = 'WHERE RecordType.Id =: rePHRecordTypeId and RE_Product_Name__c =: productId and RE_Depot_Name__c =: locationId ';
            String queryStrWhereActiveDate  = 'and RE_Valid_From__c <= TODAY and RE_Valid_To__c >= TODAY ';
            String queryStrWhereInactivePast= 'and RE_Valid_From__c <= TODAY and RE_Valid_To__c <= TODAY ';
            String queryStrOrderByAndLimit  = 'WITH SECURITY_ENFORCED ORDER BY RE_Valid_To__c DESC LIMIT 1';
            
            List<RE_Depot_Pricing_Backbone__c> lstOfActiveDPBRecords = Database.query(queryStrSelect + queryStrWhere + queryStrWhereActiveDate + queryStrOrderByAndLimit);
            //For Case #1: If the active record is found
            if(!lstOfActiveDPBRecords.isEmpty()){
                wrapper.dpbRecords = lstOfActiveDPBRecords;
                wrapper.recordCount= lstOfActiveDPBRecords.size();
            }
            
            //For Case #2: If the active record is not found, then we are fetching the latest record from the records there were active in past
            if(lstOfActiveDPBRecords.isEmpty()){
                List<RE_Depot_Pricing_Backbone__c> lstOfPastDPBRecords  = Database.query(queryStrSelect + queryStrWhere + queryStrWhereInactivePast + queryStrOrderByAndLimit);
                wrapper.dpbRecords = lstOfPastDPBRecords;
                wrapper.recordCount= lstOfPastDPBRecords.size();
            }
            
            List<String> rePHPermSets = new List<String> {'RE_PH_Pricing_Desk'};
                List<PermissionSetAssignment> userPermSets = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
                                                              FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId() AND PermissionSet.Name IN : rePHPermSets LIMIT 50];
            wrapper.userHasAccess = (!userPermSets.isEmpty()) ? true : false;
        }
        return wrapper;
    }
    
    
    @AuraEnabled(cacheable = true)
    public static Id getRecordTypeId(String objectName, String recordTypeDevName){
        try {
            Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
            return recordTypeId;
        } catch (Exception e) {
            System.debug('Error occured in getRecordTypeId: '+e.getMessage());
            return null;
        }
    }
    
    //Description : When the user selects Location and Product in the TP Management Screen, we need to check if there's an active Location
    //and Product combination (Depot Pricing Backbone) exists or not.
    @AuraEnabled(cacheable = true)
    public static ProductDepotWrapper checkForActiveCombination(Id productId, Id locationId){
        Id rePHRecordTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Philippines').getRecordTypeId();
        ProductDepotWrapper wrapper = new ProductDepotWrapper ();
        List<RE_Depot_Pricing_Backbone__c> lstOfDBPRecords = [SELECT Id, Name, RE_Product_Name__r.Name, RE_Depot_Name__r.Name, RE_Valid_From__c, RE_Valid_To__c 
                                                              FROM RE_Depot_Pricing_Backbone__c 
                                                              WHERE RecordType.Id =: rePHRecordTypeId and RE_Product_Name__c =: productId and RE_Depot_Name__c =: locationId 
                                                              and RE_Valid_From__c <= TODAY and RE_Valid_To__c >= TODAY
                                                              ORDER BY RE_Valid_To__c DESC
                                                              LIMIT 10];
        if(!lstOfDBPRecords.isEmpty()){
            wrapper.dpbRecords  = lstOfDBPRecords;
            wrapper.recordCount = lstOfDBPRecords.size();
        }
        else{
            wrapper.dpbRecords  = new List<RE_Depot_Pricing_Backbone__c> ();
            wrapper.recordCount = 0;
        }
        return wrapper;
    }
    
    // Description: When the user tries to Create/Clone/Update a Depot Pricing Backbone record, we need to check if there's any overlapping
    // Valid From and Valid To dates. So that we can avoid creating multiple DPB records for same period of time.
    @AuraEnabled
    public static ProductDepotWrapper checkDPBForDateOverlapping(Id productId, Id locationId, Date validFromDate, Date validToDate){
        System.debug('productId: '+productId+', locationId: '+locationId+', validFromDate: '+validFromDate+', validToDate: '+validToDate);
        Id rePHRecordTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Philippines').getRecordTypeId();
        ProductDepotWrapper wrapper = new ProductDepotWrapper();
        Map<Id,RE_Depot_Pricing_Backbone__c> mapOfAllOverlappingRecs = new Map<Id,RE_Depot_Pricing_Backbone__c> ();
        //Check for overlapping dates based on validFromDate
        List<RE_Depot_Pricing_Backbone__c> validFromIncludedRecords = [SELECT Id, Name, RE_Product_Name__r.Name, RE_Depot_Name__r.Name, RE_Valid_From__c, RE_Valid_To__c 
                                                                       FROM RE_Depot_Pricing_Backbone__c 
                                                                       WHERE RecordType.Id =: rePHRecordTypeId and RE_Product_Name__c =: productId and RE_Depot_Name__c =: locationId 
                                                                       and RE_Valid_From__c <=: validFromDate and RE_Valid_To__c >=: validFromDate
                                                                       ORDER BY RE_Valid_To__c DESC LIMIT 1];
        
        //Check for overlapping dates based on validToDate
        List<RE_Depot_Pricing_Backbone__c> validToIncludedRecords = [SELECT Id, Name, RE_Product_Name__r.Name, RE_Depot_Name__r.Name, RE_Valid_From__c, RE_Valid_To__c 
                                                                     FROM RE_Depot_Pricing_Backbone__c 
                                                                     WHERE RecordType.Id =: rePHRecordTypeId and RE_Product_Name__c =: productId and RE_Depot_Name__c =: locationId 
                                                                     and RE_Valid_From__c <=: validToDate and RE_Valid_To__c >=: validToDate
                                                                     ORDER BY RE_Valid_To__c DESC LIMIT 1];
        
        //Check for small but full overlapping range
        //Ex: Today = 02-Nov-2022
        //Already existing from 16-Nov-2022 to 20-Nov-2022
        //New record request from 02-Nov-2022 to 31-Dec-2022
        List<RE_Depot_Pricing_Backbone__c> smallDateRangeInFutureIncludingFromDate = [SELECT Id, Name, RE_Product_Name__r.Name, RE_Depot_Name__r.Name, RE_Valid_From__c, RE_Valid_To__c 
                                                                                      FROM RE_Depot_Pricing_Backbone__c 
                                                                                      WHERE RecordType.Id =: rePHRecordTypeId and RE_Product_Name__c =: productId and RE_Depot_Name__c =: locationId 
                                                                                      and ((RE_Valid_From__c >=: validFromDate and RE_Valid_From__c <=: validToDate) OR (RE_Valid_From__c =: validFromDate and RE_Valid_To__c =: validToDate)) 
                                                                                      ORDER BY RE_Valid_To__c DESC LIMIT 1];
        
        if(validFromIncludedRecords?.size() > 0){
            mapOfAllOverlappingRecs.putAll(validFromIncludedRecords);
            System.debug('match 1: '+validFromIncludedRecords?.size());
        }
        if(validToIncludedRecords?.size() > 0){
            mapOfAllOverlappingRecs.putAll(validToIncludedRecords);
            System.debug('match 2: '+validToIncludedRecords?.size());
        }
        if(smallDateRangeInFutureIncludingFromDate?.size() > 0){
            mapOfAllOverlappingRecs.putAll(smallDateRangeInFutureIncludingFromDate);
            System.debug('match 3: '+smallDateRangeInFutureIncludingFromDate?.size());
        }
        
        if(!mapOfAllOverlappingRecs?.isEmpty()){
            wrapper.dpbRecords  = mapOfAllOverlappingRecs.values();
            wrapper.recordCount = wrapper.dpbRecords.size();
        }
        return wrapper;
    }
    
    // Description: This method helps us to fetch the records when user clicks on Download TP Records button in TP Management screen
    // We are trying to download Active and Future records AS OF TODAY and will be put in two sheets of same excel sheet.
    @AuraEnabled
    public static DownloadTPRecordsWrapper downloadTPRecords(){
        Id rePHRecordTypeId = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Philippines').getRecordTypeId();
        DownloadTPRecordsWrapper wrapper = new DownloadTPRecordsWrapper();
        String queryStrSelect = 'SELECT Name,RE_Product_Name__c,RE_Product_Name__r.Name,RE_Depot_Name__c,RE_Depot_Name__r.Name,RE_PH_Blend_Percentage__c,RE_TH_HCV_Quote1_Percent__c,RE_TH_HCV_Quote1__c,RE_PH_Premium__c,RE_Fixed_Premium__c,RE_Fixed_Premium_Unit__c,'+
            'RE_PH_Freight_Conversion_Factor__c,RE_PH_Freight_Quote__c,RE_PH_Freight_Charges__c,RE_PH_Freight_Charges_Unit__c,RE_PH_Bio_Percent__c,RE_PH_BIO_1__c,RE_PH_BIO_2__c,'+
            'RE_PH_BIO_3__c,RE_PH_BIO_Fixed__c,RE_PH_BIO_Fixed_Unit__c,RE_Primary_Transport_Cost__c,RE_Primary_Transport_Unit__c,RE_PH_Small_Lot__c,RE_PH_Demurrage__c,RE_PH_Demurrage_Unit__c,'+
            'RE_PH_FLC_Service_Fee__c,RE_PH_FLC_Service_Fee_Unit__c,RE_PH_Terminal_Cost__c,RE_PH_Wharfage_Cost__c,RE_PH_Wharfage_Cost_Unit__c,RE_PH_Fuel_Marking_Factor__c,RE_PH_MISC_Fuel_Marking_Fee__c,'+
            'RE_PH_MISC_Fuel_Marking_Fee_Unit__c,RE_PH_Ocean_Cost__c,RE_PH_S_H__c,RE_PH_PT_Percentage__c,RE_Insurance_Percentage__c,RE_Snh_Cost__c,RE_SnH_Unit__c,RE_Valid_From__c,RE_Valid_To__c,'+
            'RE_PH_MISC_Hosehandling_Cost__c,RE_PH_MISC_Hosehandling_Cost_Unit__c,RE_PH_MISC_Shifting_Cost__c,RE_PH_MISC_Shifting_Cost_Unit__c,RE_PH_MISC_PQ_Cost__c,RE_PH_MISC_PQ_Cost_Unit__c,'+
            'RE_PH_MISC_Waterfront_Operations_Cost__c,RE_PH_Waterfront_Operations_Cost_Unit__c,RE_PH_MISC_Brokerage_Fee__c,RE_PH_MISC_Brokerage_Fee_Unit__c,RE_PH_MISC_Port_Charges__c,RE_PH_MISC_Port_Charges_Unit__c '+
            'FROM RE_Depot_Pricing_Backbone__c WHERE RecordType.Id =: rePHRecordTypeId ';
        String currentActiveCondition   = 'and RE_Valid_From__c <= TODAY and RE_Valid_To__c >= TODAY ORDER BY RE_Valid_From__c ASC LIMIT 50000';
        String futureActiveCondition    = 'and RE_Valid_From__c > TODAY ORDER BY RE_Valid_From__c ASC LIMIT 50000';
        
        List<RE_Depot_Pricing_Backbone__c> activeRecords = Database.query(queryStrSelect + currentActiveCondition);
        List<RE_Depot_Pricing_Backbone__c> futureRecords = Database.query(queryStrSelect + futureActiveCondition);
        
        wrapper.currentActiveRecords    = activeRecords?.isEmpty() ? new List<RE_Depot_Pricing_Backbone__c> () : activeRecords;
        wrapper.futureActiveRecords     = futureRecords?.isEmpty() ? new List<RE_Depot_Pricing_Backbone__c> () : futureRecords;
        String currentTime = String.valueOf(System.now());
        currentTime = currentTime.replaceAll('[-: ]','_');
        wrapper.messageToReturn = 'PH_TP_Records_'+currentTime;//Using to send file name
        
        Map<String,String> mapOfLabelByAPIName = new Map<String,String>();
        Map<String, Schema.SObjectField> schemaMap = Schema.getGlobalDescribe().get('RE_Depot_Pricing_Backbone__c').getDescribe().fields.getMap();
        
        for (String fieldName: schemaMap.keySet()) {
            mapOfLabelByAPIName.put(fieldName,schemaMap.get(fieldName).getDescribe().getLabel());
        }
        wrapper.mapOfFieldLabelByAPIName = mapOfLabelByAPIName;
        return wrapper;
    }
    
    
    //Wrapper Class for easy return of data to requestor
    public class ProductDepotWrapper{
        @AuraEnabled
        public Integer recordCount;
        @AuraEnabled
        public List<RE_Depot_Pricing_Backbone__c> dpbRecords;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public Boolean userHasAccess;
    }
    
    //Wrapper class for downloading TP Records
    public class DownloadTPRecordsWrapper{
        @AuraEnabled
        public List<RE_Depot_Pricing_Backbone__c> currentActiveRecords;
        @AuraEnabled
        public List<RE_Depot_Pricing_Backbone__c> futureActiveRecords;
        @AuraEnabled
        public String messageToReturn;//Multi-purpose string
        @AuraEnabled
        public Map<String,String> mapOfFieldLabelByAPIName;//Example format: fieldApiName => fieldLabelName
    }
}