/*****************************************************************************
@Name:  IK_InfoKioskAlert     
@=========================================================================
@Purpose: Trigger will execute on insert and update and delete to  assign the in particular user group                          
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      10/11/2017           INITIAL DEVELOPMENT
 
******************************************************************************/   
trigger IK_InfoKioskAlerts on InfoKiosk_Alert__c (before delete, before insert, before update,
                                                  after delete,after insert, after update) {
          System.debug('^^^^trigger runnnig^^^^^^^' );  
   if (Trigger.isInsert && Trigger.isAfter){ // on after insert
        IK_InfoKioskAlertHandler.onafterinsertInfoKioskAlert(Trigger.new);
   }
   if (Trigger.isInsert && Trigger.isBefore){ // on before insert
        IK_InfoKioskAlertHandler.onbeforeinsertInfoKioskAlert(Trigger.new);
   }
   if (Trigger.isUpdate && Trigger.isAfter){// on after update
        IK_InfoKioskAlertHandler.onafterupdateInfoKioskAlert(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
   }
   if (Trigger.isUpdate && Trigger.isBefore){// on before update
        IK_InfoKioskAlertHandler.onbeforeUpdateInfoKioskAlert(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
   }
   if (Trigger.isDelete && Trigger.isAfter){// on after update
        IK_InfoKioskAlertHandler.onafterdeleteInfoKiosk(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
   }
}