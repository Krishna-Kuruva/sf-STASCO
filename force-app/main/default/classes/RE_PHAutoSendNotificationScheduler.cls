public class RE_PHAutoSendNotificationScheduler implements System.Schedulable{ 
	
	public static String partnerServerUrl = URL.getSalesforceBaseUrl().toExternalForm()+System.Label.RE_BaseURL+UserInfo.getOrganizationId();   	
	public static String sessId = ''+System.UserInfo.getSessionId();

    public void execute(System.SchedulableContext con){
    	Boolean isSettlement = False;
        Boolean isMarkPrem = False;
        Boolean isFreight = False;
        Boolean isPHFx = False;
        Datetime dt = (DateTime)System.today();
        String dayOfWeek = dt.format('EEEE');
        Map<String, RE_Holiday_Calendar__c> holidayMap = RE_SOQLController.fetchPHHolidayData();
        for(RE_Market_Quotes__c LatestmopsList : [Select RE_Pricing_Date__c,RE_Quote_Type__c from RE_Market_Quotes__c where createddate = Today AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')]){
            if(LatestmopsList.RE_Quote_Type__c == 'Settlement') isSettlement = True;             
            if(LatestmopsList.RE_Quote_Type__c == 'Market Premium') isMarkPrem = True; 
            if(LatestmopsList.RE_Quote_Type__c == 'Freight') isFreight = True;             
        }
        for(RE_FX_Rates__c LatestFxRate : [SELECT RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c WHERE createddate = Today]){
            if(LatestFxRate.RE_Conversion_Unit__c == 'PHP') isPHFx = True; 
        }
        if(holidayMap.containsKey(String.valueOf(System.today().addDays(-1))))
        	isPHFx = True;
        
        if(isSettlement && isMarkPrem && isFreight && isPHFx)
            RE_PHAutoSendNotificationScheduler.sendcostPHData();
    }
    
    @future (callout=true)
    public static void sendcostPHData(){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Philippines Output Template'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Philippines Email Template'].Id;
        String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'Philippines Output Email Ids'].Id;
        
        Datetime dateToday = System.today();
        String currentDate = dateToday.format('dd-MM-yyyy');
        Map<String,Id>  mapQueryId = new Map<String,Id>(); 
        Set<String> Querylist = new Set<String>();
        
        for(APXTConga4__Conga_Merge_Query__c custSettingData :   [
            SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE RE_Type__c = 'PH CBU'
        ]){
            Querylist.add(custSettingData.APXTConga4__Name__c);
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
        CongaUrlPart2= CongaUrlPart2.removeEnd(',');  //removing the end comma
        String TodayLD = 'Philippines Transfer Price'+'('+currentDate+')';
        String PHOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailToId=+'+userId+'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2 +'&Qvar0id='+EmailIds +'&sfdciframehost=web'+
            '&solmgr='+1+'&TemplateId='+TempId+'&EmailSubject='+TodayLD+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
        request.setEndpoint(PHOutputUrl);
        request.setMethod('GET');
        request.setTimeout(60000);
        HTTPResponse response = http.send(request);
       
    }

}