public class RE_SendCostingNotificationScheduler implements schedulable{  
	public static String partnerServerUrl = URL.getSalesforceBaseUrl().toExternalForm()+System.Label.RE_BaseURL+UserInfo.getOrganizationId();
   	 
	public static String sessId = ''+System.UserInfo.getSessionId(); 
     
    public void execute(System.SchedulableContext sc){
        Boolean isSettlement = False;
        Boolean isMarkPrem = False;
        Boolean isAssessPrem = False;
        Boolean isMYFx = False;
        Boolean isSGFx = False;
        try{ 
            
            for(RE_Market_Quotes__c LatestmopsList : [Select RE_Pricing_Date__c,RE_Quote_Type__c from RE_Market_Quotes__c where createddate = Today AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') ]){
                if(LatestmopsList.RE_Quote_Type__c == 'Settlement') isSettlement = True;             
                if(LatestmopsList.RE_Quote_Type__c == 'Market Premium') isMarkPrem = True; 
                if(LatestmopsList.RE_Quote_Type__c == 'Assessed Premium') isAssessPrem = True;             
            }
            for(RE_FX_Rates__c LatestFxRate : [SELECT RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c WHERE createddate = Today]){
                if(LatestFxRate.RE_Conversion_Unit__c == 'MYR') isMYFx = True;
                if(LatestFxRate.RE_Conversion_Unit__c == 'SGD') isSGFx = True;    
            }
            if(isSettlement && isMarkPrem && isAssessPrem && isMYFx && isSGFx){
				RE_SendCostingNotificationScheduler.sendcostMYData();
				RE_SendCostingNotificationScheduler.sendcostSGData();
            } else{
				Date dt = System.today();
                DateTime dtDate = (DateTime)(dt.addDays(-1));
				
                List<RE_Market_Quotes__c> mcqUpdates  = new List<RE_Market_Quotes__c>();
				List<RE_Market_Quotes__c> mcqFinalVals  = new List<RE_Market_Quotes__c>();
				RE_Market_Quotes__c mqDate =[SELECT CreatedDate,RE_Quote_Type__c FROM RE_Market_Quotes__c WHERE RE_Quote_Type__c IN ('Settlement') AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1];
				
                if(dtDate.format('EEEE') == 'Saturday' || dtDate.format('EEEE') == 'Sunday'){
					System.debug('DEBUG: CBU Output Should Not Generate Today for Holiday');
				}else{	
                    for(RE_Market_Quotes__c mcquote :[SELECT RE_Country__c,RE_Price__c,RE_Pricing_Date__c,RE_Quote_Name__c,RE_Quote_Type__c,RE_Rate_Unit__c,RE_Tracker__c,RE_Country_Name__c FROM RE_Market_Quotes__c WHERE RE_Quote_Type__c IN ('Settlement') AND CreatedDate =: mqDate.CreatedDate AND RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') ORDER BY CreatedDate DESC NULLS FIRST]){
                        mcqUpdates.add(mcquote);
                    } 
                
					
                    for(RE_Holiday_Calendar__c holidays: [SELECT Id, Name,RE_Holiday_Date__c from RE_Holiday_Calendar__c WHERE RE_Holiday_Date__c=: dt.addDays(-1) AND Recordtype.Name = 'MY Holiday Calendar']){
						for(RE_Market_Quotes__c obRef : mcqUpdates){
																				
							mcqFinalVals.add(new RE_Market_Quotes__c(RE_Country__c=obRef.RE_Country__c,
																	RE_Price__c = obRef.RE_Price__c,
																	RE_Pricing_Date__c = dtDate,//obRef.RE_Pricing_Date__c,
																	RE_Quote_Name__c = obRef.RE_Quote_Name__c,
																	RE_Quote_Type__c = obRef.RE_Quote_Type__c,
																	RE_Rate_Unit__c =obRef.RE_Rate_Unit__c,
																	RE_Tracker__c = obRef.RE_Tracker__c,
                                            						RE_Country_Name__c = obRef.RE_Country_Name__c));
						}
                    }
                    System.debug(!mcqFinalVals.isEmpty());
                    if(!mcqFinalVals.isEmpty() ){
                        Insert mcqFinalVals;
                    }
                } 
            }
        }
        catch(Exception e){}
    }
	
	/*******************************************************************************************************************************************************-*********
	@ Class:          sendcostMYData
	@ Version:        1.0
	@ Author:         Seemesh Patel (seemesh.patel@shell.com)
	@ Purpose:        Future method to send Costing EMail Notification to Malaysia and Singapore
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 02.02.2020 / Seemesh Patel / Created the class.
	******************************************************************************************************************************************************************/
    @future (callout=true)
    public static void sendcostMYData(){
        HTTP httpref = new HTTP();
        HttpRequest req= new HttpRequest();
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
        List<APXTConga4__Conga_Solution_Query__c> lstApexConga = [SELECT APXTConga4__Alias__c,APXTConga4__Conga_Query__c 
                                                                  FROM APXTConga4__Conga_Solution_Query__c 
                                                                  WHERE APXTConga4__Conga_Query_Name__c IN : CongaMYQueryName];
        Map<String,Id> mapQueryId = new Map<String,Id>();
        
        for(APXTConga4__Conga_Solution_Query__c apexMYConga : lstApexConga)
        {
            mapQueryId.put(apexMYConga.APXTConga4__Alias__c,apexMYConga.APXTConga4__Conga_Query__c);
        }
        
        
        String CMUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
            '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[outputquery]'+
            mapQueryId.get('outputquery')+',[outputquerysbh]'+mapQueryId.get('outputquerysbh')+',[outputquerysrw]'+
            mapQueryId.get('outputquerysrw')+',[MarketQuoteQuery]'+mapQueryId.get('MarketQuoteQuery')+',[MarketQuoteYesterday]'+
            mapQueryId.get('MarketQuoteYesterday')+',[FXRateQuery]'+mapQueryId.get('FXRateQuery')+',[FXRateYesterQuery]'+
            mapQueryId.get('FXRateYesterQuery')+',[MalMarketQuery]'+mapQueryId.get('MalMarketQuery')+',[MyMQTemperature]'+mapQueryId.get('MyMQTemperature')+',[MalMarketQueyYtd]'+
            mapQueryId.get('MalMarketQueyYtd')+',[outputmtd]'+mapQueryId.get('outputmtd')+',[outputgainloss]'+
            mapQueryId.get('outputgainloss')+',[premiaisdiscount]'+mapQueryId.get('premiaisdiscount')+',[GasoilB7Diff]'+
            mapQueryId.get('GasoilB7Diff')+',[MYMPToday]'+mapQueryId.get('MYMPToday')+',[MYMPYday]'+
            mapQueryId.get('MYMPYday')+',[MidDayUpDown]'+mapQueryId.get('MidDayUpDown')+'&Qvar0id='+EmailIds +
            '&sfdciframehost=web'+'&solmgr='+ 1+'&TemplateId='+TempId+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment'; 
       
        system.debug('CMUrl==='+CMUrl);  
        req.setEndpoint(CMUrl);
        req.setMethod('GET');
        req.setTimeout(60000);
		HttpResponse rsp = new HttpResponse();
        rsp = httpref.send(req);
        System.debug('[Debug Response] ' + rsp);
		System.debug('[Debug callout Status]  ' + rsp.getStatus());
		System.debug('[Debug Body]  ' + rsp.getBody());
    }
	
	/*******************************************************************************************************************************************************-*********
	@ Class:          sendcostSGData
	@ Version:        1.0
	@ Author:         Seemesh Patel (seemesh.patel@shell.com)
	@ Purpose:        Future method to send Costing EMail Notification to Malaysia and Singapore
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
	@ Change history: 02.02.2020 / Seemesh Patel / Created the class.
	******************************************************************************************************************************************************************/
	@future (callout=true)
    public static void sendcostSGData(){
        List<String> costingIds = new List<Id>();  
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
       //+0+'&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[SingUSCent]'+mapQueryId.get('SingUSCent')+',[SingSCent]'+mapQueryId.get('SingSCent')+',[SingMarketQuotes]'+mapQueryId.get('SingMarketQuotes')+',[SingMarketQuotesYtd]'+mapQueryId.get('SingMarketQuotesYtd')+',[SingFXRateSellTdy]'+mapQueryId.get('SingFXRateSellTdy')+',[SingFXRateExYtd]'+mapQueryId.get('SingFXRateExYtd')+',[SingFXRateSellYtd]'+mapQueryId.get('SingFXRateSellYtd')+',[SingFXRateExTdy]'+mapQueryId.get('SingFXRateExTdy')+
        String CMUrl = 'https://composer.congamerge.com/composer8/index.html?SessionId=' + sessId + '&ServerUrl=' + partnerServerUrl +'&clc='+0+
       '&CongaemailtemplateID='+EmailTempId +'&EmailAdditionalTo={Qvar0}'+'&Id=' + userId +'&isdtp=p1'+'&QueryId=[SingUSCent]'+
            mapQueryId.get('SingUSCent')+',[SingSCent]'+mapQueryId.get('SingSCent')+',[SingMarketQuotes]'+ 
            mapQueryId.get('SingMarketQuotes')+',[SingMQ0005]'+
            mapQueryId.get('SingMQ0005')+',[SingMQYstrdy0005]'+mapQueryId.get('SingMQYstrdy0005')+',[SingMarketQuotesYtd]'+
            mapQueryId.get('SingMarketQuotesYtd')+',[SingFXRateSellTdy]'+
            mapQueryId.get('SingFXRateSellTdy')+',[SingFXRateExYtd]'+mapQueryId.get('SingFXRateExYtd')+',[SingFXRateSellYtd]'+
            mapQueryId.get('SingFXRateSellYtd')+',[SingMC0Dip]'+mapQueryId.get('SingMC0Dip')+',[SingFXRateExTdy]'+
            mapQueryId.get('SingFXRateExTdy')+',[SGMPToday]'+mapQueryId.get('SGMPToday')+',[SGMPYday]'+mapQueryId.get('SGMPYday')+
            ',[SGAPToday]'+mapQueryId.get('SGAPToday')+',[SGAPYday]'+mapQueryId.get('SGAPYday')+',[SgMQTemperature]'+mapQueryId.get('SgMQTemperature')+'&Qvar0id='+EmailIds +'&sfdciframehost=web'+'&solmgr='+1+'&TemplateId='+TempId+'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment';   
        system.debug('CMUrl==='+CMUrl);   //'&ds7=13&APIMODE=12&SC0=1&SC1=Attachment'
        
        HTTP http = new HTTP();
        HttpRequest hrequest = new HttpRequest();
        hrequest.setEndpoint(CMUrl);
        hrequest.setMethod('GET');
        hrequest.setTimeout(60000);
		HttpResponse rsp = new HttpResponse();
        rsp = http.send(hrequest);
        System.debug('[Debug Response SG] ' + rsp);
		System.debug('[Debug callout SG Status]  ' + rsp.getStatus());
		System.debug('[Debug Body SG]  ' + rsp.getBody());
	}
}