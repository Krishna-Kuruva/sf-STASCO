/**************************************************************************************************************************
 * Application  :   Trading and Supply  (TCP)
 * Description  :   To build email content and send emails.                
***************************************************************************************************************************/

public with sharing class TCP_EmailService {
public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    
    public static void sendEmail(Id recordId, Id recipientId, id accountId, id recipientUserId, String templateName,Boolean useOrgAddress) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(String.isNotEmpty(templateName))
            {
                EmailTemplate emailtemplate = [SELECT DeveloperName, Id, TemplateType FROM EmailTemplate WHERE DeveloperName =:templateName];
                mail.setTemplateId(emailtemplate.id);
            }
            if(useOrgAddress)
            {
                OrgWideEmailAddress OrgWideEmail = [Select id From OrgWideEmailAddress o where o.DisplayName= :Label.TCP_From_Email_Address];
          	  mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
            }
            if(accountId!=null)
            {
                Account accSalesorg = [Select id,sales_area__r.Sales_Region__c from account where id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
          	  String AccountSalesRegion=accSalesorg.sales_area__r.Sales_Region__c;
                if(AccountSalesRegion!=null){
                    TCP_DistributionEmailList__c ccListBasedOnRegion = TCP_DistributionEmailList__c.getValues(AccountSalesRegion);
                        if(ccListBasedOnRegion!=null){
                            //List<string> ccEmailList=new List<string>();
				     		//ccEmailList.add(ccListBasedOnRegion.TCP_Region_Commops_Distribution_List__c);             
                            List<string> ccEmailList=ccListBasedOnRegion.TCP_Commops_Delivery_Lists__c.split(';'); 
                            mail.setCcAddresses(ccEmailList);
                        }
                }
            }
            if(recipientId!=null)
            {
                mail.settargetObjectId(Id.valueof(recipientId));
                mail.setSaveAsActivity(true);
            }
            else
            {
                mail.settargetObjectId(Id.valueof(recipientUserId));
                mail.setSaveAsActivity(false);
            }
            mail.setWhatId(Id.valueof(recordId));
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		 mails.add(mail);
            if(!mails.isempty()){
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception excptn) {
            TCP_ExceptionLogClass.insertExceptionRecord('TCP EmailService',excptn.getMessage(),'TCP_EmailService','sendEmail','Exception');
            throw excptn;
        }
    }     
}