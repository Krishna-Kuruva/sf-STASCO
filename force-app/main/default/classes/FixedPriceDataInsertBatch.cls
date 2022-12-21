global class FixedPriceDataInsertBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {    
    
    public List<Id> fixPriceIds;
    public integer counter;
    public String country;
    Public  RE_Job_Run_Audit__c jre;
    public FixedPriceDataInsertBatch(List<Id> fixPriceIdtoBatch, integer counter, String country , RE_Job_Run_Audit__c jre) {
        this.fixPriceIds = fixPriceIdtoBatch;
        this.counter =  counter;
        this.country = country;
        this.jre = jre;
    }
    global Iterable<Sobject> start(Database.BatchableContext BC) { 
        System.debug('FixedPriceDataInsertBatch start called--');
        return ([
            SELECT Id, OwnerId,RE_Error__c, IsDeleted, Name, CreatedDate, 
            CreatedById, LastModifiedDate, LastModifiedById, 
            SystemModstamp, RE_Application__c, RE_Calculation_type__c,
            RE_Cond_Usage_Table__c, RE_Cond_table_no__c, RE_Currency_Unit__c,
            RE_Quantity__c, RE_Report_Type__c, RE_Scale_Type__c, RE_Sequence_No__c,
            RE_Status__c, RE_Uom__c, RE_Valid_End_date__c, RE_Valid_start_date__c,
            RE_Value__c, RE_Varkey__c, RE_IdnForFix__c, RE_condRecordnumber__c,
            RE_Change__c, RE_ScaleAmount__c, RE_ScaleQuantity__c, RE_ScaleUOM__c,
            RE_ScaleDate__c, RE_ScaleTime__c, RE_Material_Description__c
            FROM Fixed_Price_Staging_Table__c where id IN: fixPriceIds AND RE_Status__c = '']);        
    }
    
    global void execute(Database.BatchableContext BC, List<Fixed_Price_Staging_Table__c> fpstlist) { 
            System.debug('FixedPriceDataInsertBatch EXECUTE called--');
            Rev_GSAPStagingTableClass.onafterInsert(fpstlist);       
    }   
    
    global void finish(Database.BatchableContext BC) {        
        //check if any failures and execute the batch again
        System.debug('FixedPriceDataInsertBatch finish called--');
        list<AsyncApexJob> jobDetails = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('jobDetails--'+jobDetails);
        if(!jobDetails.isEmpty() && jobDetails[0].NumberOfErrors > 0 && counter <= 2){
            counter += 1;
            FixedPriceDataInsertBatch batch2 = new FixedPriceDataInsertBatch(fixPriceIds,counter,country ,jre);
            //database.executeBatch(batch2,85);
            System.scheduleBatch(batch2, 'Re execute batch', 1, 100); 
        }
        else{
            system.debug('inside send email -- finish method');
        try{
            jre.RE_Job_Status__c ='Completed';
            jre.RE_IsSuccess__c = true;
            update jre;            
            List<String> idList = new List<String>();
            List<String> mailToAddresses = new List<String>(); 
            EmailTemplate template;
            Group gp;
            if(country == 'Malaysia'){
                gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = 'RE_MY_Customer_Ops'];
                template =[SELECT Id,Body,Subject FROM EmailTemplate WHERE Name = 'MY Customer Ops Email'];                
                
                
                for (GroupMember gm : gp.GroupMembers) {
                    idList.add(gm.UserOrGroupId);
                }
                List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
                for(User u : userList) {
                    mailToAddresses.add(u.email);               
                } 
                mailToAddresses.add(Userinfo.getUserEmail());
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setTargetObjectId(UserInfo.getUserId()); 
                mail.setTemplateId(template.Id); 
                mail.setBccSender(false); 
                mail.setUseSignature(false); 
                mail.setSenderDisplayName('Revolution East Team'); 
                mail.setSaveAsActivity(false); 
                mail.setToAddresses(mailToAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
            if(country == 'Canada')
            {               
                String [] ToEmail;
                String [] ccEmail;
                String [] BCCList;
                for(RE_Email_Recipient__mdt rec : [SELECT id, Cc_List__c, To_List__c,Bcc_List__c FROM RE_Email_Recipient__mdt 
                                                    WHERE Country__c =: 'Canada' AND Type__c =: 'Canada GSAP' AND Is_Active__c =: TRUE LIMIT 1])
                {
                    if(rec.To_List__c != NULL){ToEmail = rec.To_List__c.split(';');}				
                    if(rec.Cc_List__c != NULL){ccEmail = rec.Cc_List__c.split(';');}				
                    if(rec.Bcc_List__c != NULL){BCCList = rec.Bcc_List__c.split(';');}                    
                }
                
                template =[select id, HtmlValue, Subject from EmailTemplate where DeveloperName ='Canada_GSAP_Email'];                
                RE_CND_Utility.sendEmail(ToEmail,ccEmail,BCCList,template.Subject,template.HtmlValue,jre);
            }                
        }    
        catch(Exception ex){
            System.debug(ex.getMessage()+'\n'+ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getStackTraceString());            
        }
    }

  }
    
}