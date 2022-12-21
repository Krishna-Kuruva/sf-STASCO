/*
    Version : 1.0
    Author  : Souvik
    Date    : 21-Oct-2020
    Details : Initial Development
*/
trigger RE_AssessedPremiaTrigger on assessed_premia__c (after insert, after update) {
	if(RE_Trigger_Activate__c.getValues('RE_AssessedPremiaTrigger').RE_Active__c){  	
        if((Trigger.isUpdate || Trigger.isInsert) && Trigger.isAfter)
      		RE_AssessedPremiaTriggerHelper.onAfterAssessedPremiaTriggerHelper(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}