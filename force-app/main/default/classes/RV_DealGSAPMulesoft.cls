/*****************************************************************************
@Name:  RV_DealGSAPMulesoft     
@=========================================================================
@Purpose: This class is used to make oauth, callout  for deal interface                  
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      13/01/2021         INITIAL DEVELOPMENT
@1.1 - Rahul Sharma                      04/03/2021         Updated code logic to support muliple header + line item deals in one transaction to support OLF.
@1.2 - Rahul Sharma                      29/04/2021         Added exception handling..
******************************************************************************/
global class RV_DealGSAPMulesoft {
    private static Integer retryCount = 0;  
    global static String basicAuthCallout(Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap){
        
          	string accessToken='';
        	if(revDealGSAPMap.containskey('Oauth')){
                Revolution_Deal_GSAP_Config__mdt oauth = revDealGSAPMap.get('Oauth');
                string payload = 'client_id=' + oauth.Client_Id__c + '&client_secret=' + oauth.Client_Secret__c +'&grant_type=client_credentials';
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setMethod(oauth.Method__c);
                req.setEndpoint(oauth.Endpoint__c);
                req.setHeader('Content-Type',oauth.Content_Type__c);
                req.setHeader('Content-Length',String.valueOf(payload.length()));
                req.setBody(payload);
                req.setTimeout(120000);
                Http binding = new Http();
                try{
                    res = binding.send(req);
                    if(res.getStatusCode() == 200){
                        JSONParser parser = JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            if (parser.getText() =='access_token'){
                                parser.nextToken();
                                accessToken= parser.getText();
                                System.debug('------accessToken------'+accessToken);
                            }
                        }
                    }
                    else{
                        try{
                            throw new CustomException('Authentication Failed.');
                        }
                        catch(Exception e){
                            System.debug('RV_DealGSAPMulesoft >> basicAuthCallout: '+e.getMessage()+'. Line number: '+e.getLineNumber());
                            RV_Exception__c rvException = new RV_Exception__c();
                            rvException.gsap_Message__c = res.getBody();
                            rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line Number: ' + String.valueOf(e.getLineNumber());
                            rvException.Apex_Class__c = 'RV_DealGSAPMulesoft';
                            rvException.Method_Name__c = 'basicAuthCallout';
                            rvException.Type__c = 'Info';
                            rvException.Status_Code__c = String.valueOf(res.getStatusCode());
                            logException(new List<RV_Exception__c>{rvException});
                        }
                    }
                }
                catch(Exception excp){
                    System.debug('RV_DealGSAPMulesoft >> basicAuthCallout: '+excp.getMessage()+'. Line number: '+excp.getLineNumber());
                    RV_Exception__c rvException = new RV_Exception__c();
                    rvException.gsap_Message__c = payload;
                    rvException.getMessage__c = 'Message: ' + excp.getMessage() + ' Line Number: ' + String.valueOf(excp.getLineNumber());
                    rvException.Apex_Class__c = 'RV_DealGSAPMulesoft';
                    rvException.Method_Name__c = 'basicAuthCallout';
                    rvException.Type__c = 'Exception';
                    rvException.Status_Code__c = String.valueOf(res.getStatusCode());
                    logException(new List<RV_Exception__c>{rvException});
                }   
        	}
        	return accessToken;
    }
    
    global static void createUpdateDelDealinGSAP(String access_Token,List<String> sapstagingStrngList,
                                        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap){
        List<SAP_Staging__c>  fetchsapStagingLst = [SELECT Id,PO_Type__c,Instance_URL__c,PriceInd__c,Handling_Type__c, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                  SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, CondPUnt__c, CondType__c, 
                  CondUnit__c, ContEndDate__c, ContStartDate__c, Count__c, Counter__c, CreationInd__c, CurrencyKey__c, 
                  Deal_Created_Date__c, EndDate__c, Error_Processing_to_GSAP__c, MaterialNo__c, MrcItemNo__c,
                  Processing_Indicator__c, QuantityUom__c, Quantity__c, Record_Created_Date__c, Record_Created_Time__c,
                  Rejection_Reason__c, SHTId__c, SalesOrg__c, SalesPrice__c, SapMrcNo__c, SapSalesContNo__c, 
                  Sent_to_GSAP__c, SfItemShtNo__c, StartDate__c, Status__c, SendEmailNoGSAPResponse__c,
                  Ship_TO_Name__c, SoldToName__c, StatusInd__c, Sent_to_OLF__c,
                  OLF_Response__c, SHT_Transaction_Id__c FROM SAP_Staging__c where Id in:sapstagingStrngList order by Count__c];                                
        if(revDealGSAPMap.containskey('CreateDeal')){
            List<String> sapStagingIdList = new List<String>();
            Map<String, RV_DealGSAPMulesoftWrapper.exceptionClass> txIdVsExpWrapMap = new Map<String, RV_DealGSAPMulesoftWrapper.exceptionClass>();
            Map<String, String> txIdVsDealGsapDataMap = createJSOnStringDeal(fetchsapStagingLst);
            Revolution_Deal_GSAP_Config__mdt createDeal = revDealGSAPMap.get('CreateDeal');
            Map<String, RV_DealGSAPMulesoftWrapper> txIdVsResWrapMap = new  Map<String, RV_DealGSAPMulesoftWrapper>();
            List<RV_Exception__c> rvExceptionList = new List<RV_Exception__c>();
            for(String txId : txIdVsDealGsapDataMap.keySet()){
                HttpRequest req = new HttpRequest();
                req.setMethod(createDeal.Method__c);
                req.setEndpoint(createDeal.Endpoint__c);
                req.setHeader('Content-Type',createDeal.Content_Type__c);
                req.setHeader('Authorization', 'Bearer ' +access_Token);
                req.setBody(txIdVsDealGsapDataMap.get(txId));
            	req.setTimeout(120000);
                Http binding = new Http();
                HttpResponse res = new HttpResponse();
                try{
                    res = binding.send(req);
                    System.debug('RV_DealGSAPMulesoft >> createUpdateDelDealinGSAP >> Transaction Id: '+txId+' Response: '+res.getBody());
            	    System.debug('RV_DealGSAPMulesoft >> createUpdateDelDealinGSAP >> Transaction Id: '+txId+' Status Code: '+res.getStatusCode());
                    //Deal Sent to GSAP Successfully
                    if(res.getStatusCode() == 201){
                        RV_DealGSAPMulesoftWrapper deserializeWrapper =(RV_DealGSAPMulesoftWrapper)JSON.deserialize(res.getBody(), RV_DealGSAPMulesoftWrapper.class);
                        System.debug('RV_DealGSAPMulesoft >> createUpdateDelDealinGSAP >> Transaction Id: '+txId+' SAP Contract No: '+deserializeWrapper.SapSalesContNo);
                        if(!String.isEmpty(deserializeWrapper.SapSalesContNo)){
                            txIdVsResWrapMap.put(txId, deserializeWrapper);
                        }
                        else{
                            //Log exception for no SAP contract number returned.
                            RV_Exception__c rvException = new RV_Exception__c();
                            rvException.gsap_Message__c = res.getBody();
                            rvException.getMessage__c = 'SAP Contract Number not received';
                            rvException.Callout_Req_Body__c = txIdVsDealGsapDataMap.get(txId);
                            rvException.Apex_Class__c = 'RV_DealGSAPMulesoft';
                            rvException.Method_Name__c = 'createUpdateDelDealinGSAP';
                            rvException.Type__c = 'Info';
                            rvException.Rv_Item_Number__c = 'SHT Transaction Id: '+txId;
                            rvException.Status_Code__c = String.valueOf(res.getStatusCode());
                            rvExceptionList.add(rvException);
                        }
                    }
                    else{
                        //Handle callout error
                        RV_Exception__c rvException = new RV_Exception__c();
                        RV_DealGSAPMulesoftWrapper.exceptionClass excp = new RV_DealGSAPMulesoftWrapper.exceptionClass();
                        rvException.gsap_Message__c = res.getBody();
                        rvException.Type__c = 'Exception';
                        rvException.Callout_Req_Body__c = txIdVsDealGsapDataMap.get(txId);
                        rvException.Status_Code__c = String.valueOf(res.getStatusCode());
                        rvException.Apex_Class__c = 'RV_DealGSAPMulesoft';
                        rvException.Method_Name__c = 'createUpdateDelDealinGSAP';
                        rvException.Rv_Item_Number__c = 'SHT Transaction Id: '+txId;
                        rvException.getMessage__c = 'Status: ' + res.getStatus() + 'Status Code: ' + String.valueOf(res.getStatusCode()) + '. Attempt: ' + String.valueOf(retryCount);
                        //START - Rahul Sharma | Date - 21-04-2021 : Commenting logic to collect data for retry
                        /*RV_DealGSAPMulesoftWrapper dealWrapper =(RV_DealGSAPMulesoftWrapper)JSON.deserialize(txIdVsDealGsapDataMap.get(txId), RV_DealGSAPMulesoftWrapper.class);
                        List<RV_DealGSAPMulesoftWrapper.RV_SHTItems> shtItemWrapList = dealWrapper.SHTItems;
                        for(RV_DealGSAPMulesoftWrapper.RV_SHTItems shtItemWrap : shtItemWrapList){
                            for(SAP_Staging__c sapStaging : fetchsapStagingLst){
                                if(sapStaging.SfItemShtNo__c == shtItemWrap.SfItemShtNo)
                                    sapStagingIdList.add(sapStaging.Id);
                            }
                        }*/
                        //END - Rahul Sharma | Date - 21-04-2021 : Commenting logic to collect data for retry.
                        excp.errorMessage = 'Status: ' + res.getStatus() + 'Status Code: ' + String.valueOf(res.getStatusCode());
                        txIdVsExpWrapMap.put(txId, excp);
                        rvExceptionList.add(rvException);
                    }
                }
                catch(Exception e){
                    System.debug('RV_DealGSAPMulesoft >> createUpdateDelDealinGSAP: '+e.getMessage()+'. Line number: '+e.getLineNumber());
                    RV_Exception__c rvException = new RV_Exception__c();
                    rvException.getMessage__c = 'Message: ' + e.getMessage() + ' Line Number: ' + String.valueOf(e.getLineNumber());
                    rvException.Callout_Req_Body__c = req.getBody();
                    rvException.Apex_Class__c = 'RV_DealGSAPMulesoft';
                    rvException.Method_Name__c = 'createUpdateDelDealinGSAP';
                    rvException.Type__c = 'Exception';
                    rvException.Rv_Item_Number__c = 'SHT Transaction Id: '+txId;
                    rvExceptionList.add(rvException);
                    //update SAP Staging record with error message.
                    RV_DealGSAPMulesoftWrapper.exceptionClass excp = new RV_DealGSAPMulesoftWrapper.exceptionClass();
                    excp.errorMessage = 'Message: ' + e.getMessage() + ' Line Number: ' + String.valueOf(e.getLineNumber());
                    txIdVsExpWrapMap.put(txId, excp);
                }
            }
            if(!rvExceptionList.isEmpty()){
                logException(rvExceptionList);
            }
            //Update SAP Staging on Success
            if(!txIdVsResWrapMap.isEmpty()){
                System.debug('RV_DealGSAPMulesoft >> createUpdateDelDealinGSAP >> Deals sent to GSAP. txIdVsResWrapMap: '+txIdVsResWrapMap);
                updateSAPStaging(fetchsapStagingLst, txIdVsResWrapMap);
            }
            //Retry Callout to GSAP on failure
            if(!sapStagingIdList.isEmpty()){
                /*System.debug('RV_DealGSAPMulesoft >> createUpdateDelDealinGSAP >> Error processing deals. Records ready to retry: '+sapStagingIdList);
                RV_DealGSAPMulesoftHelper_Queueable.DealGSAPMulesoftHelperWrapper dealGsapMuleRWrap = new RV_DealGSAPMulesoftHelper_Queueable.DealGSAPMulesoftHelperWrapper();
                RV_DealGSAPMulesoftHelper_Queueable.RetryDealPushWrapper retryDealPushWrap = new RV_DealGSAPMulesoftHelper_Queueable.RetryDealPushWrapper();
                retryDealPushWrap.access_token = access_token;
                retryDealPushWrap.rtryCount = retryCount;
                retryDealPushWrap.sapStagingIdList = sapStagingIdList;
                retryDealPushWrap.revDealGSAPMap = revDealGSAPMap;
                dealGsapMuleRWrap.retryDealPushWrap = retryDealPushWrap;
                RV_DealGSAPMulesoftHelper_Queueable enqueueJob = new RV_DealGSAPMulesoftHelper_Queueable(dealGsapMuleRWrap);
                System.enqueueJob(enqueueJob);*/
            }
            //Update SAP Staging on Error
            if(!txIdVsExpWrapMap.isEmpty()){
                System.debug('RV_DealGSAPMulesoft >> createUpdateDelDealinGSAP >> Error processing deals. Errors: '+txIdVsExpWrapMap);
                updaterrorMessage(fetchsapStagingLst, txIdVsExpWrapMap);
            }
        }
    }
    
    global static String getDealinGSAP(String access_Token,String sapSalesContNo,
                                     Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap){
        String response = '';
        if(revDealGSAPMap.containskey('GetDeal')){
            Revolution_Deal_GSAP_Config__mdt createDeal = revDealGSAPMap.get('GetDeal');
                HttpRequest req = new HttpRequest();
                req.setMethod(createDeal.Method__c);
                req.setEndpoint(createDeal.Endpoint__c+'/'+sapSalesContNo);
                req.setHeader('Content-Type','');
                req.setHeader('Authorization', 'Bearer ' +access_Token);
            	req.setTimeout(120000);
                Http binding = new Http();
                HttpResponse res = binding.send(req);
                System.debug('-------------'+res.getBody());
            	System.debug('-------------'+res.getStatusCode());
                response = res.getBody();
                if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                    
                    RV_DealGSAPMulesoftWrapper deserializeWrapper =(RV_DealGSAPMulesoftWrapper)JSON.deserialize(res.getBody(), RV_DealGSAPMulesoftWrapper.class);
                }else{
                    if(res.getStatusCode() == 504){
                        System.debug('-------------'+res.getBody());
                        getDealinGSAP(access_Token,sapSalesContNo,revDealGSAPMap);
                    }
                   // createDealinGSAP(access_Token,fetchsapStagingLst,revDealGSAPMap);
                }
        }
        return response;                                 
    }
    
    global static Map<String, String> createJSOnStringDeal(List<SAP_Staging__c> fetchsapStagingLst){
        Map<String, String> txIdVsDealGsapDataMap = new Map<String, String>();
        //RV_DealGSAPMulesoftWrapper dealGsapMuleWrap = new RV_DealGSAPMulesoftWrapper();
        for(SAP_Staging__c sapStaging : fetchsapStagingLst){
            RV_DealGSAPMulesoftWrapper dealGsapMuleWrap = new RV_DealGSAPMulesoftWrapper();
            if(!txIdVsDealGsapDataMap.isEmpty() && txIdVsDealGsapDataMap.containsKey(sapStaging.SHT_Transaction_Id__c)){
                dealGsapMuleWrap = (RV_DealGSAPMulesoftWrapper)JSON.deserialize(txIdVsDealGsapDataMap.get(sapStaging.SHT_Transaction_Id__c), RV_DealGSAPMulesoftWrapper.class);
                List<RV_DealGSAPMulesoftWrapper.RV_SHTItems> itemWrapList = dealGsapMuleWrap.SHTItems;
                itemWrapList.add(createItemWrap(sapStaging));
                dealGsapMuleWrap.SHTItems = itemWrapList;
                txIdVsDealGsapDataMap.put(sapStaging.SHT_Transaction_Id__c, JSON.serializePretty(dealGsapMuleWrap));
            }
            else if(sapStaging.SHT_Transaction_Id__c != null){
                //Create SHT Header
                dealGsapMuleWrap = createHeaderWrap(sapStaging);
                //Create SHT Item Wrap
                dealGsapMuleWrap.SHTItems = new List<RV_DealGSAPMulesoftWrapper.RV_SHTItems>{createItemWrap(sapStaging)};
                txIdVsDealGsapDataMap.put(sapStaging.SHT_Transaction_Id__c, JSON.serializePretty(dealGsapMuleWrap));
            }
        }
        return txIdVsDealGsapDataMap;
    }

    /*Method Name	:	createHeaderWrap
    * Date			:	03-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method returns RV_DealGSAPMulesoftWrapper from SAP_Staging__c object*/
    private static RV_DealGSAPMulesoftWrapper createHeaderWrap(SAP_Staging__c sapStaging){
        RV_DealGSAPMulesoftWrapper dealGsapMuleWrap = new RV_DealGSAPMulesoftWrapper();
        dealGsapMuleWrap.SfHeaderShtNo = String.valueof(sapStaging.SHT_Transaction_Id__c);
        if(sapStaging.SapSalesContNo__c == null)
            dealGsapMuleWrap.SapSalesContNo = '';
        else
            dealGsapMuleWrap.SapSalesContNo = sapStaging.SapSalesContNo__c;
        if(sapStaging.Status__c == null)
            dealGsapMuleWrap.Status = sapStaging.Processing_Indicator__c;
        else
            dealGsapMuleWrap.Status = sapStaging.Processing_Indicator__c;
        if(sapStaging.SapMrcNo__c == null)
            dealGsapMuleWrap.SapMrcNo = sapStaging.SapMrcNo__c;
        else
            dealGsapMuleWrap.SapMrcNo = sapStaging.SapMrcNo__c;
        dealGsapMuleWrap.SapMrcNo = sapStaging.SapMrcNo__c;
        if(sapStaging.Counter__c == null)
            dealGsapMuleWrap.TotalItems = '';
        else
            dealGsapMuleWrap.TotalItems = String.valueof(sapStaging.Counter__c);
        dealGsapMuleWrap.Action = sapStaging.CreationInd__c;
        String contStartDate = String.valueof(sapStaging.ContStartDate__c);
        String finalcontStartDate = '';
        if(contStartDate.contains('-')){
            finalcontStartDate = contStartDate.remove('-');
        }
        String contEndDate = String.valueof(sapStaging.ContEndDate__c);
        String finalcontEndDate = '';
        if(contEndDate.contains('-')){
            finalcontEndDate = contEndDate.remove('-');
        }
        dealGsapMuleWrap.ContStartDate =finalcontStartDate;
        dealGsapMuleWrap.ContEndDate = finalcontEndDate;
        if(sapStaging.Error_Processing_to_GSAP__c == null)
            dealGsapMuleWrap.MsgTxt = '';
        else
            dealGsapMuleWrap.MsgTxt = sapStaging.Error_Processing_to_GSAP__c;
        dealGsapMuleWrap.SalesOrg = sapStaging.SalesOrg__c;
        if(sapStaging.PO_Type__c == null)
            dealGsapMuleWrap.POType = '';
        else
            dealGsapMuleWrap.POType = sapStaging.PO_Type__c;
        if(sapStaging.Instance_URL__c == null)
            dealGsapMuleWrap.InstanceURL = '';
        else
            dealGsapMuleWrap.InstanceURL = sapStaging.Instance_URL__c;
        return dealGsapMuleWrap;
    }

    /*Method Name	:	createItemWrap
    * Date			:	03-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method returns RV_SHTItems from SAP_Staging__c object*/
    private static RV_DealGSAPMulesoftWrapper.RV_SHTItems createItemWrap(SAP_Staging__c sapStaging){
        RV_DealGSAPMulesoftWrapper.RV_SHTItems rvshtItems = new RV_DealGSAPMulesoftWrapper.RV_SHTItems();
        rvshtItems.SfHeaderShtNo = sapStaging.SHT_Transaction_Id__c;
        rvshtItems.SfItemShtNo = sapStaging.SfItemShtNo__c;
        rvshtItems.SapMrcItemNo = sapStaging.MrcItemNo__c;
        if(sapStaging.Count__c == null)
            rvshtItems.ItemCount = '';
        else
            rvshtItems.ItemCount = String.valueof(sapStaging.Count__c);
        rvshtItems.CondPUnt = sapStaging.CondPUnt__c;
        rvshtItems.CondType = sapStaging.CondType__c;
        rvshtItems.CondUnit = sapStaging.CondUnit__c;
        rvshtItems.CurrencyKey = sapStaging.CurrencyKey__c;
        Date dealCreatedDt = date.newinstance(sapStaging.Deal_Created_Date__c.year(), sapStaging.Deal_Created_Date__c.month(), sapStaging.Deal_Created_Date__c.day());
        String DealCreatedDate = String.valueof(dealCreatedDt);
        String finalDealCreatedDate = '';
        if(DealCreatedDate.contains('-'))
            finalDealCreatedDate = DealCreatedDate.remove('-');
        String sapStagingtime = String.valueOf(sapStaging.Deal_Created_Date__c.format('h:mm:ss'));
        String finalsapStaging = '';
        if(sapStagingtime.contains(':'))
            finalsapStaging = sapStagingtime.remove(':');
        rvshtItems.DealCreationDate = finalDealCreatedDate;
        rvshtItems.DealCreationTime = finalsapStaging;
        rvshtItems.MaterialNo = sapStaging.MaterialNo__c;
        rvshtItems.QuantityUom = sapStaging.QuantityUom__c;
        rvshtItems.Quantity = String.valueof(sapStaging.Quantity__c);
        if(sapStaging.Rejection_Reason__c ==null)
            rvshtItems.RejectionReason = '';
        else
            rvshtItems.RejectionReason = sapStaging.Rejection_Reason__c;
        rvshtItems.SalesPrice = String.valueof(sapStaging.SalesPrice__c);
        if(sapStaging.PriceInd__c == null)
            rvshtItems.PriceInd = '';
        else
            rvshtItems.PriceInd = sapStaging.PriceInd__c;
        return rvshtItems;
    }

    public static void updateSAPStaging(List<SAP_Staging__c>  fetchsapStagingLst, Map<String, RV_DealGSAPMulesoftWrapper> txIdVsResWrapMap){
        List<SAP_Staging__c> sapStagingLst = new List<SAP_Staging__c>();
        for(SAP_Staging__c sapStaging : fetchsapStagingLst){
            if(txIdVsResWrapMap.containsKey(sapStaging.SHT_Transaction_Id__c)){
                sapStaging.SapSalesContNo__c = txIdVsResWrapMap.get(sapStaging.SHT_Transaction_Id__c).SapSalesContNo;
                sapStaging.Processing_Indicator__c = '02';
                sapStagingLst.add(sapStaging);
            }
        }
        if(!sapStagingLst.isEmpty()){
            try{
                update sapStagingLst;
            }
            catch(Exception de){
                System.debug('----------de--------'+de);
            }                             
        }                                
    }
    
    public static void updaterrorMessage(List<SAP_Staging__c>  fetchsapStagingLst, Map<String, RV_DealGSAPMulesoftWrapper.exceptionClass> txIdVsExpWrapMap){
        List<SAP_Staging__c> sapStagingLst = new List<SAP_Staging__c>();
        Map<String,SAP_Staging__c> shtNumberMap = new Map<String,SAP_Staging__c>();                                
        for(SAP_Staging__c sapStaging : fetchsapStagingLst){
            if(txIdVsExpWrapMap.containsKey(sapStaging.SHT_Transaction_Id__c)){
                RV_DealGSAPMulesoftWrapper.exceptionClass deserializeWrapperException = txIdVsExpWrapMap.get(sapStaging.SHT_Transaction_Id__c);
                sapStaging.Processing_Indicator__c = '03';
                sapStaging.Error_Processing_to_GSAP__c = deserializeWrapperException.errorMessage;
                sapStagingLst.add(sapStaging);
                shtNumberMap.put(sapStaging.SfItemShtNo__c, sapStaging);
            }
        }
        List<Sht__c> shtLst = [Select Id,Name,Error__c from Sht__c where Name in:shtNumberMap.keyset()];
        List<Sht__c> shtfinalLst = new List<Sht__c>();
        for(Sht__c sht :shtLst){
            if(shtNumberMap.containskey(sht.Name)){
                sht.Error__c = shtNumberMap.get(sht.Name).Error_Processing_to_GSAP__c;
                shtfinalLst.add(sht);
            }                              
        }                                                                      
        if(!sapStagingLst.isEmpty()){
            try{
                update sapStagingLst;
            }catch(Exception de){
                System.debug('----------de--------'+de);
            }                             
        }                                  
        if(!shtfinalLst.isEmpty()){
            try{
                update shtfinalLst;
            }catch(Exception de){
                System.debug('----------de--------'+de);
            }                             
        }  
    }

    /*Method Name	:	retryDealPushToGSAP
    * Date			:	04-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method retries callout to push deals in GSAP system*/
    public static void retryDealPushToGSAP(String access_token, List<String> sapStagingIdList, String revDealGSAPMapString, Integer rtryCount){
        rtryCount++;
        retryCount = rtryCount;
        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap = (Map<String,Revolution_Deal_GSAP_Config__mdt>)JSON.deserialize(revDealGSAPMapString, Map<String,Revolution_Deal_GSAP_Config__mdt>.class);
        Revolution_Deal_GSAP_Config__mdt createDeal = revDealGSAPMap.get('CreateDeal');
        System.debug('RV_DealGSAPMulesoft >> retryDealPushToGSAP >> retryCount: ' + retryCount + ' createDeal.Max_Retry__c: '+createDeal.Max_Retry__c);
        if((createDeal.Max_Retry__c != null) && (retryCount <= createDeal.Max_Retry__c)){
            System.debug('RV_DealGSAPMulesoft >> retryDealPushToGSAP >> Inside if. sapStagingIdList: '+sapStagingIdList);
            System.debug('RV_DealGSAPMulesoft >> retryDealPushToGSAP >> Inside if. revDealGSAPMap: '+revDealGSAPMap);
            createUpdateDelDealinGSAP(access_Token, sapStagingIdList, revDealGSAPMap);
        }
    }

    /*Method Name	:	logException
    * Date			:	10-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method logs Exceptions to the Rv_Exception object*/
    private static void logException(List<RV_Exception__c> rvExcepList){
        try{
            insert rvExcepList;
        }
        catch(Exception e){
            System.debug('RV_DealGSAPMulesoft >> logException: Exception while inserting records into Rv_Exception object. Message: '+e.getMessage());
            RV_Exception__c rvException = new RV_Exception__c();
            rvException.getMessage__c = e.getMessage();
            rvException.Apex_Class__c = 'RV_DealGSAPMulesoft';
            rvException.Method_Name__c = 'logException';
            rvException.Type__c = 'Exception';
            insert rvException;
        }
    }

    /*Class Name	: CustomException     
     *Developer		: Rahul Sharma
	 *Date			: 26-March-2020
	 *Description	: Custom exception class*/
    public class CustomException extends Exception{}

}