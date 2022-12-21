public class IK_InfoKioskTestHelper {
  
    public static Group CreateGroupAllChanges(Group grpAllChanges){
        
         grpAllChanges.Name = 'Info Kiosk All Changes';
         return grpAllChanges;
    }
    
    public static Group CreateGroupItemsCreated(Group grpNewChanges){
          grpNewChanges.Name = 'Info Kiosk New Changes';
          return grpNewChanges;
    }
    
    public static Group CreateGroupItemsModified(Group grpExistingItems){
          grpExistingItems.Name = 'Info Kiosk Existing Items';
          return grpExistingItems;
    }
    
    public static Group CreateGroupItemsDeleted(Group grpDeletedItems){
          grpDeletedItems.Name = 'Info Kiosk Deleted Items';
          return grpDeletedItems;
    }
    
    public static InfoKiosk_Alert__c createInfoKioskAllChanges(InfoKiosk_Alert__c insertInfoKioskAllChanges){
        insertInfoKioskAllChanges.All_Changes__c = true;
        insertInfoKioskAllChanges.External_Stakeholder_Email_addresses__c = 'abc@gmailrde.com;cde@gmwsedail.com';
        insertInfoKioskAllChanges.Enter_Internal_Email_Addresses__c = 'qwe@gmailzq.com';
        insertInfoKioskAllChanges.Send_notification_immediately__c = true;
        return insertInfoKioskAllChanges;
    }
    
   
    
    public static InfoKiosk_Alert__c createInfoKioskNewCreate(InfoKiosk_Alert__c insertInfoKioskNewItems){
        insertInfoKioskNewItems.New_items_are_added__c = true;
        insertInfoKioskNewItems.External_Stakeholder_Email_addresses__c = 'abc@gmail.com;cde@gmail.com';
        insertInfoKioskNewItems.Send_notification_immediately__c = true;
        return insertInfoKioskNewItems;
    }
    
    public static InfoKiosk_Alert__c createInfoKioskItemsModified(InfoKiosk_Alert__c insertInfoKioskExistingItems){
        insertInfoKioskExistingItems.Existing_items_are_modified__c = true;
        insertInfoKioskExistingItems.External_Stakeholder_Email_addresses__c = 'abc@gmail.com;cde@gmail.com';
        insertInfoKioskExistingItems.Send_notification_immediately__c = true;
        return insertInfoKioskExistingItems;
    }
    
    public static InfoKiosk_Alert__c createInfoKioskItemsDeleted(InfoKiosk_Alert__c insertInfoKioskDeleteItems){
        insertInfoKioskDeleteItems.Items_are_deleted__c = true;
        insertInfoKioskDeleteItems.External_Stakeholder_Email_addresses__c = 'abc@gmail.com;cde@gmail.com';
        insertInfoKioskDeleteItems.Send_notification_immediately__c = true;
        return insertInfoKioskDeleteItems;
    }
    
    public static IK_Location__c insertLocation(IK_Location__c loc){
        
        loc.Name = 'Duisburg Varo depot';
        loc.Plant_Code__c = 'D140';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'West';
        loc.Sales_Region__c = 'West';
        loc.Location_Type__c = 'Shell Own Location';
        loc.LOC_Type__c = 'COO Barge';
        loc.Region_Name__c = 'East';
        //loc.Shipping_Conditions_Name__c = 'Road Pickup';
        //loc.Custom_Record_Type__c = 'InfoKiosk';
        loc.Scenario_Type__c = 'Import';
        return loc;
    }
    
    public static Live_Disruption__c insertLiveDisruptionAllProduct(Live_Disruption__c liveDisruption,IK_Location__c loc){
        
        liveDisruption.Status__c = 'Physical Product Outage';
        liveDisruption.Cause__c  = 'Delayed Primary Transport';
        liveDisruption.IK_Locations__c = loc.Id;
        liveDisruption.Country__c = 'Germany';
        liveDisruption.IK_Option_1__c = loc.Id;
        liveDisruption.Product__c = 'All Products';
        liveDisruption.Begin_Date__c = System.now();
        liveDisruption.Estimated_End_Date__c = System.now().addDays(1);
        liveDisruption.Comment__c = 'Live Disruption';  
        return liveDisruption;
    }
    
    public static Live_Disruption__c insertLiveDisruptionInProduct(Live_Disruption__c liveDisruption,IK_Location__c loc){
        
        liveDisruption.Status__c = 'Physical Product Outage';
        liveDisruption.Cause__c  = 'Delayed Primary Transport';
        liveDisruption.IK_Locations__c = loc.Id;
        liveDisruption.Country__c = 'Germany';
        liveDisruption.IK_Option_1__c = loc.Id;
        liveDisruption.Product__c = 'AGO;AGO VPD';
        liveDisruption.Begin_Date__c = System.now();
        liveDisruption.Estimated_End_Date__c = System.now().addDays(1);
        liveDisruption.Comment__c = 'Live Disruption';  
        return liveDisruption;
    }
}