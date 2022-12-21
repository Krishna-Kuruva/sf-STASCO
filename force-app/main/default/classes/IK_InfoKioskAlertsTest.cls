@isTest
public class IK_InfoKioskAlertsTest {
    
    static testMethod void IK_InfoKioskAlertsCreate() {
        
            Group grpAllChanges = new Group ();
            grpAllChanges = IK_InfoKioskTestHelper.CreateGroupAllChanges(grpAllChanges);
            insert grpAllChanges;
            
            Group grpNewChanges = new Group ();
            grpNewChanges = IK_InfoKioskTestHelper.CreateGroupItemsCreated(grpNewChanges);
            insert grpNewChanges;
            
            Group grpExistingItems = new Group ();
            grpExistingItems = IK_InfoKioskTestHelper.CreateGroupItemsModified(grpExistingItems);
            insert grpExistingItems;
            
            Group grpDeletedItems = new Group ();
            grpDeletedItems = IK_InfoKioskTestHelper.CreateGroupItemsDeleted(grpDeletedItems);
            insert grpDeletedItems;
           
            InfoKiosk_Alert__c insertInfoKioskAllChanges = new InfoKiosk_Alert__c();
            insertInfoKioskAllChanges = IK_InfoKioskTestHelper.createInfoKioskAllChanges(insertInfoKioskAllChanges);
            insert insertInfoKioskAllChanges;
            
            InfoKiosk_Alert__c insertInfoKioskNewItems = new InfoKiosk_Alert__c();
            insertInfoKioskNewItems = IK_InfoKioskTestHelper.createInfoKioskNewCreate(insertInfoKioskNewItems);
            insert insertInfoKioskNewItems;
         
            
            InfoKiosk_Alert__c insertInfoKioskExistingItems = new InfoKiosk_Alert__c();
            insertInfoKioskExistingItems = IK_InfoKioskTestHelper.createInfoKioskItemsModified(insertInfoKioskExistingItems);
            insert insertInfoKioskExistingItems;
         
            InfoKiosk_Alert__c insertInfoKioskDeleteItems = new InfoKiosk_Alert__c();
            insertInfoKioskDeleteItems = IK_InfoKioskTestHelper.createInfoKioskItemsDeleted(insertInfoKioskDeleteItems);
            insert insertInfoKioskDeleteItems;
     
    }
    
    static testMethod void IK_InfoKioskAlertsModfication() {
       
            Group grpAllChanges = new Group ();
            grpAllChanges = IK_InfoKioskTestHelper.CreateGroupAllChanges(grpAllChanges);
            insert grpAllChanges;
            
            Group grpNewChanges = new Group ();
            grpNewChanges = IK_InfoKioskTestHelper.CreateGroupItemsCreated(grpNewChanges);
            insert grpNewChanges;
            
            Group grpExistingItems = new Group ();
            grpExistingItems = IK_InfoKioskTestHelper.CreateGroupItemsModified(grpExistingItems);
            insert grpExistingItems;
            
            Group grpDeletedItems = new Group ();
            grpDeletedItems = IK_InfoKioskTestHelper.CreateGroupItemsDeleted(grpDeletedItems);
            insert grpDeletedItems;
           
            InfoKiosk_Alert__c insertInfoKioskAllChanges = new InfoKiosk_Alert__c();
            insertInfoKioskAllChanges = IK_InfoKioskTestHelper.createInfoKioskAllChanges(insertInfoKioskAllChanges);
            insert insertInfoKioskAllChanges;
            
            insertInfoKioskAllChanges.All_Changes__c = false;
            insertInfoKioskAllChanges.New_items_are_added__c = true;
            update insertInfoKioskAllChanges;
            
            InfoKiosk_Alert__c insertInfoKioskNewItems = new InfoKiosk_Alert__c();
            insertInfoKioskNewItems = IK_InfoKioskTestHelper.createInfoKioskNewCreate(insertInfoKioskNewItems);
            insert insertInfoKioskNewItems;
            
            insertInfoKioskNewItems.New_items_are_added__c = false;
            insertInfoKioskNewItems.Existing_items_are_modified__c = true;
            update insertInfoKioskNewItems;
         
            
            InfoKiosk_Alert__c insertInfoKioskExistingItems = new InfoKiosk_Alert__c();
            insertInfoKioskExistingItems = IK_InfoKioskTestHelper.createInfoKioskItemsModified(insertInfoKioskExistingItems);
            insert insertInfoKioskExistingItems;
        
            insertInfoKioskExistingItems.Existing_items_are_modified__c = false;
            insertInfoKioskExistingItems.Items_are_deleted__c = true;
            update insertInfoKioskExistingItems;
         
            InfoKiosk_Alert__c insertInfoKioskDeleteItems = new InfoKiosk_Alert__c();
            insertInfoKioskDeleteItems = IK_InfoKioskTestHelper.createInfoKioskItemsDeleted(insertInfoKioskDeleteItems);
            insert insertInfoKioskDeleteItems;
        
            insertInfoKioskDeleteItems.Items_are_deleted__c = false;
            insertInfoKioskDeleteItems.All_Changes__c = true;
            update insertInfoKioskDeleteItems;
     
    }
    
    static testMethod void IK_InfoKioskAlertsDeletion() {
       
            Group grpAllChanges = new Group ();
            grpAllChanges = IK_InfoKioskTestHelper.CreateGroupAllChanges(grpAllChanges);
            insert grpAllChanges;
            
            Group grpNewChanges = new Group ();
            grpNewChanges = IK_InfoKioskTestHelper.CreateGroupItemsCreated(grpNewChanges);
            insert grpNewChanges;
            
            Group grpExistingItems = new Group ();
            grpExistingItems = IK_InfoKioskTestHelper.CreateGroupItemsModified(grpExistingItems);
            insert grpExistingItems;
            
            Group grpDeletedItems = new Group ();
            grpDeletedItems = IK_InfoKioskTestHelper.CreateGroupItemsDeleted(grpDeletedItems);
            insert grpDeletedItems;
           
            InfoKiosk_Alert__c insertInfoKioskAllChanges = new InfoKiosk_Alert__c();
            insertInfoKioskAllChanges = IK_InfoKioskTestHelper.createInfoKioskAllChanges(insertInfoKioskAllChanges);
            insert insertInfoKioskAllChanges;
            delete insertInfoKioskAllChanges;
            
            
            InfoKiosk_Alert__c insertInfoKioskNewItems = new InfoKiosk_Alert__c();
            insertInfoKioskNewItems = IK_InfoKioskTestHelper.createInfoKioskNewCreate(insertInfoKioskNewItems);
            insert insertInfoKioskNewItems;
            delete insertInfoKioskNewItems;
           
            
            InfoKiosk_Alert__c insertInfoKioskExistingItems = new InfoKiosk_Alert__c();
            insertInfoKioskExistingItems = IK_InfoKioskTestHelper.createInfoKioskItemsModified(insertInfoKioskExistingItems);
            insert insertInfoKioskExistingItems;
            delete insertInfoKioskExistingItems;
           
            InfoKiosk_Alert__c insertInfoKioskDeleteItems = new InfoKiosk_Alert__c();
            insertInfoKioskDeleteItems = IK_InfoKioskTestHelper.createInfoKioskItemsDeleted(insertInfoKioskDeleteItems);
            insert insertInfoKioskDeleteItems;
            delete insertInfoKioskDeleteItems;
        
    }
}