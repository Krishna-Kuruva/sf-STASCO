/**************************************************************************************************
* Name: RE_CND_CostPriceBatchUpdate
* Object: RT_Price_Book__c
* Purpose: Price Book Batch Update Class for Revolution Canada
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-10-01
* Modify History: 
* 2021-10-01		Abhilash		Created
**************************************************************************************************/
public class RE_CND_PriceBookBatchUpdate implements Database.Batchable<SObject>, Database.Stateful 
{  
  RE_Job_Run_Audit__c jrAudit = New RE_Job_Run_Audit__c();
  String jrAuditStatus;
  Boolean IsSuccessJobAudit;   
  SObject[] records;
    
  public RE_CND_PriceBookBatchUpdate(SObject[] source, RE_Job_Run_Audit__c jrAudit, String jrAuditStatus, Boolean IsSuccessJobAudit) {
    records = source;   
    this.jrAudit = jrAudit;   
    this.jrAuditStatus = jrAuditStatus;  
    this.IsSuccessJobAudit = IsSuccessJobAudit;    
  }
  
  public SObject[] start(Database.BatchableContext context) {
    return records;
  }
    
  public void execute(Database.BatchableContext context, SObject[] scope) {     
     Database.SaveResult[] updateCpList = Database.update(scope, false);
     Boolean updateSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_ExecuteDepoPricingController','startCalculatingDepoPricing-UpdatePriceBookBatch',updateCpList,false, jrAudit);                                           
  }
    
  public void finish(Database.BatchableContext context) 
  {
      if((jrAuditStatus == 'Processing') && (IsSuccessJobAudit))
      {          
          jrAudit.RE_Job_Status__c = 'Completed';  
          update jrAudit;          
      }
      else
      {       
          String comments = 'Refer RV_Exception__c record for more details with jobAudit :'+jrAudit.Id;
          RE_CND_Utility.updateJobAuditPartialSuccess(jrAudit,'Issue while generating Canada Depo Pricing Job',comments);                          
      }
  }
}