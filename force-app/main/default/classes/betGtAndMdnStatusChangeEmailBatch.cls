public class betGtAndMdnStatusChangeEmailBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    /**
* @category  BET APPLICATION
* @author    Ashish.A.Jadhav@shell.com
*/
    Public Map<String,List<BET_BDD_Form__c>>gtMdnStatusChangeMap = new Map<String,List<BET_BDD_Form__c>>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = ' SELECT Id,Name,GT_Legal_Name__c,MDN_OI_Full_Legal_Name__c,GT_GoldTier_Id__c,GoldTier_Id__c, '
            +' GoldTier_Status__c,Goldtier_Status_Updated_Date__c,Goldtier_Status_Change_Email_Sent__c, '
            +' MDN_Status__c, MDN_Status_Updated_Date__c,MDN_Status_Change_Email_Sent__c, '
            +' Assigned_COF__c, Assigned_COF__r.Name, BDD_Approver__c, BDD_Approver__r.Name,Assigned_COF__r.Email,BDD_Approver__r.Email'
            +' FROM BET_BDD_Form__c WHERE (Goldtier_Status_Updated_Date__c = LAST_N_DAYS:3 OR MDN_Status_Updated_Date__c = LAST_N_DAYS:3) '
            +' AND (MDN_Status_Change_Email_Sent__c = false OR Goldtier_Status_Change_Email_Sent__c = false) ';
        system.debug('query :'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<BET_BDD_Form__c> formList) {
        // process each batch of records
        for(BET_BDD_Form__c form : formList){
            if(form.Assigned_COF__c != null){
                if(form.Goldtier_Status_Change_Email_Sent__c == false || form.MDN_Status_Change_Email_Sent__c == false){
                    if(gtMdnStatusChangeMap.containsKey(form.Assigned_COF__r.Email)){
                        gtMdnStatusChangeMap.get(form.Assigned_COF__r.Email).add(form);
                    } else {
                        gtMdnStatusChangeMap.put(form.Assigned_COF__r.Email,new List<BET_BDD_Form__c> {form});
                    }
                }
            }
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
        //String bddSupportAnalystEmail = label.betGtAndMdnStatusChangeEmailBatchCCAddress;//'ashish.a.jadhav@shell.com';
        List<String> bddSupportAnalystEmail = new List<String>();
		bddSupportAnalystEmail.addAll((Label.betGtAndMdnStatusChangeEmailBatchCCAddress).split(';'));
        List<BET_BDD_Form__c>tempList;
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        ccAddress.addALL(bddSupportAnalystEmail);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<BET_BDD_Form__c> updateList = new List<BET_BDD_Form__c>();
        String bodystr ='';
        for(String cofId : gtMdnStatusChangeMap.keyset()) {
            tempList = gtMdnStatusChangeMap.get(cofId);
			toAddress=new List<String>();
            if(tempList !=null && !tempList.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('BET Form GT/MDN Status Update Notification Email'); 
                bodystr = 'Hello COF,<br/><br/> Below are the BET Form Records for which GT Status/ MDN Status has changed. <br/><br/>'+getTableEmailBody(tempList)+'<br/><br/>Regards,<br/>BET Automation';
                toAddress.add(cofId);
                mail.setToAddresses(toAddress);
                system.debug('toAddress :'+toAddress);
                system.debug('ccAddress :'+ccAddress);
                mail.setCcAddresses(ccAddress);
                mail.setHtmlBody(bodystr);
                system.debug('For Loop :'+mail);
                mails.add(mail);
                updateList.addAll(tempList);
            }
        }
        system.debug('For Loop mails :'+mails);
        system.debug('For Loop mails SIZE :'+mails.size());
        if(mails !=null && !mails.isEmpty()){
            Messaging.SendEmail(mails);
            system.debug('Email Sent :'+mails);
            for(BET_BDD_Form__c form:updateList){
                form.MDN_Status_Change_Email_Sent__c = true;
                form.Goldtier_Status_Change_Email_Sent__c = true;
            }
            if(updateList !=null && !updateList.isEmpty())
            	update updateList;
        }
    }
    
    
    public static string getTableEmailBody(List<BET_BDD_Form__c> formList){
        
        String htmlBody = '';
        
        //open table..
        htmlBody = '<table border="1" style="border-collapse: collapse"><caption>GoldTier/MDN Status Update Notifications</caption><tr><th>BET Form Id</th><th>Legal Name</th><th>GT ID</th><th>GT Status</th><th>GT Status Updated Date</th><th>MDN Status</th><th>MDN Status Updated Date</th><th>Assigned Cof</th></tr>';
        
        for(BET_BDD_Form__c form : formList){
            String betId = (form.Name !=null && form.Name != '')? form.Name: '';
            String gtlegalName = (form.GT_Legal_Name__c !=null && form.GT_Legal_Name__c != '')? form.GT_Legal_Name__c: '';
            String gtId = (form.GoldTier_Id__c !=null )? string.valueof(form.GoldTier_Id__c.stripTrailingZeros()): '';
            String gtStatus = (form.GoldTier_Status__c !=null && form.GoldTier_Status__c != '')? form.GoldTier_Status__c: '';
            String gtStatusUpdatedDate = (form.Goldtier_Status_Updated_Date__c !=null )? string.valueof(form.Goldtier_Status_Updated_Date__c): '';
            String mdnLegalName = (form.MDN_OI_Full_Legal_Name__c !=null && form.MDN_OI_Full_Legal_Name__c != '')? form.MDN_OI_Full_Legal_Name__c: '';
            String mdnStatus = (form.MDN_Status__c !=null && form.MDN_Status__c != '')? form.MDN_Status__c: '';
            String mdnStatusUpdatedDate = (form.MDN_Status_Updated_Date__c !=null)? string.valueof(form.MDN_Status_Updated_Date__c): '';
            String assignedCofName = (form.Assigned_COF__c !=null && form.Assigned_COF__r.Name != '')? form.Assigned_COF__r.Name: '';
            htmlBody += '<tr><td>' + betId + '</td><td>' + gtlegalName + '</td><td>' + gtId + '</td><td>' + gtStatus + '</td><td>' + gtStatusUpdatedDate + '</td><td>' + mdnStatus + '</td><td>' + mdnStatusUpdatedDate + '</td><td>' + assignedCofName + '</td></tr>';
            
        }
        
        //close table...
        htmlBody += '</table>';
        
        return htmlBody;
        
    }
    
    public void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
       
        // We now call the batch class to be scheduled
        betGtAndMdnStatusChangeEmailBatch b = new betGtAndMdnStatusChangeEmailBatch ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
}