public class RE_FxRatesTriggerHelper {
	//Remove duplicate data from system
    public static void onBeforeTriggerHelper(List<RE_FX_Rates__c> newFxLst
                                             ,Map<ID,RE_FX_Rates__c> oldFxMap
                                             ,Map<ID,RE_FX_Rates__c> newFxMap)
    {
        list<RE_FX_Rates__c> oldFxlist = new list<RE_FX_Rates__c>();
        //Revolution is receiving future exchange rates from ADF. To run the below logic to remove duplicate records, where clause has been changed from RE_Pricing_Date__c to createddate
        for(RE_FX_Rates__c oldFxData : [
            SELECT RE_Conversion_Unit__c,RE_Base_Unit__c,RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c , RE_Tracker__c
            FROM RE_FX_Rates__c WHERE createddate = LAST_N_DAYS:7 AND Id NOT IN : newFxLst ORDER BY RE_Pricing_Date__c DESC
        ]){
            for(RE_FX_Rates__c newdata : newFxLst){
                if(newdata.RE_Pricing_Date__c == oldFxData.RE_Pricing_Date__c 
                   	&& newdata.RE_Base_Unit__c == oldFxData.RE_Base_Unit__c
                  	&& newdata.RE_Conversion_Unit__c == oldFxData.RE_Conversion_Unit__c 
                   	&& newdata.RE_Trade_Type__c == oldFxData.RE_Trade_Type__c
                    && newdata.RE_Is_MTDWTD__c == False){
					oldFxlist.add(oldFxData);
                    newdata.RE_Tracker__c = oldFxData.RE_Tracker__c;
				}
                if(newdata.RE_Pricing_Date__c == oldFxData.RE_Pricing_Date__c 
                   	&& newdata.RE_Base_Unit__c == oldFxData.RE_Base_Unit__c
                  	&& newdata.RE_Conversion_Unit__c == oldFxData.RE_Conversion_Unit__c 
                   	&& newdata.RE_Trade_Type__c == oldFxData.RE_Trade_Type__c
                    && newdata.RE_Is_MTDWTD__c == True
                  	&& newdata.RE_Tracker__c == oldFxData.RE_Tracker__c){
					oldFxlist.add(oldFxData);
				}
            }                                 
        }
        
        if(!oldFxlist.isEmpty())
        {
            try{delete oldFxlist;}
            catch(Exception e)
            {System.debug('Failed while delete to Fx Rates -- '+e.getMessage());}
        }
    }
    public static void onAfterTriggerHelper(List<RE_FX_Rates__c> newFxLst ,Map<ID,RE_FX_Rates__c> oldFxMap ,Map<ID,RE_FX_Rates__c> newFxMap){
        List<RE_Job_Run_Audit__c> jraList = new List<RE_Job_Run_Audit__c>();
        List<String> typelist = new List<String>();
        for(RE_FX_Rates__c quotes : newFxLst){
            if(quotes.RE_Tracker__c != null && !typelist.contains(quotes.RE_Tracker__c)){
                typelist.add(quotes.RE_Tracker__c);
            }            
        }
        if(typelist.contains('W-1')){
            System.debug('inside fX trigger for W1');
            RE_Job_Run_Audit__c jrAuditW1 = new RE_Job_Run_Audit__c();
            jrAuditW1.RE_Run_Time__c = System.now();
            jrAuditW1.RE_Run_Type__c = 'Automate';
            jrAuditW1.RE_Job_Type__c = 'Philippines W-1 Output';
            jrAuditW1.RE_User__c = UserInfo.getUserId();
            jrAuditW1.RE_Job_Run_Count__c = 0;
            jraList.add(jrAuditW1);
        }
        if(typelist.contains('M-1')){
        	RE_Job_Run_Audit__c jrAuditM1 = new RE_Job_Run_Audit__c();
            jrAuditM1.RE_Run_Time__c = System.now();
            jrAuditM1.RE_Run_Type__c = 'Automate';
            jrAuditM1.RE_Job_Type__c = 'Philippines M-1 Output';
            jrAuditM1.RE_User__c = UserInfo.getUserId();
            jrAuditM1.RE_Job_Run_Count__c = 0;
            jraList.add(jrAuditM1);
        }
        if(!jraList.isEmpty()){
            try{insert jraList;}
            catch(Exception ex){system.debug(ex.getCause());}
        }
    }
    
}