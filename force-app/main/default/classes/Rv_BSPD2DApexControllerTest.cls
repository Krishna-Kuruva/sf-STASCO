@isTest
public class Rv_BSPD2DApexControllerTest {

    @isTest
    static void doTest(){
        //START - Rahul Sharma | Date - 27-Nov-2020 : Utilized code to reduce DML commits.
        List<Product_Catalogue__c> matList = new List<Product_Catalogue__c>();
        List<BSP_Trends__c> bspTrendList = new List<BSP_Trends__c>();
        List<Backbone_Trends__c> bckBoneList = new List<Backbone_Trends__c>();
        
        Location__c loc = new Location__c();
        loc = RV_TestHelper.insertLocation(loc);
        insert loc;  
        
        Product_Catalogue__c mat = new Product_Catalogue__c();
        mat = RV_TestHelper.insertProductCat(mat);
        //insert mat;
        matList.add(mat);     
        //Product_Catalogue__c mat2 = mat.clone(false, false, false, false);
        Product_Catalogue__c mat2 = new Product_Catalogue__c();
        mat2 = RV_TestHelper.insertProductCat(mat2);
        mat2.Commodity_Grade_L2__c = 'IGO 50ppm';
        //insert mat2;
        matList.add(mat2);     
        //Product_Catalogue__c mat3 = mat.clone(false, false, false, false);
        Product_Catalogue__c mat3 = new Product_Catalogue__c();
        mat3 = RV_TestHelper.insertProductCat(mat3);
        mat3.Commodity_Grade_L2__c = 'AGO B7';
        //insert mat3;
        matList.add(mat3);     
        //Product_Catalogue__c mat4 = mat.clone(false, false, false, false);
        Product_Catalogue__c mat4 = new Product_Catalogue__c();
        mat4 = RV_TestHelper.insertProductCat(mat4);
        mat4.Commodity_Grade_L2__c = 'ULG95 E5';
        //insert mat4;
        matList.add(mat4);
        insert matList;
        
        BSP_Trends__c bsp = new BSP_Trends__c();
        bsp.Location_Name__c = loc.id;
        bsp.Sales_Org__c = loc.Company_Code__c;
        bsp.Material__c = mat.id;
        bsp.Calcualated_BSP__c = 100;
        bsp.Depot_Steer__c = 1;
        bsp.Min_Margin__c = 0.1;
        bsp.Shipping_Condition__c = 10;
        bsp.Tranche__c = 'ATP1';
        //insert bsp;
        bspTrendList.add(bsp);
        BSP_Trends__c bsp2 = new BSP_Trends__c();
        bsp2.Location_Name__c = loc.id;
        bsp2.Sales_Org__c = loc.Company_Code__c;
        bsp2.Material__c = mat2.id;
        bsp2.Calcualated_BSP__c = 100;
        bsp2.Depot_Steer__c = 1;
        bsp2.Min_Margin__c = 0.1;
        bsp2.Shipping_Condition__c = 10;
        bsp2.Tranche__c = 'ATP1';
        //insert bsp2;
        bspTrendList.add(bsp2);       
        BSP_Trends__c bsp3 = new BSP_Trends__c();
        bsp3.Location_Name__c = loc.id;
        bsp3.Sales_Org__c = loc.Company_Code__c;
        bsp3.Material__c = mat3.id;
        bsp3.Calcualated_BSP__c = 100;
        bsp3.Depot_Steer__c = 1;
        bsp3.Min_Margin__c = 0.1;
        bsp3.Shipping_Condition__c = 10;
        bsp3.Tranche__c = 'ATP1';
        bspTrendList.add(bsp3);
        //insert bsp3;       
        BSP_Trends__c bsp4 = new BSP_Trends__c();
        bsp4.Location_Name__c = loc.id;
        bsp4.Sales_Org__c = loc.Company_Code__c;
        bsp4.Material__c = mat4.id;
        bsp4.Calcualated_BSP__c = 100;
        bsp4.Depot_Steer__c = 1;
        bsp4.Min_Margin__c = 0.1;
        bsp4.Shipping_Condition__c = 10;
        bsp4.Tranche__c = 'ATP1';
        bspTrendList.add(bsp4);
        //insert bsp4;
        insert bspTrendList;
        
        Backbone_Trends__c backBone = new Backbone_Trends__c();
        backBone.Daily_BSP_Trends__c = bsp.id;
        backBone.HCV__c = 400;
        backBone.CO_Steer__c = 2;
        backBone.Bio_Cost__c = 0.3;
        backBone.FreightToDepot__c = 300;
        backBone.Route_Utilization__c = 50;
        //insert backBone;
        bckBoneList.add(backBone);        
        Backbone_Trends__c backBone2 = new Backbone_Trends__c();
        backBone2.Daily_BSP_Trends__c = bsp2.id;
        backBone2.HCV__c = 400;
        backBone2.CO_Steer__c = 2;
        backBone2.Bio_Cost__c = 0.3;
        backBone2.FreightToDepot__c = 300;
        backBone2.Route_Utilization__c = 50;
        bckBoneList.add(backBone2);
        //insert backBone2;       
        Backbone_Trends__c backBone3 = new Backbone_Trends__c();
        backBone3.Daily_BSP_Trends__c = bsp3.id;
        backBone3.HCV__c = 400;
        backBone3.CO_Steer__c = 2;
        backBone3.Bio_Cost__c = 0.3;
        backBone3.FreightToDepot__c = 300;
        backBone3.Route_Utilization__c = 50;
        bckBoneList.add(backBone3);
        //insert backBone3;       
        Backbone_Trends__c backBone4 = new Backbone_Trends__c();
        backBone4.Daily_BSP_Trends__c = bsp4.id;
        backBone4.HCV__c = 400;
        backBone4.CO_Steer__c = 2;
        backBone4.Bio_Cost__c = 0.3;
        backBone4.FreightToDepot__c = 300;
        backBone4.Route_Utilization__c = 50;
        bckBoneList.add(backBone4);
        //insert backBone4;        
        Backbone_Trends__c backBone5 = new Backbone_Trends__c();
        backBone5.Daily_BSP_Trends__c = bsp4.id;
        backBone5.HCV__c = 400;
        backBone5.CO_Steer__c = 2;
        backBone5.Bio_Cost__c = 0.3;
        backBone5.FreightToDepot__c = 300;
        backBone5.Route_Utilization__c = 50;
        bckBoneList.add(backBone5);
        //insert backBone5;
        insert bckBoneList;
        //END - Rahul Sharma | Date - 27-Nov-2020 : Utilized code to reduce DML commits.
        
        String today = String.valueOf(System.today());
        Rv_BSPD2DApexController.pageWrapper pg = Rv_BSPD2DApexController.getPageData(today, today, 'ATP1', 'DE');	//Rahul Sharma | Date : 27-Nov-2020 : Fixed Code Coverage.
    }
}