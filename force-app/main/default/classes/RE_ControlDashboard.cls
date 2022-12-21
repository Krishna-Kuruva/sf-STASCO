public class RE_ControlDashboard {
    
    public class QuoteWrapper {
        @AuraEnabled
        public Map<String,String> malaysia { get; set; }
        @AuraEnabled
        public Map<String,String> philippines { get; set; }
        @AuraEnabled
        public Map<String,String> singapore  { get; set; }
    }
    
    public class BatchWrapper {
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public Boolean IsSuccess { get; set; }
        @AuraEnabled
        public String CountryName  { get; set; }
        @AuraEnabled
        public String CreatedDate  { get; set; }
    }
    
    static final String global_returnDateFormat = 'dd.MM.yyyy HH:mm:ss';
    
    @AuraEnabled
    public static  Map<String, string> getJobsMetaData(){
        Map<String, string> countryLabelMap = new  Map<String, string>();
        Map<String, RE_BatchJobNameMapping__mdt> countryMap = RE_BatchJobNameMapping__mdt.getAll();
        for(String country: RE_BatchJobNameMapping__mdt.getAll().keySet()){
            countryLabelMap.put(countryMap.get(country).Label,countryMap.get(country).Country_Name__c);
        }
        return countryLabelMap;
    }     
    @AuraEnabled
    public static  Map<String,BatchWrapper> getAutomatedJobs(){
        Map<String,BatchWrapper> batchMap = new Map<String,BatchWrapper>();
         List<String> countryLabelList = new  List<String>();
        Map<String, RE_BatchJobNameMapping__mdt> countryMap = RE_BatchJobNameMapping__mdt.getAll();
        for(String country: RE_BatchJobNameMapping__mdt.getAll().keySet()){
            countryLabelList.add(countryMap.get(country).Label);
        }
        try{       
            for(RE_Job_Run_Audit__c audit : [Select id,Name,RE_IsSuccess__c,RE_Exception__c,RE_Country_Name__c,RE_Run_Time__c,RE_Job_Type__c,CreatedDate from RE_Job_Run_Audit__c where RE_Job_Type__c IN:countryLabelList order by CreatedDate desc Limit 500]){ 
                if(!batchMap.containsKey(audit.RE_Job_Type__c)){
                    BatchWrapper wrapper = new BatchWrapper();
                    wrapper.Name = audit.RE_Job_Type__c;
                    wrapper.CountryName = audit.RE_Country_Name__c;
                    wrapper.IsSuccess = audit.RE_IsSuccess__c;
                    wrapper.CreatedDate = audit.CreatedDate.format(global_returnDateFormat);
                    batchMap.put(audit.RE_Job_Type__c,wrapper);
                }
            }
        }catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GET QUOTE',ex.getMessage()+ex.getLineNumber(),'RE_ControlDashboard','getAutomatedJobs','Exception');
        }
        
        return batchMap;
    }
    
    
    
    
    @AuraEnabled
    public static String getData(){
        QuoteWrapper wrapper = new QuoteWrapper();
        try{
            List<RE_Market_Quotes__c> marketQuote = [Select RE_Quote_Type__c,RE_Quote_Name__c,CreatedDate from RE_Market_Quotes__c where RE_Quote_Type__c IN ('Settlement','Market Premium','Assessed Premium','Forward Swap','Freight','Midday') and CreatedDate = LAST_N_DAYS:9 and RE_Is_MTDWTD__c = false and RE_Country_Name__c INCLUDES ('SG','PH','TH','MY') order by CreatedDate desc];// where DAY_ONLY(CreatedDate) =:System.Today()];
            List<RE_FX_Rates__c> fxRatesList = [Select RE_Conversion_Unit__c,CreatedDate from RE_FX_Rates__c where RE_Conversion_Unit__c IN('SGD','PHP','MYR') and RE_Is_MTDWTD__c = false and CreatedDate = LAST_N_DAYS:9 order by CreatedDate desc];// where DAY_ONLY(CreatedDate) =:System.Today()];
            
            wrapper.malaysia = getMalaysia(marketQuote,fxRatesList);
            wrapper.philippines = getPhilippines(marketQuote,fxRatesList);
            wrapper.singapore = getSingapore(marketQuote,fxRatesList);
        } catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GET QUOTE',ex.getMessage()+ex.getLineNumber(),'RE_ControlDashboard','getData','Exception');
        }
        return JSON.serialize(wrapper);
    }
    
    public static Map<String,String> getMalaysiaMap(){
        Map<String,String> malaysiaMap = new  Map<String,String>();
        malaysiaMap.put('Settlement Price Quotes','-');
        malaysiaMap.put('Market Premium','-');
        malaysiaMap.put('Assessed Premium','-');
        malaysiaMap.put('Midday Price Quotes','-');
        malaysiaMap.put('Forex Rates','-');
        return malaysiaMap;
    }
    
    
    public static Map<String,String> getPhilippinesMap(){
        Map<String,String> malaysiaMap = new  Map<String,String>();
        malaysiaMap.put('Settlement Price Quotes','-');
        malaysiaMap.put('Market Premium','-');
        malaysiaMap.put('Assessed Premium','-');
        malaysiaMap.put('Freight Quotes','-');
        malaysiaMap.put('Forex Rates','-');
        malaysiaMap.put('CME Discount','-');
        malaysiaMap.put('Ethanol','-');
        malaysiaMap.put('UCAP RBD CNO','-');
        return malaysiaMap;
    }
    
    public static Map<String,String> getSingaporeMap(){
        Map<String,String> malaysiaMap = new  Map<String,String>();
        malaysiaMap.put('Settlement Price Quotes','-');
        malaysiaMap.put('Market Premium','-');
        malaysiaMap.put('Assessed Premium','-');
        malaysiaMap.put('Midday Price Quotes','-');
        malaysiaMap.put('Forex Rates','-');
        return malaysiaMap;
    }
    
    @AuraEnabled
    public static  Map<String,String> getSingapore(List<RE_Market_Quotes__c> marketQuote,List<RE_FX_Rates__c> fxRatesList){
        List<String> settelmentList = new List<String>{'CME Discount', 'Ethanol', 'UCAP RBD CNO'}; 
        List<String> marketPremiumList = new List<String>{'Kero Premium', 'Gasoil 0.001% Premium'}; 
        List<String> assessedPremiumList = new List<String>{'MID RON PREMIUM', 'MR Floating Premium', 'HIGH RON PREMIUM', 'FuelSave98 Premium'}; 
                    
        Map<String,String> singaporeMap = getSingaporeMap();
        try{
            for(RE_Market_Quotes__c item : marketQuote){
                string dateLatest = item.CreatedDate.format(global_returnDateFormat);
                if(!settelmentList.contains(item.RE_Quote_Name__c) && item.RE_Quote_Type__c == 'Settlement'){
                    if(singaporeMap.get('Settlement Price Quotes') == '-'){
                        singaporeMap.put('Settlement Price Quotes',dateLatest);
                    }
                }
                if(marketPremiumList.contains(item.RE_Quote_Name__c) && item.RE_Quote_Type__c == 'Market Premium'){
                    if(singaporeMap.get('Market Premium') == '-'){
                        singaporeMap.put('Market Premium',dateLatest);
                    }
                }
                if(assessedPremiumList.contains(item.RE_Quote_Name__c)  && item.RE_Quote_Type__c == 'Assessed Premium'){
                    if(singaporeMap.get('Assessed Premium') == '-'){
                        singaporeMap.put('Assessed Premium',dateLatest);
                    }
                }
                if(item.RE_Quote_Type__c == 'Midday'){
                    if(singaporeMap.get('Midday Price Quotes') == '-'){
                        singaporeMap.put('Midday Price Quotes',dateLatest);
                    }
                }
            }
            for(RE_FX_Rates__c item : fxRatesList){
                if(item.RE_Conversion_Unit__c == 'SGD'){
                    if(singaporeMap.get('Forex Rates') == '-'){
                        singaporeMap.put('Forex Rates',item.CreatedDate.format(global_returnDateFormat));
                    }
                }
            }
        } catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GET QUOTE',ex.getMessage()+ex.getLineNumber(),'RE_ControlDashboard','getSingapore','Exception');
        }
        
        return singaporeMap;
        
    } 
    
    @AuraEnabled
    public static Map<String,String> getPhilippines(List<RE_Market_Quotes__c> marketQuote,List<RE_FX_Rates__c> fxRatesList){
        
        List<String> settelmentList = new List<String>{'CME Discount', 'Ethanol', 'UCAP RBD CNO'}; 
            List<String> marketPremiumList = new List<String>{'MKT PREMIA MPI08', 'MKT PREMIA MPI09', 'QTY PREMIA S2P01', 'QTY PREMIA S2P02'}; 
                
                Map<String,String> malaysiaMap = getPhilippinesMap();
        try{
            for(RE_Market_Quotes__c item : marketQuote){
                string dateLatest = item.CreatedDate.format(global_returnDateFormat);
                if(!settelmentList.contains(item.RE_Quote_Name__c) && item.RE_Quote_Type__c == 'Settlement'){
                    if(malaysiaMap.get('Settlement Price Quotes') == '-'){
                        malaysiaMap.put('Settlement Price Quotes',dateLatest);
                    }
                }
                if(marketPremiumList.contains(item.RE_Quote_Name__c) && item.RE_Quote_Type__c == 'Market Premium'){
                    if(malaysiaMap.get('Market Premium') == '-'){
                        malaysiaMap.put('Market Premium',dateLatest);
                    }
                }
                if(item.RE_Quote_Name__c == 'FuelSave98 Premium'  && item.RE_Quote_Type__c == 'Assessed Premium'){
                    if(malaysiaMap.get('Assessed Premium') == '-'){
                        malaysiaMap.put('Assessed Premium',dateLatest);
                    }
                }
                if(item.RE_Quote_Type__c == 'Freight'){
                    if(malaysiaMap.get('Freight Quotes') == '-'){
                        malaysiaMap.put('Freight Quotes',dateLatest);
                    }
                }
                
                if(item.RE_Quote_Name__c == 'CME Discount'){
                    if(malaysiaMap.get('CME Discount') == '-'){
                        malaysiaMap.put('CME Discount',dateLatest);
                    }
                }
                if(item.RE_Quote_Name__c == 'Ethanol'){
                    if(malaysiaMap.get('Ethanol') == '-'){
                        malaysiaMap.put('Ethanol',dateLatest);
                    }
                }
                if(item.RE_Quote_Name__c == 'UCAP RBD CNO'){
                    if(malaysiaMap.get('UCAP RBD CNO') == '-'){
                        malaysiaMap.put('UCAP RBD CNO',dateLatest);
                    }
                }
            }
            for(RE_FX_Rates__c item : fxRatesList){
                if(item.RE_Conversion_Unit__c == 'PHP'){
                    if(malaysiaMap.get('Forex Rates') == '-'){
                        malaysiaMap.put('Forex Rates',item.CreatedDate.format(global_returnDateFormat));
                    }
                }
            }
        }catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GET QUOTE',ex.getMessage()+ex.getLineNumber(),'RE_ControlDashboard','getPhilippines','Exception');
        }
        
        return malaysiaMap;
    }
    
    @AuraEnabled
    public static Map<String,String> getMalaysia(List<RE_Market_Quotes__c> marketQuote,List<RE_FX_Rates__c> fxRatesList){
        
        List<String> settelmentList = new List<String>{'CME Discount', 'Ethanol', 'UCAP RBD CNO'}; 
            List<String> marketPremiumList = new List<String>{'Kero Premium', 'Gasoil 0.001% Premium'}; 
                List<String> assessedPremiumList = new List<String>{'Breakbulk Premium', 'Breakbulk Premium - GBI02'}; 
                    
                    Map<String,String> malaysiaMap = getMalaysiaMap();
        try{
            for(RE_Market_Quotes__c item : marketQuote){
                string dateLatest = item.CreatedDate.format(global_returnDateFormat);
                if(!settelmentList.contains(item.RE_Quote_Name__c) && item.RE_Quote_Type__c == 'Settlement'){
                    if(malaysiaMap.get('Settlement Price Quotes') == '-'){
                        malaysiaMap.put('Settlement Price Quotes',dateLatest);
                    }
                }
                if(marketPremiumList.contains(item.RE_Quote_Name__c) && item.RE_Quote_Type__c == 'Market Premium'){
                    if(malaysiaMap.get('Market Premium') == '-'){
                        malaysiaMap.put('Market Premium',dateLatest);
                    }
                }
                if(assessedPremiumList.contains(item.RE_Quote_Name__c) && item.RE_Quote_Type__c == 'Assessed Premium'){
                    if(malaysiaMap.get('Assessed Premium') == '-'){
                        malaysiaMap.put('Assessed Premium',dateLatest);
                    }
                }
                if(item.RE_Quote_Type__c == 'Forward Swap'){
                    if(malaysiaMap.get('Midday Price Quotes') == '-'){
                        malaysiaMap.put('Midday Price Quotes',dateLatest);
                    }
                }
            }
            
            for(RE_FX_Rates__c item : fxRatesList){
                if(item.RE_Conversion_Unit__c == 'MYR'){
                    if(malaysiaMap.get('Forex Rates') == '-'){
                        malaysiaMap.put('Forex Rates',item.CreatedDate.format(global_returnDateFormat));
                    }
                }
            }
        }catch(Exception ex){
            System.debug('ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GET QUOTE',ex.getMessage()+ex.getLineNumber(),'RE_ControlDashboard','getMalaysia','Exception');
        }
        return malaysiaMap;
    }
}