/**************************************************************************************************
* Name: RE_CND_CostPriceBatchUpdate
* Object: RE_MY_CostPrice__c
* Purpose: Cost Price Batch Update Class for Revolution Canada
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2021-10-01
* Modify History: 
* 2021-10-01		Abhilash		Created
**************************************************************************************************/
public class RE_CND_CostPriceBatchUpdate implements Database.Batchable<SObject>, Database.Stateful 
{
  List<RT_Price_Book__c> pbLst = New List<RT_Price_Book__c>();
  RE_Job_Run_Audit__c jrAudit = New RE_Job_Run_Audit__c();
  String jrAuditStatus;
  Boolean IsSuccessJobAudit;   
  SObject[] records;
    
  public RE_CND_CostPriceBatchUpdate(SObject[] source, List<RT_Price_Book__c> pbLst, RE_Job_Run_Audit__c jrAudit, String jrAuditStatus, Boolean IsSuccessJobAudit) {
    records = source;
    this.pbLst = pbLst;
    this.jrAudit = jrAudit;   
    this.jrAuditStatus = jrAuditStatus;  
    this.IsSuccessJobAudit = IsSuccessJobAudit;    
  }
  
  public SObject[] start(Database.BatchableContext context) {
    return records;
  }
    
  public void execute(Database.BatchableContext context, SObject[] scope) {     
     Database.SaveResult[] updateCpList = Database.update(scope, false);
     Boolean updateSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_ExecuteDepoPricingController','startCalculatingDepoPricing-UpdateCostPriceBatch-NoPB',updateCpList,false, jrAudit);                                           
  }
    
  public void finish(Database.BatchableContext context) {

      if(pbLst.Size() > 0)
      {
         RE_CND_PriceBookBatchUpdate updatePB = New RE_CND_PriceBookBatchUpdate(pbLst, jrAudit, jrAuditStatus, IsSuccessJobAudit);
         Database.executeBatch(updatePB);
      }
      else if((jrAuditStatus == 'Processing') && (IsSuccessJobAudit))
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