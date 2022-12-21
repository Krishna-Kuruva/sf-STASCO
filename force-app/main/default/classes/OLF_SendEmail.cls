public class OLF_SendEmail{
    
    public static void sendEmailtoCustomer(List<OLFWrapper.MrcPriceWrap> olfEmlWrpLst){
        String emailTemplateLabel = 'DealCreated';
        OLF_EmailTemplate__mdt et = new OLF_EmailTemplate__mdt();
        List<String> emailTo = new List<String>();
        Set<String> contactEmailSet = new Set<String>();	//EmailNotifyChange_31Jan2020_Soumyajit
        List<String> emailCC=new List<String>();
        String emailTemplate='';
        String emailSubject='';
        String emailBody =  '';
        String debugLogOn = System.label.OLF_ApexControllerDebugLogOn.toUpperCase();
        
        try{
            	et = [select EMAIL_TEMPLATE__c
                             ,EMAIL_SUBJECT__c
                             ,EMAIL_CC__c
                             ,EMAIL_CSS__c
                             ,EMAIL_HEADER__c
                             ,TABEL_HEADER__c
                             ,EMAIL_FOOTER__c 
                       from OLF_EmailTemplate__mdt 
                       where MasterLabel= :emailTemplateLabel limit 1];
			}catch(Exception e){
            			if(debugLogOn.equals('TRUE'))
                            system.debug('Error in OLF_SendEmailConfirmation.sendEmail while finding Email Template'+e);
                		et = new OLF_EmailTemplate__mdt();
                    }
        
        if(et.EMAIL_TEMPLATE__c != null)
        {  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            emailSubject=et.EMAIL_SUBJECT__c;
            emailTemplate = et.EMAIL_TEMPLATE__c;
            
            try{
                        List<String> ccList=et.EMAIL_CC__c.split(';');
                        for(String cc : ccList)
                        {
                            if(cc.length()>0)
                                emailCC.add(cc);
                        }
                    
                    }catch(Exception e){
                         if(debugLogOn.equals('TRUE'))
                            system.debug('Error in OLF_SendEmailConfirmation.sendEmail while finding email CC :'+e);
                        emailCC = new List<String>();
                    }
            
            emailBody = emailTemplate;
            if(et.EMAIL_CSS__c!=null)
            	emailBody = emailBody.replace('{!EMAIL_CSS__C}', et.EMAIL_CSS__c);
            if(et.EMAIL_HEADER__c!=null)
            	emailBody = emailBody.replace('{!EMAIL_HEADER__C}', et.EMAIL_HEADER__c);
            if(et.TABEL_HEADER__c!=null)
            	emailBody = emailBody.replace('{!TABEL_HEADER__C}', et.TABEL_HEADER__c);
            if(et.EMAIL_FOOTER__c!=null)
            	emailBody = emailBody.replace('{!EMAIL_FOOTER__C}', et.EMAIL_FOOTER__c);
            
            String emailTableBody = '';
            for(OLFWrapper.MrcPriceWrap olfEmlWrp :olfEmlWrpLst)
                {
                    emailTableBody = emailTableBody +'<tr>' 
                                                        +'<td>'+olfEmlWrp.sfdcDealNumber+'</td>'
                                                        +'<td>'+olfEmlWrp.MaterialName+'</td>'
                                                        +'<td>'+olfEmlWrp.Location+'</td>'
                                                        +'<td>'+olfEmlWrp.inputVolume+'</td>'
                                                        +'<td>'+olfEmlWrp.PricePerUnit+'</td>'
                                                        +'<td>'+olfEmlWrp.StartDate+' : '+olfEmlWrp.EndDate+'</td>'
                                                    +'</tr>';
                    //EmailNotifyChange_31Jan2020_Soumyajit starts
                    //emailTo.add(olfEmlWrp.contactEmail);	
                    if(!contactEmailSet.contains(olfEmlWrp.contactEmail))	
                    	contactEmailSet.add(olfEmlWrp.contactEmail);	
                    //EmailNotifyChange_31Jan2020_Soumyajit ends
                }
            emailBody = emailBody.replace('<!--<TABLE_BODY/>-->', emailTableBody);
            
            System.debug('contactEmailSet='+ contactEmailSet);
            
            //281404_MultipleEmail_08Jul2019_Soumyajit starts
            try{
                		List<Account> actLst=[Select Id,Rv_Olf_EmailID__c from account 
                                              where Rv_Olf_Customer_Email__c in :contactEmailSet //:emailTo //EmailNotifyChange_31Jan2020_Soumyajit
                                              and Rv_Available_for_OLF__c=:true];
                
                		if(actLst.size()>0)
                        {
                            for(Account acc : actLst)
                            {
                                List<String> toList=acc.Rv_Olf_EmailID__c.split(';');
                                for(String toMail : toList)
                                {
                                    if(toMail.length()>0 && !emailTo.contains(toMail))
                                        emailTo.add(toMail);
                                }
                                if(debugLogOn.equals('TRUE'))
                                    system.debug('Adding email To from Account record :'+toList);
                            }
                        }
                    
                    }catch(Exception e){
                         if(debugLogOn.equals('TRUE'))
                            system.debug('Error in OLF_SendEmailConfirmation.sendEmail while finding email To from Account record :'+e);
                    }
            //281404_MultipleEmail_08Jul2019_Soumyajit ends
            
            //EmailNotifyChange_31Jan2020_Soumyajit starts
            if(emailTo.size()== 0 && emailCC.size()>0)
            {
                emailTo.addAll(emailCC);
                emailCC.clear();
            }
            //EmailNotifyChange_31Jan2020_Soumyajit ends
                
            if(debugLogOn.equals('TRUE'))
            {
                System.debug('emailTo='+emailTo);
                System.debug('emailCC='+emailCC);
                System.debug('emailSubject='+emailSubject);
                System.debug('emailBody='+emailBody);
            }
            
            if(emailTo.size()>0)
                {
                    mail.setToAddresses(emailTo);
                    if(emailCC.size()>0)
                        mail.setCcAddresses(emailCC);
                    mail.setSubject(emailSubject);
                    mail.setHtmlBody(emailBody);
                    mail.setSaveAsActivity(false);
                    mail.setReplyTo('noreply@revolutionsupport.com');
                    mail.setSenderDisplayName('Revolution System Administrator');
                    
                    try{
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                    }catch(Exception e){
                         if(debugLogOn.equals('TRUE'))
                            system.debug('Error in OLF_SendEmailConfirmation.sendEmail while sending email :'+e);
                    }
                }
            else
            {
                if(debugLogOn.equals('TRUE'))
                	system.debug('To Email not found. Hence no email will be sent.');
            }
        }
        else
        {
            if(debugLogOn.equals('TRUE'))
                system.debug('Else part Error in OLF_SendEmailConfirmation.sendEmail');
        }
    }
    
}