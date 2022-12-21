/**************************************************************************************************
* Name: RE_CND_BatchUpdate
* Object: RE_MY_CostPrice__c, PriceBook and FixedPriceStaging
* Purpose: Batch Update Class for Revolution Canada
* Author: Aasiya Siraj (aasiya.siraj@shell.com)
* Create Date: 2021-10-06
* Modify History: 
* 2021-10-06		Abhilash		Created
**************************************************************************************************/
public class RE_CND_BatchUpdate implements Database.Batchable<SObject>, Database.Stateful {

    RE_Job_Run_Audit__c jrAudit = New RE_Job_Run_Audit__c(); 
  	SObject[] records;
    Boolean isUpdate;
    
    public RE_CND_BatchUpdate(SObject[] source, RE_Job_Run_Audit__c jrAudit,Boolean isUpdate) {
    records = source;
    this.jrAudit = jrAudit; 
    this.isUpdate=isUpdate;
  }
    
    public SObject[] start(Database.BatchableContext context) {
    return records;
  }
    
    public void execute(Database.BatchableContext context, SObject[] scope) {  
        if(isUpdate)
        {
     		Database.SaveResult[] updateList = Database.update(scope, false);
     		Boolean updateSuccess = RE_CND_Utility.handleUpdateResult('RE_CND_RackDetail_Controller','uploadToGSAP',updateList,false, jrAudit);  
        }
        else
        {
            Set<Id> idsInserted = new Set<Id>();
            Database.SaveResult[] insertList = Database.insert(scope, false);
     		idsInserted = RE_CND_Utility.handleInsert('RE_CND_RackDetail_Controller','uploadToGSAP',insertList, jrAudit);
        }
  	}
    
    public void finish(Database.BatchableContext context) {
    }
}