trigger RevolutionDashboardTrigger on Revolution_Dashboard__c (before insert,before update) {
	
   if (Trigger.isInsert && Trigger.isBefore){ // on before insert
        RevolutionDashboardTriggerHelper.onBeforeinsertRevDashboard(Trigger.new);
       
   }
   if (Trigger.isUpdate && Trigger.isBefore){// on before update
        RevolutionDashboardTriggerHelper.onBeforeupdateRevDashboard(Trigger.new,Trigger.newMap,Trigger.oldMap);
   }
}