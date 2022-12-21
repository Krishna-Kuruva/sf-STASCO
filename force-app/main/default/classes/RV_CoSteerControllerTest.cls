@isTest
public class RV_CoSteerControllerTest { 
    static testmethod void getLocationSteer(){
       
        //Insert Location
        Location__c  loc = new Location__c();
        RV_TestHelperPhase2.insertLocationLudwigshafen(loc);
        insert loc; 
        
        Product_Catalogue__c prdtCat = new Product_Catalogue__c();
        Product_Catalogue__c insertProductCat = RV_TestHelper.insertProductCat(prdtCat);
        insert insertProductCat;
        
        BSP_Trends__c bspTrends = new BSP_Trends__c();
        bspTrends.Location_Name__c = loc.Id;
		bspTrends.Material__c = insertProductCat.Id;
        bspTrends.Depot_Steer__c = 10;
        bspTrends.Shipping_Condition__c = 10;
        bspTrends.Sales_Org__c = 'D001';
        bspTrends.Mrc_No__c = 'MRCXXD002-000001';
        insert bspTrends;
        
        Backbone_Trends__c bckboneago = new Backbone_Trends__c();
        bckboneago.CO_Steer__c = 10;
        bckboneago.Route_Name__c = 'AGO-B7_MOL_Lobau_Barge_Lobau';
        bckboneago.Route_Utilization__c = 50;
        bckboneago.Daily_BSP_Trends__c = bspTrends.Id;
        bckboneago.FreightToSource__c = 20;
        bckboneago.Route_Utilization__c = 40;
        insert bckboneago;
        
        Backbone_Trends__c bckboneago1 = new Backbone_Trends__c();
        bckboneago1.CO_Steer__c = 10;
        bckboneago1.Route_Name__c = 'AGO-B7_Shell_Schwedt-PCK_Rail_Lobau';
        bckboneago1.Route_Utilization__c = 30;
        bckboneago1.Daily_BSP_Trends__c = bspTrends.Id;
        bckboneago.FreightToSource__c = 0.9;
        bckboneago.Route_Utilization__c = 40;
        insert bckboneago1;
        
        Backbone_Trends__c bckboneago2 = new Backbone_Trends__c();
        bckboneago2.CO_Steer__c = 10;
        bckboneago2.Route_Name__c = 'AGO-B7_OMV_Lobau_Rail_Lobau';
        bckboneago2.Route_Utilization__c = 20;
        bckboneago2.Daily_BSP_Trends__c = bspTrends.Id;
        bckboneago.FreightToSource__c = 40;
        bckboneago.Route_Utilization__c = 20;
        insert bckboneago2;
        
        Location__c  locDep = new Location__c();
        RV_TestHelperPhase2.insertLocationTBG(locDep);
        insert locDep;
        
        //Insert Location Steer
        Id RecordTypeIdLocStrSrc = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Source Steer').getRecordTypeId();
        Id RecordTypeIdLocStrDep = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Depot Steer').getRecordTypeId();
        Id RecordTypeIdLocStrOrg = Schema.SObjectType.Location_Steer__c.getRecordTypeInfosByName().get('Origination Steer').getRecordTypeId();
        
        //Origination Steer
        Location_Steer__c locOrgARAAGO= new Location_Steer__c();
        locOrgARAAGO=RV_TestHelperPhase2.insertorgSteerARAAGO(locOrgARAAGO,RecordTypeIdLocStrOrg);
        locOrgARAAGO.Valid_From__c=system.today();
        locOrgARAAGO.Valid_To__c= system.today().addDays(365);
        insert locOrgARAAGO;
        
        Location_Steer__c locOrgARAIGO= new Location_Steer__c();
        locOrgARAIGO=RV_TestHelperPhase2.insertorgSteerARAIGO(locOrgARAIGO,RecordTypeIdLocStrOrg);
        locOrgARAIGO.Valid_From__c=system.today();
        locOrgARAIGO.Valid_To__c= system.today().addDays(365);
        insert locOrgARAIGO;
        
        Location_Steer__c locOrgHarburgAGO= new Location_Steer__c();
        locOrgHarburgAGO=RV_TestHelperPhase2.insertorgSteerHarburgAGO(locOrgHarburgAGO,RecordTypeIdLocStrOrg);
        locOrgHarburgAGO.Valid_From__c=system.today();
        locOrgHarburgAGO.Valid_To__c= system.today().addDays(365);
        insert locOrgHarburgAGO;
        
        Location_Steer__c locOrgHarburgIGO= new Location_Steer__c();
        locOrgHarburgIGO=RV_TestHelperPhase2.insertorgSteerHarburgIGO(locOrgHarburgIGO,RecordTypeIdLocStrOrg);
        locOrgHarburgIGO.Valid_From__c=system.today();
        locOrgHarburgIGO.Valid_To__c= system.today().addDays(365);
        insert locOrgHarburgIGO;
            
		//Source Steer
		
        Location_Steer__c locSrcAgo= new Location_Steer__c();
        locSrcAgo=RV_TestHelperPhase2.insertsrcSteer(locSrcAgo,RecordTypeIdLocStrSrc,loc);
        locSrcAgo.Valid_From__c=system.today();
        locSrcAgo.Valid_To__c=system.today().addDays(365);
        locSrcAgo.Default__c=true;
        insert locSrcAgo;
        
        Location_Steer__c locSrcIgo= new Location_Steer__c();
        locSrcIgo=RV_TestHelperPhase2.insertsrcSteer1(locSrcIgo,RecordTypeIdLocStrSrc,loc);
        locSrcIgo.Valid_From__c=system.today();
        locSrcIgo.Valid_To__c=system.today().addDays(365);
        locSrcIgo.Default__c=true;
        insert locSrcIgo;
        
        Location_Steer__c locSrcUlg= new Location_Steer__c();
        locSrcUlg=RV_TestHelperPhase2.insertsrcSteer2(locSrcUlg,RecordTypeIdLocStrSrc,loc);
        locSrcUlg.Valid_From__c=system.today();
        locSrcUlg.Valid_To__c=system.today().addDays(365);
        locSrcUlg.Default__c=true;
        insert locSrcUlg;

		//Depot Steer
		Location_Steer__c locDepStrAgo = new Location_Steer__c();
        locDepStrAgo=RV_TestHelperPhase2.insertsrcSteer(locDepStrAgo,RecordTypeIdLocStrDep,locDep);
        locDepStrAgo.MOT__c='Truck';
        locDepStrAgo.Depot_Steer__c=10;
        locDepStrAgo.Scenario__c='';
        locDepStrAgo.Valid_From__c=system.today();
        locDepStrAgo.Valid_To__c=system.today().addDays(365);
        locDepStrAgo.Default__c=true;
        insert locDepStrAgo;
        
        Location_Steer__c locDepStrIgo = new Location_Steer__c();
        locDepStrIgo=RV_TestHelperPhase2.insertsrcSteer1(locDepStrIgo,RecordTypeIdLocStrDep,locDep);
        locDepStrIgo.MOT__c='Truck';
        locDepStrIgo.Depot_Steer__c=11;
        locDepStrIgo.Scenario__c='';
        locDepStrIgo.Valid_From__c=system.today();
        locDepStrIgo.Valid_To__c=system.today().addDays(365);
        locDepStrIgo.Default__c=true;
        insert locDepStrIgo;
        
        Location_Steer__c locDepStrUlg = new Location_Steer__c();
        locDepStrUlg=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlg,RecordTypeIdLocStrDep,locDep);
        locDepStrUlg.MOT__c='Truck';
        locDepStrUlg.Depot_Steer__c=12;
        locDepStrUlg.Scenario__c='';
        locDepStrUlg.Valid_From__c=system.today();
        locDepStrUlg.Valid_To__c=system.today().addDays(365);
        locDepStrUlg.Default__c=true;
        insert locDepStrUlg; 
        
        Location_Steer__c locDepStrUlgOvrRdn = new Location_Steer__c();
        locDepStrUlgOvrRdn=RV_TestHelperPhase2.insertsrcSteer2(locDepStrUlgOvrRdn,RecordTypeIdLocStrDep,locDep);
        locDepStrUlgOvrRdn.MOT__c='Truck';
        locDepStrUlgOvrRdn.Depot_Steer__c=12;
        locDepStrUlgOvrRdn.Scenario__c='';
        locDepStrUlgOvrRdn.Valid_From__c=system.today();
        locDepStrUlgOvrRdn.Valid_To__c=system.today().addDays(10);
        locDepStrUlgOvrRdn.Default__c=false;
        insert locDepStrUlgOvrRdn;
        
        test.startTest();
        RV_CoSteerController.getLocationSteer('AGO B7','AGO B7','Truck','All',false,string.valueOf(system.today()));
        RV_CoSteerController.getLocationSteer('ULG95 E5','ULG95 E5','Truck','All',false,string.valueOf(system.today()));
        RV_CoSteerController.getLocationSteer('ULG95 E5','ULG95 E5','Truck','All',true,string.valueOf(system.today()));
        RV_CoSteerController.getLocationSteer('AGO B7','AGO B7','Truck','All',false,null);
        RV_CoSteerController.getOrgSteerLst();
        RV_CoSteerController.fetchDailyPricingTrend(system.today(),'All','AGO B7');
        test.stopTest();
    }
}