global with sharing class RE_PH_OutputController { 
    Public Static Integer maxRunCount;
    @AuraEnabled
    public Static Integer maxRunCountMethod(){
        //fetching RE_Job_Run_Count__c from RE_MY_Output__c
        List<RE_Job_Run_Audit__c> costDataToday = [SELECT RE_Job_Run_Count__c FROM RE_Job_Run_Audit__c 
                                                  WHERE createddate = Today AND RE_Job_Type__c='Philippines Output' ORDER BY RE_Job_Run_Count__c  DESC LIMIT 1];
        if(!costDataToday.isEmpty())
            maxRunCount = Integer.valueOf(costDataToday[0].RE_Job_Run_Count__c);
        return maxRunCount;
    }
    public RE_PH_OutputController(ApexPages.StandardSetController controller){
        
    }

    @AuraEnabled
    public Static Datetime lastJobRun(){
        return ([SELECT RE_Run_Time__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c = 'Philippines Output' ORDER BY RE_Run_Time__c DESC LIMIT 1].RE_Run_Time__c);
    }
    
    @AuraEnabled
    public Static Boolean getUserInfo(Id userId){
        Boolean validProfile = false;       
        for(PermissionSetAssignment currentUserPerSet : [ 
            SELECT Id, PermissionSet.Name,AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId]){
                if(currentUserPerSet.PermissionSet.Name == 'RE_PH_Pricing_Desk'){  //needs change
                    validProfile = true;  
                    break;
                }
            }
        System.debug('validProfile-->'+validProfile);
        return validProfile;
    }
        
    @AuraEnabled
    public Static List<MOPSDataWrapper> getMOPSData(){
        Map<String,MOPSDataWrapper> mopsdatalist = new Map<String,MOPSDataWrapper>();
        List<MOPSDataWrapper> mopslist = new List<MOPSDataWrapper>();
        Map<String,Double> fxMap = new Map<String,Double>();
        List<RE_Market_Quotes__c> quotelist = new List<RE_Market_Quotes__c>();
        quotelist =  [
            SELECT NAME,RE_Price__c,RE_Pricing_Date__c,RE_Rate_Unit__c,RE_Quote_Name__c,RE_Tracker__c
            FROM RE_Market_Quotes__c
            WHERE RE_Quote_Type__c IN ('Settlement') AND RE_Is_MTDWTD__c = False
            AND RE_Quote_Name__c IN ('MOGAS 92','Gasoil 0.001% S','Marine FuelOil 180','ETHANOL','UCAP RBD CNO')
            ORDER BY RE_Pricing_Date__c DESC
            LIMIT 80
        ];
        for(RE_FX_Rates__c fxdata : [
            SELECT RE_Forex_Rate__c,RE_Pricing_Date__c,RE_Trade_Type__c,RE_Conversion_Unit__c,RE_Base_Unit__c FROM RE_FX_Rates__c 
            WHERE  RE_Conversion_Unit__c IN('PHP') AND RE_Base_Unit__c = 'USD' AND RE_Trade_Type__c = 'Sell' AND RE_Is_MTDWTD__c = False ORDER BY RE_Pricing_Date__c DESC]){
                if(mopsdatalist.size() == 2){
                    mopslist.addAll(mopsdatalist.values());
                    MOPSDataWrapper mopsdata = new MOPSDataWrapper();
                    mopsdata.mopsdate = 'D - (D-1)';
                    mopsdata.WeightedAvePDS = (mopslist[0].WeightedAvePDS != null ? mopslist[0].WeightedAvePDS : 0) - (mopslist[1].WeightedAvePDS != null ? mopslist[1].WeightedAvePDS : 0);
                    mopsdata.UCAPRBDCNO = (mopslist[0].UCAPRBDCNO != null ? mopslist[0].UCAPRBDCNO : 0) - (mopslist[1].UCAPRBDCNO != null ? mopslist[1].UCAPRBDCNO : 0);
                    mopsdata.CIFEthanol = (mopslist[0].CIFEthanol != null ? mopslist[0].CIFEthanol : 0) - (mopslist[1].CIFEthanol != null ? mopslist[1].CIFEthanol : 0);
                    mopsdata.SIN92UNL = (mopslist[0].SIN92UNL != null ? mopslist[0].SIN92UNL : 0) - (mopslist[1].SIN92UNL != null ? mopslist[1].SIN92UNL : 0);
                    mopsdata.SINGOIL = (mopslist[0].SINGOIL != null ? mopslist[0].SINGOIL : 0) - (mopslist[1].SINGOIL != null ? mopslist[1].SINGOIL : 0);
                    mopsdata.SINHSFO180 = (mopslist[0].SINHSFO180 != null ? mopslist[0].SINHSFO180 : 0) - (mopslist[1].SINHSFO180 != null ? mopslist[1].SINHSFO180 : 0);
                    mopsdatalist.put(mopsdata.mopsdate, mopsdata);
                    break;
                }
                else{
                    fxMap.put(fxdata.RE_Pricing_Date__c.format('yyyy-MM-dd'),fxdata.RE_Forex_Rate__c);
                    for(RE_Market_Quotes__c marketquoteData : quotelist){
                        String mopsdatadate = marketquoteData.RE_Pricing_Date__c.format('yyyy-MM-dd');
                        if(mopsdatadate == fxdata.RE_Pricing_Date__c.format('yyyy-MM-dd')){
                            if(!mopsdatalist.containsKey(mopsdatadate)){
                                MOPSDataWrapper mopsdata = new MOPSDataWrapper();
                                mopsdata.mopsdate = mopsdatadate;
                                if(fxMap.containsKey(mopsdata.mopsdate))
                                    mopsdata.WeightedAvePDS = fxMap.get(mopsdata.mopsdate);
                                if(marketquoteData.RE_Quote_Name__c == 'UCAP RBD CNO')
                                    mopsdata.UCAPRBDCNO = marketquoteData.RE_Price__c;
                                if(marketquoteData.RE_Quote_Name__c == 'ETHANOL')
                                    mopsdata.CIFEthanol = marketquoteData.RE_Price__c;   
                                if(marketquoteData.RE_Quote_Name__c == 'MOGAS 92')
                                    mopsdata.SIN92UNL = marketquoteData.RE_Price__c;
                                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S')
                                    mopsdata.SINGOIL = marketquoteData.RE_Price__c; 
                                if(marketquoteData.RE_Quote_Name__c == 'Marine FuelOil 180')
                                    mopsdata.SINHSFO180 = marketquoteData.RE_Price__c;     
                                mopsdatalist.put(mopsdata.mopsdate,mopsdata);
                            }
                            else{
                                if(marketquoteData.RE_Quote_Name__c == 'UCAP RBD CNO')
                                    mopsdatalist.get(mopsdatadate).UCAPRBDCNO = marketquoteData.RE_Price__c;
                                if(marketquoteData.RE_Quote_Name__c == 'ETHANOL')
                                    mopsdatalist.get(mopsdatadate).CIFEthanol = marketquoteData.RE_Price__c; 
                                if(marketquoteData.RE_Quote_Name__c == 'MOGAS 92')
                                    mopsdatalist.get(mopsdatadate).SIN92UNL = marketquoteData.RE_Price__c;
                                if(marketquoteData.RE_Quote_Name__c == 'Gasoil 0.001% S')
                                    mopsdatalist.get(mopsdatadate).SINGOIL = marketquoteData.RE_Price__c; 
                                if(marketquoteData.RE_Quote_Name__c == 'Marine FuelOil 180')
                                    mopsdatalist.get(mopsdatadate).SINHSFO180 = marketquoteData.RE_Price__c;                  
                            }        
                        }
                    }
                }
            }
        return mopsdatalist.values();
    }

    @AuraEnabled
    public static InitialDetailsWrapper getInitParameterDetails(Id userId){ 
        
        System.debug('userId---'+userId);
        InitialDetailsWrapper initialDetails =  new InitialDetailsWrapper();
        initialDetails.validProfile          =  getUserInfo(userId);
        initialDetails.lastJobRun            =  (lastJobRun()).format('dd/MM/yyyy hh:mm a');
        initialDetails.mops                  =  getMOPSData();
        initialDetails.jobruncount           = maxRunCountMethod();
        initialDetails.costMaps              =  getCostingDataPH(null,false);
        initialDetails.egcostMaps            =  getCostingDataPH(null,true);
        initialDetails.dataMaps              =  getDateDataPH('PH Tabangao');
        System.debug('costingMapsLDC---'+initialDetails);  
        //Cache.Org.put('PHDataWrapper', initialDetails);
        return initialDetails;
        
    }
    
    @Auraenabled
    public static List<dateDataWrapper> getDateDataPH(String plantName){
        String plant= plantName != null ? plantName : '';
        Map<String,dateDataWrapper> datedatalist = new Map<String,dateDataWrapper>();
        dateDataWrapper dwrp1 = new dateDataWrapper();
            dwrp1.datetype = 'Data';
        dateDataWrapper dwrp2 = new dateDataWrapper();
            dwrp2.datetype = 'Effective Date';
        for(RE_MY_CostPrice__c costdata : [
            SELECT RE_Product_Name__r.RE_Material__c, RE_Product_Name__r.Name,RE_Product_Name__r.RE_PH_Index__c,RE_Costprice_Laid_Down_Cost__c,
            id, RE_Type__c,RE_Data__c, RE_Effective_Date__c
            FROM RE_MY_CostPrice__c 
            WHERE RE_IsLatest__c = True AND RecordType.Name = 'Philippines' AND RE_PH_Is_Blend__c = False AND RE_Depot_Name__r.Name =: plant 
            AND RE_Type__c IN ('D-1','D-2','M-1','M-2','W-1','W-2','WTD','MTD')
            ORDER By RE_Product_Name__c DESC]){
                if(costdata.RE_Type__c == 'M-1'){
                    dwrp1.M1Date = costdata.RE_Data__c;
                    dwrp2.M1Date = costdata.RE_Effective_Date__c;
                }
                if(costdata.RE_Type__c == 'W-1'){
                    dwrp1.W1Date = costdata.RE_Data__c;
                    dwrp2.W1Date = costdata.RE_Effective_Date__c;
                }
                if(costdata.RE_Type__c == 'D-1'){
                    dwrp1.D1Date = costdata.RE_Data__c;
                    dwrp2.D1Date = costdata.RE_Effective_Date__c;
                }
                if(costdata.RE_Type__c == 'M-2'){
                    dwrp1.M2Date = costdata.RE_Data__c;
                    dwrp2.M2Date = costdata.RE_Effective_Date__c;
                }
                if(costdata.RE_Type__c == 'W-2' ){
                    dwrp1.W2Date = costdata.RE_Data__c;
                    dwrp2.W2Date = costdata.RE_Effective_Date__c;
                }
                if(costdata.RE_Type__c == 'D-2' ){
                    dwrp1.D2Date = costdata.RE_Data__c;
                    dwrp2.D2Date = costdata.RE_Effective_Date__c;
                }
                if(costdata.RE_Type__c == 'WTD'){
                    dwrp1.WTDDate = costdata.RE_Data__c;
                    dwrp2.WTDDate = costdata.RE_Effective_Date__c;
                }
                if(costdata.RE_Type__c == 'MTD'){
                    dwrp1.MTDDate = costdata.RE_Data__c;
                    dwrp2.MTDDate = costdata.RE_Effective_Date__c;
                }
            }
        datedatalist.put(dwrp1.datetype,dwrp1);
        datedatalist.put(dwrp2.datetype,dwrp2);
        return datedatalist.values();
    }
    
    @AuraEnabled
    public static List<costDataWrapper> getCostingDataPH(String plantName, Boolean isEGcost){
        String plant= plantName != null ? plantName : '';
        Map<String,costDataWrapper> costdatalist = new Map<String,costDataWrapper>();
        List<costDataWrapper> finalcostdatalist = new  List<costDataWrapper>();
        Map<String,RE_Depot_Pricing_Backbone__c> depoMap  = new Map<String,RE_Depot_Pricing_Backbone__c>();
        for(RE_Depot_Pricing_Backbone__c depodata: [
            SELECT Id,RE_Country__c,RE_Country__r.Name,RE_Depot_Name__r.Name,RE_Product_Name__r.Name
            FROM RE_Depot_Pricing_Backbone__c
            WHERE RE_Valid_From__c <= Today AND RE_Valid_To__c >= Today
            AND RecordType.Name='Philippines'
        ]){
            depoMap.put(depodata.RE_Depot_Name__r.Name+'_'+depodata.RE_Product_Name__r.Name,depodata);
        }
        for(RE_MY_CostPrice__c costdata : [
            SELECT RE_Product_Name__r.RE_Material__c, RE_Product_Name__r.Name,RE_Product_Name__r.RE_PH_Index__c,RE_Costprice_Laid_Down_Cost__c,
            id, RE_Type__c,RE_Data__c, RE_Effective_Date__c, RE_Costprice_Marginal_Cost__c
            FROM RE_MY_CostPrice__c 
            WHERE RE_IsLatest__c = True AND RecordType.Name = 'Philippines' AND RE_PH_Is_Blend__c = False AND RE_Depot_Name__r.Name =: plant 
            AND RE_Type__c IN ('D-1','D-2','M-1','M-2','W-1','W-2','WTD','MTD')
            ORDER By RE_Product_Name__c DESC]){
            if(!costdatalist.containsKey(costdata.RE_Product_Name__r.Name) && depoMap.containsKey(plant+'_'+costdata.RE_Product_Name__r.Name)){
                costDataWrapper ldcdata = new costDataWrapper();
                ldcdata.product = costdata.RE_Product_Name__r.Name;
                ldcdata.productcode = costdata.RE_Product_Name__r.RE_Material__c;
                ldcdata.index = Integer.valueOf(costdata.RE_Product_Name__r.RE_PH_Index__c);
                if(costdata.RE_Type__c == 'M-1'){
                    ldcdata.M1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }                                
                if(costdata.RE_Type__c == 'M-2'){           
                    ldcdata.M2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-1'){           
                    ldcdata.W1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-2'){           
                    ldcdata.W2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-1'){           
                    ldcdata.D1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-2'){            
                    ldcdata.D2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c; 
                }
                if(costdata.RE_Type__c == 'MTD'){          
                    ldcdata.MTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'WTD'){         
                    ldcdata.WTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                costdatalist.put(ldcdata.product,ldcdata);         
            }
            else if(depoMap.containsKey(plant+'_'+costdata.RE_Product_Name__r.Name)){
                if(costdata.RE_Type__c == 'M-1'){           
                    costdatalist.get(costdata.RE_Product_Name__r.Name).M1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'M-2'){
                    costdatalist.get(costdata.RE_Product_Name__r.Name).M2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-1'){           
                    costdatalist.get(costdata.RE_Product_Name__r.Name).W1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'W-2'){            
                    costdatalist.get(costdata.RE_Product_Name__r.Name).W2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-1'){            
                    costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'D-2'){           
                    costdatalist.get(costdata.RE_Product_Name__r.Name).D2Data = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'MTD'){
                    costdatalist.get(costdata.RE_Product_Name__r.Name).MTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdata.RE_Type__c == 'WTD'){        
                    costdatalist.get(costdata.RE_Product_Name__r.Name).WTDData = isEGcost == false ? costdata.RE_Costprice_Laid_Down_Cost__c : costdata.RE_Costprice_Marginal_Cost__c;
                }
                if(costdatalist.get(costdata.RE_Product_Name__r.Name).W1Data != null && costdatalist.get(costdata.RE_Product_Name__r.Name).W2Data != null)
                    costdatalist.get(costdata.RE_Product_Name__r.Name).W1VSW2Data = costdatalist.get(costdata.RE_Product_Name__r.Name).W1Data - 
                    costdatalist.get(costdata.RE_Product_Name__r.Name).W2Data;
                if(costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data != null && costdatalist.get(costdata.RE_Product_Name__r.Name).M1Data != null)
                    costdatalist.get(costdata.RE_Product_Name__r.Name).D1VSM1Data = costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data - 
                    costdatalist.get(costdata.RE_Product_Name__r.Name).M1Data;
                if(costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data != null && costdatalist.get(costdata.RE_Product_Name__r.Name).W1Data != null)
                    costdatalist.get(costdata.RE_Product_Name__r.Name).D1VSW1Data = costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data - 
                    costdatalist.get(costdata.RE_Product_Name__r.Name).W1Data; 
                if(costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data != null && costdatalist.get(costdata.RE_Product_Name__r.Name).D2Data != null)
                    costdatalist.get(costdata.RE_Product_Name__r.Name).D1VSD2Data = costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data - 
                    costdatalist.get(costdata.RE_Product_Name__r.Name).D2Data; 
                if(costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data != null && costdatalist.get(costdata.RE_Product_Name__r.Name).WTDData != null)
                    costdatalist.get(costdata.RE_Product_Name__r.Name).D1VSWTDData = costdatalist.get(costdata.RE_Product_Name__r.Name).D1Data - 
                    costdatalist.get(costdata.RE_Product_Name__r.Name).WTDData;  
                if(costdatalist.get(costdata.RE_Product_Name__r.Name).W1Data != null && costdatalist.get(costdata.RE_Product_Name__r.Name).WTDData != null)
                    costdatalist.get(costdata.RE_Product_Name__r.Name).WTDVSW1Data = costdatalist.get(costdata.RE_Product_Name__r.Name).WTDData - 
                    costdatalist.get(costdata.RE_Product_Name__r.Name).W1Data;  
            }
        }
        //Cache.Org.put('costList', costdatalist.values());
        finalcostdatalist = costdatalist.values();        
        finalcostdatalist.sort();
        return finalcostdatalist;
    }

    public class InitialDetailsWrapper{
        @AuraEnabled 
        public Boolean                           validProfile { get; set; }
        
        @AuraEnabled
        public String                            lastJobRun   { get; set; }
        
        @AuraEnabled
        public List<MOPSDataWrapper>             mops         { get; set; }
        
        @AuraEnabled
        public List<costDataWrapper>             costMaps     { get; set; } 
        
        @AuraEnabled
        public List<costDataWrapper>             egcostMaps   { get; set; } 
        
        @AuraEnabled
        public List<dateDataWrapper>             dataMaps     { get; set; } 
        
        @AuraEnabled
        public Integer                          jobruncount   { get; set; }

    }
     // wrapper class with @AuraEnabled and {get;set;} properties 
     public class MOPSDataWrapper{
        @AuraEnabled
        public String mopsdate{get;set;}
        @AuraEnabled
        public Double SIN92UNL{get;set;}
        @AuraEnabled
        public Double SINGOIL{get;set;}
        @AuraEnabled
        public Double SINHSFO180{get;set;}
        @AuraEnabled
        public Double WeightedAvePDS{get;set;}
        @AuraEnabled
        public Double UCAPRBDCNO{get;set;}
        @AuraEnabled
        public Double CIFEthanol{get;set;}
    }

    global class dateDataWrapper{
        @AuraEnabled
        public String datetype{get;set;}
        @AuraEnabled
        public String M1Date{get;set;}
        @AuraEnabled
        public String M2Date{get;set;}
        @AuraEnabled
        public String W1Date{get;set;}
        @AuraEnabled
        public String W2Date{get;set;}
        @AuraEnabled
        public String D1Date{get;set;}
        @AuraEnabled
        public String D2Date{get;set;}
        @AuraEnabled
        public String WTDDate{get;set;}
        @AuraEnabled
        public String MTDDate{get;set;}
        global Integer compareTo(Object ObjToCompare) {
            return datetype.CompareTo(((dateDataWrapper)ObjToCompare).datetype);
        }
    }
    global class costDataWrapper implements Comparable {
        @AuraEnabled
        public String product{get;set;}
        @AuraEnabled
        public String productcode{get;set;}
        @Auraenabled
        public Integer index{get; set;}
        @AuraEnabled
        public Decimal M1Data{get;set;}
        @AuraEnabled
        public Decimal M1tpData{get;set;}
        @AuraEnabled
        public Decimal M2Data{get;set;}
        @AuraEnabled
        public Decimal W1Data{get;set;}
        @AuraEnabled
        public Decimal W1tpData{get;set;}
        @AuraEnabled
        public Decimal W2Data{get;set;}
        @AuraEnabled
        public Decimal D1Data{get;set;}
        @AuraEnabled
        public Decimal D1tpData{get;set;}
        @AuraEnabled
        public Decimal D2Data{get;set;}
        @AuraEnabled
        public Decimal WTDData{get;set;}
        @AuraEnabled
        public Decimal WTDtpData{get;set;}
        @AuraEnabled
        public Decimal MTDData{get;set;}
        @AuraEnabled
        public Decimal MTDtpData{get;set;}
        @AuraEnabled
        public Decimal W1VSW2Data{get;set;}
        @AuraEnabled
        public Decimal D1VSM1Data{get;set;}
        @AuraEnabled
        public Decimal D1VSW1Data{get;set;}
        @AuraEnabled
        public Decimal D1VSD2Data{get;set;}
        @AuraEnabled
        public Decimal D1VSWTDData{get;set;}
        @AuraEnabled
        public Decimal WTDVSW1Data{get;set;}

        global Integer compareTo(Object ObjToCompare) {
            return Integer.valueOf(index - ((costDataWrapper)objToCompare).index);
        }
    }

    @AuraEnabled
    public Static List<Aggregateresult> fetchPlantdata(String country){
        return ([Select RE_Depot_Name__r.Name FROM RE_MY_CostPrice__c WHERE RE_IsLatest__c = True AND RecordType.Name =: country  AND RE_Depot_Name__r.Name != null AND RE_PH_Is_Blend__c = False AND RE_Type__c IN ('D-1','D-2','M-1','M-2','W-1','W-2','WTD','MTD') GROUP BY RE_Depot_Name__r.Name]);
    }
}