public class RE_MidDayMailController {
    private String partnerServerUrl;
    public String MDUrl {get; private set;}
    public String SGMidDyUrl {get; private set;}
    public String MDEMUrl {get; private set;}

    public PageReference prepareMidDayUrl() {
        System.debug('prepareMYmidday');
        partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId();
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Malaysia MidDay PM Template'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Malaysia Mid Day Email Template'].Id;
        String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'Malaysia MidDay PM Email Ids'].Id;

        Date dateToday = System.today().addDays(1);
        String midDayDate = String.valueOf(dateToday).removeEnd(' 00:00:00');

        Set<String> congaQueryName = new Set<String>();
        congaQueryName.add('Malaysia MidDay Output(PM)');
        congaQueryName.add('Sales Tax-PM');
        congaQueryName.add('MidDay Sales Tax Effective Date');
        
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c FROM APXTConga4__Conga_Solution_Query__c WHERE APXTConga4__Conga_Query_Name__c IN : congaQueryName];
        Map<String,Id>  mapQueryId = new Map<String,Id>();

        for(APXTConga4__Conga_Solution_Query__c apexconga: lstApexConga)
        {
            mapQueryId.put(apexconga.APXTConga4__Alias__c,apexconga.APXTConga4__Conga_Query__c);
        }
        
        MDUrl = 'https://composer.congamerge.com' + '?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[MidDayOutput]'+
            mapQueryId.get('MidDayOutput')+',[SalesTaxPM]'+mapQueryId.get('SalesTaxPM')+',[MidDEffDate]'+mapQueryId.get('MidDEffDate')+'&Qvar0id='+EmailIds +'&sfdciframehost=web'+
            '&solmgr='+1+'&TemplateId='+TempId+'&EmailSubject=Afternoon indication and List Price Update for Indirect PM (Eff '+midDayDate+')'+'&ds7='+2;
        return null;
    }
    public PageReference prepareMidDayEMUrl() {
        partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId();
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Malaysia MidDay EM Template'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Malaysia Mid Day EM Email Template'].Id;
        String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'Malaysia MidDay EM Email Ids'].Id;

        Date dateToday = System.today().addDays(1);
        String midDayDate = String.valueOf(dateToday).removeEnd(' 00:00:00');

        Set<String> congaQuery = new Set<String>();
        congaQuery.add('Malaysia MidDay Output(EM)');
        congaQuery.add('Sales Tax-Sabah');
        congaQuery.add('Sales Tax-Sarawak');
        congaQuery.add('MidDay Sales Tax Effective Date');
        
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c FROM APXTConga4__Conga_Solution_Query__c
        WHERE APXTConga4__Conga_Query_Name__c IN : congaQuery];
        Map<String,Id>  mapQueryId = new Map<String,Id>();

        for(APXTConga4__Conga_Solution_Query__c apexconga: lstApexConga)
        {
            mapQueryId.put(apexconga.APXTConga4__Alias__c,apexconga.APXTConga4__Conga_Query__c);
        }

        MDEMUrl = 'https://composer.congamerge.com' + '?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[MYMidDayEM]'+
            mapQueryId.get('MYMidDayEM')+',[SalesTaxSabah]'+mapQueryId.get('SalesTaxSabah')+',[SalesTaxSarawak]'+mapQueryId.get('SalesTaxSarawak')+
            ',[MDayEffDate]'+mapQueryId.get('MDayEffDate')+'&Qvar0id='+EmailIds +'&sfdciframehost=web'+'&solmgr='+1+'&TemplateId='+
            TempId+'&EmailSubject=Afternoon indication and List Price Update for Indirect EM (Eff '+midDayDate+')'+'&ds7='+2;
        return null;
    }


    public PageReference prepareCMUrl() {
        System.debug('prepareSGmidday');
        partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId();
        String userId      = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        String TempId      = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'Singapore MidDay Output Template'].Id;
        String EmailTempId = [SELECT Id FROM APXTConga4__Conga_Email_Template__c Where APXTConga4__Name__c='Singapore Mid Day Email Template'].Id;
        String EmailIds    = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c = 'SG MidDay Email Ids'].Id;

        Date dateToday = System.today().addDays(1);
        String midDayDate = String.valueOf(dateToday).removeEnd(' 00:00:00');

        Set<String> congaQueryName = new Set<String>();
        congaQueryName.add('Singapore Midday Market Quotes Query');
        congaQueryName.add('Singapore Midday Market Quotes Query-Yesterday');
        congaQueryName.add('Singapore FX RateSell-Today');
        congaQueryName.add('Singapore FX RateSell-Midday');
        congaQueryName.add('Singapore Midday MC0 Dip Query');
        congaQueryName.add('Singapore Midday CBU Query S Cent/litre');
        congaQueryName.add('Singapore FX RateEx-Today');
        congaQueryName.add('Singapore FX RateEx-Yesterday');
        congaQueryName.add('Singapore Marginal Aspirational Query');
        congaQueryName.add('Singapore Midday Morning MC');
        congaQueryName.add('Singapore Midday Temp Gain');
        congaQueryName.add('Singapore Midday Assessed Premium Quotes');
        congaQueryName.add('Singapore Midday Market Premium Quotes');
        congaQueryName.add('Singapore Midday Market Premium Quotes-Yesterday');
        congaQueryName.add('Singapore Midday Assessed Premium Quotes-Yesterday');



        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c FROM APXTConga4__Conga_Solution_Query__c
        WHERE APXTConga4__Conga_Query_Name__c IN : congaQueryName];
        Map<String,Id>  mapQueryId = new Map<String,Id>();

        for(APXTConga4__Conga_Solution_Query__c apexconga: lstApexConga)
        {
            mapQueryId.put(apexconga.APXTConga4__Alias__c,apexconga.APXTConga4__Conga_Query__c);
        }

        SGMidDyUrl = 'https://composer.congamerge.com' + '?SessionId=' + UserInfo.getSessionID() + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
                '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[SingFXSellMday]'+ mapQueryId.get('SingFXSellMday')
                +',[SingFXRateSellToday]'+mapQueryId.get('SingFXRateSellToday')+',[SingMdayMQ]'+ mapQueryId.get('SingMdayMQ')
                +',[SingMdayMQYest]'+mapQueryId.get('SingMdayMQYest')+',[SingMdaySctsltr]'+ mapQueryId.get('SingMdaySctsltr')
                +',[SingFXRateExTody]'+mapQueryId.get('SingFXRateExTody')+',[SingFXRateExYstdy]'+mapQueryId.get('SingFXRateExYstdy')
                +',[SingMarginlAsp]'+mapQueryId.get('SingMarginlAsp')+',[SGMdayMC0Dip]'+ mapQueryId.get('SGMdayMC0Dip')
                +',[SGMdayMorng]'+mapQueryId.get('SGMdayMorng')+',[SGMdayTempGain]'+mapQueryId.get('SGMdayTempGain')
                +',[SigMdMarPri]'+mapQueryId.get('SigMdMarPri')+',[SigMdMarPreYestr]'+mapQueryId.get('SigMdMarPreYestr')
                +',[SigMidAssPr]'+mapQueryId.get('SigMidAssPr')+',[SigMdAssPreyestr]'+mapQueryId.get('SigMdAssPreyestr')+
                '&Qvar0id='+EmailIds +'&sfdciframehost=web'+'&solmgr='+1+'&TemplateId='+TempId+'&EmailSubject=SG MID DAY CBU PUBLISHING - Eff '+midDayDate+'&ds7='+2;
        return null;
    }
}