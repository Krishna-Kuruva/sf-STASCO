/**
Discription:- This Test class belongs to 'BatchClearOffer' and 'BatchClearOfferScheduler'.
Created By:-Ashish Soni
**/

@isTest
public class RV_refreshLocationSteerBatchTest {

  static testMethod void testMethod1()
    {
        String sourceRecordTypeId = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByDeveloperName().get('Source_Steer').getRecordTypeId();

        Location__c locinsert = new Location__c();
        locinsert = RV_TestHelperPhase2.insertLocationLudwigshafen(locinsert);
        locinsert.Abbreviated_Name__c = 'Ludwigshafen';
        locinsert.Source_Location__c = true;
        insert locinsert;

        Location_Steer__c srcSteer = new Location_Steer__c();
         srcSteer = RV_TestHelperPhase2.insertsrcSteer(srcSteer,sourceRecordTypeId,locinsert);
         try{
            insert srcSteer;
         }catch(Exception de){
           system.debug('error inserting'+de);
         }
         try{
            update srcSteer;
          }catch(Exception de){
            system.debug('error inserting'+de);
         }

        Test.startTest();

        RV_refreshLocationSteersBatch obj = new RV_refreshLocationSteersBatch();
            DataBase.executeBatch(obj);

            RV_refreshLocSteersBatchScheduled obj1 = new RV_refreshLocSteersBatchScheduled();
         String chron = '0 0 23 * * ?';
         String jobid = System.schedule('testScheduledApex', chron, obj1);

        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
         System.assertEquals(chron,ct.CronExpression);

        Test.stopTest();

    }

}