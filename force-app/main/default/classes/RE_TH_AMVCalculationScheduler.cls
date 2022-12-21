public class RE_TH_AMVCalculationScheduler implements Schedulable{
	public void execute(SchedulableContext ctx) {
        Boolean isSettlement = False;
        Boolean isMarkPrem = False;
        Boolean isAssessPrem = False;
        Boolean isTHFx = False;
        Datetime dtt = (DateTime)System.today();
        String dayOfWeek = dtt.format('EEEE');
       
        for(RE_Market_Quotes__c LatestmopsList : [Select RE_Pricing_Date__c,RE_Quote_Type__c from RE_Market_Quotes__c where createddate = Today AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')]){
            if(LatestmopsList.RE_Quote_Type__c == 'Settlement') isSettlement = True;             
            if(LatestmopsList.RE_Quote_Type__c == 'Market Premium') isMarkPrem = True; 
            if(LatestmopsList.RE_Quote_Type__c == 'Assessed Premium') isAssessPrem = True;             
        }
        for(RE_FX_Rates__c LatestFxRate : [SELECT RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c WHERE createddate = Today]){
            if(LatestFxRate.RE_Conversion_Unit__c == 'THB') isTHFx = True;    
        }
        if((isSettlement && isMarkPrem && isAssessPrem && isTHFx) || (dayOfWeek == 'Monday' && isTHFx)){
            List<RE_Job_Run_Audit__c> jraList = new List<RE_Job_Run_Audit__c>();            
            try{                    
                RE_Job_Run_Audit__c jrAuditamv = new RE_Job_Run_Audit__c();
                jrAuditamv.RE_Run_Time__c = System.now();
                jrAuditamv.RE_Run_Type__c = 'Automate';
                jrAuditamv.RE_Job_Type__c = 'Thailand AMV Output';
                jrAuditamv.RE_User__c = UserInfo.getUserId();
                jrAuditamv.RE_Job_Run_Count__c = 0;
                jraList.add(jrAuditamv);
                if(!jraList.isEmpty())
                    insert jraList;
            }
            catch(Exception e){
                System.debug('Error in Scheduling Thailand AMV Job');
            }
        }
    }
}