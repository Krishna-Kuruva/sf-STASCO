/*****************************************************************************
@Name:  RV_SAPStagingNoResponseEmailBatch      
@=========================================================================
@Purpose: send email to deal owner if there are no response from gsap till 1 hr from deal creation.                                                                                      
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      20/09/2019         INITIAL DEVELOPMENT

******************************************************************************/
global class RV_SAPStagingNoResponseEmailBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String sapStaging= 'SELECT Id,Sent_to_GSAP__c,SendEmailNoGSAPResponse__c,createdDate,Processing_Indicator__c,Error_Processing_to_GSAP__c,SapSalesContNo__c,OwnerId,Owner.Email,CreatedBy.Username,CreatedBy.Email FROM SAP_Staging__c where'+
            ' Processing_Indicator__c =\'01\' AND SendEmailNoGSAPResponse__c = false AND CreatedDate = LAST_N_DAYS:2  ';//Added CreatedBy.Username in query to fetch OLF user name
        //'AND (SapSalesContNo__c = null OR Error_Processing_to_GSAP__c = null)';
        system.debug('sapStaging :: '+sapStaging);
        return Database.getQueryLocator(sapStaging);
    }
    
    global void execute(Database.BatchableContext BC, List<SAP_Staging__c> sapStagingList){
        system.debug('sapStagingList :: '+sapStagingList);
        Long currentTime = DateTime.now().getTime();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'BNG-ECO Revolution SBOBNG-PTID/TH'];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'RV_GSAP_No_response_Notifications'];
        List<Messaging.SingleEmailMessage> singleMessageLst = new List<Messaging.SingleEmailMessage>();
        List<SAP_Staging__c> updateSAPStagingList = new List<SAP_Staging__c>();
        List<String> ccEmailAddress = Label.RV_SAPStagingCC.split(';');
        if(!sapStagingList.isEmpty()){
            for(SAP_Staging__c sapStage : sapStagingList){
                if(sapStage.Error_Processing_to_GSAP__c == null || sapStage.SapSalesContNo__c == null){
                    system.debug('sapStage :: '+sapStage);
                    Long milliseconds = currentTime - sapStage.createdDate.getTime();
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    system.debug('sapStage Time:: '+minutes);
                    if(minutes >= Long.valueof(Label.RV_SAPStagingEmailTimeDuration) || Test.isRunningTest()){
                        system.debug('sapStage Time1:: '+Long.valueof(Label.RV_SAPStagingEmailTimeDuration));
                        sapStage.SendEmailNoGSAPResponse__c = true;
                        updateSAPStagingList.add(sapStage);
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(sapStage.OwnerId);
                        message.setTreatTargetObjectAsRecipient(true);
                        message.setSaveAsActivity(false);
                        message.setTemplateID(emailTemplate.Id);
                        message.setWhatId(sapStage.Id); //This is important for the merge fields in template to work
                        message.toAddresses = new String[] {sapStage.CreatedBy.Email};
                            if(sapStage.CreatedBy.Username == Label.RV_SAPStagingOLFUserName){   //Add email address for OLF deals
                                ccEmailAddress.addall(Label.RV_SAPStagingolfccAddress.split(';'));
                            }
                        message.ccaddresses = ccEmailAddress;
                        if ( owea.size() > 0 ) {
                            message.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        singleMessageLst.add(message);
                    }
                }
            }
            
            if(!singleMessageLst.isEmpty()){
                
                try{
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(singleMessageLst);
                    system.debug('results :: '+results);
                }catch(Exception e){
                    System.debug('------------------'+e.getMessage());
                }
            }
            
            if(!updateSAPStagingList.isEmpty()){
                
                Database.SaveResult[] saveResultList  = Database.update(updateSAPStagingList,false);
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated SAP Staging: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            RV_ClassException.getInstance();
                            RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'RV_SAPStagingNoResponseEmailBatch', 'execute','Exception');
                        }
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Method :: '+BC);
    }
}