/*
 * Created by Dharmendra.Singh2 on 12/15/2020.
 * RV_MRCFromStagingTrigger
 */

trigger RV_MRCFromStagingTrigger on RV_MRC_Item_Staging__c (after insert) {
    
    List<RV_MRC_Item_Staging__c> mrcItemList = new List<RV_MRC_Item_Staging__c>();
    mrcItemList = Trigger.new;
    System.debug('---mrcItemList---'+mrcItemList);
    if(Trigger.isAfter){
        if(mrcItemList.size()>0){
            RV_MRCFromStagingTriggerHelper.MRCFromStaging(mrcItemList);
        }
        
    }
    

}