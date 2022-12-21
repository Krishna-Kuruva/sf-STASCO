/**************************************************************************************************
* Name: RE_MY_DataAnalysisReportQueue
* Object: RE_MY_Output__c
* Purpose: Used for Malaysis Data Analysis Report geneartion
* Author: Abhilash KT (abhilash.kt@shell.com)
* Create Date: 2022-09-29
* Modify History: 
* 2022-09-29		Abhilash		Created
**************************************************************************************************/
public class RE_MY_DataAnalysisReportQueue implements Queueable {
    
    private String partnerServerUrl;
    public static String sessId = ''+System.UserInfo.getSessionId();
    public static String partnerServerUrl = URL.getSalesforceBaseUrl().toExternalForm()+System.Label.RE_BaseURL+UserInfo.getOrganizationId();
    private RE_Job_Run_Audit__c jra;
    
    public RE_MY_DataAnalysisReportQueue(RE_Job_Run_Audit__c jobAudit)
    {        
        this.jra = jobAudit;
    }
    
    public void execute(QueueableContext context) 
    {
        processMYDataAnalysisReport(jra);
    }
    
    // Processing MY Data Analysis Report 
    public static void processMYDataAnalysisReport(RE_Job_Run_Audit__c jrAuditMY)
    {
        try
        {               
            Integer totalRecords = 0; 
            
            totalRecords = [SELECT Count() FROM RE_MY_Output__c WHERE RE_Type__c = 'Malaysia Output' and RE_Pricing_Date__c = Today 
                            and ((RE_Region__c = 'Peninsular' and RE_Depot_Name__c = 'Bagan Luar') OR (RE_Region__c = 'Peninsular' and RE_Depot_Name__c = 'KVDT') 
                                 OR (RE_Region__c = 'Peninsular' and RE_Depot_Name__c = 'Pasir Gudang') OR (RE_Region__c = 'Peninsular' and RE_Depot_Name__c = 'Port Dickson') 
                                 OR (RE_Region__c = 'Peninsular' and RE_Depot_Name__c = 'Tanjung Gelang') OR (RE_Region__c = 'Peninsular' and RE_Depot_Name__c = 'Westport') 
                                 OR (RE_Region__c = 'Sabah' and RE_Depot_Name__c = 'Kota Kinabalu') OR (RE_Region__c = 'Sabah' and RE_Depot_Name__c = 'Labuan') 
                                 OR (RE_Region__c = 'Sabah' and RE_Depot_Name__c = 'Sandakan') OR (RE_Region__c = 'Sabah' and RE_Depot_Name__c = 'Tawau') 
                                 OR (RE_Region__c = 'Sarawak' and RE_Depot_Name__c = 'Bintulu') OR (RE_Region__c = 'Sarawak' and RE_Depot_Name__c = 'IOT Senari') 
                                 OR (RE_Region__c = 'Sarawak' and RE_Depot_Name__c = 'Tg Manis'))];
            
            // If any MY Output records get created
            if(totalRecords > 0)
            {        
                Map<String,String> EmailIdMap = new Map<String,String>();
                // Getting all the email recipient list
                EmailIdMap = fetchEmailIdForOutputEmail('MY Monthly CBU Costing and Chart');  
                
                if(EmailIdMap.Size() > 0)
                    // Processing and preparing Conga Report
                    RE_MY_DataAnalysisReportQueue.myMonthlyCBUCostngChartReportUrl(EmailIdMap, jrAuditMY.Id);          
                else
                {
                    // Update Audit Job Status
                    if(jrAuditMY.RE_Job_Status__c == 'Processing')
                    {
                        jrAuditMY.RE_Job_Status__c ='Completed';    
                        jrAuditMY.Other_Comments__c = 'No active email recipients';
                        update jrAuditMY;  
                    }                    
                }              
            }
            else
            {
                jrAuditMY.RE_Job_Status__c ='Completed';    
                jrAuditMY.Other_Comments__c = 'No Malaysia Output records exists on today in RE_MY_Output__c';
                update jrAuditMY;                  
            }
        }
        Catch(Exception ex)
        {
            System.debug('processMYDataAnalysisReport-Error-->'+ex.getMessage());
            System.debug('processMYDataAnalysisReport-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('processMYDataAnalysisReport-',ex.getMessage()+'-'+ex.getLineNumber(),'RE_MY_DataAnalysisReportScheduler','processMYDataAnalysisReport','Exception'); 
            RE_CND_Utility.updateJobAudit(jrAuditMY,'Failed',ex);
        }   
    }
    
    // Fetch Email Ids from Metadata 
    public static Map<String,String> fetchEmailIdForOutputEmail(String type)
    {
        Map<String,String> mailMap = new Map<String,String>();
        List<RE_Email_Recipient__mdt> metaDataObj = (List<RE_Email_Recipient__mdt>) new RV_MetadataCoverage().getMetadataCoverageRecords('Select MasterLabel, To_List__c, Cc_List__c, Bcc_List__c, Is_Active__c, Type__c FROM RE_Email_Recipient__mdt WHERE Country__c = \'Malaysia\' AND Type__c = \'MY Monthly CBU Costing and Chart\' AND Is_Active__c = TRUE');

        for(RE_Email_Recipient__mdt mdtData : metaDataObj)
        {
            String EmailIds =    (String.isBlank(mdtData.To_List__c)) ? null : mdtData.To_List__c;
            String ccEmailIds =  (String.isBlank(mdtData.Cc_List__c)) ? null : mdtData.Cc_List__c;
            String bccEmailIds = (String.isBlank(mdtData.Bcc_List__c)) ? null : mdtData.Bcc_List__c;                    
            mailMap.put(mdtData.MasterLabel,EmailIds+'β©¶'+ccEmailIds+'β©¶'+bccEmailIds);   
            System.debug('EmailIds-->'+EmailIds);
            System.debug('ccEmailIds-->'+ccEmailIds);
            System.debug('bccEmailIds-->'+bccEmailIds);
        }
        return mailMap;
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
    
    // For sending MY Monthly CBU Costing and Chart Report 
    @future(callout=true)
    public static void myMonthlyCBUCostngChartReportUrl(Map<String,String> EmailIdMap, Id jobRunAudId) 
    {
        RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();    
        jrAuditMY = [SELECT Id, RE_Job_Status__c, RE_Exception__c, Other_Comments__c FROM RE_Job_Run_Audit__c WHERE Id =: jobRunAudId];
        
        datetime currntDt = system.now();                        
        String day = string.valueOf(currntDt.day());
        String month = string.valueOf(currntDt.month());
        String hour = string.valueOf(currntDt.hour());
        String minute = string.valueOf(currntDt.minute() + 1);
        String second = string.valueOf(currntDt.second());
        String year = string.valueOf(currntDt.year());
        String strFileGenrtnTime =  year + '-' + month + '-' + day + '-' + hour + '-' + minute + '-' + second;
        
        String MyOutputUrl = null;  
        String othrComments;
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String userEmail   = UserInfo.getUserEmail();
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'MY Monthly CBU Costing and Chart'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Malaysia Monthly CBU Costing and Chart Template'].Id;
        
        String qry = 'SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = \'MY CBU Monthly Chart\' AND (APXTConga4__Name__c like \'' + 'RE MY Monthly CBU' + '%\')';
        String CongaUrlPart2 = fetchQueryDetails(qry);
                
        for(String target : EmailIdMap.values())
        {
            System.debug('Mail Start-'+target);
            String[] mailaddressAll     = target.split('β©¶');
            String   EmailIds = mailaddressAll[0];
            String   ccEmailIds = mailaddressAll[1];
            String   bccEmailIds = mailaddressAll[2];
            
            if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds == 'null')
            {
                System.debug('MY Monthly CBU Costing and Chart-1');
                MyOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}_'+ strFileGenrtnTime + '&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            }                    
            else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
            { 
                System.debug('MY Monthly CBU Costing and Chart-2');
                MyOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}_'+ strFileGenrtnTime + '&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            }              
            else if(EmailIds != 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
            {
                System.debug('MY Monthly CBU Costing and Chart-3');
                MyOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}_'+ strFileGenrtnTime + '&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            }                    
            else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds != 'null')
            {   
                System.debug('MY Monthly CBU Costing and Chart-4');
                MyOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}_'+ strFileGenrtnTime + '&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            }                    
            else if(EmailIds== 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
            {
                System.debug('MY Monthly CBU Costing and Chart-5');
                MyOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}_'+ strFileGenrtnTime + '&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            }                    
            else if(EmailIds == 'null' && ccEmailIds != 'null' && bccEmailIds == 'null')
            {
                System.debug('MY Monthly CBU Costing and Chart-6');
                MyOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailCC='+ ccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}_'+ strFileGenrtnTime + '&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            }
            else if(EmailIds != 'null' && ccEmailIds == 'null' && bccEmailIds != 'null')
            {
                System.debug('MY Monthly CBU Costing and Chart-7');
                MyOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                    '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo='+ EmailIds+ '&EmailBCC='+ bccEmailIds +'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2  + '&sfdciframehost=web'+
                    '&solmgr='+1+'&TemplateId='+TempId+'&OFN={Template.Label}_'+ strFileGenrtnTime + '&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            }
            
            if(MyOutputUrl != null) 
            {   
                try {
                    HTTP http = new HTTP();
                    HTTPRequest request = new HTTPRequest();
                    request.setEndpoint(MyOutputUrl);
                    request.setMethod('GET');
                    request.setTimeout(120000);                     
                    HttpResponse rsp = http.send(request);
                    //HttpResponse debug messages 
                    if(String.isBlank(othrComments))
                       othrComments = 'HttpResponse Status:'+rsp.getStatus() + '- ' + 'Status_Code:'+rsp.getStatusCode() + '-Email Sent Successfully To:' + EmailIds + ';-Cc:' + ccEmailIds + ';-Bcc:' + bccEmailIds;
                    else
                       othrComments = othrComments + ';' + 'HttpResponse Status:'+rsp.getStatus() + '- ' + 'Status_Code:'+rsp.getStatusCode() + '-Email Sent Successfully To:' + EmailIds + ';-Cc:' + ccEmailIds + ';-Bcc:' + bccEmailIds;
                    
                    system.debug('MY Monthly CBU Costing and Chart - Email Sent Successfully');
                }
                catch(System.CalloutException exCal)
                {
                    System.debug('RE_MY_DataAnalysisReportQueue-Error-->'+exCal.getMessage());
                    System.debug('RE_MY_DataAnalysisReportQueue-LN-->'+exCal.getLineNumber());
                    RV_ClassException.insertExceptionRecord('RE_MY_DataAnalysisReportQueue-',exCal.getMessage()+'-'+exCal.getLineNumber(),'RE_MY_DataAnalysisReportQueue','myMonthlyCBUCostngChartReportUrl','Exception'); 
                    RE_CND_Utility.updateJobAudit(jrAuditMY,'Failed',exCal);
                }                
            }         
        }            
        
        // Update Audit Job Status
        if(jrAuditMY.RE_Job_Status__c == 'Processing')
        {
            jrAuditMY.RE_Job_Status__c ='Completed'; 
            if(othrComments.length() <= 255)
              jrAuditMY.Other_Comments__c = othrComments;
            else
               jrAuditMY.Other_Comments__c = othrComments.substring(0, 254); 
            
            update jrAuditMY;  
        }   
    }
    
}