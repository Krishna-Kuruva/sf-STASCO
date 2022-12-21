/**************************************************************************************************
* Name: RV_GSAPContractFailureEmailNotify
* Object: SAP_Staging__c
* Purpose: Whenever a GSAP contract creation got failed through interface and error occurred then inform 
  to createdby,lastmodifiedby, deal owner, etc through email SAP Staging
* Author: Abhilash (abhilash.kt@shell.com)
* Create Date: 2021-02-10
* Modify History: 
* 2021-02-10		Abhilash		Created			(#702447)
**************************************************************************************************/
public class RV_GSAPContractFailureEmailNotify {

    @InvocableMethod
    public static void GSAPContractFailureEmailNotify(List<Id> stagingGSAPIds)
    {
        For(SAP_Staging__c errorItem : [Select Id, SfItemShtNo__c, Processing_Indicator__c, Error_Processing_to_GSAP__c, createdby.Email, LastModifiedBy.Email, CreationInd__c,CreatedBy.Username
        from SAP_Staging__c where Id in: stagingGSAPIds and Processing_Indicator__c =: '03' and (CreationInd__c =: 'C' or CreationInd__c =: 'D')])//Added CreatedBy.Username in query to fetch OLF user name
        {
            list<string> originalToAddress = new list<string>();
            set<string> toAddress = new set<string>();
            list<string> originalCcAddress = new list<string>();
            set<string> ccAddress = new set<string>();

            EmailTemplate templateEmail = new EmailTemplate();

            //GSAP failure for creation
            if(errorItem.CreationInd__c == 'C')
            {
                originalToAddress = Label.RV_GSAPErrorEmailToRecepients.split(';');
                originalCcAddress = Label.RV_GSAPErrorEmailCCRecepients.split(';');
                System.debug('----------------'+originalCcAddress);
                if(errorItem.CreatedBy.Username == Label.RV_SAPStagingOLFUserName){//Add email address for OLF deals
                    System.debug('----------------'+originalCcAddress);
                    originalCcAddress.addall(Label.RV_SAPStagingolfccAddress.split(';'));
                }
                System.debug('----------------'+originalCcAddress);
                templateEmail = getEmailTemplate('RV_GSAP_Contract_Failure_Notification');
            }
            //GSAP failure for cancellation
            else if(errorItem.CreationInd__c == 'D')
            {
                originalToAddress = Label.RV_GSAPErrorCancellationEmailToRecepients.split(';');
                originalCcAddress = Label.RV_GSAPErrorCancellationEmailCCRecepients.split(';');
                System.debug('--------errorItem.CreatedBy.Username--------'+errorItem.CreatedBy.Username);
                if(errorItem.CreatedBy.Username == Label.RV_SAPStagingOLFUserName){//Add email address for OLF deals
                    System.debug('----------------'+originalCcAddress);
                    originalCcAddress.addall(Label.RV_SAPStagingolfccAddress.split(';'));
                }
                templateEmail = getEmailTemplate('RV_GSAP_Contract_Cancellation_Notification');
            }

            ccAddress.addAll(originalCcAddress);
            originalToAddress.add(errorItem.createdby.Email);
            originalToAddress.add(errorItem.LastModifiedBy.Email);
            toAddress.addall(originalToAddress);

            originalToAddress = new List<String>(toAddress);
            originalCcAddress = new List<String>(ccAddress);
			System.debug('--------originalToAddress--------'+originalToAddress);
            System.debug('--------originalCcAddress--------'+originalCcAddress);
            sendEmailService(templateEmail, errorItem.Id, errorItem.SfItemShtNo__c, errorItem.Error_Processing_to_GSAP__c, originalToAddress, originalCcAddress);
        }
    }

    private static boolean sendEmailService(EmailTemplate templateEmail, Id gsapId, String SfItemShtNo, String errorMsg, list<string> toAddressParam, list<string> ccAddressParam)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = toAddressParam;
        String[] ccAddresses = ccAddressParam;
        string emailSubject = '';
        string emailBody = '';
        String recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+gsapId;

        if(toAddresses.size()>0)
        {
            emailSubject = templateEmail.Subject;
            emailSubject = emailSubject.replace('{!SAP_Staging__c.SfItemShtNo__c}', SfItemShtNo);
            emailBody = templateEmail.HtmlValue;
            emailBody = emailBody.replace('{!SAP_Staging__c.SfItemShtNo__c}', SfItemShtNo);
            emailBody = emailBody.replace('{!SAP_Staging__c.Error_Processing_to_GSAP__c}', errorMsg);
            emailBody = emailBody.replace('{!SAP_Staging__c.Link}', recordlink);
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setSubject(emailSubject);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody(emailBody);
            try{
                If(!Test.isRunningTest())
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(exception ex){
                return false;
            }
        }

        return true;
    }

    private static EmailTemplate getEmailTemplate(string emailTemplateName){
        list<EmailTemplate> emailTemplates = new list<EmailTemplate>();
        EmailTemplate returnTemplate = new EmailTemplate();
        if(emailTemplateName != null && emailTemplateName != ''){
            emailTemplates = [Select Id, Name, Subject, Description, HtmlValue, Body from EmailTemplate where DeveloperName = :emailTemplateName];
            if(emailTemplates.size()>0)
                returnTemplate=emailTemplates[0];
        }
        return returnTemplate;
    }
}