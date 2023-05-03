public with sharing class TCP_MyCompanyUsersEmailService {
    public static string tcpAccountRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TCP_Account').getRecordTypeId();
    public static void sendEmailOnEditRequest(String AccountId,string[] toEmails,String firstName, String lastName, String email, String comment,String companyName, String shellConName,Boolean useOrgAddress){
          if(comment==null){
            comment='';
        }
        comment=comment.replace('\n', '<br>');
        String body='<html><body>'+
            '<font face="verdana" size="2"><table><tr>'+
            '<td style="background: #FFFFFF; border: solid #FFFFFF; border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;" >'+
            'Dear '+ UserInfo.getFirstName()+','+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you for contacting us. We will do our best to reply to you within one working day.</p>'+
            '<p align="Left"><b>Recorded details for portal user change request:</b>'+
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
            '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Email+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+email+'</td>'+
            '</tr>'+'<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Change_requested+
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
            
            mail.setSubject('Trading & Supply Chemical Portal - User change request for '+firstName+' '+lastName);
            
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            
        }        
    }
     public static void sendEmailOnDeleteRequest(String AccountId,string[] toEmails,String firstName, String lastName, String email, String comment,String deleteReason,String companyName, String shellConName,Boolean useOrgAddress){
          if(comment==null){
            comment='';
        }
         comment=comment.replace('\n', '<br>');
         String body='<html><body>'+
            '<font face="verdana" size="2"><table><tr>'+
            '<td style="background: #FFFFFF; border: solid #FFFFFF; border-width: 0;font-family: verdana;font-face: verdana;font-size: 11px;" >'+
            'Dear '+ UserInfo.getFirstName()+','+
            '<p style="font-family: verdana;font-face: verdana;font-size: 11px;">Thank you for contacting us. We will do our best to reply to you within one working day.</p>'+
            '<p align="Left"><b>Recorded details for portal user deletion request:</b>'+
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
            '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Email+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+email+'</td>'+
            '</tr>'+'<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Reason_for_Deletion+
            '</th>'+
            '<td align="left" style="font-family: verdana;font-face: verdana;font-size: 11px;word-break:break-all">'+deleteReason+'</td>'+
            '</tr>'+
             '<tr><th width="15%" style="border-width: 0;font-family: verdana;font-weight:400;font-face: verdana;font-size: 11px;word-break:break-all" align="left">'+Label.TCP_Additional_Comments+
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
            
            mail.setSubject('Trading & Supply Chemical Portal - User deletion request for '+firstName+' '+lastName);
            
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            
        }        
    }
}