/*****************************************************************************
@Name:  OLF_SendContractInformation     
@=========================================================================
@Purpose: Class to send GSAP Contract data to OLF
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    31-Mar-2020         INITIAL DEVELOPMENT

******************************************************************************/
public with sharing class OLF_SendContractInformation{

    /*Method Name	: sendContractInfoToOLF     
     *Developer		: Rahul Sharma
	 *Date			: 31-Mar-2020
	 *Description	: Send GSAP contract info and lifting Ids to OLF for the created deals*/
    public static void sendContractInfoToOLF(Map<String, List<OLFWrapper.olfDealWrap>> orderGrpVsDealWrapMap){
        if(!orderGrpVsDealWrapMap.isEmpty()){
            try{
                OLF_SendContractInformation_Queueable enqueueCallout = new OLF_SendContractInformation_Queueable(orderGrpVsDealWrapMap, 1);
                System.enqueueJob(enqueueCallout);
            }
            catch(Exception e){
                System.debug('OLF_SendContractInformation >> sendContractInfoToOLF >> Exception: '+e.getMessage()+' Line: '+e.getLineNumber()+' Trace: '+e.getStackTraceString());
                //START - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                RV_Exception__c rvException = new RV_Exception__c();
                rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber();
                rvException.Apex_Class__c = 'OLF_SendContractInformation';
                rvException.Method_Name__c = 'sendContractInfoToOLF';
                rvException.Type__c = 'Exception';
                insert rvException;
                //END - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
            }
        }
        else{
            System.debug('OLF_SendContractInformation >> sendContractInfoToOLF: orderGrpVsDealWrapMap map is empty.');
            //START - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
            RV_Exception__c rvException = new RV_Exception__c();
            rvException.getMessage__c = 'orderGrpVsDealWrapMap map is empty.';
            rvException.Apex_Class__c = 'OLF_SendContractInformation';
            rvException.Method_Name__c = 'sendContractInfoToOLF';
            rvException.Type__c = 'Info';
            insert rvException;
            //END - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
        }
    }
}