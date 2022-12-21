/*****************************************************************************
@Name:  OLF_SendContractInformation_Schedule     
@=========================================================================
@Purpose: Scheduled class to call OLF_SendContractInformation_Queueable class for retry.
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    13-May-2020         INITIAL DEVELOPMENT

******************************************************************************/
public with sharing class OLF_SendContractInformation_Schedule implements Schedulable{
    
    //Private variable - START
    private String data;
    private Integer attempt;
    //Private variable - END

    /*Constructor Name	: OLF_SendContractInformation_Schedule     
     *Developer		: Rahul Sharma
	 *Date			: 13-May-2020
	 *Description	: constructor for OLF_SendContractInformation_Schedule*/
    public OLF_SendContractInformation_Schedule(String data, Integer attempt){
        this.data = data;
        this.attempt = attempt + 1;
    }

    public void execute(SchedulableContext sc){
        //Enqueue callout job
        OLF_SendContractInformation_Queueable enqueueCallout = new OLF_SendContractInformation_Queueable(data, attempt);
        System.enqueueJob(enqueueCallout);
    }
}