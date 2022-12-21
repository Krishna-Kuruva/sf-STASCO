public class BetBulkUploadLWCController {
    public Static string recTypeIDWonaCpt = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW CPT/BANK FORM').getRecordTypeId(); 
    public Static string recTypeIDWonaIndvl = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW INDIVIDUAL FORM').getRecordTypeId();
        
    @AuraEnabled(Cacheable=false)
    public static ResponseWrapper updateReadyToOnboard( List<BET_BDD_Form__c>selectedFormList) {
        ResponseWrapper resp = new ResponseWrapper();
        List<SuccessWrapper> scsList = new List<SuccessWrapper>();
        List<ErrorWrapper> errList = new List<ErrorWrapper>();
        for(BET_BDD_Form__c form:selectedFormList){
            form.Bet_Status__c='Ready to Onboard';
        }
        Map<Id,BET_BDD_Form__c> recordMap = new Map<Id,BET_BDD_Form__c>(selectedFormList);
        system.debug('@@@@selectedFormList '+selectedFormList);
        system.debug('@@@@selectedFormList size '+selectedFormList.size());
        if(selectedFormList!=null && !selectedFormList.isEmpty()){
            Database.SaveResult[] srList = Database.update(selectedFormList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    SuccessWrapper obj = new SuccessWrapper();
                    obj.processedRecNumber=recordMap.get(sr.getId()).Name;
                    obj.processedRecName=recordMap.get(sr.getId()).GT_Legal_Name__c;
                    obj.successMessage ='Record Updated Successfully';
                    scsList.add(obj);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        ErrorWrapper objErr = new ErrorWrapper();
                        objErr.processedRecNumber=recordMap.get(sr.getId()).Name;
                        objErr.processedRecName=recordMap.get(sr.getId()).GT_Legal_Name__c;
                        objErr.errorMessage =err.getMessage();
                        objErr.errorFields =string.join(err.getFields(),',');
                        errList.add(objErr);
                    }
                }
            }
        }
        system.debug('@@@@scsList '+scsList);
        system.debug('@@@@errList '+errList);
        resp.UpdateSuccessList =scsList;
        resp.UpdateFailedList =errList;
        
        return resp;
    }
    
    
    public class ResponseWrapper{
        @AuraEnabled
        public List<SuccessWrapper> UpdateSuccessList{get;set;}
        @AuraEnabled
        public List<ErrorWrapper> UpdateFailedList{get;set;}
    }
    
    public class SuccessWrapper{
        @AuraEnabled
        Public String processedRecNumber{get;set;}
        @AuraEnabled
        Public String processedRecName{get;set;}
        @AuraEnabled
        Public String successMessage{get;set;}
    }
    
    public class ErrorWrapper{
        @AuraEnabled
        Public String processedRecNumber{get;set;}
        @AuraEnabled
        Public String processedRecName{get;set;}
        @AuraEnabled
        Public String errorMessage{get;set;}
        @AuraEnabled
        Public String errorFields{get;set;}
    }
    
    @AuraEnabled(Cacheable=false)
    public Static List<BET_EdpResponse_WrapperClass.OrbisResult> getEdpSearchResult(Id formId, String searchString) {
        BET_BDD_Form__c form =[select id,BDD_Line_of_Business__c,BDD_Entity_Type__c,Full_Legal_Name__c,Inc_Country__c,RecordTypeId,recordtype.Name from BET_BDD_Form__c where Id =: formId Limit 1];
        List<BET_EdpResponse_WrapperClass.OrbisResult>  orbisRespList = new List<BET_EdpResponse_WrapperClass.OrbisResult>();
        if(form !=null && String.IsNotBlank(searchString)){
            String sSource ='Primary';
            String accessToken ='';
            String sLOB =form.BDD_Line_of_Business__c;
            String sEntType = form.BDD_Entity_Type__c;
            String sShortName = searchString;
            String sIncCountry = form.Inc_Country__c;
            BET_EdpResponse_WrapperClass resp = BET_BDD_Search_Controller.getEdpData(sShortName,sLOB,sEntType,sIncCountry,accessToken,sSource);
            if(resp != null ){
                if(resp.OrbisResult != null && !resp.OrbisResult.isEmpty()){
                    orbisRespList = resp.OrbisResult;
                    system.debug('######orbisRespList  ::::'+orbisRespList);
                }
            }
        }
        return orbisRespList;
    } 
    @AuraEnabled(Cacheable=false)
    public Static String updateRecordWithOrbisData(Id formId, BET_EdpResponse_WrapperClass.OrbisResult orbisRecord){
        String message ='';
        String queryString = 'Select id,RecordTypeId,recordtype.Name,Bet_Status__c, BDD_Entity_Type__c,Full_Legal_Name__c, '
					+' Bulk_Batch_Execution_Tracking__c,IsExecutedInBulkBatch__c, IsErroredInBulkBatch__c,IsSuccessInBulkBatch__c, '
            +' MDN_OI_ShortName__c,MDN_CD_Core_Business__c,MDN_CD_RegNum__c,MDN_CD_PVAT_TaxNum__c,Last_Modifiedby_User__c,'
            +'Inc_Country__c,BDD_Line_of_Business__c,BDD_Onboard_Type__c from BET_BDD_Form__c WHERE Id =: formId';
        try{
            BET_BDD_Form__c form = Database.query(queryString);
            if(form!=null) {
                if(form.recordTypeId == recTypeIDWonaCpt && form.Bet_Status__c =='Draft' && form.IsExecutedInBulkBatch__c == true && form.IsSuccessInBulkBatch__c == false){
                	BET_BDD_Search_Controller.newBddFormCrResponse newRecWrap = BET_BDD_Search_Controller.bulkUploadRecordUpdate(form,orbisRecord,null,false,'',form.Inc_Country__c,null,'','',true);
                	message ='success';
                } else {
                    message ='Only Mass Upload batch failed and Draft status records can be updated.';
                }
                
            }
        } catch (Exception e){
            message =e.getMessage();
        }
        return message;
    }
    
    @AuraEnabled(Cacheable=false)
    public static ResponseWrapper updateApproved( List<BET_BDD_Form__c>selectedFormList) {
        ResponseWrapper resp = new ResponseWrapper();
        List<SuccessWrapper> scsList = new List<SuccessWrapper>();
        List<ErrorWrapper> errList = new List<ErrorWrapper>();
        for(BET_BDD_Form__c form:selectedFormList){
            form.BDD_Eligible_Status__c='Yes';
        }
        Map<Id,BET_BDD_Form__c> recordMap = new Map<Id,BET_BDD_Form__c>(selectedFormList);
        system.debug('@@@@selectedFormList '+selectedFormList);
        system.debug('@@@@selectedFormList size '+selectedFormList.size());
        if(selectedFormList!=null && !selectedFormList.isEmpty()){
            Database.SaveResult[] srList = Database.update(selectedFormList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    SuccessWrapper obj = new SuccessWrapper();
                    obj.processedRecNumber=recordMap.get(sr.getId()).Name;
                    obj.processedRecName=recordMap.get(sr.getId()).GT_Legal_Name__c;
                    obj.successMessage ='Record Updated Successfully';
                    scsList.add(obj);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        ErrorWrapper objErr = new ErrorWrapper();
                        objErr.processedRecNumber=recordMap.get(sr.getId()).Name;
                        objErr.processedRecName=recordMap.get(sr.getId()).GT_Legal_Name__c;
                        objErr.errorMessage =err.getMessage();
                        objErr.errorFields =string.join(err.getFields(),',');
                        errList.add(objErr);
                    }
                }
            }
        }
        system.debug('@@@@scsList '+scsList);
        system.debug('@@@@errList '+errList);
        resp.UpdateSuccessList =scsList;
        resp.UpdateFailedList =errList;
        
        return resp;
    }
    
    
}