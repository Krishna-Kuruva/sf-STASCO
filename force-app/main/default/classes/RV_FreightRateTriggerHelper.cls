public class RV_FreightRateTriggerHelper {
    public static Boolean staticVal = true;
    public static void onBeforeInsertHelper(List<Freight_Rate__c> onBeforeUpdateNew , 
                                            list<Freight_Rate__c> onBeforeUpdateOld){
                                                
            Map<String,Freight_Rate__c> freightRateMap = new Map<String,Freight_Rate__c>();                                  
           // Map<String,Freight_Rate__c> markerValueMap = new Map<String,Freight_Rate__c>();
             Set<String> FreightQuoteSet = new  Set<String>();                                        
            for(Freight_Rate__c freightRate : onBeforeUpdateNew){
                //Added By Dhriti
                /*PBI-437456-Lakshmi_04162020_starts
                List<String> split = freightRate.Name.split('_');
                if(String.isNotBlank(split[1])){
                	freightRate.supplier__c = split[1];
                }
                PBI-437456-Lakshmi_04162020_Ends*/
                if(freightRate.Freight_rate_EUR_mt__c <> 0){
                    //freightRateMap.put(freightRate.Name,freightRate);//Fix_493485_Lakshmi_27Apr2020
                    freightRateMap.put(freightRate.Backbone_Route_Name__c,freightRate);
                    System.debug('freightRateMap'+freightRateMap);
                }
                if(freightRate.Freight_Quotation__c <> null){
                    FreightQuoteSet.add(freightRate.Freight_Quotation__c);
                    
                }
            }
            
            if(FreightQuoteSet.size()>0){                                        
           		Map<String,Reuters_Quotes__c> reuterMap = getReuterQuoteVal(FreightQuoteSet);
                for(Freight_Rate__c fr : onBeforeUpdateNew){
                   if(reuterMap.containskey(fr.Freight_Quotation__c)){
                   		fr.Marker__c = reuterMap.get(fr.Freight_Quotation__c).Price__c;
                   }
                }                                  
            }
            
            if(!freightRateMap.isEmpty()){
                
                   Map<String,Location_Steer_Metadata__mdt> mapOfSteerMetadata = mapOfLocationSteerMetadata(freightRateMap.keyset());
                   System.debug('%%%%%%mapOfSteerMetadata%%%%%'+mapOfSteerMetadata);  
                    
                   List<Location_Steer__c> fetchLocationSteerLst = [select id,Scenario_Value__c,productPlantScenarioKey__c
                                                                     from Location_Steer__c where productPlantScenarioKey__c in:mapOfSteerMetadata.keyset() ];//AND Source_Location__c = true
                   System.debug('%%%%%%fetchLocationSteerLst%%%%%'+fetchLocationSteerLst);
                   try{
                        update fetchLocationSteerLst;
                   }catch(Exception e){
                        System.debug('-------Exception--------'+e);
                   }
            }
                                                
           
                                                
    }
    public static void onAfterInsertHelper(List<Freight_Rate__c> onAfterInsertNew , 
                                            list<Freight_Rate__c> onAfterInsertOld){
                  List<String> freighRateIdLst = new List<String>();
                  for(Freight_Rate__c freightRate : onAfterInsertNew){
                      freighRateIdLst.add(freightRate.Id);
                  }
                  insertGroupMembersToGroup(freighRateIdLst);               
    }
    public static void onBeforeUpdateHelper(Map<Id,Freight_Rate__c> onBeforeUpdateNewMap , 
                                            Map<Id,Freight_Rate__c> onBeforeUpdateOldMap){
        //if(staticVal == true){
            
            //staticVal = false;
        
			     
            Set<String> FreightQuoteSet = new  Set<String>();
            for(Freight_Rate__c freightRate : onBeforeUpdateNewMap.values()){
               //Added By Dhriti
               /*PBI-437456-Lakshmi_04162020_starts
               List<String> split = freightRate.Name.split('_');
               if(String.isNotBlank(split[1])){
                	freightRate.supplier__c = split[1];
               }
                PBI-437456-Lakshmi_04162020_Ends*/
               if((onBeforeUpdateNewMap.get(freightRate.Id).Freight_Quotation__c <> onBeforeUpdateOldMap.get(freightRate.ID).Freight_Quotation__c ) ){
                  //  markerValueMap.put(freightRate.Freight_Quotation__c,freightRate);
                    FreightQuoteSet.add(freightRate.Freight_Quotation__c);
               }
                
            }
           
			
             if(FreightQuoteSet.size()>0){                                        
           		Map<String,Reuters_Quotes__c> reuterMap = getReuterQuoteVal(FreightQuoteSet);
                for(Freight_Rate__c fr : onBeforeUpdateNewMap.values()){
                   if(reuterMap.containskey(fr.Freight_Quotation__c)){
                   		fr.Marker__c = reuterMap.get(fr.Freight_Quotation__c).Price__c;
                        
                   }
                }                                  
            }
            
       // }
    }
    
     public static void onAfterUpdateHelper(Map<Id,Freight_Rate__c> onBeforeUpdateNewMap , 
                                            Map<Id,Freight_Rate__c> onBeforeUpdateOldMap){
        if(staticVal == true){
            
            staticVal = false;
        
            Map<String,Freight_Rate__c> freightRateMap = new Map<String,Freight_Rate__c>();
			 List<String> freighRateIdLst = new List<String>();
            for(Freight_Rate__c freightRate : onBeforeUpdateNewMap.values()){
                freighRateIdLst.add(freightRate.Id);
                if((onBeforeUpdateNewMap.get(freightRate.Id).Freight_rate_EUR_mt__c <> onBeforeUpdateOldMap.get(freightRate.ID).Freight_rate_EUR_mt__c ) ){
                   // freightRateMap.put(freightRate.Name,freightRate);
                    freightRateMap.put(freightRate.Backbone_Route_Name__c,freightRate);//Fix_493485_Lakshmi_27Apr2020
                    System.debug('freightRateMap'+freightRateMap.keyset());
                }
                
            }
             insertGroupMembersToGroup(freighRateIdLst); 
            
            if(!freightRateMap.isEmpty()){
                
                   Map<String,Location_Steer_Metadata__mdt> mapOfSteerMetadata = mapOfLocationSteerMetadata(freightRateMap.keyset());
                    System.debug('%%%%%%mapOfSteerMetadata%%%%%'+mapOfSteerMetadata);  
                    
                    List<Location_Steer__c> fetchLocationSteerLst = [select id,Scenario_Value__c,productPlantScenarioKey__c
                                                                     from Location_Steer__c where productPlantScenarioKey__c in:mapOfSteerMetadata.keyset() ];//AND Source_Location__c = true
                    System.debug('%%%%%%fetchLocationSteerLst%%%%%'+fetchLocationSteerLst);
                    try{
                        update fetchLocationSteerLst;
                    }catch(Exception e){
                        System.debug('-------Exception--------'+e);
                    }
            }
            
        }
    }
    
     // Creating Map of Key and Location steer Meta data
    // Key - Product sub Group + Plant Code + Scenario
    // Example - IGO 50ppm + D024 + Import
    public static Map<String,Location_Steer_Metadata__mdt> mapOfLocationSteerMetadata(Set<String> freightRateName){
        
        List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c  from Location_Steer_Metadata__mdt ];
        
        Map<String,Location_Steer_Metadata__mdt> locationSteerMap = new Map<String,Location_Steer_Metadata__mdt>();
        
        if(!locationSteerLst.isEmpty()){
            for(Location_Steer_Metadata__mdt locationSteerMeta : locationSteerLst){
                if(freightRateName.contains(locationSteerMeta.Route_1__c) || freightRateName.contains(locationSteerMeta.Route_2__c) ||
                  freightRateName.contains(locationSteerMeta.Differential_Value_1__c) || freightRateName.contains(locationSteerMeta.Differential_Value_2__c)){
                	locationSteerMap.put(locationSteerMeta.Product_Sub_Group__c + '-' + locationSteerMeta.Source__c + '-' + locationSteerMeta.Scenario__c , locationSteerMeta);
                }
            }
        }
        return locationSteerMap;
    }
    
   
    public static Map<String,Reuters_Quotes__c> getReuterQuoteVal(Set<String> freightRateQuote){
        System.debug('----------freightRateMap.keyset()-------'+freightRateQuote);
        List<Reuters_Quotes__c> mapOfReutersQuote = new List<Reuters_Quotes__c>();
        mapOfReutersQuote = [SELECT id,Name,Quote_Display_Name__c,Price__c from Reuters_Quotes__c where Quote_Display_Name__c
                             in:freightRateQuote order by LastModifiedDate DESC ];
        System.debug('----------mapOfReutersQuote-------'+mapOfReutersQuote);
        Map<String,Reuters_Quotes__c> mapOfReuter = new Map<String,Reuters_Quotes__c>();
        if(!mapOfReutersQuote.isEmpty()){
            for(Reuters_Quotes__c reuter : mapOfReutersQuote){
                if(!mapOfReuter.containskey(reuter.Quote_Display_Name__c)){
                    //reuter.Price__c = freightRateMap.get(reuter.Quote_Display_Name__c).Marker__c;
                    mapOfReuter.put(reuter.Quote_Display_Name__c,reuter);
                 
                }
            }
        }
        System.debug('%%%%%mapOfReuter%%%%%'+mapOfReuter);
		return mapOfReuter;
    }
    @future
    public static void insertGroupMembersToGroup(List<String> freighRateIdLst){
        List<Freight_Rate__c> freighRate = [SELECT id,Valid_To_Fomula__c,LastModifiedById from Freight_Rate__c where 
                                            Id in:freighRateIdLst AND Valid_To_Fomula__c = TODAY]; 
        List<Group> groupLst = [SELECT Id,DeveloperName FROM Group where DeveloperName = 'RV_LastModifiedByUserId'];
        List<GroupMember> addlistGroupMember =new List<GroupMember>(); 
        if(!freighRate.isEmpty()){
            for(Freight_Rate__c freightRate : freighRate){
                 GroupMember gm= new GroupMember(); 
                 gm.GroupId = groupLst.get(0).Id;
                 gm.UserOrGroupId = freightRate.LastModifiedById;
                 addlistGroupMember.add(gm);
            }
            if(!addlistGroupMember.isEmpty()){
                try{
                     insert addlistGroupMember;
                }catch(Exception e){
                        System.debug('-------Exception--------'+e);
                }       
            }
        }
    }
}