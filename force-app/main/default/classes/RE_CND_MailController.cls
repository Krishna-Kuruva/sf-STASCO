/**************************************************************************************************
* Name: RE_CND_MailController
* Object: RE_MY_CostPrice__c, RE_MY_Output__c
* Purpose: This class is developing custom conga solution for Revolution Canada Mail Data
* Author: Sunidhi Pandey (sunidhi.pandey@shell.com)
* Create Date: 2021-11-02
* Modify History: 
* 2021-11-18		Sunidhi Pandey		Created
**************************************************************************************************/
public class RE_CND_MailController {
    private String partnerServerUrl;
    public static String sessId = ''+System.UserInfo.getSessionId();
    public static String partnerServerUrl = URL.getSalesforceBaseUrl().toExternalForm()+System.Label.RE_BaseURL+UserInfo.getOrganizationId();
    
    // For sending Internal Rack Notification 
    @future(callout=true)
    public static void rackNotificationUrl(boolean selfMail,Map<String,String> EmailIdMap) 
    {
        try{     
            String CNDOutputUrl;    
            Boolean isUserAddedToBcc = False;           
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Newrack4'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Internal Rack Notification'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c like \'' + 'RackCustomerNotification' + '%\' or APXTConga4__Name__c = \'Canada Date Query\') ';
            String CongaUrlPart2 = fetchQueryDetails(qry);
                        
            if(selfMail)
            {
                 CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0'; 

                if(CNDOutputUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDOutputUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);                    
                    HttpResponse rsp = http.send(request); 
                    system.debug('Internal Rack Notification(To Me) - Email Sent Successfully');
                }
            }
            else
            { 
				for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Internal Rack Notification-1');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Internal Rack Notification-2');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Internal Rack Notification-3');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Internal Rack Notification-4');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Internal Rack Notification-5');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Internal Rack Notification-6');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Internal Rack Notification-7');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDOutputUrl');
                        CNDOutputUrl = null;
                    }
                    
                    if(CNDOutputUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDOutputUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request);
                        system.debug('Internal Rack Notification - Email Sent Successfully');
                    } 
                    
                    isUserAddedToBcc = True;
                }
            }            
        } 
        catch(Exception ex)
        {
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','rackNotificationUrl','Exception');
        }
    }
    
    // For sending Internal Shell Canada Rack Notification 
    @future(callout=true)
    public static void  shellCanadaRackNotiUrl(boolean selfMail,Map<String,String> EmailIdMap) 
    {
        try{  
            String  CNDRackChangeUrl; 
            Boolean isUserAddedToBcc = False;           
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Daily Rack Change Notification'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Shell Canada Rack Notification'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
    
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c like \'' + 'RackChangeNotification' + '%\' or APXTConga4__Name__c = \'Canada Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry);
            
            if(selfMail)
            {
                CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment'; 
                
                if(CNDRackChangeUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDRackChangeUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);                    
                    HttpResponse rsp = http.send(request);   
                    system.debug('Shell Canada Rack Notification(To Me) - Email Sent Successfully');
                }  
            }
            else
            {
                for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Shell Canada Rack Notification-1');
                        CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Shell Canada Rack Notification-2');
                        CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Canada Rack Notification-3');
                        CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Shell Canada Rack Notification-4');
                        CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Canada Rack Notification-5');
                        CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Shell Canada Rack Notification-6');
                        CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Canada Rack Notification-7');
                        CNDRackChangeUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDRackChangeUrl');
                        CNDRackChangeUrl = null;
                    }
                    
                    if(CNDRackChangeUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDRackChangeUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);    
                        HttpResponse rsp = http.send(request);
                        system.debug('Shell Canada Rack Notification - Email Sent Successfully');
                    }
                    
                    isUserAddedToBcc = True;
                }   
            }
        }
        catch(Exception ex)
        {
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','shellCanadaRackNotiUrl','Exception');
        } 
    }
    
    // For sending Shell Canada BRPP Notification 
    @future(callout=true)
    public static void canadaBRPPNotiUrl(boolean selfMail,Map<String,String> EmailIdMap) 
    {
        try{
            String  CNDBPRRUrl;  
            Boolean isUserAddedToBcc = False;
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'NewBRPP'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Internal Shell Canada BRPP Notification'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c like \'' + 'NewBAPP' + '%\' or APXTConga4__Name__c = \'Canada Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry);            
            
            if(selfMail)
            {
                CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment'; 
                
                if(CNDBPRRUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDBPRRUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);               
                    HttpResponse rsp = http.send(request);
					system.debug('Internal Shell Canada BRPP Notification(To Me) - Email Sent Successfully');                    
                }  
            }
            else
            {
                for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Internal Shell Canada BRPP Notification-1');
                        CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Internal Shell Canada BRPP Notification-2');
                        CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Internal Shell Canada BRPP Notification-3');
                        CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Internal Shell Canada BRPP Notification-4');
                        CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Internal Shell Canada BRPP Notification-5');
                        CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Internal Shell Canada BRPP Notification-6');
                        CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Internal Shell Canada BRPP Notification-7');
                        CNDBPRRUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDBPRRUrl');
                        CNDBPRRUrl = null;
                    }
                    
                    if(CNDBPRRUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDBPRRUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request);  
                        system.debug('Internal Shell Canada BRPP Notification - Email Sent Successfully');                    
                    }  
                    
                    isUserAddedToBcc = True;
                }   
            } 
        }
        catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','canadaBRPPNotiUrl','Exception');
        }
    }
    
    // For sending SFJ Rack Notification 
    @future(callout=true)
    public static void sfjRackNotiUrl(boolean selfMail,Map<String,String> EmailIdMap) {
        try{
            String  CNDSFJUrl; 
            Boolean isUserAddedToBcc = False;
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Rack Customer Notification'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'SFJ Rack notification'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c like \'' + 'RackCustomerNotification' + '%\' or APXTConga4__Name__c = \'Canada Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry);    
            
            if(selfMail)
            {
                CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment'; 
                
                if(CNDSFJUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDSFJUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);                    
                    HttpResponse rsp = http.send(request); 
                    system.debug('SFJ Rack notification(To Me) - Email Sent Successfully');                    
                }  
            }
            else
            {
                for(String target : EmailIdMap.values())
                {           
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('SFJ Rack notification-1');
                        CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('SFJ Rack notification-2');
                        CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }             
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('SFJ Rack notification-3');
                        CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('SFJ Rack notification-4');
                        CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('SFJ Rack notification-5');
                        CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('SFJ Rack notification-6');
                        CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('SFJ Rack notification-7');
                        CNDSFJUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDSFJUrl');
                        CNDSFJUrl = null;
                    }
                    
                    if(CNDSFJUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDSFJUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request);
                        system.debug('SFJ Rack notification - Email Sent Successfully');  
                    }  
                    
                    isUserAddedToBcc = True;
                }   
            } 
        }
        catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','sfjRackNotiUrl','Exception');
        }
    }
    
    // For sending Canadian Rack Prices Notification 
    @future(callout=true)
    public static void cndRackPricesUrl(boolean selfMail,Map<String,String> EmailIdMap) {
        try{
            String  CNDRackPriceUrl;    
            Boolean isUserAddedToBcc = False;
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Canadiandailyracks'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Canadian Rack Prices'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c = \'Canada Daily Rack\' or APXTConga4__Name__c = \'Canada Cost Price Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry);            
            
            if(selfMail)
            {
                CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment'; 
                
                if(CNDRackPriceUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDRackPriceUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);              
                    HttpResponse rsp = http.send(request);  
                    system.debug('Canadian Rack Prices(To Me) - Email Sent Successfully');  
                } 
            }
            else
			{
                for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Canadian Rack Prices-1');
                        CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Canadian Rack Prices-2');
                        CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Canadian Rack Prices-3');
                        CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Canadian Rack Prices-4');
                        CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Canadian Rack Prices-5');
                        CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Canadian Rack Prices-6');
                        CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Canadian Rack Prices-7');
                        CNDRackPriceUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDRackPriceUrl');
                        CNDRackPriceUrl = null;
                    }
                    
                    if(CNDRackPriceUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDRackPriceUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);          
                        HttpResponse rsp = http.send(request);
                        system.debug('Canadian Rack Prices - Email Sent Successfully'); 
                    } 
                    
                    isUserAddedToBcc = True;
                }   
            } 
        }
        catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','cndRackPricesUrl','Exception');
        }
    }
    
    // For sending 7 Day Canadian Rack Prices Notification  
    @future(callout=true)
    public static void cndRackPrice7Day(boolean selfMail,Map<String,String> EmailIdMap) {
        try{            
            String  CNDRackPrice7DayUrl;   
            Boolean isUserAddedToBcc = False;
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Canadiandailyracks7DAY'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = '7 DAY Canadian Rack Prices'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            
			String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c = \'Canada Daily Rack 7 Day\' or APXTConga4__Name__c = \'Canada Cost Price Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry);            
            
            if(selfMail)
            {
                CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment'; 
                
                if(CNDRackPrice7DayUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDRackPrice7DayUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);              
                    HttpResponse rsp = http.send(request); 
                    system.debug('7 DAY Canadian Rack Prices(To Me) - Email Sent Successfully'); 
                } 
            }
            else
            {
                for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('7 DAY Canadian Rack Prices-1');
                        CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('7 DAY Canadian Rack Prices-2');
                        CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('7 DAY Canadian Rack Prices-3');
                        CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('7 DAY Canadian Rack Prices-4');
                        CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('7 DAY Canadian Rack Prices-5');
                        CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('7 DAY Canadian Rack Prices-6');
                        CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('7 DAY Canadian Rack Prices-7');
                        CNDRackPrice7DayUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDRackPrice7DayUrl');
                        CNDRackPrice7DayUrl = null;
                    }
                    
                    if(CNDRackPrice7DayUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDRackPrice7DayUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request);
                        system.debug('7 DAY Canadian Rack Prices - Email Sent Successfully'); 
                    } 
                    
                    isUserAddedToBcc = True;
                }   
            } 
        }
        catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','cndRackPrice7Day','Exception');
        }
    }

    // For sending Shell Rack Customer Notification
    @future(callout=true)
    public static void shellRackCustomer(boolean selfMail,Map<String,String> EmailIdMap) 
	{
        try{
            String  rackCustomerUrl;    
            Boolean isUserAddedToBcc = False;
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Rack Customer Notification'].Id;
            String TempId2     = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'rack_prices'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Shell Rack Customer Notification'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c like \'' + 'RackCustomerNotification' + '%\' or APXTConga4__Name__c = \'Canada Rack Prices\' or APXTConga4__Name__c = \'Canada Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry); 
            
            if(selfMail)
            {
                rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0'; 
                
                if(rackCustomerUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(rackCustomerUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);              
                    HttpResponse rsp = http.send(request); 
                    system.debug('Shell Rack Customer Notification(To Me) - Email Sent Successfully'); 
                } 
            }
            else
            {
                for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    system.debug('toEmailIds-->'+EmailIds);
                    system.debug('ccEmailIds-->'+ccEmailIds);
                    system.debug('bccEmailIds-->'+bccEmailIds);
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Shell Rack Customer Notification-1');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Shell Rack Customer Notification-2');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Rack Customer Notification-3');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Shell Rack Customer Notification-4');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Rack Customer Notification-5');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Shell Rack Customer Notification-6');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Rack Customer Notification-7');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[Rack+Customer+Notification]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }
                    else
                    {
                        System.debug('Condition mismatch rackCustomerUrl');
                        rackCustomerUrl = null;
                    }
                    
                    if(rackCustomerUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(rackCustomerUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request); 
                        system.debug('Shell Rack Customer Notification - Email Sent Successfully'); 
                    }  
                    
                    isUserAddedToBcc = True;
                }   
            } 
        }
        catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','shellRackCustomer','Exception');
        }    
    }

    // For Canadian Rack Pricing and rack pricing Files
    @future(callout=true)
    public static void CanadianRackPricing(boolean selfMail,Map<String,String> EmailIdMap) {
        try{
            String  rackCustomerUrl;    
            Boolean isUserAddedToBcc = False;
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'canadian-rack-pricing'].Id;
            String TempId2     = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'rack_prices'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Canadian Rack Pricing and rack pricing Files'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            
			String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c like \'' + 'CanadianRackPricing' + '%\' or APXTConga4__Name__c = \'Canada Rack Prices\' or APXTConga4__Name__c = \'Canada Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry);             
            
            if(selfMail)
            {
                rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0'; 
                
                if(rackCustomerUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(rackCustomerUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);              
                    HttpResponse rsp = http.send(request); 
                    system.debug('Canadian Rack Pricing and rack pricing Files(To Me) - Email Sent Successfully'); 
                } 
            }
            else
            {
                for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Canadian Rack Pricing and rack pricing Files-1');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Canadian Rack Pricing and rack pricing Files-2');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Canadian Rack Pricing and rack pricing Files-3');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Canadian Rack Pricing and rack pricing Files-4');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Canadian Rack Pricing and rack pricing Files-5');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Canadian Rack Pricing and rack pricing Files-6');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Canadian Rack Pricing and rack pricing Files-7');
                        rackCustomerUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId=[canadian-rack-pricing]'+TempId+',[rack_prices]'+TempId2+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }
                    else
                    {
                        System.debug('Condition mismatch rackCustomerUrl');
                        rackCustomerUrl = null;
                    }
                    
                    if(rackCustomerUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(rackCustomerUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request); 
                        system.debug('Canadian Rack Pricing and rack pricing Files - Email Sent Successfully'); 
                    }  
                    
                    isUserAddedToBcc = True;
                }   
            } 
        }
        catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','CanadianRackPricing','Exception');
        }    
    }        
    
    // For sending Branded Customer Notification
    @future(callout=true)
    public static void brandedCustomer(boolean selfMail,Date reqFrmDate,Map<String,String> EmailIdMap) {
        try{
            String  brandedUrl;     
            Boolean isUserAddedToBcc = False;
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Pricing English'].Id;
            String TempId2     = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Prix en francais'].Id;
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Shell Canada - Branded Customer Notification'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            String frmdtFormat =  DateTime.newInstance(reqFrmDate.year(),reqFrmDate.month(),reqFrmDate.day()).format('MM-dd-YY');
            
			String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND (APXTConga4__Name__c like \'' + 'RackCustomerNotification' + '%\' or APXTConga4__Name__c like \'' + 'BrandedNotificationExternalWeb' + '%\' or APXTConga4__Name__c like \'' + 'BrandedNotificationChangeAmount' + '%\' or APXTConga4__Name__c = \'Canada Date Query\') ';            
            String CongaUrlPart2 = fetchQueryDetails(qry); 
            
            if(selfMail)
            {
                
                brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+ frmdtFormat +'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0'; 

                if(brandedUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(brandedUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);              
                    HttpResponse rsp = http.send(request); 
                    system.debug('Shell Canada - Branded Customer Notification(To Me) - Email Sent Successfully'); 
                }         
            }
            else
            {
				for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');                    
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Shell Canada - Branded Customer Notification-1');
                        brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+frmdtFormat+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Shell Canada - Branded Customer Notification-2');
                        brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+frmdtFormat+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }             
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Canada - Branded Customer Notification-3');
                        brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+frmdtFormat+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Shell Canada - Branded Customer Notification-4');
                        brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+frmdtFormat+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Canada - Branded Customer Notification-5');
                        brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+frmdtFormat+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Shell Canada - Branded Customer Notification-6');
                        brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+frmdtFormat+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Shell Canada - Branded Customer Notification-7');
                        brandedUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&TemplateId='+TempId+','+TempId2+'&OFN={Template.Label}+'+frmdtFormat+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment&ZipFiles=0';
                    }
                    else
                    {
                        System.debug('Condition mismatch brandedUrl');
                        brandedUrl = null;
                    }
                    
                    if(brandedUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(brandedUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);         
                        HttpResponse rsp = http.send(request);
                        system.debug('Shell Canada - Branded Customer Notification - Email Sent Successfully'); 
                    } 
                    
                    isUserAddedToBcc = True;
                }   
            } 
        }
        catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','brandedCustomer','Exception');
        }
    }
    
    // For sending No Revised Pricing 
    @future(callout=true)
    public static void noRevisedPricingUlr(boolean selfMail,Map<String,String> EmailIdMap) 
    {
        try{     
            String CNDOutputUrl;    
            Boolean isUserAddedToBcc = False;           
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'No Revised Pricing'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND APXTConga4__Name__c = \'Canada Date Query\' ';
            String CongaUrlPart2 = fetchQueryDetails(qry);
                        
            if(selfMail)
            {
                 CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1'; 

                if(CNDOutputUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDOutputUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);                    
                    HttpResponse rsp = http.send(request); 
                    system.debug('No Revised Pricing(To Me) - Email Sent Successfully');
                }
            }
            else
            { 
				for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('No Revised Pricing-1');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('No Revised Pricing-2');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('No Revised Pricing-3');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('No Revised Pricing-4');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('No Revised Pricing-5');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('No Revised Pricing-6');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('No Revised Pricing-7');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDOutputUrl');
                        CNDOutputUrl = null;
                    }
                    
                    if(CNDOutputUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDOutputUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request);
                        system.debug('No Revised Pricing - Email Sent Successfully');
                    } 
                    
                    isUserAddedToBcc = True;
                }
            }            
        } 
        catch(Exception ex)
        {
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','noRevisedPricingUlr','Exception');
        }
    }

    // For sending Ready to Upload Notification
    @future(callout=true)
    public static void readyToUploadNotiUlr(boolean selfMail,Map<String,String> EmailIdMap) 
    {
        try{     
            String CNDOutputUrl;    
            Boolean isUserAddedToBcc = False;           
            String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
            String userEmail   = UserInfo.getUserEmail();
            String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Ready to Upload Notification'].Id;
            
            Datetime dateToday = System.today();
            String currentDate = dateToday.format('dd-MM-yyyy');
            String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'CND CBU\' AND APXTConga4__Name__c = \'Canada Date Query\' ';
            String CongaUrlPart2 = fetchQueryDetails(qry);
                        
            if(selfMail)
            {
                 CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ userEmail +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1'; 

                if(CNDOutputUrl != null) 
                {   
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(CNDOutputUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);                    
                    HttpResponse rsp = http.send(request); 
                    system.debug('Ready to Upload Notification(To Me) - Email Sent Successfully');
                }
            }
            else
            { 
				for(String target : EmailIdMap.values())
                {
                    System.debug('Mail Start-'+target);
                    String[] mailaddressAll     = target.split('β©¶');
                    String   EmailIds = mailaddressAll[0];
                    String   ccEmailIds = mailaddressAll[1];
                    String   bccEmailIds = mailaddressAll[2];
                    
                    if((bccEmailIds != 'null') && (!isUserAddedToBcc))
                    {
                        if(bccEmailIds.right(1) == ';')
                            bccEmailIds = bccEmailIds + userEmail;
                        else
                            bccEmailIds = bccEmailIds + ';' + userEmail;
                    }                      
                    else if(!isUserAddedToBcc)
                        bccEmailIds = userEmail;
                    
                    if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Ready to Upload Notification-1');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    { 
                        System.debug('Ready to Upload Notification-2');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }              
                    else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Ready to Upload Notification-3');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
                    {   
                        System.debug('Ready to Upload Notification-4');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Ready to Upload Notification-5');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }                    
                    else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
                    {
                        System.debug('Ready to Upload Notification-6');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }
                    else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
                    {
                        System.debug('Ready to Upload Notification-7');
                        CNDOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                            '&solmgr='+1+'&ds7=13&APIMODE=12&SC0=1';
                    }
                    else
                    {
                        System.debug('Condition mismatch CNDOutputUrl');
                        CNDOutputUrl = null;
                    }
                    
                    if(CNDOutputUrl != null) 
                    {   
                        HTTP http = new HTTP();
                        HTTPRequest request = new HTTPRequest();
                        request.setEndpoint(CNDOutputUrl);
                        request.setMethod('GET');
                        request.setTimeout(120000);                        
                        HttpResponse rsp = http.send(request);
                        system.debug('Ready to Upload Notification - Email Sent Successfully');
                    } 
                    
                    isUserAddedToBcc = True;
                }
            }            
        } 
        catch(Exception ex)
        {
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            
            RV_ClassException.insertExceptionRecord('RE_CND_MailController',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_MailController','readyToUploadNotiUlr','Exception');
        }
    }    
  
    //fetching Query data
    public static String fetchQueryDetails(String qry)
    {
        Map<String,Id>  mapQueryId = new Map<String,Id>(); 
        Set<String> Querylist = new Set<String>();
        List<APXTConga4__Conga_Merge_Query__c> congQry;
        
        congQry = Database.query(qry);
        
        for(APXTConga4__Conga_Merge_Query__c queryData : congQry){
            Querylist.add(queryData.APXTConga4__Name__c);
        }
        
        //fetching the alias and the query data using the query names
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [
            SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c FROM APXTConga4__Conga_Solution_Query__c 
            WHERE APXTConga4__Conga_Query_Name__c IN : Querylist
        ];
        
        for(APXTConga4__Conga_Solution_Query__c apexconga: lstApexConga){
            mapQueryId.put(apexconga.APXTConga4__Alias__c,apexconga.APXTConga4__Conga_Query__c);
        }
        
        //creating part of conga url
        String CongaUrlPart2= '&QueryId=';
        for(String congaQueryData : mapQueryId.keySet()){
            CongaUrlPart2 = CongaUrlPart2+'['+congaQueryData+']'+ mapQueryId.get(congaQueryData)+',';
        }
        CongaUrlPart2= CongaUrlPart2.removeEnd(','); //removing the end comma
        return  CongaUrlPart2;
    }
    
}