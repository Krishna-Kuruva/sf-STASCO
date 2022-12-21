public class RV_TestHelperPhase2 {
public static Product_Catalogue__c insertProductCat(Product_Catalogue__c material){
        material.Level_0__c = 'Gasoil';
        material.Name = '400003817';
        material.Commodity_Grade_L2__c = 'ULG95_BOB_E10';
        material.Material_Name__c = 'INT ULG 95 10ppmS Udy Umk BOB E10 DE';
        return material;
    }
public static Third_Party_Contract_Master__c hydrocarbonValuesMOGAS(Location__c loc,Third_Party_Contract_Master__c hydro,boolean isThirdParty)
    {
        hydro=new Third_Party_Contract_Master__c();
        hydro.Additive_provider__c='Shell';
        hydro.Additive_surcharge__c=0.63;
        hydro.Depot__c=loc.Id;
        hydro.Source__c=loc.Id;
        hydro.Alternate_Type__c='';
        hydro.Average_Multiplier_Quote__c='';
        hydro.Average_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Average_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Base_Quote_1_Percent__c=93.2;
        hydro.Base_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Bio_Quotes__c=' Argus Biodiesel RED FAME -10°C CFPP FOB ARA (mean)';
        hydro.Bio_Quote__c=6.8;
        hydro.Bio_surcharge__c=9;
        hydro.Contract__c='';
       // hydro.Counterparty__c='';
        hydro.Differential_Quote_1_Percent__c=0;
        hydro.Differential_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Differential_Quote_2_Percent__c=0;
        hydro.Differential_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Differential_Quote_3_Percent__c=0;
        hydro.Differential_Quote_3__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Differential_Quote_4_Percent__c=0;
        hydro.Differential_Quote_4__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';  
   		hydro.Frieight_Quote_per__c=100;
    	hydro.Frieight_Quote__c='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne';
 		hydro.Future_Calculation__c='';
 		hydro.Grade__c='ULG95 E5';
 		hydro.isThirdParty__c=isThirdParty;
 		hydro.Loc_Diff__c=11.5;
 		hydro.MoT_Purchase__c='Truck';
 		hydro.Product_sub_grade__c='MOGAS';    
 		hydro.SalesOrg_Customer__c='DE01';
 		hydro.Shell_Owned_Type__c='';
	 // hydro.Source__c=;
//PBI_166252_DataCleanup_Lakshmi_1stOct2019
	  //hydro.Std_Material__c='400001685';
 		hydro.Supplement_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
 		hydro.Supplement_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';     
 		//hydro.Supply_Route_ID__c='MOGAS-E5_Shell_ARA_Barge_Ludwigshafen';//FIX_470189_Lakshmi_30Apr2020
 		hydro.Supplier__c='Shell';//FIX_470189_Lakshmi_30Apr2020            
 		hydro.Thruput_charge__c=0;
	 	hydro.Valid_From__c=System.today();
 		hydro.Valid_To__c=System.today()+1;

     return hydro;   
 }
public static Third_Party_Contract_Master__c hydrocarbonValuesIGO50ppm(Location__c loc,Third_Party_Contract_Master__c hydro,String type)
    {
        
         hydro=new Third_Party_Contract_Master__c();
        hydro.Additive_provider__c='Shell';
            hydro.Additive_surcharge__c=0.63;
        hydro.Depot__c=loc.Id;
        hydro.Source__c=loc.Id;
         hydro.Alternate_Type__c=type;
        hydro.Average_Multiplier_Quote__c='';
        hydro.Average_Quote_1__c='ICE LGO Low Sulfur Gasoil';
        hydro.Average_Quote_2__c='';
        hydro.Base_Quote_1_Percent__c=93.2;
        hydro.Base_Quote_1__c='Platts FOB Barge R\'dam Diesel 10ppm (high)';
        hydro.Bio_Quotes__c='Platts FOB ARA NWE RED FAME-10 (high)';
        hydro.Bio_Quote__c=6.8;
        hydro.Bio_surcharge__c=9;
        hydro.Contract__c='';
      //  hydro.Counterparty__c='';
        hydro.Differential_Quote_1_Percent__c=100;
         hydro.Differential_Quote_1__c='Platts CIF Cargo NWE ULSD 10ppm (high)';
          hydro.Differential_Quote_2_Percent__c=100;
         hydro.Differential_Quote_2__c='Platts FOB Barge R\'dam Diesel 10ppm (high)';
          hydro.Differential_Quote_3_Percent__c=0;
         hydro.Differential_Quote_3__c='';
          hydro.Differential_Quote_4_Percent__c=0;
         hydro.Differential_Quote_4__c='';  
    hydro.Frieight_Quote_per__c=100;
    hydro.Frieight_Quote__c='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne';
 hydro.Future_Calculation__c='';
 hydro.Grade__c='IGO 50ppm';
 hydro.isThirdParty__c=false;
 hydro.Loc_Diff__c=11.5;
 hydro.MoT_Purchase__c='';
 hydro.Product_sub_grade__c='IGO';
 hydro.SalesOrg_Customer__c='';
 hydro.Shell_Owned_Type__c='Cargo';
// hydro.Source__c=;
//PBI_166252_DataCleanup_Lakshmi_1stOct2019
 //hydro.Std_Material__c='400001685';
 hydro.Supplement_Quote_1__c='ICE LGO Low Sulfur Gasoil (settlement)';
 hydro.Supplement_Quote_2__c='';
// hydro.Supply_Route_ID__c='IGO-50_ENI_Neustadt_Truck_Neustadt';//FIX_470189_Lakshmi_30Apr2020  
 hydro.Supplier__c='ENI';//FIX_470189_Lakshmi_30Apr2020  
 hydro.Thruput_charge__c=0;
 hydro.Valid_From__c=System.today();
 hydro.Valid_To__c=System.today()+1;

        return hydro;
        
    }
public static Third_Party_Contract_Master__c hydrocarbonValuesAGOIGO(Location__c loc,Third_Party_Contract_Master__c hydro,Boolean isThirdParty)
    {
        
         hydro=new Third_Party_Contract_Master__c();
        hydro.Additive_provider__c='Shell';
            hydro.Additive_surcharge__c=0.63;
        hydro.Depot__c=loc.Id;
        hydro.Source__c=loc.Id;
         hydro.Alternate_Type__c='';
        hydro.Average_Multiplier_Quote__c='';
        hydro.Average_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Average_Quote_2__c='';
        hydro.Base_Quote_1_Percent__c=93.2;
        hydro.Base_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
        hydro.Bio_Quotes__c=' Argus Biodiesel RED FAME -10°C CFPP FOB ARA (mean)';
        hydro.Bio_Quote__c=6.8;
        hydro.Bio_surcharge__c=9;
        hydro.Contract__c='';
       // hydro.Counterparty__c='';
        hydro.Differential_Quote_1_Percent__c=0;
         hydro.Differential_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
          hydro.Differential_Quote_2_Percent__c=0;
         hydro.Differential_Quote_2__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
          hydro.Differential_Quote_3_Percent__c=0;
         hydro.Differential_Quote_3__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
          hydro.Differential_Quote_4_Percent__c=0;
         hydro.Differential_Quote_4__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';  
    hydro.Frieight_Quote_per__c=100;
    hydro.Frieight_Quote__c='Reuters (PJK) Rhine Freight Gasoil ARA-Cologne';
 hydro.Future_Calculation__c='';
 hydro.Grade__c='AGO B7';
 hydro.isThirdParty__c=isThirdParty;
 hydro.Loc_Diff__c=11.5;
 hydro.MoT_Purchase__c='';
 hydro.Product_sub_grade__c='AGO';
 hydro.SalesOrg_Customer__c='DE01';
 hydro.Shell_Owned_Type__c='Cargo';
// hydro.Source__c=;
//PBI_166252_DataCleanup_Lakshmi_1stOct2019
 //hydro.Std_Material__c='400001685';
 hydro.Supplement_Quote_1__c='Reuters (PJK) Rhine Freight Gasoil ARA-Karlsruhe';
 hydro.Supplement_Quote_2__c='';
 //hydro.Supply_Route_ID__c='AGO-B7_Shell_ARA_Barge_Ludwigshafen';//FIX_470189_Lakshmi_30Apr2020
 hydro.Supplier__c='Shell';//FIX_470189_Lakshmi_30Apr2020 
 hydro.Thruput_charge__c=0;
 hydro.Valid_From__c=System.today();
 hydro.Valid_To__c=System.today()+1;

     return hydro;    
        
    }
    public static Location__c insertLocationLudwigshafen(Location__c loc){
        
        loc.Name = 'Ludwigshafen depot';
        loc.Plant_Code__c = 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'South West';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Shell Own Location';
        loc.Depot_MOT__c='Truck;Rail';
        loc.Region_Name__c = 'East';
        loc.Products_Availability__c = 'AGO B7;IGO 50ppm;ULG95 E5';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        return loc;
    }
    public static Location__c insertLocationKarlsruhe(Location__c loc){
        
        loc.Name = 'Karlsruhe MiRO refinery';
        loc.Plant_Code__c = 'D029';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'South West';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Shell Own Location';
        loc.Products_Availability__c = 'AGO B7;IGO 50ppm;ULG95 E5';
        loc.Region_Name__c = 'East';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        return loc;
    }
    public static Location__c insertLocationTBG(Location__c loc){
        
        loc.Name = 'Salzburg TBG depot';
        loc.Plant_Code__c = 'A004';
        loc.Source_Location__c = false;
        loc.Company_Code__c = 'AT01';
        loc.OMR_Region__c = 'Austria';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Depot Location';
        loc.Products_Availability__c = 'AGO B7;IGO 50ppm;ULG95 E5';
        loc.Region_Name__c = 'East';
        loc.Depot_MOT__c='Truck;Rail';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        return loc;
    }
    public static Freight_Rate__c insertFreightRate(Freight_Rate__c freightRate,Location__c srcLoc,Location__c desLoc){
        //freightRate.Name='AGO-B7_Shell_ARA_Barge_Ludwigshafen';//Fix_493485_Lakshmi_27Apr2020
        freightRate.Route_Utilization__c = 7.5;
        freightRate.Source__c = srcLoc.Id;
        freightRate.Destination__c = desLoc.Id;
        freightRate.Standard_Grade__c = 'AGO B7';
        freightRate.SubGrade_3P__c = 'AGO B7';
        freightRate.Mode_Of_Transport__c = 'Barge';
        freightRate.Freight_Cost__c = 'Variable';
        freightRate.Freight_Percentage__c = 86.46;
        freightRate.Freight_diff_EUR_mt__c = 5;
        freightRate.Supplier__c = 'Shell';
        freightRate.Valid_From__c = System.today();
        freightRate.Valid_From__c = System.today().addDays(365);
        return freightRate;
    }
    public static Location_Steer__c insertorgSteerARAAGO(Location_Steer__c orgSteerARAAGO,String orgRecordTypeId){
         orgSteerARAAGO.Origination_Steer_Type__c = 'ARA AGO Steer';
         orgSteerARAAGO.RecordTypeId = orgRecordTypeId;
         orgSteerARAAGO.Steer_Value__c = 12;
         orgSteerARAAGO.Default__c  = true;
         return orgSteerARAAGO;
    }
    public static Location_Steer__c insertorgSteerARAIGO(Location_Steer__c orgSteerARAIGO,String orgRecordTypeId){
         orgSteerARAIGO.Origination_Steer_Type__c = 'ARA IGO Steer';
         orgSteerARAIGO.RecordTypeId = orgRecordTypeId;
         orgSteerARAIGO.Steer_Value__c = 12;
         orgSteerARAIGO.Default__c  = true;
         return orgSteerARAIGO;
    }
    public static Location_Steer__c insertorgSteerHarburgAGO(Location_Steer__c orgSteerHarburgAGO,String orgRecordTypeId){
         orgSteerHarburgAGO.Origination_Steer_Type__c = 'Harburg AGO Steer';
         orgSteerHarburgAGO.RecordTypeId = orgRecordTypeId;
         orgSteerHarburgAGO.Steer_Value__c = 12;
         orgSteerHarburgAGO.Default__c  = true;
         return orgSteerHarburgAGO;
    }
    public static Location_Steer__c insertorgSteerHarburgIGO(Location_Steer__c orgSteerHarburgIGO,String orgRecordTypeId){
         orgSteerHarburgIGO.Origination_Steer_Type__c = 'Harburg IGO Steer';
         orgSteerHarburgIGO.RecordTypeId = orgRecordTypeId;
         orgSteerHarburgIGO.Steer_Value__c = 12;
         orgSteerHarburgIGO.Default__c = true;
         return orgSteerHarburgIGO;
    }
    public static Location_Steer__c insertsrcSteer(Location_Steer__c srcSteer,String sourceRecordTypeId,Location__c locinsert){
         srcSteer.RecordTypeId = sourceRecordTypeId;
         srcSteer.Plant__c = locinsert.Id;
         srcSteer.Scenario__c = 'Import';
         srcSteer.Product_Sub_Group__c = 'AGO B7';
         srcSteer.Valid_From__c = System.today();
         srcSteer.Valid_To__c   = System.today().addDays(365);
         srcSteer.Default__c = true;
         return srcSteer;
    }
    public static Location_Steer__c insertsrcSteer1(Location_Steer__c srcSteer,String sourceRecordTypeId,Location__c locinsert){
         srcSteer.RecordTypeId = sourceRecordTypeId;
         srcSteer.Plant__c = locinsert.Id;
         srcSteer.Scenario__c = 'Balanced';
         srcSteer.Product_Sub_Group__c = 'IGO 50ppm';
         srcSteer.Valid_From__c = System.today();
         srcSteer.Valid_To__c   = System.today().addDays(365);
         srcSteer.Default__c = true;
         return srcSteer;
    }
    public static Location_Steer__c insertsrcSteer2(Location_Steer__c srcSteer,String sourceRecordTypeId,Location__c
                                                    locinsert){
         srcSteer.RecordTypeId = sourceRecordTypeId;
         srcSteer.Plant__c = locinsert.Id;
         srcSteer.Scenario__c = 'Export';
         srcSteer.Product_Sub_Group__c = 'ULG95 E5';
         srcSteer.Valid_From__c = System.today();
         srcSteer.Valid_To__c   = System.today().addDays(365);
         srcSteer.Default__c = true;
         return srcSteer;
    }
    public static Location_Steer__c insertOrgSteer1(Location_Steer__c srcSteer,String sourceRecordTypeId,
                                                    Location__c locinsert){
         srcSteer.RecordTypeId = sourceRecordTypeId;
         srcSteer.Plant__c = locinsert.Id;
         srcSteer.Scenario__c = 'Balanced';
         srcSteer.Product_Sub_Group__c = 'IGO 50ppm';
         srcSteer.MOT__c = 'ITT';                                             
         srcSteer.Valid_From__c = System.today();
         srcSteer.Valid_To__c   = System.today().addDays(365);
         srcSteer.Default__c = true;
         return srcSteer;
    }
    public static Bio_AMVs__c insertBioAmv(Bio_AMVs__c bioAmv,Location__c depLoc){
        bioAmv.Plant__c=depLoc.id;
        bioAmv.AGO_B7_m_Future__c=10;
        bioAmv.AGO_B7_m_Prompt__c=9;
        bioAmv.Sales_Org__c='DE01';
        bioAmv.ULG_95_E10_m_Future__c=8;
        bioAmv.ULG_95_E10_m_Prompt__c=9;
        bioAmv.ULG_95_E5_m_Future__c=10;
        bioAmv.ULG_95_E5_m_Prompt__c=9;
        bioAmv.ULG_98_m_Future__c=7;
        bioAmv.ULG_98_m_Prompt__c=11;
        bioAmv.Prompt_Valid_From__c=system.today();
        bioAmv.Prompt_valid_To__c=system.today().addDays(28);
        bioAmv.Future_Valid_From__c=system.today().addDays(61);
        bioAmv.Future_Valid_To__c=system.today().addDays(365);
        return bioAmv;
    }
    public static Throughput__c insertThroughput(Throughput__c thpt,location__c loc){
		thpt.Apply_Throughput__c='Yes';
        thpt.MOT__c='Truck';
        thpt.Plant__c=loc.Id;
        thpt.Product_Sub_Grade__c='AGO B7';
        thpt.Standard_grade__c='AGO B7';
        thpt.Throughput_Cost__c=0.28;
        return thpt;
    }
    public static Margin__c insertMargin(Margin__c mgn,location__c loc,String recdTypId){
        mgn.Plant__c=loc.Id;
        mgn.Margin_Type__c='Truck/ITT';
        mgn.RecordTypeId=recdTypId;
        mgn.AGO_B0_Sales_Margin__c=0.3;
        mgn.AGO_B7_Sales_Margin__c=0.4;
        mgn.AGO_CH_Sales_Margin__c=0.1;
        mgn.Default__c=true;
        mgn.Fixed_Surcharge_GTL_B0__c=0.2;
        mgn.IGO_1000_Sales_Margin__c=0.4;
        mgn.IGO_50_Sales_Margin__c=0.3;
        mgn.Min_Mgn_AGO_B7__c=0.2;
        mgn.Min_Mgn_IGO_50ppm__c=0.5;
        mgn.Min_Mgn_ULG95_E5__c=0.4;
        mgn.MOGAS_98_Sales_Margin__c=0.2;
        mgn.MOGAS_BOB10_Sales_Margin__c=0.4;
        mgn.MOGAS_BOB5_Sales_Margin__c=0.2;
        mgn.MOGAS_E0_Sales_Margin__c=0.6;
        mgn.Sales_Mgn_AGO_B7__c=0.1;
        mgn.Sales_Mgn_IGO_50ppm__c=0.2;
        mgn.Sales_Mgn_ULG95_E5__c=0.3;
        mgn.Sales_Org__c='DE01';
        mgn.Valid_From__c=system.today();
        mgn.Valid_To__c=system.today().addDays(365);
        
       return mgn; 
    }
    
    
}