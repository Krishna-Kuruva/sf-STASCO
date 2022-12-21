public class RV_SHTDave {
     @AuraEnabled
    public static List<SHT_Dave_Master__c> getShtDaveMaster() {
        List<SHT_Dave_Master__c> shtDaveMaster = 
                [SELECT Id,Name,Total_Exposure_Factor__c,Total_Exposure_Factors__c,Total_Hedging__c,Hedged__c,Total_Exposure_Factor_CBM__c,
                 Final_Exposure_Factor__c,Total_Exposure_Factor_MT__c
                 FROM SHT_Dave_Master__c ];
        //Add isAccessible() check
        System.debug('&&&&&&&&&&&&'+shtDaveMaster);
        return shtDaveMaster;
    }
    @AuraEnabled
    public static List<SHT_Dave__c> getShtDave() {
        List<SHT_Dave__c> shtDave = 
                [SELECT Id,Product_Name__c,Time_Stamp__c,Transactions__c,Mass_MT__c,Hedge__c,Exposure_Factor__c,Mass_CBM__c 
                 FROM SHT_Dave__c where CreatedDate = TODAY order by CreatedDate desc , Exposure_Factor__c ASC ];// 
        //Add isAccessible() check
        return shtDave;
    }
     @AuraEnabled
    public static SHT_Dave__c insertManualEntry(String productName,Decimal hedgeEntry) {
       System.debug('%%%%%%%'+hedgeEntry);
       System.debug('%%%%%%%'+productName);
       SHT_Dave__c insertSHTDave = new SHT_Dave__c();
        if(productName == null){
            productName = '';
        }
        if(hedgeEntry == null){
            hedgeEntry = 0;
        }
        if(productName <> null){
        insertSHTDave.Product_Name__c = productName;
        }
        if(hedgeEntry <> 0){
        insertSHTDave.Hedge__c = hedgeEntry;
        }
        insertSHTDave.Hedging_Date__c = System.now();
		insertSHTDave.Transactions__c = 'Hedge';
        Schema.DescribeSObjectResult s = SHT_Dave__c.sObjectType.getDescribe();
        if(s.isCreateable()){
			insert insertSHTDave;            
        }
        System.debug('%%%%%%%'+insertSHTDave);
        return insertSHTDave;
    }
    
    //AdditionalFix_166256_29Apr2019_Soumyajit starts
    ////Check permission for SHT_Dave object
    @AuraEnabled
    public static Boolean checkEditAccess() {
        if(!(SHT_Dave__c.sObjectType.getDescribe().isCreateable()
          && SHT_Dave__c.sObjectType.getDescribe().isUpdateable()))
            return false;
		else 
        	return true;
    }
    //AdditionalFix_166256_29Apr2019_Soumyajit ends
}