/*****************************************************************************
@Name:  OLF_SendContractInformation_Queueable     
@=========================================================================
@Purpose: Queuable class to make callout to OLF
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    12-May-2020         INITIAL DEVELOPMENT

******************************************************************************/
public with sharing class OLF_SendContractInformation_Queueable implements Queueable, Database.AllowsCallouts{

    //Private variable - START
    private String data;
    private Integer attempt;
    //Private variable - END

    /*Constructor Name	: OLF_SendContractInformation_Queueable     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: constructor for OLF_SendContractInformation_Queueable*/
    public OLF_SendContractInformation_Queueable(Map<String, List<OLFWrapper.olfDealWrap>> orderGrpVsDealWrapMap, Integer attempt){
        if(!orderGrpVsDealWrapMap.isEmpty()){
            List<OLFWrapper.olfDealGroupWrap> olfDealWrapList = new List<OLFWrapper.olfDealGroupWrap>();
            for(String orderGroup : orderGrpVsDealWrapMap.keySet()){
                OLFWrapper.olfDealGroupWrap dealGroupWrap = new OLFWrapper.olfDealGroupWrap();
                dealGroupWrap.orderId = orderGroup;
                dealGroupWrap.items = orderGrpVsDealWrapMap.get(orderGroup);
                olfDealWrapList.add(dealGroupWrap);
            }
            if(!olfDealWrapList.isEmpty()){
                try{
                    this.data = JSON.serialize(olfDealWrapList);
                }
                catch(Exception e){
                    System.debug('OLF_SendContractInformation_Queueable >> Contructor >> Exception: '+e.getMessage()+' Line: '+e.getLineNumber()+' Trace: '+e.getStackTraceString());
                    //START - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                    RV_Exception__c rvException = new RV_Exception__c();
                    rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString();
                    rvException.Apex_Class__c = 'OLF_SendContractInformation_Queueable';
                    rvException.Method_Name__c = 'Contructor';
                    rvException.Type__c = 'Exception';
                    insert rvException;
                    //END - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                }
            }
        }
        else{
            System.debug('OLF_SendContractInformation_Queueable >> Contructor: orderGrpVsDealWrapMap is empty.');
        }
        this.attempt = attempt;
    }

    /*Constructor Name	: OLF_SendContractInformation_Queueable     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: constructor for OLF_SendContractInformation_Queueable*/
    public OLF_SendContractInformation_Queueable(String data, Integer attempt){
        this.data = data;
        this.attempt = attempt;
    }

    /*Mthod Name	: execute     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: main execution method for the class*/
    public void execute(QueueableContext qc){
        if(!String.isBlank(data)){
            Map<String, String> authHeaderMap = new Map<String, String>();
            Map<String, String> requestHeaderMap = new Map<String, String>();
            List<Integer> statusCodeList = new List<Integer>();
            List<String> statusCodeStringList = new List<String>();
            OLF_HTTP_Callout.HTTPCalloutWrap authResponseWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
            OLF_HTTP_Callout.HTTPCalloutWrap responseWrap = new OLF_HTTP_Callout.HTTPCalloutWrap();
            //Get OLF callout setting
            OLF_Callout_Setting__mdt calloutSetting = [SELECT Id,
                                                              Enable_Rerty__c,
                                                              Time_Interval_In_Minutes__c,
                                                              Authorization_URL__c,
                                                              Endpoint_URL__c,
                                                              Max_Retry__c,
                                                              Error_Codes_for_Retry__c FROM OLF_Callout_Setting__mdt WHERE DeveloperName = 'OLF_SHT_Data_Push'];
            Integer interval = (calloutSetting.Time_Interval_In_Minutes__c).intValue(); 
            String acceptedStatusCodes = calloutSetting.Error_Codes_for_Retry__c;
            String authURL = calloutSetting.Authorization_URL__c;
            String endpointUrl = calloutSetting.Endpoint_URL__c;
            Integer maxRetry = (calloutSetting.Max_Retry__c).intValue();
            if(acceptedStatusCodes != null && acceptedStatusCodes != ''){
                String statusCodes = acceptedStatusCodes.replaceAll(' ','');
                statusCodeStringList = statusCodes.split(',');
                for(String str : statusCodeStringList){
                    statusCodeList.add(Integer.valueOf(str));
                }
            }
            //create authorization header
            authHeaderMap.put('Content-Type', 'application/x-www-form-urlencoded');
            //Make authorization callout
            if(!String.isBlank(authURL)){
                //Get bearer token
                authResponseWrap = OLF_HTTP_Callout.httpPost(authURL, '', authHeaderMap);
                if(authResponseWrap.statusCode == 200 || authResponseWrap.statusCode == 201){
                    System.debug('OLF_SendContractInformation_Queueable >> execute: Authorization Succesful! Attempt: '+attempt+' Status Code: '+authResponseWrap.statusCode+' Status: '+authResponseWrap.status);
                    //Prepare request header
                    String body = authResponseWrap.body;
                    Map<String, Object> authResponseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
                    String token = (String)authResponseMap.get('access_token');
                    requestHeaderMap.put('Authorization', 'Bearer ' + token);
                    requestHeaderMap.put('Content-Type', 'application/json');
                    //Make callout
                    if(!String.isBlank(endpointUrl)){
                        responseWrap = OLF_HTTP_Callout.httpPut(endpointUrl, data, requestHeaderMap);
                        if(responseWrap.statusCode != 200 && responseWrap.statusCode != 201 && statusCodeList.contains(responseWrap.statusCode) && calloutSetting.Enable_Rerty__c == true && attempt <= maxRetry){
                            System.debug('OLF_SendContractInformation_Queueable >> execute: Callout Failed! Setting up Retry. Attempt: '+attempt+' Status Code: '+responseWrap.statusCode+' Status: '+responseWrap.status);
                            scheduleRetry(interval, data, attempt);
                        }
                        else if(responseWrap.statusCode == 200 || responseWrap.statusCode == 201){
                            System.debug('OLF_SendContractInformation_Queueable >> execute: Callout Status is OK! Data either pushed completely or partially to OLF. Status Code: '+responseWrap.statusCode+' Status: '+responseWrap.status);
                            Map<String, String> olfSuccessDealNoMap = new Map<String, String>();
                            Map<String, String> olfFailedDealNoMap = new Map<String, String>();
                            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseWrap.body);
                            List<Object> succesDealObjList = (List<Object>)responseMap.get('updatedOrders');
                            List<Object> errorDealObjList = (List<Object>)responseMap.get('notUpdatedOrders');
                            for(Object obj : succesDealObjList){
                                Map<String, Object> objMap = (Map<String, Object>)obj;
                                String dealNo = (String)objMap.get('orderId');
                                String message = (String)objMap.get('message');
                                olfSuccessDealNoMap.put(dealNo, message);
                            }
                            for(Object obj : errorDealObjList){
                                Map<String, Object> objMap = (Map<String, Object>)obj;
                                String dealNo = (String)objMap.get('orderId');
                                String message = (String)objMap.get('message');
                                olfFailedDealNoMap.put(dealNo, message);
                            }
                            //Update SAP Staging records pushed to OLF.
                            if(!olfSuccessDealNoMap.isEmpty()){
                                System.debug('OLF_SendContractInformation_Queueable >> execute: Order(s) sent to OLF successfully: '+olfSuccessDealNoMap.keySet());
                                //Extract order Ids for successful deals from the JSON
                                List<OLFWrapper.olfDealGroupWrap> olfDealWrapGroupList = (List<OLFWrapper.olfDealGroupWrap>)JSON.deserialize(data, List<OLFWrapper.olfDealGroupWrap>.class);
                                Map<String, String> successDealVsMessageMap = new Map<String, String>();
                                for(OLFWrapper.olfDealGroupWrap dealGroupWrap : olfDealWrapGroupList){
                                    if(olfSuccessDealNoMap.containsKey(dealGroupWrap.orderId)){
                                        for(OLFWrapper.olfDealWrap dealWrap : dealGroupWrap.items){
                                            successDealVsMessageMap.put(dealWrap.orderId, olfSuccessDealNoMap.get(dealGroupWrap.orderId)); 
                                        }                                       
                                    }                                  
                                }
                                updateStagingRecords(successDealVsMessageMap, true);
                            }
                            //Retry SAP Staging records failed to push to OLF
                            if(!olfFailedDealNoMap.isEmpty()){
                                System.debug('OLF_SendContractInformation_Queueable >> execute: Order(s) failed to sent to OLF: '+olfFailedDealNoMap.keySet());
                                List<OLFWrapper.olfDealGroupWrap> olfDealWrapGroupList = (List<OLFWrapper.olfDealGroupWrap>)JSON.deserialize(data, List<OLFWrapper.olfDealGroupWrap>.class);
                                //Check retry eligibility
                                if(calloutSetting.Enable_Rerty__c == true && attempt <= maxRetry){
                                    System.debug('OLF_SendContractInformation_Queueable >> execute: Setting up retry for the failed records. Attempt: '+attempt);
                                    //Get Failed records
                                    List<OLFWrapper.olfDealGroupWrap> olfFailedDealWrapGroupList = new List<OLFWrapper.olfDealGroupWrap>();
                                    for(OLFWrapper.olfDealGroupWrap dealGroupWrap : olfDealWrapGroupList){
                                        if(olfFailedDealNoMap.containsKey(dealGroupWrap.orderId))
                                            olfFailedDealWrapGroupList.add(dealGroupWrap);
                                    }
                                    //Assign new JSON data
                                    data = JSON.serialize(olfFailedDealWrapGroupList);
                                    //Schedule retry for failed records
                                    scheduleRetry(interval, data, attempt);
                                }
                                else{
                                    System.debug('OLF_SendContractInformation_Queueable >> execute: Callout Failed! Cannot make callout to GSAP after multiple attempts. Status Code: '+responseWrap.statusCode+' Status: '+responseWrap.status);
                                    Map<String, String> failedDealVsMessageWrap = new Map<String, String>();
                                    //Get failed deals
                                    for(OLFWrapper.olfDealGroupWrap dealGroupWrap : olfDealWrapGroupList){
                                        if(olfFailedDealNoMap.containsKey(dealGroupWrap.orderId)){
                                            for(OLFWrapper.olfDealWrap dealWrap : dealGroupWrap.items){
                                                failedDealVsMessageWrap.put(dealWrap.orderId, olfFailedDealNoMap.get(dealGroupWrap.orderId)); 
                                            }                                       
                                        }                                  
                                    }
                                    //Update Staging records
                                    updateStagingRecords(failedDealVsMessageWrap, false);
                                }
                            }
                        }
                        else{
                            System.debug('OLF_SendContractInformation_Queueable >> execute: Callout Failed! Cannot make callout to GSAP. Status Code: '+responseWrap.statusCode+' Status: '+responseWrap.status);
                            Map<String, String> failedDealVsMessageMap = new Map<String, String>();
                            String error = 'Status Code: '+responseWrap.statusCode+' | Message: '+responseWrap.status+' | Type: Enpoint Error';
                            //Get failed deals
                            failedDealVsMessageMap = extractDealsFromJSON(data, error);
                            //Update Staging records
                            updateStagingRecords(failedDealVsMessageMap, false);
                        }
                    }
                    else{
                        try{
                            throw new CustomException('Enpoint URL cannot be empty.');
                        }
                        catch(Exception e){
                            System.debug('OLF_SendContractInformation_Queueable >> execute: '+e.getMessage()+'. Line Number: '+e.getLineNumber());
                            //START - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                            RV_Exception__c rvException = new RV_Exception__c();
                            rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString();
                            rvException.Apex_Class__c = 'OLF_SendContractInformation_Queueable';
                            rvException.Method_Name__c = 'execute';
                            rvException.Type__c = 'Exception';
                            insert rvException;
                            //END - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                        }
                    }

                }
                else if(statusCodeList.contains(authResponseWrap.statusCode) && calloutSetting.Enable_Rerty__c == true && 
                        attempt <= maxRetry){
                    System.debug('OLF_SendContractInformation_Queueable >> execute: Authorization Failed! Setting up Retry. Attempt: '+attempt+' Status Code: '+authResponseWrap.statusCode+' Status: '+authResponseWrap.status);
                    scheduleRetry(interval, data, attempt);
                }
                else{
                    System.debug('OLF_SendContractInformation_Queueable >> execute: Authorization Failed! Cannot make callout to GSAP. Status Code: '+authResponseWrap.statusCode+' Status: '+authResponseWrap.status);
                    Map<String, String> failedDealVsMessageMap = new Map<String, String>();
                    String error = 'Status Code: '+authResponseWrap.statusCode+' | Message: '+authResponseWrap.status+' | Type: OAuth Error';
                    //Get failed deals
                    failedDealVsMessageMap = extractDealsFromJSON(data, error);
                    //Update Staging records
                    updateStagingRecords(failedDealVsMessageMap, false);
                    
                }
            }
            else{
                try{
                    throw new CustomException('Authoriization URL cannot be empty.');
                }
                catch(Exception e){
                    System.debug('OLF_SendContractInformation_Queueable >> execute: '+e.getMessage()+'. Line Number: '+e.getLineNumber());
                    //START - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                    RV_Exception__c rvException = new RV_Exception__c();
                    rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString();
                    rvException.Apex_Class__c = 'OLF_SendContractInformation_Queueable';
                    rvException.Method_Name__c = 'execute';
                    rvException.Type__c = 'Exception';
                    insert rvException;
                    //END - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                }
            }
        }
        else{
            System.debug('OLF_SendContractInformation_Queueable >> execute >> Message: No data available for callout');
        }    
    }

    /*Method Name	: extractDealsFromJSON     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Schedule job to retry callout.*/
    public static Map<String, String> extractDealsFromJSON(String data, String error){
        Map<String, String> olfDealNoVsErrorMap = new Map<String, String>();
        List<OLFWrapper.olfDealGroupWrap> olfDealWrapGroupList = (List<OLFWrapper.olfDealGroupWrap>)JSON.deserialize(data, List<OLFWrapper.olfDealGroupWrap>.class);
        for(OLFWrapper.olfDealGroupWrap dealGroupWrap : olfDealWrapGroupList){
            List<OLFWrapper.olfDealWrap> olfDealWrapList = dealGroupWrap.items;
            if(!olfDealWrapList.isEmpty()){
                for(OLFWrapper.olfDealWrap dealWrap : olfDealWrapList){
                    olfDealNoVsErrorMap.put(dealWrap.orderId, error); 
                }
            }
            else{
                System.debug('OLF_SendContractInformation_Queueable >> extractDealsFromJSON >> olfDealWrapList is empty/null');
                return null;
            }
        }
        return olfDealNoVsErrorMap;
    }

    /*Method Name	: updateStagingRecords     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Update Staging records for which GSAP data is sent/failed to OLF.*/
    @future
    public static void updateStagingRecords(Map<String, String> olfDealNoVsMessageMap, Boolean isSuccess){
        if(!olfDealNoVsMessageMap.isEmpty()){
            Date lastFiveDays=system.today().addDays(-5);
            List<SAP_Staging__c> sapStagingList = new List<SAP_Staging__c>();
            Map<Id, String> shtIdVsMessageMap = new Map<Id, String>();
            //Update SAP Staging record status
            for(SHT__c record : [SELECT Id,
                                        Name, 
                                        OLF_Deal_Number__c  FROM SHT__c WHERE OLF_Deal_Number__c IN : olfDealNoVsMessageMap.keySet() AND
                                                                              CreatedDate >= :lastFiveDays]){                                                                      
                shtIdVsMessageMap.put(record.Id, olfDealNoVsMessageMap.get(record.OLF_Deal_Number__c));
            }
            if(!shtIdVsMessageMap.isEmpty()){
                for(SAP_Staging__c record : [SELECT Id,
                                                    Sent_to_OLF__c,
                                                    OLF_Response__c,
                                                    SHTId__c FROM SAP_Staging__c WHERE SHTId__c  IN : shtIdVsMessageMap.keySet()]){
                    if(isSuccess){
                        record.Sent_to_OLF__c = 'Success';
                    }
                    else{
                        record.Sent_to_OLF__c = 'Failed';
                    }
                    record.OLF_Response__c = shtIdVsMessageMap.get(record.SHTId__c);
                    sapStagingList.add(record);
                }
                if(!sapStagingList.isEmpty()){
                    try{
                        update sapStagingList;
                    }
                    catch(Exception e){
                        System.debug('OLF_SendContractInformation_Queueable >> updateStagingRecords >> Exception: '+e.getMessage()+' Line Number: '+e.getLineNumber()+' Trace: '+e.getStackTraceString());
                        //START - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                        RV_Exception__c rvException = new RV_Exception__c();
                        rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString();
                        rvException.Apex_Class__c = 'OLF_SendContractInformation_Queueable';
                        rvException.Method_Name__c = 'updateStagingRecords';
                        rvException.Type__c = 'Exception';
                        insert rvException;
                        //END - Rahul Sharma | Date - 26-Mar-2021 : Inserting error logs to RV_Exception object.
                    }
                }
                else{
                    System.debug('OLF_SendContractInformation_Queueable >> updateStagingRecords: No SAP Staging records found');
                }                                                                           
            }
            else{
                System.debug('OLF_SendContractInformation_Queueable >> updateStagingRecords: No SHT records found');
            }
        }
    }


    /*Method Name	: scheduleRetry     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Schedule job to retry callout.*/
     public static void scheduleRetry(Integer interval, String data, Integer attempt){ 
        //Get cron expression       
        String cronExp = generateCronExpFromCurrentTime(interval);
        //Schedule job
        OLF_SendContractInformation_Schedule sch = new OLF_SendContractInformation_Schedule(data, attempt);
        String currentTime = String.valueof(DateTime.now().getTime());
        System.schedule('OLF_SendContractInformation_Schedule - '+currentTime, cronExp, sch);
    }

    /*Method Name	: generateCronExpFromCurrentTime     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Generate cron exprression of given interval (in minutes) from current time.*/
    public static String generateCronExpFromCurrentTime(Integer interval){
        DateTime currentDateTime = DateTime.now();
        System.debug('OLF_SendContractInformation_Queueable >> generateCronExpFromCurrentTime >> Current Time: '+currentDateTime);
        DateTime mDateTime = currentDateTime.addMinutes(interval);
        System.debug('OLF_SendContractInformation_Queueable >> generateCronExpFromCurrentTime >> Next Scheduled Time: '+mDateTime);
        String mSecs;
        String mMins;
        String mHours;
        String mDaysOfMonth;
        String mMonths;
        String mYears;
        String cronExp;
        mSecs = String.valueOf(mDateTime.second());
        mMins = String.valueOf(mDateTime.minute());
        mHours = String.valueOf(mDateTime.hour());
        mDaysOfMonth = String.valueOf(mDateTime.day());
        mMonths = String.valueOf(mDateTime.month());
        mYears = String.valueOf(mDateTime.year());
        cronExp = mSecs+' '+mMins+' '+mHours+' '+mDaysOfMonth+' '+mMonths+' '+'? '+mYears;
        System.debug('RV_HTTPCOLF_SendContractInformation_Queueableallout_Generic >> generateCronExpFromCurrentTime cronExp: '+cronExp); 
        return cronExp; 
    }
    
    /*Class Name	: CustomException     
     *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Custom exception class*/
    public class CustomException extends Exception{}
}