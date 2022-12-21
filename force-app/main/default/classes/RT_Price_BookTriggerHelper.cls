/******************************************************************************************************************
className           :    RT_Price_BookTriggerHelper
Description         :    Helper class for Trigger RT_Price_BookTrigger
Author              :    Vishal Nigam
Date                :    07-Sept-2022
*******************************************************************************************************************/

public without sharing class RT_Price_BookTriggerHelper {
    public static void createHistoryRecords(List<Sobject> records,String parentObjApiName, String trackObjAPiName, String status)
    {
        if( !Test.isRunningTest()  || UserInfo.getUserName() == 'RunHistoryCreation@test.com')
        {
           TrackUtil.createHistoryRec(records, parentObjApiName,trackObjAPiName,status); 
        }
        
    }

}