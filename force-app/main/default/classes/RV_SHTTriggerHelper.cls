/*****************************************************************************
@Name:  RV_SHTTriggerHelper     
@=========================================================================
@Purpose: Trigger handler will execute on insert and update to calculate ATP_Live__c and Sales_8_30_17_30__c value  
          ATP_Live__c = ATP_Live__c - quantityCBM;
          Sales_8_30_17_30__c = Sales_8_30_17_30__c + quantityCBM;

@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      26/09/2017         INITIAL DEVELOPMENT
@1.1 - Reshu Seth                        04/10/2017         Added logic to calcuate ATP2_Live__c and ATP3_Live__c and 
                                                            Sales_8_30_17_30__c value
@1.2 - Dhriti                            13/11/2017                         
                                                            if status = Cancelled
                                                            ATP1_Live__c = ATP1_Live__c + Volume CBM
                                                            ATP3_Live__c = ATP3_Live__c + Volume CBM
                                                            ATP2_Live__c = ATP2_Live__c + Volume CBM
                                                            Sales_8_30_17_30__c = Sales_8_30_17_30__c - Volume CBM 
                                                            else
                                                            ATP1_Live__c = ATP1_Live__c - Volume CBM
                                                            ATP3_Live__c = ATP3_Live__c - Volume CBM
                                                            ATP2_Live__c = ATP2_Live__c - Volume CBM
                                                            Sales_8_30_17_30__c = Sales_8_30_17_30__c + Volume CBM

@1.3 - Rahul Sharma                      11/11/2020         Added logic to deduct Live online volume for tranche2 and tranche3.
@1.4 - Rahul Sharma                      02/03/2021         Added logic to allot transaction Id to be sent to GSAP via SAP Staging object.
******************************************************************************/
public class RV_SHTTriggerHelper {
    
    public static boolean recursion = true;
    public static boolean recursionshtDave = true;
    public static boolean recursionSHTUpdate = true;
    
    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit starts
    public static boolean isOlfDeal = false;
    public static boolean sales1AlreadyUpdated = false;
    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit ends
    
    /*Method Name	:	onBeforeInsert
    * Date			:	02-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method contains action to perform on before insert.*/
    public static void onBeforeInsert(List<SHT__c> shtListNew){
        allotTransactionId(shtListNew);
    }

    /*Method Name	:	onAfterUpdate
    * Date			:	26-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method contains action to perform on after update.*/
    public static void onAfterUpdate(List<SHT__c> shtListNew, List<SHT__c> shtListOld, Map<Id, SHT__c> shtNewMap, Map<Id, SHT__c> shtOldMap){
        updateOlfDealNoInStagning(shtNewMap, shtOldMap);
    }

    public static void onAfterInsertSHTTriggerHelper(List<SHT__c> shtLst,Map<ID,SHT__c> oldSHTMap){

       
        Map<String,List<SHT__c>> newproductnLocationMapLst = new Map<String,List<SHT__c>>();
        Map<String,List<SHT__c>> oldProductnLocationMapLst = new Map<String,List<SHT__c>>();
        
        List<String> productset = new List<String>();
        List<String> locationset = new List<String>();
        List<SHT__c> fetchshtLst = RV_DAL.fetchSHTRecord(shtLst);
        //system.debug('fetchshtLst==>'+fetchshtLst);
        
       
       // system.debug('fetchshtLst size==>'+fetchshtLst.size());
        
        List<Product_Name_Mapping__mdt> fetchProductMappingMD = [SELECT ID,MasterLabel,DeveloperName,Product_Name__c from 
                                                                 Product_Name_Mapping__mdt];
        
        Map<String,Product_Name_Mapping__mdt> MapOfProductMapping = new Map<String,Product_Name_Mapping__mdt>();
        
        MapOfProductMapping = mappingOFPRoduct(fetchProductMappingMD);
        
        //System.debug('^^^^^^^^^^^^^^'+MapOfProductMapping);
        
        
        for(SHT__c shtInterate : fetchshtLst){ // fetch SHT record on after insert/update
            
            String productName = '';
            if((shtInterate.Product_Category__c <> null || shtInterate.Location__c <> null) && shtInterate.IsATPVolumeReduced__c == true ){// if product catalogue not null
               
                if(MapOfProductMapping.containsKey(shtInterate.Product_Category__c)){
                    
                    	productName = MapOfProductMapping.get(shtInterate.Product_Category__c).Product_Name__c;
                } 
                
                //new Record Map
                if(!newproductnLocationMapLst.containsKey(productName+''+shtInterate.Location__c)){
                    
                    newproductnLocationMapLst.put(productName+''+shtInterate.Location__c, new List<SHT__c>{shtInterate});
                
                }else{
                    
                    List<SHT__c> newSHTList = newproductnLocationMapLst.get(productName+''+shtInterate.Location__c);
                    newSHTList.add(shtInterate);
                    newproductnLocationMapLst.put(productName+''+shtInterate.Location__c , newSHTList);
                    //System.debug('&&&&&&&newproductnLocationMapLst&&&&&'+newproductnLocationMapLst);
                }
                
                if(shtInterate.Location__c <> null){
                    
                	locationset.add(shtInterate.Location__c);
                    
                }
                
                if(productName  <> null){
                    
                	productset.add(productName);
                    
                }
                
            }
        }
        
       

        //System.debug('$$$$$$$newproductnLocationMapLst$$$$$$'+newproductnLocationMapLst);
        
        List<ATP__c> quryATP = new List<ATP__c>();
        
        if(locationset <> null && productset <> null){
            
        	quryATP = RV_DAL.fetchATPRecord(productset,locationset); 
        }
        
         //System.debug('$$$$$$$quryATP$$$$$$'+quryATP);
       
        List<ATP__c> updatequryATP  = new  List<ATP__c>();
        List<SHT__c> updateSHTLst  = new  List<SHT__c>();
        
        
        if(quryATP <> null  && quryATP.size()> 0){
            
             for(ATP__c iterateatp : quryATP){
                 
                String productLocationConcat = '';
                productLocationConcat = iterateatp.Grade_Level2__c+''+iterateatp.Location__c;
                
                ATP__c iterateatpOld = iterateatp.clone(); //CommentUpdateFix_10Jul2019_Soumyajit
                 
                if(newproductnLocationMapLst.containsKey(productLocationConcat)){
                    
                            List<SHT__c> fetchNewshtLst = newproductnLocationMapLst.get(productLocationConcat);
                    
                            Decimal atp1=0;
                            Decimal atp2=0;
                            Decimal atp3=0;
                            Decimal AGOIGO = 0.845;
                            Decimal ULG = 0.755;
                    		Decimal salesATP =0;
                            Decimal totalSalesATP1 = 0; //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit
                            //START - Rahul Sharma | Date - 11-Nov-2020 : Added variables to update total sales for tranche 2 and tranche 3/
                            Decimal totalSalesATP2 = 0;
                            Decimal totalSalesATP3 = 0;
                            //END - Rahul Sharma | Date - 11-Nov-2020 : Added variables to update total sales for tranche 2 and tranche 3/
                    
                            if(!fetchNewshtLst.isEmpty()){
                                
                                for(SHT__c str : fetchNewshtLst){
                                    
                                   if(str.Tranche__c <> null){
                                        
                                        if(MapOfProductMapping.containsKey(str.Product_Category__c)){
                                            
                                            String productName = MapOfProductMapping.get(str.Product_Category__c).Product_Name__c;
                                            
                                            if(productName == 'AGO B7' || productName== 'IGO 50ppm'){
                                                
                                                if(str.Tranche__c == Label.ATP1){
                                                    atp1+=(str.Volume_CBM__c * AGOIGO);
                                                    
                                                    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit starts
                                                    if(isOlfDeal)
                                                    {
                                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed')
                                                            totalSalesATP1 += (str.Volume_CBM__c * AGOIGO);
                                                        if(str.Status__c  == Label.SHT_Status_Cancelled)
                                                            totalSalesATP1 -= (str.Volume_CBM__c * AGOIGO);
                                                    }
                                                    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit ends
                                                    
                                                }else if(str.Tranche__c == Label.ATP2){
                                                    atp2+=(str.Volume_CBM__c * AGOIGO);
                                                    //START - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 2
                                                    if(isOlfDeal){
                                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed')
                                                            totalSalesATP2 += (str.Volume_CBM__c * AGOIGO);
                                                        if(str.Status__c  == Label.SHT_Status_Cancelled)
                                                            totalSalesATP2 -= (str.Volume_CBM__c * AGOIGO);
                                                    }
                                                    //END - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 2
                                                }
                                                else if(str.Tranche__c == Label.ATP3){
                                                    atp3+=(str.Volume_CBM__c * AGOIGO);
                                                    //START - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 3
                                                    if(isOlfDeal){
                                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed')
                                                            totalSalesATP3 += (str.Volume_CBM__c * AGOIGO);
                                                        if(str.Status__c  == Label.SHT_Status_Cancelled)
                                                            totalSalesATP3 -= (str.Volume_CBM__c * AGOIGO);
                                                    }
                                                    //END - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 3
                                                }
                                                
                                            }
                                            else if(productName == 'ULG95 E5'){    
                                                if(str.Tranche__c == Label.ATP1){
                                                    atp1+=(str.Volume_CBM__c * ULG);
                                                    
                                                    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit starts
                                                    if(isOlfDeal)
                                                    {
                                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed')
                                                            totalSalesATP1 += (str.Volume_CBM__c * ULG);
                                                        if(str.Status__c  == Label.SHT_Status_Cancelled)
                                                            totalSalesATP1 -= (str.Volume_CBM__c * ULG);
                                                    }
                                                    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit ends
                                                    
                                                }else if(str.Tranche__c == Label.ATP2){
                                                    atp2+=(str.Volume_CBM__c * ULG);
                                                    //START - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 2
                                                    if(isOlfDeal){
                                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed')
                                                            totalSalesATP2 += (str.Volume_CBM__c * ULG);
                                                        if(str.Status__c  == Label.SHT_Status_Cancelled)
                                                            totalSalesATP2 -= (str.Volume_CBM__c * ULG);
                                                    }
                                                    //END - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 2
                                                }
                                                else if(str.Tranche__c == Label.ATP3){
                                                    atp3+=(str.Volume_CBM__c * ULG);
                                                    //START - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 3
                                                    if(isOlfDeal){
                                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed')
                                                            totalSalesATP3 += (str.Volume_CBM__c * ULG);
                                                        if(str.Status__c  == Label.SHT_Status_Cancelled)
                                                            totalSalesATP3 -= (str.Volume_CBM__c * ULG);
                                                    }
                                                    //END - Rahul Sharma | Date - 11-Nov-2020 : Added logic to update total sales due to Online Sales for tranche 3
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                            if(atp1 <> 0){           
                                //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit starts
                                //iterateatp.ATP_Live__c = iterateatp.ATP_Live__c - atp1;
                                	if(iterateatp.Live_Online_00_14__c == null)
                                    	iterateatp.Live_Online_00_14__c = 0;
                                
                                    if(isOlfDeal)
                                    {                                        
                                        iterateatp.ATP_Live__c -= atp1;
                                        iterateatp.Live_Online_00_14__c -= atp1;
                                    }
                                	else
                                    {                                        
                                        if(atp1 > 0)
                                            {
                                               // System.debug('Split negating to ' + atp1);
                                                
                                                if(iterateatp.Live_Online_00_14__c == null)
                                                    iterateatp.Live_Online_00_14__c = 0;
                                                if(iterateatp.ATP_Live__c != null && iterateatp.Live_Online_00_14__c != null){
                                                    if(atp1 <= iterateatp.ATP_Live__c - iterateatp.Live_Online_00_14__c)
                                                    {
                                                        iterateatp.ATP_Live__c -= atp1;
                                                     }
                                                    else
                                                    {
                                                	    iterateatp.Live_Online_00_14__c -= (atp1 - (iterateatp.ATP_Live__c - iterateatp.Live_Online_00_14__c));
                                                        iterateatp.ATP_Live__c -= atp1;
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                //System.debug('Split restoring to ' + atp1);
                                                
                                                iterateatp.ATP_Live__c -= atp1;
                                            }
                                    }
                                    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit ends
                                
                            }
                            else if(atp2 <> 0){
                                //START - Rahul Sharma | Date - 11-Nov-2020 : Added ATP split logic for tranche2
                                if(iterateatp.Live_Online_ATP2__c == null)
                                    	iterateatp.Live_Online_ATP2__c = 0;
                                if(isOlfDeal){                                        
                                    iterateatp.ATP2_Live__c -= atp2;
                                    iterateatp.Live_Online_ATP2__c -= atp2;
                                }
                                else{
                                    if(atp2 > 0){
                                        if(iterateatp.Live_Online_ATP2__c == null)
                                            iterateatp.Live_Online_ATP2__c = 0;
                                        if(atp2 <= iterateatp.ATP2_Live__c - iterateatp.Live_Online_ATP2__c){
                                            iterateatp.ATP2_Live__c -= atp2;
                                        }
                                        else{
                                            iterateatp.Live_Online_ATP2__c -= (atp2 - (iterateatp.ATP2_Live__c - iterateatp.Live_Online_ATP2__c));
                                            iterateatp.ATP2_Live__c -= atp2;
                                        }
                                    }
                                    else
                                        iterateatp.ATP2_Live__c = iterateatp.ATP2_Live__c - atp2;
                                }
                                //END - Rahul Sharma | Date - 11-Nov-2020 : Added ATP split logic for tranche2
                            }
                            else if(atp3 <> 0){
                                //START - Rahul Sharma | Date - 11-Nov-2020 : Added ATP split logic for tranche3
                                if(iterateatp.Live_Online_ATP3__c == null)
                                    	iterateatp.Live_Online_ATP3__c = 0;
                                if(isOlfDeal){                                        
                                    iterateatp.ATP3_Live__c -= atp3;
                                    iterateatp.Live_Online_ATP3__c -= atp3;
                                }
                                else{
                                    if(atp3 > 0){
                                        if(iterateatp.Live_Online_ATP3__c == null)
                                            iterateatp.Live_Online_ATP3__c = 0;
                                        if(atp3 <= iterateatp.ATP3_Live__c - iterateatp.Live_Online_ATP3__c){
                                            iterateatp.ATP3_Live__c -= atp3;
                                        }
                                        else{
                                            iterateatp.Live_Online_ATP3__c -= (atp3 - (iterateatp.ATP3_Live__c - iterateatp.Live_Online_ATP3__c));
                                            iterateatp.ATP3_Live__c -= atp3;
                                        }
                                    }
                                    else
                                        iterateatp.ATP3_Live__c = iterateatp.ATP3_Live__c - atp3;
                                }
                                //END - Rahul Sharma | Date - 11-Nov-2020 : Added ATP split logic for tranche3
                            }
                    
                    		if(isOlfDeal){
                                //START - Rahul Sharma | Date - 11-nov-2020 : Added logic to update total sales for tranche 2 and tranche 3.
                                if(iterateatp.Sales_8_30_17_30__c == null)
                                    iterateatp.Sales_8_30_17_30__c = 0;
                                if(iterateatp.Sales_15_28__c == null)
                                    iterateatp.Sales_15_28__c = 0;
                                if(iterateatp.Sales_29_61__c == null)
                                    iterateatp.Sales_29_61__c = 0;

                    			if(totalSalesATP1 <> 0){
                                    iterateatp.Sales_8_30_17_30__c += totalSalesATP1;
                                    sales1AlreadyUpdated = true;
                                }
                                if(totalSalesATP2 <> 0){
                                    iterateatp.Sales_15_28__c += totalSalesATP2;
                                    sales1AlreadyUpdated = true;
                                }
                                if(totalSalesATP3 <> 0){
                                    iterateatp.Sales_29_61__c += totalSalesATP3;
                                    sales1AlreadyUpdated = true;
                                }
                                //END - Rahul Sharma | Date - 11-nov-2020 : Added logic to update total sales for tranche 2 and tranche 3.
                            }                    
                }
                 
                 //START - Rahul Sharma | Date - 11-nov-2020 : Added extra condition to include tranche 2 and tranche 3 live online sales.
                 if(iterateatp.ATP_Live__c != iterateatpOld.ATP_Live__c
                    || iterateatp.Live_Online_00_14__c != iterateatpOld.Live_Online_00_14__c
                    || iterateatp.Live_Online_ATP2__c != iterateatpOld.Live_Online_ATP2__c
                    || iterateatp.Live_Online_ATP3__c != iterateatpOld.Live_Online_ATP3__c
                    || iterateatp.ATP2_Live__c != iterateatpOld.ATP2_Live__c
                    || iterateatp.ATP3_Live__c != iterateatpOld.ATP3_Live__c
                    || iterateatp.Sales_8_30_17_30__c != iterateatpOld.Sales_8_30_17_30__c
                    || iterateatp.Sales_15_28__c != iterateatpOld.Sales_15_28__c
                    || iterateatp.Sales_29_61__c != iterateatpOld.Sales_29_61__c
                    )
                    //END - Rahul Sharma | Date - 11-nov-2020 : Added extra condition to include tranche 2 and tranche 3 live online sales.
                    updatequryATP.add(iterateatp);
                
             }
            
            if( recursion == true){
                
                if(updatequryATP <> null && updatequryATP.size() > 0){//update ATP_Live__c and Sales_8_30_17_30__c value
                    
                    try{
                        if(recursion == true){
                            recursion = false;
                        }
                        //System.debug('$$$$$$$updatequryATP$$$$$$'+updatequryATP);
                        update updatequryATP;
                    }catch(Exception e){
                        System.debug('$$$$$$$$$$$$$'+e);
                    }
                }
            }
        }
       
       updateOLFSalesForCustomer(shtLst);	//OLFCustomerCreditChk_01Aug2019_Soumyajit
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
    
    public static void onAfterUpdateSHTTriggerHelper(List<SHT__c> shtLst,Map<ID,SHT__c> newSHTMap,Map<ID,SHT__c> oldSHTMap){
        
       
        Map<String,Map<ID,SHT__c>> newproductnLocationMapLst = new Map<String,Map<ID,SHT__c>>();
        Map<String,Map<ID,SHT__c>> oldProductnLocationMapLst = new Map<String,Map<ID,SHT__c>>();
        
        List<String> productset = new List<String>();
        List<String> locationset = new List<String>();
        
        List<SHT__c> fetchshtLst = RV_DAL.fetchSHTRecord(shtLst);
        
        List<Product_Name_Mapping__mdt> fetchProductMappingMD = [SELECT ID,MasterLabel,DeveloperName,Product_Name__c 
                                                                         from Product_Name_Mapping__mdt];
        
        Map<String,Product_Name_Mapping__mdt> MapOfProductMapping = new Map<String,Product_Name_Mapping__mdt>();
        
        MapOfProductMapping = mappingOFPRoduct(fetchProductMappingMD);
        
        
        //System.debug('^^^^^^^^^^^^^^'+MapOfProductMapping);
           
        
        if(recursionshtDave == true){
            
          	updateSHTDave(fetchshtLst,newSHTMap,oldSHTMap,MapOfProductMapping);
        }
        
             
        
        for(SHT__c shtInterate : fetchshtLst){ // fetch SHT record on after insert/update
            
            if((shtInterate.Product_Category__c <> null || shtInterate.Location__c <> null) && shtInterate.IsATPVolumeReduced__c == true ){// if product catalogue not null
               
               String oldProductName='';
               String newProductName='';
                
               if(MapOfProductMapping.containsKey(shtInterate.Product_Category__c)){
                    
                    	oldProductName = MapOfProductMapping.get(oldSHTMap.get(shtInterate.Id).Product_Category__c).Product_Name__c;
                        newProductName = MapOfProductMapping.get(shtInterate.Product_Category__c).Product_Name__c;
                } 
                
                //Old Record Map
                if(oldSHTMap <> null){
                  
                    if(!oldproductnLocationMapLst.containsKey(oldProductName+''+oldSHTMap.get(shtInterate.ID).Location__c)){
                        
                        Map<ID,SHT__c> oldMaps = new Map<ID,SHT__c>();
                        oldMaps.put(oldSHTMap.get(shtInterate.Id).Id,oldSHTMap.get(shtInterate.Id));
                    	oldproductnLocationMapLst.put(oldProductName+''+oldSHTMap.get(shtInterate.ID).Location__c,oldMaps);
                    
                    }else{
                        
                        Map<ID,SHT__c> oldSHTList = oldproductnLocationMapLst.get(oldProductName+''+oldSHTMap.get(shtInterate.ID).Location__c);
                        oldSHTList.put(oldSHTMap.get(shtInterate.ID).ID,oldSHTMap.get(shtInterate.ID));
                        oldproductnLocationMapLst.put(oldProductName+''+oldSHTMap.get(shtInterate.ID).Location__c , oldSHTList);
                        //System.debug('&&&&&&&oldproductnLocationMapLst&&&&&'+oldproductnLocationMapLst);
                    }
                }
                
                //new Record Map
                if(!newproductnLocationMapLst.containsKey(newProductName+''+shtInterate.Location__c)){
                    Map<ID,SHT__c> newMaps = new Map<ID,SHT__c>();
                    newMaps.put(shtInterate.Id,shtInterate);
                    newproductnLocationMapLst.put(newProductName+''+shtInterate.Location__c, newMaps);
                
                }else{
                    
                    Map<ID,SHT__c> newSHTList = newproductnLocationMapLst.get(newProductName+''+shtInterate.Location__c);
                    newSHTList.put(shtInterate.Id,shtInterate);
                    newproductnLocationMapLst.put(newProductName+''+shtInterate.Location__c , newSHTList);
                    //System.debug('&&&&&&&newproductnLocationMapLst&&&&&'+newproductnLocationMapLst);
                }
                
                if(shtInterate.Location__c <> null)
                locationset.add(shtInterate.Location__c);
                
                if(newProductName  <> null)
                productset.add(newProductName );
                
            }
        }
        
        //System.debug('$$$$$$$newproductnLocationMapLst$$$$$$'+newproductnLocationMapLst);
        
        List<ATP__c> quryATP = new List<ATP__c>();
        
        if(locationset <> null && productset <> null){
            
        	quryATP = RV_DAL.fetchATPRecord(productset,locationset); 
        }
        
         //System.debug('$$$$$$$quryATP$$$$$$'+quryATP);
       
        List<ATP__c> updatequryATP  = new  List<ATP__c>();
        List<SHT__c> updateSHTLst  = new  List<SHT__c>();
        
        if(quryATP <> null  && quryATP.size()> 0){
            
             for(ATP__c iterateatp : quryATP){
                 
                String productLocationConcat = '';
                productLocationConcat = iterateatp.Grade_Level2__c+''+iterateatp.Location__c;
                 
                 ATP__c iterateatpOld = iterateatp.clone(); //CommentUpdateFix_10Jul2019_Soumyajit
                 
                if(newproductnLocationMapLst.containsKey(productLocationConcat)){
                    
                    Map<ID,SHT__c> fetchNewshtLst = newproductnLocationMapLst.get(productLocationConcat);
                    Map<ID,SHT__c> fetchOldshtLst = oldproductnLocationMapLst.get(productLocationConcat);
                    
                            Decimal atp1=0;
                            Decimal atp2=0;
                            Decimal atp3=0;
                            Decimal AGOIGO = 0.845;
                            Decimal ULG = 0.755;
                            Decimal newvolume = 0;
                            Decimal oldValume = 0;
                            Decimal totalSalesATP1 = 0;
                            Decimal totalSalesATP2 = 0;
                            Decimal totalSalesATP3 = 0;
                    
                            if(!fetchNewshtLst.isEmpty()){
                                
                                for(SHT__c str : fetchNewshtLst.values()){
                                    
                                    if(str.Status__c <> fetchOldshtLst.get(str.ID).status__c){ //CommentUpdateFix_10Jul2019_Soumyajit
                                    //System.debug('&&&&&&&&&&'+str.Volume_CBM__c);
                                    SHT__c oldSHTData = fetchOldshtLst.get(str.ID);
                                    String oldTranches = oldSHTData.Tranche__c;	
                                        
                                    str.Tranche__c = tranchValue(str);
                                    updateSHTLst.add(str);
                                    
                                    //System.debug('&&&&&&&str.Tranche__c&&&'+str.Tranche__c);
                                    //System.debug('&&&&&&oldTranches&&&&'+oldTranches);
                                    //System.debug('&&&&&&oldTranches&&&&'+str.Product_Category__c);
                                    if(MapOfProductMapping.containsKey(str.Product_Category__c)){
                                        
                                        String productName = MapOfProductMapping.get(str.Product_Category__c).Product_Name__c;
                                        
                                        if(productName == 'AGO B7' || productName == 'IGO 50ppm'){
                                            
                                            newvolume = str.Volume_CBM__c * AGOIGO;
                                            oldValume = oldSHTData.Volume_CBM__c * AGOIGO;
                                            
                                        }
                                        else if(productName == 'ULG95 E5'){
                                        
                                            newvolume = str.Volume_CBM__c * ULG;
                                            oldValume = oldSHTData.Volume_CBM__c * ULG;
                                        
                                    	}
                                    }
                                    
                                    //System.debug('&&&&&&oldTranches&&&&'+newvolume);
                                    if(str.Tranche__c == Label.ATP1){
                                        
                                         if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed'){
                                        		totalSalesATP1+=newvolume;
                                         }
                                         else if(str.Status__c  == 'Expired'){
                                      		    atp1 -=  newvolume;
                                         }else if(str.Status__c  == Label.SHT_Status_Cancelled){
                                                totalSalesATP1-=newvolume;
                                                atp1 -=  newvolume;
                                        }
                                        if(str.Tranche__c <> oldTranches){
                                            
                                            if(oldTranches == Label.ATP2){                                                
                                         	    if(newvolume > oldValume){                                                    
                                                 	atp2 -=  (newvolume - oldValume);                                                    
                                                }else if(newvolume < oldValume){                                                
                                              		atp2 -=  (oldValume - newvolume);                                               
                                                }else{
                                                    atp2-=newvolume;
                                                }
                                            }
                                            
                                             else if(oldTranches == Label.ATP3){                                                
                                         	    if(newvolume > oldValume){                                                    
                                                 	atp3 -=  (newvolume - oldValume);                                                    
                                                }else if(newvolume < oldValume){                                                
                                              		atp3 -=  (oldValume - newvolume);                                               
                                                }else{
                                                    atp3-=newvolume;
                                                }
                                            }
                                            atp1+=newvolume;
                                            //totalSalesATP1-=newvolume;
                                        }
                                        else {
                                            if(newvolume > oldValume){
                                                atp1 +=  (newvolume - oldValume);
                                            }else if(newvolume < oldValume){
                                                atp1 +=  (newvolume - oldValume);
                                            }
                                        }
                                    }
                                    
                                    if(str.Tranche__c == Label.ATP2){
                                        
                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed'){
                                        		totalSalesATP2+=newvolume;
                                        }else if(str.Status__c  == 'Expired'){
                               
                                                atp2 -=  newvolume;
                                        }else if(str.Status__c  == Label.SHT_Status_Cancelled){
                                                totalSalesATP2-=newvolume;
                                                atp2 -=  newvolume;
                                        }
                                        
                                    	if(str.Tranche__c <> oldTranches){
                                            
                                            if(oldTranches == Label.ATP1){                                                
                                         	    if(newvolume > oldValume){                                                    
                                                 	atp1 -=  (newvolume - oldValume);                                                    
                                                }else if(newvolume < oldValume){                                                
                                              		atp1 -=  (oldValume - newvolume);                                               
                                                }else{
                                                    atp1-=newvolume;
                                                }
                                            }
                                            else if(oldTranches == Label.ATP3){                                                
                                         	    if(newvolume > oldValume){                                                    
                                                 	atp3 -=  (newvolume - oldValume);                                                    
                                                }else if(newvolume < oldValume){                                                
                                              		atp3 -=  (oldValume - newvolume);                                               
                                                }else{
                                                    atp3-=newvolume;
                                                }
                                            }
                                            atp2+=newvolume;
                                            //totalSalesATP1-=newvolume;
                                        }else{                                            
                                            if(newvolume > oldValume){
                                                atp2 +=  (newvolume - oldValume);
                                            }else if(newvolume < oldValume){
                                                atp2 +=  (newvolume - oldValume);
                                            }                                            
                                        }
                                    }
                                    if(str.Tranche__c == Label.ATP3){
                                        
                                        if(str.Status__c == Label.SHT_Status_Completed || str.Status__c == 'Auto-Completed'){
                                        		totalSalesATP3+=newvolume;
                                        }else if(str.Status__c  == 'Expired'){
                   
                                            	atp3 -=  newvolume;
                                        }else if(str.Status__c  == Label.SHT_Status_Cancelled){
                                                totalSalesATP3-=newvolume;
                                                atp3 -=  newvolume;
                                        }
                                        
                                    	if(str.Tranche__c <> oldTranches){
                                            
                                         	 if(oldTranches == Label.ATP1){
                                                 
                                                if(newvolume > oldValume){
                                                    atp1 -=  (newvolume - oldValume);
                                                }
                                                
                                            	else if(newvolume < oldValume){
                                                    
                                                    atp1 -=  (oldValume - newvolume);
                                                    
                                                }else{
                                                    atp1-=newvolume;
                                                }
                                                 atp3+=newvolume;
                                                 //totalSalesATP2-=newvolume;
                                            }else if(oldTranches == Label.ATP2){
                                                
                                               if(newvolume > oldValume){
                                                    
                                                    atp2 -=  (oldValume - newvolume);
                                                }
                                                else if(newvolume < oldValume){
                                                    
                                                    atp2 -=  (oldValume - newvolume);
                                                    
                                                }else{
                                                    atp2-=newvolume;
                                                }
                                                atp3+=newvolume;
                                                //totalSalesATP2-=newvolume;
                                            }
                                            
                                        }else{
                                            
                                            if(newvolume > oldValume){
                                                atp3 +=  (newvolume - oldValume);
                                            }else if(newvolume < oldValume){
                                                atp3 +=  (newvolume - oldValume);
                                            }
                                            
                                        }
                                    }
                                    } //CommentUpdateFix_10Jul2019_Soumyajit
                                }
                            }
                            //System.debug('$$$$$$$atp1$$$$$'+atp1);
                            if(atp1 <> 0){
                                	//166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit starts
                                	if(iterateatp.Live_Online_00_14__c == null)
                                    	iterateatp.Live_Online_00_14__c = 0;
                                
                                    if(isOlfDeal)
                                    {
                                        iterateatp.ATP_Live__c -= atp1; //270192_OLFDealCancel_08Jul2019_Soumyajit
                                        iterateatp.Live_Online_00_14__c -= atp1; //270192_OLFDealCancel_08Jul2019_Soumyajit
                                    }
                                	else
                                    {
                                        if(atp1 > 0)
                                            {
                                                //System.debug('Split negating to ' + atp1);
                                                
                                                if(iterateatp.Live_Online_00_14__c == null)
                                                    iterateatp.Live_Online_00_14__c = 0;
                                                
                                                if(atp1 <= iterateatp.ATP_Live__c - iterateatp.Live_Online_00_14__c)
                                                {
                                                    iterateatp.ATP_Live__c -= atp1;
                                                }
                                                else
                                                {
                                                	iterateatp.Live_Online_00_14__c -= (atp1 - (iterateatp.ATP_Live__c - iterateatp.Live_Online_00_14__c));
                                                    iterateatp.ATP_Live__c -= atp1;
                                                }
                                            }
                                            else{
                                                //System.debug('Split restoring to ' + atp1);
                                                iterateatp.ATP_Live__c -= atp1;
                                                //START - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : calculating online ATP split volume on deal cancellation.
                                                if(iterateatpOld.ATP_Live__c == null || iterateatpOld.ATP_Live__c <= 0)
                                                    iterateatp.Live_Online_00_14__c = RV_ATPTriggerHelper.getOnlineATP(iterateatp.ATP_Live__c,
                                                                                                                    iterateatp.Minimum_Daily_Split_Volume__c,
                                                                                                                    iterateatp.Split_Volume__c,
                                                                                                                    iterateatp.Minimum_Online_Volume__c,
                                                                                                                    iterateatp.Maximum_Online_Volume__c);
                                                //END - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : calculating online ATP split volume on deal cancellation.
                                            }
                                    }
                                    //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit ends
                            }
                            if(atp2 <> 0){
                                //START - Rahul Sharma | Date - 11-Nov-2020 : Rahul Sharma : Added ATP split logic for tranche 2.
                                if(iterateatp.Live_Online_ATP2__c == null)
                                    	iterateatp.Live_Online_ATP2__c = 0;
                                    if(isOlfDeal){
                                        iterateatp.ATP2_Live__c -= atp2; 
                                        iterateatp.Live_Online_ATP2__c -= atp2;
                                    }
                                    else{
                                        if(atp2 > 0){
                                            if(iterateatp.Live_Online_ATP2__c == null)
                                                iterateatp.Live_Online_ATP2__c = 0;                                               
                                            if(atp2 <= iterateatp.ATP2_Live__c - iterateatp.Live_Online_ATP2__c){
                                                iterateatp.ATP2_Live__c -= atp2;
                                            }
                                            else{
                                                iterateatp.Live_Online_ATP2__c -= (atp2 - (iterateatp.ATP2_Live__c - iterateatp.Live_Online_ATP2__c));
                                                iterateatp.ATP2_Live__c -= atp2;
                                            }
                                        }
                                        else{
                                            iterateatp.ATP2_Live__c -= atp2;
                                            //START - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : calculating online ATP split volume on deal cancellation.
                                            if(iterateatpOld.ATP2_Live__c == null || iterateatpOld.ATP2_Live__c <= 0)
                                                iterateatp.Live_Online_ATP2__c = RV_ATPTriggerHelper.getOnlineATP(iterateatp.ATP2_Live__c,
                                                                                                                iterateatp.Min_Daily_Split_Vol_ATP2__c,
                                                                                                                iterateatp.Split_Volume_Per_ATP2__c,
                                                                                                                iterateatp.Min_Online_Volume_ATP2__c,
                                                                                                                iterateatp.Max_Online_Volume_ATP2__c);
                                            //END - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : calculating online ATP split volume on deal cancellation.
                                                                                    }
                                    }
                                //END - Rahul Sharma | Date - 11-Nov-2020 : Rahul Sharma : Added ATP split logic for tranche 2.
                            }
                            if(atp3 <> 0){
                                //START - Rahul Sharma | Date - 11-Nov-2020 : Rahul Sharma : Added ATP split logic for tranche 2.
                                if(iterateatp.Live_Online_ATP3__c == null)
                                    	iterateatp.Live_Online_ATP3__c = 0;
                                    if(isOlfDeal){
                                        iterateatp.ATP3_Live__c -= atp3; 
                                        iterateatp.Live_Online_ATP3__c -= atp3;
                                    }
                                    else{
                                        if(atp3 > 0){
                                            if(iterateatp.Live_Online_ATP3__c == null)
                                                iterateatp.Live_Online_ATP3__c = 0;                                               
                                            if(atp2 <= iterateatp.ATP3_Live__c - iterateatp.Live_Online_ATP3__c){
                                                iterateatp.ATP3_Live__c -= atp3;
                                            }
                                            else{
                                                iterateatp.Live_Online_ATP3__c -= (atp3 - (iterateatp.ATP3_Live__c - iterateatp.Live_Online_ATP3__c));
                                                iterateatp.ATP3_Live__c -= atp3;
                                            }
                                        }
                                        else{
                                            iterateatp.ATP3_Live__c -= atp3;
                                            //START - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : calculating online ATP split volume on deal cancellation.
                                            if(iterateatpOld.ATP2_Live__c == null || iterateatpOld.ATP2_Live__c <= 0)
                                                iterateatp.Live_Online_ATP3__c = RV_ATPTriggerHelper.getOnlineATP(iterateatp.ATP3_Live__c,
                                                                                                                iterateatp.Min_Daily_Split_Vol_ATP3__c,
                                                                                                                iterateatp.Split_Volume_Per_ATP3__c,
                                                                                                                iterateatp.Min_Online_Volume_ATP3__c,
                                                                                                                iterateatp.Max_Online_Volume_ATP3__c);
                                            //END - Rahul Sharma | PBI-731483 | Date - 30-Apr-2021 : calculating online ATP split volume on deal cancellation.
                                        }
                                    }
                                //END - Rahul Sharma | Date - 11-Nov-2020 : Rahul Sharma : Added ATP split logic for tranche 2.
                            }
                    		if(iterateatp.Sales_8_30_17_30__c == null){
                                iterateatp.Sales_8_30_17_30__c = 0;
                            }
                    		if(totalSalesATP1 <> 0){
                                if(!sales1AlreadyUpdated)
                                    iterateatp.Sales_8_30_17_30__c += totalSalesATP1;
                            }                 		
                            if(iterateatp.Sales_15_28__c == null){
                                iterateatp.Sales_15_28__c = 0;
                            }
                            //START - Rahul Sharma | Date - 11-nov-2020 : Added logic to avoid ATP update if was already updated on insert.  
                    		if(totalSalesATP2 <> 0){
                                if(!sales1AlreadyUpdated)
                                    iterateatp.Sales_15_28__c += totalSalesATP2;
                            }
                            if(iterateatp.Sales_29_61__c == null){
                                iterateatp.Sales_29_61__c = 0;
                            }
                            if(totalSalesATP3 <> 0){
                                if(!sales1AlreadyUpdated)
                                    iterateatp.Sales_29_61__c += totalSalesATP3;
                            }
                            //END - Rahul Sharma | Date - 11-nov-2020 : Added logic to avoid ATP update if was already updated on insert.                            
                    }
                 //START - Rahul Sharma | Date - 11-nov-2020 : Added extra condition to include tranche 2 and tranche 3 live online sales.
                 if( iterateatp.ATP_Live__c != iterateatpOld.ATP_Live__c
                    || iterateatp.Live_Online_00_14__c != iterateatpOld.Live_Online_00_14__c
                    || iterateatp.Live_Online_ATP2__c != iterateatpOld.Live_Online_ATP2__c
                    || iterateatp.Live_Online_ATP3__c != iterateatpOld.Live_Online_ATP3__c
                    || iterateatp.ATP2_Live__c != iterateatpOld.ATP2_Live__c
                    || iterateatp.ATP3_Live__c != iterateatpOld.ATP3_Live__c
                    || iterateatp.Sales_8_30_17_30__c != iterateatpOld.Sales_8_30_17_30__c
                    || iterateatp.Sales_15_28__c != iterateatpOld.Sales_15_28__c
                    || iterateatp.Sales_29_61__c != iterateatpOld.Sales_29_61__c
                    )
                //END - Rahul Sharma | Date - 11-nov-2020 : Added extra condition to include tranche 2 and tranche 3 live online sales.
                  updatequryATP.add(iterateatp);
                 
              }
        }
        
         if( recursion == true){
                
                if(updatequryATP <> null && updatequryATP.size() > 0){//update ATP_Live__c and Sales_8_30_17_30__c value
                    
                    try{
                        if(recursion == true){
                            recursion = false;
                        }
                       // System.debug('$$$$$$$updatequryATP$$$$$$'+updatequryATP);
                        update updatequryATP;
                    }catch(Exception e){
                        System.debug('$$$$$$$$$$$$$'+e);
                    }
                }
          }
         
        if(recursionSHTUpdate == true){
          
            if(updateSHTLst <> null && updateSHTLst.size() > 0){//update ATP_Live__c and Sales_8_30_17_30__c value
                
                try{
                    if(recursionSHTUpdate == true){
                            recursionSHTUpdate = false;
                    }
                    update updateSHTLst;
                }catch(Exception e){
                    System.debug('$$$$$$$$$$$$$'+e);
                }
          }
        }
        
        updateOLFSalesForCustomer(shtLst);	//OLFCustomerCreditChk_01Aug2019_Soumyajit
    }
    
    public static String tranchValue(SHT__c str){
        
        if(str.Tranche__c <> null){
                                        
            Date contractStartDate;
            Integer daysBetween;
            
            if(str.Contract_Start__c <> null){
                
                contractStartDate = str.Contract_Start__c;
                daysBetween = System.today().daysBetween(contractStartDate);
            }
            
            
            
            if(daysBetween >=0 && daysBetween <=14){
                
                if(str.Tranche__c <> null){
                    
                    str.Tranche__c=Label.ATP1;
                }
            }
            else if(daysBetween >14 && daysBetween <=28){
                
                if(str.Tranche__c <> null){
                    
                    str.Tranche__c=Label.ATP2;
                }
            }
            else if(daysBetween >28 && daysBetween <=61){
                
                if(str.Tranche__c <> null){
                    
                    str.Tranche__c=Label.ATP3;
                }
            }
            
        }
        return str.Tranche__c;
    }
    
    /*-------------------------------------------------------------*/
    public static void updateSHTDave(List<SHT__c> shtDealList,Map<ID,SHT__c> newSHTMap,Map<ID,SHT__c> oldSHTMap,Map<String,Product_Name_Mapping__mdt> MapOfProductMapping){
        
        //Create a Map of Product and Quantity
        Map<String, List<DaveWrapper>> shtDealMap = new Map<String, List<DaveWrapper>>();
        
        for(SHT__c sht : shtDealList){ 
            if((sht.IsVolumeHedged__c == true && (newSHTMap.get(sht.Id).status__c <> oldSHTMap.get(sht.Id).status__c))
            //OLFChanges_20Apr2019_Soumyajit starts
            ||
            (sht.IsVolumeHedged__c == true && (newSHTMap.get(sht.Id).isOlfDeal__c) && (newSHTMap.get(sht.Id).Status__c == 'Completed' && oldSHTMap.get(sht.Id).name==null))
            //OLFChanges_20Apr2019_Soumyajit ends
               )
            {
                //System.debug('%%%%%%%%%%%'+sht.Product_Category__c );
                DaveWrapper dw = new DaveWrapper();
                //PBI_166252_DataCleanup_Lakshmi_1stOct2019
              /*  dw.mogasE5 = sht.MOGAS_E5_Volume__c;
               	  dw.mogasE10 = sht.MOGAS_E10_Volume__c;
                  dw.mogas98 = sht.MOGAS_98_Volume__c;
                  */
                  
                dw.volumeCBM = sht.Volume_CBM__c;
                dw.shtStatus = sht.Status__c;
                String newProductName='';
                newProductName = sht.Product_Category__c;
                if(!shtDealMap.containsKey(newProductName)){        
                         shtDealMap.put(newProductName , new List<DaveWrapper>{dw});
                         //System.debug('&&&&&&&shtDealMap&&&&&'+shtDealMap);
                 }
               else{
                        List<DaveWrapper> dwList = shtDealMap.get(newProductName);
                        dwList.add(dw);
                        shtDealMap.put(newProductName , dwList);
                        //System.debug('&&&&&&&shtDealMap&&&&&'+shtDealMap);
                } 
            }
        }
    
        //Update SHT Dave Records SHT_Dave__c

        List<SHT_Dave_Master__c> shtDaveList = [Select Id,Name,Total_Exposure_Factor__c,Total_Hedging__c,Final_Exposure_Factor__c
                                                from SHT_Dave_Master__c where Name in:shtDealMap.keyset() Limit 100];
		 insertSHTDaveData(shtDaveList, shtDealMap,MapOfProductMapping);
    }
    
    private static void insertSHTDaveData(List<SHT_Dave_Master__c> daveDataList, Map<String, List<DaveWrapper>> shtDealMap,
                                          Map<String,Product_Name_Mapping__mdt> MapOfProductMapping){
        
        DateTime dT = System.now();
        Date createDate = date.newinstance(dT.year(), dT.month(), dT.day()); 
        List<SHT_Dave__c> insertShtDaveLst = new List<SHT_Dave__c>();
         
         		 if(!daveDataList.isEmpty()){
                     
                         for(SHT_Dave_Master__c dd : daveDataList){  
                            
                            List<DaveWrapper> fetchWrapper = shtDealMap.get(dd.Name);
                             
                                    if(!fetchWrapper.isEmpty()){
                                        
                                                for(DaveWrapper wrp : fetchWrapper){
                                                    
                                                            SHT_Dave__c insertShtDave = new SHT_Dave__c();
                                                            
                                                            insertShtDave.SHT_Dave_Master__c = dd.Id;
                                                            insertShtDave.Product_Name__c = dd.Name;
                                                     		insertShtDave.Transactions__c = 'Sales';
                                                    		insertShtDave.Created_Date__c = dT;
                                                              
                                                                assignstatusFactor(insertShtDave,wrp,MapOfProductMapping);
                                                                
                                                        
                                                            if(wrp.shtStatus == Label.SHT_Status_Completed || wrp.shtStatus == 'Auto-Completed' || wrp.shtStatus == Label.SHT_Status_Cancelled){
                                                            	insertShtDaveLst.add(insertShtDave);
                                                            }
                                                }
                                    }
                        }
                 }
                 //System.debug('%%%%%insertShtDaveLst%%%%%'+insertShtDaveLst);
         
                 if(!insertShtDaveLst.isEmpty()){
                     try{
                         recursionshtDave = false;
                         insert insertShtDaveLst;
                         // sht record insert for platform event
                          //System.debug('^^^^^insertShtDaveLst^^^^^^'+insertShtDaveLst);
                     }catch(Exception e){
                         System.debug('^^^^^^^^^^^'+e);
                     }
                     for(SHT_Dave__c insertShtDave : insertShtDaveLst){
                         Rv_SubscribeToSHT__e shtDav = new Rv_SubscribeToSHT__e();
                         shtDav.RecordId__c= insertShtDave.Id;
                         shtDav.Product_Name__c=insertShtDave.Product_Name__c;
                         shtDav.Time_Stamp__c=RV_SHTDaveTriggerHelper.gettimeStamp(System.now());
                         shtDav.Transactions__c=insertShtDave.Transactions__c;
                         shtDav.Mass_CBM__c=String.valueof(insertShtDave.Mass_CBM__c);
                         shtDav.Mass_MT__c =insertShtDave.Mass_MT__c;
                         shtDav.Hedged_Vol__c=insertShtDave.Hedged_Vol__c;
                         shtDav.Exposure_Factor__c=insertShtDave.Exposure_Factor__c;
                         Database.SaveResult sr = EventBus.publish(shtDav);
                         if (sr.isSuccess()) { 
                             //System.debug('Successfully published event.'); 
                         } else { 
                             for(Database.Error err : sr.getErrors()) { 
                                 System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage()); 
                             }
                         }
                     }
                 }
    }
    
    private static SHT_Dave__c assignstatusFactor(SHT_Dave__c insertShtDave , DaveWrapper wrp,Map<String,Product_Name_Mapping__mdt> MapOfProductMapping){
            
            String newProductName;
        	if(MapOfProductMapping.containsKey(insertShtDave.Product_Name__c)){
                
                newProductName = MapOfProductMapping.get(insertShtDave.Product_Name__c).Product_Name__c;
            }
        				if(wrp.shtStatus == Label.SHT_Status_Completed || wrp.shtStatus == 'Auto-Completed'){
                            
                            if(wrp.shtStatus == Label.SHT_Status_Completed){
                                
                            	insertShtDave.Status__c = Label.SHT_Status_Completed;
                                
                            }else if(wrp.shtStatus == 'Auto-Completed'){
                                
                                insertShtDave.Status__c = 'Auto-Completed';
                            }
                            insertShtDave.Mass_CBM__c = wrp.volumeCBM ;
                            if(newProductName == 'AGO B7' || newProductName == 'IGO 50ppm'){
                            	insertShtDave.Mass_MT__c = wrp.volumeCBM * 0.8450;
                            }
                            if(newProductName == 'ULG95 E5' || newProductName == 'ULG98' ||
                              newProductName == 'ULG95 E10'){
                            	insertShtDave.Mass_MT__c = wrp.volumeCBM  * 0.755;
                            }
                                 insertShtDave.Exposure_Factor__c = (insertShtDave.Mass_MT__c/100)* (-1);
                        }
                        if(wrp.shtStatus == Label.SHT_Status_Cancelled){
                            
                            insertShtDave.Status__c = Label.SHT_Status_Cancelled;
                            insertShtDave.Mass_CBM__c = wrp.volumeCBM * (-1);
                            if(newProductName == 'AGO B7' || newProductName == 'IGO 50ppm'){
                                insertShtDave.Mass_MT__c = wrp.volumeCBM   * 0.8450 * (-1);
                            }
                            if(newProductName == 'ULG95 E5' || newProductName == 'ULG98' ||
                              newProductName == 'ULG95 E10' || newProductName == 'ULG95_BOB_E5' ||
                              newProductName == 'ULG95_BOB_E10'){
                            	insertShtDave.Mass_MT__c = wrp.volumeCBM  * 0.755 * (-1);
                            }
                                insertShtDave.Exposure_Factor__c = insertShtDave.Mass_MT__c/100;
                        }
        
        return insertShtDave;
    }
    
   
    //OLFCustomerCreditChk_01Aug2019_Soumyajit starts
    public static boolean accountAlreadyUpdated = false;

    public static void updateOLFSalesForCustomer(List<SHT__c> shtLst){
        System.debug('------------Inside updateOLFSalesForCustomer------------');
        if(shtLst.size()>0 && !accountAlreadyUpdated){
            list<Id> AccId = new list<Id>();
        	map<Id,Decimal> AccUpdCreditTobeDeducted = new map<Id,Decimal>();
            List<Account> updAccLst = new List<Account>();
            Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
            //Build Maps
            for(SHT__c sht: shtLst){
                if(sht.Tranche__c != null && sht.Status__c !=null & sht.Customer__c !=null){
                    Id key = sht.Customer__c;
                    if(sht.Tranche__c.equals(Label.ATP1)){
                        Decimal creditTobeDeducted = 0;
                        if(sht.Status__c.equals('Completed') || sht.Status__c.equals('Auto-Completed'))
                            creditTobeDeducted += (sht.SP_100L__c*sht.Volume_CBM__c*10);
                        else if(sht.Status__c.equals('Cancelled'))
                            creditTobeDeducted -= (sht.SP_100L__c*sht.Volume_CBM__c*10);
                        else
                            creditTobeDeducted = 0;                        
                        if(!AccId.contains(key))
                            AccId.add(key);
                        //Build Credit List
                        if(AccUpdCreditTobeDeducted.containsKey(key)){
                            creditTobeDeducted += AccUpdCreditTobeDeducted.get(key);
                            AccUpdCreditTobeDeducted.remove(key);
                        }
                        AccUpdCreditTobeDeducted.put(key,creditTobeDeducted);
                    }
                    else
                        System.debug('Ignoring sht = '+sht);
                }
            }
            List<Account> accLst= [Select Id, Rv_Credit_Available__c,Rv_Credit_Utilized__c 
                                     from Account 
                                     where recordTypeId=:recTypeId and Id  in :AccId and Rv_Available_for_OLF__c=:true];   
            if(accLst.size()>0){
                for(Account acc: accLst){
                    Id key = acc.Id;
                    Boolean doUpdate = false;
                    if(acc.Rv_Credit_Available__c == null)
                    	acc.Rv_Credit_Available__c = 0;
                    if(acc.Rv_Credit_Utilized__c == null)
                    	acc.Rv_Credit_Utilized__c = 0;
                    if(AccUpdCreditTobeDeducted.containskey(key)){
                        if(AccUpdCreditTobeDeducted.get(key) != 0){
                            acc.Rv_Credit_Available__c-= AccUpdCreditTobeDeducted.get(key);
                            acc.Rv_Credit_Utilized__c+= AccUpdCreditTobeDeducted.get(key);
                        	if(!doUpdate)
                            	doUpdate = true;
                        }                       
                    }
                    if(doUpdate)    
                        updAccLst.add(acc);
                    else
                        System.debug('As update values is/are 0 will do nothing');
                }
               // System.debug('After update List = '+updAccLst);
                try{
                    if(updAccLst.size()>0 && Account.sObjectType.getDescribe().isUpdateable())
                    	update updAccLst;
                }
                catch(Exception e){
                    System.debug(e);
                }
            }
            else
            	System.debug('------------No Account found to Update------------');
            accountAlreadyUpdated = true;
        }
        else
            System.debug('------------No Account Update needed------------');
    }
    //OLFCustomerCreditChk_01Aug2019_Soumyajit ends

    /*Method Name	:	allotTransactionId
    * Date			:	02-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method generates transaction id to be sent to GSAP to get SAP contract nummber*/
    private static void allotTransactionId(List<SHT__c> shtList){
        Map<String, List<SHT__c>> dealKeyVsShtLstMap = new Map<String, List<SHT__c>>();
        for(SHT__c sht : shtList){
            if(sht.MRCNumber__c != null && sht.Contract_Start__c != null && sht.Contract_End_Date__c != null){
            String key = sht.MRCNumber__c + String.valueOf(sht.Contract_Start__c).replaceAll('[^a-zA-Z0-9\\s+]', '') + String.valueOf(sht.Contract_End_Date__c).replaceAll('[^a-zA-Z0-9\\s+]', '');
            if(!dealKeyVsShtLstMap.isEmpty() && dealKeyVsShtLstMap.containsKey(key)){
                List<SHT__c> shtLst = dealKeyVsShtLstMap.get(key);
                shtLst.add(sht);
                dealKeyVsShtLstMap.put(key, shtLst);
            }
            else{
                dealKeyVsShtLstMap.put(key, new List<SHT__c>{sht});
            }
            }
        }
        RV_Settings__c rvSetting = getOldTxId();
        try{
            Integer txId = Integer.valueOf(rvSetting.Value__c);
            for(String key : dealKeyVsShtLstMap.keySet()){
                txId++;
                for(SHT__c sht : dealKeyVsShtLstMap.get(key)){
                    sht.Transaction_Id__c = 'H-' + String.valueOf(txId);			
                }
            }
            rvSetting.Value__c = String.valueOf(txId);
            saveNewTxId(rvSetting);	
        }
        catch(Exception e){
            System.debug('RV_SHTTriggerHelper >> allotTransactionId >> Exception: '+e.getMessage());
            String errMsg = e.getMessage() + ' | Trace: '+e.getStackTraceString();
            RV_Exception__c excp = new RV_Exception__c();
            excp.Apex_Class__c = 'RV_SHTTriggerHelper';
            excp.Method_Name__c = 'allotTransactionId';
            excp.Type__c = 'Exception';
            //excp.getMessage__c = errMsg.subString(0, 255);
            excp.RV_GetExceptionMessage__c = errMsg;
            insert excp;
        }
    }

    /*Method Name	:	getOldTxId
    * Date			:	02-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method latest saved transaction Id from Revolution Germany Settings custom setting saved from previous deals*/
    private static RV_Settings__c getOldTxId(){
        RV_Settings__c rvSetting = new RV_Settings__c();
        try{
            //NOTE:- SOQL query is used to get custom setting in order to avoid cache and ensure unique transaction id allotment.
            rvSetting = [SELECT Id, 
                                Name,
                                Value__c FROM RV_Settings__c WHERE Name = 'SHT Transaction Id' LIMIT 1 FOR UPDATE];
        }
        catch(Exception e){
            if(e.getTypeName() == 'System.QueryException'){
                rvSetting.Name = 'SHT Transaction Id';
                rvSetting.Active__c = true;
                rvSetting.Value__c = '1000000001';
                insert rvSetting;
            }
            else{
                System.debug('RV_SHTTriggerHelper >> getOldTxId >> Exception: '+e.getMessage());
                String errMsg = e.getMessage() + ' | Trace: '+e.getStackTraceString();
                RV_Exception__c excp = new RV_Exception__c();
                excp.Apex_Class__c = 'RV_SHTTriggerHelper';
                excp.Method_Name__c = 'getOldTxId';
                excp.Type__c = 'Exception';
                //excp.getMessage__c = errMsg.subString(0, 255);
                excp.RV_GetExceptionMessage__c = errMsg;
                insert excp;
            }
        }
        return rvSetting;
    }

    /*Method Name	:	saveNewTxId
    * Date			:	02-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method saves transaction Id to Revolution Germany Settings custom setting*/
    private static void saveNewTxId(RV_Settings__c rvSetting){
        try{
            update rvSetting;
        }
        catch(Exception e){
            System.debug('RV_SHTTriggerHelper >> saveNewTxId >> Exception: '+e.getMessage());
            String errMsg = e.getMessage() + ' | Trace: '+e.getStackTraceString();
            RV_Exception__c excp = new RV_Exception__c();
            excp.Apex_Class__c = 'RV_SHTTriggerHelper';
            excp.Method_Name__c = 'saveNewTxId';
            excp.Type__c = 'Exception';
            //excp.getMessage__c = errMsg.subString(0, 255);
            excp.RV_GetExceptionMessage__c = errMsg;
            insert excp;
        }
    }

    /*Method Name	: updateOlfDealNoInStagning     
     *Developer		: Rahul Sharma
	 *Date			: 26-Mar-2021
	 *Description	: Updates OLF Deal number in SAP Staging object*/
    public static void updateOlfDealNoInStagning(Map<Id, SHT__c> shtNewMap, Map<Id, SHT__c> shtOldMap){
        System.debug('RV_SHTTriggerHelper >> updateOlfDealNoInStagning: Inside method');
        System.debug('updateOlfDealNoInStagning: shtNewMap :::' +shtNewMap+ 'new keys :::' +shtNewMap.keySet());
        System.debug('updateOlfDealNoInStagning: shtOldMap :::' +shtOldMap+ 'old keys :::' +shtOldMap.keySet());
        List<SAP_Staging__c> stagingList = new List<SAP_Staging__c>();
        Map<String, String> shtNoVsOlfNoMap = new Map<String, String>();

        for(SHT__c shtNew : shtNewMap.values()){
            SHT__c shtOld = shtOldMap.get(shtNew.Id);
            if(shtNew.OLF_Deal_Number__c != null && shtOld.OLF_Deal_Number__c == null){
               // shtNoVsOlfNoMap.put(shtNew.Name, shtNew.OLF_Deal_Number__c);
               shtNoVsOlfNoMap.put(shtNew.Id, shtNew.OLF_Deal_Number__c);
            }
        }
        System.debug('RV_SHTTriggerHelper >> updateOlfDealNoInStagning >> shtNoVsOlfNoMap: '+shtNoVsOlfNoMap);

        if(!shtNoVsOlfNoMap.isEmpty()){
            for(SAP_Staging__c stagingObj : [SELECT Id, 
                                                    SfItemShtNo__c, 
                                                    OLF_Deal_Number__c,SHTId__c,RV_SAPSHT_ExternalID__c 
                                                    FROM SAP_Staging__c WHERE RV_SAPSHT_ExternalID__c IN : shtNoVsOlfNoMap.keySet() 
                                                    FOR UPDATE]){                                                    
                if(shtNoVsOlfNoMap.containsKey(stagingObj.SHTId__c) && shtNoVsOlfNoMap.get(stagingObj.SHTId__c) != null){
                    stagingObj.OLF_Deal_Number__c = shtNoVsOlfNoMap.get(stagingObj.SHTId__c);
                    stagingList.add(stagingObj);
                }                                                                                     
            }
        }
        if(!stagingList.isEmpty()){
            System.debug('RV_SHTTriggerHelper >> updateOlfDealNoInStagning >> stagingList size: '+stagingList.size());
            try{
                update stagingList;
            }
            catch(Exception e){
                System.debug('RV_SHTTriggerHelper >> updateOlfDealNoInStagning >> Exception: '+e.getMessage()+' Line Number: '+e.getLineNumber()+' Trace: '+e.getStackTraceString());
                RV_Exception__c rvException = new RV_Exception__c();
                //rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString();
                rvException.RV_GetExceptionMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString();
                rvException.Apex_Class__c = 'RV_SHTTriggerHelper';
                rvException.Method_Name__c = 'updateOlfDealNoInStagning';
                rvException.Type__c = 'Exception';
                insert rvException;
            }
        }
    }

    private class DaveWrapper{
        //PBI_166252_DataCleanup_Lakshmi_1stOct2019
        /* Decimal mogas98;
        Decimal mogasE10;
        Decimal mogasE5;*/
        Decimal volumeCBM;
        String shtStatus;
    }
    
    
}