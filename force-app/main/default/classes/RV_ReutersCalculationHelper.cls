public class RV_ReutersCalculationHelper{
    
    private static RV_ReutersCalculationHelper instance = null;
    private RV_ReutersCalculationHelper(){
    }
    public static RV_ReutersCalculationHelper getInstance(){
        if(instance == null) 
            instance = new RV_ReutersCalculationHelper();
        
        return instance;
    }
    
    
    public void checkandUpdateGeltQuotes(Boolean isLiveExchangeRateChanged,
                                         Map<String,Decimal> newGeltQuotes,List<String> geltQuotesNameWithOtherCurrency)
    {
        if(isLiveExchangeRateChanged==true)
        {
            
      
            
            List<Reuters_Quotes__c> geltList= [select Quote_Name__c,Price__c ,Quote_Display_Name__c   from Reuters_Quotes__c where 
                                               (Quote_Display_Name__c in : geltQuotesNameWithOtherCurrency and Quote_Display_Name__c not in : newGeltQuotes.keySet()) or 
                                               (Quote_Display_Name__c in ('EUR/CHF','EUR/USD')) order by createdDate desc ];
            if(geltList.isEmpty()==false)
            {
                for(Reuters_Quotes__c reuterQuote:geltList)
                {
                    if(newGeltQuotes.containsKey(reuterQuote.Quote_Display_Name__c)==false)
                    {
                        newGeltQuotes.put(reuterQuote.Quote_Display_Name__c,reuterQuote.Price__c);
                    }
                }
                
            }     
            Decimal usdConversionRate=newGeltQuotes.get('EUR/USD');
            Decimal chfConversionRate=newGeltQuotes.get('EUR/CHF');   
            newGeltQuotes.remove('EUR/USD');
            newGeltQuotes.remove('EUR/CHF');
            
            for(String quoteDisplayName:newGeltQuotes.keySet())
            {
                
                if(geltQuotesNameWithOtherCurrency.contains(quoteDisplayName)==true)
                {
                    Decimal quotePrice=newGeltQuotes.get(quoteDisplayName);
                    Decimal USDToEUR=1/usdConversionRate;
                    quotePrice=quotePrice * chfConversionRate*USDToEUR;
                    newGeltQuotes.put(quoteDisplayName,quotePrice);           
                }  
                
            }
            
        }
        
        
        if(newGeltQuotes.isEmpty()==false)
        {
            updateFreightRates(newGeltQuotes);
        }
        
        
    }
    
    
    
    
    public void updateFreightRates(Map<String,Decimal> rqFreightMap){
        
        //system.debug('HELPER inside update FREIGHT  '+rqFreightMap);
        List<Freight_Rate__c> freightObjList = [Select id,name ,Destination__c,Freight_Cost__c,Freight_diff_EUR_mt__c,
                                                Freight_Percentage__c,Freight_Quotation__c,
                                                Marker__c,Mode_Of_Transport__c,Source__c,
                                                Valid_From__c,Valid_To__c from Freight_Rate__c
                                                where Mode_Of_Transport__c = 'Barge' and  Freight_Quotation__c in : rqFreightMap.keySet() ];
        //system.debug('HELPER inside update FREIGHT  MAP------>'+rqFreightMap);
        //system.debug('HELPER inside update FREIGHT  LIST------>'+freightObjList);
        for(Freight_Rate__c frObj :freightObjList){
            
            if (rqFreightMap.containsKey(frObj.Freight_Quotation__c) && rqFreightMap.get(frObj.Freight_Quotation__c) != null){
                frObj.Marker__c = rqFreightMap.get(frObj.Freight_Quotation__c);
            }
        }
        try{
            update freightObjList;
        }catch(Exception e){
            system.debug('Exception while updating freight rate '+e);
        }
    }
    
    
    public static void beforeInsetUpdate()
    {
        Set<Reuters_Quotes__c> updateList = new Set<Reuters_Quotes__c>();
        
        Map<String,Reuters_Quotes__c> rqPlattsMap = new Map<String,Reuters_Quotes__c>();
        Map<String,Reuters_Quotes__c> qNamesMap = new Map<String,Reuters_Quotes__c>();
        Map<String,Reuters_ICE_Calculation__c> plattsNameMap = new Map<String,Reuters_ICE_Calculation__c>();
        Map<String,Reuters_ICE_Calculation__c> iceNameMap = new Map<String,Reuters_ICE_Calculation__c>();
        
        Map<id,Reuters_Quotes__c> quoteObjList;
        List<String> qList = new List<String>();
        Reuters_Quotes__c extObj;
        String iceKEY;
        boolean isUpdate = false;
        
        //Decimal dailyRate =0;
        Decimal galToBBL =100;
        // Decimal meToT =0.42;
        // Decimal convertCHFRate = 1;
        // Decimal convertRate =1;
        DateTime myDateTime = System.now();
        String dayOfWeek = myDateTime.format('EEE');
        Map<String,Reuters_Quotes__c> rqICEMap = new Map<String,Reuters_Quotes__c>(); 
        List<Reuters_Quotes__c> listOfLiveDataDelete=new List<Reuters_Quotes__c>(); 
        Set<String> iceKeysPresent=new Set<String>();
        
        List<String> quoteNames=new List<String>();
        for(Reuters_Quotes__c reuter:(List<Reuters_Quotes__c>)Trigger.New)
        {
            quoteNames.add(reuter.Quote_Name__c);
            
            
        }
        
        
        List<Reuters_ICE_Calculation__c> quoteList= [Select Id,Display_Name__c,frequency__c,Quote_Name__c,Name,Column__c, ProdDiff_Display_Name__c 
                                                     from Reuters_ICE_Calculation__c where Quote_Name__c in :quoteNames ];
        
       // Column__c, ProdDiff_Display_Name__c
        //System.debug('quoteList '+quoteList);
        for(Reuters_ICE_Calculation__c ice:quoteList){
            if(ice.frequency__c.equalsIgnoreCase('Daily'))
                plattsNameMap.put(ice.Quote_Name__c,ice);
            if(ice.frequency__c.equalsIgnoreCase('Live'))
                iceNameMap.put(ice.Quote_Name__c,ice);
            
            qList.add(ice.Quote_Name__c);
        }
        
        //create Platts quotes Map
        if(dayOfWeek == 'Mon'){
            quoteObjList = new Map<id,Reuters_Quotes__c>([ select id ,Name,Quote_Name__c,Price__c ,Unit_Of_Measure__c,CurrencyCode__c,
                                                          Price_USD__c,Pricing_Date__c,Valid_From_Date__c,Valid_Month__c,Valid_To_Date__c
                                                          from Reuters_Quotes__c where 
                                                          Quote_Name__c in : qList AND CreatedDate >=: system.now()-3  order by Name ]);
        }else{
            quoteObjList = new Map<id,Reuters_Quotes__c>([ select id ,Name,Quote_Name__c,Price__c ,Unit_Of_Measure__c,CurrencyCode__c,
                                                          Price_USD__c,Pricing_Date__c,Valid_From_Date__c,Valid_Month__c,Valid_To_Date__c
                                                          from Reuters_Quotes__c where 
                                                          Quote_Name__c in : qList AND createdDate >= YESTERDAY  order by Name ]);
        }
        Integer counter=0;
        
        
        //System.debug('Sze '+quoteObjList.size());
        
        
        for(Reuters_Quotes__c rqObj: (List<Reuters_Quotes__c>)Trigger.New){
            
            //System.debug('rqObj >> '+rqObj);
            if(rqObj.Quote_Name__c == 'EU/USD Currency'||rqObj.Quote_Name__c == 'CHF/USD Currency'){
                
                iceKeysPresent.add(rqObj.Quote_Name__c);
            }
            
            if(iceNameMap.containsKey(rqObj.Quote_Name__c))
            {
                iceKeysPresent.add(rqObj.Quote_Name__c+rqObj.Valid_Month__c);
                
            }
            
            
            /*if(rqObj.Unit_Of_Measure__c == 'GAL' ){
                rqObj.Price__c = rqObj.Price__c * galToBBL;
                rqObj.Unit_Of_Measure__c = 'BBL';
            }*/
            
            //update display Name 
            if(plattsNameMap.containsKey(rqObj.Quote_Name__c)){
                
                   rqObj.Column__c=plattsNameMap.get(rqObj.Quote_Name__c).Column__c;
                   rqObj.ProdDiff_Display_Name__c=plattsNameMap.get(rqObj.Quote_Name__c).ProdDiff_Display_Name__c;
                rqObj.Frequency__c=plattsNameMap.get(rqObj.Quote_Name__c).Frequency__c;
                
                if(plattsNameMap.get(rqObj.Quote_Name__c).Display_Name__c != null){
                    rqObj.Quote_Display_Name__c = plattsNameMap.get(rqObj.Quote_Name__c).Display_Name__c;
                 
                }else{
                    rqObj.Quote_Display_Name__c = rqObj.Quote_Name__c;
                }
            }
            if(iceNameMap.containsKey(rqObj.Quote_Name__c)){
                  rqObj.Column__c=iceNameMap.get(rqObj.Quote_Name__c).Column__c;
                   rqObj.ProdDiff_Display_Name__c=iceNameMap.get(rqObj.Quote_Name__c).ProdDiff_Display_Name__c;
                 rqObj.Frequency__c=iceNameMap.get(rqObj.Quote_Name__c).Frequency__c;
                if(iceNameMap.get(rqObj.Quote_Name__c).Display_Name__c != null){
                    rqObj.Quote_Display_Name__c = iceNameMap.get(rqObj.Quote_Name__c).Display_Name__c;
                }else{
                    rqObj.Quote_Display_Name__c = rqObj.Quote_Name__c;
                }
            }
            
        }
        
        
        
        //System.debug('Ice Key Present---'+iceKeysPresent);
        //system.debug('----QUOTE LIST   ----'+quoteObjList );
        
        
        
        
        if(quoteObjList != NULL){
            for(Reuters_Quotes__c qObj :quoteObjList.values() ){
                //System.debug('All Quotes>>'+qObj.Id);
                if(plattsNameMap.keySet().contains(qObj.Quote_Name__c)){
                    if(qObj.Price__c != null && qObj.Price__c != 0)
                        rqPlattsMap.put(plattsNameMap.get(qObj.Quote_Name__c).Name,qObj);
                }
                if(iceNameMap.keySet().contains(qObj.Quote_Name__c)){
                    if(qObj.Price__c != null && qObj.Price__c != 0)
                    {
                        rqICEMap.put(iceNameMap.get(qObj.Quote_Name__c).Name+qObj.Valid_Month__c,qObj);
                        
                    }
                }
                if(!qNamesMap.containsKey(qObj.Quote_Name__c)){
                    if(qObj.Valid_Month__c != NULL)
                        qNamesMap.put(qObj.Quote_Name__c+qObj.Valid_Month__c,qObj);
                    else
                        qNamesMap.put(qObj.Quote_Name__c,qObj);
                }
                
                
                if(iceKeysPresent!=null)
                {
                    
                    if(qobj.Valid_Month__c!=null&&iceKeysPresent.contains(qObj.Quote_Name__c+qobj.Valid_Month__c))
                    {
                        listOfLiveDataDelete.add(qObj);
                    }
                    
                    if((qobj.Quote_Name__c == 'EU/USD Currency'||qObj.Quote_Name__c == 'CHF/USD Currency')){
                        
                        listOfLiveDataDelete.add(qObj);
                    }
                    
                }
                
            }
        }
        
        //System.debug('Heap Size consumed 1 >>'+ Limits.getHeapSize()+' iceNameMap '+iceNameMap );
        
        
        
        
        //System.debug('Deleting live Reuters-->'+listOfLiveDataDelete);
        
        if(listOfLiveDataDelete!=null && !listOfLiveDataDelete.isEmpty()){
            try
            {
                delete  listOfLiveDataDelete;
            }
            catch(Exception e)
            {
                System.debug('Error while deleting reuter quotes >>'+e+' List>>'+updateList);
            } 
        }
        
    }
    
    public static void afterUpdateInsert()
    {
        
        
        boolean isLiveExchangeRateUpdated = false;
        boolean isFreightRateUpdate = false;
                Map<String,Decimal> rqFreightMap = new Map<String,Decimal>();       
          RV_ReutersCalculationHelper helperObj = RV_ReutersCalculationHelper.getInstance();
                  List<String> geltQuotesNameWithOtherCurrency=new List<String>() ;
            Set<String> productDifferentialQuoteNames=new Set<String>();
         List<Reuters_ICE_Calculation__c> reuterCusSettngs;
        
        List<Reuters_Quotes__c> geltList= [select id ,Name,Quote_Name__c,Price__c ,Unit_Of_Measure__c,CurrencyCode__c,
                                           Price_USD__c,Pricing_Date__c,Quote_Display_Name__c   from Reuters_Quotes__c where 
                                           Quote_Display_Name__c LIKE '%PJK%' ];
        List<Reuters_ICE_Calculation__c> quoteListForGeltCHF= 
            [Select Quote_Name__c from Reuters_ICE_Calculation__c where Gelt_Other_Currency__c =true  ];
        
        
        for(Reuters_Quotes__c rqObj: (List<Reuters_Quotes__c>)Trigger.New){
            //System.debug('Heap Size consumed in loop >>'+ Limits.getHeapSize() );
            if(rqObj.Quote_Name__c.contains('GELT')){
                isFreightRateUpdate = true;
                rqFreightMap.put(rqObj.Quote_Display_Name__c.trim(), rqObj.Price__c);
            }
            if(rqObj.Quote_Name__c.contains('EU/USD Currency')){
                isLiveExchangeRateUpdated = true;
                
                
            }
            if(rqObj.Quote_Name__c.contains('CHF/USD Currency')){
                isLiveExchangeRateUpdated = true;
                
                
            }
            
        }
        
           reuterCusSettngs= [Select Id,Display_Name__c,frequency__c,
                                                                Quote_Name__c,Name,Gelt_Other_Currency__c,Product_Differential__c  
                                                                from Reuters_ICE_Calculation__c 
                                                                where Gelt_Other_Currency__c=true or Product_Differential__c=true];
            for(Reuters_ICE_Calculation__c reuterCusSettng:reuterCusSettngs)
            {
                if(reuterCusSettng.Gelt_Other_Currency__c)
                {
                    geltQuotesNameWithOtherCurrency.add(reuterCusSettng.Quote_Name__c); 
                }
                if(reuterCusSettng.Product_Differential__c)
                {
                    productDifferentialQuoteNames.add(reuterCusSettng.Quote_Name__c.trim());
                }
            }  
        
        if(isFreightRateUpdate||isLiveExchangeRateUpdated){
    
           helperObj.checkandUpdateGeltQuotes(isLiveExchangeRateUpdated, rqFreightMap,geltQuotesNameWithOtherCurrency);
            
        }
        helperObj.insertProductDifferentail((List<Reuters_Quotes__c>)Trigger.New,productDifferentialQuoteNames );
        
        helperObj.updateLocationSeers((List<Reuters_Quotes__c>)Trigger.New);	//Fix_403664_06Jan2020_Soumyajit
        
    }
    
    public static void stopcreatingDailyQuotes(List<Reuters_Quotes__c> reuterQuotesLst){
        
        List<Date> pricingdateLst = new List<Date>();
        List<String> priceDateIdLst = new List<String>();
        Map<String,Reuters_Quotes__c> quotenameIdMap = new Map<String,Reuters_Quotes__c>();
        for(Reuters_Quotes__c reuterQuotes : reuterQuotesLst){
            if(reuterQuotes.Frequency__c == 'daily'){
                pricingdateLst.add(reuterQuotes.Pricing_Date__c);
            	quotenameIdMap.put(reuterQuotes.Quote_Name__c, reuterQuotes);
                priceDateIdLst.add(reuterQuotes.Id);
            }
                
        }
        
        //System.debug('-----pricingdateLst-------'+pricingdateLst.size());
        //System.debug('-----quotenameIdMap-------'+quotenameIdMap.size());
        //PBI 1036994 - Swarna - Commented And condition
        List<Reuters_Quotes__c> fetchreuterQuotesLst = [SELECT Id,Frequency__c,Pricing_Date__c,Quote_Name__c,Price__c   from Reuters_Quotes__c 
                                                        where Frequency__c ='daily' /*AND 
                                                        (Pricing_Date__c in:pricingdateLst OR Pricing_Date__c >=:pricingdateLst)*/
                                                        AND Id NOT in:priceDateIdLst];
        //System.debug('-----fetchreuterQuotesLst-------'+fetchreuterQuotesLst.size());
        List<Reuters_Quotes__c> deleteliveQuoteLst = new List<Reuters_Quotes__c>();
        
        if(!fetchreuterQuotesLst.isEmpty()){
            for(Reuters_Quotes__c reuterQuote : fetchreuterQuotesLst){
                if(quotenameIdMap.containskey(reuterQuote.Quote_Name__c)){
                //PBI 1036994 - Swarna - added Pricing date comaprision consition
                    //System.debug('-------reuterQuote.Pricing_Date__c-----'+reuterQuote.Pricing_Date__c);
                    //System.debug('-------quotenameIdMap.get(reuterQuote.Quote_Name__c).Pricing_Date__c-----'+quotenameIdMap.get(reuterQuote.Quote_Name__c).Pricing_Date__c);
                    if( (reuterQuote.Pricing_Date__c == quotenameIdMap.get(reuterQuote.Quote_Name__c).Pricing_Date__c) &&
                        (reuterQuote.Quote_Name__c == quotenameIdMap.get(reuterQuote.Quote_Name__c).Quote_Name__c) &&
                        (reuterQuote.Price__c == quotenameIdMap.get(reuterQuote.Quote_Name__c).Price__c)){
                            deleteliveQuoteLst.add(quotenameIdMap.get(reuterQuote.Quote_Name__c));
                     }
                    else if((reuterQuote.Pricing_Date__c > quotenameIdMap.get(reuterQuote.Quote_Name__c).Pricing_Date__c) &&
                            (reuterQuote.Quote_Name__c == quotenameIdMap.get(reuterQuote.Quote_Name__c).Quote_Name__c) /*&&
                            (reuterQuote.Price__c == quotenameIdMap.get(reuterQuote.Quote_Name__c).Price__c)*/){
                                 
                        deleteliveQuoteLst.add(quotenameIdMap.get(reuterQuote.Quote_Name__c));
                    }
                }
            }
        }
        
        //System.debug('-----deleteliveQuoteLst-------'+deleteliveQuoteLst.size());
        List<String> reuterQuotesIdLst = new List<String>();
        for(Reuters_Quotes__c reuterDelete : deleteliveQuoteLst){
            reuterQuotesIdLst.add(reuterDelete.Id);
        }
        
        //System.debug('-----reuterQuotesIdLst-------'+reuterQuotesIdLst);
        
        if(!deleteliveQuoteLst.isEmpty()){
            delete [Select Id from Reuters_Quotes__c where Id in:reuterQuotesIdLst];
        }
        
        
    }
    
    public void insertProductDifferentail(List<Reuters_Quotes__c> newReuterQuotes,Set<String> filterQuoteNames)
    {
        String dashboardRecId = Schema.SObjectType.Product_Differential__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
        //System.debug('newReuterQuotes '+newReuterQuotes);
        //System.debug('filterQuoteNames '+filterQuoteNames);
        Map<String,Reuters_Quotes__c> mapOfQuoteNameAndReuter=new Map<String,Reuters_Quotes__c>();
         Map<String,Reuters_Quotes__c> mapOfFilteredQuoteNameAndReuter=new Map<String,Reuters_Quotes__c>();
        List<Product_Differential__c> productList;
        List<Product_Differential__c> upsertProductList=new List<Product_Differential__c>();
        Map<String,Product_Differential__c> mapOfExsistingProduct=new Map<String,Product_Differential__c>();

        Date todaysDate=System.today();
        for(Reuters_Quotes__c quote:newReuterQuotes)
        {
            if(quote.Valid_From_Date__c!=null&&quote.Valid_To_Date__c!=null
               &&todaysDate>=quote.Valid_From_Date__c&&todaysDate<=quote.Valid_To_Date__c)
            {
                mapOfQuoteNameAndReuter.put(quote.Quote_Name__c,quote); 
            }
                else  if(quote.Valid_From_Date__c==null&&quote.Valid_To_Date__c==null)
            {
                mapOfQuoteNameAndReuter.put(quote.Quote_Name__c,quote); 
            }
        }
        
        for(String quoteName:   mapOfQuoteNameAndReuter.keySet())
        {
            
            //System.debug('quoteName trigger New '+quoteName+' filterQuoteNames '+filterQuoteNames);
            if(filterQuoteNames.contains(quoteName.trim()))
            {
              mapOfFilteredQuoteNameAndReuter.put(quoteName,mapOfQuoteNameAndReuter.get(quoteName));  
            }
        }
        //System.debug('map Of Filtered '+mapOfFilteredQuoteNameAndReuter);
        
        if(mapOfFilteredQuoteNameAndReuter.isEmpty()==false)
        {
            
            productList=[Select Id,Name,Price__c from Product_Differential__c where Name in :mapOfFilteredQuoteNameAndReuter.keySet() and 
                         RecordTypeId= : dashboardRecId ];
            if(productList!=null&&productList.isEmpty()==false)
            {
                for(Product_Differential__c diff: productList)
                {
                    mapOfExsistingProduct.put(diff.Name,diff);
                }
            }
            
       
            for(String quoteName:mapOfFilteredQuoteNameAndReuter.keySet())
            {
                Reuters_Quotes__c reuter=mapOfFilteredQuoteNameAndReuter.get(quoteName);
                if(mapOfExsistingProduct.containsKey(quoteName))
                {
                    Product_Differential__c exsistProduct=mapOfExsistingProduct.get(quoteName);
                    exsistProduct.Price__c=reuter.Price__c;
                       exsistProduct.Column__c=reuter.Column__c;
                    exsistProduct.Display_Name__c=reuter.ProdDiff_Display_Name__c;
                    exsistProduct.Frequency__c=reuter.Frequency__c;
                     exsistProduct.RecordTypeId=dashboardRecId;
                    
                    upsertProductList.add(exsistProduct);
                    
                }
                else
                {
                    Product_Differential__c newProduct=new Product_Differential__c();
                    newProduct.Name=reuter.Quote_Name__c;
                    newProduct.Price__c=reuter.Price__c;
                   newProduct.Column__c=reuter.Column__c;
                    newProduct.Display_Name__c=reuter.ProdDiff_Display_Name__c;
                    newProduct.Frequency__c=reuter.Frequency__c;
                        
                     newProduct.RecordTypeId=dashboardRecId;
                    upsertProductList.add(newProduct);
                }
            }
            if(upsertProductList!=null&&upsertProductList.isEmpty()==false)
            {
                //ExceptionHandle_06Jan2020_Soumyajit starts
                //upsert   upsertProductList;  
               List<RV_Exception__c> excpList = new List<RV_Exception__c>();
               Database.SaveResult[] updateResult = Database.update(upsertProductList, false);
               for (Database.SaveResult r : updateResult)
               {
                   if (!r.isSuccess())
                   {
                       for (Database.Error err : r.getErrors())
                       {
                           System.debug(err.getMessage());
                           RV_Exception__c rvExcep = new RV_Exception__c();
                           rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                           rvExcep.getMessage__c = err.getMessage();
                           rvExcep.Apex_Class__c = 'RV_ReutersCalculationHelper';
                           rvExcep.Method_Name__c = 'insertProductDifferentail';
                           rvExcep.Type__c = 'Exception';
                           excpList.add(rvExcep); 
                       }
                   }
               }
               if(excpList.size()>0)
                   RV_ClassException.insertExceptionRecord(excpList);
                //ExceptionHandle_06Jan2020_Soumyajit ends
            }
            //System.debug('upsertProductList '+upsertProductList);
            
        }
        else
        {
            
        }
    }
    
    //Fix_403664_06Jan2020_Soumyajit starts
    public void updateLocationSeers(List<Reuters_Quotes__c> reutQuotes)
    {
        Set<String> plattSet = new Set<String>();
        
        for(Reuters_Quotes__c r :reutQuotes)
        {
            if(r.Quote_Display_Name__c !=null)
            {
                String key = r.Quote_Display_Name__c;
                if(key.containsIgnoreCase('Platts') && !plattSet.contains(key))
                    plattSet.add(key);
            }
        }
        
        if(plattSet.size()>0)
        {
            //System.debug('%%%plattSet%%% '+ plattSet);
            Map<String,Location_Steer_Metadata__mdt> mapOfSteerMetadata = new Map<String,Location_Steer_Metadata__mdt>();
            mapOfSteerMetadata = mapOfLocationSteerMetadata(plattSet);
            
            if(mapOfSteerMetadata.size()>0)
            {
                //System.debug('%%%%%%mapOfSteerMetadata%%%%%'+mapOfSteerMetadata);
                List<Location_Steer__c> fetchLocationSteerLst = [select id,Scenario_Value__c,productPlantScenarioKey__c
                                                                 from Location_Steer__c where productPlantScenarioKey__c in:mapOfSteerMetadata.keyset() ];
                //System.debug('%%%%%%fetchLocationSteerLst%%%%%'+fetchLocationSteerLst);
                
                if(fetchLocationSteerLst.size()>0)
                {
                   List<RV_Exception__c> excpList = new List<RV_Exception__c>();
                   Database.SaveResult[] updateResult = Database.update(fetchLocationSteerLst, false);
                   for (Database.SaveResult r : updateResult)
                   {
                       if (!r.isSuccess())
                       {
                           for (Database.Error err : r.getErrors())
                           {
                               System.debug(err.getMessage());
                               RV_Exception__c rvExcep = new RV_Exception__c();
                               rvExcep.Status_Code__c = String.valueof(err.getStatusCode());
                               rvExcep.getMessage__c = err.getMessage();
                               rvExcep.Apex_Class__c = 'RV_ReutersCalculationHelper';
                               rvExcep.Method_Name__c = 'updateLocationSeers';
                               rvExcep.Type__c = 'Exception';
                               excpList.add(rvExcep); 
                           }
                       }
                   }
                   if(excpList.size()>0)
                       RV_ClassException.insertExceptionRecord(excpList);
                }
            }
        }
    }
    
    public Map<String,Location_Steer_Metadata__mdt> mapOfLocationSteerMetadata(Set<String> plattSet){
        
        List<Location_Steer_Metadata__mdt> locationSteerLst1 = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt 
                                                              where Differential_Value_1__c in :plattSet
                                                              ];
        List<Location_Steer_Metadata__mdt> locationSteerLst2 = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt 
                                                              where Differential_Value_2__c in :plattSet
                                                              ];

        Map<String,Location_Steer_Metadata__mdt> locationSteerMap = new Map<String,Location_Steer_Metadata__mdt>();
        
        if(!locationSteerLst1.isEmpty()){
            for(Location_Steer_Metadata__mdt locationSteerMeta : locationSteerLst1){
                	locationSteerMap.put(locationSteerMeta.Product_Sub_Group__c + '-' + locationSteerMeta.Source__c + '-' + locationSteerMeta.Scenario__c , locationSteerMeta);
            }
        }
        if(!locationSteerLst2.isEmpty()){
            for(Location_Steer_Metadata__mdt locationSteerMeta : locationSteerLst2){
                	locationSteerMap.put(locationSteerMeta.Product_Sub_Group__c + '-' + locationSteerMeta.Source__c + '-' + locationSteerMeta.Scenario__c , locationSteerMeta);
            }
        }
        return locationSteerMap;
    }
    //Fix_403664_06Jan2020_Soumyajit ends
    
}