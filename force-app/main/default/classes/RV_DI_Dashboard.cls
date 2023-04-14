public class RV_DI_Dashboard{
    public String query;
    public Map<Id, MRC__c> mrcMap; 
    public Date contractStratDate;
    public Date contractEndDate;
    public RV_SPCalculationController.salesPriceCalAndAuditWrap sp;
    public List<RV_SPCalculationController.salesPriceWrap> spWrapList;
    public Map<String, MRC__c> mrcNumberMrcMap = new Map<String, MRC__c>();
    public Map<String,Revolution_Dashboard__c> dashboardItemsMap = new Map<String,Revolution_Dashboard__c>();  
    Map<String, RV_SPCalculationController.salesPriceWrap> mrcPriceWrapperMap = new Map<String, RV_SPCalculationController.salesPriceWrap>();
    //Constructor - Loads all the MRCs from system and construct MRC Map
    public RV_DI_Dashboard(){
        
        system.debug('Inside Constructor');
        String recTypeId = Schema.SObjectType.MRC__c.getRecordTypeInfosByDeveloperName().get('DI_Dashboard').getRecordTypeId();
        System.debug('--------'+recTypeId);
        //Set<String> MaterialSet= new  Set<String>{'000000000400001685','000000000400002410','000000000400001637','000000000400001986','000000000400003805','000000000400002484'}; //400003805 added by Dharmendra : PBI328
		String MaterialSet = Label.RV_MaterialName;
    }
    
    //Method to getch SP for all the MRCs
    public Map<String,Revolution_Dashboard__c> getPriceForDashboard(String DashboardType,Date contractStratDate,
                                                              Date contractEndDate,Map<Id,MRC__c> mrcMapValue){
        //Set<String> MaterialSet= new  Set<String>{'000000000400001685','000000000400002410','000000000400001637','000000000400001986','000000000400003805','000000000400002484'}; //400003805 added by Dharmendra : PBI328
        String customLabel = Label.RV_MaterialName;
        List<String> matNameLst = customLabel.split(',');
        Set<String> MaterialSet = new Set<String>(matNameLst);
        Set<String> uniqueKeySet= new Set<string>();
        System.debug('---mrcMapValue---'+mrcMapValue); //added by Dharmendra
        //Map of MRC Name and associated MRC Object
        if(!mrcMapValue.isEmpty()){
            for(MRC__c mrc : mrcMapValue.values()){
                if(MaterialSet.contains(mrc.Product__r.Name)){
              		mrcNumberMrcMap.put(mrc.Name, mrc);  
                }
            }
        }                                                    
        //Below method call returns the wrapper of All MRCs with Price Details
        sp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        
        if(DashboardType == 'Future' && contractStratDate <> null && contractEndDate <> null){
            sp = RV_SPCalculationController.getCalulatedSp(mrcMapValue.values(), contractStratDate, contractEndDate);
        }else{
        	sp = RV_SPCalculationController.getCalulatedSp(mrcNumberMrcMap.values(), contractStratDate, contractEndDate);
            //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit starts
            //updateProductDifferentialAgoMogasLiveValues(sp.salesPriceWrpLst);
            //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit ends
        }
        System.debug('------Input MRC Map-----'+mrcNumberMrcMap.size());                                                               
        spWrapList = sp.salesPriceWrpLst;
        Map<String,List<Mrc__c>> uniqueKeyMrcLstMap= new Map<String,List<Mrc__c>>();                                                        
        for(RV_SPCalculationController.salesPriceWrap wrap : spWrapList){
          mrcPriceWrapperMap.put(wrap.mrcNo, wrap);
          integer shippingcondition=0;
          if(mrcNumberMrcMap.containsKey(wrap.mrcNo) && mrcNumberMrcMap.get(wrap.mrcNo).Shipping_Condition__c != null){
                shippingcondition=integer.valueOf(mrcNumberMrcMap.get(wrap.mrcNo).Shipping_Condition__c);
          }
          string unique=(mrcNumberMrcMap.get(wrap.mrcNo)).Sales_Organization__c+(mrcNumberMrcMap.get(wrap.mrcNo)).Plant__c+string.valueOf(shippingcondition);
          uniqueKeySet.add(unique);
            if(uniqueKeyMrcLstMap.containsKey(unique)){
				List<Mrc__c> mrcLst=uniqueKeyMrcLstMap.get(unique);
                mrcLst.add(mrcNumberMrcMap.get(wrap.mrcNo));
                uniqueKeyMrcLstMap.put(unique,mrcLst);
            }else{
                uniqueKeyMrcLstMap.put(unique,new List<Mrc__c>{mrcNumberMrcMap.get(wrap.mrcNo)});
            }
         // unqMatMrcPriceMap.put(unique+(mrcNumberMrcMap.get(wrap.mrcNo)).Product__r.Name,wrap); 
        }
                                                                 
        /**************** Shipping Condition**************************/
        List<Shipping_Condition_Mapping__mdt> shippingConditionLst = [select id,MasterLabel,Margin_Type__c,MOT__c,
                                                                      MoTKey__c,Shipping_Condition__c from 
                                                                      Shipping_Condition_Mapping__mdt];
        
        Map<Decimal,String> mapOfShipConMOT = new Map<Decimal,String>();
        if(!shippingConditionLst.isEmpty()){
            for(Shipping_Condition_Mapping__mdt shippingCondition : shippingConditionLst){
                mapOfShipConMOT.put(shippingCondition.Shipping_Condition__c,shippingCondition.MOT__c);
            }
        }
        
        String recTypeId = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId(); 
        for(string key:uniqueKeyMrcLstMap.keySet()){
			Revolution_Dashboard__c rdRecord = new Revolution_Dashboard__c(); 
             rdRecord.Plant_Name__c=uniqueKeyMrcLstMap.get(key)[0].Plant__c;
            if(key.length()>4){
                rdRecord.Sales_Channel__c=key.left(4);
            }
             rdRecord.Shipping_Condition__c =uniqueKeyMrcLstMap.get(key)[0].Shipping_Condition__c;
             Decimal rounded = rdRecord.Shipping_Condition__c.setScale(1, RoundingMode.HALF_UP);
             if(mapOfShipConMOT.containskey(rounded)){
                 rdRecord.MOT__c = mapOfShipConMOT.get(rounded); 
             }
             
             rdRecord.UniqueKey__c=key;
            
            if(recTypeId <> null){
                rdRecord.RecordTypeId = recTypeId;
            }
             List<Mrc__c> mrclst=uniqueKeyMrcLstMap.get(key);  
             for(Mrc__c mr:mrclst){
                 if(mrcPriceWrapperMap.containsKey(mr.Name)){
                     if(mr.Product__r.Name == Label.RV_MaterialName1685){
                         rdRecord.BSP_AGO__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                         rdRecord.PSP_AGO__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                         rdRecord.Total_Tax_AGO__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                         rdRecord.OTM_AGO__c=mrcPriceWrapperMap.get(mr.Name).OTM;
                     }
                     if(mr.Product__r.Name == Label.RV_MaterialName2410){
                         rdRecord.BSP_IGO__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                         rdRecord.PSP_IGO__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                         rdRecord.Total_Tax_IGO__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                         rdRecord.OTM_IGO__c=mrcPriceWrapperMap.get(mr.Name).OTM;
                     }
                     if(mr.Product__r.Name == Label.RV_MaterialName1637){
                         rdRecord.BSP_MOGAS__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                         rdRecord.PSP_MOGAS__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                         rdRecord.Total_Tax_MOGAS__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                         rdRecord.OTM_MOGAS__c=mrcPriceWrapperMap.get(mr.Name).OTM; 
                     }
                     // added by Dharmendra for 400003805 : PBI328
                     if(mr.Product__r.Name == Label.RV_MaterialName2484){
                         rdRecord.BSP_MOGAS__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                         rdRecord.PSP_MOGAS__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                         rdRecord.Total_Tax_MOGAS__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                         rdRecord.OTM_MOGAS__c=mrcPriceWrapperMap.get(mr.Name).OTM; 
                     }
                     if(mr.Product__r.Name == Label.RV_MaterialName3805){
                         rdRecord.BSP_MOGAS__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                         rdRecord.PSP_MOGAS__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                         rdRecord.Total_Tax_MOGAS__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                         rdRecord.OTM_MOGAS__c=mrcPriceWrapperMap.get(mr.Name).OTM; 
                     }
                     /* Start - Added by Mohan as part of NEHG change */
                     if(mr.Product__r.Name == Label.RV_MaterialName2498){
                         rdRecord.BSP_AGO__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                         rdRecord.PSP_AGO__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                         rdRecord.Total_Tax_AGO__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                         rdRecord.OTM_AGO__c=mrcPriceWrapperMap.get(mr.Name).OTM;
                     }
                     if(mr.Product__r.Name == Label.RV_MaterialName2390){
                        rdRecord.BSP_IGO__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                        rdRecord.PSP_IGO__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                        rdRecord.Total_Tax_IGO__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                        rdRecord.OTM_IGO__c=mrcPriceWrapperMap.get(mr.Name).OTM;
                     }
                     /* End - Added by Mohan as part of NEHG change */
                     // added by Dharmendra - End
                     if(mr.Product__r.Name == Label.RV_MaterialNameGTL){//
                         rdRecord.BSP_GTL__c=mrcPriceWrapperMap.get(mr.Name).BSP;
                         //Fix_260839_Soumyajit_22May2019 Starts
                         rdRecord.Total_Tax_GTL__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                         //Fix_260839_Soumyajit_22May2019 Ends
                     }
                     /* INC9303327 Start - Added by Apoorva */
                     if(mr.Product__r.Name == Label.RV_MaterialName12162){
                        rdRecord.BSP_AGO__c =  mrcPriceWrapperMap.get(mr.Name).BSP;
                        rdRecord.PSP_AGO__c =  mrcPriceWrapperMap.get(mr.Name).MSP;
                        rdRecord.Total_Tax_AGO__c = mrcPriceWrapperMap.get(mr.Name).totalTax;
                        rdRecord.OTM_AGO__c=mrcPriceWrapperMap.get(mr.Name).OTM;
                    }
                    /* INC9303327 End - Added by Apoorva */

                 }
             }
             dashboardItemsMap.put(rdRecord.UniqueKey__c,rdRecord);
        }               
                                                           
       
        if(DashboardType <> 'Future'){
            if(!dashboardItemsMap.isEmpty()){
                system.debug('List size is not null -------->' + dashboardItemsMap.size());
                Schema.SObjectField f = Revolution_Dashboard__c.Fields.UniqueKey__c;
                Database.UpsertResult [] cr = Database.upsert(dashboardItemsMap.values(), f, false);
                system.debug('Success ------->' + cr);
                for (Database.UpsertResult sr : cr) {
                     if (sr.isSuccess()) {
                         // Operation was successful, so get the ID of the record that was processed
                         System.debug('Successfully updated AMV Scenario: ' + sr.getId());
                     }
                     else {
                         // Operation failed, so get all errors                
                         for(Database.Error err : sr.getErrors()) {
                             RV_ClassException.getInstance();
                             RV_ClassException.insertExceptionRecord(String.valueof(err.getStatusCode()), err.getMessage(), 'RV_DI_Dashboard', 'getPriceForDashboard','Exception');
                         }
                     }
                 }
            }
        }
        return dashboardItemsMap;
    }
    //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit starts
    /*
    public static void updateProductDifferentialAgoMogasLiveValues(List<RV_SPCalculationController.salesPriceWrap> WrpLst){
        system.debug('updateProductDifferentialAgoMogasLiveValues==>'+WrpLst);
        Map<String,Decimal> QuoateNameValueMap= new  Map<String,Decimal>();
        Set<String> prdDiffNameSet= new Set<String>{'Wesseling AGO Live','Wesseling MOGAS Live'};
        for(RV_SPCalculationController.salesPriceWrap wrp : WrpLst){
            //AGO
            if(wrp.mrcNo == label.Rv_Wesseling_AGO_MRC_Dashboard){
                //label.Rv_Wesseling_AGO_MRC){
                QuoateNameValueMap.put('Wesseling AGO Live',wrp.MSP);
            }
            //Mogas
            if(wrp.mrcNo == label.Rv_Wesseling_MOGAS_MRC_Dashboard){
               //label.Rv_Wesseling_MOGAS_MRC){
                QuoateNameValueMap.put('Wesseling MOGAS Live',wrp.MSP);
            } 
        }
        Rv_DailyPriceTrendQueueable.updateProdDifferetial(QuoateNameValueMap,prdDiffNameSet);   
    } */
    //Fix_WesslingLiveValueUpdate_15May2019_Soumyajit ends
}