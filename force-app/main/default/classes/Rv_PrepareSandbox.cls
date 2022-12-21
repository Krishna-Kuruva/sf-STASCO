global class Rv_PrepareSandbox implements SandboxPostCopy {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 29-Apr-2020
	Details	: Post Refresh controller class
	*/
    
    public static String invalidEmail = 'invalidEmail@test.com;';
    public static String invalidString = '.invalid';
    public static String orgName = '';
    public static Boolean checkOnly = false;
    
    global void runApexClass(SandboxContext context) {
        actionWrapper action = new actionWrapper();
        action.saveErrLst.add(saveError('Org ID: ' + context.organizationId() 
                  						+ ';Sandbox ID: ' + context.sandboxId()
                  						+ ';Sandbox Name: ' + context.sandboxName()
                                        ,'Rv_PrepareSandbox'
                                        ,'Info'));
        
        if(isSandboxOrg())
            RvGermanyRunFromSandboxRefresh();
        else
            action.saveErrLst.add(saveError('This command cannot be executed in Production','Rv_PrepareSandbox','Exception'));
        
        if(action.saveErrLst.size()>0)
            insertExceptions(action.saveErrLst);
    }
    
    global static Boolean isSandboxOrg()
    {
        Organization org = [SELECT Id, IsSandbox FROM Organization limit 1];
        return org.IsSandbox;
    }
    
    @AuraEnabled(cacheable=true)
    public static pageIniitWrapper initPage()
    {
        pageIniitWrapper returnPageIniitWrapper = new pageIniitWrapper();

        returnPageIniitWrapper.hasAccess = checkPageAccess();
        returnPageIniitWrapper.orgName = orgInstanceName();

        return returnPageIniitWrapper;
    }

    public static Boolean checkPageAccess()
    {
        Boolean hasAccess = false;
        
        if(isSandboxOrg())
        {
            Profile profileDetail = [select id,name from profile where id = :UserInfo.getProfileId() limit 1];
            if(profileDetail.name.equals('System Administrator'))
                hasAccess = true;
        }
        
        return hasAccess;
    }
    
    public static String fetchUserSessionId()
    {
         String sessionId = '';

         PageReference reportPage = Page.Rv_GetSessionIdVF;
         String vfContent = '';
         if(Test.isRunningTest())
             vfContent = 'Start_Of_Session_Id'+ UserInfo.getSessionId() +'End_Of_Session_Id';
         else
            vfContent = reportPage.getContent().toString();
         Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
         endP = vfContent.indexOf('End_Of_Session_Id');
         sessionId = vfContent.substring(startP, endP);
        
         return sessionId;
     }
    
    @AuraEnabled
    public static List<String> RvGermanyRunFromPage(List<String> runType
                                                    , Boolean isCheckOnly
                                                    , String email
                                                    , String invalidStr
                                                    , String orgNameAppend)
    {
        checkOnly = isCheckOnly;
        if(email != null)
            invalidEmail = email;
        if(invalidStr != null)
            invalidString = invalidStr;

        if(orgNameAppend != null)
            orgName = orgNameAppend;
        else
                orgName = orgInstanceName();

        List<String> returnList = new List<String>();
        actionWrapper action = new actionWrapper();

        if(checkPageAccess() && runType.size()>0)
        {
            if(runType.contains('GsapUpdate')
              || runType.contains('ITalertEmailUpdate')
              || runType.contains('OlfEmailUpdate')
              )
            {
                action.service = MetadataService.createService();
                action.service.SessionHeader.sessionId = fetchUserSessionId();
            }
            
            if(runType.contains('GsapUpdate'))
                action = gsapUrlUpdate(action,true);
            if(runType.contains('ITalertEmailUpdate'))
                action = ITalertEmailUpdate(action,true);
            if(runType.contains('OlfEmailUpdate'))
                action = OlfEmailUpdate(action,true);
            if(runType.contains('OlfConnInsert'))
                action = OLFSettingsInsert(action,false);
            if(runType.contains('OlfAccEmailUpdate'))
                action = OLFAccountEmailsInvalidate(action,false);
        }
        else
        {
            action.saveErrLst.add(saveError('This command cannot be executed in Production','RvGermanyRunFromPage','Exception'));
        }
        
        if(action.saveErrLst.size()>0)
        {
            for(RV_ClassExceptionErrors e : action.saveErrLst)
            {
                returnList.add(e.errMessage);
            System.debug(e.errMessage);}

            if(!checkOnly)
                insertExceptions(action.saveErrLst);
        }
        
        return returnList;
    }
    
    global static void RvGermanyRunFromSandboxRefresh()
    {
        actionWrapper action = new actionWrapper();
        orgName = orgInstanceName();

        if(isSandboxOrg())
        {
            action.service = MetadataService.createService();
            action = gsapUrlUpdate(action,false);
            action = ITalertEmailUpdate(action,false);
            action = OlfEmailUpdate(action,false);
            action = OLFSettingsInsert(action,false);
            action = OLFAccountEmailsInvalidate(action,false);  
        }
        else
        {
            action.saveErrLst.add(saveError('This command cannot be executed in Production','RvGermanyRunFromSandboxRefresh','Exception'));
        }
        
        if(action.saveErrLst.size()>0 && !checkOnly)
            insertExceptions(action.saveErrLst);
    }
    
    static void insertExceptions(List<RV_ClassExceptionErrors> saveErrLst)
    {
        List<RV_Exception__c> excpList = new List<RV_Exception__c>();
        
        for(RV_ClassExceptionErrors e : saveErrLst)
        {
            RV_Exception__c rvExcep = new RV_Exception__c();
            rvExcep.Status_Code__c = e.StatusCode;
            rvExcep.getMessage__c = e.errMessage;
            rvExcep.Apex_Class__c = e.className;
            rvExcep.Method_Name__c = e.methodName;
            rvExcep.Type__c = e.errType;
            excpList.add(rvExcep);
        }
        
        if(excpList.size()>0)
            String status = RV_ClassException.insertExceptionRecord(excpList);
    }
    
    static boolean setMDTCalled = false;
    static map<String,String> mdtMap = new map<String,String>();
    @TestVisible
    static void qryMDT()
    {
        mdtMap = new map<String,String>();
        
		IT_Dashboard_Setting__mdt[] setMDT = [select id, label,developername, value__c from IT_Dashboard_Setting__mdt];
        
        if(setMDT.size()>0)
        {
            for(IT_Dashboard_Setting__mdt s : setMDT)
                mdtMap.put(s.developername, s.Value__c);
        }
        
        setMDTCalled = true;
    }
    
    global static String orgInstanceName()
    {
        Organization org = [SELECT Id, InstanceName FROM Organization limit 1];
        return org.InstanceName;
    }
    
    @TestVisible
    static actionWrapper gsapUrlUpdate(actionWrapper inputWrap,Boolean callFromPage)
    {    
        String methodName = 'gsapUrlUpdate';
        if(!setMDTCalled)
            qryMDT();
        Boolean doExecute = callFromPage;
        if(mdtMap.containsKey('PostRefresh_GSAPupdate') && !callFromPage)
            try{doExecute = Boolean.valueOf(mdtMap.get('PostRefresh_GSAPupdate'));}catch(Exception e){}
        
        if(isSandboxOrg() && doExecute)
        {
            set<String> qryLabels = new set<String>{'GSAP_TestURL','GSAPTestUsername','GSAPTestPasswordEncrypted','GSAPTestEncryptKey'};
            
            if(mdtMap.containsKey('GSAP_TestURL')
              && mdtMap.containsKey('GSAPTestUsername')
              && mdtMap.containsKey('GSAPTestPasswordEncrypted')
              && mdtMap.containsKey('GSAPTestEncryptKey'))
            {
                 try{
                    Blob GSAPTestEncryptKey = EncodingUtil.base64Decode(mdtMap.get('GSAPTestEncryptKey'));
                    Blob GSAPTestPasswordEncrypted = EncodingUtil.base64Decode(mdtMap.get('GSAPTestPasswordEncrypted'));
                    Blob GSAPTestPasswordDecrypted = Crypto.decryptWithManagedIV('AES256', GSAPTestEncryptKey, GSAPTestPasswordEncrypted);
                    String GSAPTestPasswordDecryptedString = GSAPTestPasswordDecrypted.toString();

                    MetadataService.MetadataPort service = inputWrap.service;
            
                    MetadataService.ExternalDataSource gsapSource = (MetadataService.ExternalDataSource) service.readMetadata('ExternalDataSource',
                                    new String[] { 'GSAP_Connect' }).getRecords()[0];
                     
                     if(gsapSource != null)
                     {
                         if(gsapSource.endpoint.equalsIgnoreCase(mdtMap.get('GSAP_TestURL'))
                           && gsapSource.username.equals(mdtMap.get('GSAPTestUsername')))
                         {
                             inputWrap.saveErrLst.add(saveError('No Change Needed for GSAP Connection',methodName,'Info'));
                         }
                         else
                         {
                             gsapSource.endpoint = mdtMap.get('GSAP_TestURL');
                             gsapSource.username = mdtMap.get('GSAPTestUsername');
                             gsapSource.password = GSAPTestPasswordDecryptedString;

                             if(checkOnly)
                                 inputWrap.saveErrLst.add(saveError('GSAP Connection update required',methodName,'Info'));
                             else {
                                 List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[]{
                                         gsapSource
                                 });
                                 inputWrap.saveErrLst.add(saveError('GSAP Connection updated to TEST C94', methodName, 'Info'));
                             }
                         }
                     }
                }
                catch (Exception e)
                {
                    inputWrap.saveErrLst.add(saveError('Error in GSAP Connection Update ' + e.getMessage() + ' ' + e.getLineNumber(),methodName,'Exception'));
                }
            }
        }
        else
        {
            inputWrap.saveErrLst.add(saveError('GSAP Connection Update cannot be executed',methodName,'Exception'));
        }
        
        return inputWrap;
    }
    
    @TestVisible
    static actionWrapper ITalertEmailUpdate(actionWrapper inputWrap,Boolean callFromPage)
    {
 		String methodName = 'ITalertEmailUpdate';
        String sandboxName = orgName;
        if(!setMDTCalled)
            qryMDT();
        Boolean doExecute = callFromPage;
        if(mdtMap.containsKey('PostRefresh_EmailTemplateUpdate') && !callFromPage)
            try{doExecute = Boolean.valueOf(mdtMap.get('PostRefresh_EmailTemplateUpdate'));}catch(Exception e){}
        
        if(isSandboxOrg() && doExecute)
        {
            try{
             String emailTemplateLabel = 'default';
             IT_Alert_Email_Template__mdt et = [select EMAIL_SUBJECT__c from IT_Alert_Email_Template__mdt 
                                                where MasterLabel= :emailTemplateLabel limit 1];
             if(et != null)
             {
                 map<String,String> setValMap = new map<String,String>{'EMAIL_CC__c' => invalidEmail
                     												,'EMAIL_TO__c' => invalidEmail
                													, 'EMAIL_SUBJECT__c' => sandboxName + ' : Revolution IT Dashboard Alert'};
                                                                    
                 MetadataService.MetadataPort service = inputWrap.service;
                 List<MetadataService.CustomMetadataValue> updateValueLst = new List<MetadataService.CustomMetadataValue>();
                 
                 MetadataService.CustomMetadata ITAlertEmailMdt = (MetadataService.CustomMetadata) service.readMetadata('CustomMetadata',
                                    new String[] { 'IT_Alert_Email_Template__mdt.'+emailTemplateLabel }).getRecords()[0];
				 if(ITAlertEmailMdt !=null)
                 {
                     map<String,String> valMap = new map<String,String>();
                     for(MetadataService.CustomMetadataValue val : ITAlertEmailMdt.values)
                     	valMap.put(val.field,val.value);
                     
                     if(valMap.size()>0)
                     {
                         for(String fld : setValMap.keySet())
                         {
                             if(valMap.containsKey(fld))
                             {
                                 if(valMap.get(fld) != null) {
                                     if (!valMap.get(fld).equals(setValMap.get(fld))) {
                                         MetadataService.CustomMetadataValue val = new MetadataService.CustomMetadataValue();
                                         val.field = fld;
                                         val.value = setValMap.get(fld);
                                         updateValueLst.add(val);
                                     }
                                 }
                                 else {
                                     MetadataService.CustomMetadataValue val = new MetadataService.CustomMetadataValue();
                                     val.field = fld;
                                     val.value = setValMap.get(fld);
                                     updateValueLst.add(val);
                                 }
                             }
                         }
                         
                         if(updateValueLst.size()>0)
                         {
                             ITAlertEmailMdt.values = updateValueLst;
                             try{
                                 if(checkOnly)
                                     inputWrap.saveErrLst.add(saveError('IT Alert Email Update Needed to Append ' + orgName + ' and/or ' + invalidEmail,methodName,'Info'));
                                 else {
                                     List<MetadataService.SaveResult> resultsITAlertEmailMdt = service.updateMetadata(new MetadataService.Metadata[]{
                                             ITAlertEmailMdt
                                     });
                                     inputWrap.saveErrLst.add(saveError('IT Alert Email Update Completed to Append ' + orgName + ' and/or ' + invalidEmail, methodName, 'Info'));
                                 }
                             }
                             catch(Exception e)
                             {
                      			 inputWrap.saveErrLst.add(saveError('Error in IT Alert Email Update ' + e.getMessage() + ' ' + e.getLineNumber(),methodName,'Exception'));
                             }
                         }
                         else
                         {
                             inputWrap.saveErrLst.add(saveError('No change Needed for IT Alert Email',methodName,'Info'));
                         }
                     }
                 }
             }
            }
            catch (Exception e)
               {saveError('Error during IT Alert Email Update ' + e.getMessage() + ' ' + e.getLineNumber(),methodName,'Exception');}
        }
        else
        {
            inputWrap.saveErrLst.add(saveError('IT Alert Email Update Cannot be Executed',methodName,'Exception'));
        }
        return inputWrap;
    }
        
    @TestVisible
    static actionWrapper OlfEmailUpdate(actionWrapper inputWrap,Boolean callFromPage)
    {
        String methodName = 'OlfEmailUpdate';
        String sandboxName = orgName;
        if(!setMDTCalled)
            qryMDT();
        Boolean doExecute = callFromPage;
        if(mdtMap.containsKey('PostRefresh_OlfEmailTemplateUpdate') && !callFromPage)
            try{doExecute = Boolean.valueOf(mdtMap.get('PostRefresh_OlfEmailTemplateUpdate'));}catch(Exception e){}
        
        if(isSandboxOrg() && doExecute)
        {
            try{
             map<String,String> OLFemailTemplateLabelMap = new map<String,String>{'DealCreated' => 'Deal Confirmation online Deals'
                 																,'ConnectionStatusActive' => 'OLF Connection Activated'
                 																,'ConnectionStatusInactive' => 'OLF Connection Deactivated'};
             OLF_EmailTemplate__mdt[] ot = [select MasterLabel, EMAIL_SUBJECT__c from OLF_EmailTemplate__mdt 
                                                where MasterLabel in :OLFemailTemplateLabelMap.keySet() ];
             if(ot.size()>0)
             {
                 map<String,OLF_EmailTemplate__mdt> otMap = new map<String,OLF_EmailTemplate__mdt>();
                 for(OLF_EmailTemplate__mdt o : ot)
                     otMap.put(o.MasterLabel,o);
                 
                 List<String> OLFEmailMdtLst = new List<String>();
                 map<String,map<String,String>> setMdtValueMap= new map<String,map<String,String>>();
                 for(String otLabel : otMap.keySet())
                 {
                     OLFEmailMdtLst.add('OLF_EmailTemplate__mdt.' + otLabel);
                     map<String,String> setValMap = new map<String,String>{'EMAIL_CC__c' => invalidEmail
                     												,'EMAIL_TO__c' => invalidEmail
                													,'EMAIL_SUBJECT__c' => sandboxName + ' : ' + OLFemailTemplateLabelMap.get(otLabel)};
                     setMdtValueMap.put(otLabel,setValMap);
                 }
                 
                 MetadataService.MetadataPort service = inputWrap.service;
                 
                 List<MetadataService.CustomMetadata> OLFEmailMdt = (List<MetadataService.CustomMetadata>) 
                     											service.readMetadata('CustomMetadata', OLFEmailMdtLst).getRecords();
                 
                 if(OLFEmailMdt !=null)
                 {
                     List<MetadataService.CustomMetadata> updateOLFEmailMdt = new List<MetadataService.CustomMetadata>();
                     
                     for(MetadataService.CustomMetadata mdt : OLFEmailMdt)
                     {
                         map<String,String> valMap = new map<String,String>();
                         for(MetadataService.CustomMetadataValue val : mdt.values)
                             valMap.put(val.field,val.value);

						 map<String,String> setValMap = setMdtValueMap.get(mdt.label);
                         List<MetadataService.CustomMetadataValue> updateValueLst = new List<MetadataService.CustomMetadataValue>();
                         
                         if(valMap.size()>0)
                         {
                             for(String fld : setValMap.keySet())
                             {
                                 if(valMap.containsKey(fld))
                                 {
                                     if(valMap.get(fld) != null) {
                                         if (!valMap.get(fld).equals(setValMap.get(fld))) {
                                             MetadataService.CustomMetadataValue val = new MetadataService.CustomMetadataValue();
                                             val.field = fld;
                                             val.value = setValMap.get(fld);
                                             updateValueLst.add(val);
                                         }
                                     }
                                     else {
                                         MetadataService.CustomMetadataValue val = new MetadataService.CustomMetadataValue();
                                         val.field = fld;
                                         val.value = setValMap.get(fld);
                                         updateValueLst.add(val);
                                     }
                                 }
                             }
                         }
                         
                         if(updateValueLst.size()>0)
                         {
                             mdt.values = updateValueLst;
                             updateOLFEmailMdt.add(mdt);
                         }
                         
                     }
                     
                     if(updateOLFEmailMdt.size()>0)
                     {
                         try{
                                 if(checkOnly)
                                     inputWrap.saveErrLst.add(saveError('OLF Email Template Update Needed to Append ' + orgName + ' and/or ' + invalidEmail,methodName,'Info'));
                                 else {
                                     List<MetadataService.SaveResult> resultsOLFEmailMdt = service.updateMetadata(updateOLFEmailMdt);
                                     inputWrap.saveErrLst.add(saveError('OLF Email Template Update Completed to Append ' + orgName + ' and/or ' + invalidEmail, methodName, 'Info'));
                                 }
                             }
                             catch(Exception e)
                             {
                      			 inputWrap.saveErrLst.add(saveError('Error in OLF Email Template Update ' + e.getMessage() + ' ' + e.getLineNumber(),methodName,'Exception'));
                             }
                     }
                     else
                         {
                             inputWrap.saveErrLst.add(saveError('No change Needed for OLF Email Templates',methodName,'Info'));
                         }
                 }
             }
            }
            catch (Exception e)
               {
                   inputWrap.saveErrLst.add(saveError('Error during OLF Email Template Update '+ e.getMessage() + ' ' + e.getLineNumber(),methodName,'Exception'));
               }
        }
        else
        {
            inputWrap.saveErrLst.add(saveError('OLF Email Template Update Cannot be Executed',methodName,'Exception'));
        }
        return inputWrap;
    }
    
    @TestVisible
    static actionWrapper OLFSettingsInsert(actionWrapper inputWrap,Boolean callFromPage)
    {
        String methodName = 'OLFSettingsInsert';
        if(!setMDTCalled)
            qryMDT();
        Boolean doExecute = callFromPage;
        if(mdtMap.containsKey('PostRefresh_OLFsettingsInsert') && !callFromPage)
            try{doExecute = Boolean.valueOf(mdtMap.get('PostRefresh_OLFsettingsInsert'));}catch(Exception e){}
        
        if(isSandboxOrg() && doExecute)
        {
            User u = [select id, username from user where name='OLF Integration User' limit 1];
            map<String,String> setValMap = new map<String,String>{'OLF Username' => ((u != null) ? u.username : '')
                												, 'OLF Connection Active' => 'TRUE'};
                
            Revolution_Setting__c[] revSettings = [select id, name, value__c 
                                                   from Revolution_Setting__c
                                                  where name in :setValMap.keySet()];
            Map<String,Revolution_Setting__c> rsMap = new Map<String,Revolution_Setting__c>();
            Map<String,Revolution_Setting__c> rsUpsert = new Map<String,Revolution_Setting__c>();
            
            for(Revolution_Setting__c rs : revSettings)
                rsMap.put(rs.name,rs);
            
            for(string s : setValMap.keySet())
            {
                if(rsMap.containsKey(s))
                {
                    if(!setValMap.get(s).equals(rsMap.get(s).value__c))
                    {
                        rsMap.get(s).value__c= setValMap.get(s);
                        rsUpsert.put(s,rsMap.get(s));
                    }
                }
                else
                {
                    Revolution_Setting__c rs = new Revolution_Setting__c();
                    rs.name=s;
                    rs.value__c= setValMap.get(s);
                    rsUpsert.put(rs.name,rs);
                }
            }  
            
            if(rsUpsert.size()>0)
            {
                try{
                    if(checkOnly)
                        inputWrap.saveErrLst.add(saveError('OLF Settings Update Needed',methodName,'Info'));
                    else {
                        upsert rsUpsert.values();
                        inputWrap.saveErrLst.add(saveError('OLF Settings Update Completed', methodName, 'Info'));
                    }
                }
                catch(Exception e)
                {
                    inputWrap.saveErrLst.add(saveError('Error in OLF Settings Update',methodName,'Exception'));
                }
            }
            else
            {
                inputWrap.saveErrLst.add(saveError('No update Needed to OLF Settings',methodName,'Info'));
            }
        }
        else
        {
            inputWrap.saveErrLst.add(saveError('OLF Settings Update Cannot be Executed',methodName,'Exception'));
        }
        
        return inputWrap;
    }
    
    @TestVisible
    static actionWrapper OLFAccountEmailsInvalidate(actionWrapper inputWrap,Boolean callFromPage)
    {
        String methodName = 'OLFAccountEmailsInvalidate';
        if(!setMDTCalled)
            qryMDT();
        Boolean doExecute = callFromPage;
        if(mdtMap.containsKey('PostRefresh_OLFAccountUpdate') && !callFromPage)
            try{doExecute = Boolean.valueOf(mdtMap.get('PostRefresh_OLFAccountUpdate'));}catch(Exception e){}
        
        if(isSandboxOrg() && doExecute)
        {
            String invalStr = invalidString;
            Account[] acc =[select id,Rv_Olf_Customer_Email__c,Rv_Olf_EmailID__c from account where Rv_Olf_Customer_Email__c!=null];
            List<Account> updateAcc = new List<Account>();
            
            if(acc.size()>0)
            {
                for(Account a : acc)
                {
                    Boolean doUpdate = false;
                    
                    if(!a.Rv_Olf_Customer_Email__c.containsIgnoreCase(invalStr))
                    {
                        a.Rv_Olf_Customer_Email__c = a.Rv_Olf_Customer_Email__c + invalStr;
                        doUpdate = true;
                    }
                    if(a.Rv_Olf_EmailID__c != null)
                    {
                        List<String> toList=a.Rv_Olf_EmailID__c.split(';');
                        List<String> emailTo = new List<String>();
                        String newToEmail=a.Rv_Olf_EmailID__c;
                        
                        for(String toMail : toList)
                        {
                            if(toMail.length()>0 && !toMail.containsIgnoreCase(invalStr))
                                emailTo.add(toMail + invalStr);
                        }
                        
                        if(emailTo.size()>0)
                        {
                            newToEmail = '';
                            for(String toMailNew : emailTo)
                                newToEmail = newToEmail + toMailNew + ';';
                        }
                        
                        if(!newToEmail.equals(a.Rv_Olf_EmailID__c))
                        {
                            a.Rv_Olf_EmailID__c = newToEmail;
                            doUpdate = true;
                        }
                    }
                    
                    if(doUpdate)
                        updateAcc.add(a);
                }
                if(updateAcc.size()>0)
                {
                    try{
                        if(checkOnly)
                            inputWrap.saveErrLst.add(saveError('OLF Accounts Update Needed to append ' + invalidString,methodName,'Info'));
                        else {
                            update updateAcc;
                            inputWrap.saveErrLst.add(saveError('OLF Accounts Appended with ' + invalidString, methodName, 'Info'));
                        }
                    }
                    catch(Exception e)
                    {
            			inputWrap.saveErrLst.add(saveError('Error in OLF Accounts Update' + e.getMessage() + ' ' + e.getLineNumber(),methodName,'Exception'));
                    }
                }
                else
                {
                    inputWrap.saveErrLst.add(saveError('No update Needed to OLF Accounts',methodName,'Info'));
                }
            }
            else
            {
            	inputWrap.saveErrLst.add(saveError('No OLF Accounts Found to Update',methodName,'Info'));
            }
        }
        else
        {
            inputWrap.saveErrLst.add(saveError('OLF Accounts Update Cannot be Executed',methodName,'Exception'));
        }
        
        return inputWrap;
    }
    
    @TestVisible
    static RV_ClassExceptionErrors saveError(String errMsg, String methodName, String type)
    {
        RV_ClassExceptionErrors err = new RV_ClassExceptionErrors();
        err.errMessage = errMsg;
        err.methodName = methodName;
        err.errType = type;
        return err;
    }
    
    public class actionWrapper
    {
        public string error = '';
        MetadataService.MetadataPort service;
        List<RV_ClassExceptionErrors> saveErrLst = new List<RV_ClassExceptionErrors>();
    }
    
    public class RV_ClassExceptionErrors
    {
        String StatusCode = 'NA';
        String className = 'Rv_PrepareSandbox';
        String errMessage;
        String methodName;
        String errType;
    }

    public class pageIniitWrapper
    {
        @AuraEnabled
        public Boolean hasAccess;
        @AuraEnabled
        public String orgName;
    }
}