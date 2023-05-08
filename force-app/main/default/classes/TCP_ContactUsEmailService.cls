public with sharing class TCP_ContactUsEmailService {
    
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    public static void sendEmailOnNewRequest(String AccountId,string[] toEmails,String firstName, String lastName, String phone, String email, String comment,String companyName, String shellConName,Boolean useOrgAddress) {
        if(comment==null){
            comment='';
        }
        
        comment=comment.replace('\n', '<br>');
        System.debug('Check Comment replace '+comment);
        String body='<html><body>'+
            '<font face="verdana" size="2"><table><tr>'+
            '<td style="background: #FFFFFF; border: solid #FFFFFF; border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;" >'+
            'Dear '+ UserInfo.getFirstName()+','+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you for contacting us. We will do our best to reply to you within one working day.</p>'+
            '<p align="Left"><b>Recorded details for portal user creation request:</b>'+
            '<table><tr>'+
            '<th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_FirstName+
            '</th>'+
            '<td align="left" style="font-family: verdana; font-face: verdana;font-size: 11px;word-break:break-all">'+firstName+'</td>'+
            '</tr>'+
            '<tr style="border-width: 0">'+
            '<th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_LastName+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+
            lastName+'</td></tr>'+
            '<tr style="border-width: 0"><th width="15%" style="background: #FFFFFF;font-weight:400;border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Phone+'</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+phone+'</td>'+
            '</tr>'+'<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Email+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+email+'</td>'+
            '</tr>'+
            '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Comment+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+comment+'</td>'+
            '</tr>'+'</table><p align="Left"><b>Additional reference information:</b></p>'+
            '<table>'+
            '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Company+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+companyName+'</td>'+
            '</tr></table>'+
            '<table><tr><th width="27%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px" align="left">'+Label.TCP_ShellContactName+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px">'+shellConName+'</td>'+
            '</tr>'+'</table>'+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you,<br/>Shell Trading</p>'+
            '</body></html>';
        
       
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toEmails.size()>0){
                mail.setToAddresses(toEmails);
            }
            if(accountId!=null)
            {
                Account accSalesorg = [Select id,sales_area__r.Sales_Region__c from account where id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
          	  String AccountSalesRegion=accSalesorg.sales_area__r.Sales_Region__c;
                if(AccountSalesRegion!=null){
                    TCP_DistributionEmailList__c ccListBasedOnRegion = TCP_DistributionEmailList__c.getValues(AccountSalesRegion);
                        if(ccListBasedOnRegion!=null){
                            List<string> ccEmailList=ccListBasedOnRegion.TCP_Commops_Delivery_Lists__c.split(';'); 
                            mail.setCcAddresses(ccEmailList);
                        }
                }
            }
            if(useOrgAddress)
            {
                OrgWideEmailAddress OrgWideEmail = [Select id,Address From OrgWideEmailAddress o where o.DisplayName= :Label.TCP_From_Email_Address];
                mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
               
            }
           
            mail.setSubject('Trading & Supply Chemical Portal - User creation request for '+firstName+' '+lastName);
            
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){
            TCP_ExceptionLogClass.insertExceptionRecord('My Company Users or Contact Us Email Service Expection',ex.getMessage(),'TCP_ContactUsEmailService','sendEmailOnNewRequest','Exception');
        }        
    }
    public static void sendEmailOnCommentRequest(String AccountId,string[] toEmails, String comment,String companyName, String shellConName,Boolean useOrgAddress){
        if(comment==null){
            comment='';
        }
        comment=comment.replace('\n', '<br>');
        String body='<html><body>'+
            '<font face="verdana" size="2"><table><tr>'+
            '<td style="background: #FFFFFF; border: solid #FFFFFF; border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;" >'+
            'Dear '+ UserInfo.getFirstName()+','+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you for contacting us. We will do our best to reply to you within one working day.</p>'+
            '<table><tr>'+
            '<th width="25%" style="font-weight:400" align="left">'+'<b>'+Label.TCP_Comment_recorded_Description+'</b>'+
            '</th>'+
            '<td align="left" style="font-family: verdana; font-face: verdana;font-size: 11px;word-break:break-all">'+comment+'</td>'+
            '</tr>'+
            '</table><p align="Left"><b>Additional reference information:</b></p>'+
            '<table>'+
            '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Company+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+companyName+'</td>'+
            '</tr></table>'+
            '<table><tr><th width="27%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px" align="left">'+Label.TCP_ShellContactName+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px">'+shellConName+'</td>'+
            '</tr>'+'</table>'+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you,<br/>Shell Trading</p>'+
            '</body></html>';
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toEmails.size()>0){
                mail.setToAddresses(toEmails);
            }
            if(accountId!=null)
            {
              Account accSalesorg = [Select id,sales_area__r.Sales_Region__c from account where id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
          	  String AccountSalesRegion=accSalesorg.sales_area__r.Sales_Region__c;
                if(AccountSalesRegion!=null){
                    TCP_DistributionEmailList__c ccListBasedOnRegion = TCP_DistributionEmailList__c.getValues(AccountSalesRegion);
                        if(ccListBasedOnRegion!=null){
                            List<string> ccEmailList=ccListBasedOnRegion.TCP_Commops_Delivery_Lists__c.split(';'); 
                            mail.setCcAddresses(ccEmailList);
                        }
                }
            }
            if(useOrgAddress)
            {
                OrgWideEmailAddress OrgWideEmail = [Select id From OrgWideEmailAddress o where o.DisplayName= :Label.TCP_From_Email_Address];
                mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
            }
            
            mail.setSubject('Trading & Supply Chemical Portal - Comment');
            
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){
            TCP_ExceptionLogClass.insertExceptionRecord('Contact Us Email Service Expection',ex.getMessage(),'TCP_ContactUsEmailService','sendEmailOnCommentRequest','Exception');
        }     
    }
     public static void sendEmailOnInquiryRequest(String AccountId,string[] toEmails, String comment,String companyName, String shellConName,Boolean useOrgAddress){
        if(comment==null){
            comment='';
        }
         comment=comment.replace('\n', '<br>');
         String body='<html><body>'+
            '<font face="verdana" size="2"><table><tr>'+
            '<td style="background: #FFFFFF; border: solid #FFFFFF; border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;" >'+
            'Dear '+ UserInfo.getFirstName()+','+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you for contacting us. We will do our best to reply to you within one working day.</p>'+
            '<table><tr>'+
            '<th width="25%" style="font-weight:400" align="left">'+'<b>'+Label.TCP_Inquiry_recorded_Description+'</b>'+
            '</th>'+
            '<td align="left" style="font-family: verdana; font-face: verdana;font-size: 11px;word-break:break-all">'+comment+'</td>'+
            '</tr>'+
            '</table><p align="Left"><b>Additional reference information:</b></p>'+
            '<table>'+
            '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Company+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+companyName+'</td>'+
            '</tr></table>'+
            '<table><tr><th width="27%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px" align="left">'+Label.TCP_ShellContactName+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px">'+shellConName+'</td>'+
            '</tr>'+'</table>'+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you,<br/>Shell Trading</p>'+
            '</body></html>';
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toEmails.size()>0){
                mail.setToAddresses(toEmails);
            }
            if(accountId!=null)
            {
                Account accSalesorg = [Select id,sales_area__r.Sales_Region__c from account where id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
          	  String AccountSalesRegion=accSalesorg.sales_area__r.Sales_Region__c;
                if(AccountSalesRegion!=null){
                    TCP_DistributionEmailList__c ccListBasedOnRegion = TCP_DistributionEmailList__c.getValues(AccountSalesRegion);
                        if(ccListBasedOnRegion!=null){
                            List<string> ccEmailList=ccListBasedOnRegion.TCP_Commops_Delivery_Lists__c.split(';'); 
                            mail.setCcAddresses(ccEmailList);
                        }
                }
            }
            if(useOrgAddress)
            {
                OrgWideEmailAddress OrgWideEmail = [Select id From OrgWideEmailAddress o where o.DisplayName= :Label.TCP_From_Email_Address];
                mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
            }
            
            mail.setSubject('Trading & Supply Chemical Portal - Inquiry');
            
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){
            TCP_ExceptionLogClass.insertExceptionRecord('Contact Us Email Service Expection',ex.getMessage(),'TCP_ContactUsEmailService','sendEmailOnInquiryRequest','Exception');
        }     
    }
    public static void sendEmailOnComplaintRequest(String AccountId,string[] toEmails,String customerPo, String shellRefNo, String product, String comment,String companyName, String shellConName,Boolean useOrgAddress) {
       if(comment==null){
            comment='';
        }
        comment=comment.replace('\n', '<br>');
        String body='<html><body>'+
            '<font face="verdana" size="2"><table><tr>'+
            '<td style="background: #FFFFFF; border: solid #FFFFFF; border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;" >'+
            'Dear '+ UserInfo.getFirstName()+','+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you for contacting us. We will do our best to reply to you within one working day.</p>'+
            '<p align="Left"><b>Complaint - Recorded Details:</b>'+
            '<table><tr>'+
            '<th width="17%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Shell_Reference_Number+
            '</th>'+
            '<td align="left" style="font-family: verdana; font-face: verdana;font-size: 11px;word-break:break-all">'+shellRefNo+'</td>'+
            '</tr>'+
            '<tr style="border-width: 0">'+
            '<th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_CustomerPO+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+
            customerPo+'</td></tr>'+
            '<tr style="border-width: 0"><th width="15%" style="background: #FFFFFF;font-weight:400;border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Product+'</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+product+'</td>'+
            '</tr>'+'<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Description+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+comment+'</td>'+
            '</tr>'+'</table><p align="Left"><b>Additional reference information:</b></p>'+
            '<table>'+
            '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Company+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+companyName+'</td>'+
            '</tr></table>'+
            '<table><tr><th width="27%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px" align="left">'+Label.TCP_ShellContactName+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px">'+shellConName+'</td>'+
            '</tr>'+'</table>'+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you,<br/>Shell Trading</p>'+
            '</body></html>';
        
        
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toEmails.size()>0){
                mail.setToAddresses(toEmails);
            }
            if(accountId!=null)
            {
                Account accSalesorg = [Select id,sales_area__r.Sales_Region__c from account where id=:accountId and recordtype.id=:tcpAccountRecTypeid and Active__c=true];
          	  String AccountSalesRegion=accSalesorg.sales_area__r.Sales_Region__c;
                if(AccountSalesRegion!=null){
                    TCP_DistributionEmailList__c ccListBasedOnRegion = TCP_DistributionEmailList__c.getValues(AccountSalesRegion);
                        if(ccListBasedOnRegion!=null){
                            List<string> ccEmailList=ccListBasedOnRegion.TCP_Commops_Delivery_Lists__c.split(';'); 
                            mail.setCcAddresses(ccEmailList);
                        }
                }
            }
            if(useOrgAddress)
            {
                OrgWideEmailAddress OrgWideEmail = [Select id From OrgWideEmailAddress o where o.DisplayName= :Label.TCP_From_Email_Address];
                mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
            }
            
            mail.setSubject('Trading & Supply Chemical Portal - Complaint');
            
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception ex){
            TCP_ExceptionLogClass.insertExceptionRecord('Contact Us Email Service Expection',ex.getMessage(),'TCP_ContactUsEmailService','sendEmailOnComplaintRequest','Exception');
        } 
            }
}