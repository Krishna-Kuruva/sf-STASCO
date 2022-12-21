global class BET_DocumentStatusUpdateBatch implements Database.Batchable<sObject>{
     global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,LastModifiedDate,BET_Status__c,(Select Id,BET_Doc_Status__c,BET_IDD_Link__c from BDD_Documents__r where BET_Doc_Status__c != \'Ready to Delete\' and BET_Doc_Status__c != \'Deleted Successfully\') from BET_BDD_Form__c where BET_Status__c = \'Submitted\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<BET_BDD_Form__c> scope){
        List<BET_BDD_Document__c> documentList = new List<BET_BDD_Document__c>();
        Date lastExectedDate = System.today() - 30;
        System.debug('last exe date**'+lastExectedDate);
        for(BET_BDD_Form__c formRec : scope){
            System.debug('bet status'+formRec.BET_Status__c);
            System.debug('doc rec'+formRec.BDD_Documents__r);
            if(formRec.LastModifiedDate < lastExectedDate && formRec.BET_Status__c == 'Submitted' && formRec.BDD_Documents__r != Null){
                for(BET_BDD_Document__c docRec : formRec.BDD_Documents__r){
                    if(docRec.BET_IDD_Link__c != Null){
                    docRec.BET_Doc_Status__c = 'Ready to Delete';
                    documentList.add(docRec);
                    }}}}
            System.debug('doc list'+documentList.size());
        CheckRecursive.isRunningBatch = false;
        database.update(documentList, false);
        //update documentList;
        CheckRecursive.isRunningBatch = true;
        
    }
	global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}