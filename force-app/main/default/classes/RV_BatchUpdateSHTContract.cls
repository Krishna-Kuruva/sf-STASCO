global class RV_BatchUpdateSHTContract implements Database.Batchable<sObject>{ 
    global Iterable<sObject> start(Database.BatchableContext BC){ 
        System.debug('### BatchUpdateSHTContract start()'); 
        List<SF_SAP_DataSet__x> externalData=new List<SF_SAP_DataSet__x>();
        String status1 = '02';
        String status2 = '03';  
        Set<String> statusSet = new Set<String>{'02','03'};
            List<SAP_Staging__c> recordsWaitingForResponse=[SELECT SHT_Transaction_Id__c,
                                                                   SfHeaderShtNo__c,
                                                                   SfItemShtNo__c,
                                                                   Processing_Indicator__c FROM SAP_Staging__c WHERE (Deal_Created_Date__c = TODAY OR 
                                                                                                                      LastModifiedDate = TODAY) AND Processing_Indicator__c ='01'];
        Set<String> itemSet = new Set<String>();
        for(SAP_Staging__c s:recordsWaitingForResponse){
            itemSet.add(s.SfItemShtNo__c);
        }
        try{
            if(Test.isRunningTest()){
                SF_SAP_DataSet__x mockedRequest = new SF_SAP_DataSet__x(SfHeaderShtNo__c='324435432', SfItemShtNo__c='SHT-0222', SapSalesContNo__c='32432432',Status__c='02',MsgTxt__c='test',Action__c='C');
                externalData.add(mockedRequest);
            }
            else{
                externalData = [select id,SfHeaderShtNo__c, SfItemShtNo__c, SapSalesContNo__c,Status__c,MsgTxt__c,Action__c from SF_SAP_DataSet__x where Status__c in:statusSet and SfItemShtNo__c in :itemSet];
            }
        }
        catch(Exception e){
            RV_ClassException.insertExceptionRecord
                                   (String.valueof(e.getTypeName()),
                                    e.getMessage(),
                                    'RV_BatchUpdateSHTContract',
                                    'Database.Batchable.start',
                                    'Exception');
        }
        return externalData; 
    } 
    
    global void execute(Database.BatchableContext BC, List<SF_SAP_DataSet__x> scope){        
        List<SAP_Staging__c> stagingCreateRecords=new List<SAP_Staging__c>();
        List<SAP_Staging__c> stagingRejectRecords=new List<SAP_Staging__c>();
        List<SAP_Staging__c> stagingFailedRecords=new List<SAP_Staging__c>();
        List<SF_SAP_DataSet__x> items =(List<SF_SAP_DataSet__x>)scope;
        Map<string,SAP_Staging__c> sfItemShtNoStagingObjMap= new  Map<string,SAP_Staging__c>();
        Set<String> statusSet = new Set<String>{'02','03'};
        List<SAP_Staging__c> StaginLst=[SELECT SHT_Transaction_Id__c,
                                               SfHeaderShtNo__c,
                                               CreationInd__c,
                                               SfItemShtNo__c,
                                               Processing_Indicator__c FROM SAP_Staging__c WHERE (Deal_Created_Date__c=TODAY OR 
                                                                                                  LastModifiedDate = TODAY) AND Processing_Indicator__c ='01'];
        System.debug('====='+StaginLst);
        for(SAP_Staging__c stg:StaginLst){
            sfItemShtNoStagingObjMap.put(stg.SfItemShtNo__c,stg);
        }
        
        
        for(SF_SAP_DataSet__x item:items){
            if(sfItemShtNoStagingObjMap.containsKey(item.SfItemShtNo__c)){
               SAP_Staging__c stagingRecord =new SAP_Staging__c();
                   stagingRecord =sfItemShtNoStagingObjMap.get(item.SfItemShtNo__c);
				if(stagingRecord.SHT_Transaction_Id__c==item.SfHeaderShtNo__c && stagingrecord.CreationInd__c=='C' &&
                   item.Action__c=='C' && stagingrecord.SfItemShtNo__c==item.SfItemShtNo__c && 
                   item.Status__c=='02' && stagingrecord.Processing_Indicator__c=='01' && 
                   item.SapSalesContNo__c!=NULL){
                    stagingrecord.SapSalesContNo__c=item.SapSalesContNo__c;
                    stagingrecord.Processing_Indicator__c=item.Status__c;
                    stagingCreateRecords.add(stagingrecord);             
                } 
                else if(stagingrecord.SHT_Transaction_Id__c==item.SfHeaderShtNo__c && stagingrecord.CreationInd__c=='D' && item.Action__c=='D' && stagingrecord.SfItemShtNo__c==item.SfItemShtNo__c && item.Status__c=='02' && stagingrecord.Processing_Indicator__c=='01'){
                    //Added for Issue :Feedback Contract number for cancelled deals:Start
                    stagingrecord.SapSalesContNo__c=item.SapSalesContNo__c;
                    //End
                    stagingrecord.Processing_Indicator__c=item.Status__c;
                    stagingRejectRecords.add(stagingrecord);  
                }
                else if(stagingrecord.SHT_Transaction_Id__c==item.SfHeaderShtNo__c && stagingrecord.CreationInd__c=='C' && item.Action__c=='C' && stagingrecord.SfItemShtNo__c==item.SfItemShtNo__c && item.Status__c=='03' && item.MsgTxt__c!=NULL && stagingrecord.Processing_Indicator__c=='01'){
                    //Added for Issue :Feedback Contract number for cancelled deals:Start
                    stagingrecord.SapSalesContNo__c=item.SapSalesContNo__c;
                    //End
                    stagingrecord.Processing_Indicator__c=item.Status__c;
                    stagingrecord.Error_Processing_to_GSAP__c=item.MsgTxt__c;
                    stagingFailedRecords.add(stagingrecord);
                } 
                else if(stagingrecord.SHT_Transaction_Id__c==item.SfHeaderShtNo__c && stagingrecord.CreationInd__c=='D' && item.Action__c=='D' && stagingrecord.SfItemShtNo__c==item.SfItemShtNo__c && item.Status__c=='03' && item.MsgTxt__c!=NULL && stagingrecord.Processing_Indicator__c=='01'){
                    stagingrecord.Processing_Indicator__c=item.Status__c;
                    stagingrecord.Error_Processing_to_GSAP__c=item.MsgTxt__c;
                    stagingFailedRecords.add(stagingrecord);
                } 
            }
        }
        if(stagingCreateRecords.size()>0){
            update stagingCreateRecords;
        }
        if(stagingRejectRecords.size()>0){
            update stagingRejectRecords;
        }
        if(stagingFailedRecords.size()>0){
            update stagingFailedRecords;
        }
    } 
    
    global void finish(Database.BatchableContext BC){ 
        System.debug('### BatchUpdateSHTContract: finish() called'); 
    } 
}