/**
 * @description       : Query the Assigned records
**/
public class BetExportApprovalDataController {
    public Static string recTypeIDWonaCpt = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW CPT/BANK FORM').getRecordTypeId(); 
    public Static Id loggedInUser = UserInfo.getUserId();
    @AuraEnabled(cacheable=true)
    public static List<BET_BDD_Form__c> getMyApprovalDataToExport(){
        List<BET_BDD_Form__c> lstForms = [select id,name,BDD_Eligible_Status__c,Bulk_Batch_Execution_Tracking__c, IsExecutedInBulkBatch__c, IsErroredInBulkBatch__c,IsSuccessInBulkBatch__c, BET_Status__c,
											Assigned_COF__r.Name,BDD_Approver__r.Name,GT_Int_Business_Rel__c,
											RecordType.Name,recordtypeId,BDD_Entity_Type__c,Full_Legal_Name__c, GT_Legal_Name__c, Inc_Country__c,Assigned_COF__c, BDD_Approver__c, 
											GT_Contact_With_CP__c,GT_Trading_Name__c,GT_Rationale_OB_CP__c,GT_Cust_Entity_Type_Class__c,GT_Nature_of_Business__c,GT_Type_Of_RelationShip__c,
											GT_BDD_Commodity__c,GT_Other_Relationship_Comment__c,GT_GI__c,GT_Core_Business_Act__c,GT_BDD_Business_Division__c,GT_Req_Name__c,GT_Relationship__c,
											GT_Shell_Company__c,GT_Desk__c,GT_Were_any_deviations_applied_tothis_CP__c,GT_Counterparty_Type__c,GT_Operating_Region__c,PEPs_and_Sanc_Found__c,
											Negative_Stories_Found__c,BET_PEPs_and_Sanctions_Comments__c,BET_Negative_Stories_Comments__c from BET_BDD_Form__c 
											where recordtypeId =:recTypeIDWonaCpt AND IsSuccessInBulkBatch__c = true AND BDD_Eligible_Status__c != 'Yes' AND BDD_Approver__c =: loggedInUser LIMIT 600];
        return lstForms;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<BET_BDD_Form__c> getBulkApprovalRecords( String searchKey, String sortBy,  String sortDirection) {
        String betstatus ='Yes';
        Set<String> recordtypeSet = new Set<String>{recTypeIDWonaCpt};
            String query = ' SELECT Id,Assigned_COF__c,BDD_Eligible_Status__c, Assigned_COF__r.Name,Name,GT_Legal_Name__c,recordtypeId,recordtype.Name,BET_Status__c, BDD_Entity_Type__c,Full_Legal_Name__c,Inc_Country__c,BDD_Line_of_Business__c,BDD_Onboard_Type__c FROM BET_BDD_Form__c ';
        query +=' WHERE RecordTypeId IN :recordtypeSet and IsSuccessInBulkBatch__c = true AND  BDD_Approver__c=:loggedInUser AND BDD_Eligible_Status__c  !=:betstatus ';
        system.debug('query---'+query);
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' AND (Name LIKE :key OR GT_Legal_Name__c LIKE :key)';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        query = query + ' LIMIT 10000 ';
        return Database.query( query );
    }
}