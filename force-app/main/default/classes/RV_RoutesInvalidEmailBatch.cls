global class RV_RoutesInvalidEmailBatch implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'SELECT id,Valid_To_Fomula__c,LastModifiedById from Freight_Rate__c where Valid_To_Fomula__c = TODAY';
      return Database.getQueryLocator(query);
   } 

   global void execute(Database.BatchableContext BC, List<Freight_Rate__c> scope){
         List<Group> groupLst = [SELECT Id,DeveloperName FROM Group where DeveloperName = 'RV_LastModifiedByUserId'];
         delete [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId =: groupLst.get(0).Id];
         List<GroupMember> addlistGroupMember =new List<GroupMember>();  
         for(Freight_Rate__c freightRate : scope){
             GroupMember gm= new GroupMember(); 
             gm.GroupId = groupLst.get(0).Id;
             gm.UserOrGroupId = freightRate.LastModifiedById;
             addlistGroupMember.add(gm);
         }
         try{
             insert addlistGroupMember;
         }catch(Exception e){
                System.debug('-------Exception--------'+e);
         }
    }

   global void finish(Database.BatchableContext BC){
   }
}