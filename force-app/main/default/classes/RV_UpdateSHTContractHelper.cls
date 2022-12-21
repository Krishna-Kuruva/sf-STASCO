public class RV_UpdateSHTContractHelper {
    
    //START | Rahul Sharma | Date - 14-May-2020 : Added static set to track updated staging records throughout the transaction.
    private static Set<Id> sapStagingIdSet = new Set<Id>();
    //END | Rahul Sharma | Date - 14-May-2020 : Added static set to track updated staging records throughout the transaction.

    public static void onAfterInsert(List<SAP_Staging__c> sapstagingList){
        List<SAP_Staging__c> RejectRecords=new List<SAP_Staging__c>();
        List<SAP_Staging__c> createRecords=new List<SAP_Staging__c>();
        List<String> sapstagingStrngList=new List<String>();
        List<String> sapstagingStrngDelList=new List<String>();
        for(SAP_Staging__c eachRecord: sapstagingList){
            System.Debug('eachRecord:'+eachRecord);
            if(eachRecord.CreationInd__c=='D'){  
                System.Debug('Inside Loop 1');  
                sapstagingStrngDelList.add(eachRecord.Id);
                RejectRecords.add(eachRecord);
            } 
            if(eachRecord.CreationInd__c=='C'){
                sapstagingStrngList.add(eachRecord.Id);
                createRecords.add(eachRecord);
            }
        } 
        if(RejectRecords.size()>0){
            
            if(Label.RV_GSAP_Old_Interface == 'True'){
                System.debug('=====Label.RV_GSAP_Old_Interface====='+Label.RV_GSAP_Old_Interface);
            	rejectRecord(RejectRecords);   
            }else{
                System.debug('=====Label.RV_GSAP_Old_Interface====='+Label.RV_GSAP_Old_Interface);
                DeleteDealinGSAPInterface(sapstagingStrngDelList);
            }
        }
        
        if(createRecords.size()>0){
            if(Label.RV_GSAP_Old_Interface != 'True')
            	CreateDealinGSAPInterface(sapstagingStrngList);  
        }
        
    }
    
    @future (callout=true)
    public static void CreateDealinGSAPInterface(List<String> sapstagingStrngList){
        
        List<Revolution_Deal_GSAP_Config__mdt> revDealGSAPLst = [Select Id,MasterLabel,DeveloperName,
                                                                 Client_Id__c,Client_Secret__c,
                                                                 Content_Type__c,Endpoint__c,Method__c from 
                                                                 Revolution_Deal_GSAP_Config__mdt ];
        
        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap = new Map<String,Revolution_Deal_GSAP_Config__mdt>();
        for(Revolution_Deal_GSAP_Config__mdt revDealGSAPConfig : revDealGSAPLst){
            revDealGSAPMap.put(revDealGSAPConfig.MasterLabel,revDealGSAPConfig);
        }
        String access_Token = RV_DealGSAPMulesoft.basicAuthCallout(revDealGSAPMap);
        if(!String.isBlank(access_Token))
            RV_DealGSAPMulesoft.createUpdateDelDealinGSAP(access_Token, sapstagingStrngList, revDealGSAPMap);
        //START - Rahul Sharma | Date - 28-04-2021 : Added logic to update SAP Staging and SHT records with error message.
        else
            updateErrorSapStaging(sapstagingStrngList);
        //END - Rahul Sharma | Date - 28-04-2021 : Added logic to update SAP Staging and SHT records with error message.   
    }
    
    @future (callout=true)
    public static void DeleteDealinGSAPInterface(List<String> sapstagingStrngList){
        
        List<Revolution_Deal_GSAP_Config__mdt> revDealGSAPLst = [Select Id,MasterLabel,DeveloperName,
                                                                 Client_Id__c,Client_Secret__c,
                                                                 Content_Type__c,Endpoint__c,Method__c from 
                                                                 Revolution_Deal_GSAP_Config__mdt ];
        
        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap = new Map<String,Revolution_Deal_GSAP_Config__mdt>();
        for(Revolution_Deal_GSAP_Config__mdt revDealGSAPConfig : revDealGSAPLst){
            revDealGSAPMap.put(revDealGSAPConfig.MasterLabel,revDealGSAPConfig);
        }
        System.debug('------revDealGSAPMap------'+revDealGSAPMap);
        String access_Token = RV_DealGSAPMulesoft.basicAuthCallout(revDealGSAPMap);
        if(!String.isBlank(access_Token))
            RV_DealGSAPMulesoft.createUpdateDelDealinGSAP(access_Token,sapstagingStrngList,revDealGSAPMap);
        //START - Rahul Sharma | Date - 28-04-2021 : Added logic to update SAP Staging and SHT records with error message.
        else
            updateErrorSapStaging(sapstagingStrngList);
        //END - Rahul Sharma | Date - 28-04-2021 : Added logic to update SAP Staging and SHT records with error message.
    }
    
    /*@future (callout=true)
    public static void updateDealinGSAPInterface(List<String> sapstagingStrngList){
        
        List<Revolution_Deal_GSAP_Config__mdt> revDealGSAPLst = [Select Id,MasterLabel,DeveloperName,
                                                                 Client_Id__c,Client_Secret__c,
                                                                 Content_Type__c,Endpoint__c,Method__c from 
                                                                 Revolution_Deal_GSAP_Config__mdt ];
        
        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap = new Map<String,Revolution_Deal_GSAP_Config__mdt>();
        for(Revolution_Deal_GSAP_Config__mdt revDealGSAPConfig : revDealGSAPLst){
            revDealGSAPMap.put(revDealGSAPConfig.MasterLabel,revDealGSAPConfig);
        }
        System.debug('------revDealGSAPMap------'+revDealGSAPMap);
        String access_Token = RV_DealGSAPMulesoft.basicAuthCallout(revDealGSAPMap);
        RV_DealGSAPMulesoft.createUpdateDelDealinGSAP(access_Token,sapstagingStrngList,revDealGSAPMap);
    }*/
    
    public static void onAfterUpdate(List<SAP_Staging__c> sapstagingList){
        Date LastFiveDays=system.today().addDays(-5);
        //START | Rahul Sharma | Date - 14-May-2020 : Updated SHT query to fetch deal number and load Id.
        Map<String, List<OLFWrapper.olfDealWrap>> orderGrpVsDealWrapMap = new Map<String, List<OLFWrapper.olfDealWrap>>();
        List<SHT__c> shtRecords=[SELECT Id,
                                        Name,
                                        SAP_Contract_Number__c,
                                        OLF_Deal_Number__c,
                                        MRC__r.Load_Id__c,
                                        isOlfDeal__c FROM SHT__c WHERE (Status__c='Completed' OR Status__c='Cancelled') AND 
                                                                        CreatedDate >= :LastFiveDays LIMIT 50000];
        //END | Rahul Sharma | Date - 14-May-2020 : Updated SHT query to fetch deal number and load Id.
        List<SAP_Staging__c> CreateRecords=new List<SAP_Staging__c>();
        List<SHT__c> recordsToBeUpdated=new List<SHT__c>();
        for(SAP_Staging__c eachRecord: sapstagingList){
            System.debug('eachRecord:'+eachRecord);
            //Added for Deleted Records
            if(eachRecord.Counter__c!=NULL && eachRecord.Count__c!=NULL && eachRecord.Processing_Indicator__c=='01' 
               && (eachRecord.CreationInd__c=='C' || eachRecord.CreationInd__c=='D' ) ){
                CreateRecords.add(eachRecord); 
            }
             //Added for Deleted Records:Updated Condition
            //debugs added by Dharmendra
        	System.debug('---eachRecord.SapSalesContNo__c---'+eachRecord.SapSalesContNo__c);
            System.debug('---eachRecord.Processing_Indicator__c---'+eachRecord.Processing_Indicator__c);
            System.debug('---sapstagingList---'+sapstagingList);
            system.debug('----eachRecord.MaterialNo__c-----'+eachRecord.MaterialNo__c);
            
            
            if((eachRecord.SapSalesContNo__c!=NULL && eachRecord.SapSalesContNo__c!='0') &&
               eachRecord.Processing_Indicator__c=='02'){
                for(SHT__c s:shtRecords){
                    //debugs added by Dharmendra
        			System.debug('---s.name---'+s.name);
                    System.debug('---eachRecord.SfItemShtNo__c---'+eachRecord.SfItemShtNo__c);
                    if(s.name==eachRecord.SfItemShtNo__c){
                        s.SAP_Contract_Number__c=eachRecord.SapSalesContNo__c;
                        recordsToBeUpdated.add(s);
                        //START | Rahul Sharma | Date - 14-May-2020 : Added logic to collect deal data to be sent to OLF.
                        if(!sapStagingIdSet.contains(eachRecord.Id) && eachRecord.OLF_Deal_Number__c != null && s.isOlfDeal__c && eachRecord.Sent_to_OLF__c != 'Success' && eachRecord.Sent_to_OLF__c != 'Failed'){
                            sapStagingIdSet.add(eachRecord.Id);
                            String dealGroup = s.OLF_Deal_Number__c != null ? s.OLF_Deal_Number__c.subStringBefore('-') : '';
                            if(orderGrpVsDealWrapMap.containsKey(dealGroup)){
                                List<OLFWrapper.olfDealWrap> olfDealWrapList = orderGrpVsDealWrapMap.get(dealGroup);
                                OLFWrapper.olfDealWrap dealWrap = new OLFWrapper.olfDealWrap();
                                dealWrap.orderId = s.OLF_Deal_Number__c;
                                dealWrap.vendorContractNo = eachRecord.SapSalesContNo__c;
                                dealWrap.vendorLiftingId = s.MRC__r.Load_Id__c != null ? s.MRC__r.Load_Id__c : '';
                                olfDealWrapList.add(dealWrap);
                                orderGrpVsDealWrapMap.put(dealGroup, olfDealWrapList);
                            }
                            else{
                                List<OLFWrapper.olfDealWrap> olfDealWrapList = new List<OLFWrapper.olfDealWrap>();
                                OLFWrapper.olfDealWrap dealWrap = new OLFWrapper.olfDealWrap();
                                dealWrap.orderId = s.OLF_Deal_Number__c;
                                dealWrap.vendorContractNo = eachRecord.SapSalesContNo__c;
                                dealWrap.vendorLiftingId = s.MRC__r.Load_Id__c != null ? s.MRC__r.Load_Id__c : '';
                                olfDealWrapList.add(dealWrap);
                                orderGrpVsDealWrapMap.put(dealGroup, olfDealWrapList);
                            }                        
                        }
                        //END | Rahul Sharma | Date - 14-May-2020 : Added logic to collect deal data to be sent to OLF.
                    }
                }                
            }           
        }   
        if(recordsToBeUpdated.size()>0){
            update recordsToBeUpdated;
        }  
        if(CreateRecords.size()>0){
            if(Label.RV_GSAP_Old_Interface == 'True'){
                System.debug('-------Label.RV_GSAP_Old_Interface-----'+Label.RV_GSAP_Old_Interface);
            	createRecord(CreateRecords);
        }
        }
        //START | Rahul Sharma | Date - 14-May-2020 : Send deal information to OLF.
        if(!orderGrpVsDealWrapMap.isEmpty()){
            System.debug('##sendContractInfoToOLF');
            OLF_SendContractInformation.sendContractInfoToOLF(orderGrpVsDealWrapMap);
        }
        //END | Rahul Sharma | Date - 14-May-2020 : Send deal information to OLF.
    }
    
    public static void createRecord(List<SAP_Staging__c> sapRecords){ 
        List<SF_SAP_DataSet__x> listOfItems=new List<SF_SAP_DataSet__x>();
        for(SAP_Staging__c sapData:sapRecords){
            SF_SAP_DataSet__x item= new SF_SAP_DataSet__x();  
            if(sapData.CondType__c==NULL)
                item.CondType__c='YP23';
            else
                item.CondType__c=sapData.CondType__c;
            item.ContEndDate__c=sapdata.EndDate__c;
            item.ContStartDate__c=sapdata.StartDate__c;
            item.CurrencyKey__c=sapData.CurrencyKey__c;
            item.MaterialNo__c=sapdata.MaterialNo__c;
            item.SapMrcItemNo__c=sapdata.MrcItemNo__c;
            item.Quantity__c=String.valueOf(sapdata.Quantity__c);
            item.QuantityUom__c=sapdata.QuantityUom__c;
            item.SalesOrg__c=sapdata.SalesOrg__c;
            item.SalesPrice__c=String.valueOf(sapdata.SalesPrice__c);
            item.SapMrcNo__c=sapdata.SapMrcNo__c;
            //item.SfHeaderShtNo__c=sapdata.SfHeaderShtNo__c;
			item.SfHeaderShtNo__c=sapdata.SHT_Transaction_Id__c;
            item.SfItemShtNo__c=sapdata.SfItemShtNo__c;
            item.TotalItems__c=String.valueOf(sapdata.Counter__c);
            item.ItemCount__c=String.valueOf(sapdata.Count__c);
            item.Action__c=sapdata.CreationInd__c;
            item.Status__c=sapdata.Processing_Indicator__c;
            item.DealCreationDate__c=sapdata.Record_Created_Date__c;
            item.DealCreationTime__c=sapdata.Record_Created_Time__c;
            item.CondPUnt__c=sapData.CondPUnt__c;
            item.CondUnit__c=sapData.CondUnit__c;
            listOfItems.add(item);  
        }
        IF(listOfItems.size()>0){
            List<Database.SaveResult> sr = Database.insertAsync(listOfItems);
        }
    }
    
    public static void rejectRecord(List<SAP_Staging__c> sapRecords){
        List<SF_SAP_DataSet__x> listOfItems=new List<SF_SAP_DataSet__x>();
        for(SAP_Staging__c sapData:sapRecords){
            SF_SAP_DataSet__x item= new SF_SAP_DataSet__x();
            if(sapData.CondType__c==NULL)
                item.CondType__c='YP23';
            else
                item.CondType__c=sapData.CondType__c;
            item.ContEndDate__c=sapdata.EndDate__c;
            item.ContStartDate__c=sapdata.StartDate__c;
            item.CurrencyKey__c=sapData.CurrencyKey__c;
            item.MaterialNo__c=sapdata.MaterialNo__c;
            item.SapMrcItemNo__c=sapdata.MrcItemNo__c;
            item.Quantity__c=String.valueOf(sapdata.Quantity__c);
            item.QuantityUom__c=sapdata.QuantityUom__c;
            item.SalesOrg__c=sapdata.SalesOrg__c;
            item.SalesPrice__c=String.valueOf(sapdata.SalesPrice__c);
            item.SapMrcNo__c=sapdata.SapMrcNo__c;
            //item.SfHeaderShtNo__c=sapdata.SfHeaderShtNo__c;
			item.SfHeaderShtNo__c=sapdata.SHT_Transaction_Id__c;
            item.SfItemShtNo__c=sapdata.SfItemShtNo__c;
            item.Action__c=sapdata.CreationInd__c;
            item.Status__c=sapdata.Processing_Indicator__c;
            item.DealCreationDate__c=sapdata.Record_Created_Date__c;
            item.DealCreationTime__c=sapdata.Record_Created_Time__c;
            item.CondPUnt__c=sapData.CondPUnt__c;
            item.CondUnit__c=sapData.CondUnit__c;
            item.RejectionReason__c=sapData.Rejection_Reason__c;            
            listOfItems.add(item);
        }
        IF(listOfItems.size()>0){
            List<Database.SaveResult> sr = Database.InsertAsync(listOfItems);
        }
    }

    /*Method Name	:	updateErrorSapStaging
    * Date			:	28-Apr-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method updates error message into SAP staging for authentication failure.
    */
    private static void updateErrorSapStaging(List<String> sapstagingStrngList){
        Map<String,SAP_Staging__c> shtNumberMap = new Map<String,SAP_Staging__c>(); 
        List<SAP_Staging__c>  fetchsapStagingLst = [SELECT Id,  
                                                           Name,
                                                           Count__c,
                                                           Error_Processing_to_GSAP__c,
                                                           Processing_Indicator__c,
                                                           SfItemShtNo__c  FROM SAP_Staging__c WHERE Id IN : sapstagingStrngList ORDER BY Count__c]; 
        if(!fetchsapStagingLst.isEmpty()){
            List<SAP_Staging__c> sapStagingLst = new List<SAP_Staging__c>();
            for(SAP_Staging__c stagingObj : fetchsapStagingLst){
                stagingObj.Processing_Indicator__c = '03';
                stagingObj.Error_Processing_to_GSAP__c = 'Authentication Failed';
                sapStagingLst.add(stagingObj);
                shtNumberMap.put(stagingObj.SfItemShtNo__c, stagingObj);
            }
            List<Sht__c> shtLst = [SELECT Id,
                                          Name,
                                          Error__c FROM Sht__c WHERE Name IN : shtNumberMap.keyset()];
            List<Sht__c> shtfinalLst = new List<Sht__c>();
            for(Sht__c sht :shtLst){
                if(shtNumberMap.containsKey(sht.Name)){
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
    }
}