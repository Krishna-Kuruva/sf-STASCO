@RestResource(urlMapping='/createDeal/*')
global class OLF_CreateDeal {
    @HttpPost 
    global static void createOlfDeals(){ 
        RestRequest req = RestContext.request;
        if(OLF_Utility.connectionAllowed()){	//292153_OLFConnectionTime_11Jul2019_Soumyajit
            Map<String, String> headerMap=req.headers;
            OLF_Utility.auditOlfApiLogin(headerMap,'createDeal',system.now());
            Blob body = req.requestBody;
            String requestString = body.toString();
            List<OLFWrapper.MrcPriceWrap> mrcWrpLst=new List<OLFWrapper.MrcPriceWrap>();
            mrcWrpLst=(List<OLFWrapper.MrcPriceWrap>)JSON.deserialize(requestString,List<OLFWrapper.MrcPriceWrap>.class);
            string dealCreationResult=insertOlfDealInSht(mrcWrpLst);
            system.debug('dealCreationResult.message==>'+dealCreationResult);
            //Return Response
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(dealCreationResult); 
            
        //292153_OLFConnectionTime_11Jul2019_Soumyajit starts
        }
        else
        {
            System.debug('Connection Not Allowed');
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(OLF_Utility.connectionErrMsg));
            RestContext.response.statusCode = 500;
        }
        //292153_OLFConnectionTime_11Jul2019_Soumyajit ends
    }
    public static string insertOlfDealInSht(List<OLFWrapper.MrcPriceWrap> olfDealWrap){ 
        //Set<String> mrcNumSet= new Set<String>();
        //string contractStartDat;
        //string contractEndDate;
        String contactEmail;
        List<OLFWrapper.MrcPriceWrap> olfResponse;
        Set<String> mrcNumSet = new Set<String>(); 
        Map<String, Set<String>> startDateVsMrcNoSetMap = new Map<String, Set<String>>();
        Map<String, List<OLFWrapper.MrcPriceWrap>> startDateVsDealWrapLstMap = new Map<String, List<OLFWrapper.MrcPriceWrap>>();
        for(OLFWrapper.MrcPriceWrap mpw:olfDealWrap){
            mrcNumSet.add(mpw.MRCNumber);
            if(!startDateVsDealWrapLstMap.isEmpty() && startDateVsDealWrapLstMap.containsKey(mpw.StartDate)){
                List<OLFWrapper.MrcPriceWrap> mrcPriceWrapList = startDateVsDealWrapLstMap.get(mpw.StartDate);
                mrcPriceWrapList.add(mpw);
                startDateVsDealWrapLstMap.put(mpw.StartDate, mrcPriceWrapList);
            }
            else{
                startDateVsDealWrapLstMap.put(mpw.StartDate, new List<OLFWrapper.MrcPriceWrap>{mpw});
            }
            if(!startDateVsMrcNoSetMap.isEmpty() && startDateVsMrcNoSetMap.containsKey(mpw.StartDate)){
                Set<String> mrcNoSet = startDateVsMrcNoSetMap.get(mpw.StartDate);
                mrcNoSet.add(mpw.MRCNumber);
                startDateVsMrcNoSetMap.put(mpw.StartDate, mrcNoSet);
            }
            else{
                startDateVsMrcNoSetMap.put(mpw.StartDate, new Set<String>{mpw.MRCNumber});
            }
            //contractStartDat=mpw.StartDate;
            //contractEndDate=mpw.EndDate;
            contactEmail=mpw.contactEmail;
        }
        //String dealCreationResult;
        if(!startDateVsDealWrapLstMap.isEmpty() && !startDateVsMrcNoSetMap.isEmpty())
            olfResponse = getPrice(startDateVsDealWrapLstMap, startDateVsMrcNoSetMap, mrcNumSet, contactEmail);         
        /*if(mrcNumSet.size()>0){
            olfResponse=getPrice(olfDealWrap,mrcNumSet,contractStartDat,contractEndDate,contactEmail);         
        }*/
        return JSON.serialize(olfResponse);
    }

    //public static List<OLFWrapper.MrcPriceWrap> getPrice(List<OLFWrapper.MrcPriceWrap> olfDealToBeCreated,Set<String> mrcNoSet,string contractStartDate,string contractEndDate,String contactEmail){
    public static List<OLFWrapper.MrcPriceWrap> getPrice(Map<String, List<OLFWrapper.MrcPriceWrap>> startDateVsDealWrapLstMap, Map<String, Set<String>> startDateVsMrcNoSetMap, Set<String> mrcNoSet, String contactEmail){
        //String tranche;
        //RV_SPCalculationController.salesPriceCalAndAuditWrap salesPrcWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        Map<String, String> startDateVsTrancheMap = new Map<String, String>();
        //List<RV_SPCalculationController.salesPriceWrap> toBeInsertedDealSpWrp = new List<RV_SPCalculationController.salesPriceWrap>();
        Map<String, List<RV_SPCalculationController.salesPriceWrap>> startDateVsDealWrpMap = new Map<String, List<RV_SPCalculationController.salesPriceWrap>>();
        List<RV_SPCalculationController.priceAuditWrap> salesPriceAuditInsertLst= new List<RV_SPCalculationController.priceAuditWrap>();
        Map<String, List<RV_SPCalculationController.priceAuditWrap>> startDateVsPriceAuditMap= new Map<String, List<RV_SPCalculationController.priceAuditWrap>>();
        List<Sht__c> shtLst = new List<Sht__c>();
        List<Mrc__c> mrcLst= new List<Mrc__c>();
        List<Date> startDateList;
        Map<String, List<MRC__c>> startDateVsMrcLstMap = new Map<String, List<MRC__c>>(); 
        Map<String,Mrc__c> mrcNoPoTypHandTypMap= new Map<String,Mrc__c>();
        Map<String,RV_SPCalculationController.salesPriceWrap> mrcNoRecentCalculatedSpMap = new Map<String,RV_SPCalculationController.salesPriceWrap>();
        Set<String> plantCodeSet= new Set<String>();
        List<Product_Name_Mapping__mdt> pdtNameMapLst=[Select Id,Product_Name__c,MasterLabel from Product_Name_Mapping__mdt];
        Map<String,String> gradeMap= new Map<String,String>();
        List<OLFWrapper.MrcPriceWrap> mrcPriceWrapList = new List<OLFWrapper.MrcPriceWrap>();
        for(Product_Name_Mapping__mdt pnm :pdtNameMapLst){
            gradeMap.put(pnm.MasterLabel,pnm.Product_Name__c);
        }
        if(mrcNoSet.size()>0){
            mrcLst=getMrcRecords(mrcNoSet);
        }
        Id accountId;
        Map<String,String> mrcPlantGrdMap= new Map<String,String>();
        String olfContactName;
        RV_SPCalculationController.isOlfDeal = true;
        if(mrcLst.size()>0){
            startDateList = new List<Date>();
            for(Mrc__c mr : mrcLst){
                mrcPlantGrdMap.put(mr.name,mr.Plant_Code__c+gradeMap.get(mr.Material_Description__c));
                mrcNoPoTypHandTypMap.put(mr.Name,mr);
                accountId=mr.Sold_To__c;
                plantCodeSet.add(mr.Plant_Code__c);
                for(String startDate : startDateVsMrcNoSetMap.keySet()){
                    startDateList.add(Date.valueOf(startDate));
                    Set<String> mrcNumSet = startDateVsMrcNoSetMap.get(startDate);
                    if(mrcNumSet.contains(mr.Name)){
                        if(!startDateVsMrcLstMap.isEmpty() && startDateVsMrcLstMap.containsKey(startDate)){
                            List<MRC__c> mrcList = startDateVsMrcLstMap.get(startDate);
                            mrcList.add(mr);
                            startDateVsMrcLstMap.put(startDate, mrcList);
                        }
                        else{
                            startDateVsMrcLstMap.put(startDate, new List<MRC__c>{mr});
                        }
                    }
                }
            }
            startDateVsTrancheMap = OLF_Utility.getOnilineTranche(startDateList);
            for(String startDate : startDateVsDealWrapLstMap.keySet()){
                String tranche = startDateVsTrancheMap.get(startDate);
                if(tranche == 'ATP4'){
                    tranche = 'ATP3';
                    startDateVsTrancheMap.put(startDate, tranche);
                }
                RV_SPCalculationController.tranche = tranche;
                RV_SPCalculationController.salesPriceCalAndAuditWrap salesPrcWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
                String endDate = startDateVsDealWrapLstMap.get(startDate)[0].EndDate;
                List<MRC__c> mrcList = startDateVsMrcLstMap.get(startDate);
                salesPrcWrp = RV_SPCalculationController.getCalulatedSp(mrcList, Date.valueOf(startDate), Date.valueOf(endDate)); 
                startDateVsDealWrpMap.put(startDate, salesPrcWrp.salesPriceWrpLst);
                startDateVsPriceAuditMap.put(startDate, salesPrcWrp.auditWrpLst);
                //toBeInsertedDealSpWrp.addAll(salesPrcWrp.salesPriceWrpLst);
                //salesPriceAuditInsertLst.addAll(salesPrcWrp.auditWrpLst);
                //toBeInsertedDealSpWrp = salesPrcWrp.salesPriceWrpLst; 
                //salesPriceAuditInsertLst = salesPrcWrp.auditWrpLst; 
            }
        }
        List<Account> actLst=OLF_Utility.queryForCustomerDetail(contactEmail);
        //START | Rahul Sharma | Date - 18-Mar-2020 : Updated input paramenter to send ParentId of Sold-to account from Ship-to accounts
        //START | Rahul Sharma | Date - 06-Nov-2020 : Added tranche parameter to get tranche specific ATP.
        Map<String ,Decimal> atpLocMap = OLF_FetchMrcFinalPrice.getAtpforPlant(plantCodeSet, actLst[0].ParentId, new List<String>(new Set<String>(startDateVsTrancheMap.values()))); 
        //END | Rahul Sharma | Date - 06-Nov-2020 : Added tranche parameter to get tranche specific ATP.
        //END | Rahul Sharma | Date - 18-Mar-2020 : Updated input paramenter to send ParentId of Sold-to account from Ship-to accounts
        /*if(toBeInsertedDealSpWrp.size()>0){
            for(RV_SPCalculationController.salesPriceWrap spw :toBeInsertedDealSpWrp){
                mrcNoRecentCalculatedSpMap.put(spw.mrcNo + spw.tranche, spw);
            }
        }*/
        if(!startDateVsDealWrpMap.isEmpty()){
            for(String startDate : startDateVsDealWrpMap.keySet()){
                for(RV_SPCalculationController.salesPriceWrap spw : startDateVsDealWrpMap.get(startDate)){
                    mrcNoRecentCalculatedSpMap.put(spw.mrcNo + startDate, spw);
                }
            }
        }
        //Shipping Condition Map
        Map<Integer,String> ShipCondNoNameMap= new Map<Integer,String>();
        List<Shipping_Condition_Mapping__mdt> shipCdnMetDatLst= [Select id,Mot__c,Shipping_Condition__c
                                                                from Shipping_Condition_Mapping__mdt];
        for(Shipping_Condition_Mapping__mdt shp:shipCdnMetDatLst){
            ShipCondNoNameMap.put(Integer.valueOf(shp.Shipping_Condition__c),shp.Mot__c);
        }
        //Deal Event Manager metadata
        Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap=RV_SHT_CreateController.getDealEventMetdataMap(); 
        //Map<String,Integer> plantGradeVolumeInDealMap= new Map<String,Integer>();
        Map<String,String> plantIdCodeMap=new Map<String,String>();
        decimal volumeCheckforAllDeals= 0;
        decimal creditAvailable=0;
        decimal creditTobeDeducted=0;
        String volCheckPlantGrade=''; 
        //boolean deductCredit=false;
        Account acc=actLst[0];
        if(acc.Parent.Rv_Credit_Available__c != null){
            creditAvailable=acc.Parent.Rv_Credit_Available__c; 
        } 
        for(String startDate : startDateVsDealWrapLstMap.keySet()){
            Boolean deductCredit = false;
            String tranche = startDateVsTrancheMap.get(startDate);
            List<OLFWrapper.MrcPriceWrap> olfDealToBeCreated = startDateVsDealWrapLstMap.get(startDate);
            Map<String,Integer> plantGradeVolumeInDealMap= new Map<String,Integer>();
            for(OLFWrapper.MrcPriceWrap mpw : olfDealToBeCreated){
                if(contactEmail != null && contactEmail != '' 
                   && mpw.inputVolume != null && mpw.inputVolume != '' &&
                   mpw.PricePerUnit != null && mpw.PricePerUnit != ''){ 
                    Sht__c sh = new Sht__c();
                    Mrc__c mr= new Mrc__c();
                    mr=mrcNoPoTypHandTypMap.get(mpw.MRCNumber);
                    System.debug('Inside for '+mpw.inputVolume);
                    //Available Volume Check
                    if(Integer.valueOf(mpw.inputVolume) <= atpLocMap.get(mr.Plant_Code__c+mpw.grade+tranche)){
                        plantIdCodeMap.put(mr.Plant__c,mr.Plant_Code__c);
                        sh.MRC__c = mr.Id;
                        sh.MRC_Number__c = mpw.MRCNumber;
                        sh.Customer__c = mr.Sold_To__c;
                        sh.Tranche__c = tranche; //Rahul Sharma | Date - 06-Nov-2020 : Removed hardcoded ATP value.
                        if(mrcNoRecentCalculatedSpMap.containsKey(mpw.MRCNumber + startDate)){
                            sh.BSP__c=(mrcNoRecentCalculatedSpMap.get(mpw.MRCNumber + startDate)).BSP;
                            sh.MSP__c=(mrcNoRecentCalculatedSpMap.get(mpw.MRCNumber + startDate)).MSP;
                            sh.OTM__c=(mrcNoRecentCalculatedSpMap.get(mpw.MRCNumber + startDate)).OTM;
                        }
                        if(mpw.PricePerUnit!=null & mpw.PricePerUnit!='')
                            sh.SP_100L__c=Decimal.valueOf(mpw.PricePerUnit);
                        sh.Status__c='Completed';
                        sh.Sales_Type__c='Internet Sales';
                        sh.Product_Category__c=mpw.grade;
                        sh.Select__c=true;
                        sh.Contract_Start__c=Date.valueOf(mpw.StartDate);
                        sh.Contract_End_Date__c=Date.valueOf(mpw.EndDate);
                        if(mpw.inputVolume!=null & mpw.inputVolume!=''){
                            if(plantGradeVolumeInDealMap.containsKey(mr.Plant_Code__c + mpw.grade)){
                                Integer volumeInDeal = plantGradeVolumeInDealMap.get(mr.Plant_Code__c + mpw.grade) + Integer.valueOf(mpw.inputVolume);
                                if(volumeInDeal <= atpLocMap.get(mr.Plant_Code__c+mpw.grade+tranche)){
                                    sh.Volume_CBM__c = Decimal.valueOf(mpw.inputVolume);
                                    deductCredit = true;
                                }
                                else{
                                    deductCredit = false;
                                    volCheckPlantGrade = volCheckPlantGrade+mpw.Location+' and ' +mpw.MaterialName+' ;'; 
                                    volumeCheckforAllDeals++;
                                }
                                plantGradeVolumeInDealMap.put(mr.Plant_Code__c + mpw.grade, volumeInDeal);   
                            }
                            else{
                                sh.Volume_CBM__c=Decimal.valueOf(mpw.inputVolume);
                                deductCredit=true;
                                plantGradeVolumeInDealMap.put(mr.Plant_Code__c+mpw.grade,Integer.valueOf(mpw.inputVolume));
                            }  
                        }     
                        sh.isOlfDeal__c=true;
                        sh.Location__c=mr.Plant__c;
                        sh.Contact_Email__c=contactEmail;
                        sh.Contact_Name__c=olfContactName;
                        //Deal Event Manager Attributes for Pricing ,Vol deduction & Hedging
                        sh.Price_Condition__c='YP24';
                        sh.IsATPVolumeReduced__c=false;
                        sh.IsGsapDealCancelOn__c=false;
                        sh.IsGsapDealCreateOn__c=false;
                        sh.IsPricingTaxed__c=false;
                        sh.IsVolumeHedged__c=false;
                        sh.IsZeroPriceDeal__c=false;
                        
                        string key=mr.PO_Type__c + mr.Handling_Type__c;
                        String otherKey=mr.PO_Type__c + 'Others';
                        string finalKey; 
                        Deal_Event_Manager__mdt dealEvent;
                        if(poTypeHandlingDealMdtMap.containsKey(key)){
                            dealEvent = poTypeHandlingDealMdtMap.get(key);
                        }
                        else if(poTypeHandlingDealMdtMap.containsKey(otherKey)){
                            dealEvent=poTypeHandlingDealMdtMap.get(otherKey);
                        }
                        system.debug('dealEvent==>'+dealEvent);
                        if(dealEvent != null){
                            sh.IsPricingTaxed__c=dealEvent.IsPricingTaxed__c;
                            sh.Price_Condition__c=dealEvent.Pricing_Condition__c;
                            sh.IsATPVolumeReduced__c=dealEvent.IsATPVolumeReduced__c;
                            sh.IsVolumeHedged__c=dealEvent.IsVolumeHedged__c;
                            sh.IsZeroPriceDeal__c=dealEvent.IsZeroPriceDeal__c; 
                            if(dealEvent.Shipping_Condition__c.contains(ShipCondNoNameMap.get(Integer.valueOf(mr.Shipping_Condition__c)))){
                                sh.IsGsapDealCreateOn__c=dealEvent.IsGsapDealCreateOn__c;
                                sh.IsGsapDealCancelOn__c=dealEvent.IsGsapDealCancelOn__c;
                            }
                            //Retro Volume Deals not required here   
                        } 
                        if(poTypeHandlingDealMdtMap.containsKey(key)){
                            sh.Price_Condition__c=poTypeHandlingDealMdtMap.get(key).Pricing_Condition__c;
                            sh.IsATPVolumeReduced__c=poTypeHandlingDealMdtMap.get(key).IsATPVolumeReduced__c;
                            sh.IsGsapDealCancelOn__c=poTypeHandlingDealMdtMap.get(key).IsGsapDealCancelOn__c;
                            sh.IsGsapDealCreateOn__c=poTypeHandlingDealMdtMap.get(key).IsGsapDealCreateOn__c;
                            sh.IsPricingTaxed__c=poTypeHandlingDealMdtMap.get(key).IsPricingTaxed__c;
                            sh.IsVolumeHedged__c=poTypeHandlingDealMdtMap.get(key).IsVolumeHedged__c;
                            sh.IsPricingTaxed__c=poTypeHandlingDealMdtMap.get(key).IsPricingTaxed__c;
                            sh.IsZeroPriceDeal__c=poTypeHandlingDealMdtMap.get(key).IsZeroPriceDeal__c;
                        } 
                        else if(poTypeHandlingDealMdtMap.containsKey(otherKey)){
                            sh.Price_Condition__c=poTypeHandlingDealMdtMap.get(otherKey).Pricing_Condition__c;
                            sh.IsATPVolumeReduced__c=poTypeHandlingDealMdtMap.get(otherKey).IsATPVolumeReduced__c;
                            sh.IsGsapDealCancelOn__c=poTypeHandlingDealMdtMap.get(otherKey).IsGsapDealCancelOn__c;
                            sh.IsGsapDealCreateOn__c=poTypeHandlingDealMdtMap.get(otherKey).IsGsapDealCreateOn__c;
                            sh.IsPricingTaxed__c=poTypeHandlingDealMdtMap.get(otherKey).IsPricingTaxed__c;
                            sh.IsVolumeHedged__c=poTypeHandlingDealMdtMap.get(otherKey).IsVolumeHedged__c;
                            sh.IsPricingTaxed__c=poTypeHandlingDealMdtMap.get(otherKey).IsPricingTaxed__c;
                            sh.IsZeroPriceDeal__c=poTypeHandlingDealMdtMap.get(otherKey).IsZeroPriceDeal__c;
                        }
                        else{
                            sh.Price_Condition__c='YP24';
                            sh.IsATPVolumeReduced__c=false;
                            sh.IsGsapDealCancelOn__c=false;
                            sh.IsGsapDealCreateOn__c=false;
                            sh.IsPricingTaxed__c=false;
                            sh.IsVolumeHedged__c=false;
                            sh.IsPricingTaxed__c=false;
                            sh.IsZeroPriceDeal__c=false;
                        }
                        if(deductCredit){
                            creditTobeDeducted = creditTobeDeducted + (sh.SP_100L__c*sh.Volume_CBM__c*10);  
                        }
                        shtLst.add(sh);   
                    }
                    else{
                        volCheckPlantGrade=volCheckPlantGrade+mpw.Location+' and ' +mpw.MaterialName+' ;'; 
                        volumeCheckforAllDeals++; 
                    } 
                }   
            }
        }
        List<String> insertedIds=new List<String>();
        //Available Volume & Credit Check
        if(volumeCheckforAllDeals == 0  && creditAvailable >= creditTobeDeducted){
            if(shtLst.size()>0){
                try{ 
                    //Inserting Deals
                    RV_SHTTriggerHelper.isOlfDeal = true; //166747_OLF_OnlineATPsplit_24Jun2019_Soumyajit
                    RV_SHTTriggerHelper.accountAlreadyUpdated = true; //OLFCustomerCreditChk_01Aug2019_Soumyajit
                    
                    List<Database.SaveResult> srList= database.insert(shtLst);
                    for(database.SaveResult sr:srList){
                        if(sr.isSuccess()){
                            insertedIds.add(sr.getId());
                        }
                    }
                    //updating credit for the customer
                    OLF_Utility.updateCreditForCustomer(acc,creditTobeDeducted);
                    //Inserting/Updating sales of Customer for Plant Grade and Customer Combination
                    //START | Rahul Sharma | Date - 18-March-2020 : Updated input parameter for send parent account (Sold-to Account) Id.
                    OLF_Utility.makeEntryInCustomerSalesManagement(shtLst, acc.ParentId, gradeMap, plantIdCodeMap);
                    //END | Rahul Sharma | Date - 18-March-2020 : Updated input parameter for send parent account (Sold-to Account) Id.
                }
                catch(Exception e){ 
                    System.debug('OLF_CreateDeal >> getPrice() >> Exception: ' + e.getMessage() + ' Line number: ' + e.getLineNumber()); 
                }
            }
        }
        
        Map<string,String> mrcNoSHTNoMap= new Map<string,String>();
        //List<OLFWrapper.MrcPriceWrap> olfCompDealEmailWrpLst = new List<OLFWrapper.MrcPriceWrap>();
        //Map<String,Decimal> mrcAtpMap= new Map<String,Decimal>();
        Map<String,Decimal> plantGrdAtpMap= new Map<String,Decimal>();
      
       
        //Inserting Audit Record for deals Created
        if(insertedIds.size()>0){
            List<Sht__c> createdOlfDeals= new List<Sht__c>();
            createdOlfDeals = [SELECT Id,
                                      Name,
                                      MRC__r.Name,
                                      Contract_Start__c,
                                      Tranche__c FROM SHT__c WHERE Id IN :insertedIds];
            system.debug('createdOlfDeals shtIds===>'+createdOlfDeals);
            Map<String,String> mrcNoShtIdMap= new Map<String,String>();
            for(Sht__c sh : createdOlfDeals){
                mrcNoShtIdMap.put(sh.MRC__r.Name + String.valueOf(sh.Contract_Start__c), sh.Id);
                mrcNoSHTNoMap.put(sh.MRC__r.Name + String.valueOf(sh.Contract_Start__c), sh.Name);
            }
            /*for(RV_SPCalculationController.priceAuditWrap adtWrp : salesPriceAuditInsertLst){
                adtWrp.shtId = mrcNoShtIdMap.get(adtWrp.mrcNo + adtWrp.tranche);
            }*/
            for(String startDate : startDateVsPriceAuditMap.keySet()){
                for(RV_SPCalculationController.priceAuditWrap adtWrp : startDateVsPriceAuditMap.get(startDate)){
                    adtWrp.shtId = mrcNoShtIdMap.get(adtWrp.mrcNo + startDate);
                    salesPriceAuditInsertLst.add(adtWrp);
                }
            }
            if(salesPriceAuditInsertLst.size()>0){
                Rv_PriceAuditController.insertPriceAuditWrap(salesPriceAuditInsertLst);
            }
            for(String startDate : startDateVsDealWrapLstMap.keySet()){
                //String tranche = startDateVsTrancheMap.get(startDate);
                List<OLFWrapper.MrcPriceWrap> olfDealToBeCreated = startDateVsDealWrapLstMap.get(startDate);
                for(OLFWrapper.MrcPriceWrap mpw :olfDealToBeCreated){
                    if(mpw.inputVolume != null && mpw.inputVolume != '' && mpw.PricePerUnit != null && mpw.PricePerUnit != ''){
                        if(mrcNoSHTNoMap.containsKey(mpw.MRCNumber + startDate)){
                            mpw.sfdcDealNumber=mrcNoSHTNoMap.get(mpw.MRCNumber + startDate); 
                            mpw.dealMessage='Deal Created Successfully.';
                            //olfCompDealEmailWrpLst.add(mpw);
                            mrcPriceWrapList.add(mpw);
                        }  
                    }
                }
            }     
        }
        /*if(olfCompDealEmailWrpLst.size()>0){
            OLF_SendEmail.sendEmailtoCustomer(olfCompDealEmailWrpLst);
        }*/
        if(mrcPriceWrapList.size()>0){
            OLF_SendEmail.sendEmailtoCustomer(mrcPriceWrapList);
        }
        
        if(volumeCheckforAllDeals > 0){
            //On Insufficient Volume Available for any Combnation of plant and Grade
            Set<String> plantGrdSet=new Set<String>();
            plantGrdSet.addAll(mrcPlantGrdMap.values());
            //START | Rahul Sharma | Date - 18-Mar-2020 : Updated input paramenter to send ParentId of Sold-to account from Ship-to accounts
            //START | Rahul Sharma | Date - 06-Nov-2020 : Added tranche parameter to get tranche specific ATP.
            plantGrdAtpMap = OLF_FetchMrcFinalPrice.getAtpforPlant(plantCodeSet,acc.ParentId, new List<String>(new Set<String>(startDateVsTrancheMap.values()))); 
            //END | Rahul Sharma | Date - 06-Nov-2020 : Added tranche parameter to get tranche specific ATP.
            //END | Rahul Sharma | Date - 18-Mar-2020 : Updated input paramenter to send ParentId of Sold-to account from Ship-to accounts
            for(String startDate : startDateVsDealWrapLstMap.keySet()){
                String tranche = startDateVsTrancheMap.get(startDate);
                List<OLFWrapper.MrcPriceWrap> olfDealToBeCreated = startDateVsDealWrapLstMap.get(startDate);
                for(OLFWrapper.MrcPriceWrap mpw :olfDealToBeCreated){
                    mpw.dealMessage='Insufficent Volume for Plant Grade Combination of '+ volCheckPlantGrade;
                    if(plantGrdAtpMap.get(mrcPlantGrdMap.get(mpw.MRCNumber) + tranche) <1){
                        mpw.availableVolume='0';
                    }
                    else{
                        mpw.availableVolume = String.valueOf(plantGrdAtpMap.get(mrcPlantGrdMap.get(mpw.MRCNumber) + tranche));
                    }
                    mrcPriceWrapList.add(mpw);  
                }
            }
            //return olfDealToBeCreated;
        }
        else if(creditAvailable < creditTobeDeducted){
            //On Insufficient Credit Limit Available
            for(String startDate : startDateVsDealWrapLstMap.keySet()){
                String tranche = startDateVsTrancheMap.get(startDate);
                List<OLFWrapper.MrcPriceWrap> olfDealToBeCreated = startDateVsDealWrapLstMap.get(startDate);
                for(OLFWrapper.MrcPriceWrap mpw :olfDealToBeCreated){
                    mpw.dealMessage='Insufficient Credit';
                    mrcPriceWrapList.add(mpw);
                }
            }
            //return olfDealToBeCreated;
        } 
        /*else{
            //On Successful Deal Creation
           return olfDealToBeCreated;
        }*/
        return mrcPriceWrapList;
    }

    public static List<Mrc__c> getMrcRecords(Set<string> mrcNos){
        List<Mrc__c> mrcList= new List<Mrc__c>();
        if(mrcNos.size()>0){
            mrcList = [select id,name,Plant__c,Plant__r.Name,Po_Type__c,
                      Supply_Type__c,Product__c,Plant_code__c,Product__r.Name,Material_Description__c,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,
                       Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,
                       Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                       Ship_to_Name__c, Valid_From_Date__c,Valid_To_Date__c,Shipping_Condition__c from MRC__c 
                       where Name IN :mrcNos and Valid_To_Date__c >= TODAY order by Name,Plant_code__c ASC];
        }
        return mrcList;
    }   
}