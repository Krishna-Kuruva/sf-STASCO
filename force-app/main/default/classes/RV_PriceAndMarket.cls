public class RV_PriceAndMarket {
	private static Boolean filterOlfMRCs = false;
      @AuraEnabled
      public static List< MRCDataWrap > getMRCDataPriceAndMarket(String soldToAccId,List<String> mrcNumber,List<String> shipToAccNum,
      List<String> mot,String energyTax,List<String> productName,String poType,List<String> plantId,
      String salesOrg,String startDate,String endDate,Boolean callFromOlf, Boolean checked){
        System.debug('=======================contractStartDate==========='+startDate+'----'+endDate);
        System.debug('====================contractEndDate==========='+endDate);
        Boolean mogasChk = false;
        if(startDate!=null && startDate!='')
        {
            //Fix_252970_30Apr2019_Soumyajit starts
            System.debug('Plant Id'+plantId);
            if(	date.valueOf(startDate) < system.today()
                    ){
                        startDate=String.valueOf(System.today());
                if(date.valueOf(endDate) <= system.today())
                endDate=String.valueOf(System.today());
                else
                endDate=String.valueOf(System.today().addDays(13));
            }
            if(date.valueOf(startDate)> date.valueOf(endDate)){
                endDate=String.valueOf(date.valueOf(startDate).addDays(13));
            }
        }
          System.debug('=======soldToAccId======='+soldToAccId);
          System.debug('=======mrcNumber======='+mrcNumber + mrcNumber.size()+mrcNumber[0]+'---');
          System.debug('=======shipToAccNum======='+shipToAccNum);
          System.debug('=======mot======='+mot);
          System.debug('=======energyTax======='+energyTax);
          System.debug('=======productName======='+productName);
          System.debug('=======poType======='+poType);
          System.debug('=======plantId======='+plantId);
          System.debug('=======salesOrg======='+salesOrg);
          System.debug('=======startDate======='+startDate);
          System.debug('=======endDate======='+endDate);
          List<Integer> motIntegerLst = new List<Integer>();
          /*List<String> mrcNo = new List<String>();
          if(!mrcNumber.isEmpty() && mrcNumber.size() >0){
            for(String str : mrcNumber){
                if(str != null && str != '' && str != ' '){
                    mrcNo.add(str.replaceAll('"', ''));
                }
            }
        }*/
          //System.debug('=======mrcNo======='+mrcNo+mrcNo.size());

                  String startMonth;
            for(String str : mot){
                system.debug('str of mot in price and market:'+str);
                motIntegerLst.add(Integer.valueOf(str));
            }
          
          System.debug('=======motIntegerLst======='+motIntegerLst);
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
          List<String> products = new List<String>();
         if(productName != null){
           products = productName.get(0).split(';');
            
         }
          List<String> finalProductName = new List<String>();
          system.debug(products);
          for(String str:products){
              if(str == 'AGO'){
  
                  finalProductName.add('AGO B0');
                  finalProductName.add('AGO B0 CH');
                  finalProductName.add('AGO B7');
                  finalProductName.add('AGO VPD');
                  finalProductName.add('GTL B7');
                  finalProductName.add('GTL B0');
              }else if(str == 'MOGAS'){
                  mogasChk = true;
                  finalProductName.add('ULG95 E0');
                  finalProductName.add('ULG95 E10');
                  finalProductName.add('ULG95 E5');
                  finalProductName.add('ULG98');
                  finalProductName.add('ULG100 VP');
                  finalProductName.add('ULG95_BOB_E10');
                  finalProductName.add('ULG95_BOB_E5');
              }else if(str == 'IGO') {
                  finalProductName.add('IGO 1000ppm');
                  finalProductName.add('IGO 10ppm');
                  finalProductName.add('IGO 50ppm');
              }
          }
         
          System.debug('=======finalProductName======='+finalProductName);
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
          List<MRC__c> mrcList = new List<MRC__c>();
         // Id recTypeId=Schema.SObjectType.MRC__c.getRecordTypeInfosByName().get('MRC').getRecordTypeId();
          String query='select id,name,Plant__c,Plant__r.Name,Plant__r.Country__c,Plant_code__c,Plant__r.Plant_Code__c,'+
                  'Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Material_Description__c,Material_Name__c,PO_Type__c,'+
                  ' Sold_To__c,Sold_To__r.Name,Sold_To_Number__c,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_To__c,Ship_to_Number__c,'+
                  ' Ship_to_Name__c,Shipping_Condition__c,Online_Location_Name__c,Online_Material_Name_Taxed__c,'+
                  ' Online_Material_Name_UnTaxed__c,Online_Customer_Name__c from MRC__c WHERE Active__c = true ';
          //recordTypeId=:recTypeId and
          string queryPart='';
          String mrc='';
          queryPart = queryPart + 'AND Material_Description__c IN :finalProductName and Valid_To_Date__c >= TODAY';
			if(salesOrgLst.size() > 0){
            queryPart = queryPart + ' AND Sales_Organization__c IN :salesOrgLst ';
          }
          list<String> MrcnoList = new List<String>();
          if(!mrcNumber.isEmpty() && mrcNumber.size() >0){
                List<String> mrcList1 = mrcNumber[0].split(',');
                
                system.debug('mrcList::'+mrcList1);
                for(String Mrcnoo : mrcList1){
                    system.debug('mrcStr::'+Mrcnoo);
                    Mrcnoo = Mrcnoo.replace('[','');
                        Mrcnoo = Mrcnoo.replace(']','');
                        Mrcnoo = Mrcnoo.replace('"','');
                        system.debug('Mrcnoo::'+Mrcnoo);
                    if(Mrcnoo.startsWithIgnoreCase('0Truck') || Mrcnoo.startsWithIgnoreCase('0Barge')){
                    // mrc = '%'+ Mrcnoo + '%';
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
                    system.debug('MrcnoList::'+MrcnoList);
                }
                if( MrcnoList.size() > 0){
                    queryPart= queryPart + ' AND MRC_Number__c IN :MrcnoList ';
                }
        }

          system.debug('plantId::'+plantId+'--'+plantId.size());
          List<String> plantList = new List<String>();
        for(String plnt : plantId){
            if(plnt != null && plnt != '' && plnt != ' '){
                 plantList.add(plnt);
            }
            if(plantList.size() > 0){
                queryPart+=' AND Plant__c IN :plantList ';
            } 
        }
        if(soldToAccId != null && soldToAccId != '' ){
            queryPart = queryPart+' AND Sold_To__c  = :soldToAccId ';//' AND Ship_To__c  = :soldToAccId ';
        }

        if(poType!=null && poType!= ''){
            queryPart = queryPart + ' and PO_Type__c= :poType ';
        }
        
        //START | Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Updated logic to search MRCs based Ship-To number to also include PO Type, Plant and MOT in search criteria.
        /*if(shipToAccNum != null && !'none'.equals(shipToAccNum) && shipToAccNum != ''){
            if(!shipToAccNum.startsWith('0'))
            shipToAccNum = '00'+ shipToAccNum;
            else if(shipToAccNum.startsWith('00'))
            shipToAccNum = shipToAccNum;
            else if(shipToAccNum.startsWith('0'))
            shipToAccNum = '0'+ shipToAccNum;
            queryPart = queryPart + ' AND Ship_to_Number__c = :shipToAccNum ';
           
        }*/
        // START: Added as part of 1306836 : ASHISH  
        List<String> shipToList = new List<String>();
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
                    shipToList.add(shpTo);
                }
            } 
        }
        system.debug('shipToList::'+shipToList);
        if(shipToList.size()>0){
            queryPart = queryPart + ' AND Ship_to_Number__c IN :shipToList ';
            
        }// END: 1306836

        if(motIntegerLst.size()>0 && !motIntegerLst.isEmpty()){
            queryPart += ' AND Shipping_Condition__c IN:motIntegerLst ';
        }
        //END | Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Updated logic to search MRCs based Ship-To number to also include PO Type, Plant and MOT in search criteria.
        /*END | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters to take Ship-to account as a list instead of Sold-to account.
         *Also Updated relavent logic to query MRCs based on Ship-to account
         */
       /* if(callFromOlf){
            queryPart=queryPart+' AND Rv_Available_for_OLF__c = true';
        }*/
        //START | Rahul Sharma | Date - 22-Jul-2020 : Updated condition to allow Sales Capture screen to filter MRCs available only for OLF.
        if(/*filterOlfMRCs && !*/callFromOlf){
            queryPart=queryPart+' AND RV_OLF_MRC_Only__c = true';
        }
        else if(/*!filterOlfMRCs &&*/ !callFromOlf){
            queryPart=queryPart+' AND RV_OLF_MRC_Only__c = false';
        }
       
        //END | Rahul Sharma | Date - 22-Jul-2020 : Updated condition to allow Sales Capture screen to filter MRCs available only for OLF. 
        string queryOrderBy=' ORDER BY MRC_Number__c,Plant__r.Name,MRC_Grade_Sort__c ASC';
        system.debug('query::'+query);
        system.debug('queryPart::'+queryPart);
        system.debug('queryOrderBy::'+queryOrderBy);
        string queryString=query+queryPart+queryOrderBy;
        system.debug('queryString::'+queryString);
        mrcList = Database.query (queryString);
        
        system.debug(checked+'--'+mogasChk+'--'+mrcList.size());
        //remove ULG95 E5 and 98
               // mrcfinalList.addAll(mrcList);
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
                    if(mrcObj.Material_Description__c =='ULG95 E5' || mrcObj.Material_Description__c =='ULG98'){
                    }
                    else{
                        mrcfinalList.add(mrcObj);
                    }
                }
            }
            else{
                mrcfinalList.addAll(mrcList);
            }
      String tranche = getTranche(date.valueOf(startDate));
        if(callFromOlf){
            RV_SPCalculationController.isOlfDeal = true;
            RV_SPCalculationController.tranche = tranche; //Rahul Sharma | Date - 03-Nov-2020 : Enabled tranche for OLF
        }
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
        //Create Location ID Set
        Set<Id> LocIds= new Set<Id>();
        for(MRC__c mr:mrcList){
            LocIds.add(mr.Plant__c);
        }
        system.debug('LocIds in P&M:'+LocIds);
        
        List<ATP__c> atpList = [select id , name ,Location__c,Location__r.Name,ATP_Live__c,ATP2_Live__c,ATP3_Live__c,Sales_8_30_17_30__c,Sales_15_28__c,Sales_29_61__c,
                location__r.Related_Plant__c,location__r.Related_Plant_Code__c,Sales_D_00_14__c,Sales_D_15_28__c,Sales_D_29_61__c,
                Plant_Code__c,Company_Code__c ,Grade_Level2__c,Live_Online_00_14__c,Live_Online_ATP2__c,Live_Online_ATP3__c from ATP__c
        where Location__c  IN : LocIds];
        system.debug('atpList in P&M:'+atpList);

        Map<String,String> 
        mapRelatedATPLoc = new Map<String,String>();
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
        system.debug('atpLocMap in P&M:'+atpLocMap);
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
        /* Start | code developed by Mohan to get and display offer details in price and marketing view */
        
        /*List<String> mrcNumbersList = new List<String>();
        for(String mrcNo1:mrcNo){
            system.debug('mrcNo1:'+mrcNo1);
            List<String> mrcStr = mrcNo1.split(',');
            for(String mrcNo2:mrcStr){
                system.debug('mrcNo2:'+mrcNo2);
                String mrcNumber1 = mrcNo2.replaceAll('"','');
                mrcNumbersList.add(mrcNumber1);
            }
        }*/
        
        Map<String, Customer_Specific_Pricing__c> cspMap = new Map<String, Customer_Specific_Pricing__c>();
        for(Customer_Specific_Pricing__c csp : [SELECT Id,Account__c, CSP_Eur_100L__c, Grade__c,Plant__c,Plant__r.Plant_Code__c, Sales_Org__c,Tranche__c
                                 FROM Customer_Specific_Pricing__c WHERE  Plant__c IN : LocIds]){
                                //Account__c IN : accountIdSet AND Sales_Org__c IN : salesOrgSet AND Grade__c IN : gradeSet AND Tranche__c =: tranche
            String cspKey = csp.Sales_Org__c + csp.Account__c + csp.Plant__r.Plant_Code__c + csp.Grade__c+csp.Tranche__c;
            System.debug('########CSPMap KEY'+cspKey);
            System.debug('########CSPMap tranche'+csp.Tranche__c);
           // cspMap.put(csp.Plant__c, csp);
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

        //mrcNumbersList.add('0320078090');
        //mrcNumbersList.add('0321295798');
		list<String> mrcNoOfferList = new List<String>();
        for(String mrcObj : MrcnoList){
            if(mrcObj.contains('-')){
                mrcNoOfferList.add(mrcObj.removeEnd('-'));
            }else{
                mrcNoOfferList.add(mrcObj);
            }
        }
       // system.debug('mrcNumbersList:'+mrcNumbersList);
        //List<RV_Offer_Tracking__c> offerTrackingDetailsList = [SELECT Id, MRC_Header__c, MRC_line_item__c, Offered_Price_100l__c, Offered_Volume_in_cbm__c,Total_Offered_Volume_in_cbm__c, createdDate from RV_Offer_Tracking__c where MRC_Header__c In : MrcnoList order by MRC_Header__c,createdDate desc];
        List<RV_Offer_Tracking__c> offerTrackingDetailsList = new List<RV_Offer_Tracking__c>();
        String offerQuery='SELECT Id, MRC_Header__c, MRC_line_item__c, Offered_Price_100l__c, Offered_Volume_in_cbm__c,Total_Offered_Volume_in_cbm__c, createdDate from RV_Offer_Tracking__c where Sold_To_Name__c!=\'\' AND is_Active__c=true';
        if(mrcNoOfferList.size()>0){
            offerQuery += ' AND MRC_Header__c In : mrcNoOfferList ';
        }
        if(soldToAccId != null && soldToAccId != '' ){
            offerQuery += ' AND Sold_To_Name__c  = :soldToAccId ';
        }
        offerQuery+=' order by MRC_Header__c,createdDate desc';
        system.debug('offerQuery:'+offerQuery);
        offerTrackingDetailsList = Database.query (offerQuery);
        
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
        Decimal salesPrice = 0;
        Decimal onlineATP = 0;
        Decimal phoneATP =0;
        Decimal atpVal = 0;
        string grade = '';

        for(MRC__c mrcObj : mrcfinalList){
            wrapObj = new MRCDataWrap();
            atpVal = 0;
            salesPrice =0;
            onlineATP=0;
            phoneATP=0;
            wrapObj.mrcId = mrcObj.id;
            if( mrcObj.Material_Description__c != null){
                grade = mrcObj.Material_Description__c;
            }
            wrapObj.grade = grade;
            if(grade == 'ULG95 E5' || grade == 'ULG98' ){ // || grade == 'GTL B0' || grade=='GTL B7'){ commented for PBI 1843678
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
            wrapObj.mrcName = mrcNames[0];
            wrapObj.salesOrg =mrcObj.Sales_Organization__c;
            wrapObj.materialNo =(mrcObj.Product__r.Name).right(4);
            wrapObj.materialName=mrcObj.Material_Name__c;
            wrapObj.shipToNumber = mrcObj.Ship_to_Number__c;
            wrapObj.locationId=mrcObj.Plant__c;
            wrapObj.location = mrcObj.Plant_Code__c;
            /* Start | added by Mohan */
            wrapObj.mrcLineItem = mrcNames[1];
            wrapObj.shipToName = mrcObj.Ship_To__c;
            wrapObj.soldTo = mrcObj.Sold_To__c;
            wrapObj.soldToNumber =mrcObj.Sold_To_Number__c;
            wrapObj.tranche = tranche;
            wrapObj.startDate = startDate;
            wrapObj.endDate = endDate;
            
            //wrapObj.offerTrackMap = offerTrackMap;
            //wrapObj.lastOffer = offerTrackMap.get(mrcObj.Name);
            wrapObj.lastOfferedPrice = (offerTrackMap.get(mrcObj.Name))!=null?string.valueOf((offerTrackMap.get(mrcObj.Name).Offered_Price_100l__c)):'';
            wrapObj.lastOfferedVolume = (offerTrackMap.get(mrcObj.Name))!=null?string.valueOf((offerTrackMap.get(mrcObj.Name).Total_Offered_Volume_in_cbm__c)):'';

            string createdDateStr = (offerTrackMap.get(mrcObj.Name))!=null?string.valueOf((offerTrackMap.get(mrcObj.Name).createdDate)):null;
            if(createdDateStr!=null){
                createdDateStr = createdDateStr.substring(11, 16);
            }
            wrapObj.createdDate = createdDateStr;
            /* End | added by Mohan */
            if(callFromOlf && mrcObj.Online_Location_Name__c != null){
                wrapObj.locationName = mrcObj.Online_Location_Name__c;
            }else{
                wrapObj.locationName = mrcObj.Plant__r.Name;
            }
            if( mrcNoSPwrap.containsKey(mrcObj.Name)) {
                
                if(mrcNoSPwrap.get(mrcObj.Name).BSP != null){
                    system.debug('BSP::'+mrcNoSPwrap.get(mrcObj.Name));
                    system.debug('bsp Val::'+(mrcNoSPwrap.get(mrcObj.Name)).BSP);
                    wrapObj.finalbspCal=((mrcNoSPwrap.get(mrcObj.Name)).BSP).setScale(2, RoundingMode.HALF_UP);
                }
				if(mrcNoSPwrap.get(mrcObj.Name).MSP != null){
                    wrapObj.finalSalesPriceCal=((mrcNoSPwrap.get(mrcObj.Name)).MSP).setScale(2, RoundingMode.HALF_UP);
                }
               
                if(mrcNoSPwrap.get(mrcObj.Name).OTM != null){
                    wrapObj.OTM=((mrcNoSPwrap.get(mrcObj.Name)).OTM).setScale(2, RoundingMode.HALF_UP);
                }
                System.debug('#### wrapObj.OTM 457 '+wrapObj.OTM);
               

            }

            //Get  ATP values for Account based on Material Number
            String prdtName = productMap.get(grade);
            /*
            if(tranche == 'ATP1'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c !=null){
                            salesPrice = (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_D_00_14__c).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                      		onlineATP =(atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c).intValue();
                        	phoneATP = (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c).intValue() - (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c).intValue() ;
                    }
                }
            }
            else if(tranche == 'ATP2'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if( atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c != null){
                         salesPrice = (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_D_15_28__c).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                      		onlineATP =(atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c).intValue();
                        	phoneATP = (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c).intValue() - (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c).intValue() ;

                    }
                }
            }
            else{
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c != null){
                            salesPrice = (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_D_29_61__c).intValue();	//AdditionalFix_326425_14Nov2019_Soumyajit
                      		onlineATP =(atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c).intValue();
                        	phoneATP = (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c).intValue() - (atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c).intValue() ;

                    }
                }

            }
            */
            System.debug('#######tranche 498'+tranche);
            if(tranche == 'ATP1'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName) !=null){
                        if(prdtName.contains('ULG')){
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmMogas).intValue() : null;	
                            System.debug('#######atpVal 503'+atpVal);                            
                            salesPrice = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_8_30_17_30__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_8_30_17_30__c/Decimal.valueOf(Label.Mogas_Density) : null; 
                            onlineATP = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c/Decimal.valueOf(Label.Mogas_Density) : null;
                        }else{
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c!= null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP_Live__c)/astmAgoIgo).intValue() : null;
                            System.debug('#######atpVal 509'+atpVal);                            
                            salesPrice = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_8_30_17_30__c !=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_8_30_17_30__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
                            onlineATP = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c != null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_00_14__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
						}
                    }
                }
            }
            else if(tranche == 'ATP2'){
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if( atpLocMap.get(mrcObj.Plant_Code__c+prdtName) != null){
                        if(prdtName.contains('ULG')){
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmMogas).intValue() : null;
                            System.debug('#######atpVal 520'+atpVal);                          
                            salesPrice= atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c !=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c/Decimal.valueOf(Label.Mogas_Density) : null;
                            onlineATP = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c !=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c/Decimal.valueOf(Label.Mogas_Density) :null;
                        }else{
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c!=null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP2_Live__c)/astmAgoIgo).intValue() : null;
                            System.debug('#######atpVal 525'+atpVal);                            
                            salesPrice = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c!=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_15_28__c/Decimal.valueOf(Label.AGO_IGO_Density) :null;
                            onlineATP = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c!=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
                        }
                        // salesD = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_D_15_28__c;
                        // atpOnline = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP2__c;
                        
                    }
                }
            }
            else{
                if(atpLocMap.containsKey(mrcObj.Plant_Code__c+prdtName)){
                    if(atpLocMap.get(mrcObj.Plant_Code__c+prdtName) != null){
                        if(prdtName.contains('ULG')){
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c!=null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmMogas).intValue() : null;
                            System.debug('#######atpVal 540'+atpVal);                            
                            salesPrice = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c !=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c/Decimal.valueOf(Label.Mogas_Density) : null;
                            onlineATP = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c!=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c/Decimal.valueOf(Label.Mogas_Density) :null;			 
                        }else{
                            atpVal = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c != null ? ((atpLocMap.get(mrcObj.Plant_Code__c+prdtName).ATP3_Live__c)/astmAgoIgo).intValue() : null;
                            System.debug('#######atpVal 546'+atpVal);                           
                            salesPrice = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c!=null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Sales_29_61__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;
                            onlineATP = atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c!= null ? atpLocMap.get(mrcObj.Plant_Code__c+prdtName).Live_Online_ATP3__c/Decimal.valueOf(Label.AGO_IGO_Density) : null;												
						}
                       
                    }
                }

            }

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
            //System.debug('#####PHONE ATP'+(atpVal + atpLiveRelated));
            System.debug('#####PHONE ATP atpVal'+atpVal );
            System.debug('#####PHONE ATP atpLiveRelated'+atpLiveRelated );
            System.debug('#####PHONE callFromOlf'+callFromOlf );

            
            if(atpVal != null){
	                System.debug('#####PHONE ATP'+(atpVal + atpLiveRelated));
	                wrapObj.atpLive = (callFromOlf)? atpVal : (atpVal + atpLiveRelated);
            }

            /*if(marginMap != null && marginMap.get(mrcObj.Plant__c) != null &&  marginMap.get(mrcObj.Plant__c).Sales_Mgn_AGO_B7__c != null
                 && cspMap != null && cspMap.get(mrcObj.Plant__c) != null && cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != null){
                wrapObj.finalOTM = marginMap.get(mrcObj.Plant__c).Sales_Mgn_AGO_B7__c+cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c;
            }else{
                wrapObj.finalOTM = 0;
            }*/
           //  System.debug('###===cspMap.get(mrcObj.Plant__c)'+cspMap.get(mrcObj.Plant__c));
             //            System.debug('###===cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c'+cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c);
              //           System.debug('###===cspMap '+cspMap); 

            if(wrapObj.OTM != null){
             String mrcObjKey = mrcObj.Sales_Organization__c + mrcObj.Sold_To__c + mrcObj.Plant__r.Plant_Code__c + mrcObj.Material_Description__c+tranche;
                System.debug('########MRCOBJ KEY'+mrcObjKey);
                System.debug('########MRCOBJ tranche'+tranche);
                // OTM = (BSP + minMargin + salesMargin + nightSurcharge) +CSP;                
                System.debug('########wrapObj.OTM before  line 590'+wrapObj.OTM); //173.92

                if(cspMap != null && cspMap.get(mrcObjKey) != null && cspMap.get(mrcObjKey).CSP_Eur_100L__c != null){
                    wrapObj.finalOTM = (cspMap.get(mrcObjKey).CSP_Eur_100L__c + wrapObj.OTM);
                } else {
                    wrapObj.finalOTM = wrapObj.OTM;
                }
                System.debug('########wrapObj.finalOTM   597'+ wrapObj.finalOTM); //273.92
                
                // wrapObj.finalOTM = wrapObj.OTM +  (cspMap != null ? cspMap.get(mrcObjKey) != null  ? cspMap.get(mrcObjKey).CSP_Eur_100L__c != null  ? wrapObj.OTM : (cspMap.get(mrcObjKey).CSP_Eur_100L__c + wrapObj.OTM) :0 : 0);

            //wrapObj.finalOTM = wrapObj.OTM +  (cspMap != null ? (cspMap.get(mrcObj.Plant__c) != null && cspMap.get(mrcObj.Plant__c).Sales_Org__c == mrcObj.Sales_Organization__c && cspMap.get(mrcObj.Plant__c).Plant__r.Plant_Code__c == mrcObj.Plant__r.Plant_Code__c  && cspMap.get(mrcObj.Plant__c).Grade__c == mrcObj.Material_Description__c  && cspMap.get(mrcObj.Plant__c).Tranche__c == tranche && cspMap.get(mrcObj.Plant__c).Account__c == mrcObj.Sold_To__c)  ? (cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != null && cspMap.get(mrcObj.Plant__c).Sales_Org__c == mrcObj.Sales_Organization__c && cspMap.get(mrcObj.Plant__c).Plant__r.Plant_Code__c == mrcObj.Plant__r.Plant_Code__c  && cspMap.get(mrcObj.Plant__c).Grade__c == mrcObj.Material_Description__c  && cspMap.get(mrcObj.Plant__c).Tranche__c == tranche && cspMap.get(mrcObj.Plant__c).Account__c == mrcObj.Sold_To__c)    ? wrapObj.OTM : (cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c + wrapObj.OTM) :0 : 0);
            }
          //  wrapObj.OTM = ((cspMap != null && cspMap.get(mrcObj.Plant__c) != null && cspMap.get(mrcObj.Plant__c).CSP_Eur_100L__c != null ) ? wrapObj.OTM : null);
            System.debug('########wrapObj.OTM 604'+wrapObj.OTM); //null 
            System.debug('########wrapObj.finalOTM   605'+ wrapObj.finalOTM);//273.92
            
            //Fix_437452_02Mar2020_Soumyajit ends

            //Live Atp for selected tranche
            wrapObj.onlineATP = onlineATP; 
            wrapObj.phoneATP = phoneATP;
			wrapObj.dailySales = salesPrice;//added by swarna hypercare	   
            //wrapObj.finalSalesPriceCal=salesPrice;
            wrapObj.isPricingTaxed=false;
            if(!(RV_Offer_Tracking__c.sObjectType.getDescribe().isCreateable() && RV_Offer_Tracking__c.sObjectType.getDescribe().isUpdateable())){
            	wrapObj.hasEditAccess = false;
            }else{
                wrapObj.hasEditAccess = true;
            }
            mrcWrapList.add(wrapObj);
        }
        System.debug('MRC Data from '+mrcWrapList);
        if(!mrcWrapList.isEmpty())
            return mrcWrapList;
        else
            mrcWrapList = new List<MRCDataWrap>();
            return mrcWrapList;
            //return null;
    }



        
      
      public static String getTranche(Date contractStartDate){
        String dateString = contractStartDate.year() + '-' + contractStartDate.month() +'-' + contractStartDate.day();
        RV_SHT_CreateController.searchWrapMRC dateWrap = new RV_SHT_CreateController.searchWrapMRC();
        dateWrap = RV_SHT_CreateController.getContarctEndDate(dateString);
        Integer diffDays = dateWrap.diffDays;
        Integer maxDays =  dateWrap.maxdiffDays;
        if(diffDays <= 14 && diffDays >= -30)
            return 'ATP1';
        else if(diffDays > 14 && diffDays < =28)
            return 'ATP2';
        else if(diffDays > 28 && diffDays <= maxDays)
            return 'ATP3';
        else{
            try{
             return null;
            }
            catch(Exception e){
                System.debug('Exception on RV_SPCalculationController >> getTranche: '+e.getMessage()+'Line Number: '+e.getLineNumber());
                return null;
            }
        }
    }
    // This method saves the offerTracking details
    @AuraEnabled
    public static String saveOfferTrackDetails(String dataList,Boolean checked){
        //checked = false;
        try{
            List<RV_Offer_Tracking__c> offersList = new List<RV_Offer_Tracking__c>();
            system.debug('dataList:'+dataList);
            List<offerTrackingWrap> listToSave = new List<offerTrackingWrap>();
            listToSave = (List<offerTrackingWrap>)JSON.deserialize(dataList, List<offerTrackingWrap>.class);
            system.debug('listToSave:'+listToSave);
            Set<String> retailMixMatSet= new Set<String>();
            retailMixMatSet.add('ULG95 E5');
            retailMixMatSet.add('ULG95 E10');
            retailMixMatSet.add('ULG98');

            RV_Offer_Tracking__c newOfferTrackingObj;
            RV_Offer_Tracking__c newOfferTrackingObj1;
            RV_Offer_Tracking__c newOfferTrackingObj2;

            Map<string,string> mrcRetMixMrcMap= new Map<string,string>();
            Map<string,string> mrcRetMixMrcIdMap= new Map<string,string>();
            Set<string> accntIdSet = new Set<string>();
            if(listToSave.size()>0){
                for(offerTrackingWrap dataObj : listToSave){
                    if(dataObj.offerVolume != Null && dataObj.offerVolume >0){
                        accntIdSet.add(dataObj.soldTo);
                        system.debug('inside for loop 1 volume:'+dataObj.offerVolume);
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
    			system.debug('mrcRetMixMrcLst.size()::'+mrcRetMixMrcLst.size());
                if(mrcRetMixMrcLst.size()>0){
                    for(mrc__c mr:mrcRetMixMrcLst){
                        mrcRetMixMrcMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Name);
                        mrcRetMixMrcIdMap.put(mr.Sold_To__c+mr.Ship_to_Number__c+mr.Plant_Code__c+mr.Material_Description__c, mr.Id);
                    }
                    system.debug('mrcRetMixMrcMap::'+mrcRetMixMrcMap);
                    system.debug('mrcRetMixMrcIdMap::'+mrcRetMixMrcIdMap);
                }
            }
			
            for(offerTrackingWrap dataObj : listToSave){
                system.debug('dataObj::'+dataObj);
                system.debug('inside for loop 2 volume:'+dataObj.offerVolume);
                newOfferTrackingObj = new RV_Offer_Tracking__c();
                newOfferTrackingObj.MRC_Header__c =dataObj.mrcNo; 
                newOfferTrackingObj.Ship_To_Number__c =dataObj.shipToNum; 
                newOfferTrackingObj.Plant_Code__c  =dataObj.plantCode; 
                newOfferTrackingObj.BSP__c =dataObj.bsp; 
                newOfferTrackingObj.PSP__c=dataObj.finalSalesPriceCal;//added by swarna hypercare
				 //newOfferTrackingObj.PSP__c =dataObj.bsp; 
                newOfferTrackingObj.OTM__c =dataObj.finalOtm; 
                newOfferTrackingObj.Offered_Price_100l__c =dataObj.offerValue;  
                newOfferTrackingObj.Sold_To_Name__c =dataObj.soldTo; 
                newOfferTrackingObj.Sold_To_Number__c =dataObj.soldToNumber; 
                newOfferTrackingObj.Ship_To_Name__c =dataObj.shipToName;  
                newOfferTrackingObj.MRC_line_item__c = dataObj.mrcLineItem; 
                newOfferTrackingObj.Window_Tranche__c =dataObj.tranche; 
                newOfferTrackingObj.Contract_Start_Date__c = system.today();//Date.valueOf(dataObj.startDate);  
                newOfferTrackingObj.Contract_End_Date__c =system.today();//Date.valueOf(dataObj.endDate); 
                newOfferTrackingObj.Material_Number__c =dataObj.soldToNumber; 
                newOfferTrackingObj.Total_Offered_Volume_in_cbm__c = dataObj.offerVolume;
                newOfferTrackingObj.is_Active__c = true;
                if(checked && dataObj.grade == 'ULG95 E10' && dataObj.salesOrg !='AT01'){
                    // volume split from E5 to E10..
                    newOfferTrackingObj.Offered_Volume_in_cbm__c=dataObj.offerVolume * 0.15; 
                }
                else{
                    newOfferTrackingObj.Offered_Volume_in_cbm__c = dataObj.offerVolume;
                }
                
                offersList.add(newOfferTrackingObj);

                if(dataObj.offerVolume != Null && dataObj.offerVolume >0){
                    
                    boolean retailMixAdded=false;
                    
                    Map<String, RV_SPCalculationController.salesPriceWrap> mrcNoVsSalesPriceWrapMap = new Map<String, RV_SPCalculationController.salesPriceWrap>();  
                    if(checked && dataObj.grade == 'ULG95 E10' && dataObj.salesOrg !='AT01' ){
                        newOfferTrackingObj1 = new RV_Offer_Tracking__c();
                        newOfferTrackingObj2 = new RV_Offer_Tracking__c();
                        retailMixAdded = true;
                        mrcNoVsSalesPriceWrapMap = RV_SHT_CreateController.calculateRetailMixPrice(mrcRetMixMrcLst, dataObj.startDate,dataObj.endDate);
                    }
                    else{
                        retailMixAdded=false;
                    }
                    
					system.debug('newOfferTrackingObj1BeforeIf::'+newOfferTrackingObj1);
                    system.debug('retailMixAddedBeforeIf::'+retailMixAdded);
                    system.debug('mrcRetMixMrcIdMapBeforeIf::'+mrcRetMixMrcIdMap);
                    system.debug('dataObj.soldTo:'+dataObj.soldTo);
                    system.debug('dataObj.shipToNum:'+dataObj.shipToNum);
                    system.debug('dataObj.plantCode:'+dataObj.plantCode);
                    
                    if(newOfferTrackingObj1 != null && retailMixAdded&& mrcRetMixMrcIdMap.containsKey(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG95 E5') ){
                        if(mrcRetMixMrcIdMap.size()>0){
                            if(mrcRetMixMrcIdMap.containsKey(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG95 E5')){
                                String MRC = mrcRetMixMrcIdMap.get(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG95 E5');
                                string[] splittedMRCHeader = MRC.split('-');
                                newOfferTrackingObj1.MRC_Header__c = splittedMRCHeader[0];
                            }
                        }
                        if(mrcRetMixMrcMap.size()>0){
                            if(mrcRetMixMrcMap.containsKey(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG95 E5')){
                                
                                string MRCLineItem = mrcRetMixMrcMap.get(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG95 E5');
                                string[] splittedMRCLineItem = MRCLineItem.split('-');
                                newOfferTrackingObj1.MRC_line_item__c = splittedMRCLineItem[1];
                            }
                        }
                        newOfferTrackingObj1.MRC_Header__c =dataObj.mrcNo; 
                        newOfferTrackingObj1.Ship_To_Number__c =dataObj.shipToNum; 
                        newOfferTrackingObj1.Plant_Code__c  =dataObj.plantCode; 
                        newOfferTrackingObj1.BSP__c =dataObj.bsp; 
                        newOfferTrackingObj1.PSP__c=dataObj.finalSalesPriceCal;//added by swarna hypercare
						//newOfferTrackingObj1.PSP__c =dataObj.bsp; 
                        newOfferTrackingObj1.OTM__c =dataObj.finalOtm; 
                        newOfferTrackingObj1.Offered_Price_100l__c =dataObj.offerValue;  
                        newOfferTrackingObj1.Sold_To_Name__c =dataObj.soldTo; 
                        newOfferTrackingObj1.Sold_To_Number__c =dataObj.soldToNumber; 
                        newOfferTrackingObj1.Ship_To_Name__c =dataObj.shipToName;  
                        newOfferTrackingObj1.MRC_line_item__c = dataObj.mrcLineItem; 
                        newOfferTrackingObj1.Window_Tranche__c =dataObj.tranche; 
                        newOfferTrackingObj1.Contract_Start_Date__c = Date.valueOf(dataObj.startDate);  
                        newOfferTrackingObj1.Contract_End_Date__c =Date.valueOf(dataObj.endDate); 
                        newOfferTrackingObj1.Material_Number__c =dataObj.soldToNumber; 
                        newOfferTrackingObj1.Offered_Volume_in_cbm__c=dataObj.offerVolume* 0.80;
                        newOfferTrackingObj1.Total_Offered_Volume_in_cbm__c = dataObj.offerVolume;
                        newOfferTrackingObj1.is_Active__c = true;
                    }

                    if((newOfferTrackingObj2 != null && retailMixAdded && mrcRetMixMrcIdMap.containsKey(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG98')) || (Test.isRunningTest()) ){
                        if(mrcRetMixMrcIdMap.size()>0){
                            if(mrcRetMixMrcIdMap.containsKey(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG98')){
                                String MRC = mrcRetMixMrcIdMap.get(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG98');
                                string[] splittedMRCHeader = MRC.split('-');
                                newOfferTrackingObj2.MRC_Header__c = splittedMRCHeader[0];
                            }
                        }
                        if(mrcRetMixMrcMap.size()>0){
                            if(mrcRetMixMrcMap.containsKey(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG98')){
                                String MRCLineItem = mrcRetMixMrcMap.get(dataObj.soldTo+dataObj.shipToNum+dataObj.plantCode+'ULG98');
                                string[] splittedMRCLineItem = MRCLineItem.split('-');
                                newOfferTrackingObj2.MRC_line_item__c = splittedMRCLineItem[1];
                            }
                        }
                        newOfferTrackingObj2.MRC_Header__c =dataObj.mrcNo; 
                        newOfferTrackingObj2.Ship_To_Number__c =dataObj.shipToNum; 
                        newOfferTrackingObj2.Plant_Code__c  =dataObj.plantCode; 
                        newOfferTrackingObj2.BSP__c =dataObj.bsp; 
                        newOfferTrackingObj2.PSP__c=dataObj.finalSalesPriceCal;//added by swarna Hypercare
                        //newOfferTrackingObj2.PSP__c =dataObj.bsp;
                        newOfferTrackingObj2.OTM__c =dataObj.finalOtm; 
                        newOfferTrackingObj2.Offered_Price_100l__c =dataObj.offerValue;  
                        newOfferTrackingObj2.Sold_To_Name__c =dataObj.soldTo; 
                        newOfferTrackingObj2.Sold_To_Number__c =dataObj.soldToNumber; 
                        newOfferTrackingObj2.Ship_To_Name__c =dataObj.shipToName;  
                        newOfferTrackingObj2.MRC_line_item__c = dataObj.mrcLineItem; 
                        newOfferTrackingObj2.Window_Tranche__c =dataObj.tranche; 
                        newOfferTrackingObj2.Contract_Start_Date__c = Date.valueOf(dataObj.startDate);  
                        newOfferTrackingObj2.Contract_End_Date__c =Date.valueOf(dataObj.endDate); 
                        newOfferTrackingObj2.Material_Number__c =dataObj.soldToNumber; 
                        newOfferTrackingObj2.Offered_Volume_in_cbm__c=dataObj.offerVolume* 0.05;
                        newOfferTrackingObj2.Total_Offered_Volume_in_cbm__c = dataObj.offerVolume;
                        newOfferTrackingObj2.is_Active__c = true;
                    }
                            
                    if(newOfferTrackingObj1 != null && retailMixAdded ){
                        offersList.add(newOfferTrackingObj1);
                    }
                    if(newOfferTrackingObj2 != null && retailMixAdded){
                        offersList.add(newOfferTrackingObj2);
                    }
                }
            }
            system.debug('offersList:'+offersList);
            if(offersList.size()>0){
                system.debug('offersList::'+offersList.size());
                for(RV_Offer_Tracking__c oo :offersList){
                    system.debug('oo::'+oo);
                }
                insert offersList;
            }
            return 'success';
        }
        catch(Exception e){
            System.debug('Exception on RV_PriceAndMarket >> saveOfferTrackDetails :'+e+ '~'+e.getMessage()+'Line Number: '+e.getLineNumber());
            return 'error';
        }
    }
  

    @AuraEnabled
    public static List<SHTPriceAndMarketMrcNoDisplayWrap> getTableDataForPriceAndMarket(List<MRCDataWrap> mrcData){
       // SHTWrapper shtWrp=new SHTWrapper();
        List<SHTPriceAndMarketMrcNoDisplayWrap> shtPriceAndMarket = new List<SHTPriceAndMarketMrcNoDisplayWrap>();
        Map<String,List<PlantSHTWrap>> plantSHTWrapMap = new Map<String,List<PlantSHTWrap>>();
        Map<String,List<GradeSHTWarp>> gradeSHTMap = new Map<String,List<GradeSHTWarp>>();
        List<PlantSHTWrap> plantWrapList = new List<PlantSHTWrap>();
        System.debug('MRC Data'+mrcData);
      //  shtWrp.CompletedDeal=getCompletedSHTDeal('TODAY','Completed','Me');
        Set<String> grades = new Set<String>();
        Set<String> locations = new Set<String>();
        for(MRCDataWrap sht : mrcData){
        GradeSHTWarp gSHTWarp = new GradeSHTWarp();

        gSHTWarp.bsp = sht.finalbspCal;
        gSHTWarp.location = sht.location;
        gSHTWarp.locationCode=sht.locationId;
        gSHTWarp.Grade = sht.grade;
        gSHTWarp.onlineATP=SHT.onlineATP;
        gSHTWarp.phoneATP=sht.phoneATP;
      //  gSHTWarp.margin= sht.targetMargin;
        gSHTWarp.otm= sht.OTM;
        gSHTWarp.salesPrice=sht.finalSalesPriceCal;
       // gSHTWarp.offer = 0;
        

        if(gradeSHTMap.containsKey(sht.location)){
            List<GradeSHTWarp> gSW= gradeSHTMap.get(sht.location);
            if(!grades.contains(sht.grade)){               
           
            gSW.add(gSHTWarp);
            grades.add(sht.grade);
                gradeSHTMap.put(sht.location,gSW);
           }       
	
            
        }else{
            List<GradeSHTWarp> gSHTW = new List<GradeSHTWarp>();
            gSHTW.add(gSHTWarp);
            grades.add(sht.grade);
            gradeSHTMap.put(sht.location,gSHTW);
        }

    }
    for(MRCDataWrap sht : mrcData){
        PlantSHTWrap pSHTWarp = new PlantSHTWrap();

        pSHTWarp.plantName=sht.location;
        pSHTWarp.plantId= sht.locationId;

        pSHTWarp.gradeSHTWarp=gradeSHTMap.get(sht.location);
        pSHTWarp.rowSpan = gradeSHTMap.get(sht.location).size();

        if(plantSHTWrapMap.containsKey(sht.location)){
            List<PlantSHTWrap> pSW= plantSHTWrapMap.get(sht.mrcName);
            if(!locations.contains(sht.location)){               
                locations.add(sht.location);
            pSW.add(pSHTWarp);
            plantSHTWrapMap.put(sht.mrcName,pSW);
            }


        }else{
           	List<PlantSHTWrap> pSHTW = new List<PlantSHTWrap>();
            pSHTW.add(pSHTWarp);
            locations.add(sht.location);
			plantSHTWrapMap.put(sht.mrcName,pSHTW);
		}
	}
    Set<String> mrcs = new Set<String>();
    for(MRCDataWrap sht : mrcData){
        mrcs.add(sht.mrcName);
    }
	for(String mrc : mrcs){
		SHTPriceAndMarketMrcNoDisplayWrap shtPAM = new SHTPriceAndMarketMrcNoDisplayWrap();
		shtPAM.mrcNo= mrc;
		shtPAM.plantSHTWrap = plantSHTWrapMap.get(mrc);
        shtPAM.rowSpan = plantSHTWrapMap.get(mrc).size();
		shtPriceAndMarket.add(shtPAM);
	}
    System.debug('SHTS Sampada'+' '+plantSHTWrapMap+' '+shtPriceAndMarket);

	return shtPriceAndMarket;

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

   
    
    public class MRCDataWrap{          
      @AuraEnabled
      public Id mrcId;
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
      public decimal onlineATP;
      @AuraEnabled
      public decimal phoneATP;	//Fix_437452_02Mar2020_Soumyajit
      @AuraEnabled
      public decimal finalbspCal;
      @AuraEnabled
      public decimal finalSalesPriceCal;
      @AuraEnabled
	  public decimal dailySales;//added by swarna hyoercare
      @AuraEnabled
      public decimal OTM;
      @AuraEnabled
      public Decimal volumeCBM;
      @AuraEnabled
      public String Comment;
      @AuraEnabled
      public boolean isPricingTaxed;
      @AuraEnabled
      public boolean margin;
      @AuraEnabled
      public Decimal lap;
      @AuraEnabled
      public String contractStartDate;
      @AUraEnabled
      public String contractEndDate;
      @AUraEnabled
      public String createdDate;
      
      /* Start - Code added by Mohan */
      @auraEnabled
      public decimal finalOTM;
      @AUraEnabled
      public String mrcLineItem;
      @AUraEnabled
      public String shipToName;
      @AuraEnabled
      public String soldTo;
      @AuraEnabled
      public String soldToNumber;
      @AuraEnabled
      public String tranche;
      @AuraEnabled
      public String startDate;
      @AuraEnabled
      public String endDate;
      @AuraEnabled
      public map<String,RV_Offer_Tracking__c> offerTrackMap;
      @AuraEnabled
      public RV_Offer_Tracking__c lastOffer; 
      @AuraEnabled
      public String lastOfferedPrice; 
      @AuraEnabled
      public String lastOfferedVolume; 
      @AuraEnabled
      public decimal atpLive;
      @AuraEnabled
      public Boolean hasEditAccess;
      @AuraEnabled
      public Boolean showFinalOTM;
      /* End - Code added by Mohan */
  }
    /* Start - Code added by Mohan */
    public class offerTrackingWrap{          
        @AuraEnabled
        public String mrcNo;
        @AuraEnabled
        public string shipToNum;
        @AuraEnabled
        public string plantCode;
        @AuraEnabled
        public Decimal bsp;
        @AuraEnabled
		public decimal finalSalesPriceCal;//added by swarna hypercare
        @AuraEnabled
        public Decimal finalOtm;
        @AuraEnabled
        public Decimal offerValue;
        @AUraEnabled
        public String mrcLineItem;
        @AUraEnabled
        public String shipToName;
        @AuraEnabled
        public String soldTo;
        @AuraEnabled
        public String soldToNumber;
        @AuraEnabled
        public String tranche;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public Decimal offerVolume;
        @AuraEnabled
        public Boolean checked;
        @AuraEnabled
        public String grade;
        @AuraEnabled
        public String salesOrg;

    }   
    /* End - Code added by Mohan */
}