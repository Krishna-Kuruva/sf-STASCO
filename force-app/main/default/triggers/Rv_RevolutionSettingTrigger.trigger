/*
    Version : 0.0
    Author  : Soumyajit
    Date    : 03-May-2019
    Details : Apex controller for OLF Dashboard
    */
trigger Rv_RevolutionSettingTrigger on Revolution_Setting__c (before update,after update) {
    if (Trigger.isUpdate && Trigger.isAfter)
        Rv_RevolutionSettingTriggerHelper.SettingAfterUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
}