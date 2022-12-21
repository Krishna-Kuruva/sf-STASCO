/* ****************************************************************************************************************
* Class Name 	: RE_TestDataFactory
* Created Date	: 07-Sep-2022
* Purpose		: DataFactory class for test class data creation
* Imporant Note : ***** PLEASE ADD ANY MANDATORY FIELDS AS REQUIRED IN FUTURE FOR THE EASE OF OTHERS *****
* Author        : K. Nandeeswara Raju (n.kondur@shell.com)
* Modification#1: Name  - Date  - Description
* *****************************************************************************************************************/
@isTest
public class RE_TestDataFactory {

    public static User createUser(String frstName, String lastName, Id userRoleId, Id profileId){
        User u	= new User();
        u.LastName		= lastName;
        u.FirstName	    = frstName;
        u.Alias		    = frstName.substring(0, 2)+'t';
        u.Email		    = frstName+lastName+'@mail.com';
        u.Username		= frstName+lastName+'@mail.com.reveast';
        u.CommunityNickname	= frstName+'Nickname';
        u.UserRoleId	= userRoleId;
        u.TimeZoneSidKey    = 'America/Los_Angeles';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey  = 'en_US';
        u.ProfileId	    = profileId;
        return u;
    }

    //Create RE_Product__c records
    public static RE_Product__c createREProduct(String reProdName, Id reProdCountryId, Id reProdRecTypeId){
        RE_Product__c prod = new RE_Product__c ();
        prod.Name           = reProdName;
        prod.RE_Country__c  = reProdCountryId;
        prod.RecordTypeId   = reProdRecTypeId;
        return prod;
    }

    //Create RE_SG_CostPrice__c records
    public static RE_SG_CostPrice__c createRESGCostPrice(Boolean reIsLatestBool, Datetime rePricingDate){
        RE_SG_CostPrice__c sgcp = new RE_SG_CostPrice__c ();
        sgcp.RE_IsLatest__c     = reIsLatestBool;
        sgcp.RE_Pricing_Date__c = rePricingDate;
        return sgcp;
    }

    //Create RE_Market_Quotes__c records
    public static RE_Market_Quotes__c createREMarketQuote(Decimal rePrice, String reQuoteName, Date rePricingDate, String reTracker){
        RE_Market_Quotes__c mq = new RE_Market_Quotes__c ();
        mq.RE_Price__c          = rePrice;
        mq.RE_Quote_Name__c     = reQuoteName;
        mq.RE_Pricing_Date__c   = rePricingDate;
        mq.RE_Tracker__c        = reTracker;
        mq.RE_Country_Name__c   = 'SG;PH;TH;MY';
        return mq;
    }

    //Create RE_MY_Output__c records
    public static RE_MY_Output__c createREMyOutput(String reRegion, Integer reJobRunCount, String reType, String reDepotName, Boolean reIsLatest, Date rePricingDate){
        RE_MY_Output__c op = new RE_MY_Output__c ();
        op.RE_Region__c         = reRegion;
        op.RE_Job_Run_Count__c  = reJobRunCount;
        op.RE_Type__c           = reType;
        op.RE_Depot_Name__c     = reDepotName;
        op.RE_IsLatest__c       = reIsLatest;
        op.RE_Pricing_Date__c   = rePricingDate;
        return op;
    }

    //Create RE_Depot_Pricing_Backbone__c records
    public static RE_Depot_Pricing_Backbone__c createREDepotPricingBackBone(Id reCountryId, Id recordTypeId, Id reDepotId, Id reProdId, Date validFrom, Date validTo){
        RE_Depot_Pricing_Backbone__c dpb = new RE_Depot_Pricing_Backbone__c ();
        dpb.RE_Country__c   = reCountryId;
        dpb.RecordTypeId    = recordTypeId;
        dpb.RE_Depot_Name__c = reDepotId;
        dpb.RE_Product_Name__c  = reProdId;
        dpb.RE_Valid_From__c= validFrom;
        dpb.RE_Valid_To__c  = validTo;
        return dpb;
    }

    //Create RE_FX_Rates__c record
    public static RE_FX_Rates__c createREFxRate(String reForexName, Decimal reForexRate, String reBaseUnit, String reConversionUnit, DateTime rePricingDateTime, String reTradeType, String reTracker){
        RE_FX_Rates__c fr = new RE_FX_Rates__c ();
        fr.RE_Forex_Name__c = reForexName;
        fr.RE_Forex_Rate__c = reForexRate;
        fr.RE_Base_Unit__c = reBaseUnit;
        fr.RE_Conversion_Unit__c = reConversionUnit;
        fr.RE_Pricing_Date__c = rePricingDateTime;
        fr.RE_Trade_Type__c   = reTradeType;
        fr.RE_Tracker__c      = reTracker;
        return fr;
    }

    //Create RE_Sales_Tax__c record
    public static RE_Sales_Tax__c createRESalesTax(String reProdType, String reTaxUnit, String reRegion, Date reValidFrom, Date reValidTo, Date rePublishDate){
        RE_Sales_Tax__c st = new RE_Sales_Tax__c();
        st.RE_Product_Type__c   = reProdType;
        st.RE_Tax_Unit__c       = reTaxUnit;
        st.RE_Region__c         = reRegion;
        st.RE_Valid_From__c     = reValidFrom;
        st.RE_Valid_To__c       = reValidTo;
        st.RE_Publish_Date__c   = rePublishDate;
        return st;
    }

    //Create RE_Rate_Unit_Manager__c record
    public static RE_Rate_Unit_Manager__c createRateUnitManagerCS(String csName, String reRateUnit, String reCurrencyUnit, String reVolUnit){
        RE_Rate_Unit_Manager__c cs = new RE_Rate_Unit_Manager__c ();
        cs.Name                  = csName;
        cs.RE_Rate_Unit__c       = reRateUnit;
        cs.RE_Currency_Unit__c   = reCurrencyUnit;
        cs.RE_Volume_Unit__c     = reVolUnit;
        return cs;
    }
    
}