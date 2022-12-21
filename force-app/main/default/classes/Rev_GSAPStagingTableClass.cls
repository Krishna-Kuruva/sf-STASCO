public class Rev_GSAPStagingTableClass {
    
    public static void onafterInsert(List<Fixed_Price_Staging_Table__c> newLst){
        System.debug('onafterInsert --');
        List<String> gsapStagingTableLst = new List<String>();
        for(Fixed_Price_Staging_Table__c gsapStaging : newLst){
            gsapStagingTableLst.add(gsapStaging.Id);
        }
        CreateFixPricingGSAPInterface(gsapStagingTableLst);
    }
    
    // @future (callout=true)
    public static void CreateFixPricingGSAPInterface(List<String> gsapStagingTableLst){

        List<Revolution_Deal_GSAP_Config__mdt> revDealGSAPLst = [Select Id,MasterLabel,DeveloperName,
                                                                 Client_Id__c,Client_Secret__c,
                                                                 Content_Type__c,Endpoint__c,Method__c from 
                                                                 Revolution_Deal_GSAP_Config__mdt ];
        
        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap = new Map<String,Revolution_Deal_GSAP_Config__mdt>();
        System.debug('revDealGSAPLst--'+revDealGSAPLst);
        for(Revolution_Deal_GSAP_Config__mdt revDealGSAPConfig : revDealGSAPLst){
            revDealGSAPMap.put(revDealGSAPConfig.MasterLabel,revDealGSAPConfig);
        }
        String access_Token = RV_DealGSAPMulesoft.basicAuthCallout(revDealGSAPMap);
        System.debug('access Token--'+access_Token);
        Rev_FixPricingGSAPInterface.callGSAPforFixPricing (access_Token,gsapStagingTableLst,revDealGSAPMap);
    }    
    
    public static void onafterUpdate(List<Fixed_Price_Staging_Table__c> newLst){

        Boolean uploadAllowed=true;
        Map<Id,RT_Price_Book__c> pblist = new Map<Id,RT_Price_Book__c>();
        Map<Id,RE_MY_CostPrice__c> cplist = new Map<Id,RE_MY_CostPrice__c>();
        
        Map<Id,Fixed_Price_Staging_Table__c> failedpblist = new Map<Id,Fixed_Price_Staging_Table__c>();
        Map<Id,Fixed_Price_Staging_Table__c> failedcplist = new Map<Id,Fixed_Price_Staging_Table__c>();
        
        for(Fixed_Price_Staging_Table__c fpsdata : newLst){
            system.debug('fpsdata---'+fpsdata);
            if(fpsdata.RE_Country_Name__c=='CA')
            {
                if(RE_GSAP_Upload__c.getValues('Canada') != null)
                {
                    uploadAllowed= RE_GSAP_Upload__c.getValues('Canada').RE_GSAP_Upload__c;
                }
            }
            
            if(fpsdata.REV_Price_Book__c != null )
            {
                System.debug('Pricebook--'+fpsdata.REV_Price_Book__c );
                RT_Price_Book__c pbdata = new RT_Price_Book__c();
                pbdata.Id =  fpsdata.REV_Price_Book__c;
                if(fpsdata.RE_Is_latest__c && fpsdata.RE_Status__c != null && fpsdata.RE_condRecordnumber__c != 'NotCreated' && fpsdata.RE_condRecordnumber__c != null &&
                   !failedpblist.containsKey(fpsdata.REV_Price_Book__c))
                {
                    System.debug('fps Status -- Uploaded');
                    pbdata.RE_Custom_Opp_Approve__c = 'Uploaded';
                    if(!pblist.containskey(pbdata.Id))
                        pblist.put(pbdata.Id,pbdata);
                }
                else if(fpsdata.RE_Is_latest__c && uploadAllowed )
                {
                    System.debug('fps Status -- Failed');
                    pbdata.RE_Custom_Opp_Approve__c = 'Failed';
                    pblist.put(pbdata.Id,pbdata);
                    if(!failedpblist.containskey(fpsdata.REV_Price_Book__c))
                        failedpblist.put(fpsdata.REV_Price_Book__c,fpsdata);
                } 
            }
            if(fpsdata.RE_Cost_Price__c != null )
            {
                System.debug('Cost Price--'+fpsdata.RE_Cost_Price__c );
                RE_MY_CostPrice__c cpdata = new RE_MY_CostPrice__c();
                cpdata.Id =  fpsdata.RE_Cost_Price__c;
                if(fpsdata.RE_Status__c != null && fpsdata.RE_condRecordnumber__c != 'NotCreated' && fpsdata.RE_condRecordnumber__c != null &&
                   !failedcplist.containsKey(fpsdata.RE_Cost_Price__c))
                {
                    System.debug('fps Status -- Uploaded');
                    cpdata.RE_Status__c = 'Uploaded';
                    if(!cplist.containskey(cpdata.Id))
                        cplist.put(cpdata.Id,cpdata);
                }
                else if(fpsdata.RE_Is_latest__c && uploadAllowed )
                {
                    System.debug('fps Status -- Failed');
                    cpdata.RE_Status__c = 'Failed';
                    cplist.put(cpdata.Id,cpdata);
                    if(!failedcplist.containskey(fpsdata.RE_Cost_Price__c))
                        failedcplist.put(fpsdata.RE_Cost_Price__c,fpsdata);
                } 
            }
            
        }
        List<sObject> objects = new List<sObject>();
        if(!cplist.isEmpty())
        {
            System.debug('cplist--'+cplist.values());
            objects.addAll((List<RE_MY_CostPrice__c>)(cplist.values()));  
        }
        if(!pblist.isEmpty())
        {
            System.debug('pblist--'+pblist.values());
            objects.addAll((List<RT_Price_Book__c>)(pblist.values()));  
        }
        
        if(!objects.isEmpty()){
            try
            { update objects;
            System.debug('UPdated--cpList--'+cplist.values());
            System.debug('UPdated--pblist--'+pblist.values());
            }
            Catch(Exception e) { System.debug('Failed to update RT_Price_Book__c '+e.getMessage());}
        }        
    }
    
}