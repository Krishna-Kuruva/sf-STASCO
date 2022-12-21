public class OLF_FetchMrcFinalPrice{
  
    //START | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters and logic to take list of Ship-to accounts instead of Sold-to Account
    //START | Rahul Sharma | Date - 02-Nov-2020 : Updated method parameters and logic to contain OLFWrapper.OlfTrancheWrap as an addtional parameter.
    public static List<OLFWrapper.MrcPriceWrap> fetchPrice(List<Account> accList, String contactEmail, OLFWrapper.OlfTrancheWrap olfTrancheWrap){        
        String locationMaterialString = '';
        Set<Id> accIdSet = (new Map<Id, Account>(accList)).keySet();
        OLFWrapper.ContractDateWindowWrap dateWrap = new OLFWrapper.ContractDateWindowWrap();
        dateWrap = OLF_Utility.getContractDateWindow(olfTrancheWrap.startDay, olfTrancheWrap.endDay);
        Id accId = accList[0].ParentId;
        String startDate = String.valueOf(dateWrap.contractStartDate);
        String endDate = String.valueOf(dateWrap.contractEndDate);
        if(olfTrancheWrap.tranche == 'ATP4')
            olfTrancheWrap.tranche = 'ATP3';
        List<RV_SHT_CreateController.MRCDataWrap> mrcMasterData = RV_SHT_CreateController.getMRCRecordsData(olfTrancheWrap.tranche, null, accIdSet, null, false, true, true, true, null, null, null, startDate, endDate,true) ;
    //END | Rahul Sharma | Date - 02-Nov-2020 : Updated method parameters and logic to contain OLFWrapper.OlfTrancheWrap as an addtional parameter.
        List<OLFWrapper.MrcPriceWrap> mrcPriceWrapVar = new List<OLFWrapper.MrcPriceWrap>();
        if(mrcMasterData != null){
            Set<String> plantCodeSet = new Set<String>();
            
            for(RV_SHT_CreateController.MRCDataWrap wrp : mrcMasterData){
                plantCodeSet.add(wrp.location); 
            }
            Map<String,Decimal> atpLocMap = getAtpforPlant(plantCodeSet, accId, new List<String>{olfTrancheWrap.tranche});
            for(RV_SHT_CreateController.MRCDataWrap wrp : mrcMasterData){
                OLFWrapper.MrcPriceWrap wrapRecord = new OLFWrapper.MrcPriceWrap();
                wrapRecord.MRCNumber = wrp.mrcName;
                wrapRecord.Location = wrp.locationName;
                wrapRecord.MaterialName = wrp.materialName;
                wrapRecord.grade = wrp.grade;
                if(atpLocMap.get(wrp.location+wrp.grade+olfTrancheWrap.tranche)<1){
                   wrapRecord.availableVolume='0';  
                }else{
                    wrapRecord.availableVolume=String.valueOf(Integer.valueOf(atpLocMap.get(wrp.location+wrp.grade+olfTrancheWrap.tranche))); 
    //END | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters and logic to take list of Ship-to accounts instead of Sold-to Account
                }
                wrapRecord.PricePerUnit = String.valueOf(wrp.OTM);
                wrapRecord.StartDate = startDate;
                wrapRecord.EndDate = endDate;
                wrapRecord.customerName=wrp.accName;
                wrapRecord.contactEmail=contactEmail;
                mrcPriceWrapVar.add(wrapRecord);
            }
        }
        if(!mrcPriceWrapVar.isEmpty()){
            return mrcPriceWrapVar;
        }else{
            return null;
        }        
    } 
    //Get Online ATP based on plantcode and customer
    //START | Rahul Sharma | Date - 27-Jan-2021 : Updated logic to get ATP and available volume based on tranches.
    public static Map<String, Decimal> getAtpforPlant(Set<string> plantCodeSet, Id accId, List<String> trancheList){
       Map<String ,Decimal> atpLocTrancheMap = new Map<String, Decimal >();
       Map<String ,Decimal> atpLocTrancheVsVolMap = new Map<String, Decimal>();
       Map<String,Decimal> locGrdSalesPerCustMap = new Map<String, Decimal>();
       List<ATP__c> atpList = [SELECT Id,
                                      Name,
                                      Location__c,
                                      Location__r.Name,
                                      ATP_Live__c,
                                      Live_Online_00_14__c,
                                      Live_Online_ATP2__c,
                                      Live_Online_ATP3__c,
                                      Volume_Cap_Customer__c, 
                                      Vol_Cap_Customer_ATP2__c,
                                      Vol_Cap_Customer_ATP3__c,
                                      Plant_Code__c,
                                      Grade_Level2__c from ATP__c WHERE Plant_Code__c  IN : plantCodeSet];
        for(String tranche : trancheList){
            if(tranche == 'ATP1'){
                atpLocTrancheMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Live_Online_00_14__c', tranche));
                atpLocTrancheVsVolMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Volume_Cap_Customer__c', tranche));
            }
            else if(tranche == 'ATP2'){
                atpLocTrancheMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Live_Online_ATP2__c', tranche));
                atpLocTrancheVsVolMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Vol_Cap_Customer_ATP2__c', tranche));
            }
            else if(tranche == 'ATP3'){
                atpLocTrancheMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Live_Online_ATP3__c', tranche));
                atpLocTrancheVsVolMap.putAll(OLF_Utility.convertTonCBM(atpList, 'Vol_Cap_Customer_ATP3__c', tranche));
            }
        }
        if(!atpLocTrancheMap.isEmpty() && !atpLocTrancheVsVolMap.isEmpty()){
            locGrdSalesPerCustMap = OLF_Utility.getCustomerSpecificVolume(atpLocTrancheVsVolMap, accId, trancheList);
            for(String plantGrd: atpLocTrancheMap.keyset()){
                if(locGrdSalesPerCustMap.containsKey(plantGrd)){
                    if(locGrdSalesPerCustMap.get(plantGrd) < atpLocTrancheMap.get(plantGrd)){
                        atpLocTrancheMap.put(plantGrd, locGrdSalesPerCustMap.get(plantGrd));
                    }
                }
            }
        }
        return atpLocTrancheMap;
        //END | Rahul Sharma | Date - 27-Jan-2021 : Updated logic to get ATP and available volume based on tranches.
    }
}