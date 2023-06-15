public class RV_InsertGroupMembersToGroupQueueable implements Queueable {
	private List<String> freighRateIdLst;
    public RV_InsertGroupMembersToGroupQueueable(List<String> freighRateIds) {
        this.freighRateIdLst = freighRateIds;
    }
    public void execute(QueueableContext context) {
        List<Freight_Rate__c> freighRate = [SELECT id,Valid_To_Fomula__c,LastModifiedById from Freight_Rate__c where
                                            Id in:freighRateIdLst AND Valid_To_Fomula__c = TODAY];
        List<Group> groupLst = [SELECT Id,DeveloperName FROM Group where DeveloperName = 'RV_LastModifiedByUserId'];
        List<GroupMember> addlistGroupMember =new List<GroupMember>();
        if(!freighRate.isEmpty()){
            for(Freight_Rate__c freightRate : freighRate){
                GroupMember gm= new GroupMember();
                gm.GroupId = groupLst.get(0).Id;
                gm.UserOrGroupId = freightRate.LastModifiedById;
                addlistGroupMember.add(gm);
            }
            if(!addlistGroupMember.isEmpty()){
                try{
                    insert addlistGroupMember;
                }catch(Exception e){
                    System.debug('-------Exception--------'+e);
                }
            }
        }
    }
}