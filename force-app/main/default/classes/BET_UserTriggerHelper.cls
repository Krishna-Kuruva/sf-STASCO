public class BET_UserTriggerHelper {
    public static void updateIsApprover(Map<Id,User> userList){
       Map<Id,List<String>> permissionsMap = new Map<Id,List<String>>();
        permissionsMap = BET_BDDFormTriggerUtil.getPermissionListBulk(userList.keySet());
        if(!permissionsMap.isEmpty()){
            for(User usr : userList.values()){
                List<String> assignedPermissionSet = permissionsMap.get(usr.Id);
                if(assignedPermissionSet.contains('BET_Eligible_Approver'))
                    usr.Is_Approver_User__c = True;
            }            
        }
    }
}