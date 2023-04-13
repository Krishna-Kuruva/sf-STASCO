public class rv_sht_CreateControllerLWC {
    //START | |||||Rahul Sharma||===|=== | Date - 22-Jul-2020 : Added checkbox to determine MRCs available for OLF.
    private static Boolean filterOlfMRCs = false;
    //END | Rahul Sharma | Date - 22-Jul-2020 : Added checkbox to determine MRCs available for OLF.
    /*START | Rahul Sharma | Date - 17-Mar-2020 : Updated method pmotarameters to take Ship-to account as a list instead of Sold-to account.
    *Also *Updated relavent logic to query MRCs based on Ship-to account */
    @AuraEnabled
    public static string checkMRC(string mrcInput){
        string mrcAvailability='';
        if(mrcInput != null){
            if(!mrcInput.startsWith('0') ){
                mrcInput = '0'+ mrcInput;
               }
            MRC__c mrcrec = [Select Id, Contract__c from MRC__C where Contract__c =:mrcInput limit 1 ];
            if(mrcrec != null && mrcrec.Contract__c != null ){
                mrcAvailability = 'Available';
            }
            else{
                mrcAvailability = 'notAvailable';
            }
        }

        return mrcAvailability;
    }
    public static List<MRCDataWrap>  getMRCRecordsData(String tranche ,String Mrcno ,Set<Id> accIdSet,
            List<String> shipto,Boolean checked ,Boolean agoChk,
            Boolean igoChk,Boolean mogasChk,string poType,String salesOrg,
            List<String> plant,List<String> mot,string contractStartDate,
            string contractEndDate,boolean callFromOlf)
    {
        system.debug('Mrcno::'+Mrcno+mogasChk+checked);

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

		List<String> plantList = new List<String>();
        for(String plnt : plant){
            if(plnt != null && plnt != '' && plnt != ' '){
                 plantList.add(plnt);

            }
        }

         // START: Added as part of 1306836 : ASHISH
      List<String> shipToSet = new List<String>();
    List<String> shipToList = new List<String>();
        if(shipto!= null && shipto.size() > 0){
            List<String> shipToAccNum1 = shipto[0].split(',');
            for(String shpTo : shipToAccNum1){
                if(shpTo != null && shpTo != '' && shpTo != ' '){
                    if(!shpTo.startsWith('0'))
                        shpTo = '00'+ shpTo;
                    else if(shpTo.startsWith('00'))
                        shpTo = shpTo;
                    else if(shpTo.startsWith('0'))
                        shpTo = '0'+ shpTo;

                    shipToList.add(shpTo);
                }


            }
        }

        shipToSet.addAll(shipToList);

		List<String> salesOrgLst = new List<String>();
        List<String> salesOrgLst1 = new List<String>();
        salesOrgLst1 = salesOrg != null ? salesOrg.split(';') : null;
          for (String str : salesOrgLst1) {
                  String salesOrgStr = '';
                  if(String.isNotEmpty(str) && str!=null){
                      salesOrgStr = str;
                    salesOrgLst.add(str);
                  }
              }
		system.debug('salesOrgLst::'+salesOrgLst);

        System.debug('=======mot======='+mot);
        List<Integer> motIntegerLst = new List<Integer>();

        for(String str : mot){
            system.debug('str of mot in deal entry:'+str);
            motIntegerLst.add(Integer.valueOf(str));

        }

        System.debug('=======motIntegerLst======='+motIntegerLst);

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
        if(mogasChk ){
            productSet.add('ULG95 E5');
            productSet.add('ULG95_BOB_E5');
            productSet.add('ULG95_BOB_E10');
            productSet.add('ULG95 E10');
            productSet.add('ULG98');
            productSet.add('ULG95 E0');
            productSet.add('ULG100 VP');
            productSet.add('AVGAS');
        }

        Set<String> myLocationsSet = new Set<String>();
        Map<String,Revolution_Dashboard__c> revDashboardMap = new Map<String,Revolution_Dashboard__c>();
        Map<String,Margin__c> marginMap = new Map<String,Margin__c>();
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
        String query='select id,name,Plant__c,Plant__r.Name,Plant__r.Country__c,Plant_code__c,Contract_Description__c,Plant__r.Plant_Code__c,'+
                'Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Material_Description__c,Material_Name__c,PO_Type__c,'+
                ' Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,'+
                ' Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,Online_Material_Name_Taxed__c,'+
                ' Online_Material_Name_UnTaxed__c,Online_Customer_Name__c from MRC__c WHERE Active__c = true ';
        //recordTypeId=:recTypeId and
        string queryPart='';
        String mrc='';

		queryPart = queryPart + ' and Material_Description__c IN :productSet and Valid_To_Date__c >= TODAY';
		if(salesOrgLst.size() > 0){
            queryPart = queryPart + ' AND Sales_Organization__c IN :salesOrgLst ';
          }
        List<String> mrcList1 = mrcNo.split(',');
        list<String> MrcnoList = new List<String>();
        system.debug('mrcList::'+mrcList1);
        for(String Mrcnoo : mrcList1){
            system.debug('mrcStr::'+Mrcnoo);
                Mrcnoo = Mrcnoo.replace('[','');
                Mrcnoo = Mrcnoo.replace(']','');
                Mrcnoo = Mrcnoo.replace('"','');
                system.debug('Mrcnoo::'+Mrcnoo);
            if(Mrcnoo.startsWithIgnoreCase('0Truck') || Mrcnoo.startsWithIgnoreCase('0Barge')){
               // mrc = '%'+ Mrcno + '%';
                //queryPart='AND Name LIKE :mrc ';
            }
            else if(!Mrcnoo.startsWith('0') && Mrcnoo != '' && Mrcnoo != null && !Mrcnoo.startsWith('MRC')){
                Mrcnoo = '0'+ Mrcnoo;
               MrcnoList.add(string.valueOf(Mrcnoo));
              }
			else if(Mrcnoo.startsWith('MRC')){
                Mrcnoo = Mrcnoo+'-';
                MrcnoList.add(string.valueOf(Mrcnoo));
            }
            if(string.valueOf(Mrcnoo) != null && string.valueOf(Mrcnoo) != ''){
                MrcnoList.add(string.valueOf(Mrcnoo));

            }

            }
            if( MrcnoList.size() > 0){
            queryPart= queryPart + ' AND MRC_Number__c IN :MrcnoList ';
        }

		system.debug('plant::'+plant.isEmpty()+'--'+plant.size()+'--'+plant);
        if( !plantList.isEmpty() && plantList.size()>0){
            queryPart = queryPart +' AND Plant__c IN :plantList ';
        }

        if(!accIdSet.isEmpty()){
            queryPart= queryPart + ' AND Ship_To__c IN :accIdSet ';
        }


        if( poType!=null && poType!= ''){

            queryPart= queryPart+ ' AND PO_Type__c= :poType';
        }

        /*if(shipto != null && !'none'.equals(shipto) && shipto != '' ){
            if(!shipto.startsWith('0'))
                shipto = '00'+ shipto;
            else if(shipto.startsWith('00'))
                shipto = shipto;
            else if(shipto.startsWith('0'))
                shipto = '0'+ shipto;
            queryPart= queryPart + ' AND Ship_to_Number__c = :shipto ';

        }*/
         if( !shipToList.isEmpty() && shipToList.size()>0){
            queryPart = queryPart +' AND Ship_to_Number__c IN :shipToList ';
        }
        if(motIntegerLst.size()>0 && !motIntegerLst.isEmpty()){
            queryPart += ' AND Shipping_Condition__c IN:motIntegerLst ';
        }

        if(callFromOlf){
            queryPart=queryPart+' AND Rv_Available_for_OLF__c = true';
        }

        if(filterOlfMRCs && !callFromOlf){
            queryPart=queryPart+' AND RV_OLF_MRC_Only__c = true';
        }
        else if(!filterOlfMRCs && !callFromOlf){
            queryPart=queryPart+' AND RV_OLF_MRC_Only__c = false';
        }

        string queryOrderBy=' ORDER BY MRC_Number__c,Plant__r.Name,MRC_Grade_Sort__c ASC';
        system.debug('query::'+query);
        system.debug('queryPart::'+queryPart);
        system.debug('queryOrderBy::'+queryOrderBy);

        string queryString=query+queryPart+queryOrderBy;

        system.debug('queryString::'+queryString);
        mrcList = Database.query (queryString);
        system.debug('checked::'+checked+mrcList.size());
        //remove ULG95 E5 and 98
        if(mogasChk && checked){
            system.debug('mrcList::'+mrcList.size());
            Map<String,Set<String>> planCodeRtlMixMrcLstMap= new Map<String,Set<String>>();
            Set<String> MrcNoFinalSet= new Set<String>();
            for(MRC__c mrcObj : mrcList){
                system.debug('mrcObj@201::'+mrcObj.Material_Description__c);
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
            system.debug('MrcNoFinalSet@214::'+MrcNoFinalSet.size());
            for(string plntCod : planCodeRtlMixMrcLstMap.Keyset()){
                Set<String> mrcNolst=planCodeRtlMixMrcLstMap.get(plntCod);
                if(mrcNolst.size()== 3){
                    MrcNoFinalSet.addall(mrcNolst);
                }
            }
            system.debug('MrcNoFinalSet@221::'+MrcNoFinalSet.size());
            List<Mrc__c> mrcNewLst = new List<Mrc__c>();
            for(MRC__c mrcObj : mrcList){
                if(MrcNoFinalSet.contains(mrcObj.Name)){
                    mrcNewLst.add(mrcObj);
                }
            }
            system.debug('mrcNewLst@228::'+mrcNewLst.size());
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
        tranche = rv_PriceAndMarket.getTranche(date.valueOf(contractStartDate));
        if(callFromOlf){
            RV_SPCalculationController.isOlfDeal = true;
            RV_SPCalculationController.tranche = tranche; //Rahul Sharma | Date - 03-Nov-2020 : Enabled tranche for OLF
        }
        system.debug('mrcfinalList::'+mrcfinalList.size());
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
            system.debug('LocId::'+mr.Plant__c);
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
        List<ATP__c> atpList = [select id , name ,Location__c,Location__r.Name,ATP_Live__c,ATP2_Live__c,ATP3_Live__c,Sales_8_30_17_30__c,Sales_15_28__c,Sales_29_61__c,
                location__r.Related_Plant__c,location__r.Related_Plant_Code__c,Sales_D_00_14__c,Sales_D_15_28__c,Sales_D_29_61__c,
                Plant_Code__c,Company_Code__c ,Grade_Level2__c,Live_Online_00_14__c,Live_Online_ATP2__c,Live_Online_ATP3__c from ATP__c
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
        Map<String, Customer_Specific_Pricing__c> cspMap = new Map<String, Customer_Specific_Pricing__c>();
        for(Customer_Specific_Pricing__c csp : [SELECT Id,Account__c, CSP_Eur_100L__c, Grade__c,Plant__c,Plant__r.Plant_Code__c, Sales_Org__c,Tranche__c
                                 FROM Customer_Specific_Pricing__c WHERE  Plant__c IN : LocIds]){
                                //Account__c IN : accountIdSet AND Sales_Org__c IN : salesOrgSet AND Grade__c IN : gradeSet AND Tranche__c =: tranche
           // String cspKey = csp.Sales_Org__c + csp.Account__c + csp.Plant__r.Plant_Code__c + csp.Grade__c;
           String cspKey = csp.Sales_Org__c + csp.Account__c + csp.Plant__r.Plant_Code__c + csp.Grade__c+csp.Tranche__c;
            cspMap.put(cspKey, csp);
        }



        Id marginRecordTypeId = Schema.SObjectType.Margin__c.getRecordTypeInfosByDeveloperName().get('Truck_ITT').getRecordTypeId();

        List<Margin__c> marginList = [SELECT Id,
                                                 Sales_Org__c,
                                                 Plant__c,
                                                 Sales_Mgn_AGO_B7__c,
                                                 Sales_Mgn_IGO_50ppm__c,
                                          		 Tranche__c,
                                                 Sales_Mgn_ULG95_E5__c FROM Margin__c WHERE  Plant__c IN : LocIds AND
                                                                                            RecordTypeId =: marginRecordTypeId];
                                                                                            //Sales_Org__c IN : salesOrgSet AND
        for(Margin__c mrg : marginList){
            marginMap.put(mrg.Plant__c, mrg);
        }
        String dashboardRecTypeId = Schema.SObjectType.Revolution_Dashboard__c.getRecordTypeInfosByName().get('Dashboard').getRecordTypeId();
		List<Revolution_Dashboard__c> allLocAtpPrcLst=new List<Revolution_Dashboard__c>();
        String dashboardqueryString ='SELECT ATP1_Live_AGO__c,ATP1_Live_IGO__c,ATP1_Live_MOGAS__c,BSP_AGO__c,'+
            		 ' BSP_GTL__c,BSP_IGO__c,BSP_MOGAS__c,Id,'+
                     'MOT__c,MRC_Name__c,Name,OTM_AGO__c,UniqueKey__c ,'+
                     'OTM_IGO__c,OTM_MOGAS__c,Plant_Code__c,Plant_Name__c,Plant_Name__r.Name,'+
                     'PSP_AGO__c,PSP_IGO__c,PSP_MOGAS__c,Sales_Channel__c,Shipping_Condition__c,'+
            		 'BSP_w_o_Tax_AGO__c,BSP_w_o_Tax_IGO__c,BSP_w_o_Tax_MOGAS__c,BSP_w_o_Tax_GTL__c,'+
            		 'PSP_w_o_Tax_AGO__c,PSP_w_o_Tax_IGO__c,PSP_w_o_Tax_MOGAS__c,'+
            		 'OTM_w_o_Tax_AGO__c,OTM_w_o_Tax_IGO__c,OTM_w_o_Tax_MOGAS__c,'+
                     //Fix_260839_Lakshmi_20May2019 starts
            		 'Total_Tax_AGO__c,Total_Tax_IGO__c,Total_Tax_MOGAS__c,Total_Tax_GTL__c,'+
            		 //Fix_260839_Lakshmi_20May2019 ends
            	     'ATP2_Live_AGO__c,ATP2_Live_IGO__c,ATP2_Live_MOGAS__c,ATP3_Live_IGO__c,ATP3_Live_AGO__c,ATP3_Live_MOGAS__c'+
                     ' FROM Revolution_Dashboard__c '+
            		 ' where  RecordTypeId =\''+ ''+dashboardRecTypeId+'\'';
                     //Sales_Channel__c IN :channel and MOT__c IN: MOT and
        /*if(myLocationsSet.size()>0){
            queryString=queryString + ' and Plant_Code__c IN: myLocationsSet ';
        }*/
        dashboardqueryString=dashboardqueryString+' order by Plant_Name__r.Name';
        allLocAtpPrcLst = Database.query (dashboardqueryString);
        for(Revolution_Dashboard__c revdashboard : allLocAtpPrcLst){
            revDashboardMap.put(revdashboard.Plant_Name__c,revdashboard);
        }

        list<String> mrcNoOfferList = new List<String>();
        for(String mrcObj : MrcnoList){
            if(mrcObj.contains('-')){
                mrcNoOfferList.add(mrcObj.removeEnd('-'));
            }else{
                mrcNoOfferList.add(mrcObj);
            }
        }

        /* Start | code developed by Mohan to get and display offer details in price and marketing view */
       // List<RV_Offer_Tracking__c> offerTrackingDetailsList = [SELECT Id, MRC_Header__c, MRC_line_item__c, Offered_Price_100l__c, Offered_Volume_in_cbm__c from RV_Offer_Tracking__c where MRC_Header__c IN : MrcnoList order by MRC_Header__c,createdDate desc];
       // system.debug('offerTrackingDetailsList::'+offerTrackingDetailsList);
       // system.debug('offerTrackingDetailsList mrc::'+MrcnoList);
        List<RV_Offer_Tracking__c> offerTrackingDetailsList = new List<RV_Offer_Tracking__c>();
        String offerQuery='SELECT Id, MRC_Header__c, MRC_line_item__c, Offered_Price_100l__c, Offered_Volume_in_cbm__c,Total_Offered_Volume_in_cbm__c, createdDate from RV_Offer_Tracking__c where Sold_To_Name__c!=\'\' AND is_Active__c=true ';
        if(mrcNoOfferList.size()>0){
            offerQuery += ' AND MRC_Header__c In : mrcNoOfferList ';
        }
        if(!accIdSet.isEmpty()){
            offerQuery +=' AND Ship_To_Name__c IN :accIdSet ';
        }

        offerQuery+=' order by MRC_Header__c,createdDate desc';
        system.debug('offerQuery:'+offerQuery);
        offerTrackingDetailsList = Database.query (offerQuery);
        system.debug('offerTrackingDetailsList data :'+offerTrackingDetailsList);



        Map<String, RV_Offer_Tracking__c> offerTrackMap = new Map<String, RV_Offer_Tracking__c>();
        if(offerTrackingDetailsList.size()>0){
            for(RV_Offer_Tracking__c offer : offerTrackingDetailsList ){
                if(!offerTrackMap.containsKey(offer.MRC_Header__c+'-'+offer.MRC_line_item__c)) {
                    offerTrackMap.put(offer.MRC_Header__c+'-'+offer.MRC_line_item__c, offer);
                }
            }
        }
        system.debug('offerTrackMap:'+offerTrackMap);
        /* End | code developed by Mohan to get and display offer details in price and marketing view */

        //create wraper object
        MRCDataWrap wrapObj ;
        Decimal atpVal = 0;
        string grade = '';
        Decimal salesD = 0;
        Decimal atpOnline = 0;
        //lastOfferedPrice



        for(MRC__c mrcObj : mrcfinalList){
            wrapObj = new MRCDataWrap();
            atpVal =0;
            salesD = 0;
            atpOnline = 0;
            wrapObj.mrcId = mrcObj.id;

            if( mrcObj.Material_Description__c != null){
                grade = mrcObj.Material_Description__c;
            }
            wrapObj.grade = grade;
            if(grade == 'ULG95 E5' || grade == 'ULG98') { // || grade == 'GTL B0' || grade=='GTL B7'){ commented for PBI 1843678
                wrapObj.showFinalOTM = false;

            } else {
                wrapObj.showFinalOTM = true;

            }
            if(mrcObj.Sold_To__c != null){
                wrapObj.accId=mrcObj.Sold_To__c;
                wrapObj.accName=mrcObj.Sold_To__r.Name;

            }
            if(callFromOlf && mrcObj.Online_Customer_Name__c != null){
                wrapObj.accName=mrcObj.Online_Customer_Name__c;
            }
            List<String> mrcNames = mrcObj.Name.split('-');
            wrapObj.contractDescription = mrcObj.Contract_Description__c;
            wrapObj.mrcNameMogas= mrcNames[0];
            wrapObj.mrcName = mrcObj.Name;
            wrapObj.salesOrg =mrcObj.Sales_Organization__c;
            wrapObj.materialNo =(mrcObj.Product__r.Name).right(4);
            wrapObj.materialName=mrcObj.Material_Name__c;
            wrapObj.shipToNumber = mrcObj.Ship_to_Number__c;
            wrapObj.locationId=mrcObj.Plant__c;
            wrapObj.location = mrcObj.Plant_Code__c;
            wrapObj.tranche = tranche;
            if(callFromOlf && mrcObj.Online_Location_Name__c != null){
                wrapObj.locationName = mrcObj.Online_Location_Name__c;
            }else{
                wrapObj.locationName = mrcObj.Plant__r.Name;
            }
           // wrapObj.dailySales = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_D_00_14__c;

            //Get  ATP values for Account based on Material Number
            String prdtName = productMap.get(grade);
            if(tranche == 'ATP1'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName) !=null){
                        if(prdtName.contains('ULG')){
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmMogas).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmMogas).intValue() : null;	//AdditionalFix_326425_14Nov2019_Soumyajit
							salesD = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_8_30_17_30__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_8_30_17_30__c/Decimal.valueOf(Label.Mogas_Density) : null;
                            atpOnline = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c/Decimal.valueOf(Label.Mogas_Density) : null;
						}else{
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmAgoIgo).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmAgoIgo).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
							salesD = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_8_30_17_30__c/Decimal.valueOf(Label.AGO_IGO_Density);
                            atpOnline = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c/Decimal.valueOf(Label.AGO_IGO_Density);
						}

                    }
                }
            }
            else if(tranche == 'ATP2'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if( atpLocMap.get(mrcObj.Plant_Code__c+prdtName) != null){
                        if(prdtName.contains('ULG')){
                            //atpVal = ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmMogas).round(System.RoundingMode.HALF_UP);	//AdditionalFix_326425_14Nov2019_Soumyajit
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmMogas).intValue() : null;	//AdditionalFix_326425_14Nov2019_Soumyajit
							salesD= atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c/Decimal.valueOf(Label.Mogas_Density) : null;
                            atpOnline = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c/Decimal.valueOf(Label.Mogas_Density) : null;
						}else{
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmAgoIgo).intValue() : null;	//AdditionalFix_326425_14Nov2019_Soumyajit
							salesD = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
                            atpOnline = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
						}

                    }
                }
            }
            else{
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName) != null){
                        if(prdtName.contains('ULG')){
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmMogas).intValue() : null;	//AdditionalFix_326425_14Nov2019_Soumyajit
						    salesD = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c/Decimal.valueOf(Label.Mogas_Density) : null;
                            atpOnline = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c/Decimal.valueOf(Label.Mogas_Density) : null;
                        }else{
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmAgoIgo).intValue() : null;	//AdditionalFix_326425_14Nov2019_Soumyajit
							salesD = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
                            atpOnline = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
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
            if(atpVal != null){
                wrapObj.atpLive = (callFromOlf)? atpVal : (atpVal + atpLiveRelated);	//Fix_437452_02Mar2020_Soumyajit
            }	//Fix_437452_02Mar2020_Soumyajit
            //final Atp for selected tranche
            system.debug('margin map::'+marginMap.get(mrcObj.Plant__c));
           // system.debug('cspMap::'+cspMap.get(mrcObj.Plant__c));
           /* if(marginMap != null && marginMap.get(mrcObj.Plant__c) != null &&  marginMap.get(mrcObj.Plant__c).Sales_Mgn_AGO_B7__c != null
                 && cspMap != null && cspMap.get(mrcObj.Plant__c) != null && cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != null){
                wrapObj.finalOTM = marginMap.get(mrcObj.Plant__c).Sales_Mgn_AGO_B7__c+cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c;
            }else{
                wrapObj.finalOTM = 0;
            }*/
            wrapObj.atpLiveRelated = atpLiveRelated;
            wrapObj.onlineATP = atpOnline;
            wrapObj.dailySales = salesD;//added by swarna
            system.debug('PhoneATP::'+revDashboardMap.get(mrcObj.Plant__c));
            if(revDashboardMap != null && mrcObj.Plant__c!= null && revDashboardMap.get(mrcObj.Plant__c)!=null && revDashboardMap.get(mrcObj.Plant__c).ATP1_Live_AGO__c != null){
                wrapObj.phoneATP = revDashboardMap.get(mrcObj.Plant__c).ATP1_Live_AGO__c;
            }else{
                wrapObj.phoneATP = 0;
            }
           // wrapObj.phoneATP = 0;//revDashboardMap.get(mrcObj.Plant__c).ATP1_Live_AGO__c == null ? 0 :revDashboardMap.get(mrcObj.Plant__c).ATP1_Live_AGO__c;
           wrapObj.lastOfferedPrice = (offerTrackMap.get(mrcObj.Name))!=null?string.valueOf((offerTrackMap.get(mrcObj.Name).Offered_Price_100l__c)):'';

           wrapObj.finalatpLive = 0;//(callFromOlf)? atpVal : (atpVal - atpLiveRelated) == null ? 0 : (callFromOlf)? atpVal : (atpVal - atpLiveRelated);	//added by swarna aspart of revemp
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

                if(!shipToSet.contains('00000000') && dealEvent.Shipping_Condition__c.contains(ShipCondNoNameMap.get(Integer.valueOf(mrcObj.Shipping_Condition__c)))){
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
            if( mrcNoSPwrap != null && mrcNoSPwrap.containsKey(mrcObj.Name) && mrcNoSPwrap.get(mrcObj.Name) != null) {
                if(mrcNoSPwrap.get(mrcObj.Name).landedCost != null){
                    wrapObj.landedCostCal=((mrcNoSPwrap.get(mrcObj.Name)).landedCost).setScale(2, RoundingMode.HALF_UP);
                }
                if(mrcNoSPwrap.get(mrcObj.Name).BSP != null){
                    system.debug('BSP::'+mrcNoSPwrap.get(mrcObj.Name));
                    system.debug('bsp Val::'+(mrcNoSPwrap.get(mrcObj.Name)).BSP);
                    wrapObj.finalbspCal=((mrcNoSPwrap.get(mrcObj.Name)).BSP).setScale(2, RoundingMode.HALF_UP);
                }
                if(mrcNoSPwrap.get(mrcObj.Name).MSP != null){
                    wrapObj.finalSalesPriceCal=((mrcNoSPwrap.get(mrcObj.Name)).MSP).setScale(2, RoundingMode.HALF_UP);
                }

                if(mrcNoSPwrap.get(mrcObj.Name).OTM != null /*&& cspMap != null && cspMap.get(mrcObj.Plant__c) != null && cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != null && cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != 0*/){
                    wrapObj.OTM=((mrcNoSPwrap.get(mrcObj.Name)).OTM).setScale(2, RoundingMode.HALF_UP);
                }
                String mrcObjKey = mrcObj.Sales_Organization__c + mrcObj.Sold_To__c + mrcObj.Plant__r.Plant_Code__c + mrcObj.Material_Description__c+tranche;
                if(wrapObj.OTM != null){
                    if(cspMap != null && cspMap.get(mrcObjKey) != null && cspMap.get(mrcObjKey).CSP_Eur_100L__c != null ){
                        wrapObj.finalOTM = (cspMap.get(mrcObjKey).CSP_Eur_100L__c + wrapObj.OTM);
                    } else {
                        wrapObj.finalOTM = wrapObj.OTM;
                    }
                    //wrapObj.finalOTM = wrapObj.OTM + (cspMap != null ? cspMap.get(mrcObj.Plant__c) != null ? cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != null ? wrapObj.OTM : (cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c + wrapObj.OTM) :0 : 0);
                }
                //wrapObj.OTM = ((cspMap != null && cspMap.get(mrcObj.Plant__c) != null && cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != null) ? wrapObj.OTM : null);
                wrapObj.OTM = ((cspMap != null && cspMap.get(mrcObjKey) != null && cspMap.get(mrcObjKey).CSP_Eur_100L__c != null) ? wrapObj.OTM : null);
                decimal totalTax=0;
                if(mrcNoSPwrap.get(mrcObj.Name).totalTax != null){
                    totalTax=((mrcNoSPwrap.get(mrcObj.Name)).totalTax).setScale(2, RoundingMode.HALF_UP);
                }

            }
            //START - Rahul Sharma | Date - 28-Jan-2021 | PBI-702438 : Updated pricePerVol as 0 for zero price deal.
            if(wrapObj.isZeroPriceDeal){
                wrapObj.pricePerVol = 0;
            }
           // wrapObj.dealmargin=0;
            system.debug('wrapObj::'+wrapObj);
            wrapObj.dealmargin= wrapObj.finalOTM != null ? wrapObj.finalbspCal != null ?wrapObj.finalOTM - wrapObj.finalbspCal : 0 : 0;
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
        system.debug('shtId::'+shtId);
        system.debug('status::'+status);
        system.debug('reason::'+reason);
        system.debug('searchList::'+searchList);
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
                Product_Category__c,Status__c,Cancellation_Reason__c,Deal_Comment__c
                ,isOlfDeal__c //270192_OLFDealCancel_08Jul2019_Soumyajit
        from SHT__c where id =:shtId LIMIT 1];
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
            if(reason.contains('-')){
                obj.Deal_Comment__c = reason.SubStringAfter('-')+obj.Deal_Comment__c;
                obj.Cancellation_Reason_Label__c=reason.SubStringBefore('-');
            }else{
                obj.Cancellation_Reason_Label__c=reason;
            }
            Schema.DescribeSObjectResult s = sht__c.sObjectType.getDescribe();
            if(s.isUpdateable()){
                update obj;
            }
        }
        shtDspWrap= getCompletedSHTDeal('TODAY','Completed','Me');
        srchSaveWrp.savedResult=shtDspWrap;
        srchSaveWrp.searchResult=searchWrap;
        srchSaveWrp.cancelMsg=message;
        return srchSaveWrp;

    }


    @AuraEnabled
    public static saveResultsearchWrap saveSHTObjectRecordLWC(String dataList,String trancheVal , string contractStartDate, string contractEndDate,
                                            boolean checked){
                system.debug('dataList::'+dataList);
                system.debug('trancheVal::'+trancheVal);
                system.debug('contractStartDate::'+contractStartDate);
                system.debug('contractEndDate::'+contractEndDate);
                system.debug('checked::'+checked);
                //checked = true;
                date ContractStrtDateToBeSaved=date.valueOf(contractStartDate);
                date ContractEndDateToBeSaved=date.valueOf(contractEndDate);

                if(date.valueOf(contractStartDate) < system.today()){
                    contractStartDate = String.valueOf(System.today());
                    if(date.valueOf(contractEndDate) <= system.today())
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

                //List<MRCDataWrap> listToSave = (List<MRCDataWrap>)JSON.deserialize(dataList, List<MRCDataWrap>.class);
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
            mrcRetMixMrcLst = [SELECT Id,Name,Material_Description__c,Sold_To__c,Plant__c,Plant__r.Name,Plant__r.Country__c,Plant_code__c,
                    Supply_Type__c,Product__c,Product__r.Name, Product__r.Commodity_Grade_L2__c, Product__r.BEHG_Value_100l__c,
                    Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,
                    Product__r.Future_BEHG_valid_from_date__c, Product__r.Future_BEHG_valid_to_date__c, Material_Name__c,PO_Type__c,
                    Sold_To__r.Name,Handling_Type__c,Sales_Organization__c,MRC_Number__c, Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,
                    Online_Material_Name_Taxed__c,Online_Material_Name_UnTaxed__c,Online_Customer_Name__c,Ship_to_Number__c FROM Mrc__c WHERE  Sold_To__c IN :accntIdSet AND
            Material_Description__c IN :retailMixMatSet];

            if(mrcRetMixMrcLst.size()>0){
                for(mrc__c mr:mrcRetMixMrcLst){
                    mrcRetMixMrcMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Name);
                    mrcRetMixMrcIdMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Id);

                }
            }
            system.debug('mrcRetMixMrcMap::'+mrcRetMixMrcMap);
            system.debug('mrcRetMixMrcIdMap::'+mrcRetMixMrcIdMap);
        }
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
                system.debug('dataObj.grade ::'+checked+dataObj.grade+'--'+dataObj.salesOrg );
                Map<String, RV_SPCalculationController.salesPriceWrap> mrcNoVsSalesPriceWrapMap = new Map<String, RV_SPCalculationController.salesPriceWrap>(); //Rahul Sharma | Date- 28-Jan-2021 ; Added mrc numberr vs salesPriceWrap map.
                if(checked && dataObj.grade == 'ULG95 E10' && dataObj.salesOrg !='AT01'){
                    newSHTObj1 = new SHT__c();
                    newSHTObj2 = new SHT__c();
                    retailMixAdded = true;
                    mrcNoVsSalesPriceWrapMap = calculateRetailMixPrice(mrcRetMixMrcLst, contractStartDate, contractEndDate);
                }
                else{
                    retailMixAdded=false;
                }
                system.debug('retailMixAdded::'+retailMixAdded);
                newSHTObj.MRC__c = dataObj.mrcId;
                newSHTObj.MRC_Number__c = dataObj.mrcName;
                newSHTObj.Customer__c = dataObj.accId;
                newSHTObj.Tranche__c = dataObj.tranche;//trancheVal;
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
                if(checked && dataObj.grade == 'ULG95 E10' && dataObj.salesOrg !='AT01'){
                    newSHTObj.Volume_CBM__c=(dataObj.volumeCBM * 0.15).round(System.RoundingMode.HALF_EVEN);
                }
                else{
                    newSHTObj.Volume_CBM__c = (dataObj.volumeCBM).round(System.RoundingMode.HALF_EVEN);
                }
                newSHTObj.Location__c = dataObj.locationId;
                saveList.add(newSHTObj);
                system.debug('mrcRetMixMrcIdMap::'+mrcRetMixMrcIdMap);
                system.debug('mrc vals::'+dataObj.accId+'--'+dataObj.shipToNumber+'--'+dataObj.location);
                /*mrcRetMixMrcIdMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location*/
                if(newSHTObj1 != null && retailMixAdded
                        && mrcRetMixMrcIdMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5')
                        ){
                    if(mrcRetMixMrcIdMap.size()>0){
                        if(mrcRetMixMrcIdMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5')){
                            newSHTObj1.MRC__c = mrcRetMixMrcIdMap.get(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5');
                        }
                    }
                    if(mrcRetMixMrcMap.size()>0){
                        system.debug('key::'+dataObj.accId+dataObj.shipToNumber+dataObj.location);
                        if(mrcRetMixMrcMap.containsKey(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5')){
                            newSHTObj1.MRC_Number__c = mrcRetMixMrcMap.get(dataObj.accId+dataObj.shipToNumber+dataObj.location+'ULG95 E5');
                        }
                    }
                    newSHTObj1.Customer__c = dataObj.accId;
                    newSHTObj1.Location__c = dataObj.locationId;
                    newSHTObj1.Product_Category__c = 'ULG95 E5';
                    if(!mrcNoVsSalesPriceWrapMap.isEmpty() && mrcNoVsSalesPriceWrapMap.containsKey(newSHTObj1.MRC_Number__c)){
                        newSHTObj1.BSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj1.MRC_Number__c).BSP;
                        newSHTObj1.MSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj1.MRC_Number__c).MSP;
                    }
                    else{
                        newSHTObj1.BSP__c = dataObj.finalbspCal;
                        newSHTObj1.MSP__c = dataObj.finalSalesPriceCal;
                    }
                    newSHTObj1.Status__c = 'Saved';
                    if(dataObj.isZeroPriceDeal){
                        newSHTObj1.SP_100L__c=0;
                    }else{
                        newSHTObj1.SP_100L__c = dataObj.pricePerVol+decimal.valueOf(Label.RV_Surcharge_E5); // Enetred Price by End User
                    }
                    if(newSHTObj1.SP_100L__c != null && newSHTObj1.BSP__c != null){
                        newSHTObj1.Target_Margin__c = newSHTObj1.SP_100L__c - newSHTObj1.BSP__c;
                    }
                    newSHTObj1.Select__c= true;
                    newSHTObj1.Tranche__c = dataObj.tranche;//trancheVal;
                    newSHTObj1.Volume_CBM__c=(dataObj.volumeCBM* 0.80).round(System.RoundingMode.HALF_EVEN);
                    newSHTObj1.Deal_Comment__c=dataObj.Comment;
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
                    if(!mrcNoVsSalesPriceWrapMap.isEmpty() && mrcNoVsSalesPriceWrapMap.containsKey(newSHTObj2.MRC_Number__c)){
                        newSHTObj2.BSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj2.MRC_Number__c).BSP;
                        newSHTObj2.MSP__c = mrcNoVsSalesPriceWrapMap.get(newSHTObj2.MRC_Number__c).MSP;
                    }
                    else{
                        newSHTObj2.BSP__c = dataObj.finalbspCal;
                        newSHTObj2.MSP__c = dataObj.finalSalesPriceCal;
                    }

                    newSHTObj2.Status__c = 'Saved';
                    if(dataObj.isZeroPriceDeal){
                        newSHTObj2.SP_100L__c=0;
                    }else{
                        newSHTObj2.SP_100L__c = dataObj.pricePerVol + decimal.valueOf(Label.RV_Surcharge_98); // Enetred Price by End User
                    }
                    if(newSHTObj2.SP_100L__c != null && newSHTObj2.BSP__c != null){
                        newSHTObj2.Target_Margin__c = newSHTObj2.SP_100L__c - newSHTObj2.BSP__c;
                    }
                    newSHTObj2.Select__c= true;
                    newSHTObj2.Tranche__c = dataObj.tranche;//trancheVal;
                    newSHTObj2.Volume_CBM__c=(dataObj.volumeCBM* 0.05).round(System.RoundingMode.HALF_EVEN) == 0.00 ? 1 :(dataObj.volumeCBM* 0.05).round(System.RoundingMode.HALF_EVEN);
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
        system.debug('srchSaveWrp::'+srchSaveWrp);
        return srchSaveWrp;


            }

    @AuraEnabled
    public static saveResultsearchWrap saveSHTObjectRecord(String dataList,String trancheVal ,String account,
            string salesType ,string contractStartDate,
            string contractEndDate,boolean checked){
                system.debug('dataList::'+dataList);
                system.debug('trancheVal::'+trancheVal);
                system.debug('account::'+account);
                system.debug('salesType::'+salesType);
                system.debug('contractStartDate::'+contractStartDate);
                system.debug('contractEndDate::'+contractEndDate);
                system.debug('checked::'+checked);
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
        //Sampada Bhat | Date : 24-Dec-2021 - Added Sales_Price__c and OTM__c
        String queryString = 'select Id,Name,Customer__c,Customer__r.Name,Volume_CBM__c,Product_Category__c,Cancellation_Reason_Label__c,'+
                'MRC__c,MRC__r.Name,SP_100L__c,SHT_Contract_Number__c,Sales_Type__c,Status__c,Deal_Comment__c,Ship_To__c,Material_Name__c,'+
                'Tranche__c,Location__c,Location__r.Name,BSP__c,Sales_Price__c,OTM__c,MSP__c,Target_Margin__c,Material_No__c,'+
                'Contract_Start__c,Contract_End_Date__c,IsZeroPriceDeal__c,Select__c,PO_Type__c'+  //Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added PO_Type__c field in the query.
                ' from SHT__c where CreatedById =:LoggedInUsr AND PO_Type__c != '+'\'TTTT\''+' AND Status__c = '+'\'Saved\''+'order by createdDate desc';

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
           //Sampada Bhat | Date : 24-Dec-2021
                if(sh.OTM__c != null){
                    shtDspWrp.otm = sh.OTM__c.setScale(2, RoundingMode.HALF_UP);
                }
                shtDspWrp.volCbm=sh.Volume_CBM__c;//.round(System.RoundingMode.HALF_UP);
                shtDspWrp.contractStartDate=sh.Contract_Start__c;
                shtDspWrp.contractEndDate=sh.Contract_End_Date__c;
                shtDspWrp.c_startDate = rv_SHT_CreateController.formatdate(sh.Contract_Start__c);
                shtDspWrp.c_endDate = rv_SHT_CreateController.formatdate(sh.Contract_End_Date__c);
                if(sh.SP_100L__c != null){
                    shtDspWrp.spPer100L=sh.SP_100L__c;
                }
                   //Added by sampada.bhat as part of PBI - 1265727
                if(sh.SP_100L__c != null && sh.SP_100L__c>=sh.msp__c){
                    shtDspWrp.salesPriceCheck = true;
                    shtDspWrp.spColor = 'color:black';
                }else{
                    shtDspWrp.salesPriceCheck = false;
                    shtDspWrp.spColor = 'color:red';
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
        system.debug('**dataList:'+dataList);
        List<SHTDisplayWrap>  shtCmpwrp= new List<SHTDisplayWrap>();
        Map<String,RV_SPCalculationController.salesPriceWrap> mrcSalesPrcWrp=new Map<String,RV_SPCalculationController.salesPriceWrap>();
        List<SHTDisplayWrap> listToUpdate = (List<SHTDisplayWrap>)JSON.deserialize(dataList, List<SHTDisplayWrap>.class);
        Map<String,SHTDisplayWrap> wrapMap = new Map<String,SHTDisplayWrap>();
        Map<string,Id> mrcShtIdMap = new Map<string,Id>();
        set<Id> shtIds= new set<Id>();
        set<Id> mrcId = new set<Id>();
        date contractStartDate;
        date contractEndDate;
        system.debug('**listToUpdate:'+listToUpdate);
        for(SHTDisplayWrap wrapObj : listToUpdate){
            system.debug('**wrapObj:'+wrapObj);
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
                shtObj.Volume_CBM__c=(wrapMap.get(shtObj.id).volCbm).round(System.RoundingMode.HALF_EVEN);
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
        if(createdby== '' || createdby=='Me'){
            LoggedInUsr = UserInfo.getUserId();
            queryPartTwo= 'where CreatedById =:LoggedInUsr AND Status__c = :status ' ;
        }
        else{
            queryPartTwo= 'where Status__c = :status ';
        }
        //Cancellation Reason Update
        //PBI_166252_DataCleanup_Lakshmi_1stOct2019==> Removed Quantitiy_CBM__c from query
        //Sampada Bhat | Date : 24-Dec-2021 - Added Sales_Price__c and OTM__c
        String queryString = 'select Id,Name ,Customer__c,Customer__r.Name,Volume_CBM__c,Product_Category__c,'+
                'MRC__c,MRC__r.Name,SP_100L__c,BSP__c,OTM__c,Target_Margin__c,SHT_Contract_Number__c,Sales_Type__c,Status__c,Ship_To__c,Effective_Margin__c,MSP__c,'+
                'Tranche__c,Cancellation_Reason__c,Location__c,Location__r.Name,Material_Name__c,Material_No__c,'+
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
                shtDspWrp.MrcNo=sh.MRC__r.Name;
                shtDspWrp.MrcId=sh.MRC__c;
                shtDspWrp.Customer=sh.Customer__r.Name;
                shtDspWrp.CustomerId =sh.Customer__c;
                shtDspWrp.locationId =sh.Location__c;
                shtDspWrp.location=sh.Location__r.name;
             //   shtDspWrp.locationCode = sh.Location__r.Plant_Code__c;
                shtDspWrp.product=sh.Product_Category__c == null ? 'AGO B7': sh.Product_Category__c;
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
                shtDspWrp.dealStatus=sh.Status__c;
                shtDspWrp.cancellationReason=sh.Cancellation_Reason_Label__c;
                shtDspWrp.Comment=sh.Deal_Comment__c;
                shtDspWrp.gsapContract=sh.SAP_Contract_Number__c;
                //START - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                if(String.isEmpty(shtDspWrp.gsapContract)){
                    shtDspWrp.gsapError = sh.Error__c;
                }
                shtDspWrp.poType = sh.PO_Type__c;
                //END - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                shtDspWrp.isZeroPriceDeal=sh.IsZeroPriceDeal__c;
                wrapList.add(shtDspWrp);
            }

        }
        return wrapList;
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
            system.debug('sht::'+sht);
            if(sht== null || sht.length()==0 || sht.equals('()'))
                sht= 'ALL';
            if(soldTo == null || soldTo.length()==0 || soldTo.equals('()'))
                soldTo = 'ALL';

            queryCreatedDate1 = string.valueOf(createdOnStDate)+'T00:00:00Z';
            queryCreatedDate2 = string.valueOf(createdOnEdDate+1)+'T00:00:00Z';

            System.debug(queryCreatedDate1);
            System.debug(queryCreatedDate2);
            //PBI_166252_DataCleanup_Lakshmi_1stOct2019==> Removed Quantitiy_CBM__c from query
            String SearchQuery = 'select Id,Name ,Customer__c,Customer__r.Name,Volume_CBM__c,Product_Category__c,'+
                    'MRC__c,MRC__r.Name,SP_100L__c,SHT_Contract_Number__c,Sales_Type__c,Status__c,Ship_To__c,Effective_Margin__c,MSP__c,'+
                    'Tranche__c,Cancellation_Reason__c,Location__c,Location__r.Name,Material_Name__c,Material_No__c,'+
                    'Contract_Start__c,Contract_End_Date__c,SAP_Contract_Number__c,Deal_Comment__c,IsZeroPriceDeal__c,Cancellation_Reason_Label__c,Error__c,PO_Type__c '+ //Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added Error__c field in the query.
                    ' from SHT__c where createdDate >= '+queryCreatedDate1 +' and createdDate < '+queryCreatedDate2;
                    System.debug('status::'+status+'-'+UserInfo.getUserId());
            SearchQuery = SearchQuery + ' and Status__c = :status ';

            if(createdBy.toUpperCase().equals('ME')){
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
            string SearchQuery1='';
            if (!soldTo.toUpperCase().equals('ALL')){
                SearchQuery = SearchQuery + ' and Customer__r.Name = :soldTo ';
                SearchQuery1 = ' and Customer__r.Name = :soldTo';
                system.debug('SearchQuery1::'+SearchQuery1 +'-'+ soldTo);
            }

            if (!sht.toUpperCase().equals('ALL')){
                SearchQuery1='';
                SearchQuery = SearchQuery + ' and Name = :sht ';
                SearchQuery1 = ' and Name = :sht';
                system.debug('SearchQuery1::'+SearchQuery1 +'-'+ sht);
            }
            system.debug('poType::'+poType);
            if (!poType.toUpperCase().equals('ALL')){
                SearchQuery1 = '';
                SearchQuery = SearchQuery + ' and  PO_Type__c =: poType ';
                SearchQuery1 = ' and  PO_Type__c =: poType ';
                system.debug('SearchQuery1::'+SearchQuery1 +'-'+ poType);
            }
                system.debug('1524::'+SearchQuery);
            //Fix_PBI_403668_Lakshmi_12202019
            SearchQuery = SearchQuery + ' and isOlfDeal__c = :internetSales order by Name desc'; //270192_OLFDealCancel_08Jul2019_Soumyajit

            System.debug('SearchQuery:'+SearchQuery);
            List<SHT__c> shtList = Database.query (SearchQuery);
            system.debug('shtList::'+shtList.size());
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
                    shtDspWrp.msp=sh.MSP__c;
                    if(sh.SP_100L__c != null)
                        shtDspWrp.spPer100L=sh.SP_100L__c;
                    shtDspWrp.contractStartDate=sh.Contract_Start__c;
                    shtDspWrp.contractEndDate=sh.Contract_End_Date__c;
                    shtDspWrp.dealStatus=sh.Status__c;
                    shtDspWrp.cancellationReason=sh.Cancellation_Reason_Label__c;
                    shtDspWrp.Comment=sh.Deal_Comment__c;
                    shtDspWrp.gsapContract=sh.SAP_Contract_Number__c;
                    //START - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                    if(String.isEmpty(shtDspWrp.gsapContract)){
                        shtDspWrp.gsapError = sh.Error__c;
                    }
                    shtDspWrp.poType = sh.PO_Type__c;
                    //END - Rahul Dharma | Date - 29-Jan-2021 | PBI-702438 : Added gsapError and poType to show error message and poType respectively.
                    shtDspWrp.isZeroPriceDeal=sh.IsZeroPriceDeal__c;
                    returnSHTDisplayWrap.add(shtDspWrp);
                }
            }

            if(returnSHTDisplayWrap.size()>0)
            {
                for(SHTDisplayWrap sd : returnSHTDisplayWrap){
                    system.debug('returnSoldToList::'+returnSoldToList);
                    system.debug('sd.Customer::'+sd.Customer);
                    system.debug('soldTo::'+soldTo);
                    if(!returnSoldToList.contains(sd.Customer) && soldTo.toUpperCase().equals('ALL')){
                        returnSoldToList.add(sd.Customer);
                        returnSoldToListMap.put(sd.customer,sd.customer);
                    }else {
                        returnSoldToList.add(sd.Customer);
                        returnSoldToListMap.put(sd.customer,sd.customer);
                    }
                    if(!returnSHTList.contains(sd.shtNo) && sht.toUpperCase().equals('ALL')){
                        returnSHTList.add(sd.shtNo);
                        returnSHTListMap.put(sd.shtNo,sd.shtNo);
                    }else{
                        returnSHTList.add(sd.shtNo);
                        returnSHTListMap.put(sd.shtNo,sd.shtNo);
                    }
                    //START - Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : adding list of PO Types to the return wrapper.
                    if(!returnpoTypeList.contains(sd.poType) && poType.toUpperCase().equals('ALL')){
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
            List<String> shipto,Boolean checked ,Boolean agoChk,
            Boolean igoChk,Boolean mogasChk,String poType,String salesOrg,
            List<String> plant,List<String> mot,String contractStartDate,
            String contractEndDate,Boolean callFromOlf, Boolean OLFOnly){
                system.debug(tranche+'-'+Mrcno+'-'+accId+'-'+shipto);
                system.debug(poType+'-'+plant+'-'+mot+'-'+contractStartDate+'-'+contractEndDate);

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
                system.debug('accIdSet::'+accIdSet);
                mrcWrapList = getMRCRecordsData(tranche ,Mrcno , accIdSet, shipto, checked , agoChk, igoChk, mogasChk, poType, salesOrg,
                        plant, mot, contractStartDate, contractEndDate, callFromOlf);
               //system.debug('mrcWrapList::'+mrcWrapList.size());
                return mrcWrapList;
            }
            else
                    return null;
        }
        else if(Mrcno != null && !''.equals(Mrcno)){
            mrcWrapList = getMRCRecordsData(tranche ,Mrcno , new Set<Id>(), shipto, checked , agoChk, igoChk, mogasChk, poType, salesOrg,
                    plant, mot, contractStartDate, contractEndDate, callFromOlf);
            return mrcWrapList;
        }
        //Fix_494336_Lakshmi_Starts
        else if(shipto != null){
            mrcWrapList = getMRCRecordsData(tranche ,Mrcno , new Set<Id>(), shipto, checked , agoChk, igoChk, mogasChk, poType, salesOrg,
                    plant, mot, contractStartDate, contractEndDate, callFromOlf);
            return mrcWrapList;
        }
        //Fix_494336_Lakshmi_Ends
        else
                return null;
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
      /*Method Name	:	getSHTDealsForPriceAndMarket
    * Date			:	29-Dec-2021
    * Developer		:	Sampada Bhat
    * Description	:	This method returns SHT Deals for Price and Market Page*/
    @AuraEnabled
    public static List<SHTPriceAndMarketMrcNoDisplayWrap> getSHTDealsForPriceAndMarket(List<SHTDisplayWrap> completedDeals ){
        SHTWrapper shtWrp=new SHTWrapper();
        List<SHTPriceAndMarketMrcNoDisplayWrap> shtPriceAndMarket = new List<SHTPriceAndMarketMrcNoDisplayWrap>();
        Map<String,List<PlantSHTWrap>> plantSHTWrapMap = new Map<String,List<PlantSHTWrap>>();
        Map<String,List<GradeSHTWarp>> gradeSHTMap = new Map<String,List<GradeSHTWarp>>();
        List<PlantSHTWrap> plantWrapList = new List<PlantSHTWrap>();

      //  shtWrp.CompletedDeal=getCompletedSHTDeal('TODAY','Completed','Me');
        Set<String> grades = new Set<String>();
        Set<String> locations = new Set<String>();
        for(SHTDisplayWrap sht : completedDeals){
        GradeSHTWarp gSHTWarp = new GradeSHTWarp();

        gSHTWarp.bsp = sht.bsp;
        gSHTWarp.location = sht.location;
        gSHTWarp.locationCode=sht.locationCode;
        gSHTWarp.Grade = sht.product;
        gSHTWarp.margin= sht.targetMargin;
        gSHTWarp.otm= sht.otm;
        gSHTWarp.salesPrice=sht.spPer100L;
        gSHTWarp.offer = 0;


        if(gradeSHTMap.containsKey(sht.location)){
            List<GradeSHTWarp> gSW= gradeSHTMap.get(sht.location);
            if(!grades.contains(sht.product)){

            gSW.add(gSHTWarp);
            grades.add(sht.product);
                gradeSHTMap.put(sht.location,gSW);
           }


        }else{
            List<GradeSHTWarp> gSHTW = new List<GradeSHTWarp>();
            gSHTW.add(gSHTWarp);
            grades.add(sht.product);
            gradeSHTMap.put(sht.location,gSHTW);
        }

    }
    for(SHTDisplayWrap sht : completedDeals){
        PlantSHTWrap pSHTWarp = new PlantSHTWrap();

        pSHTWarp.plantName=sht.location;
        pSHTWarp.plantId= sht.locationCode;

        pSHTWarp.gradeSHTWarp=gradeSHTMap.get(sht.location);
        pSHTWarp.rowSpan = gradeSHTMap.get(sht.location).size();

        if(plantSHTWrapMap.containsKey(sht.location)){
            List<PlantSHTWrap> pSW= plantSHTWrapMap.get(sht.MrcNo);
            if(!locations.contains(sht.location)){
                locations.add(sht.location);
            pSW.add(pSHTWarp);
            plantSHTWrapMap.put(sht.MrcNo,pSW);
            }


        }else{
           	List<PlantSHTWrap> pSHTW = new List<PlantSHTWrap>();
            pSHTW.add(pSHTWarp);
            locations.add(sht.location);
			plantSHTWrapMap.put(sht.MrcNo,pSHTW);
		}
	}
    Set<String> mrcs = new Set<String>();
    for(SHTDisplayWrap sht : completedDeals){
        mrcs.add(sht.MrcNo);
    }
	for(String mrc : mrcs){
		SHTPriceAndMarketMrcNoDisplayWrap shtPAM = new SHTPriceAndMarketMrcNoDisplayWrap();
		shtPAM.mrcNo= mrc;
		shtPAM.plantSHTWrap = plantSHTWrapMap.get(mrc);
        shtPAM.rowSpan = plantSHTWrapMap.get(mrc).size();
		shtPriceAndMarket.add(shtPAM);
	}
    System.debug('SHTS Sampada'+shtWrp.CompletedDeal+' '+plantSHTWrapMap+' '+shtPriceAndMarket);

	return shtPriceAndMarket;

}
    @AuraEnabled
  public static String retrySHTDealtoGSAP(List<String> shtIds){
      system.debug('shtList::'+shtIds.size());
      List<SHT__c> shtst = new List<SHT__c>();
      if(shtIds.size() > 0){
        shtst = [Select Id, OwnerId, CreatedDate, IsDeleted, Name, Auto_Num__c, Cancellation_Reason__c, Contract_End_Date__c, Error__c,
         Contract_Start__c, Customer__c, Grade__c, Product_Sub_Group__c, Handling_Type__c, Location__c, PO_Type__c, Transaction_Id__c,
         MRC_Number__c, MRC__c, PSP__c, Product_Catalogue__c, Product_Category__c, SHT_Contract_Number__c, SP_100L__c, Sales_Price__c, Sales_Type__c,
          Select__c, Sold_Price__c, Status__c, Tranche__c, Volume_CBM__c, Deal_Comment__c, BSP__c, Created_Time__c, Effective_Margin__c,
           IsATPVolumeReduced__c, IsGsapDealCancelOn__c, IsGsapDealCreateOn__c, IsPricingTaxed__c, IsVolumeHedged__c, IsZeroPriceDeal__c,
            MRCNumber__c, MSP__c, Margin__c, Margin_vs_MSP__c, Material_Name__c, Material_No__c, Plant_No__c, Price_Condition__c, Price_Unit__c,
             SAP_Contract_Number__c, Sales_Organization__c, Ship_To__c, Target_Margin__c, Volume_Unit__c, Cancellation_Reason_Label__c,
             Contact_Email__c, Contact_Name__c, OLF_Deal_Number__c, OTM__c, isOlfDeal__c, Rv_LastModifiedById__c, Rv_LastModifiedDate__c, Deal_Hour__c,
             Ship_To_Name__c, Sold_To_Name__c, Trigger_Master_Data__c from sht__C where  Name IN :shtIds];
        RV_CreateSHTSAP.processStagingRecord(shtst,null);
    }
        return shtst[0].Name+' has been sent to GSAP again';
  }


    //Sampada Bhat 29/12/2021
    public class SHTPriceAndMarketMrcNoDisplayWrap{
        @AuraEnabled
        public String mrcNo;
        @AuraEnabled
        public List<PlantSHTWrap> plantSHTWrap{get;set;}
        @AuraEnabled
        public Integer rowSpan;
    }
    //Sampada Bhat 29/12/2021
    public class GradeSHTWarp{
        @AuraEnabled
        public String Grade;
        @AuraEnabled
        public String location;
        @AuraEnabled
        public String locationCode;
        @AuraEnabled
        public Decimal salesPrice;
        @AuraEnabled
        public Decimal onlineATP;
        @AuraEnabled
        public Decimal phoneATP;
        @AuraEnabled
        public Decimal bsp;
        @AuraEnabled
        public Decimal lap;
        @AuraEnabled
        public Decimal margin;
        @AuraEnabled
        public Decimal otm;
        @AuraEnabled
        public Decimal offer;
    }
    //Sampada Bhat 29/12/2021
    public class PlantSHTWrap{
        @AuraEnabled
       public String plantName;
       @AuraEnabled
        public String plantId;
        @AuraEnabled
        public List<GradeSHTWarp> gradeSHTWarp{get;set;}
        @AuraEnabled
        public Integer rowSpan;
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
        //Added By Sampada.Bhat
        public string locationCode;
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
        public String c_StartDate;
        @AuraEnabled
        public String c_EndDate;
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
        public Boolean salesPriceCheck; //Sampada Bhat
        @AuraEnabled
        public String spColor;
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
        @AuraEnabled
        public String mrcNameMogas;
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
        public decimal dailySales;//added by swarna
        @auraEnabled
        public decimal onlineATP;//added by swarna
        @auraEnabled
        public decimal phoneATP;//added by swarna
        @auraEnabled
        public decimal dealmargin;//added by swarna
        @auraEnabled
        public decimal finalOTM;//added by swarna
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
        public Decimal bsp;
        @AuraEnabled
        public Decimal spPer100L;
        @AuraEnabled
        public String contractStartDate;
        @AUraEnabled
        public String contractEndDate;
        @AuraEnabled
        public String contractDescription;
        @AuraEnabled
        public String lastOfferedPrice;
        @AuraEnabled
        public String tranche;
        @AuraEnabled
        public Boolean showFinalOTM;
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