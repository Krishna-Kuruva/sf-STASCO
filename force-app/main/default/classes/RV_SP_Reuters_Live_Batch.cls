global class RV_SP_Reuters_Live_Batch  implements Database.Batchable<Sobject>,Database.Stateful{
   
   global final String Query;
   global final String Entity;
   global final String Field;
   global final String Value;
   global final  DateTime lastpickedRecordDate;
   global Map<String,DateTime> mapOfQuoteMonthAndReuters; 
   global  Map<String,String> mapofQuoteAndFrequency;
   Map<String, RV_SP_Reuters_Live_Batch_Helper.QuoteDatesWrapper> quoteNameVsDateWrapMap = new Map<String, RV_SP_Reuters_Live_Batch_Helper.QuoteDatesWrapper>();

   global RV_SP_Reuters_Live_Batch(String q,DateTime lastpickedRecordDateInner,Map<String,String> mapofQuoteAndFrequencyInner){
      Query = q;
      lastpickedRecordDate = lastpickedRecordDateInner;
      mapofQuoteAndFrequency = mapofQuoteAndFrequencyInner;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      mapOfQuoteMonthAndReuters = RV_SP_Reuters_Live_Batch_Helper.getListOfData(lastpickedRecordDate,mapofQuoteAndFrequency);
      quoteNameVsDateWrapMap = RV_SP_Reuters_Live_Batch_Helper.fetchDailyQuotes();
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Reuters_Quotes__c> listOfQuotes){
      List<Reuters_Quotes__c> listOfQuotesToDeleteLive=new List<Reuters_Quotes__c>();
      List<Reuters_Quotes__c> listOfQuotesToCloneDaily=new List<Reuters_Quotes__c>();
      //System.debug('batch listOfQuotes size: '+listOfQuotes.size());
      for(Reuters_Quotes__c quote: listOfQuotes){ 
         String liveKey=quote.Quote_Name__c+quote.Valid_Month__c;
         String dailyKey=quote.Quote_Name__c;
         
         if(quote.CreatedDate < mapOfQuoteMonthAndReuters.get(liveKey) && mapofQuoteAndFrequency.get(quote.Quote_Name__c)=='Live'){
            listOfQuotesToDeleteLive.add(quote);
         }
         //else if(quote.CreatedDate < mapOfQuoteMonthAndReuters.get(dailyKey)&&mapofQuoteAndFrequency.get(quote.Quote_Name__c)=='Daily')//Fix_PBI_489251_26052020_Lakshmi
         /*else if(quote.CreatedDate <= mapOfQuoteMonthAndReuters.get(dailyKey)&&mapofQuoteAndFrequency.get(quote.Quote_Name__c)=='Daily'){
            listOfQuotesToCloneDaily.add(quote);  
         }
         // else if(quote.CreatedDate < mapOfQuoteMonthAndReuters.get(dailyKey))//Fix_PBI_489251_26052020_Lakshmi
         else if(quote.CreatedDate <= mapOfQuoteMonthAndReuters.get(dailyKey)){
            listOfQuotesToCloneDaily.add(quote);    
         }*/
         if(!quoteNameVsDateWrapMap.isEmpty() && quoteNameVsDateWrapMap.containsKey(dailyKey) && quote.Pricing_Date__c != null){
            RV_SP_Reuters_Live_Batch_Helper.QuoteDatesWrapper quoteDatesWrap = quoteNameVsDateWrapMap.get(dailyKey);
            if(quoteDatesWrap != null && quoteDatesWrap.CreatedDate != null && quote.createdDate <= quoteDatesWrap.CreatedDate){
               listOfQuotesToCloneDaily.add(quote);  
            }
         }
      }
      if(listOfQuotesToCloneDaily!=null && listOfQuotesToCloneDaily.isEmpty()==false)  {
         //system.debug('listOfQuotesToCloneDaily'+listOfQuotesToCloneDaily);
         //RV_SP_Reuters_Live_Batch_Helper.cloneAndDeleteDailyRec(listOfQuotesToCloneDaily);//Fix_PBI_489251_26052020_Lakshmi
         RV_SP_Reuters_Live_Batch_Helper.cloneAndDeleteDailyRec(listOfQuotes,listOfQuotesToCloneDaily,quoteNameVsDateWrapMap,mapofQuoteAndFrequency);
         
      }                  
      if(listOfQuotesToDeleteLive!=null&&listOfQuotesToDeleteLive.isEmpty()==false){ 
         RV_SP_Reuters_Live_Batch_Helper.deleteLiveRec(listOfQuotesToDeleteLive);
      }                     
   }

   global void finish(Database.BatchableContext BC){  

   }

}