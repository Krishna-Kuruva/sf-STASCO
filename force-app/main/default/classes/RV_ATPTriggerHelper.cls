/*****************************************************************************
@Name:  RV_ATPTriggerHelper     
@=========================================================================
@Purpose: Trigger will execute on insert and update to calculate ATP Refresh                                                                                        
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/18/2017         INITIAL DEVELOPMENT

******************************************************************************/
public  class RV_ATPTriggerHelper {
    
    public static Boolean recursiveValue= true;
    public static Boolean recursiveDashboard= true; 
    public static void onBeforeinsertAtp(List<ATP__c> atpLst){  
        List<ATP__c> fetchAtpLst = new List<ATP__c>();
        if(recursiveValue==true){  
            for(ATP__c atpRecords:atpLst){  
                if(atpRecords.ATP_Refresh__c == true || 
                   atpRecords.Reset_2__c == true ||
                   atpRecords.Reset_3__c == true){//Added By Dhriti
                    fetchAtpLst.add(atpRecords);
                }else if(atpRecords.ATP1__c <> null){
                    fetchAtpLst.add(atpRecords);
                }
            }
        }
        //System.debug('^^^^^^^^^^^'+fetchAtpLst); 
        if(!fetchAtpLst.isEmpty()){ 
            for(ATP__c atpRecords : fetchAtpLst){
                if(atpRecords.ATP_Refresh__c == true){//Added By Dhriti
                    if(atpRecords.ATP_Live__c == null) atpRecords.ATP_Live__c = 0.0;
                    if(atpRecords.ATP1__c == null)atpRecords.ATP1__c=0.0;
                    atpRecords.ATP_Live__c= atpRecords.ATP1__c;
                    atpRecords.Sales_8_30_17_30__c = 0;
                }
                if(atpRecords.Reset_2__c == true){//Added By Dhriti
                    if(atpRecords.ATP2_Live__c == null) atpRecords.ATP2_Live__c = 0.0;
                    if(atpRecords.ATP2__c == null)atpRecords.ATP2__c=0.0;
                    atpRecords.ATP2_Live__c= atpRecords.ATP2__c;
                    atpRecords.Sales_15_28__c = 0;
                }
                if(atpRecords.Reset_3__c == true){//Added By Dhriti
                    if(atpRecords.ATP3_Live__c == null) atpRecords.ATP3_Live__c = 0.0;
                    if(atpRecords.ATP3__c == null)atpRecords.ATP3__c=0.0;
                    atpRecords.ATP3_Live__c= atpRecords.ATP3__c;
                    atpRecords.Sales_29_61__c = 0;
                }
                if(atpRecords.ATP_Refresh__c == true){
                    atpRecords.ATP_Refresh__c = false;
                }
                /****** Reseting 2 and 3 *************/
                if(atpRecords.Reset_2__c == true){//Added By Dhriti
                    atpRecords.Reset_2__c = false;
                }
                if(atpRecords.Reset_3__c == true){//Added By Dhriti
                    atpRecords.Reset_3__c = false;
                }
            }
        }
        
        //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit starts
        //System.debug('About to insert Online ATP');
    	for(ATP__c atpRecords : atpLst){
            //START - Rahul Sharma | Date - 04-Nov-2020 : Added ATP split logic for tranche 2 and tranche3.
            if(atpRecords.ATP1__c != null){
                /*Decimal dailyVol = atpRecords.ATP_Live__c; //atpRecords.ATP1__c;	//Fix_326689_06Sep2019_Soumyajit
                Decimal minDailyVol = atpRecords.Minimum_Daily_Split_Volume__c;
                Decimal splitVol = atpRecords.Split_Volume__c;
                Decimal minOnlineVol = atpRecords.Minimum_Online_Volume__c;
                Decimal maxOnlineVol = atpRecords.Maximum_Online_Volume__c;
                
                atpRecords.Live_Online_00_14__c = getOnlineATP( dailyVol
                                                                ,minDailyVol
                                                                ,splitVol
                                                                ,minOnlineVol
                                                                ,maxOnlineVol);*/
                
                //System.debug('dailyVol='+dailyVol+';minDailyVol='+minDailyVol+';splitVol='+splitVol
                //            +';minOnlineVol='+minOnlineVol+';maxOnlineVol='+maxOnlineVol
                //            +'Live_Online='+atpRecords.Live_Online_00_14__c);
                atpRecords.Live_Online_00_14__c = getOnlineATP(atpRecords.ATP_Live__c,
                                                               atpRecords.Minimum_Daily_Split_Volume__c,
                                                               atpRecords.Split_Volume__c,
                                                               atpRecords.Minimum_Online_Volume__c,
                                                               atpRecords.Maximum_Online_Volume__c);
            }
            if(atpRecords.ATP2__c != null){
                atpRecords.Live_Online_ATP2__c = getOnlineATP(atpRecords.ATP2_Live__c,
                                                              atpRecords.Min_Daily_Split_Vol_ATP2__c,
                                                              atpRecords.Split_Volume_Per_ATP2__c,
                                                              atpRecords.Min_Online_Volume_ATP2__c,
                                                              atpRecords.Max_Online_Volume_ATP2__c);
            }
            if(atpRecords.ATP3__c != null){
                atpRecords.Live_Online_ATP3__c = getOnlineATP(atpRecords.ATP3_Live__c,
                                                              atpRecords.Min_Daily_Split_Vol_ATP3__c,
                                                              atpRecords.Split_Volume_Per_ATP3__c,
                                                              atpRecords.Min_Online_Volume_ATP3__c,
                                                              atpRecords.Max_Online_Volume_ATP3__c);
            }
            //END - Rahul Sharma | Date - 04-Nov-2020 : Added ATP split logic for tranche 2 and tranche3.
        }
        //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit ends
    } 
    //After Update 
    public static void onBeforeUpdateAtp(List<ATP__c> atpLst,Map<ID,ATP__c> atpNewMap,Map<ID,ATP__c> atpOldMap){   
        Set<String> fetchAtpSet = new Set<String>();
        Map<String,Decimal> plantGradeAtpValueMap=new Map<String,Decimal>();
        List<ATP__c> fetchAtpLst = new List<ATP__c>();        
        if(recursiveValue==true){     
            for(ATP__c atpRecords:atpLst){        
                if( (atpNewMap.get(atpRecords.Id).ATP1__c <> atpOldMap.get(atpRecords.Id).ATP1__c) ||
                   (atpNewMap.get(atpRecords.Id).ATP2__c <> atpOldMap.get(atpRecords.Id).ATP2__c) ||
                   (atpNewMap.get(atpRecords.Id).ATP3__c <> atpOldMap.get(atpRecords.Id).ATP3__c)  
                  ){
                      if(atpNewMap.get(atpRecords.Id).ATP1__c <> atpOldMap.get(atpRecords.Id).ATP1__c){
                          if(atpRecords.ATP_Live__c == null) atpRecords.ATP_Live__c = 0.0;
                          if(atpRecords.ATP1__c == null)atpRecords.ATP1__c=0.0;
                          atpRecords.ATP_Live__c= atpRecords.ATP1__c;
                      }
                      if(atpNewMap.get(atpRecords.Id).ATP2__c <> atpOldMap.get(atpRecords.Id).ATP2__c){
                          if(atpRecords.ATP2_Live__c == null) atpRecords.ATP2_Live__c = 0.0;
                          if(atpRecords.ATP2__c == null)atpRecords.ATP2__c=0.0;
                          atpRecords.ATP2_Live__c= atpRecords.ATP2__c;
                      }
                      if(atpNewMap.get(atpRecords.Id).ATP3__c <> atpOldMap.get(atpRecords.Id).ATP3__c){
                          if(atpRecords.ATP3_Live__c == null) atpRecords.ATP3_Live__c = 0.0;
                          if(atpRecords.ATP3__c == null)atpRecords.ATP3__c=0.0;
                          atpRecords.ATP3_Live__c= atpRecords.ATP3__c;
                      }
                       //fetchAtpLst.add(atpRecords);
                       
                   }else if(atpRecords.ATP_Refresh__c == true || atpRecords.Reset_2__c == true ||
                   			atpRecords.Reset_3__c == true){//Added By Dhriti
                       fetchAtpLst.add(atpRecords);
                   }
            }
        }
      
        //System.debug('^^^^^^^^^^^'+fetchAtpLst);
        if(!fetchAtpLst.isEmpty()){
            
                for(ATP__c atpRecords : fetchAtpLst){
                    
                    if(atpRecords.ATP_Refresh__c == true || 
                       atpRecords.Reset_2__c == true || 
                       atpRecords.Reset_3__c == true){//Added By Dhriti
                        if(atpRecords.ATP_Refresh__c == true){
                            if(atpRecords.ATP_Live__c == null) atpRecords.ATP_Live__c = 0.0;
                            if(atpRecords.ATP1__c == null)atpRecords.ATP1__c=0.0;
                            atpRecords.ATP_Live__c= atpRecords.ATP1__c;
                        }
                        if(atpRecords.Reset_2__c == true){
                            if(atpRecords.ATP2_Live__c == null) atpRecords.ATP2_Live__c = 0.0;
                            if(atpRecords.ATP2__c == null)atpRecords.ATP2__c=0.0;
                            atpRecords.ATP2_Live__c= atpRecords.ATP2__c;
                        }
                        if(atpRecords.Reset_3__c == true){
                            if(atpRecords.ATP3_Live__c == null) atpRecords.ATP3_Live__c = 0.0;
                            if(atpRecords.ATP3__c == null)atpRecords.ATP3__c=0.0;
                             atpRecords.ATP3_Live__c= atpRecords.ATP3__c;
                        }
                    }else{//Added By Dhriti
                        /*if(atpRecords.ATP_Live__c == null) atpRecords.ATP_Live__c = 0.0;
                            if(atpRecords.ATP1__c == null)atpRecords.ATP1__c=0.0;
                            atpRecords.ATP_Live__c= atpRecords.ATP1__c;
                        if(atpRecords.ATP2_Live__c == null) atpRecords.ATP2_Live__c = 0.0;
                            if(atpRecords.ATP2__c == null)atpRecords.ATP2__c=0.0;
                            atpRecords.ATP2_Live__c= atpRecords.ATP2__c;
                        if(atpRecords.ATP3_Live__c == null) atpRecords.ATP3_Live__c = 0.0;
                        	if(atpRecords.ATP3__c == null)atpRecords.ATP3__c=0.0;
                            atpRecords.ATP3_Live__c= atpRecords.ATP3__c;*/
                    }
                    //logic to be added for online Atp split
                      
                    
                        /*Fix_PBI_264813_Lakshmi_starts
                         atpRecords.Sales_8_30_17_30__c = 0;
                    	atpRecords.Sales_15_28__c = 0;
                    	atpRecords.Sales_29_61__c = 0;
						Fix_PBI_264813_Lakshmi_Ends*/
                    
                        if(atpRecords.ATP_Refresh__c == true){
                             atpRecords.ATP_Refresh__c = false;
                        }
                    	if(atpRecords.Reset_2__c == true){//Added By Dhriti
                             atpRecords.Reset_2__c = false;
                        }
                        if(atpRecords.Reset_3__c == true){//Added By Dhriti
                            atpRecords.Reset_3__c = false;
                        }
                    
                }
        }
    	for(ATP__c atpRecords : atpLst){
            //START - Rahul Sharma | Date - 04-Nov-2020 : Added full ATP split logic for tranche 2 and tranche3.
            if(atpNewMap.get(atpRecords.Id).ATP1__c <> atpOldMap.get(atpRecords.Id).ATP1__c ||
               atpNewMap.get(atpRecords.Id).Minimum_Daily_Split_Volume__c <> atpOldMap.get(atpRecords.Id).Minimum_Daily_Split_Volume__c || 
               atpNewMap.get(atpRecords.Id).Split_Volume__c <> atpOldMap.get(atpRecords.Id).Split_Volume__c || 
               atpNewMap.get(atpRecords.Id).Minimum_Online_Volume__c <> atpOldMap.get(atpRecords.Id).Minimum_Online_Volume__c || 
               atpNewMap.get(atpRecords.Id).Maximum_Online_Volume__c <> atpOldMap.get(atpRecords.Id).Maximum_Online_Volume__c){
                Decimal dailyVol = atpNewMap.get(atpRecords.Id).ATP1__c;
                //Fix_326689_06Sep2019_Soumyajit starts
                if(atpNewMap.get(atpRecords.Id).ATP_Live__c != null && atpNewMap.get(atpRecords.Id).ATP_Live__c <> atpOldMap.get(atpRecords.Id).ATP_Live__c)
                    dailyVol = atpNewMap.get(atpRecords.Id).ATP_Live__c;
                else
                    dailyVol = atpOldMap.get(atpRecords.Id).ATP_Live__c;
                //Fix_326689_06Sep2019_Soumyajit ends
                Decimal minDailyVol = atpOldMap.get(atpRecords.Id).Minimum_Daily_Split_Volume__c;
                Decimal splitVol = atpOldMap.get(atpRecords.Id).Split_Volume__c;
                Decimal minOnlineVol = atpOldMap.get(atpRecords.Id).Minimum_Online_Volume__c;
                Decimal maxOnlineVol = atpOldMap.get(atpRecords.Id).Maximum_Online_Volume__c;
                
                if(atpNewMap.get(atpRecords.Id).Minimum_Daily_Split_Volume__c <> atpOldMap.get(atpRecords.Id).Minimum_Daily_Split_Volume__c)
                    minDailyVol = atpNewMap.get(atpRecords.Id).Minimum_Daily_Split_Volume__c;
                if(atpNewMap.get(atpRecords.Id).Split_Volume__c <> atpOldMap.get(atpRecords.Id).Split_Volume__c)
                    splitVol = atpNewMap.get(atpRecords.Id).Split_Volume__c;
                if(atpNewMap.get(atpRecords.Id).Minimum_Online_Volume__c <> atpOldMap.get(atpRecords.Id).Minimum_Online_Volume__c)
                    minOnlineVol = atpNewMap.get(atpRecords.Id).Minimum_Online_Volume__c;
                if(atpNewMap.get(atpRecords.Id).Maximum_Online_Volume__c <> atpOldMap.get(atpRecords.Id).Maximum_Online_Volume__c)
                    maxOnlineVol = atpNewMap.get(atpRecords.Id).Maximum_Online_Volume__c;       
                atpRecords.Live_Online_00_14__c = getOnlineATP(dailyVol,
                                                               minDailyVol,
                                                               splitVol,
                                                               minOnlineVol,
                                                               maxOnlineVol); 
                //System.debug('dailyVol='+dailyVol+';minDailyVol='+minDailyVol+';splitVol='+splitVol
                //            +';minOnlineVol='+minOnlineVol+';maxOnlineVol='+maxOnlineVol
                //            +'Live_Online='+atpRecords.Live_Online_00_14__c);
            }
            if(atpNewMap.get(atpRecords.Id).ATP2__c <> atpOldMap.get(atpRecords.Id).ATP2__c ||
               atpNewMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP2__c <> atpOldMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP2__c || 
               atpNewMap.get(atpRecords.Id).Split_Volume_Per_ATP2__c <> atpOldMap.get(atpRecords.Id).Split_Volume_Per_ATP2__c || 
               atpNewMap.get(atpRecords.Id).Min_Online_Volume_ATP2__c <> atpOldMap.get(atpRecords.Id).Min_Online_Volume_ATP2__c || 
               atpNewMap.get(atpRecords.Id).Max_Online_Volume_ATP2__c <> atpOldMap.get(atpRecords.Id).Max_Online_Volume_ATP2__c){
                Decimal dailyVol = atpNewMap.get(atpRecords.Id).ATP2__c;
                if(atpNewMap.get(atpRecords.Id).ATP2_Live__c != null && atpNewMap.get(atpRecords.Id).ATP2_Live__c <> atpOldMap.get(atpRecords.Id).ATP2_Live__c)
                    dailyVol = atpNewMap.get(atpRecords.Id).ATP2_Live__c;
                else
                    dailyVol = atpOldMap.get(atpRecords.Id).ATP2_Live__c;
                Decimal minDailyVol = atpOldMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP2__c;
                Decimal splitVol = atpOldMap.get(atpRecords.Id).Split_Volume_Per_ATP2__c;
                Decimal minOnlineVol = atpOldMap.get(atpRecords.Id).Min_Online_Volume_ATP2__c;
                Decimal maxOnlineVol = atpOldMap.get(atpRecords.Id).Max_Online_Volume_ATP2__c;
                
                if(atpNewMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP2__c <> atpOldMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP2__c)
                    minDailyVol = atpNewMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP2__c;
                if(atpNewMap.get(atpRecords.Id).Split_Volume_Per_ATP2__c <> atpOldMap.get(atpRecords.Id).Split_Volume_Per_ATP2__c)
                    splitVol = atpNewMap.get(atpRecords.Id).Split_Volume_Per_ATP2__c;
                if(atpNewMap.get(atpRecords.Id).Min_Online_Volume_ATP2__c <> atpOldMap.get(atpRecords.Id).Min_Online_Volume_ATP2__c)
                    minOnlineVol = atpNewMap.get(atpRecords.Id).Min_Online_Volume_ATP2__c;
                if(atpNewMap.get(atpRecords.Id).Max_Online_Volume_ATP2__c <> atpOldMap.get(atpRecords.Id).Max_Online_Volume_ATP2__c)
                    maxOnlineVol = atpNewMap.get(atpRecords.Id).Max_Online_Volume_ATP2__c;       
                atpRecords.Live_Online_ATP2__c = getOnlineATP(dailyVol,
                                                               minDailyVol,
                                                               splitVol,
                                                               minOnlineVol,
                                                               maxOnlineVol); 
            }
            if(atpNewMap.get(atpRecords.Id).ATP3__c <> atpOldMap.get(atpRecords.Id).ATP3__c ||
               atpNewMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP3__c <> atpOldMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP3__c || 
               atpNewMap.get(atpRecords.Id).Split_Volume_Per_ATP3__c <> atpOldMap.get(atpRecords.Id).Split_Volume_Per_ATP3__c || 
               atpNewMap.get(atpRecords.Id).Min_Online_Volume_ATP3__c <> atpOldMap.get(atpRecords.Id).Min_Online_Volume_ATP3__c || 
               atpNewMap.get(atpRecords.Id).Max_Online_Volume_ATP3__c <> atpOldMap.get(atpRecords.Id).Max_Online_Volume_ATP3__c){
                Decimal dailyVol = atpNewMap.get(atpRecords.Id).ATP3__c;
                if(atpNewMap.get(atpRecords.Id).ATP3_Live__c != null && atpNewMap.get(atpRecords.Id).ATP3_Live__c <> atpOldMap.get(atpRecords.Id).ATP3_Live__c)
                    dailyVol = atpNewMap.get(atpRecords.Id).ATP3_Live__c;
                else
                    dailyVol = atpOldMap.get(atpRecords.Id).ATP3_Live__c;
                Decimal minDailyVol = atpOldMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP3__c;
                Decimal splitVol = atpOldMap.get(atpRecords.Id).Split_Volume_Per_ATP3__c;
                Decimal minOnlineVol = atpOldMap.get(atpRecords.Id).Min_Online_Volume_ATP3__c;
                Decimal maxOnlineVol = atpOldMap.get(atpRecords.Id).Max_Online_Volume_ATP3__c;
                
                if(atpNewMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP3__c <> atpOldMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP3__c)
                    minDailyVol = atpNewMap.get(atpRecords.Id).Min_Daily_Split_Vol_ATP3__c;
                if(atpNewMap.get(atpRecords.Id).Split_Volume_Per_ATP3__c <> atpOldMap.get(atpRecords.Id).Split_Volume_Per_ATP3__c)
                    splitVol = atpNewMap.get(atpRecords.Id).Split_Volume_Per_ATP3__c;
                if(atpNewMap.get(atpRecords.Id).Min_Online_Volume_ATP3__c <> atpOldMap.get(atpRecords.Id).Min_Online_Volume_ATP3__c)
                    minOnlineVol = atpNewMap.get(atpRecords.Id).Min_Online_Volume_ATP3__c;
                if(atpNewMap.get(atpRecords.Id).Max_Online_Volume_ATP3__c <> atpOldMap.get(atpRecords.Id).Max_Online_Volume_ATP3__c)
                    maxOnlineVol = atpNewMap.get(atpRecords.Id).Max_Online_Volume_ATP3__c;       
                atpRecords.Live_Online_ATP3__c = getOnlineATP(dailyVol,
                                                               minDailyVol,
                                                               splitVol,
                                                               minOnlineVol,
                                                               maxOnlineVol); 
            }
            //END - Rahul Sharma | Date - 04-Nov-2020 : Added full ATP split logic for tranche 2 and tranche3.
        }
      
    } 

    public static void onAfterUpdateAtp(List<ATP__c> atpLst,Map<ID,ATP__c> atpNewMap,Map<ID,ATP__c> atpOldMap){
        Set<String> fetchAtpSet = new Set<String>();
        Map<String,Decimal> plantGradeAtpValueMap=new Map<String,Decimal>(); 
        
        //Fix_437452_02Mar2020_Soumyajit starts
        Set<ID> atpLocTriggSet = new Set<ID>();
        Set<ID> atpLocTriggRelatedSet = new Set<ID>();
        Map<String,String> mapRelatedATP = new Map<String,String>();
        Map<String,List<Decimal>> mapLiveValues = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> mapLiveNewValues = new Map<String,List<Decimal>>();
        Set<String> ATPnotFound = new Set<String>();
        
        for(ATP__c atp:atpLst){
            if(!atpLocTriggSet.contains(atpOldMap.get(atp.id).location__c))
            	atpLocTriggSet.add(atpOldMap.get(atp.id).location__c);
        }
        
        if(atpLocTriggSet.size() >0)
        {
            //START - Rahul Sharma | Date - 26-Nov-2020 : Updated query to include Live_Online_ATP2__c and Live_Online_ATP3__c fields.
            ATP__c[] atpQryList = [SELECT Id,
                                          Location__c, 
                                          Grade_Level2__c,
                                          Plant_Code__c,
                                          ATP_Live__c,
                                          ATP2_Live__c,
                                          ATP3_Live__c,
                                          Live_Online_00_14__c,
                                          Live_Online_ATP2__c,
                                          Live_Online_ATP3__c,
                                          Location__r.Related_Plant__c,
                                          Location__r.Related_Plant_Code__c FROM ATP__c WHERE Location__c IN :atpLocTriggSet OR 
                                                                                              Location__r.Related_Plant__c IN : atpLocTriggSet];
            //END - Rahul Sharma | Date - 26-Nov-2020 : Updated query to include Live_Online_ATP2__c and Live_Online_ATP3__c fields.
        
            for(ATP__c atp:atpQryList)
            {
                if(atp.location__r.Related_Plant_Code__c != null)
                {
                    mapRelatedATP.put(atp.Plant_Code__c,atp.location__r.Related_Plant_Code__c);
                    
                    if(!atpLocTriggRelatedSet.contains(atp.location__r.Related_Plant__c))
                        atpLocTriggRelatedSet.add(atp.location__r.Related_Plant__c);
                }
                //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live_Online_ATP2__c and Live_Online_ATP3__c fields.
                mapLiveValues.put(atp.Plant_Code__c + atp.Grade_Level2__c, new List<Decimal>{atp.ATP_Live__c, atp.ATP2_Live__c, atp.ATP3_Live__c, 
                                                                                             atp.Live_Online_00_14__c, atp.Live_Online_ATP2__c, atp.Live_Online_ATP3__c});
                //END - Rahul Sharma | Date - 26-Nov-2020 : Added Live_Online_ATP2__c and Live_Online_ATP3__c fields.
            }
            
            //Find Child Related ATP
            if(atpLocTriggRelatedSet.size()>0)
            {
                //START - Rahul Sharma | Date - 26-Nov-2020 : Updated query to include Live_Online_ATP2__c and Live_Online_ATP3__c fields.
                ATP__c[] atpQryList2 = [SELECT Id ,
                                               Location__c, 
                                               Grade_Level2__c,
                                               Plant_Code__c,
                                               ATP_Live__c,
                                               ATP2_Live__c,
                                               ATP3_Live__c,
                                               Live_Online_00_14__c,
                                               Live_Online_ATP2__c,
                                               Live_Online_ATP3__c,
                                               Location__r.Related_Plant__c,
                                               Location__r.Related_Plant_Code__c FROM ATP__c WHERE Location__c IN : atpLocTriggRelatedSet];
                //END - Rahul Sharma | Date - 26-Nov-2020 : Updated query to include Live_Online_ATP2__c and Live_Online_ATP3__c fields.
                
                for(ATP__c atp:atpQryList2){
                    //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live_Online_ATP2__c and Live_Online_ATP3__c fields.
                    mapLiveValues.put(atp.Plant_Code__c+atp.Grade_Level2__c, new List<Decimal>{atp.ATP_Live__c, atp.ATP2_Live__c, atp.ATP3_Live__c,
                                                                                               atp.Live_Online_00_14__c, atp.Live_Online_ATP2__c, atp.Live_Online_ATP3__c});
                    //END - Rahul Sharma | Date - 26-Nov-2020 : Added Live_Online_ATP2__c and Live_Online_ATP3__c fields.
                }
            }
        }
        
        for(String key : mapLiveValues.keySet())
        {
            String plant = key.replace('AGO B7', '').replace('IGO 50ppm', '').replace('ULG95 E5', '');
            String grade = key.replace(plant,'');
            
            Decimal LiveAtp1 = (mapLiveValues.get(key)[0] != null) ? mapLiveValues.get(key)[0] : 0;
            Decimal LiveAtp2 = (mapLiveValues.get(key)[1] != null) ? mapLiveValues.get(key)[1] : 0;
            Decimal LiveAtp3 = (mapLiveValues.get(key)[2] != null) ? mapLiveValues.get(key)[2] : 0;
            //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables for tranche2 and tranche3.
            Decimal LiveOnline = (mapLiveValues.get(key)[3] != null) ? mapLiveValues.get(key)[3] : 0;
            Decimal liveOnline2 = (mapLiveValues.get(key)[4] != null) ? mapLiveValues.get(key)[4] : 0;
            Decimal liveOnline3 = (mapLiveValues.get(key)[5] != null) ? mapLiveValues.get(key)[5] : 0;
            //END - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables for tranche2 and tranche3.
            if(mapRelatedATP.containskey(plant))
            {
                String relatedPlantGrade = mapRelatedATP.get(plant) + grade;
                if(mapLiveValues.containsKey(relatedPlantGrade))
                {
                    if(mapLiveValues.get(relatedPlantGrade)[0] !=null)
                    	LiveAtp1 += mapLiveValues.get(relatedPlantGrade)[0];
                    if(mapLiveValues.get(relatedPlantGrade)[1] !=null)
                    	LiveAtp2 += mapLiveValues.get(relatedPlantGrade)[1];
                    if(mapLiveValues.get(relatedPlantGrade)[2] !=null)
                    	LiveAtp3 += mapLiveValues.get(relatedPlantGrade)[2];  
                }
            }
            mapLiveNewValues.put(plant + grade, new List<Decimal>{LiveAtp1, LiveAtp2, LiveAtp3, LiveOnline, liveOnline2, liveOnline3}); //Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables for tranche2 and tranche3.
        }
        
        ATPnotFound.addall(mapLiveNewValues.keySet());
        //System.debug('mapLiveNewValues=' + mapLiveNewValues);
        
        //system.debug('after update');
        if(recursiveDashboard == true){
            for(ATP__c atp : atpLst){
                // Added for dashboard logic
                if((atpNewMap.get(atp.Id).ATP_Live__c <> atpOldMap.get(atp.Id).ATP_Live__c) ||
                   (atpNewMap.get(atp.Id).Live_Online_00_14__c <> atpOldMap.get(atp.Id).Live_Online_00_14__c) ||
                   //START - Rahul Sharma | Date - 26-Nov-2020 : Added conditions for live online variables for tranche2 and tranche3.
                   (atpNewMap.get(atp.Id).Live_Online_ATP2__c <> atpOldMap.get(atp.Id).Live_Online_ATP2__c) ||
                   (atpNewMap.get(atp.Id).Live_Online_ATP3__c <> atpOldMap.get(atp.Id).Live_Online_ATP3__c) ||
                   //END - Rahul Sharma | Date - 26-Nov-2020 : Added conditions for live online variables for tranche2 and tranche3.
                   (atpNewMap.get(atp.Id).ATP2_Live__c <> atpOldMap.get(atp.Id).ATP2_Live__c) ||
                   (atpNewMap.get(atp.Id).ATP3_Live__c <> atpOldMap.get(atp.Id).ATP3_Live__c) ||
                   (atpNewMap.get(atp.Id).ATP1__c <> atpOldMap.get(atp.Id).ATP1__c) || 
                   (atpNewMap.get(atp.Id).ATP2__c <> atpOldMap.get(atp.Id).ATP2__c) || 
                   (atpNewMap.get(atp.Id).ATP3__c <> atpOldMap.get(atp.Id).ATP3__c)){
                       //system.debug('inside==>'+atp);
                       fetchAtpSet.add(atp.Plant_Code__c); 
                       
                       String plant = atpOldMap.get(atp.id).Plant_Code__c;
                       String grade = atpOldMap.get(atp.id).Grade_Level2__c;
                       Decimal LiveAtp1 = (mapLiveNewValues.containskey(plant + grade)) ? ((mapLiveNewValues.get(plant + grade)[0] != null) ? mapLiveNewValues.get(plant + grade)[0] : 0) : atp.ATP_Live__c;
                       Decimal LiveAtp2 = (mapLiveNewValues.containskey(plant + grade)) ? ((mapLiveNewValues.get(plant + grade)[1] != null) ? mapLiveNewValues.get(plant + grade)[1] : 0) : atp.ATP2_Live__c;
                       Decimal LiveAtp3 = (mapLiveNewValues.containskey(plant + grade)) ? ((mapLiveNewValues.get(plant + grade)[2] != null) ? mapLiveNewValues.get(plant + grade)[2] : 0) : atp.ATP3_Live__c;
                       Decimal LiveOnline = (mapLiveNewValues.containskey(plant + grade)) ? ((mapLiveNewValues.get(plant + grade)[3] != null) ? mapLiveNewValues.get(plant + grade)[3] : 0) : atp.Live_Online_00_14__c;
                       //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables for tranche2 and tranche3.
                       Decimal liveOnline2 = (mapLiveNewValues.containskey(plant + grade)) ? ((mapLiveNewValues.get(plant + grade)[4] != null) ? mapLiveNewValues.get(plant + grade)[4] : 0) : atp.Live_Online_ATP2__c;
                       Decimal liveOnline3 = (mapLiveNewValues.containskey(plant + grade)) ? ((mapLiveNewValues.get(plant + grade)[5] != null) ? mapLiveNewValues.get(plant + grade)[5] : 0) : atp.Live_Online_ATP3__c;
                       //END - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables for tranche2 and tranche3.
                       if(mapLiveNewValues.containskey(plant + grade))
                           ATPnotFound.remove(plant + grade);
                       
                       plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP1Offline',LiveAtp1);
                       if(atp.Live_Online_00_14__c != null)
                           plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP1Online',atp.Live_Online_00_14__c);
                        //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables in map for tranche2 and tranche3.
                        if(atp.Live_Online_ATP2__c != null)
                            plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP2Online',atp.Live_Online_ATP2__c);
                        if(atp.Live_Online_ATP3__c != null)
                            plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP3Online',atp.Live_Online_ATP3__c);
                        //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables in map for tranche2 and tranche3.
                       plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP2',LiveAtp2);
                       plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP3',LiveAtp3);
                   }
            }
            
            if(ATPnotFound.size()>0)
            {
                for(String key : ATPnotFound)
                {
                    String plant = key.replace('AGO B7', '').replace('IGO 50ppm', '').replace('ULG95 E5', '');
                    Decimal LiveAtp1 = (mapLiveNewValues.get(key)[0] != null) ? mapLiveNewValues.get(key)[0] : 0;
                    Decimal LiveAtp2 = (mapLiveNewValues.get(key)[1] != null) ? mapLiveNewValues.get(key)[1] : 0;
                    Decimal LiveAtp3 = (mapLiveNewValues.get(key)[2] != null) ? mapLiveNewValues.get(key)[2] : 0;
                    Decimal LiveOnline = (mapLiveNewValues.get(key)[3] != null) ? mapLiveNewValues.get(key)[3] : 0;
                    //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables for tranche2 and tranche3.
                    Decimal liveOnline2 = (mapLiveNewValues.get(key)[4] != null) ? mapLiveNewValues.get(key)[4] : 0;
                    Decimal liveOnline3 = (mapLiveNewValues.get(key)[5] != null) ? mapLiveNewValues.get(key)[5] : 0;
                    //END - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables for tranche2 and tranche3.
                    plantGradeAtpValueMap.put(key+'ATP1Offline',LiveAtp1);
                    plantGradeAtpValueMap.put(key+'ATP1Online',LiveOnline);
                    //START - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables in map for tranche2 and tranche3.
                    plantGradeAtpValueMap.put(key+'ATP2Online',liveOnline2);
                    plantGradeAtpValueMap.put(key+'ATP3Online',liveOnline3);
                    //END - Rahul Sharma | Date - 26-Nov-2020 : Added Live online variables in map for tranche2 and tranche3.
                    plantGradeAtpValueMap.put(key+'ATP2',LiveAtp2);
                    plantGradeAtpValueMap.put(key+'ATP3',LiveAtp3);
                    fetchAtpSet.add(plant);
                }
            }
            //Fix_437452_02Mar2020_Soumyajit ends
            
            if(fetchAtpSet.size()>0){
                List<Revolution_Dashboard__c> fetchSelectedSalesLst = fetchSalesBoard(fetchAtpSet);
                updateATPLiveSalesBoard(fetchSelectedSalesLst,fetchAtpSet,plantGradeAtpValueMap);
            }
            recursiveDashboard=false;
            //system.debug('fetchAtpSet==>'+fetchAtpSet);
            //system.debug('plantGradeAtpValueMap==>'+plantGradeAtpValueMap);
        }  
    }
    /*************** fetch sales dashboard records****************/
    public static List<Revolution_Dashboard__c> fetchSalesBoard(Set<String> atpUniqueKey){//
        Id dashboardRcdTypId=Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
        return [select id,Plant_Code__c,ATP1_Live_AGO__c,ATP1_Live_IGO__c,ATP1_Live_MOGAS__c,
                ATP2_Live_AGO__c,ATP2_Live_IGO__c,ATP2_Live_MOGAS__c, ATP3_Live_AGO__c,ATP3_Live_IGO__c,ATP3_Live_MOGAS__c
                from Revolution_Dashboard__c where Plant_Code__c in:atpUniqueKey and recordTypeId =:dashboardRcdTypId];
    }
    /*************** filter logic to update live atp field in sales dashboard object****************/
    public static void updateATPLiveSalesBoard(List<Revolution_Dashboard__c> fetchSelectedSalesLst,Set<String> fetchAtpSet,Map<string,Decimal> plantGradeAtpValueMap){
         	 List<Revolution_Dashboard__c> updateATPLiveLst = new List<Revolution_Dashboard__c>();
        	//System.debug('fetchSelectedSalesLst==>'+fetchSelectedSalesLst+'size==>'+fetchSelectedSalesLst.size());
        decimal astmAgoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
        decimal astmMogas= Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon); 
             for(Revolution_Dashboard__c rev : fetchSelectedSalesLst){
                 if(fetchAtpSet.contains(rev.Plant_Code__c)){
                    //AdditionalFix_326425_14Nov2019_Soumyajit starts                     
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'AGO B7ATP1Offline')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP1Offline')!=null) )
                        rev.ATP1_Live_AGO__c = (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP1Offline')/astmAgoIgo).intValue();
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'AGO B7ATP1Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP1Online')!=null) )
                        rev.ATP1_Live_AGO__c = rev.ATP1_Live_AGO__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP1Online')/astmAgoIgo).intValue();
                     
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'IGO 50ppmATP1Offline')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP1Offline')!=null) )
                        rev.ATP1_Live_IGO__c = (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP1Offline')/astmAgoIgo).intValue();
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'IGO 50ppmATP1Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP1Online')!=null) )
                        rev.ATP1_Live_IGO__c = rev.ATP1_Live_IGO__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP1Online')/astmAgoIgo).intValue();
                     
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'ULG95 E5ATP1Offline')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP1Offline')!=null) )
                        rev.ATP1_Live_MOGAS__c = (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP1Offline')/astmMogas).intValue();
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'ULG95 E5ATP1Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP1Online')!=null) )
                        rev.ATP1_Live_MOGAS__c = rev.ATP1_Live_MOGAS__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP1Online')/astmMogas).intValue();
                     //AdditionalFix_326425_14Nov2019_Soumyajit ends

                    //START - Rahul Sharma | Date - 26-Nov-2020 : Updated logic to substract live online volume from the offline volume for tranche 2 and tranche3.
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'AGO B7ATP2')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP2')!=null) )  
                        rev.ATP2_Live_AGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP2')/astmAgoIgo;
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'AGO B7ATP2Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP2Online')!=null) )
                        rev.ATP2_Live_AGO__c = rev.ATP2_Live_AGO__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP2Online')/astmAgoIgo).intValue();
                    
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'IGO 50ppmATP2')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP2')!=null) ) 
                        rev.ATP2_Live_IGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP2')/astmAgoIgo;
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'IGO 50ppmATP2Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP2Online')!=null) )
                        rev.ATP2_Live_IGO__c = rev.ATP2_Live_IGO__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP2Online')/astmAgoIgo).intValue();
                    
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'ULG95 E5ATP2')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP2')!=null) )  
                        rev.ATP2_Live_MOGAS__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP2')/astmMogas;
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'ULG95 E5ATP2Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP2Online')!=null) )
                        rev.ATP2_Live_MOGAS__c = rev.ATP2_Live_MOGAS__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP2Online')/astmMogas).intValue();

                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'AGO B7ATP3')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP3')!=null))  
                        rev.ATP3_Live_AGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP3')/astmAgoIgo;
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'AGO B7ATP3Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP3Online')!=null) )
                        rev.ATP3_Live_AGO__c = rev.ATP3_Live_AGO__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP3Online')/astmAgoIgo).intValue();
                        
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'IGO 50ppmATP3')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP3')!=null))
                        rev.ATP3_Live_IGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP3')/astmAgoIgo;
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'IGO 50ppmATP3Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP3Online')!=null) )
                        rev.ATP3_Live_IGO__c = rev.ATP3_Live_IGO__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP3Online')/astmAgoIgo).intValue();
                    
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'ULG95 E5ATP3')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP3')!=null))
                        rev.ATP3_Live_MOGAS__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP3')/astmMogas;
                    if((plantGradeAtpValueMap.containskey(rev.Plant_Code__c+'ULG95 E5ATP3Online')) && (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP3Online')!=null) )
                        rev.ATP3_Live_MOGAS__c = rev.ATP3_Live_MOGAS__c - (plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP3Online')/astmMogas).intValue();
                    //END - Rahul Sharma | Date - 26-Nov-2020 : Updated logic to substract live online volume from the offline volume for tranche 2 and tranche3.
                     updateATPLiveLst.add(rev);   
                 }
            }
        	for(Revolution_Dashboard__c rev : updateATPLiveLst)
            {
                if(rev.ATP1_Live_AGO__c != null)
                	rev.ATP1_Live_AGO__c = rev.ATP1_Live_AGO__c.intValue();
                if(rev.ATP1_Live_IGO__c != null)
                	rev.ATP1_Live_IGO__c = rev.ATP1_Live_IGO__c.intValue();
                if(rev.ATP1_Live_MOGAS__c != null)
                	rev.ATP1_Live_MOGAS__c = rev.ATP1_Live_MOGAS__c.intValue();
                if(rev.ATP2_Live_AGO__c != null)
                	rev.ATP2_Live_AGO__c = rev.ATP2_Live_AGO__c.intValue();
                if(rev.ATP2_Live_IGO__c != null)
                	rev.ATP2_Live_IGO__c = rev.ATP2_Live_IGO__c.intValue();
                if(rev.ATP2_Live_MOGAS__c != null)
                	rev.ATP2_Live_MOGAS__c = rev.ATP2_Live_MOGAS__c.intValue();
                if(rev.ATP3_Live_AGO__c != null)
                	rev.ATP3_Live_AGO__c = rev.ATP3_Live_AGO__c.intValue();
                if(rev.ATP3_Live_IGO__c != null)
                	rev.ATP3_Live_IGO__c = rev.ATP3_Live_IGO__c.intValue();
                if(rev.ATP3_Live_MOGAS__c != null)
                	rev.ATP3_Live_MOGAS__c = rev.ATP3_Live_MOGAS__c.intValue();
            }
         	updateATPLive(updateATPLiveLst);
     }
    /*************** updating live atp field in sales dashboard object****************/
    public static void updateATPLive(List<Revolution_Dashboard__c> updateATPLiveLst){
         
             if(!updateATPLiveLst.isEmpty()){
                    try{
                         Database.SaveResult[] atpLiveSalesDash = Database.update(updateATPLiveLst);
                         for (Database.SaveResult sr : atpLiveSalesDash) {
                             if (sr.isSuccess()) {
                                 // Operation was successful, so get the ID of the record that was processed
                                 //System.debug('Successfully updated ATP Live: ' + sr.getId());
                             }
                             else {
                                 // Operation failed, so get all errors                
                                 for(Database.Error err : sr.getErrors()) {
                                     RV_ClassException.getInstance();
                                     RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'RV_ATPTriggerHelper', 'onBeforeinsertAtp','Exception');
                                 }
                             }
                         }
                    }catch(Exception e){
                        System.debug('--------'+e);
                    }
             }
     }

    public static Decimal getOnlineATP (
                                         Decimal liveOfflineVol
                                        ,Decimal minOfflineVol
                                        ,Decimal splitVol
                                        ,Decimal minOnlineVol
                                        ,Decimal maxOnlineVol
                            			)
    {
        Decimal liveOnline = 0;

        if(minOfflineVol == null)
            minOfflineVol = 0;
        if (minOnlineVol == null)
            minOnlineVol =0;
        if (splitVol == null)
            splitVol =0;
        if (maxOnlineVol == null)
            maxOnlineVol =0;
        
        if(liveOfflineVol >= (minOfflineVol + minOnlineVol))
        {
            Decimal splitPercentVol = (splitVol * liveOfflineVol) / 100 ;
            
            if(liveOfflineVol < (minOfflineVol + splitPercentVol))
                liveOnline = liveOfflineVol - minOfflineVol;
            else
                liveOnline = splitPercentVol;
        }
        
        if(liveOnline < 0)
            liveOnline = 0;
        
        if(liveOnline >= maxOnlineVol)
            liveOnline = maxOnlineVol;

        return liveOnline;
    }    
}