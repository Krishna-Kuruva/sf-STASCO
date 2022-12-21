public class Rev_FixPricingGSAPInterface { 
    
    public static void callGSAPforFixPricing(String access_Token,List<String> gsapstagingStrngList,Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap)
    {

        List<Fixed_Price_Staging_Table__c>  gsapStagingTableLst = [SELECT Id, OwnerId,RE_Error__c, IsDeleted, Name, CreatedDate, 
                                                               CreatedById, LastModifiedDate, LastModifiedById, 
                                                               SystemModstamp, RE_Application__c, RE_Calculation_type__c,
                                                               RE_Cond_Usage_Table__c, RE_Cond_table_no__c, RE_Currency_Unit__c,
                                                               RE_Quantity__c, RE_Report_Type__c, RE_Scale_Type__c, RE_Sequence_No__c,
                                                               RE_Status__c, RE_Uom__c, RE_Valid_End_date__c, RE_Valid_start_date__c,
                                                               RE_Value__c, RE_Varkey__c, RE_IdnForFix__c, RE_condRecordnumber__c,
                                                               RE_Change__c, RE_ScaleAmount__c, RE_ScaleQuantity__c, RE_ScaleUOM__c,
                                                               RE_ScaleDate__c, RE_ScaleTime__c, RE_Material_Description__c
                                                               FROM Fixed_Price_Staging_Table__c where 
                                                               Id in:gsapstagingStrngList order by RE_Sequence_No__c];
       if(revDealGSAPMap.containskey('CreateFixPrice')){
            Revolution_Deal_GSAP_Config__mdt createDeal = revDealGSAPMap.get('CreateFixPrice');
                HttpRequest req = new HttpRequest();
                req.setMethod(createDeal.Method__c);
                req.setEndpoint(createDeal.Endpoint__c);
                req.setHeader('Content-Type',createDeal.Content_Type__c);
                req.setHeader('Authorization', 'Bearer ' +access_Token);
                req.setBody(createJSOnStringDeal(gsapStagingTableLst));
            	req.setTimeout(120000);
                Http binding = new Http();
                HttpResponse res = binding.send(req);
                System.debug('-------------'+res.getBody());
            	System.debug('-------------'+res.getStatusCode());
                if (res.getStatusCode() == 201) {
                    List<Rev_FixPricingInterfaceWrapper> deserializeWrapper =(List<Rev_FixPricingInterfaceWrapper>)JSON.deserialize(res.getBody(), List<Rev_FixPricingInterfaceWrapper>.class);
                    System.debug('-------deserializeWrapper-------'+deserializeWrapper);
                    if(deserializeWrapper.size()>0){
                    	updateGSAPStaging(gsapStagingTableLst,deserializeWrapper);
                    }
                }else{
                    if(res.getStatusCode() == 504){
                        System.debug('-------------'+res.getBody());
                        callGSAPforFixPricing(access_Token,gsapstagingStrngList,revDealGSAPMap);
                    }else{
                        system.debug('---Response--'+res.getBody());
                        Rev_FixPricingInterfaceWrapper.exceptionClass deserializeWrapperexception =(Rev_FixPricingInterfaceWrapper.exceptionClass)JSON.deserialize(res.getBody(), Rev_FixPricingInterfaceWrapper.exceptionClass.class);
                        System.debug('------deserializeWrapper------'+deserializeWrapperexception);
                        updateerrorMessage(gsapStagingTableLst,deserializeWrapperexception);
                    }
                   // createDealinGSAP(access_Token,fetchsapStagingLst,revDealGSAPMap);
                }
        }

    }
    
    public static String createJSOnStringDeal(List<Fixed_Price_Staging_Table__c> fetchsapStagingLst){
        Map<String,List<Rev_FixPricingInterfaceWrapper>> fixPricingIntrfcMap = new Map<String,List<Rev_FixPricingInterfaceWrapper>>();
        Map<String,List<Fixed_Price_Staging_Table__c>> fixPricingGSPMap = new Map<String,List<Fixed_Price_Staging_Table__c>>();
         
         for(Fixed_Price_Staging_Table__c gsapStagingTable : fetchsapStagingLst){           
             
             if(!fixPricingIntrfcMap.containsKey(String.valueof(gsapStagingTable.RE_Sequence_No__c))){
                 fixPricingGSPMap.put(String.valueof(gsapStagingTable.RE_Sequence_No__c),new List<Fixed_Price_Staging_Table__c> {gsapStagingTable});
                 System.debug('-----fixPricingIntrfcMap---------'+fixPricingIntrfcMap);
             }else{
                 
                 List<Fixed_Price_Staging_Table__c> fixGSPprcLst = fixPricingGSPMap.get(String.valueof(gsapStagingTable.RE_Sequence_No__c));
                 fixGSPprcLst.add(gsapStagingTable);
                 fixPricingGSPMap.put(String.valueof(gsapStagingTable.RE_Sequence_No__c),fixGSPprcLst);
                 System.debug('-----fixPricingGSPMap---------'+fixPricingGSPMap.values().size());
             }

         }
        System.debug('--------fixPricingGSPMap keyset---------'+fixPricingGSPMap.keyset());
        System.debug('--------fixPricingGSPMap values---------'+fixPricingGSPMap.values().size());
        
        List<Rev_FixPricingInterfaceWrapper> fixPricingWrapper = new List<Rev_FixPricingInterfaceWrapper>();
          for(String gsapHeaderVal : fixPricingGSPMap.keyset()){
              
              System.debug('----------gsapHeader----------'+gsapHeaderVal);
              if(fixPricingGSPMap.containskey(String.valueof(gsapHeaderVal))){
                  List<Fixed_Price_Staging_Table__c> fixprcList = fixPricingGSPMap.get(gsapHeaderVal);
                  Fixed_Price_Staging_Table__c gsapHeader = fixprcList.get(0);
                  Rev_FixPricingInterfaceWrapper revFixPricing = new Rev_FixPricingInterfaceWrapper();
                     /*if(gsapStagingTable.RE_IdnForFix__c == null)
                         revFixPricing.IdnForFix = '';
                     else*/
                         revFixPricing.IdnForFix = 'Fix';
                     if(gsapHeader.RE_Status__c == null)
                        revFixPricing.Status = '';
                     else
                        revFixPricing.Status = gsapHeader.RE_Status__c;
                     if(gsapHeader.RE_condRecordnumber__c == null)
                        revFixPricing.condRecordnumber = '';
                     else
                        revFixPricing.condRecordnumber = gsapHeader.RE_condRecordnumber__c;
                     revFixPricing.SeqNo = String.valueof(gsapHeader.RE_Sequence_No__c);
                     revFixPricing.CondUsageTable = gsapHeader.RE_Cond_Usage_Table__c;
                     revFixPricing.Condtableno = gsapHeader.RE_Cond_table_no__c;
                     revFixPricing.Application = gsapHeader.RE_Application__c;
                     revFixPricing.CondType = gsapHeader.RE_Report_Type__c;
                     revFixPricing.Varkey = gsapHeader.RE_Varkey__c;
                     
                     revFixPricing.StartDate = gsapHeader.RE_Valid_start_date__c;
                     revFixPricing.EndDate = gsapHeader.RE_Valid_End_date__c;
                     revFixPricing.ScaleType = gsapHeader.RE_Scale_Type__c;
                     revFixPricing.Calculationtype = gsapHeader.RE_Calculation_type__c;
                     
                     revFixPricing.PriceVal = gsapHeader.RE_Value__c;
                     revFixPricing.RateUnit = gsapHeader.RE_Currency_Unit__c;
                     revFixPricing.Uom = gsapHeader.RE_Uom__c;
                     revFixPricing.Quantity = gsapHeader.RE_Quantity__c;
                     if(gsapHeader.RE_Material_Description__c == null)
                        revFixPricing.MaterialDesc = '';
                     else
                         revFixPricing.MaterialDesc = gsapHeader.RE_Material_Description__c;
                     if(gsapHeader.RE_Change__c == null)
                        revFixPricing.Change = '';
                     else
                         revFixPricing.Change = gsapHeader.RE_Change__c;             
            
                  List<Rev_FixPricingInterfaceWrapper.ScaleValues> ScaleValues = new List<Rev_FixPricingInterfaceWrapper.ScaleValues>();

                  for(Fixed_Price_Staging_Table__c gsapStagingTable : fixprcList){
                      
                      Rev_FixPricingInterfaceWrapper.ScaleValues scaleValue = new Rev_FixPricingInterfaceWrapper.ScaleValues();
             		  scaleValue.SeqNo = String.valueof(gsapStagingTable.RE_Sequence_No__c);
                      scaleValue.IdnForFix = 'Fix';
                      if(gsapStagingTable.RE_ScaleAmount__c == null)
                          scaleValue.ScaleAmount = '';
                      else
                          scaleValue.ScaleAmount = gsapStagingTable.RE_ScaleAmount__c;
                      if(gsapStagingTable.RE_ScaleQuantity__c == null)
                          scaleValue.ScaleQuantity = '';
                      else
                          scaleValue.ScaleQuantity = gsapStagingTable.RE_ScaleQuantity__c;
                      if(gsapStagingTable.RE_Uom__c == null)
                          scaleValue.ScaleUOM = '';
                      else
                          scaleValue.ScaleUOM = gsapStagingTable.RE_Uom__c;
                      if(gsapStagingTable.RE_ScaleDate__c == null)
                      	scaleValue.ScaleDate = '';
                      else
                          scaleValue.ScaleDate = gsapStagingTable.RE_ScaleDate__c;
                      if(gsapStagingTable.RE_ScaleTime__c == null)
                          scaleValue.ScaleTime = '';
                      else
                          scaleValue.ScaleTime = gsapStagingTable.RE_ScaleTime__c;
                      ScaleValues.add(scaleValue);
                      System.debug('---------ScaleValues-----------'+ScaleValues);
                  }
                  revFixPricing.ScaleValues.addAll(ScaleValues);
                  System.debug('---------revFixPricing-----------'+revFixPricing);
                  fixPricingWrapper.add(revFixPricing);     
              }
				        
          }
         System.debug('------------------------'+JSON.serializePretty(fixPricingWrapper));

        return JSON.serializePretty(fixPricingWrapper);
     }
    
    public static void updateGSAPStaging(List<Fixed_Price_Staging_Table__c>  gsapStagingTableLst,List<Rev_FixPricingInterfaceWrapper> deserializeWrapper)
    {

            Map<String,Rev_FixPricingInterfaceWrapper> fixPrcMap = new Map<String,Rev_FixPricingInterfaceWrapper>();
                                            
            if(deserializeWrapper.size()>0){
                for(Rev_FixPricingInterfaceWrapper fixPrc :  deserializeWrapper){
                    /*if(!fixPrcMap.containskey(fixPrc.SeqNo)){
                        fixPrcMap.put(fixPrc.SeqNo,new List<Rev_FixPricingInterfaceWrapper> {fixPrc});
                    }else{
                        List<Rev_FixPricingInterfaceWrapper> fixPrcLst = fixPrcMap.get(fixPrc.SeqNo);
                        fixPrcMap.put(fixPrc.SeqNo,fixPrcLst);
                    }*/
                    fixPrcMap.put(fixPrc.SeqNo,fixPrc);
                }                                 
            } 
            
                                            
            List<Fixed_Price_Staging_Table__c> gsapStagingLst = new List<Fixed_Price_Staging_Table__c>();
            for(Fixed_Price_Staging_Table__c sapStaging : gsapStagingTableLst){
                if(fixPrcMap.containskey(String.valueof(sapStaging.RE_Sequence_No__c))){
                     sapStaging.RE_Status__c = fixPrcMap.get(String.valueof(sapStaging.RE_Sequence_No__c)).Status;
                     sapStaging.RE_condRecordnumber__c = fixPrcMap.get(String.valueof(sapStaging.RE_Sequence_No__c)).condRecordnumber;
                    gsapStagingLst.add(sapStaging);
                }
                
                
            }
            if(!gsapStagingLst.isEmpty()){
                try{
                    update gsapStagingLst;
                }catch(Exception de){
                    System.debug('----------de--------'+de);
                }              
            }   

    }
    
    public static void updateerrorMessage(List<Fixed_Price_Staging_Table__c>  fetchsapStagingLst,
                                        Rev_FixPricingInterfaceWrapper.exceptionClass deserializeWrapperException){
            List<Fixed_Price_Staging_Table__c> sapStagingLst = new List<Fixed_Price_Staging_Table__c>();
            Map<String,Fixed_Price_Staging_Table__c> shtNumberMap = new Map<String,Fixed_Price_Staging_Table__c>();                                
            for(Fixed_Price_Staging_Table__c sapStaging : fetchsapStagingLst){
                sapStaging.RE_Error__c = deserializeWrapperException.errorMessage;
                sapStagingLst.add(sapStaging);
                //shtNumberMap.put(sapStaging.SfItemShtNo__c,sapStaging);
            }                                   
           
                                            
            if(!sapStagingLst.isEmpty()){
                try{
                    update sapStagingLst;
                }catch(Exception de){
                    System.debug('----------de--------'+de);
                }                     
            }  

    }
}