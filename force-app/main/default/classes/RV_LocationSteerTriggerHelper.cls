public class RV_LocationSteerTriggerHelper {

    //Added Boolean to Avoid Recursive Loop :Location Steer May Release
    public static boolean oneTimeRun = true;

    //LocationSteerPBI_Soumyajit_24Jul2019 starts
    public static map<String, Location_Steer__c> global_originSteerTriggerred = new map<String, Location_Steer__c>();
    public static map<String, Decimal> global_steerUpdatedValues = new map<String, Decimal>();
    public static list<Location_Steer__c> global_relatedSteerUpdLst = new list<Location_Steer__c>();
    public static Map<String,Location_Steer_Metadata__mdt> global_locationSteerMdt = new Map<String,Location_Steer_Metadata__mdt>();
    public static set<String> global_relatedSteerMdt = new set<String>();
    public static integer global_recurssionCnt = 0;
    public static Map<integer,String> global_relatedSteerUpdateOrder = new Map<integer,String>();
    //LocationSteerPBI_Soumyajit_24Jul2019 ends
    
    public static void onBeforeInsert(List<Location_Steer__c> onBeforeInsertNewLst){
        
		//LocationSteerPBI_Soumyajit_24Jul2019 starts
		System.debug('---------------------onBeforeInsert triggered------------------------' + onBeforeInsertNewLst);
		/*
         String orgRecordTypeId = fetchOriginationRecordType();
         updateOnOrginationCreate(onBeforeInsertNewLst,orgRecordTypeId);
		*/ 
		 //get Location steer Mdt
		if(global_locationSteerMdt.isEmpty())
			global_locationSteerMdt = mapOfLocationSteerMetadata();
		
        String orgRecordTypeId = fetchOriginationRecordType();
        String srcRecordTypeId = fetchSourceRecordType();
		
        List<Location_Steer__c> orginationList = new List<Location_Steer__c>();
        
        for(Location_Steer__c ls : onBeforeInsertNewLst)
        {
            if(ls.RecordTypeId == orgRecordTypeId)
            {
                orginationList.add(ls);
                global_originSteerTriggerred.put(ls.Origination_Steer_Type__c,ls);
            }
        }
		
		//if trigger is for origin steer
        if(orginationList.size()>0)
        	{
                System.debug('Going for orginationList' + orginationList);
                updateOnOrginationCreate(orginationList,orgRecordTypeId);
            }
        //LocationSteerPBI_Soumyajit_24Jul2019 ends
		
         putValidationRule(onBeforeInsertNewLst); // call this function to put all the validations
        
         calculateSteerVal(onBeforeInsertNewLst); //calculate CO steer value   

		 System.debug('---------------------onBeforeInsert updated------------------------' + onBeforeInsertNewLst);	//LocationSteerPBI_Soumyajit_24Jul2019
    }
    
    public static void onAfterInsert(List<Location_Steer__c> onAfterInsertNewLst){
        publishSteerEvent(onAfterInsertNewLst);
        
    }
    
    public static void publishSteerEvent(List<Location_Steer__c> onAfterInsertNewLst){
        List<RV_LocationSteerChange__e> locationSteerpublish = new List<RV_LocationSteerChange__e>();
        for(Location_Steer__c locationSteer : onAfterInsertNewLst){
            //if(daveMasterSet.contains(shtDaveMaster.Name)){
                System.debug('-----locationSteer-----'+locationSteer);
                RV_LocationSteerChange__e subscribeLocationSteerChange = new RV_LocationSteerChange__e();
                subscribeLocationSteerChange.Default__c = locationSteer.Default__c;
                subscribeLocationSteerChange.Depot_Steer_mt__c = locationSteer.Depot_Steer__c;
                subscribeLocationSteerChange.Manual_Adjustment_mt__c = locationSteer.Manual_Adjustment__c;
                subscribeLocationSteerChange.MOT__c = locationSteer.MOT__c;
                subscribeLocationSteerChange.Origination_Steer_Type__c = locationSteer.Origination_Steer_Type__c;
                subscribeLocationSteerChange.Plant_Code__c = locationSteer.Plant_Code__c;
            	subscribeLocationSteerChange.Plant_Name__c = locationSteer.Plant_Name__c;
            	subscribeLocationSteerChange.Product_Sub_Group__c = locationSteer.Product_Sub_Group__c;
            	subscribeLocationSteerChange.RecordId__c = locationSteer.Id;
            	subscribeLocationSteerChange.Scenario__c = locationSteer.Scenario__c;
            	subscribeLocationSteerChange.Scenario_Availability__c = locationSteer.Scenario_Availability__c;
            	subscribeLocationSteerChange.Source_Steer_mt__c = locationSteer.Source_Steer__c;
            	subscribeLocationSteerChange.Steer_Value_mt__c = locationSteer.Steer_Value__c;
            	subscribeLocationSteerChange.Valid_From__c = locationSteer.Valid_From__c;
            	subscribeLocationSteerChange.Valid_To__c = locationSteer.Valid_To__c;
            	locationSteerpublish.add(subscribeLocationSteerChange);
                //Database.SaveResult sr = EventBus.publish(subscribeLocationSteerChange);
            }
        	
        
        if(!locationSteerpublish.isEmpty()){
            	List<Database.SaveResult> results = EventBus.publish(locationSteerpublish);
			}
    }
    
    public static void updateOnOrginationCreate(List<Location_Steer__c> onBeforeInsertNewLst,String orgRecordTypeId){
        
        Map<String,Location_Steer__c> mapOfLocMap = new Map<String,Location_Steer__c>();

        for(Location_Steer__c locSteer : onBeforeInsertNewLst){
        
         
                if(orgRecordTypeId <> null){
                    //if(locSteer.RecordTypeId == orgRecordTypeId){
                         //Commented for Location Steer 0 Cal issue
                        //if(locSteer.Steer_Value__c <> 0 ){
                            mapOfLocMap.put(locSteer.Origination_Steer_Type__c,locSteer);
                        
                    //}
                }
         }
         if(!mapOfLocMap.isEmpty()){
             
             Map<String,Location_Steer_Metadata__mdt> fetchSteerVal = global_locationSteerMdt;//mapOfLocationSteerMetadata(); //LocationSteerPBI_Soumyajit_24Jul2019
             Map<String,Location_Steer_Metadata__mdt> locationSteerMap = new Map<String,Location_Steer_Metadata__mdt>();
             System.debug('---fetchSteerVal---'+fetchSteerVal);    
             if(!fetchSteerVal.isEmpty())
			 {
                 for(Location_Steer_Metadata__mdt locaSteer : fetchSteerVal.values())
				 {
                     if(mapOfLocMap.containskey(locaSteer.Origination_Steer_Type__c))
					 {
                           locationSteerMap.put(locaSteer.Product_Sub_Group__c + '-' + locaSteer.Source__c + '-' +
                                                locaSteer.Scenario__c , locaSteer);
					 }
                 }
             }
              System.debug('---locationSteerMap---'+locationSteerMap);   
			//updated query	- PBI728069_Dharam_11thMay2021		 
             List<Location_Steer__c> locationSteerLst = [select id,Scenario_Value__c,productPlantScenarioKey__c,Valid_To__c from Location_Steer__c
                                                     where productPlantScenarioKey__c in:locationSteerMap.keyset() and Valid_To__c >=: System.Today()];
             System.debug('---locationSteerLst---'+locationSteerLst);
             //LocationSteerPBI_Soumyajit_24Jul2019 starts
             if(locationSteerLst.size()>0)
             	global_relatedSteerUpdLst.addall(locationSteerLst);
             
			 //check dependant steer list
             getDependentSteers(locationSteerMap);
			
			 //Moved update into parent call
             /*if(!locationSteerLst.isEmpty()){
                 try{
                     //:Location Steer May Release
                     if(oneTimeRun){
                      oneTimeRun = false;
                         update locationSteerLst;
                        
                     }
                 }catch(Exception e){
                        System.debug('---------------'+e);     
                 }
             }*/
	         //LocationSteerPBI_Soumyajit_24Jul2019 ends
         }

    }
    
    public static void calculateSteerVal(List<Location_Steer__c> onBeforeInsertNewLst){

		System.Debug('calculateSteerVal:'+onBeforeInsertNewLst);
      	Set<Freight_Rate__c> freightsToUpdate = new Set<Freight_Rate__c>(); //to update Routes field if they are used in steer calculation PBI728069_Dharam_11thMay2021
        //:Location Steer May Release
        Map<String,Location_Steer_Metadata__mdt> locationSteerMetadatanewMap = global_locationSteerMdt;//mapOfLocationSteerMetadata(); //LocationSteerPBI_Soumyajit_24Jul2019
         Set<String> varSetData=new Set<String>();
        for(Location_Steer_Metadata__mdt s:locationSteerMetadatanewMap.Values()){
            if(s.Select_Co_Steer__c!=null && s.Select_Co_Steer__c!=''){
                System.Debug(s.Select_Co_Steer__c);            
                varSetData.add(s.Select_Co_Steer__c);
            }
           
        }
        
        Map<String,Decimal> selectSteerMap=getValueForCalculation(varSetData);
        System.Debug('selectSteerMap:'+selectSteerMap);
                
        Set<String> originationSteerTypeSet = new Set<String>();
        set<String> differentialSet1 = new set<String>();
        set<String> differentialSet2 = new set<String>();
        Map<String,Location_Steer_Metadata__mdt> locationSteerMetadatanewMapUpdate = new 
                      Map<String,Location_Steer_Metadata__mdt>();
        //added by swarna as part of PBI-1625464
        set<String> quoteName1Set1 = new set<String>();//added for weighing quotes
        set<String> quoteName2Set1 = new set<String>();//added for weighing quotes
        //end PBI-1625464
        
        for(Location_Steer__c locationSteer : onBeforeInsertNewLst){
            String keyToFetchMetadata = locationSteer.productPlantScenarioKey__c; // Generating the key
            if(locationSteerMetadatanewMap.containskey(keyToFetchMetadata)){ // If metadata contains the key
                locationSteerMetadatanewMapUpdate.put(keyToFetchMetadata,locationSteerMetadatanewMap.get(keyToFetchMetadata)); // generating new map for selected metadata records
                originationSteerTypeSet.add(locationSteerMetadatanewMap.get(keyToFetchMetadata).Origination_Steer_Type__c);
                differentialSet1.add(locationSteerMetadatanewMap.get(keyToFetchMetadata).Differential_Value_1__c);
                differentialSet2.add(locationSteerMetadatanewMap.get(keyToFetchMetadata).Differential_Value_2__c);
                //added by swarna as part of PBI-1625464
                quoteName1Set1.add(locationSteerMetadatanewMap.get(keyToFetchMetadata).Quote_Name1__c);
                quoteName2Set1.add(locationSteerMetadatanewMap.get(keyToFetchMetadata).Quote_Name2__c);
                //end PBI-1625464
            }
        }
       
        //added  by swarna as part of PBI-1625464
        List<Reuters_Quotes__c> fetchReutersQuoteLst_new = [select id,Quote_Display_Name__c,CurrencyCode__c,Price__c,Price_USD__c,LastModifiedDate from Reuters_Quotes__c where 
                                                        (Quote_Display_Name__c in:quoteName1Set1 OR Quote_Display_Name__c in:quoteName2Set1) 
                                                        order by LastModifiedDate DESC ];
        
        //end
        List<Reuters_Quotes__c> fetchConversionRateLst = [select id,Name,Price__c,Quote_Display_Name__c from 
                                                          Reuters_Quotes__c where Quote_Display_Name__c= 'EUR/USD' 
                                                          LIMIT 1];
        
        Decimal conversionRate = 0;
        if(!fetchConversionRateLst.isEmpty()){
            conversionRate = fetchConversionRateLst.get(0).Price__c;
        }
                
        Map<String,Reuters_Quotes__c> mapOfReuter = new Map<String,Reuters_Quotes__c>();
        
        //added by swarna as part of PBI-1625464

        if(!fetchReutersQuoteLst_new.isEmpty()){
            for(Reuters_Quotes__c reuters : fetchReutersQuoteLst_new){
                if(reuters.Quote_Display_Name__c <> null && !mapOfReuter.containskey(reuters.Quote_Display_Name__c)){
                        mapOfReuter.put(reuters.Quote_Display_Name__c,reuters);

                }
            }
        }
        //end
            
        Map<String,Freight_Rate__c> mapOfNameFreightRate = mapOfNameFreightRate(); // fetching freight Rate
        String OriginationRTID = fetchOriginationRecordType(); // fetching originationrecordTypeid
        Map<String,Location_Steer__c> mapOfOriginationLocationSteer = mapOfOriginNameLocationSteer(OriginationRTID,originationSteerTypeSet); // fetching origination Record Type records
        List<Location_Steer__c> sourceLocLst = fetchLocationSteer();
        Map<String,Location_Steer__c> mapOfSourcesteer = new Map<String,Location_Steer__c>();
        
        if(!sourceLocLst.isEmpty()){
            for(Location_Steer__c locationSteer : sourceLocLst){
                if(!mapOfSourcesteer.containsKey(locationSteer.productPlantScenarioKey__c)){
                    mapOfSourcesteer.put(locationSteer.productPlantScenarioKey__c,locationSteer);
                }
            }
        }
        
        //LocationSteerPBI_Soumyajit_24Jul2019 starts
		//sort the triggered list as per update order
        List<Location_Steer__c> sortedOnBeforeInsertNewLst = new List<Location_Steer__c>();
        map<String,Location_Steer__c> onBeforeInsertNewMap = new map<String,Location_Steer__c>();
		
        for(Location_Steer__c locationSteer : onBeforeInsertNewLst)
            onBeforeInsertNewMap.put(locationSteer.CoSteer_Formula__c,locationSteer);
        
        map<String,Location_Steer__c> onBeforeInsertNewMapDuplicate = onBeforeInsertNewMap.clone();
        
        for(Integer seq : global_relatedSteerUpdateOrder.keySet())
        {
            if(onBeforeInsertNewMap.containskey(global_relatedSteerUpdateOrder.get(seq)))
            {
                System.debug('Sorting for '+ global_relatedSteerUpdateOrder.get(seq));
                sortedOnBeforeInsertNewLst.add(onBeforeInsertNewMap.get(global_relatedSteerUpdateOrder.get(seq)));
                onBeforeInsertNewMapDuplicate.remove(global_relatedSteerUpdateOrder.get(seq));
            }
        }
		
		//If no order found for the rest, add them to the end
        if(onBeforeInsertNewMapDuplicate.size()>0)
            sortedOnBeforeInsertNewLst.addAll(onBeforeInsertNewMapDuplicate.values());
        
        //for(Location_Steer__c locationSteer : onBeforeInsertNewLst){
        for(Location_Steer__c locationSteer : sortedOnBeforeInsertNewLst){
        //LocationSteerPBI_Soumyajit_24Jul2019 ends
		
            String keyToFetchMetadata = locationSteer.productPlantScenarioKey__c; // Generating the key
            Decimal originationSteerVal=0;
            Decimal route1=0;
            Decimal route2=0;
            
            if(locationSteerMetadatanewMapUpdate.containskey(keyToFetchMetadata) && locationSteer.Source_Location__c == true ){
                
                 Location_Steer_Metadata__mdt metadataVal = locationSteerMetadatanewMapUpdate.get(keyToFetchMetadata);
                 if(mapOfOriginationLocationSteer.containskey(metadataVal.Origination_Steer_Type__c)){
                     //LocationSteerPBI_Soumyajit_24Jul2019 starts
					 //check, if value is present in triggered list
                     if(global_originSteerTriggerred.containsKey(metadataVal.Origination_Steer_Type__c))
                         originationSteerVal = global_originSteerTriggerred.get(metadataVal.Origination_Steer_Type__c).Steer_Value__c;
                     else
                     //LocationSteerPBI_Soumyajit_24Jul2019 ends
                     	originationSteerVal = mapOfOriginationLocationSteer.get(metadataVal.Origination_Steer_Type__c).Steer_Value__c;
                 }
                 //:Location Steer May Release
                else if(metadataVal.Select_CO_Steer__c <> null){
                    //LocationSteerPBI_Soumyajit_24Jul2019 starts
                    //originationSteerVal =selectSteerMap.get(metadataVal.Select_CO_Steer__c);
					//check, if value is present in triggered list
                    if(global_steerUpdatedValues.containsKey(metadataVal.Select_CO_Steer__c))
                        originationSteerVal = global_steerUpdatedValues.get(metadataVal.Select_CO_Steer__c);
                    else
                    {
                        if(selectSteerMap.containskey(metadataVal.Select_CO_Steer__c))
                            originationSteerVal =selectSteerMap.get(metadataVal.Select_CO_Steer__c);
                        else
                            originationSteerVal =0;
                    }
                    //LocationSteerPBI_Soumyajit_24Jul2019 ends
                    
                    System.Debug('originationSteerVal :'+originationSteerVal );              
                 }
                /*----logic to consider route value in case invalid Freight Rate records used in 
						Steer Calculation field -- PBI728069_Dharam_11thMay2021*/
                
                //added by swarna as part of PBI-1625464
                Decimal quoteweightage = 0;
                Decimal quoteweightage2 = 0;
                if(mapOfReuter.containsKey(metadataVal.Quote_Name1__c)){
                    system.debug('q1::'+mapOfReuter.get(metadataVal.Quote_Name1__c));
                    Reuters_Quotes__c reuterData = mapOfReuter.get(metadataVal.Quote_Name1__c);
                    quoteweightage = reuterData.Price__c;
                }else if(mapOfNameFreightRate.containskey(metadataVal.Quote_Name1__c)){
                    //route1
                    quoteweightage = mapOfNameFreightRate.get(metadataVal.Quote_Name1__c).Freight_rate_EUR_mt__c;
                    mapOfNameFreightRate.get(metadataVal.Quote_Name1__c).Rv_Required_for_Scenario_Calculation__c = True;
                    freightsToUpdate.add(mapOfNameFreightRate.get(metadataVal.Quote_Name1__c));
                }else{
                    //route1
                    quoteweightage = Decimal.valueOf(Label.Rv_Invalid_route_value);
                }

                if(mapOfReuter.containsKey(metadataVal.Quote_Name2__c)){
                    system.debug('q2::'+mapOfReuter.get(metadataVal.Quote_Name2__c));
                    Reuters_Quotes__c reuterData = mapOfReuter.get(metadataVal.Quote_Name2__c);
                    quoteweightage2 = reuterData.Price__c;
                }else if(mapOfNameFreightRate.containskey(metadataVal.Quote_Name2__c)){
                    //route2
                    quoteweightage2 = mapOfNameFreightRate.get(metadataVal.Quote_Name2__c).Freight_rate_EUR_mt__c;
                    mapOfNameFreightRate.get(metadataVal.Quote_Name2__c).Rv_Required_for_Scenario_Calculation__c = True;
                    freightsToUpdate.add(mapOfNameFreightRate.get(metadataVal.Quote_Name2__c));
                }else{
                    //route2
                    quoteweightage2 = Decimal.valueOf(Label.Rv_Invalid_route_value);
                }

                //end
                Decimal factorRoute1 =0;
                Decimal factorRoute2 =0;
                if(metadataVal.Factor_Route_1__c <> 0){
                    factorRoute1 = metadataVal.Factor_Route_1__c;
                }
                if(metadataVal.Factor_Route_2__c <> 0){
                    factorRoute2 = metadataVal.Factor_Route_2__c;
                }
                //added by swarna as part of PBI-1625464
                if(quoteweightage == null){
                    quoteweightage = 0;
                }
                if(quoteweightage2 == null){
                    quoteweightage2 = 0;
                }
                //end
                if(route1 == null){
                    route1 = 0;
                }
                if(route2 == null){
                    route2 = 0;
                }
                //added by swarna as part of PBI-1625464
                decimal wwp1 = 0;
                decimal wwp2 = 0;
                if(metadataVal.Weighting_of_Quote1__c != null &&  metadataVal.Weighting_of_Quote1__c <> 0){
                    wwp1 = metadataVal.Weighting_of_Quote1__c/100;
                }
                if(metadataVal.Weighting_of_Quote2__c != null &&  metadataVal.Weighting_of_Quote2__c <> 0){
                    wwp2 = metadataVal.Weighting_of_Quote2__c/100;
                }
                decimal quotageValue =((wwp1 * quoteweightage) - (wwp2 * quoteweightage2));
		if(metadataVal.NoWeightage__c){
                    quotageValue = 0;
                }
                if(locationSteer.Scenario__c == 'Export' && quotageValue >= 0){
                    locationSteer.Scenario_Value__c = originationSteerVal + (-1 * quotageValue);
               }
                else {
                    locationSteer.Scenario_Value__c = originationSteerVal + (1 * quotageValue);
                }
               //end
                //LocationSteerPBI_Soumyajit_24Jul2019 starts
                System.debug('ID='+locationSteer.id);                
                System.debug('factorRoute1='+factorRoute1+',route1='+route1+',factorRoute2='+factorRoute2+',route2='+route2);
                System.debug('Scenario_Value__c='+locationSteer.Scenario_Value__c);
                
				//if the value has changed, then store it for next use
                if(locationSteer.CoSteer_Formula__c !=null && locationSteer.Scenario_Value__c!=null && locationSteer.Manual_Adjustment__c!=null)
                    global_steerUpdatedValues.put(locationSteer.CoSteer_Formula__c,locationSteer.Scenario_Value__c+locationSteer.Manual_Adjustment__c);
                //LocationSteerPBI_Soumyajit_24Jul2019 ends
             }
        }
        /*----: updating Freight_Rate__c records which are used in steer calculations
			PBI728069_Dharam_11thMay2021	:----*/
        List<Freight_Rate__c> freightListUpdate = new List<Freight_Rate__c>();
        if(freightsToUpdate.size() > 0){
                freightListUpdate.addAll(freightsToUpdate);
        }
        if(freightListUpdate.size() >0){
            Update freightListUpdate;	
        }
       	
    }
    
    public static void onBeforeUpdate(List<Location_Steer__c> onBeforeUpdateNewLst){
        
		//LocationSteerPBI_Soumyajit_24Jul2019 starts
        System.debug('---------------------onBeforeUpdate triggered------------------------' + onBeforeUpdateNewLst);
        //get Location steer Mdt
		if(global_locationSteerMdt.isEmpty())
			global_locationSteerMdt = mapOfLocationSteerMetadata();
			
        // String orgRecordTypeId = fetchOriginationRecordType();
        //LocationSteerPBI_Soumyajit_24Jul2019 ends
		
         putValidationRule(onBeforeUpdateNewLst); // call this function to put all the validations
        
         calculateSteerVal(onBeforeUpdateNewLst); //calculate CO steer value 
        publishSteerEvent(onBeforeUpdateNewLst);//added as part of Select CO steer dependency
        System.debug('---------------------onBeforeUpdate updated--------------------------' + onBeforeUpdateNewLst); //LocationSteerPBI_Soumyajit_24Jul2019
    }
    
    public static void onAfterUpdate(List<Location_Steer__c> onBeforeUpdateNewLst){
        //LocationSteerPBI_Soumyajit_24Jul2019 starts
		System.debug('---------------------onAfterUpdate triggered-------------------------' + onBeforeUpdateNewLst);
		
        /*
		String orgRecordTypeId = fetchOriginationRecordType();
        updateOnOrginationCreate(onBeforeUpdateNewLst,orgRecordTypeId);
        */
		
		//get Location steer Mdt
		if(global_locationSteerMdt.isEmpty())
			global_locationSteerMdt = mapOfLocationSteerMetadata();
		
        String depotRTId = fetchDepotRecordType();
        String orgRecordTypeId = fetchOriginationRecordType();
        String srcRecordTypeId = fetchSourceRecordType();
		
        List<Location_Steer__c> depotSteerList = new List<Location_Steer__c>();
        List<Location_Steer__c> orginationList = new List<Location_Steer__c>();
        List<Location_Steer__c> srcList = new List<Location_Steer__c>();
        
        for(Location_Steer__c ls : onBeforeUpdateNewLst)
        {
            if(ls.RecordTypeId == depotRTId){
                depotSteerList.add(ls);
            }
            if(ls.RecordTypeId == orgRecordTypeId)
            {
                orginationList.add(ls);
                global_originSteerTriggerred.put(ls.Origination_Steer_Type__c,ls);
            }
            if(ls.RecordTypeId == srcRecordTypeId)
            {
                srcList.add(ls);
            }
        }
		if(depotSteerList.size()>0 && oneTimeRun){
            publishSteerEvent(onBeforeUpdateNewLst);
        }
		//if trigger is for origin steer
        if(orginationList.size()>0 && oneTimeRun)
        	{
                publishSteerEvent(onBeforeUpdateNewLst);
                System.debug('Going for orginationList' + orginationList);
                updateOnOrginationCreate(orginationList,orgRecordTypeId);
            }
        
		//if trigger is for source steer
		// removed oneTimeRun from condition for two stage scenario 'CO Steer' refresh_Dharam_17thMay2021_PBI728069
        if(srcList.size()>0)
        	{
                publishSteerEvent(onBeforeUpdateNewLst);
                System.debug('Going for srcList' + srcList);
                
             	Map<String,Location_Steer_Metadata__mdt> locationSteerMap = new Map<String,Location_Steer_Metadata__mdt>();
                for(Location_Steer__c sls :srcList)
                {
                    if(global_locationSteerMdt.containskey(sls.productPlantScenarioKey__c))
                    {
                        locationSteerMap.put(sls.productPlantScenarioKey__c, 
							global_locationSteerMdt.get(sls.productPlantScenarioKey__c));
                    }
                }
                
				if(locationSteerMap.size()>0)
                	getDependentSteers(locationSteerMap);
            }
        
		//update dependent steers, if present
        if(global_relatedSteerUpdLst.size()>0 && oneTimeRun)
        {
        	try{
				oneTimeRun = false;
                update global_relatedSteerUpdLst;
                 }catch(Exception e){
                        System.debug('---------------'+e);     
                 }
        }
		
		System.debug('---------------------onAfterUpdate updated----------------------------' + onBeforeUpdateNewLst);
        //LocationSteerPBI_Soumyajit_24Jul2019 ends
    }
    
    // Creating Map of Key and Location Steer
    // Key - Origination steer type
    // Example - ARA PBH AGO Steer    
    public static Map<String,Location_Steer__c> mapOfOriginNameLocationSteer(String OriginationRTID,Set<String> originationSteerTypeSet){
        
        List<Location_Steer__c> locationSteerLst = [select id,Default__c,Steer_Value__c,Origination_Steer_Type__c from Location_Steer__c 
                                                    where RecordTypeId=:OriginationRTID];
        
        Map<String,List<Location_Steer__c>> mapOfOriginationSteer = new Map<String,List<Location_Steer__c>>();
        Map<String,Location_Steer__c> originationSteerMap = new Map<String,Location_Steer__c>();
            
        if(!locationSteerLst.isEmpty()){
            
            for(Location_Steer__c locationSteer : locationSteerLst){
                
                if(!mapOfOriginationSteer.containskey(locationSteer.Origination_Steer_Type__c)){
                    mapOfOriginationSteer.put(locationSteer.Origination_Steer_Type__c,new List<Location_Steer__c>{locationSteer} );
                }else{
                
                  List<Location_Steer__c> orgList = mapOfOriginationSteer.get(locationSteer.Origination_Steer_Type__c);
                    orgList.add(locationSteer);
                    mapOfOriginationSteer.put(locationSteer.Origination_Steer_Type__c , orgList);
                }   
            }
            
             
            if(!mapOfOriginationSteer.isEmpty()){
                
                for(String locationSteer : mapOfOriginationSteer.keyset()){
                    List<Location_Steer__c> fetchOrgLocStr = mapOfOriginationSteer.get(locationSteer);
                    if(fetchOrgLocStr.size() > 1 && fetchOrgLocStr <> null){
                        for(Location_Steer__c loc :fetchOrgLocStr){
                            if(loc.Default__c == false){
                                originationSteerMap.put(locationSteer,loc);
                            }
                        }
                    }else{
                        if(fetchOrgLocStr.get(0).Default__c == true){
                           originationSteerMap.put(locationSteer,fetchOrgLocStr.get(0));
                        }
                    }
                }
            }
            
        }
        return originationSteerMap;
    }
    
     // Creating Map of Key and freight Rate
    // Key - Name
    // Example - IGO-50_Shell_ARA_Barge_Godorf  
    public static Map<String,Freight_Rate__c> mapOfNameFreightRate(){
        
        
        //List<Freight_Rate__c> fetchFreightRateLst = [select id,Name,Freight_rate_EUR_mt__c from Freight_Rate__c];
        //Modified filter to fetch only valid records PBI728069_Dharam_11thMay2021
        List<Freight_Rate__c> fetchFreightRateLst = [select id,Name,Backbone_Route_Name__c,Valid_To__c,Valid_From__c,
                                              		Freight_rate_EUR_mt__c from Freight_Rate__c 
                                                    WHERE Valid_To__c >=: System.Today()
                                                    AND Valid_From__c <=: System.Today()]; //Fix_493485_Lakshmi_27Apr2020
        Map<String,Freight_Rate__c> mapFONameFreight = new Map<String,Freight_Rate__c>();
        System.debug('---fetchFreightRateLst---'+fetchFreightRateLst);
        if(!fetchFreightRateLst.isEmpty()){
            
            for(Freight_Rate__c freight : fetchFreightRateLst){
                //mapFONameFreight.put(freight.Name, freight);
                mapFONameFreight.put(freight.Backbone_Route_Name__c, freight);//Fix_493485_Lakshmi_27Apr2020
            }
        }
        
        return mapFONameFreight;
        
    }
    
    // Creating Map of Key and Location steer Meta data
    // Key - Product sub Group + Plant Code + Scenario
    // Example - IGO 50ppm + D024 + Import
    public static Map<String,Location_Steer_Metadata__mdt> mapOfLocationSteerMetadata(){
        
        List<Location_Steer_Metadata__mdt> locationSteerLst = [select id,MasterLabel,DeveloperName,Factor_Route_1__c,Factor_Route_2__c,Origination_Steer_Type__c,Select_CO_Steer__c,
                                                               Plant_Code__c,Product_Sub_Group__c,Route_1__c,Route_2__c,Scenario__c,Source__c,Differential_Value_1__c ,
                                                               Differential_Value_2__c,Quote_Name1__c, Quote_Name2__c, Weighting_of_Quote1__c, Weighting_of_Quote2__c, NoWeightage__c  from Location_Steer_Metadata__mdt];
        
        Map<String,Location_Steer_Metadata__mdt> locationSteerMap = new Map<String,Location_Steer_Metadata__mdt>();
        
        if(!locationSteerLst.isEmpty()){
            for(Location_Steer_Metadata__mdt locationSteerMeta : locationSteerLst){
              
                locationSteerMap.put(locationSteerMeta.Product_Sub_Group__c + '-' + locationSteerMeta.Source__c +
                                     '-' + locationSteerMeta.Scenario__c , locationSteerMeta);
            }
        }
        return locationSteerMap;
    }
    
    public static void putValidationRule(List<Location_Steer__c> onAfterInsertNewLst){
       
        
        String depotRTId = fetchDepotRecordType();
        String sourceRTID = fetchSourceRecordType();
        String OriginationRTID = fetchOriginationRecordType();
        Set<String> plantCodeSet = new Set<String>();
        Set<String> productsubGroupSet = new Set<String>();
        Set<String> locationSteerId = new Set<String>();
        for(Location_Steer__c locationSteer : onAfterInsertNewLst){
            locationSteerId.add(locationSteer.Id);
            if(locationSteer.RecordTypeId == sourceRTID){

                if(locationSteer.Scenario__c <> null){
                    
                    if(locationSteer.Scenario_Availability__c <> null){
                        
                        if(!locationSteer.Scenario_Availability__c.contains(locationSteer.Scenario__c)){
                            
                            locationSteer.addError('Scenario Availability not matching!');
                        }
                    }else{
                           locationSteer.addError('Scenario is not Available for this plant!');
                    }
                }
            }
            
            if(locationSteer.RecordTypeId == depotRTId){

                if(locationSteer.MOT__c <> null){
                    
                    if(locationSteer.MOT_Availability__c <> null){

                        if(!locationSteer.MOT_Availability__c.contains(locationSteer.MOT__c)){
                            
                            locationSteer.addError('MOT Availability not matching!');
                        }
                    }else{
                           locationSteer.addError('MOT not Available for this plant!');
                    }
                }
            }
            
            if(locationSteer.Product_Sub_Group__c <> null){
                if(locationSteer.Product_Sub_Group_Availability__c <> null){
                    
                    if(!locationSteer.Product_Sub_Group_Availability__c.contains(locationSteer.Product_Sub_Group__c)){
                        
                        locationSteer.addError('Product Sub Group Availability not matching!');
                    }
                }else{
                        locationSteer.addError('Product Sub Group not Availabe for this plant!');
                }
            }
            
            productsubGroupSet.add(locationSteer.Product_Sub_Group__c);
            plantCodeSet.add(locationSteer.Plant_Code__c);
                
        }
        //FIX_PBI_574959_Lakshmi_25Aug2020
        //Modified filter to pick Steer data based on valid to date PBI791818_Dharam_11thMay2021
        List<Location_Steer__c> locationSteerLst = [select id,Product_Sub_Group__c,Plant_Code__c,RecordTypeId,Valid_From__c,Valid_To__c,MOT__c, 
                                                    Depot_Steer_Override_Start_Date__c,Depot_Steer_Override_mt__c,Default__c 
                                                    from Location_Steer__c where 
                                                    Product_Sub_Group__c in:productsubGroupSet 
                                                    AND Plant_Code__c in:plantCodeSet AND Default__c= false  AND Valid_To__c >= : System.today()];         
        Map<String,List<Location_Steer__c>> KeyValMap      = new Map<String,List<Location_Steer__c>>();
        Map<String,List<Location_Steer__c>> KeyValMapDepot = new Map<String,List<Location_Steer__c>>();
        
        
        if(!locationSteerLst.isEmpty()){
            
            for(Location_Steer__c locationSteer : locationSteerLst){
                
                if(!locationSteerId.contains(locationSteer.Id)){
                    
                    String keyVal = locationSteer.RecordTypeId + '-' + locationSteer.Product_Sub_Group__c + '-' + locationSteer.Plant_Code__c;
                    //Fix_PBI-552203-Lakshmi_20thJuly2020
                    String keydepotVal = locationSteer.RecordTypeId + '-' + locationSteer.Product_Sub_Group__c + '-' + locationSteer.Plant_Code__c + '-' + locationSteer.MOT__c;
                    if(locationSteer.RecordTypeId == sourceRTID){
                        
                        if(!KeyValMap.containskey(keyVal)){
                            KeyValMap.put(keyVal, new List<Location_Steer__c>{locationSteer});
                        }else{
                            List<Location_Steer__c> newLocationSteerList = KeyValMap.get(keyVal);
                            newLocationSteerList.add(locationSteer);
                            KeyValMap.put(keyVal , newLocationSteerList);
                        }
                        
                    }
                    if(locationSteer.RecordTypeId == depotRTId){
                        //Fix_PBI-552203-Lakshmi_20thJuly2020_Starts
                       /*if(!KeyValMapDepot.containskey(keyVal)){
                            KeyValMapDepot.put(keyVal, new List<Location_Steer__c>{locationSteer});
                        }else{
                            List<Location_Steer__c> newLocationSteerList = KeyValMapDepot.get(keyVal);
                            newLocationSteerList.add(locationSteer);
                            KeyValMapDepot.put(keyVal , newLocationSteerList);
                        }*/
                        if(!KeyValMapDepot.containskey(keydepotVal)){
                            KeyValMapDepot.put(keydepotVal, new List<Location_Steer__c>{locationSteer});
                        }else{
                            List<Location_Steer__c> newLocationSteerList = KeyValMapDepot.get(keydepotVal);
                            newLocationSteerList.add(locationSteer);
                            KeyValMapDepot.put(keydepotVal , newLocationSteerList);
                        }
                        //Fix_PBI-552203-Lakshmi_20thJuly2020_ends
                    }
                }
            }
        }
        
        for(Location_Steer__c locationStr : onAfterInsertNewLst){
            
            if(locationStr.RecordTypeId == sourceRTID){
                
                String plantcodeProductKey =  locationStr.RecordTypeId + '-' + locationStr.Product_Sub_Group__c + '-' + locationStr.Plant_Code__c ;
               
                if(KeyValMap.containskey(plantcodeProductKey)){
                          
                    List<Location_Steer__c> locationSteerVal = KeyValMap.get(plantcodeProductKey);
                    for(Location_Steer__c locationSteer : locationSteerVal){
                            //add logic to exclude 'default' steer records from validation_PBI791818_Dharam_11thMay2021
                            if(((locationStr.Default__c == False) || (locationSteer.Default__c == False)) && ((locationStr.Valid_From__c >= locationSteer.Valid_From__c && locationStr.Valid_From__c <= locationSteer.Valid_To__c) ||
                              (locationStr.Valid_To__c >= locationSteer.Valid_From__c && locationStr.Valid_To__c <= locationSteer.Valid_To__c))){
                                
                                locationStr.addError('Cannot put overlapping date');
                            }
                    }
                    
                }
            }
            
            if(locationStr.RecordTypeId == depotRTId){
                //Fix_PBI-552203-Lakshmi_20thJuly2020
                //String plantcodeProductKey =  locationStr.RecordTypeId + '-' + locationStr.Product_Sub_Group__c + '-' + locationStr.Plant_Code__c ;
                String plantcodeProductMOTKey =  locationStr.RecordTypeId + '-' + locationStr.Product_Sub_Group__c + '-' + locationStr.Plant_Code__c + '-' + locationStr.MOT__c;
                if(KeyValMapDepot.containskey(plantcodeProductMOTKey)){
                    
                    List<Location_Steer__c> locationSteerVal = KeyValMapDepot.get(plantcodeProductMOTKey);
                    for(Location_Steer__c locationSteer : locationSteerVal){
                        //add logic to exclude 'default' steer records from validation_PBI791818_Dharam_11thMay2021
                        if(((locationStr.Default__c == False) || (locationSteer.Default__c == False)) && ((locationStr.Valid_From__c >= locationSteer.Valid_From__c && locationStr.Valid_From__c <= locationSteer.Valid_To__c) ||
                              (locationStr.Valid_To__c >= locationSteer.Valid_From__c && locationStr.Valid_To__c <= locationSteer.Valid_To__c))){
                            
                            locationStr.addError('Cannot put overlapping date');
                        }
                    }
                    //FIX_PBI_574959_Lakshmi_25Aug2020_Starts
                    for(Location_Steer__c locationSteer : locationSteerVal){
                        if((locationStr.Depot_Steer_Override_Start_Date__c >= locationSteer.Valid_From__c && locationStr.Depot_Steer_Override_Start_Date__c <= locationSteer.Valid_To__c))
                           {
                            
                            locationStr.addError('Cannot put overlapping Override Start date');
                        }
                    }
                    //FIX_PBI_574959_Lakshmi_25Aug2020_Ends
                }
            }
            
        }
    
    }
    
    public static String fetchDepotRecordType(){
        String depotRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
        return depotRecordTypeId;
    }
    
    public static String fetchSourceRecordType(){
        String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        return sourceRecordTypeId;
    }
    
    public static String fetchOriginationRecordType(){
        String orgRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Origination Steer').getRecordTypeId();
        return orgRecordTypeId;
    }
    
    public static List<Location_Steer__c> fetchLocationSteer(){
        String sourceSteerId = fetchSourceRecordType();
        return [select id,productPlantScenarioKey__c,Scenario_Value__c from Location_Steer__c where 
                RecordTypeId=:sourceSteerId ORDER BY lastModifiedDate];
    }
    
     //Method Added for Scenario logic: Review CO steer Mogas Issue
    public static Map<String,Decimal> getValueForCalculation(Set<String> varSet){
        System.Debug('var Set here :'+varSet);
        Map<String,Decimal> mapToCalculate=new Map<String,Decimal>();
        if(varSet!=null ){
            List<Location_Steer__c> locSteer=[Select Id,Source_Steer__c,CoSteer_Formula__c ,productPlantScenarioKey__c from Location_Steer__c where RecordType.Name='Source Steer' and CoSteer_Formula__c In:varSet];
            System.debug('locSteer:'+locSteer);
	    for(Location_Steer__c l:locSteer){            
                mapToCalculate.put(l.CoSteer_Formula__c ,l.Source_Steer__c);             
        
            }
            System.Debug('mapToCalculate:'+mapToCalculate);
        }
        return mapToCalculate;
    }
    
 //LocationSteerPBI_Soumyajit_24Jul2019 starts
 	public static void getDependentSteers (Map<String,Location_Steer_Metadata__mdt> locationSteerMap)
    {
			//get all dependent mdt steers recurssively
			global_recurssionCnt = 0;
            getDependentSteersRecurssive(locationSteerMap);
             
             if(global_relatedSteerMdt.size()>0)
             {
                 System.debug('complete relatedSteerMdt = '+global_relatedSteerMdt);
                 System.debug('Update order = ' + global_relatedSteerUpdateOrder);
                 
				 //find steer rows and assign to update list
                 List<Location_Steer__c> relatedSteerLst = [select id,Scenario_Value__c,productPlantScenarioKey__c from Location_Steer__c
                                                         where productPlantScenarioKey__c in:global_relatedSteerMdt];
                 
                 System.debug('relatedSteerLst = '+relatedSteerLst);
                 if(relatedSteerLst.size()>0)
                 {
                     for(Location_Steer__c ls : relatedSteerLst)
                     {
                         if(!global_relatedSteerUpdLst.contains(ls))
                         	global_relatedSteerUpdLst.add(ls);
                     }
                 }
             }
    }
    
    public static void getDependentSteersRecurssive (Map<String,Location_Steer_Metadata__mdt> locationSteerMap)
    {
				global_recurssionCnt++;
				
				//get dependent mdt
				Set<String> relatedSteerMdtSet = new Set<String>();
                for(String mdt : locationSteerMap.keyset())
                 {
                     String setkey = locationSteerMap.get(mdt).Product_Sub_Group__c + '-' + locationSteerMap.get(mdt).Source__c;
                     if(!relatedSteerMdtSet.contains(setkey))
                        relatedSteerMdtSet.add(setkey);
                 }
                System.debug('relatedSteer '+ global_recurssionCnt + ' = '+relatedSteerMdtSet);
        
				//set  mdt update order
        		Set<String> global_relatedSteerUpdateOrderValues = new Set<String>();
        		global_relatedSteerUpdateOrderValues.addall(global_relatedSteerUpdateOrder.values());
        		for(String mdt : relatedSteerMdtSet)
                {
                    if(!global_relatedSteerUpdateOrder.containsKey(global_recurssionCnt) && !global_relatedSteerUpdateOrderValues.contains(mdt))
                    	global_relatedSteerUpdateOrder.put(global_recurssionCnt,mdt);
                    else
                        global_relatedSteerUpdateOrder.put(global_relatedSteerUpdateOrder.size()+1,mdt);
                }
                 
				 //set realted steer mdt and look for next level dependancy
                 Map<String,Location_Steer_Metadata__mdt> relatedSteerMdt = new Map<String,Location_Steer_Metadata__mdt>();
                 if(!global_locationSteerMdt.isEmpty())
                 {
                     for(Location_Steer_Metadata__mdt locaSteer : global_locationSteerMdt.values())
                     {
                       String setkey = locaSteer.Select_CO_Steer__c;
                       if(setkey != null)
                       {
                           if(relatedSteerMdtSet.contains(setkey))
                           	{
                                String mdtKey = locaSteer.Product_Sub_Group__c + '-' + locaSteer.Source__c + '-' + locaSteer.Scenario__c;
                                relatedSteerMdt.put(mdtKey, locaSteer);
								
                            	if(!global_relatedSteerMdt.contains(mdtKey))
                                    global_relatedSteerMdt.add(mdtKey);
                            }
                       }
                     }
                 }
                 
				 //if next level dependancy is present, do recurssion again
                 if(relatedSteerMdt.size()>0)
                    getDependentSteersRecurssive(relatedSteerMdt);
    }
   //LocationSteerPBI_Soumyajit_24Jul2019 ends
   
    //169496_Soumyajit_11May2020 starts
    @InvocableMethod(label='Recalculate All Source Steers' description='Recalculate All Available Source Steers & dummy update if required')
    public static void recalcAllSourceSteers()
    {
        System.debug('---recalcAllSourceSteers triggered---');
        recalcSourceSteers();
    }
    
    @future(callout=true)
    public static void recalcSourceSteers()
    {
        System.debug('---recalcSourceSteers starts---');
        try{
        oneTimeRun = true;
        String srcRecordType = fetchSourceRecordType();
        String qry =   'SELECT Id, Name, RecordTypeId, Default__c, Depot_Steer__c, Location_Abbreviated_Name__c,' 
                     + 'MOT_Availability__c, MOT__c, Manual_Adjustment__c, Origination_Steer_Type__c, PlantGradeUnq__c,' 
                     + 'Plant_Code__c, Plant_Name__c, Plant__c, Product_Sub_Group_Availability__c, '
                     + 'Product_Sub_Group__c, Scenario_Availability__c, Scenario_Value__c, Scenario__c, '
                     + 'Source_Location__c, Source_Steer__c, Steer_Value__c, Valid_From__c, Valid_To__c, '
                     + 'productPlantScenarioKey__c, CoSteer_Formula__c, Manual_Adjustment_Override_Start_Date__c, '
                     + 'Manual_Adjustment_Override__c, Override_Scenario__c '
                     + 'FROM Location_Steer__c '
                     + 'where RecordTypeId= :srcRecordType';
        map<id,Location_Steer__c> steerRecalcMap = new map<id,Location_Steer__c>((Location_Steer__c[])Database.query(qry));
        if(global_locationSteerMdt.isEmpty())
			global_locationSteerMdt = mapOfLocationSteerMetadata();
        
        if(steerRecalcMap.size()>0)
        {
            calculateSteerVal(steerRecalcMap.values());
            map<id,Location_Steer__c> steerExistingMap = new map<id,Location_Steer__c>((Location_Steer__c[])Database.query(qry));
            
            List<Location_Steer__c> updSteerLst = new List<Location_Steer__c>();
            
            for(Id keyId : steerExistingMap.keySet())
            {
                if(steerRecalcMap.containsKey(keyId))
                {
                    if(steerRecalcMap.get(keyId).Scenario_Value__c != steerExistingMap.get(keyId).Scenario_Value__c)
                        updSteerLst.add(steerExistingMap.get(keyId));
                }
            }
            
            if(updSteerLst.size()>0)
            {
                try{
                    System.debug('---Found Steers to Update----');
                    for(Location_Steer__c l : updSteerLst)
                        System.debug(l);
                	update updSteerLst;
                }
                 catch(Exception e)
                 {System.debug('Error during upsert' + e);}
            }
        }
        System.debug('---recalcSourceSteers ends---');
        }
        catch(Exception e)
        {System.debug('Error during recalc' + e);}
    }
    //169496_Soumyajit_11May2020 ends
}