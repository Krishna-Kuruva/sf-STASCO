global class RE_MalayasiaOutputController{    
    Public Static Integer maxRunCount;
    public Static Integer maxRunCountMethod(){
        List<RE_MY_Output__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_MY_Output__c 
                                                  WHERE RE_Pricing_Date__c = Today AND RE_Type__c='Malaysia Output' ORDER BY RE_Job_Run_Count__c  DESC LIMIT 1];
        if(!costDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
        return maxRunCount;
    }
    public RE_MalayasiaOutputController(ApexPages.StandardSetController controller){
         
    }
   	@InvocableMethod(label='Malaysia AMV Output' description='Malaysia AMV Output Generation.')
    public Static void AMVjobExecute(){
        Integer maxJobRunCount = 0;
        List<RE_Job_Run_Audit__c> jobDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c 
                                                  WHERE createddate = Today AND RE_Job_Type__c =: 'Malaysia AMV Output' ORDER BY RE_Job_Run_Count__c DESC LIMIT 1];
        if(!jobDataToday.isEmpty())
            maxJobRunCount = Integer.valueOf(jobDataToday[0].RE_Job_Run_Count__c)+1;
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit.RE_Run_Time__c = System.now();
        jrAudit.RE_Run_Type__c = 'Manual';
        jrAudit.RE_Job_Type__c = 'Malaysia AMV Output';
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
        jrAudit.RE_Job_Type__c = country;//'Malaysia Output';
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
        return ([SELECT RE_Run_Time__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c = 'Malaysia Output' ORDER BY RE_Run_Time__c DESC LIMIT 1].RE_Run_Time__c);
    }
    
    @AuraEnabled
    public Static Boolean getUserInfo(Id userId){
		Boolean validProfile = false;       
        for(PermissionSetAssignment currentUserPerSet : [ 
            SELECT Id, PermissionSet.Name,AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId]){
                if(currentUserPerSet.PermissionSet.Name == 'RE_MY_Pricing_Desk'){
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
        Double temperatureVal = 0.00;
		Double temperatureCTVMYRval = 0.00;
        
        for(RE_Market_Quotes__c marketquoteData : [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c,RE_Temperature_Gain_USD_BB6__c,Temperature_Gain_MY_cent_l__c
            FROM RE_Market_Quotes__c
            WHERE RE_Tracker__c IN ('D','D-1')
            AND RE_Quote_Type__c IN ('Settlement','Market Premium')
            AND RE_Quote_Name__c IN ('Gasoil 0.05% S', 'Gasoil 0.5% S','Gasoil 0.005% S','Kero','MOGAS 95','MOGAS 97','Gasoil 0.001% S','Kero Premium','Gasoil 0.001% Premium')
            ORDER BY RE_Quote_Type__c ASC
        ]){
            if(marketquoteData.RE_Tracker__c =='D'){
                latestmarketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S'){
					temperatureVal	=	marketquoteData.RE_Temperature_Gain_USD_BB6__c;
					temperatureCTVMYRval	=	marketquoteData.Temperature_Gain_MY_cent_l__c;
				}
            }
            else{
                if(marketquoteData.RE_Tracker__c == 'D-1')
                    oldmarketquoteList.put(marketquoteData.RE_Quote_Name__c,marketquoteData);
            }
        }  
        
        List<MOPSDataWrapper> mopsdatalist = new List<MOPSDataWrapper>();
        for(RE_Market_Quotes__c todaymops : latestmarketquoteList.values()){
        	MOPSDataWrapper mopdata = new MOPSDataWrapper();
            mopdata.item = todaymops.RE_Quote_Name__c;
            mopdata.dailyval = todaymops.RE_Price__c;
			mopdata.lastdayval = 0; 
            mopdata.temperature	=	temperatureVal;//((MOPS10PPM + SpotPrem10ppm - QTYPREMIAGBE37) * 0.016).setscale(3);
			mopdata.temperatureMYRCTSL = temperatureCTVMYRval;//((MOPS10PPMCTMYRL + SpotPrem10ppmCTMYRL + QTYPREMIAGBE37CTMYRL) * 0.016).setscale(3);
            for(RE_Market_Quotes__c yesterdaymops : oldmarketquoteList.values()){
                if(todaymops.RE_Quote_Name__c == yesterdaymops.RE_Quote_Name__c){                    
                    mopdata.lastdayval = yesterdaymops.RE_Price__c;                                       
                }
            }
            mopsdatalist.add(mopdata);
        }
        return mopsdatalist;
    }
    
    @AuraEnabled
    public static List<FxDataWrapper> getFxData(){
        List<FxDataWrapper> fxdatawraplist = new List<FxDataWrapper>();
        List<RE_FX_Rates__c> fxListdatatoday = [
            SELECT RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c FROM RE_FX_Rates__c 
            WHERE  RE_Tracker__c  = 'D' AND RE_Conversion_Unit__c = 'MYR' AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell'];
        List<RE_FX_Rates__c> fxListdatayesterday = [
            SELECT RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c FROM RE_FX_Rates__c 
            WHERE  RE_Tracker__c  = 'D-1' AND RE_Conversion_Unit__c = 'MYR' AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell'];          
        
        FxDataWrapper fxWrapper = new FxDataWrapper();                                  
        fxWrapper.item = 'FX Rate (MYR/USD)';
        if(fxListdatatoday.size()>0 && fxListdatatoday[0] != null)
        {
            fxWrapper.dailyval = fxListdatatoday[0].RE_Forex_Rate__c;
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
        fxdatawraplist.add(fxWrapper);
        return fxdatawraplist;
    }

    public Static List<RE_MY_Output__c> marginalCostData(String region, Integer jobruncount){
        String type = 'Malaysia Output';
        String query = 'SELECT RE_Depot_Name__c,RE_Gasoil_B0_0_05_S_MC_Diff__c,RE_Gasoil_B0_0_05_S_MC__c,RE_Gasoil_B7_0_001_S_MC_Diff__c,RE_Gasoil_B7_0_001_S_MC__c,RE_Gasoil_B0_0_001_S_MC_Diff__c,RE_Gasoil_B0_0_001_S_MC__c,RE_Gasoil_B7_0_05_S_MC_Diff__c,RE_Gasoil_B7_0_05_S_MC__c,RE_Kerosene_MC_Diff__c,RE_Kerosene_MC__c,RE_MOGAS_95_MC_Diff__c,RE_MOGAS_95_MC__c,RE_MOGAS_97_MC_Diff__c,RE_MOGAS_97_MC__c,RE_Pricing_Date__c,RE_Region__c,RE_Gasoil_E2_B10_MC__c,RE_Gasoil_E2_B10_MC_Diff__c,RE_Gasoil_E5_B10_MC__c,RE_Gasoil_E5_B10_MC_Diff__c FROM RE_MY_Output__c WHERE RE_Pricing_Date__c = Today AND RE_Region__c =: region AND RE_Job_Run_Count__c =: jobruncount AND RE_Type__c =:type ORDER BY RE_Depot_Name__c ASC';
        List<RE_MY_Output__c> sobjList = Database.query(query);
        return sobjList;
    }

    public Static List<RE_MY_Output__c> laiddownCostData(String region, Integer jobruncount){
        String type = 'Malaysia Output';
        String query = 'SELECT RE_Depot_Name__c,RE_Gasoil_B0_0_05_S_LDC_Diff__c,RE_Gasoil_B0_0_05_S_LDC__c,RE_Gasoil_B7_0_001_S_LDC_Diff__c,RE_Gasoil_B7_0_001_S_LDC__c,RE_Gasoil_B0_0_001_S_LDC_Diff__c,RE_Gasoil_B0_0_001_S_LDC__c,RE_Gasoil_B7_0_05_S_LDC_Diff__c,RE_Gasoil_B7_0_05_S_LDC__c,RE_Kerosene_LDC_Diff__c,RE_Kerosene_LDC__c,RE_MOGAS_95_LDC_Diff__c,RE_MOGAS_95_LDC__c,RE_MOGAS_97_LDC_Diff__c,RE_MOGAS_97_LDC__c,RE_Pricing_Date__c,RE_Region__c,RE_Gasoil_E2_B10_LDC__c,RE_Gasoil_E2_B10_LDC_Diff__c,RE_Gasoil_E5_B10_LDC__c,RE_Gasoil_E5_B10_LDC_Diff__c FROM RE_MY_Output__c WHERE RE_Pricing_Date__c = Today AND RE_Region__c =: region AND RE_Job_Run_Count__c =: jobruncount AND RE_Type__c =:type ORDER BY RE_Depot_Name__c ASC';
        List<RE_MY_Output__c> sobjList = Database.query(query);
        return sobjList;
    }

    @AuraEnabled
    public static List<costDataWrapper> getCostingDataPeninsular(){
        Integer jobruncount = maxRunCountMethod();
        List<RE_MY_Output__c> penoutputmcdata = marginalCostData('Peninsular',jobruncount);
        List<costDataWrapper> costdataList = new costDataWrapper[penoutputmcdata.size() * 2];
        for(RE_MY_Output__c outputmcdata : penoutputmcdata){
            costdataList.add(getMCCostData(outputmcdata));
        }
        for(RE_MY_Output__c outputLDCdata : laiddownCostData('Peninsular',jobruncount)){
            costdataList.add(getLDCCostData(outputLDCdata));
        }        
        costdataList.sort();
        return costdataList;
    }

    @AuraEnabled
    public static List<costDataWrapper> getCostingDataSabah(){
        Integer jobruncount = maxRunCountMethod();
        List<RE_MY_Output__c> sbhoutputmcdata = marginalCostData('Sabah',jobruncount);
        List<costDataWrapper> costdataList = new costDataWrapper[sbhoutputmcdata.size() * 2];
        for(RE_MY_Output__c outputmcdata : sbhoutputmcdata){
            costdataList.add(getMCCostData(outputmcdata));
        }
        for(RE_MY_Output__c outputLDCdata : laiddownCostData('Sabah',jobruncount)){
            costdataList.add(getLDCCostData(outputLDCdata));
        }
        costdataList.sort();
        return costdataList;
    }

    @AuraEnabled
    public static List<costDataWrapper> getCostingDataSarawak(){
        Integer jobruncount = maxRunCountMethod();
        List<RE_MY_Output__c> swkoutputmcdata = marginalCostData('Sarawak',jobruncount);
        List<costDataWrapper> costdataList = new costDataWrapper[swkoutputmcdata.size() * 2];
        for(RE_MY_Output__c outputmcdata : swkoutputmcdata){
            costdataList.add(getMCCostData(outputmcdata));
        }
        for(RE_MY_Output__c outputLDCdata : laiddownCostData('Sarawak',jobruncount)){
            costdataList.add(getLDCCostData(outputLDCdata));
        }
        costdataList.sort();
        System.debug('costdataList'+costdataList);
        return costdataList;
    }
    
    public static costDataWrapper getMCCostData(RE_MY_Output__c outputmcdata){
        costDataWrapper costdata = new costDataWrapper();
        costdata.location = outputmcdata.RE_Depot_Name__c;
        costdata.mcorldc = 'MC';
        if(outputmcdata.RE_Kerosene_MC__c != null ) costdata.kerocbu = outputmcdata.RE_Kerosene_MC__c;
        if(outputmcdata.RE_Kerosene_MC_Diff__c != null ) costdata.kerodiff = outputmcdata.RE_Kerosene_MC_Diff__c;		
		if(outputmcdata.RE_Gasoil_B7_0_05_S_MC__c != null ) costdata.gob705cbu = outputmcdata.RE_Gasoil_B7_0_05_S_MC__c;
        if(outputmcdata.RE_Gasoil_B7_0_05_S_MC_Diff__c != null ) costdata.gob705diff = outputmcdata.RE_Gasoil_B7_0_05_S_MC_Diff__c;
		if(outputmcdata.RE_Gasoil_B0_0_05_S_MC__c != null ) costdata.gob005cbu = outputmcdata.RE_Gasoil_B0_0_05_S_MC__c;		
        if(outputmcdata.RE_Gasoil_B0_0_05_S_MC_Diff__c != null ) costdata.gob005diff = outputmcdata.RE_Gasoil_B0_0_05_S_MC_Diff__c;		
		if(outputmcdata.RE_Gasoil_B7_0_001_S_MC__c != null ) costdata.gob7001cbu = outputmcdata.RE_Gasoil_B7_0_001_S_MC__c;		
        if(outputmcdata.RE_Gasoil_B7_0_001_S_MC_Diff__c != null ) costdata.gob7001diff = outputmcdata.RE_Gasoil_B7_0_001_S_MC_Diff__c;	
        if(outputmcdata.RE_Gasoil_B0_0_001_S_MC__c != null ) costdata.gob0001cbu = outputmcdata.RE_Gasoil_B0_0_001_S_MC__c;		
        if(outputmcdata.RE_Gasoil_B0_0_001_S_MC_Diff__c != null ) costdata.gob0001diff = outputmcdata.RE_Gasoil_B0_0_001_S_MC_Diff__c;	
		if(outputmcdata.RE_MOGAS_95_MC__c != null ) costdata.mogas95cbu = outputmcdata.RE_MOGAS_95_MC__c;		
        if(outputmcdata.RE_MOGAS_95_MC_Diff__c != null ) costdata.mogas95diff = outputmcdata.RE_MOGAS_95_MC_Diff__c;		
		if(outputmcdata.RE_MOGAS_97_MC__c != null ) costdata.mogas97cbu = outputmcdata.RE_MOGAS_97_MC__c;
        if(outputmcdata.RE_MOGAS_97_MC_Diff__c != null ) costdata.mogas97diff = outputmcdata.RE_MOGAS_97_MC_Diff__c;
		if(outputmcdata.RE_Gasoil_E2_B10_MC__c != null ) costdata.goe2b10cbu = outputmcdata.RE_Gasoil_E2_B10_MC__c;
        if(outputmcdata.RE_Gasoil_E2_B10_MC_Diff__c != null ) costdata.goe2b10diff = outputmcdata.RE_Gasoil_E2_B10_MC_Diff__c;	
        if(outputmcdata.RE_Gasoil_E5_B10_MC__c != null ) costdata.goe5b10cbu = outputmcdata.RE_Gasoil_E5_B10_MC__c;
        if(outputmcdata.RE_Gasoil_E5_B10_MC_Diff__c != null ) costdata.goe5b10diff = outputmcdata.RE_Gasoil_E5_B10_MC_Diff__c;
        return costdata;
    }
    
    public static costDataWrapper getLDCCostData(RE_MY_Output__c outputLDCdata){
        costDataWrapper costdata = new costDataWrapper();
        costdata.location = outputLDCdata.RE_Depot_Name__c;
        costdata.mcorldc = 'LDC';
        if(outputLDCdata.RE_Kerosene_LDC__c != null ) costdata.kerocbu = outputLDCdata.RE_Kerosene_LDC__c;
        if(outputLDCdata.RE_Kerosene_LDC_Diff__c != null ) costdata.kerodiff = outputLDCdata.RE_Kerosene_LDC_Diff__c;		
		if(outputLDCdata.RE_Gasoil_B7_0_05_S_LDC__c != null ) costdata.gob705cbu = outputLDCdata.RE_Gasoil_B7_0_05_S_LDC__c;
        if(outputLDCdata.RE_Gasoil_B7_0_05_S_LDC_Diff__c != null ) costdata.gob705diff = outputLDCdata.RE_Gasoil_B7_0_05_S_LDC_Diff__c;
		if(outputLDCdata.RE_Gasoil_B0_0_05_S_LDC__c != null ) costdata.gob005cbu = outputLDCdata.RE_Gasoil_B0_0_05_S_LDC__c;		
        if(outputLDCdata.RE_Gasoil_B0_0_05_S_LDC_Diff__c != null ) costdata.gob005diff = outputLDCdata.RE_Gasoil_B0_0_05_S_LDC_Diff__c;		
		if(outputLDCdata.RE_Gasoil_B7_0_001_S_LDC__c != null ) costdata.gob7001cbu = outputLDCdata.RE_Gasoil_B7_0_001_S_LDC__c;		
        if(outputLDCdata.RE_Gasoil_B7_0_001_S_LDC_Diff__c != null ) costdata.gob7001diff = outputLDCdata.RE_Gasoil_B7_0_001_S_LDC_Diff__c;	
        if(outputLDCdata.RE_Gasoil_B0_0_001_S_LDC__c != null ) costdata.gob0001cbu = outputLDCdata.RE_Gasoil_B0_0_001_S_LDC__c;		
        if(outputLDCdata.RE_Gasoil_B0_0_001_S_LDC_Diff__c != null ) costdata.gob0001diff = outputLDCdata.RE_Gasoil_B0_0_001_S_LDC_Diff__c;	
		if(outputLDCdata.RE_MOGAS_95_LDC__c != null ) costdata.mogas95cbu = outputLDCdata.RE_MOGAS_95_LDC__c;		
        if(outputLDCdata.RE_MOGAS_95_LDC_Diff__c != null ) costdata.mogas95diff = outputLDCdata.RE_MOGAS_95_LDC_Diff__c;		
		if(outputLDCdata.RE_MOGAS_97_LDC__c != null ) costdata.mogas97cbu = outputLDCdata.RE_MOGAS_97_LDC__c;
        if(outputLDCdata.RE_MOGAS_97_LDC_Diff__c != null ) costdata.mogas97diff = outputLDCdata.RE_MOGAS_97_LDC_Diff__c;
		if(outputLDCdata.RE_Gasoil_E2_B10_LDC__c != null ) costdata.goe2b10cbu = outputLDCdata.RE_Gasoil_E2_B10_LDC__c;
        if(outputLDCdata.RE_Gasoil_E2_B10_LDC_Diff__c != null ) costdata.goe2b10diff = outputLDCdata.RE_Gasoil_E2_B10_LDC_Diff__c;
        if(outputLDCdata.RE_Gasoil_E5_B10_LDC__c != null ) costdata.goe5b10cbu = outputLDCdata.RE_Gasoil_E5_B10_LDC__c;
        if(outputLDCdata.RE_Gasoil_E5_B10_LDC_Diff__c != null ) costdata.goe5b10diff = outputLDCdata.RE_Gasoil_E5_B10_LDC_Diff__c;
        return costdata;
    }
    
    @AuraEnabled
    public static InitialDetailsWrapper getInitParameterDetails(Id userId){
		
		Map<String,List<costDataWrapper>> costingMaps = new Map<String,List<costDataWrapper>>();
		costingMaps.put('costingMaps',getCostingDataPeninsular());
		costingMaps.put('costingSabahs',getCostingDataSabah());
		costingMaps.put('costingDataSarawaks',getCostingDataSarawak());
		
		InitialDetailsWrapper initialDetails = 	new InitialDetailsWrapper();
		initialDetails.validProfile 		 = 	getUserInfo(userId);
		initialDetails.lastJobRun			 =	(lastJobRun()).format('dd/MM/yyyy hh:mm a');
		initialDetails.mops					 =	getMOPSData();
		initialDetails.fxrates				 =	getFxData();
		initialDetails.costMaps			   	 =	costingMaps;
				
		return initialDetails;
		
    }
    @AuraEnabled
    public static Boolean fetchmiddaydata(){
        List<RE_Midday_Pricing__c> middaylistEM = RE_MidDayPricingController.fetchMidDayOutput('EM');
        if(middaylistEM != null)
            return true;
        else
            return false;
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
	}
    
    global class costDataWrapper implements Comparable {
        @AuraEnabled
        public String location{get;set;}
        @AuraEnabled
        public String mcorldc{get;set;}
        @AuraEnabled
        public Decimal kerocbu{get;set;}
        @AuraEnabled
        public Decimal kerodiff{get;set;}
        @AuraEnabled
        public Decimal gob705cbu{get;set;}
        @AuraEnabled
        public Decimal gob705diff{get;set;}
        @AuraEnabled
        public Decimal gob005cbu{get;set;}
        @AuraEnabled
        public Decimal gob005diff{get;set;}
        @AuraEnabled
        public Decimal gob7001cbu{get;set;}
        @AuraEnabled
        public Decimal gob7001diff{get;set;}
        @AuraEnabled
        public Decimal mogas95cbu{get;set;}
        @AuraEnabled
        public Decimal mogas95diff{get;set;}
        @AuraEnabled
        public Decimal mogas97cbu{get;set;}
        @AuraEnabled
        public Decimal mogas97diff{get;set;}              
        @AuraEnabled
        public Decimal goe2b10cbu{get;set;}
        @AuraEnabled
        public Decimal goe2b10diff{get;set;} 
        @AuraEnabled
        public Decimal gob0001cbu{get;set;}
        @AuraEnabled
        public Decimal gob0001diff{get;set;}
        @AuraEnabled
        public Decimal goe5b10cbu{get;set;}
        @AuraEnabled
        public Decimal goe5b10diff{get;set;}
        
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
        public Double Price{get;set;}
        @AuraEnabled
        public Double temperature{get;set;}
		@AuraEnabled
        public Double temperatureMYRCTSL{get;set;}
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
}