public class LiveATPPSPDemoController{
    
    /* PBI_166252_DataCleanup_Lakshmi_1stOct2019 == Commented PSP Object Related fields
     * 
     * */
    @AuraEnabled
    public static List<ATPWrap> getAllATPList(List<String> channel, String window, String locType){
        system.debug('inside LiveATPPSPDemoController----'+ channel + '--' + window + '--' +locType);
        List<ATP__c> atpList = new List<ATP__c>();
     //   List<PSP__c> PspList = new List<PSP__c>();
                
        Set<Id> LocIds= new Set<Id>();
      //  Map<string,PSP__c> pspMap= new  Map<string,PSP__c>();
        Map<string,ATP__c> atpMap= new  Map<string,ATP__c>();
        Map<string,ATP__c> atpLocMap= new Map<string,ATP__c>();
        Set<String> allLocationSet = new Set<String>();
        String myLocationString = '';
        atpList = [SELECT Id ,
                          Name,
                          Location__c,
                          Location__r.Name,
                          Plant_Code__c,
                          Location_Name__c,
                          Grade_Level2__c,
                          Company_code__c,
                          ATP_Live__c,
                          ATP2_Live__c,
                          ATP3_Live__c ,
                          Lifting_Validity_From1__c,
                          Lifting_Validity_From2__c,
                          Lifting_Validity_From3__c,
                          Live_Online_00_14__c, 
                          Live_Online_ATP2__c,
                          Live_Online_ATP3__c,
                          Location__r.Abbreviated_Name__c, //270224_OLFLiveOnline_09Jul2019_Soumyajit
                          Comment_Prompt_Sales__c,
                          Comment_Forward_Sales__c ,
                          Sales_D_00_14__c,
                          Sales_D_15_28__c,
                          Sales_D_29_61__c,
                          Sales_8_30_17_30__c,
                          Sales_15_28__c,
                          Sales_29_61__c, //FIX: 326425_12sep2019_Lakshmi
                          Location__r.Related_Plant__c,
                          Location__r.Related_Plant_Code__c FROM ATP__c WHERE Company_code__c IN : channel ORDER BY Location__r.Name ASC];
        System.debug('-------atpList size--------:'+atpList.size());
        for(ATP__c atp: atpList){
            LocIds.add(atp.Location__c);
            allLocationSet.add(atp.Plant_Code__c);
        }

        Map<String,String> mapRelatedATP = new Map<String,String>();	//Fix_437452_02Mar2020_Soumyajit
       
        for(ATP__c at:atpList){
            atpMap.put(at.Plant_Code__c+at.Grade_Level2__c, at);
            atpLocMap.put(at.Plant_Code__c,at);
            
            if(at.location__r.Related_Plant_Code__c != null)
                mapRelatedATP.put(at.Plant_Code__c,at.location__r.Related_Plant_Code__c);	//Fix_437452_02Mar2020_Soumyajit
        }
        
        //Fix_437452_02Mar2020_Soumyajit starts
        for(ATP__c at:atpList)
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
                    atpLocMap.put(at.Plant_Code__c,at);
                }
            }
        }
        //Fix_437452_02Mar2020_Soumyajit ends
        
        List<ATPWrap> atpWrpLst= new List<ATPWrap>();
        List<ATPWrap> myLocAtpLst= new List<ATPWrap>();
        List<ATPWrap> myDELocAtpLst= new List<ATPWrap>();
        List<ATPWrap> myATLocAtpLst= new List<ATPWrap>();
        List<ATPWrap> allLocAtpLst= new List<ATPWrap>();
        List<ATPWrap> customizeLocAtpLst= new List<ATPWrap>();
        //Added as enhancement - Srikrishna
        Id loggedInUserId = UserInfo.getUserId();
        User loggedInUser = [Select Id, Name, My_DE_Locations__c, My_AT_Locations__c from User where Id =: loggedInUserId];
        //String myLocations = loggedInUser.My_Locations__c;
        //My_DE_Locations__c, My_AT_Locations__c
        String myDELocations = loggedInUser.My_DE_Locations__c;
        String myATLocations = loggedInUser.My_AT_Locations__c;
        Map<String, String> myLocationsMap = new Map<String, String>();
        Map<String, String> myATLocationsMap = new Map<String, String>();
        Map<String, String> myDELocationsMap = new Map<String, String>();
        List<String> myLocationList = new List<String>();
        List<String> myDELocationList = new List<String>();
        List<String> myATLocationList = new List<String>();
        
        if(myDELocations != null){
            myDELocationList = myDELocations.split(',');
        }        
        if(myATLocations != null){
            myATLocationList = myATLocations.split(',');
        }        
        myLocationList.addAll(myDELocationList);
        myLocationList.addAll(myATLocationList);
        
        for(String plantcode : myLocationList){
            myLocationsMap.put(plantcode, plantcode);
        }
        if(atpMap.size()>0){
            for(String key :atpLocMap.keySet()){
                
                if(window == 'ATP1'){
                    ATPWrap wrpAtp = new ATPWrap();
                    wrpAtp.locChannel = atpLocMap.get(key).company_code__c;
                    wrpAtp.locName=(atpLocMap.get(key)).Location__r.Name;
                    wrpAtp.locCode=key;
                    wrpAtp.locAbbrName=((atpLocMap.get(key)).Location__r.Abbreviated_Name__c == null ? (atpLocMap.get(key)).Location__r.Name : (atpLocMap.get(key)).Location__r.Abbreviated_Name__c); //270224_OLFLiveOnline_09Jul2019_Soumyajit
                    
                    //AGO B7
                    //system.debug('AGO B7==>'+key+'AGO B7');
                    if(atpMap.containsKey(key+'AGO B7')){
                        if((atpMap.get(key+'AGO B7')).ATP_Live__c != null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpAGO=((atpMap.get(key+'AGO B7')).ATP_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpAGO=((atpMap.get(key+'AGO B7')).ATP_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                           //FIX: 250519_Lakshmi_Ends
                            wrpAtp.atpAGOString = RV_LocaleHelper.formattedNumber(wrpAtp.atpAGO);
                        // wrpAtp.atpAGOString = ''+wrpAtp.atpAGO;
                        }                
                        if((atpMap.get(key+'AGO B7')).Lifting_Validity_From1__c !=null){
                            wrpAtp.dateAGO=(atpMap.get(key+'AGO B7')).Lifting_Validity_From1__c;
                        }                
                        if((atpMap.get(key+'AGO B7')).Comment_Prompt_Sales__c != null){
                            wrpAtp.commentAGO=(atpMap.get(key+'AGO B7')).Comment_Prompt_Sales__c;
                        } 
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'AGO B7')).Sales_8_30_17_30__c != null){
                        	wrpAtp.salesValueAGO= ((atpMap.get(key+'AGO B7')).Sales_8_30_17_30__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                        }
                         //FIX: 326425_12sep2019_Lakshmi_Ends
                         
                        if((atpMap.get(key+'AGO B7')).Live_Online_00_14__c != null){
                            wrpAtp.AGOonline = ((atpMap.get(key+'AGO B7')).Live_Online_00_14__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                            wrpAtp.atpAGOonline = RV_LocaleHelper.formattedNumber(wrpAtp.AGOonline);
                        }
                        //270224_OLFLiveOnline_09Jul2019_Soumyajit ends
                    }
                    //IGO 50ppm
                    //system.debug('IGO 50ppm==>'+key+'IGO 50ppm');
                    if(atpMap.containsKey(key+'IGO 50ppm')){
                        if((atpMap.get(key+'IGO 50ppm')).ATP_Live__c !=null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpIGO=((atpMap.get(key+'IGO 50ppm')).ATP_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpIGO=((atpMap.get(key+'IGO 50ppm')).ATP_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                         	//FIX: 250519_Lakshmi_Ends
                         	
                            // wrpAtp.atpIGO=500000000;
                            wrpAtp.atpIGOString = RV_LocaleHelper.formattedNumber(wrpAtp.atpIGO);
                            //wrpAtp.atpIGOString=''+wrpAtp.atpIGO;
                        }                
                        if((atpMap.get(key+'IGO 50ppm')).Lifting_Validity_From1__c !=null){
                            wrpAtp.dateIGO=(atpMap.get(key+'IGO 50ppm')).Lifting_Validity_From1__c;
                        }                
                        if((atpMap.get(key+'IGO 50ppm')).Comment_Prompt_Sales__c != null){
                            wrpAtp.commentIGO=(atpMap.get(key+'IGO 50ppm')).Comment_Prompt_Sales__c;
                        }    
                        //wrpAtp.salesValueIGO = (atpLocMap.get(key)).Sales_D_00_14__c;
                        
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'IGO 50ppm')).Sales_8_30_17_30__c != null){
                        	wrpAtp.salesValueIGO= ((atpMap.get(key+'IGO 50ppm')).Sales_8_30_17_30__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue() ;	
                            system.debug('wrpAtp.salesValueIGO'+wrpAtp.salesValueIGO);
                        }
                        //FIX: 326425_12sep2019_Lakshmi_Ends
                        
                        if((atpMap.get(key+'IGO 50ppm')).Live_Online_00_14__c != null){
                            wrpAtp.IGOonline = ((atpMap.get(key+'IGO 50ppm')).Live_Online_00_14__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                            wrpAtp.atpIGOonline = RV_LocaleHelper.formattedNumber(wrpAtp.IGOonline);
                        }
                    }
                    //ULG95 E5
                    //system.debug('ULG95 E5==>'+key+'ULG95 E5');
                    if(atpMap.containsKey(key+'ULG95 E5')){
                        if((atpMap.get(key+'ULG95 E5')).ATP_Live__c !=null){
                            //FIX: 250519_Lakshmi_starts
                   //wrpAtp.atpULG=((atpMap.get(key+'ULG95 E5')).ATP_Live__c/Decimal.valueOf(Label.Mogas_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpULG=((atpMap.get(key+'ULG95 E5')).ATP_Live__c/Decimal.valueOf(Label.Mogas_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            //FIX: 250519_Lakshmi_Ends
                            wrpAtp.atpULGString = RV_LocaleHelper.formattedNumber(wrpAtp.atpULG);
                        }                
                        if((atpMap.get(key+'ULG95 E5')).Lifting_Validity_From1__c != null){
                            wrpAtp.dateULG=(atpMap.get(key+'ULG95 E5')).Lifting_Validity_From1__c;
                        }                
                        if((atpMap.get(key+'ULG95 E5')).Comment_Prompt_Sales__c != null){
                            wrpAtp.commentULG=(atpMap.get(key+'ULG95 E5')).Comment_Prompt_Sales__c;
                        }
                        //wrpAtp.salesValueULG = (atpLocMap.get(key)).Sales_D_00_14__c;
                        
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'ULG95 E5')).Sales_8_30_17_30__c != null){
                        	wrpAtp.salesValueULG= ((atpMap.get(key+'ULG95 E5')).Sales_8_30_17_30__c/Decimal.valueOf(Label.Mogas_Density)).intValue();
                        }
                        
  						//FIX: 326425_12sep2019_Lakshmi_Ends
                        
                        if((atpMap.get(key+'ULG95 E5')).Live_Online_00_14__c != null){
                            wrpAtp.MOGASonline = ((atpMap.get(key+'ULG95 E5')).Live_Online_00_14__c/Decimal.valueOf(Label.Mogas_Density)).intValue();
                            wrpAtp.atpMOGASonline = RV_LocaleHelper.formattedNumber(wrpAtp.MOGASonline);
                        }
                    }
                    atpWrpLst.add(wrpAtp);
                }
                //ATP2
                else if(window == 'ATP2'){
                    ATPWrap wrpAtp = new ATPWrap();
                    wrpAtp.locChannel = atpLocMap.get(key).company_code__c;
                    wrpAtp.locName=(atpLocMap.get(key)).Location__r.Name;
                    wrpAtp.locCode=key;
                    wrpAtp.locAbbrName=((atpLocMap.get(key)).Location__r.Abbreviated_Name__c == null ? (atpLocMap.get(key)).Location__r.Name : (atpLocMap.get(key)).Location__r.Abbreviated_Name__c); //270224_OLFLiveOnline_09Jul2019_Soumyajit
                    
                    //AGO B7
                    //system.debug('AGO B7==>'+key+'AGO B7');
                    if(atpMap.containsKey(key+'AGO B7')){
                        if((atpMap.get(key+'AGO B7')).ATP2_Live__c != null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpAGO=((atpMap.get(key+'AGO B7')).ATP2_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).round(System.RoundingMode.HALF_UP).intvalue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpAGO=((atpMap.get(key+'AGO B7')).ATP2_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).intvalue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                           //FIX: 250519_Lakshmi_Ends
                            wrpAtp.atpAGOString = RV_LocaleHelper.formattedNumber(wrpAtp.atpAGO);
                        }                
                        if((atpMap.get(key+'AGO B7')).Lifting_Validity_From2__c !=null){
                            wrpAtp.dateAGO=(atpMap.get(key+'AGO B7')).Lifting_Validity_From2__c;
                        }                
                        if((atpMap.get(key+'AGO B7')).Comment_Forward_Sales__c != null){
                            wrpAtp.commentAGO=(atpMap.get(key+'AGO B7')).Comment_Forward_Sales__c;
                        } 
                        //wrpAtp.salesValueAGO = (atpLocMap.get(key)).Sales_D_15_28__c;
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'AGO B7')).Sales_15_28__c != null){
                        	wrpAtp.salesValueAGO= ((atpMap.get(key+'AGO B7')).Sales_15_28__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                        }
                        //FIX: 326425_12sep2019_Lakshmi_Ends

                        //START - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 2 online deals
                        if((atpMap.get(key+'AGO B7')).Live_Online_ATP2__c != null){
                            wrpAtp.AGOonline = ((atpMap.get(key+'AGO B7')).Live_Online_ATP2__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                            wrpAtp.atpAGOonline = RV_LocaleHelper.formattedNumber(wrpAtp.AGOonline);
                        }
                        //END - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 2 online deals
                    }
                    //IGO 50ppm    
                    //system.debug('IGO 50ppm==>'+key+'IGO 50ppm');
                    if(atpMap.containsKey(key+'IGO 50ppm')){
                        if((atpMap.get(key+'IGO 50ppm')).ATP2_Live__c !=null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpIGO=((atpMap.get(key+'IGO 50ppm')).ATP2_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpIGO=((atpMap.get(key+'IGO 50ppm')).ATP2_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                           //FIX: 250519_Lakshmi_Ends
                            wrpAtp.atpIGOString = RV_LocaleHelper.formattedNumber(wrpAtp.atpIGO);
                        }                
                        if((atpMap.get(key+'IGO 50ppm')).Lifting_Validity_From2__c !=null){
                            wrpAtp.dateIGO=(atpMap.get(key+'IGO 50ppm')).Lifting_Validity_From2__c;
                        }                
                        if((atpMap.get(key+'IGO 50ppm')).Comment_Forward_Sales__c != null){
                            wrpAtp.commentIGO=(atpMap.get(key+'IGO 50ppm')).Comment_Forward_Sales__c;
                        }
                        //wrpAtp.salesValueIGO = (atpLocMap.get(key)).Sales_D_15_28__c;
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'IGO 50ppm')).Sales_15_28__c != null){
                        	wrpAtp.salesValueIGO= ((atpMap.get(key+'IGO 50ppm')).Sales_15_28__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                        }
                        //FIX: 326425_12sep2019_Lakshmi_Ends
                        //START - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 2 online deals
                        if((atpMap.get(key+'IGO 50ppm')).Live_Online_ATP2__c != null){
                            wrpAtp.IGOonline = ((atpMap.get(key+'IGO 50ppm')).Live_Online_ATP2__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                            wrpAtp.atpIGOonline = RV_LocaleHelper.formattedNumber(wrpAtp.IGOonline);
                        }
                        //END - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 2 online deals
                    }
                    //ULG95 E5  
                    //system.debug('ULG95 E5==>'+key+'ULG95 E5');
                    if(atpMap.containsKey(key+'ULG95 E5')){
                        if((atpMap.get(key+'ULG95 E5')).ATP2_Live__c !=null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpULG=((atpMap.get(key+'ULG95 E5')).ATP2_Live__c/Decimal.valueOf(Label.Mogas_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpULG=((atpMap.get(key+'ULG95 E5')).ATP2_Live__c/Decimal.valueOf(Label.Mogas_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            //FIX: 250519_Lakshmi_ends
                            wrpAtp.atpULGString = RV_LocaleHelper.formattedNumber(wrpAtp.atpULG);
                        }                
                        if((atpMap.get(key+'ULG95 E5')).Lifting_Validity_From2__c != null){
                            wrpAtp.dateULG=(atpMap.get(key+'ULG95 E5')).Lifting_Validity_From2__c;
                        }                
                        if((atpMap.get(key+'ULG95 E5')).Comment_Forward_Sales__c != null){
                            wrpAtp.commentULG=(atpMap.get(key+'ULG95 E5')).Comment_Forward_Sales__c;    
                        }
                        //wrpAtp.salesValueULG = (atpLocMap.get(key)).Sales_D_15_28__c;
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'ULG95 E5')).Sales_15_28__c != null){
                        	wrpAtp.salesValueULG= ((atpMap.get(key+'ULG95 E5')).Sales_15_28__c/Decimal.valueOf(Label.Mogas_Density)).intValue();
                        }
                        //FIX: 326425_12sep2019_Lakshmi_Ends
                        //START - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 2 online deals
                        if((atpMap.get(key+'ULG95 E5')).Live_Online_ATP2__c != null){
                            wrpAtp.MOGASonline = ((atpMap.get(key+'ULG95 E5')).Live_Online_ATP2__c/Decimal.valueOf(Label.Mogas_Density)).intValue();
                            wrpAtp.atpMOGASonline = RV_LocaleHelper.formattedNumber(wrpAtp.MOGASonline);
                        }
                        //END - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 2 online deals
                    }
                    atpWrpLst.add(wrpAtp);
                }
                //ATP3
                else{
                    ATPWrap wrpAtp = new ATPWrap();
                    wrpAtp.locChannel = atpLocMap.get(key).company_code__c;
                    wrpAtp.locName=(atpLocMap.get(key)).Location__r.Name;
                    wrpAtp.locCode=key;
                    wrpAtp.locAbbrName=((atpLocMap.get(key)).Location__r.Abbreviated_Name__c == null ? (atpLocMap.get(key)).Location__r.Name : (atpLocMap.get(key)).Location__r.Abbreviated_Name__c); //270224_OLFLiveOnline_09Jul2019_Soumyajit
                    
                    //AGO B7
                    //system.debug('AGO B7==>'+key+'AGO B7');
                    if(atpMap.containsKey(key+'AGO B7')){
                        if((atpMap.get(key+'AGO B7')).ATP3_Live__c != null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpAGO=((atpMap.get(key+'AGO B7')).ATP3_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpAGO=((atpMap.get(key+'AGO B7')).ATP3_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                         	//FIX: 250519_Lakshmi_ends
                            wrpAtp.atpAGOString = RV_LocaleHelper.formattedNumber(wrpAtp.atpAGO);
                        }                
                        if((atpMap.get(key+'AGO B7')).Lifting_Validity_From3__c !=null){
                            wrpAtp.dateAGO=(atpMap.get(key+'AGO B7')).Lifting_Validity_From3__c;
                        }                
                        if((atpMap.get(key+'AGO B7')).Comment_Forward_Sales__c != null){
                            wrpAtp.commentAGO=(atpMap.get(key+'AGO B7')).Comment_Forward_Sales__c;
                        }
                        //wrpAtp.salesValueAGO = (atpLocMap.get(key)).Sales_D_29_61__c;
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'AGO B7')).Sales_29_61__c!= null){
                        	wrpAtp.salesValueAGO= ((atpMap.get(key+'AGO B7')).Sales_29_61__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                        }
                        //FIX: 326425_12sep2019_Lakshmi_Ends
                        //START - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 3 online deals.
                        if((atpMap.get(key+'AGO B7')).Live_Online_ATP3__c != null){
                            wrpAtp.AGOonline = ((atpMap.get(key+'AGO B7')).Live_Online_ATP3__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                            wrpAtp.atpAGOonline = RV_LocaleHelper.formattedNumber(wrpAtp.AGOonline);
                        }
                        //END - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 3 online deals.
                    }
                    //IGO 50ppm
                    //system.debug('IGO 50ppm==>'+key+'IGO 50ppm');
                    if(atpMap.containsKey(key+'IGO 50ppm')){
                        if((atpMap.get(key+'IGO 50ppm')).ATP3_Live__c !=null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpIGO=((atpMap.get(key+'IGO 50ppm')).ATP3_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpIGO=((atpMap.get(key+'IGO 50ppm')).ATP3_Live__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            //FIX: 250519_Lakshmi_ends
                            wrpAtp.atpIGOString = RV_LocaleHelper.formattedNumber(wrpAtp.atpIGO);
                        }                
                        if((atpMap.get(key+'IGO 50ppm')).Lifting_Validity_From3__c !=null){
                            wrpAtp.dateIGO=(atpMap.get(key+'IGO 50ppm')).Lifting_Validity_From3__c;
                        }                
                        if((atpMap.get(key+'IGO 50ppm')).Comment_Forward_Sales__c != null){
                            wrpAtp.commentIGO=(atpMap.get(key+'IGO 50ppm')).Comment_Forward_Sales__c;
                        }  
                        //wrpAtp.salesValueIGO = (atpLocMap.get(key)).Sales_D_29_61__c;
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'IGO 50ppm')).Sales_29_61__c != null){
                        	wrpAtp.salesValueIGO= ((atpMap.get(key+'IGO 50ppm')).Sales_29_61__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                        }
                        //FIX: 326425_12sep2019_Lakshmi_Ends
                        //START - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 3 online deals
                        if((atpMap.get(key+'IGO 50ppm')).Live_Online_ATP3__c != null){
                            wrpAtp.IGOonline = ((atpMap.get(key+'IGO 50ppm')).Live_Online_ATP3__c/Decimal.valueOf(Label.AGO_IGO_Density)).intValue();
                            wrpAtp.atpIGOonline = RV_LocaleHelper.formattedNumber(wrpAtp.IGOonline);
                        }
                        //END - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 3 online deals
                    }
                    //ULG95 E5
                    //system.debug('ULG95 E5==>'+key+'ULG95 E5');
                    if(atpMap.containsKey(key+'ULG95 E5')){
                        if((atpMap.get(key+'ULG95 E5')).ATP3_Live__c !=null){
                            //FIX: 250519_Lakshmi_starts
                            //wrpAtp.atpULG=((atpMap.get(key+'ULG95 E5')).ATP3_Live__c/Decimal.valueOf(Label.Mogas_Density)).round(System.RoundingMode.HALF_UP).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                            wrpAtp.atpULG=((atpMap.get(key+'ULG95 E5')).ATP3_Live__c/Decimal.valueOf(Label.Mogas_Density)).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                           //FIX: 250519_Lakshmi_ends
                            wrpAtp.atpULGString = RV_LocaleHelper.formattedNumber(wrpAtp.atpULG);
                        }                
                        if((atpMap.get(key+'ULG95 E5')).Lifting_Validity_From3__c != null){
                            wrpAtp.dateULG=(atpMap.get(key+'ULG95 E5')).Lifting_Validity_From3__c;
                        }                
                        if((atpMap.get(key+'ULG95 E5')).Comment_Forward_Sales__c != null){
                            wrpAtp.commentULG=(atpMap.get(key+'ULG95 E5')).Comment_Forward_Sales__c; 
                        } 
                        //wrpAtp.salesValueULG = (atpLocMap.get(key)).Sales_D_29_61__c;
                        //FIX: 326425_12sep2019_Lakshmi_starts
                        if((atpMap.get(key+'ULG95 E5')).Sales_29_61__c != null){
                        	wrpAtp.salesValueULG= ((atpMap.get(key+'ULG95 E5')).Sales_29_61__c/Decimal.valueOf(Label.Mogas_Density)).intValue();
                        }
                        //FIX: 326425_12sep2019_Lakshmi_Ends
                        //START - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 3 online deals
                        if((atpMap.get(key+'ULG95 E5')).Live_Online_ATP3__c != null){
                            wrpAtp.MOGASonline = ((atpMap.get(key+'ULG95 E5')).Live_Online_ATP3__c/Decimal.valueOf(Label.Mogas_Density)).intValue();
                            wrpAtp.atpMOGASonline = RV_LocaleHelper.formattedNumber(wrpAtp.MOGASonline);
                        }
                        //END - Rahul Sharma | Date - 09-Nov-2020 : Added logic to display Tranche 3 online deals
                    }
                 /*   if(pspMap.containsKey(key+'ULG95 E5')){
                        if((pspMap.get(key+'ULG95 E5')).PSP3__c != null){
                            wrpAtp.pspULG=(pspMap.get(key+'ULG95 E5')).PSP3__c.setScale(2, RoundingMode.HALF_UP);
                            wrpAtp.pspULGString = RV_LocaleHelper.formattedDecimal(wrpAtp.pspULG);
                        }            
                    }*/

                    atpWrpLst.add(wrpAtp);
                }
            } 
        } 
        
        //Return only Loggedin Users Locations
        if(locType == 'My'){     
            for(ATPWrap myAtpLocation : atpWrpLst){
                if(myLocationsMap.containsKey(myAtpLocation.locCode)){
                    myLocAtpLst.add(myAtpLocation);
                }
            }
            return myLocAtpLst;        
        }
        //Return All Locations
        if(locType == 'All'){
            return atpWrpLst;    
        }
        //Get the Selected Location List
        if(locType == 'Customize'){
            for(ATPWrap myAtpLocation : atpWrpLst){
                if(myLocationsMap.containsKey(myAtpLocation.locCode)){
                    myAtpLocation.selected = true;
                    customizeLocAtpLst.add(myAtpLocation);
                }else{
                    customizeLocAtpLst.add(myAtpLocation);
                }
            }
            return customizeLocAtpLst;
        }
        return atpWrpLst;
    }

    @AuraEnabled
    public static String saveLocationPref(String dataList, List<String> channel){
        
        List<ATPWrap> listToUpdate = (List<ATPWrap>)JSON.deserialize(dataList, List<ATPWrap>.class); 
        List<String> selectedATLocList = new List<String>();
        List<String> selectedDELocList = new List<String>();
        List<String> selectedLocList = new List<String>();
        
        String myATLocationString = '';
        String myDELocationString = '';
        String myLocationString = ''; 
        
        User loggedInUser = [Select Id, Name, My_DE_Locations__c, My_AT_Locations__c from User where Id =: UserInfo.getUserId()];

        if(channel.size() == 2){
            
            for(ATPWrap wrap: listToUpdate){
                if(wrap.selected == true && wrap.locChannel == 'AT01'){
                    selectedATLocList.add(wrap.locCode);
                }
                if(wrap.selected == true && wrap.locChannel == 'DE01'){
                    selectedDELocList.add(wrap.locCode);
                }    
            }

            if(!selectedATLocList.isEmpty()){
                myATLocationString = String.join(selectedATLocList, ',');
            }
            if(!selectedDELocList.isEmpty()){
                myDELocationString = String.join(selectedDELocList, ',');
            }
            
            
            loggedInUser.My_AT_Locations__c = myATLocationString;
            loggedInUser.My_DE_Locations__c = myDELocationString;
            update loggedInUser;
        }
      
        if(channel.size() == 1){
            if(channel[0] == 'AT01'){
            
                for(ATPWrap wrap: listToUpdate){
                    if(wrap.selected == true){
                        selectedATLocList.add(wrap.locCode);
                    }
                            
                }
                
                myATLocationString = String.join(selectedATLocList, ',');
                loggedInUser.My_AT_Locations__c = myATLocationString;
                //system.debug('loggedInUser.My_AT_Locations__c==>'+loggedInUser.My_AT_Locations__c);
                update loggedInUser;
            }  
            if(channel[0] == 'DE01'){            
                for(ATPWrap wrap: listToUpdate){
                    if(wrap.selected == true ){
                        selectedDELocList.add(wrap.locCode);  
                    }
                           
                }
               
                myDELocationString = String.join(selectedDELocList, ',');
                loggedInUser.My_DE_Locations__c = myDELocationString;                 
                update loggedInUser;
            }  
        }
                                        
        return 'SUCCESS';
                                             
    }

    Public class ATPWrap{
        @AuraEnabled
        public String locName {get;set;}
        @AuraEnabled
        public String locCode {get;set;}
        @AuraEnabled
        public Integer atpAGO {get;set;}
        @AuraEnabled
        public String atpAGOString {get;set;}
        @AuraEnabled
        public Decimal pspAGO {get;set;}
        @AuraEnabled
        public String pspAGOString;
        @AuraEnabled
        public Date dateAGO {get;set;}
        @AuraEnabled
        public string commentAGO {get;set;}
        @AuraEnabled
        public Integer atpIGO {get;set;}
        @AuraEnabled
        public String atpIGOString {get;set;}
        @AuraEnabled
        public Decimal pspIGO {get;set;}
        @AuraEnabled
        public String pspIGOString {get;set;}
        @AuraEnabled
        public Date dateIGO {get;set;}
        @AuraEnabled
        public string commentIGO {get;set;}
        @AuraEnabled
        public Integer atpULG {get;set;}
        @AuraEnabled
        public String atpULGString {get;set;}
        @AuraEnabled
        public String pspULGString {get;set;}
        @AuraEnabled
        public Decimal pspULG {get;set;}
        @AuraEnabled
        public Date dateULG {get;set;}
        @AuraEnabled
        public string commentULG {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}
        @AuraEnabled
        public String locChannel {get;set;}
        @AuraEnabled
        public Decimal salesValueAGO {get;set;}
        @AuraEnabled
        public Decimal salesValueIGO {get;set;}
        @AuraEnabled
        public Decimal salesValueULG {get;set;}
        //270224_OLFLiveOnline_09Jul2019_Soumyajit starts
        @AuraEnabled
        public String locAbbrName {get;set;}
        @AuraEnabled
        public Integer AGOonline {get;set;}
        @AuraEnabled
        public String atpAGOonline {get;set;}
        @AuraEnabled
        public Integer IGOonline {get;set;}
        @AuraEnabled
        public String atpIGOonline {get;set;}
        @AuraEnabled
        public Integer MOGASonline {get;set;}
        @AuraEnabled
        public String atpMOGASonline {get;set;}
        //270224_OLFLiveOnline_09Jul2019_Soumyajit ends
    }
}