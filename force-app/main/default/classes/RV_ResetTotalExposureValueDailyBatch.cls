/*****************************************************************************
@Name:  RV_ResetTotalExposureValueDailyBatch      
@=========================================================================
@Purpose: Batch will execute  to reset sht dave master values ,This batch will run daily night 12 pm                                                                              
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      1/12/2018       INITIAL DEVELOPMENT

******************************************************************************/
global class RV_ResetTotalExposureValueDailyBatch implements Queueable{//Database.Batchable<sObject>

   global void execute(QueueableContext context){//Database.BatchableContext BC, List<SHT_Dave_Master__c> shtDaveMasterLst
         
         String query = 'SELECT Id,Name,Total_Exposure_Factor__c,Total_Exposure_Factors__c,Total_Hedging__c,Hedged__c,'+
                      'Total_Exposure_Factor_CBM__c,Final_Exposure_Factor__c,Total_Exposure_Factor_MT__c FROM '+
          			   'SHT_Dave_Master__c ';
         List<SHT_Dave_Master__c> shtDaveMasterLst = database.query(query);
         System.debug('&&&&&&&&&&shtDaveMasterLst&&&&&&&&&'+shtDaveMasterLst);
       
         List<SHT_Dave_Master__c> finalupdateSHTDaveRecord = new List<SHT_Dave_Master__c>();
         
         if(shtDaveMasterLst <> null && shtDaveMasterLst.size() > 0){
            
             for(SHT_Dave_Master__c shtDaveMaster : shtDaveMasterLst){
                
                 if(shtDaveMaster.Total_Exposure_Factors__c == null)shtDaveMaster.Total_Exposure_Factors__c=0;
                 if(shtDaveMaster.Hedged__c == null)shtDaveMaster.Hedged__c=0;
                 shtDaveMaster.Total_Exposure_Factors__c = 0;
                 shtDaveMaster.Hedged__c = 0;
                 finalupdateSHTDaveRecord.add(shtDaveMaster);
             }
             
             if(!finalupdateSHTDaveRecord.isEmpty()){
                     
                     //finalupdateBioAMVRecord = null;
                     System.debug('Successfully updated AMV Scenario: ' + finalupdateSHTDaveRecord);
                     
                     Database.SaveResult[] saveResultList  = Database.update(finalupdateSHTDaveRecord,false);
                     for (Database.SaveResult sr : saveResultList) {
                         
                         if (sr.isSuccess()) {
                             // Operation was successful, so get the ID of the record that was processed
                             System.debug('Successfully updated AMV Scenario: ' + sr.getId());
                         }
                         else {
                             // Operation failed, so get all errors                
                             for(Database.Error err : sr.getErrors()) {
                                 RV_ClassException.getInstance();
                                 RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'RV_ResetBioAMVSteerValDailyBatch', 'execute','Exception');
                             }
                         }
                     }
             }
         }
    }

}