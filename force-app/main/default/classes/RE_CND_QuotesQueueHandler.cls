/******************************************************************************************************************
className           :    RE_CND_QuotesqueueHandler
Description         :    Controller class for Queuable class RE_CN_Quotes_Queue
Author              :    Aasiya Siraj
Date				:	 30-April-2021 
*******************************************************************************************************************/
public class RE_CND_QuotesQueueHandler {
    
    /****************************************************************************************************************
Method Name:  getTodaysCanadianQuotes
Description:  Return the list of Canada Reuter Quotes  by iterating through RE_Zema_Quotes_Setting__c
****************************************************************************************************************/      
    public static quoteWrapper getTodaysCanadianQuotes(RE_Job_Run_Audit__c jobRunAudit){ 
        quoteWrapper qw =new quoteWrapper();
        try{
            List<Reuters_Quotes__c> todaysCanadianQuote = new List<Reuters_Quotes__c>();
            List<Reuters_Quotes__c> canadaFXRates = new List<Reuters_Quotes__c>();
            List<Id> reuterIdList = new List<ID>();
            
            Set<Id> commonQuotesForOtherCountry = new  Set<Id>();
            Set<Id> onlyCanadaQuoteIDSet = new  Set<Id>();
            Set<String> zemaQuotesNameSet = new  Set<String>();
            
            Map<Id,String> fxIdDisplayNameMap =new Map<Id,String>();
            Map<Id,String> marketIdDisplayNameMap =new Map<Id,String>();
            Map<String,String> displayNameMap = new  Map<String,String>();
            Map<String,String> currentDisplayNameMap = new  Map<String,String>();
            Map<String,String> zemaCountryMap = new  Map<String,String>();
            Map<Id, StatusWrapper> IDMovedtoMarket 	= 	new Map<Id,StatusWrapper>();
            Map<Id, StatusWrapper> IDMovedtoHistory = 	new Map<Id,StatusWrapper>();
            Map<Id, StatusWrapper> IDMovedtoFX 		= 	new Map<Id,StatusWrapper>();
            Map<String,String> nameTypeMap = new Map<String,String>();
            Map<String,String> frequencyNameMap = new Map<String,String>();
            Map<String,Boolean> pricetobeconvrtdMap = new Map<String,Boolean>();
            
            Decimal fxRate=0;
            
            //Iterating Zema Quotesto get Display Name, Type and Frequency and store them in Maps for Canada
            
            for(RE_Zema_Quotes_Settings__c zemaQuote:[SELECT Quote_Name__c,Country__c,Frequency__c,Type__c,Display_Name__c,Price_to_be_converted__c FROM RE_Zema_Quotes_Settings__c WHERE Country__c LIKE '%Canada%' AND Is_Active__c =: TRUE])
            {
                zemaQuotesNameSet.add(zemaQuote.Quote_Name__c);
                displayNameMap.put(zemaQuote.Quote_Name__c,zemaQuote.Display_Name__c);
                zemaCountryMap.put(zemaQuote.Quote_Name__c,zemaQuote.Country__c);
                nameTypeMap.put(zemaQuote.Quote_Name__c, zemaQuote.Type__c);
                frequencyNameMap.put(zemaQuote.Quote_Name__c, zemaQuote.Frequency__c);
                pricetobeconvrtdMap.put(zemaQuote.Quote_Name__c, zemaQuote.Price_to_be_converted__c);
            }
            
            //Fetching Canada Quotes from Reuters Quotes based on Quote Name in Zema Quotes Custom setting
            for(Reuters_Quotes__c reuterInstance :[SELECT Id,Quote_Name__c,Unit_Of_Measure__c,CurrencyCode__c,Pricing_Date__c,CreatedDate,Frequency__c,Price__c  
                                                   FROM Reuters_Quotes__c WHERE CreatedDate=TODAY AND Quote_Name__c IN :zemaQuotesNameSet ORDER BY CreatedDate LIMIT 50000])
            { 
                
                if(nameTypeMap.get(reuterInstance.Quote_Name__c)=='FX Rates')
                {
                    canadaFXRates.add(reuterInstance);
                    StatusWrapper sw = new StatusWrapper();
                    sw.isCreated=false;sw.isUpdated=false;sw.isFailed=false;sw.noActionRequired=false;
                    IDMovedtoFX.put(reuterInstance.Id,sw);
                    fxIdDisplayNameMap.put(reuterInstance.ID,displayNameMap.get(reuterInstance.Quote_Name__c));
                    
                    //Fx Rate of type Daily is used for conversion and calculation
                    if(frequencyNameMap.get(reuterInstance.Quote_Name__c)=='Live')
                    {
                        fxRate=reuterInstance.Price__c; 
                    }
                }
                else if(nameTypeMap.get(reuterInstance.Quote_Name__c)=='Settlement Quote')
                {
                    todaysCanadianQuote.add(reuterInstance);
                    StatusWrapper sw = new StatusWrapper();
                    sw.isCreated=false;sw.isUpdated=false;sw.isFailed=false;sw.noActionRequired=false;
                    IDMovedtoMarket.put(reuterInstance.Id,sw);
                    marketIdDisplayNameMap.put(reuterInstance.ID,displayNameMap.get(reuterInstance.Quote_Name__c));
                }
                
                currentDisplayNameMap.put(reuterInstance.Quote_Name__c,displayNameMap.get(reuterInstance.Quote_Name__c));
                reuterIdList.add(reuterInstance.Id);
                
                StatusWrapper sw1 = new StatusWrapper();
                sw1.isCreated=false;sw1.isUpdated=false;sw1.isFailed=false;sw1.noActionRequired=false;
                IDMovedtoHistory.put(reuterInstance.Id,sw1);
                
                //checking if a quote only belongs to Canada or common for other countries
                //This is defined in Zema quotes setting 
                
                if(zemaCountryMap.containsKey(reuterInstance.Quote_Name__c))
                {
                    String countryValue=zemaCountryMap.get(reuterInstance.Quote_Name__c);
                    for(String country : countryValue.split(';'))
                    {
                        if(!(country.equalsIgnoreCase('Canada')))
                        {
                            commonQuotesForOtherCountry.add(reuterInstance.Id) ;
                        }
                    }
                    if(!(commonQuotesForOtherCountry.contains(reuterInstance.Id)))
                    {
                        onlyCanadaQuoteIDSet.add(reuterInstance.Id); 
                    }
                }
            }
            
            qw.settlementQuotes			=	todaysCanadianQuote;
            qw.fxRates					=	canadaFXRates;
            qw.displayNameMap			=	currentDisplayNameMap;
            qw.marketIdDisplayNameMap	=	marketIdDisplayNameMap;
            qw.fxIdDisplayNameMap		=	fxIdDisplayNameMap;
            qw.quoteIDList				=	reuterIdList;
            qw.commonQuoteIDSet			=	commonQuotesForOtherCountry;
            qw.onlyCanadaQuoteIDSet		=	onlyCanadaQuoteIDSet;
            qw.isIDMovedtoMarket		=	IDMovedtoMarket;
            qw.isIDMovedtoHistory		=	IDMovedtoHistory;
            qw.isIDMovedtoFX			=	IDMovedtoFX;
            qw.fxRateValue				=	fxRate; 
            qw.frequencyNameMap			=	frequencyNameMap;
            qw.pricetobeconvrtdMap   	=   pricetobeconvrtdMap;
        }
        catch(Exception err)
        {
            System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
            RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
        }
        return qw;
    }
    
    
/****************************************************************************************************************
Method Name:  moveToMarketQuotes
Description:  Moves Canada reuters quotes to Market Quotes 
****************************************************************************************************************/ 
    public static Map<Id, StatusWrapper> moveToMarketQuotes(Decimal fxRate,List<Reuters_Quotes__c> canadaQuoteList,Map<String, String> displayNameMap,Map<Id,String> idDisplayMap,
                                                            RE_Job_Run_Audit__c jobRunAudit,Map<Id, StatusWrapper> isIDMovedtoMarket,Map<String,String> frequencyNameMap, Map<String,Boolean>pricetobeconvrtdMap){
                                                                try{
                                                                    List<RE_Market_Quotes__c> marketQuotesToUpsert = new List<RE_Market_Quotes__c>();
                                                                    Map<String,RE_Market_Quotes__c> marketQuoteMap = new Map<String,RE_Market_Quotes__c>();
                                                                    Map<String,String> quoteCountryMap = new Map<String,String> ();
                                                                    Set<Id> existingMarketId = new Set<Id>();
                                                                    String rateUnit;
                                                                    Map<Id, RE_CND_Utility.StatusWrapper> marketIdUpserted = new Map<Id, RE_CND_Utility.StatusWrapper>();
                                                                    List<string> quoteNameList =idDisplayMap.values();
                                                                    Set<String> canadianQuoteName = new Set<String>(quoteNameList);
                                                                    Map<String,Decimal> conversionKeyValue = new Map<String,Decimal> ();
                                                                    
                                                                    if(canadianQuoteName.size()>0)
                                                                    {
                                                                        if(fxRate==0)
                                                                        {
                                                                            String fxLiveName=[SELECT Display_Name__c FROM RE_Zema_Quotes_Settings__c 
                                                                                               WHERE Frequency__c='Live' AND Type__c='FX Rates' AND Country__c LIKE '%Canada%' AND Is_Active__c =: TRUE LIMIT 1].Display_Name__c;
                                                                            fxRate=[SELECT RE_Forex_Rate__c FROM RE_FX_Rates__c WHERE RE_Quote_Name__c=: fxLiveName ORDER BY CreatedDate DESC LIMIT 1].RE_Forex_Rate__c;
                                                                        }
                                                                        
                                                                        rateUnit= [SELECT Type__c, Default_Unit_Rate__c FROM RE_Default_Unit_Rate_Settings__c
                                                                                   WHERE Country_Name__c =: 'Canada' AND Object_Name__c = 'RE_Market_Quotes__c'
                                                                                   AND Type__c ='Settlement Quote' AND Is_Active__c =: TRUE LIMIT 1].Default_Unit_Rate__c;
                                                                        
                                                                        //checking if Canadian Quote already exist in Market Quotes
                                                                        for(RE_Market_Quotes__c existingQuote :[SELECT Id,RE_Quote_Name__c,RE_Country_Name__c,RE_Pricing_Date__c,RE_Price__c FROM RE_Market_Quotes__c
                                                                                                                WHERE RE_Quote_Name__c IN:canadianQuoteName AND (CreatedDate = LAST_N_DAYS:3) LIMIT 50000])
                                                                        {
                                                                            marketQuoteMap.put(existingQuote.RE_Quote_Name__c+existingQuote.RE_Pricing_Date__c,existingQuote);
                                                                            quoteCountryMap.put(existingQuote.RE_Quote_Name__c+existingQuote.RE_Pricing_Date__c,existingQuote.RE_Country_Name__c);
                                                                        }                
                                                                    }
                                                                    
                                                                    if(canadaQuoteList.size()>0){
                                                                        for(Reuters_Quotes__c rqc :canadaQuoteList)
                                                                        {
                                                                            //If a Market Quote with Same pricing Date already exists then check for country
                                                                            if(marketQuoteMap.containsKey(displayNameMap.get(rqc.Quote_Name__c)+rqc.Pricing_Date__c))
                                                                            {                
                                                                                String countryValue= quoteCountryMap.get(displayNameMap.get(rqc.Quote_Name__c)+rqc.Pricing_Date__c);
                                                                                //if quote exist and country is blank , update Canada(CA) in COuntry Name
                                                                                if(countryValue == NULL)
                                                                                {                            
                                                                                    RE_Market_Quotes__c marketQuote = marketQuoteMap.get(displayNameMap.get(rqc.Quote_Name__c)+rqc.Pricing_Date__c);
                                                                                    marketQuote.RE_Price__c=rqc.Price__c;
                                                                                    marketQuote.RE_Country_Name__c= 'CA';
                                                                                    marketQuote.RE_Country_Basis_Sharing_Settings__c= 'CA';
                                                                                    marketQuote.RE_Frequency__c= frequencyNameMap.get(rqc.Quote_Name__c);
                                                                                    marketQuotesToUpsert.add(marketQuote);
                                                                                    existingMarketId.add(marketQuote.Id);
                                                                                }
                                                                                else
                                                                                {
                                                                                    //if quote exist and country is not blank , check for country Name value
                                                                                    if(!(countryValue.contains('CA'))) 
                                                                                    {                             
                                                                                        RE_Market_Quotes__c marketQuote = marketQuoteMap.get(displayNameMap.get(rqc.Quote_Name__c)+rqc.Pricing_Date__c);
                                                                                        if(!(existingMarketId.contains(marketQuote.Id)))
                                                                                        {
                                                                                            marketQuote.RE_Price__c=rqc.Price__c;
                                                                                            marketQuote.RE_Country_Name__c= marketQuote.RE_Country_Name__c +';'+'CA';
                                                                                            marketQuote.RE_Frequency__c= frequencyNameMap.get(rqc.Quote_Name__c);
                                                                                            marketQuote.RE_Country_Basis_Sharing_Settings__c= marketQuote.RE_Country_Basis_Sharing_Settings__c +';'+'CA'; 
                                                                                            marketQuotesToUpsert.add(marketQuote);
                                                                                            existingMarketId.add(marketQuote.Id);
                                                                                        }
                                                                                    }
                                                                                    else
                                                                                    {   
                                                                                        RE_Market_Quotes__c marketQuote = marketQuoteMap.get(displayNameMap.get(rqc.Quote_Name__c)+rqc.Pricing_Date__c);
                                                                                        if(marketQuote.RE_Price__c==rqc.Price__c)
                                                                                        {                                
                                                                                            StatusWrapper sw2=isIDMovedtoMarket.get(rqc.Id);
                                                                                            sw2.noActionRequired=true;
                                                                                            isIDMovedtoMarket.put(rqc.Id,sw2);                            	
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            //create new record for different price
                                                                                            String unitMeasure = '';
                                                                                            if(rqc.Unit_Of_Measure__c.toLowerCase() == 'i' || rqc.Unit_Of_Measure__c == '/')
                                                                                                unitMeasure = 'LTR';
                                                                                            else if(rqc.Unit_Of_Measure__c.toLowerCase() == 't')
                                                                                                unitMeasure = 'TON';
                                                                                            else
                                                                                                unitMeasure = rqc.Unit_Of_Measure__c;
                                                                                            
                                                                                            String incomingRate=rqc.CurrencyCode__c+'/'+unitMeasure;
                                                                                            Decimal convertedPrice =rqc.Price__c; 
                                                                                            if((incomingRate==rateUnit) || (!(pricetobeconvrtdMap.get(rqc.Quote_Name__c))))
                                                                                            {
                                                                                                convertedPrice =rqc.Price__c; 
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                String ConvertedCurrency=RE_unitConversion.unitBreakUp(rateUnit)[0];
                                                                                                Map<String, Double> rateMap = new Map<String, Double>();
                                                                                                rateMap.put(ConvertedCurrency+'-'+rqc.CurrencyCode__c,fxRate);
                                                                                                RE_unitConversion  unitCon = new RE_unitConversion();
                                                                                                convertedPrice=rqc.Price__c* unitCon.unitConversionMultiplier(incomingRate,rateUnit,'Canada',null,rateMap);  
                                                                                            }
                                                                                            
                                                                                            RE_Market_Quotes__c marketQuote1 = new RE_Market_Quotes__c();
                                                                                            marketQuote1.RE_Quote_Name__c = displayNameMap.get(rqc.Quote_Name__c);
                                                                                            marketQuote1.RE_Price__c = convertedPrice;
                                                                                            marketQuote1.RE_Pricing_Date__c = rqc.Pricing_Date__c;
                                                                                            marketQuote1.RE_Quote_Type__c='Settlement';
                                                                                            marketQuote1.RE_Country_Name__c='CA';
                                                                                            marketQuote1.RE_Frequency__c= frequencyNameMap.get(rqc.Quote_Name__c);
                                                                                            marketQuote1.RE_Country_Basis_Sharing_Settings__c='CA';
                                                                                            
                                                                                            if(pricetobeconvrtdMap.get(rqc.Quote_Name__c))
                                                                                               marketQuote1.RE_Rate_Unit__c = rateUnit;
                                                                                            else
                                                                                               marketQuote1.RE_Rate_Unit__c = incomingRate; 
                                                                                            
                                                                                            marketQuotesToUpsert.add(marketQuote1);
                                                                                        }
                                                                                        
                                                                                    }   
                                                                                }
                                                                                
                                                                            }
                                                                            
                                                                            //If a Market Quote with Same pricing Date does not exists in Market Quote
                                                                            else
                                                                            {	
                                                                                String unitMeasure = '';
                                                                                if(rqc.Unit_Of_Measure__c.toLowerCase() == 'i' || rqc.Unit_Of_Measure__c == '/')
                                                                                    unitMeasure = 'LTR';
                                                                                else if(rqc.Unit_Of_Measure__c.toLowerCase() == 't')
                                                                                    unitMeasure = 'TON';
                                                                                else
                                                                                    unitMeasure = rqc.Unit_Of_Measure__c; 
                                                                                
                                                                                String incomingRate=rqc.CurrencyCode__c+'/'+unitMeasure;
                                                                                Decimal convertedPrice =rqc.Price__c; 
                                                                                
                                                                                if((incomingRate==rateUnit) || (!(pricetobeconvrtdMap.get(rqc.Quote_Name__c))))
                                                                                {
                                                                                    convertedPrice =rqc.Price__c; 
                                                                                }
                                                                                else
                                                                                {                            
                                                                                    String ConvertedCurrency=RE_unitConversion.unitBreakUp(rateUnit)[0];
                                                                                    Map<String, Double> rateMap = new Map<String, Double>();
                                                                                    rateMap.put(ConvertedCurrency+'-'+rqc.CurrencyCode__c,fxRate);
                                                                                    RE_unitConversion  unitCon = new RE_unitConversion();
                                                                                    convertedPrice=rqc.Price__c* unitCon.unitConversionMultiplier(incomingRate,rateUnit,'Canada',null,rateMap);  
                                                                                }              
                                                                                
                                                                                RE_Market_Quotes__c marketQuote = new RE_Market_Quotes__c();
                                                                                marketQuote.RE_Quote_Name__c = displayNameMap.get(rqc.Quote_Name__c);
                                                                                marketQuote.RE_Price__c = convertedPrice;
                                                                                marketQuote.RE_Frequency__c= frequencyNameMap.get(rqc.Quote_Name__c);
                                                                                marketQuote.RE_Pricing_Date__c = rqc.Pricing_Date__c;
                                                                                marketQuote.RE_Quote_Type__c='Settlement';
                                                                                marketQuote.RE_Country_Basis_Sharing_Settings__c='CA';
                                                                                marketQuote.RE_Country_Name__c='CA';
                                                                                
                                                                                if(pricetobeconvrtdMap.get(rqc.Quote_Name__c))
                                                                                  marketQuote.RE_Rate_Unit__c = rateUnit;
                                                                                else
                                                                                   marketQuote.RE_Rate_Unit__c = incomingRate; 
                                                                                
                                                                                marketQuotesToUpsert.add(marketQuote);
                                                                            }   
                                                                        }
                                                                    }
                                                                    if(marketQuotesToUpsert.size() >0)
                                                                    {
                                                                        Database.UpsertResult[] upsertStatus= Database.upsert(marketQuotesToUpsert, false);
                                                                        marketIdUpserted=RE_CND_Utility.handleUpsertResult('RE_CND_QuotesQueueHandler','moveToMarketQuotes',upsertStatus,jobRunAudit);
                                                                        isIDMovedtoMarket=getReutersmovedtoMarketCount(marketIdUpserted,isIDMovedtoMarket,idDisplayMap,jobRunAudit);
                                                                    }
                                                                }
                                                                catch(Exception err)
                                                                {
                                                                    System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
                                                                    RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
                                                                }
                                                                
                                                                return isIDMovedtoMarket;
                                                            }  
    /****************************************************************************************************************
Method Name:  getReutersmovedtoMarketCount
Description:  Update isIDMovedtoMarket to true for records that were successfully upserted to Market Quotes
****************************************************************************************************************/     
    public static Map<Id, StatusWrapper> getReutersmovedtoMarketCount(Map<Id, RE_CND_Utility.StatusWrapper> marketIdUpserted,Map<Id, StatusWrapper> isIDMovedtoMarket,
                                                                      Map<Id, String> reutersIdDisplayMap,RE_Job_Run_Audit__c jobRunAudit)
    {
        try{
            
            List <RE_Market_Quotes__c> marketUpserted= [SELECT Id,RE_Quote_Name__c FROM RE_Market_Quotes__c WHERE Id IN:marketIdUpserted.keySet() ];
            Set<Id> idSet=reutersIdDisplayMap.keySet();
            for(RE_Market_Quotes__c mk:marketUpserted )
            {
                for(Id quoteId:reutersIdDisplayMap.keySet())
                {
                    if(reutersIdDisplayMap.get(quoteId)==mk.RE_Quote_Name__c)
                    {
                        StatusWrapper sw4=isIDMovedtoMarket.get(quoteId);
                        if(marketIdUpserted.get(mk.Id).isCreated==true)
                        {
                            sw4.isCreated=true;
                            
                        }
                        else if(marketIdUpserted.get(mk.Id).isUpdated==true)
                        {
                            sw4.isUpdated=true;
                        }
                        isIDMovedtoMarket.put(quoteId,sw4);
                        
                    }
                }
            }
            
            for(Id reuterId:isIDMovedtoMarket.keySet())
            {
                StatusWrapper sw3=  isIDMovedtoMarket.get(reuterId);
                if(sw3.noActionRequired== false && sw3.isCreated==false && sw3.isUpdated==false)
                {
                    sw3.isFailed=true;
                    isIDMovedtoMarket.put(reuterId,sw3);
                }
            }
        }
        catch(Exception err)
        {
            System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
            RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
        }
        return isIDMovedtoMarket;
    }
/****************************************************************************************************************
Method Name:  moveToFXRates
Description:  Moves Canada reuters quotes to FX Rates 
****************************************************************************************************************/ 
    public static Map<Id, StatusWrapper> moveToFXRates(List<Reuters_Quotes__c> fxList,Map<String, String> displayNameMap, Map<Id,String> idDisplayMap,
                                                       RE_Job_Run_Audit__c jobRunAudit,Map<Id, StatusWrapper> isIDMovedtoFX)
    {
        try{
            List<RE_FX_Rates__c> FXRatesToUpsert = new List<RE_FX_Rates__c>();
            Map<String,RE_FX_Rates__c> FXMap = new Map<String,RE_FX_Rates__c>();
            Set<Id> existingFXId = new Set<Id>();
            Map<Id, RE_CND_Utility.StatusWrapper> FXIdUpserted =	new Map<Id, RE_CND_Utility.StatusWrapper>();
            List<string> quoteNameList =idDisplayMap.values();
            Set<String> canadianQuoteName = new Set<String>(quoteNameList);
            
            //check for existing FX rates 
            if(canadianQuoteName.size()>0)
            {
                for(RE_FX_Rates__c existingFX :[SELECT Id,RE_Quote_Name__c,RE_Pricing_Date__c FROM RE_FX_Rates__c
                                                WHERE RE_Quote_Name__c IN:canadianQuoteName AND CreatedDate= LAST_N_DAYS:3 LIMIT 50000])
                {
                    FXMap.put(existingFX.RE_Quote_Name__c+existingFX.RE_Pricing_Date__c,existingFX);
                }   
            }
            
            if(fxList.size()>0){
                for(Reuters_Quotes__c rqc :fxList)
                {
                    if(FXMap.containsKey(displayNameMap.get(rqc.Quote_Name__c)+rqc.Pricing_Date__c))
                    {
                        StatusWrapper sw2=isIDMovedtoFX.get(rqc.Id);
                        sw2.noActionRequired=true;
                        isIDMovedtoFX.put(rqc.Id,sw2);
                    }
                    else
                    {
                        RE_FX_Rates__c fxRate = new RE_FX_Rates__c();
                        fxRate.RE_Quote_Name__c = displayNameMap.get(rqc.Quote_Name__c);
                        fxRate.RE_Forex_Rate__c = rqc.Price__c;
                        fxRate.RE_Pricing_Date__c = rqc.Pricing_Date__c;
                        fxRate.RE_Trade_Type__c='Exchange Rate';
                        fxRate.RE_Base_Unit__c='USD';
                        fxRate.RE_Conversion_Unit__c = rqc.CurrencyCode__c;
                        fxRate.RE_Forex_Name__c =rqc.CurrencyCode__c+ '/USD';
                        FXRatesToUpsert.add(fxRate);
                    }   
                }
            }
            
            if(FXRatesToUpsert.size() >0)
            {
                Database.UpsertResult[] upsertStatus= Database.upsert(FXRatesToUpsert, false);
                FXIdUpserted=RE_CND_Utility.handleUpsertResult('RE_CND_QuotesQueueHandler','moveToFXRates',upsertStatus,jobRunAudit);
                isIDMovedtoFX=getReutersmovedtoFXCount(FXIdUpserted,isIDMovedtoFX,idDisplayMap,jobRunAudit);
            }
        }
        catch(Exception err)
        {
            System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
            RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
        }
        return isIDMovedtoFX;
    }
    /****************************************************************************************************************
Method Name:  getReutersmovedtoFXCount
Description:  Update isIDMovedtoFX to true for records that were successfully upserted to Market Quotes
****************************************************************************************************************/     
    public static Map<Id, StatusWrapper> getReutersmovedtoFXCount(Map<Id, RE_CND_Utility.StatusWrapper> FXIdUpserted,Map<Id, StatusWrapper>  isIDMovedtoFX,
                                                                  Map<Id, String> reutersIdDisplayMap,RE_Job_Run_Audit__c jobRunAudit)
    { 
        try{
            List <RE_FX_Rates__c> FXUpserted= [SELECT Id,RE_Quote_Name__c FROM RE_FX_Rates__c WHERE Id IN:FXIdUpserted.keySet() ];
            Set<Id> idSet=reutersIdDisplayMap.keySet();
            for(RE_FX_Rates__c fxr:FXUpserted )
            {
                for(Id quoteId:reutersIdDisplayMap.keySet())
                {
                    if(reutersIdDisplayMap.get(quoteId)==fxr.RE_Quote_Name__c)
                    {
                        //isIDMovedtoFX.put(quoteId,true);
                        StatusWrapper sw4=isIDMovedtoFX.get(quoteId);
                        if(FXIdUpserted.get(fxr.Id).isCreated)
                        {
                            sw4.isCreated=true;
                            
                        }
                        else if(FXIdUpserted.get(fxr.Id).isUpdated)
                        {
                            sw4.isUpdated=true;
                        }
                        isIDMovedtoFX.put(quoteId,sw4);
                    }
                }
            }
            for(Id reuterId:isIDMovedtoFX.keySet())
            {
                StatusWrapper sw3=  isIDMovedtoFX.get(reuterId);
                if(sw3.noActionRequired== false && sw3.isCreated==false && sw3.isUpdated==false)
                {
                    sw3.isFailed=true;
                    isIDMovedtoFX.put(reuterId,sw3);
                }
            }
        }
        catch(Exception err)
        {
            System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
            RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
        }
        return isIDMovedtoFX;
    }
    
    
    /****************************************************************************************************************
Method Name:  moveToReutersHistory
Description:  Moves Canada reuters quotes and updates Quote_display_Name in Reuters History
****************************************************************************************************************/    
    public static Map<Id, StatusWrapper> moveToReutersHistory(List<Reuters_Quotes__c> canadaQuoteList,Map<String, String> displayNameMap, List<Id> reuterIdList,
                                                              RE_Job_Run_Audit__c jobRunAudit,Map<Id, StatusWrapper> isIDMovedtoHistory){ 
                                                                  try
                                                                  {
                                                                      List<Reuters_History__c> historyReutersList = new List<Reuters_History__c>();
                                                                      Map<Id,String> historyCountryMap =new Map<Id,String>();
                                                                      Map<Id,Reuters_History__c> historyMap = new Map<Id,Reuters_History__c>();
                                                                      Map<Id, RE_CND_Utility.StatusWrapper> historyIdUpserted = new Map<Id, RE_CND_Utility.StatusWrapper>();
                                                                      
                                                                      //check if Candain Quotes already exist in history
                                                                      for(Reuters_History__c existingQuoteHistory : [SELECT Id,RE_Country_Name__c ,Reuter_Id__c
                                                                                                                     FROM Reuters_History__c
                                                                                                                     WHERE Reuter_Id__c IN :reuterIdList])
                                                                      {
                                                                          historyCountryMap.put(existingQuoteHistory.Reuter_Id__c,existingQuoteHistory.RE_Country_Name__c);
                                                                          historyMap.put(existingQuoteHistory.Reuter_Id__c,existingQuoteHistory);
                                                                      }
                                                                      
                                                                      for(Reuters_Quotes__c quote :canadaQuoteList)
                                                                      {
                                                                          if(historyCountryMap.containsKey(quote.Id))
                                                                          {
                                                                              String countryValue=historyCountryMap.get(quote.Id);
                                                                              //if quote exist and country is blank , update Canada(CA) in COuntry Name
                                                                              if(countryValue == NULL)
                                                                              {
                                                                                  Reuters_History__c historyEod = historyMap.get(quote.Id);
                                                                                  historyEod.RE_Country_Name__c = 'CA';
                                                                                  historyEod.Quote_Display_Name__c=displayNameMap.get(quote.Quote_Name__c);
                                                                                  historyEod.CurrencyCode__c=quote.CurrencyCode__c;
                                                                                  historyReutersList.add(historyEod); 
                                                                              }
                                                                              else
                                                                              {
                                                                                  //if quote exist and country is not blank , check for country Name value
                                                                                  if(!(countryValue.contains('CA')))
                                                                                  {
                                                                                      Reuters_History__c historyEod = historyMap.get(quote.Id);
                                                                                      historyEod.RE_Country_Name__c = historyEod.RE_Country_Name__c +';'+'CA';
                                                                                      historyEod.Quote_Display_Name__c=displayNameMap.get(quote.Quote_Name__c);
                                                                                      historyEod.CurrencyCode__c=quote.CurrencyCode__c;
                                                                                      historyReutersList.add(historyEod); 
                                                                                  }
                                                                                  else
                                                                                  {
                                                                                      StatusWrapper sw2=isIDMovedtoHistory.get(quote.Id);
                                                                                      sw2.noActionRequired=true;
                                                                                      isIDMovedtoHistory.put(quote.Id,sw2);
                                                                                  } 
                                                                              }
                                                                              
                                                                          }
                                                                          else
                                                                          {
                                                                              //create record in Reuters History                    
                                                                              Reuters_History__c historyEod=new Reuters_History__c();
                                                                              historyEod.Reuters_Created_Date__c=quote.CreatedDate;
                                                                              historyEod.Quote_Display_Name__c=displayNameMap.get(quote.Quote_Name__c);
                                                                              historyEod.Quote_Name__c	=quote.Quote_Name__c;
                                                                              historyEod.Price__c=quote.Price__c;
                                                                              historyEod.Reuter_Id__c=quote.Id;
                                                                              historyEod.Frequency__c=quote.Frequency__c;
                                                                              historyEod.CurrencyCode__c=quote.CurrencyCode__c;
                                                                              historyEod.Pricing_Date__c=quote.Pricing_Date__c;
                                                                              historyEod.Unit_Of_Measure__c=quote.Unit_Of_Measure__c;
                                                                              historyEod.RE_Country_Name__c='CA';
                                                                              historyReutersList.add(historyEod);
                                                                          }
                                                                      }          	
                                                                      
                                                                      if(historyReutersList.size() >0)
                                                                      {
                                                                          Database.UpsertResult[] upsertStatus = Database.upsert(historyReutersList, false);
                                                                          historyIdUpserted=RE_CND_Utility.handleUpsertResult('RE_CND_QuotesQueueHandler','moveToReutersHistory',upsertStatus,jobRunAudit);
                                                                          isIDMovedtoHistory=getReutersmovedtoHistoryCount(historyIdUpserted,isIDMovedtoHistory,reuterIdList,jobRunAudit);
                                                                      }
                                                                  }
                                                                  catch(Exception err)
                                                                  {
                                                                      System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
                                                                      RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
                                                                  }
                                                                  return isIDMovedtoHistory;
                                                              } 
    /****************************************************************************************************************
Method Name:  getReutersmovedtoHistoryCount
Description:  Update IDMovedtoHistory to true for records that were successfully upserted to Reuters History
****************************************************************************************************************/    
    public static Map<Id, StatusWrapper> getReutersmovedtoHistoryCount( Map<Id, RE_CND_Utility.StatusWrapper> historyIdUpserted,Map<Id, StatusWrapper> isIDMovedtoHistory,
                                                                       List<Id> reutersIdList,RE_Job_Run_Audit__c jobRunAudit){ 
                                                                           try
                                                                           {
                                                                               List <Reuters_History__c> historyUpserted= [SELECT Reuter_Id__c FROM Reuters_History__c WHERE Id IN:historyIdUpserted.keySet()];
                                                                               for(Reuters_History__c rh:historyUpserted )
                                                                               {
                                                                                   if(isIDMovedtoHistory.keySet().contains(rh.Reuter_Id__c))
                                                                                   {
                                                                                       StatusWrapper sw4=isIDMovedtoHistory.get(rh.Reuter_Id__c);
                                                                                       if(historyIdUpserted.get(rh.Id).isCreated==true)
                                                                                       {
                                                                                           sw4.isCreated=true;
                                                                                           
                                                                                       }
                                                                                       else if(historyIdUpserted.get(rh.Id).isUpdated==true)
                                                                                       {
                                                                                           sw4.isUpdated=true;
                                                                                       }
                                                                                       isIDMovedtoHistory.put(rh.Reuter_Id__c,sw4);
                                                                                       isIDMovedtoHistory.put(rh.Reuter_Id__c,sw4) ;
                                                                                   }
                                                                               }
                                                                           }
                                                                           catch(Exception err)
                                                                           {
                                                                               System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
                                                                               RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
                                                                           }
                                                                           return isIDMovedtoHistory;
                                                                       } 
    
    /****************************************************************************************************************
Method Name:  getStatusCount
Description:  Get Set of Success Id and a set of Failure Id.This is used further for deletion and details for mail
****************************************************************************************************************/     
    //market and history
    public static CountWrapper getStatusCount(Map<Id, StatusWrapper> idMoved,RE_Job_Run_Audit__c jobRunAudit){
        CountWrapper sfcw = new CountWrapper();
        try{
            
            for(Id i:idMoved.keySet())
            {
                statusWrapper sw5= idMoved.get(i);
                if(sw5.isCreated)
                {
                    sfcw.createdIDSet.add(i);
                    sfcw.successIDSet.add(i);
                }
                else if(sw5.isUpdated)
                {
                    sfcw.updatedIDSet.add(i);
                    sfcw.successIDSet.add(i);
                }
                else if(sw5.isFailed)
                {
                    sfcw.failureIDSet.add(i); 
                }
                else if(sw5.noActionRequired)
                {
                    sfcw.noActionIDSet.add(i);
                    sfcw.successIDSet.add(i);
                }
                
            }
        }
        catch(Exception err)
        {
            System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
            RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
        }
        return sfcw;
    }
    /****************************************************************************************************************
Method Name:  deleteCanadaQuotes
Description:  Deletes Canada Quotes from Reuters Quote.If isDeleteOtherCountry is true ,the method will delete quotes that is common for other country besides Canada
****************************************************************************************************************/    
    public static Boolean deleteQuotes(Set<Id>canadaQuoteIds,Set<Id>commonQuoteIds,Boolean isDeleteCanada,Boolean isDeleteOtherCountry,
                                       RE_Job_Run_Audit__c jobRunAudit)
    {	Boolean isDeleteError =false;
     try{
         
         List<Id> listToDelete = new List<Id>();
         if (isDeleteCanada && canadaQuoteIds.size()>0)
         {
             listToDelete.addAll(canadaQuoteIds);
         }
         if (isDeleteOtherCountry && commonQuoteIds.size()>0)
         {
             listToDelete.addAll(commonQuoteIds);
         }
         if(listToDelete.size()>0)
         {
             Database.DeleteResult[] deleteStatus = Database.delete(listToDelete, false);
             isDeleteError=RE_CND_Utility.handleDeleteResult('RE_CND_QuotesQueueHandler','deleteQuotes',deleteStatus,isDeleteError,jobRunAudit);
             
         }
     }
     catch(Exception err)
     {
         System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
         RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
     }
     return isDeleteError; 
    }
    /****************************************************************************************************************
Method Name:  partialDeleteCanadaQuotes
Description:  Deletes Quotes from Reuters Quote which were successfully moved to History or Market Quotes.
If isDeleteOtherCountry is true ,the method will delete quotes that is common for other country besides Canada
****************************************************************************************************************/    
    public static Boolean partialDeleteCanadaQuotes(Set<Id>canadaQuoteIds,Set<Id>commonQuoteIds,Boolean isDeleteCanada,Boolean isDeleteOtherCountry,
                                                    RE_Job_Run_Audit__c jobRunAudit,Set<ID> quoteId)
    {
        Boolean isDeleteError =false;
        try{
            
            List<Id> listToDelete = new List<Id>();
            for(Id reuterId :quoteId)
            {
                if (isDeleteCanada && canadaQuoteIds.contains(reuterId) )
                {
                    listToDelete.add(reuterId);
                }
                else if (isDeleteOtherCountry && commonQuoteIds.contains(reuterId))
                {
                    listToDelete.add(reuterId);
                }
            }
            if(listToDelete.size()>0)
            {
                Database.DeleteResult[] deleteStatus = Database.delete(listToDelete, false);
                isDeleteError=RE_CND_Utility.handleDeleteResult('RE_CND_QuotesQueueHandler','partialDeleteCanadaQuotes',deleteStatus,isDeleteError,jobRunAudit);
            } 
        }
        catch(Exception err)
        {
            System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
            RE_CND_Utility.updateJobAudit(jobRunAudit,'Failed',err);
        }
        return isDeleteError;
    }
    /****************************************************************************************************************
Method Name:  sendJobReportMail
Description:  method to send mail with details of the Job Run and record counts
****************************************************************************************************************/    
    public static void sendJobReportMail(Integer totalCount,CountWrapper historyWrap, CountWrapper marketWrap,
                                         CountWrapper fxWrap,Boolean isDeleteException,RE_Job_Run_Audit__c jobRunAudit)
    {
        try{
            
            String jobStatus=jobRunAudit.RE_Job_Status__c;
            if(jobRunAudit.RE_Job_Status__c=='Processing')
            {
                jobStatus='Completed'; 
            }
            
            String [] ToEmail;
            String [] ccEmail;
            String [] BCCList;
            for(RE_Email_Recipient__mdt rec : [SELECT id, Cc_List__c, To_List__c,Bcc_List__c FROM RE_Email_Recipient__mdt 
                                               WHERE Country__c =: 'Canada' AND Type__c =: 'Canada Quote Movement' AND Is_Active__c =: TRUE LIMIT 1])
            {
                if(rec.To_List__c != NULL){ToEmail = rec.To_List__c.split(';');}				
                if(rec.Cc_List__c != NULL){ccEmail = rec.Cc_List__c.split(';');}				
                if(rec.Bcc_List__c != NULL){BCCList = rec.Bcc_List__c.split(';');}                    
            }  

            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+jobRunAudit.Id;
            String emailSubject =jobStatus+':Canada Reuter Quote Movement Report - '+System.now();
            String emailBody ='Hello, <br/><br/>Canada Reuter Quote Movement Report<br/><br/><table border="1"><tr><th></th><th>Total Records</th><th>Created</th><th>Updated</th><th>No Action</th><th>Failed</th></tr><tr><td>Reuters Quote</td><td>'
                +totalCount+'</td><td></td><td></td><td></td><td></td></tr> <tr><td>Market Quotes</td><td>'
                +marketWrap.successIDSet.size()+'</td><td>'
                +marketWrap.createdIDSet.size()+'</td><td>'
                +marketWrap.updatedIDSet.size()+'</td><td>'
                +marketWrap.noActionIDSet.size()+'</td><td>'
                +marketWrap.failureIDSet.size()+'</td></tr> <tr><td>FX Rates</td><td>'
                +fxWrap.successIDSet.size()+'</td><td>'
                +fxWrap.createdIDSet.size()+'</td><td>'
                +fxWrap.updatedIDSet.size()+'</td><td>'
                +fxWrap.noActionIDSet.size()+'</td><td>'
                +fxWrap.failureIDSet.size()+'</td></tr><tr><td>Reuter History</td><td>'
                +historyWrap.successIDSet.size()+'</td><td>'
                +historyWrap.createdIDSet.size()+'</td><td>'
                +historyWrap.updatedIDSet.size()+'</td><td>'
                +historyWrap.noActionIDSet.size()+'</td><td>'
                +historyWrap.failureIDSet.size()+'</td></tr></table>';
            if(isDeleteException)
            {
                emailBody=emailBody+'<br/><p style="color:red;">Note:Issue while deleting Reuters Quote.Refer RV_exception for more details with jobAudit :<a href='+Recordlink
                    +'>'+ jobRunAudit.Id+'</a></p>';
            }
            emailBody=emailBody+'<br/><br/>Regards,<br/> Rev Canada';
            RE_CND_Utility.sendEmail(ToEmail,ccEmail,BCCList,emailSubject,emailBody,jobRunAudit);
        }
        catch(Exception err)
        {
            System.debug('QueueHandler--line--'+err.getLineNumber()+'--exception--'+err.getCause());
            RE_CND_Utility.updateJobAuditPartialSuccess(jobRunAudit,err.getMessage(), 'Exception while sending email notification');
        }
        
    }   
    /****************************************************************************************************************
Class Name:  QuoteWrapper
Description:  Wrapper class to return list of canada quotes and their corresponding display names from Custom Setting RE_Zema_Quotes_Setting__c
****************************************************************************************************************/  
    public class QuoteWrapper
    {
        public Decimal fxRateValue ;
        public List<Reuters_Quotes__c> settlementQuotes = new List<Reuters_Quotes__c>();
        public List<Reuters_Quotes__c> fxRates = new List<Reuters_Quotes__c>();
        
        public Set<Id> commonQuoteIDSet = new Set<Id>();
        public List<Id> quoteIDList = new List<Id>();
        public Set<Id> onlyCanadaQuoteIDSet = new Set<Id>();
        
        public Map<Id,String> fxIdDisplayNameMap =new Map<Id,String>();
        public Map<Id,String> marketIdDisplayNameMap =new Map<Id,String>();
        public Map<String, String> displayNameMap = new Map<String,String>();
        public Map<String,String> frequencyNameMap = new Map<String,String>();
        public Map<String,Boolean> pricetobeconvrtdMap = new Map<String,Boolean>();
        
        public Map<Id, StatusWrapper> isIDMovedtoMarket 	= new Map<Id,StatusWrapper>();
        public Map<Id, StatusWrapper> isIDMovedtoHistory 	= new Map<Id,StatusWrapper>();
        public Map<Id, StatusWrapper> isIDMovedtoFX 		= new Map<Id,StatusWrapper>();
    }
    
    /****************************************************************************************************************
Class Name:  SuccessFailureCountWrapper
Description:  Wrapper class to store seggregated success and failure ids in a Set
****************************************************************************************************************/     
    public class CountWrapper
    {
        public Set<Id> createdIDSet = new Set<Id>();
        public Set<Id> updatedIDSet = new Set<Id>();
        public Set<Id> noActionIDSet = new Set<Id>();
        public Set<Id> failureIDSet = new Set<Id>();
        public Set<Id> successIDSet= new Set<Id>();
    }
    
    public class StatusWrapper
    {
        public Boolean isCreated;
        public Boolean isUpdated;
        public Boolean isFailed;
        public Boolean noActionRequired;
    }    
    
}