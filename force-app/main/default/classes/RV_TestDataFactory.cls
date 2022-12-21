/*****************************************************************************
@Name:  RV_TestDataFactory     
@=========================================================================
@Purpose: Data factory class for Revolution DE
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    03-Mar-2020         INITIAL DEVELOPMENT

******************************************************************************/ 
@isTest
public class RV_TestDataFactory {
    /*Method Name	:	createSoldToCustomer
    * Date			:	03-Mar-2020
    * Developer		:	Rahul Sharma
    * Description	:	create Sold-to customer account
    */
    public static Account createSoldToCustomer(String accName, String soldToNum, Boolean hasMRC, Boolean iwoMember, Boolean availableForOLF){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Name = accName;
        acc.Customer_Type__c = 'Sold To';
        acc.Sold_To_Number__c = soldToNum;
        acc.Has_MRC__c = hasMRC;
        acc.IWO_Member__c = iwoMember;
        acc.Rv_Available_for_OLF__c = availableForOLF;
        acc.Rv_Credit_Limit__c = 100000;
        acc.Rv_Credit_Available__c = 100000;
        acc.Rv_Credit_Utilized__c = 0;
        return acc;
    }

    /*Method Name	:	createShipToCustomer
    * Date			:	03-Mar-2020
    * Developer		:	Rahul Sharma
    * Description	:	create Ship-to customer account
    */
    public static Account createShipToCustomer(Account accSoldTo, String accName, Boolean hasMRC, Boolean iwoMember, String emailId, Boolean availableForOLF, String shipToNum){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Ship_To').getRecordTypeId();
        Account acc = new Account();
        acc.ParentId = accSoldTo.Id;
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Name = accName;
        acc.Customer_Type__c = 'Ship To';
        acc.Sold_To_Number__c = accSoldTo.Sold_To_Number__c;
        acc.Ship_to_Number__c = shipToNum;
        acc.Rv_Olf_Customer_Email__c = emailId;
        acc.Has_MRC__c = hasMRC;
        acc.IWO_Member__c = iwoMember;
        acc.Rv_Available_for_OLF__c = availableForOLF;
        return acc;
    }

    /*Method Name	:	createLocation
    * Date			:	04-Mar-2020
    * Developer		:	Rahul Sharma
    * Description	:	create Ship-to customer account
    */
    public static Location__c createLocation(String locationName,String pantCode){
        Location__c loc = new Location__c();
        loc.Name = locationName != null ? locationName : 'Ludwigshafen depot';
        loc.Plant_Code__c = pantCode != null ? pantCode : 'D004';
        loc.Source_Location__c = true;
        loc.Company_Code__c = 'DE01';
        loc.OMR_Region__c = 'South West';
        loc.Sales_Region__c = 'South';
        loc.Location_Type__c = 'Shell Own Location';
        loc.Alt_Type__c='Alternate1';
        loc.Region_Name__c = 'East';
        loc.Products_Availability__c='AGO B7;IGO 50ppm;ULG95 E5';
        loc.Depot_MOT__c='Barge;ITT;Rail;TRuck';
        loc.Custom_Record_Type__c = 'Revolution';
        loc.Scenario_Type__c = 'Import;Export;Balanced';
        return loc;
    }

    /*Method Name	:	createMarginTruckITT
    * Date			:	04-Mar-2020
    * Developer		:	Rahul Sharma
    * Description	:	create Ship-to customer account
    */
    public static Margin__c createMarginTruckITT(Id locationId, String salesOrg){
        /*Variable values:
         *locationId            : Location__c.Id
         *salesOrg              : 'DE01' | 'AT01'
         */    
        Id recTypId = Schema.SObjectType.Margin__c.getRecordTypeInfosByDeveloperName().get('Truck_ITT').getRecordTypeId();
        Margin__c mgn = new Margin__c();
        mgn.Plant__c = locationId;
        mgn.Margin_Type__c = 'Truck/ITT';
        mgn.RecordTypeId = recTypId;
        mgn.AGO_B0_Sales_Margin__c = 0.3;
        mgn.AGO_B7_Sales_Margin__c = 0.4;
        mgn.AGO_CH_Sales_Margin__c  = 0.1;
        mgn.Default__c = true;
        mgn.Fixed_Surcharge_GTL_B0__c = 0.2;
        mgn.IGO_1000_Sales_Margin__c = 0.4;
        mgn.IGO_50_Sales_Margin__c = 0.3;
        mgn.Min_Mgn_AGO_B7__c = 0.2;
        mgn.Min_Mgn_IGO_50ppm__c = 0.5;
        mgn.Min_Mgn_ULG95_E5__c = 0.4;
        mgn.MOGAS_98_Sales_Margin__c = 0.2;
        mgn.MOGAS_BOB10_Sales_Margin__c = 0.4;
        mgn.MOGAS_BOB5_Sales_Margin__c = 0.2;
        mgn.MOGAS_E0_Sales_Margin__c = 0.6;
        mgn.Sales_Mgn_AGO_B7__c = 0.1;
        mgn.Sales_Mgn_IGO_50ppm__c = 0.2;
        mgn.Sales_Mgn_ULG95_E5__c = 0.3;
        mgn.Sales_Org__c = salesOrg;
        mgn.Valid_From__c = System.today();
        mgn.Valid_To__c = System.today().addDays(365);      
        return mgn;         
    }

    /*Method Name	:	createCsp
    * Date			:	04-Mar-2020
    * Developer		:	Rahul Sharma
    * Description	:	create Ship-to customer account
    */
    //START - Rahul Sharma | Date - 13-Nov-2020 : Added tranche paramter.
    public static Customer_Specific_Pricing__c createCsp(Id accountId, Id locationId, String grade, Decimal customerSpecificPrice, String salesOrg, String tranche){
        /*Variable values:
         *accountId             : Account.Id
         *locationId            : Location__c.Id
         *grade                 :   'AGO B7' | 'ULG95 E5' | 'IGO 50ppm' | 'GTL B0'
         *customerSpecificPrice : Decimal value(i.e. 3.44)
         *salesOrg              : 'DE01' | 'AT01'
         */    
        Customer_Specific_Pricing__c csp = new Customer_Specific_Pricing__c();
        csp.Account__c = accountId;
        csp.Grade__c = grade;
        csp.Plant__c = locationId;
        csp.CSP_Eur_100L__c = customerSpecificPrice;
        csp.Sales_Org__c = salesOrg;
        csp.Tranche__c = tranche;
        //END - Rahul Sharma | Date - 13-Nov-2020 : Added tranche paramter.
        return csp;
    } 

    /*Method Name	:	createMRC
    * Date			:	15-Apr-2020
    * Developer		:	Rahul Sharma
    * Description	:	create MRC record
    */
    public static MRC__c createMRC(Account soldToAcc, Account shipToAcc,  Location__c loc, Product_Catalogue__c productCat, String salesOrg){
        MRC__c mrc = new MRC__c();
        mrc.Name = '320076590-101004';
        mrc.Valid_To_Date__c  = System.today().addYears(15);
        mrc.Valid_From_Date__c  = System.today().addYears(-1);
        mrc.Sold_To__c = soldToAcc.Id;
        mrc.Ship_To__c = shipToAcc.Id;
        mrc.Plant__c = loc.Id;
        mrc.Product__c = productCat.Id;
        mrc.Sales_Organization__c = salesOrg;
        mrc.Ship_to_Number__c = shipToAcc.Ship_to_Number__c;
        mrc.Ship_to_Name__c = shipToAcc.Name;
        mrc.Ship_to_Street__c = shipToAcc.ShippingStreet;
        mrc.Ship_to_City__c  = shipToAcc.ShippingCity;
        mrc.Ship_to_State__c  = shipToAcc.ShippingState;
        mrc.Plant_Description__c = loc.Plant_Code__c+' '+loc.Name;
        mrc.Handling_Type__c = 'CA';
        mrc.PO_Type__c='TSFP';
        return mrc;
    }

    /*Method Name	:	createRevolutionSetting
    * Date			:	15-Apr-2020
    * Developer		:	Rahul Sharma
    * Description	:	create Revolution Setting
    */
    public static Revolution_Setting__c createRevolutionSetting(String settingName, String value, Boolean active, Integer startDay, Integer endDay){
        Revolution_Setting__c setting = new Revolution_Setting__c();
        setting.Name = settingName;
        setting.Value__c = value;
        setting.Active__c = active;
        setting.Start_Day__c = startDay;
        setting.End_Day__c = endDay;
        return setting;
    }

    /*Method Name	:	createCSM
    * Date			:	16-Apr-2020
    * Developer		:	Rahul Sharma
    * Description	:	create Customer Sales Management record
    */
    public static Customer_Sales_Management__c createCSM(Account soldToAcc, Location__c loc, String prodGrade, Integer dealCount){
        Customer_Sales_Management__c csm = new Customer_Sales_Management__c();
        csm.Customer__c = soldToAcc.Id;
        csm.Plant__c = loc.Id;
        csm.Product_Category__c = prodGrade;
        csm.Sales_CBM__c = 10000;
        csm.Online_Deal_Count__c = dealCount;
        return csm;
    }
}