/**
Discription:- This Test class belongs to 'BatchClearOffer' and 'BatchClearOfferScheduler'.
Created By:-Ashish Soni
**/

@isTest
public class RV_OfferDealCleanupBatchTest {
    
  static testMethod void testMethod1() 
    {
        RV_Offer_Tracking__c RV = New RV_Offer_Tracking__c();
        RV.MRC_Header__c = 'test';
        RV.is_Active__c = true;
        Insert RV;
        Test.startTest();

            RV_OfferDealCleanupBatch obj = new RV_OfferDealCleanupBatch();
            DataBase.executeBatch(obj); 
        
        RV_OfferDealCleanupBatchScheduler obj1 = new RV_OfferDealCleanupBatchScheduler();   
         String chron = '0 0 23 * * ?';        
         String jobid = System.schedule('testScheduledApex', chron, obj1);
        
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
         System.assertEquals(chron,ct.CronExpression); 
            
        Test.stopTest();
        
    }
    
}