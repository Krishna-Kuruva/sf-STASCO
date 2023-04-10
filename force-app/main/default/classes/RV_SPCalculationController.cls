public class RV_SPCalculationController {
    public static String gtl_b7 = 'GTL B7';
    public static boolean isOlfDeal = false;	//Fix_394298_10Jan2020_Soumyajit
    public static String tranche;   //Rahul Sharma | DATE - 03-Nov-2020 : Added tranche variable updated by OLF transaction.
    public static salesPriceCalAndAuditWrap getCalulatedSp(List<MRC__c> mrclist,date contractStartDate,date contractEndDate){
        List<salesPriceWrap> spWrapLst= new List<salesPriceWrap>();
        List<RV_SHT_Calculation_Util.PriceDataWrap> hcvWrap = new List<RV_SHT_Calculation_Util.PriceDataWrap>();
        salesPriceCalAndAuditWrap spCalPrcAdtWrp= new salesPriceCalAndAuditWrap();
        RV_SHT_Calculation_Util util=new RV_SHT_Calculation_Util();
        Map<String,MRC__c> mrcNoMap = new  Map<String,MRC__c>();
        Map<String,Product_Catalogue__c> materialNoCostMap = new  Map<String,Product_Catalogue__c>();
        Map<String,String> mrcMaterialNoMap = new  Map<String,String>();
        Map<String,Product_Catalogue__c> materialNoMap = new Map<String,Product_Catalogue__c>();
        Set<String> plantGradeSet = new Set<String>();
        Map<string,Decimal> CoSrcSteerMap= new Map<string,Decimal>();
        Map<string,Decimal> depotSteerMap= new Map<string,Decimal>();
        Set<String> plantUnqSet= new Set<String>();
        Set<String> materialUnqSet= new Set<String>();
        Set<String> gradeThirdPartyPlantCode= new Set<String>();
        Set<String> plantGradeThptSet= new Set<String>();
        Set<String> plantStdGrdUnqSet= new Set<String>();
        Map<String,String> MapOfProductMapping = new Map<String,String>();

        Map<String,String> BioAmvGardeMap = new Map<String,String>();
        Map<String,String> thirdPartyGardeMap = new Map<String,String>();
        Map<String,Mrc__c> plantGradeMrcObjMap= new Map<String,Mrc__c>();
        Map<String,List<Freight_Rate__c>> plantGradeBAMVObjMap= new Map<String,List<Freight_Rate__c>>();
        Map<String,decimal> bioAmvPlntGradMap= new Map<String,decimal>();
        Map<String,Decimal> mrcLandedCostmap = new Map<String,Decimal>();
        Set<String> thirdPartyQuotes=new Set<String>();
        Map<String,Decimal> mapOFQuotesAndValues=new Map<String,Decimal>();
        Set<Id> acntIdSet= new Set<Id>();
        Set<Id> locationIdSet = new Set<Id>();
        Set<String> salesOrgSet = new Set<String>();
        Set<String> gradeSet = new Set<String>();
        Map<String,String> marginGradeMap= new  Map<String,String>();
	//added by Swarna as part of PBI-1659161 --> GTL B7 Margin
        Map<String,String> gtlProdMap = new Map<String,String>();
        //PBI_166949_Lakshmi_31032020_starts
        List<Product_Name_Mapping__mdt> fetchProductMappingMD = [SELECT ID,MasterLabel,DeveloperName,Product_Name__c,Margin_Mapping__c,Bio_AMV_Grade_Name__c from
                                                                 Product_Name_Mapping__mdt];

        //START - Rahul Sharma | Date: 12-Jun-2020 : Get tranche for the current deal.
        //START - Rahul Sharma | Date: 03-Nov-2020 : Added condition to call getTranche method only for offline deal.
        if(!isOlfDeal){
        //END - Rahul Sharma | Date: 03-Nov-2020 : Added condition to call getTranche method only for offline deal.
            tranche = getTranche(contractStartDate);
            }
        //END - Rahul Sharma | Date: 12-Jun-2020 : Get tranche for the current deal.

        // Standard grade and Grade Mapping
        for(Product_Name_Mapping__mdt prd:fetchProductMappingMD){
	    //added by Swarna as part of PBI-1659161 --> GTL B7 Margin
            if(prd.MasterLabel == gtl_b7){
                MapOfProductMapping.put(prd.MasterLabel,prd.MasterLabel);
                marginGradeMap.put(prd.MasterLabel,prd.MasterLabel);
                gtlProdMap.put(prd.MasterLabel,prd.Product_Name__c);
            }else{
		    MapOfProductMapping.put(prd.MasterLabel,prd.Product_Name__c);
		    marginGradeMap.put(prd.MasterLabel,prd.Margin_Mapping__c);
		}
            //end PBI-1659161 --> GTL B7 Margin
            BioAmvGardeMap.put(prd.MasterLabel,prd.Bio_AMV_Grade_Name__c);//PBI_166949_Lakshmi_31032020
           // mrcBAMVGradeMap.put(prd.Product_Name__c,prd.MasterLabel);
        }

        //Shipping Condition Map
        Map<Integer,Shipping_Condition_Mapping__mdt> shippingCondMap= new Map<Integer,Shipping_Condition_Mapping__mdt>();
        List<Shipping_Condition_Mapping__mdt> shippingLst=[Select id,MOT__c,MoTKey__c,Shipping_Condition__c,Margin_Type__c
                                                           from Shipping_Condition_Mapping__mdt];
        for(Shipping_Condition_Mapping__mdt scm:shippingLst){
            shippingCondMap.put(Integer.valueOf(scm.Shipping_Condition__c),scm);
        }
        Set<String> salesOrgPlantCodeMotSet= new Set<String>();
        Map<String,mrcMaterialWrap> mrcMaterialWrapMap = new Map<String,mrcMaterialWrap>();
       //making diffrent Maps as per use
        for(mrc__c mr:mrclist){
            mrcMaterialWrap mrcMaterial = new mrcMaterialWrap();
            mrcMaterial.gradeL2 = mr.Product__r.Commodity_Grade_L2__c;
            mrcMaterial.handlingtype = mr.Handling_Type__c;
            mrcMaterial.salesOrg = mr.Sales_Organization__c;

            if(mr.Product__r.BEHG_Value_100l__c !=null && mr.Product__r.BEHG_Value_100l__c !=0)
            mrcMaterial.behgeuro100l = mr.Product__r.BEHG_Value_100l__c;
            if(mr.Product__r.Current_BEHG_valid_from_date__c !=null)
            mrcMaterial.currValidFrom = mr.Product__r.Current_BEHG_valid_from_date__c;
            if(mr.Product__r.Current_BEHG_valid_to_date__c !=null)
            mrcMaterial.currValidTo = mr.Product__r.Current_BEHG_valid_to_date__c;

            if(mr.Product__r.Future_BEHG_value_in_100l__c !=null && mr.Product__r.Future_BEHG_value_in_100l__c !=0)
            mrcMaterial.futurebehgeuro100l = mr.Product__r.Future_BEHG_value_in_100l__c;
            if(mr.Product__r.Future_BEHG_valid_from_date__c !=null)
            mrcMaterial.FutValidFrom = mr.Product__r.Future_BEHG_valid_from_date__c;
            if(mr.Product__r.Future_BEHG_valid_to_date__c !=null)
            mrcMaterial.FutValidTo = mr.Product__r.Future_BEHG_valid_to_date__c;

            mrcMaterialWrapMap.put(mr.Name, mrcMaterial);
            mrcNoMap.put(mr.Name,mr);
            if((mr.Shipping_Condition__c!=null) && shippingCondMap.containsKey(Integer.valueOf(mr.Shipping_Condition__c))
               && shippingCondMap.get(Integer.valueOf(mr.Shipping_Condition__c)).MOT__c != null){
                   string  mot=shippingCondMap.get(Integer.valueOf(mr.Shipping_Condition__c)).MOT__c;
                   if(mot=='Barge' || mot=='Rail'){
                       plantGradeThptSet.add(mr.Plant_Code__c+mr.Material_Description__c+shippingCondMap.get(Integer.valueOf(mr.Shipping_Condition__c)).MOT__c);

                   }else{
                       plantGradeThptSet.add(mr.Plant_Code__c+MapOfProductMapping.get(mr.Material_Description__c)+shippingCondMap.get(Integer.valueOf(mr.Shipping_Condition__c)).MOT__c);
                   }
               }
            plantGradeMrcObjMap.put(mr.Plant_Code__c+BioAmvGardeMap.get(mr.Material_Description__c)+mr.Name,mr);
            mrcMaterialNoMap.put(mr.Name,mr.Product__r.Name);
		//added by Swarna as part of PBI-1659161 --> GTL B7 Margin
           if(gtlProdMap.get(mr.Material_Description__c) != null && mr.Material_Description__c == MapOfProductMapping.get(mr.Material_Description__c)){
                plantStdGrdUnqSet.add(mr.Plant_Code__c+gtlProdMap.get(mr.Material_Description__c));
            }else{
            	plantStdGrdUnqSet.add(mr.Plant_Code__c+MapOfProductMapping.get(mr.Material_Description__c));
		}//end
            materialUnqSet.add(mr.Product__r.Name);
            acntIdSet.add(mr.Sold_To__c);
            plantUnqSet.add(mr.Plant_Code__c);
            plantGradeSet.add(mr.Plant_Code__c+'_'+mr.Material_Description__c); // For CPD Margin and sales Margin

            if(shippingCondMap.containsKey(Integer.valueOf(mr.Shipping_Condition__c))){
                salesOrgPlantCodeMotSet.add(mr.Sales_Organization__c+mr.Plant_Code__c+shippingCondMap.get((Integer.valueOf(mr.Shipping_Condition__c))).Margin_Type__c);
            }
            //START - Rahul Sharma | Date: 18-Feb-2020 : Added logic to store Plant, Sales Org and Material Grade
            locationIdSet.add(mr.Plant__c);
            salesOrgSet.add(mr.Sales_Organization__c);
            gradeSet.add(mr.Material_Description__c);
            //END - Rahul Sharma | Date: 18-Feb-2020 : Added logic to store Account Id, Plant Code, Sales Org and Material Grade
        }

        //START - Rahul Sharma | Date - 14-Feb-2020 : Added map for Customer Specific Pricing
        Map<String, Customer_Specific_Pricing__c> cspKeyVsObjectMap = getCustomerSpecificPricing(locationIdSet, acntIdSet, salesOrgSet, gradeSet, tranche);
        //END - Rahul Sharma | Date - 14-Feb-2020 : Added map for Customer Specific Pricing

        //Material additives cost Map
        List<Product_Catalogue__c> materialLst=[Select id,Name,Total_Additive_cost_EUR_100l__c,WASA_EUR_100l__c
                                                , Marketing_Cost__c	//Fix_394298_10Jan2020_Soumyajit
                                                from Product_Catalogue__c where Name IN :materialUnqSet];
        for(integer i=0;i<materialLst.size();i++){
            materialNoCostMap.put(materialLst[i].Name,materialLst[i]);
        }

        //==> Query On backbone AMV for fileterd plant and standard Grade Combination
        List<Freight_Rate__c>  BAMVLst= new List<Freight_Rate__c>();
        Map<String,List<Freight_Rate__c>> MrcNoBAMVMap = new Map<String,List<Freight_Rate__c>>();
        //Fix_PBI_201967_Lakshmi_Starts
        //Added By Dhriti (Supplier__c)
        //Fix_493485_Lakshmi_27Apr2020(Backbone_Route_Name__c)
        BAMVLst=[Select id,Destination__c,Destination_Code__c,Standard_Grade__c,Source__c,Source_Code__c,Bio_Split__c,
                 Name,Backbone_Route_Name__c,Mode_Of_Transport__c,Freight_rate_EUR_mt__c,Supplier__c,Route_Utilization__c,
                 Supply_Type__c,PlantGradeUnq__c,Alt_Type__c,SubGrade_3P__c,Quote_Region_Source__c,
                 Valid_From__c,Valid_To__c,Third_Party__c,Freight_Percentage__c,Marker__c from Freight_Rate__c where PlantGradeUnq__c IN :plantStdGrdUnqSet and  Valid_From__c <= :contractStartDate and
                                                                        Valid_To__c >=:contractStartDate];

        //system.debug('BAMVLst===>'+BAMVLst);
    //    system.debug('BAMVLst===>'+BAMVLst[0].Valid_From__c);
       // system.debug('BAMVLst===>'+BAMVLst[0].Valid_To__c);


        //Fix_PBI_201967_Lakshmi_Ends
        Set<String> plantGrade3rdBioAMVSet= new Set<String>();
        for(Freight_Rate__c bav:BAMVLst){
            if(plantGradeBAMVObjMap.containsKey(bav.Destination_Code__c+bav.SubGrade_3P__c)){
                List<Freight_Rate__c> bavLst=plantGradeBAMVObjMap.get(bav.Destination_Code__c+bav.SubGrade_3P__c);
                bavLst.add(bav);
                 plantGradeBAMVObjMap.put(bav.Destination_Code__c+bav.SubGrade_3P__c,bavLst);
            }
            else{
                plantGradeBAMVObjMap.put(bav.Destination_Code__c+bav.SubGrade_3P__c,New List<Freight_Rate__c>{bav});
            }
            if(bav.Bio_Split__c){
                //AdditionalFix_1709686_Soumyajit_19Jul2019 starts
               //plantGrade3rdBioAMVSet.add(bav.Destination_Code__c+bav.SubGrade_3P__c);

               //Fix_493485_Lakshmi_27Apr2020_starts
               //plantGrade3rdBioAMVSet.add(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.name);
                plantGrade3rdBioAMVSet.add(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.Backbone_Route_Name__c);
               //Fix_493485_Lakshmi_27Apr2020_Ends
                //AdditionalFix_1709686_Soumyajit_19Jul2019 ends
            }
        }


        //Making Map of Mrc number and adding Backbone amv row items for each mrc
        //Finding Third Party row item from Backbone Amv
         //plantGradeBAMVObjMap, plantGradeMrcObjMap

        for(String key :plantGradeMrcObjMap.keySet()){
            string newkey=key.removeEnd((plantGradeMrcObjMap.get(key).Name));
            if(plantGradeBAMVObjMap.containsKey(newkey)){
                MrcNoBAMVMap.put((plantGradeMrcObjMap.get(key)).Name,plantGradeBAMVObjMap.get(newkey));
            }
        }



        for(string mrc:MrcNoBAMVMap.keyset()){
            List<Freight_Rate__c> frLst=MrcNoBAMVMap.get(mrc);
            for(Freight_Rate__c frt:frLst){
                RV_SHT_Calculation_Util.PriceDataWrap wrp = new RV_SHT_Calculation_Util.PriceDataWrap();
                string salesOrg=mrcNoMap.get(mrc).Sales_Organization__c;
                wrp.MRCNumber=mrc;
                wrp.plantCode=frt.Destination_Code__c;
                wrp.altType=frt.Alt_Type__c;
                wrp.salesOrg=salesOrg;
                //wrp.routeName=frt.Name;
                wrp.routeName=frt.Backbone_Route_Name__c;//Fix_493485_Lakshmi_27Apr2020
                wrp.isThirdParty=frt.Third_Party__c;
                wrp.grade=BioAmvGardeMap.get(mrcNoMap.get(mrc).Material_Description__c);
                wrp.locationType=frt.Quote_Region_Source__c;//Barge-Cargo of Source
                if(frt.Third_Party__c){
                     //gradeThirdPartyPlantCode.add(salesOrg+'_'+frt.Name);//Fix_493485_Lakshmi_27Apr2020
                     gradeThirdPartyPlantCode.add(salesOrg+'_'+frt.Backbone_Route_Name__c);
                }
                 hcvWrap.add(wrp);
            }
        }

        //system.debug('priceDataHCVWrapListTo=>'+hcvWrap);
        // Getting HCV values for Plant and Grade Combination
        Map<string,RV_SHT_Calculation_Util.ReturnWrap> plantGradeHCVMap= new Map<string,RV_SHT_Calculation_Util.ReturnWrap>();
        List<RV_SHT_Calculation_Util.PriceDataWrap> priceDataHCVWrap=util.getFinalHCV(hcvWrap,contractStartDate,contractEndDate);
        List<RV_SHT_Calculation_Util.PriceDataWrap> HCVwrapLst= new List<RV_SHT_Calculation_Util.PriceDataWrap>();
        HCVwrapLst.addAll(priceDataHCVWrap);
        //hcvWrap,HCVwrapLst

        //system.debug('priceDataHCVWrapListFrom=>'+priceDataHCVWrap);
        for(integer i=0;i<HCVwrapLst.size();i++){
            if(HCVwrapLst[i].ReturnWrap != null){
                if(HCVwrapLst[i].isThirdParty){
                    plantGradeHCVMap.put(HCVwrapLst[i].salesOrg+'_'+HCVwrapLst[i].routeName,HCVwrapLst[i].ReturnWrap);
                }else{
                    plantGradeHCVMap.put(HCVwrapLst[i].routeName,HCVwrapLst[i].ReturnWrap);
                }

            }
            else{
                //system.debug('salesPriceCalAndAuditWrap Error HCV==>'+HCVwrapLst[i]);
            }

        }
        priceDataHCVWrap=null;

        //Getting Co Steer Source Value
        Id srcRcdTypId=Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        Id depotRcdTypId=Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
        List<Location_Steer__c> locStrLst= new List<Location_Steer__c>([Select id,Depot_Steer__c,Source_Steer__c,Valid_From__c,
                                                                        Valid_To__c,MOT__c,Product_Sub_Group__c,Plant_Code__c,
                                                                        PlantGradeUnq__c,RecordTypeId,Default__c,RecordType.Name from Location_Steer__c where
                                                                        (RecordTypeId =:srcRcdTypId Or RecordTypeId =:depotRcdTypId)
                                                                        //Fix_314451_Soumyajit_23Sep2019 starts
                                                                        /*and  Valid_From__c <= :contractStartDate and
                                                                        Valid_To__c >=:contractStartDate
																		order by PlantGradeUnq__c ASC*/
                                                                        and (	(Valid_From__c <= :contractStartDate)
                                                                        	or 	(Valid_To__c <=:contractEndDate)
                                                                            or  (Valid_From__c <= :contractEndDate))
                                                                        order by PlantGradeUnq__c, Valid_From__c, Valid_To__c ASC
                                                                       //Fix_314451_Soumyajit_23Sep2019 ends
                                                                       ]);

        //Filtering Source Steer & Depot Steer
        List<Location_Steer__c> srcStrLst=fiterList(locStrLst,srcRcdTypId);
        List<Location_Steer__c> depotStrLst=fiterList(locStrLst,depotRcdTypId);

        //Getting Average value for Source based on Plant and Grade
        CoSrcSteerMap=getSteerWeightedAvg(srcStrLst,contractStartDate,contractEndDate,'Source Steer');	//getSteerAvg(srcStrLst,'Source Steer');	//Fix_314451_Soumyajit_23Sep2019 starts
        //Getting Average value for Deoot based on Plant,Grade & Steer
        depotSteerMap=getSteerWeightedAvg(depotStrLst,contractStartDate,contractEndDate,'Depot Steer');	//getSteerAvg(depotStrLst,'Depot Steer');	//Fix_314451_Soumyajit_23Sep2019 starts

        //get bio amv based on contract start and end date for prompt and future
        bioAmvPlntGradMap=getBioAmvAvg(plantUnqSet,contractStartDate,contractEndDate);

        //Get Freight and Bio Amv for 3rd party

        //FIX_470189_Lakshmi_30Apr2020(change Supply_Route_ID__c to Supply_Route_ID_Name__c)
        List<Third_Party_Contract_Master__c> thirdpartyLstAll=[Select id,Additive_surcharge__c,Bio_Quote__c,Bio_Quotes__c,Plant_Code__c,
                                                            Bio_surcharge__c,Frieight_Quote_per__c,Loc_Diff__c,GradeLocation__c,Grade__c,
                                                            Frieight_Quote__c,Valid_From__c,Valid_To__c,SalesOrg_Customer__c,Supply_Route_ID_Name__c
                                                            from Third_Party_Contract_Master__c
                                                            where GradeLocation__c IN: gradeThirdPartyPlantCode
                                                          //  and Valid_From__c <= :contractStartDate
                                                            order by GradeLocation__c,Valid_To__c asc];
        List<Third_Party_Contract_Master__c> thirdpartyLst= new List<Third_Party_Contract_Master__c>();
        for(Third_Party_Contract_Master__c thrd :thirdpartyLstAll){
            if(thrd.Valid_From__c <= contractEndDate){
               thirdpartyLst.add(thrd);
            }
        }
        Map<String,Third_Party_Contract_Master__c> GradeLocationthirdPartyWasaCost=new Map<String,Third_Party_Contract_Master__c>();

       //For Considering Additive Cost first element to be taken
        for(Third_Party_Contract_Master__c thirdPArty:thirdpartyLst)
        {

                GradeLocationthirdPartyWasaCost.put(thirdPArty.GradeLocation__c,thirdPArty);
        }


        for(Third_Party_Contract_Master__c thirdparty :thirdpartyLst){
            /* prod deployment */
            if(thirdparty.Bio_Quotes__c != null){
                thirdPartyQuotes.add(thirdparty.Bio_Quotes__c);
            }
            if(thirdparty.Frieight_Quote__c != null){
                thirdPartyQuotes.add(thirdparty.Frieight_Quote__c);
            }
        }

        date last4days =system.today().addDays(-4);
        List<Reuters_Quotes__c> quotesValuesReuters=[Select  QuoteAndMonth__c,Valid_Month__c,Quote_Display_Name__c,Price__c,CurrencyCode__c,Unit_Of_Measure__c
                                                     from Reuters_Quotes__c where
                                                     //lastModifiedDate >= :last4days  and
                                                     (Quote_Display_Name__c in: thirdPartyQuotes )  order by lastModifiedDate asc];

        for(Reuters_Quotes__c quoteReuter: quotesValuesReuters){
            if(quoteReuter.Quote_Display_Name__c!=null){
                Decimal finalPrice=util.convertCurrencyAndUnitValue(quoteReuter.Price__c,quoteReuter.CurrencyCode__c, quoteReuter.Unit_Of_Measure__c);
                mapOFQuotesAndValues.put(quoteReuter.Quote_Display_Name__c,finalPrice);
            }
        }

        Map<string,decimal> plantGradeFreightMap =new Map<string,decimal>();
        Map<string,decimal> plantGrade3rdBioMap = new Map<string,decimal>();
        Map<String,decimal> plantGrade3rdAdditiveMap= new Map<String,decimal>();
        Map<string,decimal> thirdPartySplitBio=new Map<string,decimal>();
        decimal densityagoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
 		decimal densityMogas=Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);
        //Fix_1709686_Soumyajit_24May2019 Starts
        //Pass HCV to split calculation
        //thirdPartySplitBio=getThirdPartySplitBioAmvValue(thirdpartyLstAll,plantGrade3rdBioAMVSet,mapOFQuotesAndValues,contractStartDate,contractEndDate);
        thirdPartySplitBio=getThirdPartySplitBioAmvValue(thirdpartyLstAll,plantGrade3rdBioAMVSet,mapOFQuotesAndValues,contractStartDate,contractEndDate,plantGradeHCVMap);
        //Fix_1709686_Soumyajit_24May2019 Ends

        Map<String,Integer> plantGrd3rdBioNoOfDaysMap= new Map<String,Integer>();		//Fix_404256_27Dec2019_Soumyajit
        Map<String,Integer> plantGradeFreightNoOfDaysMap= new Map<String,Integer>();	//Fix_404256_27Dec2019_Soumyajit

        for(Third_Party_Contract_Master__c thirdparty :thirdpartyLst){
            decimal freightPercent=thirdparty.Frieight_Quote_per__c;
            decimal bioPercent=thirdparty.Bio_Quote__c;
            decimal freightQuoteVal=mapOFQuotesAndValues.get(thirdparty.Frieight_Quote__c);
            decimal bioQuoteVal=0;
            decimal bioSurcharge=thirdparty.Bio_surcharge__c;

            //Fix_404256_27Dec2019_Soumyajit starts
            Integer noOfDays =0;

            if(thirdparty.Valid_From__c <= contractStartDate &&  thirdparty.Valid_To__c >= contractEndDate)
                noOfDays=contractStartDate.daysBetween(contractEndDate) + 1;
            else if(thirdparty.Valid_From__c <= contractStartDate && thirdparty.Valid_To__c <= contractEndDate)
                noOfDays=contractStartDate.daysBetween(thirdparty.Valid_To__c) + 1;
            else if(thirdparty.Valid_From__c >= contractStartDate && thirdparty.Valid_To__c >= contractEndDate)
                noOfDays=thirdparty.Valid_From__c.daysBetween(contractEndDate) + 1;
            else if(thirdparty.Valid_From__c >= contractStartDate && thirdparty.Valid_To__c <= contractEndDate)
                noOfDays=thirdparty.Valid_From__c.daysBetween(thirdparty.Valid_To__c) + 1;
            else
                noOfDays = 0;

            if(noOfDays < 0)
                noOfDays = 0;

            //System.debug('For ' + thirdparty.GradeLocation__c);
            //System.debug('From='+ thirdparty.Valid_From__c + ',To=' + thirdparty.Valid_To__c + ',noOfDays='+noOfDays);

            if(noOfDays>0){
            //Fix_404256_27Dec2019_Soumyajit ends

            if((thirdparty.Bio_Quotes__c != null) && thirdparty.Bio_Quotes__c.containsIgnoreCase('FAME')){

                if(mapOFQuotesAndValues.containsKey(thirdparty.Bio_Quotes__c)){
                    bioQuoteVal=mapOFQuotesAndValues.get(thirdparty.Bio_Quotes__c);

                }//ago igo - 0.845

                //Fix_1709686_Soumyajit_24May2019 Starts
                //Do Bio-HCV
                if(plantGradeHCVMap.containsKey(thirdparty.GradeLocation__c) && (plantGradeHCVMap.get(thirdparty.GradeLocation__c).finalHCVValue != null) && bioQuoteVal !=null)
                {
                    //system.debug('BioFAME-HCV for'+thirdparty.GradeLocation__c + ' is ' + bioQuoteVal + ' - ' + plantGradeHCVMap.get(thirdparty.GradeLocation__c).finalHCVValue);
                    bioQuoteVal = bioQuoteVal - plantGradeHCVMap.get(thirdparty.GradeLocation__c).finalHCVValue;
                }
                //Fix_1709686_Soumyajit_24May2019 Ends

                if(bioPercent==0 ||bioPercent== null){
                    bioQuoteVal=0;
                }else{
                    bioQuoteVal=(bioQuoteVal*bioPercent)/100;
                }
                decimal finalBio=0;
               // decimal densityagoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
                if(bioSurcharge==0 || bioSurcharge== null){
                    finalBio=bioQuoteVal;
                }else{
                   finalBio=bioQuoteVal+(bioSurcharge/densityagoIgo);

                }

                //System.debug('Inside BioFAME with Bio_Quotes__c='+ thirdparty.Bio_Quotes__c +', bioPercent='+bioPercent+', bioQuoteVal='+bioQuoteVal+', surcharge='+bioSurcharge+', densityagoIgo='+densityagoIgo);
                //System.debug('Inside BioFAME with finalBio='+finalBio);

                //Fix_404256_27Dec2019_Soumyajit starts
                //plantGrade3rdBioMap.put(thirdparty.GradeLocation__c,finalBio);
                decimal finalWeightedBio = finalBio * noOfDays;
                if(plantGrade3rdBioMap.containskey(thirdparty.GradeLocation__c))
                    finalWeightedBio += plantGrade3rdBioMap.get(thirdparty.GradeLocation__c);
                plantGrade3rdBioMap.put(thirdparty.GradeLocation__c,finalWeightedBio);

                //System.debug('finalWeightedBio='+finalWeightedBio);

                if(plantGrd3rdBioNoOfDaysMap.containsKey(thirdparty.GradeLocation__c))
                    plantGrd3rdBioNoOfDaysMap.put(thirdparty.GradeLocation__c
                                                  ,noOfDays + plantGrd3rdBioNoOfDaysMap.get(thirdparty.GradeLocation__c));
                else
                	plantGrd3rdBioNoOfDaysMap.put(thirdparty.GradeLocation__c,noOfDays);
                //Fix_404256_27Dec2019_Soumyajit ends
            }
            if((thirdparty.Bio_Quotes__c != null) && thirdparty.Bio_Quotes__c.containsIgnoreCase('ETHANOL')){

                if(mapOFQuotesAndValues.containsKey(thirdparty.Bio_Quotes__c)){
                    bioQuoteVal=mapOFQuotesAndValues.get(thirdparty.Bio_Quotes__c);
                    if(bioQuoteVal!=0){
                        bioQuoteVal=bioQuoteVal/0.792;
                    }
                }

                //Fix_1709686_Soumyajit_24May2019 Starts
                //Do Bio-HCV
                if(plantGradeHCVMap.containsKey(thirdparty.GradeLocation__c) && (plantGradeHCVMap.get(thirdparty.GradeLocation__c).finalHCVValue != null) && bioQuoteVal !=null)
                {
                   // system.debug('BioETHANOL-HCV for'+thirdparty.GradeLocation__c + ' is ' + bioQuoteVal + ' - ' + plantGradeHCVMap.get(thirdparty.GradeLocation__c).finalHCVValue);
                    bioQuoteVal = bioQuoteVal - plantGradeHCVMap.get(thirdparty.GradeLocation__c).finalHCVValue;
                }
                //Fix_1709686_Soumyajit_24May2019 Ends

                //mogas - 0.755
                //(BioQuoteVal/densityEthanol *bioPercentage)+bioSurcharge/densityMogas
                if(bioPercent==0 ||bioPercent== null){
                    bioQuoteVal=0;
                }else{
                    bioQuoteVal=(bioQuoteVal*bioPercent)/100;
                }
                decimal finalBio=0;
                //decimal densityMogas=Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);
                if(bioSurcharge==0 || bioSurcharge== null){
                    finalBio=bioQuoteVal;
                }else{
                   finalBio=bioQuoteVal+(bioSurcharge/densityMogas);
                }

                //System.debug('Inside BioETHANOL with Bio_Quotes__c='+ thirdparty.Bio_Quotes__c +', bioPercent='+bioPercent+', bioQuoteVal='+bioQuoteVal+', surcharge='+bioSurcharge +', densityMogas='+densityMogas);
                //System.debug('Inside BioETHANOL with finalBio='+finalBio);

                //Fix_404256_27Dec2019_Soumyajit starts
                //plantGrade3rdBioMap.put(thirdparty.GradeLocation__c,finalBio);
                decimal finalWeightedBio = finalBio * noOfDays;
                if(plantGrade3rdBioMap.containskey(thirdparty.GradeLocation__c))
                    finalWeightedBio += plantGrade3rdBioMap.get(thirdparty.GradeLocation__c);
                plantGrade3rdBioMap.put(thirdparty.GradeLocation__c,finalWeightedBio);

                //System.debug('finalWeightedBio='+finalWeightedBio);

                if(plantGrd3rdBioNoOfDaysMap.containsKey(thirdparty.GradeLocation__c))
                    plantGrd3rdBioNoOfDaysMap.put(thirdparty.GradeLocation__c
                                                  ,noOfDays + plantGrd3rdBioNoOfDaysMap.get(thirdparty.GradeLocation__c));
                else
                	plantGrd3rdBioNoOfDaysMap.put(thirdparty.GradeLocation__c,noOfDays);
                //Fix_404256_27Dec2019_Soumyajit ends
            }

            //Fix_260836_Soumyajit_22May2019 Starts
            //Surcharge is applicable, even if BioQuote is abscent
            if(thirdparty.Bio_Quotes__c == null && bioSurcharge!=0 && bioSurcharge!= null)
            {
                decimal finalBio=0;
                //FIX_470189_Lakshmi_30Apr2020
                //if(thirdparty.Supply_Route_ID__c.containsIgnoreCase('MOGAS'))
                  if(thirdparty.Supply_Route_ID_Name__c.containsIgnoreCase('MOGAS'))
                    finalBio=bioSurcharge/densityMogas;
                else
                	finalBio=bioSurcharge/densityagoIgo;

                //System.debug('Inside BioNoQuote with Supply_Route_ID__c='+ thirdparty.Supply_Route_ID__c +', surcharge='+bioSurcharge +', densityagoIgo=' +densityagoIgo+', densityMogas='+densityMogas);
                //System.debug('Inside BioNoQuote with finalBio='+finalBio);

                //Fix_404256_27Dec2019_Soumyajit starts
                //plantGrade3rdBioMap.put(thirdparty.GradeLocation__c,finalBio);
                decimal finalWeightedBio = finalBio * noOfDays;
                if(plantGrade3rdBioMap.containskey(thirdparty.GradeLocation__c))
                    finalWeightedBio += plantGrade3rdBioMap.get(thirdparty.GradeLocation__c);
                plantGrade3rdBioMap.put(thirdparty.GradeLocation__c,finalWeightedBio);

                //System.debug('finalWeightedBio='+finalWeightedBio);

                if(plantGrd3rdBioNoOfDaysMap.containsKey(thirdparty.GradeLocation__c))
                    plantGrd3rdBioNoOfDaysMap.put(thirdparty.GradeLocation__c
                                                  ,noOfDays + plantGrd3rdBioNoOfDaysMap.get(thirdparty.GradeLocation__c));
                else
                	plantGrd3rdBioNoOfDaysMap.put(thirdparty.GradeLocation__c,noOfDays);
                //Fix_404256_27Dec2019_Soumyajit ends
            }
            //Fix_260836_Soumyajit_22May2019 Ends

            if(freightPercent==null) freightPercent = 0;
            if(freightQuoteVal==null) freightQuoteVal = 0;
            if(thirdparty.Loc_Diff__c==null) thirdparty.Loc_Diff__c = 0;

            decimal freightVal=freightPercent*freightQuoteVal;
            if(freightVal!=0){
                freightVal=freightVal/100;
            }

            	//Fix_404256_27Dec2019_Soumyajit starts
                //plantGradeFreightMap.put(thirdparty.GradeLocation__c,freightVal+thirdparty.Loc_Diff__c);
                decimal finalWeightedFreight = (freightVal+thirdparty.Loc_Diff__c) * noOfDays;
                if(plantGradeFreightMap.containskey(thirdparty.GradeLocation__c))
                    finalWeightedFreight += plantGradeFreightMap.get(thirdparty.GradeLocation__c);
                plantGradeFreightMap.put(thirdparty.GradeLocation__c,finalWeightedFreight);

            	//System.debug('finalWeightedFreight='+finalWeightedFreight);

            	if(plantGradeFreightNoOfDaysMap.containsKey(thirdparty.GradeLocation__c))
                    plantGradeFreightNoOfDaysMap.put(thirdparty.GradeLocation__c
                                                  ,noOfDays + plantGradeFreightNoOfDaysMap.get(thirdparty.GradeLocation__c));
                else
                	plantGradeFreightNoOfDaysMap.put(thirdparty.GradeLocation__c,noOfDays);
            }
                //Fix_404256_27Dec2019_Soumyajit ends


        }

        //Fix_404256_27Dec2019_Soumyajit starts
        //System.debug('-----------plantGrade3rdBioMap---------');
        for(String key :plantGrade3rdBioMap.keySet())
        {
             plantGrade3rdBioMap.put(key
                                    ,plantGrade3rdBioMap.get(key)/plantGrd3rdBioNoOfDaysMap.get(key));
            //System.debug(key + ' = ' + plantGrade3rdBioMap.get(key));
        }
        //System.debug('-----------plantGradeFreightMap---------');
        for(String key :plantGradeFreightMap.keySet())
        {
             plantGradeFreightMap.put(key
                                      ,plantGradeFreightMap.get(key)/plantGradeFreightNoOfDaysMap.get(key));
            //System.debug(key + ' = ' + plantGradeFreightMap.get(key));
        }
        //System.debug('---------------------------------------');
        //Fix_404256_27Dec2019_Soumyajit ends

        //Adding all the attributes of backbone amv and to get Landed Cost
        Map<string,decimal> mrcNoLandedCostMap= new Map<string,decimal>();
        List<backboneAMVpriceCompWrap> bakBonAMVwrpLst=new List<backboneAMVpriceCompWrap>();

        for(string key : MrcNoBAMVMap.keySet()){
            List<Freight_Rate__c> bavLst= MrcNoBAMVMap.get(key);
            decimal finalBavval=0;
            for(Freight_Rate__c bav :bavLst){

                //Added standard Grade for wasa and additive conversion
                string standardGrade=MapOfProductMapping.get(mrcNoMap.get(key).Material_Description__c);

                if((BioAmvGardeMap.get(mrcNoMap.get(key).Material_Description__c) == bav.SubGrade_3P__c)
                   && (mrcNoMap.get(key).Plant_Code__c == bav.Destination_Code__c))
                {
                    backboneAMVpriceCompWrap bakBonAMVwrp= new backboneAMVpriceCompWrap();
                    decimal freight=0;
                    decimal bioAmv=0;
                    decimal coStr=0;
                    if(!bav.Third_Party__c){
                        if(CoSrcSteerMap.containsKey(bav.Source_Code__c+bav.Standard_Grade__c)
                          && (CoSrcSteerMap.get(bav.Source_Code__c+bav.Standard_Grade__c) != null)){
                            coStr= CoSrcSteerMap.get(bav.Source_Code__c+bav.Standard_Grade__c);
                        }
                    }
                    decimal freightToSource=0;
                    decimal freightToDepot=0;

                    if(bav.Freight_rate_EUR_mt__c != null){
                        freightToDepot=bav.Freight_rate_EUR_mt__c;
                        //system.debug('Frieght to depot'+freightToDepot);
                    }
                    //Fix_493485_Lakshmi_27Apr2020_starts
					//string salesOrgRouteName=mrcNoMap.get(key).Sales_Organization__c+'_'+bav.Name;
                    string salesOrgRouteName=mrcNoMap.get(key).Sales_Organization__c+'_'+bav.Backbone_Route_Name__c;
                    //Fix_493485_Lakshmi_27Apr2020_Ends
                    if(bav.Third_Party__c){
                     // string salesOrgRouteName=mrcNoMap.get(key).Sales_Organization__c+'_'+bav.Name;
                        if(plantGradeFreightMap.containsKey(salesOrgRouteName)
                          && (plantGradeFreightMap.get(salesOrgRouteName) !=null))
                            freightToSource=plantGradeFreightMap.get(salesOrgRouteName);
                        //system.debug('Frieght to source'+freightToSource);
                    }
                    freight=freightToSource+freightToDepot;


                    decimal hcv=0;
                    if(bav.Third_Party__c){
                        if(plantGradeHCVMap.containsKey(salesOrgRouteName)
                           && (plantGradeHCVMap.get(salesOrgRouteName).finalHCVValue != null)){
                               hcv=(plantGradeHCVMap.get(salesOrgRouteName)).finalHCVValue;
                           }
                    }else{
                        //Fix_493485_Lakshmi_27Apr2020_Starts
                       /* if(plantGradeHCVMap.containsKey(bav.name)
                           && (plantGradeHCVMap.get(bav.name).finalHCVValue != null)){
                               hcv=(plantGradeHCVMap.get(bav.name)).finalHCVValue;
                           }*/
                        if(plantGradeHCVMap.containsKey(bav.Backbone_Route_Name__c)
                           && (plantGradeHCVMap.get(bav.Backbone_Route_Name__c).finalHCVValue != null)){
                               hcv=(plantGradeHCVMap.get(bav.Backbone_Route_Name__c)).finalHCVValue;
                           }
                        //Fix_493485_Lakshmi_27Apr2020_Ends
                    }



                    //Logic to be changed for 3rd party bio based on date
                    if(bav.Third_Party__c){
                        if(bav.Bio_Split__c){
                             //logic for bio amv to be written based on dates
                             //AdditionalFix_1709686_Soumyajit_19Jul2019 starts
                            /*if(thirdPartySplitBio.containskey(bav.Destination_Code__c+bav.SubGrade_3P__c)
                              && (thirdPartySplitBio.get(bav.Destination_Code__c+bav.SubGrade_3P__c) !=null)){

                                 bioAmv=thirdPartySplitBio.get(bav.Destination_Code__c+bav.SubGrade_3P__c);
                                  System.debug('bioAMV***'+bioAmv);
                            }*/
                             //AdditionalFix_1709686_Soumyajit_19Jul2019 ends

                            //Fix_493485_Lakshmi_27Apr2020_Starts
                           /* if(thirdPartySplitBio.containskey(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.name)
                              && (thirdPartySplitBio.get(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.name) !=null)){

                                 bioAmv=thirdPartySplitBio.get(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.name);
                                  System.debug('bioAMV***'+bioAmv);
                            }*/


                            if(thirdPartySplitBio.containskey(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.Backbone_Route_Name__c)
                              && (thirdPartySplitBio.get(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.Backbone_Route_Name__c) !=null)){

                                 bioAmv=thirdPartySplitBio.get(bav.Destination_Code__c+bav.SubGrade_3P__c+bav.Backbone_Route_Name__c);
                                  System.debug('bioAMV***'+bioAmv);
                            }
                           //Fix_493485_Lakshmi_27Apr2020_Ends
                        }else{



                            if(plantGrade3rdBioMap.containskey(salesOrgRouteName)
                               && (plantGrade3rdBioMap.get(salesOrgRouteName) !=null)){
                                   bioAmv=plantGrade3rdBioMap.get(salesOrgRouteName);
                               }
                        }

                    }else{
                        if(bioAmvPlntGradMap.containskey(bav.Destination_Code__c+mrcNoMap.get(key).Sales_Organization__c+bav.SubGrade_3P__c)
                            && (bioAmvPlntGradMap.get(bav.Destination_Code__c+mrcNoMap.get(key).Sales_Organization__c+bav.SubGrade_3P__c) !=null)){
                            bioAmv=bioAmvPlntGradMap.get(bav.Destination_Code__c+mrcNoMap.get(key).Sales_Organization__c+bav.SubGrade_3P__c);
                        }

                    }

                    // Change here for 3rd party additives /wasa charge
                    decimal additives=0;
                    decimal wasa=0;//No wasa for 3rd Party
                    integer strtMonth=contractStartDate.month();
                    integer endMonth=contractEndDate.month();
                    //Put Logic for adding wasa from additives field in 3rd party Object
                    if(bav.Third_Party__c){
                        if((strtMonth== 11 || strtMonth== 12 || strtMonth== 1 || strtMonth==2)

                          ){
                             // string salesOrgRouteName=mrcNoMap.get(key).Sales_Organization__c+'_'+bav.Name;

                              if(GradeLocationthirdPartyWasaCost.containsKey(salesOrgRouteName)
                                 && GradeLocationthirdPartyWasaCost.get(salesOrgRouteName).Additive_surcharge__c != null){
                                     wasa=GradeLocationthirdPartyWasaCost.get(salesOrgRouteName).Additive_surcharge__c;

                                 }
                          }
                    }else{
                         //wasa logic added for date range falling between start and end month of contract --To Be Checked
                        if((strtMonth== 11 || strtMonth== 12 || strtMonth== 1 || strtMonth==2)

                          ){
                               wasa = materialNoCostMap.get((mrcNoMap.get(key).Product__r.Name)).WASA_EUR_100l__c;
                              //Converting to Euro/CBM
								wasa=wasa*10;
                           }
                    }

                        if(materialNoCostMap.containsKey((mrcNoMap.get(key).Product__r.Name)) &&
                           materialNoCostMap.get((mrcNoMap.get(key).Product__r.Name)).Total_Additive_cost_EUR_100l__c != null ){
                               additives = materialNoCostMap.get((mrcNoMap.get(key).Product__r.Name)).Total_Additive_cost_EUR_100l__c;
                           }
                    //Conversion of wasa and additives

                     decimal agoIgoCon=Decimal.valueOf(Label.Conversion_Euro_100L_AGO_IGO);
           			 decimal mogasCon=Decimal.valueOf(Label.Conversion_Euro_100L_MOGAS);

                    if(additives != null){
                        if(standardGrade=='ULG95 E5'){
                            additives=additives*mogasCon;
                        }else{
                            additives=additives*agoIgoCon;
                        }
                    }

                    //Converting to Euro/ton
                    if(wasa != null){
                        if(standardGrade=='ULG95 E5'){
                            wasa=wasa/densityMogas;
                        }else{
                            wasa=wasa/densityagoIgo;
                        }
                    }


                    if(freight== null){
                        freight=0;
                    }
                    decimal bavValue=0;
                    decimal landedBAMVValue=0;
                    if(bav.Route_Utilization__c !=null){
                        landedBAMVValue=coStr+freight+hcv+bioAmv+additives+wasa;
                        bavValue=bav.Route_Utilization__c*landedBAMVValue;
                        if(bavValue != 0){
                            bavValue=bavValue/100;
                        }
                        else{
                            bavValue=0;
                        }
                    //system.debug(bav.Destination_Code__c+'has bioAmv==>'+bioAmv);
                    //system.debug(bav.Source__c+'has bioAmv==>');
                    //system.debug('coStr'+coStr+'freight==>'
                    //                 +freight+'bioAmv==>'+bioAmv+'wasa==>'+wasa+
                    //                 'hcv==>'+hcv+'additives==>'+additives +'bavValue'+bavValue);
                    }
                   //Assigning all values in Backbone Amv Audit wrapper
                   bakBonAMVwrp.mrcNo=key;
                   //bakBonAMVwrp.routeName=bav.Name;
                   bakBonAMVwrp.routeName=bav.Backbone_Route_Name__c;//Fix_493485_Lakshmi_27Apr2020
                   bakBonAMVwrp.routeUtilizationPercent=bav.Route_Utilization__c;
                   bakBonAMVwrp.hcv=hcv;
                   bakBonAMVwrp.coSteer=coStr;
                   bakBonAMVwrp.freightPercentage=bav.Freight_Percentage__c;
                   bakBonAMVwrp.freightQuoteValue=bav.Marker__c;
                   bakBonAMVwrp.freightToSource=freightToSource;
                   bakBonAMVwrp.freightToDepot=freightToDepot;
                   bakBonAMVwrp.freight=freight;
                   bakBonAMVwrp.bioCost=bioAmv;
                   bakBonAMVwrp.thirdParty=bav.Third_Party__c;
                   bakBonAMVwrp.bioSplit=bav.Bio_Split__c;
                   bakBonAMVwrp.additiveCost=additives;
                   bakBonAMVwrp.wasa=wasa;
                   bakBonAMVwrp.landedBAMVvalue=landedBAMVValue;
                   bakBonAMVwrp.finalBAMVvalue=bavValue;
                   //FIX_PBI_281711_Lakshmi_26thJune2019_Starts
                   bakBonAMVwrp.source=bav.Source__c;
                   //FIX_PBI_281711_Lakshmi_26thJune2019_Ends
                   //Additional Fix:FIX_PBI_281711_Lakshmi_Starts
                   bakBonAMVwrp.Depot=bav.Destination__c;
                   bakBonAMVwrp.supplier = bav.Supplier__c;//Added by Dhriti
                   bakBonAMVwrp.mot=bav.Mode_Of_Transport__c;//FIX_PBI_471288_Lakshmi_20Apr20
                   bakBonAMVwrp.tranche = tranche;  //Rahul Sharma | Date: 25-Nov-2020 : Added tranche parameter.
                   bakBonAMVwrpLst.add(bakBonAMVwrp);


                  //Adding all backbone AMV for same destination and product
                    finalBavval=finalBavval+bavValue;

                }
            }
            mrcNoLandedCostMap.put(key,finalBavval);
        }



       //Adding all the backbone amv Components in wrapper for audit of price calculation
       //Creating Map of MRC and Backbone Amv price Wrapper
        Map<string,List<backboneAMVpriceCompWrap>> mrcBkBonAmvWrpMap= new Map<string,List<backboneAMVpriceCompWrap>>();
        for(integer i=0;i<bakBonAMVwrpLst.size();i++){
            if(mrcBkBonAmvWrpMap.containsKey(bakBonAMVwrpLst[i].mrcNo)){
                List<backboneAMVpriceCompWrap> bavPrcWrpLst=mrcBkBonAmvWrpMap.get(bakBonAMVwrpLst[i].mrcNo);
                bavPrcWrpLst.add(bakBonAMVwrpLst[i]);
                mrcBkBonAmvWrpMap.put(bakBonAMVwrpLst[i].mrcNo,bavPrcWrpLst);
            }
            else{
                mrcBkBonAmvWrpMap.put(bakBonAMVwrpLst[i].mrcNo, new List<backboneAMVpriceCompWrap> {bakBonAMVwrpLst[i]});
            }
        }

        //Get Throughput,Min Margin
        Map<String,Throughput__c> plantMatThptMap=getThroughput(plantGradeThptSet);

        //Get Gov Fees
        Map<String,Decimal> govFeesMap=getGovFees();
        //get IWO Member from Account
        Map<Id,Boolean> IWOMemberMap=getIWOMember(acntIdSet);

        //Deal Event Manager metadata
        Map<String,Deal_Event_Manager__mdt> poTypeHandlingDealMdtMap = RV_SHT_CreateController.getDealEventMetdataMap();

        //Get Target Margin which is Sales Margin + Min Margin based on Contract Start Date
        //START - Rahul Sharma | Date: 12-Jun-2020 : Updated logic to get Sales and Min Margins based on tranches.
        Boolean commonMargin = false;   //If true, the Margin record is independant of tranches and applied for all tranches.
        Map<String, Map<String,marginWrap>> trancheVsTargtMarginWrapMap = getTargetMargin(salesOrgPlantCodeMotSet,contractStartDate);
        Map<String,marginWrap> plantGradeMotTargetMarginMap = new Map<String,marginWrap>();
        if(trancheVsTargtMarginWrapMap.containsKey(tranche))
            plantGradeMotTargetMarginMap = trancheVsTargtMarginWrapMap.get(tranche);
        else if(trancheVsTargtMarginWrapMap.containsKey('')){
            commonMargin = true;
            plantGradeMotTargetMarginMap = trancheVsTargtMarginWrapMap.get('');
        }
        //END - Rahul Sharma | Date: 12-Jun-2020 : Updated logic to get Sales and Min Margins based on tranches.

        //Wrapper List initialization For Price audt wrap
        List<priceAuditWrap> prcAdtWrplst= new  List<priceAuditWrap>();
        //Calculate final Sales Price for each MRC
        for(string mrcno :mrcNoLandedCostMap.keySet()){
            decimal totalLandedCostEuro100L=0;
            decimal totalLandedCostEuroMt=0;
            decimal landedcostEuroMt=0;
            decimal depotMargin=0;
            if(mrcNoLandedCostMap.containsKey(mrcno)  && mrcNoLandedCostMap.get(mrcno) != null)
                landedcostEuroMt=mrcNoLandedCostMap.get(mrcno);
            string standardGrade=MapOfProductMapping.get(mrcNoMap.get(mrcno).Material_Description__c);
            string key=mrcNoMap.get(mrcno).Plant_Code__c+standardGrade;
            //Grade

            if(mrcNoMap.containsKey(mrcno) && mrcNoMap.get(mrcno).Shipping_Condition__c != null && shippingCondMap.containskey(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c))){
                if(depotSteerMap.containsKey(key+(shippingCondMap.get(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c))).MOT__c) &&
                   depotSteerMap.get(key+(shippingCondMap.get(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c))).MOT__c) != null)
                    depotMargin=depotSteerMap.get(key+(shippingCondMap.get(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c))).MOT__c);

            }

            //Total Landed Cost in EURO/MT
            totalLandedCostEuroMt=landedcostEuroMt+depotMargin;


            string plantcode=mrcNoMap.get(mrcno).Plant_Code__c;

            string mot ='';
            if(shippingCondMap.containskey(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c)))
            	 mot=shippingCondMap.get(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c)).MOT__c;
            string SalesOrg=mrcNoMap.get(mrcno).Sales_Organization__c;
            string grade=MapOfProductMapping.get(mrcNoMap.get(mrcno).Material_Description__c);
            string subgrade=mrcNoMap.get(mrcno).Material_Description__c;
            decimal costWithThrpt;

            //Conversion For Euro/MT to Euro/100L
            decimal agoIgoCon=Decimal.valueOf(Label.Conversion_Euro_100L_AGO_IGO);
            decimal mogasCon=Decimal.valueOf(Label.Conversion_Euro_100L_MOGAS);
            //Total Landed Cost Converted into Euro/100L
            if(standardGrade=='ULG95 E5'){
                totalLandedCostEuro100L=totalLandedCostEuroMt/mogasCon;
            }else{
                totalLandedCostEuro100L=totalLandedCostEuroMt/agoIgoCon;
            }


            //Addition of Throughput Cost on total Landed Cost, If applicable
            costWithThrpt=totalLandedCostEuro100L;
            decimal thrptCost=0;
            string applyThrpt='No';
            string thptKey='';
            if(mot=='Barge' || mot=='Rail'){
                 thptKey=plantcode+subgrade+mot;
            }else{
                 thptKey=plantcode+grade+mot;
            }



            if(plantMatThptMap.containsKey(thptKey)){
                if(plantMatThptMap.get(thptKey).Apply_Throughput__c =='Yes'){
                    applyThrpt = 'Yes';
                    if(plantMatThptMap.get(thptKey).Throughput_Cost__c != null){
                       thrptCost=plantMatThptMap.get(thptKey).Throughput_Cost__c;
                    }
                    costWithThrpt=costWithThrpt+thrptCost;
                }
            }


            //Addition Of Gov Fees on totallandedcost with throughput fees(if applicable)
            //decimal totalEnergyTax = 0;
            decimal energyFees = 0;
            decimal cso = 0;
            decimal unionFees = 0;
            //decimal CO2=0;// Added By Dhriti PBI-297
            boolean iwoMember = false;
            Decimal co2Surchrge = 0;    //Rahul Sharma | Date - 05-May-2021 | PBI-791775 : New variable for C02 surcharge.

            //Energy Fees
            //Fix_250100_20May2019_Soumyajit starts
            /*if(govFeesMap.containsKey('Energy tax'+SalesOrg+grade)){
               energyFees=govFeesMap.get('Energy tax'+SalesOrg+grade);
            }*/
            String handlingType = mrcNoMap.get(mrcno).Handling_Type__c;
            if(handlingType==null)
                handlingType = 'Others';
            //START - Rahul Sharma | Date - 05-May-2021 | PBI-791775 : Combined logic to apply energy fee to utilize the code.
            String poHandling;
            if(mrcNoMap.get(mrcno).PO_Type__c != null && mrcNoMap.get(mrcno).Handling_Type__c != null)
                poHandling = mrcNoMap.get(mrcno).PO_Type__c + mrcNoMap.get(mrcno).Handling_Type__c;
            if(govFeesMap.containsKey('Energy tax' + SalesOrg + grade + handlingType)){
                if(poTypeHandlingDealMdtMap.containsKey(poHandling) && poTypeHandlingDealMdtMap.get(poHandling) != null
                   && poTypeHandlingDealMdtMap.get(poHandling).IsPricingTaxed__c && govFeesMap.get('Energy tax' + SalesOrg + grade + handlingType) != null)
                    energyFees = govFeesMap.get('Energy tax' + SalesOrg + grade + handlingType);
            }
            //END - Rahul Sharma | Date - 05-May-2021 | PBI-791775 : Combined logic to apply energy fee to utilize the code.
            if(mrcMaterialWrapMap.containskey(mrcno)){
                mrcMaterialWrap mrcMat = mrcMaterialWrapMap.get(mrcno);
                //START - Rahul Sharma | Date - 05-May-2021 | PBI - 791775 : Apply CO2 surcharge only if energy fee is applied.
                if(MapOfProductMapping.get(mrcMat.gradeL2) == grade && mrcMat.handlingtype == handlingType && mrcMat.salesOrg == SalesOrg
                   && mrcMat.behgeuro100l != null && energyFees != null && energyFees != 0){
                    if((SalesOrg == 'DE01' && mrcMat.salesOrg == 'DE01') || (SalesOrg == 'AT01' && mrcMat.salesOrg == 'AT01')){
                        //CO2 = mrcMat.behgeuro100l;

                        if(contractStartDate  >= mrcMat.currValidFrom && contractEndDate  <=  mrcMat.currValidTo)
                        	co2Surchrge = mrcMat.behgeuro100l;

                        else if(contractStartDate >= mrcMat.FutValidFrom && contractEndDate <=  mrcMat.FutValidTo)
                        	co2Surchrge = mrcMat.futurebehgeuro100l;

                        else if(contractStartDate  >= mrcMat.currValidFrom){
                            if(contractEndDate >= mrcMat.FutValidFrom){
                                Integer daysbetweenCurr = contractStartDate.daysBetween(mrcMat.currValidTo) +1;
                                Integer daysbetweenFuture = mrcMat.FutValidFrom.daysBetween(contractEndDate) +1;
                                //PBI_702588 Sampada - calculation daysbetween start & end date
                                Integer daysbetweenStartAndEnd =contractStartDate.daysBetween(contractEndDate)+1;
                                co2Surchrge = ((daysbetweenCurr*mrcMat.behgeuro100l) + (daysbetweenFuture*mrcMat.futurebehgeuro100l))/daysbetweenStartAndEnd;
                            }
                        }
                    }
                }
                //END - Rahul Sharma | Date - 05-May-2021 | PBI - 791775 : Apply CO2 surcharge only if energy fee is applied.
            }
            //if(govFeesMap.containsKey('CO2'+SalesOrg+grade+handlingType))// Added By Dhriti PBI-297
                //CO2=govFeesMap.get('CO2'+SalesOrg+grade+handlingType);

            //System.debug('Got EnergyTax for SalesOrg=' + SalesOrg + ', grade=' + grade + ', handlingType=' + handlingType + ' as energyFees=' + energyFees);
            //Fix_250100_20May2019_Soumyajit ends

            //CSO
            if(govFeesMap.containsKey('CSO'+SalesOrg+grade)){
              cso=govFeesMap.get('CSO'+SalesOrg+grade);
            }

            //If IWO member add the Union fee/IWO
            if(IWOMemberMap.containsKey(mrcNoMap.get(mrcno).Sold_To__c)){
                iwoMember=IWOMemberMap.get(mrcNoMap.get(mrcno).Sold_To__c);
                if(!iwoMember){
                    if(govFeesMap.get('Union fee'+SalesOrg+grade) != null){
                        unionFees = govFeesMap.get('Union fee'+SalesOrg+grade);
                    }
                }
            }
            //total Tax
            Decimal totalTax = energyFees + unionFees + co2Surchrge;
            //CO2 Surcharge
            //decimal finalCO2 = 0;// Added By Dhriti PBI-297
            //START - Rahul Sharma | Date - 05-May-2021 : Reduced redundant variable assignment.
            /*if(totalTax!= null && totalTax!=0){// Added By Dhriti PBI-297
            if(energyFees != null && energyFees != 0)
                finalCO2 = CO2;
            totalTax = totalTax + CO2;*/
            //END - Rahul Sharma | Date - 05-May-2021 : Reduced redundant variable assignment.
            //BSP included with throughput and taxes
            decimal BSP = costWithThrpt + cso + totalTax;// Added By Dhriti PBI-297

            //After BSP to be added for MSP
           // Sales Org +Plant Code + Grade + Margin Type

           decimal minMargin=0;
           decimal MarginMM=0;
           decimal salesMargin=0;
           decimal fixedSurcharge=0;
           string shippingCondition = '';
           decimal nightSurcharge = 0;
           decimal customerSpecificPrice = 0;
           if(shippingCondMap.containskey(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c)))
            shippingCondition=shippingCondMap.get(Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c)).Margin_Type__c;
			string motKey;
            if(shippingCondition=='TRUCK/ITT'){
                 motKey=mrcNoMap.get(mrcno).Sales_Organization__c+
                      mrcNoMap.get(mrcno).Plant_Code__c+
                      marginGradeMap.get(mrcNoMap.get(mrcno).Material_Description__c)+
                      shippingCondition;
            }else{
            motKey=mrcNoMap.get(mrcno).Sales_Organization__c+
                      mrcNoMap.get(mrcno).Plant_Code__c+
                      mrcNoMap.get(mrcno).Material_Description__c+
                      shippingCondition;
            }



            if(plantGradeMotTargetMarginMap.containsKey(motKey)){
                //put logic for massive means and truck itt based on usage
                if(shippingCondition=='TRUCK/ITT'){
                    if((plantGradeMotTargetMarginMap.get(motKey)).subGrade !='GTL B0'){
                        //START - Rahul Sharma | Date-6-Feb-2020 : Adding night surcharge for IGO, AGO B7, ULG95
                        Time nsStartTime;
                        Time nsEndTime;
                        DateTime currentDateTime = DateTime.now();
                        Time currentTime = currentDateTime.time();
                        //START - Rahul Sharma | Date-12-Jun-2020 : Updated logic to apply night surcharges only from Tranche1 Margin record
                        if(tranche == 'ATP1' || commonMargin == true){
                            nsStartTime = plantGradeMotTargetMarginMap.get(motKey).nightSurchargeStartTime;
                            nsEndTime = plantGradeMotTargetMarginMap.get(motKey).nightSurchargeEndTime;
                            if(currentTime >= nsStartTime && currentTime < nsEndTime)
                                nightSurcharge = plantGradeMotTargetMarginMap.get(motKey).nightSurcharge != null ? plantGradeMotTargetMarginMap.get(motKey).nightSurcharge : 0;
                        //END - Rahul Sharma | Date-6-Feb-2020 : Adding night surcharge for IGO, AGO B7, ULG95
                        }
                        else{
                            //Apply night surcharges from Tranche1 Margin record in case of deal is confirmed for Tranche2 and Tranche3
                            Map<String,marginWrap> plantGradeMotTargetMarginTranche1Map = new Map<String,marginWrap>();
                            if(trancheVsTargtMarginWrapMap.containsKey('ATP1')){
                                plantGradeMotTargetMarginTranche1Map = trancheVsTargtMarginWrapMap.get('ATP1');
                                if(plantGradeMotTargetMarginTranche1Map.containsKey(motKey)){
                                    nsStartTime = plantGradeMotTargetMarginTranche1Map.get(motKey).nightSurchargeStartTime;
                                    nsEndTime = plantGradeMotTargetMarginTranche1Map.get(motKey).nightSurchargeEndTime;
                                    if(currentTime >= nsStartTime && currentTime < nsEndTime)
                                        nightSurcharge = plantGradeMotTargetMarginTranche1Map.get(motKey).nightSurcharge != null ? plantGradeMotTargetMarginTranche1Map.get(motKey).nightSurcharge : 0;
                                }
                            }
                        }
                        //END - Rahul Sharma | Date-12-Jun-2020 : Updated logic to apply night surcharges only from Tranche1 Margin record
                        //System.debug('RV_SPCalculationController >> nsStartTime: '+nsStartTime+' nsEndTime: '+nsEndTime+' currentTime: '+currentTime);
                        if(plantGradeMotTargetMarginMap.get(motKey).minMargin != null)
                            minMargin= plantGradeMotTargetMarginMap.get(motKey).minMargin;
                        if(plantGradeMotTargetMarginMap.get(motKey).salesMargin != null)
                            salesMargin= plantGradeMotTargetMarginMap.get(motKey).salesMargin;
                    }
                    else{
                        if(plantGradeMotTargetMarginMap.containsKey(motKey) &&
                           plantGradeMotTargetMarginMap.get(motKey).fixedSurcharge != null)
                            minMargin= plantGradeMotTargetMarginMap.get(motKey).fixedSurcharge;
                        	salesMargin=0;
                    }
                }else{

                    if(plantGradeMotTargetMarginMap.containsKey(motKey) &&
                       plantGradeMotTargetMarginMap.get(motKey).salesMargin != null)
                        MarginMM=plantGradeMotTargetMarginMap.get(motKey).salesMargin;
                }

            }

            //Code to be changed as per new magin and fixed surcharge logic
            decimal MSP=0;
            decimal OTM=0;
            decimal targetMargin=minMargin+salesMargin;
            if(shippingCondition=='TRUCK/ITT'){
                MSP = BSP + minMargin;
                OTM = BSP + minMargin + salesMargin + nightSurcharge;
            //System.debug('RV_SPCalculationController >> getCalulatedSp >> MRC: '+mrcno+' BSP: '+BSP+' minMargin: '+minMargin+ ' PSP: '+MSP+' salesMargin: '+salesMargin+' nightSurcharge: '+nightSurcharge+ ' OTM: '+OTM);
            }else{
                MSP=BSP+MarginMM;
                OTM=BSP+MarginMM;
            }

            //START - Rahul Sharma | Date - 17-Feb-2020 : Adding Customer Specific Pricing to OTM when called from OLF
            if(!cspKeyVsObjectMap.isEmpty()){
                String cspKey = mrcNoMap.get(mrcno).Sales_Organization__c + mrcNoMap.get(mrcno).Sold_To__c
                                + mrcNoMap.get(mrcno).Plant_Code__c+ marginGradeMap.get(mrcNoMap.get(mrcno).Material_Description__c);
                //System.debug('RV_SPCalculationController >> getCalulatedSp >> cspKey: '+cspKey);
                if(cspKeyVsObjectMap.containsKey(cspKey)){
                    customerSpecificPrice = cspKeyVsObjectMap.get(cspKey).CSP_Eur_100L__c;
                    OTM += customerSpecificPrice != null ? customerSpecificPrice : 0;
                    //System.debug('RV_SPCalculationController >> getCalulatedSp >> OTM after CSP: '+OTM);
                }
            }
            //END - Rahul Sharma | Date - 17-Feb-2020 : Adding Customer Specific Pricing to OTM when called from OLF

            //Fix_394298_10Jan2020_Soumyajit starts
            decimal marketingCostEur100l=0;
            if(materialNoCostMap.containsKey((mrcNoMap.get(mrcno).Product__r.Name))
              && materialNoCostMap.get((mrcNoMap.get(mrcno).Product__r.Name)).Marketing_Cost__c != null
              && isOlfDeal)
            {
                marketingCostEur100l = materialNoCostMap.get((mrcNoMap.get(mrcno).Product__r.Name)).Marketing_Cost__c;
                //System.debug('========>OTM without marketingCost = ' + OTM);
                OTM = OTM + marketingCostEur100l;
                //System.debug('========>marketingCost = ' + marketingCostEur100l + ', OTM = ' + OTM);
            }
            //Fix_394298_10Jan2020_Soumyajit ends
            //START - Rahul Sharma | Date - 05-May-2021 : Utilizing code by commenting the logic and moving above.
            /*String poHandling;
            if(mrcNoMap.get(mrcno).PO_Type__c != null && mrcNoMap.get(mrcno).Handling_Type__c != null){
                poHandling=mrcNoMap.get(mrcno).PO_Type__c+mrcNoMap.get(mrcno).Handling_Type__c;
            }*/
            //END - Rahul Sharma | Date - 05-May-2021 : Utilizing code by commenting the logic and moving above.

            //Creating sales Price wrap to be returned Finally on UI
            salesPriceWrap spwrp= new salesPriceWrap();
            spwrp.mrcNo=mrcno;
            spwrp.landedCost=totalLandedCostEuro100L;
            //START - Rahul Sharma | Date - 05-May-2021 | PBI-791775, PBI-791773 : Commenting the logic to substract totalTax from BSP, MSP & OTM.
            /*if(poTypeHandlingDealMdtMap.containsKey(poHandling) && poTypeHandlingDealMdtMap.get(poHandling) != null &&
               poTypeHandlingDealMdtMap.get(poHandling).IsPricingTaxed__c ){

                   spwrp.BSP=BSP;
                   spwrp.MSP=MSP;
                   spwrp.OTM=OTM; //Fix_OTMtaxed_17Jun2019_Soumyajit
               }else{

                   spwrp.BSP=BSP-totalTax;
                   spwrp.MSP=MSP-totalTax;
                   spwrp.OTM=OTM-totalTax; //Fix_OTMtaxed_17Jun2019_Soumyajit
               }*/
            spwrp.BSP = BSP;
            spwrp.MSP = MSP;
            spwrp.OTM = OTM;
            //END - Rahul Sharma | Date - 05-May-2021 | PBI-791775, PBI-791773 : Commenting the logic to substract totalTax from BSP, MSP & OTM.
            spwrp.totalTax = totalTax;
            //spwrp.OTM=OTM; //Fix_OTMtaxed_17Jun2019_Soumyajit
            spwrp.tranche = tranche;    //Rahul Sharma | Date - 08-Mar-2021 : Added tranche value.
            spWrapLst.add(spwrp);



            //adding wrapper values for audit of Price and to be inserted in other Object
            priceAuditWrap paWrp = new priceAuditWrap();
            paWrp.mrcNo=mrcno;
            paWrp.locationId = mrcNoMap.get(mrcno).Plant__c;//Added By Dhriti;PBI-235351
            paWrp.salesOrg=mrcNoMap.get(mrcno).Sales_Organization__c;
            paWrp.shippingCond=Integer.valueOf(mrcNoMap.get(mrcno).Shipping_Condition__c);
            paWrp.materialId=mrcNoMap.get(mrcno).Product__c;
            paWrp.landedCostEuroMt=landedcostEuroMt;
            paWrp.depotSteer=depotMargin;
            paWrp.finalAMVEuroMt=totalLandedCostEuroMt;
            paWrp.finalAMVEuro100L=totalLandedCostEuro100L;
            paWrp.applyThroughput=applyThrpt;
            paWrp.throughputCost=thrptCost;
            paWrp.iwoMember=iwoMember;
            paWrp.salesMargin=salesMargin;
            paWrp.minMargin=minMargin;
            paWrp.nightSurcharges=nightSurcharge;  //Rahul Sharma | Date - 06-Feb-2020 : Added night surcharge for audit
            paWrp.customerSpecificPrice = customerSpecificPrice;   //Rahul Sharma | Date - 17-Feb-2020 : Added customer specific pricing for audit
            paWrp.otm = OTM;   //Rahul Sharma | Date - 20-Feb-2020 : Added OTM price for audit
            paWrp.calculatedBSP=spwrp.BSP;
            paWrp.calculatedMSP=spwrp.MSP;
            paWrp.cso=cso;
            //paWrp.CO2=finalCO2;// Added By Dhriti PBI-297
            paWrp.CO2 = co2Surchrge;   //Rahul Sharma | Date - 05-May-2021 : new variable assignment for CO2 surcharge.
            pawrp.marketingCost = marketingCostEur100l;	//Fix_394298_10Jan2020_Soumyajit
            pawrp.tranche = tranche;   //Rahul Sharma | Date: 25-Nov-2020 : Added tranche parameter.
            /*START - Rahul Sharma | Date - 05-May-2021 | PBI-791775, PBI-791773 : Updated logic to exclude union fee dependancy on IsPricingTaxed__c field.
                                                                       Also moved the condtion above to utilize the code.*/
            /*if(poTypeHandlingDealMdtMap.containsKey(poHandling) && poTypeHandlingDealMdtMap.get(poHandling) != null &&
               poTypeHandlingDealMdtMap.get(poHandling).IsPricingTaxed__c ){
                   paWrp.energyFees=energyFees;

                   //paWrp.unionFees=unionFees;
               }else{
                   paWrp.energyFees=0;

                   //paWrp.unionFees=0;
               }*/
            paWrp.energyFees = energyFees;
            paWrp.unionFees = unionFees;
            /*END - Rahul Sharma | Date - 05-May-2021 | PBI-791775, PBI-791773 : Updated logic to exclude union fee dependancy on IsPricingTaxed__c field.
                                                                       Also moved the condtion above to utilize the code.*/
            paWrp.bavWrp=mrcBkBonAmvWrpMap.get(mrcno);
            prcAdtWrplst.add(paWrp);

        }

        spCalPrcAdtWrp.salesPriceWrpLst=spWrapLst;
        spCalPrcAdtWrp.auditWrpLst=prcAdtWrplst;
        //system.debug('audit salesPriceWrpLst==>'+spWrapLst);
        //system.debug('audit auditWrpLst==>'+prcAdtWrplst);
        return spCalPrcAdtWrp;

    }
    //Method to get Cp Margin and Sales Margin
    public static Map<String, Map<String,marginWrap>> getTargetMargin(Set<String> salesOrgPlantCodeMotSet,date contractStartDate){

        Map<String,marginWrap> trgtMarginWrapMap= new Map<String,marginWrap>();
        Map<String, Map<String, marginWrap>> trancheVsTargtMarginWrapMap = new Map<String, Map<String, marginWrap>>();
        List<Margin__c> finalMgnLst= new List<Margin__c>();
        List<Margin__c> marginLst=[SELECT Default__c,
                                          Id,MarginKey__c,
                                          Margin_Type__c,
                                          Min_Mgn_AGO_B7__c,
                                          Min_Mgn_IGO_50ppm__c,
                                          Min_Mgn_ULG95_E5__c,
				   	  Min_Mgn_GTL_B7__c,
                                          Name,
                                          Plant_Code__c,
                                          Plant__c,
                                          Sales_Mgn_AGO_B7__c,
                                          Sales_Mgn_IGO_50ppm__c,
                                          Sales_Mgn_ULG95_E5__c,
				   	  Sales_Mgn_GTL_B7__c,
                                          Sales_Org__c,
                                          Target_Mgn_AGO_B7__c,
                                          Target_Mgn_IGO_50ppm__c,
                                          Fixed_Surcharge_GTL_B0__c,
                                          Target_Mgn_ULG95_E5__c,
				   	  Target_Mgn_GTL_B7__c,
                                          AGO_B0_Sales_Margin__c,
                                          AGO_B7_Sales_Margin__c,
                                          AGO_CH_Sales_Margin__c,
                                          IGO_1000_Sales_Margin__c,
                                          IGO_50_Sales_Margin__c,
                                          MOGAS_98_Sales_Margin__c,
                                          MOGAS_BOB10_Sales_Margin__c,
                                          MOGAS_BOB5_Sales_Margin__c,
                                          MOGAS_E0_Sales_Margin__c,
                                          RecordTypeId,
                                          Valid_From__c,
                                          Valid_To__c,
				  	  Night_Surcharges_GTL_B7__c,
                                          Night_Surcharges_IGO_ppm_Eur_100L__c,
                                          Night_Surcharges_AGO_B7_Eur_100L__c,
                                          Night_Surcharges_ULG95_E5_Eur_100L__c,
                                          Night_Surcharge_Start_Time__c,
                                          Night_Surcharge_End_Time__c,
                                          Tranche__c FROM Margin__c WHERE SalesOrgPlantCodeMot__c IN :salesOrgPlantCodeMotSet AND
                                                                          Valid_From__c<= :contractStartDate AND
                                                                          Valid_To__c >=:contractStartDate ORDER BY SalesOrgPlantCodeMot__c,
                                                                                                                    Valid_From__c ASC];


        //Filtering the list to find out valid for the particulat contract date
        //Plant Code+Sales Org + Margin Type
        Map<String,List<Margin__c>> plantSalesOrgMotMap= new Map<String,List<Margin__c>>();
        for(integer i=0;i<marginLst.size();i++){
            //START - Rahul Sharma | Date: 12-Jun-2020 : Updated logic to include tranche on Margin
            String tranche = marginLst[i].Tranche__c != null ? marginLst[i].Tranche__c : '';
            string UniqueKey=marginLst[i].Plant_Code__c+marginLst[i].Sales_Org__c+marginLst[i].Margin_Type__c+tranche;
            //END - Rahul Sharma | Date: 12-Jun-2020 : Updated logic to include tranche on Margin
            if(plantSalesOrgMotMap.containsKey(UniqueKey)){
                List<Margin__c> mgnlst= plantSalesOrgMotMap.get(UniqueKey);
                mgnlst.add(marginLst[i]);
                plantSalesOrgMotMap.put(UniqueKey,mgnlst);
            }
            else{
                plantSalesOrgMotMap.put(UniqueKey,new List<Margin__c> {marginLst[i]});
            }
        }
        for(string key:plantSalesOrgMotMap.keySet()){
            if((plantSalesOrgMotMap.get(key)).size()>1){
                Margin__c mgn;
                if(((plantSalesOrgMotMap.get(key)).get(0)).Default__c){
                    mgn=(plantSalesOrgMotMap.get(key)).get(1);
                }
                else{
                    mgn=(plantSalesOrgMotMap.get(key)).get(0);
                }
                finalMgnLst.add(mgn);
            }
            else{
                Margin__c mgn=(plantSalesOrgMotMap.get(key)).get(0);
                finalMgnLst.add(mgn);
            }
        }

        List<marginWrap> mgnWrpLst= new list<marginWrap>();
        // Sales Org +Plant Code + Grade + Margin Type
        for(Margin__c mgn :finalMgnLst){
            String tranche = mgn.Tranche__c != null ? mgn.Tranche__c : '';  //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
            if(mgn.Margin_Type__c =='TRUCK/ITT'){
                //AGO B7 Margin
                marginWrap mgnWrp= new marginWrap();
                mgnWrp.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'AGO B7'+mgn.Margin_Type__c;
                mgnWrp.subGrade='AGO B7';
                mgnWrp.salesMargin=mgn.Sales_Mgn_AGO_B7__c;
                mgnWrp.minMargin=mgn.Min_Mgn_AGO_B7__c;
                mgnWrp.nightSurcharge=mgn.Night_Surcharges_AGO_B7_Eur_100L__c;
                mgnWrp.nightSurchargeStartTime=mgn.Night_Surcharge_Start_Time__c;
                mgnWrp.nightSurchargeEndTime=mgn.Night_Surcharge_End_Time__c;
                mgnWrp.tranche = tranche;   //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrp);

                //IGO 50ppm Margin
                marginWrap mgnIGOWrp= new marginWrap();
                mgnIGOWrp.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'IGO 50ppm'+mgn.Margin_Type__c;
                mgnIGOWrp.subGrade='IGO 50ppm';
                mgnIGOWrp.salesMargin=mgn.Sales_Mgn_IGO_50ppm__c;
                mgnIGOWrp.minMargin=mgn.Min_Mgn_IGO_50ppm__c;
                mgnIGOWrp.nightSurcharge=mgn.Night_Surcharges_IGO_ppm_Eur_100L__c;
                mgnIGOWrp.nightSurchargeStartTime=mgn.Night_Surcharge_Start_Time__c;
                mgnIGOWrp.nightSurchargeEndTime=mgn.Night_Surcharge_End_Time__c;
                mgnIGOWrp.tranche = tranche;    //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnIGOWrp);

		//added by Swarna as part of PBI-1659161 --> GTL B7 Margin
                marginWrap mgnGTLB7Wrp= new marginWrap();
                mgnGTLB7Wrp.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+gtl_b7+mgn.Margin_Type__c;
                mgnGTLB7Wrp.subGrade=gtl_b7;
                mgnGTLB7Wrp.salesMargin=mgn.Sales_Mgn_GTL_B7__c;
                mgnGTLB7Wrp.minMargin=mgn.Min_Mgn_GTL_B7__c;
                mgnGTLB7Wrp.nightSurcharge=mgn.Night_Surcharges_GTL_B7__c;
                mgnGTLB7Wrp.nightSurchargeStartTime=mgn.Night_Surcharge_Start_Time__c;
                mgnGTLB7Wrp.nightSurchargeEndTime=mgn.Night_Surcharge_End_Time__c;
                mgnGTLB7Wrp.tranche = tranche;
                mgnWrpLst.add(mgnGTLB7Wrp);
                //end

                //ULG95 E5 Margin
                marginWrap mgnULGWrp= new marginWrap();
                mgnULGWrp.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'ULG95 E5'+mgn.Margin_Type__c;
                mgnULGWrp.subGrade='ULG95 E5';
                mgnULGWrp.salesMargin=mgn.Sales_Mgn_ULG95_E5__c;
                mgnULGWrp.minMargin=mgn.Min_Mgn_ULG95_E5__c;
                mgnULGWrp.nightSurcharge=mgn.Night_Surcharges_ULG95_E5_Eur_100L__c;
                mgnULGWrp.nightSurchargeStartTime=mgn.Night_Surcharge_Start_Time__c;
                mgnULGWrp.nightSurchargeEndTime=mgn.Night_Surcharge_End_Time__c;
                mgnULGWrp.tranche =tranche; //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnULGWrp);

                //GTL B0 Fixed Surcharge
                marginWrap mgnGTLWrp= new marginWrap();
                mgnGTLWrp.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'GTL B0'+mgn.Margin_Type__c;
                mgnGTLWrp.subGrade='GTL B0';
                mgnGTLWrp.fixedSurcharge=mgn.Fixed_Surcharge_GTL_B0__c;
                mgnGTLWrp.tranche = tranche;    //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnGTLWrp);

            }
            else{
                //MOGAS-E0
                marginWrap mgnWrp= new marginWrap();
                mgnWrp.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'ULG95 E0'+mgn.Margin_Type__c;
                mgnWrp.subGrade='ULG95 E0';
                mgnWrp.salesMargin=mgn.MOGAS_E0_Sales_Margin__c;
                mgnWrp.tranche = tranche;   //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrp);

                //MOGAS-BOB5
                marginWrap mgnWrpBob5= new marginWrap();
                mgnWrpBob5.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'ULG95_BOB_E5'+mgn.Margin_Type__c;
                mgnWrpBob5.subGrade='ULG95_BOB_E5';
                mgnWrpBob5.salesMargin=mgn.MOGAS_BOB5_Sales_Margin__c;
                mgnWrpBob5.tranche = tranche;   //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrpBob5);

                //MOGAS-BOB10
                marginWrap mgnWrpBob10= new marginWrap();
                mgnWrpBob10.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'ULG95_BOB_E10'+mgn.Margin_Type__c;
                mgnWrpBob10.subGrade='ULG95_BOB_E10';
                mgnWrpBob10.salesMargin=mgn.MOGAS_BOB10_Sales_Margin__c;
                mgnWrpBob10.tranche = tranche;  //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrpBob10);

                //MOGAS-98
                marginWrap mgnWrp98= new marginWrap();
                mgnWrp98.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'ULG98'+mgn.Margin_Type__c;
                mgnWrp98.subGrade='ULG98';
                mgnWrp98.salesMargin=mgn.MOGAS_98_Sales_Margin__c;
                mgnWrp98.tranche = tranche; //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrp98);

                //AGO-B0
                marginWrap mgnWrpAgoB0= new marginWrap();
                mgnWrpAgoB0.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'AGO B0'+mgn.Margin_Type__c;
                mgnWrpAgoB0.subGrade='AGO B0';
                mgnWrpAgoB0.salesMargin=mgn.AGO_B0_Sales_Margin__c;
                mgnWrpAgoB0.tranche = tranche;  //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrpAgoB0);

                //AGO-CH
                marginWrap mgnWrpAgoCH= new marginWrap();
                mgnWrpAgoCH.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'AGO B0 CH'+mgn.Margin_Type__c;
                mgnWrpAgoCH.subGrade='AGO B0 CH';
                mgnWrpAgoCH.salesMargin=mgn.AGO_CH_Sales_Margin__c;
                mgnWrpAgoCH.tranche = tranche;  //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrpAgoCH);

                //AGO-B7
                marginWrap mgnWrpAgoB7= new marginWrap();
                mgnWrpAgoB7.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'AGO B7'+mgn.Margin_Type__c;
                mgnWrpAgoB7.subGrade='AGO B7';
                mgnWrpAgoB7.salesMargin=mgn.AGO_B7_Sales_Margin__c;
                mgnWrpAgoB7.tranche = tranche;  //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrpAgoB7);

                //IGO-50
                marginWrap mgnWrpIgo50= new marginWrap();
                mgnWrpIgo50.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'IGO 50ppm'+mgn.Margin_Type__c;
                mgnWrpIgo50.subGrade='IGO 50ppm';
                mgnWrpIgo50.salesMargin=mgn.IGO_50_Sales_Margin__c;
                mgnWrpIgo50.tranche = tranche;  //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrpIgo50);

                //IGO-1000
                marginWrap mgnWrpIgo1000= new marginWrap();
                mgnWrpIgo1000.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+'IGO 1000ppm'+mgn.Margin_Type__c;
                mgnWrpIgo1000.subGrade='IGO 1000ppm';
                mgnWrpIgo1000.salesMargin=mgn.IGO_1000_Sales_Margin__c;
                mgnWrpIgo1000.tranche = tranche;    //Rahul Sharma | Date: 12-Jun-2020 : Included tranche for the Margin
                mgnWrpLst.add(mgnWrpIgo1000);

		//adde by Swarna as part of PBI-1659161 --> GTL-B7
                marginWrap mgnWrpGTLB7= new marginWrap();
                mgnWrpGTLB7.salesOrgPlntCodGradeMgnTypeKey=mgn.Sales_Org__c+mgn.Plant_Code__c+gtl_b7+mgn.Margin_Type__c;
                mgnWrpGTLB7.subGrade=gtl_b7;
                mgnWrpGTLB7.salesMargin=mgn.Sales_Mgn_GTL_B7__c;
                mgnWrpGTLB7.tranche = tranche;
                mgnWrpLst.add(mgnWrpGTLB7);


            }


        }
        for(integer i=0;i<mgnWrpLst.size();i++){
        //START - Rahul Sharma | Date: 12-Jun-2020 : Updated logic to get Sales and Min Margins based on tranches.
            if(trancheVsTargtMarginWrapMap.containsKey(mgnWrpLst[i].tranche)){
                Map<String, marginWrap> targetMarginWrapMap = trancheVsTargtMarginWrapMap.get(mgnWrpLst[i].tranche);
                targetMarginWrapMap.put(mgnWrpLst[i].salesOrgPlntCodGradeMgnTypeKey, mgnWrpLst[i]);
                trancheVsTargtMarginWrapMap.put(mgnWrpLst[i].tranche, targetMarginWrapMap);
            }
            else{
                Map<String, marginWrap> targetMarginWrapMap = new Map<String, marginWrap>();
                targetMarginWrapMap.put(mgnWrpLst[i].salesOrgPlntCodGradeMgnTypeKey, mgnWrpLst[i]);
                trancheVsTargtMarginWrapMap.put(mgnWrpLst[i].tranche, targetMarginWrapMap);
            }
        }
        return trancheVsTargtMarginWrapMap;
        //END - Rahul Sharma | Date: 12-Jun-2020 : Updated logic to get Sales and Min Margins based on tranches.
    }
    //Method to Get IWO Member from Account
    public static Map<Id,Boolean> getIWOMember(Set<Id> acntIdSet){
        Map<Id,Boolean> acntMap=new Map<Id,Boolean>();
        List<Account> acntLst= new List<Account>([Select Id,name,IWO_Member__c from account where Id IN:acntIdSet]);
        for(Account acc:acntLst){
            acntMap.put(acc.Id,acc.IWO_Member__c);
        }
        return acntMap;
    }
    //Method to get BIO AMV for 3rd Party
    public static Map<String,Decimal> getThirdPartySplitBioAmvValue(List<Third_Party_Contract_Master__c> thirdpartyLst,
                                                                    Set<String >plantGrade3rdBioAMVSet,
                                                                    Map<String,Decimal> mapOFQuotesAndValues,
                                                                    date contractStartDate,date contractEndDate
                                                                   ,Map<string,RV_SHT_Calculation_Util.ReturnWrap> plantGradeHCVMap //Fix_1709686_Soumyajit_24May2019
                                                                   ){
        List<Third_Party_Contract_Master__c> thirdPartyNewLst= new List<Third_Party_Contract_Master__c>();
        Map<String,List<Third_Party_Contract_Master__c>> quoteNameThirdPartyMap= new Map<String,List<Third_Party_Contract_Master__c>>();
        Map<String,List<Third_Party_Contract_Master__c>> quoteNameThirdPartyFinalMap= new Map<String,List<Third_Party_Contract_Master__c>>();
        Map<String,Decimal> plantGrade3rdBioAMVMap= new Map<String,Decimal>();

        Map<String,Decimal> plantGrdFinalBioNoQuoteValMap= new Map<String,Decimal>();  //Fix_260836_Soumyajit_22May2019

        for(Third_Party_Contract_Master__c third:thirdpartyLst){
            //AdditionalFix_1709686_Soumyajit_19Jul2019 starts
            //if(plantGrade3rdBioAMVSet.contains(third.Plant_Code__c+third.Grade__c)){

            //FIX_470189_Lakshmi_30Apr2020
            //if(plantGrade3rdBioAMVSet.contains(third.Plant_Code__c+third.Grade__c+third.Supply_Route_ID__c)){
            if(plantGrade3rdBioAMVSet.contains(third.Plant_Code__c+third.Grade__c+third.Supply_Route_ID_Name__c)){
            //AdditionalFix_1709686_Soumyajit_19Jul2019 ends
                thirdPartyNewLst.add(third);
            }
        }

        for(Third_Party_Contract_Master__c third:thirdPartyNewLst){
            //AdditionalFix_1709686_Soumyajit_19Jul2019 starts
            //if(plantGrade3rdBioAMVSet.contains(third.Plant_Code__c+third.Grade__c)){
            //FIX_470189_Lakshmi_30Apr2020
            //if(plantGrade3rdBioAMVSet.contains(third.Plant_Code__c+third.Grade__c+third.Supply_Route_ID__c)){
            if(plantGrade3rdBioAMVSet.contains(third.Plant_Code__c+third.Grade__c+third.Supply_Route_ID_Name__c)){
            //AdditionalFix_1709686_Soumyajit_19Jul2019 ends
                if(quoteNameThirdPartyMap.containsKey(third.Bio_Quotes__c)){
                   List<Third_Party_Contract_Master__c> thirdLst=quoteNameThirdPartyMap.get(third.Bio_Quotes__c);
                   thirdLst.add(third);
                   quoteNameThirdPartyMap.put(third.Bio_Quotes__c,thirdLst);
                }
                else{
                    quoteNameThirdPartyMap.put(third.Bio_Quotes__c,new List<Third_Party_Contract_Master__c> {third});
                }
                //Fix_260836_Soumyajit_22May2019 Starts
                //Surcharge is applicable, even if BioQuote is abscent
                if(third.Bio_Quotes__c == null && third.Bio_surcharge__c!=0 && third.Bio_surcharge__c!= null)
                {
                    decimal finalBio=0;
                    decimal densityMogas=Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);
                    decimal densityagoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
                    //FIX_470189_Lakshmi_30Apr2020
                    //if(third.Supply_Route_ID__c.containsIgnoreCase('MOGAS'))
                    if(third.Supply_Route_ID_Name__c.containsIgnoreCase('MOGAS'))
                        finalBio=third.Bio_surcharge__c/densityMogas;
                    else
                        finalBio=third.Bio_surcharge__c/densityagoIgo;

                    //System.debug('Inside BioSplitNoQuote with Supply_Route_ID__c='+ third.Supply_Route_ID__c +', surcharge='+third.Bio_surcharge__c +', densityagoIgo=' +densityagoIgo+', densityMogas='+densityMogas);
                    //System.debug('Inside BioSplitNoQuote with finalBio='+finalBio);
                    //FIX_470189_Lakshmi_30Apr2020
                    //plantGrdFinalBioNoQuoteValMap.put(third.Plant_Code__c+third.Grade__c+ third.Supply_Route_ID__c,finalBio);
                    plantGrdFinalBioNoQuoteValMap.put(third.Plant_Code__c+third.Grade__c+ third.Supply_Route_ID_Name__c,finalBio);
                }
                //Fix_260836_Soumyajit_22May2019 Ends
            }
        }


        for(string key: quoteNameThirdPartyMap.keySet()){
            List<Third_Party_Contract_Master__c> thrdPrtyLst = quoteNameThirdPartyMap.get(key);
            for(Third_Party_Contract_Master__c third :thrdPrtyLst){

                if(third.Valid_From__c <= contractEndDate ){


                    if(quoteNameThirdPartyFinalMap.containsKey(key)){
                        List<Third_Party_Contract_Master__c> thirdLst=quoteNameThirdPartyFinalMap.get(key);
                        thirdLst.add(third);
                        quoteNameThirdPartyFinalMap.put(key,thirdLst);
                    }
                    else{
                        quoteNameThirdPartyFinalMap.put(key,new List<Third_Party_Contract_Master__c> {third});
                    }
                }
            }
        }



        Map<String,Integer> mapOfQuoteNameAndDays = new Map<String,Integer>();
        Map<String,Decimal> plantGrdBioValLstMap= new Map<String,Decimal>();
        Map<String,Integer> plantGrdNoOfDaysMap= new Map<String,Integer>();
        Map<String,Decimal> plantGrdFinalBioValMap= new Map<String,Decimal>();
        for(String key :quoteNameThirdPartyFinalMap.keySet()){
           List<Third_Party_Contract_Master__c> thrLst=quoteNameThirdPartyFinalMap.get(key);


            for(Third_Party_Contract_Master__c thr:thrLst){

			    Integer noOfDays =0;

                 //Fix_Lakshmi_bug_1stJuly2019_Starts
                //if(thr.Valid_To__c <= contractStartDate || thr.Valid_From__c >= contractEndDate){
                if(thr.Valid_To__c < contractStartDate || thr.Valid_From__c > contractEndDate){

                	 //System.debug('satisfied');
                    continue;
                    //Fix_Lakshmi_bug_1stJuly2019_Ends
                }
                else if(thr.Valid_From__c <= contractStartDate &&  thr.Valid_To__c >= contractEndDate){
                   //contractStartDate to contractEndDate

                   noOfDays=contractStartDate.daysBetween(contractEndDate) + 1;

                }
                else if(thr.Valid_From__c <= contractStartDate && thr.Valid_To__c <= contractEndDate){
                    //ContractStartDate to BioQuoteValidTo

                    noOfDays=contractStartDate.daysBetween(thr.Valid_To__c) + 1;

                }
                else if(thr.Valid_From__c >= contractStartDate && thr.Valid_To__c >= contractEndDate){
                    //BioQuoteValidFrom to contractEndDate

                	 noOfDays=thr.Valid_From__c.daysBetween(contractEndDate) + 1;


                }
                else if(thr.Valid_From__c >= contractStartDate && thr.Valid_To__c <= contractEndDate){
                    //BioQuoteValidFrom to BioQuoteValidTo

                	 noOfDays=thr.Valid_From__c.daysBetween(thr.Valid_To__c) + 1;


                }

                //calculate BioAMV for each date range
                decimal bioQuoteVal=0;
                decimal bioPercent=0;
                decimal surcharge=0;
                decimal bioValue=0;
                if(noOfDays>0){
                    bioQuoteVal = mapOFQuotesAndValues.get(thr.Bio_Quotes__c);
                    bioPercent = thr.Bio_Quote__c;
                    surcharge=0;

                    //Fix_1709686_Soumyajit_24May2019 Starts
                    //Do Bio-HCV
                    if(plantGradeHCVMap.containsKey(thr.GradeLocation__c))
                    	//system.debug('BioSplit-HCV for'+ thr.Supply_Route_ID__c + ' is ' + bioQuoteVal + ' - ' + plantGradeHCVMap.get(thr.GradeLocation__c).finalHCVValue);

                    if(plantGradeHCVMap.containsKey(thr.GradeLocation__c) && (plantGradeHCVMap.get(thr.GradeLocation__c).finalHCVValue != null) && bioQuoteVal !=null)
                    {
                        bioQuoteVal = bioQuoteVal - plantGradeHCVMap.get(thr.GradeLocation__c).finalHCVValue;
                    }
                    //Fix_1709686_Soumyajit_24May2019 Ends

                    if(thr.Bio_surcharge__c !=null){
                        //Conversion For Euro/MT to Euro/100L
                        decimal densityMogas=Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);
                        decimal densityagoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
                        //FIX_470189_Lakshmi_30Apr2020
                        //if(thr.Supply_Route_ID__c.contains('MOGAS')){
                        if(thr.Supply_Route_ID_Name__c.contains('MOGAS')){
                            surcharge=thr.Bio_surcharge__c/densityMogas;
                        }else{
                            surcharge=thr.Bio_surcharge__c/densityagoIgo;
                        }
                    }
                }
                //Fix_260836_Soumyajit_22May2019 Starts
                /*if(bioPercent!= null && bioQuoteVal!=null){
                    bioValue = bioValue + ((((bioPercent * bioQuoteVal)/100) + surcharge) * noOfDays);
                }*/
                if(bioPercent==0 || bioPercent== null)
                    bioQuoteVal=0;

                //System.debug('Inside BioSplit with bioPercent=' + bioPercent + ', bioQuoteVal=' + bioQuoteVal + ', surcharge=' + surcharge + ', noOfDays=' + noOfDays);

                if(bioQuoteVal==0 || bioQuoteVal== null)
                {
                    if(surcharge!=0 || surcharge != null)
                    	bioValue = bioValue + surcharge * noOfDays;
                }
                else
                    bioValue = bioValue + ((((bioPercent * bioQuoteVal)/100) + surcharge) * noOfDays);

                //System.debug('Inside BioSplit with bioValue=' + bioValue);
                //Fix_260836_Soumyajit_22May2019 Ends

                //AdditionalFix_1709686_Soumyajit_19Jul2019 starts
                /*if(plantGrdBioValLstMap.containsKey(thr.Plant_Code__c+thr.Grade__c)){
                    decimal oldBio=plantGrdBioValLstMap.get(thr.Plant_Code__c+thr.Grade__c);
                    bioValue=bioValue+oldBio;
                    plantGrdBioValLstMap.put(thr.Plant_Code__c+thr.Grade__c,bioValue);
                }else{
                    plantGrdBioValLstMap.put(thr.Plant_Code__c+thr.Grade__c,bioValue);
                }

                if(plantGrdNoOfDaysMap.containsKey(thr.Plant_Code__c+thr.Grade__c)){
                    integer olddays=plantGrdNoOfDaysMap.get(thr.Plant_Code__c+thr.Grade__c);
                    noOfDays=noOfDays+olddays;
                    plantGrdNoOfDaysMap.put(thr.Plant_Code__c+thr.Grade__c,noOfDays);
                }else{
                    plantGrdNoOfDaysMap.put(thr.Plant_Code__c+thr.Grade__c,noOfDays);
                }*/

                /*FIX_470189_Lakshmi_30Apr2020_starts
                if(plantGrdBioValLstMap.containsKey(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c)){
                    decimal oldBio=plantGrdBioValLstMap.get(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c);
                    bioValue=bioValue+oldBio;
                    //system.debug('bioValue'+bioValue);
                    plantGrdBioValLstMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c,bioValue);
                }else{
                    plantGrdBioValLstMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c,bioValue);
                }
                 //system.debug('plantGrdBioValLstMap'+plantGrdBioValLstMap);
                if(plantGrdNoOfDaysMap.containsKey(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c)){
                    integer olddays=plantGrdNoOfDaysMap.get(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c);
                    noOfDays=noOfDays+olddays;
                    plantGrdNoOfDaysMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c,noOfDays);
                }else{
                    plantGrdNoOfDaysMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID__c,noOfDays);
                }
		FIX_470189_Lakshmi_30Apr2020_Ends*/
                if(plantGrdBioValLstMap.containsKey(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c)){
                    decimal oldBio=plantGrdBioValLstMap.get(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c);
                    bioValue=bioValue+oldBio;

                    plantGrdBioValLstMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c,bioValue);
                }else{
                    plantGrdBioValLstMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c,bioValue);
                }

                if(plantGrdNoOfDaysMap.containsKey(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c)){
                    integer olddays=plantGrdNoOfDaysMap.get(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c);
                    noOfDays=noOfDays+olddays;
                    plantGrdNoOfDaysMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c,noOfDays);
                }else{
                    plantGrdNoOfDaysMap.put(thr.Plant_Code__c+thr.Grade__c+thr.Supply_Route_ID_Name__c,noOfDays);
                }
                //AdditionalFix_1709686_Soumyajit_19Jul2019 ends
                 //system.debug('plantGrdNoOfDaysMap'+plantGrdNoOfDaysMap);
            }
        }


        for(String plantGrd :plantGrdBioValLstMap.keySet()){
             plantGrdFinalBioValMap.put(plantGrd,plantGrdBioValLstMap.get(plantGrd)/plantGrdNoOfDaysMap.get(plantGrd));
        }
        //system.debug('bio plantGrdFinalBioValMap==>'+plantGrdFinalBioValMap);

        //Fix_260836_Soumyajit_22May2019 Starts
        //system.debug('bio plantGrdFinalBioNoQuoteValMap==>'+plantGrdFinalBioNoQuoteValMap);
        if(plantGrdFinalBioNoQuoteValMap.size()>0)
            plantGrdFinalBioValMap.putall(plantGrdFinalBioNoQuoteValMap);
        //system.debug('bio plantGrdFinalBioValMap WithNoquotes==>'+plantGrdFinalBioValMap);
        //Fix_260836_Soumyajit_22May2019 Ends

          return plantGrdFinalBioValMap ;
    }

    //Method to get Throughput
    public static Map<String,Throughput__c> getThroughput(Set<String> plantGradeSet){
        Map<String,Throughput__c> PlantMatThroughputMap= new Map<String,Throughput__c>();
        List<Throughput__c> throughPutLst= new List<Throughput__c>();
        throughPutLst=[Select id,Apply_Throughput__c,MOT__c,Plant__c,
                       Name,Plant_Code__c,Throughput_Cost__c,Product_Sub_Grade__c,Standard_grade__c from
                       Throughput__c where PlantGrade__c IN :plantGradeSet];
        for(Throughput__c thrpt:throughPutLst){
            if(thrpt.MOT__c == 'Barge' || thrpt.MOT__c== 'Rail'){
            	PlantMatThroughputMap.put(thrpt.Plant_Code__c+thrpt.Product_Sub_Grade__c+thrpt.MOT__c,thrpt);
            }else{
                PlantMatThroughputMap.put(thrpt.Plant_Code__c+thrpt.Standard_grade__c+thrpt.MOT__c,thrpt);
            }
        }
        return PlantMatThroughputMap;
    }
    //Method to get Gov Fees
    public static Map<String,Decimal> getGovFees(){
        List<GovFees__mdt> GovFeesLst=new List<GovFees__mdt>();
        Map<String,Decimal> govFesTypeSalOrgGradeValMap=new Map<String,Decimal>();
        //Fix_250100_20May2019_Soumyajit starts
        //GovFeesLst=[Select id,Grade__c,Sales_Org__c,Type__c,Value_Eur_100L__c from GovFees__mdt];
        GovFeesLst=[Select id,Grade__c,Sales_Org__c,Type__c,Handling_Type__c,Value_Eur_100L__c from GovFees__mdt];
        //Fix_250100_20May2019_Soumyajit ends
        for(GovFees__mdt gov:GovFeesLst){
            //Fix_250100_20May2019_Soumyajit starts
            if(gov.Type__c.equals('Energy tax'))
            	govFesTypeSalOrgGradeValMap.put(gov.Type__c+gov.Sales_Org__c+gov.Grade__c+gov.Handling_Type__c,gov.Value_Eur_100L__c);
            else
            //Fix_250100_20May2019_Soumyajit ends
            govFesTypeSalOrgGradeValMap.put(gov.Type__c+gov.Sales_Org__c+gov.Grade__c,gov.Value_Eur_100L__c);
        }
        return govFesTypeSalOrgGradeValMap;
    }
    //Method to get Bio AMV for selected date range
    public static Map<String,Decimal> getBioAmvAvg(Set<string> plantUnqSet,date contractStartDate,Date contractEndDate){

        Map<String,Bio_AMVs__c> PlantBioAmvMap= new Map<String,Bio_AMVs__c>();
        Map<String,Decimal> PlantGradBioAmvMap= new Map<String,Decimal>();
       //FIX_PBI_574982_Lakshmi_25Aug2020_Starts
       // date enddate=system.today().addDays(28);
       date PromptEnddate;
       date PromptStartdate;
       date FutureEnddate;
       date FutureStartdate;
        //FIX_PBI_574982_Lakshmi_25Aug2020_Ends
        List<Bio_AMVs__c> BioAmvLst= new List<Bio_AMVs__c>();
        BioAmvLst=[select id,Prompt_Valid_From__c,Prompt_valid_To__c,Future_Valid_From__c,Future_Valid_To__c,Plant__c,Plant_Code__c,AGO_B7_m_Future__c,AGO_B7_m_Prompt__c,ULG_95_E10_m_Future__c,
                   ULG_95_E10_m_Prompt__c,ULG_95_E5_m_Future__c,ULG_95_E5_m_Prompt__c,ULG_98_m_Future__c,Sales_Org__c,
                   ULG_98_m_Prompt__c from Bio_AMVs__c where Plant_Code__c IN :plantUnqSet ]; //FIX_PBI_574982_25Aug2020
        for(Bio_AMVs__c bio:BioAmvLst){
            PlantBioAmvMap.put(bio.Plant_Code__c+bio.Sales_Org__c,bio);
            //FIX_PBI_574982_Lakshmi_25Aug2020_Starts
            PromptEnddate=bio.Prompt_valid_To__c;
            PromptStartdate = bio.Prompt_Valid_From__c;
            FutureStartdate = bio.Future_Valid_From__c;
            FutureEnddate = bio.Future_Valid_To__c;
            //FIX_PBI_574982_25Aug2020_Ends
        }
        //FIX_PBI_574982_Lakshmi_25Aug2020_Starts
        if(PromptEnddate == null || PromptStartdate==null || FutureStartdate==null || FutureEnddate == null ){
            PromptStartdate = System.today();
            PromptEnddate=system.today().addDays(60);
            FutureStartdate = PromptEnddate + 1;
            FutureEnddate = date.newInstance(3999,12,31);
        }
        //FIX_PBI_574982_Lakshmi_25Aug2020_Ends

       for(string Key:PlantBioAmvMap.keyset()){
              if(PlantBioAmvMap.containsKey(Key)){
                if((contractStartDate >= PromptStartdate && contractEndDate <= PromptEnddate) ||
                    (contractStartDate <= PromptStartdate && contractEndDate <= PromptEnddate)){ //FIX_PBI_574982_25Aug2020
                    if((PlantBioAmvMap.get(Key)).AGO_B7_m_Prompt__c !=null)
                PlantGradBioAmvMap.put(Key+'AGO B7',(PlantBioAmvMap.get(Key)).AGO_B7_m_Prompt__c);
                    if((PlantBioAmvMap.get(Key)).ULG_95_E10_m_Prompt__c != null)
                PlantGradBioAmvMap.put(Key+'ULG95 E10',(PlantBioAmvMap.get(Key)).ULG_95_E10_m_Prompt__c);
                    if((PlantBioAmvMap.get(Key)).ULG_95_E5_m_Prompt__c != null)
                PlantGradBioAmvMap.put(Key+'ULG95 E5',(PlantBioAmvMap.get(Key)).ULG_95_E5_m_Prompt__c);
                    if((PlantBioAmvMap.get(Key)).ULG_98_m_Prompt__c !=null)
                PlantGradBioAmvMap.put(Key+'ULG98',(PlantBioAmvMap.get(Key)).ULG_98_m_Prompt__c);
            }
           else if(contractStartDate >= FutureStartdate && contractEndDate <= FutureEnddate){ //FIX_PBI_574982_25Aug2020
                    if((PlantBioAmvMap.get(Key)).AGO_B7_m_Future__c !=null)
                PlantGradBioAmvMap.put(Key+'AGO B7',(PlantBioAmvMap.get(Key)).AGO_B7_m_Future__c);
                    if((PlantBioAmvMap.get(Key)).ULG_95_E10_m_Future__c != null)
                PlantGradBioAmvMap.put(Key+'ULG95 E10',(PlantBioAmvMap.get(Key)).ULG_95_E10_m_Future__c);
                    if((PlantBioAmvMap.get(Key)).ULG_95_E5_m_Future__c != null)
                PlantGradBioAmvMap.put(Key+'ULG95 E5',(PlantBioAmvMap.get(Key)).ULG_95_E5_m_Future__c);
                    if((PlantBioAmvMap.get(Key)).ULG_98_m_Future__c !=null)
                PlantGradBioAmvMap.put(Key+'ULG98',(PlantBioAmvMap.get(Key)).ULG_98_m_Future__c);
            }
            //FIX_PBI_574982_Lakshmi_25Aug2020_starts
            else if(contractStartDate <= PromptEnddate && contractEndDate >= FutureStartdate){

                Integer TotalnoOfDays =0;
                Integer noOfPromptDays =0;
                Integer noOfFutureDays =0;

                noOfPromptDays = contractStartDate.daysBetween(PromptEnddate) + 1;
                noOfFutureDays = FutureStartdate.daysBetween(contractEndDate) + 1;
                TotalnoOfDays = noOfPromptDays + noOfFutureDays;

                if(((PlantBioAmvMap.get(Key)).AGO_B7_m_Prompt__c !=null) && (PlantBioAmvMap.get(Key)).AGO_B7_m_Future__c != null)
                PlantGradBioAmvMap.put(Key+'AGO B7',(((PlantBioAmvMap.get(Key)).AGO_B7_m_Prompt__c)*noOfPromptDays+(((PlantBioAmvMap.get(Key)).AGO_B7_m_Future__c))*noOfFutureDays)/TotalnoOfDays);
                    if(((PlantBioAmvMap.get(Key)).ULG_95_E10_m_Prompt__c !=null) && (PlantBioAmvMap.get(Key)).ULG_95_E10_m_Future__c != null)
                PlantGradBioAmvMap.put(Key+'ULG95 E10',(((PlantBioAmvMap.get(Key)).ULG_95_E10_m_Prompt__c)*noOfPromptDays+(((PlantBioAmvMap.get(Key)).ULG_95_E10_m_Future__c))*noOfFutureDays)/TotalnoOfDays);
                    if(((PlantBioAmvMap.get(Key)).ULG_95_E5_m_Prompt__c !=null) && (PlantBioAmvMap.get(Key)).ULG_95_E5_m_Future__c != null)
                PlantGradBioAmvMap.put(Key+'ULG95 E5',(((PlantBioAmvMap.get(Key)).ULG_95_E5_m_Prompt__c)*noOfPromptDays+(((PlantBioAmvMap.get(Key)).ULG_95_E5_m_Future__c))*noOfFutureDays)/TotalnoOfDays);
                    if(((PlantBioAmvMap.get(Key)).ULG_98_m_Prompt__c !=null) && (PlantBioAmvMap.get(Key)).ULG_98_m_Future__c != null)
                PlantGradBioAmvMap.put(Key+'ULG98',(((PlantBioAmvMap.get(Key)).ULG_98_m_Prompt__c)*noOfPromptDays+(((PlantBioAmvMap.get(Key)).ULG_98_m_Future__c))*noOfFutureDays)/TotalnoOfDays);

            }
				//FIX_PBI_574982_Lakshmi_25Aug2020_Ends
              }
        }

        for(String grade:PlantGradBioAmvMap.keySet()){
            if(grade.contains('ULG')){
                decimal convertedValue=(PlantGradBioAmvMap.get(grade))/Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);
                PlantGradBioAmvMap.put(grade,convertedValue);
            }else{
                decimal convertedValue=(PlantGradBioAmvMap.get(grade))/Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
                PlantGradBioAmvMap.put(grade,convertedValue);
            }
        }
        //System.debug('BIOOOOOOOOOO PlantGradBioAmvMap' + PlantGradBioAmvMap);
        return PlantGradBioAmvMap;
    }

    //Method for fitering location Steer based on record type
    public static List<Location_Steer__c> fiterList(List<Location_Steer__c> strLst,string recTypeId){
        List<Location_Steer__c> locStrLst=new List<Location_Steer__c>();
        for(Location_Steer__c loc:strLst){
            if(loc.recordTypeId==recTypeId){
                locStrLst.add(loc);
            }
        }
        return locStrLst;
    }

    //Fix_314451_Soumyajit_23Sep2019 starts
    /*
    //Method for caluclating final steer value based on contract start date for each plant grade
    public static Map<string,Decimal> getSteerAvg(List<Location_Steer__c> locStrLst,String recTypeName){
        Map<string,Decimal> plantGradfinalMap= new Map<string,Decimal>();
        Map<String,List<Location_Steer__c>> plantGrdMap= new Map<String,List<Location_Steer__c>>();
        string UniqKey;
        for(integer i=0;i<locStrLst.size();i++){
            UniqKey=locStrLst[i].PlantGradeUnq__c;
            if(plantGrdMap.containsKey(locStrLst[i].PlantGradeUnq__c)){
                List<Location_Steer__c> loclst= plantGrdMap.get(locStrLst[i].PlantGradeUnq__c);
                loclst.add(locStrLst[i]);
                plantGrdMap.put(locStrLst[i].PlantGradeUnq__c,loclst);
            }
            else{
                plantGrdMap.put(locStrLst[i].PlantGradeUnq__c,new List<Location_Steer__c> {locStrLst[i]});
            }
        }


        for(string key:plantGrdMap.keySet()){
            if((plantGrdMap.get(key)).size()>1){
                Location_Steer__c loc;
                if(((plantGrdMap.get(key)).get(0)).Default__c){
                    loc=(plantGrdMap.get(key)).get(1);
                    if(loc.recordtype.name=='Source Steer'){
                        plantGradfinalMap.put(loc.PlantGradeUnq__c,loc.Source_Steer__c);
                    }
                    else{
                        plantGradfinalMap.put(loc.PlantGradeUnq__c,loc.Depot_Steer__c);
                    }
                }
                else{
                    loc=(plantGrdMap.get(key)).get(0);
                    if(loc.recordtype.name=='Source Steer'){
                        plantGradfinalMap.put(loc.PlantGradeUnq__c,loc.Source_Steer__c);
                    }
                    else{
                        plantGradfinalMap.put(loc.PlantGradeUnq__c,loc.Depot_Steer__c);
                    }
                }
            }
            else{
                Location_Steer__c loc=(plantGrdMap.get(key)).get(0);
                if(loc.recordtype.name=='Source Steer'){
                    plantGradfinalMap.put(loc.PlantGradeUnq__c,loc.Source_Steer__c);
                }
                else{
                    plantGradfinalMap.put(loc.PlantGradeUnq__c,loc.Depot_Steer__c);
                }
            }
        }
         return plantGradfinalMap;
    }
    */

    public static Map<string,Decimal> getSteerWeightedAvg(List<Location_Steer__c> locStrLst
													 ,Date contractStartDate
													 ,Date contractEndDate
                                                     ,String recTypeName)
    {
        Map<string,Decimal> plantGradfinalMap= new Map<string,Decimal>();
        Map<String,List<Location_Steer__c>> plantGrdMap= new Map<String,List<Location_Steer__c>>();

        for(integer i=0;i<locStrLst.size();i++)
        {
            String locKey=locStrLst[i].PlantGradeUnq__c;
            if(plantGrdMap.containsKey(locKey))
            {
                List<Location_Steer__c> loclst= plantGrdMap.get(locKey);
                loclst.add(locStrLst[i]);
                plantGrdMap.put(locKey,loclst);
            }
            else
                plantGrdMap.put(locKey,new List<Location_Steer__c> {locStrLst[i]});
        }

        for(string key:plantGrdMap.keySet())
        {
        	Map<Integer,List<String>> steerCalcMap = new Map<Integer,List<String>>();
            Integer counter = 1;

			for(Location_Steer__c loc : plantGrdMap.get(key))
            {
            	String locKey = loc.PlantGradeUnq__c;
                Date startDate = contractStartDate;
                Date endDate = contractEndDate;
                Integer noOfDays = 0;
                Integer totalNoOfDays = contractStartDate.daysBetween(contractEndDate) + 1;
                Double steerVal = 0;
                Double finalSteerVal = 0;
                Boolean calcNoOfDays = true;

                if(loc.recordtype.name=='Source Steer')
                	steerVal = loc.Source_Steer__c;
                else
                	steerVal = loc.Depot_Steer__c;

				if(steerVal != null && steerVal != 0)
                {
                    if(contractStartDate >= loc.Valid_From__c)
                    {
                        if(contractEndDate <= loc.Valid_To__c)
                        {
                            startDate = contractStartDate;
                            endDate = contractEndDate;
                        }
                        else
                        {
                            if(contractStartDate <= loc.Valid_To__c)
                            {
                                startDate = contractStartDate;
                                endDate = loc.Valid_To__c;
                            }
                            else
                                calcNoOfDays = false;
                        }
                    }
                    else
                    {
                        if(contractEndDate <= loc.Valid_To__c)
                        {
                            startDate = loc.Valid_From__c;
                            endDate = contractEndDate;
                        }
                        else
                        {
                            if(contractStartDate <= loc.Valid_To__c)
                            {
                                startDate = loc.Valid_From__c;
                            	endDate = loc.Valid_To__c;
                            }
                            else
                                calcNoOfDays = false;
                        }
                    }

                    if(calcNoOfDays)
                    {
                        noOfDays = startDate.daysBetween(endDate) + 1;

                        if(steerCalcMap.size()>0)
                        {
                            Map<Integer,List<String>> steerCalcMapTemp = new Map<Integer,List<String>>();
                            steerCalcMapTemp.putAll(steerCalcMap);
                            steerCalcMap.clear();

                            for(Integer i =1 ; i<=steerCalcMapTemp.size(); i++)
                            {
                                if(steerCalcMapTemp.get(i) != null)
                                {
                                    Date steerCalcStartDate = Date.valueOf(steerCalcMapTemp.get(i)[0]);
                                    Date steerCalcEndDate = Date.valueOf(steerCalcMapTemp.get(i)[1]);
                                    Double steerCalcVal = Double.valueOf(steerCalcMapTemp.get(i)[3]);
                                    Integer newNoOfDays = 0;

                                    if(startDate >= steerCalcStartDate)
                                    {
                                        if(endDate <= steerCalcEndDate)
                                        {
                                            newNoOfDays = steerCalcStartDate.daysBetween(startDate-1) + 1;
                                            if(newNoOfDays > 0)
                                            {
                                                counter = steerCalcMap.size() + 1;
                                                steerCalcMap.put(counter,new List<String> {String.valueOf(steerCalcStartDate)
                                                                                    ,String.valueOf(startDate-1)
                                                                                    ,String.valueOf(newNoOfDays)
                                                                                    ,String.valueOf(steerCalcVal)});
                                            }

                                            counter = steerCalcMap.size() + 1;
                                            steerCalcMap.put(counter,new List<String> {String.valueOf(startDate)
                                                                                    ,String.valueOf(endDate)
                                                                                    ,String.valueOf(noOfDays)
                                                                                    ,String.valueOf(steerVal)});

                                            newNoOfDays = (endDate+1).daysBetween(steerCalcEndDate) + 1;
                                            if(newNoOfDays > 0)
                                            {
                                                counter = steerCalcMap.size() + 1;
                                                steerCalcMap.put(counter,new List<String> {String.valueOf(endDate+1)
                                                                                        ,String.valueOf(steerCalcEndDate)
                                                                                        ,String.valueOf(newNoOfDays)
                                                                                        ,String.valueOf(steerCalcVal)});
                                            }
                                        }
                                        else if(endDate > steerCalcStartDate)
                                        {
                                            counter = steerCalcMap.size() + 1;
                                            steerCalcMap.put(counter,steerCalcMapTemp.get(i));

                                            counter = steerCalcMap.size() + 1;
                                            steerCalcMap.put(counter,new List<String> {String.valueOf(startDate)
                                                                                        ,String.valueOf(endDate)
                                                                                        ,String.valueOf(noOfDays)
                                                                                        ,String.valueOf(steerVal)});
                                        }
                                        else
                                        {
                                            counter = steerCalcMap.size() + 1;
                                            steerCalcMap.put(counter,steerCalcMapTemp.get(i));
                                        }
                                    }
                                    else if(endDate >= steerCalcStartDate)
                                    {
                                        newNoOfDays = startDate.daysBetween(steerCalcStartDate-1) + 1;
                                        counter = steerCalcMap.size() + 1;
                                        steerCalcMap.put(counter,new List<String> {String.valueOf(startDate)
                                                                                  ,String.valueOf(steerCalcStartDate)
                                                                                ,String.valueOf(newNoOfDays)
                                                                                ,String.valueOf(steerVal)});

                                        if(endDate <= steerCalcEndDate)
                                        {
                                            newNoOfDays = (endDate+1).daysBetween(steerCalcEndDate) + 1;
                                            if(newNoOfDays > 0)
                                            {
                                                counter = steerCalcMap.size() + 1;
                                                steerCalcMap.put(counter,new List<String> {String.valueOf(endDate+1)
                                                                                        ,String.valueOf(steerCalcEndDate)
                                                                                        ,String.valueOf(newNoOfDays)
                                                                                        ,String.valueOf(steerCalcVal)});
                                            }
                                        }
                                    }
                                    else
                                    {
                                        counter = steerCalcMap.size() + 1;
                                        steerCalcMap.put(counter,steerCalcMapTemp.get(i));
                                    }
                                }
                            }
                        }
                        else
                        {
                            counter = 1;
                            steerCalcMap.put(counter,new List<String> {String.valueOf(startDate)
                                                                    ,String.valueOf(endDate)
                                                                    ,String.valueOf(noOfDays)
                                                                    ,String.valueOf(steerVal)});
                        }

                        //System.debug(locKey + ' steerCalcMap=> '+steerCalcMap);

                        for(Integer i : steerCalcMap.keyset())
                            finalSteerVal += (Integer.valueOf(steerCalcMap.get(i)[2]) * Double.valueOf(steerCalcMap.get(i)[3]));

                        finalSteerVal = finalSteerVal / totalNoOfDays;
                        plantGradfinalMap.put(locKey,finalSteerVal);
                    }
                }
			}
        }

        //System.debug('---'+ recTypeName +' Weighted Average plantGradfinalMap starts---');
        /*for (String s : plantGradfinalMap.keyset())
    		System.debug(s + ' = ' + plantGradfinalMap.get(s));
        System.debug('---'+ recTypeName +' Weighted Average plantGradfinalMap ends---');*/

        return plantGradfinalMap;
    }
    //Fix_314451_Soumyajit_23Sep2019 ends

    /*Method Name	:	getCustomerSpecificPricing
    * Date			:	14-Feb-2020
    * Developer		:	Rahul Sharma
    * Description	:	Get records from Customer Specific Pricing object based on MRC records*/
    public static Map<String, Customer_Specific_Pricing__c> getCustomerSpecificPricing(Set<Id> locationIdSet, Set<Id> accountIdSet, Set<String> salesOrgSet, Set<String> gradeSet, String tranche){
        Map<String, Customer_Specific_Pricing__c> cspKeyVsObjectMap = new Map<String, Customer_Specific_Pricing__c>();
        for(Customer_Specific_Pricing__c csp : [SELECT Id,
                                                       Account__c,
                                                       CSP_Eur_100L__c,
                                                       Grade__c,
                                                       Plant__c,
                                                       Plant__r.Plant_Code__c,
                                                       Sales_Org__c FROM Customer_Specific_Pricing__c WHERE Account__c IN : accountIdSet
                                                                                                      AND Plant__c IN : locationIdSet
                                                                                                      AND Sales_Org__c IN : salesOrgSet
                                                                                                      AND Grade__c IN : gradeSet
                                                                                                      AND Tranche__c =: tranche]){
            String cspKey = csp.Sales_Org__c + csp.Account__c + csp.Plant__r.Plant_Code__c + csp.Grade__c;
            cspKeyVsObjectMap.put(cspKey, csp);
        }
        return cspKeyVsObjectMap;
    }

    /*Method Name	:	getTranche
    * Date			:	12-Jun-2020
    * Developer		:	Rahul Sharma
    * Description	:	Get tranche from the given contract start*/
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
                throw new CustomException('Invalid input. Contract Start Date is not valid.');
            }
            catch(Exception e){
                System.debug('Exception on RV_SPCalculationController >> getTranche: '+e.getMessage()+'Line Number: '+e.getLineNumber());
                return null;
            }
        }
    }

    public class salesPriceWrap{
        @AuraEnabled
        public decimal BSP;
        @AuraEnabled
        public decimal OTM;
        @AuraEnabled
        public decimal MSP;
        @AuraEnabled
        public decimal landedCost;
        @AuraEnabled
        public string mrcNo;
        @AuraEnabled
        public decimal totalTax;
        @AuraEnabled
        public String tranche;  //Rahul Sharma | Date - 28-Jan-2021 : Added addtional tranche parameter to identify OLF deals.
    }

    public class salesPriceCalAndAuditWrap{
        public List<priceAuditWrap> auditWrpLst;
        public List<salesPriceWrap> salesPriceWrpLst;
    }
    public class priceAuditWrap{
        public string mrcNo;
        public Id shtId;
        public string salesOrg;
        public String locationId;//Added By Dhriti;PBI-235351
        public Id materialId;
        public integer shippingCond;
        public decimal landedCostEuroMt;
        public decimal depotSteer;
        public decimal finalAMVEuroMt;
        public decimal finalAMVEuro100L;
        public string applyThroughput;
        public decimal throughputCost;
        public decimal energyFees;
        public decimal cso;
        public decimal CO2;// Added By Dhriti PBI-297
        public Boolean iwoMember;
        public decimal unionFees;
        public decimal calculatedBSP;
        public decimal salesMargin;
        public decimal minMargin;
        public decimal nightSurcharges;    //Rahul Sharma | Date: 06-Feb-2020: added night surchagers for AGO B7, IGP ppm and ULG95 E5
        public decimal customerSpecificPrice;   //Rahul Sharma | Date: 12-Feb-2020: added customer specific price for AGO B7, IGP 50ppm, GTL B0 and ULG95 E5 grades
        public decimal otm; //Rahul Sharma | Date: 20-Feb-2020: added otm price for audit.
        public decimal calculatedMSP;
        public decimal exchangeRate;
        public decimal marketingCost;	//Fix_394298_10Jan2020_Soumyajit
        public String tranche;  //Rahul Sharma | Date: 25-Nov-2020 : Added tranche parameter.
        public list<backboneAMVpriceCompWrap> bavWrp;
    }
    public class backboneAMVpriceCompWrap{
        public string mrcNo;
        public string routeName;
        public decimal routeUtilizationPercent;
        public decimal hcv;
        public decimal coSteer;
        public decimal freight;
        public decimal freightPercentage;
        public decimal freightQuoteValue;
        public decimal freightToSource;
        public decimal freightToDepot;
        public decimal bioCost;
        public boolean thirdParty;
        public boolean bioSplit;
        public decimal wasa;
        public decimal additiveCost;
        public decimal landedBAMVvalue;
        public decimal finalBAMVvalue;
        public String supplier;//Added By Dhriti
        //FIX_PBI_281711_Lakshmi_26thJune2019_Starts
        public string source;
        //FIX_PBI_281711_Lakshmi_26thJune2019_Ends
        //Additional Fix:FIX_PBI_281711_Lakshmi_Starts
        public string Depot;
        public string mot;//FIX_PBI_471288_Lakshmi_20Apr20
        public String tranche;  //Rahul Sharma | Date: 25-Nov-2020 : Added tranche parameter.


    }
    public class marginWrap{
        public string salesOrgPlntCodGradeMgnTypeKey;
        public string subGrade;
        public decimal salesMargin;
        public decimal minMargin;
        public decimal fixedSurcharge;
        public decimal nightSurcharge;
        public time nightSurchargeStartTime;
        public time nightSurchargeEndTime;
        public String tranche = ''; //Rahul Sharma | Date: 12-Jun-2020 : Added tranche for the Margin
    }
    public class mrcMaterialWrap{
        public string gradeL2;
        public String handlingtype;
        public String salesOrg;
        public decimal behgeuro100l = 0;
        public decimal futurebehgeuro100l = 0;
        public Date currValidFrom;
        public Date currValidTo;
        public Date FutValidFrom;
        public Date FutValidTo;
        mrcMaterialWrap(){
            behgeuro100l = 0;
            futurebehgeuro100l = 0;
        }
    }

    /*Class Name	:	CustomException
    * Date			:	12-Jun-2020
    * Developer		:	Rahul Sharma
    * Description	:	Custom excception class*/
    public class CustomException extends Exception{}
}