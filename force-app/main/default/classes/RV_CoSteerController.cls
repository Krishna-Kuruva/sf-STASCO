public class RV_CoSteerController {
    
    @AuraEnabled 
    public static plantSteerWrapper getLocationSteer(String srcStrGrade,String depStrGrade,
                                                     String depMot,String depPlant,
                                                     Boolean plantOverriden,String contractDate){
         date contractStartDate;                                           
        if(contractDate == null){
            contractStartDate=System.today();
        }else{
             contractStartDate=date.valueOf(contractDate);
        }  
        List<String> plantLst= new List<String>();
        List<Location__c> locLst= new List<Location__c>([select id,name from Location__C where Source_Location__c= false and Abbreviated_Name__c != null order by name]);
        for(Location__c loc:locLst){
            plantLst.add(loc.name);
        }
        //Map<String,Map<String,backboneaccordion>> fetchDailyPricingTrend = fetchDailyPricingTrend(contractStartDate);                                                
        plantSteerWrapper strWrp= new plantSteerWrapper();
        strWrp.srcStrLst=getSourceSteer(srcStrGrade,String.valueOf(contractStartDate));
        strWrp.depotStrLst=getDepotSteer(depStrGrade,depMot,depPlant,plantOverriden,contractStartDate);
        strWrp.orgStrLst=getOrgSteerLst();
        strWrp.depotLst=plantLst;
        strWrp.todaysDate=contractStartDate;
        strWrp.backBoneMap = fetchDailyPricingTrend(contractStartDate,depPlant,depStrGrade);                                                   
        return strWrp;
    }

    @AuraEnabled
    public static List<Location_Steer__c> getSourceSteer(String grade,string contractStartDate){
        List<Location_Steer__c> locStrLst= new List<Location_Steer__c>();
        date contractDate=date.valueOf(contractStartDate);
        Id srcStrRcdTypId=Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        locStrLst=[Select id,Plant__c,Plant_Name__c,Plant_Code__c,Product_Sub_Group__c,Scenario__c,Scenario_Value__c,
                   Manual_Adjustment__c,Source_Steer__c,Valid_From__c,Valid_To__c,PlantGradeUnq__c,Default__c,Rv_prompt_window_percent__c
                   from Location_Steer__c where Product_Sub_Group__c=:grade and 
                   Source_Location__c= true and recordTypeId=:srcStrRcdTypId and
                   Valid_From__c <= :contractDate and Valid_To__c >= :contractDate order by PlantGradeUnq__c,LastModifiedDate ASC ];
        //locStrLst Query udpated to add Rv_prompt_window_percent__c field
        //Dharam_1st_June_PBI811125(400)
        
        //FIX_PBI_578468_Lakshmi_20AUG2020_Starts
        
        //return getTodaysValue(locStrLst);  
        List<Location_Steer__c> finallocStrLst= new List<Location_Steer__c>();
        Map<String,List<Location_Steer__c>> plantGrdMap= new Map<String,List<Location_Steer__c>>();
        for(integer i=0;i<locStrLst.size();i++){
           if(plantGrdMap.containsKey(locStrLst[i].PlantGradeUnq__c)){
                List<Location_Steer__c> loclst= plantGrdMap.get(locStrLst[i].PlantGradeUnq__c);
                loclst.add(locStrLst[i]);
                plantGrdMap.put(locStrLst[i].PlantGradeUnq__c,loclst);
               
            }
            else{
                plantGrdMap.put(locStrLst[i].PlantGradeUnq__c,new List<Location_Steer__c> {locStrLst[i]});
                               
            }
        }
        
           for(string key:plantGrdMap.keySet()){
            if((plantGrdMap.get(key)).size()>1){
                Location_Steer__c loc;
                if(((plantGrdMap.get(key)).get(0)).Default__c){
                    loc=(plantGrdMap.get(key)).get(1);
                }
                else{
                    loc=(plantGrdMap.get(key)).get(0);
                }
             finallocStrLst.add(loc);
                
            }
            else{
                Location_Steer__c loc=(plantGrdMap.get(key)).get(0);
                finallocStrLst.add(loc);
                
            }
        } 
        return finallocStrLst;
        //FIX_PBI_578468_Lakshmi_20AUG2020_Ends
    }
    
    @AuraEnabled
    public static List<Location_Steer__c> getDepotSteer(String grade, string mot,
                                                        string plantName,boolean showOverridden,date contractStartDate){
        List<Location_Steer__c> locStrLst= new List<Location_Steer__c>();
        string finalQuery;
        //query udpated to add Rv_prompt_window_percent__c field
        //Dharam_1st_June_PBI811125(400)
        Id depotStrRcdTypId=Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
        string query='Select id,Plant__c,Plant_Name__c,Plant_Code__c,Product_Sub_Group__c,MOT__c,Depot_Steer__c,Default__c,'+
                    'Valid_From__c,Valid_To__c,PlantGradeUnq__c,Rv_prompt_window_percent__c from Location_Steer__c where '+
                    '(Product_Sub_Group__c=:grade and Source_Location__c= false and recordTypeId=:depotStrRcdTypId) and'+
                     ' Valid_From__c <= :contractStartDate and Valid_To__c >= :contractStartDate';
        if(showOverridden){
            query=query+' and Default__c = false';
        }
        if(mot !='All'){
            query=query +' and MOT__c=:mot';
        }
         string queryIncludeAll=' order by PlantGradeUnq__c,LastModifiedDate ASC';
         string querySpecificPlant= ' and Plant_Name__c=:plantName order by PlantGradeUnq__c,LastModifiedDate ASC';
        if(plantName=='All'){
            finalQuery=query+queryIncludeAll;
        }
        else{
             finalQuery=query+querySpecificPlant;
        }
        locStrLst=Database.query(finalQuery);
        return getTodaysValue(locStrLst);
    }
    @AuraEnabled
    public static List<Location_Steer__c> getOrgSteerLst(){
        List<Location_Steer__c> locStrLst= new List<Location_Steer__c>();
        List<Location_Steer__c> finallocStrLst= new List<Location_Steer__c>();
        Id orgStrRcdTypId=Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Origination Steer').getRecordTypeId();
        locStrLst=[Select Id,Origination_Steer_Type__c,Steer_Value__c,Valid_From__c,Valid_To__c,Default__c 
                   from Location_Steer__c where recordTypeId=:orgStrRcdTypId and
                   Valid_From__c <= TODAY and Valid_To__c >= TODAY ];
        Map<String,List<Location_Steer__c>> plantGrdMap= new Map<String,List<Location_Steer__c>>();
        for(integer i=0;i<locStrLst.size();i++){
           if(plantGrdMap.containsKey(locStrLst[i].Origination_Steer_Type__c)){
                List<Location_Steer__c> loclst= plantGrdMap.get(locStrLst[i].Origination_Steer_Type__c);
                loclst.add(locStrLst[i]);
                plantGrdMap.put(locStrLst[i].Origination_Steer_Type__c,loclst);
            }
            else{
                plantGrdMap.put(locStrLst[i].Origination_Steer_Type__c,new List<Location_Steer__c> {locStrLst[i]});
            }
        }
           for(string key:plantGrdMap.keySet()){
            if((plantGrdMap.get(key)).size()>1){
                Location_Steer__c loc;
                if(((plantGrdMap.get(key)).get(0)).Default__c){
                    loc=(plantGrdMap.get(key)).get(1);
                }
                else{
                    loc=(plantGrdMap.get(key)).get(0);
                }
             finallocStrLst.add(loc);
            }
            else{
                Location_Steer__c loc=(plantGrdMap.get(key)).get(0);
                finallocStrLst.add(loc);
            }
        } 
        return finallocStrLst;
    }
    public static List<Location_Steer__c> getTodaysValue(List<Location_Steer__c> locStrLst){
        List<Location_Steer__c> finallocStrLst= new List<Location_Steer__c>();
        Map<String,List<Location_Steer__c>> plantGrdMap= new Map<String,List<Location_Steer__c>>();
        for(integer i=0;i<locStrLst.size();i++){
           if(plantGrdMap.containsKey(locStrLst[i].PlantGradeUnq__c)){
                List<Location_Steer__c> loclst= plantGrdMap.get(locStrLst[i].PlantGradeUnq__c);
                loclst.add(locStrLst[i]);
                plantGrdMap.put(locStrLst[i].PlantGradeUnq__c,loclst);
            }
            else{
                plantGrdMap.put(locStrLst[i].PlantGradeUnq__c,new List<Location_Steer__c> {locStrLst[i]});
            }
        }
           for(string key:plantGrdMap.keySet()){
            if((plantGrdMap.get(key)).size()>1){
                Location_Steer__c loc;
                //FIX_PBI_578468_Lakshmi_20AUG2020_Starts
                Double steerVal = 0;
                if(((plantGrdMap.get(key)).get(0)).Default__c){       
                    steerval = ((plantGrdMap.get(key)).get(1)).Depot_Steer__c ; 
                    if(((plantGrdMap.get(key)).get(1)).Default__c){ 
                        
                        loc=(plantGrdMap.get(key)).get(0);
                    }
                    else{
                        
                    if(steerVal == null || steerVal == 0)
               		 {
                         
                    loc=(plantGrdMap.get(key)).get(0);
                         
                	 }
                     else
                     {
                        
                    loc=(plantGrdMap.get(key)).get(1);
               		 }
                   }
                }
                else{
                    
                    steerval = ((plantGrdMap.get(key)).get(0)).Depot_Steer__c ; 
                    
                    if(steerVal == null || steerVal == 0)
               		 {
                         
                    loc=(plantGrdMap.get(key)).get(1);
                         
                	 }
                    else
                    {
                        
                    loc=(plantGrdMap.get(key)).get(0);
                    }
                }
                //FIX_PBI_578468_Lakshmi_20AUG2020_Ends
             finallocStrLst.add(loc);
            }
            else{
                Location_Steer__c loc=(plantGrdMap.get(key)).get(0);
                finallocStrLst.add(loc);
            }
        } 
        return finallocStrLst;
    }
    
    @AuraEnabled
    public static Map<String,Map<String,backboneaccordion>> fetchDailyPricingTrend(Date contractDate,
                                                                                   String plantName,
                                                                                   String gradeName){
        //Date dt = System.today().addDays(0);
        String startTimeFormat = String.valueof(contractDate);
        List<Backbone_Trends__c> bspTrendLst = new List<Backbone_Trends__c>();
        String bspTrendString = '';
        System.debug('------gradeName-----'+gradeName);
        if((!string.isBlank(plantName) || !string.isBlank(gradeName)) && plantName != 'All'){
            System.debug('------contractDate-----'+contractDate);
            System.debug('------plantName-----'+plantName);
        	
            bspTrendString = 'Select Id,Depot__c,Depot__r.Name,Daily_BSP_Trends__r.Plant_Code__c,FreightToSource__c,Route_Uti_CO_steer__c,Depot_Steer_Euro_Mt__c,'+
                       'Daily_BSP_Trends__r.Material_Grade_L2__c,Daily_BSP_Trends__r.Depot_Steer__c,'+
                        'Route_Name__c,Route_Utilization__c,CO_Steer__c,Daily_BSP_Trends__r.Shipping_Condition__c,'+
                        'Daily_BSP_Trends__r.Sales_Org__c from Backbone_Trends__c where '+
                        'CreatedDate__c ='+startTimeFormat+' AND Daily_BSP_Trends__r.Shipping_Condition__c = 10';
            bspTrendString = bspTrendString + ' AND Daily_BSP_Trends__r.Material_Grade_L2__c =:gradeName AND Depot__r.Name =:plantName'+                                                          
                          ' order by Daily_BSP_Trends__r.Plant_Code__c,Daily_BSP_Trends__r.Material_Grade_L2__c';
        }else{
            bspTrendString = 'Select Id,Depot__c,Depot__r.Name,Daily_BSP_Trends__r.Plant_Code__c,FreightToSource__c,Route_Uti_CO_steer__c,Depot_Steer_Euro_Mt__c,'+
                       'Daily_BSP_Trends__r.Material_Grade_L2__c,Daily_BSP_Trends__r.Depot_Steer__c,'+
                        'Route_Name__c,Route_Utilization__c,CO_Steer__c,Daily_BSP_Trends__r.Shipping_Condition__c,'+
                        'Daily_BSP_Trends__r.Sales_Org__c from Backbone_Trends__c where '+
                		'Daily_BSP_Trends__r.Material_Grade_L2__c =:gradeName'+
                        ' AND CreatedDate__c ='+startTimeFormat+' AND Daily_BSP_Trends__r.Shipping_Condition__c = 10'+
                        ' AND Tranche__c = \'ATP1\'';  //Rahul Sharma | Date - 25-Nov-2020 : Getting only Tranche 1 Backbone list.
        	bspTrendString = bspTrendString+' order by Daily_BSP_Trends__r.Plant_Code__c,Daily_BSP_Trends__r.Material_Grade_L2__c';
        }
        System.debug('------bspTrendString-----'+bspTrendString);
        bspTrendLst = Database.query(bspTrendString);
        System.debug('------bspTrendLst-----'+bspTrendLst.size());
        Map<String,List<Backbone_Trends__c>> backboneMap = new Map<String,List<Backbone_Trends__c>>();
        for(Backbone_Trends__c bcboneTrends: bspTrendLst){
            if(bcboneTrends.Daily_BSP_Trends__r.Plant_Code__c.startsWith('D') && 
               String.valueof(bcboneTrends.Daily_BSP_Trends__r.Sales_Org__c).startsWith('D') || 
               bcboneTrends.Daily_BSP_Trends__r.Plant_Code__c.startsWith('A')){
                
            
                    if(!backboneMap.containskey(bcboneTrends.Depot__r.Name+'('+bcboneTrends.Daily_BSP_Trends__r.Plant_Code__c+')')){
                        backboneMap.put(bcboneTrends.Depot__r.Name+'('+bcboneTrends.Daily_BSP_Trends__r.Plant_Code__c+')',new List<Backbone_Trends__c>{bcboneTrends} );
                    }else{
                        List<Backbone_Trends__c> addBackboneLst = backboneMap.get(bcboneTrends.Depot__r.Name+'('+bcboneTrends.Daily_BSP_Trends__r.Plant_Code__c+')');
                        addBackboneLst.add(bcboneTrends);
                        backboneMap.put(bcboneTrends.Depot__r.Name+'('+bcboneTrends.Daily_BSP_Trends__r.Plant_Code__c+')',addBackboneLst);
                    }
            }
        }
        System.debug('------bspTrendLst-----'+backboneMap.keyset());
        Map<String,Map<String,backboneaccordion>> finalbackboneMap = new Map<String,Map<String,backboneaccordion>>();
        for(String bcboneTrends: backboneMap.keyset()){
            Map<String,backboneaccordion> backboneMaptemp = new Map<String,backboneaccordion>();
            System.debug('------bcboneTrends-----'+bcboneTrends);
            System.debug('------bspTrendLst-----'+backboneMap.get(bcboneTrends).size());
            for(Backbone_Trends__c bckbone: backboneMap.get(bcboneTrends)){
                System.debug('------bckbone-----'+bckbone.Route_Name__c);
                System.debug('------bckbone-----'+bckbone.CO_Steer__c);
                if(!backboneMaptemp.containskey(bckbone.Daily_BSP_Trends__r.Material_Grade_L2__c)){
                    backboneaccordion bckboneWrap = new backboneaccordion();
                    bckboneWrap.backBoneLst.addAll(new List<Backbone_Trends__c>{bckbone});
					bckboneWrap.isExpand = false;                    
                    backboneMaptemp.put(bckbone.Daily_BSP_Trends__r.Material_Grade_L2__c,bckboneWrap);
                }else{
                    backboneaccordion addBackboneLst = backboneMaptemp.get(bckbone.Daily_BSP_Trends__r.Material_Grade_L2__c);
                    //backboneaccordion bckboneWrap = new backboneaccordion();
                    addBackboneLst.backBoneLst.add(bckbone);
					//bckboneWrap.isExpand = false; 
                    backboneMaptemp.put(bckbone.Daily_BSP_Trends__r.Material_Grade_L2__c,addBackboneLst);
                }
            }
            
            finalbackboneMap.put(bcboneTrends,backboneMaptemp);
        }
        
        Map<String,Map<String,backboneaccordion>> finalMap = new Map<String,Map<String,backboneaccordion>>();
        for(String plantCode: finalbackboneMap.keyset()){
            Map<String,backboneaccordion> backboneMapinside = finalbackboneMap.get(plantCode);
            Map<String,backboneaccordion> backboneMapTotalSteer = new Map<String,backboneaccordion>();
            for(String grade :  backboneMapinside.keyset()){
                backboneaccordion bclbone = backboneMapinside.get(grade);
                Decimal totalDepotSteer = 0;
                Decimal sumDepotSteer = 0;
                Decimal sumrouteUtilization = 0;
                Decimal sumcosteer = 0;
                Decimal sumthirdpartySteer = 0;
                System.debug('------grade-----'+grade);
            	Decimal DepotSteersum = 0; 
                for(Backbone_Trends__c bckboneiterate : bclbone.backBoneLst){
                    System.debug('------bckboneiterate.CO_Steer__c-----'+bckboneiterate.CO_Steer__c);
                    totalDepotSteer = totalDepotSteer + bckboneiterate.Route_Uti_CO_steer__c.setScale(4);
                    sumDepotSteer = sumDepotSteer + bckboneiterate.Depot_Steer_Euro_Mt__c.setScale(4);
                    sumrouteUtilization = sumrouteUtilization + bckboneiterate.Route_Utilization__c.setScale(2);
                    sumcosteer = sumcosteer +  bckboneiterate.CO_Steer__c.setScale(4); 
                    System.debug('-----------'+bckboneiterate.Daily_BSP_Trends__r.Depot_Steer__c);
                    System.debug('------bckboneiterate.Route_Utilization__c-----'+bckboneiterate.Route_Utilization__c);
                    System.debug('------bckboneiterate.FreightToSource__c-----'+bckboneiterate.FreightToSource__c);
                    if(bckboneiterate.FreightToSource__c != null){
                    	sumthirdpartySteer = sumthirdpartySteer + (bckboneiterate.Route_Utilization__c*bckboneiterate.FreightToSource__c)/100;
                    }
                    DepotSteersum = DepotSteersum + bckboneiterate.Daily_BSP_Trends__r.Depot_Steer__c;
                }
                bclbone.sumcosteer = totalDepotSteer;
                totalDepotSteer= totalDepotSteer + bclbone.backBoneLst.get(0).Daily_BSP_Trends__r.Depot_Steer__c + sumthirdpartySteer;
                bclbone.totalDepotSteer = totalDepotSteer;
                bclbone.sumDepotSteer = bclbone.backBoneLst.get(0).Depot_Steer_Euro_Mt__c;
                bclbone.sumrouteUtilization = sumrouteUtilization;
                bclbone.sumThirdparty = sumthirdpartySteer;
                System.debug('----bclbone-----'+bclbone.backBoneLst);
                backboneMapTotalSteer.put(grade,bclbone);
            }
            finalMap.put(plantCode,backboneMapTotalSteer);
        }
        return finalMap;
        
    }
    
    public class backboneaccordion{
        @AuraEnabled
        public List<Backbone_Trends__c> backBoneLst = new List<Backbone_Trends__c>();
        @AuraEnabled
        public Boolean isExpand = false;
        @AuraEnabled
        public Decimal totalDepotSteer = 0;
        @AuraEnabled
        public Decimal sumDepotSteer = 0;
        @AuraEnabled
        public Decimal sumrouteUtilization = 0;
        @AuraEnabled
        public Decimal sumcosteer = 0;
        @AuraEnabled
        public Decimal sumThirdparty = 0;
    }
    
    public class plantSteerWrapper{ 
         @AuraEnabled
         public List<Location_Steer__c> srcStrLst;
         @AuraEnabled
         public List<Location_Steer__c> depotStrLst;
         @AuraEnabled
         public List<Location_Steer__c> orgStrLst;
         @AuraEnabled
         public List<string> depotLst;
         @AuraEnabled
         public date todaysDate;
         @AuraEnabled
         public Map<String,Map<String,backboneaccordion>> backBoneMap;
    }
    
    
}