public class RV_CreateSHTSAP {
    
    public static void processStagingRecord(List<SHT__c> shtRecords,Map<ID,SHT__c> oldRecordMap){   
        Set<SHT__c> shtrecordsNew=new Set<SHT__c>();
        List<SHT__c> rejectshtrecords=new List<SHT__c>();
        List<SHT__c> updateshtrecords=new List<SHT__c>();
        List<String> updateSHTRecordLst = new List<String>(); 
        for(SHT__c shtRecord:shtRecords){
            if(oldRecordMap != null){
            SHT__c oldRecord=oldRecordMap.get(shtRecord.id);
            if((((shtRecord.Status__c == 'Completed' && oldRecord.Status__c!='Completed') || (shtRecord.Status__c == 'Auto-Completed' && oldRecord.Status__c!='Auto-Completed'))) && (shtRecord.IsGsapDealCreateOn__c!=null && shtRecord.IsGsapDealCreateOn__c ==true ))
            {
                shtrecordsNew.add(shtRecord);
            } 
            //OLFChanges_20Apr2019_Soumyajit starts
            else if((shtRecord.isOlfDeal__c) && (shtRecord.Status__c == 'Completed' && oldRecord.name==null) && (shtRecord.IsGsapDealCreateOn__c!=null && shtRecord.IsGsapDealCreateOn__c ==true ))
            {
                //System.debug('Creating Staging for OLF');
                shtrecordsNew.add(shtRecord);
            }
            else{}
            //OLFChanges_20Apr2019_Soumyajit ends
            if(shtRecord.Status__c == 'Cancelled' && oldRecord.Status__c!='Cancelled' && (shtRecord.IsGsapDealCancelOn__c!=null && shtRecord.IsGsapDealCancelOn__c == true))
            {
                rejectshtrecords.add(shtRecord);
            }
            //Added for Deal Interface update operation 13th Jan 2021_Dhriti
            /*if((shtRecord.Volume_CBM__c <> oldRecord.Volume_CBM__c || shtRecord.SP_100L__c <> oldRecord.SP_100L__c) && shtRecord.SAP_Contract_Number__c != null){
                updateSHTRecordLst.add(shtRecord.Id);
                updateshtrecords.add(shtRecord);
            }*/
            }else{
                system.debug('status::'+shtRecord.Status__c );
                if(shtRecord.Status__c == 'Completed'  && shtRecord.IsGsapDealCreateOn__c!=null && shtRecord.IsGsapDealCreateOn__c ==true )
                {
                    shtrecordsNew.add(shtRecord);
                    
                } 
            
            }
        }
        if(shtrecordsNew.size()>0){
            createStagingRecord(shtrecordsNew);
        }
        //Added for Deal Interface update operation 13th Jan 2021_Dhriti
        /*if(updateshtrecords.size()>0){
            List<String> sapStagingId = updateStagingRecord(updateshtrecords);
            if(updateSHTRecordLst.size()>0){
            	RV_UpdateSHTContractHelper.updateDealinGSAPInterface(sapStagingId);
        	}
        }*/
        
        if(rejectshtRecords.size()>0){
            rejectStagingRecord(rejectshtRecords);
        }
        
    }
    
    public static void createStagingRecord(Set<SHT__c> shtRecords){
        List<SAP_Staging__c> stagingRecords=new List<SAP_Staging__c>();
        List<String> insertedIds=new List<String>();
        for(SHT__c shtRecord:shtRecords){
            SAP_Staging__c stagingRecord=new SAP_Staging__c();
            stagingRecord.ContEndDate__c=shtRecord.Contract_End_Date__c;
            stagingRecord.ContStartDate__c=shtRecord.Contract_Start__c;
            stagingRecord.Deal_Created_Date__c=shtRecord.CreatedDate;
            stagingRecord.CreationInd__c='C';
            stagingRecord.CurrencyKey__c='EUR';
            stagingRecord.MaterialNo__c=shtRecord.Material_No__c;
            if(!String.isBlank(shtRecord.MRC_Number__c)){
                stagingRecord.MrcItemNo__c=shtRecord.MRC_Number__c.SubStringAfter('-');
            }
            stagingRecord.Ship_TO_Name__c = shtRecord.Ship_To_Name__c;//Added By Dhriti
            stagingRecord.SoldToName__c = shtRecord.Sold_To_Name__c;//Added By Dhriti
            stagingRecord.Quantity__c=shtRecord.Volume_CBM__c;
            stagingRecord.QuantityUom__c='CBM';
            stagingRecord.SalesOrg__c=shtRecord.Sales_Organization__c;
            stagingRecord.SalesPrice__c=shtRecord.SP_100L__c;
            stagingRecord.SapMrcNo__c=shtRecord.MRCNumber__c;
            stagingRecord.CondType__c=shtRecord.Price_Condition__c;
            stagingRecord.SfItemShtNo__c=shtRecord.Name;
            stagingRecord.Processing_Indicator__c='01';
            stagingRecord.CondPUnt__c='100';
            stagingRecord.CondUnit__c='L15';
            stagingRecord.PO_Type__c =shtRecord.PO_Type__c ;
            stagingRecord.SHTId__c=shtRecord.Id;
            stagingRecord.Handling_Type__c = shtRecord.Handling_Type__c; //Rahul Sharma | Date - 11-Feb-2021 | Bug-732764 : Adding handling type field in SAP Staging.
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
			System.debug('----runningInASandbox-----'+runningInASandbox);
            if(runningInASandbox == true){
                stagingRecord.Instance_URL__c = 'T';
            }else{
                stagingRecord.Instance_URL__c = 'P';
            }
            
            Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap = RV_SHT_CreateController.getDealEventMetdataMap();    //Rahul Sharma | Date - 11-Feb-2021 | Bug-732764 : Adding Deal Event Manager metadata records.
            String dealEventKey = stagingRecord.PO_Type__c + stagingRecord.Handling_Type__c;
            String dealEventOtherKey = stagingRecord.PO_Type__c + 'Others';
            if(!poTypeHandlingDealMdtMap.isEmpty() && poTypeHandlingDealMdtMap.containsKey(dealEventKey) && !String.isEmpty(poTypeHandlingDealMdtMap.get(dealEventKey).Pricing_Indicator__c)){
                stagingRecord.PriceInd__c = poTypeHandlingDealMdtMap.get(dealEventKey).Pricing_Indicator__c;
            }
            else if(!poTypeHandlingDealMdtMap.isEmpty() && poTypeHandlingDealMdtMap.containsKey(dealEventOtherKey) && !String.isEmpty(poTypeHandlingDealMdtMap.get(dealEventOtherKey).Pricing_Indicator__c)){
                stagingRecord.PriceInd__c = poTypeHandlingDealMdtMap.get(dealEventOtherKey).Pricing_Indicator__c;
            }
            else
                stagingRecord.PriceInd__c = '';
            stagingRecord.SHT_Transaction_Id__c = shtRecord.Transaction_Id__c;  //Rahul Sharma | Date - 02-Mar-2021 : Updating transaction id from SHT to SAP Staging.
            stagingRecords.add(stagingRecord);
        }
        if(stagingRecords.size()>0){
            List<Database.SaveResult> srList= database.insert(stagingRecords);
            for(database.SaveResult sr:srList){
                if(sr.isSuccess()){
                    insertedIds.add(sr.getId());
                }
            }
        }
        if(insertedIds.size()>0){
            clubDeals(insertedIds);
        }   
    }
    
    public static void rejectStagingRecord(List<SHT__c> shtRecords){
        List<SAP_Staging__c> stagingRecords=new List<SAP_Staging__c>();
        for(SHT__c shtRecord:shtRecords){
            SAP_Staging__c stagingRecord=new SAP_Staging__c();
            stagingRecord.ContEndDate__c=shtRecord.Contract_End_Date__c;
            stagingRecord.ContStartDate__c=shtRecord.Contract_Start__c;
            stagingRecord.Deal_Created_Date__c=shtRecord.CreatedDate;
            stagingRecord.CreationInd__c='D';
            stagingRecord.CurrencyKey__c='EUR';
            stagingRecord.MaterialNo__c=shtRecord.Material_No__c;
            stagingRecord.MrcItemNo__c=shtRecord.MRC_Number__c.SubStringAfter('-');
            stagingRecord.Quantity__c=shtRecord.Volume_CBM__c;
            stagingRecord.Ship_TO_Name__c = shtRecord.Ship_To_Name__c;//Added By Dhriti
            stagingRecord.SoldToName__c = shtRecord.Sold_To_Name__c;//Added By Dhriti
            stagingRecord.QuantityUom__c='CBM';
            stagingRecord.SalesOrg__c=shtRecord.Sales_Organization__c;
            stagingRecord.SalesPrice__c=shtRecord.SP_100L__c;
            stagingRecord.SapMrcNo__c=shtRecord.MRCNumber__c;
            stagingRecord.CondType__c=shtRecord.Price_Condition__c;
            stagingRecord.SapSalesContNo__c=shtRecord.SAP_Contract_Number__c;
            stagingRecord.SfItemShtNo__c=shtRecord.Name;
            stagingRecord.Processing_Indicator__c='01';
            //Added for Cancellation Reason
           stagingRecord.Rejection_Reason__c= shtRecord.Cancellation_Reason__c;
            stagingRecord.CondPUnt__c='100';
            stagingRecord.CondUnit__c='L15';
            stagingRecord.PO_Type__c =shtRecord.PO_Type__c ;
            stagingRecord.SHTId__c=shtRecord.Id;
            stagingRecord.Handling_Type__c = shtRecord.Handling_Type__c; //Rahul Sharma | Date - 11-Feb-2021 | Bug-732764 : Adding handling type field in SAP Staging.
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
			System.debug('----runningInASandbox-----'+runningInASandbox);
            if(runningInASandbox == true){
                stagingRecord.Instance_URL__c = 'T';
            }else{
                stagingRecord.Instance_URL__c = 'P';
            }
            
            Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap = RV_SHT_CreateController.getDealEventMetdataMap();    //Rahul Sharma | Date - 11-Feb-2021 | Bug-732764 : Adding Deal Event Manager metadata records.
            String dealEventKey = stagingRecord.PO_Type__c + stagingRecord.Handling_Type__c;
            String dealEventOtherKey = stagingRecord.PO_Type__c + 'Others';
            if(!poTypeHandlingDealMdtMap.isEmpty() && poTypeHandlingDealMdtMap.containsKey(dealEventKey) && !String.isEmpty(poTypeHandlingDealMdtMap.get(dealEventKey).Pricing_Indicator__c)){
                stagingRecord.PriceInd__c = poTypeHandlingDealMdtMap.get(dealEventKey).Pricing_Indicator__c;
            }
            else if(!poTypeHandlingDealMdtMap.isEmpty() && poTypeHandlingDealMdtMap.containsKey(dealEventOtherKey) && !String.isEmpty(poTypeHandlingDealMdtMap.get(dealEventOtherKey).Pricing_Indicator__c)){
                stagingRecord.PriceInd__c = poTypeHandlingDealMdtMap.get(dealEventOtherKey).Pricing_Indicator__c;
            }
            else
                stagingRecord.PriceInd__c = '';
            stagingRecord.SHT_Transaction_Id__c = shtRecord.Transaction_Id__c;  //Rahul Sharma | Date - 02-Mar-2021 : Updating transaction id from SHT to SAP Staging.
            stagingRecords.add(stagingRecord);
        }
        if(stagingRecords.size()>0){
            insert stagingRecords;
        }
    }
    
    //Added for Deal Interface update operation 13th Jan 2021_Dhriti
    /*public static List<String> updateStagingRecord(List<SHT__c> shtRecords){
        List<SAP_Staging__c> stagingRecords=new List<SAP_Staging__c>();
        for(SHT__c shtRecord:shtRecords){
            SAP_Staging__c stagingRecord=new SAP_Staging__c();
            stagingRecord.ContEndDate__c=shtRecord.Contract_End_Date__c;
            stagingRecord.ContStartDate__c=shtRecord.Contract_Start__c;
            stagingRecord.Deal_Created_Date__c=shtRecord.CreatedDate;
            stagingRecord.CreationInd__c='U';
            stagingRecord.CurrencyKey__c='EUR';
            stagingRecord.MaterialNo__c=shtRecord.Material_No__c;
            stagingRecord.MrcItemNo__c=shtRecord.MRC_Number__c.SubStringAfter('-');
            stagingRecord.Quantity__c=shtRecord.Volume_CBM__c;
            stagingRecord.Ship_TO_Name__c = shtRecord.Ship_To_Name__c;//Added By Dhriti
            stagingRecord.SoldToName__c = shtRecord.Sold_To_Name__c;//Added By Dhriti
            stagingRecord.QuantityUom__c='CBM';
            stagingRecord.SalesOrg__c=shtRecord.Sales_Organization__c;
            stagingRecord.SalesPrice__c=shtRecord.SP_100L__c;
            stagingRecord.SapMrcNo__c=shtRecord.MRCNumber__c;
            stagingRecord.CondType__c=shtRecord.Price_Condition__c;
            stagingRecord.SapSalesContNo__c=shtRecord.SAP_Contract_Number__c;
            stagingRecord.SfItemShtNo__c=shtRecord.Name;
            stagingRecord.Processing_Indicator__c='01';
            
           stagingRecord.Rejection_Reason__c= shtRecord.Cancellation_Reason__c;//Added for Cancellation Reason
            stagingRecord.CondPUnt__c='100';
            stagingRecord.CondUnit__c='L15';
            stagingRecord.PO_Type__c =shtRecord.PO_Type__c ;
            stagingRecord.SHTId__c=shtRecord.Id;
            stagingRecord.Handling_Type__c = shtRecord.Handling_Type__c; //Rahul Sharma | Date - 11-Feb-2021 | Bug-732764 : Adding handling type field in SAP Staging.
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
			System.debug('----runningInASandbox-----'+runningInASandbox);
            if(runningInASandbox == true){
                stagingRecord.Instance_URL__c = 'T';
            }else{
                stagingRecord.Instance_URL__c = 'P';
            }
            
            Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap = RV_SHT_CreateController.getDealEventMetdataMap();    //Rahul Sharma | Date - 11-Feb-2021 | Bug-732764 : Adding Deal Event Manager metadata records.
            String dealEventKey = stagingRecord.PO_Type__c + stagingRecord.Handling_Type__c;
            String dealEventOtherKey = stagingRecord.PO_Type__c + 'Others';
            if(!poTypeHandlingDealMdtMap.isEmpty() && poTypeHandlingDealMdtMap.containsKey(dealEventKey) && !String.isEmpty(poTypeHandlingDealMdtMap.get(dealEventKey).Pricing_Indicator__c)){
                stagingRecord.PriceInd__c = poTypeHandlingDealMdtMap.get(dealEventKey).Pricing_Indicator__c;
            }
            else if(!poTypeHandlingDealMdtMap.isEmpty() && poTypeHandlingDealMdtMap.containsKey(dealEventOtherKey) && !String.isEmpty(poTypeHandlingDealMdtMap.get(dealEventOtherKey).Pricing_Indicator__c)){
                stagingRecord.PriceInd__c = poTypeHandlingDealMdtMap.get(dealEventOtherKey).Pricing_Indicator__c;
            }
            else
                stagingRecord.PriceInd__c = '';
            stagingRecord.SHT_Transaction_Id__c = shtRecord.Transaction_Id__c;  //Rahul Sharma | Date - 02-Mar-2021 : Updating transaction id from SHT to SAP Staging.
            stagingRecords.add(stagingRecord);
        }
        if(stagingRecords.size()>0){
            insert stagingRecords;
        }
        List<String> sapStagingId = new List<String>();
        for(SAP_Staging__c sapStaging : stagingRecords){
            sapStagingId.add(sapStaging.Id);
        }
        return sapStagingId;
    }*/
    
    public static void clubDeals(List<Id> stagingRecordIds){
        Integer counter=0;
        Integer total=0;
        Set<String> uniqueIds=new Set<String>();
        List<SAP_Staging__c> allStagingRecords=new List<SAP_Staging__c>();
        //START - Rahul Sharma | Date - 02-Mar-21 : Replaced SfHeaderShtNo__c with SHT_Transaction_Id__c.
        allStagingRecords=[SELECT SapSalesContNo__c,
                                  SfItemShtNo__c,
                                  Counter__c,
                                  CreationInd__c,
                                  Processing_Indicator__c,
                                  SHT_Transaction_Id__c FROM SAP_Staging__c WHERE Id IN :stagingRecordIds];
        Map<String,Integer> totalCount=new Map<String,Integer>();
        List<SAP_Staging__c> updateRecords=new List<SAP_Staging__c>();
        for(SAP_Staging__c s:allStagingRecords){
            if(s.Counter__c==NULL && s.CreationInd__c!='D' && (s.Processing_Indicator__c!='02' || s.Processing_Indicator__c!='03') ){
                //uniqueIds.add(s.SfHeaderShtNo__c);
                uniqueIds.add(s.SHT_Transaction_Id__c);
        //END - Rahul Sharma | Date - 02-Mar-21 : Replaced SfHeaderShtNo__c with SHT_Transaction_Id__c.
            } 
        }
        for(String Uniqueid:uniqueIds){  
            counter=0;
            for(SAP_Staging__c s:allStagingRecords){  
                //if(s.SfHeaderShtNo__c==Uniqueid){
                if(s.SHT_Transaction_Id__c==Uniqueid){
                    counter++;
                }
            }
            totalCount.put(Uniqueid,counter);
        }
        for(String str:totalCount.keySet()){
            integer count=totalCount.get(str);
            for(SAP_Staging__c s:allStagingRecords){  
                //if(s.SfHeaderShtNo__c==str && s.SfHeaderShtNo__c!=NULL){
                //END - Rahul Sharma | Date - 02-Mar-21 : Replaced SfHeaderShtNo__c with SHT_Transaction_Id__c.
                if(s.SHT_Transaction_Id__c==str && s.SHT_Transaction_Id__c!=NULL){
                    s.Counter__c=totalCount.get(str);
                    s.Count__c =String.valueOf(count);
                    count--;
                    updateRecords.add(s); 
                }
            }
        }
        if(updateRecords.size()>0){
            update  updateRecords;
        }         
    }
}