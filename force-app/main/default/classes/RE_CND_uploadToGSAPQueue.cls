/**************************************************************************************************
* Name: RE_CND_uploadToGSAPQueue
* Object: Fixed_Price_Staging_Table__c, RE_MY_CostPrice__c, RT_Price_Book__c
* Purpose: Method to upload Canada Prices from Cost Price and REV Pricebook into GSAP System
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-06-13
* Modify History: 
* 2022-06-13		Abhilash		Created
**************************************************************************************************/
public class RE_CND_uploadToGSAPQueue implements Queueable {
    
    private List<String> recordstoupload;
    private Date datefilter;
    private String uploadType;
    private Id jobRunAudId;
    private Boolean isDefSettingActive = false;
    private Integer defDateExt;
    
    public RE_CND_uploadToGSAPQueue(List<String> recordstoupload,Date datefilter,String uploadType, Id jobRunAudId)
    {
        this.recordstoupload = recordstoupload;
        this.datefilter = datefilter;
        this.uploadType = uploadType;
        this.jobRunAudId = jobRunAudId;
    }
    
    public void execute(QueueableContext context) 
    {
        System.debug('RE_CND_uploadToGSAPQueue queue called---');
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit = [SELECT Id, RE_Job_Status__c, RE_Exception__c, Other_Comments__c, RE_Batch_Job_Ids__c FROM RE_Job_Run_Audit__c WHERE Id =: jobRunAudId]; 
        
        try
        {
            Id costPriceRecordTypeId 	= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            Id pricebookRecordTypeId 	= Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
            
            Map<String,RE_CustomOpps_ReportConfiguration__c> configMap = new Map<String,RE_CustomOpps_ReportConfiguration__c>();
            List<Fixed_Price_Staging_Table__c> fpsToInsert = new List<Fixed_Price_Staging_Table__c>();
            List<Fixed_Price_Staging_Table__c> fpsToUpdate = new List<Fixed_Price_Staging_Table__c>();
            List<RE_MY_CostPrice__c> cpListToUpdate = new List<RE_MY_CostPrice__c>();
            List<RT_Price_Book__c> pbListToUpdate = new List<RT_Price_Book__c>();           
            Map<String,Id> oldFixedPrceRecods = New Map<String,Id>();
            Map<String,String> newFixedPrceRecods = New Map<String,String>();
            Date defaultToDateForGsap;
            String validStartDtString = RE_CND_RackDetail_Controller.convertDate(String.valueOf(datefilter));
            
            // Get the GSAP To Date extension 
            List<RE_Default_Settings__c> DefSettingList = RE_Default_Settings__c.getAll().values();
            for(RE_Default_Settings__c DefSettingRec :DefSettingList )
            {
                if(DefSettingRec.Is_Active__c && DefSettingRec.Country_Name__c == 'Canada' && DefSettingRec.Type__c == 'GSAP To Date Extension')
                {
                    isDefSettingActive = true;
                    defDateExt =  Integer.valueOf(DefSettingRec.Value__c);
                    break;
                }
            }
            
            List<Id> accIds=new List<Id>();
            Boolean uploadAllowed=false;
            
            // Get all Is latest True records from Fixed Price staging table
            For(Fixed_Price_Staging_Table__c oldRecds: [SELECT Id, RE_Record_Key__c FROM Fixed_Price_Staging_Table__c
                                                        WHERE RE_Country_Name__c =: 'CA' AND RE_Valid_start_date__c =: validStartDtString AND RE_Is_latest__c =: TRUE])
            {
                oldFixedPrceRecods.put(oldRecds.RE_Record_Key__c, oldRecds.Id);
            }
            
            List<String> statusList=new List<String>{'Failed','Ready to Upload'};  
                
                if(uploadType=='Retry Upload')
                statusList=new List<String>{'Failed'};
                    if(RE_GSAP_Upload__c.getValues('Canada') != null && RE_GSAP_Upload__c.getValues('Canada').RE_GSAP_Upload__c)
                {
                    uploadAllowed=true; 
                }
            
            for(RE_CustomOpps_ReportConfiguration__c reportInfo:RE_CustomOpps_ReportConfiguration__c.getall().values())
            {
                if(reportInfo.RE_Country_Name__c=='Canada')
                {
                    configMap.put(reportInfo.RE_Customer_Type__c,reportInfo);
                }
            }
            Integer seqNo=1;
            
            if(recordstoupload.contains('Branded') || recordstoupload.contains('Unbranded'))
            {
                
                for (RE_MY_CostPrice__c cp :[SELECT Id,RE_CND_Final_Value__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,
                                             RE_Product_Codes__c,RE_Depot_Code__c,RE_Status__c ,RE_CND_Group__c,RE_CND_Product_Name__c
                                             FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= :datefilter 
                                             AND RE_CND_Effective_To_Date__c >= :datefilter AND  RecordTypeId=:costPriceRecordTypeId AND RE_IsLatest__c=TRUE
                                             AND RE_CND_Is_only_applicable_to_SFJ__c = FALSE
                                             AND RE_Status__c IN :(statusList) AND RE_CND_Group__c IN: recordstoupload])
                {                    
                    defaultToDateForGsap = isDefSettingActive ? cp.RE_CND_Effective_From_Date__c.addDays(defDateExt):cp.RE_CND_Effective_To_Date__c;
                    
                    if(uploadAllowed==false)
                    {
                        cp.RE_Status__c = 'Upload not allowed';	
                        cpListToUpdate.add(cp);
                    }
                    // System.debug('cp record--'+cp);
                    if(cp.RE_CND_Group__c=='Branded' && recordstoupload.contains('Branded'))
                    {                        
                        String key='';
                        List<string> keylist =configMap.get('Branded').RE_Varkey__c.split('\\+');
                        for(String tempData : keylist){ 
                            if(tempData.contains('_'))
                                key=key+cp.get(tempData);
                            else
                                key=key+ tempData;
                        }
                        
                        fpsToInsert=RE_CND_RackDetail_Controller.createStaging(configMap.get('Branded'),seqNo,cp.RE_CND_Effective_From_Date__c,defaultToDateForGsap,
                                                                               cp.RE_CND_Final_Value__c,cp.RE_CND_Product_Name__c,key,fpsToInsert,cp.Id,jrAudit.Id);
                        
                        newFixedPrceRecods.put(key+'-'+ validStartDtString + '-'+
                                               RE_CND_RackDetail_Controller.convertDate(String.valueOf(defaultToDateForGsap)),key+'-'+
                                               validStartDtString + '-'+ RE_CND_RackDetail_Controller.convertDate(String.valueOf(defaultToDateForGsap)));
                        seqNo++;                       
                    }
                    else if(cp.RE_CND_Group__c=='Unbranded' && recordstoupload.contains('Unbranded'))
                    {
                        String key='';
                        List<string> keylist =configMap.get('Unbranded').RE_Varkey__c.split('\\+');
                        for(String tempData : keylist){ 
                            if(tempData.contains('_'))
                                key=key+cp.get(tempData);
                            else
                                key=key+ tempData;
                        }
                        //    System.debug('depot code---'+key);
                        fpsToInsert=RE_CND_RackDetail_Controller.createStaging(configMap.get('Unbranded'),seqNo,cp.RE_CND_Effective_From_Date__c,defaultToDateForGsap,
                                                                               cp.RE_CND_Final_Value__c,cp.RE_CND_Product_Name__c,key,fpsToInsert,cp.Id,jrAudit.Id);
                        
                        newFixedPrceRecods.put(key+'-'+ validStartDtString + '-'+ RE_CND_RackDetail_Controller.convertDate(String.valueOf(defaultToDateForGsap)),key+'-'+ validStartDtString + '-'+ RE_CND_RackDetail_Controller.convertDate(String.valueOf(defaultToDateForGsap)));
                        seqNo++;                        
                    }
                }
            }
            
            if(recordstoupload.contains('SFJ'))
            {
                for(RT_Price_Book__c pb : [SELECT id, RE_CND_Customer_Name__r.AccountNumber,RE_CND_Final_Value__c, 
                                           RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,RT_Product_Code__c,
                                           RE_Custom_Opp_Approve__c, RE_CND_Product_Name__c, RE_CND_ShipTo_Number__c    
                                           FROM RT_Price_Book__c WHERE  RE_CND_Effective_From_Date__c <= :datefilter 
                                           AND RE_CND_Effective_To_Date__c >= :datefilter AND  RecordTypeId=:pricebookRecordTypeId AND RE_Is_Latest__c=TRUE
                                           AND RE_Custom_Opp_Approve__c IN :(statusList)])
                {                    
                    defaultToDateForGsap = isDefSettingActive ? pb.RE_CND_Effective_From_Date__c.addDays(defDateExt):pb.RE_CND_Effective_To_Date__c;   
                    
                    System.debug('pb Record--'+pb);
                    if(uploadAllowed==false)
                    {
                        pb.RE_Custom_Opp_Approve__c = 'Upload not allowed';
                        pbListToUpdate.add(pb);
                    }                    
                    
                    String key='';
                    List<string> keylist =configMap.get('SFJ').RE_Varkey__c.split('\\+');
                    for(String tempData : keylist)
                    { 
                        if(tempData.contains('_'))
                        {
                            if(tempData=='Account_Number')
                            {                             
                                key=key+pb.RE_CND_ShipTo_Number__c;
                            }
                            else
                                key=key+pb.get(tempData);
                        }
                        else
                            key=key+ tempData;
                    }
                    
                    fpsToInsert=RE_CND_RackDetail_Controller.createStaging(configMap.get('SFJ'),seqNo,pb.RE_CND_Effective_From_Date__c,defaultToDateForGsap,
                                                                           pb.RE_CND_Final_Value__c,pb.RE_CND_Product_Name__c,key,fpsToInsert,pb.Id,jrAudit.Id);
                    
                    newFixedPrceRecods.put(key+'-'+ validStartDtString + '-'+ RE_CND_RackDetail_Controller.convertDate(String.valueOf(defaultToDateForGsap)),key+'-'+ validStartDtString + '-'+ RE_CND_RackDetail_Controller.convertDate(String.valueOf(defaultToDateForGsap)));
                    seqNo++;  
                }
            }            
            
            if(cpListToUpdate !=null)
            {                
                RE_CND_BatchUpdate bu = new RE_CND_BatchUpdate(cpListToUpdate, jrAudit,true);
                ID cpListBatchId = Database.executebatch(bu,200);
                
                // Update Batch Ids to corresponding Job Run Audit
                jrAudit.RE_Batch_Job_Ids__c = jrAudit.RE_Batch_Job_Ids__c + ';' + cpListBatchId;
                update jrAudit;                
            }
            if(pbListToUpdate !=null)
            {                
                RE_CND_BatchUpdate bu = new RE_CND_BatchUpdate( pbListToUpdate, jrAudit,true);
                ID pbListBatchId =Database.executebatch(bu,200);
                
                // Update Batch Ids to corresponding Job Run Audit
                jrAudit.RE_Batch_Job_Ids__c = jrAudit.RE_Batch_Job_Ids__c + ';' + pbListBatchId;
                update jrAudit; 
            }
            
            if(fpsToInsert.size()>0)
            {
                Map<Id, RE_CND_Utility.StatusWrapper> idsUpserted = new Map<Id, RE_CND_Utility.StatusWrapper>();
                Set<Id> idsInserted= new Set<Id>();
                System.debug('Before Fixed Pricing Records Upsert--');
                Database.SaveResult[] insertObjectStatus= Database.insert(fpsToInsert, false);
                idsInserted=RE_CND_Utility.handleInsert('RE_CND_RackDetail_Controller','uploadToGSAP',insertObjectStatus,jrAudit);
                
                //RE_CND_BatchUpdate bu = new RE_CND_BatchUpdate( fpsToInsert, jrAudit,false);
                //Database.executebatch(bu,200);
                
                System.debug('Started Version Control Process');
                if(oldFixedPrceRecods.Size()>0 && newFixedPrceRecods.Size()>0)
                {
                    for(String keyVal:newFixedPrceRecods.values())
                    {
                        if(oldFixedPrceRecods.containsKey(keyVal))
                        {
                            Fixed_Price_Staging_Table__c fpsUpdateRecord = new Fixed_Price_Staging_Table__c();
                            fpsUpdateRecord.Id = oldFixedPrceRecods.get(keyVal);
                            fpsUpdateRecord.RE_Is_latest__c = FALSE;                            
                            fpsToUpdate.add(fpsUpdateRecord);                            
                        }
                    }
                }
                
                system.debug('fpsToUpdate-->'+fpsToUpdate);
                if(fpsToUpdate.Size() > 0)
                {
                    System.debug('RE_CND_BatchUpdate Batch Started');
                    RE_CND_BatchUpdate bu1 = new RE_CND_BatchUpdate( fpsToUpdate, jrAudit,true);
                    ID fpsToUpdateBatchId = Database.executebatch(bu1,200);   
                    
                    // Update Batch Ids to corresponding Job Run Audit
                    jrAudit.RE_Batch_Job_Ids__c = jrAudit.RE_Batch_Job_Ids__c + ';' + fpsToUpdateBatchId;
                    update jrAudit; 
                }              
            }
            
            if(uploadAllowed)
            {                
                List<Id> fixPriceIds = new List<Id>();
                for(Fixed_Price_Staging_Table__c tempdata: fpsToInsert)
                {
                    if(tempdata.RE_Is_latest__c)
                        fixPriceIds.add(tempdata.Id);
                }                
                
                //Using Bacth class data will be send to GSAP system
                if(!fixPriceIds.isEmpty())
                {
                    FixedPriceDataInsertBatch fdp = new FixedPriceDataInsertBatch( fixPriceIds,0 ,'Canada', jrAudit);
                    ID fpsInsertBatchId = Database.executebatch(fdp,200);  
                    
                    // Update Batch Ids to corresponding Job Run Audit
                    jrAudit.RE_Batch_Job_Ids__c = jrAudit.RE_Batch_Job_Ids__c + ';' + fpsInsertBatchId;
                    update jrAudit;                     
                }
            }
            else
            {
                if(jrAudit.RE_Job_Status__c=='Processing')
                {
                    RE_Job_Run_Audit__c jrAuditlatst = new RE_Job_Run_Audit__c(); 
                    RE_Job_Run_Audit__c[] jra = [SELECT Id, RE_Batch_Job_Ids__c, Other_Comments__c FROM RE_Job_Run_Audit__c WHERE Id =: jrAudit.Id];
                    if(jra.Size() > 0)
                    {
                        List<String> apexJobIds = jra[0].RE_Batch_Job_Ids__c.split(';');
                        if(apexJobIds.Size() > 0)
                        {
                            Integer totAbortdJobs = [SELECT count() FROM AsyncApexJob WHERE Id IN: apexJobIds AND Status = 'Aborted'];
                            if(totAbortdJobs > 0)
                            {
                                jrAuditlatst.Id = jra[0].Id;
                                jrAuditlatst.RE_Job_Status__c = 'Cancelled';
                                if(String.isEmpty(jra[0].Other_Comments__c))
                                    jrAuditlatst.Other_Comments__c = 'Batch Job Id(s) has been aborted by manual SAP Download option hence cancelled the JobRunAudit';  
                                else
                                    jrAuditlatst.Other_Comments__c = jra[0].Other_Comments__c +  ' - Batch Job Id(s) has been aborted by manual SAP Download option hence cancelled the JobRunAudit';  
                                Update jrAuditlatst;                                
                            }
                            else
                            {
                                jrAudit.RE_Job_Status__c='Completed'; 
                                update jrAudit;                                    
                            }
                        }
                        else
                        {
                            jrAudit.RE_Job_Status__c='Completed'; 
                            update jrAudit;                              
                        }
                    }    
                }                
            }    
        }
        catch(Exception ex)
        {
            if(	jrAudit!= NULL)
            {
                RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex); 
            }            
            RV_ClassException.insertExceptionRecord('RE_CND_uploadToGSAPQueue',ex.getMessage()+ex.getLineNumber(),'RE_CND_uploadToGSAPQueue','uploadToGSAP','Exception');
        }
    }
    
}