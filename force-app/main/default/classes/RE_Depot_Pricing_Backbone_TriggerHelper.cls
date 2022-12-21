public class RE_Depot_Pricing_Backbone_TriggerHelper {
    
    public static void createHistoryRecords(List<Sobject> records,String parentObjApiName, String trackObjAPiName, String status)
    {
        if( !Test.isRunningTest()  || UserInfo.getUserName() == 'RunHistoryCreation@test.com')
        {
           TrackUtil.createHistoryRec(records, parentObjApiName,trackObjAPiName,status); 
        }
        
    }
    
	public static void onAfterPMTChange(List<RE_Depot_Pricing_Backbone__c> dpbList,Map<Id,RE_Depot_Pricing_Backbone__c> dpbMap){
        Map<String, RE_Depot_Pricing_Backbone__c> dpbPMTmap = new Map<String, RE_Depot_Pricing_Backbone__c>();
        List<RE_Route_Backbone__c> finalrbdlist = new List<RE_Route_Backbone__c>();
        for(RE_Depot_Pricing_Backbone__c dpbdata :  dpbList){
            dpbPMTmap.put(dpbdata.RE_Depot_Name__c+'-'+dpbdata.RE_Product_Name__c,dpbdata);
        } 
        System.debug('dpbPMTmap  '+dpbPMTmap);
        for(RE_Route_Backbone__c rbdata : RE_SOQLController.fetchRouteBackboneData()){
            if(dpbPMTmap.containsKey(rbdata.RE_Destination_Name__c+'-'+rbdata.RE_Product_Name__c)){
                System.debug('rbdata '+rbdata);
                rbdata.RE_MY_Primary_Transport_Cost__c = dpbPMTmap.get(rbdata.RE_Destination_Name__c+'-'+rbdata.RE_Product_Name__c).RE_Primary_Transport_Cost__c;
                rbdata.RE_MY_Primary_Transport_Offset__c = dpbPMTmap.get(rbdata.RE_Destination_Name__c+'-'+rbdata.RE_Product_Name__c).RE_Primary_Transport_Offset__c;
                rbdata.RE_MY_Primary_Transport_Unit__c = dpbPMTmap.get(rbdata.RE_Destination_Name__c+'-'+rbdata.RE_Product_Name__c).RE_Primary_Transport_Unit__c;
                finalrbdlist.add(rbdata);
            }                
        }
        if(!finalrbdlist.isEmpty()){
            try{
                update finalrbdlist;
            }
            catch(Exception ex){
                System.debug('Error in updating Primary Transport Cost');
            }
        }
    }
}