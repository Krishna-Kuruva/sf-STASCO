@isTest
public class OLF_OldOffersCleanupBatchSchedulerTest {
    
  @isTest
  public static void deleteOLFMRCDataPositiveScenario() 
    {
        RV_OLF_MRC_Data__c objOLFMRCData = New RV_OLF_MRC_Data__c();
        Insert objOLFMRCData;
        Test.startTest();        
        OLF_OldOffersCleanupBatch obj = new OLF_OldOffersCleanupBatch();
        DataBase.executeBatch(obj);         
        OLF_OldOffersCleanupBatchScheduler obj1 = new OLF_OldOffersCleanupBatchScheduler();   
        String chron = '0 0 23 * * ?';        
        String jobid = System.schedule('testScheduledApex', chron, obj1);        
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);         
        Test.stopTest();        
    }
    @isTest
    public static void deleteOLFMRCDataNegativeScenario() 
    {
        RV_OLF_MRC_Data__c objOLFMRCData = New RV_OLF_MRC_Data__c();
        Insert objOLFMRCData;
        Test.startTest();        
        OLF_OldOffersCleanupBatch obj = new OLF_OldOffersCleanupBatch();
        obj.finish(null);         
        OLF_OldOffersCleanupBatchScheduler obj1 = new OLF_OldOffersCleanupBatchScheduler();   
        String chron = '0 0 23 * * ?';        
        String jobid = System.schedule('testScheduledApex', chron, obj1);        
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);         
        Test.stopTest();        
    }
}