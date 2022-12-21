/***********************************************************************************
 * Created By   : Dhriti Krishna Ghosh Moulick
 * Created Date : 06/09/2018
 * Description  : This trigger will execute and calculate the live vs 8 am field value
 * Last Modified By:
 * Last Modified Date :
 * *********************************************************************************/
trigger RV_ProductDifferential on Product_Differential__c (before insert,before update,after update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
             RV_ProductDifferentialHelper.onBeforeInsert(Trigger.new);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
             RV_ProductDifferentialHelper.onBeforeUpdate(Trigger.new);
        }
        if(Trigger.isAfter){
            RV_ProductDifferentialHelper.onAfterUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
        }
        
    }
}