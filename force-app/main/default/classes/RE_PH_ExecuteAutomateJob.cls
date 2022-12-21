global class RE_PH_ExecuteAutomateJob implements Schedulable {
	public void execute(SchedulableContext ctx) {
        Boolean isSettlement = False;
        Boolean isMarkPrem = False;
        Boolean isFreight = False;
        Boolean isPHFx = False;
        Datetime dt = (DateTime)System.today();
        String dayOfWeek = dt.format('EEEE');
        Map<String, RE_Holiday_Calendar__c> holidayMap = RE_SOQLController.fetchPHHolidayData();
        for(RE_Market_Quotes__c LatestmopsList : [Select RE_Pricing_Date__c,RE_Quote_Type__c from RE_Market_Quotes__c where createddate = Today AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') AND RE_Is_MTDWTD__c = false AND RE_Quote_Type__c != 'Midday']){
            if(LatestmopsList.RE_Quote_Type__c == 'Settlement') isSettlement = True;             
            if(LatestmopsList.RE_Quote_Type__c == 'Market Premium') isMarkPrem = True; 
            if(LatestmopsList.RE_Quote_Type__c == 'Freight') isFreight = True;             
        }
        for(RE_FX_Rates__c LatestFxRate : [SELECT RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c WHERE createddate = Today  AND RE_Is_MTDWTD__c = false]){
            if(LatestFxRate.RE_Conversion_Unit__c == 'PHP') isPHFx = True; 
        }
        if(holidayMap.containsKey(String.valueOf(System.today().addDays(-1))))
        	isPHFx = True;
        
        if(isSettlement && isMarkPrem && isFreight && isPHFx){
            RE_MarketQuotesTriggerHelper.temperaturegaincalculation();
            List<RE_Job_Run_Audit__c> jraList = new List<RE_Job_Run_Audit__c>();
            Boolean mopsRun = RE_ExternalTriggerHelper.mopsDataTracker();
            Boolean fxRun = RE_ExternalTriggerHelper.fxDataTracker();
            
            if(mopsRun == True && fxRun == True){
                try{                                                         
                    RE_Job_Run_Audit__c jrAuditTH = new RE_Job_Run_Audit__c();
                    jrAuditTH.RE_Run_Time__c = System.now();
                    jrAuditTH.RE_Run_Type__c = 'Automate';
                    jrAuditTH.RE_Job_Type__c = 'Philippines Output';
                    jrAuditTH.RE_User__c = UserInfo.getUserId();
                    jrAuditTH.RE_Job_Run_Count__c = 0;
                    jraList.add(jrAuditTH);                     
                    if(!jraList.isEmpty())
                        insert jraList;
                }
                catch(Exception e){
					System.debug(e.getCause());
                }
            }
        }
        else{
			sendnotification();
        }
    }
    
    public static void sendnotification(){
        List<String> tomail = System.label.RE_TH_Mail_Recipient.split(';');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(tomail);
            email.setSubject('TH CBU Output not generated for - '+System.Today());
            email.setHtmlBody('Hello, <br/><br/>Since we have not received today`s data from BOT we are not generating PH CBU output. <br/><br/>Regards,<br/> Dev Team');
        	try{
                if(![SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox)
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        	}catch(exception e){
            	apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        	}
    }
}