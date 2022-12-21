public class RV_MRCDataUploadInsertQueuable implements Queueable{
    public List<MRC__c> mrcList;
    public RV_MRCDataUploadInsertQueuable(List<MRC__c> mrcLists){
        this.mrcList = mrcLists;
    }
    public void execute(QueueableContext queCont){
        System.debug('----mrcList-----'+mrcList);
        List<MRC__c> updatedMRCLst = updateLookupOnInsert(mrcList);
        System.debug('----updatedMRCLst-----'+updatedMRCLst);
        insertMRCList(updatedMRCLst);
        
    }
    public static void insertMRCList(List<MRC__c> updateMRCList){
       
         //system.debug('-------before Insert '+insertList.size());
            try{
            Database.SaveResult[] srList = Database.insert(updateMRCList, false);
            System.debug('------srList----'+srList.size());
            List<RV_Exception__c> rvExceptionList = new List<RV_Exception__c>();
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        RV_Exception__c rvException = new RV_Exception__c();
                        rvException.getFields__c = err.getFields().get(0);
                        rvException.getMessage__c = err.getMessage();
                        rvExceptionList.add(rvException);
                    }
                }
            }
            }catch(Exception e){
                system.debug('--------------'+e);
            }
     }
    public static List<MRC__c> updateLookupOnInsert(List<MRC__c> mrcList){
        //system.debug('---------------------inside updateLookupOnInsert---------------'+mrcList);
        Set<String> shipToSet = new Set<String>();//566937MRC Upload - Fix 
        Set<String> soldToSet = new Set<String>();
        Set<String> locSet = new Set<String>();
        Set<String> plantSet = new Set<String>();
        
        Map<String,String> accSoldToIDMap = new Map<String,String>();
        Map<String,String> accShipToIDMap = new Map<String,String>();
        Map<String,String> locIDMap = new Map<String,String>();
        Map<String,String> materialIDMap = new Map<String,String>();
        if(!mrcList.isEmpty()){
            for(MRC__c mrc : mrcList){
                //System.debug('------------'+mrc);
                if(mrc <> null){
                    if(mrc.Ship_to_Number__c != null){//566937MRC Upload - Fix 
                    	shipToSet.add(mrc.Ship_to_Number__c);
                	} 
                    if(mrc.Sold_To_Number_XLS__c != null){
                        soldToSet.add(mrc.Sold_To_Number_XLS__c);
                    }
                    if(mrc.Plant_Code_XLS__c != null){
                        locSet.add(mrc.Plant_Code_XLS__c);
                    }
                    if(mrc.Material_No_XLS__c != null){
                        plantSet.add(mrc.Material_No_XLS__c);
                    }
                }
            }
        }
        String accrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        String accShipTorecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution Ship-To Account').getRecordTypeId();
    
        for(Account acc : [Select Id, Sold_To_Number__c from Account where Sold_To_Number__c in : soldToSet AND RecordTypeId =:accrecTypeId]){
            accSoldToIDMap.put(acc.Sold_To_Number__c,acc.id);
        }
        
        for(Account acc : [Select Id, Ship_to_Number__c from Account where Ship_to_Number__c in : shipToSet AND RecordTypeId =:accShipTorecTypeId]){
            accShipToIDMap.put(acc.Ship_to_Number__c,acc.id);//566937MRC Upload - Fix 
        }
        
        for(Location__c loc : [Select Id, Plant_Code__c from Location__c where Plant_Code__c in : locSet]){
            locIDMap.put(loc.Plant_Code__c,loc.id);
        }
        
        for(Product_Catalogue__c prd : [Select Id,Name from Product_Catalogue__c 
                                        where Name in : plantSet]){
            materialIDMap.put(prd.Name,prd.id);
        }
        List<MRC__c> updateMRCList = new List<MRC__c>();
        if(!mrcList.isEmpty()){
            for(MRC__c mrc : mrcList){
                if(mrc <> null){
                if(mrc.Plant_Code_XLS__c != null  && mrc.Sold_To_Number_XLS__c != null 
                   && mrc.Material_No_XLS__c != null ){
                       
                       mrc.name = mrc.Contract__c+'-'+mrc.Item_No_XLS__c;
                       mrc.Sold_To__c = accSoldToIDMap.get(mrc.Sold_To_Number_XLS__c);
                       mrc.Ship_To__c = accShipToIDMap.get(mrc.Ship_to_Number__c);//566937MRC Upload - Fix 
                       mrc.Plant__c = locIDMap.get(mrc.Plant_Code_XLS__c);
                       mrc.Product__c = materialIDMap.get(mrc.Material_No_XLS__c);
                   }
                }
                updateMRCList.add(mrc);
            }
        }
        
         return updateMRCList;
    }
}