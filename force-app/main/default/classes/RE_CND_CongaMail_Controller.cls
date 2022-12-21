/******************************************************************************************************************
className           :    RE_CND_CongaMail_Controller
Description         :    Controller class for sending CA Email 
Author              :    Aasiya Siraj
Date				:	 1-Nov-2021 
*******************************************************************************************************************/

public with sharing class RE_CND_CongaMail_Controller {
    
    @AuraEnabled
    public static Boolean getJobStatusMail()
    {         
        Boolean isProcessing = false;
        RE_Job_Run_Audit__c jra = [SELECT RE_Job_Status__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c='Canada Email Output' ORDER BY CreatedDate DESC LIMIT 1];
       
        if(jra.RE_Job_Status__c == 'Processing')
            isProcessing = true;
        else
            isProcessing = false;
        
        return isProcessing;
    }
    
    @AuraEnabled
    public static MailWrapper getMailDetails()
    { 
        MailWrapper mw = new MailWrapper();
        List <APXTConga4__Conga_Email_Template__c> mailList =[SELECT Id, APXTConga4__HTMLBody__c,  APXTConga4__Name__c, APXTConga4__Subject__c,  
                                                               APXTConga4__TextBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c IN
                                                               ('Internal Rack Notification','Canadian Rack Prices','Shell Rack Customer Notification','Ready to Upload Notification',
                                                                'SFJ Rack notification','Internal Shell Canada BRPP Notification','Shell Canada Rack Notification','7 DAY Canadian Rack Prices',
                                                                'Shell Canada - Branded Customer Notification','No Revised Pricing','Canadian Rack Pricing and rack pricing Files')];
        
        List<RE_Record_Id_Mappings__c> mappingList = [SELECT Id, Record_Id__c,Type_Name__c FROM RE_Record_Id_Mappings__c WHERE Country_Name__c = 'Canada' AND Is_Active__c = TRUE];
        System.debug('mailList--'+mailList);
        System.debug('mappingList--'+mappingList);
        mw.mailList		=	mailList;
        mw.mappingList	=	mappingList;
        return mw;
    }
    
    public class MailWrapper
    {
        @AuraEnabled public List<APXTConga4__Conga_Email_Template__c> mailList;
        @AuraEnabled public List<RE_Record_Id_Mappings__c> mappingList;
    }
    
    @AuraEnabled
    public static void sendEmailDetails(List<String> selectedMail,List <APXTConga4__Conga_Email_Template__c> updatedEmail,Boolean isOnlyMe, Date dateFilter)
    {
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        try{
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Manual';
            jrAudit.RE_Job_Type__c = 'Canada Email Output';
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';
            jrAudit.RE_Country_Name__c='CA';
            insert jrAudit;

            String dateString =string.valueof(dateFilter).substring(0,10);
            
            List<APXTConga4__Conga_Email_Template__c> emailListToUpdate = new List<APXTConga4__Conga_Email_Template__c>();
            List<APXTConga4__Conga_Merge_Query__c> queryListToUpdate = new List<APXTConga4__Conga_Merge_Query__c>();
            Map<String,APXTConga4__Conga_Email_Template__c> emailMap= new Map<String,APXTConga4__Conga_Email_Template__c>();
            
            Map<Id, RE_CND_Utility.StatusWrapper> emailIdsUpserted = new Map<Id, RE_CND_Utility.StatusWrapper>();   
            Map<Id, RE_CND_Utility.StatusWrapper> queryIdsUpserted = new Map<Id, RE_CND_Utility.StatusWrapper>();
            
            for(APXTConga4__Conga_Email_Template__c mailDetail :[SELECT Id,APXTConga4__Description__c, APXTConga4__HTMLBody__c,  APXTConga4__Name__c, APXTConga4__Subject__c,  
                                                                 APXTConga4__TextBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c IN
                                                                 ('Internal Rack Notification','Canadian Rack Prices','Shell Rack Customer Notification','Ready to Upload Notification',
                                                                  'SFJ Rack notification','Internal Shell Canada BRPP Notification','Shell Canada Rack Notification','7 DAY Canadian Rack Prices',
                                                                  'Shell Canada - Branded Customer Notification','No Revised Pricing','Canadian Rack Pricing and rack pricing Files')])
            {
                emailMap.put(mailDetail.APXTConga4__Name__c,mailDetail);
            }
            
            for(APXTConga4__Conga_Email_Template__c newMail :updatedEmail)
            {
                if(emailMap.containsKey(newMail.APXTConga4__Name__c))
                {
                    emailMap.get(newMail.APXTConga4__Name__c).APXTConga4__HTMLBody__c=newMail.APXTConga4__HTMLBody__c;
                    emailMap.get(newMail.APXTConga4__Name__c).APXTConga4__TextBody__c=newMail.APXTConga4__TextBody__c;
                    emailMap.get(newMail.APXTConga4__Name__c).APXTConga4__Subject__c=newMail.APXTConga4__Subject__c;
                    emailListToUpdate.add(emailMap.get(newMail.APXTConga4__Name__c));
                }
            }
            
            // Update Email Subject & Email Body
            if(emailListToUpdate.size() >0)
            {                
                Database.UpsertResult[] updateMailList = Database.upsert(emailListToUpdate, false);
                emailIdsUpserted = RE_CND_Utility.handleUpsertResult('RE_CND_CongaMail_Controller','sendEmailDetails-emailListToUpdate',updateMailList,jrAudit);
            }
             String regExp='[0-9]{4}'+'-'+'[0-9]{2}'+'-'+'[0-9]{2}';
            for(APXTConga4__Conga_Merge_Query__c congaQuery :[SELECT Id, APXTConga4__Name__c, APXTConga4__Query__c FROM APXTConga4__Conga_Merge_Query__c 
                                                              WHERE APXTConga4__Name__c IN
                                                              ('Canada Daily Rack','Canada Branded','Canada SFJ','Canada Unbranded','Canada Daily Rack 7 Day','Canada Rack Prices',
                                                               'Canada Cost Price Date Query')])
            {
                congaQuery.APXTConga4__Query__c = congaQuery.APXTConga4__Query__c.replaceAll(regExp, dateString);
                System.debug('new query--'+congaQuery.APXTConga4__Query__c);
                
                queryListToUpdate.add(congaQuery);
            }
            
            // Update Conga Query
            if(queryListToUpdate.size() >0)
            {                
                Database.UpsertResult[] updateQueryList = Database.upsert(queryListToUpdate, false);
                queryIdsUpserted = RE_CND_Utility.handleUpsertResult('RE_CND_CongaMail_Controller','sendEmailDetails-queryListToUpdate',updateQueryList,jrAudit);
            }
            
            // Process for creating MyOutput records
            RE_CND_EmailMyOutputController.emailMyOutputCreation(selectedMail, isOnlyMe, dateFilter, jrAudit,jrAudit.RE_Job_Status__c);       
        }
        catch(Exception ex)
        {
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            if(	jrAudit!= NULL)            
                RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex); 
            
            RV_ClassException.insertExceptionRecord('RE_CND_CongaMail_Controller',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_CongaMail_Controller','sendEmailDetails','Exception');
        }
    }
    
}