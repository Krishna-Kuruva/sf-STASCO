global class Rv_DailyPriceTrendQueueable implements Queueable{
    
    global void execute(QueueableContext context ){
        List<Price_Trend_Management__mdt> prcTrndMgmtLst= new List<Price_Trend_Management__mdt>();
        prcTrndMgmtLst=[Select id,MasterLabel,DeveloperName from Price_Trend_Management__mdt]; 
        Set<String> SoldToNameSet= new Set<String>();
        for(Price_Trend_Management__mdt ptm :prcTrndMgmtLst){
            SoldToNameSet.add(ptm.MasterLabel);
        }
        //String accName='%Shell Revolution Special Co.%'; 
        String query='select id,name,Plant__c,Plant__r.Name,Plant_code__c,'+
            'Supply_Type__c,Product__c,Product__r.Name,Product__r.Commodity_Grade_L2__c,Product__r.BEHG_Value_100l__c,Product__r.Current_BEHG_valid_from_date__c,Product__r.Current_BEHG_valid_to_date__c,Product__r.Future_BEHG_value_in_100l__c,Product__r.Future_BEHG_valid_from_date__c,Product__r.Future_BEHG_valid_to_date__c,Material_Description__c,Material_Name__c,PO_Type__c,'+
            ' Sold_To__c,Sold_To__r.Name,Sales_Organization__c,Handling_Type__c,MRC_Number__c,Ship_to_Number__c,'+
            ' Ship_to_Name__c,Shipping_Condition__c from MRC__c where Sold_To__r.Name IN :SoldToNameSet LIMIT 1000'; 
        List<Mrc__c> mrclst= database.query(query);
        List<Reuters_Quotes__c> reuQtsLst = new List<Reuters_Quotes__c>();
        //PBI_166252_DataCleanup_Lakshmi_15thOct2019==> Removed Quote__c,Reuters_Code__c
        reuQtsLst=[Select id,CurrencyCode__c,Price__c,Price_USD__c,
                   Pricing_Date__c,Quote_Display_Name__c,Quote_Name__c,
                   Unit_Of_Measure__c,Valid_From_Date__c,Frequency__c,LastModifiedDate,CreatedDate,
                   Valid_Month__c,Valid_To_Date__c from Reuters_Quotes__c WHERE Quote_Display_Name__c != '' LIMIT 1000];
        
        if(mrclst.size()>0){
            //START - Rahul Sharma | Date - 25-Nov-2020 : Updated code to calculate BSP and MSP for all 3 tranches.
            RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp1 = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
            RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp2 = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
            RV_SPCalculationController.salesPriceCalAndAuditWrap spAdtWrp3 = new RV_SPCalculationController.salesPriceCalAndAuditWrap();
            List<RV_SPCalculationController.priceAuditWrap> priceAdtWrpLst= new List<RV_SPCalculationController.priceAuditWrap>();
            spAdtWrp1 = RV_SPCalculationController.getCalulatedSp(mrclst, System.today(), System.today().addDays(14));
            spAdtWrp2 = RV_SPCalculationController.getCalulatedSp(mrclst, System.today().addDays(15), System.today().addDays(28));
            spAdtWrp3 = RV_SPCalculationController.getCalulatedSp(mrclst, System.today().addDays(29), System.today().addDays(61));
            priceAdtWrpLst = spAdtWrp1.auditWrpLst;
            priceAdtWrpLst.addAll(spAdtWrp2.auditWrpLst);
            priceAdtWrpLst.addAll(spAdtWrp3.auditWrpLst);
            //END - Rahul Sharma | Date - 25-Nov-2020 : Updated code to calculate BSP and MSP for all 3 tranches.
            List<BSP_Trends__c> prcAdtBspTrndLst=new List<BSP_Trends__c>();
            List<Backbone_Trends__c> prcAdtAMVTrndLst= new List<Backbone_Trends__c>();
            List<RV_SPCalculationController.backboneAMVpriceCompWrap> prcWrpBAMVLst= new List<RV_SPCalculationController.backboneAMVpriceCompWrap>();
            if(priceAdtWrpLst.size()>0){           
                for(integer i=0;i<priceAdtWrpLst.size();i++){
                    BSP_Trends__c prcAudBsp = new BSP_Trends__c();
                    prcAudBsp.Material__c=priceAdtWrpLst[i].materialId;
                    prcAudBsp.Location_Name__c = priceAdtWrpLst[i].locationId;//Added By Dhriti;PBI-235351
                    prcAudBsp.Calcualated_BSP__c=priceAdtWrpLst[i].calculatedBSP;
                    prcAudBsp.Calcualated_MSP__c= priceAdtWrpLst[i].calculatedMSP;
                    prcAudBsp.Shipping_Condition__c=priceAdtWrpLst[i].shippingCond;
                    prcAudBsp.Sales_Org__c=priceAdtWrpLst[i].salesOrg;
                    prcAudBsp.CSO__c=priceAdtWrpLst[i].cso;
                    prcAudBsp.CO2_Euro_100L__c=priceAdtWrpLst[i].CO2;// Added By Dhriti PBI-297
                    prcAudBsp.Depot_Steer__c=priceAdtWrpLst[i].depotSteer;
                    prcAudBsp.Energy_Fees__c=priceAdtWrpLst[i].energyFees;
                    prcAudBsp.Final_AMV_Euro_100L__c=priceAdtWrpLst[i].finalAMVEuro100L;
                    prcAudBsp.Final_AMV_Euro_Mt__c=priceAdtWrpLst[i].finalAMVEuroMt;
                    prcAudBsp.IWO_Member__c=priceAdtWrpLst[i].iwoMember;
                    prcAudBsp.Landed_Cost_Euro_Mt__c=priceAdtWrpLst[i].landedCostEuroMt;
                    prcAudBsp.Min_Margin__c=priceAdtWrpLst[i].minMargin;
                    prcAudBsp.Mrc_No__c=priceAdtWrpLst[i].mrcNo;
                    prcAudBsp.Sales_Margin__c=priceAdtWrpLst[i].salesMargin;
                    prcAudBsp.Throughput_Applied__c=priceAdtWrpLst[i].applyThroughput;
                    prcAudBsp.Throughput_Cost__c=priceAdtWrpLst[i].throughputCost;
                    prcAudBsp.Union_Fees__c=priceAdtWrpLst[i].unionFees;
                    prcAudBsp.Marketing_cost__c = priceAdtWrpLst[i].marketingCost;  //Fix_394298_10Jan2020_Soumyajit
                    prcAudBsp.Tranche__c = priceAdtWrpLst[i].tranche;   //Rahul Sharma | Date - 25-Nov-2020 : Added tranche identifier.
                    prcAdtBspTrndLst.add(prcAudBsp);
                    List<RV_SPCalculationController.backboneAMVpriceCompWrap> prcBAMVLst=priceAdtWrpLst[i].bavWrp;
                    prcWrpBAMVLst.addAll(prcBAMVLst);
                }
                //updateProductDifferentialAgoMogas8amValues(prcAdtBspTrndLst); //Rahul Sharma | Date - 25-Nov-2020 : Commented as the values product differential values no more required.
                Set<Id> insertedIds= new Set<Id>();
                try{
                    List<Database.SaveResult> srList= database.insert(prcAdtBspTrndLst);
                    for(database.SaveResult sr:srList){
                        if(sr.isSuccess()){
                            insertedIds.add(sr.getId());
                        }
                    }
                }        
                catch(Exception e){
                    
                }
                
                List<BSP_Trends__c> prcAdtLst=new List<BSP_Trends__c>();
                Map<string,Id> mrcPrcAdtIdMap = new Map<string,Id>();
                //START - Rahul Sharma | Date - 25-Nov-2020 : Updated map key.
                if(insertedIds.size()>0){
                    prcAdtLst=[SELECT Id,
                                      Mrc_No__c,
                                      Tranche__c FROM BSP_Trends__c WHERE Id IN :insertedIds];
                }
                for(BSP_Trends__c pad:prcAdtLst){ 
                    mrcPrcAdtIdMap.put(pad.Mrc_No__c + pad.Tranche__c, pad.Id);
                }
                //END - Rahul Sharma | Date - 25-Nov-2020 : Updated map key.
                for(integer i=0;i<prcWrpBAMVLst.size();i++){
                    Backbone_Trends__c prcAdtBkbnAmv= new Backbone_Trends__c();
                    prcAdtBkbnAmv.Additive_Cost__c=prcWrpBAMVLst[i].additiveCost;
                    prcAdtBkbnAmv.Bio_Cost__c=prcWrpBAMVLst[i].additiveCost;
                    prcAdtBkbnAmv.Additive_Cost__c=prcWrpBAMVLst[i].additiveCost;
                    prcAdtBkbnAmv.Bio_Cost__c=prcWrpBAMVLst[i].bioCost;
                    prcAdtBkbnAmv.Bio_Split__c=prcWrpBAMVLst[i].bioSplit;
                    prcAdtBkbnAmv.CO_Steer__c=prcWrpBAMVLst[i].coSteer;
                    prcAdtBkbnAmv.Landed_BAMV__c=prcWrpBAMVLst[i].landedBAMVvalue;
                    prcAdtBkbnAmv.Final_BAMV_Value__c=prcWrpBAMVLst[i].finalBAMVvalue;
                    prcAdtBkbnAmv.Freight_Percentage__c=prcWrpBAMVLst[i].freightPercentage;
                    prcAdtBkbnAmv.Freight_Quote_Value__c=prcWrpBAMVLst[i].freightQuoteValue;
                    prcAdtBkbnAmv.FreightToSource__c=prcWrpBAMVLst[i].freightToSource;
                    prcAdtBkbnAmv.FreightToDepot__c=prcWrpBAMVLst[i].freightToDepot;
                    prcAdtBkbnAmv.Freight__c=prcWrpBAMVLst[i].freight;
                    prcAdtBkbnAmv.HCV__c=prcWrpBAMVLst[i].hcv;
                    prcAdtBkbnAmv.Mrc_No__c=prcWrpBAMVLst[i].mrcNo;
                    prcAdtBkbnAmv.Daily_BSP_Trends__c=mrcPrcAdtIdMap.get(prcWrpBAMVLst[i].mrcNo + prcWrpBAMVLst[i].tranche);    //Rahul Sharma | Date - 25-Nov-2020 : Added tranche identifier.
                    prcAdtBkbnAmv.Route_Name__c=prcWrpBAMVLst[i].routeName;
                    prcAdtBkbnAmv.Route_Utilization__c=prcWrpBAMVLst[i].routeUtilizationPercent;
                    prcAdtBkbnAmv.Third_Party__c=prcWrpBAMVLst[i].thirdParty;
                    //Additional Fix:FIX_PBI_281711_Lakshmi_Starts
                    //Fix By Sampada Bhat 15/12/2021
                    prcAdtBkbnAmv.WASA__c = prcWrpBAMVLst[i].wasa;
                    prcAdtBkbnAmv.Source__c=prcWrpBAMVLst[i].source;
                    system.debug(prcAdtBkbnAmv.Source__c+'source');
                    prcAdtBkbnAmv.Depot__c=prcWrpBAMVLst[i].Depot;
                    system.debug(prcAdtBkbnAmv.Depot__c+'Depot');
                    //Additional Fix:FIX_PBI_281711_Lakshmi_Ends
                    prcAdtAMVTrndLst.add(prcAdtBkbnAmv);
                }
                insert prcAdtAMVTrndLst;
            }
        }
        
        if(reuQtsLst.size()>0){
            List<Price_Trends__c> prcTrndLst= new List<Price_Trends__c>(); 
            for(integer i=0;i<reuQtsLst.size();i++){
                Price_Trends__c prcTrnd= new Price_Trends__c();
                prcTrnd.CurrencyCode__c=reuQtsLst[i].CurrencyCode__c;
                prcTrnd.Price__c=reuQtsLst[i].Price__c;
                prcTrnd.Frequency__c=reuQtsLst[i].Frequency__c;
                prcTrnd.Pricing_Date__c=reuQtsLst[i].Pricing_Date__c;
                prcTrnd.Quote_Display_Name__c=reuQtsLst[i].Quote_Display_Name__c;
                prcTrnd.Quote_Name__c=reuQtsLst[i].Quote_Name__c;
                //PBI_166252_DataCleanup_Lakshmi_15thOct2019==>Reuters_Code__c
                //prcTrnd.Reuters_Code__c=reuQtsLst[i].Reuters_Code__c;
                prcTrnd.Unit_Of_Measure__c=reuQtsLst[i].Unit_Of_Measure__c;
                prcTrnd.Valid_From_Date__c=reuQtsLst[i].Valid_From_Date__c;
                prcTrnd.Valid_Month__c=reuQtsLst[i].Valid_Month__c;
                prcTrnd.Valid_To_Date__c=reuQtsLst[i].Valid_To_Date__c;
                prcTrnd.Quote_Last_Modified_Date__c=reuQtsLst[i].LastModifiedDate;
                prcTrnd.Quote_Created_Date__c=reuQtsLst[i].CreatedDate;
                prcTrndLst.add(prcTrnd);
            }
            insert prcTrndLst; 
        }
    }
    
    public static void updateProdDifferetial(Map<String,Decimal> QuoateNameValueMap,Set<String> prdDiffNameSet){
        List<Product_Differential__c> prdDiffLst = new List<Product_Differential__c>();
        List<Product_Differential__c> prdDiffLstToBeUpdated = new List<Product_Differential__c>();
        prdDiffLst=[Select Id,Name,Price__C from Product_Differential__c where Name IN :prdDiffNameSet];
        if(prdDiffLst.size()>0){
            for(Product_Differential__c prd :prdDiffLst){
                if(QuoateNameValueMap.containsKey(prd.Name)){
                    prd.Price__c=QuoateNameValueMap.get(prd.Name);
                    prdDiffLstToBeUpdated.add(prd);
                } 
            }
        }
        if(prdDiffLstToBeUpdated.size()>0){
            update prdDiffLstToBeUpdated;
        }
    }

    public static void updateProductDifferentialAgoMogas8amValues(List<BSP_Trends__c> prcAdtBspTrndLst){
        Map<String,Decimal> QuoateNameValueMap= new  Map<String,Decimal>();
        Set<String> prdDiffNameSet= new Set<String>{'Wesseling AGO 8am Today','Wesseling Mogas 8am Today'};
        for(BSP_Trends__c bsp :prcAdtBspTrndLst){
            //AGO
            if(bsp.Mrc_No__c == label.Rv_Wesseling_AGO_MRC){
                QuoateNameValueMap.put('Wesseling AGO 8am Today',bsp.Calcualated_MSP__c);
            }
            //Mogas
            if(bsp.Mrc_No__c == label.Rv_Wesseling_MOGAS_MRC){
                QuoateNameValueMap.put('Wesseling Mogas 8am Today',bsp.Calcualated_MSP__c);
            } 
        }
        updateProdDifferetial(QuoateNameValueMap,prdDiffNameSet);   
    }
}