/******************************************************************************************************************
className           :    RE_Cost_Price_Trigger_Helper
Description         :    Helper class for Trigger RE_MY_CostPrice_Trigger
Author              :    Vishal Nigam
Date                :    29-July-2022
*******************************************************************************************************************/
public without sharing class RE_Cost_Price_Trigger_Helper {
    public static void createHistoryRecords(List<Sobject> records,String parentObjApiName, String trackObjAPiName, String status)
    {
        if( !Test.isRunningTest()  || UserInfo.getUserName() == 'RunHistoryCreation@test.com')
        {
           TrackUtil.createHistoryRec(records, parentObjApiName,trackObjAPiName,status); 
        }
        
    }
}