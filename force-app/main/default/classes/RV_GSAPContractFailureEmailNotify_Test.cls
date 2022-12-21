/*****************************************************************************************
* @author       Abhilash     
* @date         2021-02-11
* @description  Test class for: RV_GSAPContractFailureEmailNotify (SAP_Staging__c object)
*
* --------------------------------------------------------------------------
*   Developer                  Date                Description
* --------------------------------------------------------------------------* 
*   Abhilash                  2021-02-11          Test class for RV_GSAPContractFailureEmailNotify class
******************************************************************************************/
@isTest
public class RV_GSAPContractFailureEmailNotify_Test {

    @testSetup static void setup(){        
        SAP_Staging__c sapStaging = new SAP_Staging__c();
        sapStaging.SfItemShtNo__c = 'SHT - 145057';
        sapStaging.Processing_Indicator__c = '01';
        insert sapStaging;        
    }    
    
    static testmethod void GSAPContractFailureEmail_forCreation()
    {
        test.startTest();     
        SAP_Staging__c sapStagingData = new SAP_Staging__c();
        List<SAP_Staging__c> sapStagingError = new List<SAP_Staging__c> ();
        List<Id> sapStagingIds = new List<Id>();
        for(SAP_Staging__c sapStaging : [Select Id, SfItemShtNo__c, Processing_Indicator__c, Error_Processing_to_GSAP__c, createdby.Email, LastModifiedBy.Email from SAP_Staging__c limit 1])
        {
            sapStagingData.Id = sapStaging.Id;
            sapStagingData.Processing_Indicator__c = '03';
            sapStagingData.Error_Processing_to_GSAP__c = 'Test Error';
            sapStagingData.CreationInd__c = 'C';
            sapStagingIds.add(sapStaging.Id);
            sapStagingError.add(sapStagingData);
        }
        
        if(sapStagingError.size()>0)
           update sapStagingError;
        
        RV_GSAPContractFailureEmailNotify.GSAPContractFailureEmailNotify(sapStagingIds);
        
        test.stopTest();
    }
    
    static testmethod void GSAPContractFailureEmail_forCancellation()
    {
        test.startTest();     
        SAP_Staging__c sapStagingData = new SAP_Staging__c();
        List<SAP_Staging__c> sapStagingError = new List<SAP_Staging__c> ();
        List<Id> sapStagingIds = new List<Id>();
        for(SAP_Staging__c sapStaging : [Select Id, SfItemShtNo__c, Processing_Indicator__c, Error_Processing_to_GSAP__c, createdby.Email, LastModifiedBy.Email from SAP_Staging__c limit 1])
        {
            sapStagingData.Id = sapStaging.Id;
            sapStagingData.Processing_Indicator__c = '03';
            sapStagingData.Error_Processing_to_GSAP__c = 'Test Error';
            sapStagingData.CreationInd__c = 'D';
            sapStagingIds.add(sapStaging.Id);
            sapStagingError.add(sapStagingData);
        }
        
        if(sapStagingError.size()>0)
           update sapStagingError;
        
        RV_GSAPContractFailureEmailNotify.GSAPContractFailureEmailNotify(sapStagingIds);
        
        test.stopTest();
    }
    
}