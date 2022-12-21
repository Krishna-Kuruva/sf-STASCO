public class Rv_PriceAuditController implements Queueable{
   /* public static  void  insertPriceAuditWrap(List<RV_SPCalculationController.priceAuditWrap> priceAdtWrpLst){
       List<RV_SPCalculationController.backboneAMVpriceCompWrap> prcWrpBAMVLst= new List<RV_SPCalculationController.backboneAMVpriceCompWrap>();
       Map<string,List<RV_SPCalculationController.backboneAMVpriceCompWrap>> mrcBamvWrpMap= new Map<string,List<RV_SPCalculationController.backboneAMVpriceCompWrap>>();
       List<Price_Audit_BSP__c> prcAdtBspObjLst=new List<Price_Audit_BSP__c>();
       List<Price_Audit_Backbone_AMV__c> prcAdtAMVObjLst= new List<Price_Audit_Backbone_AMV__c>();
       
        for(integer i=0;i<priceAdtWrpLst.size();i++){
            Price_Audit_BSP__c prcAudBsp = new Price_Audit_BSP__c();
            prcAudBsp.SHT__c=priceAdtWrpLst[i].shtId;
            prcAudBsp.Material__c=priceAdtWrpLst[i].materialId;
            prcAudBsp.Calcualated_BSP__c=priceAdtWrpLst[i].calculatedBSP;
            prcAudBsp.Calcualated_MSP__c= priceAdtWrpLst[i].calculatedMSP;
            prcAudBsp.Shipping_Condition__c=priceAdtWrpLst[i].shippingCond;
            prcAudBsp.Sales_Org__c=priceAdtWrpLst[i].salesOrg;
            prcAudBsp.CSO__c=priceAdtWrpLst[i].cso;
            prcAudBsp.Depot_Steer__c=priceAdtWrpLst[i].depotSteer;
            prcAudBsp.Energy_Fees__c=priceAdtWrpLst[i].energyFees;
            prcAudBsp.Final_AMV_Euro_100L__c=priceAdtWrpLst[i].finalAMVEuro100L;
            prcAudBsp.Final_AMV_Euro_Mt__c=priceAdtWrpLst[i].finalAMVEuroMt;
            prcAudBsp.IWO_Member__c=priceAdtWrpLst[i].iwoMember;
            prcAudBsp.Landed_Cost_Euro_Mt__c=priceAdtWrpLst[i].landedCostEuroMt;
            prcAudBsp.Min_Margin__c=priceAdtWrpLst[i].minMargin;
            prcAudBsp.Mrc_No__c=priceAdtWrpLst[i].mrcNo;
            prcAudBsp.Sales_Margin__c=priceAdtWrpLst[i].salesMargin;
            prcAudBsp.Night_Surcharges_Eur_100L__c = priceAdtWrpLst[i].nightSurcharges; //Rahul Sharma | Date - 07-Feb-2020 : Added night surcharge for audit
            prcAudBsp.Throughput_Applied__c=priceAdtWrpLst[i].applyThroughput;
            prcAudBsp.Throughput_Cost__c=priceAdtWrpLst[i].throughputCost;
            prcAudBsp.Union_Fees__c=priceAdtWrpLst[i].unionFees;
            prcAudBsp.Marketing_cost__c = priceAdtWrpLst[i].marketingCost;  //Fix_394298_10Jan2020_Soumyajit
            prcAudBsp.CSP_Eur_100L__c = priceAdtWrpLst[i].customerSpecificPrice; //Rahul Sharma | Date - 17-Feb-2020 : Added customer specific pricing for audit
            prcAudBsp.OTM_Eur_100L__c = priceAdtWrpLst[i].otm;  //Rahul Sharma | Date - 20-Feb-2020 : Added OTM price for audit
            prcAdtBspObjLst.add(prcAudBsp);
            List<RV_SPCalculationController.backboneAMVpriceCompWrap> prcBAMVLst=priceAdtWrpLst[i].bavWrp;
            prcWrpBAMVLst.addAll(prcBAMVLst);
        }
        Set<Id> insertedIds= new Set<Id>();
         try{
            List<Database.SaveResult> srList= database.insert(prcAdtBspObjLst);
            for(database.SaveResult sr:srList){
                if(sr.isSuccess()){
                    insertedIds.add(sr.getId());
                }
            }
        }        
        catch(Exception e){
            
        }
        List<Price_Audit_BSP__c> prcAdtLst=new List<Price_Audit_BSP__c>();
        Map<string,Id> mrcPrcAdtIdMap = new Map<string,Id>();
        if(insertedIds.size()>0){
            prcAdtLst=[Select id,Mrc_No__c from Price_Audit_BSP__c where Id IN :insertedIds];
        }
        for(Price_Audit_BSP__c pad:prcAdtLst){
            mrcPrcAdtIdMap.put(pad.Mrc_No__c,pad.Id);
        }
        for(integer i=0;i<prcWrpBAMVLst.size();i++){
            Price_Audit_Backbone_AMV__c prcAdtBkbnAmv= new Price_Audit_Backbone_AMV__c();
            prcAdtBkbnAmv.Additive_Cost__c=prcWrpBAMVLst[i].additiveCost;
          //  prcAdtBkbnAmv.Bio_Cost__c=prcWrpBAMVLst[i].additiveCost;
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
            prcAdtBkbnAmv.Price_Audit__c=mrcPrcAdtIdMap.get(prcWrpBAMVLst[i].mrcNo);
            prcAdtBkbnAmv.Route_Name__c=prcWrpBAMVLst[i].routeName;
            //FIX_PBI_281711_Lakshmi_26thJune2019_Starts
            prcAdtBkbnAmv.Source__c=prcWrpBAMVLst[i].source;
            system.debug(prcAdtBkbnAmv.Source__c+'source');
            //FIX_PBI_281711_Lakshmi_26thJune2019_Ends
            prcAdtBkbnAmv.Route_Utilization__c=prcWrpBAMVLst[i].routeUtilizationPercent;
            prcAdtBkbnAmv.Third_Party__c=prcWrpBAMVLst[i].thirdParty;
            prcAdtBkbnAmv.Wasa__c=prcWrpBAMVLst[i].wasa;
            prcAdtBkbnAmv.Supplier__c = prcWrpBAMVLst[i].supplier;//Added By Dhriti
            prcAdtAMVObjLst.add(prcAdtBkbnAmv);
        }
        insert prcAdtAMVObjLst;
       
    }*/
    List<RV_SPCalculationController.priceAuditWrap> salesPriceAuditInsertLst;
    public Rv_PriceAuditController(List<RV_SPCalculationController.priceAuditWrap> salesPriceAuditInsertLsts){
        this.salesPriceAuditInsertLst = salesPriceAuditInsertLsts;
    }
    
    public void execute(QueueableContext queCont){
        insertPriceAuditWrap(salesPriceAuditInsertLst);
    }
    
    public static  void  insertPriceAuditWrap(List<RV_SPCalculationController.priceAuditWrap> priceAdtWrpLst){
       List<RV_SPCalculationController.backboneAMVpriceCompWrap> prcWrpBAMVLst= new List<RV_SPCalculationController.backboneAMVpriceCompWrap>();
       Map<string,List<RV_SPCalculationController.backboneAMVpriceCompWrap>> mrcBamvWrpMap= new Map<string,List<RV_SPCalculationController.backboneAMVpriceCompWrap>>();
       List<Price_Audit_BSP__c> prcAdtBspObjLst=new List<Price_Audit_BSP__c>();
       List<Price_Audit_Backbone_AMV__c> prcAdtAMVObjLst= new List<Price_Audit_Backbone_AMV__c>();
       
        for(integer i=0;i<priceAdtWrpLst.size();i++){
            Price_Audit_BSP__c prcAudBsp = new Price_Audit_BSP__c();
            prcAudBsp.SHT__c=priceAdtWrpLst[i].shtId;
            prcAudBsp.Material__c=priceAdtWrpLst[i].materialId;
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
            prcAudBsp.Night_Surcharges_Eur_100L__c = priceAdtWrpLst[i].nightSurcharges; //Rahul Sharma | Date - 07-Feb-2020 : Added night surcharge for audit
            prcAudBsp.Throughput_Applied__c=priceAdtWrpLst[i].applyThroughput;
            prcAudBsp.Throughput_Cost__c=priceAdtWrpLst[i].throughputCost;
            prcAudBsp.Union_Fees__c=priceAdtWrpLst[i].unionFees;
            prcAudBsp.Marketing_cost__c = priceAdtWrpLst[i].marketingCost;  //Fix_394298_10Jan2020_Soumyajit
            prcAudBsp.CSP_Eur_100L__c = priceAdtWrpLst[i].customerSpecificPrice; //Rahul Sharma | Date - 17-Feb-2020 : Added customer specific pricing for audit
            prcAudBsp.OTM_Eur_100L__c = priceAdtWrpLst[i].otm;  //Rahul Sharma | Date - 20-Feb-2020 : Added OTM price for audit
            prcAdtBspObjLst.add(prcAudBsp);
            List<RV_SPCalculationController.backboneAMVpriceCompWrap> prcBAMVLst=priceAdtWrpLst[i].bavWrp;
            prcWrpBAMVLst.addAll(prcBAMVLst);
            //System.debug('Rv_PriceAuditController >> prcAdtBspObjLst: '+prcAdtBspObjLst);
        }
        Set<Id> insertedIds= new Set<Id>();
         try{
            List<Database.SaveResult> srList= database.insert(prcAdtBspObjLst);
            for(database.SaveResult sr:srList){
                if(sr.isSuccess()){
                    insertedIds.add(sr.getId());
                }
            }
        }        
        catch(Exception e){
            
        }
        List<Price_Audit_BSP__c> prcAdtLst=new List<Price_Audit_BSP__c>();
        Map<string,Id> mrcPrcAdtIdMap = new Map<string,Id>();
        if(insertedIds.size()>0){
            prcAdtLst=[Select id,Mrc_No__c from Price_Audit_BSP__c where Id IN :insertedIds];
        }
        for(Price_Audit_BSP__c pad:prcAdtLst){
            mrcPrcAdtIdMap.put(pad.Mrc_No__c,pad.Id);
        }
        for(integer i=0;i<prcWrpBAMVLst.size();i++){
            Price_Audit_Backbone_AMV__c prcAdtBkbnAmv= new Price_Audit_Backbone_AMV__c();
            prcAdtBkbnAmv.Additive_Cost__c=prcWrpBAMVLst[i].additiveCost;
          //  prcAdtBkbnAmv.Bio_Cost__c=prcWrpBAMVLst[i].additiveCost;
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
            prcAdtBkbnAmv.Price_Audit__c=mrcPrcAdtIdMap.get(prcWrpBAMVLst[i].mrcNo);
            prcAdtBkbnAmv.Route_Name__c=prcWrpBAMVLst[i].routeName;
            //FIX_PBI_281711_Lakshmi_26thJune2019_Starts
            prcAdtBkbnAmv.Source__c=prcWrpBAMVLst[i].source;
            //system.debug(prcAdtBkbnAmv.Source__c+'source');
            //FIX_PBI_281711_Lakshmi_26thJune2019_Ends
            prcAdtBkbnAmv.Route_Utilization__c=prcWrpBAMVLst[i].routeUtilizationPercent;
            prcAdtBkbnAmv.Third_Party__c=prcWrpBAMVLst[i].thirdParty;
            prcAdtBkbnAmv.Wasa__c=prcWrpBAMVLst[i].wasa;
            prcAdtBkbnAmv.Supplier__c = prcWrpBAMVLst[i].supplier;//Added By Dhriti
            prcAdtBkbnAmv.MOT__c=prcWrpBAMVLst[i].mot;//FIX_PBI_471288_Lakshmi_20Apr20
           
            prcAdtAMVObjLst.add(prcAdtBkbnAmv);
        }
        insert prcAdtAMVObjLst;
       
    }

}