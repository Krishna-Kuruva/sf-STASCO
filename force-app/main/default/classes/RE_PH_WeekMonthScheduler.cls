public class RE_PH_WeekMonthScheduler implements schedulable{
	
    public void execute(System.SchedulableContext sc){
        Datetime dt = System.today();
    	Integer dayOfmonth = dt.day();                                   
    	string dayOfWeek = dt.format('EEEE');
        System.debug('--Dt--'+dt);
        System.debug('--dayOfWeek--'+dayOfWeek);
		List<RE_Market_Quotes__c> quotedata = new List<RE_Market_Quotes__c>();
        List<RE_Market_Quotes__c> oldquotedata = new List<RE_Market_Quotes__c>();
     	if(dayOfWeek =='Monday' || Test.isRunningTest()){            
			//calculating W-1
			for(AggregateResult mopsdatalastweek : [
				SELECT AVG(RE_Price__c) pravgval,RE_Quote_Name__c,RE_Rate_Unit__c,RE_Quote_Type__c FROM RE_Market_Quotes__c 
				WHERE RE_Pricing_Date__c = LAST_WEEK AND RE_Quote_Type__c IN('Settlement','Market Premium','Freight') AND RE_Is_MTDWTD__c = False AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
				GROUP BY RE_Quote_Name__c,RE_Rate_Unit__c, RE_Quote_Type__c
			]){
				RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();                    
				markQuote.RE_Quote_Name__c = (String)mopsdatalastweek.get('RE_Quote_Name__c');
				markQuote.RE_Quote_Type__c = (String)mopsdatalastweek.get('RE_Quote_Type__c');                    
				markQuote.RE_Rate_Unit__c = (String)mopsdatalastweek.get('RE_Rate_Unit__c');
				markQuote.RE_Price__c = (Decimal) mopsdatalastweek.get('pravgval');
				markQuote.RE_Pricing_Date__c = System.today();
				markQuote.RE_Tracker__c = 'W-1';
                markQuote.RE_Is_MTDWTD__c = True;
                markQuote.RE_Country_Name__c = 'SG;PH;TH;MY';
				quotedata.add(markQuote);
			}
		} 
    
        if(dayOfmonth == 1  || Test.isRunningTest()){
			//calculating M-1   			
			for(AggregateResult mopsdatalastweek : [
				SELECT AVG(RE_Price__c) pravgval,RE_Quote_Name__c,RE_Rate_Unit__c,RE_Quote_Type__c FROM RE_Market_Quotes__c 
				WHERE RE_Pricing_Date__c = LAST_MONTH AND RE_Quote_Type__c IN('Settlement','Market Premium','Freight') AND RE_Is_MTDWTD__c = False AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')
				GROUP BY RE_Quote_Name__c,RE_Rate_Unit__c, RE_Quote_Type__c
			]){
				RE_Market_Quotes__c markQuote = new RE_Market_Quotes__c();                    
				markQuote.RE_Quote_Name__c = (String)mopsdatalastweek.get('RE_Quote_Name__c');
				markQuote.RE_Quote_Type__c = (String)mopsdatalastweek.get('RE_Quote_Type__c');                    
				markQuote.RE_Rate_Unit__c = (String)mopsdatalastweek.get('RE_Rate_Unit__c');
				markQuote.RE_Price__c = (Decimal) mopsdatalastweek.get('pravgval');
				markQuote.RE_Pricing_Date__c = System.today();
				markQuote.RE_Tracker__c = 'M-1';
                markQuote.RE_Is_MTDWTD__c = True;
                markQuote.RE_Country_Name__c = 'SG;PH;TH;MY';
				quotedata.add(markQuote);
			}
		}
        
        if(!quotedata.isEmpty()){
            try{insert quotedata;}
        	catch(Exception ex){system.debug(ex.getCause());}
        }
    }
}