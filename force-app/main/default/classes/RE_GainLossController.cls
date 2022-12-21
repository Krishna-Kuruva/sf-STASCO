public class RE_GainLossController {  
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getMopsProducts(){
       Set<String> sets = new Set<String>();
        List<String> lst = new List<String>();
        for(RE_Market_Quotes__c mps: [select id,RE_Quote_Name__c from RE_Market_Quotes__c where RE_Quote_Type__c='Settlement' AND createddate = LAST_N_DAYS : 15 AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')]){
           String s=mps.RE_Quote_Name__c;
            if(!lst.contains(s)){
                sets.add(mps.RE_Quote_Name__c);
            }
        }
        List<OptionWrapper> options = new List<OptionWrapper>();
        for(String s: sets){
           options.add(new OptionWrapper(s,s));
        }
           
        return options;
    }
    @AuraEnabled(cacheable=true)
    public static List<GainLossWrapper> gainLossDetails(String searchFilter, String Country){
       // searchFilter = 'Gasoil 0.5% S';
        Map<String,String> weekMap = new Map<String,String>();
        weekMap.put('1','Week 1');weekMap.put('2','Week 2');weekMap.put('3','Week 3');weekMap.put('4','Week 4');weekMap.put('5','Week 5');weekMap.put('6','Week 6');
        List<GainLossWrapper> gainRef = new List<GainLossWrapper>();
        Double monthAverages=0.00;
		Date lastMonthDates=System.today();
		List<RE_Weekly_Data__c> weeklyData = RE_Weekly_Data__c.getAll().values();
		date weekStart = date.today().toStartofWeek();									 //and RE_Published_Date__c < This_Week
		Date dt= date.today().toStartofMonth();
		for(RE_Weekly_Data__c wd : weeklydata){
			if(wd.RE_Valid_From__c <= dt &&  wd.RE_Valid_To__c >= dt){
				lastMonthDates = wd.RE_Week_Start_Date__c;
			}
		}
		
		String rcId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get(Country).getRecordTypeId();
		
		List<RE_Gain_Loss_Audit__c> fgains = [SELECT Recordtype.Name,Id,RE_WeekAverage__c,RE_Weeks_AVG__c,RE_Months_AVG__c,RE_MonthlyAverage__c, RE_Type__c, RE_Week_Number__c, RE_Published_Date__c, Name, RE_W_1__c, RE_W_1__r.name, RE_Quote_Name__c, RE_Year__c, RE_MTD__c, RE_Month__c, RE_Price__c FROM RE_Gain_Loss_Audit__c where RE_Published_Date__c>=: lastMonthDates and RE_Published_Date__c<=THIS_Week   and RE_Type__c IN ('W-1','M-1') and RE_MOPS_Name__c=:searchFilter AND RecordTypeId =: rcId ORDER BY RE_Week_Number__c	];
         
        for(integer i=0;i< fgains.size();i++){
			GainLossWrapper
             obj = new GainLossWrapper();
            RE_Gain_Loss_Audit__c  gains =  fgains[i];
			monthAverages=(fgains[0].RE_Months_AVG__c).setScale(2);
            
            if(gains.RE_Type__c=='W-1'){/* //&& gains.RE_Published_Date__c < weekStart
                date myDate = date.today();
                date weekStart = myDate.toStartofWeek();
                RE_Weekly_Data__c objref = [select name,RE_Week_Start_Date__c,RE_Week_End_Date__c from RE_Weekly_Data__c where RE_Week_Start_Date__c <=: gains.RE_Published_Date__c and RE_Week_End_Date__c >=: gains.RE_Published_Date__c LIMIT 1];*/
				
				DateTime dts;
				DateTime dte;
				for(RE_Weekly_Data__c wb : weeklyData){
					if(wb.RE_Week_Start_Date__c <= gains.RE_Published_Date__c && wb.RE_Week_End_Date__c >= gains.RE_Published_Date__c){
						dts = wb.RE_Week_Start_Date__c;
						dte = wb.RE_Week_End_Date__c;
					}
				}
            	               
                obj.monthAverage = (monthAverages);
				
                obj.liftingDate = dts.format('d MMM')+' - '+dte.format('d MMM');//String.valueOf(weekStart);//gains.RE_Week_Number__c;
                obj.weeks		= weekMap.get(gains.RE_Week_Number__c);
                obj.week_1		= (fgains[i].RE_Weeks_AVG__c).setScale(2);//(gains.RE_WeekAverage__c).setScale(2);                
                obj.Differences	= fgains[i].Recordtype.Name == 'Thailand' ? (obj.week_1 - obj.monthAverage) : (obj.monthAverage - obj.week_1);
                obj.Position	= obj.Differences > 0 ? 'In The Money' : 'Out The Money';
                gainRef.add(obj);
            }
            
        }
        system.debug(gainRef);
        return gainRef;
    }
    @AuraEnabled (cacheable = true)
    public static list<glWrap> fetchGainLossData(String searchFilter, String Country){
       // searchFilter = 'Gasoil 0.5% S';
        List<glwrap> gldatalist = new List<glwrap>();
		String rcId	=	Schema.SObjectType.RE_Gain_Loss_Audit__c.getRecordTypeInfosByName().get(Country).getRecordTypeId();

        for(RE_Gain_Loss_Audit__c glaudit : [
            SELECT Id,RE_WeekAverage__c,RE_MOPS_Name__c,RE_MonthlyAverage__c
            FROM RE_Gain_Loss_Audit__c 
            WHERE RE_Published_Date__c = TODAY
            AND RE_Type__c = 'D'
            AND RE_MOPS_Name__c =: searchFilter AND RecordTypeId =: rcId]){
            glWrap gldata = new glWrap();
            gldata.mopsdata = glaudit.RE_MOPS_Name__c;
            gldata.weeklydifference = (glaudit.RE_WeekAverage__c).setScale(2);
            gldata.monthlydifference =(glaudit.RE_MonthlyAverage__c).setScale(2);
            gldatalist.add(gldata);
        }
        return gldatalist;
    }

    
    public class glWrap{
        @AuraEnabled public String mopsdata {get;set;}
        @AuraEnabled public Decimal weeklydifference {get;set;}
        @AuraEnabled public Decimal monthlydifference {get;set;}        
    }

   public class GainLossWrapper{
        
        @AuraEnabled public String liftingDate 		{ get; set; }
        @AuraEnabled public String weeks 			{ get; set; }
        @AuraEnabled public Double monthAverage		{ get; set; }
        @AuraEnabled public Double week_1 			{ get; set; }
 		@AuraEnabled public Double Differences		{ get; set; }
        @AuraEnabled public String Position 		{ get; set; }
        
    }
    public class OptionWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public OptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}