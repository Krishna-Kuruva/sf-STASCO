/******************************************************************************************************************
className           :    RE_CND_Utility
Description         :    Utility class to handle common functions
Author              :    Aasiya Siraj
Date				:	 12-May-2021 
*******************************************************************************************************************/
public class RE_CND_Utility {
       
/****************************************************************************************************************
Method Name:  updateJobAudit
Description:  update Run Job Status to Fail when exception arises in a method.
****************************************************************************************************************/    
    public static void updateJobAudit(RE_Job_Run_Audit__c jobAudit,String status, Exception e){ 
        jobAudit.RE_Job_Status__c=status;
        jobAudit.RE_Job_Run_Count__c = 1;
        if(jobAudit.RE_Exception__c==null)
        {
            jobAudit.RE_Exception__c=e.getMessage()+'.'; 
        }
        else{
            jobAudit.RE_Exception__c=jobAudit.RE_Exception__c+e.getMessage()+'.';  
        }
        update jobAudit;
    }
    
/****************************************************************************************************************
Method Name:  updateJobAuditPartialSuccess
Description:  update Run Job Status to Partial Complete when some records fail to upsert or delete
****************************************************************************************************************/    
    public static void updateJobAuditPartialSuccess(RE_Job_Run_Audit__c jobAudit,String exceptionDetails,String otherComment ){ 
        jobAudit.RE_Job_Status__c='Partial Complete';
        if(jobAudit.RE_Exception__c==null)
        {
            jobAudit.RE_Exception__c=exceptionDetails+'.'; 
        }
        else{
            jobAudit.RE_Exception__c=jobAudit.RE_Exception__c+exceptionDetails+'.';  
        }
        if(jobAudit.Other_Comments__c==null)
        {
        jobAudit.Other_Comments__c=otherComment+'.';
        }
        else
        {
         jobAudit.Other_Comments__c=jobAudit.Other_Comments__c+otherComment+'.';   
        }
        update jobAudit;
    }
 /****************************************************************************************************************
Method Name:  handleUpsertResult
Description:  Method to handle UpsertResult and create RV_Exception records for failing records.Returns set of  ids of records upserted
****************************************************************************************************************/        
    
    public static Map<Id,StatusWrapper> handleUpsertResult(String className,String methodName,Database.UpsertResult[] upsertStatus,RE_Job_Run_Audit__c jobRunAudit ){ 
        System.debug('handleUpsertResult called---');
        Map<Id,StatusWrapper> idStatusMap = new Map<Id,StatusWrapper>();
        Set<Id> idUpserted = new Set<Id>();
        List<RV_Exception__c> excpList = new List<RV_Exception__c>();
        for (Database.UpsertResult  sr : upsertStatus) {
            StatusWrapper sw= new StatusWrapper();
            if(sr.isSuccess())
            {
                idUpserted.add(sr.getId());
                if(sr.isCreated()==true)
                {
                    sw.isCreated=true;
                    idStatusMap.put(sr.getId(),sw);
                }
                else{
                    sw.isUpdated=true;
                    idStatusMap.put(sr.getId(),sw);
                }
            }
            else{
                for(Database.Error err : sr.getErrors()) {
                    System.debug('err--'+err);
                    RV_Exception__c rvExcep = new RV_Exception__c();
                    rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                    rvExcep.getMessage__c = jobRunAudit.Id+':'+err.getMessage();
                    rvExcep.Apex_Class__c = className;
                    rvExcep.getFields__c	= JSON.serialize(err.getFields());
                    rvExcep.Method_Name__c = methodName;
                    rvExcep.Type__c = 'Exception';
                    excpList.add(rvExcep);
                 }
            }
        }
        
        if(excpList.size()>0){
            RV_ClassException.insertExceptionRecord(excpList); 
            String otherComment='Refer RV_Exception__c record for more details with jobAudit :'+jobRunAudit.Id;
            updateJobAuditPartialSuccess(jobRunAudit,'DML Exception while Database.Upsert',otherComment);
        }
        System.debug('idStatusMap--'+idStatusMap);
        return idStatusMap;
    }
    
    /****************************************************************************************************************
Method Name:  handleDeleteResult
Description:  Method to handle DeleteResult and create RV_Exception for failing records with details
****************************************************************************************************************/    
    public static Boolean handleDeleteResult(String className,String methodName,Database.DeleteResult[] deleteStatus,Boolean isDeleteError,RE_Job_Run_Audit__c jobRunAudit ){ 
        List<RV_Exception__c> excpList = new List<RV_Exception__c>();
        for (Database.DeleteResult  sr : deleteStatus) {
            System.debug('Delete--sr--'+sr);
            if(!(sr.isSuccess())) {
                for(Database.Error err : sr.getErrors()) {
                    
                    RV_Exception__c rvExcep = new RV_Exception__c();
                    rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                    rvExcep.getMessage__c = jobRunAudit.Id+':'+err.getMessage();
                    rvExcep.Apex_Class__c = className;
                    rvExcep.Method_Name__c =	methodName;
                    rvExcep.getFields__c	= JSON.serialize(err.getFields());
                    rvExcep.Type__c = 'Exception';
                    excpList.add(rvExcep);
                }
            }
        }
        if(excpList.size()>0){
            RV_ClassException.insertExceptionRecord(excpList); 
            String otherComment='Refer RV_Exception__c record for more details with jobAudit :'+jobRunAudit.Id;
            updateJobAuditPartialSuccess(jobRunAudit,'DML Exception while Database.DeleteResult',otherComment);
            isDeleteError=true;
        }
        return isDeleteError;
    } 
 /****************************************************************************************************************
Method Name:  handleInsert
Description:  Method to handle SaveResult and create RV_Exception for failing records with details
****************************************************************************************************************/    
    public static Set<Id> handleInsert(String className,String methodName,Database.SaveResult[] updateStatus,RE_Job_Run_Audit__c jobRunAudit ){ 
        List<RV_Exception__c> excpList = new List<RV_Exception__c>();
        System.debug('handleInsert called--');
        Set<Id> idsCreated = new Set<Id>();
        for (Database.SaveResult  sr : updateStatus) {
            if(sr.isSuccess())
            {
                idsCreated.add(sr.getId());
            }
            else
            {
                for(Database.Error err : sr.getErrors()) {
                    
                    RV_Exception__c rvExcep = new RV_Exception__c();
                    rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                    rvExcep.getMessage__c = jobRunAudit.Id+':'+err.getMessage();
                    rvExcep.Apex_Class__c = className;
                    rvExcep.Method_Name__c =	methodName;
                    rvExcep.getFields__c	= JSON.serialize(err.getFields());
                    rvExcep.Type__c = 'Exception';
                    excpList.add(rvExcep);
                }
            }
        }
        if(excpList.size()>0){
            RV_ClassException.insertExceptionRecord(excpList); 
            String otherComment='Refer RV_Exception__c record for more details with jobAudit :'+jobRunAudit.Id;
            updateJobAuditPartialSuccess(jobRunAudit,'DML Exception while Database.Update',otherComment);
        }
        return idsCreated;
    } 
      
    
  /****************************************************************************************************************
Method Name:  handleUpdate
Description:  Method to handle UpdateResult and create RV_Exception for failing records with details
****************************************************************************************************************/    
    public static Boolean handleUpdateResult(String className,String methodName,Database.SaveResult[] updateStatus,Boolean isDeleteError,RE_Job_Run_Audit__c jobRunAudit ){ 
        List<RV_Exception__c> excpList = new List<RV_Exception__c>();
        for (Database.SaveResult  sr : updateStatus) {
            if(!(sr.isSuccess())) {
                for(Database.Error err : sr.getErrors()) {
                    
                    RV_Exception__c rvExcep = new RV_Exception__c();
                    rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                    rvExcep.getMessage__c = jobRunAudit.Id+':'+err.getMessage();
                    rvExcep.Apex_Class__c = className;
                    rvExcep.Method_Name__c =	methodName;
                    rvExcep.getFields__c	= JSON.serialize(err.getFields());
                    rvExcep.Type__c = 'Exception';
                    excpList.add(rvExcep);
                }
            }
        }
        if(excpList.size()>0){
            RV_ClassException.insertExceptionRecord(excpList); 
            String otherComment='Refer RV_Exception__c record for more details with jobAudit :'+jobRunAudit.Id;
            updateJobAuditPartialSuccess(jobRunAudit,'DML Exception while Database.Update',otherComment);
            isDeleteError=true;
        }
        return isDeleteError;
    } 
      
/****************************************************************************************************************
Method Name:  sendEmail
Description:  Method to send email
****************************************************************************************************************/    
    public static void sendEmail(String [] ToEmail,String[] ccAddresses ,String[] BccList,String subject,String body,RE_Job_Run_Audit__c jobRunAudit ){ 
        try{
        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(ToEmail != NULL)
            	{email.setToAddresses(ToEmail);}
            if(ccAddresses != NULL)
            	{email.setCcAddresses(ccAddresses);}
            if(BccList != NULL)
            	{email.setBccAddresses(BccList);}
            
            email.setSubject(subject);
            email.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        catch(Exception e)
        {
          updateJobAuditPartialSuccess(jobRunAudit,e.getMessage(),'Exception while sending email notification');  
        }
    }  
    
    
    public class StatusWrapper
	{
    	public Boolean isCreated;
    	public Boolean isUpdated;
	}
    
}