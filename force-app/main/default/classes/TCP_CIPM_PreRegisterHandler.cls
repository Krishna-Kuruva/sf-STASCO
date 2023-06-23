public with sharing class  TCP_CIPM_PreRegisterHandler{
    
    public user user { get; set; }
    public string userid { get; set; }
    public TCP_CIPM_PreRegisterHandler(ApexPages.StandardController controller) {
        user =  (user) controller.getRecord();
        userid = user.Id;
        
    }
    
    public PageReference resendCIPMRequest() {
        manageCIPMRegister(userid);
        PageReference pageRef = new PageReference('/'+userid);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the user page
    }

    @future(callout=true)
    public static void manageCIPMRegister(string userid){
        try{
            if(string.isNotBlank(userid) ){
                list<user> user = [select email,firstname,lastname,CIPM_Id__c,CIPM_Status__c,CIPM_Message__c,CIPM_Access__c from user where id =: userid LIMIT 1];
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:TCP_CIPM_Preregister');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                string body = generateJSONstring(user[0],user[0].CIPM_Id__c == null?false:true);
                system.debug('body '+body);
                request.setBody(body);
                Http http = new Http();
                HttpResponse res = http.send(request);
                system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
                if(res.getStatusCode() == 201){
                    Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());  
                    user[0].CIPM_Id__c = (string)jsonMap.get('uuid');
                    user[0].CIPM_Status__c = 'Request sent';
                    user[0].CIPM_Message__c = '';
                    
                        
                }
                else if(res.getStatusCode() == 422){
                    Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
                    system.debug('jsonMap : '+jsonMap);
                    user[0].CIPM_Status__c = 'Request not sent';
                    string error = jsonMap.get('error') + '  '+
                        		   jsonMap.get('error_description') + '  '+
                        		   jsonMap.get('error_details');
                    user[0].CIPM_Message__c = error;
                   
                }
                else{
                    user[0].CIPM_Status__c = 'Request failed';
                    user[0].CIPM_Message__c = 'Something went wrong, please retry or contact IT team. Error message : '+res.getBody();
                }
                
                update user[0];
            }
        }
        catch(Exception e){
            system.debug('Exception in CIPM Preregister '+e.getCause() +TCP_Constants.ERROR_MESSAGE+e.getMessage());
            TCP_ExceptionLogClass.insertExceptionRecord('Exception in CIPM Preregister',e.getMessage(),'TCP_CIPM_PreRegisterHandler','manageCIPMRegister','Exception');
            throw e;
        }
        
    }

    public static string generateJSONstring(user u,boolean isresend){
        
        TCP_CIPM_Settings__mdt config = TCP_CIPM_Settings__mdt.getInstance('Preregister');

        TCP_CIPM_preRegWrapper re = new TCP_CIPM_preRegWrapper();
        re.client_id = config.client_id__c;
        re.scope = config.Scope__c;
        re.auth_type = config.Auth_type__c;
        re.redirect_uri = config.Redirect_URL__c;
        re.grant_type = config.Grant_type__c;
        re.locale = 'en-GB';
        re.resend = isresend;
        
        TCP_CIPM_preRegWrapper.profile_fields ff = new TCP_CIPM_preRegWrapper.profile_fields();
        ff.emailAddress = u.email;
        if(string.isNotBlank(u.firstName))
        	ff.firstName = u.firstName;
        else
            ff.firstName = '';
        ff.lastName = u.lastName;
        ff.resourceAccessTradingAndSupplyb2b = u.CIPM_Access__c;
        re.profile_fields = ff;
        system.debug('json val '+JSON.serializePretty(re));
        
        return JSON.serializePretty(re);
    }
}