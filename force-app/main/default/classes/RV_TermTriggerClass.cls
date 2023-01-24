/**
 * Created by===========> Dhriti.GhoshMoulick on 8/9/2021.*/
 public  class RV_TermTriggerClass {
    @AuraEnabled
    public static List < Map < String, String >> getPickListValuesMonth(String objApiName, String fieldName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                    'label' => f.getLabel(),
                    'value' => f.getValue()
            };
            options.add(values);
        }
        return options;
    }

    public static String getMonth(String startDateMonth){
        String startMonth;
        //set<String> monthSet = new set<String>();
        //for(String startMonth : startDateMonth){
            if (startDateMonth == '01') {
                startMonth = 'Jan';
            }
            if (startDateMonth == '02') {
                startMonth = 'Feb';
            }
            if (startDateMonth == '03') {
                startMonth = 'Mar';
            }
            if (startDateMonth == '04') {
                startMonth = 'Apr';
            }
            if (startDateMonth == '05') {
                startMonth = 'May';
            }
           if (startDateMonth == '06') {
                startMonth = 'Jun';
            }
            if (startDateMonth == '07') {
                startMonth = 'Jul';
            }
            if (startDateMonth == '08') {
                startMonth = 'Aug';
            }
            if (startDateMonth == '09') {
                startMonth = 'Sep';
            }
            if (startDateMonth == '10') {
                startMonth = 'Oct';
            }
            if (startDateMonth == '11') {
                startMonth = 'Nov';
            }
            if (startDateMonth == '12') {
                startMonth = 'Dec';
            }
            system.debug(startMonth);
       // monthSet.add(startMonth);
    //}
        return startMonth;
    }
    @AuraEnabled
    public static finalTermTriggerWrap fetchTermTriggerDeal1(String soldToAccId,List<String> mrcNumber,List<String> shipToAccNum,
            List<String> mot,String energyTax,List<String> productName,String poType,List<String> plantId,
            List<String> salesOrg,String startDate,String endDate, Boolean isRetailMixChecked ){
                try{
        // Integer motInteger = Integer.valueOf(mot);
        /*System.debug('=======soldToAccId======='+soldToAccId);
        System.debug('=======mrcNumber======='+mrcNumber);
        System.debug('=======shipToAccNum======='+shipToAccNum);
        System.debug('=======mot======='+mot);
        System.debug('=======energyTax======='+energyTax);
        System.debug('=======productName======='+productName);
        System.debug('=======poType======='+poType);
        System.debug('=======plantId======='+plantId);
        System.debug('=======salesOrg======='+salesOrg);
        System.debug('=======startDate======='+startDate);
        System.debug('=======endDate======='+endDate);*/
        string tranche ;
        List<String> mrcNumbersList = new List<String>();
        for(String mrcNo1:mrcNumber){
			if(mrcNo1 != null && mrcNo1 != '' && mrcNo1 != ' '){
            system.debug('mrcNo1:'+mrcNo1);
            List<String> mrcStr = mrcNo1.split(',');
            for(String mrcNo2:mrcStr){
                system.debug('mrcNo2:'+mrcNo2);
                String mrcNumber1 = mrcNo2.replaceAll('"','');
                mrcNumbersList.add(mrcNumber1);
				}
            }
        }

        List<Integer> motIntegerLst = new List<Integer>();
                String startMonth;
		if(mot.size()>0){
        for(String str : mot){
            //motIntegerLst.add(Integer.valueOf(str));
            List<String> motList = str.split(';');
            for(String motVal : motList){
                motIntegerLst.add(Integer.valueOf(motVal));
                system.debug('motVal:'+motVal);
				 }
            }
        }

        System.debug('=======motIntegerLst======='+motIntegerLst);
        List<String> salesOrgLst = new List<String>();
        if(salesOrg != null) {
            String salesOrgStr = '';
            for (String str : salesOrg) {
				if(str != null && str != '' && str!= ' '){
					salesOrgStr = str;
					salesOrgLst.add(str);
				}
			}
            if(salesOrgStr != null && salesOrgStr != ''){
                salesOrgLst = salesOrgStr.split(';');
            }
            System.debug('=======salesOrgLst=======' + salesOrgLst);
        }
        List<String> finalProductName = new List<String>();
        set<String> monthset = new set<String>();
        for(String product:productName){
            system.debug('str inside termTrigger ~~'+product);
            List<String> productList = product.split(';');
            for(String str:productList){
                if(str == 'AGO'){

                    finalProductName.add('AGO B0');
                    finalProductName.add('AGO B0 CH');
                    finalProductName.add('AGO B7');
                    finalProductName.add('AGO VPD');
                    finalProductName.add('GTL B7');
                    finalProductName.add('GTL B0');
                }else if(str == 'MOGAS'){
                    if(isRetailMixChecked){
                        finalProductName.add('ULG95 E10');
                    }else{
                        finalProductName.add('ULG95 E0');
                        finalProductName.add('ULG95 E10');
                        finalProductName.add('ULG95 E5');
                        finalProductName.add('ULG98');
                        finalProductName.add('ULG100 VP');
                        finalProductName.add('ULG95_BOB_E10');
                        finalProductName.add('ULG95_BOB_E5');
                    }
                }else if(str == 'IGO') {
                    finalProductName.add('IGO 1000ppm');
                    finalProductName.add('IGO 10ppm');
                    finalProductName.add('IGO 50ppm');
                }
			}
        }
        system.debug('finalProductName:'+finalProductName);
        if(!String.isBlank(startDate)) {

            List<String> startDateList = startDate.split('-');
            String startYear = startDateList[0];
             startMonth = startDateList[1];
             String strtDate = startDateList[2];
             set<String> startMonthLst = new set<String>();
             system.debug('startDate::'+startDate);
            if (!String.isBlank(startDate)) {
                monthset.add(String.valueOf(RV_TermTriggerClass.getMonth(startMonth)));
                system.debug('monthset::'+monthset);
            }
             if(Integer.ValueOf(strtDate) > 25){

                 Integer sm = Integer.valueOf(startMonth) + 1 ;
                 system.debug('sm::'+sm);
                 string sm1 = (String.valueOf(sm)).length() == 1 ? '0'+String.valueOf(sm): String.valueOf(sm);
                 //startMonthLst.add(string.valueOf(sm));
                monthset.add(String.valueOf(RV_TermTriggerClass.getMonth(sm1)));
                system.debug('startMonth::'+startMonth);
                system.debug('monthset::'+monthset);
            }
            system.debug('monthSet::'+monthset);
        }

        String triggerMasterData = 'SELECT Id, Name,Sold_to_Name__c,Sold_to_Name__r.Name, Sold_to_Number__c, MRC_Number__r.Contract_Description__c, MRC_Number__r.Name,MRC_Number__r.Contract__c, MRC_Number__r.Material_Description__c, MRC_Number__r.Material_Name__c, MRC_Number__r.Product__r.Name, MRC_Number__r.Ship_to_Number__c, '+
                ' MRC_Number__r.Mode_Of_Transport__c,MRC_Number__r.PO_Type__c,MRC_Number__r.Plant__r.Name,MRC_Number__r.Plant__r.Plant_Code__c,MRC_Number__r.Handling_Type__c,Monthly_volume__c, Trigger_Month__c, Trigger_Year__c,MRC_Number__r.Shipping_Condition__c, '+
                ' Min_Trigger_Volume__c, Max_Trigger_Volume__c, Max_number_of_triggers_per_month__c, Remaining_triggers__c, Remaining_trigger_volume__c FROM RV_Trigger_Master_Data__c ';
        if(!String.isBlank(poType)){
			triggerMasterData+=' where MRC_Number__r.PO_Type__c =: poType';
        }
        if(!String.isBlank(soldToAccId)) {
          triggerMasterData+=' And Sold_to_Name__c =:soldToAccId';
        }
		List<String> mrcList = new List<String>();
        for(String mno : mrcNumber){
            if(mno != null && mno != '' && mno != ' '){
                mrcList.add(mno);
            }
        }
            if(mrcList.size()>0){
            triggerMasterData+=' AND MRC_Number__r.Contract__c IN: mrcNumbersList';
            }


      // START: Added as part of 1306836 : ASHISH
        List<String> shipToListNew = new List<String>();
        if(shipToAccNum!= null && shipToAccNum.size() > 0){
            List<String> shipToAccNum1 = shipToAccNum[0].split(',');
            for(String shpTo : shipToAccNum1){
                if(shpTo != null && shpTo != '' && shpTo != ' '){
                    if(!shpTo.startsWith('0'))
                        shpTo = '00'+ shpTo;
                    else if(shpTo.startsWith('00'))
                        shpTo = shpTo;
                    else if(shpTo.startsWith('0'))
                        shpTo = '0'+ shpTo;
                    shipToListNew.add(shpTo);
                }
            }
        }
        system.debug('shipToList::'+shipToAccNum);
                            system.debug('shipToListNew::'+shipToListNew);

        if(shipToListNew.size()>0){
            triggerMasterData+=' AND MRC_Number__r.Ship_to_Number__c IN:shipToListNew';

        }// END: 1306836

                 /*   if(shipToAccNum.size()>0){
                        triggerMasterData+=' AND MRC_Number__r.Ship_to_Number__c IN:shipToAccNum';

                    }*/
                    /* if(!String.isBlank(shipToAccNum)){
triggerMasterData+=' AND MRC_Number__r.Ship_to_Number__c =:shipToAccNum';

}*/

		if(!finalProductName.isEmpty()){
            triggerMasterData+=' AND MRC_Number__r.Material_Description__c in:finalProductName';
        }

        if(!motIntegerLst.isEmpty()){
            triggerMasterData+=' AND MRC_Number__r.Mode_Of_Transport__c in:motIntegerLst';

        }

        List<String> plantList = new List<String>();
        for(String plnt : plantId){
            if(plnt != null && plnt != '' && plnt != ' '){
                 plantList.add(plnt);
            }
		}
        system.debug('plantId::'+plantList+plantList.size());
        if(plantList.size()>0){
            triggerMasterData+=' AND MRC_Number__r.Plant__c IN: plantList';
		}

        system.debug('salesOrgLst::'+salesOrgLst+'--'+salesOrgLst.size());
		if(!salesOrgLst.isEmpty() && salesOrgLst.size() > 0){
            triggerMasterData+=' AND MRC_Number__r.Sales_Organization__c in:salesOrgLst';
        }
        if(!String.isBlank(startDate)) {
            triggerMasterData += ' AND Trigger_Month__c IN :monthset';
           triggerMasterData += ' AND Trigger_Year__c =: startYear';


		 }
          triggerMasterData += ' ORDER BY MRC_Number__r.Plant__r.Name, MRC_Number__r.MRC_Grade_Sort__c ASC';


		System.debug('query:'+triggerMasterData);
        List<termTriggerWrapper> termWrapperList = new List<termTriggerWrapper>();
        List<String> triggerIdLst = new List<String>();

                system.debug('values::'+soldToAccId+'-'+mrcNumber+'--'+poType+'--'+monthset);
		set<String> mrcIds = new set<String>();//added by swarna
        for(Sobject sobj: Database.query(triggerMasterData)){
            triggerIdLst.add(sobj.Id);
			//added by swarna
            RV_Trigger_Master_Data__C rvtm1 = (RV_Trigger_Master_Data__C)sobj;
            mrcIds.add(rvtm1.MRC_Number__c);
            //end
        }
		 List<MRC__c> mrcfinalList = [Select Id, Name, Contract_Description__c, Customer_Payment_Term__c, Distribution_Channel__c, Division__c, Ship_To__c, Handling_Type__c, MRC_Number__c,
                        Material_Description__c, Mode_Of_Transport__c, Load_Id__c, RV_OLF_MRC_Only__c, Active__c, Cust_SoldTo_Cr_Limit__c, RV_Condition_group_2_Description__c, RV_Condition_group_2__c,
                        RV_Incoterms_Part1__c, RV_Incoterms_Part2__c, RV_Invoicing_date__c, PO_Number__c, Payment_Term__c, Plant_Code__c, Plant_Description__c, Plant__c, Pricing_Date__c, Product__c,
                        Quantity__c, Rejection_Reasons__c, Sales_Doc_Type__c, Sales_Document_Item__c, Sales_Document__c, Sales_Organization__c, Ship_to_City__c, Ship_to_County__c, Ship_to_Customer_group__c,
                        Ship_to_Name__c, Ship_to_Number__c, Ship_to_State__c, Ship_to_Street__c, Shipping_Condition__c, Sold_To_Number__c, Sold_To__c, Storage_Location__c, Target_Quantity__c, UOM__c,
                        Valid_From_Date__c, Valid_To_Date__c, Valuation_Type__c, Contract__c, Item_No_XLS__c, Material_No_XLS__c, Plant_Code_XLS__c, Sold_To_Number_XLS__c, Material_Name__c, PO_Type__c,
                        ProductLocationKey__c, Ship_to_party_PO_type__c, Supply_Type__c, Online_Customer_Name__c, Online_Location_Name__c, Online_Material_Name_Taxed__c, Online_Material_Name_UnTaxed__c,
                        Plant_Name__c, Rv_Available_for_OLF__c, MRC_Grade_Sort__c, RV_Invoicing_dates_Description__c, RV_Payment_Method_Description__c, RV_Payment_Method__c, RV_Payment_Terms_Description__c,
                        RV_Rejection_Code__c, RV_Shipping_Condition_Description__c,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,
                Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,
                Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Product__r.Name  from MRC__c where ID IN :mrcIds];
        system.debug('triggerIdLst size:'+triggerIdLst.size());
        List<String> returnSHTList = new List<String>();
        List<String> returnSoldToList = new List<String>();
        List<String> returnPotypeList = new List<String>();
        // System.debug(termWrapperList);
        string LoggedInUsr=UserInfo.getUserId();
        //PBI-1592108, Added Location__r.Name in the query
        List<SHT__c> shtupdateLst = [SELECT Auto_Num__c,BSP__c,Cancellation_Reason_Label__c,Cancellation_Reason__c,Contact_Email__c,
                Contact_Name__c,Contract_End_Date__c,Contract_Start__c,CreatedById,CreatedDate,Created_Time__c,Customer__c,Customer__r.Name,Deal_Comment__c,
                Deal_Hour__c,Effective_Margin__c,Error__c,Grade__c,Handling_Type__c,Id,IsATPVolumeReduced__c,IsDeleted,IsGsapDealCancelOn__c,
                IsGsapDealCreateOn__c,isOlfDeal__c,IsPricingTaxed__c,IsVolumeHedged__c,IsZeroPriceDeal__c,LastModifiedById,LastModifiedDate,
                LastReferencedDate,LastViewedDate,Location__c,Location__r.Name,Margin_vs_MSP__c,Margin__c,Material_Name__c,Material_No__c,MRCNumber__c,
                MRC_Number__c,MRC__c,MSP__c,Name,OLF_Deal_Number__c,OTM__c,OwnerId,Plant_No__c,PO_Type__c,Price_Condition__c,Price_Unit__c,
                Product_Catalogue__c,Product_Category__c,Product_Sub_Group__c,PSP__c,Rv_LastModifiedById__c,Rv_LastModifiedDate__c,
                Sales_Organization__c,Sales_Price__c,Sales_Type__c,SAP_Contract_Number__c,Select__c,Ship_To_Name__c,Ship_To__c,
                SHT_Contract_Number__c,Sold_Price__c,Sold_To_Name__c,SP_100L__c,Status__c,SystemModstamp,Target_Margin__c,Tranche__c,
                Transaction_Id__c,Trigger_Master_Data__c,UserTimezoneOffset__c,Volume_CBM__c,Volume_Unit__c
        FROM SHT__c where (PO_Type__c = 'TTTT' OR PO_Type__c = 'TTTI') AND  CreatedById =:LoggedInUsr];
        finalTermTriggerWrap finalTerm = new finalTermTriggerWrap();
        finalTerm.shtList = shtupdateLst;
		//added by swarna
        tranche = rv_PriceAndMarket.getTranche(date.valueOf(startDate));
        //setting Inut data wrap for price calculation
        List<RV_SPCalculationController.salesPriceWrap> salesPriceWrapLst=new List<RV_SPCalculationController.salesPriceWrap>();
        List<RV_SPCalculationController.salesPriceWrap> finalSalesPriceWrapLst=new List<RV_SPCalculationController.salesPriceWrap>();
        RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        spAdtWrp=RV_SPCalculationController.getCalulatedSp(mrcfinalList,date.valueOf(startDate),date.valueOf(endDate));
        salesPriceWrapLst=spAdtWrp.salesPriceWrpLst;
        finalSalesPriceWrapLst.addAll(salesPriceWrapLst);
        salesPriceWrapLst=null;
        Map<String,RV_SPCalculationController.salesPriceWrap> mrcNoSPwrap= new Map<String,RV_SPCalculationController.salesPriceWrap>();
        for(RV_SPCalculationController.salesPriceWrap spwrp:finalSalesPriceWrapLst){
            mrcNoSPwrap.put(spwrp.mrcNo,spwrp); //Map of Sp and MRC
        }
        //end
		//Deal Event Manager metadata
        Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap=rv_sht_CreateControllerLWC.getDealEventMetdataMap();
        //system.debug('poTypeHandlingDealMdtMap==>'+poTypeHandlingDealMdtMap);

        //Shipping Condition Map
        Map<Integer,String> ShipCondNoNameMap= new Map<Integer,String>();
        List<Shipping_Condition_Mapping__mdt> shipCdnMetDatLst= [Select id,Mot__c,Shipping_Condition__c
        from Shipping_Condition_Mapping__mdt];
        for(Shipping_Condition_Mapping__mdt shp:shipCdnMetDatLst){
            ShipCondNoNameMap.put(Integer.valueOf(shp.Shipping_Condition__c),shp.Mot__c);
        }


        for(Sobject sobj: Database.query(triggerMasterData)){
			termTriggerWrapper termTrigger = new termTriggerWrapper();
            RV_Trigger_Master_Data__C rvtm = (RV_Trigger_Master_Data__C)sobj;
            rvtm.MRC_Number__r.Product__r.Name = (rvtm.MRC_Number__r.Product__r.Name).right(4);
			if(mrcNoSPwrap != null && mrcNoSPwrap.get(rvtm.MRC_Number__r.Name) != null ){
			if(mrcNoSPwrap.get(rvtm.MRC_Number__r.Name).BSP != null){
                    system.debug('BSP::'+mrcNoSPwrap.get(rvtm.MRC_Number__r.Name));
                    system.debug('bsp Val::'+(mrcNoSPwrap.get(rvtm.MRC_Number__r.Name)).BSP);
                    rvtm.BSP__c=((mrcNoSPwrap.get(rvtm.MRC_Number__r.Name)).BSP).setScale(2, RoundingMode.HALF_UP);
                }
                if(mrcNoSPwrap.get(rvtm.MRC_Number__r.Name).MSP != null){
                    rvtm.MSP__c=((mrcNoSPwrap.get(rvtm.MRC_Number__r.Name)).MSP).setScale(2, RoundingMode.HALF_UP);
                }
            }
			   string key=rvtm.MRC_Number__r.PO_Type__c+rvtm.MRC_Number__r.Handling_Type__c;
            String otherKey=rvtm.MRC_Number__r.PO_Type__c+'Others';
            string finalKey;
            Deal_Event_Manager__mdt dealEvent;
            if(poTypeHandlingDealMdtMap.containsKey(key)){
                dealEvent=poTypeHandlingDealMdtMap.get(key);
            }
            else if(poTypeHandlingDealMdtMap.containsKey(otherKey)){
                dealEvent=poTypeHandlingDealMdtMap.get(otherKey);
            }

            if(dealEvent != null){
                termTrigger.isPricingTaxed=dealEvent.IsPricingTaxed__c;
                termTrigger.pricingCondition=dealEvent.Pricing_Condition__c;
                termTrigger.atpVoltoBeReduced=dealEvent.IsATPVolumeReduced__c;
                termTrigger.isVolToBeHedged=dealEvent.IsVolumeHedged__c;
                termTrigger.isZeroPriceDeal=dealEvent.IsZeroPriceDeal__c;

                if(/*shipto != '00000000' && */dealEvent.Shipping_Condition__c.contains(ShipCondNoNameMap.get(Integer.valueOf(rvtm.MRC_Number__r.Shipping_Condition__c)))){
                    termTrigger.isGsapDealCreateOn=dealEvent.IsGsapDealCreateOn__c;
                    termTrigger.isGsapDealCancelOn=dealEvent.IsGsapDealCancelOn__c;
                    //Retro GSAP Deals
                    termTrigger.retroGsapDealCreateOn=dealEvent.IsRetroGsapDealCreateOn__c;
                    termTrigger.retroGsapDealCancelOn=dealEvent.IsRetroGsapDealCancelOn__c;
                }
                //Retro Volume Deals
                termTrigger.retroAtpVoltoBeReduced=dealEvent.IsRetroATPVolumeReduced__c;
                termTrigger.retroVolToBeHedged=dealEvent.IsRetroVolumeHedged__c;
            }

           termTrigger.tranche = tranche ;
            termTrigger.triggerMasterData = rvtm;//sobj;
            termWrapperList.add(termTrigger);
        }
        system.debug('termWrapperList::'+termWrapperList.size());
        finalTerm.termTriggerWrapperList = termWrapperList;
        if(!(sht__c.sObjectType.getDescribe().isCreateable() && sht__c.sObjectType.getDescribe().isUpdateable())){
            finalTerm.hasEditAccess = false;
        }else{
            finalTerm.hasEditAccess = true;
        }
        for(SHT__c sht : shtupdateLst){
            // system.debug('tw::'+tw);
            returnSHTList.add(sht.Name);
            if(!returnSoldToList.contains(sht.Customer__r.Name)){
                returnSoldToList.add(sht.Customer__r.Name);
            }
            if(!returnPotypeList.contains(sht.PO_Type__c)){
                returnPotypeList.add(sht.PO_Type__c);
            }

        }
        finalTerm.shtNo = returnSHTList;
        finalTerm.soldToList = returnSoldToList;
        finalTerm.poTypeList = returnPotypeList;
        return finalTerm;
    }
    catch(exception e){
        system.debug('Exception ::'+e.getStackTraceString()+e.getLineNumber()+e.getMessage());
        return null;
    }

}

    @AuraEnabled
    public static List<SHT__c> saveTermTriggerDeal1(String triggerdata, String startDate,
     String endDate, boolean checked, String trancheVal){
         System.debug('##### triggerData'+triggerdata);
         //added by swarna aspart of PBI-1238303
         string stDateMonth;

         Date nextMonthStDate;
         if(startDate != null){
             Date stDate = Date.valueOf(startDate);

             DateTime dtConverted = Datetime.newInstance(stDate.year(), stDate.month(),stDate.day(),0,0,0);
             stDateMonth = string.valueOf(dtConverted.format('MMM'));
             nextMonthStDate = stDate.addMonths(1);
             nextMonthStDate = nextMonthStDate.toStartOfMonth();
             system.debug('next month::'+nextMonthStDate);
         }
         //end PBI-1238303
         List<termTriggerWrapperData> triggerListData = (List<termTriggerWrapperData>)JSON.deserialize(triggerdata, List<termTriggerWrapperData>.class);
        System.debug('triggerListData::'+triggerListData);
        List<SHT__c> createSHTList = new List<SHT__c>();
        List<String> triggerMasterIdLst = new List<String>();
        List<RV_Trigger_Master_Data__c> updateTriggerMaster = new List<RV_Trigger_Master_Data__c>();
        Set<String> retailMixMatSet= new Set<String>();
        retailMixMatSet.add('ULG95 E5');
        retailMixMatSet.add('ULG95 E10');
        retailMixMatSet.add('ULG98');
        Set<string> accntIdSet = new Set<string>();
        Set<Id> mrcId= new Set<Id>();
        Map<string,string> mrcRetMixMrcMap= new Map<string,string>();
        Map<string,string> mrcRetMixMrcIdMap= new Map<string,string>();
        if(triggerListData.size()>0){
            for(termTriggerWrapperData dataObj : triggerListData){
                system.debug('each termTriggerWrapperData::'+dataObj);
                termTriggerWrapperData rvTriggerMasterData = (termTriggerWrapperData)dataObj;
                system.debug('rvTriggerMasterData::'+rvTriggerMasterData);
                if(dataObj.TriggerVolume1 != Null && dataObj.TriggerVolume1 >0){
                    accntIdSet.add(rvTriggerMasterData.Sold_to_Name);
                    mrcId.add(rvTriggerMasterData.MRC_Number);
                }

            }
        }

        List<Mrc__c> mrcRetMixMrcLst= new List<Mrc__c>();
        if(accntIdSet.size()>0){
            mrcRetMixMrcLst = [SELECT Id,Name,Material_Description__c,Sold_To__c,Plant__c,Plant__r.Name,Plant__r.Country__c,Plant_code__c,
                Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,
                Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,
                Material_Name__c,PO_Type__c,Sold_To__r.Name,Handling_Type__c,Sales_Organization__c,MRC_Number__c,Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,
                Online_Material_Name_Taxed__c,Online_Material_Name_UnTaxed__c,Online_Customer_Name__c,Ship_to_Number__c FROM Mrc__c WHERE
                 Sold_To__c IN :accntIdSet AND Material_Description__c IN :retailMixMatSet];

            if(mrcRetMixMrcLst.size()>0){
                for(mrc__c mr:mrcRetMixMrcLst){
                    mrcRetMixMrcMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Name);
                    mrcRetMixMrcIdMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Id);
                }
            }
        }
        RV_Trigger_Master_Data__c tmd;
        SHT__c createTriggerSHT;
        SHT__c newSHTObj1;
        SHT__c newSHTObj2;

        for(termTriggerWrapperData termTrigger : triggerListData){
            System.debug('termTrigger::'+termTrigger);
            termTriggerWrapperData rvTriggerMasterData = (termTriggerWrapperData)termTrigger;

            if(rvTriggerMasterData.TriggerVolume1 != Null && rvTriggerMasterData.TriggerVolume1>0){
				tmd = new RV_Trigger_Master_Data__c();
                createTriggerSHT = new SHT__c();
                boolean retailMixAdded=false;
                Map<String, RV_SPCalculationController.salesPriceWrap> mrcNoVsSalesPriceWrapMap = new Map<String, RV_SPCalculationController.salesPriceWrap>(); //Rahul Sharma | Date- 28-Jan-2021 ; Added mrc numberr vs salesPriceWrap map.

                if(checked && rvTriggerMasterData.MRC_Number_Material_Description == 'ULG95 E10' && rvTriggerMasterData.salesOrg !='AT01' ){
                    newSHTObj1 = new SHT__c();
                    newSHTObj2 = new SHT__c();
                    retailMixAdded = true;
                    mrcNoVsSalesPriceWrapMap = RV_SHT_CreateController.calculateRetailMixPrice(mrcRetMixMrcLst, startDate, endDate);
                }else{
                    retailMixAdded=false;
                }
					tmd.Id = rvTriggerMasterData.Id;
                    createTriggerSHT.Trigger_Master_Data__c = rvTriggerMasterData.Id;
                    createTriggerSHT.MRC__c = rvTriggerMasterData.MRC_Number;
                    createTriggerSHT.MRC_Number__c = rvTriggerMasterData.MRC_Number_Name;
                    createTriggerSHT.Customer__c = rvTriggerMasterData.Sold_to_Name;
                    createTriggerSHT.SP_100L__c = 0;
                    createTriggerSHT.Status__c = 'Saved';
                    createTriggerSHT.Select__c = true;
                    createTriggerSHT.Tranche__c = rvTriggerMasterData.tranche;
                    createTriggerSHT.Sales_Type__c = 'Obam Sales';
                    createTriggerSHT.Product_Category__c = rvTriggerMasterData.MRC_Number_Material_Description;
                    //added by swarna aspart of PBI-1238303
                    createTriggerSHT.Contract_Start__c = (stDateMonth == rvTriggerMasterData.Trigger_Month) ?Date.valueof(startDate) : nextMonthStDate;
                    createTriggerSHT.Contract_End_Date__c = (stDateMonth == rvTriggerMasterData.Trigger_Month) ?Date.valueof(endDate) : nextMonthStDate.addDays(13);
                    //end PBI-1238303
                    createTriggerSHT.Deal_Comment__c = rvTriggerMasterData.TriggerComment1;
					//added aspart of gsap connectivity1261339
                    createTriggerSHT.IsATPVolumeReduced__c= rvTriggerMasterData.atpVoltoBeReduced !=null ? Boolean.valueOf(rvTriggerMasterData.atpVoltoBeReduced) : false;
                    createTriggerSHT.IsVolumeHedged__c= rvTriggerMasterData.isVolToBeHedged !=null ? Boolean.valueOf(rvTriggerMasterData.isVolToBeHedged) : false;
                    createTriggerSHT.IsZeroPriceDeal__c=rvTriggerMasterData.isZeroPriceDeal !=null ? Boolean.valueOf(rvTriggerMasterData.isZeroPriceDeal):false;
                    createTriggerSHT.IsGsapDealCreateOn__c=rvTriggerMasterData.isGsapDealCreateOn !=null ? Boolean.valueOf(rvTriggerMasterData.isGsapDealCreateOn): false;
                    createTriggerSHT.IsGsapDealCancelOn__c=rvTriggerMasterData.isGsapDealCancelOn !=null ? Boolean.valueOf(rvTriggerMasterData.isGsapDealCancelOn):false;
                    createTriggerSHT.IsPricingTaxed__c = rvTriggerMasterData.isPricingTaxed !=null ? Boolean.valueOf(rvTriggerMasterData.isPricingTaxed): false;
                    createTriggerSHT.Price_Condition__c = rvTriggerMasterData.pricingCondition;
                    //end
                    createTriggerSHT.Location__c =rvTriggerMasterData.MRC_Number_Plant;
					createTriggerSHT.BSP__c = rvTriggerMasterData.BSP;
                    createTriggerSHT.MSP__c = rvTriggerMasterData.MSP;
                    createTriggerSHT.Target_Margin__c = (createTriggerSHT.SP_100L__c!=null && createTriggerSHT.BSP__c!=null) ? createTriggerSHT.SP_100L__c - createTriggerSHT.BSP__c : 0;

                    if(checked && rvTriggerMasterData.MRC_Number_Material_Description == 'ULG95 E10' && rvTriggerMasterData.salesOrg !='AT01'){
                        createTriggerSHT.Volume_CBM__c=rvTriggerMasterData.TriggerVolume1 * 0.15;
                    }
                    else{
                        createTriggerSHT.Volume_CBM__c = rvTriggerMasterData.TriggerVolume1;
                    }
                    createSHTList.add(createTriggerSHT);

                   //for retail mix functionality

			string retmixKey = rvTriggerMasterData.Sold_to_Name;
			string shitopnum = rvTriggerMasterData.MRC_Number_Ship_to_Number ;
			retmixKey = retmixKey + shitopnum+ rvTriggerMasterData.MRC_Number_Plant_Plant_Code;

            if(newSHTObj1 != null && retailMixAdded
            && mrcRetMixMrcIdMap.containsKey(retmixKey+'ULG95 E5')
            ){

                system.debug('@392::'+rvTriggerMasterData.Sold_to_Name+rvTriggerMasterData.shipToNumber+rvTriggerMasterData.MRC_Number_Plant_Plant_Code);
                if(mrcRetMixMrcIdMap.size()>0){
                    system.debug('@394::'+retmixKey);
                    if(mrcRetMixMrcIdMap.containsKey(retmixKey+'ULG95 E5')){
                        newSHTObj1.MRC__c = mrcRetMixMrcIdMap.get(retmixKey+'ULG95 E5');
                        system.debug('@397::'+newSHTObj1.MRC__c);
                    }
                }
                if(mrcRetMixMrcMap.size()>0){
                    system.debug('@401::'+rvTriggerMasterData.Sold_to_Name+rvTriggerMasterData.shipToNumber+rvTriggerMasterData.MRC_Number_Plant_Plant_Code);
                    if(mrcRetMixMrcMap.containsKey(retmixKey+'ULG95 E5')){
                        newSHTObj1.MRC_Number__c = mrcRetMixMrcMap.get(retmixKey+'ULG95 E5');
                        system.debug('@403::'+newSHTObj1.MRC_Number__c);
                    }
                }

                newSHTObj1.Trigger_Master_Data__c = rvTriggerMasterData.Id;
                //newSHTObj1.MRC__c = rvTriggerMasterData.MRC_Number;
                //newSHTObj1.MRC_Number__c = rvTriggerMasterData.MRC_Number_Name;
                newSHTObj1.Customer__c = rvTriggerMasterData.Sold_to_Name;
                newSHTObj1.SP_100L__c = 0;
                newSHTObj1.Status__c = 'Saved';
                newSHTObj1.Select__c = true;
                newSHTObj1.Tranche__c =  rvTriggerMasterData.tranche;
                newSHTObj1.Sales_Type__c = 'Obam Sales';
                newSHTObj1.Product_Category__c = 'ULG95 E5';
                newSHTObj1.Contract_Start__c = (stDateMonth == rvTriggerMasterData.Trigger_Month) ?Date.valueof(startDate) : nextMonthStDate;
                newSHTObj1.Contract_End_Date__c = (stDateMonth == rvTriggerMasterData.Trigger_Month) ?Date.valueof(endDate) : nextMonthStDate.addDays(13);
                newSHTObj1.Deal_Comment__c = rvTriggerMasterData.TriggerComment1;
				//added aspart of GSAP BUG-1261339
                newSHTObj1.IsATPVolumeReduced__c=Boolean.valueOf(termTrigger.atpVoltoBeReduced);
                newSHTObj1.IsVolumeHedged__c=Boolean.valueOf(termTrigger.isVolToBeHedged);
                newSHTObj1.IsZeroPriceDeal__c=Boolean.valueOf(termTrigger.isZeroPriceDeal);
                newSHTObj1.IsGsapDealCreateOn__c=Boolean.valueOf(termTrigger.isGsapDealCreateOn);
                newSHTObj1.IsGsapDealCancelOn__c=Boolean.valueOf(termTrigger.isGsapDealCancelOn);
                newSHTObj1.Price_Condition__c =termTrigger.pricingCondition;
                newSHTObj1.IsPricingTaxed__c = rvTriggerMasterData.isPricingTaxed !=null ? Boolean.valueOf(rvTriggerMasterData.isPricingTaxed): false;
                //end
                newSHTObj1.Location__c =rvTriggerMasterData.MRC_Number_Plant;
                newSHTObj1.Volume_CBM__c=rvTriggerMasterData.TriggerVolume1* 0.80;
				//newSHTObj1.BSP__c = rvTriggerMasterData.BSP;
                //newSHTObj1.MSP__c = rvTriggerMasterData.MSP;
                if(!mrcNoVsSalesPriceWrapMap.isEmpty() && mrcNoVsSalesPriceWrapMap.containsKey(newSHTObj1.MRC_Number__c)){
                        newSHTObj1.BSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj1.MRC_Number__c).BSP;
                        newSHTObj1.MSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj1.MRC_Number__c).MSP;
                }
                else{
                        newSHTObj1.BSP__c = rvTriggerMasterData.BSP;
                		newSHTObj1.MSP__c = rvTriggerMasterData.MSP;
                }
                newSHTObj1.Target_Margin__c = (newSHTObj1.SP_100L__c!=null && newSHTObj1.BSP__c!=null) ? newSHTObj1.SP_100L__c - newSHTObj1.BSP__c : 0;
            }


            if(newSHTObj2 != null && retailMixAdded
            && mrcRetMixMrcIdMap.containsKey(retmixKey+'ULG98')
            ){
                if(mrcRetMixMrcIdMap.size()>0){
                    if(mrcRetMixMrcIdMap.containsKey(retmixKey+'ULG98')){
                        newSHTObj2.MRC__c = mrcRetMixMrcIdMap.get(retmixKey+'ULG98');
                    }
                }
                if(mrcRetMixMrcMap.size()>0){
                    if(mrcRetMixMrcMap.containsKey(retmixKey+'ULG98')){
                        newSHTObj2.MRC_Number__c = mrcRetMixMrcMap.get(retmixKey+'ULG98');
                    }
                }

                newSHTObj2.Trigger_Master_Data__c = rvTriggerMasterData.Id;
                //newSHTObj2.MRC__c = rvTriggerMasterData.MRC_Number;
                //newSHTObj2.MRC_Number__c = rvTriggerMasterData.MRC_Number_Name;
                newSHTObj2.Customer__c = rvTriggerMasterData.Sold_to_Name;
                newSHTObj2.SP_100L__c = 0;
                newSHTObj2.Status__c = 'Saved';
                newSHTObj2.Select__c = true;
                 newSHTObj2.Tranche__c =  rvTriggerMasterData.tranche;
                newSHTObj2.Sales_Type__c = 'Obam Sales';
                newSHTObj2.Product_Category__c = 'ULG98';
                newSHTObj2.Contract_Start__c = (stDateMonth == rvTriggerMasterData.Trigger_Month) ?Date.valueof(startDate) : nextMonthStDate;
                newSHTObj2.Contract_End_Date__c = (stDateMonth == rvTriggerMasterData.Trigger_Month) ?Date.valueof(endDate) : nextMonthStDate.addDays(13);
                newSHTObj2.Deal_Comment__c = rvTriggerMasterData.TriggerComment1;
				//added aspart of GSAP BUG-1261339
                newSHTObj2.IsATPVolumeReduced__c=Boolean.valueOf(termTrigger.atpVoltoBeReduced);
                newSHTObj2.IsVolumeHedged__c=Boolean.valueOf(termTrigger.isVolToBeHedged);
                newSHTObj2.IsZeroPriceDeal__c=Boolean.valueOf(termTrigger.isZeroPriceDeal);
                newSHTObj2.IsGsapDealCreateOn__c=Boolean.valueOf(termTrigger.isGsapDealCreateOn);
                newSHTObj2.IsGsapDealCancelOn__c=Boolean.valueOf(termTrigger.isGsapDealCancelOn);
                newSHTObj2.IsPricingTaxed__c = rvTriggerMasterData.isPricingTaxed !=null ? Boolean.valueOf(rvTriggerMasterData.isPricingTaxed): false;
                newSHTObj2.Price_Condition__c =termTrigger.pricingCondition;
                //end
                newSHTObj2.Location__c =rvTriggerMasterData.MRC_Number_Plant;
                newSHTObj2.Volume_CBM__c=rvTriggerMasterData.TriggerVolume1* 0.05;
				//newSHTObj2.BSP__c = rvTriggerMasterData.BSP;
                //newSHTObj2.MSP__c = rvTriggerMasterData.MSP;
                if(!mrcNoVsSalesPriceWrapMap.isEmpty() && mrcNoVsSalesPriceWrapMap.containsKey(newSHTObj2.MRC_Number__c)){
                        newSHTObj2.BSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj2.MRC_Number__c).BSP;
                        newSHTObj2.MSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj2.MRC_Number__c).MSP;
                    }
                    else{
                        newSHTObj2.BSP__c = rvTriggerMasterData.BSP;
                		newSHTObj2.MSP__c = rvTriggerMasterData.MSP;
                    }
                newSHTObj2.Target_Margin__c = newSHTObj2.SP_100L__c - newSHTObj2.BSP__c;
            }
            if(newSHTObj1 != null && retailMixAdded ){
                system.debug('sht1::'+newSHTObj1.MRC_Number__c+'--'+newSHTObj1.Contract_Start__c+'--'+newSHTObj1.Contract_End_Date__c);
                createSHTList.add(newSHTObj1);
            }
            if(newSHTObj2 != null && retailMixAdded){
                system.debug('sht1::'+newSHTObj2.MRC_Number__c+'--'+newSHTObj2.Contract_Start__c+'--'+newSHTObj2.Contract_End_Date__c);
                createSHTList.add(newSHTObj2);
            }
           triggerMasterIdLst.add(rvTriggerMasterData.Id);
            tmd.Remaining_trigger_volume__c = rvTriggerMasterData.Remaining_trigger_volume != null ?  rvTriggerMasterData.Remaining_trigger_volume - termTrigger.TriggerVolume1 : rvTriggerMasterData.Monthly_volume - termTrigger.TriggerVolume1 ;
            //if(rvTriggerMasterData.MRC_Number_PO_Type != 'TTTI'){
            if(rvTriggerMasterData.Max_number_of_triggers_per_month != null){
                tmd.Remaining_triggers__c = rvTriggerMasterData.Remaining_triggers != NULL ?rvTriggerMasterData.Remaining_triggers - 1: rvTriggerMasterData.Max_number_of_triggers_per_month - 1;
            }
            //updateTriggerMaster.add(rvTriggerMasterData);
            updateTriggerMaster.add(tmd);

        }

    }
        if(!createSHTList.isEmpty()){
            insert createSHTList;
        }
        if(!updateTriggerMaster.isEmpty()){
           update updateTriggerMaster;
        }

        List<String> shtIdList = new List<String>();
        for(SHT__c sht :createSHTList){
            shtIdList.add(sht.Id);
        }
        string LoggedInUsr=UserInfo.getUserId();
        //PBI-1592108, Added Location__r.Name in the query
        List<SHT__c> shtupdateLst = [SELECT Auto_Num__c,BSP__c,Cancellation_Reason_Label__c,Cancellation_Reason__c,Contact_Email__c,
                Contact_Name__c,Contract_End_Date__c,Contract_Start__c,CreatedById,CreatedDate,Created_Time__c,Customer__c,Deal_Comment__c,
                Deal_Hour__c,Effective_Margin__c,Error__c,Grade__c,Handling_Type__c,Id,IsATPVolumeReduced__c,IsDeleted,IsGsapDealCancelOn__c,
                IsGsapDealCreateOn__c,isOlfDeal__c,IsPricingTaxed__c,IsVolumeHedged__c,IsZeroPriceDeal__c,LastModifiedById,LastModifiedDate,
                LastReferencedDate,LastViewedDate,Location__c,Location__r.Name,Margin_vs_MSP__c,Margin__c,Material_Name__c,Material_No__c,MRCNumber__c,
                MRC_Number__c,MRC__c,MSP__c,Name,OLF_Deal_Number__c,OTM__c,OwnerId,Plant_No__c,PO_Type__c,Price_Condition__c,Price_Unit__c,
                Product_Catalogue__c,Product_Category__c,Product_Sub_Group__c,PSP__c,Rv_LastModifiedById__c,Rv_LastModifiedDate__c,
                Sales_Organization__c,Sales_Price__c,Sales_Type__c,SAP_Contract_Number__c,Select__c,Ship_To_Name__c,Ship_To__c,
                SHT_Contract_Number__c,Sold_Price__c,Sold_To_Name__c,SP_100L__c,Status__c,SystemModstamp,Target_Margin__c,Tranche__c,
                Transaction_Id__c,Trigger_Master_Data__c,UserTimezoneOffset__c,Volume_CBM__c,Volume_Unit__c
        FROM SHT__c where CreatedById =:LoggedInUsr AND Status__c = 'Saved' AND (PO_Type__c = 'TTTT' OR PO_Type__c = 'TTTI') order by createdDate desc];
        return shtupdateLst;
    }
    //Start-Added by Surbhi-PBI-1539864
    @AuraEnabled
    public static List<SHT__c> getTriggerSavedDeal(){
        string LoggedInUsr=UserInfo.getUserId();
        //PBI-1592108, Added Location__r.Name in the query
        List<SHT__c> lstofSavedSHTDeals = [SELECT Auto_Num__c,BSP__c,Cancellation_Reason_Label__c,Cancellation_Reason__c,Contact_Email__c,
                Contact_Name__c,Contract_End_Date__c,Contract_Start__c,CreatedById,CreatedDate,Created_Time__c,Customer__c,Deal_Comment__c,
                Deal_Hour__c,Effective_Margin__c,Error__c,Grade__c,Handling_Type__c,Id,IsATPVolumeReduced__c,IsDeleted,IsGsapDealCancelOn__c,
                IsGsapDealCreateOn__c,isOlfDeal__c,IsPricingTaxed__c,IsVolumeHedged__c,IsZeroPriceDeal__c,LastModifiedById,LastModifiedDate,
                LastReferencedDate,LastViewedDate,Location__c,Location__r.Name,Margin_vs_MSP__c,Margin__c,Material_Name__c,Material_No__c,MRCNumber__c,
                MRC_Number__c,MRC__c,MRC__r.Plant__r.Name,MSP__c,Name,OLF_Deal_Number__c,OTM__c,OwnerId,Plant_No__c,PO_Type__c,Price_Condition__c,Price_Unit__c,
                Product_Catalogue__c,Product_Category__c,Product_Sub_Group__c,PSP__c,Rv_LastModifiedById__c,Rv_LastModifiedDate__c,
                Sales_Organization__c,Sales_Price__c,Sales_Type__c,SAP_Contract_Number__c,Select__c,Ship_To_Name__c,Ship_To__c,
                SHT_Contract_Number__c,Sold_Price__c,Sold_To_Name__c,SP_100L__c,Status__c,SystemModstamp,Target_Margin__c,Tranche__c,
                Transaction_Id__c,UserTimezoneOffset__c,Volume_CBM__c,Volume_Unit__c
        FROM SHT__c where CreatedById =:LoggedInUsr AND Status__c = 'Saved' AND (PO_Type__c = 'TTTT' OR PO_Type__c = 'TTTI') order by createdDate desc];
        return lstofSavedSHTDeals;
    }
     //End-Added by Surbhi-PBI-1539864
    @AuraEnabled
    public static List<SHT__c> confirmTermTriggerDeal(List<SHT__c> confirmTriggerList){
        System.debug('=========confirmTriggerList=========='+confirmTriggerList);
        List<SHT__c> updateSHTList = new List<SHT__c>();
        List<String> triggerMasterIdLst = new List<String>();






         //added by swarna Bug-1287854
        Map<String,RV_SPCalculationController.salesPriceWrap> mrcSalesPrcWrp=new Map<String,RV_SPCalculationController.salesPriceWrap>();
        Map<string,Id> mrcShtIdMap = new Map<string,Id>();
        set<Id> mrcId = new set<Id>();
        date contractStartDate;
        date contractEndDate;
        system.debug('confirmTriggerList in termtrigger:'+confirmTriggerList);
        for(SHT__c termTrigger : confirmTriggerList){
            termTrigger.Status__c = 'Completed';
            if(termTrigger.BSP__c != null && termTrigger.MSP__c!= null){
                termTrigger.Target_Margin__c=termTrigger.MSP__c - termTrigger.BSP__c;
            }
            triggerMasterIdLst.add(termTrigger.Trigger_Master_Data__c);
            updateSHTList.add(termTrigger);
             mrcId.add(termTrigger.MRC__c);
            mrcShtIdMap.put(termTrigger.MRC_Number__c,termTrigger.Id);
            contractStartDate=termTrigger.Contract_Start__c;
            contractEndDate=termTrigger.Contract_End_Date__c;
        }


         //Fetching Price for ALL deals to be Confirmed
        RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
        List<RV_SPCalculationController.salesPriceWrap> savedDealSpWrp = new List<RV_SPCalculationController.salesPriceWrap>();
        List<RV_SPCalculationController.priceAuditWrap> salesPriceAuditInsertLst= new List<RV_SPCalculationController.priceAuditWrap>();
        spAdtWrp = RV_SHT_CreateController.getSavedDealPricePerMrc(mrcId,string.valueOf(contractStartDate),string.valueOf(contractEndDate));
        system.debug('spAdtWrp::'+spAdtWrp);
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
        //end by swarna BUG-1287854
        if(!updateSHTList.isEmpty()){
            update updateSHTList;
        }
       System.debug('#### triggerMasterIdLst 787 size'+triggerMasterIdLst);
        List<SHT__c> shtupdateLst = [SELECT Auto_Num__c,BSP__c,Cancellation_Reason_Label__c,Cancellation_Reason__c,Contact_Email__c,
                Contact_Name__c,Contract_End_Date__c,Contract_Start__c,CreatedById,CreatedDate,Created_Time__c,Customer__c,Deal_Comment__c,
                Deal_Hour__c,Effective_Margin__c,Error__c,Grade__c,Handling_Type__c,Id,IsATPVolumeReduced__c,IsDeleted,IsGsapDealCancelOn__c,
                IsGsapDealCreateOn__c,isOlfDeal__c,IsPricingTaxed__c,IsVolumeHedged__c,IsZeroPriceDeal__c,LastModifiedById,LastModifiedDate,
                LastReferencedDate,LastViewedDate,Location__c,Margin_vs_MSP__c,Margin__c,Material_Name__c,Material_No__c,MRCNumber__c,
                MRC_Number__c,MRC__c,MSP__c,Name,OLF_Deal_Number__c,OTM__c,OwnerId,Plant_No__c,PO_Type__c,Price_Condition__c,Price_Unit__c,
                Product_Catalogue__c,Product_Category__c,Product_Sub_Group__c,PSP__c,Rv_LastModifiedById__c,Rv_LastModifiedDate__c,
                Sales_Organization__c,Sales_Price__c,Sales_Type__c,SAP_Contract_Number__c,Select__c,Ship_To_Name__c,Ship_To__c,
                SHT_Contract_Number__c,Sold_Price__c,Sold_To_Name__c,SP_100L__c,Status__c,SystemModstamp,Target_Margin__c,Tranche__c,
                Transaction_Id__c,Trigger_Master_Data__c,UserTimezoneOffset__c,Volume_CBM__c,Volume_Unit__c
        FROM SHT__c where Trigger_Master_Data__c in:triggerMasterIdLst AND Status__c = 'Completed'];
        System.debug('#### shtquery 787 size'+shtupdateLst.size());
        return shtupdateLst;
    }

    @AuraEnabled
    public static List<SHT__c> deleteTermTriggerDeal(String RecordId){
        System.debug('======RecordId======='+RecordId);
		List<String> tmdIds = new List<String>();
        List<RV_Trigger_Master_Data__c> updatetrgrMsterDataLst = new List<RV_Trigger_Master_Data__c>();
        Map<String,Decimal> shtMap = new Map<String,Decimal>();
		//PBI-1592108, Added-Location__r.Name in the below query
        SHT__c shtupdateLst = [SELECT Auto_Num__c,BSP__c,Cancellation_Reason_Label__c,Cancellation_Reason__c,Contact_Email__c,
                Contact_Name__c,Contract_End_Date__c,Contract_Start__c,CreatedById,CreatedDate,Created_Time__c,Customer__c,Deal_Comment__c,
                Deal_Hour__c,Effective_Margin__c,Error__c,Grade__c,Handling_Type__c,Id,IsATPVolumeReduced__c,IsDeleted,IsGsapDealCancelOn__c,
                IsGsapDealCreateOn__c,isOlfDeal__c,IsPricingTaxed__c,IsVolumeHedged__c,IsZeroPriceDeal__c,LastModifiedById,LastModifiedDate,
                LastReferencedDate,LastViewedDate,Location__c,Location__r.Name,Margin_vs_MSP__c,Margin__c,Material_Name__c,Material_No__c,MRCNumber__c,
                MRC_Number__c,MRC__c,MSP__c,Name,OLF_Deal_Number__c,OTM__c,OwnerId,Plant_No__c,PO_Type__c,Price_Condition__c,Price_Unit__c,
                Product_Catalogue__c,Product_Category__c,Product_Sub_Group__c,PSP__c,Rv_LastModifiedById__c,Rv_LastModifiedDate__c,
                Sales_Organization__c,Sales_Price__c,Sales_Type__c,SAP_Contract_Number__c,Select__c,Ship_To_Name__c,Ship_To__c,
                SHT_Contract_Number__c,Sold_Price__c,Sold_To_Name__c,SP_100L__c,Status__c,SystemModstamp,Target_Margin__c,Tranche__c,
                Transaction_Id__c,Trigger_Master_Data__c,UserTimezoneOffset__c,Volume_CBM__c,Volume_Unit__c
        FROM SHT__c where Id=:RecordId];

        shtupdateLst.Status__c = 'Cancelled';
        update shtupdateLst;
			shtMap.put(shtupdateLst.Trigger_Master_Data__c , shtupdateLst.Volume_CBM__c);

		List<RV_Trigger_Master_Data__c> trgrMsterDataLst = [Select Id, Name, Sold_to_Name__c, Sold_to_Number__c, MRC_Number__c, Remaining_triggers__c,
                                                                Ship_To_Number__c, Monthly_volume__c, Trigger_Month__c, Trigger_Year__c, Min_Trigger_Volume__c,
                                                                 Max_Trigger_Volume__c, Max_number_of_triggers_per_month__c, Remaining_trigger_volume__c, SHT__c
                                                                 from RV_Trigger_Master_Data__c where Id =:shtupdateLst.Trigger_Master_Data__c];
                    if(trgrMsterDataLst.size() > 0){
                        for(RV_Trigger_Master_Data__c eachTMD : trgrMsterDataLst){

					    eachTMD.Remaining_trigger_volume__c = eachTMD.Remaining_trigger_volume__c != null ? eachTMD.Remaining_trigger_volume__c + shtMap.get(eachTMD.Id) : shtMap.get(eachTMD.Id);
                        eachTMD.Remaining_triggers__c = eachTMD.Remaining_triggers__c != null ? eachTMD.Remaining_triggers__c + 1 : 1;


                           // eachTMD.Remaining_trigger_volume__c = eachTMD.Remaining_trigger_volume__c +  shtMap.get(eachTMD.Id) ;
                           // eachTMD.Remaining_triggers__c = eachTMD.Remaining_triggers__c + 1;
                            updatetrgrMsterDataLst.add(eachTMD);
                        }
                    }
            update updatetrgrMsterDataLst;
			string LoggedInUsr = UserInfo.getUserId();
        //PBI-1592108, Added-Location__r.Name in the below query
        return [SELECT Auto_Num__c,BSP__c,Cancellation_Reason_Label__c,Cancellation_Reason__c,Contact_Email__c,
                Contact_Name__c,Contract_End_Date__c,Contract_Start__c,CreatedById,CreatedDate,Created_Time__c,Customer__c,Deal_Comment__c,
                Deal_Hour__c,Effective_Margin__c,Error__c,Grade__c,Handling_Type__c,Id,IsATPVolumeReduced__c,IsDeleted,IsGsapDealCancelOn__c,
                IsGsapDealCreateOn__c,isOlfDeal__c,IsPricingTaxed__c,IsVolumeHedged__c,IsZeroPriceDeal__c,LastModifiedById,LastModifiedDate,
                LastReferencedDate,LastViewedDate,Location__c,Location__r.Name,Margin_vs_MSP__c,Margin__c,Material_Name__c,Material_No__c,MRCNumber__c,
                MRC_Number__c,MRC__c,MSP__c,Name,OLF_Deal_Number__c,OTM__c,OwnerId,Plant_No__c,PO_Type__c,Price_Condition__c,Price_Unit__c,
                Product_Catalogue__c,Product_Category__c,Product_Sub_Group__c,PSP__c,Rv_LastModifiedById__c,Rv_LastModifiedDate__c,
                Sales_Organization__c,Sales_Price__c,Sales_Type__c,SAP_Contract_Number__c,Select__c,Ship_To_Name__c,Ship_To__c,
                SHT_Contract_Number__c,Sold_Price__c,Sold_To_Name__c,SP_100L__c,Status__c,SystemModstamp,Target_Margin__c,Tranche__c,
                Transaction_Id__c,Trigger_Master_Data__c,UserTimezoneOffset__c,Volume_CBM__c,Volume_Unit__c
        FROM SHT__c where /*Trigger_Master_Data__c =:shtupdateLst.Trigger_Master_Data__c*/ (PO_Type__c = 'TTTT' OR PO_Type__c = 'TTTI') AND Status__c = 'Saved' AND CreatedById =:LoggedInUsr];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getUserList ()
    {
        Map<String, String> returnUserList = new Map<String, String>();

        returnUserList.put('ME','Me');
        returnUserList.put('ALL','All');

        if (Schema.sObjectType.PermissionSetAssignment.isAccessible())
        {
            PermissionSetAssignment[] psa = [SELECT Id, AssigneeId, Assignee.name FROM PermissionSetAssignment where PermissionSet.name='RV_DI' and Assignee.isActive = true order by Assignee.name];

            if(psa.size()>0)
            {
                for (PermissionSetAssignment p : psa)
                {
                    if(!p.Assignee.name.equals(UserInfo.getName()))
                        returnUserList.put(p.AssigneeId,p.Assignee.name);
                }
            }
        }
        System.debug('returnUserList =' + returnUserList);
        return returnUserList;
    }

    public class termTriggerWrapperData{
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public Decimal TriggerVolume1{get;set;}
        @AuraEnabled
        public Integer TriggersLeft{get;set;}
        @AuraEnabled
        public String TriggerComment1{get;set;}
        @AuraEnabled
        public String salesOrg{get;set;}
          @AuraEnabled
        public String shipToNumber{get;set;}
        @AuraEnabled
        public String Sold_to_Name{get;set;}
        @AuraEnabled
        public String Sold_to_Number{get;set;}
        @AuraEnabled
        public String MRC_Number{get;set;}
        @AuraEnabled
        public Decimal Monthly_volume{get;set;}
        @AuraEnabled
        public String Trigger_Month{get;set;}
        @AuraEnabled
        public String Trigger_Year{get;set;}
        @AuraEnabled
        public Integer Min_Trigger_Volume{get;set;}
        @AuraEnabled
        public Integer Max_Trigger_Volume{get;set;}
        @AuraEnabled
        public Integer Max_number_of_triggers_per_month{get;set;}
        @AuraEnabled
        public Integer Remaining_triggers{get;set;}
        @AuraEnabled
        public Decimal Remaining_trigger_volume{get;set;}
        @AuraEnabled
        public String MRC_Number_Name{get;set;}
        @AuraEnabled
        public String MRC_Number_Contract{get;set;}
        @AuraEnabled
        public String MRC_Number_Material_Description{get;set;}
        @AuraEnabled
        public String MRC_Number_Product{get;set;}
        @AuraEnabled
        public String MRC_Number_Ship_to_Number{get;set;}
        @AuraEnabled
        public Integer MRC_Number_Mode_Of_Transport{get;set;}
        @AuraEnabled
        public String MRC_Number_PO_Type{get;set;}
        @AuraEnabled
        public String MRC_Number_Plant{get;set;}
        @AuraEnabled
        public String MRC_Number_Id{get;set;}
        @AuraEnabled
        public String MRC_Number_Plant_Name{get;set;}
        @AuraEnabled
        public String MRC_Number_Plant_Plant_Code{get;set;}
        @AuraEnabled
        public String MRC_Number_Product_Name{get;set;}
		@AuraEnabled
        public Decimal BSP{get;set;}
        @AuraEnabled
        public Decimal MSP{get;set;}
        @AuraEnabled
        public boolean isPricingTaxed{get;set;}
        @AuraEnabled
        public String pricingCondition{get;set;}
        @AuraEnabled
        public boolean atpVoltoBeReduced{get;set;}
        @AuraEnabled
        public boolean isVolToBeHedged{get;set;}
        @AuraEnabled
        public boolean isZeroPriceDeal{get;set;}
        @AuraEnabled
        public boolean isGsapDealCreateOn{get;set;}
        @AuraEnabled
        public boolean isGsapDealCancelOn{get;set;}
        @AuraEnabled
        public boolean retroAtpVoltoBeReduced{get;set;}
        @AuraEnabled
        public boolean retroVolToBeHedged{get;set;}
        @AuraEnabled
        public boolean retroGsapDealCreateOn{get;set;}
        @AuraEnabled
        public boolean retroGsapDealCancelOn{get;set;}
        @AuraEnabled
        public String tranche{get;set;}
    }

    public class termTriggerWrapper{
        @AuraEnabled
        public Sobject triggerMasterData{get;set;}
        @AuraEnabled
        public Integer TriggerVolume1{get;set;}
        @AuraEnabled
        public Integer TriggersLeft{get;set;}
        @AuraEnabled
        public String TriggerComment1{get;set;}
        @AuraEnabled
        public String salesOrg{get;set;}
        @AuraEnabled
        public String shipToNumber{get;set;}
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
        public String tranche;

        public termTriggerWrapper(){
            //triggerMasterData = new Sobject();
            TriggerVolume1 = 0;
            TriggerComment1 = '';
        }
    }

    public class finalTermTriggerWrap{
        @AuraEnabled
        public List<SHT__c> shtList{get;set;}
        @AuraEnabled
        public List<termTriggerWrapper> termTriggerWrapperList{get;set;}
        @AuraEnabled
        public List<String> shtNo{get;set;}
        @AuraEnabled
        public List<String> soldToList{get;set;}
        @AuraEnabled
        public List<String> poTypeList{get;set;}
        @AuraEnabled
        public Boolean hasEditAccess{get;set;}
    }
}
