/*****************************************************************************
@Name:  IK_DAL     
@=========================================================================
@Purpose: DAL class for info kiosk    test                   
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      14/11/2017           INITIAL DEVELOPMENT
  
******************************************************************************/  
public class IK_DAL {
    public static List<InfoKiosk_Alert__c> fetchInfoKioskAlert(List<String> alertID){
        return[select id,All_Changes__c,New_items_are_added__c,Existing_items_are_modified__c,Items_are_deleted__c,
               Anything_changes__c,Someone_changes_item_last_modified_by_me__c,Someone_changes_an_item_created_by_me__c,
               User_Selection__c,Select_Location__c,Select_Products__c,Location_Code__c
               from InfoKiosk_Alert__c where ID in:alertID];
    }
    public static List<Group> fetchGroup(Set<String> setOfGroupName){
        return [SELECT Id,DeveloperName FROM Group where DeveloperName in:setOfGroupName];
    }
    
    public static List<GroupMember> fetchGroupMember(Set<String> keyset,String userId){
        return[select id,Group.DeveloperName,GroupId,UserOrGroupId from Groupmember where Group.DeveloperName in:keySet AND UserOrGroupId=:userId];
    }
}