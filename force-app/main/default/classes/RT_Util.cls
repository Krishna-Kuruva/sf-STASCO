public class RT_Util {

    public static final String countryName = 'TU';
    public static final String approverGroup = 'RT_Approvers';

    public static final Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Turkey').getRecordTypeId();
    public static final String soldToType = 'YSTP';
    public static final String shipToType = 'YSHP';
    public static final String accountType = 'Resellers';
    public static final Boolean includeExceptionAccount = false;

    public static final Id locRecTypeId = Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Turkey').getRecordTypeId();
    public static final String depotLocType = 'Depot';
    public static final String refineryLocType = 'Refinery';
    public static final String siteLocType = 'Retail Site';
    public static final Boolean restrictToImportTerminal = true;

    public static final Id prodRecTypeId = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Turkey').getRecordTypeId();
    public static final String materialProdType = 'Material';
    public static final String subgradeProdType = 'Product Sub-grade';
    public static final String gradeProdType = 'Product Grade';

    public static final Id codeSettRecTypeId = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('RT_Code_Value_mapping').getRecordTypeId();
    public static final String dailyAdjystmentType = 'Daily Adjustment';
    public static final String dailyAdjustmentRecordName = 'Daily Adjustment';

    public static final Id sapContractRecordTypeID = Schema.SObjectType.RE_Contract__c.getRecordTypeInfosByDeveloperName().get('Turkey').getRecordTypeId();
    
    public static final Id accountRocSettRecTypeId = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('RT_Account_ROC_Mapping').getRecordTypeId();

    public static final Id fbsRecTypeId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Retail_Prices').getRecordTypeId();
    public static final Id depotPriceRecTypeId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Depot_Prices').getRecordTypeId();
    public static final Id refineryPriceRecTypeId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('Refinery_Prices').getRecordTypeId();
    public static final Id revContractPricesRecordTypeId = Schema.SObjectType.RT_Price_Book__c.getRecordTypeInfosByDeveloperName().get('RT_Rev_Contract_Prices').getRecordTypeId();

    public static final Id routeRecTypeId = Schema.SObjectType.RE_Route_Backbone__c.getRecordTypeInfosByDeveloperName().get('Turkey').getRecordTypeId();

    public static final String yp04Condition = 'YP04';
    public static final String yd05Condition = 'YD05';
    public static final String yd07Condition = 'YD07';
    public static final String yd06Condition = 'YD06';

    public static final String outputReportName = 'Daily Price Changes';
    public static final String exportReportName = 'Price Output';
    public static final String reportFolderName = 'Revolution Turkey';

    public static final String surchargeMessage = 'Deactivation Reason: Surcharge';
    public static final String validityMessage  = 'Deactivation Reason: Validity Expired';
    
    public static final string logicRunClassName = 'RT_REVContractDataBatch';
    
    public static final decimal marginPercentage = 44;

    public static List<RT_PriceOutput__c> queryPriceData(String appendQry)
    {
        List<RT_PriceOutput__c> returnList = new List<RT_PriceOutput__c>();

        String priceQry = 'SELECT Id, SoldToName__c, SoldToName__r.name, SoldToNumber__c, ProductName__c, ProductName__r.name'
                +', ProductCode__c, DepotName__c, DepotAbbreviatedName__c, DepotName__r.name, DepotCode__c, Key_Value__c, Condition_Type__c'
                +', AureusAmount__c, Amount__c, SiteName__c, SiteName__r.name, SiteCode__c, RefineryName__c, RefineryName__r.name'
                +', RefineryCode__c, MaterialSubGrade__c, MaterialGrade__c, CF_IMM__c, TotalPostDiscountPrice__c'
                +', AccountType__c, Exception__c, ImportProductRatio__c, ImportTerminal__c, PaymentDescription__c'
                +', Adjustment__c, Shell_IMM__c, PUMP_REFINERY_DIFF__c, DEPOT_REFINERY_DIFF__c, SCT__c, EMRA__c'
                +', Defined_Refinery_Price__c, Defined_Depot_Price__c, Pump_Price_wo_Tax__c, Pump_Price__c'
                +', Refinery_Price_wo_Tax__c, Refinery_Price__c, Depot_Price_wo_Tax__c, Depot_Price__c'
                +', Approver__c, Approver__r.name, Approver__r.firstname, Approver__r.lastname'
                +', Editor__c, Editor__r.name, Editor__r.firstname, Editor__r.lastname'
                +', Status__c, PriceDate__c, Aureus_Data__c, DiscountType__c'
                +', ProductName__r.RT_Parent_Product__c, ProductName__r.RT_Parent_Product__r.RT_Parent_Product__c'
            	+', ProductSubGrade__c, ProductGrade__c, RT_Country__c, YD06_Amount__c, MarginAfterDiscount__c'
                + ' FROM RT_PriceOutput__c  where RT_Country__c=\'' + countryName + '\''
                + ' and SoldToName__r.RT_Active__c = true and SoldToName__r.recordtypeid = \'' + accRecTypeId + '\''
                + ' and DepotName__r.RT_Active__c = true and DepotName__r.recordtypeid = \'' + locRecTypeId + '\''
                + ' and DepotName__r.RT_Location_Type__c = \'' + depotLocType + '\''
                //+ ' and RefineryName__r.RT_Active__c = true and RefineryName__r.recordtypeid = \'' + locRecTypeId + '\''
                //+ ' and RefineryName__r.RT_Location_Type__c = \'' + refineryLocType + '\''
                //+ ' and SiteName__r.RT_Active__c = true and SiteName__r.recordtypeid = \'' + locRecTypeId + '\''
                //+ ' and SiteName__r.RT_Location_Type__c = \'' + siteLocType + '\''
                + ' and ProductName__r.Active__c = true and ProductName__r.recordtypeid = \'' + prodRecTypeId + '\''
                + ' and ProductName__r.RT_Product_Type__c = \'' + materialProdType + '\''
                + ' and AccountType__c=\'' + accountType + '\'' // and ImportTerminal__c = ' + restrictToImportTerminal
                //+ ' and Exception__c = ' + includeExceptionAccount
                + ' and Condition_Type__c in (\''+ yp04Condition +'\',\'' + yd05Condition +'\',\'' + yd07Condition +'\',\'' + yd06Condition +'\')';

        if(appendQry != null)
            priceQry += appendQry;
        System.debug(priceQry);
        try{
            returnList = Database.query(priceQry);
        } catch (Exception e){System.debug(e);}

        return returnList;
    }

    //Added by Dharmedra for Price Book upsert
    public static List<RT_Price_Book__c> queryPriceBooks(String appndQry)
    {
        List<RT_Price_Book__c> returnAllPriceBooks = new List<RT_Price_Book__c>();

        String priceBookQuery = 'SELECT Id,LastModifiedDate,Name,RecordTypeId,RT_Active__c,RT_Amount__c'
                +', RT_Condition_Type__c,RT_Country__c,RT_Depot_Price__c,RT_Effective_Date__c'
                +', RT_Key_Value__c,RT_Location_Code__c,RT_Location__c,RT_Product_Code__c'
                +', RT_Product__c,RT_Rev_Contract__c,RT_Sold_to_Name__c,RT_Sold_to_Number__c'
                + ' FROM RT_Price_Book__c  where RT_Country__c=\'' + countryName +'\'' ;
        System.debug('Apend query-------'+appndQry);
        if(appndQry != null)
            priceBookQuery += appndQry;
        System.debug('Price query-------'+priceBookQuery);
        try{
            returnAllPriceBooks = Database.query(priceBookQuery);
        } catch (Exception e){System.debug(e);}

        return returnAllPriceBooks;
    }
    
    // added by Dharmendra for old Aureus deactivation
    public static List<REV_Contract_Master__c> returnOldAureus(){
        List<REV_Contract_Master__c> revConList = [Select Id, RT_AMOUNT__c, Active__c, RT_Sold_to_Name__c, RT_Plant_Desc__c,RT_Material_Desc__c,RT_Key_Value__c,RT_Condition_Type_Name__c,RT_Payment_Term__c
             From REV_Contract_Master__c Where Active__c=true and RT_Sold_to_Name__c !=null and RT_Plant_Desc__c !=null and RT_Material_Desc__c !=null and RT_Condition_Type_Name__c !=null 
             and RT_Payment_Term__c !=null and lastmodifieddate != today];
    return revConList;
    }

    public static List<priceWrapper> buildPriceWrapper(List<RT_PriceOutput__c> priceList)
    {
        List<priceWrapper> returnWrap = new List<priceWrapper>();
        Decimal dailyAdjustment = getDailyAdjustment();

        System.debug('priceList= ' + priceList.size());
        for(RT_PriceOutput__c pr : priceList)
        {
            priceWrapper returnPriceWrap = new priceWrapper();

            returnPriceWrap.priceId = pr.id;
            returnPriceWrap.keyVal = pr.Key_Value__c;
            returnPriceWrap.condType = pr.Condition_Type__c;
            returnPriceWrap.aureusID = pr.Aureus_Data__c;
            returnPriceWrap.priceDate = pr.PriceDate__c;

            returnPriceWrap.soldToName = pr.SoldToName__r.name;
            returnPriceWrap.soldToID = pr.SoldToName__c;
            returnPriceWrap.soldToNumber = pr.SoldToNumber__c;
            returnPriceWrap.soldToType = pr.AccountType__c;
            returnPriceWrap.paymentTerm = pr.PaymentDescription__c;
            returnPriceWrap.plantName = pr.DepotName__r.name;
            returnPriceWrap.plantAbbreviatedName = pr.DepotAbbreviatedName__c;
            returnPriceWrap.plantID = pr.DepotName__c;
            returnPriceWrap.plantCode = pr.DepotCode__c;
            returnPriceWrap.isImportTerminal= pr.ImportTerminal__c;
            returnPriceWrap.importRatio = ((pr.ImportProductRatio__c != null)? pr.ImportProductRatio__c : 0) /100;
            returnPriceWrap.materialName = pr.ProductName__r.name;
            returnPriceWrap.materialID = pr.ProductName__c;
            returnPriceWrap.materialCode = pr.ProductCode__c;
            returnPriceWrap.materialSubGrade = pr.MaterialSubGrade__c;
            returnPriceWrap.materialSubGradeID = (pr.ProductSubGrade__c != null)? pr.ProductSubGrade__c : pr.ProductName__r.RT_Parent_Product__c;
            returnPriceWrap.materialGrade = pr.MaterialGrade__c;
            returnPriceWrap.materialGradeID = (pr.ProductGrade__c != null)? pr.ProductGrade__c : pr.ProductName__r.RT_Parent_Product__r.RT_Parent_Product__c;

            returnPriceWrap.amount = (pr.Amount__c == null)? ((pr.AureusAmount__c != null)? pr.AureusAmount__c.setScale(4) : 0) : pr.Amount__c;
            returnPriceWrap.aureusAmount = (pr.AureusAmount__c != null)? pr.AureusAmount__c.setScale(4) : 0;
            returnPriceWrap.adjustment = (pr.Adjustment__c != null)? pr.Adjustment__c : dailyAdjustment;

            returnPriceWrap.status = (pr.status__c != null)? pr.status__c : 'New';

            if(pr.Editor__c != null)
            {
                returnPriceWrap.submitter = pr.Editor__r.name;
                returnPriceWrap.submitterInitials = ((pr.Editor__r.firstname != null) ? pr.Editor__r.firstname.left(1).toUpperCase() : '')
                        + pr.Editor__r.lastname.left(1).toUpperCase();
                returnPriceWrap.submitterID = pr.Editor__c;
            }

            if(pr.Approver__c != null && (pr.status__c.equalsIgnoreCase('Approved') || pr.status__c.equalsIgnoreCase('Rejected')))
            {
                returnPriceWrap.approver = pr.Approver__r.name;
                returnPriceWrap.approverInitials = ((pr.Approver__r.firstname != null) ? pr.Approver__r.firstname.left(1).toUpperCase() : '')
                        + pr.Approver__r.lastname.left(1).toUpperCase();
                returnPriceWrap.approverID = pr.Approver__c;
            }

            returnWrap.add(returnPriceWrap);
        }

        if(returnWrap.size()>0)
            returnWrap = RT_TurkeyPricingLogic.calculateDailyPrice(returnWrap);

        return returnWrap;
    }

    public static List<RT_PriceOutput__c> buildPriceList(List<priceWrapper> priceWrap)
    {
        List<RT_PriceOutput__c> returnList = new List<RT_PriceOutput__c>();

        for(priceWrapper pw : priceWrap)
        {
            RT_PriceOutput__c price = new RT_PriceOutput__c();
            price.RT_Country__c = countryName;
            price.PriceDate__c = pw.priceDate;
            price.id = pw.priceId;
            price.SoldToName__c = pw.soldToID;
            price.DepotName__c = pw.plantID;
            price.ProductName__c = pw.materialID;
            price.ProductSubGrade__c = pw.materialSubGradeID;
            price.ProductGrade__c = pw.materialGradeID;
            price.RefineryName__c = pw.refineryID;
            price.SiteName__c = pw.siteID;
            price.Aureus_Data__c = pw.aureusID;
            price.Key_Value__c = pw.keyVal;
            price.Condition_Type__c = pw.condType;

            price.AureusAmount__c = pw.aureusAmount;
            price.Amount__c = pw.amount;
            price.Adjustment__c = pw.adjustment;

            price.Defined_Depot_Price__c = pw.definedDepotPrice;
            price.Defined_Refinery_Price__c = pw.definedRefineryPrice;
            price.EMRA__c = pw.emra;
            price.SCT__c = pw.sct;
            price.Depot_Price__c = pw.depotPrice;
            price.Depot_Price_wo_Tax__c = pw.depotPrice_woTax;
            price.Refinery_Price__c = pw.refineryPrice;
            price.Refinery_Price_wo_Tax__c = pw.refineryPrice_woTax;
            price.Pump_Price__c = pw.pumpPrice;
            price.Pump_Price_wo_Tax__c = pw.pumpPrice_woTax;
            price.DEPOT_REFINERY_DIFF__c = pw.depotRefineryDiff;
            price.PUMP_REFINERY_DIFF__c = pw.pumpRefineryDiff;

            price.Shell_IMM__c = pw.shellMargin;
            price.CF_IMM__c = pw.cfMargin;
            price.DiscountType__c = pw.discountType;
            price.TotalPostDiscountPrice__c = pw.totalPostDiscount;
            price.YD06_Amount__c = pw.yd06Amount;
            price.MarginAfterDiscount__c = pw.cfMarginAfterDiscount;

            price.Status__c = pw.status;
            price.Approver__c = pw.approverID;
            price.Editor__c = pw.submitterID;

            returnList.add(price);
        }

        return returnList;
    }

    public static Decimal getDailyAdjustment()
    {
        Decimal dailyAdjustment = 0;

        RT_Setting__c dailyAdjustSetting = new RT_Setting__c();
        try{
            dailyAdjustSetting = [select id, name, value__c from RT_Setting__c
            where name = :dailyAdjustmentRecordName and recordtypeid = :codeSettRecTypeId and Type__c = :dailyAdjystmentType
            and Country__c = :countryName limit 1];
        }catch(Exception e){System.debug(e);}

        if(dailyAdjustSetting == new RT_Setting__c() && RT_Setting__c.sObjectType.getDescribe().isCreateable())
        {
            dailyAdjustSetting.name = dailyAdjustmentRecordName;
            dailyAdjustSetting.recordtypeid = codeSettRecTypeId;
            dailyAdjustSetting.Country__c = countryName;
            dailyAdjustSetting.Type__c = dailyAdjystmentType;
            dailyAdjustSetting.value__c = String.valueof(0);
            insert dailyAdjustSetting;
        }

        if(dailyAdjustSetting != new RT_Setting__c())
            dailyAdjustment = Decimal.valueof(dailyAdjustSetting.value__c);

        return dailyAdjustment;
    }

    public class priceWrapper
    {
        @AuraEnabled
        public ID priceId;
        @AuraEnabled
        public String keyVal = '';
        @AuraEnabled
        public ID aureusID;
        public Date priceDate = System.today();

        @AuraEnabled
        public String soldToName = '';
        @AuraEnabled
        public ID soldToID;
        @AuraEnabled
        public String soldToNumber = '';
        @AuraEnabled
        public String soldToType = '';
        @AuraEnabled
        public String paymentTerm = '';
        @AuraEnabled
        public String plantName = '';
        @AuraEnabled
        public String plantAbbreviatedName = '';
        @AuraEnabled
        public ID plantID;
        @AuraEnabled
        public String plantCode = '';
        @AuraEnabled
        public Boolean isImportTerminal = false;
        @AuraEnabled
        public Decimal importRatio = 0;
        @AuraEnabled
        public String materialName = '';
        @AuraEnabled
        public ID materialID;
        @AuraEnabled
        public String materialCode = '';
        @AuraEnabled
        public String materialSubGrade = '';
        @AuraEnabled
        public ID materialSubGradeID;
        @AuraEnabled
        public String materialGrade = '';
        @AuraEnabled
        public ID materialGradeID;
        @AuraEnabled
        public String condType = '';
        @AuraEnabled
        public String refineryName = '';
        @AuraEnabled
        public ID refineryID;
        @AuraEnabled
        public String refineryCode = '';
        @AuraEnabled
        public String siteName = '';
        @AuraEnabled
        public ID siteID;
        @AuraEnabled
        public String siteCode = '';

        @AuraEnabled
        public Decimal depotPrice = 0;
        @AuraEnabled
        public Decimal depotPrice_woTax = 0;
        @AuraEnabled
        public Decimal refineryPrice = 0;
        @AuraEnabled
        public Decimal refineryPrice_woTax = 0;
        @AuraEnabled
        public Decimal pumpPrice = 0;
        @AuraEnabled
        public Decimal pumpPrice_woTax = 0;
        @AuraEnabled
        public Decimal definedDepotPrice = 0;
        @AuraEnabled
        public Decimal definedRefineryPrice = 0;
        @AuraEnabled
        public Decimal emra = 0;
        @AuraEnabled
        public Decimal sct = 0;
        @AuraEnabled
        public Decimal depotRefineryDiff = 0;
        @AuraEnabled
        public Decimal pumpRefineryDiff = 0;

        @AuraEnabled
        public Decimal amount = 0;
        @AuraEnabled
        public Decimal aureusAmount = 0;
        @AuraEnabled
        public Decimal yd06Amount = 0;
        @AuraEnabled
        public Decimal shellMargin = 0;
        @AuraEnabled
        public Decimal cfMargin = 0;
        @AuraEnabled
        public Boolean isMatch = true;
        @AuraEnabled
        public Decimal totalPostDiscount = 0;
        @AuraEnabled
        public String discountType = 'No Discount';
        @AuraEnabled
        public Decimal adjustment = 0;
        @AuraEnabled
        public Decimal suggestedAmount = 0;
        @AuraEnabled
        public Boolean hideAdjustment = false;
        @AuraEnabled
        public Boolean hideYd06Amount = true;
        @AuraEnabled
        public Boolean hideTotalPostDiscount = false;
        @AuraEnabled
        public Boolean hideCfMarginAfterDiscount = false;
        @AuraEnabled
        public Decimal cfMarginAfterDiscount = 0;

        @AuraEnabled
        public String submitter = 'N/A';
        @AuraEnabled
        public String submitterInitials = '';
        public ID submitterID;
        @AuraEnabled
        public String approver = 'N/A';
        @AuraEnabled
        public String approverInitials = '';
        public ID approverID;

        @AuraEnabled
        public String status = 'New';
    }
}