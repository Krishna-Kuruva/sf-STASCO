public class RE_CovamoMailController {  
    private String partnerServerUrl;  
    public String ReqId {get;set;}
    private ApexPages.StandardSetController controller; 
    public String CovamoUrl{get; private set;}
    public RE_CovamoMailController(ApexPages.StandardController controller) {
        ReqId = Apexpages.currentPage().getparameters().get('Id');  //fetching the record id passed from lwc
        partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId(); 
    }  
    
    public PageReference prepareCovamoUrl() {
        //partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId(); 
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Covamo Template'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Covamo Email Template'].Id;
        String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'Covamo Email Ids'].Id;
        
        //fetching custom setting data-queries
        Map<String,RE_Covamo_Query__c> custSettingName = RE_Covamo_Query__c.getAll();
        Set<String> Querylist = new Set<String>();
        for (RE_Covamo_Query__c setting : RE_Covamo_Query__c.getAll().values())
            Querylist.add(setting.Query__c); //fetching the particular custom setting field
        
        System.debug('customsettingdata--'+Querylist);
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c 
                                                                  FROM APXTConga4__Conga_Solution_Query__c 
                                                                  WHERE APXTConga4__Conga_Query_Name__c IN : Querylist];
        Map<String,Id>  mapQueryId = new Map<String,Id>();
        for(APXTConga4__Conga_Solution_Query__c apexconga: lstApexConga)
        {
            mapQueryId.put(apexconga.APXTConga4__Alias__c,apexconga.APXTConga4__Conga_Query__c);
        }       
        String urlPart2= '&QueryId=';  //creating part of url
        for(String congaData : mapQueryId.keySet())
        {
            urlPart2 = urlPart2+'['+congaData+']'+ mapQueryId.get(congaData)+',';
        }
        urlPart2= urlPart2.removeEnd(',');
        
        CovamoUrl = 'https://composer.congamerge.com' + '?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' +partnerServerUrl+'&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailToId=+'+userId+'&EmailAdditionalTo={Qvar0}'+'&Id=' + ReqId + '&isdtp=p1' + urlPart2+
            '&Qvar0id='+EmailIds +'&sfdciframehost=web'+'&solmgr='+1+'&TemplateId='+TempId+'&ds7='+2;
        
        //System.debug('CovamoUrl--'+CovamoUrl);
        return null;
    }
}