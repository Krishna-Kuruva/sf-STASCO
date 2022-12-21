/******************************************************************************************************************
className           :    RE_CND_RackDetail_Controller
Description         :    Controller class for CA Pricing Dashboard
Author              :    Aasiya Siraj
Date				:	 13-JUly-2021 
*******************************************************************************************************************/

public with sharing class RE_CND_RackDetail_Controller {
    
    @AuraEnabled
    public static String getGSAPJobStatus()
    { 
        System.debug('getGSAPJobStatus called--');
        String GSAPProcessingStatus;
        RE_Job_Run_Audit__c jra=[SELECT RE_Job_Status__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c='Canada GSAP Upload' ORDER BY CreatedDate DESC LIMIT 1];
        if(jra!=null)
        {
            GSAPProcessingStatus=jra.RE_Job_Status__c;
        }
        
        return GSAPProcessingStatus;
    }
    
    @AuraEnabled
    public static GSAPWrapper getGSAPUploadStatus(Date datefilter)
    {
        GSAPWrapper gsw = new GSAPWrapper();  
        Decimal totalRecord=0;
        Decimal totalProcessed=0;
        RE_Job_Run_Audit__c jra = [SELECT Id,RE_Job_Status__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c='Canada GSAP Upload' ORDER BY CreatedDate DESC LIMIT 1];
        
        if(jra!=null)
        {
            for(Fixed_Price_Staging_Table__c fps :[SELECT id, RE_Status__c  FROM Fixed_Price_Staging_Table__c WHERE  RE_Job_Run_Audit__c=:jra.Id AND RE_Is_latest__c =true AND  RE_Country_Name__c ='CA' 
                                                   AND  ((RE_Cost_Price__r.RE_CND_Effective_From_Date__c <=:datefilter AND  RE_Cost_Price__r.RE_CND_Effective_To_Date__c >=:datefilter) 
                                                         OR (REV_Price_Book__r.RE_CND_Effective_From_Date__c <=:datefilter AND  REV_Price_Book__r.RE_CND_Effective_To_Date__c >=:datefilter))])
            {
                totalRecord++;
                if(fps.RE_Status__c!=null)
                {
                    totalProcessed++;
                }
            }        
            
            gsw.GSAPProcessingStatus = jra.RE_Job_Status__c;
            gsw.isProcessing		=	(jra.RE_Job_Status__c=='Processing' ? true : false);
            gsw.totalUploaded		=	totalRecord;
            gsw.numberProcessed		=	totalProcessed;
        }
        return gsw;
    }   
    
    @AuraEnabled
    // Update the Cancelled JobRun Audit Record
    public static void updatingCancelledJobRunAudit(String jobType)
    {
        try
        {
            List<RE_Job_Run_Audit__c> updateJobRunLst = New List<RE_Job_Run_Audit__c>();
            
            RE_Job_Run_Audit__c[] jra = [SELECT Id,RE_Job_Status__c, RE_Batch_Job_Ids__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c=: jobType AND RE_Job_Status__c = 'Cancelled' ORDER BY CreatedDate DESC LIMIT 1];
            If(jra.Size() > 0)
            {                
                if(jra[0].RE_Batch_Job_Ids__c != null)
                {
                    RE_Job_Run_Audit__c[] jraOldJob = [SELECT Id,RE_Job_Status__c, RE_Batch_Job_Ids__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c=: 'Canada GSAP Upload' AND Id =: jra[0].RE_Batch_Job_Ids__c];
                    if(jraOldJob.Size() > 0)
                    {                        
                        RE_Job_Run_Audit__c updateJobRunCompl = New RE_Job_Run_Audit__c();
                        updateJobRunCompl.Id = jra[0].Id;
                        updateJobRunCompl.RE_Job_Status__c = 'Completed';
                        updateJobRunCompl.RE_Batch_Job_Ids__c = '';
                        updateJobRunLst.add(updateJobRunCompl);
                        
                        RE_Job_Run_Audit__c updateJobRunCanc = New RE_Job_Run_Audit__c();
                        updateJobRunCanc.Id = jraOldJob[0].Id;
                        updateJobRunCanc.RE_Job_Status__c = 'Cancelled';                        
                        updateJobRunLst.add(updateJobRunCanc);                          
                    }                    
                }
            }
            
            if(updateJobRunLst.Size() > 0)
                update updateJobRunLst;
            
        }catch(Exception ex)
        {
            System.debug('updatingCancelledJobRunAudit-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());            
            RV_ClassException.insertExceptionRecord('updatingCancelledJobRunAudit',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','updatingCancelledJobRunAudit','Exception');
        }
    }
    
    @AuraEnabled
    public static List<VersionWrapper>  getVersionRecords(String version,String groupName){
        List<VersionWrapper> versionList = new List<VersionWrapper>();
        try{
            //System.debug('version--'+version+'--groupName--'+groupName);
            
            if(version!=null && version!='')
            {                
                if(groupName=='Branded'||groupName=='Unbranded')
                {
                    for(RE_MY_CostPrice__c cp :[select id,RE_Pricing_Date__c,RE_CND_Adjustment_Value__c, RE_CND_Final_Value__c, RE_Status__c, RE_Submitter_Comments__c  from RE_MY_CostPrice__c  
                                                where RecordType.name like '%canada%' and RE_Initial_Version__c =:version])
                    {
                        VersionWrapper vw= new VersionWrapper();
                        vw.adjustValue	=cp.RE_CND_Adjustment_Value__c;
                        vw.versionId	=cp.Id;
                        vw.pricingDate	=cp.RE_Pricing_Date__c;
                        vw.finalValue	=cp.RE_CND_Final_Value__c;
                        vw.status		=cp.RE_Status__c;
                        vw.comment		=cp.RE_Submitter_Comments__c;
                        versionList.add(vw);
                    }
                }
                if(groupName=='SFJ')
                {
                    for(RT_Price_Book__c pb :[select id,RE_Pricing_Date__c,RE_CND_Adjustment_Value__c, RE_CND_Final_Value__c, RE_Custom_Opp_Approve__c, RE_Submitter_Comments__c from RT_Price_Book__c 
                                              where RecordType.name like '%canada%'  and RE_Initial_Version__c =:version])
                    {
                        VersionWrapper vw= new VersionWrapper();
                        vw.versionId	=pb.Id;
                        vw.adjustValue	=pb.RE_CND_Adjustment_Value__c;
                        vw.pricingDate	=pb.RE_Pricing_Date__c;
                        vw.finalValue	=pb.RE_CND_Final_Value__c;
                        vw.status		=pb.RE_Custom_Opp_Approve__c;
                        vw.comment		=pb.RE_Submitter_Comments__c;
                        versionList.add(vw); 
                    }
                }
            }
        }catch(Exception ex)
        {
            System.debug('SFJ CREATION-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());            
            RV_ClassException.insertExceptionRecord('SFJ CREATION',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','getVersionRecords','Exception');
        }
        return versionList;
    }
    
    /****************************************************************************************************************
Method Name:  generateSFJPrices
Description:  Method to generate SFJ Prices based on Rev Contract Master and base prices from Cost Price
****************************************************************************************************************/       
    @AuraEnabled
    public static void generateSFJPrices(Date datefilter){
        // System.debug('Generate SFJ date--'+datefilter);
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        Date maxEffectiveFrom;
        Date maxEffectiveTo;
        List<RT_Price_Book__c>  agrList= new List<RT_Price_Book__c> ();
        try{
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Manual';
            jrAudit.RE_Job_Type__c = 'Canada SFJ Record Creation';
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';
            jrAudit.RE_Country_Name__c='CA';
            insert jrAudit;
            
            Set<Id> idsInserted = new Set<Id>();
            
            Map<String,RT_Price_Book__c> pbMap= new Map<String,RT_Price_Book__c>();
            Map<String,RE_MY_CostPrice__c> baseProductMap = new Map<String,RE_MY_CostPrice__c>();
            List<RT_Price_Book__c> pbListToCreate = new List<RT_Price_Book__c>();
            
            Id costPriceRecordTypeId 	= Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            Id pricebookRecordTypeId 	= Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
            
            Map<String, Double> curConvMap = new Map<String, Double>();
            
            for (RE_MY_CostPrice__c cp :[SELECT Id,RE_CND_Adjustment_Value__c,RE_CND_Final_Value__c, RE_CND_Market_Move__c,RE_CND_New_Base_Value__c,RE_Costprice_Unit__c,
                                         RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,RE_Product_Codes__c,RE_Depot_Code__c ,RE_CND_Group__c,RE_Fx_Rate__c,
                                         RE_Requested_Date__c
                                         FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= :datefilter AND RE_CND_Effective_To_Date__c >= :datefilter AND  
                                         RE_CND_Group__c='Unbranded' AND RecordTypeId=:costPriceRecordTypeId AND  RE_IsLatest__c=TRUE ])
            {
                baseProductMap.put(cp.RE_Product_Codes__c+'-'+cp.RE_Depot_Code__c+'-'+cp.RE_CND_Group__c,cp); 
                //System.debug('baseProductMap--'+cp.RE_Product_Codes__c+'-'+cp.RE_Depot_Code__c+'-'+cp.RE_CND_Group__c);
            }  
            
            for(REV_Contract_Master__c rcm: [SELECT id,Active__c, Country_Name__c, Name, RT_Material_Desc__c,RE_CND_Rack__c,
                                             RT_Sold_to_Name__c,  RT_Ship_to_Name__c ,RT_Ship_to_Number__c,RT_Material_Desc__r.RT_Product_Code__c,
                                             RE_CND_Product_Group__c,RE_CND_Pricing_Basis__c,RE_Final_Price_Unit__c
                                             FROM REV_Contract_Master__c where Active__c=TRUE AND Country_Name__c='CA'] )
            {
                //System.debug('rcm--'+rcm);
                RT_Price_Book__c newpb= new RT_Price_Book__c();
                newpb.RT_Sold_to_Name__c		=	rcm.RT_Sold_to_Name__c;
                newpb.RE_Is_Latest__c			=	true;
                newpb.RE_CND_Customer_Name__c 	=	rcm.RT_Ship_to_Name__c;
                newpb.RE_Custom_Opp_Approve__c 	=	'Draft';
                newpb.RE_CND_Rack__c			=	rcm.RE_CND_Rack__c;
                newpb.RE_CND_Pricing_Basis__c	= 	rcm.RE_CND_Pricing_Basis__c;
                newpb.RE_CND_Product_Group__c	=	rcm.RE_CND_Product_Group__c;
                newpb.RecordTypeId				=	pricebookRecordTypeId; 
                newpb.RT_Product__c				=	rcm.RT_Material_Desc__c;  
                newpb.RE_Pricing_Date__c		=	System.now();
                newpb.RE_Final_Price_Unit__c	=	rcm.RE_Final_Price_Unit__c;
                newpb.RE_CND_ShipTo_Number__c   =   rcm.RT_Ship_to_Number__c;
                if(baseProductMap.containsKey(rcm.RE_CND_Pricing_Basis__c))
                {
                    RE_MY_CostPrice__c base =   baseProductMap.get(rcm.RE_CND_Pricing_Basis__c);
                    newpb.RE_Fx_Rate__c				=	base.RE_Fx_Rate__c;
                    if(rcm.RE_Final_Price_Unit__c==base.RE_Costprice_Unit__c)
                    {
                        newpb.RE_CND_New_Base_Value__c					=	base.RE_CND_New_Base_Value__c;
                        newpb.RE_CND_Market_Move__c						=	base.RE_CND_Market_Move__c;  
                        newpb.RE_CND_Final_Value__c						=	base.RE_CND_Final_Value__c;
                    }
                    else
                    {
                        
                        String BaseCurrency=RE_unitConversion.unitBreakUp(base.RE_Costprice_Unit__c)[0];
                        String ConvertedCurrency=RE_unitConversion.unitBreakUp(rcm.RE_Final_Price_Unit__c)[0];
                        curConvMap.put(ConvertedCurrency+'-'+BaseCurrency,base.RE_Fx_Rate__c);
                        //System.debug('curConvMap--'+curConvMap);
                        
                        RE_unitConversion  ruc = new RE_unitConversion();
                        Double conversionMultiplier=ruc.unitConversionMultiplier(base.RE_Costprice_Unit__c,rcm.RE_Final_Price_Unit__c,'Canada',rcm.RE_CND_Product_Group__c,curConvMap);
                        newpb.RE_CND_New_Base_Value__c					=	(base.RE_CND_New_Base_Value__c *conversionMultiplier).setScale(4);
                        newpb.RE_CND_Market_Move__c						=	(base.RE_CND_Market_Move__c * conversionMultiplier).setScale(4);  
                        newpb.RE_CND_Final_Value__c						=	(base.RE_CND_Final_Value__c *conversionMultiplier).setScale(4);
                    }
                    newpb.RE_CND_Adjustment_Value__c					=	base.RE_CND_Adjustment_Value__c;
                    newpb.RE_CND_Effective_From_Date__c				=	base.RE_CND_Effective_From_Date__c;
                    newpb.RE_CND_Effective_To_Date__c				=	base.RE_CND_Effective_To_Date__c;
                    newpb.RT_Effective_Date__c						=	base.RE_Requested_Date__c;
                }
                pbMap.put(rcm.RT_Material_Desc__r.RT_Product_Code__c+'-'+rcm.RT_Ship_to_Number__c,newpb);
                //System.debug('pbMap--'+pbMap);
            }
            
            agrList=[SELECT  RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c FROM RT_Price_Book__c 
                     WHERE RE_Is_Latest__c =TRUE AND RecordTypeId=: pricebookRecordTypeId AND RE_CND_Effective_From_Date__c < :datefilter 
                     AND RE_CND_Effective_To_Date__c < :datefilter ORDER BY RE_CND_Effective_To_Date__c DESC LIMIT 1];
            //System.debug('AggregateResult--'+agrList);
            if(agrList.size()>0)
            {
                maxEffectiveFrom	=	agrList[0].RE_CND_Effective_From_Date__c;
                maxEffectiveTo		=	agrList[0].RE_CND_Effective_To_Date__c;
            }
                        
            //System.debug('From Date--'+maxEffectiveFrom+'--To Date--'+maxEffectiveTo);
            if(maxEffectiveFrom !=NULL && maxEffectiveTo!= NULL)
            {
                for(RT_Price_Book__c previousPrice : [SELECT id, RE_CND_Customer_Name__r.AccountNumber, RT_Product_Code__c,RE_CND_Final_Value__c,RE_Final_Price_Unit__c,RE_Fx_Rate__c,
                                                      RE_CND_Product_Group__c FROM RT_Price_Book__c WHERE RE_CND_Effective_From_Date__c =:maxEffectiveFrom AND 
                                                      RE_CND_Effective_To_Date__c=:maxEffectiveTo AND RE_Is_Latest__c=TRUE AND RecordTypeId=:pricebookRecordTypeId])
                {
                    //   System.debug('previousPrice--'+previousPrice);
                    if(pbMap.containsKey(previousPrice.RT_Product_Code__c+'-'+previousPrice.RE_CND_Customer_Name__r.AccountNumber))
                    {
                        String newpbRateUnit=pbMap.get(previousPrice.RT_Product_Code__c+'-'+previousPrice.RE_CND_Customer_Name__r.AccountNumber).RE_Final_Price_Unit__c;
                        if(newpbRateUnit==previousPrice.RE_Final_Price_Unit__c)
                            pbMap.get(previousPrice.RT_Product_Code__c+'-'+previousPrice.RE_CND_Customer_Name__r.AccountNumber).RE_CND_Old_Base_Value__c =previousPrice.RE_CND_Final_Value__c;
                        else
                        {
                            String BaseCurrency=RE_unitConversion.unitBreakUp(previousPrice.RE_Final_Price_Unit__c)[0];
                            String ConvertedCurrency=RE_unitConversion.unitBreakUp(newpbRateUnit)[0];
                            
                            Map<String, Double> yesterdayPriceMap = new Map<String, Double>();
                            yesterdayPriceMap.put(ConvertedCurrency+'-'+BaseCurrency,previousPrice.RE_Fx_Rate__c);
                            
                            RE_unitConversion  unitCon = new RE_unitConversion();
                            Double conversionMultiplier=unitCon.unitConversionMultiplier(previousPrice.RE_Final_Price_Unit__c,newpbRateUnit,'Canada',
                                                                                         previousPrice.RE_CND_Product_Group__c,yesterdayPriceMap);
                            // System.debug('conversionMultiplier--'+conversionMultiplier);
                            pbMap.get(previousPrice.RT_Product_Code__c+'-'+previousPrice.RE_CND_Customer_Name__r.AccountNumber).RE_CND_Old_Base_Value__c =
                                (previousPrice.RE_CND_Final_Value__c*conversionMultiplier).setScale(4);
                        }
                    }
                }
            }
            //System.debug('pbMap--'+pbMap);
            pbListToCreate=pbMap.values();
            //System.debug('pbListToCreate--'+pbListToCreate);
            if(pbListToCreate.size() >0)
            {
                Database.SaveResult[] insertPBStatus= Database.insert(pbListToCreate, false);
                idsInserted=RE_CND_Utility.handleInsert('RE_CND_RackDetail_Controller','generateSFJPrices',insertPBStatus,jrAudit);
                
                List<RT_Price_Book__c> pbVersionList = new List<RT_Price_Book__c>();
                for(RT_Price_Book__c pbversion : [SELECT Id ,Name,RE_Initial_Version__c FROM RT_Price_Book__c WHERE Id IN :idsInserted])
                {
                    pbversion.RE_Initial_Version__c= pbversion.Name;
                    pbVersionList.add(pbversion);
                }
                if(pbVersionList.size() >0)
                {
                    //   System.debug('pbVersionList--'+pbVersionList);
                    //update pbVersionList;
                    Database.SaveResult[] updatePBVersion= Database.update(pbVersionList, false);
                    Boolean isError= RE_CND_Utility.handleUpdateResult('RE_CND_RackDetail_Controller','generateSFJPrices',updatePBVersion,false,jrAudit); 
                }
                //System.debug('After Insert---');
            }
            
            if(jrAudit.RE_Job_Status__c=='Processing')
            {
                jrAudit.RE_Job_Status__c='Completed';               
                update jrAudit;
            }
            
        }
        catch(Exception ex){
            System.debug('SFJ CREATION-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            if(	jrAudit!= NULL)
            {
                RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex); 
            }
            RV_ClassException.insertExceptionRecord('SFJ CREATION',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','generateSFJPrices','Exception');
        }
    }
    
    // Get SAP Download data from Cost Price & Price Book
    @AuraEnabled
    public static sapDowldWrappr getSAPdownloadData(List<String> recordsToDownload, Date datefilter)
    {
        sapDowldWrappr sapDowld = New sapDowldWrappr();       
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        try
        {
            RE_CND_ExecuteDepoPricingController.jobRunStatusWrapper jobRunStat = New RE_CND_ExecuteDepoPricingController.jobRunStatusWrapper();
            Id costPriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            Id pricebookRecordTypeId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
            Map<String,RE_CustomOpps_ReportConfiguration__c> configMap = new Map<String,RE_CustomOpps_ReportConfiguration__c>();
            Boolean isDefSettingActive = false;
            Integer defDateExt;
            Date defaultToDateForGsap;
            String validStartDtString = RE_CND_RackDetail_Controller.convertDate(String.valueOf(datefilter));
            Integer brandedSeqNo = 1;
            Integer unbrandedSeqNo = 1;
            Integer sfjSeqNo = 1;
            List<Fixed_Price_Staging_Table__c> unBrandedLstData = New List<Fixed_Price_Staging_Table__c>();
            List<Fixed_Price_Staging_Table__c> brandedLstData = New List<Fixed_Price_Staging_Table__c>();
            List<Fixed_Price_Staging_Table__c> sfjLstData = New List<Fixed_Price_Staging_Table__c>();
            DateTime dtNow = System.now();
            
            // Get the GSAP To Date extension 
            List<RE_Default_Settings__c> DefSettingList = RE_Default_Settings__c.getAll().values();
            for(RE_Default_Settings__c DefSettingRec :DefSettingList )
            {
                if(DefSettingRec.Is_Active__c && DefSettingRec.Country_Name__c == 'Canada' && DefSettingRec.Type__c == 'GSAP To Date Extension')
                {
                    isDefSettingActive = true;
                    defDateExt =  Integer.valueOf(DefSettingRec.Value__c);
                    break;
                }
            }       
            
            // Get details of Varkey preparation
            for(RE_CustomOpps_ReportConfiguration__c reportInfo:RE_CustomOpps_ReportConfiguration__c.getall().values())
            {
                if(reportInfo.RE_Country_Name__c=='Canada')
                {
                    configMap.put(reportInfo.RE_Customer_Type__c,reportInfo);
                }
            }
            
            List<String> statusList = new List<String>{'Failed', 'Ready to Upload', 'Uploaded', 'Upload not allowed'};
                
                if(recordsToDownload.contains('Branded') || recordsToDownload.contains('Unbranded'))
            {                  
                for (RE_MY_CostPrice__c cp :[SELECT Id,RE_CND_Final_Value__c,RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,
                                             RE_Product_Codes__c,RE_Depot_Code__c,RE_Status__c ,RE_CND_Group__c,RE_CND_Product_Name__c
                                             FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= :datefilter 
                                             AND RE_CND_Effective_To_Date__c >= :datefilter AND  RecordTypeId=:costPriceRecordTypeId AND RE_IsLatest__c=TRUE
                                             AND RE_CND_Is_only_applicable_to_SFJ__c = FALSE
                                             AND RE_Status__c IN :(statusList) AND RE_CND_Group__c IN: recordsToDownload])
                {                    
                    Fixed_Price_Staging_Table__c fpsData = new Fixed_Price_Staging_Table__c();
                    defaultToDateForGsap = isDefSettingActive ? cp.RE_CND_Effective_From_Date__c.addDays(defDateExt):cp.RE_CND_Effective_To_Date__c;
                    
                    if(cp.RE_CND_Group__c == 'Branded' && recordsToDownload.contains('Branded'))
                    {                        
                        String key = '';
                        List<string> keylist = configMap.get('Branded').RE_Varkey__c.split('\\+');
                        for(String tempData : keylist){ 
                            if(tempData.contains('_'))
                                key = key + cp.get(tempData);
                            else
                                key = key + tempData;
                        }
                        
                        fpsData = createSAPDataForDownload(configMap.get('Branded'),brandedSeqNo,cp.RE_CND_Effective_From_Date__c,defaultToDateForGsap,
                                                           cp.RE_CND_Final_Value__c,key);
                        
                        brandedLstData.add(fpsData);                        
                        brandedSeqNo++;                       
                    }
                    else if(cp.RE_CND_Group__c == 'Unbranded' && recordsToDownload.contains('Unbranded'))
                    {
                        String key = '';
                        List<string> keylist = configMap.get('Unbranded').RE_Varkey__c.split('\\+');
                        for(String tempData : keylist){ 
                            if(tempData.contains('_'))
                                key = key + cp.get(tempData);
                            else
                                key = key + tempData;
                        }
                        
                        fpsData = createSAPDataForDownload(configMap.get('Unbranded'),unbrandedSeqNo,cp.RE_CND_Effective_From_Date__c,defaultToDateForGsap,
                                                           cp.RE_CND_Final_Value__c,key);
                        
                        unBrandedLstData.add(fpsData);                         
                        unbrandedSeqNo++;                        
                    }
                }
            }            
            
            if(recordsToDownload.contains('SFJ'))
            {
                for(RT_Price_Book__c pb : [SELECT id, RE_CND_Customer_Name__r.AccountNumber,RE_CND_Final_Value__c, 
                                           RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,RT_Product_Code__c,
                                           RE_Custom_Opp_Approve__c, RE_CND_Product_Name__c, RE_CND_ShipTo_Number__c    
                                           FROM RT_Price_Book__c WHERE  RE_CND_Effective_From_Date__c <= :datefilter 
                                           AND RE_CND_Effective_To_Date__c >= :datefilter AND  RecordTypeId=:pricebookRecordTypeId AND RE_Is_Latest__c=TRUE
                                           AND RE_Custom_Opp_Approve__c IN :(statusList)])
                {             
                    Fixed_Price_Staging_Table__c fpsData = new Fixed_Price_Staging_Table__c();
                    defaultToDateForGsap = isDefSettingActive ? pb.RE_CND_Effective_From_Date__c.addDays(defDateExt):pb.RE_CND_Effective_To_Date__c;   
                    
                    String key = '';
                    List<string> keylist = configMap.get('SFJ').RE_Varkey__c.split('\\+');
                    for(String tempData : keylist)
                    { 
                        if(tempData.contains('_'))
                        {
                            if(tempData=='Account_Number')
                            {                             
                                key = key + pb.RE_CND_ShipTo_Number__c;
                            }
                            else
                                key = key + pb.get(tempData);
                        }
                        else
                            key = key + tempData;
                    }
                    
                    fpsData = createSAPDataForDownload(configMap.get('SFJ'),sfjSeqNo,pb.RE_CND_Effective_From_Date__c,defaultToDateForGsap,
                                                       pb.RE_CND_Final_Value__c,key);
                    
                    sfjLstData.add(fpsData);                
                    sfjSeqNo++;  
                }
            }               
            
            // Aborting the existing Apexjobs that triggered for Uploading to SAP
            RE_Job_Run_Audit__c[] jra = [SELECT Id, RE_Job_Status__c, RE_Batch_Job_Ids__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c =: 'Canada GSAP Upload' AND CreatedDate = Today ORDER BY CreatedDate DESC LIMIT 1];
            if(jra.Size() > 0)
            {
                if(jra[0].RE_Job_Status__c == 'Processing')
                {                    
                    List<String> apexJobIds = jra[0].RE_Batch_Job_Ids__c.split(';');
                    if(apexJobIds.Size() > 0)
                    {                    
                        for (AsyncApexJob asynJob : [SELECT Id ,Status FROM AsyncApexJob WHERE Id IN: apexJobIds 
                                                     AND Status NOT IN ('Aborted','Completed','Failed')])
                        {                    
                            try
                            {
                                System.AbortJob(asynJob.Id); 
                            }
                            catch(Exception e){
                                System.debug('line-'+e.getLineNumber()+e.getMessage());
                                RV_ClassException.insertExceptionRecord('getSAPdownloadData-AbortJobs',e.getMessage()+e.getLineNumber()+asynJob.Id,'RE_CND_RackDetail_Controller','getSAPdownloadData-AbortJobs','Exception');                                                    
                            }            
                        }
                    }
                    
                    jrAudit.RE_Run_Time__c = dtNow;
                    jrAudit.RE_Run_Type__c = 'Manual';
                    jrAudit.RE_Job_Type__c = 'Canada GSAP Upload';
                    jrAudit.RE_User__c = UserInfo.getUserId();
                    jrAudit.RE_Job_Run_Count__c = 1;
                    jrAudit.RE_Job_Status__c = 'Cancelled';
                    jrAudit.RE_Country_Name__c ='CA';
                    jrAudit.RE_Batch_Job_Ids__c = jra[0].Id;
                    jrAudit.Other_Comments__c = 'Manually Downloaded the SAP File(s), while processing the Upload To SAP JobRunAudit: ' + jra[0].Id;
                    insert jrAudit;                    
                }
                else
                {                    
                    jrAudit.RE_Run_Time__c = dtNow;
                    jrAudit.RE_Run_Type__c = 'Manual';
                    jrAudit.RE_Job_Type__c = 'Canada GSAP Upload';
                    jrAudit.RE_User__c = UserInfo.getUserId();
                    jrAudit.RE_Job_Run_Count__c = 1;
                    jrAudit.RE_Job_Status__c = 'Completed';
                    jrAudit.RE_Country_Name__c ='CA';
                    jrAudit.Other_Comments__c = 'Manually Downloaded the SAP File(s)';
                    insert jrAudit;                     
                }
            }
            else
            {                
                jrAudit.RE_Run_Time__c = dtNow;
                jrAudit.RE_Run_Type__c = 'Manual';
                jrAudit.RE_Job_Type__c = 'Canada GSAP Upload';
                jrAudit.RE_User__c = UserInfo.getUserId();
                jrAudit.RE_Job_Run_Count__c = 1;
                jrAudit.RE_Job_Status__c = 'Completed';
                jrAudit.RE_Country_Name__c = 'CA';
                jrAudit.Other_Comments__c = 'Manually Downloaded the SAP File(s)';
                insert jrAudit;                
            }      
            
            sapDowld.brandedLst = brandedLstData;
            sapDowld.unbrandedLst = unBrandedLstData;
            sapDowld.sfjLst = sfjLstData;

            return sapDowld;
        }
        catch(Exception ex)
        {
            System.debug('getSAPdownloadData-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('getSAPdownloadData',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','getSAPdownloadData','Exception');
            return sapDowld;
        }        
    }
    
    // Prepare SAP Download Data
    public static Fixed_Price_Staging_Table__c createSAPDataForDownload(RE_CustomOpps_ReportConfiguration__c config,Integer seq,Date fromDate,Date toDate,Decimal value,String key)
    {        
        String fromDateString = convertDate(String.valueOf(fromDate));
        String toDateString = convertDate(String.valueOf(toDate));
        Fixed_Price_Staging_Table__c fps = new Fixed_Price_Staging_Table__c();
        fps.RE_Sequence_No__c = seq;
        fps.RE_Cond_Usage_Table__c = config.RE_Condition_Usage_Table__c;
        fps.RE_Cond_table_no__c = config.RE_Condition_Table__c;
        fps.RE_Application__c = config.RE_Application__c;
        fps.RE_Report_Type__c = config.RE_Condition_Type__c;
        fps.RE_Varkey__c = key;
        fps.RE_Valid_start_date__c = fromDateString;
        fps.RE_Valid_End_date__c = toDateString;
        fps.RE_Scale_Type__c = config.RE_Scale_Type__c;
        fps.RE_Calculation_type__c = config.RE_Calculation_Type__c;
        fps.RE_Value__c = String.valueOf(value);
        fps.RE_Currency_Unit__c = config.RE_Unit__c;
        fps.RE_Uom__c = config.RE_UoM__c;
        fps.RE_Quantity__c = config.RE_Quantity__c;        
        
        return fps;
    }
    
    /****************************************************************************************************************
Method Name:  uploadToGSAP
Description:  Method to upload Canada Prices from Cost Price and REV Pricebook into GSAP System
****************************************************************************************************************/  
    @AuraEnabled
    public static void uploadToGSAP(List<String> recordstoupload,Date datefilter,String uploadType )
    {
        
        System.debug('datefilter--'+datefilter+'--upload Type--'+uploadType+'--recordstoupload--'+recordstoupload);
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        
        try
        {
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Manual';
            jrAudit.RE_Job_Type__c = 'Canada GSAP Upload';
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';
            jrAudit.RE_Country_Name__c='CA';
            insert jrAudit;
            
            // Queueable Class
            RE_CND_uploadToGSAPQueue upldSAPQue = New RE_CND_uploadToGSAPQueue(recordstoupload,datefilter,uploadType,jrAudit.Id);
            // Enqueue the job for processing
            ID jobID = System.enqueueJob(upldSAPQue);  
            
            // Update Batch Ids to corresponding Job Run Audit
            jrAudit.RE_Batch_Job_Ids__c = jobID;
            update jrAudit;      
            
        } catch(Exception ex){
            if(	jrAudit!= NULL)
            {
                RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex); 
            }
            System.debug('GSAP UPLOAD-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GSAP UPLOAD',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','uploadToGSAP','Exception');
        }
        
    }
    public static String convertDate(String dateToConvert)
    {
        String dateString='';
        for(String x : dateToConvert.split('-'))
        {
            dateString= dateString+x;
        }
        return dateString;
    }
    
    public static List<Fixed_Price_Staging_Table__c> createStaging(RE_CustomOpps_ReportConfiguration__c config,Integer seq,Date fromDate,Date toDate,Decimal value,
                                                                   String prodDesc,String key,List<Fixed_Price_Staging_Table__c> fpsToInsert,Id recordId, Id jobRunId)
    {
        String fromDateString=convertDate(String.valueOf(fromDate));
        String toDateString=convertDate(String.valueOf(toDate));
        Fixed_Price_Staging_Table__c fps = new Fixed_Price_Staging_Table__c();
        fps.RE_Sequence_No__c=seq;
        fps.RE_Cond_Usage_Table__c=config.RE_Condition_Usage_Table__c;
        fps.RE_Cond_table_no__c=config.RE_Condition_Table__c;
        fps.RE_Application__c =config.RE_Application__c;
        fps.RE_Report_Type__c =config.RE_Condition_Type__c;
        fps.RE_Varkey__c=key;
        fps.RE_Valid_start_date__c=fromDateString;
        fps.RE_Valid_End_date__c =toDateString;
        fps.RE_Scale_Type__c=config.RE_Scale_Type__c;
        fps.RE_Calculation_type__c=config.RE_Calculation_Type__c;
        fps.RE_Value__c=String.valueOf(value);
        fps.RE_Currency_Unit__c=config.RE_Unit__c;
        fps.RE_Uom__c=config.RE_UoM__c;
        fps.RE_Quantity__c=config.RE_Quantity__c;
        fps.RE_Material_Description__c=prodDesc;
        fps.RE_Is_latest__c=true;
        fps.RE_Country_Name__c='CA';
        fps.RE_Job_Run_Audit__c = jobRunId;
        fps.RE_Record_Key__c = key + '-' + fromDateString + '-' + toDateString;
        if(config.RE_Customer_Type__c=='Branded'||config.RE_Customer_Type__c=='Unbranded')
        {
            fps.RE_Cost_Price__c=recordId;
        }
        else if(config.RE_Customer_Type__c=='SFJ')
        {
            fps.REV_Price_Book__c=recordId ;
        }
        fpsToInsert.add(fps);
        //System.debug('fps---'+fps);
        return fpsToInsert;
    }
    
    @AuraEnabled
    public static saveReturnWrapper getSaveStatus(){
        
        saveReturnWrapper srw = new saveReturnWrapper();
        try{
            RE_Job_Run_Audit__c jra=[SELECT RE_Job_Status__c,RE_IsSuccess__c,Other_Comments__c FROM RE_Job_Run_Audit__c WHERE RE_Job_Type__c='Canada Pricing Recalculation' 
                                     ORDER BY CreatedDate DESC LIMIT 1];
            srw.isSuccess	=jra.RE_IsSuccess__c;
            srw.saveMessage	=jra.Other_Comments__c;
            srw.saveStatus	=jra.RE_Job_Status__c;
        }
        catch(Exception ex)
        {
            System.debug('SAVE STATUS-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('SAVE STATUS',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','getSaveStatus','Exception');  
        }
        return srw;
    }
    
    
    @AuraEnabled
    public static void saveRecords(String updatedRecords ,Date datefilter){
        System.debug('updatedRecords--'+updatedRecords);
                
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        try
        {            
            jrAudit.RE_Run_Time__c = System.now();
            jrAudit.RE_Run_Type__c = 'Manual';
            jrAudit.RE_Job_Type__c = 'Canada Pricing Recalculation';
            jrAudit.RE_User__c = UserInfo.getUserId();
            jrAudit.RE_Job_Run_Count__c = 1;
            jrAudit.RE_Job_Status__c='Processing';
            jrAudit.RE_Country_Name__c='CA';
            jrAudit.RE_IsSuccess__c=false;
            insert jrAudit;
            
            // Queueable Class
            RE_CND_saveRecordQueue saveRecQue = New RE_CND_saveRecordQueue(updatedRecords,datefilter,jrAudit);
            // Enqueue the job for processing
            ID jobID = System.enqueueJob(saveRecQue);           
        }
        catch(Exception ex){
            if(	jrAudit!= NULL)
            {
                RE_CND_Utility.updateJobAudit(jrAudit,'Failed',ex); 
            }
            System.debug('SAVE ADJUSTMENT-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('SAVE ADJUSTMENT',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','saveRecords','Exception');
        }
    }
    
    public static RE_MOA__c updateMOA(Decimal adjustment,RE_MOA__c moa,String comment, Boolean calcDiff,Decimal parentFinalPrice,Decimal oldAdjust)
    {
        System.debug('adjustment--'+adjustment+'--oldAdjust--'+oldAdjust);
        adjustment = (adjustment == null) ? 0.00 : adjustment;  
        if(moa.RE_CND_Competitive_Adj__c!=null) 
        {
            //moa.RE_CND_Competitive_Adj__c=(moa.RE_CND_Competitive_Adj__c+adjustment-oldAdjust).setScale(1, RoundingMode.HALF_UP);
            moa.RE_CND_Competitive_Adj__c=(moa.RE_CND_Competitive_Adj__c+adjustment).setScale(1, RoundingMode.HALF_UP);
            System.debug('Competitive adjustment---'+moa.RE_CND_Competitive_Adj__c);
        }
        else
        {
            moa.RE_CND_Competitive_Adj__c=(adjustment).setScale(1, RoundingMode.HALF_UP);  
            System.debug('Competitive adjustment---'+moa.RE_CND_Competitive_Adj__c);
        }
        
        if(moa.RE_CND_Market_Move__c!=null)
        {
            if(moa.RE_CND_Competitive_Adj__c > 0)
            {
                moa.RE_CND_Net_Move__c = (moa.RE_CND_Market_Move__c+ moa.RE_CND_Competitive_Adj__c).setScale(1, RoundingMode.HALF_UP) ;
                System.debug('Net move--'+moa.RE_CND_Net_Move__c );
            }
            else
            {
                if(moa.RE_CND_Competitive_Adj__c == 0) 
                {
                    moa.RE_CND_Net_Move__c = moa.RE_CND_Market_Move__c.setScale(1);
                    System.debug('Net move--'+moa.RE_CND_Net_Move__c );
                }
                else
                {
                    moa.RE_CND_Net_Move__c =  (moa.RE_CND_Market_Move__c+ moa.RE_CND_Competitive_Adj__c).setScale(1, RoundingMode.HALF_UP);
                    System.debug('Net move--'+moa.RE_CND_Net_Move__c );
                }
            }
        }
        else
        {
            
            if(moa.RE_CND_Competitive_Adj__c > 0)
            {
                moa.RE_CND_Net_Move__c = (moa.RE_CND_Competitive_Adj__c).setScale(1, RoundingMode.HALF_UP);
                System.debug('Net move--'+moa.RE_CND_Net_Move__c );
            }
            else
            {
                if(moa.RE_CND_Competitive_Adj__c == 0) 
                { moa.RE_CND_Net_Move__c =moa.RE_CND_Competitive_Adj__c.setScale(1, RoundingMode.HALF_UP); 
                 System.debug('Net move--'+moa.RE_CND_Net_Move__c );}
                else
                {moa.RE_CND_Net_Move__c = (moa.RE_CND_Competitive_Adj__c).setScale(1, RoundingMode.HALF_UP);
                 System.debug('Net move--'+moa.RE_CND_Net_Move__c );}
            }
        }
        moa.RE_CND_New_End_Price__c=(moa.RE_CND_Today_s_Price__c+moa.RE_CND_Net_Move__c).setScale(2, RoundingMode.HALF_UP);
        moa.RE_AM_Comments__c=comment+'new adjustment--'+adjustment+'--old Adjust--'+oldAdjust;
        if(calcDiff)
        {
            moa.RE_CND_Difference__c=(moa.RE_CND_New_End_Price__c-parentFinalPrice).setScale(1, RoundingMode.HALF_UP);
        }
        system.debug('After update--'+moa);
        return moa;
    }
    
    @AuraEnabled
    public static prcngDiffWrappr priceExecutnDataIntegrityChecks(Date datefilter)
    {        
        prcngDiffWrappr prcngDiffWrpper = new prcngDiffWrappr();
        
        try
        {
            Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
            Id cndCostPriceRecdTypId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            Map<String,Decimal> prceExecMOAData = New Map<String,Decimal>();
            Map<String,Decimal> costPrceData = New Map<String,Decimal>();
            String validatnMsg = null;
            List<prcngDiffClass> prcngDiffClassLst = New List<prcngDiffClass>();
            
            // Get all the cost price data for price execution racks
            for(RE_MY_CostPrice__c cpData : [SELECT Id, RE_CND_Rack__c, RE_Product_Name__r.RE_Product_Classification_L0__c, RE_CND_Final_Value__c  
                                             FROM RE_MY_CostPrice__c WHERE RecordTypeId =: cndCostPriceRecdTypId AND RE_CND_Effective_From_Date__c <=: datefilter AND RE_CND_Effective_To_Date__c >=: datefilter 
                                             AND RE_IsLatest__c =: TRUE AND RE_CND_Group__c =: 'Unbranded' AND (RE_CND_Is_Base_Product__c =: TRUE 
                                                                                                                OR (RE_CND_Rack__c =: 'Belleville' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD'))
                                                                                                                OR (RE_CND_Rack__c =: 'Ottawa' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD'))
                                                                                                                OR (RE_CND_Rack__c =: 'Kingston' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD'))
                                                                                                                OR (RE_CND_Rack__c =: 'Sarnia' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD'))
                                                                                                                OR (RE_CND_Rack__c =: 'London' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD'))
                                                                                                                OR (RE_CND_Rack__c =: 'Sault Ste Marie' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD'))
                                                                                                                OR (RE_CND_Rack__c =: 'Thunder Bay' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD'))
                                                                                                                OR (RE_CND_Rack__c =: 'Kamloops' AND (RE_CND_Product_Group__c =: 'RUG' OR RE_CND_Product_Group__c =: 'ULSD')))
                                             ORDER BY RE_CND_Rack__c, RE_CND_Product_Group__c])
            {
                costPrceData.put(cpData.RE_CND_Rack__c + '-'+ cpData.RE_Product_Name__r.RE_Product_Classification_L0__c,cpData.RE_CND_Final_Value__c);
            }
            
            // Get all the price execution data for selected date
            for(RE_MOA__c peData : [SELECT Id, RE_CND_Rack__c, RE_CND_Group__c, RE_CND_New_End_Price__c FROM RE_MOA__c 
                                    WHERE RecordTypeId =: cadMOARecordTypeId AND RE_CND_Effective_From_Date__c <=: datefilter AND RE_CND_Effective_To_Date__c >=: datefilter
                                    AND RE_IsLatest__c =: TRUE ORDER BY RE_CND_Rack__c, RE_CND_Group__c])
            {
                prceExecMOAData.put(peData.RE_CND_Rack__c + '-'+ peData.RE_CND_Group__c, peData.RE_CND_New_End_Price__c);
            }            
            
            if(prceExecMOAData.Size() > 0 && costPrceData.Size() > 0)
            {
                for(String rckDetail: prceExecMOAData.keyset())
                {
                    // check price execution and ca dashboard values are matching
                    if((costPrceData.containsKey(rckDetail)) && (costPrceData.get(rckDetail) != prceExecMOAData.get(rckDetail)))
                    {
                        prcngDiffClass prcngDiff = new prcngDiffClass();
                        
                        if(rckDetail.substringAfter('-') == 'Gasoline')
                        {
                            prcngDiff.rack = rckDetail.substringBefore('-Gasoline');
                            prcngDiff.grpclassifictn = 'Gasoline';
                            prcngDiff.caPrice = costPrceData.get(rckDetail);
                            prcngDiff.pePrice = prceExecMOAData.get(rckDetail);
                            prcngDiff.capaDiff = costPrceData.get(rckDetail) - prceExecMOAData.get(rckDetail);
                            prcngDiffClassLst.add(prcngDiff);
                        }
                        else if(rckDetail.substringAfter('-') == 'Gas Oil')
                        {
                            prcngDiff.rack = rckDetail.substringBefore('-Gas Oil');
                            prcngDiff.grpclassifictn = 'Gas Oil';
                            prcngDiff.caPrice = costPrceData.get(rckDetail);
                            prcngDiff.pePrice = prceExecMOAData.get(rckDetail);
                            prcngDiff.capaDiff = costPrceData.get(rckDetail) - prceExecMOAData.get(rckDetail);
                            prcngDiffClassLst.add(prcngDiff);                            
                        }                        
                    }
                }
            }
            
            // If any non-matching records while comparing price execution and ca dashboard
            if(prcngDiffClassLst.Size() > 0)
            {
                prcngDiffWrpper.prcngDiffLst = prcngDiffClassLst;
                prcngDiffWrpper.isPrceDiscrepancyExists = True;   
            }
            else            
            {
                prcngDiffWrpper.prcngDiffLst = null;
                prcngDiffWrpper.isPrceDiscrepancyExists = False; 
            }
        }
        Catch(Exception ex)
        {      
            prcngDiffWrpper.isPrceDiscrepancyExists = False; 
            System.debug('priceExecutnDataIntegrityChecks-Error-->'+ex.getMessage());
            System.debug('priceExecutnDataIntegrityChecks-Error-LN-->'+ex.getLineNumber());
            RV_ClassException.insertExceptionRecord('priceExecutnDataIntegrityChecks',ex.getMessage()+'-'+ex.getLineNumber(),'RE_CND_RackDetail_Controller','priceExecutnDataIntegrityChecks','Exception');          
        }         
        
        return prcngDiffWrpper;
    }
    
    @AuraEnabled
    public static Boolean checkFutureRecord()
    {
        Boolean hasFutureRecord=false;
        try
        {
            Id costPriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            List<RE_MY_CostPrice__c> futureCP =[SELECT Id FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= TOMORROW AND RE_CND_Effective_To_Date__c >= TOMORROW 
                                                AND  RecordTypeId=:costPriceRecordTypeId AND RE_IsLatest__c=TRUE];
            
            if(futureCP.size()>0)
            {hasFutureRecord =true;  }
        }        
        catch(Exception ex)
        {
            System.debug('HAS FUTURE RECORD-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('HAS FUTURE RECORD',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','checkFutureRecord','Exception');
        }
        return hasFutureRecord;
    }
    
    @AuraEnabled
    public static CanadaRackWrapper getCanadaFilters(Date datefilter){
        System.debug('getCanadaFilters called--'+datefilter);
        
        Boolean editAdjustmentOnCP =false;
        Boolean editAdjustmentOnPB =false;
        CanadaRackWrapper crw = new CanadaRackWrapper();
        List<string>  groupList = new List<string>();
        List<String> locationList = new List<String>();
        List<String> productList = new List<String>();
        
        List<String> gasolineList = new List<String>();
        List<String> dieselList = new List<String>();
        
        List<String> rackList = new List<String>();
        try
        {
            Id costPriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            
            for (RE_MY_CostPrice__c cp :[SELECT Id,RE_CND_Rack__c,RE_CND_Location_Abbreviated_Name__c, RE_Depot_Code__c,RE_CND_Product_Name__c, RE_Product_Codes__c,
                                         RE_CND_Product_Group__c,RE_Product_Name__r.RE_Product_Classification_L0__c
                                         FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= :datefilter 
                                         AND RE_CND_Effective_To_Date__c >= :datefilter AND  RecordTypeId=:costPriceRecordTypeId AND RE_IsLatest__c=TRUE ORDER BY RE_CND_Rack__c DESC])
            {
                if(!locationList.contains(cp.RE_CND_Location_Abbreviated_Name__c+'-'+cp.RE_Depot_Code__c))
                    locationList.add(cp.RE_CND_Location_Abbreviated_Name__c+'-'+cp.RE_Depot_Code__c);
                
                if(!productList.contains(cp.RE_CND_Product_Name__c+'-'+cp.RE_Product_Codes__c))
                    productList.add(cp.RE_CND_Product_Name__c+'-'+cp.RE_Product_Codes__c); 
                
                if(!(rackList.contains(cp.RE_CND_Rack__c)))
                {
                    rackList.add(cp.RE_CND_Rack__c);
                }
                
                if(!groupList.contains(cp.RE_CND_Product_Group__c))
                    groupList.add(cp.RE_CND_Product_Group__c);
                
                if(cp.RE_Product_Name__r.RE_Product_Classification_L0__c=='Gasoline')
                {
                    if(!(gasolineList.contains(cp.RE_CND_Product_Group__c)))
                    {
                        gasolineList.add(cp.RE_CND_Product_Group__c);
                        // System.debug('gasolineList--'+gasolineList);
                    }
                }
                else
                {
                    if(!(dieselList.contains(cp.RE_CND_Product_Group__c)))
                        dieselList.add(cp.RE_CND_Product_Group__c );
                    // System.debug('dieselList--'+dieselList);
                }
            }
            groupList.sort();
            locationList.sort();
            productList.sort();
            Boolean hasEditAccess=false;
            Boolean hasGSAPAccess=false;
            List<PermissionSetAssignment> permlst = [SELECT Id, PermissionSet.Name, PermissionSet.Profile.Name FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId()];
            for(PermissionSetAssignment perm:permlst){
                if((perm.PermissionSet.Name == 'RE_CND_Pricing_Permission') )
                {
                    hasEditAccess= true;
                }
                
                if((perm.PermissionSet.Name == 'RE_CND_SAP_Permission'))
                {hasGSAPAccess=true;}
            } 
            
            crw.GSAPProcessingStatus= getGSAPJobStatus();
            crw.gasolineList= gasolineList;
            crw.dieselList=dieselList;
            crw.prodGroupList=groupList;
            crw.PricingAccess=hasEditAccess;
            crw.GSAPAccess=hasGSAPAccess;
            crw.racklist=rackList;
            crw.locList=locationList;
            crw.prodList=productList;
            //System.debug('crw--'+crw);
        }
        catch(Exception ex)
        {
            System.debug('GET CANADA FILTER-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GET CANADA FILTER',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','getCanadaRacks','Exception');
        }
        return crw;
    }
    
    @AuraEnabled
    public static AllDataWrapper getAllData(Date datefilter){
        System.debug('datefilter--'+datefilter);
        
        Map<String,List<Integer>> baseDerivativeMap = new Map<String,List<Integer>>();
        Boolean generateSFJ=false;
        Map<String, String> approveStatus = new Map<String, String>{'Draft' => 'DR' ,'Ready to Upload' => 'RU', 'Uploaded' => 'UP' , 'Failed' => 'FA', 'Upload not allowed' => 'UN'};
            List<CostPriceWrapper > cplist= new List<CostPriceWrapper > (); 
        AllDataWrapper adw = new AllDataWrapper();
        try{
            
            RE_Record_Id_Mappings__c opisReport =[SELECT id, Record_Id__c,Type_Name__c FROM RE_Record_Id_Mappings__c WHERE Country_Name__c ='Canada' AND Is_Active__c=TRUE
                                                  AND Type_Name__c ='OPIS Comparison'];
            // System.debug('opisReport--'+opisReport);
            Id costPriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
            Id pricebookRecordTypeId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Canada_SFJ_Price').getRecordTypeId();
            
            Integer i=0;
            
            List<RE_MY_CostPrice__c> futureCP =[SELECT Id FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= TOMORROW AND RE_CND_Effective_To_Date__c >= TOMORROW 
                                                AND  RecordTypeId=:costPriceRecordTypeId AND RE_IsLatest__c=TRUE];
            
            if(futureCP.size()>0 &&  datefilter==System.today())
            {adw.hasFutureRecord =true;  }
            else
            {adw.hasFutureRecord =false;  }
            
            for (RE_MY_CostPrice__c cp :[SELECT Id,RE_CND_Rack__c,RE_CND_Final_Value__c,RE_Initial_Version__c,RE_CND_Differential_Basis__c,RE_Costprice_Unit__c,
                                         RE_CND_Product_Group__c,RE_CND_Adjustment_Value__c,RE_Product_Name__c,RE_Depot_Name__c,RE_IsLatest__c,RE_Pricing_Date__c,
                                         RE_CND_Brand_Discount__c,RE_CND_Plant_Differential__c,RE_CND_Brand_Fee__c,RE_CND_Product_Differential__c,RE_Fx_Rate__c,
                                         RE_CND_Old_Base_Value__c,RE_CND_Net_Move_Value__c,RE_CND_Market_Move__c,RE_CND_New_Base_Value__c,RE_Submitter_Comments__c,
                                         RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,RE_CND_Pricing_Basis__c,RE_Product_Codes__c,RE_Depot_Code__c ,
                                         RE_CND_Special_Adjustment__c,RE_Comments__c,RE_CND_Rack_Basis_Differential__c,RE_Product_Name__r.RE_Product_Classification_L0__c,
                                         //RE_CND_Parent_Rack__c,RE_CND_Parent_Rack_Group__c,
                                         RE_CND_Supplier1_Price__c,RE_CND_Supplier2_Price__c,RE_CND_Supplier3_Price__c,RE_CND_Supplier4_Price__c,
                                         RE_Status__c ,RE_CND_Is_Base_Product__c,RE_CND_Group__c,RE_CND_Location_Abbreviated_Name__c,RE_CND_Product_Name__c,
                                         RE_CND_Is_only_applicable_to_SFJ__c
                                         FROM RE_MY_CostPrice__c WHERE RE_CND_Effective_From_Date__c <= :datefilter 
                                         AND RE_CND_Effective_To_Date__c >= :datefilter AND  RecordTypeId=:costPriceRecordTypeId AND RE_IsLatest__c=TRUE])
            {
                CostPriceWrapper cpw = new CostPriceWrapper();
                generateSFJ=true;
                cpw.cpRecord=cp;
                cpw.pbRecord=null;
                cpw.status=approveStatus.get(cp.RE_Status__c);
                cpw.groupName=cp.RE_CND_Group__c;
                cpw.isLatest=cp.RE_IsLatest__c;
                if(cp.RE_CND_Is_Base_Product__c==false)
                {
                    cpw.isBase='N';
                }
                else
                {
                    cpw.isBase='Y'; 
                    // system.debug('Base record--'+cp);
                }
                
                if(cp.RE_CND_Is_only_applicable_to_SFJ__c == false)
                    cpw.isOnlySFJ='N';
                else
                    cpw.isOnlySFJ='Y'; 
                
                //System.debug('cpw--'+cpw);
                if(cp.RE_IsLatest__c)
                {
                    if(baseDerivativeMap.containsKey(cp.RE_CND_Pricing_Basis__c))
                    {
                        List<Integer> indexList=baseDerivativeMap.get(cp.RE_CND_Pricing_Basis__c);
                        indexList.add(i);
                        i++;
                    }
                    else
                    {
                        List<Integer> indexList= new List<Integer> ();
                        indexList.add(i);
                        i++;
                        baseDerivativeMap.put(cp.RE_CND_Pricing_Basis__c, indexList);
                    }
                    cplist.add(cpw); 
                }
                
            }
            
            for(RT_Price_Book__c pb : [SELECT id,RE_CND_Rack__c, RE_CND_Product_Group__c,RE_CND_Adjustment_Value__c,RE_CND_Customer_Name__r.AccountNumber ,RT_Product__c,
                                       RE_CND_Customer_Name__c,RE_CND_Net_Move_Value__c,RE_Initial_Version__c,RT_Sold_to_Name__c,RE_Final_Price_Unit__c,RE_Fx_Rate__c,
                                       RE_CND_Old_Base_Value__c, RE_CND_New_Base_Value__c,RE_CND_Market_Move__c,RE_Submitter_Comments__c,RE_CND_Final_Value__c, 
                                       RE_CND_Effective_From_Date__c,RE_CND_Effective_To_Date__c,RE_CND_Pricing_Basis__c,RT_Product_Code__c,RT_Location_Code__c,
                                       RE_Is_Latest__c,RE_Pricing_Date__c,RE_Custom_Opp_Approve__c, RE_CND_Product_Name__c,RE_CND_Customer_Name__r.Name,RT_Product__r.RE_Product_Classification_L0__c,
                                       RE_CND_ShipTo_Number__c
                                       FROM RT_Price_Book__c WHERE  RE_CND_Effective_From_Date__c <= :datefilter 
                                       AND RE_CND_Effective_To_Date__c >= :datefilter AND  RecordTypeId=:pricebookRecordTypeId AND RE_Is_Latest__c=TRUE])
            {
                CostPriceWrapper cpw = new CostPriceWrapper();
                // System.debug('pb--'+pb);
                cpw.pbRecord=pb;
                cpw.cpRecord=null;
                cpw.status=approveStatus.get(pb.RE_Custom_Opp_Approve__c);
                cpw.isBase='N';
                cpw.groupName='SFJ';
                cpw.isLatest=pb.RE_Is_Latest__c;
                
                if(pb.RE_Is_Latest__c)
                {cplist.add(cpw);
                 if(baseDerivativeMap.containsKey(pb.RE_CND_Pricing_Basis__c))
                 {
                     List<Integer> indexList=baseDerivativeMap.get(pb.RE_CND_Pricing_Basis__c);
                     indexList.add(i);
                     i++;
                 }
                 else
                 {
                     List<Integer> indexList= new List<Integer> ();
                     indexList.add(i);
                     i++;
                     baseDerivativeMap.put(pb.RE_CND_Pricing_Basis__c, indexList);
                 }
                }
            }
            adw.generateSFJ=generateSFJ;
            adw.cppbRecords	=  	cplist;
            adw.baseMap		=	baseDerivativeMap;
            adw.opisReportID=	opisReport;
            adw.GSAPProcessingStatus = getGSAPJobStatus();
            
        }
        catch(Exception ex)
        {
            System.debug('GET CANADA PRICING DATA-ex--'+ex.getLineNumber()+'-'+ex.getCause()+'-'+ex.getStackTraceString()+'--'+ex.getMessage());
            RV_ClassException.insertExceptionRecord('GET CANADA PRICING DATA',ex.getMessage()+ex.getLineNumber(),'RE_CND_RackDetail_Controller','getAllData','Exception');
        }
        
        return adw;
    }
    /****************************************************************************************************************
Class Name:  PicklistWrapper
Description:  Wrapper class for picklist
****************************************************************************************************************/     
    public class CostPriceWrapper
    {
        @AuraEnabled public RE_MY_CostPrice__c cpRecord;
        @AuraEnabled public RT_Price_Book__c pbRecord;
        @AuraEnabled public String groupName;
        @AuraEnabled public String status;
        @AuraEnabled public String isBase;
        @AuraEnabled public Boolean isLatest; 
        @AuraEnabled public String isOnlySFJ;
    }
    public class saveReturnWrapper
    {
        @AuraEnabled public Boolean isSuccess; 
        @AuraEnabled public String saveMessage;
        @AuraEnabled public String saveStatus;
    }
    
    public class AllDataWrapper
    {
        @AuraEnabled public List<CostPriceWrapper> cppbRecords;
        @AuraEnabled public Map<String,List<Integer>> baseMap;
        @AuraEnabled public RE_Record_Id_Mappings__c opisReportID;
        @AuraEnabled public String GSAPProcessingStatus;
        @AuraEnabled public Boolean hasFutureRecord;
        @AuraEnabled public Boolean generateSFJ;
    }
    
    public class PicklistWrapper
    {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
    public class VersionWrapper
    {
        @AuraEnabled public Id versionId;
        @AuraEnabled public Datetime  pricingDate;
        @AuraEnabled public Decimal finalValue;
        @AuraEnabled public Decimal adjustValue;
        @AuraEnabled public String status;
        @AuraEnabled public String comment;
    }
    
    public class CanadaRackWrapper
    {
        @AuraEnabled public Boolean PricingAccess;
        @AuraEnabled public Boolean GSAPAccess;
        @AuraEnabled public List<String> racklist;
        @AuraEnabled public List<String> prodGroupList;
        @AuraEnabled public List<String> locList;
        @AuraEnabled public List<String> prodList;
        @AuraEnabled public List<String> gasolineList;
        @AuraEnabled public List<String> dieselList;
        @AuraEnabled public String GSAPProcessingStatus;
    }
    public class GSAPWrapper
    {
        @AuraEnabled public Boolean 	isProcessing;
        @AuraEnabled public Decimal  totalUploaded;
        @AuraEnabled public Decimal  numberProcessed;
        @AuraEnabled public String  GSAPProcessingStatus;        
    }
    public class saveWrapper
    {
        @AuraEnabled public Id recordId;
        @AuraEnabled public Decimal  Adjustment;
        @AuraEnabled public Decimal finalValue;
        @AuraEnabled public String Comment; 
        @AuraEnabled public String  custType;
    }
    
    public class prcngDiffClass
    {       
        @AuraEnabled         
        public String rack {get;set;} 
        @AuraEnabled         
        public String grpclassifictn {get;set;}   
        @AuraEnabled         
        public Decimal caPrice {get;set;} 
        @AuraEnabled         
        public Decimal pePrice {get;set;} 
        @AuraEnabled         
        public Decimal capaDiff {get;set;}         
    }
    
    public class prcngDiffWrappr
    {
        @AuraEnabled 
        public List<prcngDiffClass> prcngDiffLst  {get;set;}
        @AuraEnabled 
        public Boolean isPrceDiscrepancyExists {get;set;}
    }    
    
    public class sapDowldWrappr
    {
        @AuraEnabled
        public List<Fixed_Price_Staging_Table__c> unbrandedLst;
        @AuraEnabled
        public List<Fixed_Price_Staging_Table__c> brandedLst;
        @AuraEnabled
        public List<Fixed_Price_Staging_Table__c> sfjLst;        
    }
    
}