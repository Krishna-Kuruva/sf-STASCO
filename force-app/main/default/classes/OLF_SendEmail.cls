public class OLF_SendEmail{
    
    public static void sendEmailtoCustomer(List<OLFWrapper.MrcPriceWrap> olfEmlWrpLst){
        String emailTemplateLabel = 'DealCreated';
        OLF_EmailTemplate__mdt et = new OLF_EmailTemplate__mdt();
        Set<String> contactEmailSet = new Set<String>();	//EmailNotifyChange_31Jan2020_Soumyajit
        String emailTemplate='';
        String emailSubject='';
        String emailBody =  '';
        String debugLogOn = System.label.OLF_ApexControllerDebugLogOn.toUpperCase();
        //Added by Surbhi, PBI-1756697
        Set<String> setToAddress = new Set<String>();            
        Set<String> setCCAddress = new Set<String>();
        //Ended by Surbhi, PBI-1756697
        
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
                //Added by Surbhi, PBI-1756697
                if(String.isNotEmpty(et.EMAIL_CC__c)){                    
                    List<String> ccList=et.EMAIL_CC__c.split(';');
                    for(String cc : ccList)
                    {
                        setCCAddress.add(cc);
                    }
                }
                //Ended by Surbhi, PBI-1756697                      
                    }catch(Exception e){
                         if(debugLogOn.equals('TRUE'))
                            system.debug('Error in OLF_SendEmailConfirmation.sendEmail while finding email CC :'+e);
                        //Added by Surbhi, PBI-1756697
                        setCCAddress = new Set<String>();
                        //Ended by Surbhi, PBI-1756697
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
                                //Added by Surbhi, PBI-1756697
                                //Fetching TO email address from EMAIL_TO_c custom field from custom metadata
                                if(String.isNotEmpty(acc.Rv_Olf_EmailID__c)){
                                    List<String> lstToAddress=acc.Rv_Olf_EmailID__c.split(';');                                    
                                    for(String toAddress : lstToAddress)
                                    {
                                        setToAddress.add(toAddress);
                                    }
                                }
                                //Ended by Surbhi, PBI-1756697
                                if(debugLogOn.equals('TRUE'))
                                    system.debug('Adding email To from Account record :'+setToAddress);
                            }
                        }
                //Added by Surbhi, PBI-1756697
                //Fetching TO email address from permission set 
                List<String> lstToAddressFromPermissionSet = OLF_DashboardApexController.getUserEmailFromPermissionSet('RV_OnlineSalesManagement');                    
                if(lstToAddressFromPermissionSet.size() > 0){
                    setToAddress.addAll(lstToAddressFromPermissionSet);
                }
                //Ended by Surbhi, PBI-1756697
                
                    }catch(Exception e){
                         if(debugLogOn.equals('TRUE'))
                            system.debug('Error in OLF_SendEmailConfirmation.sendEmail while finding email To from Account record :'+e);
                    }
            //281404_MultipleEmail_08Jul2019_Soumyajit ends
            
            //EmailNotifyChange_31Jan2020_Soumyajit starts
            // Commented by Surbhi,PBI-1756697
           /* if(emailTo.size()== 0 && emailCC.size()>0)
            {
                emailTo.addAll(emailCC);
                emailCC.clear();
            } */
            // Commented by Surbhi,PBI-1756697
            // Added by Surbhi, PBI-1756697
            if(setToAddress.size() == 0 && setCCAddress.size() > 0)
            {
                setToAddress.addAll(setCCAddress);
                setCCAddress.clear();
            }
            // Ended by Surbhi, PBI-1756697
            //EmailNotifyChange_31Jan2020_Soumyajit ends
            System.debug('setToAddress='+setToAddress);
            System.debug('setCCAddress='+setCCAddress);   
            if(debugLogOn.equals('TRUE'))
            {
                System.debug('setToAddress='+setToAddress);
                System.debug('setCCAddress='+setCCAddress);
                System.debug('emailSubject='+emailSubject);
                System.debug('emailBody='+emailBody);
            }
            
            if(setToAddress.size()>0)
                {
                    //Added by Surbhi, PBI-1756697
                    List<String> toAddresses = new List<String>();
                    toAddresses.addAll(setToAddress);
                    mail.setToAddresses(toAddresses);  
                    if(setCCAddress.size()>0){
                        List<String> ccAddresses = new List<String>();
                        ccAddresses.addAll(setCCAddress); 
                        mail.setCcAddresses(ccAddresses);
                    }
                    //Ended by Surbhi, PBI-1756697
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