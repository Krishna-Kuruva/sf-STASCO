/*
 * Description : Trigger is used to set Is Approver User field to true 
 * when the user is assigned with Eligible Approver permission set.
 * Project : BET Tool
 * Date : 13-9-2020
 */
trigger BET_UserTrigger on User (before insert,before update) {
	//BET_UserTriggerHelper.updateIsApprover(trigger.new);
}