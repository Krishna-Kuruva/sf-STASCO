@isTest
public class IK_LiveDisruptionTriggerClassTest {
    
    static testMethod void IK_LiveDisruptionTriggerClassCreate() {
        
       
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
      
        System.runAs (thisUser) {
            
            test.startTest();
            Group grpAllChanges = new Group ();
            grpAllChanges = IK_InfoKioskTestHelper.CreateGroupAllChanges(grpAllChanges);
            insert grpAllChanges;
            
                //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = grpAllChanges.Id;
            Insert grpMem1;
 
            
            Group grpNewChanges = new Group ();
            grpNewChanges = IK_InfoKioskTestHelper.CreateGroupItemsCreated(grpNewChanges);
            insert grpNewChanges;
            
                 //Create Group Member
            GroupMember grpMemNew = new GroupMember();
            grpMemNew.UserOrGroupId = UserInfo.getUserId();
            grpMemNew.GroupId = grpAllChanges.Id;
            Insert grpMemNew;
 
            
           
            InfoKiosk_Alert__c createInfoKioskAllChanges = new InfoKiosk_Alert__c();
            createInfoKioskAllChanges = IK_InfoKioskTestHelper.createInfoKioskAllChanges(createInfoKioskAllChanges);
            insert createInfoKioskAllChanges;
            
            
            
             IK_Location__c insertLocation = new IK_Location__c();
            insertLocation = IK_InfoKioskTestHelper.insertLocation(insertLocation);
            insert insertLocation;
        
            Live_Disruption__c insertLiveDisruptionsAllProduct = new Live_Disruption__c();
            insertLiveDisruptionsAllProduct = IK_InfoKioskTestHelper.insertLiveDisruptionAllProduct(insertLiveDisruptionsAllProduct,insertLocation);
            insert insertLiveDisruptionsAllProduct;
            
            Live_Disruption__c insertLiveDisruptionsEachProdct = new Live_Disruption__c();
            insertLiveDisruptionsEachProdct = IK_InfoKioskTestHelper.insertLiveDisruptionInProduct(insertLiveDisruptionsEachProdct,insertLocation);
            insert insertLiveDisruptionsEachProdct;
            
            InfoKiosk_Alert__c insertInfoKioskNewItemsCreated = new InfoKiosk_Alert__c();
            insertInfoKioskNewItemsCreated = IK_InfoKioskTestHelper.createInfoKioskNewCreate(insertInfoKioskNewItemsCreated);
            insert insertInfoKioskNewItemsCreated;
            test.stopTest();
            Live_Disruption__c insertLiveDisruptionsAllProducts = new Live_Disruption__c();
            insertLiveDisruptionsAllProducts = IK_InfoKioskTestHelper.insertLiveDisruptionAllProduct(insertLiveDisruptionsAllProducts,insertLocation);
            insert insertLiveDisruptionsAllProducts;
        
        }
            
        
    }
    
    static testMethod void IK_LiveDisruptionTriggerClassUpdate() {
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            
            test.startTest();
            Group grpAllChanges = new Group ();
            grpAllChanges = IK_InfoKioskTestHelper.CreateGroupAllChanges(grpAllChanges);
            insert grpAllChanges;
            
                //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = grpAllChanges.Id;
            Insert grpMem1;
 
            
            /*Group grpNewChanges = new Group ();
            grpNewChanges = IK_InfoKioskTestHelper.CreateGroupItemsCreated(grpNewChanges);
            insert grpNewChanges;*/
            
                 //Create Group Member
            GroupMember grpMemNew = new GroupMember();
            grpMemNew.UserOrGroupId = UserInfo.getUserId();
            grpMemNew.GroupId = grpAllChanges.Id;
            Insert grpMemNew;
 
            
            Group grpExistingItems = new Group ();
            grpExistingItems = IK_InfoKioskTestHelper.CreateGroupItemsModified(grpExistingItems);
            insert grpExistingItems;
            
            Group grpDeletedItems = new Group ();
            grpDeletedItems = IK_InfoKioskTestHelper.CreateGroupItemsDeleted(grpDeletedItems);
            insert grpDeletedItems;
            
            InfoKiosk_Alert__c insertInfoKioskNewItems = new InfoKiosk_Alert__c();
            insertInfoKioskNewItems = IK_InfoKioskTestHelper.createInfoKioskAllChanges(insertInfoKioskNewItems);
            insert insertInfoKioskNewItems;
        	test.stopTest();
            
            IK_Location__c insertLocation = new IK_Location__c();
            insertLocation = IK_InfoKioskTestHelper.insertLocation(insertLocation);
            insert insertLocation;
        
            Live_Disruption__c insertLiveDisruptionsAllProduct = new Live_Disruption__c();
            insertLiveDisruptionsAllProduct = IK_InfoKioskTestHelper.insertLiveDisruptionAllProduct(insertLiveDisruptionsAllProduct,insertLocation);
            insert insertLiveDisruptionsAllProduct;
        
            insertLiveDisruptionsAllProduct.Cause__c = 'Overlifting';
            update insertLiveDisruptionsAllProduct;
            
            insertLiveDisruptionsAllProduct.Status__c = 'Constraint';
            update insertLiveDisruptionsAllProduct;
        
            insertLiveDisruptionsAllProduct.Country__c = 'Austria';
            update insertLiveDisruptionsAllProduct;
            
         
            
        }
            
        
            
            
    }
    
    static testMethod void IK_LiveDisruptionTriggerClassUpdate1() {
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            test.startTest();
            Group grpAllChanges = new Group ();
            grpAllChanges = IK_InfoKioskTestHelper.CreateGroupAllChanges(grpAllChanges);
            insert grpAllChanges;
            
                //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = grpAllChanges.Id;
            Insert grpMem1;
 
            
            Group grpNewChanges = new Group ();
            grpNewChanges = IK_InfoKioskTestHelper.CreateGroupItemsCreated(grpNewChanges);
            insert grpNewChanges;
            
                 //Create Group Member
            GroupMember grpMemNew = new GroupMember();
            grpMemNew.UserOrGroupId = UserInfo.getUserId();
            grpMemNew.GroupId = grpAllChanges.Id;
            Insert grpMemNew;
 
            
            Group grpExistingItems = new Group ();
            grpExistingItems = IK_InfoKioskTestHelper.CreateGroupItemsModified(grpExistingItems);
            insert grpExistingItems;
            
            Group grpDeletedItems = new Group ();
            grpDeletedItems = IK_InfoKioskTestHelper.CreateGroupItemsDeleted(grpDeletedItems);
            insert grpDeletedItems;
            InfoKiosk_Alert__c insertInfoKioskNewItems = new InfoKiosk_Alert__c();
            insertInfoKioskNewItems = IK_InfoKioskTestHelper.createInfoKioskAllChanges(insertInfoKioskNewItems);
            insert insertInfoKioskNewItems;
        
            IK_Location__c insertLocation = new IK_Location__c();
            insertLocation = IK_InfoKioskTestHelper.insertLocation(insertLocation);
            insert insertLocation;
        
            Live_Disruption__c insertLiveDisruptionsAllProduct = new Live_Disruption__c();
            insertLiveDisruptionsAllProduct = IK_InfoKioskTestHelper.insertLiveDisruptionAllProduct(insertLiveDisruptionsAllProduct,insertLocation);
            insert insertLiveDisruptionsAllProduct;
        
            insertLiveDisruptionsAllProduct.Begin_Date__c = System.now().addDays(-1);
            update insertLiveDisruptionsAllProduct;
        
            insertLiveDisruptionsAllProduct.Estimated_End_Date__c = System.now().addDays(2);
            update insertLiveDisruptionsAllProduct;
        
            insertLiveDisruptionsAllProduct.Comment__c = 'updated';
            update insertLiveDisruptionsAllProduct;
        
            insertLiveDisruptionsAllProduct.Resolve_Date_Time__c = System.now().addDays(3);
            update insertLiveDisruptionsAllProduct;
        
            Live_Disruption__c insertLiveDisruptionsEachProdct = new Live_Disruption__c();
            insertLiveDisruptionsEachProdct = IK_InfoKioskTestHelper.insertLiveDisruptionInProduct(insertLiveDisruptionsEachProdct,insertLocation);
            insert insertLiveDisruptionsEachProdct;
        
            InfoKiosk_Alert__c insertInfoKioskNewItemsCreated = new InfoKiosk_Alert__c();
            insertInfoKioskNewItemsCreated = IK_InfoKioskTestHelper.createInfoKioskNewCreate(insertInfoKioskNewItemsCreated);
            insert insertInfoKioskNewItemsCreated;
            test.stopTest();
            Live_Disruption__c insertLiveDisruptionsAllProducts = new Live_Disruption__c();
            insertLiveDisruptionsAllProducts = IK_InfoKioskTestHelper.insertLiveDisruptionAllProduct(insertLiveDisruptionsAllProducts,insertLocation);
            insert insertLiveDisruptionsAllProducts;
            
        }
            
        
            
            
    }
    
    static testMethod void IK_LiveDisruptionTriggerClassDelete() {
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            
            test.startTest();
            
            Group grpAllChanges = new Group ();
            grpAllChanges = IK_InfoKioskTestHelper.CreateGroupAllChanges(grpAllChanges);
            insert grpAllChanges;
            
                //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = grpAllChanges.Id;
            Insert grpMem1;
 
            
            
            /*Group grpDeletedItems = new Group ();
            grpDeletedItems = IK_InfoKioskTestHelper.CreateGroupItemsDeleted(grpDeletedItems);
            insert grpDeletedItems;
            
            GroupMember grpMem2 = new GroupMember();
            grpMem2.UserOrGroupId = UserInfo.getUserId();
            grpMem2.GroupId = grpDeletedItems.Id;
            Insert grpMem2;*/
            
            InfoKiosk_Alert__c insertInfoKioskNewItems = new InfoKiosk_Alert__c();
            insertInfoKioskNewItems = IK_InfoKioskTestHelper.createInfoKioskAllChanges(insertInfoKioskNewItems);
            insertInfoKioskNewItems.changes_an_item_appears_in_following_reg__c = 'East';
            insert insertInfoKioskNewItems;
            
            /*InfoKiosk_Alert__c insertInfoKioskdeleteItems = new InfoKiosk_Alert__c();
            insertInfoKioskdeleteItems = IK_InfoKioskTestHelper.createInfoKioskItemsDeleted(insertInfoKioskdeleteItems);
            insertInfoKioskdeleteItems.changes_an_item_appears_in_following_reg__c = 'East';
            insert insertInfoKioskdeleteItems;*/
      
            IK_Location__c insertLocation = new IK_Location__c();
            insertLocation = IK_InfoKioskTestHelper.insertLocation(insertLocation);
            insert insertLocation;
        	
            Live_Disruption__c insertLiveDisruptionsAllProduct = new Live_Disruption__c();
            insertLiveDisruptionsAllProduct = IK_InfoKioskTestHelper.insertLiveDisruptionInProduct(insertLiveDisruptionsAllProduct,insertLocation);
            insertLiveDisruptionsAllProduct.Product__c = 'Avgas';
            insert insertLiveDisruptionsAllProduct;
        	
            delete insertLiveDisruptionsAllProduct;
          	test.stopTest();
         
        }
            
        
           
            
    }
    
}