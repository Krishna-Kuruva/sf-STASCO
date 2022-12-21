public class RE_THAutoSendNotificationScheduler implements System.Schedulable{

    public static String partnerServerUrl = URL.getSalesforceBaseUrl().toExternalForm()+System.Label.RE_BaseURL+UserInfo.getOrganizationId();

    public static String sessId = ''+System.UserInfo.getSessionId();

    public void execute(System.SchedulableContext con){
        Boolean isSettlement = False;
        Boolean isTHFx = False;
        Datetime dtt = (DateTime)System.today();
        String dayOfWeek = dtt.format('EEEE');
        
        for(RE_Market_Quotes__c LatestmopsList : [Select RE_Pricing_Date__c,RE_Quote_Type__c from RE_Market_Quotes__c where createddate = Today AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY')]){
            if(LatestmopsList.RE_Quote_Type__c == 'Settlement') isSettlement = True;                  
        }
        for(RE_FX_Rates__c LatestFxRate : [SELECT RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c WHERE createddate = Today]){
            if(LatestFxRate.RE_Conversion_Unit__c == 'THB') isTHFx = True;

        }

        if((isSettlement && isTHFx) || (dayOfWeek == 'Monday' && isTHFx)){
            RE_THAutoSendNotificationScheduler.sendcostTHData();
        }
    }
    @future (callout=true)
    public static void sendcostTHData(){
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Thailand Output Template'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Thailand Output Email Template'].Id;
        String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'Thailand Output Email Ids'].Id;
        Datetime dateToday = System.today();
        String currentDate = dateToday.format('dd-MM-yyyy');

        //fetching custom setting data (Query name)
        Set<String> Querylist = new Set<String>();
        for(RE_TH_Query_Data__c custSettingData : RE_TH_Query_Data__c.getall().values())
        {
            Querylist.add(custSettingData.RE_TH_Query_Name__c);
        }
        //fetching the alias and the query data using the query names
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c
        FROM APXTConga4__Conga_Solution_Query__c
        WHERE APXTConga4__Conga_Query_Name__c IN : Querylist];
        Map<String,Id>  mapQueryId = new Map<String,Id>();
        for(APXTConga4__Conga_Solution_Query__c apexconga: lstApexConga)
        {
            mapQueryId.put(apexconga.APXTConga4__Alias__c,apexconga.APXTConga4__Conga_Query__c);
        }

        //creating part of conga url
        String CongaUrlPart2= '&QueryId=';
        for(String congaQueryData : mapQueryId.keySet())
        {
            CongaUrlPart2 = CongaUrlPart2+'['+congaQueryData+']'+ mapQueryId.get(congaQueryData)+',';
        }
        CongaUrlPart2= CongaUrlPart2.removeEnd(',');  //removing the end comma

        String THOutputUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl + '&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailToId=+'+userId+'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId + '&isdtp=p1'+ CongaUrlPart2 +'&Qvar0id='+EmailIds +'&sfdciframehost=web'+'&solmgr='+1+'&TemplateId='+TempId+'&EmailSubject=Today%20LD('+currentDate+')'+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';
            
            /*'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl + '&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailToId=+'+userId+'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2 +'&Qvar0id='+EmailIds +'&sfdciframehost=web'+
            '&solmgr='+1+'&TemplateId='+TempId+'&EmailSubject=Thialand CBU Output Sheet (Eff '+currentDate+')'+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';*/
        request.setEndpoint(THOutputUrl);
        request.setMethod('GET');
        request.setTimeout(60000);
        HTTPResponse response = http.send(request);
        System.debug(THOutputUrl);
        System.debug('[Debug Response] ' + response);
        System.debug('[Debug callout Status]  ' + response.getStatus());
        System.debug('[Debug Body]  ' + response.getBody());
    }
}