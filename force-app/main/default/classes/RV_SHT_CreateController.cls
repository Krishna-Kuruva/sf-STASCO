public class RV_SHT_CreateController {
    //START | Rahul Sharma | Date - 22-Jul-2020 : Added checkbox to determine MRCs available for OLF.
    private static Boolean filterOlfMRCs = false;
    //END | Rahul Sharma | Date - 22-Jul-2020 : Added checkbox to determine MRCs available for OLF.
    /*START | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters to take Ship-to account as a list instead of Sold-to account.
    *Also Updated relavent logic to query MRCs based on Ship-to account
    */
    //@AuraEnabled
    public static List<MRCDataWrap>  getMRCRecordsData(String tranche ,String Mrcno ,Set<Id> accIdSet,
            String shipto,Boolean checked ,Boolean agoChk,
            Boolean igoChk,Boolean mogasChk,string poType,
            string plant,string mot,string contractStartDate,
            string contractEndDate,boolean callFromOlf)
    {
        if(contractStartDate!=null && contractStartDate!='')
        {
            //Fix_252970_30Apr2019_Soumyajit starts
            if(	date.valueOf(contractStartDate) < system.today()
                    ){
                contractStartDate=String.valueOf(System.today());
                if(date.valueOf(contractEndDate) <= system.today())
                    contractEndDate=String.valueOf(System.today());
                else
                        contractEndDate=String.valueOf(System.today().addDays(13));
            }
            if(date.valueOf(contractStartDate)> date.valueOf(contractEndDate)){
                contractEndDate=String.valueOf(date.valueOf(contractStartDate).addDays(13));
            }
        }
        //System.debug('contractStartDate==>'+contractStartDate+'contractEndDate==>'+contractEndDate);
        Set<String> productSet= new Set<String>();
        if(agoChk){
            productSet.add('AGO B7');
            productSet.add('AGO B0');
            productSet.add('AGO B0 CH');
            productSet.add('AGO VPD');
            productSet.add('GTL B0');
            productSet.add('GTL B7');
        }
        if(igoChk){
            productSet.add('IGO 50ppm');
            productSet.add('IGO 1000ppm');
            productSet.add('IGO 10ppm');
        }
        if(mogasChk){
            productSet.add('ULG95 E5');
            productSet.add('ULG95_BOB_E5');
            productSet.add('ULG95_BOB_E10');
            productSet.add('ULG95 E10');
            productSet.add('ULG98');
            productSet.add('ULG95 E0');
            productSet.add('ULG100 VP');
            productSet.add('AVGAS');
        }
        Map<String , ATP__c >  atpLocMap = new Map<String , ATP__c >();
        decimal astmAgoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
        decimal astmMogas= Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);
        List<MRCDataWrap> mrcWrapList = new List<MRCDataWrap>();
        List<MRC__c> mrcfinalList = new List<MRC__c>();
        //get Product custom settings
        Map<String,String> productMap = new Map<String,String>();
        List<Product_Name_Mapping__mdt> productMapMD = [SELECT ID,MasterLabel,DeveloperName,Product_Name__c from Product_Name_Mapping__mdt];
        for(Product_Name_Mapping__mdt mdt : productMapMD){
            productMap.put(mdt.MasterLabel, mdt.Product_Name__c);
        }

        //Get MRC Data
        List<MRC__c> mrcList = new List<MRC__c>();
        Id recTypeId=Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        String query='select id,name,Plant__c,Plant__r.Name,Plant_code__c,Plant__r.Country__c,'+
                'Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Material_Description__c,Material_Name__c,PO_Type__c,'+
                ' Sold_To__c,Sold_To__r.Name,Sold_To__r.Rv_Olf_Customer_Email__c,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,'+
                ' Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,Online_Material_Name_Taxed__c,'+
                ' Online_Material_Name_UnTaxed__c,Online_Customer_Name__c from MRC__c WHERE Active__c = true ';
        //recordTypeId=:recTypeId and
        string queryPart='';
        String mrc='';
        if(Mrcno != null && !''.equals(Mrcno)){
            if(Mrcno.startsWithIgnoreCase('0Truck') || Mrcno.startsWithIgnoreCase('0Barge')){
                mrc = '%'+ Mrcno + '%';
                queryPart='AND Name LIKE :mrc ';
            }
            else if(!Mrcno.startsWith('0')){
                Mrcno = '0'+ Mrcno;
                queryPart='AND MRC_Number__c = :Mrcno and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY';
            }
            else{
                queryPart='AND MRC_Number__c = :Mrcno and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY';
            }
        }
        if(accIdSet != null && !accIdSet.isEmpty()){
            queryPart='AND Ship_To__c IN :accIdSet and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY';
        }
        if(!accIdSet.isEmpty() && poType!=null && poType!= ''){
            queryPart='AND Ship_To__c IN :accIdSet and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY'+
                    ' and PO_Type__c= :poType';
        }
        if(!accIdSet.isEmpty() && poType!=null && poType!= '' && plant!= null && plant!=''){
            queryPart='AND Ship_To__c IN :accIdSet and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY'+
                    ' and PO_Type__c= :poType and Plant__r.Name= :plant';
        }
        if(!accIdSet.isEmpty() && poType!=null && poType!= '' && mot!= null && mot!=''){
            String shippingCondition='';
            if(mot.contains('-')){
                shippingCondition = mot.substringAfter('-');
            }
            //system.debug('shippingCondition=>'+shippingCondition);
            // Commented out Integer conversion and used Set for passing value of Shipping_Condition__c
            // integer shippingcond=Integer.valueOf(shippingCondition);
            set<Integer> shippingcondtn = new Set<Integer>();
            shippingcondtn.add(Integer.valueOf(shippingCondition.trim()));
            //  queryPart='AND Ship_To__c IN :accIdSet and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY'+
            //   ' and PO_Type__c= :poType and Shipping_Condition__c= :shippingcond';
            queryPart='AND Ship_To__c IN :accIdSet and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY'+
                    ' and PO_Type__c= :poType and Shipping_Condition__c IN :shippingcondtn ';
        }
        //START | Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Updated logic to search MRCs based Ship-To number to also include PO Type, Plant and MOT in search criteria.
        if(shipto != null && !'none'.equals(shipto) && shipto != '' && !String.isEmpty(poType)){
            if(!shipto.startsWith('0'))
                shipto = '00'+ shipto;
            else if(shipto.startsWith('00'))
                shipto = shipto;
            else if(shipto.startsWith('0'))
                shipto = '0'+ shipto;
            queryPart='AND Ship_to_Number__c = :shipto  AND Material_Description__c IN :productSet AND Valid_To_Date__c >= TODAY AND PO_Type__c= :poType';
            if(!String.isEmpty(plant))
                queryPart += ' AND Plant__r.Name= :plant';
            if(!String.isEmpty(mot)){
                String shippingCondition='';
                if(mot.contains('-')){
                    shippingCondition = mot.substringAfter('-');
                }
                Integer shippingcond=Integer.valueOf(shippingCondition);
                queryPart += ' AND Shipping_Condition__c= :shippingcond';
            }
        }
        //END | Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Updated logic to search MRCs based Ship-To number to also include PO Type, Plant and MOT in search criteria.
        /*END | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters to take Ship-to account as a list instead of Sold-to account.
         *Also Updated relavent logic to query MRCs based on Ship-to account
         */
        if(callFromOlf){
            queryPart=queryPart+' AND Rv_Available_for_OLF__c = true';
        }
        //START | Rahul Sharma | Date - 22-Jul-2020 : Updated condition to allow Sales Capture screen to filter MRCs available only for OLF.
        if(filterOlfMRCs && !callFromOlf){
            queryPart=queryPart+' AND RV_OLF_MRC_Only__c = true';
        }
        else if(!filterOlfMRCs && !callFromOlf){
            queryPart=queryPart+' AND RV_OLF_MRC_Only__c = false';
        }
        //END | Rahul Sharma | Date - 22-Jul-2020 : Updated condition to allow Sales Capture screen to filter MRCs available only for OLF. 
        string queryOrderBy=' ORDER BY MRC_Number__c,Plant__r.Name,MRC_Grade_Sort__c ASC';
        string queryString=query+queryPart+queryOrderBy;
        mrcList = Database.query (queryString);

        //remove ULG95 E5 and 98
        if(mogasChk && checked){
            Map<String,Set<String>> planCodeRtlMixMrcLstMap= new Map<String,Set<String>>();
            Set<String> MrcNoFinalSet= new Set<String>();
            for(MRC__c mrcObj : mrcList){
                if(mrcObj.Material_Description__c =='ULG95 E10' || mrcObj.Material_Description__c =='ULG98' || mrcObj.Material_Description__c == 'ULG95 E5'){
                    if(planCodeRtlMixMrcLstMap.containsKey(mrcObj.Plant_Code__c+mrcObj.MRC_Number__c+mrcObj.Ship_to_Name__c)){
                        Set<String> MrcNoSet=planCodeRtlMixMrcLstMap.get(mrcObj.Plant_Code__c+mrcObj.MRC_Number__c+mrcObj.Ship_to_Name__c);
                        MrcNoSet.add(mrcObj.Name);
                        planCodeRtlMixMrcLstMap.put(mrcObj.Plant_Code__c+mrcObj.MRC_Number__c+mrcObj.Ship_to_Name__c, MrcNoSet);
                    }else{
                        planCodeRtlMixMrcLstMap.put(mrcObj.Plant_Code__c+mrcObj.MRC_Number__c+mrcObj.Ship_to_Name__c, new Set<String> {mrcObj.Name});
                    }
                }else{
                    MrcNoFinalSet.add(mrcObj.Name);
                }
            }

            for(string plntCod : planCodeRtlMixMrcLstMap.Keyset()){
                Set<String> mrcNolst=planCodeRtlMixMrcLstMap.get(plntCod);
                if(mrcNolst.size()== 3){
                    MrcNoFinalSet.addall(mrcNolst);
                }
            }
            List<Mrc__c> mrcNewLst = new List<Mrc__c>();
            for(MRC__c mrcObj : mrcList){
                if(MrcNoFinalSet.contains(mrcObj.Name)){
                    mrcNewLst.add(mrcObj);
                }
            }
            for(MRC__c mrcObj : mrcNewLst){
                //START - Rahul Sharma | Date - 21-Nov-2020 : Updated Logic to remove ULG95 E5 and ULG98 instead of ULG95 E10 and ULG98
                if(mrcObj.Material_Description__c =='ULG95 E5' || mrcObj.Material_Description__c =='ULG98'){
                }
                else{
                    mrcfinalList.add(mrcObj);
                }
                //END - Rahul Sharma | Date - 21-Nov-2020 : Updated Logic to remove ULG95 E5 and ULG98 instead of ULG95 E10 and ULG98
            }
        }
        else{
            mrcfinalList.addAll(mrcList);
        }
        if(callFromOlf){
            RV_SPCalculationController.isOlfDeal = true;
            RV_SPCalculationController.tranche = tranche; //Rahul Sharma | Date - 03-Nov-2020 : Enabled tranche for OLF
        }
        //setting Inut data wrap for price calculation
        List<RV_SPCalculationController.salesPriceWrap> salesPriceWrapLst=new List<RV_SPCalculationController.salesPriceWrap>();
        List<RV_SPCalculationController.salesPriceWrap> finalSalesPriceWrapLst=new List<RV_SPCalculationController.salesPriceWrap>();
        RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        spAdtWrp=RV_SPCalculationController.getCalulatedSp(mrcfinalList,date.valueOf(contractStartDate),date.valueOf(contractEndDate));
        salesPriceWrapLst=spAdtWrp.salesPriceWrpLst;
        finalSalesPriceWrapLst.addAll(salesPriceWrapLst);
        salesPriceWrapLst=null;
        Map<String,RV_SPCalculationController.salesPriceWrap> mrcNoSPwrap= new Map<String,RV_SPCalculationController.salesPriceWrap>();
        for(RV_SPCalculationController.salesPriceWrap spwrp:finalSalesPriceWrapLst){
            mrcNoSPwrap.put(spwrp.mrcNo,spwrp); //Map of Sp and MRC
        }
        //Create Location ID Set
        Set<Id> LocIds= new Set<Id>();
        for(MRC__c mr:mrcList){
            LocIds.add(mr.Plant__c);
        }
        //Deal Event Manager metadata
        Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap=getDealEventMetdataMap();
        //system.debug('poTypeHandlingDealMdtMap==>'+poTypeHandlingDealMdtMap); 

        //Shipping Condition Map
        Map<Integer,String> ShipCondNoNameMap= new Map<Integer,String>();
        List<Shipping_Condition_Mapping__mdt> shipCdnMetDatLst= [Select id,Mot__c,Shipping_Condition__c
        from Shipping_Condition_Mapping__mdt];
        for(Shipping_Condition_Mapping__mdt shp:shipCdnMetDatLst){
            ShipCondNoNameMap.put(Integer.valueOf(shp.Shipping_Condition__c),shp.Mot__c);
        }

        //Fix_437452_02Mar2020_Soumyajit starts
        //Get ATP Data
        List<ATP__c> atpList = [select id , name ,Location__c,Location__r.Name,ATP_Live__c,ATP2_Live__c,ATP3_Live__c,
                location__r.Related_Plant__c,location__r.Related_Plant_Code__c,
                Plant_Code__c,Company_Code__c ,Grade_Level2__c from ATP__c
        where Location__c  IN : LocIds];

        Map<String,String> mapRelatedATPLoc = new Map<String,String>();
        Set<ID> relatedLocSet = new Set<ID>();
        Map<String , ATP__c >  atpLocRelatedMap = new Map<String , ATP__c >();

        //Changed this map to get atp value for location and product (Make key as Location+Product)
        if(atpList.size() >0){
            for(ATP__c atpObj :atpList){
                atpLocMap.put(atpObj.Plant_Code__c+atpObj.Grade_Level2__c,atpObj);

                if(atpObj.location__r.Related_Plant_Code__c != null)
                {
                    if(!relatedLocSet.contains(atpObj.location__r.Related_Plant__c))
                        relatedLocSet.add(atpObj.location__r.Related_Plant__c);
                    mapRelatedATPLoc.put(atpObj.Plant_Code__c+atpObj.Grade_Level2__c,atpObj.location__r.Related_Plant_Code__c+atpObj.Grade_Level2__c);
                }
            }
        }

        if(relatedLocSet.size()>0)
        {
            List<ATP__c> atpRelatedList = [select id , name ,Location__c,Location__r.Name,ATP_Live__c,ATP2_Live__c,ATP3_Live__c,
                    location__r.Related_Plant__c,location__r.Related_Plant_Code__c,
                    Plant_Code__c,Company_Code__c ,Grade_Level2__c from ATP__c
            where Location__c  IN : relatedLocSet];

            if(atpRelatedList.size()>0)
            {
                for(ATP__c atpObj :atpRelatedList)
                    atpLocRelatedMap.put(atpObj.Plant_Code__c+atpObj.Grade_Level2__c,atpObj);
            }
        }
        //Fix_437452_02Mar2020_Soumyajit ends

        //create wraper object 
        MRCDataWrap wrapObj ;
        Decimal atpVal = 0;
        string grade = '';

        for(MRC__c mrcObj : mrcfinalList){
            wrapObj = new MRCDataWrap();
            atpVal =0;
            wrapObj.mrcId = mrcObj.id;
            if( mrcObj.Material_Description__c != null){
                grade = mrcObj.Material_Description__c;
            }
            wrapObj.grade = grade;
            if(mrcObj.Sold_To__c != null){
                wrapObj.accId=mrcObj.Sold_To__c;
				wrapObj.accName=mrcObj.Sold_To__r.Name;
                 //Added By Sampada Bhat
                if(mrcObj.Sold_To__r.Rv_Olf_Customer_Email__c != null){
                    wrapObj.contactEmail = mrcObj.Sold_To__r.Rv_Olf_Customer_Email__c;
                }               
            }
            if(callFromOlf && mrcObj.Online_Customer_Name__c != null){
                wrapObj.accName=mrcObj.Online_Customer_Name__c;
            }
            wrapObj.mrcName = mrcObj.Name;
            wrapObj.salesOrg =mrcObj.Sales_Organization__c;
            wrapObj.materialNo =(mrcObj.Product__r.Name).right(4);
            wrapObj.materialName=mrcObj.Material_Name__c;
            wrapObj.shipToNumber = mrcObj.Ship_to_Number__c;
            wrapObj.locationId=mrcObj.Plant__c;
            wrapObj.location = mrcObj.Plant_Code__c;
            if(callFromOlf && mrcObj.Online_Location_Name__c != null){
                wrapObj.locationName = mrcObj.Online_Location_Name__c;
            }else{
                wrapObj.locationName = mrcObj.Plant__r.Name;
            }


            //Get  ATP values for Account based on Material Number
            String prdtName = productMap.get(grade);
            if(tranche == 'ATP1'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c !=null){
                        if(prdtName.contains('ULG')){
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmMogas).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmMogas).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                        }else{
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmAgoIgo).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmAgoIgo).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                        }
                    }
                }
            }
            else if(tranche == 'ATP2'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if( atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c != null){
                        if(prdtName.contains('ULG')){
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmMogas).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmMogas).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                        }else{
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmAgoIgo).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmAgoIgo).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                        }
                    }
                }
            }
            else{
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c != null){
                        if(prdtName.contains('ULG')){
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmMogas).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmMogas).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                        }else{
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmAgoIgo).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmAgoIgo).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                        }
                    }
                }

            }

            //Fix_437452_02Mar2020_Soumyajit starts
            Decimal atpLiveRelated = 0;
            if(mapRelatedATPLoc.containskey(mrcObj.Plant_Code__c+prdtName))
            {
                String relatedKey = mapRelatedATPLoc.get(mrcObj.Plant_Code__c+prdtName);
                Decimal divFactor = (prdtName.contains('ULG'))? astmMogas : astmAgoIgo;

                if(atpLocRelatedMap.containskey(relatedKey))
                {
                    switch on tranche
                    {
                        when 'ATP1' {
                            atpLiveRelated = (atpLocRelatedMap.get(relatedKey).ATP_Live__c !=null) ? atpLocRelatedMap.get(relatedKey).ATP_Live__c :0;
                        }
                        when 'ATP2' {
                            atpLiveRelated = (atpLocRelatedMap.get(relatedKey).ATP2_Live__c !=null) ? atpLocRelatedMap.get(relatedKey).ATP2_Live__c :0;
                        }
                        when else {
                            atpLiveRelated = (atpLocRelatedMap.get(relatedKey).ATP3_Live__c !=null) ? atpLocRelatedMap.get(relatedKey).ATP3_Live__c :0;
                        }
                    }
                    atpLiveRelated = (atpLiveRelated / divFactor).intValue();
                }
            }
            //Fix_437452_02Mar2020_Soumyajit ends

            //Live Atp for selected tranche
            wrapObj.atpLive = (callFromOlf)? atpVal : (atpVal + atpLiveRelated);	//Fix_437452_02Mar2020_Soumyajit
            //Deal Event Manager Attributes for Pricing ,Vol deduction & Hedging
            wrapObj.isPricingTaxed=false;
            wrapObj.pricingCondition='YP24';
            wrapObj.atpVoltoBeReduced=false;
            wrapObj.isVolToBeHedged=false;
            wrapObj.isZeroPriceDeal=false;
            wrapObj.retroAtpVoltoBeReduced=false;
            wrapObj.retroVolToBeHedged=false;
            wrapObj.isGsapDealCreateOn=false;
            wrapObj.isGsapDealCancelOn=false;
            wrapObj.retroGsapDealCreateOn=false;
            wrapObj.retroGsapDealCancelOn=false;

            string key=mrcObj.PO_Type__c+mrcObj.Handling_Type__c;
            String otherKey=mrcObj.PO_Type__c+'Others';
            // system.debug('GSAP key==>'+key+'otherKey==>'+otherKey);
            //  system.debug('GSAP MRC key==>'+ShipCondNoNameMap.get(Integer.valueOf(mrcObj.Shipping_Condition__c)));
            string finalKey;
            Deal_Event_Manager__mdt dealEvent;
            if(poTypeHandlingDealMdtMap.containsKey(key)){
                dealEvent=poTypeHandlingDealMdtMap.get(key);
                //system.debug('dealEvent2==>'+dealEvent);
            }
            else if(poTypeHandlingDealMdtMap.containsKey(otherKey)){
                dealEvent=poTypeHandlingDealMdtMap.get(otherKey);
                //system.debug('dealEvent1==>'+dealEvent);
            }
            //system.debug('dealEvent==>'+dealEvent);
            if(dealEvent != null){
                wrapObj.isPricingTaxed=dealEvent.IsPricingTaxed__c;
                wrapObj.pricingCondition=dealEvent.Pricing_Condition__c;
                wrapObj.atpVoltoBeReduced=dealEvent.IsATPVolumeReduced__c;
                wrapObj.isVolToBeHedged=dealEvent.IsVolumeHedged__c;
                wrapObj.isZeroPriceDeal=dealEvent.IsZeroPriceDeal__c;

                if(dealEvent.Shipping_Condition__c.contains(ShipCondNoNameMap.get(Integer.valueOf(mrcObj.Shipping_Condition__c)))){
                    wrapObj.isGsapDealCreateOn=dealEvent.IsGsapDealCreateOn__c;
                    wrapObj.isGsapDealCancelOn=dealEvent.IsGsapDealCancelOn__c;
                    //Retro GSAP Deals
                    wrapObj.retroGsapDealCreateOn=dealEvent.IsRetroGsapDealCreateOn__c;
                    wrapObj.retroGsapDealCancelOn=dealEvent.IsRetroGsapDealCancelOn__c;
                }
                //Retro Volume Deals
                wrapObj.retroAtpVoltoBeReduced=dealEvent.IsRetroATPVolumeReduced__c;
                wrapObj.retroVolToBeHedged=dealEvent.IsRetroVolumeHedged__c;
            }
            //Online Material Name for OLF Based on taxation
            if(callFromOlf && wrapObj.isPricingTaxed && mrcObj.Online_Material_Name_Taxed__c != null){
                wrapObj.materialName=mrcObj.Online_Material_Name_Taxed__c;
            }else if(callFromOlf && !wrapObj.isPricingTaxed && mrcObj.Online_Material_Name_UnTaxed__c !=null){
                wrapObj.materialName=mrcObj.Online_Material_Name_UnTaxed__c;
            }else{
                wrapObj.materialName=mrcObj.Material_Name__c;
            }

            // system caLCULATED price euro/100L
            if( mrcNoSPwrap.containsKey(mrcObj.Name)) {
                if(mrcNoSPwrap.get(mrcObj.Name).landedCost != null){
                    wrapObj.landedCostCal=((mrcNoSPwrap.get(mrcObj.Name)).landedCost).setScale(2, RoundingMode.HALF_UP);
                }
                if(mrcNoSPwrap.get(mrcObj.Name).BSP != null){
                    wrapObj.finalbspCal=((mrcNoSPwrap.get(mrcObj.Name)).BSP).setScale(2, RoundingMode.HALF_UP);
                }
                if(mrcNoSPwrap.get(mrcObj.Name).MSP != null){
                    wrapObj.finalSalesPriceCal=((mrcNoSPwrap.get(mrcObj.Name)).MSP).setScale(2, RoundingMode.HALF_UP);
                }

                if(mrcNoSPwrap.get(mrcObj.Name).OTM != null){
                    wrapObj.OTM=((mrcNoSPwrap.get(mrcObj.Name)).OTM).setScale(2, RoundingMode.HALF_UP);
                }
                decimal totalTax=0;
                if(mrcNoSPwrap.get(mrcObj.Name).totalTax != null){
                    totalTax=((mrcNoSPwrap.get(mrcObj.Name)).totalTax).setScale(2, RoundingMode.HALF_UP);
                }

            }
            //START - Rahul Sharma | Date - 28-Jan-2021 | PBI-702438 : Updated pricePerVol as 0 for zero price deal. 
            if(wrapObj.isZeroPriceDeal){
                wrapObj.pricePerVol = 0;
            }
            //END - Rahul Sharma | Date - 28-Jan-2021 | PBI-702438 : Updated pricePerVol as 0 for zero price deal. 
            mrcWrapList.add(wrapObj);
        }

        if(!mrcWrapList.isEmpty())
            return mrcWrapList;
        else
                return null;
    }

    //Deal Event Manager metadata
    //START - Rahul Sharma | Date - 28-Jan-2021 | PBI-702438 : Updated query to retreive only active records. 
    public static  Map<String,Deal_Event_Manager__mdt> getDealEventMetdataMap(){
        List<Deal_Event_Manager__mdt> dealMgrMdtLst=[SELECT Handling_Type__c,
                IsATPVolumeReduced__c,
                IsGsapDealCancelOn__c,
                IsGsapDealCreateOn__c,
                IsPricingTaxed__c,
                IsVolumeHedged__c,
                IsZeroPriceDeal__c,
                PO_Type__c,
                Pricing_Indicator__c, //Rahul Sharma | Date - 11-Feb-2021 | Bug-732764 : Adding Deal Event Manager metadata records.
                Pricing_Condition__c,
                IsRetroGsapDealCancelOn__c,
                IsRetroGsapDealCreateOn__c,
                IsRetroVolumeHedged__c,
                Shipping_Condition__c,
                IsRetroATPVolumeReduced__c FROM Deal_Event_Manager__mdt WHERE Active__c = true];
        //END - Rahul Sharma | Date - 28-Jan-2021 | PBI-702438 : Updated query to retreive only active records.
        Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap= new Map<String,Deal_Event_Manager__mdt>();
        for(Deal_Event_Manager__mdt dem :dealMgrMdtLst){
            poTypeHandlingDealMdtMap.put(dem.PO_Type__c+dem.Handling_Type__c, dem);
        }
        return poTypeHandlingDealMdtMap;
    }

    @AuraEnabled
    public static string updateDealComment(Id shtId,string comment){
        Sht__c shtRec=[Select Id ,name,Deal_Comment__c from Sht__c where Id=:shtId];
        //CommentUpdateFix_10Jul2019_Soumyajit starts
        if(comment != null)
        {
            if(!comment.equals(shtRec.Deal_Comment__c))
            {
                //CommentUpdateFix_10Jul2019_Soumyajit ends
                shtRec.Deal_Comment__c=comment;
                Schema.DescribeSObjectResult s = sht__c.sObjectType.getDescribe();
                if(s.isUpdateable()){
                    update shtRec;
                }
                return 'Success';
                //CommentUpdateFix_10Jul2019_Soumyajit starts
            }
            else
                    return 'NoUpdate';
        }
        else
                return 'NoUpdate';
        //CommentUpdateFix_10Jul2019_Soumyajit ends

    }
    @AuraEnabled
    public static saveResultsearchWrap cancelSHTDeal(String shtId,string status,string reason, string searchList){
		 if(reason != null && reason.contains('-')){
            reason = reason.split('-')[0];
        }
        Map<String,Decimal> shtMap = new Map<String,Decimal>();    
        List<RV_Trigger_Master_Data__c> updatetrgrMsterDataLst = new List<RV_Trigger_Master_Data__c>();

        saveResultsearchWrap srchSaveWrp = new saveResultsearchWrap();
        List<MRCDataWrap> searchWrap= new List<MRCDataWrap>();
        List<SHTDisplayWrap> shtDspWrap = new List<SHTDisplayWrap>();
        List<MRCDataWrap> listToUpdate;
        try{
            listToUpdate = (List<MRCDataWrap>)JSON.deserialize(searchList, List<MRCDataWrap>.class);
        }
        catch(Exception e){
        }
        List<SHT__c> shtList = [select id,name,MRC_Number__c,Volume_CBM__c,Location__c,Location__r.Name,
        Trigger_Master_Data__c, Product_Category__c,Status__c,Cancellation_Reason__c, Deal_Comment__c 
                ,isOlfDeal__c //270192_OLFDealCancel_08Jul2019_Soumyajit
        from SHT__c where id =:shtId LIMIT 1];
		 for(SHT__c st:shtList){
            shtMap.put(st.Trigger_Master_Data__c , st.Volume_CBM__c);        
        }
        SHT__c obj = shtList.get(0);
        Decimal volCBM = obj.Volume_CBM__c;
        decimal volume;
        string locProd;
        string message;
        Map<String,String> reasonLabelApiNameMap=new  Map<String,String>();
        List<Cancellation_Reason_Mapping__mdt> canRsnMdtLst=[Select Cancellation_Reason_Code__c,Cancellation_Reason_Label__c
        from Cancellation_Reason_Mapping__mdt];
        for(Cancellation_Reason_Mapping__mdt crm :canRsnMdtLst){
            reasonLabelApiNameMap.put(crm.Cancellation_Reason_Label__c,crm.Cancellation_Reason_Code__c);
        }
        /*
        Schema.DescribeFieldResult fieldResult = SHT__c.Cancellation_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            reasonLabelApiNameMap.put(f.getLabel(),f.getValue());
        }
	`	*/
        //270192_OLFDealCancel_08Jul2019_Soumyajit starts
        if(obj.isOlfDeal__c)
            RV_SHTTriggerHelper.isOlfDeal = true;
        //270192_OLFDealCancel_08Jul2019_Soumyajit ends

        if(status =='Saved') {
            if(listToUpdate.size()>0){
                for(MRCDataWrap mrcWrp:listToUpdate){
                    if(mrcWrp.mrcName == obj.MRC_Number__c){
                        volume=obj.Volume_CBM__c;
                        locProd=obj.Location__r.Name+obj.Product_Category__c;
                    }
                    if(mrcWrp.locationName+mrcWrp.grade == locProd){
                        mrcWrp.atpLive=mrcWrp.atpLive+volume;
                        searchWrap.add(mrcWrp);
                    }
                    else{
                        searchWrap.add(mrcWrp);
                    }
                }

            }
            if(obj.Status__c == 'Saved'){
                obj.Status__c = 'Expired'; //saved deals which has been cancelled
                obj.Cancellation_Reason__c='Saved Deal';
                update obj;
                message='Completed';
            }
            else if(obj.Status__c == 'Auto-Completed'){
                message='Auto-Completed';
            }
        }
        else if(status =='Completed'){
            obj.Status__c = 'Cancelled';
            obj.Cancellation_Reason__c=reasonLabelApiNameMap.get(reason);
			if(reason != null && reason.contains('-')){
                obj.Deal_Comment__c = reason.SubStringAfter('-')+obj.Deal_Comment__c;
                obj.Cancellation_Reason_Label__c=reason.SubStringBefore('-');
            }else{
                obj.Cancellation_Reason_Label__c=reason;
            }
            Schema.DescribeSObjectResult s = sht__c.sObjectType.getDescribe();
            if(s.isUpdateable()){
                update obj;
            }
			 List<RV_Trigger_Master_Data__c> trgrMsterDataLst = [Select Id, Name, Sold_to_Name__c, Sold_to_Number__c, MRC_Number__c, Remaining_triggers__c, 
                                                                Ship_To_Number__c, Monthly_volume__c, Trigger_Month__c, Trigger_Year__c, Min_Trigger_Volume__c,
                                                                Max_Trigger_Volume__c, Max_number_of_triggers_per_month__c, Remaining_trigger_volume__c, SHT__c  
                                                                from RV_Trigger_Master_Data__c where Id =:shtMap.keySet()];
            if(trgrMsterDataLst.size() > 0){
                for(RV_Trigger_Master_Data__c eachTMD : trgrMsterDataLst){
                    
                    eachTMD.Remaining_trigger_volume__c = eachTMD.Remaining_trigger_volume__c != null ? eachTMD.Remaining_trigger_volume__c + shtMap.get(eachTMD.Id) : shtMap.get(eachTMD.Id);
                   if(eachTMD.Max_number_of_triggers_per_month__c != null){
                        eachTMD.Remaining_triggers__c = eachTMD.Remaining_triggers__c != null ? eachTMD.Remaining_triggers__c + 1 : 1;
                    }
                    
                    updatetrgrMsterDataLst.add(eachTMD);
                }
            }
            update updatetrgrMsterDataLst;  
        }
        shtDspWrap= getCompletedSHTDeal('TODAY','Completed','Me');
        srchSaveWrp.savedResult=shtDspWrap;
        srchSaveWrp.searchResult=searchWrap;
        srchSaveWrp.cancelMsg=message;
        return srchSaveWrp;

	 
				
																							  
											
									
													
																	  
																	   
									  
																																				  
											   
															   
															   
																										
															   
				
																																														  
		   
								
												  
																	  
													
											 
				 
			 
		 
																								   
																									 
						 
												 
											  
																		   
																		 
																   
																		 
																		 
			   
																  
										 
											 
																																																																																					  
												 
																			
																			  
													   
													
													 
															

																			  
																 
					  
																							
				 
																		   
																																					  
				 
												  
										  
																					  
														 
																	   
											   
															  
													   
															  
																																					 
																																					 
																																															  
														  
												  
																	   
													
																																											 
													 
																																														
												   
																		
												   
																		 
													  
																																														  
													  
																																														  
																								  
																						  
																							 
																									 
																																																																		  
				 
					 
																
				 
														   
										
			 
		 
											 
												   
								
			
										
				
																				  
									 
									   
															
										
																						
				 
			 
							   
												
			 

											 
		 
											   
						  
    }

    @AuraEnabled
    public static saveResultsearchWrap saveSHTObjectRecord(String dataList,String trancheVal ,String account,
            string salesType ,string contractStartDate,
            string contractEndDate,boolean checked){

        date ContractStrtDateToBeSaved=date.valueOf(contractStartDate);
        date ContractEndDateToBeSaved=date.valueOf(contractEndDate);

        //Fix_252970_30Apr2019_Soumyajit starts
        if(date.valueOf(contractStartDate) < system.today()){
            contractStartDate = String.valueOf(System.today());
            if(date.valueOf(contractEndDate) <= system.today())	//FixReverted_252970_07Aug2019_Soumyajit
                contractEndDate=String.valueOf(System.today());
            else
                    contractEndDate=String.valueOf(System.today().addDays(13));
        }
        saveResultsearchWrap srchSaveWrp = new saveResultsearchWrap();
        List<SHTDisplayWrap> shtSavedWrap = new List<SHTDisplayWrap>();
        Set<Id> MrcIds = new Set<Id>();
        List<MRCDataWrap> listToSave = (List<MRCDataWrap>)JSON.deserialize(dataList, List<MRCDataWrap>.class);
        Map<string,string> mrcRetMixMrcMap= new Map<string,string>();
        Map<string,string> mrcRetMixMrcIdMap= new Map<string,string>();
        Set<string> accntIdSet = new Set<string>();
        Set<Id> mrcId= new Set<Id>();
        Set<String> retailMixMatSet= new Set<String>();
        retailMixMatSet.add('ULG95 E5');
        retailMixMatSet.add('ULG95 E10');
        retailMixMatSet.add('ULG98');
        if(listToSave.size()>0){
            for(MRCDataWrap dataObj : listToSave){
                if(dataObj.volumeCBM != Null && dataObj.volumeCBM >0){
                    accntIdSet.add(dataObj.accId);
                    mrcId.add(dataObj.mrcId);
                }

            }
        }
        List<Mrc__c> mrcRetMixMrcLst= new List<Mrc__c>();
        if(accntIdSet.size()>0){
            //START - Rahul Sharma | Date - 28-Jan-2021 : Updated query fields.
            mrcRetMixMrcLst = [SELECT Id,
                    Name,
                    Material_Description__c,
                    Sold_To__c,
                    Plant__c,
                    Plant__r.Name,
					Plant__r.Country__c,	
                    Plant_code__c,
                    Supply_Type__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Commodity_Grade_L2__c,
                    Product__r.BEHG_Value_100l__c,
                    Product__r.Current_BEHG_valid_from_date__c,
                    Product__r.Current_BEHG_valid_to_date__c,
                    Product__r.Future_BEHG_value_in_100l__c,
                    Product__r.Future_BEHG_valid_from_date__c,
                    Product__r.Future_BEHG_valid_to_date__c,
                    Material_Name__c,
                    PO_Type__c,
                    Sold_To__r.Name,
                    Handling_Type__c,
                    Sales_Organization__c,
                    MRC_Number__c,
                    Ship_to_Name__c,
                    Shipping_Condition__c,
                    Online_Location_Name__c,
                    Online_Material_Name_Taxed__c,
                    Online_Material_Name_UnTaxed__c,
                    Online_Customer_Name__c,
                    Ship_to_Number__c FROM Mrc__c WHERE  Sold_To__c IN :accntIdSet AND
            Material_Description__c IN :retailMixMatSet];
            //END - Rahul Sharma | Date - 28-Jan-2021 : Updated query fields.

            if(mrcRetMixMrcLst.size()>0){
                for(mrc__c mr:mrcRetMixMrcLst){
                    mrcRetMixMrcMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Name);
                    mrcRetMixMrcIdMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Id);
                }
            }
        }
        //system.debug('mrcRetMixMrcMap==>'+mrcRetMixMrcMap); 
        SHT__c newSHTObj;
        SHT__c newSHTObj1;
        SHT__c newSHTObj2;
        Set<SHT__c> saveList = new Set<SHT__c>();
        for(MRCDataWrap dataObj : listToSave){
            if(date.valueOf(ContractStrtDateToBeSaved) < system.today()){
                dataObj.atpVoltoBeReduced=dataObj.retroAtpVoltoBeReduced;
                dataObj.isVolToBeHedged=dataObj.retroVolToBeHedged;
                dataObj.isGsapDealCreateOn=dataObj.retroGsapDealCreateOn;
                dataObj.isGsapDealCancelOn=dataObj.retroGsapDealCancelOn;
            }
            if(dataObj.volumeCBM != Null && dataObj.volumeCBM >0){
                newSHTObj = new SHT__c();
                boolean retailMixAdded=false;
                Map<String, RV_SPCalculationController.salesPriceWrap> mrcNoVsSalesPriceWrapMap = new Map<String, RV_SPCalculationController.salesPriceWrap>(); //Rahul Sharma | Date- 28-Jan-2021 ; Added mrc numberr vs salesPriceWrap map. 
                //START - Rahul Sharma | Date - 21-Nov-2020 : Updated retail mix logic from E5 to E10.
                //if(checked && dataObj.grade == 'ULG95 E5' && dataObj.salesOrg !='AT01' ){
                if(checked && dataObj.grade == 'ULG95 E10' && dataObj.salesOrg !='AT01' ){
                    //END - Rahul Sharma | Date - 21-Nov-2020 : Updated retail mix logic from E5 to E10.
                    newSHTObj1 = new SHT__c();
                    newSHTObj2 = new SHT__c();
                    retailMixAdded = true;
                    //START - Rahul Sharma | Date- 28-Jan-2021 ; Added logic to calculate BSP MSP for retail-mix products.
                    mrcNoVsSalesPriceWrapMap = calculateRetailMixPrice(mrcRetMixMrcLst, contractStartDate, contractEndDate);
                    //END - Rahul Sharma | Date- 28-Jan-2021 ; Added logic to calculate BSP MSP for retail-mix products.
                }
                else{
                    retailMixAdded=false;
                }
                newSHTObj.MRC__c = dataObj.mrcId;
                newSHTObj.MRC_Number__c = dataObj.mrcName;
                newSHTObj.Customer__c = dataObj.accId;
                newSHTObj.Tranche__c = trancheVal;
                newSHTObj.BSP__c=dataObj.finalbspCal;
                newSHTObj.MSP__c=dataObj.finalSalesPriceCal;

                if(dataObj.isZeroPriceDeal !=null && dataObj.isZeroPriceDeal){
                    newSHTObj.SP_100L__c = 0; // Zero Price Deal 
                }else{
                    newSHTObj.SP_100L__c = dataObj.pricePerVol; // Enetred Price by End User
                }
                if(newSHTObj.MSP__c!= null && newSHTObj.SP_100L__c !=null){
                    newSHTObj.Target_Margin__c=newSHTObj.SP_100L__c-newSHTObj.BSP__c;
                }
                newSHTObj.Status__c = 'Saved';
                newSHTObj.Select__c= true;
                newSHTObj.Sales_Type__c = 'Obam Sales';
                newSHTObj.Product_Category__c = dataObj.grade;
                newSHTObj.Contract_Start__c=ContractStrtDateToBeSaved;
                newSHTObj.Contract_End_Date__c=ContractEndDateToBeSaved;
                //newSHTObj.Volume_CBM__c=dataObj.volumeCBM;    //Rahul Sharma | Date - 26-Apr-2021 : Commented redundant variable assignment. 
                newSHTObj.Deal_Comment__c=dataObj.Comment;
                if(dataObj.isPricingTaxed != null)
                    newSHTObj.IsPricingTaxed__c=dataObj.isPricingTaxed;
                if(dataObj.pricingCondition != null)
                    newSHTObj.Price_Condition__c=dataObj.pricingCondition;
                if(dataObj.atpVoltoBeReduced != null)
                    newSHTObj.IsATPVolumeReduced__c=dataObj.atpVoltoBeReduced;
                if(dataObj.isVolToBeHedged != null)
                    newSHTObj.IsVolumeHedged__c=dataObj.isVolToBeHedged;
                if(dataObj.isZeroPriceDeal != null)
                    newSHTObj.IsZeroPriceDeal__c=dataObj.isZeroPriceDeal;
                if(dataObj.isGsapDealCreateOn != null)
                    newSHTObj.IsGsapDealCreateOn__c=dataObj.isGsapDealCreateOn;
                if(dataObj.isGsapDealCancelOn != null)
                    newSHTObj.IsGsapDealCancelOn__c=dataObj.isGsapDealCancelOn;
                //START - Rahul Sharma | Date - 21-Nov-2020 : Updated volume split from E5 to E10.
                //if(checked && dataObj.grade == 'ULG95 E5' && dataObj.salesOrg !='AT01'){
                if(checked && dataObj.grade == 'ULG95 E10' && dataObj.salesOrg !='AT01'){
                    //END - Rahul Sharma | Date - 21-Nov-2020 : Updated volume split from E5 to E10..
                    newSHTObj.Volume_CBM__c=dataObj.volumeCBM * 0.15; //Rahul Sharma | Date - 04-Jan-2020 : Updated volume split from 80% to 15% to retain old split logic.
                }
                else{
                    newSHTObj.Volume_CBM__c = dataObj.volumeCBM;
                }
                newSHTObj.Location__c = dataObj.locationId;
                saveList.add(newSHTObj);
                //If retail mix
                //START - Rahul Sharma | Date - 21-Nov-2020 : Updated filter condition from E10 to E5.
                if(newSHTObj1 != null && retailMixAdded
                        && mrcRetMixMrcIdMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5')
                        ){
                    if(mrcRetMixMrcIdMap.size()>0){
                        if(mrcRetMixMrcIdMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5')){
                            newSHTObj1.MRC__c = mrcRetMixMrcIdMap.get(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5');
                        }
                    }
                    if(mrcRetMixMrcMap.size()>0){
                        if(mrcRetMixMrcMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5')){
                            newSHTObj1.MRC_Number__c = mrcRetMixMrcMap.get(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5');
                        }
                    }
                    newSHTObj1.Customer__c = dataObj.accId;
                    newSHTObj1.Location__c = dataObj.locationId;
                    newSHTObj1.Product_Category__c = 'ULG95 E5';
                    //END - Rahul Sharma | Date - 21-Nov-2020 : Updated filter condition from E10 to E5.
                    //START - Rahul Sharma | Date - 28-Jan-2021 : Updated logic to add actual BSP and MSP.
                    //newSHTObj1.BSP__c = dataObj.finalbspCal;
                    //newSHTObj1.MSP__c = dataObj.finalSalesPriceCal;
                    if(!mrcNoVsSalesPriceWrapMap.isEmpty() && mrcNoVsSalesPriceWrapMap.containsKey(newSHTObj1.MRC_Number__c)){
                        newSHTObj1.BSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj1.MRC_Number__c).BSP;
                        newSHTObj1.MSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj1.MRC_Number__c).MSP;
                    }
                    else{
                        newSHTObj1.BSP__c = dataObj.finalbspCal;
                        newSHTObj1.MSP__c = dataObj.finalSalesPriceCal;
                    }
                    //END - Rahul Sharma | Date - 28-Jan-2021 : Updated logic to add actual BSP and MSP.
                    //START - Rahul Sharma | Date - 28-Jan-2021 : Removed logic for target margin.
                    /*if(newSHTObj1.MSP__c!= null && newSHTObj1.BSP__c !=null){
                        newSHTObj1.Target_Margin__c=newSHTObj1.MSP__c-newSHTObj1.BSP__c;
                    }*/
                    //END - Rahul Sharma | Date - 28-Jan-2021 : Removed logic for target margin.
                    newSHTObj1.Status__c = 'Saved';
                    if(dataObj.isZeroPriceDeal){
                        newSHTObj1.SP_100L__c=0;
                    }else{
                        newSHTObj1.SP_100L__c = dataObj.pricePerVol+decimal.valueOf(Label.RV_Surcharge_E5); // Enetred Price by End User 
                    }
                    //START - Rahul Sharma | Date - 28-Jan-2021 : Updated calculation logic for target margin.
                    if(newSHTObj1.SP_100L__c != null && newSHTObj1.BSP__c != null){
                        newSHTObj1.Target_Margin__c = newSHTObj1.SP_100L__c - newSHTObj1.BSP__c;
                    }
                    //END - Rahul Sharma | Date - 28-Jan-2021 : Updated calculation logic for target margin.
                    newSHTObj1.Select__c= true;
                    newSHTObj1.Tranche__c = trancheVal;
                    newSHTObj1.Volume_CBM__c=dataObj.volumeCBM* 0.80;   //Rahul Sharma | Date - 04-Jan-2020 : Updated volume split from 15% to 80% to retain old split logic.
                    newSHTObj1.Deal_Comment__c=dataObj.Comment;
                    //PBI_166252_DataCleanup_Lakshmi_1stOct2019
                    //newSHTObj1.MOGAS_E10_Volume__c = dataObj.volumeCBM * 0.15;
                    newSHTObj1.Contract_Start__c=ContractStrtDateToBeSaved;
                    newSHTObj1.Contract_End_Date__c=ContractEndDateToBeSaved;
                    newSHTObj1.Sales_Type__c = 'Obam Sales';
                    if(dataObj.isPricingTaxed != null)
                        newSHTObj1.IsPricingTaxed__c=dataObj.isPricingTaxed;
                    if(dataObj.pricingCondition != null)
                        newSHTObj1.Price_Condition__c=dataObj.pricingCondition;
                    if(dataObj.atpVoltoBeReduced != null)
                        newSHTObj1.IsATPVolumeReduced__c=dataObj.atpVoltoBeReduced;
                    if(dataObj.isVolToBeHedged != null)
                        newSHTObj1.IsVolumeHedged__c=dataObj.isVolToBeHedged;
                    if(dataObj.isZeroPriceDeal != null)
                        newSHTObj1.IsZeroPriceDeal__c=dataObj.isZeroPriceDeal;
                    if(dataObj.isGsapDealCreateOn != null)
                        newSHTObj1.IsGsapDealCreateOn__c=dataObj.isGsapDealCreateOn;
                    if(dataObj.isGsapDealCancelOn != null)
                        newSHTObj1.IsGsapDealCancelOn__c=dataObj.isGsapDealCancelOn;

                }
                if(newSHTObj2 != null && retailMixAdded
                        && mrcRetMixMrcIdMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG98')
                        ){
                    if(mrcRetMixMrcIdMap.size()>0){
                        if(mrcRetMixMrcIdMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG98')){
                            newSHTObj2.MRC__c = mrcRetMixMrcIdMap.get(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG98');
                        }
                    }
                    if(mrcRetMixMrcMap.size()>0){
                        if(mrcRetMixMrcMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG98')){
                            newSHTObj2.MRC_Number__c = mrcRetMixMrcMap.get(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG98');
                        }
                    }
                    newSHTObj2.Customer__c = dataObj.accId;

                    newSHTObj2.Location__c = dataObj.locationId;
                    newSHTObj2.Product_Category__c = 'ULG98';
                    //START - Rahul Sharma | Date - 28-Jan-2021 : Updated logic to add actual BSP and MSP.
                    //newSHTObj2.BSP__c=dataObj.finalbspCal;
                    //newSHTObj2.MSP__c=dataObj.finalSalesPriceCal;
                    if(!mrcNoVsSalesPriceWrapMap.isEmpty() && mrcNoVsSalesPriceWrapMap.containsKey(newSHTObj2.MRC_Number__c)){
                        newSHTObj2.BSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj2.MRC_Number__c).BSP;
                        newSHTObj2.MSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj2.MRC_Number__c).MSP;
                    }
                    else{
                        newSHTObj2.BSP__c = dataObj.finalbspCal;
                        newSHTObj2.MSP__c = dataObj.finalSalesPriceCal;
                    }
                    //END - Rahul Sharma | Date - 28-Jan-2021 : Updated logic to add actual BSP and MSP.
                    //START - Rahul Sharma | Date - 28-Jan-2021 : Removed logic for target margin.
                    /*if(newSHTObj2.MSP__c!= null && newSHTObj2.BSP__c !=null){
                        newSHTObj2.Target_Margin__c=newSHTObj2.MSP__c-newSHTObj2.BSP__c;
                    }*/
                    //END - Rahul Sharma | Date - 28-Jan-2021 : Removed logic for target margin.
                    newSHTObj2.Status__c = 'Saved';
                    if(dataObj.isZeroPriceDeal){
                        newSHTObj2.SP_100L__c=0;
                    }else{
                        newSHTObj2.SP_100L__c = dataObj.pricePerVol + decimal.valueOf(Label.RV_Surcharge_98); // Enetred Price by End User
                    }
                    //START - Rahul Sharma | Date - 28-Jan-2021 : Updated calculation logic for target margin.
                    if(newSHTObj2.SP_100L__c != null && newSHTObj2.BSP__c != null){
                        newSHTObj2.Target_Margin__c = newSHTObj2.SP_100L__c - newSHTObj2.BSP__c;
                    }
                    //END - Rahul Sharma | Date - 28-Jan-2021 : Updated calculation logic for target margin.
                    newSHTObj2.Select__c= true;
                    newSHTObj2.Tranche__c = trancheVal;
                    newSHTObj2.Volume_CBM__c=dataObj.volumeCBM* 0.05;
                    newSHTObj2.Deal_Comment__c=dataObj.Comment;
                    newSHTObj2.Contract_Start__c=ContractStrtDateToBeSaved;
                    newSHTObj2.Contract_End_Date__c=ContractEndDateToBeSaved;
                    newSHTObj2.Sales_Type__c = 'Obam Sales';
                    if(dataObj.isPricingTaxed != null)
                        newSHTObj2.IsPricingTaxed__c=dataObj.isPricingTaxed;
                    if(dataObj.pricingCondition != null)
                        newSHTObj2.Price_Condition__c=dataObj.pricingCondition;
                    if(dataObj.atpVoltoBeReduced != null)
                        newSHTObj2.IsATPVolumeReduced__c=dataObj.atpVoltoBeReduced;
                    if(dataObj.isVolToBeHedged != null)
                        newSHTObj2.IsVolumeHedged__c=dataObj.isVolToBeHedged;
                    if(dataObj.isZeroPriceDeal != null)
                        newSHTObj2.IsZeroPriceDeal__c=dataObj.isZeroPriceDeal;
                    if(dataObj.isGsapDealCreateOn != null)
                        newSHTObj2.IsGsapDealCreateOn__c=dataObj.isGsapDealCreateOn;
                    if(dataObj.isGsapDealCancelOn != null)
                        newSHTObj2.IsGsapDealCancelOn__c=dataObj.isGsapDealCancelOn;
                }
                if(newSHTObj1 != null && retailMixAdded ){
                    saveList.add(newSHTObj1);
                }
                if(newSHTObj2 != null && retailMixAdded){
                    saveList.add(newSHTObj2);
                }
            }
        }

        Set<Id> insertedIds= new Set<Id>();
        List<sht__c> shtLst = new List<sht__c>();
        if(!saveList.isEmpty()){
            List<SHT__c> newSaveLst= new List<SHT__c>();
            newSaveLst.addAll(saveList);
            try{
                Schema.DescribeSObjectResult s = sht__c.sObjectType.getDescribe();
                if(s.isCreateable()){
                    insert  newSaveLst;
                }

            }
            catch(Exception e){
                System.debug('Exception ==>'+e);
            }

            shtSavedWrap=getSavedSHTDeal();
        }
        srchSaveWrp.savedResult=shtSavedWrap;
        return srchSaveWrp;
    }

    public static RV_SPCalculationController.salesPriceCalAndAuditWrap
    getSavedDealPricePerMrc(Set<Id> mrcIds,string contractStartDate,string contractEndDate){
        RV_SPCalculationController.salesPriceCalAndAuditWrap salesPrcWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        List<Mrc__c> mrcLst= new List<Mrc__c>();
        if(mrcIds.size()>0){
            mrcLst=getMrcRecords(mrcIds);
        }
        salesPrcWrp=RV_SPCalculationController.getCalulatedSp(mrcLst,date.valueOf(contractStartDate),date.valueOf(contractEndDate));
        return salesPrcWrp;
    }


    @AuraEnabled
    //START - Rahul Sharma | Date - 03-Feb-2021 | PBI-702438 : Updated method to search MRCs based on either Sold-To account Id or Ship-To number.
    public static acctSearchWrapper searchDependentShipToMRC(string acctId, String shipToNum){
        /*Set<String> lstMrcNo = new Set<String>();
        Set<String> poTypeSet = new Set<String>();
        Set<String> plantNameSet = new Set<String>();
        Set<String> motSet = new Set<String>();
        list<string> mrcNoLst= new list<string>();
        list<string> poTypeLst= new list<string>();
        list<string> plantNameLst= new list<string>();
        list<string> motLst= new list<string>();*/
        Map<String, String> mrcNoVsMrcHeadMap = new Map<String, String>();
        Map<String, String> mrcNoVsMotMap = new Map<String, String>();
        Map<String, String> mrcNoVsPlantMap = new Map<String, String>();
        Map<String, String> mrcNoVsPoTypeMap = new Map<String, String>();
        Id recTypeId=Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        acctSearchWrapper accwrp= new acctSearchWrapper();
        String query = 'SELECT MRC_Number__c, '+
                'Ship_to_Number__c, '+
                'PO_Type__c, '+
                'MRC__c.Name, '+
                'Shipping_Condition__c, '+
                'Product__r.Commodity_Grade_L2__c, '+
                'Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c, '+
                'Plant__c,Plant__r.Name,Plant__r.Country__c  from MRC__c WHERE Active__c = true';
        if(!String.isEmpty(acctId) || !String.isEmpty(shipToNum)){
            if(!String.isEmpty(acctId))
                query += ' AND Sold_To__c =: acctId';
            else if(!String.isEmpty(shipToNum))
            {
                if(!shipToNum.startsWith('0'))
                    shipToNum = '00'+ shipToNum;
                else if(shipToNum.startsWith('00'))
                    shipToNum = shipToNum;
                else if(shipToNum.startsWith('0'))
                    shipToNum = '0'+ shipToNum;

                query+= '  AND Ship_to_Number__c =: shipToNum';
            }

            query += ' AND RecordTypeId =: recTypeId ORDER BY Plant__r.Name';
            try{
                List<MRC__c> mrcLst= Database.query(query);
                Map<Decimal,Shipping_Condition_Mapping__mdt> shippingCondMap = getShippingConditionMap();
                if(mrcLst.size()>0){
                    for(Mrc__c mr:mrcLst){
                        if(mr.PO_Type__c!= null){
                            //poTypeSet.add(mr.PO_Type__c);
                            mrcNoVsPoTypeMap.put(mr.Name, mr.PO_Type__c);
                        }
                        if(mr.Shipping_Condition__c != null){
                            if(shippingCondMap.containsKey(mr.Shipping_Condition__c)
                                    && shippingCondMap.get(mr.Shipping_Condition__c).MOT__c != null){
                                //motSet.add(shippingCondMap.get(mr.Shipping_Condition__c).MOT__c+'-'+mr.Shipping_Condition__c);
                                mrcNoVsMotMap.put(mr.Name, shippingCondMap.get(mr.Shipping_Condition__c).MOT__c+'-'+mr.Shipping_Condition__c);
                            }
                        }
                        if(mr.Plant__c !=null){
                            //plantNameSet.add(mr.Plant__r.Name);
                            mrcNoVsPlantMap.put(mr.Name, mr.Plant__r.Name);
                        }
                        if(mr.MRC_Number__c != null){
                            //lstMrcNo.add(mr.MRC_Number__c);
                            mrcNoVsMrcHeadMap.put(mr.Name, mr.MRC_Number__c);
                        }
                    }
                }
                /*poTypeLst.addAll(poTypeSet);
                mrcNoLst.addAll(lstMrcNo);
                plantNameLst.addAll(plantNameSet);
                motLst.addAll(motSet);
                accwrp.plantLst=plantNameLst;
                accwrp.poTypeLst=poTypeLst;
                accwrp.mrcLst=mrcNoLst;
                accwrp.motLst=motLst;*/
                accwrp.mrcNoVsMrcHeadMap = mrcNoVsMrcHeadMap;
                accwrp.mrcNoVsMotMap = mrcNoVsMotMap;
                accwrp.mrcNoVsPlantMap = mrcNoVsPlantMap;
                accwrp.mrcNoVsPoTypeMap = mrcNoVsPoTypeMap;
            }
            catch(Exception e){
                System.debug('searchDependentShipToMRC() >> Exception: '+e.getMessage() + ' Line Number: '+e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
            //END - Rahul Sharma | Date - 03-Feb-2021 | PBI-702438 : Updated method to search MRCs based on either Sold-To account Id or Ship-To number.
        }
        return accwrp;
    }

    //START - Rahul Sharma | Date - 03-Feb-2021 | PBI-702438 : Removed extra server call.
    /*@AuraEnabled
    public static acctSearchWrapper getSelAccountPOTypeMRC(string soldTo,string poType){
        acctSearchWrapper acwrp= new acctSearchWrapper();
        Set<String> plantNameSet = new Set<String>();
        Set<String> motSet = new Set<String>();
        Set<String> lstMrcNo = new Set<String>();
        list<string> mrcNoLst= new list<string>();
        list<string> poTypeLst= new list<string>();
        list<string> plantNameLst= new list<string>();
        list<string> motLst= new list<string>();
        Id recTypeId=Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
        Map<Decimal,Shipping_Condition_Mapping__mdt> shippingCondMap=getShippingConditionMap();
        List<MRC__c> mrcLst=[select MRC_Number__c,Ship_to_Number__c,PO_Type__c,Shipping_Condition__c,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,
                             Plant__c,Plant__r.Name  from MRC__c where Sold_To__c= :soldTo
                             and recordTypeId=:recTypeId and PO_Type__c=:poType];
        if(mrcLst.size()>0){
            for(MRC__c mr:mrcLst){
                if(mr.Shipping_Condition__c != null){
                             if(shippingCondMap.containsKey(mr.Shipping_Condition__c)
                                && shippingCondMap.get(mr.Shipping_Condition__c).MOT__c != null){
                                    motSet.add(shippingCondMap.get(mr.Shipping_Condition__c).MOT__c+'-'+mr.Shipping_Condition__c);
                                }
                         }
                         if(mr.Plant__c !=null){
                             plantNameSet.add(mr.Plant__r.Name);
                         }
                         if(mr.MRC_Number__c != null){
                             lstMrcNo.add(mr.MRC_Number__c);
                         }
            }
        }
        mrcNoLst.addAll(lstMrcNo);
        plantNameLst.addAll(plantNameSet);
        motLst.addAll(motSet);
        acwrp.plantLst=plantNameLst;
        acwrp.mrcLst=mrcNoLst;
        acwrp.motLst=motLst;
        return acwrp;
    }*/
    //END - Rahul Sharma | Date - 03-Feb-2021 | PBI-702438 : Removed extra server call.

    public static Map<Decimal,Shipping_Condition_Mapping__mdt> getShippingConditionMap(){
        Map<Decimal,Shipping_Condition_Mapping__mdt> shippingCondMap= new Map<Decimal,Shipping_Condition_Mapping__mdt>();
        List<Shipping_Condition_Mapping__mdt> shippingLst=[Select id,MOT__c,MoTKey__c,Shipping_Condition__c,Margin_Type__c
        from Shipping_Condition_Mapping__mdt];
        for(Shipping_Condition_Mapping__mdt scm:shippingLst){
            shippingCondMap.put(Integer.valueOf(scm.Shipping_Condition__c),scm);
        }
        return shippingCondMap;
    }
    @AuraEnabled
    public static List<Account> searchRecords(String soldTo){
        String j= '%'+soldTo+'%';
        Id revRcdTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        //START - Rahul Sharma | Date - 17-Feb-2021 | PBI-712394 : Updated query to filter out inactive accounts from search.
        List<Account> accList = [SELECT Id,
                Name FROM Account WHERE Name LIKE :j AND
        RecordTypeId =:revRcdTypId AND
        Customer_Type__c = 'Sold To' AND
        Has_MRC__c = true AND
        (Rv_AT01_Deletion_Flag__c = false OR
        Rv_DE01_Deletion_Flag__c = false)];
        //END - Rahul Sharma | Date - 17-Feb-2021 | PBI-712394 : Updated query to filter out inactive accounts from search.
        return accList;
    }

    @AuraEnabled
    public static SHTWrapper getAllSHTDeals(){
        SHTWrapper shtWrp=new SHTWrapper();
        set<String> options = new set<String>();
        List<String> optionSet = new List<String>();
        Schema.DescribeFieldResult fieldResult = SHT__c.Cancellation_Reason_Label__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        options.remove('Saved Deal');
        optionSet.addAll(options);

        shtWrp.CompletedDeal=getCompletedSHTDeal('TODAY','Completed','Me');
        shtWrp.savedDeal=getSavedSHTDeal();
        shtWrp.reasonList=optionSet;
        shtWrp.ContractStartDate= system.today(); //Default Contract Start Date
        shtWrp.ContractEndDate= system.today().addDays(14);//Default Contract End Date

        //AdditionalFix_166256_29Apr2019_Soumyajit starts
        shtWrp.hasEditAccess = true;

        //Check permission for SHT object
        if(!(sht__c.sObjectType.getDescribe().isCreateable()
                && sht__c.sObjectType.getDescribe().isUpdateable()))
            shtWrp.hasEditAccess = false;

        //AdditionalFix_166256_29Apr2019_Soumyajit ends
        return shtWrp;

    }

    @AuraEnabled
    public static List<SHTDisplayWrap> getSavedSHTDeal(){
        List<SHTDisplayWrap> wrapList = new List<SHTDisplayWrap>();
        string LoggedInUsr=UserInfo.getUserId();
        //PBI_166252_DataCleanup_Lakshmi_1stOct2019==> Removed Quantitiy_CBM__c from query
        String queryString = 'select Id,Name,Customer__c,Customer__r.Name,Volume_CBM__c,Product_Category__c,Cancellation_Reason_Label__c,'+
                'MRC__c,MRC__r.Name,SP_100L__c,SHT_Contract_Number__c,Sales_Type__c,Status__c,Deal_Comment__c,Ship_To__c,Material_Name__c,'+
                'Tranche__c,Location__c,Location__r.Name,BSP__c,Sales_Price__c,OTM__c,MSP__c,Target_Margin__c,Material_No__c,'+
                'Contract_Start__c,Contract_End_Date__c,IsZeroPriceDeal__c,Select__c,PO_Type__c'+  //Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added PO_Type__c field in the query.
                ' from SHT__c where CreatedById =:LoggedInUsr AND Status__c = '+'\'Saved\''+'order by createdDate desc';

        // Removed --> AND createdDate = TODAY  from above query

        List<SHT__c> shtList = Database.query (queryString);
        if(shtList.size()>0){
            for(SHT__c sh:shtList){
                SHTDisplayWrap shtDspWrp= new  SHTDisplayWrap();
                shtDspWrp.shtRecordId=sh.Id;
                shtDspWrp.shtNo=sh.Name;
                shtDspWrp.mrcId=sh.Mrc__c;
                shtDspWrp.MrcNo=sh.MRC__r.Name;
				shtDspWrp.CustomerId=sh.Customer__c;
                shtDspWrp.Customer=sh.Customer__r.Name;
                shtDspWrp.shipToNumber=sh.Ship_To__c;
				shtDspWrp.locationId=sh.Location__c;
                shtDspWrp.location=sh.Location__r.name;
                shtDspWrp.product=sh.Product_Category__c;
                if(sh.Material_No__c != null && sh.Material_No__c.length()>4)
                    shtDspWrp.materialNo=sh.Material_No__c.right(4);
                shtDspWrp.materialName=sh.Material_Name__c;
                if(sh.bsp__c != null)
                    shtDspWrp.bsp=sh.bsp__c.setScale(2, RoundingMode.HALF_UP);
                if(sh.Target_Margin__c != null)
                    shtDspWrp.targetMargin=sh.Target_Margin__c.setScale(2, RoundingMode.HALF_UP);
                if(sh.msp__c != null)
                    shtDspWrp.msp=sh.msp__c.setScale(2, RoundingMode.HALF_UP);
                shtDspWrp.volCbm=sh.Volume_CBM__c.round(System.RoundingMode.HALF_UP);
                shtDspWrp.contractStartDate=sh.Contract_Start__c;
                shtDspWrp.contractEndDate=sh.Contract_End_Date__c;
                if(sh.SP_100L__c != null){
                    shtDspWrp.spPer100L=sh.SP_100L__c;
                }
                shtDspWrp.selected=sh.Select__c;
                shtDspWrp.contractStartDate=sh.Contract_Start__c;
                shtDspWrp.contractEndDate=sh.Contract_End_Date__c;
                shtDspWrp.dealStatus=sh.Status__c;
                shtDspWrp.Comment=sh.Deal_Comment__c;
                shtDspWrp.isZeroPriceDeal=sh.IsZeroPriceDeal__c;
                //START - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                shtDspWrp.poType = sh.PO_Type__c;
                //END - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                wrapList.add(shtDspWrp);
            }
        }
        return wrapList;
    }

    @AuraEnabled
    public static List<SHTDisplayWrap> updateSHTObjectRecord(String dataList){
        List<SHTDisplayWrap>  shtCmpwrp= new List<SHTDisplayWrap>();
        Map<String,RV_SPCalculationController.salesPriceWrap> mrcSalesPrcWrp=new Map<String,RV_SPCalculationController.salesPriceWrap>();
        List<SHTDisplayWrap> listToUpdate = (List<SHTDisplayWrap>)JSON.deserialize(dataList, List<SHTDisplayWrap>.class);
        Map<String,SHTDisplayWrap> wrapMap = new Map<String,SHTDisplayWrap>();
        Map<string,Id> mrcShtIdMap = new Map<string,Id>();
        set<Id> shtIds= new set<Id>();
        set<Id> mrcId = new set<Id>();
        date contractStartDate;
        date contractEndDate;
        for(SHTDisplayWrap wrapObj : listToUpdate){
            shtIds.add(wrapObj.shtRecordId);
            mrcId.add(wrapObj.MrcId);
            mrcShtIdMap.put(wrapObj.MrcNo,wrapObj.shtRecordId);
            contractStartDate=wrapObj.contractStartDate;
            contractEndDate=wrapObj.contractEndDate;
        }
        //Updating the Date for Recalculating Price Of Past Date Deals
        //START - Rahul Sharma | Date - 13-May-2021 | PBI-728047 : Added missing logic to consider prompt dates for past dated deals.
        /*Date StrtDateForPastDeals;
        Date EndDateForPastDeals;
        if(contractStartDate< system.today()){
            StrtDateForPastDeals=System.today();
            EndDateForPastDeals=System.today().addDays(14);
        }*/
        if(contractStartDate < system.today()){
            contractStartDate = System.today();
            if(contractEndDate <= system.today())
                contractEndDate = System.today();
            else
                    contractEndDate = System.today().addDays(13);
        }
        //END - Rahul Sharma | Date - 13-May-2021 | PBI-728047 : Added missing logic to consider prompt dates for past dated deals.
        //Fetching Price for ALL deals to be Confirmed
        RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        List<RV_SPCalculationController.salesPriceWrap> savedDealSpWrp = new List<RV_SPCalculationController.salesPriceWrap>();
        List<RV_SPCalculationController.priceAuditWrap> salesPriceAuditInsertLst= new List<RV_SPCalculationController.priceAuditWrap>();
        spAdtWrp = getSavedDealPricePerMrc(mrcId,string.valueOf(contractStartDate),
                string.valueOf(contractEndDate));
        savedDealSpWrp=spAdtWrp.salesPriceWrpLst;
        salesPriceAuditInsertLst=spAdtWrp.auditWrpLst;
        //mrcSalesPrcWrp for Storing Latest Price
        for(integer i=0;i<savedDealSpWrp.size();i++){
            mrcSalesPrcWrp.put(savedDealSpWrp[i].mrcNo,savedDealSpWrp[i]);
        }
        //Logic for Updating sht Id in Audit Records
        for(integer i=0;i<salesPriceAuditInsertLst.size();i++){
            if(mrcShtIdMap.containsKey(salesPriceAuditInsertLst[i].mrcNo)){
                salesPriceAuditInsertLst[i].shtId=mrcShtIdMap.get(salesPriceAuditInsertLst[i].mrcNo);
            }
        }
        //Inserting Audit Records
        if(salesPriceAuditInsertLst.size()>0){
            //Rv_PriceAuditController.insertPriceAuditWrap(salesPriceAuditInsertLst);
            System.enqueueJob(new Rv_PriceAuditController(salesPriceAuditInsertLst));//437443 194. Performance of Salesforce (speed)
        }
        List<sht__c> shtLst = new List<sht__c>();
        if(shtIds.size()>0){
            shtLst = [Select Id,status__c,MRC_Number__c,BSP__c,MSP__c,Target_Margin__c,
                    Contract_Start__c,Contract_End_Date__c,Deal_Comment__c
            from sht__c where Id IN:shtIds
            and Status__c !='Auto-Completed'];
        }
        for(SHTDisplayWrap wrapObj : listToUpdate){
            if(wrapObj.selected==true && wrapObj.volCbm != null && !''.equals(wrapObj.volCbm)){
                wrapMap.put(wrapObj.shtRecordId,wrapObj);
            }
        }
        for(SHT__c shtObj :shtLst ){
            if(wrapMap.keySet().contains(shtObj.Id))
            {
                if(wrapMap.get(shtObj.id).spPer100L != null){
                    shtObj.SP_100L__c=wrapMap.get(shtObj.id).spPer100L;
                }
                shtObj.Volume_CBM__c=wrapMap.get(shtObj.id).volCbm;
                shtObj.Status__c = 'Completed';

                //Updating New Price
                if(mrcSalesPrcWrp.containskey(shtObj.MRC_Number__c) && (mrcSalesPrcWrp.get(shtObj.MRC_Number__c).BSP != null)){
                    shtObj.BSP__c=(mrcSalesPrcWrp.get(shtObj.MRC_Number__c)).BSP;
                }
                if(mrcSalesPrcWrp.containskey(shtObj.MRC_Number__c) && (mrcSalesPrcWrp.get(shtObj.MRC_Number__c).MSP != null)){
                    shtObj.MSP__c=(mrcSalesPrcWrp.get(shtObj.MRC_Number__c)).MSP;
                }
                if(shtObj.BSP__c != null && shtObj.MSP__c!= null){
                    shtObj.Target_Margin__c=shtObj.MSP__c -shtObj.BSP__c;
                }
                shtObj.Contract_Start__c=wrapMap.get(shtObj.id).contractStartDate;
                shtObj.Contract_End_Date__c=wrapMap.get(shtObj.id).contractEndDate;
                shtObj.Deal_Comment__c=wrapMap.get(shtObj.id).Comment;
            }
        }
        try{
            Schema.DescribeSObjectResult s = sht__c.sObjectType.getDescribe();
            if(s.isUpdateable()){
                Database.update(shtLst, false);
            }
        }catch(Exception e){
        }
        shtCmpwrp=getCompletedSHTDeal('TODAY','Completed','Me');
        return shtCmpwrp;
    }

    @AuraEnabled
    public static List<SHTDisplayWrap> getCompletedSHTDeal(string day,string status,string createdby){
        List<SHTDisplayWrap> wrapList = new List<SHTDisplayWrap>();
        string LoggedInUsr;
        String queryPart;
        string queryPartTwo;
        if(day =='TODAY')
            queryPart= 'createdDate = TODAY';
        //Fix_170853_13May2019_Soumyajit starts
        /*else if(day=='YESTERDAY')
        	queryPart= 'createdDate = YESTERDAY';*/
        else if(day=='LAST_DEAL_DATE')
        {
            Date lastDealDate= getLastDealDate(status);
            String queryCreatedDate1 = string.valueOf(lastDealDate)+'T00:00:00Z';
            String queryCreatedDate2 = string.valueOf(lastDealDate+1)+'T00:00:00Z';
            queryPart= ' createdDate >= '+queryCreatedDate1 +' and createdDate < '+queryCreatedDate2;
        }
        //Fix_170853_13May2019_Soumyajit starts
        else if(day=='THIS_WEEK')
            queryPart= 'createdDate = THIS_WEEK';
        //Fix_170853_13May2019_Soumyajit starts
        /*else
            queryPart= 'createdDate  < THIS_WEEK';*/
        else if(day=='LAST_WEEK')
            queryPart= 'createdDate  >= LAST_WEEK and createdDate < TODAY';
        else
                queryPart= 'createdDate  >= LAST_N_WEEKS:3 and createdDate < TODAY';
        //Fix_170853_13May2019_Soumyajit ends
        if(createdby=='Me'){
            LoggedInUsr = UserInfo.getUserId();
            queryPartTwo= 'where CreatedById =:LoggedInUsr AND Status__c = :status ' ;
        }
        else{
            queryPartTwo= 'where Status__c = :status ';
        }
        //Cancellation Reason Update
        //PBI_166252_DataCleanup_Lakshmi_1stOct2019==> Removed Quantitiy_CBM__c from query
        String queryString = 'select Id,Name ,Customer__c,Customer__r.Name,Volume_CBM__c,Product_Category__c,'+
                'MRC__c,MRC__r.Name,SP_100L__c,BSP__c,OTM__c,Target_Margin__c,SHT_Contract_Number__c,Sales_Type__c,Status__c,Ship_To__c,Effective_Margin__c,MSP__c,'+
                'Tranche__c,Cancellation_Reason__c,Location__c,Location__r.Name,Material_Name__c,Material_No__c,CreatedDate,'+
                'Contract_Start__c,Contract_End_Date__c,SAP_Contract_Number__c,Deal_Comment__c,IsZeroPriceDeal__c,Cancellation_Reason_Label__c,Error__c, PO_Type__c'+  //Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added Error__c and PO_Type__c fields in the query.
                ' from SHT__c '+queryPartTwo+
                ' AND ' +queryPart +' order by Name desc';
        // ' AND ' +queryPart +' order by createdDate desc';//Fix_PBI_403668_Lakshmi_12202019


        List<SHT__c> shtList = Database.query (queryString);

        if(shtList.size()>0){
            for(SHT__c sh:shtList){
                SHTDisplayWrap shtDspWrp= new  SHTDisplayWrap();
                shtDspWrp.shtRecordId=sh.Id;
                shtDspWrp.shtNo=sh.name;
				shtDspWrp.tranche = sh.Tranche__c;		  
                shtDspWrp.MrcNo=sh.MRC__r.Name;
                shtDspWrp.MrcId=sh.MRC__c;
                shtDspWrp.Customer=sh.Customer__r.Name;
				shtDspWrp.CustomerId =sh.Customer__c;
                shtDspWrp.locationId =sh.Location__c; 
                shtDspWrp.location=sh.Location__r.name;
                shtDspWrp.product=sh.Product_Category__c;
                shtDspWrp.shipToNumber=sh.Ship_To__c;
                //system.debug('material no==>'+sh.Material_No__c);
                if(sh.Material_No__c != null && sh.Material_No__c.length()>4)
                    shtDspWrp.materialNo=sh.Material_No__c.right(4);
                shtDspWrp.materialName=sh.Material_Name__c;
                shtDspWrp.volCbm=sh.Volume_CBM__c.round(System.RoundingMode.HALF_UP);
                shtDspWrp.targetMargin=sh.Effective_Margin__c;
                shtDspWrp.msp=sh.MSP__c;
                if(sh.SP_100L__c != null)
                    shtDspWrp.spPer100L=sh.SP_100L__c;
				if(sh.bsp__c != null)
                    shtDspWrp.bsp=sh.bsp__c.setScale(2, RoundingMode.HALF_UP);
               // if(sh.Target_Margin__c != null)      //Sampada Bhat | Date : 24-Dec-2021
                 //   shtDspWrp.targetMargin=sh.Target_Margin__c.setScale(2, RoundingMode.HALF_UP);
                if(sh.msp__c != null)       //Sampada Bhat | Date : 24-Dec-2021
                    shtDspWrp.msp=sh.msp__c.setScale(2, RoundingMode.HALF_UP);
      
                if(sh.OTM__c != null){           //Sampada Bhat | Date : 24-Dec-2021
                    shtDspWrp.otm = sh.OTM__c.setScale(2, RoundingMode.HALF_UP);
                }
                shtDspWrp.contractStartDate=sh.Contract_Start__c;
                shtDspWrp.contractEndDate=sh.Contract_End_Date__c;
				shtDspWrp.c_StartDate=formatdate(sh.Contract_Start__c);
                shtDspWrp.c_EndDate=formatdate(sh.Contract_End_Date__c);
                shtDspWrp.dealStatus=sh.Status__c;
                shtDspWrp.cancellationReason=sh.Cancellation_Reason_Label__c;
                shtDspWrp.Comment=sh.Deal_Comment__c;
                shtDspWrp.gsapContract=sh.SAP_Contract_Number__c;
				if(!String.isEmpty(sh.SAP_Contract_Number__c)){
                    shtDspWrp.gsapContractCheck=true;
                }else{
                    shtDspWrp.gsapContractCheck=false;
                }
                //START - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                if(String.isEmpty(shtDspWrp.gsapContract) && sh.PO_Type__c != 'Dummy' && (sh.Customer__r.Name != 'Avia Co. (Dummy)')){
                    shtDspWrp.gsapError = sh.Error__c;
					//added aspart of Bug BUG 1261339
                    shtDspWrp.gsapErrorCheck = (sh.Error__c == null || sh.Error__c == '' ) ? false : true;
                }else{
                    shtDspWrp.gsapErrorCheck = false;
                }
                shtDspWrp.poType = sh.PO_Type__c;
                //END - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                shtDspWrp.isZeroPriceDeal=sh.IsZeroPriceDeal__c;
				if(shtDspWrp.Comment != null && (shtDspWrp.Comment).contains('cancelled deal SHT - ') &&
                 sh.createdDate.date() == date.today() && sh.Status__c == 'Completed'){
                    shtDspWrp.highlightDeal = 'background-color: #90f181;';
                }else{
                    shtDspWrp.highlightDeal = 'background-color:rgb(255, 255, 255);';
                }
                wrapList.add(shtDspWrp);
            }

        }
        return wrapList;
    }

	public static String formatdate(Date shdate){
                datetime dt = (datetime)shdate;
                system.debug(dt.format('dd-MM-yyyy'));
                return dt.format('dd-MM-yyyy');
        }
    //Fix_170853_13May2019_Soumyajit starts
    @TestVisible
    private static Date getLastDealDate(String status)
    {
        Date returnLastDealDate = System.today().adddays(-1);
        DateTime returnLastDealDateTime;

        String LoggedInUsr = UserInfo.getUserId();
        String queryString = 'select max(createddate)maxDate from SHT__c where CreatedById =:LoggedInUsr and Status__c = :status and createddate<TODAY';
        list<aggregateResult> shtMaxDate = Database.query (queryString);
        if(!shtMaxDate.isEmpty() && shtMaxDate[0].get('maxDate') != null)
            returnLastDealDateTime = DateTime.valueof(shtMaxDate[0].get('maxDate'));

        if(returnLastDealDateTime != null)
            returnLastDealDate = date.newinstance(returnLastDealDateTime.year(), returnLastDealDateTime.month(), returnLastDealDateTime.day());

        //System.debug('returnLastDealDate='+returnLastDealDate);
        return returnLastDealDate;
    }

    @AuraEnabled
    public static Map<String, String> getUserList ()
    {
        Map<String, String> returnUserList = new Map<String, String>();

        returnUserList.put('ME','Me');
        returnUserList.put('ALL','All');

        if (Schema.sObjectType.PermissionSetAssignment.isAccessible())
        {
            PermissionSetAssignment[] psa = [SELECT Id, AssigneeId, Assignee.name FROM PermissionSetAssignment where PermissionSet.name='RV_DI' order by Assignee.name];

            if(psa.size()>0)
            {
                for (PermissionSetAssignment p : psa)
                {
                    if(!p.Assignee.name.equals(UserInfo.getName()))
                        returnUserList.put(p.AssigneeId,p.Assignee.name);
                }
            }
        }
        //System.debug('returnUserList =' + returnUserList);
        return returnUserList;
    }

    @AuraEnabled
    public static SHTDisplayWithAdvanceFilterWrap getCompletedSHTDealWithAdvanceFilterWrap(string createdOnStartDate,	//Required
            string createdOnEndDate,	//Required
            string dayInterval,		//Required
            string status,			//Required
            string createdBy,			//Required
            string soldTo,				//Required
            string sht,
            Boolean internetSales, //270192_OLFDealCancel_08Jul2019_Soumyajit
            String poType){
        SHTDisplayWithAdvanceFilterWrap returnSHTDisplayWithAdvanceFilterWrap = new SHTDisplayWithAdvanceFilterWrap();
        List<SHTDisplayWrap> returnSHTDisplayWrap = new List<SHTDisplayWrap>();
		Map<String,String> returnSHTListMap = new Map<String,String>();
        Map<String,String> returnSoldToListMap = new Map<String,String>();
        Map<String,String> returnpoTypeListMap = new Map<String,String>();
        List<String> returnSHTList = new List<String>();
        List<String> returnSoldToList = new List<String>();
        List<String> returnpoTypeList = new List<String>(); //Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : adding returnpoTypeList for the return wrapper.
        Date createdOnStDate;
        Date createdOnEdDate;
        Boolean returnDateValid = true;

        String queryCreatedDate1, queryCreatedDate2;

        if(createdOnStartDate == null)
            createdOnStDate = System.today();
        else
                createdOnStDate = Date.valueOf(createdOnStartDate);

        if(createdOnEndDate == null)
            createdOnEdDate = System.today();
        else
                createdOnEdDate = Date.valueOf(createdOnEndDate);

        if(dayInterval != null)
        {
            if(createdOnStDate.daysBetween(createdOnEdDate) > Integer.valueOf(dayInterval))
                returnDateValid = false;
        }

        //System.debug('Date check is ' + returnDateValid);

        if (returnDateValid)
        {
            if(sht== null || sht.length()==0 || sht.equals('()'))
                sht= 'ALL';
            if(soldTo == null || soldTo.length()==0 || soldTo.equals('()'))
                soldTo = 'ALL';

            queryCreatedDate1 = string.valueOf(createdOnStDate)+'T00:00:00Z';
            queryCreatedDate2 = string.valueOf(createdOnEdDate+1)+'T00:00:00Z';

            //System.debug(queryCreatedDate1);
            //System.debug(queryCreatedDate2);
            //PBI_166252_DataCleanup_Lakshmi_1stOct2019==> Removed Quantitiy_CBM__c from query
            String SearchQuery = 'select Id,Name ,Customer__c,Customer__r.Name,Volume_CBM__c,Product_Category__c,'+
                    'MRC__c,MRC__r.Name,SP_100L__c,SHT_Contract_Number__c,Sales_Type__c,Status__c,Ship_To__c,Effective_Margin__c,MSP__c,'+
                    'Tranche__c,Cancellation_Reason__c,Location__c,Location__r.Name,Material_Name__c,Material_No__c,createdDate,'+
                    'Contract_Start__c,Contract_End_Date__c,SAP_Contract_Number__c,Deal_Comment__c,IsZeroPriceDeal__c,Cancellation_Reason_Label__c,Error__c,PO_Type__c '+ //Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added Error__c field in the query.
                    ' from SHT__c where createdDate >= '+queryCreatedDate1 +' and createdDate < '+queryCreatedDate2;

            SearchQuery = SearchQuery + ' and Status__c = :status ';

            if(createdBy == '' || createdBy.toUpperCase().equals('ME')){
                //System.debug('For Logged in user');
                string LoggedInUsr = UserInfo.getUserId();
                SearchQuery = SearchQuery + ' and CreatedById =:LoggedInUsr' ;
            }
            else if (createdBy.toUpperCase().equals('ALL')){
                //System.debug('For ALL users');
                SearchQuery = SearchQuery;
            }
            else
            {
                Id createdUserId = Id.valueOf(createdBy);
                //System.debug('For THIS user :' +createdUserId);
                SearchQuery = SearchQuery + ' and CreatedById =:createdUserId' ;
            }

            if (!soldTo.toUpperCase().equals('ALL'))
                SearchQuery = SearchQuery + ' and Customer__r.Name = :soldTo ';

            if (!sht.toUpperCase().equals('ALL'))
                SearchQuery = SearchQuery + ' and Name = :sht ';
            if (!poType.toUpperCase().equals('ALL'))
                SearchQuery = SearchQuery + ' and  PO_Type__c =: poType ';
            //Fix_PBI_403668_Lakshmi_12202019
            SearchQuery = SearchQuery + ' and isOlfDeal__c = :internetSales order by Name desc'; //270192_OLFDealCancel_08Jul2019_Soumyajit

            //System.debug('SearchQuery: '+SearchQuery);
            List<SHT__c> shtList = Database.query (SearchQuery);

            if(shtList.size()>0){
                for(SHT__c sh:shtList){
                    SHTDisplayWrap shtDspWrp= new  SHTDisplayWrap();
                    shtDspWrp.shtRecordId=sh.Id;
                    shtDspWrp.shtNo=sh.name;
                    shtDspWrp.MrcNo=sh.MRC__r.Name;
                    shtDspWrp.MrcId=sh.MRC__c;
                    shtDspWrp.Customer=sh.Customer__r.Name;
                    shtDspWrp.location=sh.Location__r.name;
                    shtDspWrp.product=sh.Product_Category__c;
                    shtDspWrp.shipToNumber=sh.Ship_To__c;
                    if(sh.Material_No__c != null && sh.Material_No__c.length()>4)
                        shtDspWrp.materialNo=sh.Material_No__c.right(4);
                    shtDspWrp.materialName=sh.Material_Name__c;
                    shtDspWrp.volCbm=sh.Volume_CBM__c.round(System.RoundingMode.HALF_UP);
                    shtDspWrp.targetMargin=sh.Effective_Margin__c;
                    shtDspWrp.msp = sh.MSP__c != null ? sh.MSP__c.setScale(2) : null;
                    if(sh.SP_100L__c != null)
                        shtDspWrp.spPer100L=sh.SP_100L__c;
                    shtDspWrp.contractStartDate=sh.Contract_Start__c;
                    shtDspWrp.contractEndDate=sh.Contract_End_Date__c;
					shtDspWrp.c_StartDate=formatdate(sh.Contract_Start__c);
                    shtDspWrp.c_EndDate=formatdate(sh.Contract_End_Date__c);  
                    shtDspWrp.dealStatus=sh.Status__c;
                    shtDspWrp.cancellationReason=sh.Cancellation_Reason_Label__c;
                    shtDspWrp.Comment=sh.Deal_Comment__c;
                    shtDspWrp.gsapContract=sh.SAP_Contract_Number__c;
					if(!String.isEmpty(sh.SAP_Contract_Number__c)){
                        shtDspWrp.gsapContractCheck=true;
                    }else{
                        shtDspWrp.gsapContractCheck=false;
                    }
                    //START - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                    if(String.isEmpty(shtDspWrp.gsapContract) && (sh.Customer__r.Name != 'Avia Co. (Dummy)')){
                        shtDspWrp.gsapError = sh.Error__c;
					    shtDspWrp.gsapErrorCheck = true;
                    }else{
                        shtDspWrp.gsapErrorCheck = false;
                    }
                    shtDspWrp.poType = sh.PO_Type__c;
                    //END - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                    shtDspWrp.isZeroPriceDeal=sh.IsZeroPriceDeal__c;
					if(shtDspWrp.Comment != null && (shtDspWrp.Comment).contains('cancelled deal SHT - ') &&
                        sh.createdDate.date() == date.today() && sh.Status__c == 'Completed'){
                            shtDspWrp.highlightDeal = 'background-color: #90f181;';
                        }else{
                            shtDspWrp.highlightDeal = 'background-color:rgb(255, 255, 255);';
                        }
                    returnSHTDisplayWrap.add(shtDspWrp);
                }
            }

            if(returnSHTDisplayWrap.size()>0)
            {
                for(SHTDisplayWrap sd : returnSHTDisplayWrap){
                    if(!returnSoldToList.contains(sd.Customer) && soldTo.toUpperCase().equals('ALL')){
                        returnSoldToList.add(sd.Customer);
						returnSoldToListMap.put(sd.customer,sd.customer);
                    }else {
                        returnSoldToList.add(sd.Customer);
                        returnSoldToListMap.put(sd.customer,sd.customer);
                    }   
                    if(!returnSHTList.contains(sd.shtNo) && sht.toUpperCase().equals('ALL')) {
                        returnSHTList.add(sd.shtNo);
					returnSHTListMap.put(sd.shtNo,sd.shtNo);
                    }else{
                        returnSHTList.add(sd.shtNo);
                        returnSHTListMap.put(sd.shtNo,sd.shtNo);
                    }  
                    //START - Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : adding list of PO Types to the return wrapper.
                    if(!returnpoTypeList.contains(sd.poType) && poType.toUpperCase().equals('ALL')) {
					  returnpoTypeList.add(sd.poType);
                        returnpoTypeListMap.put(sd.poType,sd.poType);
                    }else{
                        returnpoTypeList.add(sd.poType);
                        returnpoTypeListMap.put(sd.poType,sd.poType);
                    } 
                }
                if(returnpoTypeList.size() > 0)
                    returnpoTypeList.sort();
                //END - Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : adding list of PO Types to the return wrapper.
                if(returnSoldToList.size()>0)
                    returnSoldToList.sort();
                if(returnSHTLIst.size()>0)
                    returnSHTList.sort();
            }
        }
        returnSHTDisplayWithAdvanceFilterWrap.SHTDisplayWrapList = returnSHTDisplayWrap;
        returnSHTDisplayWithAdvanceFilterWrap.SHTList = returnSHTList;
        returnSHTDisplayWithAdvanceFilterWrap.SoldToList = returnSoldToList;
		returnSHTDisplayWithAdvanceFilterWrap.SHTListMap = returnSHTListMap;
        returnSHTDisplayWithAdvanceFilterWrap.SoldToListMap = returnSoldToListMap;
        returnSHTDisplayWithAdvanceFilterWrap.poTypeListMap = returnpoTypeListMap;
        returnSHTDisplayWithAdvanceFilterWrap.DateValid = returnDateValid;
        returnSHTDisplayWithAdvanceFilterWrap.poTypeList = returnpoTypeList;    //Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : adding list of PO Types to the return wrapper.
        return returnSHTDisplayWithAdvanceFilterWrap;
    }

    @AuraEnabled
    public static date getMinPossibleContractStartDate(){
        return system.today().addDays(-30);
    }
    @AuraEnabled
    public static searchWrapMRC getContarctEndDate(string dateInput) {
        searchWrapMRC srcWrp= new searchWrapMRC();
        date newDate=date.valueOf(dateInput);
        date today = Date.today();
        integer noOfDays=13;
        if(newDate == today){
            noOfDays=14;
        }
        //Fix_252970_30Apr2019_Soumyajit starts
        //srcWrp.disableConEndDate = false;	//FixReverted_252970_07Aug2019_Soumyajit
        if(newDate < today){
            noOfDays=0;
            srcWrp.diffDays=0;
            srcWrp.conEndDate=today;
            srcWrp.maxdiffDays=0;
            srcWrp.maxEndDate=today;
            //srcWrp.disableConEndDate = true;	//FixReverted_252970_07Aug2019_Soumyajit
        }
        else{
            //Fix_252970_30Apr2019_Soumyajit ends
            integer daysBet= today.daysBetween(newDate);
            newDate=newDate.addDays(noOfDays);
            srcWrp.diffDays=daysBet;
            srcWrp.conEndDate=newDate;
            srcWrp.maxdiffDays=today.daysBetween(getMaxContractEndDate().addDays(-noOfDays));
            srcWrp.maxEndDate=getMaxContractEndDate();
        }//Fix_252970_30Apr2019_Soumyajit
        return srcWrp;
    }

    @AuraEnabled
    public static date getMaxContractEndDate(){
        date endOfCurrMonth=system.today().addMonths(1).toStartofMonth().addDays(-1);
        date endofM15Month=endOfCurrMonth.addMonths(15);
        return endofM15Month;
    }

    public static List<Mrc__c> getMrcRecords(Set<Id> mrcIds){
        List<Mrc__c> mrcList= new List<Mrc__c>();
        if(mrcIds.size()>0){
            mrcList = [select id,name,Plant__c,Plant__r.Name,Plant__r.Country__c,Po_Type__c,
                    Supply_Type__c,Product__c,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Plant_code__c,Product__r.Name,Material_Description__c,
                    Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,
                    Ship_to_Name__c, Valid_From_Date__c,Valid_To_Date__c,Shipping_Condition__c from MRC__c
            where Id IN :mrcIds and Valid_To_Date__c >= TODAY order by Name,Plant_code__c ASC];
        }
        return mrcList;
    }

    /*Method Name	:	getMrcData
    * Date			:	18-Mar-2020
    * Developer		:	Rahul Sharma
    * Description	:	get MRC records data*/
    @AuraEnabled
    //START | Rahul Sharma | Date - 22-Jul-2020 : Updated method with extra paramter called availableForOLF and also updated logic to only get MRCs available for OLF based on boolean value.
    public static List<MRCDataWrap>  getMrcData(String tranche ,String Mrcno ,String accId,
            String shipto,Boolean checked ,Boolean agoChk,
            Boolean igoChk,Boolean mogasChk,String poType,
            String plant,string mot,String contractStartDate,
            String contractEndDate,Boolean callFromOlf, Boolean OLFOnly){
        List<MRCDataWrap> mrcWrapList = new List<MRCDataWrap>();
        if(OLFOnly)
            filterOlfMRCs = true;
        else
                filterOlfMRCs = false;
        //END | Rahul Sharma | Date - 22-Jul-2020 : Updated method with extra paramter called availableForOLF and also updated logic to only get MRCs available for OLF based on boolean value.
        if(accId != null && !''.equals(accId)){
            List<Account> accList = [SELECT Id FROM Account WHERE ParentId = : accId];
            if(!accList.isEmpty()){
                Set<Id> accIdSet = (new Map<Id, Account>(accList)).keySet();
                mrcWrapList = getMRCRecordsData(tranche ,Mrcno , accIdSet, shipto, checked , agoChk, igoChk, mogasChk, poType,
                        plant, mot, contractStartDate, contractEndDate, callFromOlf);
                return mrcWrapList;
            }
            else
                    return null;
        }
        else if(Mrcno != null && !''.equals(Mrcno)){
            mrcWrapList = getMRCRecordsData(tranche ,Mrcno , new Set<Id>(), shipto, checked , agoChk, igoChk, mogasChk, poType,
                    plant, mot, contractStartDate, contractEndDate, callFromOlf);
            return mrcWrapList;
        }
        //Fix_494336_Lakshmi_Starts
        else if(shipto != null && !''.equals(shipto)){
            mrcWrapList = getMRCRecordsData(tranche ,Mrcno , new Set<Id>(), shipto, checked , agoChk, igoChk, mogasChk, poType,
                    plant, mot, contractStartDate, contractEndDate, callFromOlf);
            return mrcWrapList;
        }
        //Fix_494336_Lakshmi_Ends
        else
                return null;
    }

    @AuraEnabled
    public static /*saveResultsearchWrap*/ List<SHT__c> saveCancelledDealLWC(String dataList){
        system.debug('dataList::'+dataList);
        dataList = '['+dataList+']';
        List<SHT__c> newSaveLst= new List<SHT__c>();
        saveResultsearchWrap srchSaveWrp = new saveResultsearchWrap();
        List<SHTDisplayWrap> shtSavedWrap = new List<SHTDisplayWrap>();
        Set<Id> MrcId = new Set<Id>();
        List<MRCDataWrap> listToSave = (List<MRCDataWrap>)JSON.deserialize(dataList, List<MRCDataWrap>.class);
        //Fix_252970_30Apr2019_Soumyajit starts
        /*if(date.valueOf(contractStartDate) < system.today()){
            contractStartDate = String.valueOf(System.today());
            if(date.valueOf(contractEndDate) <= system.today())	//FixReverted_252970_07Aug2019_Soumyajit
                contractEndDate=String.valueOf(System.today());
            else
                    contractEndDate=String.valueOf(System.today().addDays(13));
        }*/
        if(listToSave.size()>0){
            for(MRCDataWrap dataObj : listToSave){
                if(dataObj.volumeCBM != Null && dataObj.volumeCBM >0){
                    //accntIdSet.add(dataObj.accId);
                    mrcId.add(dataObj.mrcId);
                }
            }
        }
        List<Mrc__c> mrcList = [Select Id,Name from MRC__c where Id IN : mrcId Limit 1];
        //Map<Id,Mrc__c> mrcMap = new Map<Id,MRC__c>(Select Id,Name from MRC__c where Id IN : mrcId);
        SHT__c newSHTObj;
        Set<SHT__c> saveList = new Set<SHT__c>();
        for(MRCDataWrap dataObj : listToSave){
           /* if(date.valueOf(ContractStrtDateToBeSaved) < system.today()){
                dataObj.atpVoltoBeReduced=dataObj.retroAtpVoltoBeReduced;
                dataObj.isVolToBeHedged=dataObj.retroVolToBeHedged;
                dataObj.isGsapDealCreateOn=dataObj.retroGsapDealCreateOn;
                dataObj.isGsapDealCancelOn=dataObj.retroGsapDealCancelOn;
            }*/
            if(dataObj.volumeCBM != Null && dataObj.volumeCBM >0){
                newSHTObj = new SHT__c();
                boolean retailMixAdded=false;
                Map<String, RV_SPCalculationController.salesPriceWrap> mrcNoVsSalesPriceWrapMap = new Map<String, RV_SPCalculationController.salesPriceWrap>(); //Rahul Sharma | Date- 28-Jan-2021 ; Added mrc numberr vs salesPriceWrap map. 
                newSHTObj.MRC__c = dataObj.mrcId;
                newSHTObj.MRC_Number__c = mrcList[0].Name;//dataObj.mrcName;
                newSHTObj.Customer__c = dataObj.accId;
                //newSHTObj.Tranche__c = trancheVal;
                newSHTObj.BSP__c=dataObj.finalbspCal;
                newSHTObj.MSP__c=dataObj.finalSalesPriceCal;

                if(dataObj.isZeroPriceDeal !=null && dataObj.isZeroPriceDeal){
                    newSHTObj.SP_100L__c = 0; // Zero Price Deal 
                }else{
                    newSHTObj.SP_100L__c = dataObj.pricePerVol; // Enetred Price by End User
                }
                if(newSHTObj.MSP__c!= null && newSHTObj.SP_100L__c !=null){
                    newSHTObj.Target_Margin__c=newSHTObj.SP_100L__c-newSHTObj.BSP__c;
                }
                newSHTObj.Status__c = 'Completed';
                newSHTObj.Select__c= true;
                newSHTObj.Cancellation_Reason_Label__c = dataObj.cancellationReason;
                newSHTObj.SP_100L__c = dataObj.spPer100L;
               // newSHTObj.Effective_Margin__c = dataObj.targetMargin;
                newSHTObj.MSP__c = dataObj.msp;
               // newSHTObj.Ship_To__c = dataObj.shipToNumber;
                newSHTObj.Sales_Type__c = 'Obam Sales';
                newSHTObj.Product_Category__c = dataObj.grade;
                newSHTObj.Contract_Start__c=Date.valueOf(dataObj.contractStartDate);//ContractStrtDateToBeSaved;
                newSHTObj.Contract_End_Date__c=Date.valueOf(dataObj.contractEndDate);//ContractEndDateToBeSaved;
                //newSHTObj.Volume_CBM__c=dataObj.volumeCBM;    //Rahul Sharma | Date - 26-Apr-2021 : Commented redundant variable assignment. 
                newSHTObj.Deal_Comment__c=dataObj.Comment;
                if(dataObj.isPricingTaxed != null)
                    newSHTObj.IsPricingTaxed__c=dataObj.isPricingTaxed;
                if(dataObj.pricingCondition != null)
                    newSHTObj.Price_Condition__c=dataObj.pricingCondition;
                if(dataObj.atpVoltoBeReduced != null)
                    newSHTObj.IsATPVolumeReduced__c=dataObj.atpVoltoBeReduced;
                if(dataObj.isVolToBeHedged != null)
                    newSHTObj.IsVolumeHedged__c=dataObj.isVolToBeHedged;
                if(dataObj.isZeroPriceDeal != null)
                    newSHTObj.IsZeroPriceDeal__c=dataObj.isZeroPriceDeal;
                if(dataObj.isGsapDealCreateOn != null)
                    newSHTObj.IsGsapDealCreateOn__c=dataObj.isGsapDealCreateOn;
                if(dataObj.isGsapDealCancelOn != null)
                    newSHTObj.IsGsapDealCancelOn__c=dataObj.isGsapDealCancelOn;
                //START - Rahul Sharma | Date - 21-Nov-2020 : Updated volume split from E5 to E10.
                //if(checked && dataObj.grade == 'ULG95 E5' && dataObj.salesOrg !='AT01'){
                if(/*checked && */dataObj.grade == 'ULG95 E10' && dataObj.salesOrg !='AT01'){
                    //END - Rahul Sharma | Date - 21-Nov-2020 : Updated volume split from E5 to E10..
                    newSHTObj.Volume_CBM__c=dataObj.volumeCBM * 0.15; //Rahul Sharma | Date - 04-Jan-2020 : Updated volume split from 80% to 15% to retain old split logic.
                }
                else{
                    newSHTObj.Volume_CBM__c = dataObj.volumeCBM;
                }
                newSHTObj.Location__c = dataObj.locationId;
                saveList.add(newSHTObj);
            }
        }
       // Set<Id> insertedIds= new Set<Id>();
        //List<sht__c> shtLst = new List<sht__c>();
        if(!saveList.isEmpty()){
            
            newSaveLst.addAll(saveList);
            try{
                Schema.DescribeSObjectResult s = sht__c.sObjectType.getDescribe();
                if(s.isCreateable()){
                    insert  newSaveLst;
                    system.debug('newSaveLst::'+newSaveLst);
                    //newSaveLst = null;
                    newSaveLst = [Select Id, Name from SHT__C where Id IN :newSaveLst ];
                }
            }
            catch(Exception e){
                System.debug('Exception ==>'+e);
            }

            //shtSavedWrap=getSavedSHTDeal();
        }
        //srchSaveWrp.savedResult=shtSavedWrap;
        return newSaveLst;
        
    }

    /*Method Name	:	calculateRetailMixPrice
    * Date			:	28-Jan-2021
    * Developer		:	Rahul Sharma
    * Description	:	This method calculates BSP and MSP for retail mix line items*/
    public static Map<String, RV_SPCalculationController.salesPriceWrap> calculateRetailMixPrice(List<MRC__c> mrcList, String contractStartDate, String contractEndDate){
        RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        Map<String, RV_SPCalculationController.salesPriceWrap> mrcNoVsSalesPriceWrpMap = new Map<String, RV_SPCalculationController.salesPriceWrap>();
        spAdtWrp = RV_SPCalculationController.getCalulatedSp(mrcList, Date.valueOf(contractStartDate), Date.valueOf(contractEndDate));
        for(RV_SPCalculationController.salesPriceWrap salesPriceWrap : spAdtWrp.salesPriceWrpLst){
            mrcNoVsSalesPriceWrpMap.put(salesPriceWrap.mrcNo, salesPriceWrap);
        }
        return mrcNoVsSalesPriceWrpMap;
    }

    public class searchWrapMRC{
        @AuraEnabled
        public integer diffDays;
        @AuraEnabled
        public date conEndDate;
        @AuraEnabled
        public integer maxdiffDays;
        @AuraEnabled
        public date maxEndDate;
    }

    public class SHTWrapper{
        @AuraEnabled
        public List<SHTDisplayWrap> savedDeal;
        @AuraEnabled
        public List<SHTDisplayWrap> CompletedDeal;
        @AuraEnabled
        public List<String> reasonList;
        @AuraEnabled
        Public Date ContractStartDate;
        @AuraEnabled
        Public Date ContractEndDate;
        //AdditionalFix_166256_29Apr2019_Soumyajit starts
        @AuraEnabled
        Public Boolean hasEditAccess;
        //AdditionalFix_166256_29Apr2019_Soumyajit ends
    }

    public class SHTDisplayWrap{
        @AuraEnabled
        public Id shtRecordId;
        @AuraEnabled
        public boolean selected;
        @AuraEnabled
        public string shtNo;
        @AuraEnabled
        public string MrcNo;
        @AuraEnabled
        public Id MrcId;
		@AuraEnabled
        public string CustomerId;
        @AuraEnabled
		public string Customer;
        @AuraEnabled
        public string shipToNumber;
        @AuraEnabled
        public string location;
        @AuraEnabled
		public string locationId;
        @AuraEnabled		   
		public string product;
        @AuraEnabled
        public string materialNo;
        @AuraEnabled
        public string materialName;
        @AuraEnabled
        public decimal volCbm;
        @AuraEnabled
        public decimal spPer100L;
        @AuraEnabled
        public decimal bsp;
        @AuraEnabled
        public decimal targetMargin;
        @AuraEnabled
        public decimal msp;
        @AuraEnabled
        public date contractStartDate;
        @AuraEnabled
        public date contractEndDate;
        @AuraEnabled
		public string c_StartDate;
        @AuraEnabled
        public string c_EndDate;
        @AuraEnabled		  
        public String dealStatus;
        @AuraEnabled
        public String cancellationReason;
        @AuraEnabled
        public string Comment;
        @AuraEnabled
        public string gsapContract;
        @AuraEnabled
        public boolean isZeroPriceDeal;
        @AuraEnabled
        public String gsapError;    //Rahul Sharma | PBI-702438 | Date - 22-Jan-2021 : new variable to show GSAP error message.
        @AuraEnabled
        public String poType;   //Rahul Sharma | PBI-702438 | Date - 29-Jan-2021 : new variable to show PO type.
		@AuraEnabled 
		public Decimal otm;   //Sampada Bhat | Date - 14-Dec-2021 : new variable to sht
        @AuraEnabled 
        public Decimal salesPrice;//Sampada Bhat | Date - 14-Dec-2021 : new variable to sht
        @AuraEnabled
        public String highlightDeal;
        @AuraEnabled
        public boolean gsapErrorCheck;
        @AuraEnabled
        public boolean gsapContractCheck;
        @AuraEnabled
        public String tranche;//ashish tiwari | Date - 26/5/2022 : cancelled &new volume update fix
    }
    public class picklistWrap{
        @AuraEnabled
        public String recrdId;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string num;
    }

    Public class acctSearchWrapper{
        //START - Rahul Sharma | Date - 03-Feb-2021 | PBI-702438 : Updated Wrapper to contain map instead of list.
        /*@AuraEnabled
        public List<String> shipTolst;
        @AuraEnabled
        public List<String> mrcLst;
        @AuraEnabled
        public List<String> motLst;
        @AuraEnabled
        public List<String> plantLst;
        @AuraEnabled
        public List<String> poTypeLst;*/
        @AuraEnabled
        public Map<String, String> mrcNoVsMrcHeadMap;
        @AuraEnabled
        public Map<String, String> mrcNoVsMotMap;
        @AuraEnabled
        public Map<String, String> mrcNoVsPlantMap;
        @AuraEnabled
        public Map<String, String> mrcNoVsPoTypeMap;
        //END - Rahul Sharma | Date - 03-Feb-2021 | PBI-702438 : Updated Wrapper to contain map instead of list.
    }
    public class saveResultsearchWrap{
        @AuraEnabled
        public List<SHTDisplayWrap> savedResult;
        @AuraEnabled
        public List<MRCDataWrap> searchResult;
        @AuraEnabled
        public string cancelMsg;
    }
    public class MRCDataWrap{
        @AuraEnabled
        public Id mrcId;
        //Added By Sampada Bhat
        @AuraEnabled
        public String contactEmail;
        @AuraEnabled
		public string accName;
        @AuraEnabled
        public string salesOrg;
        @AuraEnabled
        public string accId;
        @AuraEnabled
        public string mrcName;
        @AuraEnabled
        public string shipToNumber;
        @AuraEnabled
        public string location;
        @AuraEnabled
        public string locationId;
        @AuraEnabled
        public string locationName;
        @AuraEnabled
        public string grade;
        @AuraEnabled
        public string materialNo;
        @AuraEnabled
        public string materialName;
        @AuraEnabled
        public decimal atpLive;
        @AuraEnabled
        public decimal atpLiveRelated;	//Fix_437452_02Mar2020_Soumyajit
		@AuraEnabled
        public decimal finalatpLive; //added by swarna as part of revamp
        @AuraEnabled
		public decimal landedCostCal;
        @AuraEnabled
        public decimal finalbspCal;
        @AuraEnabled
        public decimal finalSalesPriceCal;
        @AuraEnabled
        public decimal OTM;
        @AuraEnabled
        public decimal pricePerVol;
        @AuraEnabled
        public Decimal volumeCBM;
        @AuraEnabled
        public String Comment;
        @AuraEnabled
        public boolean isPricingTaxed;
        @AuraEnabled
        public String pricingCondition;
        @AuraEnabled
        public boolean atpVoltoBeReduced;
        @AuraEnabled
        public boolean isVolToBeHedged;
        @AuraEnabled
        public boolean isZeroPriceDeal;
        @AuraEnabled
        public boolean isGsapDealCreateOn;
        @AuraEnabled
        public boolean isGsapDealCancelOn;
        @AuraEnabled
        public boolean retroAtpVoltoBeReduced;
        @AuraEnabled
        public boolean retroVolToBeHedged;
        @AuraEnabled
        public boolean retroGsapDealCreateOn;
        @AuraEnabled
        public boolean retroGsapDealCancelOn;
		@AuraEnabled
        public String cancellationReason;
        @AuraEnabled
        public Decimal msp;
        @AuraEnabled
        public Decimal spPer100L;
        @AuraEnabled
        public String contractStartDate;
        @AUraEnabled
        public String contractEndDate;
        @AUraEnabled
        public String tranche;	
    }
    //Fix_170853_13May2019_Soumyajit starts
    public class SHTDisplayWithAdvanceFilterWrap{
		@AuraEnabled
        public Map<String,String> SHTListMap;
        @AuraEnabled
        public Map<String,String> soldToListMap;
        @AuraEnabled
        public Map<String,String> poTypeListMap;
        @AuraEnabled
		public List<SHTDisplayWrap> SHTDisplayWrapList;
        @AuraEnabled
        public List<String> SHTList;
        @AuraEnabled
        public List<String> SoldToList;
        @AuraEnabled
        public boolean DateValid;
        @AuraEnabled
        public List<String> poTypeList; //Rahul Sharma | PBI-702438 | Date - 01-Feb-2021 : Added poTypeList.
    }
    //Fix_170853_13May2019_Soumyajit ends

}