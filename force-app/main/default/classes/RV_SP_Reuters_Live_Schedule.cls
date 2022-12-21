global class RV_SP_Reuters_Live_Schedule implements Schedulable {

   global void execute(SchedulableContext SC) {

      executeReutersBatch();
   }    
    
    public static void cronSchedule()
    {
        System.schedule('CloneAndDelete Daily and Delete Live Data', '0 0 * * * ?', new RV_SP_Reuters_Live_Schedule() );
    }
    
    
    
    public static void executeReutersBatch(){
        DateTime lastDateTobePicked=System.now();
        Map<String,String> mapofQuoteAndFrequency=RV_SP_Reuters_Live_Batch_Helper.getMapOFQuoteNameAndFrequency();
        Set<String> quoteNames = mapofQuoteAndFrequency.keySet();
        //Fix_PBI_489251_26052020_Lakshmi
       String query='Select Id,Quote_Name__c,Valid_Month__c,CreatedDate,Valid_To_Date__c,Valid_From_Date__c,Quote_Display_Name__c,Price__c,Frequency__c,Pricing_Date__c,Unit_Of_Measure__c from  Reuters_Quotes__c' 
           +' where' 
            //'Quote_Name__c in : quoteNames and'   
           +'  CreatedDate <=' + lastDateTobePicked.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
   
         //System.debug('executeReutersBatch quoteNameAndFrequency '+mapofQuoteAndFrequency); 
         //System.debug(' executeReutersBatch lastpickedRecordDate '+lastDateTobePicked); 
          String batchId=  Database.executeBatch(new RV_SP_Reuters_Live_Batch(query,lastDateTobePicked,mapofQuoteAndFrequency),2000);
   }
    
    
}