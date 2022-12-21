public class RV_ReadGSAPContractClass {
	@auraEnabled
    public static List<innerClassDisplayRead> readGSAPContract(String sapContractNo){
        List<Revolution_Deal_GSAP_Config__mdt> revDealGSAPLst = [Select Id,MasterLabel,DeveloperName,
                                                                 Client_Id__c,Client_Secret__c,
                                                                 Content_Type__c,Endpoint__c,Method__c from 
                                                                 Revolution_Deal_GSAP_Config__mdt ];
        
    
		Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap = new Map<String,Revolution_Deal_GSAP_Config__mdt>();
        for(Revolution_Deal_GSAP_Config__mdt revDealGSAPConfig : revDealGSAPLst){
            revDealGSAPMap.put(revDealGSAPConfig.MasterLabel,revDealGSAPConfig);
        }
         String access_Token = RV_DealGSAPMulesoft.basicAuthCallout(revDealGSAPMap);
		 String response = RV_DealGSAPMulesoft.getDealinGSAP(access_Token,sapContractNo, revDealGSAPMap);
          RV_ReadGSAPContractWrapper deserializeWrapper =(RV_ReadGSAPContractWrapper)JSON.deserialize(response, RV_ReadGSAPContractWrapper.class);
                    System.debug('-------deserializeWrapper-------'+deserializeWrapper);
        List<innerClassDisplayRead> innerClassReadLst = new List<innerClassDisplayRead>();
        for(RV_ReadGSAPContractWrapper.SHTItems items : deserializeWrapper.SHTItems){
            innerClassDisplayRead innerClassRead = new innerClassDisplayRead();
            innerClassRead.SapSalesContNo = deserializeWrapper.SapSalesContNo;
            innerClassRead.shtHeader = deserializeWrapper.shtHeader;
            innerClassRead.contStartDate = deserializeWrapper.contStartDate;
            innerClassRead.contEndDate = deserializeWrapper.contEndDate;
            innerClassRead.CreationDateSap = deserializeWrapper.CreationDateSap;
            innerClassRead.CreationTimeSap = deserializeWrapper.CreationTimeSap;
            innerClassRead.changeDateSAP = deserializeWrapper.changeDateSAP;
            innerClassRead.soldTo = deserializeWrapper.soldTo;
            innerClassRead.POType = deserializeWrapper.POType;
            
            innerClassRead.SfItemShtNo = items.SfItemShtNo;
            innerClassRead.MaterialNo = items.MaterialNo;
            innerClassRead.Quantity = items.Quantity;
            innerClassRead.QuantityUOM = items.QuantityUOM;
            innerClassRead.OpenQuantity = items.OpenQuantity;
            innerClassRead.RejectionReason = items.RejectionReason;
            innerClassRead.CondType = items.CondType;
            innerClassRead.SalesPrice = items.SalesPrice;
            innerClassRead.CurrencyKey = items.CurrencyKey;
            innerClassRead.CondPUnt = items.CondPUnt;
            innerClassRead.CondUnit = items.CondUnit;
            innerClassRead.PriceInd = items.PriceInd;
            innerClassRead.PriceVar = items.PriceVar;
            innerClassRead.TasLoadId = items.TasLoadId;
            innerClassRead.Tas3rdPtyDel = items.Tas3rdPtyDel;
            innerClassReadLst.add(innerClassRead);
        }
         return innerClassReadLst;
    }
    
    public class innerClassDisplayRead{
        @auraEnabled public String SapSalesContNo;
        @auraEnabled public String shtHeader;
        @auraEnabled public String contStartDate;
        @auraEnabled public String contEndDate;
        @auraEnabled public String CreationDateSap;
        @auraEnabled public String CreationTimeSap;
        
        @auraEnabled public String changeDateSAP;
        @auraEnabled public String soldTo;
        @auraEnabled public String POType;
        @auraEnabled public String SfItemShtNo;
        @auraEnabled public String MaterialNo;
        @auraEnabled public String Quantity;
        
        @auraEnabled public String QuantityUOM;
        @auraEnabled public String OpenQuantity;
        @auraEnabled public String RejectionReason;
        @auraEnabled public String CondType;
        @auraEnabled public String SalesPrice;
        @auraEnabled public String CurrencyKey;
        
        @auraEnabled public String CondPUnt;
        @auraEnabled public String CondUnit;
        @auraEnabled public String PriceInd;
        @auraEnabled public String PriceVar;
        @auraEnabled public String TasLoadId;
        @auraEnabled public String Tas3rdPtyDel;
    }
}