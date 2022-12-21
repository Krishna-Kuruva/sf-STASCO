/*****************************************************************************
@Name:  RV_BIOAMVsTriggerHelperTest     
@=========================================================================
@Purpose: Test class for BIO AMV functionality
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      12/04/2018         INITIAL DEVELOPMENT

******************************************************************************/
@isTest
private class RV_BIOAMVsTriggerHelperTest {

    @testSetup static void setup() {
        // Create common test BIO AMVs
        List<Bio_AMVs__c> testAccts = new List<Bio_AMVs__c>();
        Location__c location = new Location__c();
        location = RV_TestHelper.insertLocation(location);
        
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Bio_AMVs__c(Plant__c = location.Id));
        }
        insert testAccts;        
    }
    
    //Test method for Batch
    @isTest static void testMethodBIOAMVBatch() {
         List<Bio_AMVs__c> bioAMV = [SELECT Id,Plant__c,Prompt_Valid_From__c,Prompt_valid_To__c,Future_Valid_From__c,
                                     Future_Valid_To__c,Override_Date__c FROM Bio_AMVs__c ];
         RV_BIOAMVDailyBatch bioAMVBatch = new RV_BIOAMVDailyBatch();
         System.enqueueJob(new RV_BIOAMVDailyBatch());
         //database.executeBatch(bioAMVBatch);
    }
    
	//Test method for Triggers
    @isTest static void testMethodTrigger() {
        //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
        Bio_AMVs__c bioAMV = [SELECT Id,Plant__c,Prompt_Valid_From__c,Prompt_valid_To__c,Override_Date__c,Future_Valid_From__c,Future_Valid_To__c FROM Bio_AMVs__c LIMIT 1];
        bioAMV.Prompt_Valid_From__c= System.Today();
        bioAMV.Override_Date__c=System.Today().addDays(-1);
        //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
        update bioAMV;
        
    }
    //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
    //Test method for Triggers
    @isTest static void testMethod1Trigger() {
        
        Bio_AMVs__c bioAMV = [SELECT Id,Plant__c,Prompt_Valid_From__c,Prompt_valid_To__c,Override_Date__c,Future_Valid_From__c,Future_Valid_To__c FROM Bio_AMVs__c LIMIT 1];
        bioAMV.Prompt_Valid_From__c= System.Today();
        bioAMV.Override_Date__c=System.Today().addDays(1);
        update bioAMV;
        
    }
    //Fix_PBI-513549_12Jun2020_Lakshmi_Ends
    
    //Test method for Scheduler
    @isTest static void testMethodScheduler() {
        //Fix_PBI-513549_12Jun2020_Lakshmi_Starts
        //List<Bio_AMVs__c> bioAMV = [SELECT Id,Plant__c,Prompt_Valid_From__c,Prompt_valid_To__c,Future_Valid_From__c,
          //                           Future_Valid_To__c FROM Bio_AMVs__c ];
        Bio_AMVs__c bioAMV = [SELECT Id,Plant__c,Prompt_Valid_From__c,Override_Date__c,Prompt_valid_To__c,Future_Valid_From__c,
                                    Future_Valid_To__c FROM Bio_AMVs__c limit 1];
        bioAMV.Prompt_Valid_From__c= System.Today();
        bioAMV.Override_Date__c=System.Today().addDays(1);
        update bioAMV;
        //Fix_PBI-513549_12Jun2020_Lakshmi_Ends
        Test.StartTest();

        RV_BIOAMVScheduler bioScheduler = new RV_BIOAMVScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Bio AMV', sch, bioScheduler); 
        System.enqueueJob(new RV_BIOAMVDailyBatch());
        Test.stopTest();
    
    }
    
    
}