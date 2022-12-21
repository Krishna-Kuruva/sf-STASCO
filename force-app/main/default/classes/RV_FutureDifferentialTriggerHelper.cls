public class RV_FutureDifferentialTriggerHelper {
    public static void onBeforeInsert(List<Future_Differential__c> onBeforeNewLst){
        
       	    validationOnOverlappingDate(onBeforeNewLst);
    }
    
    public static void onBeforeUpdate(List<Future_Differential__c> onBeforeNewLst){
    		validationOnOverlappingDate(onBeforeNewLst);
        
    }
    public static void validationOnOverlappingDate(List<Future_Differential__c> onBeforeNewLst){
         Map<String,List<Future_Differential__c>> mapOfInsertedFutDif = new Map<String,List<Future_Differential__c>>();
        
         mapOfInsertedFutDif = createMap(onBeforeNewLst);
               
         List<Future_Differential__c> futDiffLst = fetchFutDifRecord(mapOfInsertedFutDif);
        
         Map<String,List<Future_Differential__c>> mapOfExistingFutDiff = createMap(futDiffLst);
        
         validationRule(onBeforeNewLst,mapOfExistingFutDiff);
    }
    public static List<Future_Differential__c> fetchFutDifRecord(Map<String,List<Future_Differential__c>> mapOfInsertedFutDiff){
        return [SELECT id,Diff_Value__c,Name,Grade__c,SubGradeSupplyType__c,Supply_Type__c,Valid_From__c,Valid_To__c
                from Future_Differential__c where SubGradeSupplyType__c in:mapOfInsertedFutDiff.keyset()];
    }
    
    public static void validationRule(List<Future_Differential__c> onBeforeNewLst,Map<String,List<Future_Differential__c>> mapOfExistingFutDiff){
        
        for(Future_Differential__c futureDiff : onBeforeNewLst){
            if(mapOfExistingFutDiff.containskey(futureDiff.SubGradeSupplyType__c)){
                List<Future_Differential__c> ftDifLst = mapOfExistingFutDiff.get(futureDiff.SubGradeSupplyType__c);
                for(Future_Differential__c ftDf : ftDifLst){
                    System.debug('-------futureDiff----'+futureDiff.Id);
                    if(ftDf.Id <> futureDiff.Id){
                        if((futureDiff.Valid_From__c >= ftDf.Valid_From__c && futureDiff.Valid_From__c <= ftDf.Valid_To__c) ||
                                  (futureDiff.Valid_To__c >= ftDf.Valid_From__c && futureDiff.Valid_To__c <= ftDf.Valid_To__c)){
                                    
                                    futureDiff.addError('Cannot put overlapping date');
                        }
                    }
                }
            }
        }
    }
    
    public static Map<String,List<Future_Differential__c>> createMap(List<Future_Differential__c> futureDiffLst){
        
        System.debug('---------futureDiffLst-------'+futureDiffLst);
        Map<String,List<Future_Differential__c>> mapOfInsertedFutDif = new Map<String,List<Future_Differential__c>>();
        for(Future_Differential__c futureDiff: futureDiffLst){
            if(!mapOfInsertedFutDif.containsKey(futureDiff.SubGradeSupplyType__c)){
                mapOfInsertedFutDif.put(futureDiff.SubGradeSupplyType__c, new List<Future_Differential__c>{futureDiff});
            }else{
                List<Future_Differential__c> marginDtaLst = mapOfInsertedFutDif.get(futureDiff.SubGradeSupplyType__c);
                marginDtaLst.add(futureDiff);
                mapOfInsertedFutDif.put(futureDiff.SubGradeSupplyType__c,marginDtaLst);
            }
        }
        return mapOfInsertedFutDif;
    }
}