/**************************************************************************************************
* Name: RE_PriceBookBatchUpdate
* Object: RT_Price_Book__c
* Purpose: Price Book Batch Update Class for Revolution MY
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-11-30
* Modify History: 
* 2022-11-30		Abhilash		Created
**************************************************************************************************/
public class RE_PriceBookBatchUpdate implements Database.Batchable<SObject>, Database.Stateful  
{
    RE_Job_Run_Audit__c jrAudit = New RE_Job_Run_Audit__c();
    SObject[] records;

  public RE_PriceBookBatchUpdate(SObject[] source, RE_Job_Run_Audit__c jrAudit) {
    records = source;  
    this.jrAudit = jrAudit; 
  }

  public SObject[] start(Database.BatchableContext context) {
    return records;
  }
    
  public void execute(Database.BatchableContext context, SObject[] scope) {     
     Database.SaveResult[] updatePbList = Database.update(scope, false);
     Boolean updateSuccess = RE_CND_Utility.handleUpdateResult('RE_PriceBookBatchUpdate','RE_PriceBookBatchUpdate-UpdatePriceBookBatch',updatePbList,false, jrAudit);                                           
  }
    
  public void finish(Database.BatchableContext context) 
  {
  }    
    
}