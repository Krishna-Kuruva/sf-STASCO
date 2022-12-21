//This class fetches data from various tables to display on thailand Output UI  
global class RE_ThailandOutputController {
    Public Static Integer maxRunCount;
    @AuraEnabled
    public Static Integer maxRunCountMethod(){
        //fetching RE_Job_Run_Count__c from RE_MY_Output__c
        List<RE_MY_Output__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_Output__c 
                                                  WHERE RE_Pricing_Date__c = Today AND RE_Type__c='Thailand Output' ORDER BY RE_Job_Run_Count__c  DESC LIMIT 1];
        if(!costDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
        return maxRunCount;
    }
    public RE_ThailandOutputController(ApexPages.StandardSetController controller){
        
    }
   @InvocableMethod(label='Thailand AMV Output' description='Thailand AMV Output Generation.')
    public Static void AMVjobExecute(){
        Integer maxJobRunCount = 0;
        List<RE_Job_Run_Audit__c> jobDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c 
                                                  WHERE createddate = Today AND RE_Job_Type__c =: 'Thailand AMV Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(!jobDataToday.isEmpty())
            maxJobRunCount = Integer.valueOf(jobDataToday[0].RE_Job_Run_Count__c)+1;
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit.RE_Run_Time__c = System.now();
        jrAudit.RE_Run_Type__c = 'Manual';
        jrAudit.RE_Job_Type__c = 'Thailand AMV Output';
        jrAudit.RE_User__c = UserInfo.getUserId();
        jrAudit.RE_Job_Run_Count__c = maxJobRunCount;
        System.Debug('maxJobRunCount--'+maxJobRunCount);
        try{
            insert jrAudit;
        }
        catch(Exception ex){
            
        }
    }
    @AuraEnabled
    public Static void jobExecute(String country){
        Integer maxJobRunCount = 0;
        List<RE_Job_Run_Audit__c> jobDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c 
                                                  WHERE createddate = Today AND RE_Job_Type__c =: country ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(!jobDataToday.isEmpty())
            maxJobRunCount = Integer.valueOf(jobDataToday[0].RE_Job_Run_Count__c)+1;
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit.RE_Run_Time__c = System.now();
        jrAudit.RE_Run_Type__c = 'Manual';
        jrAudit.RE_Job_Type__c = country;//'Thailand Output';
        jrAudit.RE_User__c = UserInfo.getUserId();
        jrAudit.RE_Job_Run_Count__c = maxJobRunCount;
        System.Debug('maxJobRunCount--'+maxJobRunCount);
        try{
            insert jrAudit;
        }
        catch(Exception ex){
            
        }
    }
    @AuraEnabled
    public Static Datetime lastJobRun(){
        return ([SELECT RE_Run_Time__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c = 'Thailand Output' ORDER BY RE_Run_Time__c DESC LIMIT 1].RE_Run_Time__c);
    }
    
    @AuraEnabled
    public Static Boolean getUserInfo(Id userId){
		Boolean validProfile = false;       
        for(PermissionSetAssignment currentUserPerSet : [ 
            SELECT Id, PermissionSet.Name,AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId]){
                if(currentUserPerSet.PermissionSet.Name == 'RE_TH_Pricing_Desk'){  //needs change
                    validProfile = true;  
                    break;
                }
            }
        return validProfile;
    }
    
    @AuraEnabled
    public Static List<MOPSDataWrapper> getMOPSData(){
        Map<String, RE_Market_Quotes__c> latestmarketquoteList = new Map<String, RE_Market_Quotes__c>();
        Map<String, RE_Market_Quotes__c> oldmarketquoteList = new Map<String, RE_Market_Quotes__c>();
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D','D-1')
            AND RE_Quote_Type__c IN ('Settlement')
            AND RE_Quote_Name__c NOT IN ('MOGAS 97','Gasoil 0.005% S','Gasoil 0.5% S','Gasoil 0.25% S','HDGO','GTL')
            ORDER BY RE_Quote_Type__c ASC
        ]){
            if(marketquoteData.RE_Tracker__c =='D'){ 
                latestmarketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
            }
            else{
                if(marketquoteData.RE_Tracker__c == 'D-1')
                    oldmarketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
            }
        }  
        RE_unitConversion unitconv = new RE_unitConversion();
        RE_SOQLController soqldata = new RE_SOQLController();
    	Map<String,Double> curConvMap = soqldata.fetchLatestFxData();
        
        List<MOPSDataWrapper> mopsdatalist = new List<MOPSDataWrapper>();
        for(RE_Market_Quotes__c todaymops : latestmarketquoteList.values()){
        	MOPSDataWrapper mopdata = new MOPSDataWrapper();
            mopdata.item = todaymops.RE_Quote_Name__c;
            mopdata.dailyval = todaymops.RE_Price__c;
            mopdata.Priceunit  =    todaymops.RE_Rate_Unit__c;     
			//mopdata.lastdayval = 0;                
            mopdata.lastdayval   = oldmarketquoteList.containsKey(todaymops.RE_Quote_Name__c) ? oldmarketquoteList.get(todaymops.RE_Quote_Name__c).RE_Price__c : 0;
            mopdata.diffdayval	=	mopdata.dailyval - mopdata.lastdayval;
            mopsdatalist.add(mopdata);
        }
        return mopsdatalist;
    }
    
    @AuraEnabled
    public static List<FxDataWrapper> getFxData(){
        List<FxDataWrapper> fxdatawraplist = new List<FxDataWrapper>();
        List<RE_FX_Rates__c> fxListdatatoday = [
            SELECT RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c,RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c 
            WHERE  RE_Tracker__c  = 'D+1' AND RE_Conversion_Unit__c IN('THB') AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell'];
        List<RE_FX_Rates__c> fxListdatayesterday = new List<RE_FX_Rates__c>();/*[
            SELECT RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c FROM RE_FX_Rates__c 
            WHERE  RE_Tracker__c  = 'D-1' AND RE_Conversion_Unit__c = 'MYR' AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell'];          
        */
        
        for(RE_FX_Rates__c fx : fxListdatatoday){
            FxDataWrapper fxWrapper = new FxDataWrapper();
            fxWrapper.item = 'FX Rate ('+fx.RE_Conversion_Unit__c+'/'+fx.RE_Base_Unit__c+')';
            fxWrapper.dailyval	=	fx.RE_Forex_Rate__c;
            fxdatawraplist.add(fxWrapper);
        }
        /*
        fxWrapper.item = 'FX Rate';
        if(fxListdatatoday.size()>0 && fxListdatatoday[0] != null)
        {
            fxWrapper.dailyval = fxListdatatoday[0].RE_Forex_Rate__c;/*
            if(fxListdatayesterday.size()>0 && fxListdatayesterday[0]!=null)            
                fxWrapper.lastdayval = fxListdatayesterday[0].RE_Forex_Rate__c;        		            
            else            
                fxWrapper.lastdayval = 0;
        }
        else
        {
            fxWrapper.dailyval = 0;
            fxWrapper.lastdayval = 0;
            
        }
        fxdatawraplist.add(fxWrapper);*/
        return fxdatawraplist;
    }


    public Static List<RE_MY_Output__c> laiddownCostData(String region, Integer jobruncount){
        String type = 'Thailand Output';
        String query = 'SELECT RE_Depot_Name__c,RE_Kerosene_LDC_Diff__c,RE_Kerosene_LDC__c,RE_TH_AWD_DIFF__c,RE_TH_AWD_LDC__c,RE_TH_Com_B0_DIFF__c,RE_TH_Com_B0_LDC__c,RE_TH_Com_B7_DIFF__c,RE_TH_Com_B7_LDC__c,RE_TH_Com_B10_DIFF__c,RE_TH_Com_B10_LDC__c,RE_TH_Com_B20_DIFF__c,RE_TH_Com_B20_LDC__c,RE_TH_FOA_DIFF__c,RE_TH_FOA_LDC__c,RE_TH_FOA_X_DIFF__c,RE_TH_FOA_X_LDC__c,RE_TH_FOC_DIFF__c,RE_TH_FOC_LDC__c,RE_TH_FOC_X_DIFF__c,RE_TH_FOC_X_LDC__c,RE_TH_FSD_B7_DIFF__c,RE_TH_FSD_B7_LDC__c,RE_TH_FSD_B10_DIFF__c,RE_TH_FSD_B10_LDC__c,RE_TH_G91_E10_DIFF__c,RE_TH_G91_E10_LDC__c,RE_TH_G95_E10_DIFF__c,RE_TH_G95_E10_LDC__c,RE_TH_G95_E20_LDC__c,RE_TH_LPP_DIFF__c,RE_TH_LPP_LDC__c,RE_TH_PSFD_DIFF__c,RE_TH_PSFD_LDC__c,RE_TH_U91_E0_DIFF__c,RE_TH_U91_E0_LDC__c,RE_TH_U95_E0_DIFF__c,RE_TH_U95_E0_LDC__c,RE_TH_ULSD_DIFF__c,RE_TH_ULSD_LDC__c,RE_TH_VPD_B7_DIFF__c,RE_TH_VPD_B7_LDC__c,RE_TH_VPG_E10_DIFF__c,RE_TH_VPG_E10_LDC__c,RE_Type__c,RE_TH_G95_E20_DIFF__c,RE_TH_LSFO_80_DIFF__c,RE_TH_LSFO_80_LDC__c,RE_TH_LSFO_380_DIFF__c,RE_TH_LSFO_380_LDC__c,RE_TH_MGO_0_1_DIFF__c,RE_TH_MGO_0_1_LDC__c,RE_TH_VPD_B10_DIFF__c,RE_TH_VPD_B10_LDC__c  FROM RE_MY_Output__c WHERE RE_Pricing_Date__c = Today AND RE_Region__c =: region AND RE_Job_Run_Count__c =: jobruncount AND RE_Type__c =:type ORDER BY RE_Depot_Name__c ASC';
        //String query = 'SELECT Id,RE_Depot_Name__c,RE_Kerosene_LDC_Diff__c,RE_Kerosene_LDC__c,RE_TH_AWD_DIFF__c,RE_TH_AWD_LDC__c FROM RE_MY_Output__c';
        List<RE_MY_Output__c> sobjList = Database.query(query);
        System.debug('sobjList---'+sobjList);
        return sobjList;
    }

    @AuraEnabled
    public static List<costDataWrapper> getCostingDataThailand(){
        Integer jobruncount = maxRunCountMethod();
        List<costDataWrapper> costdataList = new List<costDataWrapper>();
        List<costDataWrapper> costdataUnsortedList = new List<costDataWrapper>();
        List<costDataWrapper> costdataSortedList = new List<costDataWrapper>();
        
        for(RE_MY_Output__c outputLDCdata : laiddownCostData('Thailand',jobruncount)){
            costdataList.add(getLDCCostData(outputLDCdata));
        }        
        costdataList.sort();
        //Arranging list to bring Chongnonsri data first in the list
        for(costDataWrapper costList : costdataList)
        {
            if(costList.location == 'Chongnonsri')
            costdataSortedList.add(costList);
            else
            costdataUnsortedList.add(costList);
        }
        costdataSortedList.addAll(costdataUnsortedList);
          
        System.debug('costdataSortList----'+costdataSortedList);
        return costdataSortedList;
    } 

    public static costDataWrapper getLDCCostData(RE_MY_Output__c outputLDCdata){
        costDataWrapper costdata = new costDataWrapper();
        costdata.location = outputLDCdata.RE_Depot_Name__c;
        if(outputLDCdata.RE_Kerosene_LDC__c != null ) costdata.kerocbu = outputLDCdata.RE_Kerosene_LDC__c;
        if(outputLDCdata.RE_Kerosene_LDC_Diff__c != null ) costdata.kerodiff = outputLDCdata.RE_Kerosene_LDC_Diff__c;
        if(outputLDCdata.RE_TH_AWD_LDC__c != null ) costdata.awdcbu = outputLDCdata.RE_TH_AWD_LDC__c;
		if(outputLDCdata.RE_TH_AWD_DIFF__c != null ) costdata.awddiff = outputLDCdata.RE_TH_AWD_DIFF__c;
        if(outputLDCdata.RE_TH_Com_B0_LDC__c != null ) costdata.comb0cbu = outputLDCdata.RE_TH_Com_B0_LDC__c;
		if(outputLDCdata.RE_TH_Com_B0_DIFF__c != null ) costdata.comb0diff = outputLDCdata.RE_TH_Com_B0_DIFF__c;		
        if(outputLDCdata.RE_TH_Com_B7_LDC__c != null ) costdata.comb7cbu = outputLDCdata.RE_TH_Com_B7_LDC__c;		
		if(outputLDCdata.RE_TH_Com_B7_DIFF__c != null ) costdata.comb7diff = outputLDCdata.RE_TH_Com_B7_DIFF__c;		
        if(outputLDCdata.RE_TH_Com_B10_LDC__c != null ) costdata.comb10cbu = outputLDCdata.RE_TH_Com_B10_LDC__c;		
		if(outputLDCdata.RE_TH_Com_B10_DIFF__c != null ) costdata.comb10diff = outputLDCdata.RE_TH_Com_B10_DIFF__c;		
        if(outputLDCdata.RE_TH_Com_B20_LDC__c != null ) costdata.comb20cbu = outputLDCdata.RE_TH_Com_B20_LDC__c;		
		if(outputLDCdata.RE_TH_Com_B20_DIFF__c != null ) costdata.comb20diff = outputLDCdata.RE_TH_Com_B20_DIFF__c;
        if(outputLDCdata.RE_TH_FOA_LDC__c != null ) costdata.foacbu = outputLDCdata.RE_TH_FOA_LDC__c;
		if(outputLDCdata.RE_TH_FOA_DIFF__c != null ) costdata.foadiff = outputLDCdata.RE_TH_FOA_DIFF__c;
        if(outputLDCdata.RE_TH_FOA_X_LDC__c != null ) costdata.foaxcbu = outputLDCdata.RE_TH_FOA_X_LDC__c;
        if(outputLDCdata.RE_TH_FOA_X_DIFF__c != null ) costdata.foaxdiff = outputLDCdata.RE_TH_FOA_X_DIFF__c;
        if(outputLDCdata.RE_TH_FOC_LDC__c != null ) costdata.foccbu = outputLDCdata.RE_TH_FOC_LDC__c;
        if(outputLDCdata.RE_TH_FOC_DIFF__c != null ) costdata.focdiff = outputLDCdata.RE_TH_FOC_DIFF__c;
        if(outputLDCdata.RE_TH_FOC_X_LDC__c != null ) costdata.focXcbu = outputLDCdata.RE_TH_FOC_X_LDC__c;
        if(outputLDCdata.RE_TH_FOC_X_DIFF__c != null ) costdata.focXdiff = outputLDCdata.RE_TH_FOC_X_DIFF__c;
        if(outputLDCdata.RE_TH_FSD_B7_LDC__c != null ) costdata.fsdb7cbu = outputLDCdata.RE_TH_FSD_B7_LDC__c;
        if(outputLDCdata.RE_TH_FSD_B7_DIFF__c != null ) costdata.fsdb7diff = outputLDCdata.RE_TH_FSD_B7_DIFF__c;
        if(outputLDCdata.RE_TH_FSD_B10_LDC__c != null ) costdata.fsdb10cbu = outputLDCdata.RE_TH_FSD_B10_LDC__c;
        if(outputLDCdata.RE_TH_FSD_B10_DIFF__c != null ) costdata.fsdb10diff = outputLDCdata.RE_TH_FSD_B10_DIFF__c;
        if(outputLDCdata.RE_TH_G91_E10_LDC__c != null ) costdata.g91e10cbu = outputLDCdata.RE_TH_G91_E10_LDC__c;
        if(outputLDCdata.RE_TH_G91_E10_DIFF__c != null ) costdata.g91e10diff = outputLDCdata.RE_TH_G91_E10_DIFF__c;
        if(outputLDCdata.RE_TH_G95_E10_LDC__c != null ) costdata.g95e10cbu = outputLDCdata.RE_TH_G95_E10_LDC__c;
        if(outputLDCdata.RE_TH_G95_E10_DIFF__c != null ) costdata.g95e10diff = outputLDCdata.RE_TH_G95_E10_DIFF__c;
        if(outputLDCdata.RE_TH_G95_E20_LDC__c != null ) costdata.g95e20cbu = outputLDCdata.RE_TH_G95_E20_LDC__c;
        if(outputLDCdata.RE_TH_G95_E20_DIFF__c != null ) costdata.g95e20diff = outputLDCdata.RE_TH_G95_E20_DIFF__c;
        if(outputLDCdata.RE_TH_LPP_LDC__c != null ) costdata.lppcbu = outputLDCdata.RE_TH_LPP_LDC__c;
        if(outputLDCdata.RE_TH_LPP_DIFF__c != null ) costdata.lppdiff = outputLDCdata.RE_TH_LPP_DIFF__c;
        if(outputLDCdata.RE_TH_PSFD_LDC__c != null ) costdata.psfdcbu = outputLDCdata.RE_TH_PSFD_LDC__c;
        if(outputLDCdata.RE_TH_PSFD_DIFF__c != null ) costdata.psfddiff = outputLDCdata.RE_TH_PSFD_DIFF__c;
        if(outputLDCdata.RE_TH_U91_E0_LDC__c != null ) costdata.u91e0cbu = outputLDCdata.RE_TH_U91_E0_LDC__c;
        if(outputLDCdata.RE_TH_U91_E0_DIFF__c != null ) costdata.u91e0diff = outputLDCdata.RE_TH_U91_E0_DIFF__c;
        if(outputLDCdata.RE_TH_U95_E0_LDC__c != null ) costdata.u95e0cbu = outputLDCdata.RE_TH_U95_E0_LDC__c;
        if(outputLDCdata.RE_TH_U95_E0_DIFF__c != null ) costdata.u95e0diff = outputLDCdata.RE_TH_U95_E0_DIFF__c;
        if(outputLDCdata.RE_TH_ULSD_LDC__c != null ) costdata.ulsdcbu = outputLDCdata.RE_TH_ULSD_LDC__c;
        if(outputLDCdata.RE_TH_ULSD_DIFF__c != null ) costdata.ulsddiff = outputLDCdata.RE_TH_ULSD_DIFF__c;
        if(outputLDCdata.RE_TH_VPD_B7_LDC__c != null ) costdata.vpdb7cbu = outputLDCdata.RE_TH_VPD_B7_LDC__c;
        if(outputLDCdata.RE_TH_VPD_B7_DIFF__c != null ) costdata.vpdb7diff = outputLDCdata.RE_TH_VPD_B7_DIFF__c;
        if(outputLDCdata.RE_TH_VPG_E10_LDC__c != null ) costdata.vpge10cbu = outputLDCdata.RE_TH_VPG_E10_LDC__c;
        if(outputLDCdata.RE_TH_VPG_E10_DIFF__c != null ) costdata.vpge10diff = outputLDCdata.RE_TH_VPG_E10_DIFF__c;
        if(outputLDCdata.RE_TH_LSFO_80_DIFF__c != null ) costdata.lsfo8diff = outputLDCdata.RE_TH_LSFO_80_DIFF__c;
        if(outputLDCdata.RE_TH_LSFO_80_LDC__c != null ) costdata.lsfo8cbu = outputLDCdata.RE_TH_LSFO_80_LDC__c;
        if(outputLDCdata.RE_TH_LSFO_380_DIFF__c != null ) costdata.lsfo3diff = outputLDCdata.RE_TH_LSFO_380_DIFF__c;
        if(outputLDCdata.RE_TH_LSFO_380_LDC__c != null ) costdata.lsfo3cbu = outputLDCdata.RE_TH_LSFO_380_LDC__c;
        if(outputLDCdata.RE_TH_MGO_0_1_DIFF__c != null ) costdata.mgodiff = outputLDCdata.RE_TH_MGO_0_1_DIFF__c;
        if(outputLDCdata.RE_TH_MGO_0_1_LDC__c != null ) costdata.mgocbu = outputLDCdata.RE_TH_MGO_0_1_LDC__c;
	if(outputLDCdata.RE_TH_VPD_B10_LDC__c != null ) costdata.vpdb10cbu = outputLDCdata.RE_TH_VPD_B10_LDC__c;
        if(outputLDCdata.RE_TH_VPD_B10_DIFF__c != null ) costdata.vpdb10diff = outputLDCdata.RE_TH_VPD_B10_DIFF__c;
        //System.debug('costingdata-----'+costdata);
        return costdata;
    }
    
    public static List<bioQuoteDataWrapper> getBioQuotes(){
        RE_SOQLController soqldata = new RE_SOQLController();
        List<bioQuoteDataWrapper>bqwrapper = new List<bioQuoteDataWrapper>();
        for(RE_Bio_Quotes__c bq : soqldata.fetchThailandQuotesData('Thailand')){
            bioQuoteDataWrapper onjref = new bioQuoteDataWrapper();
            onjref.item = bq.RE_Bio_Quotes_Name__c;
            onjref.dailyval= bq.RE_Price__c;
            onjref.Priceunit=bq.RE_Bio_RateUnit__c;
            bqwrapper.add(onjref);
        }
        return bqwrapper;
    }
    @AuraEnabled
    public static InitialDetailsWrapper getInitParameterDetails(Id userId){	
		Map<String,List<costDataWrapper>> costingMaps = new Map<String,List<costDataWrapper>>();
		costingMaps.put('costingMaps',getCostingDataThailand());
		System.debug('userId---'+userId);
		InitialDetailsWrapper initialDetails = 	new InitialDetailsWrapper();
		initialDetails.validProfile 		 = 	getUserInfo(userId);
		initialDetails.lastJobRun			 =	(lastJobRun()).format('dd/MM/yyyy hh:mm a');
		initialDetails.mops					 =	getMOPSData();
		initialDetails.fxrates				 =	getFxData();
		initialDetails.costMaps			   	 =	costingMaps;
        initialDetails.bioQuotes			 =  getBioQuotes();
        initialDetails.jobruncount			 = maxRunCountMethod();
		System.debug('costingMapsLDC---'+initialDetails);
        
		return initialDetails;
		
    }
    
	public class InitialDetailsWrapper{
		@AuraEnabled 
        public Boolean 							 validProfile { get; set; }
		
		@AuraEnabled
		public String 							 lastJobRun   { get; set; }
		
		@AuraEnabled
		public List<MOPSDataWrapper> 			 mops 	  	  { get; set; }
		
		@AuraEnabled
		public List<FxDataWrapper> 	 			 fxrates  	  { get; set; }
		
		@AuraEnabled
		public Map<String,List<costDataWrapper>> costMaps 	  { get; set; }	
        
        @AuraEnabled
		public List<bioQuoteDataWrapper> 		 bioQuotes 	  { get; set; }
        
        @AuraEnabled
		public Integer 		 					jobruncount	  { get; set; }

	}
    
    global class costDataWrapper implements Comparable {
        @AuraEnabled
        public String location{get;set;}
        @AuraEnabled
        public Decimal kerocbu{get;set;}
        @AuraEnabled
        public Decimal kerodiff{get;set;}
        @AuraEnabled
        public Decimal foacbu{get;set;}
        @AuraEnabled
        public Decimal foadiff{get;set;}
        @AuraEnabled
        public Decimal foccbu{get;set;}
        @AuraEnabled
        public Decimal focdiff{get;set;}
        @AuraEnabled
        public Decimal focXcbu{get;set;}
        @AuraEnabled
        public Decimal focXdiff{get;set;}
        @AuraEnabled
        public Decimal psfdcbu{get;set;}
        @AuraEnabled
        public Decimal psfddiff{get;set;}
        @AuraEnabled
        public Decimal u95e0cbu{get;set;}
        @AuraEnabled
        public Decimal u95e0diff{get;set;}              
        @AuraEnabled
        public Decimal awdcbu{get;set;}
        @AuraEnabled
        public Decimal awddiff{get;set;}
        @AuraEnabled
        public Decimal comb7cbu{get;set;}
        @AuraEnabled
        public Decimal comb7diff{get;set;} 
        @AuraEnabled
        public Decimal comb0cbu{get;set;}
        @AuraEnabled
        public Decimal comb0diff{get;set;}
        @AuraEnabled
        public Decimal comb10cbu{get;set;}
        @AuraEnabled
        public Decimal comb10diff{get;set;}
        @AuraEnabled
        public Decimal comb20cbu{get;set;}
        @AuraEnabled
        public Decimal comb20diff{get;set;}
        @AuraEnabled
        public Decimal g95e20cbu{get;set;}
        @AuraEnabled
        public Decimal g95e20diff{get;set;}
        @AuraEnabled
        public Decimal foaxcbu{get;set;}
        @AuraEnabled
        public Decimal foaxdiff{get;set;}
        @AuraEnabled
        public Decimal fsdb7cbu{get;set;}
        @AuraEnabled
        public Decimal fsdb7diff{get;set;}
        @AuraEnabled
        public Decimal fsdb10cbu{get;set;}
        @AuraEnabled
        public Decimal fsdb10diff{get;set;}
        @AuraEnabled
        public Decimal g91e10cbu{get;set;}
        @AuraEnabled
        public Decimal g91e10diff{get;set;}
        @AuraEnabled
        public Decimal g95e10cbu{get;set;}
        @AuraEnabled
        public Decimal g95e10diff{get;set;}
        @AuraEnabled
        public Decimal u91e0cbu{get;set;}
        @AuraEnabled
        public Decimal u91e0diff{get;set;}
        @AuraEnabled
        public Decimal vpge10cbu{get;set;}
        @AuraEnabled
        public Decimal vpge10diff{get;set;}
        @AuraEnabled
        public Decimal vpdb7cbu{get;set;}
        @AuraEnabled
        public Decimal vpdb7diff{get;set;}
        @AuraEnabled
        public Decimal lppcbu{get;set;}
        @AuraEnabled
        public Decimal lppdiff{get;set;}
        @AuraEnabled
        public Decimal ulsdcbu{get;set;}
        @AuraEnabled
        public Decimal ulsddiff{get;set;}
        @AuraEnabled
        public Decimal lsfo8diff{get;set;}
        @AuraEnabled
        public Decimal lsfo8cbu{get;set;}
        @AuraEnabled
        public Decimal lsfo3diff{get;set;}
        @AuraEnabled
        public Decimal lsfo3cbu{get;set;}
        @AuraEnabled
        public Decimal mgodiff{get;set;}
        @AuraEnabled
        public Decimal mgocbu{get;set;}
        @AuraEnabled
        public Decimal vpdb10cbu{get;set;}
        @AuraEnabled
        public Decimal vpdb10diff{get;set;}
        
        global Integer compareTo(Object ObjToCompare) {
            return location.CompareTo(((costDataWrapper)ObjToCompare).location);
        }
    }
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class MOPSDataWrapper{
        @AuraEnabled
        public String item{get;set;}
        @AuraEnabled
        public String REQuoteName{get;set;}
        @AuraEnabled
        public Double dailyval{get;set;}
        @AuraEnabled
        public Double lastdayval{get;set;}
        @AuraEnabled
        public Double diffdayval{get;set;}
        @AuraEnabled
        public Double Price{get;set;}
        @AuraEnabled
        public String Priceunit{get;set;}
    }
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class FxDataWrapper{
        @AuraEnabled
        public String item{get;set;}
        @AuraEnabled
        public Double dailyval{get;set;}
        @AuraEnabled
        public Double lastdayval{get;set;}
        
    }
    
    public class bioQuoteDataWrapper{
        @AuraEnabled
        public String item{get;set;}
        @AuraEnabled
        public Double dailyval{get;set;}
        @AuraEnabled
        public String Priceunit{get;set;}
    }

}