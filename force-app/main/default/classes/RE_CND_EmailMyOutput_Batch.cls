/**************************************************************************************************
* Name: RE_CND_EmailMyOutput_Batch
* Object: RE_MY_Output__c
* Purpose: Used for Upserting Myoutput records for Rev Canada Email output
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2023-03-10
* Modify History: 
* 2023-03-19        Abhilash        Created - Performance improvement PBI#1826604
**************************************************************************************************/
public with sharing class RE_CND_EmailMyOutput_Batch implements Database.Batchable<SObject>, Database.Stateful{ 
    //Class variables
    public List<SObject> recordsToProcess = new List<SObject>();
    public RE_Job_Run_Audit__c jra = new RE_Job_Run_Audit__c();
    public Integer successCount = 0;
    public Integer failureCount = 0;
    RE_UtilityClass.ProcessedCountWrapper pcWrappr = New RE_UtilityClass.ProcessedCountWrapper();
    public List<String> emailNames;
    public Boolean isEmailToMe;
    public Date reqFrmDate;
    
    //Constructor
    public RE_CND_EmailMyOutput_Batch(List<SObject> inputRecords, RE_Job_Run_Audit__c jra, List<String> emailNames, Boolean isEmailToMe, Date reqFrmDate) {
        this.recordsToProcess   = inputRecords;
        this.jra = jra;
        this.emailNames = emailNames;
        this.isEmailToMe = isEmailToMe;
        this.reqFrmDate = reqFrmDate;        
    }
    
    //Start Method
    public List<SObject> start(Database.BatchableContext bc) {
        return recordsToProcess;
    }
    
    //Execute Method
    public void execute(Database.BatchableContext bc, List<SObject> scope){        
        try{            
            Database.UpsertResult[] upsertResult = Database.upsert(scope, false);
            pcWrappr = RE_UtilityClass.reHandleUpsertRequest('RE_CND_EmailMyOutput_Batch','Execute',upsertResult,jra);  
            successCount += pcWrappr.successCount;
            failureCount += pcWrappr.failureCount;
        }catch(Exception e){
            RE_UtilityClass.reInsertExceptionRecord('Exception','RE_CND_EmailMyOutput_Batch', 'Execute','Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString(),'');
        }
    }

    //Finish Method
    public void finish(Database.BatchableContext bc){ 
        // Call the Conga output Email
        if (failureCount <= 0) {
            System.enqueueJob(new RE_CND_EmailMyOutput_Queue(jra, emailNames, isEmailToMe, reqFrmDate));}
        else{
            jra.RE_Job_Status__c = 'Failed';
            jra.Other_Comments__c = 'MyOutput Data creation got failed, please refer Rv_Exception records';
            update jra;
        }
    }   
}