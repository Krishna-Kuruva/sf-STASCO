//this class is developing custom conga solution for Thailand Mail Data
    public class RE_PH_MailController {
    private String partnerServerUrl;
    public String PHOutputUrl {get; private set;}
    
    public PageReference preparePhilippinesUrl() {
        partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId();
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
        
        PHOutputUrl = 'https://composer.congamerge.com' + '?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailToId=+'+userId+'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+ CongaUrlPart2 +'&Qvar0id='+EmailIds +'&sfdciframehost=web'+
            '&solmgr='+1+'&TemplateId='+TempId+'&EmailSubject=Today LD('+currentDate+')'+'&ds7='+2;
        return null;
    }
    
   
}