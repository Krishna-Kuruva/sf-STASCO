/******************************************************************************************************************
className           :    RE_SG_CostPrice_TriggerHelper
Description         :    Helper class for Trigger RE_SG_CostPrice_Trigger
Author              :    Vishal Nigam
Date                :    06-Sept-2022
*******************************************************************************************************************/
public without sharing class RE_SG_CostPrice_TriggerHelper {
    public static void createHistoryRecords(List<Sobject> records,String parentObjApiName, String trackObjAPiName, String status)
    {
        if(( !Test.isRunningTest() ) || UserInfo.getUserName() == 'RunHistoryCreation@test.com')
        {
           TrackUtil.createHistoryRec(records, parentObjApiName,trackObjAPiName,status); 
        }        
    }    
}