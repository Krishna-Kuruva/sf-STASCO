global class RE_MY_ExecuteAutomateJob implements Schedulable {    
    public void execute(SchedulableContext ctx) {
        Boolean isSettlement = False;
        Boolean isMarkPrem = False;
        Boolean isAssessPrem = False;
        Boolean isMYFx = False;
        Boolean isSGFx = False;
        for(RE_Market_Quotes__c LatestmopsList : [Select RE_Pricing_Date__c,RE_Quote_Type__c from RE_Market_Quotes__c where createddate = Today AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') AND RE_Is_MTDWTD__c = false AND RE_Quote_Type__c != 'Midday']){
            if(LatestmopsList.RE_Quote_Type__c == 'Settlement') isSettlement = True;             
            if(LatestmopsList.RE_Quote_Type__c == 'Market Premium') isMarkPrem = True; 
            if(LatestmopsList.RE_Quote_Type__c == 'Assessed Premium') isAssessPrem = True;             
        }
        for(RE_FX_Rates__c LatestFxRate : [SELECT RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c WHERE createddate = Today AND RE_Is_MTDWTD__c = false]){
            if(LatestFxRate.RE_Conversion_Unit__c == 'MYR') isMYFx = True;
            if(LatestFxRate.RE_Conversion_Unit__c == 'SGD') isSGFx = True; 
        }
        if(isSettlement && isMarkPrem && isAssessPrem && isMYFx && isSGFx){
            RE_MarketQuotesTriggerHelper.temperaturegaincalculation();
            List<RE_Job_Run_Audit__c> jraList = new List<RE_Job_Run_Audit__c>();
            Boolean mopsRun = RE_ExternalTriggerHelper.mopsDataTracker();
            Boolean fxRun = RE_ExternalTriggerHelper.fxDataTracker();
            if(!Test.isRunningTest()){
            RE_ExternalTriggerHelper.createDailyLagAuditData('MYR CTS/LTR','Malaysia');
            }
            if(mopsRun == True && fxRun == True){
                try{
                    RE_Job_Run_Audit__c jrAuditMY = new RE_Job_Run_Audit__c();
                    jrAuditMY.RE_Run_Time__c = System.now();
                    jrAuditMY.RE_Run_Type__c = 'Automate';
                    jrAuditMY.RE_Job_Type__c = 'Malaysia Output';
                    jrAuditMY.RE_User__c = UserInfo.getUserId();
                    jrAuditMY.RE_Job_Run_Count__c = 0;
                    jraList.add(jrAuditMY);
                    RE_Job_Run_Audit__c jrAuditSG = new RE_Job_Run_Audit__c();
                    jrAuditSG.RE_Run_Time__c = System.now();
                    jrAuditSG.RE_Run_Type__c = 'Automate';
                    jrAuditSG.RE_Job_Type__c = 'Singapore Output';
                    jrAuditSG.RE_User__c = UserInfo.getUserId();
                    jrAuditSG.RE_Job_Run_Count__c = 0;
                    jraList.add(jrAuditSG); 
                    if(!jraList.isEmpty())
                        insert jraList;
                }
                catch(Exception e){
                    RE_MY_ExecuteAutomateJob.sendnotification();
                }
            }
        }
        else{
			RE_MY_ExecuteAutomateJob.sendnotification();
        }
    }
    public static void sendnotification(){
        List<String> tomail = System.label.RE_MY_Mail_Recipient.split(';');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(tomail);
            email.setSubject('CBU Output not generated for - '+System.Today());
            email.setHtmlBody('Hello, <br/><br/>Since we have not received today`s data from BOT we are not generating CBU output. <br/><br/>Regards,<br/> Dev Team');
        	try{
                if(![SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox)
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        	}catch(exception e){
            	apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        	}
    }
}