/******************************************************************************************************************
className           :    REVCountry_Setting_TriggerHelper
Description         :    Helper class for Trigger REVCountry_Setting_Trigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
*******************************************************************************************************************/
public without sharing class REVCountry_Setting_TriggerHelper {
    public static void createHistoryRecords(List<Sobject> records,String parentObjApiName, String trackObjAPiName, String status)
    {
        if( !Test.isRunningTest()  || UserInfo.getUserName() == 'RunHistoryCreation@test.com')
        {
           TrackUtil.createHistoryRec(records, parentObjApiName,trackObjAPiName,status); 
        }
        
    }
}