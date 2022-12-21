public class RevolutionDashboardTriggerHelper {
    /*************************** Before insert ******************************/
	public static void onBeforeinsertRevDashboard(List<Revolution_Dashboard__c> revDashboardLst){
        
        Map<String,Revolution_Dashboard__c> mapOfDashboard = new Map<String,Revolution_Dashboard__c>();
        List<RV_PriceChange__e> priceLst = new List<RV_PriceChange__e>();
        for(Revolution_Dashboard__c revDashboard : revDashboardLst){
            priceLst = returnPriceLst(priceLst);
            if((revDashboard.Plant_Code__c!=null)&&((revDashboard.ATP1_Live_AGO__c == null) || 
                                                    (revDashboard.ATP1_Live_AGO__c == null) ||
                                                    (revDashboard.ATP1_Live_MOGAS__c == null) ||
                                                    (revDashboard.ATP2_Live_AGO__c == null) || 
                                                    (revDashboard.ATP2_Live_AGO__c == null) ||
                                                    (revDashboard.ATP2_Live_MOGAS__c == null) ||
                                                    (revDashboard.ATP3_Live_AGO__c == null) || 
                                                    (revDashboard.ATP3_Live_AGO__c == null) ||
                                                    (revDashboard.ATP3_Live_MOGAS__c == null) 
                                                   )){
                mapOfDashboard.put(revDashboard.Plant_Code__c, revDashboard);
            }
        }
        system.debug('mapOfDashboard==>'+mapOfDashboard);
        Map<String,Decimal> plantGradeAtpValueMap=new Map<String,Decimal>();
        Map<Id,ATP__c> fetchATPMap = new Map<ID,ATP__c>([select id,ATP_Live__c,
                                                         Live_Online_00_14__c,	//AdditionalFix_326425_14Nov2019_Soumyajit
                                                         location__r.Related_Plant__c,location__r.Related_Plant_Code__c,	//Fix_437452_02Mar2020_Soumyajit
                                                         ATP2_Live__c,ATP3_Live__c,Grade_Level2__c,Plant_Code__c from ATP__c 
                                                         where Plant_Code__c in:mapOfDashboard.keyset()]);
        System.debug('fetchATPMap==>'+fetchATPMap);
        if(!fetchATPMap.isEmpty()){
        
        //Fix_437452_02Mar2020_Soumyajit starts
        Map<String,String> mapRelatedATP = new Map<String,String>();
        Map<string,ATP__c> atpMap= new  Map<string,ATP__c>();
            
        for(ATP__c at:fetchATPMap.values()){
            atpMap.put(at.Plant_Code__c+at.Grade_Level2__c, at);
            
            if(at.location__r.Related_Plant_Code__c != null)
                mapRelatedATP.put(at.Plant_Code__c,at.location__r.Related_Plant_Code__c);
        }
        
        for(ATP__c at:fetchATPMap.values())
        {
            if(mapRelatedATP.containskey(at.Plant_Code__c))
            {
                String relatedKey = mapRelatedATP.get(at.Plant_Code__c);
                if(atpMap.containsKey(relatedKey + at.Grade_Level2__c))
                {
                    if(atpMap.get(relatedKey + at.Grade_Level2__c).ATP_Live__c != null && at.ATP_Live__c!=null)
                    	at.ATP_Live__c += atpMap.get(relatedKey + at.Grade_Level2__c).ATP_Live__c;
                    if(atpMap.get(relatedKey + at.Grade_Level2__c).ATP2_Live__c != null && at.ATP2_Live__c!=null)
                    	at.ATP2_Live__c += atpMap.get(relatedKey + at.Grade_Level2__c).ATP2_Live__c;
                    if(atpMap.get(relatedKey + at.Grade_Level2__c).ATP3_Live__c != null && at.ATP3_Live__c!=null)
                    	at.ATP3_Live__c += atpMap.get(relatedKey + at.Grade_Level2__c).ATP3_Live__c;
                    atpMap.put(at.Plant_Code__c+at.Grade_Level2__c, at);
                }
            }
        }

            for(ATP__c atp : atpMap.values()){
                if(mapOfDashboard.containskey(atp.Plant_Code__c)){
                    plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP1Offline',atp.ATP_Live__c);
                    if(atp.Live_Online_00_14__c != null)
                    	plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP1Online',atp.Live_Online_00_14__c);
                    plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP2',atp.ATP2_Live__c);
                    plantGradeAtpValueMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+'ATP3',atp.ATP3_Live__c);
                }
            }
        }
        //Fix_437452_02Mar2020_Soumyajit ends
        
        System.debug('plantGradeAtpValueMap==>'+plantGradeAtpValueMap);
        decimal astmAgoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
        decimal astmMogas= Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon); 
        for(Revolution_Dashboard__c rev : revDashboardLst){
            //AdditionalFix_326425_14Nov2019_Soumyajit starts
            /*
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP1') != null && plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP1') != 0){
                 rev.ATP1_Live_AGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP1')/astmAgoIgo;
            }
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP1') != null ){
                 rev.ATP1_Live_IGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP1')/astmAgoIgo;
            }   
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP1') != null) {
                 rev.ATP1_Live_MOGAS__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP1')/astmMogas;
            }  */
            
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
                     
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP2') != null) {
                 rev.ATP2_Live_AGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP2')/astmAgoIgo;
            }  
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP2') != null){
                 rev.ATP2_Live_IGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP2')/astmAgoIgo;
            }   
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP2') != null){
                  rev.ATP2_Live_MOGAS__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP2')/astmMogas;
            }   
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP3') != null ){
                  rev.ATP3_Live_AGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'AGO B7ATP3')/astmAgoIgo;
            } 
            if( plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP3') != null ){
                rev.ATP3_Live_IGO__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'IGO 50ppmATP3')/astmAgoIgo;
            } 
            if(plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP3') != null ) {
                 rev.ATP3_Live_MOGAS__c = plantGradeAtpValueMap.get(rev.Plant_Code__c+'ULG95 E5ATP3')/astmMogas;  
            } 
                
        }
        
        	//AdditionalFix_326425_14Nov2019_Soumyajit starts
        	for(Revolution_Dashboard__c rev : revDashboardLst)
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
        	//AdditionalFix_326425_14Nov2019_Soumyajit ends
        	
        System.debug('revDashboardLst==>'+revDashboardLst);
        Database.SaveResult publishEnt = publishEventonChange(priceLst);
    }
    
    /*************************** Before update ******************************/
    public static void onBeforeupdateRevDashboard(List<Revolution_Dashboard__c> revDashboardLst,Map<Id,Revolution_Dashboard__c> revDashboardNewMap,
                                                  Map<Id,Revolution_Dashboard__c> revDashboardOldMap){
                 List<RV_PriceChange__e> priceLst = new List<RV_PriceChange__e>();
               
                 for(Revolution_Dashboard__c revolution : revDashboardLst){
                      if((revDashboardNewMap.get(revolution.Id) <> revDashboardOldMap.get(revolution.Id))){
                                priceLst = returnPriceLst(priceLst);
                       }
                 }
                 System.debug('-----priceLst-----'+priceLst);                                     
                 Database.SaveResult publishEnt = publishEventonChange(priceLst);
   }
    
    /*************************** Create priceList ******************************/
    public static List<RV_PriceChange__e> returnPriceLst(List<RV_PriceChange__e> priceLst){
        RV_PriceChange__e price = new RV_PriceChange__e();
        price.Price_Changed__c=true;
        priceLst.add(price);
        return priceLst;
    }
    
    /*************************** Trigger publish event ******************************/
    public static Database.SaveResult publishEventonChange(List<RV_PriceChange__e> priceLst){
             Database.SaveResult prcChangeVal;
             RV_PriceChange__e priceChange = new RV_PriceChange__e();
        	 if(!priceLst.isEmpty()){
                 for(RV_PriceChange__e prcLst : priceLst){
                     if(prcLst.Price_Changed__c){
                         priceChange = prcLst;
                         break;
                     }
                 }
                    try{
                         prcChangeVal = EventBus.publish(priceChange);
                       
                             if (prcChangeVal.isSuccess()) {
                                 // Operation was successful, so get the ID of the record that was processed
                                 System.debug('Successfully called publish event. ' + prcChangeVal.getId());
                             }
                             else {
                                 
                             }
                       
                        
                    }catch(Exception e){
                        System.debug('--------'+e);
                      
                    }
        	}
        	return prcChangeVal;
    } 
}