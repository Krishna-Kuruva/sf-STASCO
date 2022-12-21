public class RE_MY_CostingController { 
    private String partnerServerUrl;
    private ApexPages.StandardSetController controller; 
    private List<String> costingIds = new List<Id>();
    public String MYUrl {get; private set;}  
    public RE_MY_CostingController(ApexPages.StandardSetController controller) { 
        this.controller = controller;
        for (RE_MY_CostPrice__c cost : (List<RE_MY_CostPrice__c>)controller.getSelected()){ 
            costingIds.add(cost.Id); 
        } 
        partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId(); 
    } 
    public PageReference prepareMYUrl() { 
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Costing Output sheet'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c Where APXTConga4__Name__c='Revolution Malaysian Template'].Id;
        String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'Malaysia Email Ids'].Id;
        
        Set<String> CongaMYQueryName = new Set<String>();
        CongaMYQueryName.add('CBU Output Query Peninsula');
        CongaMYQueryName.add('CBU Sabah Output');
        CongaMYQueryName.add('CBU Output Sarawak');
        CongaMYQueryName.add('Malaysia Product Details');
        CongaMYQueryName.add('Malaysia Product Details-Yesterday');
        CongaMYQueryName.add('FX Rate Query');
        CongaMYQueryName.add('FX Rate Yesterday Query');
        CongaMYQueryName.add('Malaysia Market Quote-Today');
        CongaMYQueryName.add('Malaysia Market Query-Yesterday');
		CongaMYQueryName.add('SG Market Premium Today');
        CongaMYQueryName.add('SG Market Premium Yesterday');
        CongaMYQueryName.add('MTD Position');
        CongaMYQueryName.add('MTD Position Gain Loss');
        CongaMYQueryName.add('premiaisdiscount');
        CongaMYQueryName.add('GasoilB7Diff');
        CongaMYQueryName.add('Midday Forecast Up Down');
         CongaMYQueryName.add('SingMarketQuotesTemperature');
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c FROM APXTConga4__Conga_Solution_Query__c 
                                                                  WHERE APXTConga4__Conga_Query_Name__c IN : CongaMYQueryName];
        Map<String,Id> mapQueryId = new Map<String,Id>();
        
        for(APXTConga4__Conga_Solution_Query__c apexMYConga : lstApexConga)
        {
            mapQueryId.put(apexMYConga.APXTConga4__Alias__c,apexMYConga.APXTConga4__Conga_Query__c);
        }
        
        MYUrl = 'https://composer.congamerge.com' + '?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[outputquery]'+
            mapQueryId.get('outputquery')+',[outputquerysbh]'+mapQueryId.get('outputquerysbh')+',[outputquerysrw]'+
            mapQueryId.get('outputquerysrw')+',[MarketQuoteQuery]'+mapQueryId.get('MarketQuoteQuery')+',[MarketQuoteYesterday]'+
            mapQueryId.get('MarketQuoteYesterday')+',[FXRateQuery]'+mapQueryId.get('FXRateQuery')+',[FXRateYesterQuery]'+
            mapQueryId.get('FXRateYesterQuery')+',[MalMarketQuery]'+mapQueryId.get('MalMarketQuery')+',[MalMarketQueyYtd]'+
            mapQueryId.get('MalMarketQueyYtd')+',[outputmtd]'+mapQueryId.get('outputmtd')+',[MyMQTemperature]'+mapQueryId.get('MyMQTemperature')+',[outputgainloss]'+
            mapQueryId.get('outputgainloss')+',[premiaisdiscount]'+
            mapQueryId.get('premiaisdiscount')+',[MidDayUpDown]'+
            mapQueryId.get('MidDayUpDown')+',[GasoilB7Diff]'+
            mapQueryId.get('GasoilB7Diff')+/*',[MYMPToday]'+mapQueryId.get('MYMPToday')+',[MYMPYday]'+mapQueryId.get('MYMPYday')+*/'&Qvar0id='+EmailIds +
            '&sfdciframehost=web'+'&solmgr='+1+'&TemplateId='+TempId+'&ds7='+2+ String.join(new List<String>(costingIds),'\'|\''); 
        return null;
    }
}