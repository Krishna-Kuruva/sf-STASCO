public class RV_MarginTriggerHelper {
    
    public static void onBeforeInsert(List<Margin__c> onBeforeNewLst){
        
       
        Map<String,List<Margin__c>> mapOfInsertedMargin = new Map<String,List<Margin__c>>();
        
        mapOfInsertedMargin = createMap(onBeforeNewLst);
        
        List<Margin__c> marginLst = fetchMarginRecord(mapOfInsertedMargin);
         
        Map<String,List<Margin__c>> mapOfExistingMargin = createMap(marginLst);
        
        validationRule(onBeforeNewLst,mapOfExistingMargin);
    }
    
    public static void onBeforeUpdate(List<Margin__c> onBeforeNewLst){
        
        Map<String,List<Margin__c>> mapOfInsertedMargin = new Map<String,List<Margin__c>>();
        
        mapOfInsertedMargin = createMap(onBeforeNewLst);
         
        List<Margin__c> marginLst = fetchMarginRecord(mapOfInsertedMargin);
         
        Map<String,List<Margin__c>> mapOfExistingMargin = createMap(marginLst);
        
        validationRule(onBeforeNewLst,mapOfExistingMargin);
    }
    
    public static List<Margin__c> fetchMarginRecord(Map<String,List<Margin__c>> mapOfInsertedMargin){
        return [SELECT Id,
                       SalesOrgPlantCodeMot__c,
                       Valid_To__c,
                       Valid_From__c,
                       Plant__c,
                       Margin_Type__c,
                       Plant_Code__c,
                       Sales_Org__c,
                       Tranche__c FROM Margin__c WHERE SalesOrgPlantCodeMot__c IN :mapOfInsertedMargin.keyset() AND 
                                                         Default__c =: false];
    }
    
    public static void validationRule(List<Margin__c> onBeforeNewLst,Map<String,List<Margin__c>> mapOfExistingMargin){
        
        for(Margin__c mrgin : onBeforeNewLst){
            if(mapOfExistingMargin.containskey(mrgin.SalesOrgPlantCodeMot__c)){
                List<Margin__c> marginLst = mapOfExistingMargin.get(mrgin.SalesOrgPlantCodeMot__c);
                for(Margin__c mrgn : marginLst){
                    //START - Rahul Sharma | Date - 18-Jun-20 : Updated logic to allow Margin creation with different tranche.
                    if(mrgn.Id <> mrgin.Id && mrgn.Tranche__c == mrgin.Tranche__c){
                    //END - Rahul Sharma | Date - 18-Jun-20 : Updated logic to allow Margin creation with different tranche.
                        if((mrgin.Valid_From__c >= mrgn.Valid_From__c && mrgin.Valid_From__c <= mrgn.Valid_To__c) ||
                                  (mrgin.Valid_To__c >= mrgn.Valid_From__c && mrgin.Valid_To__c <= mrgn.Valid_To__c)){                                 
                                    mrgin.addError('Cannot put overlapping date');
                        }
                    }
                }
            }
        }
    }
    
    public static Map<String,List<Margin__c>> createMap(List<Margin__c> marginLst){
        
        System.debug('---------marginLst-------'+marginLst);
        Map<String,List<Margin__c>> mapOfInsertedMargin = new Map<String,List<Margin__c>>();
        for(Margin__c margin: marginLst){
            if(!mapOfInsertedMargin.containsKey(margin.SalesOrgPlantCodeMot__c)){
                mapOfInsertedMargin.put(margin.SalesOrgPlantCodeMot__c, new List<Margin__c>{margin});
            }else{
                List<Margin__c> marginDtaLst = mapOfInsertedMargin.get(margin.SalesOrgPlantCodeMot__c);
                marginDtaLst.add(margin);
                mapOfInsertedMargin.put(margin.SalesOrgPlantCodeMot__c,marginDtaLst);
            }
        }
        return mapOfInsertedMargin;
    }
}