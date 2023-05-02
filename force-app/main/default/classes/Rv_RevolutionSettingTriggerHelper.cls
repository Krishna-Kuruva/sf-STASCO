public class Rv_RevolutionSettingTriggerHelper {
	/*
    Version : 0.0
    Author  : Soumyajit
    Date    : 03-May-2019
    Details : Revolution Settings Trigger Helper
    */
    public static string global_reason = '';
    public static void SettingAfterUpdate(List<Revolution_Setting__c> triggeredSetting,
                                          map<id,Revolution_Setting__c> oldSettingMap,
                                          map<id,Revolution_Setting__c> newSettingMap
                                         )
    {
        
        String activeLabel = 'OLF Connection Active';
        Revolution_Setting__c olfConnSetting = new Revolution_Setting__c();
        Boolean notifyOLFStatusChange = false;
        
        for(id key : oldSettingMap.keyset())
        {
            if(oldSettingMap.get(key).name.equals(activeLabel))
            {
                if(!newSettingMap.get(key).value__c.toUpperCase().equals(oldSettingMap.get(key).value__c.toUpperCase()))
                {
                    System.debug('OLF Status Change happened');
                    olfConnSetting = newSettingMap.get(key);
                    notifyOLFStatusChange = true;
                    break;
                }
            }
        }
        
        if(notifyOLFStatusChange && olfConnSetting != null)
        {
            System.debug('Send OLF Status Mail');

            String emailTemplateLabel = '';
            if(olfConnSetting.value__c.toUpperCase().equals('TRUE'))
                emailTemplateLabel = 'ConnectionStatusActive';
            else
                emailTemplateLabel = 'ConnectionStatusInactive';
            
            User u = [select id,name from user where id = :olfConnSetting.LastModifiedById limit 1];
            
            OLF_EmailTemplate__mdt et = new OLF_EmailTemplate__mdt();
            //Added by Surbhi, PBI-1756697
            Set<String> setToAddress = new Set<String>();            
            Set<String> setCCAddress = new Set<String>();
            //Ended by Surbhi, PBI-1756697
            String emailTemplate='';
            String emailSubject='';
            String emailBody =  '';
            String dateFormat = 'dd.MM.yyyy HH:mm:ss';
            
            try{
                    et = [select EMAIL_TEMPLATE__c
                                 ,EMAIL_SUBJECT__c
                                 ,EMAIL_CC__c
                          		 ,EMAIL_TO__c
                                 ,EMAIL_CSS__c
                                 ,EMAIL_HEADER__c
                                 ,TABEL_HEADER__c
                                 ,EMAIL_FOOTER__c 
                           from OLF_EmailTemplate__mdt 
                           where MasterLabel= :emailTemplateLabel limit 1];
                }catch(Exception e){
                            system.debug('Error while finding Email Template'+e);
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
                    //Added by Surbhi, PBI-1756697
                    system.debug('Error while finding email CC :'+e);
                    setCCAddress = new Set<String>();
                    //Ended by Surbhi, PBI-1756697
                }                
                try{
                    //Added by Surbhi, PBI-1756697
                    //Fetching TO email address from EMAIL_TO_c custom field from custom metadata
                    if(String.isNotEmpty(et.EMAIL_TO__c)){
                        List<String> lstToAddress=et.EMAIL_TO__c.split(';');
                        
                        for(String toAddress : lstToAddress)
                        {
                            setToAddress.add(toAddress);
                        }
                    }
                    //Fetching TO email address from permission set 
                    List<String> lstToAddressFromPermissionSet = OLF_DashboardApexController.getUserEmailFromPermissionSet('RV_OnlineSalesManagement');                    
                    if(lstToAddressFromPermissionSet.size() > 0){
                        setToAddress.addAll(lstToAddressFromPermissionSet);
                    }
                    //Ended by Surbhi, PBI-1756697
                }catch(Exception e){
                    system.debug('Error while finding email TO :'+e);
                    //Added by Surbhi, PBI-1756697
                    setToAddress = new Set<String>();
                    //Ended by Surbhi, PBI-1756697
                }

                emailBody = emailTemplate;
                if(et.EMAIL_CSS__c!=null)
                	emailBody = emailBody.replace('{!EMAIL_CSS__C}', et.EMAIL_CSS__c);
                if(et.EMAIL_HEADER__c!=null)
                {
                    String newEmailHeader = et.EMAIL_HEADER__c.replace('{!MODIFIED_USERNAME}',u.name);
                    newEmailHeader = newEmailHeader.replace('{!MODIFIED_TIME}',System.now().format(dateFormat));
                    newEmailHeader = newEmailHeader.replace('{!REASON}', global_reason);
                    emailBody = emailBody.replace('{!EMAIL_HEADER__C}', newEmailHeader);
                }
                if(et.EMAIL_FOOTER__c!=null)
                	emailBody = emailBody.replace('{!EMAIL_FOOTER__C}', et.EMAIL_FOOTER__c);
                //Added by Surbhi, PBI-1756697
                System.debug('setToAddress='+setToAddress);
                System.debug('setCCAddress='+setCCAddress);
                //Ended by Surbhi, PBI-1756697
                
                System.debug('emailSubject='+emailSubject);
                System.debug('emailBody='+emailBody);
                
                //Added by Surbhi, PBI-1756697
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
                             system.debug('Error while sending email :'+e);
                        }
                    }
            }
            else
                system.debug('Else part Error');
        }
        
    }
}