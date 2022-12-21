/*****************************************************************************
@Name:  RV_SHTDaveTriggerHelper     
@=========================================================================
@Purpose: Trigger handler will execute when we are inserting data in SHT Dave for transaction type Hedge
         
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/14/2017         INITIAL DEVELOPMENT
@2.0 - Soumyajit Jagadev			     04/14/2020         Removed Hardcoded Product Mapping
******************************************************************************/
public class RV_SHTDaveTriggerHelper {
    public static boolean newValExposFac= true;
    public static boolean newValHedged= true;
    public static final Set<String> daveMasterSet = new Set<String>{'AGO B7', 'IGO 50ppm','MOGAS'};	//Fix_483601_14Apr2020_Soumyajit
    public static void onBeforeInsert(List<SHT_Dave__c> shtDaveInsert){
        
        Set<String> shtDavestring = new Set<String>();
        
        for(SHT_Dave__c shtDave : shtDaveInsert){
            shtDavestring.add(shtDave.Product_Name__c);
        }
        List<SHT_Dave_Master__c> shtDaveMasterMap = [select id,Name,LastModifiedDate,Total_Exposure_Factors__c,Hedged__c 
                                                     from SHT_Dave_Master__c FOR UPDATE];
        
        Map<String,SHT_Dave_Master__c> shtDaveMasterMaps = new Map<String,SHT_Dave_Master__c>();
    
        if(!shtDaveMasterMap.isEmpty()){                
            for(SHT_Dave_Master__c shtDaveMstr : shtDaveMasterMap){
                shtDaveMasterMaps.put(shtDaveMstr.Name,shtDaveMstr);
            }
        } 
            
            
        DateTime dT = System.now();            
        Map<String,SHT_Dave_Master__c> shtDaveUpdate = new Map<String,SHT_Dave_Master__c>();
    
            for(SHT_Dave__c shtDave : shtDaveInsert){                    
                shtDave.Created_Date__c = dT;
                if(shtDaveMasterMaps.containsKey(shtDave.Product_Name__c)){
                    shtDave.SHT_Dave_Master__c = shtDaveMasterMaps.get(shtDave.Product_Name__c).ID;
                }
             
                if(shtDave.Created_Date__c <> null)
                    shtDave.Time_Stamp__c = gettimeStamp(shtDave.Created_Date__c);
        
                if(shtDave.Hedging_Date__c <> null){
                    shtDave.Hedging_Date__c = System.now();                       
                    shtDave.Time_Stamp__c = gettimeStamp(shtDave.Hedging_Date__c);
                }
             
                List<Product_Name_Mapping__mdt> fetchProductMappingMD = [SELECT ID,MasterLabel,DeveloperName,Product_Name__c
                                                                         ,Hedge_Mapping__c	//Fix_483601_14Apr2020_Soumyajit
                                                                         from Product_Name_Mapping__mdt];

                Map<String,Product_Name_Mapping__mdt> MapOfProductMapping = new Map<String,Product_Name_Mapping__mdt>();                
                MapOfProductMapping = mappingOFPRoduct(fetchProductMappingMD);
            
                if(shtDave.Hedging_Date__c == null){    
                    if( MapOfProductMapping.containsKey(shtDave.Product_Name__c)){
                        SHT_Dave_Master__c shtDaveMaster = shtDaveMasterMaps.get(shtDave.Product_Name__c);
                        
                        if(shtDaveMaster <> null){                         
                            Date lastmodifiedDate = date.newinstance(shtDaveMaster.LastModifiedDate.year(), shtDaveMaster.LastModifiedDate.month(), shtDaveMaster.LastModifiedDate.day()); 
                            Date createDate = date.newinstance(shtDave.Created_Date__c.year(), shtDave.Created_Date__c.month(), shtDave.Created_Date__c.day()); 
                            if(createDate == lastmodifiedDate)
                            {
                                String prodtctName = MapOfProductMapping.get(shtDave.Product_Name__c).Hedge_Mapping__c;  //Fix_483601_14Apr2020_Soumyajit
    
                                if( daveMasterSet.contains(prodtctName) && shtDaveMasterMaps.containskey(prodtctName))
                                {
                                    SHT_Dave_Master__c shtDaveMasterGasOil = shtDaveMasterMaps.get(prodtctName);
                                    if(shtDaveMasterGasOil.Total_Exposure_Factors__c == null)
                                        shtDaveMasterGasOil.Total_Exposure_Factors__c = 0;                     
                                    if(shtDave.Status__c == Label.SHT_Status_Cancelled){
                                        shtDaveMasterGasOil.Total_Exposure_Factors__c -= shtDave.Exposure_Factor__c;
                                    }else if(shtDave.Status__c == Label.SHT_Status_Completed || shtDave.Status__c == 'Auto-Completed'){
                                        shtDaveMasterGasOil.Total_Exposure_Factors__c += shtDave.Exposure_Factor__c;
                                }  
                                
                                shtDave.Exposure_Factor__c = shtDaveMasterGasOil.Total_Exposure_Factors__c + shtDaveMasterGasOil.Hedged__c;                        
                                shtDaveUpdate.put(prodtctName,shtDaveMasterGasOil);
                            }
                        }
                    }
                }
            }else if(shtDave.Hedging_Date__c <> null){
                if(daveMasterSet.contains(shtDave.Product_Name__c) && shtDaveMasterMaps.containskey(shtDave.Product_Name__c)){
                 
                    SHT_Dave_Master__c shtDaveMaster = shtDaveMasterMaps.get(shtDave.Product_Name__c);                 
                    if(shtDaveMaster <> null){                     
                        Date lastmodifiedDate = date.newinstance(shtDaveMaster.LastModifiedDate.year(), shtDaveMaster.LastModifiedDate.month(), shtDaveMaster.LastModifiedDate.day()); 
                        Date createDate = date.newinstance(shtDave.Created_Date__c.year(), shtDave.Created_Date__c.month(), shtDave.Created_Date__c.day()); 
                        
                        if(createDate == lastmodifiedDate){                                
                            if(shtDaveMaster.Hedged__c == null)
                                shtDaveMaster.Hedged__c = 0;             
                            
                            shtDaveMaster.Hedged__c += shtDave.Hedge__c;                                
                            shtDave.Exposure_Factor__c =  shtDaveMaster.Total_Exposure_Factors__c + shtDaveMaster.Hedged__c;
                            shtDaveUpdate.put(shtDave.Product_Name__c,shtDaveMaster);                            
                        }
                    }
                }
            }
        }
        
        if(shtDaveUpdate <> null && shtDaveUpdate.size() > 0){
            try{
                update shtDaveUpdate.values();
            }catch(Exception e){
                //System.debug('%%%%%%%%%'+shtDaveUpdate);
            }
        }
    }
    
    public static void publishTotalExposure(List<SHT_Dave_Master__c> shtDaveUpdate){
        for(SHT_Dave_Master__c shtDaveMaster : shtDaveUpdate){
            if(daveMasterSet.contains(shtDaveMaster.Name)){
                Rv_SubscribeToShtDave__e subscribeSHTDave = new Rv_SubscribeToShtDave__e();
                subscribeSHTDave.Total_Exposure_Factor__c = shtDaveMaster.Total_Exposure_Factors__c;
                subscribeSHTDave.Xposr_CBM__c = shtDaveMaster.Total_Exposure_Factor_CBM__c;
                subscribeSHTDave.Xposr_Tonne__c = shtDaveMaster.Total_Exposure_Factor_MT__c;
                subscribeSHTDave.Hedge_Lots__c = shtDaveMaster.Hedged__c;
                subscribeSHTDave.Open_Xposr_Lots__c = shtDaveMaster.Final_Exposure_Factor__c;
                subscribeSHTDave.Product_Name__c = shtDaveMaster.Name;
                Database.SaveResult sr = EventBus.publish(subscribeSHTDave);
                if (sr.isSuccess()) { 
                } else { 
                    for(Database.Error err : sr.getErrors()) { 
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage()); 
                    }
                }
            }
        
    }
    }
    
    public static Map<String,Product_Name_Mapping__mdt> mappingOFPRoduct(List<Product_Name_Mapping__mdt> fetchProductMappingMD){        
        Map<String,Product_Name_Mapping__mdt> MapOfProductMapping = new Map<String,Product_Name_Mapping__mdt>();
        
        if(!fetchProductMappingMD.isEmpty()){            
            for(Product_Name_Mapping__mdt productName : fetchProductMappingMD){                
                MapOfProductMapping.put(productName.MasterLabel, productName);                    
            }
        }
        
        return MapOfProductMapping;
    }
    
    
    public static String gettimeStamp(Datetime hedgingTime){
        String hours;
        String minutes;
        
        if(hedgingTime.hour() < 10) 
            hours = '0'+String.valueof(hedgingTime.hour());
        else 
            hours = String.valueof(hedgingTime.hour());
        if(hedgingTime.minute() < 10)
            minutes = '0'+String.valueof(hedgingTime.minute());
        else 
            minutes =  String.valueof(hedgingTime.minute());            
        String timeStamp = hours+':'+minutes;            
        
        return timeStamp;
    }

}