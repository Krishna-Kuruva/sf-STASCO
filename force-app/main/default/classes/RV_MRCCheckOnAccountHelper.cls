public class RV_MRCCheckOnAccountHelper{
    public static void checkMRCOnInsert(List<MRC__c> mrcList){
        List<Account> accToUpdate = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();
        for(MRC__c mrc : mrcList){
            if(mrc.Sold_To__c != null){
                accIdSet.add(mrc.Sold_To__c);
            }
            //START - Rahul Sharma | Date - 21-Apr-2020 : Added Ship-To accounts as well for Has_MRC__c check.
            if(mrc.Ship_To__c != null){
                accIdSet.add(mrc.Ship_To__c);
            }
            //END - Rahul Sharma | Date - 21-Apr-2020 : Added Ship-To accounts as well for Has_MRC__c check.
        }
        updatehasMRC(accIdSet);
    }
    @future
    public static void updatehasMRC(Set<Id> accIdSet){
        List<Account> accToUpdate = new List<Account>();
        // accToUpdate = [Select Id, Has_MRC__c from Account where Id in : accIdSet];
        //START - Rahul Sharma | Date - 21-Apr-2020 : Updated query to filter only accounts with Has_MRC__c = false.
        for(Account acc : [SELECT Id, Has_MRC__c FROM Account WHERE Id IN : accIdSet AND 
                                                                            Has_MRC__c = false]){
        //END - Rahul Sharma | Date - 21-Apr-2020 : Updated query to filter only accounts with Has_MRC__c = false.
            acc.Has_MRC__c = true;
        }
        
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }

    /*Mthod Name	: updateShipToAccount     
     *Developer		: Rahul Sharma
	 *Date			: 21-Apr-2020
	 *Description	: Update Ship-To lookup with respective Ship-To Account based on MRC Ship-To Number*/
    public static void updateShipToAccount(List<MRC__c> mrcList){
        Set<Id> soldToAccSet = new Set<Id>();
        Set<Id> mrcIdSet = new Set<Id>();
        Set<String> shipToNumSet = new Set<String>();
        for(MRC__c mrc : mrcList){
            if(!String.isBlank(mrc.Ship_to_Number__c) && mrc.Sold_To__c != null && mrc.Ship_To__c == null){
                mrcIdSet.add(mrc.Id);
                soldToAccSet.add(mrc.Sold_To__c);
                shipToNumSet.add(mrc.Ship_to_Number__c);
            }
        }
        if(!soldToAccSet.isEmpty() && !mrcIdSet.isEmpty() && !shipToNumSet.isEmpty()){
            updateMrcLookup(soldToAccSet, mrcIdSet, shipToNumSet);
        }
    }

    /*Mthod Name	: updateShipToAccount     
     *Developer		: Rahul Sharma
	 *Date			: 21-Apr-2020
	 *Description	: Update Ship-To lookup with respective Ship-To Account based on MRC Ship-To Number*/
    @future
    public static void updateMrcLookup(Set<Id> soldToAccSet, Set<Id> mrcIdSet, Set<String> shipToNumSet){
        List<MRC__c> updatedMrcList = new List<MRC__c>();
        for(Account acc : [SELECT Id,
						  (SELECT Id,
								  Ship_to_Number__c FROM ChildAccounts WHERE Ship_to_Number__c =: shipToNumSet),
								  (SELECT Id,
										  Sold_To__c,
										  Ship_To__c,
										  Ship_to_Number__c FROM MRC__r WHERE Id =: mrcIdSet) FROM Account WHERE Id =: soldToAccSet]){
            for(MRC__c mrc : acc.MRC__r){
                for(Account shipToAcc : acc.ChildAccounts){
                    if(mrc.Ship_to_Number__c == shipToAcc.Ship_to_Number__c){
                        mrc.Ship_To__c = shipToAcc.Id;
                        updatedMrcList.add(mrc);
                    }				
                }
            }	
        }
        update updatedMrcList;
    }
	
}