/**
 * Created by Dharmendra.Singh2 on 11/12/2020.
 */
@IsTest
public class RV_SAPStagingNoResponseEmailBatchTest {

    @TestSetup
    public static void setup(){
        List<SAP_Staging__c> sapStagings = new List<SAP_Staging__c>();
        SAP_Staging__c sapStaging = new SAP_Staging__c();
        //sapStaging.Sent_to_GSAP__c = true;
        sapStaging.SendEmailNoGSAPResponse__c = false;
        sapStaging.Processing_Indicator__c = '01';
        insert sapStaging;
        sapStagings.add(sapStaging);

    }
    public static testMethod void sendEmailBatch(){

        Test.startTest();
        RV_SAPStagingNoResponseEmailSchl emailSchl= new RV_SAPStagingNoResponseEmailSchl();
        String cronExpr = '0 0 23 * * ?';
        String jobId = System.schedule('EmailBatchJob', cronExpr, emailSchl);
        emailSchl.execute(null);
        Test.stopTest();
    }

}