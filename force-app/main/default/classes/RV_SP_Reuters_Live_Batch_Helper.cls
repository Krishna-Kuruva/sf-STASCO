public class RV_SP_Reuters_Live_Batch_Helper {

    public static Map<String,DateTime> getListOfData(Datetime lastpickedRecordDate, Map<String,String> quoteNameAndFrequency){
        //System.debug('quoteNameAndFrequency '+quoteNameAndFrequency); 
        //System.debug('lastpickedRecordDate '+lastpickedRecordDate); 
        Map<String, DateTime> mapOfQuoteMonthAndReuters=new Map<String,DateTime>();
        List<AggregateResult> lastestReuterQuotesList= [SELECT  Quote_Name__c,
                Valid_Month__c,
                Max(createddate) maxCreatedDate FROM Reuters_Quotes__c WHERE CreatedDate <= :lastpickedRecordDate AND
        Frequency__c = 'live' GROUP BY Quote_Name__c,
                Valid_Month__c];
        //System.debug('=======lastestReuterQuotesList========'+lastestReuterQuotesList.size());
        for(AggregateResult agr:lastestReuterQuotesList){
            String quoteName=(String)agr.get('Quote_Name__c');
            if(quoteName=='EU/USD Currency' || quoteName=='CHF/USD Currency' || quoteNameAndFrequency.containsKey(quoteName) == false) //quoteNameAndFrequency.get(quoteName)=='daily'
            {
                mapOfQuoteMonthAndReuters.put(quoteName,((DateTime)agr.get('maxCreatedDate'))) ;
                //System.debug('=======if========'+mapOfQuoteMonthAndReuters);

            }

            else{
                mapOfQuoteMonthAndReuters.put(quoteName+(String)agr.get('Valid_Month__c'), ((DateTime)agr.get('maxCreatedDate'))) ;
                //System.debug('=======else========'+mapOfQuoteMonthAndReuters);
            }
        }
        //System.debug('mapOfQuoteMonthAndReuters '+mapOfQuoteMonthAndReuters);
        //mapOfQuoteMonthAndReuters = fetchDailyQuotes(mapOfQuoteMonthAndReuters);
        return mapOfQuoteMonthAndReuters;
    }

    public static Map<String, QuoteDatesWrapper> fetchDailyQuotes(){
        Map<String, QuoteDatesWrapper> quoteNameVsDateWrapMap = new Map<String, QuoteDatesWrapper>();
        List<Reuters_Quotes__c> lastestReuterQuotesList= [SELECT  Quote_Name__c,
                Valid_Month__c,
                Pricing_Date__c,
                Createddate FROM Reuters_Quotes__c  WHERE Frequency__c != 'live' AND
        Pricing_Date__c <= TODAY ORDER BY Quote_Name__c,
                Pricing_Date__c,
                Createddate];
        for(Reuters_Quotes__c reuterQuotes : lastestReuterQuotesList){
            QuoteDatesWrapper quoteDatesWrap = new QuoteDatesWrapper();
            if(reuterQuotes.Pricing_Date__c != null)
                quoteDatesWrap.pricingDate = reuterQuotes.Pricing_Date__c;
            quoteDatesWrap.createdDate = reuterQuotes.CreatedDate;
            quoteNameVsDateWrapMap.put(reuterQuotes.Quote_Name__c, quoteDatesWrap);
        }
        return quoteNameVsDateWrapMap;
    }

    public static Map<String,String> getMapOFQuoteNameAndFrequency(){
        Map<String,String> quoteNameAndFrequency=new Map<String,String>();
        List<Reuters_ICE_Calculation__c>  quoteList=[Select Quote_Name__c,frequency__c from Reuters_ICE_Calculation__c];
        for(Reuters_ICE_Calculation__c quoteVal:quoteList)
        {
            quoteNameAndFrequency.put(quoteVal.Quote_Name__c,quoteVal.frequency__c);
        }

        return quoteNameAndFrequency;
    }

    public static void cloneAndDeleteDailyRec(List<Reuters_Quotes__c> listOfallQuotes, List<Reuters_Quotes__c> listOfQuotesToCloneDaily,
            Map<String, QuoteDatesWrapper> quoteNameVsDateWrapMap, Map<String,String> quoteNameAndFrequency)//Fix_PBI_489251_26052020_Lakshmi
    {
        //Fix_PBI_489251_26052020_Lakshmi_starts
        Set<ID> RHId = new Set<ID>();
        Set<String> quoteNames = quoteNameVsDateWrapMap.keySet();

        List<Reuters_History__c> ReutershistoryList = [SELECT Id,Reuter_Id__c,Quote_Name__c from Reuters_History__c
        where Quote_Name__c in : quoteNames order by CreatedDate desc limit 50000];
        //system.debug('ReutershistoryList'+ReutershistoryList.size());
        if(ReutershistoryList.size()!=0){
            for (Reuters_History__c rh :ReutershistoryList)
            {
                RHId.Add(rh.Reuter_Id__c);
            }
        }
        // system.debug('RHId'+RHId);
        //Fix_PBI_489251_26052020_Lakshmi_Ends

        List<Reuters_Quotes__c> listOfQuotesToDeleteDaily=new List<Reuters_Quotes__c>();
        List<Id> historyObjIdSuccessList=new List<Id>();
        List<Reuters_History__c> historyReutersList=new List<Reuters_History__c>();

        //Fix_PBI_489251_26052020_Lakshmi_starts
        if(ReutershistoryList.size()==0){

            for(Reuters_Quotes__c quote:listOfQuotesToCloneDaily)
            {

                Reuters_History__c historyEod=new Reuters_History__c();
                historyEod.Reuters_Created_Date__c=quote.CreatedDate;
                historyEod.Valid_To_Date__c=quote.Valid_To_Date__c;
                historyEod.Valid_From_Date__c=quote.Valid_From_Date__c;
                historyEod.Quote_Display_Name__c=quote.Quote_Display_Name__c;
                historyEod.Valid_Month__c=quote.Valid_Month__c;
                historyEod.Quote_Name__c	=quote.Quote_Name__c;
                historyEod.Price__c=quote.Price__c;
                historyEod.Reuter_Id__c=quote.Id;
                historyEod.Frequency__c=quote.Frequency__c;
                historyEod.Pricing_Date__c=quote.Pricing_Date__c;
                historyEod.Unit_Of_Measure__c=quote.Unit_Of_Measure__c;
                historyReutersList.add(historyEod);

            }
        }
        //Fix_PBI_489251_26052020_Lakshmi_Ends
        else{ //Fix_PBI_489251_26052020_Lakshmi

            for(Reuters_Quotes__c quote:listOfQuotesToCloneDaily)
            {

                if(!RHId.contains(quote.Id)){ //Fix_PBI_489251_26052020_Lakshmi

                    Reuters_History__c historyEod=new Reuters_History__c();
                    historyEod.Reuters_Created_Date__c=quote.CreatedDate;
                    historyEod.Valid_To_Date__c=quote.Valid_To_Date__c;
                    historyEod.Valid_From_Date__c=quote.Valid_From_Date__c;
                    historyEod.Quote_Display_Name__c=quote.Quote_Display_Name__c;
                    historyEod.Valid_Month__c=quote.Valid_Month__c;
                    historyEod.Quote_Name__c	=quote.Quote_Name__c;
                    historyEod.Price__c=quote.Price__c;
                    historyEod.Reuter_Id__c=quote.Id;
                    historyEod.Frequency__c=quote.Frequency__c;
                    historyEod.Pricing_Date__c=quote.Pricing_Date__c;
                    historyEod.Unit_Of_Measure__c=quote.Unit_Of_Measure__c;
                    historyReutersList.add(historyEod);

                }
            }

        }
        //system.debug('historyReutersList'+historyReutersList.size());

        Database.SaveResult[] historyInserted=Database.insert(historyReutersList, false);
        for (Database.SaveResult sr : historyInserted) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //System.debug('Successfully inserted Reuters ' + sr.getId());
                historyObjIdSuccessList.add(sr.getId());
            }
            else{
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Reuters fields that affected this error: ' + err.getFields());
                }
            }
        }
        Map<String,List<DateTime>> QuoteMonthAndReuters=new Map<String,List<DateTime>>();
        Map<String,List<DateTime>> result=new Map<String,List<DateTime>>();
        for(Reuters_Quotes__c quote : listOfallQuotes){
            String key=quote.Quote_Name__c;
            /*if(quote.CreatedDate < mapOfQuoteMonthAndReuters.get(key) && quoteNameAndFrequency.get(key)=='Daily'){
                listOfQuotesToDeleteDaily.add(quote);
            }
            else if(quote.CreatedDate < mapOfQuoteMonthAndReuters.get(key)){
                listOfQuotesToDeleteDaily.add(quote);
            }*/
            if(!quoteNameVsDateWrapMap.isEmpty() && quoteNameVsDateWrapMap.containsKey(key) && quote.Pricing_Date__c != null){
                QuoteDatesWrapper quoteDatesWrap = quoteNameVsDateWrapMap.get(key);
                System.debug('quoteDatesWrap: '+quoteDatesWrap);
                if(quoteDatesWrap != null){
                    if(quoteDatesWrap.pricingDate != null && quote.Pricing_Date__c < quoteDatesWrap.pricingDate){
                        listOfQuotesToDeleteDaily.add(quote);
                    }
                    else if(quote.Pricing_Date__c == quoteDatesWrap.pricingDate){
                        if(quoteDatesWrap.CreatedDate != null && quote.createdDate < quoteDatesWrap.CreatedDate){
                            listOfQuotesToDeleteDaily.add(quote);
                        }
                    }
                }
            }
        }
        if(!listOfQuotesToDeleteDaily.isEmpty()){
            Database.delete(listOfQuotesToDeleteDaily, false);
        }
    }


    public static void deleteLiveRec(List<Reuters_Quotes__c> listOfQuotesToDeleteLive){
        //delete listOfQuotesToDeleteLive;
        Database.delete(listOfQuotesToDeleteLive, false);
    }

    public class QuoteDatesWrapper{
        public Date pricingDate;
        public DateTime createdDate;
    }

}