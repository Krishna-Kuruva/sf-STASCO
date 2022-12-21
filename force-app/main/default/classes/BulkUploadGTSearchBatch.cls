global class BulkUploadGTSearchBatch implements Database.Batchable < sObject > , Database.AllowsCallouts {
    Integer batchLimit = 200;
    String recTypeIDWonaCpt = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW CPT/BANK FORM').getRecordTypeId(); 
    //string recTypeIDWonaIndvl = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW INDIVIDUAL FORM').getRecordTypeId();
    Set<String> recordtypeSet = new Set<String>{recTypeIDWonaCpt};
        public BulkUploadGTSearchBatch(Integer batchRecordLimit){
            if(batchRecordLimit !=null)
                this.batchLimit = batchRecordLimit;
        }
    public BulkUploadGTSearchBatch(){
        //this.batchLimit = batchLimit;
    }
    
    String sSource ;
    String accessToken ;
    String sLOB ;
    String sEntType ;
    String sShortName ;
    String sIncCountry ;
    BET_EdpResponse_WrapperClass.OrbisResult orbresp;
    BET_EdpResponse_WrapperClass.BankersResult bankresp;
    BET_BULK_UPLOAD_SETTINGS__c bulkSettings = BET_BULK_UPLOAD_SETTINGS__c.getOrgDefaults();
    boolean ConsiderOrbisId = bulkSettings.Is_OrbisID_Available__c;
    boolean ConsiderFirstRecord = bulkSettings.Consider_First_Match__c;
    Boolean ConsiderGTFieldsOnly = bulkSettings.Consider_GT_Fields_Only__c;
    
    public String query = 'Select id,RecordTypeId,recordtype.Name,Bet_Status__c, BDD_Entity_Type__c,Full_Legal_Name__c,Bulk_Batch_Execution_Tracking__c, '
        +' MDN_OI_ShortName__c,MDN_CD_Core_Business__c,MDN_CD_RegNum__c,MDN_CD_PVAT_TaxNum__c,Last_Modifiedby_User__c,'
        +'Inc_Country__c,BDD_Line_of_Business__c,BDD_Onboard_Type__c from BET_BDD_Form__c WHERE RecordTypeId IN :recordtypeSet and IsSuccessInBulkBatch__c = false limit : batchLimit ';
    List < BET_BDD_Form__c > updateBddFromList = new List < BET_BDD_Form__c > ();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List < BET_BDD_Form__c > bddFromList) {
        sSource ='Primary';
        accessToken ='';
        for(BET_BDD_Form__c form:bddFromList){
            sLOB =  form.BDD_Line_of_Business__c;
            sEntType = form.BDD_Entity_Type__c;
            sShortName = form.Full_Legal_Name__c;
            sIncCountry = form.Inc_Country__c;
            form.IsExecutedInBulkBatch__c = true;
            BET_EdpResponse_WrapperClass.OrbisResult orbresp; 
            try{
                BET_EdpResponse_WrapperClass resp = BET_BDD_Search_Controller.getEdpData(sShortName,sLOB,sEntType,sIncCountry,accessToken,sSource);
                if(resp != null ){
                    if(resp.OrbisResult != null && !resp.OrbisResult.isEmpty()){
                        if(resp.OrbisResult.size() == 1){
                            orbresp = resp.OrbisResult[0];
                            form.IsSuccessInBulkBatch__c =true;
                            form.Bulk_Batch_Execution_Tracking__c =(String.isBlank(form.Bulk_Batch_Execution_Tracking__c)?'' :form.Bulk_Batch_Execution_Tracking__c+ '\n') +' Executed in bulk batch with exact match on '+datetime.now();
                            system.debug('#####@@@@@ Exact match  sShortName : '+sShortName+'resp.OrbisResult.size() '+resp.OrbisResult.size()+' Result : '+resp.OrbisResult);
                        }
                        else if(resp.OrbisResult.size() > 1 && ConsiderOrbisId ){
                            form.Bulk_Batch_Execution_Tracking__c =(String.isBlank(form.Bulk_Batch_Execution_Tracking__c)?'' :form.Bulk_Batch_Execution_Tracking__c+ '\n')+' Executed in bulk batch with more matches and orbis Id consideration on '+datetime.now();
                        } else if(resp.OrbisResult.size() > 1 && ConsiderFirstRecord){
                            orbresp = resp.OrbisResult[0];
                            form.Bulk_Batch_Execution_Tracking__c =(String.isBlank(form.Bulk_Batch_Execution_Tracking__c)?'' :form.Bulk_Batch_Execution_Tracking__c+ '\n')+' Executed in bulk batch with more matches and First record consideration on '+datetime.now();
                            system.debug('#####@@@@@ More Matches consider first record  sShortName : '+sShortName+'resp.OrbisResult.size() '+resp.OrbisResult.size()+' Result : '+resp.OrbisResult);
                        } else if(resp.OrbisResult.size() > 1){
                            system.debug('#####@@@@@ More Matches consider as exception ');
                            form.Bulk_Batch_Execution_Tracking__c =(String.isBlank(form.Bulk_Batch_Execution_Tracking__c)?'' :form.Bulk_Batch_Execution_Tracking__c+ '\n')+' Executed in bulk batch with more matches and IDENTIFICATION_PROBLEM on '+datetime.now();
                        }
                        if(orbresp !=null){
                            system.debug('#####@@@@@  Start of the upsert method');
                            BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap = BET_BDD_Search_Controller.bulkUploadRecordUpdate(form,orbresp,null,false,'',sIncCountry,null,accessToken,'',ConsiderGTFieldsOnly);
                            system.debug('#####@@@@@  End of the upsert method');
                        }
                    }
                    else {
                        system.debug('##### OrbisResult is null');
                        form.Bulk_Batch_Execution_Tracking__c =(String.isBlank(form.Bulk_Batch_Execution_Tracking__c)?'' :form.Bulk_Batch_Execution_Tracking__c+ '\n')+' Executed in bulk batch with Blank OrbisResult on '+datetime.now();
                    }
                }
                else {
                    system.debug('##### response is null');
                    form.Bulk_Batch_Execution_Tracking__c =(String.isBlank(form.Bulk_Batch_Execution_Tracking__c)?'' :form.Bulk_Batch_Execution_Tracking__c+ '\n')+' Executed in bulk batch with NULL_RESPONSE on '+datetime.now();
                }
                
            }
            Catch(exception e){
                system.debug('##exception---->'+ e.getmessage());
                form.Bulk_Batch_Execution_Tracking__c =(String.isBlank(form.Bulk_Batch_Execution_Tracking__c)?'' :form.Bulk_Batch_Execution_Tracking__c+ '\n' )+' Executed in bulk batch with EXCEPTION : '+e.getmessage()+' line No: '+e.getLineNumber()+' Reason: '+e.getCause()+' on '+datetime.now();
                form.IsErroredInBulkBatch__c =true;
            } finally {
                System.debug('In the finally block.');
                updateBddFromList.add(form);
            }
            
        }
        if(updateBddFromList !=null && !updateBddFromList.isEmpty()) {
            try {
                update updateBddFromList;
            } Catch(exception e){
                system.debug('##exception---->'+ e.getmessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}