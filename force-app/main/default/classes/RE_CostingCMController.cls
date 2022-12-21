public class RE_CostingCMController {    
    private String partnerServerUrl;  
    private ApexPages.StandardSetController controller; 
    private List<String> costingIds = new List<Id>();  
    public String CMUrl {get; private set;}  
    public RE_CostingCMController(ApexPages.StandardSetController controller) { 
        this.controller = controller;  
        for (RE_MY_CostPrice__c cost : (List<RE_MY_CostPrice__c>)controller.getSelected()){ 
            costingIds.add(cost.Id); 
        } 
    partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId(); 
    }  
    
    public PageReference prepareCMUrl() { 
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Singapore Output Template'].Id;
		String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c Where APXTConga4__Name__c='Revolution Singapore Template'].Id;
		String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'Singapore Email Ids'].Id;
       
       Set<String> congaQueryName = new Set<String>();
        congaQueryName.add('Singapore CBU Query US Cent/litre');
        congaQueryName.add('Singapore CBU Query S Cent/litre');
        congaQueryName.add('Singapore Market Quotes Query');
        congaQueryName.add('Singapore Market Quotes Query-Yesterday');
        congaQueryName.add('Singapore FX RateSell-Today');
        congaQueryName.add('Singapore FX RateSell-Yesterday');
        congaQueryName.add('Singapore FX RateEx-Today');
        congaQueryName.add('Singapore FX RateEx-Yesterday');
        congaQueryName.add('Singapore MC0 Dip Query');
        congaQueryName.add('SG Market Premium Today');
        congaQueryName.add('SG Market Premium Yesterday');
        congaQueryName.add('SG Assessed Premium Today');
        congaQueryName.add('SG Assessed Premium Yesterday');
        congaQueryName.add('SingMarketQuotesTemperature');
        congaQueryName.add('Singapore Market Quotes Query-Gasoil0.005');
        congaQueryName.add('Singapore Market Quotes Query-Yesterday-Gasoil0.005');
        
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c FROM APXTConga4__Conga_Solution_Query__c WHERE APXTConga4__Conga_Query_Name__c IN : congaQueryName];
        Map<String,Id>  mapQueryId = new Map<String,Id>();
        
        for(APXTConga4__Conga_Solution_Query__c apexconga: lstApexConga)
        {
          mapQueryId.put(apexconga.APXTConga4__Alias__c,apexconga.APXTConga4__Conga_Query__c);
        }
       //system.debug('mapQueryId==='+mapQueryId);
       
        CMUrl = 'https://composer.congamerge.com' + '?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
       '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[SingUSCent]'+
            mapQueryId.get('SingUSCent')+',[SingSCent]'+mapQueryId.get('SingSCent')+',[SingMarketQuotes]'+
            mapQueryId.get('SingMarketQuotes')+',[SingMarketQuotesYtd]'+mapQueryId.get('SingMarketQuotesYtd')+
            ',[SingMQ0005]'+mapQueryId.get('SingMQ0005')+',[SingMQYstrdy0005]'+mapQueryId.get('SingMQYstrdy0005')+',[SingFXRateSellTdy]'+
            mapQueryId.get('SingFXRateSellTdy')+',[SingFXRateExYtd]'+mapQueryId.get('SingFXRateExYtd')+',[SingFXRateSellYtd]'+
            mapQueryId.get('SingFXRateSellYtd')+',[SingMC0Dip]'+mapQueryId.get('SingMC0Dip')+',[SingFXRateExTdy]'+
            mapQueryId.get('SingFXRateExTdy')+',[SGMPToday]'+mapQueryId.get('SGMPToday')+',[SGMPYday]'+mapQueryId.get('SGMPYday')+
            ',[SGAPToday]'+mapQueryId.get('SGAPToday')+',[SGAPYday]'+mapQueryId.get('SGAPYday')+',[SgMQTemperature]'+mapQueryId.get('SgMQTemperature')+
            '&Qvar0id='+EmailIds +'&sfdciframehost=web'+'&solmgr='+1+'&TemplateId='+TempId+'&ds7='+2+ String.join(new List<String>(costingIds),'\'|\'');   
        //system.debug('CMUrl==='+CMUrl);
        return null; 
    }

}