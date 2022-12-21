/******************************************************************************************************************
className           :    RE_CND_TestDataFactory
Description         :    Class to create setup objects for Revolution Canada
Author              :    Aasiya Siraj
Date				:	 10-May-2021 
*******************************************************************************************************************/
public class RE_CND_TestDataFactory {
   
     public static RE_Record_Id_Mappings__c createRecMap(String recordId ,String mapName,string recName,Boolean isActive,string country)
    {
       RE_Record_Id_Mappings__c   recMap= new RE_Record_Id_Mappings__c();
        recMap.Record_Id__c= recordId;
        recMap.Type_Name__c =mapName;
        recMap.Name=recName;
        recMap.Is_Active__c=isActive;
        recMap.Country_Name__c=country;
        insert recMap;
        return recMap;
    }

      public static APXTConga4__Conga_Merge_Query__c createCongaQuery(String congaQuery ,String congaName)
    {
       APXTConga4__Conga_Merge_Query__c   congaQ= new APXTConga4__Conga_Merge_Query__c();
        congaQ.APXTConga4__Name__c= congaName;
        congaQ.APXTConga4__Query__c=congaQuery;
        insert congaQ;
        return congaQ;
    }

    
    public static APXTConga4__Conga_Email_Template__c congaEmailTemplate(String htmlBody ,String tempName,String tempSubject,String textBody)
    {
        APXTConga4__Conga_Email_Template__c cet= new APXTConga4__Conga_Email_Template__c();
        cet.APXTConga4__Name__c= tempName;
        cet.APXTConga4__HTMLBody__c=htmlBody;
        cet.APXTConga4__Subject__c=tempSubject;
        cet.APXTConga4__TextBody__c=textBody;
        insert cet;
        return cet;
    }
    
    
    public static RE_GSAP_Upload__c createGSAPUpload()
    {
        RE_GSAP_Upload__c gsap = new RE_GSAP_Upload__c();
        gsap.RE_GSAP_Upload__c=TRUE;
        gsap.Name='Canada';
        insert gsap;
        return gsap;
    }
    
    public static RE_CustomOpps_ReportConfiguration__c createOppConfig(String name1,String conTable,String cusType,String dataType,String varKey)
    {
        RE_CustomOpps_ReportConfiguration__c crc= new RE_CustomOpps_ReportConfiguration__c();
        crc.Name=name1;
        crc.RE_Application__c='V';
        crc.RE_Calculation_Type__c='C';
        crc.RE_Condition_Table__c=conTable;
        crc.RE_Condition_Type__c='YP02';
        crc.RE_Condition_Usage_Table__c='A';
        crc.RE_Country_Name__c='Canada';
        crc.RE_Customer_Type__c=cusType;
        crc.RE_Data_Type__c=dataType;
        crc.RE_Is_Active__c=TRUE;
        crc.RE_Quantity__c='100';
        crc.RE_Scale_Type__c='A';
        crc.RE_Unit__c='CAD';
        crc.RE_UoM__c='L15';
        crc.RE_Varkey__c=varKey;
        insert crc;
        return crc;
    }
    
    public static REV_Contract_Master__c createRevMaster(Id recordType,String Rack,String Group1,Id ProdID,Id LocID,Id shipTo,
                                                         Id soldTo,Id baselocID,Id baseProdId,String rateUnit){
                                                             REV_Contract_Master__c rev = new REV_Contract_Master__c();
                                                             rev.Active__c=TRUE; 
                                                             rev.Country_Name__c='CA'; 
                                                             rev.RT_Material_Desc__c=ProdID;
                                                             rev.RE_CND_Rack__c=Rack;
                                                             rev.RT_Sold_to_Name__c=soldTo;  
                                                             rev.RT_Ship_to_Name__c =shipTo;
                                                             rev.RE_CND_Plant_Pricing_Basis__c=baselocID;
                                                             rev.RE_CND_Product_Pricing_Basis__c=baseProdId;
                                                             rev.RE_CND_Group_Pricing_Basis__c='Unbranded';
                                                             rev.RE_Final_Price_Unit__c=rateUnit;
                                                             insert rev;
                                                             return rev;
                                                         }
    public static RE_Product__c createProduct(Id recordType,String code,String name1,String prodClass,String subGroup,String prodGroup,String pg, String country,Boolean active){
        RE_Product__c product = new RE_Product__c();
        product.RecordTypeId=recordType;
        product.RE_Product_Classification_L0__c=prodClass;
        product.Name=name1;
        product.RT_Product_Code__c =code;
        product.RE_Product_Code__c =Decimal.valueOf(code);
        product.RE_Product_Subgroup__c=subGroup;
        product.RE_Product_Group__c=pg;
        product.RE_CND_Product_Groups__c=prodGroup;
        product.RE_Country_Name__c=country;
        product.Active__c=active;
        
        insert product;
        return product;
    }
    public static RE_Location__c createLocation(Id recordType,String code,String name1,String abbName,String country,Boolean active){
        RE_Location__c loc = new RE_Location__c();
        loc.RecordTypeId=recordType;
        loc.RE_Location_Code__c=code;
        loc.Name=name1;
        loc.RE_Abbreviated_Name__c=abbName;
        loc.RE_Country_Name__c=country;
        loc.RT_Active__c=active;
        
        insert loc;
        return loc;
    }
    
    public static RE_Holiday_Calendars__c createHolidyCalender(string name, string Dayname, string Holiday, date Holiday_Date)
    {
        RE_Holiday_Calendars__c hc = new RE_Holiday_Calendars__c();
        hc.Name = name;
        hc.Country_Name__c = 'Canada';
        hc.Day__c = Dayname;
        hc.Holiday__c = Holiday;
        hc.Holiday_Date__c = Holiday_Date;
        hc.Is_Active__c = TRUE;
        
        insert hc;
        return hc;
    }
    
    public static Account createAccount(Id recordType,String name1,Id parent,String custType,String accNo,Boolean active){
        Account acc = new Account();
        acc.Name=name1;
        acc.ParentId=parent;
        acc.Customer_Type__c=custType;
        acc.RecordTypeId=recordType;
        acc.AccountNumber=accNo;
        acc.RT_Active__c=active;
        
        insert acc;
        return acc;
    }
    
    public static List<RE_Zema_Quotes_Settings__c> createZemaQuotes(){
        List<RE_Zema_Quotes_Settings__c> zemaList = new List<RE_Zema_Quotes_Settings__c>();
        RE_Zema_Quotes_Settings__c rezs1= new RE_Zema_Quotes_Settings__c
            (Country__c='Canada',Quote_Name__c= 'Test Quote',Display_Name__c='Test Display',Frequency__c='Daily',Name='ZQ-00001',Type__c='Settlement Quote',Is_Active__c = TRUE);
        zemaList.add(rezs1);
        
        RE_Zema_Quotes_Settings__c rezs2= new RE_Zema_Quotes_Settings__c
            (Country__c='Canada',
             Quote_Name__c= 'Argus US east coast Gasoline 83.5 CBOB NYH barge Daily (low) barge Nymex Gasoline RBOB USC/USG Interpolation: previous',
             Display_Name__c='Argus US Petroleum products Gasoline 83.5 CBOB NYH Barge value low',
             Frequency__c='Daily',
             Name='ZQ-00002',Type__c='Settlement Quote',Is_Active__c = TRUE);
        zemaList.add(rezs2);
        
        RE_Zema_Quotes_Settings__c rezs3= new RE_Zema_Quotes_Settings__c
            (Country__c='Canada;Turkey',
             Quote_Name__c= 'ICE Cleared Settle Oil (Futures) Settlement Price North Sea Brent Crude',
             Display_Name__c='ICE Brent M+0',
             Frequency__c='Daily',
             Name='ZQ-00003',Type__c='Settlement Quote',Is_Active__c = TRUE);
        zemaList.add(rezs3);
        
        RE_Zema_Quotes_Settings__c rezs4= new RE_Zema_Quotes_Settings__c
            (Country__c='Canada',
             Quote_Name__c= 'Reuters 12 Noon USD Exchange Benckmark USD Mid Canada Dollar CAD Interpolation: previous',
             Display_Name__c='Live FX Rate',
             Frequency__c='Live',
             Name='ZQ-00004',Type__c='FX Rates',Is_Active__c = TRUE);
        zemaList.add(rezs4);
        
        
        insert zemaList;
        return zemaList;
        
    }
    
    public static RE_Default_Unit_Rate_Settings__c createDefaultUnit(String Name,String dstype,String rate,String country,String objType,Boolean isactive)
    {
        RE_Default_Unit_Rate_Settings__c ds = new RE_Default_Unit_Rate_Settings__c();
        ds.Name=Name;
        ds.Type__c=dstype;
        ds.Default_Unit_Rate__c =rate;
        ds.Country_Name__c=country;
        ds.Object_Name__c=objType;
        ds.Is_Active__c=isactive;
        insert ds;
        return ds;
    }
    
    public static RE_Rate_Unit_Manager__c createRateUnitManager (String name1,String rate,String currency1,String volume)
    {
        RE_Rate_Unit_Manager__c rum = new  RE_Rate_Unit_Manager__c();
        rum.Name=name1;
        rum.RE_Currency_Unit__c=currency1;
        rum.RE_Rate_Unit__c=rate;
        rum.RE_Volume_Unit__c=volume;
        insert rum;
        return rum;
    }
    
    public static RE_Currency_Conversion__c createCurrencyConversion (String name1,String baseCurrency,String conCurr,String formula)
    {
        RE_Currency_Conversion__c cc = new  RE_Currency_Conversion__c();
        cc.Name=name1;
        cc.Base_Currency_Unit__c=baseCurrency;
        cc.Converted_Currency_Unit__c=conCurr;
        cc.Formula__c=formula;
        insert cc;
        return cc;
    }
    
    public static RE_FX_Rates__c createFXRate(String Name,Decimal price , Date pricingDate,String currencyCode)
    {
        RE_FX_Rates__c fxRate = new RE_FX_Rates__c();
        fxRate.RE_Quote_Name__c = Name;
        fxRate.RE_Forex_Rate__c = price;
        fxRate.RE_Pricing_Date__c = pricingDate;
        fxRate.RE_Trade_Type__c='Exchange Rate';
        fxRate.RE_Base_Unit__c='USD';
        fxRate.RE_Conversion_Unit__c = currencyCode;
        fxRate.RE_Forex_Name__c =currencyCode+ '/USD';
        insert fxRate;
        return fxRate;
    }
    
    public static Reuters_History__c  createReutersHistrory(String displayName,String quoteName,DateTime CreatedDate,String frequency,Id reuterId,Decimal reuterPrice,Date pricingDate,String country)
    {
        Reuters_History__c rhs = new Reuters_History__c();
        rhs.Quote_Display_Name__c=displayName;
        rhs.Quote_Name__c=quoteName;
        rhs.Reuters_Created_Date__c=CreatedDate;
        rhs.Frequency__c= frequency;
        rhs.Reuter_Id__c=reuterId;
        rhs.Price__c=reuterPrice;
        rhs.Pricing_Date__c=pricingDate;
        rhs.RE_Country_Name__c=country;
        insert rhs;
        return rhs;
    }
    
    public static RE_Job_Run_Audit__c createJobRunAudit(String runType, String jobType, String Country){
        RE_Job_Run_Audit__c jrAudit = new RE_Job_Run_Audit__c();
        jrAudit.RE_Run_Time__c = System.now();
        jrAudit.RE_Run_Type__c = runType ;
        jrAudit.RE_Job_Type__c = jobType;
        jrAudit.RE_User__c = UserInfo.getUserId();
        jrAudit.RE_Job_Run_Count__c = 1;
        jrAudit.RE_Country_Name__c=Country;
        jrAudit.RE_Job_Status__c='Processing';
        jrAudit.RE_IsSuccess__c=true;
        insert jrAudit;
        return jrAudit;
    }
    
    public static RE_JobControls__c createJobControlSetting(string jobName,String className, String methodName, String Country, Boolean isActive){
        RE_JobControls__c rec= new RE_JobControls__c(Name=jobName,Active__c=isActive,Class_Name__c=className,Country__c=Country,Method_Name__c=methodName);
        insert rec;
        return rec;
    }
    
    public static Reuters_Quotes__c createReutersQuote(String QuoteName,Date pricingDate, Decimal Price, String UnitofMeasure,String currencyCode){
        
        Reuters_Quotes__c qs= new Reuters_Quotes__c(Pricing_Date__c=pricingDate,
                                                    Quote_Name__c=QuoteName,
                                                    Unit_Of_Measure__c=UnitofMeasure,
                                                    Price__c=Price,
                                                    Frequency__c='Daily',
                                                    CurrencyCode__c=currencyCode);
        insert qs;
        return qs;
    }
    
    public static RE_Market_Quotes__c createMarketQuotes(String QuoteName,Date pricingDate, Decimal Price,String Country){
        RE_Market_Quotes__c mqs= new RE_Market_Quotes__c(RE_Quote_Name__c=QuoteName,RE_Pricing_Date__c=pricingDate,RE_Price__c=Price,RE_Country_Name__c=Country);
        insert mqs;
        return mqs;
    }
    
    public static RE_Pricing_Input_STG__c createCompetitor(Id recordType,string rackname,string suplrName,string prodctGroup,
                                                           decimal price,string curency, string unit)
    {
        Datetime prngDateTime = system.now();
        Date prngDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        
        RE_Pricing_Input_STG__c compi = new RE_Pricing_Input_STG__c();
        compi.RecordTypeId = recordType;
        compi.RE_CND_Daily_Racks_Raw_Date__c = '20210901';
        compi.RE_CND_City_Code__c ='50';
        compi.RE_CND_City_Name__c = rackname;
        compi.RE_CND_Supplier_Name__c = suplrName;
        compi.RE_CND_Brand_Indicator__c ='u';
        compi.RE_CND_Product_Group__c = prodctGroup;
        compi.RE_Price__c = price;
        compi.RE_CND_Move_Value__c = '0.9000';
        compi.RE_Pricing_Date__c = prngDate;
        compi.RE_Default_Currency__c = curency;
        compi.RE_Unit_of_Measure__c = unit;
        
        insert compi;
        return compi;   
    } 
    
    public static List<RE_Market_Quotes__c> createOPISLive(Datetime effctDateTime)
    {
        Id opisSpotRecordTypeId = Schema.SObjectType.RE_Market_Quotes__c.getRecordTypeInfosByDeveloperName().get('Canada_OPIS_Spot_Ticker').getRecordTypeId();
        List<RE_Market_Quotes__c> opisList = New List<RE_Market_Quotes__c>();
        Datetime effctvDateTime = effctDateTime;
        Date effcFrmDate =  date.newinstance(effctvDateTime.year(), effctvDateTime.month(), effctvDateTime.day());
        
        RE_Market_Quotes__c opis1 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL)',RE_Price__c=78.8,
                                                            RE_Validity_Month__c = 'Aug-21', RE_Rate_Unit__c='USD/BBL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis1);
        
        RE_Market_Quotes__c opis2 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL) (Change)',RE_Price__c=-1.5900,
                                                            RE_Validity_Month__c = 'Aug-22', RE_Rate_Unit__c='USD/BBL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis2);
        
        RE_Market_Quotes__c opis_1 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL)',RE_Price__c=77.8,
                                                             RE_Validity_Month__c = 'Sep-21', RE_Rate_Unit__c='USD/BBL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis_1);
        
        RE_Market_Quotes__c opis_2 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL) (Change)',RE_Price__c=0.678,
                                                             RE_Validity_Month__c = 'Sep-20', RE_Rate_Unit__c='USD/BBL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis_2);  
        
        RE_Market_Quotes__c opis_1_1 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL)',RE_Price__c=77.8,
                                                               RE_Validity_Month__c = 'Sep-22', RE_Rate_Unit__c='USD/BBL',
                                                               RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis_1_1);
        
        RE_Market_Quotes__c opis_2_1 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL) (Change)',RE_Price__c=0.678,
                                                               RE_Validity_Month__c = 'Sep-21', RE_Rate_Unit__c='USD/BBL',
                                                               RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis_2_1);  
        
        RE_Market_Quotes__c opis_1_2 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL)',RE_Price__c=77.8,
                                                               RE_Validity_Month__c = 'Oct-21', RE_Rate_Unit__c='USD/BBL',
                                                               RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis_1_2);
        
        RE_Market_Quotes__c opis_2_2 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WTI (CL) (Change)',RE_Price__c=0.678,
                                                               RE_Validity_Month__c = 'Oct-21', RE_Rate_Unit__c='USD/BBL',
                                                               RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis_2_2);  
        
        
        RE_Market_Quotes__c opis3 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB)',RE_Price__c=68.8,
                                                            RE_Validity_Month__c = '21-Oct', RE_Rate_Unit__c='USD/GAL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis3);
        
        RE_Market_Quotes__c opis4 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB) (Change)',RE_Price__c=0.8,
                                                            RE_Validity_Month__c = '22-Oct', RE_Rate_Unit__c='USD/GAL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis4);
        
        RE_Market_Quotes__c opis5 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST RBOB UNL NYHB',RE_Price__c=56.8,
                                                            RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis5);
        
        RE_Market_Quotes__c opis6 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST RBOB UNL NYHB (Change)',RE_Price__c=0.10,
                                                            RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis6);
        
        RE_Market_Quotes__c opis7 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WEST ULS#2 SF',RE_Price__c=67.8,
                                                            RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis7);
        
        RE_Market_Quotes__c opis8 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='WEST ULS#2 SF (Change)',RE_Price__c=0.3,
                                                            RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis8);
        
        RE_Market_Quotes__c opis9 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST RBOB UNL Chi.Comp',RE_Price__c=79.8,
                                                            RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                            RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis9);
        
        RE_Market_Quotes__c opis10 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST RBOB UNL Chi.Comp (Change)',RE_Price__c=21.8,
                                                             RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis10);
        
        RE_Market_Quotes__c opis11 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST CBOB Chi.Comp',RE_Price__c=75.8,
                                                             RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis11);
        
        RE_Market_Quotes__c opis12 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST CBOB Chi.Comp (Change)',RE_Price__c=0.18,
                                                             RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis12);
        
        RE_Market_Quotes__c opis13 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST CBOB GC',RE_Price__c=87.8,
                                                             RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis13);
        
        
        RE_Market_Quotes__c opis14 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='EAST CBOB GC (Change)',RE_Price__c=1.08,
                                                             RE_Validity_Month__c = '', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis14);
        
        RE_Market_Quotes__c opis15 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB)',RE_Price__c=28.8,
                                                             RE_Validity_Month__c = '21-Sep', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis15);
        
        RE_Market_Quotes__c opis16 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB) (Change)',RE_Price__c=0.5,
                                                             RE_Validity_Month__c = '20-Sep', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis16);
        
        RE_Market_Quotes__c opis17 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB)',RE_Price__c=28.8,
                                                             RE_Validity_Month__c = '22-Sep', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis17);
        
        RE_Market_Quotes__c opis18 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB) (Change)',RE_Price__c=0.5,
                                                             RE_Validity_Month__c = '21-Sep', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis18);
        
        RE_Market_Quotes__c opis19 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB)',RE_Price__c=28.8,
                                                             RE_Validity_Month__c = '21-Nov', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis19);
        
        RE_Market_Quotes__c opis20 = New RE_Market_Quotes__c(RecordTypeId=opisSpotRecordTypeId,RE_Quote_Name__c='RBOB (RB) (Change)',RE_Price__c=0.5,
                                                             RE_Validity_Month__c = '21-Nov', RE_Rate_Unit__c='USD/GAL',
                                                             RE_Is_Processed__c = FALSE,RE_CND_Validity_Date__c=effcFrmDate,RE_Country_Name__c='CA');
        opisList.add(opis20);
        
        insert opisList;
        return opisList;
    }
    
    public static List<RE_MOA__c> createMarketMoveData(Datetime effctDateTime)
    {
        Id marktMveRecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Market_Moves').getRecordTypeId();
        List<RE_MOA__c> mqList = New List<RE_MOA__c>();
        Datetime effctvDateTime = effctDateTime;
        Date reqFrmDate =  date.newinstance(effctvDateTime.year(), effctvDateTime.month(), effctvDateTime.day());
        Date reqDate = reqFrmDate.addDays(1);
        reqFrmDate = reqFrmDate.addDays(1);
        
        RE_MOA__c mq1 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='Chi CBOB', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq1);
        
        RE_MOA__c mq2 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='USG CBOB', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq2);
        
        RE_MOA__c mq3 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='Chi Rbob', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq3);
        
        RE_MOA__c mq4 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='NYH RBOB Unl', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq4);     
        
        RE_MOA__c mq5 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='RBOB', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq5);
        
        RE_MOA__c mq6 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='PNW CARBOB', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq6);
        
        RE_MOA__c mq7 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='NYH CBOB', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq7);
        
        RE_MOA__c mq8 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='WTI', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gasoline', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq8);
        
        RE_MOA__c mq9 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                      RE_CND_Marker_Name__c='Chi ULS#2', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                      RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                      RE_CND_Group__c = 'Gas Oil', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq9);
        
        RE_MOA__c mq10 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_CND_Marker_Name__c='USG ULS#2', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                       RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                       RE_CND_Group__c = 'Gas Oil', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq10);
        
        RE_MOA__c mq11 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_CND_Marker_Name__c='NYH ULS#2', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                       RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                       RE_CND_Group__c = 'Gas Oil', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq11);
        
        RE_MOA__c mq12 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_CND_Marker_Name__c='HO', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                       RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                       RE_CND_Group__c = 'Gas Oil', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq12);
        
        RE_MOA__c mq13 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_CND_Marker_Name__c='LA ULS#2', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                       RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                       RE_CND_Group__c = 'Gas Oil', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq13);
        
        RE_MOA__c mq14 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_CND_Marker_Name__c='PNW ULS#2', RE_Price_Value__c = 2.2200, RE_CND_Delta_Percentage__c=-1.04,
                                       RE_CND_Actual_Delta__c = -0.0233,RE_CND_CAD_Delta_cpl__c=-0.755,RE_CND_PrvDay_Delta_Percentage__c=-1.04,
                                       RE_CND_Group__c = 'Gas Oil', RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD/LTR',RE_Initial_Version__c='Test1');
        mqList.add(mq14);
        
        RE_MOA__c mq15 = New RE_MOA__c(RecordTypeId=marktMveRecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,RE_CND_Effective_From_Date__c=reqFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_CND_Marker_Name__c='Reuters Fx', RE_Price_Value__c = 1.2553, RE_CND_Delta_Percentage__c=-1.04,
                                       RE_CND_Actual_Delta__c = -0.0233,RE_CND_PrvDay_Delta_Percentage__c=-1.04,RE_CND_Group__c = 'Fx Rate',RE_Initial_Version__c='Test1');
        mqList.add(mq15);
        
        insert mqList;
        return mqList;
    }
    
    public static List<RE_MOA__c> createExecutPriceData(Datetime effctDateTime)
    {
        Id cadMOARecordTypeId = Schema.SObjectType.RE_MOA__c.getRecordTypeInfosByDeveloperName().get('Canada_Execute_Pricing').getRecordTypeId();
        List<RE_MOA__c> expList = New List<RE_MOA__c>();
        Datetime effctvDateTime = effctDateTime;
        Date effcFrmDate =  date.newinstance(effctvDateTime.year(), effctvDateTime.month(), effctvDateTime.day());
        Date reqDate = effcFrmDate;
        effcFrmDate = effcFrmDate.addDays(1);
        
        RE_MOA__c exp1 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Edmonton', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp1);
        
        RE_MOA__c exp2 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Montreal', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp2);
        
        RE_MOA__c exp3 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Vancouver', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp3);
        
        RE_MOA__c exp4 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Kamloops', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp4);
        
        RE_MOA__c exp5 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Ottawa', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp5);
        
        RE_MOA__c exp6 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Sarnia', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp6);
        
        RE_MOA__c exp7 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Thunder Bay', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp7);
        
        RE_MOA__c exp8 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Toronto', RE_CND_Group__c='Gasoline', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp8);
        
        RE_MOA__c exp9 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                       RE_CND_Rack__c='Edmonton', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                       RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                       RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                       RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp9);
        
        RE_MOA__c exp10 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Montreal', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp10);
        
        RE_MOA__c exp11 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Vancouver', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp11);
        
        RE_MOA__c exp12 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Kamloops', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp12);
        
        RE_MOA__c exp13 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Ottawa', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp13);
        
        RE_MOA__c exp14 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Sarnia', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp14);
        
        RE_MOA__c exp15 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Thunder Bay', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp15);
        
        RE_MOA__c exp16 = New RE_MOA__c(RecordTypeId=cadMOARecordTypeId,RE_CND_Effective_Date__c = effctvDateTime, RE_IsLatest__c=TRUE,
                                        RE_CND_Rack__c='Toronto', RE_CND_Group__c='Gas Oil', RE_CND_Today_s_Price__c = 78.8, 
                                        RE_CND_Market_Move__c = -1.64,RE_CND_Competitive_Adj__c=0.00,RE_CND_Net_Move__c=-1.60,
                                        RE_CND_New_End_Price__c =85.20,RE_CND_Difference__c=0.00,RE_CND_Effective_From_Date__c=effcFrmDate,RE_CND_Effective_To_Date__c=effcFrmDate,RE_Requested_Date__c=reqDate,RE_CND_Current_OPIS_Selected_Date__c=reqDate,
                                        RE_Base_Rate_Unit__c='USD/BBL', RE_Converted_Rate_Unit__c='CAD CTS/LTR',RE_Initial_Version__c='Test1');
        expList.add(exp16);
        
        insert expList;
        return expList;
    }

    public static List<RE_Pricing_Input_STG__c> createOPISspotTickerData()
    {
        List<RE_Pricing_Input_STG__c> cndOpisData = New List<RE_Pricing_Input_STG__c>();
        Id opisRecordTypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByDeveloperName().get('Canada_OPIS_Spot_Ticker').getRecordTypeId();
        Datetime prngDateTime = system.now();
        Date prngDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        
        RE_Pricing_Input_STG__c opis1 = new RE_Pricing_Input_STG__c
            (RecordTypeId = opisRecordTypeId,RE_CND_Quote_Name__c='WTI',RE_Price__c=87.0, RE_Validity_Month__c='Aug-21',RE_Pricing_Date__c=prngDate,
             RE_Default_Currency__c='USD',RE_Unit_of_Measure__c='BBL',RE_Quote_Type__c='OPIS', RE_Quote_Source__c='Spot');
        cndOpisData.add(opis1);
        
        insert cndOpisData;
        return cndOpisData;        
    }
    
    public static List<RE_Pricing_Input_STG__c> createCompetitorData()
    {
        List<RE_Pricing_Input_STG__c> cndCompetitorData = New List<RE_Pricing_Input_STG__c>();
        Id competitorRecordTypeId = Schema.SObjectType.RE_Pricing_Input_STG__c.getRecordTypeInfosByDeveloperName().get('Canada_Competitor').getRecordTypeId();
        Datetime prngDateTime = system.now();
        Date prngDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date nxtPrngDate = prngDate.addDays(1);
        
        RE_Pricing_Input_STG__c compi1 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Edmonton',RE_CND_Supplier_Name__c='Esso Canada',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=76.5, RE_CND_Move_Value__c='0.9000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi1);
        
        RE_Pricing_Input_STG__c compi2 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Edmonton',RE_CND_Supplier_Name__c='Esso Canada',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Pre',RE_Price__c=78.8, RE_CND_Move_Value__c='0.7000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi2);
        
        RE_Pricing_Input_STG__c compi3 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Edmonton',RE_CND_Supplier_Name__c='Esso Canada',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=70.8, RE_CND_Move_Value__c='0.6000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi3);
        
        RE_Pricing_Input_STG__c compi4 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Edmonton',RE_CND_Supplier_Name__c='Esso Canada',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=80.8, RE_CND_Move_Value__c='0.6000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi4);
        
        RE_Pricing_Input_STG__c compi5 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Edmonton',RE_CND_Supplier_Name__c='Suncor',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=70.8, RE_CND_Move_Value__c='0.6000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi5); 
        
        RE_Pricing_Input_STG__c compi6 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Edmonton',RE_CND_Supplier_Name__c='Valero',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=65.8, RE_CND_Move_Value__c='0.6000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi6);
        //
        
        RE_Pricing_Input_STG__c compi7 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Calgary',RE_CND_Supplier_Name__c='Esso Canada',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=80.8, RE_CND_Move_Value__c='0.6000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi7);
        
        RE_Pricing_Input_STG__c compi8 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Calgary',RE_CND_Supplier_Name__c='Suncor',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=70.8, RE_CND_Move_Value__c='0.6000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi8); 
        
        RE_Pricing_Input_STG__c compi9 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId, RE_CND_Daily_Racks_Raw_Date__c = '20210901',RE_CND_City_Code__c='50', RE_CND_City_Name__c='Calgary',RE_CND_Supplier_Name__c='Valero',RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',RE_Price__c=65.8, RE_CND_Move_Value__c='0.6000',RE_Pricing_Date__c=nxtPrngDate,RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        
        cndCompetitorData.add(compi9);
        	RE_Pricing_Input_STG__c compi10 = new RE_Pricing_Input_STG__c
            (RecordTypeId = competitorRecordTypeId,
			RE_CND_Daily_Racks_Raw_Date__c = '20210901',
			RE_CND_City_Code__c='50',
			RE_CND_City_Name__c='Calgary',
			RE_CND_Supplier_Name__c='Parkland',
			RE_CND_Brand_Indicator__c='u',
             RE_CND_Product_Group__c = 'Unl',
			 RE_Price__c=72.8,
			 RE_CND_Move_Value__c='0.6000',
			 RE_Pricing_Date__c=nxtPrngDate,
			 RE_Default_Currency__c='CAD CTS',RE_Unit_of_Measure__c='LTR');
        cndCompetitorData.add(compi10); 
        insert cndCompetitorData;
        return cndCompetitorData;        
    }
    
    public static List<RE_Field_Value_Mappings__c> createMarkerNameMappings()
    {
        List<RE_Field_Value_Mappings__c> mnS = New List<RE_Field_Value_Mappings__c>();
        RE_Field_Value_Mappings__c fvm = New RE_Field_Value_Mappings__c(Name='fvm',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                        Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WTI (CL)',Mapping_Field_Value__c='WTI',Is_Active__c=True);
        
        mnS.add(fvm);
        
        RE_Field_Value_Mappings__c fvm1 = New RE_Field_Value_Mappings__c(Name='fvm1',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WTI (CL) (Change)',Mapping_Field_Value__c='WTI',Is_Active__c=True);
        
        mnS.add(fvm1);
        
        RE_Field_Value_Mappings__c fvm2 = New RE_Field_Value_Mappings__c(Name='fvm2',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='RBOB (RB)',Mapping_Field_Value__c='RBOB',Is_Active__c=True);
        
        mnS.add(fvm2);
        
        RE_Field_Value_Mappings__c fvm3 = New RE_Field_Value_Mappings__c(Name='fvm3',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='RBOB (RB) (Change)',Mapping_Field_Value__c='RBOB',Is_Active__c=True);
        
        mnS.add(fvm3);
        
        RE_Field_Value_Mappings__c fvm4 = New RE_Field_Value_Mappings__c(Name='fvm4',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST RBOB UNL NYHB',Mapping_Field_Value__c='NYH RBOB Unl',Is_Active__c=True);
        
        mnS.add(fvm4);
        
        RE_Field_Value_Mappings__c fvm5 = New RE_Field_Value_Mappings__c(Name='fvm5',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST RBOB UNL NYHB (Change)',Mapping_Field_Value__c='NYH RBOB Unl',Is_Active__c=True);
        
        mnS.add(fvm5);
        
        RE_Field_Value_Mappings__c fvm6 = New RE_Field_Value_Mappings__c(Name='fvm6',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST ULS#2 SF',Mapping_Field_Value__c='NYH CBOB',Is_Active__c=True);
        
        mnS.add(fvm6);
        
        RE_Field_Value_Mappings__c fvm7 = New RE_Field_Value_Mappings__c(Name='fvm7',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST ULS#2 SF (Change)',Mapping_Field_Value__c='NYH CBOB',Is_Active__c=True);
        
        mnS.add(fvm7);
        
        RE_Field_Value_Mappings__c fvm8 = New RE_Field_Value_Mappings__c(Name='fvm8',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST RBOB UNL Chi.Comp',Mapping_Field_Value__c='Chi Rbob',Is_Active__c=True);
        
        mnS.add(fvm8);
        
        RE_Field_Value_Mappings__c fvm9 = New RE_Field_Value_Mappings__c(Name='fvm9',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                         Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST RBOB UNL Chi.Comp (Change)',Mapping_Field_Value__c='Chi Rbob',Is_Active__c=True);
        
        mnS.add(fvm9);
        
        RE_Field_Value_Mappings__c fvm10 = New RE_Field_Value_Mappings__c(Name='fvm10',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST CBOB Chi.Comp',Mapping_Field_Value__c='Chi CBOB',Is_Active__c=True);
        
        mnS.add(fvm10);
        
        RE_Field_Value_Mappings__c fvm11 = New RE_Field_Value_Mappings__c(Name='fvm11',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST CBOB Chi.Comp (Change)',Mapping_Field_Value__c='Chi CBOB',Is_Active__c=True);
        
        mnS.add(fvm11);
        
        RE_Field_Value_Mappings__c fvm12 = New RE_Field_Value_Mappings__c(Name='fvm12',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST CBOB GC',Mapping_Field_Value__c='USG CBOB',Is_Active__c=True);
        
        mnS.add(fvm12);
        
        RE_Field_Value_Mappings__c fvm13 = New RE_Field_Value_Mappings__c(Name='fvm13',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST CBOB GC (Change)',Mapping_Field_Value__c='USG CBOB',Is_Active__c=True);
        
        mnS.add(fvm13);
        
        RE_Field_Value_Mappings__c fvm14 = New RE_Field_Value_Mappings__c(Name='fvm14',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST CARBOB PNW',Mapping_Field_Value__c='PNW CARBOB',Is_Active__c=True);
        
        mnS.add(fvm14);
        
        RE_Field_Value_Mappings__c fvm15 = New RE_Field_Value_Mappings__c(Name='fvm15',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST CARBOB PNW (Change)',Mapping_Field_Value__c='PNW CARBOB',Is_Active__c=True);
        
        mnS.add(fvm15);
        
        RE_Field_Value_Mappings__c fvm16 = New RE_Field_Value_Mappings__c(Name='fvm16',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='ULSD (HO)',Mapping_Field_Value__c='HO',Is_Active__c=True);
        
        mnS.add(fvm16);
        
        RE_Field_Value_Mappings__c fvm17 = New RE_Field_Value_Mappings__c(Name='fvm17',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='ULSD (HO) (Change)',Mapping_Field_Value__c='HO',Is_Active__c=True);
        
        mnS.add(fvm17);
        
        RE_Field_Value_Mappings__c fvm18 = New RE_Field_Value_Mappings__c(Name='fvm18',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST ULS#2 NYHB',Mapping_Field_Value__c='NYH ULS#2',Is_Active__c=True);
        
        mnS.add(fvm18);
        
        RE_Field_Value_Mappings__c fvm19 = New RE_Field_Value_Mappings__c(Name='fvm19',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST ULS#2 NYHB (Change)',Mapping_Field_Value__c='NYH ULS#2',Is_Active__c=True);
        
        mnS.add(fvm19);
        
        RE_Field_Value_Mappings__c fvm20 = New RE_Field_Value_Mappings__c(Name='fvm20',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST ULS#2 Chi.Comp',Mapping_Field_Value__c='Chi ULS#2',Is_Active__c=True);
        
        mnS.add(fvm20);
        
        RE_Field_Value_Mappings__c fvm21 = New RE_Field_Value_Mappings__c(Name='fvm21',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST ULS#2 Chi.Comp (Change)',Mapping_Field_Value__c='Chi ULS#2',Is_Active__c=True);
        
        mnS.add(fvm21);
        
        RE_Field_Value_Mappings__c fvm22 = New RE_Field_Value_Mappings__c(Name='fvm22',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST ULS#2 PNW',Mapping_Field_Value__c='PNW ULS#2',Is_Active__c=True);
        
        mnS.add(fvm22);
        
        RE_Field_Value_Mappings__c fvm23 = New RE_Field_Value_Mappings__c(Name='fvm23',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST ULS#2 PNW (Change)',Mapping_Field_Value__c='PNW ULS#2',Is_Active__c=True);
        
        mnS.add(fvm23);
        
        RE_Field_Value_Mappings__c fvm24 = New RE_Field_Value_Mappings__c(Name='fvm24',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST ULS#2 LA',Mapping_Field_Value__c='LA ULS#2',Is_Active__c=True);
        
        mnS.add(fvm24);
        
        RE_Field_Value_Mappings__c fvm25 = New RE_Field_Value_Mappings__c(Name='fvm25',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='WEST ULS#2 LA (Change)',Mapping_Field_Value__c='LA ULS#2',Is_Active__c=True);
        
        mnS.add(fvm25);
        
        RE_Field_Value_Mappings__c fvm26 = New RE_Field_Value_Mappings__c(Name='fvm26',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST ULS#2 GC',Mapping_Field_Value__c='USG ULS#2',Is_Active__c=True);
        
        mnS.add(fvm26);
        
        RE_Field_Value_Mappings__c fvm27 = New RE_Field_Value_Mappings__c(Name='fvm27',Country_Name__c='Canada',Purpose__c='Live OPIS Spot Ticker Import',Object_Name__c='RE_MOA__c',
                                                                          Field_Name__c='RE_CND_Marker_Name__c',Source_Field_Value__c='EAST ULS#2 GC (Change)',Mapping_Field_Value__c='USG ULS#2',Is_Active__c=True);
        
        mnS.add(fvm27);
        
        Insert mnS;
        return mnS;
    }
    
    public static RE_Field_Value_Mappings__c createFieldValueMappings (String Name,String CountryName,String Purpose,String ObjectName,String FieldName,String SourceFieldValue,String MappingFieldValue,Boolean IsActive)
    {
        RE_Field_Value_Mappings__c fvm = new  RE_Field_Value_Mappings__c();
        fvm.Name =  Name;
        fvm.Country_Name__c = CountryName;
        fvm.Purpose__c = Purpose;
        fvm.Object_Name__c = ObjectName;
        fvm.Field_Name__c = FieldName;
        fvm.Source_Field_Value__c = SourceFieldValue;
        fvm.Mapping_Field_Value__c = MappingFieldValue;
        fvm.Is_Active__c = IsActive; 
        
        insert fvm;
        return fvm;
    }
    
    public static List<RE_MY_CostPrice__c> createCostPriceData()
    {
        List<RE_MY_CostPrice__c> cndCPdata = New List<RE_MY_CostPrice__c>();
        Id costpriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1);
        
        RE_MY_CostPrice__c cp1 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD CTS/LTR',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,
             RE_CND_Notify_Users__c = TRUE, RE_CND_Supplier1_Price__c=0.00, RE_CND_Supplier2_Price__c=0.00, RE_CND_Supplier3_Price__c=0.00, RE_CND_Supplier4_Price__c=0.00);
        cndCPdata.add(cp1);  
            
        RE_MY_CostPrice__c cp3 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Calgary',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD/LTR',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,
             RE_CND_Notify_Users__c = TRUE, RE_CND_Supplier1_Price__c=10.00, RE_CND_Supplier2_Price__c=20.00, RE_CND_Supplier3_Price__c=30.00, RE_CND_Supplier4_Price__c=40.00);
        cndCPdata.add(cp3); 
        insert cndCPdata;
        return cndCPdata;        
    }  
    
    public static List<RE_MY_CostPrice__c> createOldCostPriceData()
    {
        List<RE_MY_CostPrice__c> cndCPdata = New List<RE_MY_CostPrice__c>();
        Id costpriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Datetime prngDateTime = system.now();
        prngDateTime = prngDateTime.addDays(-1);
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1);
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        
        RE_MY_CostPrice__c cp1 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD CTS/LTR',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,
             RE_CND_Supplier1_Price__c=0.00, RE_CND_Supplier2_Price__c=0.00, RE_CND_Supplier3_Price__c=0.00,RE_CND_Is_Base_Product__c=TRUE,
             RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc1.Id);
        cndCPdata.add(cp1);  
        
        RE_MY_CostPrice__c cp2 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Calgary',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD CTS/LTR',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,
             RE_CND_Supplier1_Price__c=10.00, RE_CND_Supplier2_Price__c=20.00, RE_CND_Supplier3_Price__c=30.00);
        cndCPdata.add(cp2); 
        
        RE_MY_CostPrice__c cp3 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD/LTR',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,
             RE_CND_Supplier1_Price__c=0.00, RE_CND_Supplier2_Price__c=0.00, RE_CND_Supplier3_Price__c=0.00,RE_CND_Is_Base_Product__c=false,
             RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc2.Id);
        cndCPdata.add(cp3); 
        
        RE_MY_CostPrice__c cp4 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD/LTR',RE_CND_Group__c='Branded',RE_IsLatest__c=TRUE,
             RE_CND_Supplier1_Price__c=0.00, RE_CND_Supplier2_Price__c=0.00, RE_CND_Supplier3_Price__c=0.00,RE_CND_Is_Base_Product__c=false,
             RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc2.Id);
        cndCPdata.add(cp4); 
        
        insert cndCPdata;
        return cndCPdata;        
    }  
    
    public static List<RT_Setting__c> createCountrySettings()
    {                       
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        RE_Product__c prod1=RE_CND_TestDataFactory.createProduct(prodRecordID,'40005','prod2','Gas Oil','IGO','ULSD','IGO','CA',TRUE);
        
        Id cndPricngDiffRecdTypId = Schema.SObjectType.RT_Setting__c.getRecordTypeInfosByDeveloperName().get('Canada_Pricing_Differential').getRecordTypeId();
        List<RT_Setting__c> rtList = New List<RT_Setting__c>();
        
        RT_Setting__c rt = New RT_Setting__c(Name='BF1',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Brand Fee',
                                             RE_Value__c=-0.18,RE_Rate_Unit__c='CAD/LTR',Active__c=true);
        rtList.add(rt);
        
        RT_Setting__c rt11 = New RT_Setting__c(Name='BF2',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Brand Fee',
                                               RE_Value__c=-0.16,RE_Rate_Unit__c='CAD CTS/LTR',Active__c=true);
        rtList.add(rt11);
        
        RT_Setting__c rt1 = New RT_Setting__c(Name='BD1',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Brand Discount',
                                              RE_Value__c=-0.15,RE_Rate_Unit__c='CAD/LTR',Active__c=true,RE_CND_Rack__c='Edmonton');
        rtList.add(rt1);
        
        RT_Setting__c rt12 = New RT_Setting__c(Name='BD2',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Brand Discount',
                                               RE_Value__c=-0.14,RE_Rate_Unit__c='CAD CTS/LTR',Active__c=true,RE_CND_Rack__c='Edmonton');
        rtList.add(rt12);
        
        RT_Setting__c rt2 = New RT_Setting__c(Name='PLD1',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Plant Differential',
                                              RE_Value__c=-0.17,RE_Rate_Unit__c='CAD/LTR',Active__c=true,RE_Location_Name__c=loc1.Id);
        rtList.add(rt2);
        
        RT_Setting__c rt3 = New RT_Setting__c(Name='PD1',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Product Differential',
                                              RE_Value__c=-0.8,RE_Rate_Unit__c='CAD/LTR',Active__c=true,RE_CND_Rack__c='Edmonton',RE_Product_Name__c=prod.Id);
        rtList.add(rt3);
        
        RT_Setting__c rt4 = New RT_Setting__c(Name='PD2',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Product Differential',
                                              RE_Value__c=-0.8,RE_Rate_Unit__c='CAD CTS/LTR',Active__c=true,RE_CND_Rack__c='Edmonton',RE_Product_Name__c=prod1.Id);
        rtList.add(rt4);
        
        RT_Setting__c rt5 = New RT_Setting__c(Name='PLD2',RecordTypeId=cndPricngDiffRecdTypId,RE_CND_Differential_Type__c='Plant Differential',
                                              RE_Value__c=-0.17,RE_Rate_Unit__c='CAD CTS/LTR',Active__c=true,RE_Location_Name__c=loc2.Id);
        rtList.add(rt5);
        
        insert rtList;
        return rtList;
    }
    
    public static List<RE_MY_VolumeConversion__c> createVolumeConver()
    {
        List<RE_MY_VolumeConversion__c> volConvLst = New List<RE_MY_VolumeConversion__c>();
        RE_MY_VolumeConversion__c volConv = New RE_MY_VolumeConversion__c(Name='volConv',RE_MY_Country__c='Canada',RE_MY_Base_Volume_Unit__c='BBL',
                                                                          RE_MY_Conversion_Rate__c=0.0063,RE_MY_Volume_Unit__c='LTR');
        volConvLst.add(volConv);
        
        RE_MY_VolumeConversion__c volConv1 = New RE_MY_VolumeConversion__c(Name='volConv1',RE_MY_Country__c='Canada',RE_MY_Base_Volume_Unit__c='LTR',
                                                                           RE_MY_Conversion_Rate__c=158.9873,RE_MY_Volume_Unit__c='BBL');
        volConvLst.add(volConv1);
        
        RE_MY_VolumeConversion__c volConv2 = New RE_MY_VolumeConversion__c(Name='volConv2',RE_MY_Country__c='Canada',RE_MY_Base_Volume_Unit__c='GAL',
                                                                           RE_MY_Conversion_Rate__c=0.2642,RE_MY_Volume_Unit__c='LTR');
        volConvLst.add(volConv2);
        
        RE_MY_VolumeConversion__c volConv3 = New RE_MY_VolumeConversion__c(Name='volConv3',RE_MY_Country__c='Canada',RE_MY_Base_Volume_Unit__c='LTR',
                                                                           RE_MY_Conversion_Rate__c=3.7854,RE_MY_Volume_Unit__c='GAL');
        volConvLst.add(volConv3);
        
        Insert volConvLst;
        Return volConvLst;
    }
    
    public static List<RE_Currency_Conversion__c> createCurrcyConver()
    {
        List<RE_Currency_Conversion__c> currLst = New List<RE_Currency_Conversion__c>();
        RE_Currency_Conversion__c curr = New RE_Currency_Conversion__c(Name='curr',Base_Currency_Unit__c='CAD',Converted_Currency_Unit__c='USD',Formula__c='1/FxRate');
        currLst.add(curr);
        RE_Currency_Conversion__c curr1 = New RE_Currency_Conversion__c(Name='curr1',Base_Currency_Unit__c='CAD',Converted_Currency_Unit__c='CTS',Formula__c='100');
        currLst.add(curr1);
        RE_Currency_Conversion__c curr2 = New RE_Currency_Conversion__c(Name='curr2',Base_Currency_Unit__c='CAD',Converted_Currency_Unit__c='USD CTS',Formula__c='100/FxRate');
        currLst.add(curr2);
        RE_Currency_Conversion__c curr3 = New RE_Currency_Conversion__c(Name='curr3',Base_Currency_Unit__c='USD',Converted_Currency_Unit__c='CAD',Formula__c='FxRate');
        currLst.add(curr3);
        RE_Currency_Conversion__c curr4 = New RE_Currency_Conversion__c(Name='curr4',Base_Currency_Unit__c='USD',Converted_Currency_Unit__c='CAD CTS',Formula__c='100*FxRate');
        currLst.add(curr4);
        RE_Currency_Conversion__c curr5 = New RE_Currency_Conversion__c(Name='curr5',Base_Currency_Unit__c='USD',Converted_Currency_Unit__c='USD CTS',Formula__c='100');
        currLst.add(curr5);
        RE_Currency_Conversion__c curr6 = New RE_Currency_Conversion__c(Name='curr6',Base_Currency_Unit__c='CAD CTS',Converted_Currency_Unit__c='USD',Formula__c='0.01/FxRate');
        currLst.add(curr6);
        RE_Currency_Conversion__c curr7 = New RE_Currency_Conversion__c(Name='curr7',Base_Currency_Unit__c='CAD CTS',Converted_Currency_Unit__c='USD CTS',Formula__c='1/FxRate');
        currLst.add(curr7);
        
        Insert currLst;
        return currLst;
    }
    
    public static List<RE_MY_CostPrice__c> createOldCostPriceData_New()
    {
        List<RE_MY_CostPrice__c> cndCPdata = New List<RE_MY_CostPrice__c>();
        Id costpriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Datetime prngDateTime = system.now();
        prngDateTime = prngDateTime.addDays(-1);
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1);
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        RE_Product__c prod1=RE_CND_TestDataFactory.createProduct(prodRecordID,'40005','prod2','Gas Oil','IGO','ULSD','IGO','CA',TRUE);
        
        RE_MY_CostPrice__c cp1 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD CTS/LTR',RE_CND_Group__c='Unbranded',
             RE_CND_Is_Base_Product__c=TRUE,RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc1.Id,RE_IsLatest__c=TRUE);
        cndCPdata.add(cp1); 
        
        RE_MY_CostPrice__c cp2 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD/LTR',RE_CND_Group__c='Unbranded',
             RE_CND_Is_Base_Product__c=FALSE, RE_CND_Pricing_Basis__c='40004-C123-Unbranded', RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc1.Id,RE_IsLatest__c=TRUE);
        cndCPdata.add(cp2); 
        
        insert cndCPdata;
        return cndCPdata;
    }
    
    public static List<RE_MY_CostPrice__c> createNewCostPriceData()
    {
        List<RE_MY_CostPrice__c> cndCPdata = New List<RE_MY_CostPrice__c>();
        Id costpriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Datetime prngDateTime = system.now();      
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1);
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        RE_Product__c prod1=RE_CND_TestDataFactory.createProduct(prodRecordID,'40005','prod2','Gas Oil','IGO','ULSD','IGO','CA',TRUE);
        
        RE_MY_CostPrice__c cp1 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD CTS/LTR',RE_CND_Group__c='Unbranded',
             RE_CND_Is_Base_Product__c=TRUE,RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc1.Id,RE_IsLatest__c=TRUE,RE_Initial_Version__c='Test1');
        cndCPdata.add(cp1); 
        
        RE_MY_CostPrice__c cp2 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD/LTR',RE_CND_Group__c='Unbranded',
             RE_CND_Is_Base_Product__c=FALSE, RE_CND_Pricing_Basis__c='40004-C123-Unbranded', RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc1.Id,RE_IsLatest__c=TRUE,RE_Initial_Version__c='Test1');
        cndCPdata.add(cp2); 
        
        RE_MY_CostPrice__c cp3 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_Fx_Rate__c=1.255,RE_Costprice_Unit__c='CAD CTS/LTR',RE_CND_Group__c='Unbranded',
             RE_CND_Is_Base_Product__c=FALSE, RE_CND_Pricing_Basis__c='40004-C234-Unbranded', RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc2.Id,RE_IsLatest__c=TRUE,RE_Initial_Version__c='Test2');
        cndCPdata.add(cp3); 
        
        insert cndCPdata;
        return cndCPdata;
    }
    
    public static List<RE_Depot_Pricing_Backbone__c> createDepoPricingData_New()
    {
        List<RE_Depot_Pricing_Backbone__c> depoPrcng = New List<RE_Depot_Pricing_Backbone__c>();
        Id cndProductRecdTypId = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndLocationRecdTypId = Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndDepotPricingRecdTypId = Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        RE_Product__c prod1=RE_CND_TestDataFactory.createProduct(prodRecordID,'40005','prod2','Gas Oil','IGO','ULSD','IGO','CA',TRUE);
        
        id plantDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Plant Differential' and name='PLD1'].Id;
        id productDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Product Differential' and name='PD1'].Id;
        id brandFeeId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Fee' and name='BF1'].Id;
        id brandDiscountId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Discount' and name='BD1'].Id;
        
        id ctsplantDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Plant Differential' and name='PLD2'].Id;
        id ctsproductDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Product Differential' and name='PD2'].Id;
        id ctsbrandFeeId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Fee' and name='BF2'].Id;
        id ctsbrandDiscountId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Discount' and name='BD2'].Id;        
        
        RE_Depot_Pricing_Backbone__c depo1 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                              RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD CTS/LTR',
                                                                              RE_CND_Is_Base_Product__c=TRUE,RE_Location_Name__c=loc1.Id,RE_Product_Name__c=prod.Id,                                                                            
                                                                              RE_CND_Rack_Differential_Basis__c='Edmonton',RE_Product_Classification__c='Gasoline',
                                                                              RE_CND_Required_CanadianDailyRack__c = TRUE,RE_CND_Required_CanadianDailyRack7Day__c=TRUE);
        depoPrcng.add(depo1);
        
        RE_Depot_Pricing_Backbone__c depo2 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                              RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD CTS/LTR',
                                                                              RE_CND_Is_Base_Product__c=false,RE_Location_Name__c=loc1.Id,RE_Product_Name__c=prod.Id,
                                                                              RE_CND_Product_Pricing_Basis__c=prod.Id,RE_CND_Plant_Pricing_Basis__c=loc1.Id,RE_CND_Group_Pricing_Basis__c='Unbranded',
                                                                              RE_CND_Brand_Fees__c=brandFeeId, RE_CND_Brand_Discount__c=brandDiscountId,
                                                                              RE_CND_Plant_Differential__c = plantDifferentialId,RE_CND_Product_Differentials__c = productDifferentialId);
        depoPrcng.add(depo2);
        
        RE_Depot_Pricing_Backbone__c depo3 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Sarnia',
                                                                              RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD/LTR',
                                                                              RE_CND_Is_Base_Product__c=false,RE_Location_Name__c=loc2.Id,RE_Product_Name__c=prod1.Id,
                                                                              RE_CND_Product_Pricing_Basis__c=prod1.Id,RE_CND_Plant_Pricing_Basis__c=loc2.Id,RE_CND_Group_Pricing_Basis__c='Unbranded',
                                                                              RE_CND_Plant_Differential__c = plantDifferentialId,RE_CND_Product_Differentials__c = productDifferentialId);
        depoPrcng.add(depo3);
        
        insert depoPrcng;
        return depoPrcng;
        
    }
    
    public static List<RE_Depot_Pricing_Backbone__c> createDepoPricingData()
    {
        List<RE_Depot_Pricing_Backbone__c> depoPrcng = New List<RE_Depot_Pricing_Backbone__c>();
        Id cndProductRecdTypId = Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndLocationRecdTypId = Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        Id cndDepotPricingRecdTypId = Schema.SObjectType.RE_Depot_Pricing_Backbone__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        RE_Product__c prod1=RE_CND_TestDataFactory.createProduct(prodRecordID,'40005','prod2','Gas Oil','IGO','ULSD','IGO','CA',TRUE);
        
        id plantDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Plant Differential' Limit 1].Id;
        id productDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Product Differential' Limit 1].Id;
        id brandFeeId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Fee' Limit 1].Id;
        id brandDiscountId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Discount' Limit 1].Id;
        
        id ctsplantDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Plant Differential' Limit 1].Id;
        id ctsproductDifferentialId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Product Differential' Limit 1].Id;
        id ctsbrandFeeId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Fee' Limit 1].Id;
        id ctsbrandDiscountId = [Select Id from RT_Setting__c where RE_CND_Differential_Type__c='Brand Discount' Limit 1].Id;
        
        RE_Depot_Pricing_Backbone__c depo1 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                              RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD CTS/LTR',
                                                                              RE_CND_Is_Base_Product__c=TRUE,RE_Location_Name__c=loc1.Id,RE_Product_Name__c=prod.Id,                                                                            
                                                                              RE_CND_Rack_Differential_Basis__c='Edmonton',RE_Product_Classification__c='Gasoline',
                                                                              RE_CND_Required_CanadianDailyRack__c = TRUE,RE_CND_Required_CanadianDailyRack7Day__c=TRUE);
        depoPrcng.add(depo1);
        
        RE_Depot_Pricing_Backbone__c depo11 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                               RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='USD/LTR',
                                                                               RE_CND_Is_Base_Product__c=TRUE,RE_Location_Name__c=loc2.Id,RE_Product_Name__c=prod.Id,                                                                            
                                                                               RE_CND_Rack_Differential_Basis__c='Edmonton',RE_Product_Classification__c='Gas Oil',
                                                                               RE_CND_Required_CanadianDailyRack__c = TRUE,RE_CND_Required_CanadianDailyRack7Day__c=TRUE);
        depoPrcng.add(depo11);
        
        RE_Depot_Pricing_Backbone__c depo2 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                              RE_CND_Group__c='Branded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD CTS/LTR',
                                                                              RE_CND_Is_Base_Product__c=false,RE_Location_Name__c=loc1.Id,RE_Product_Name__c=prod.Id,
                                                                              RE_CND_Product_Pricing_Basis__c=prod.Id,RE_CND_Plant_Pricing_Basis__c=loc1.Id,RE_CND_Group_Pricing_Basis__c='Unbranded',
                                                                              RE_CND_Brand_Fees__c=ctsbrandFeeId, RE_CND_Brand_Discount__c=ctsbrandDiscountId,RE_CND_Plant_Differential__c=ctsplantDifferentialId,
                                                                              RE_CND_Product_Differentials__c=ctsproductDifferentialId);
        depoPrcng.add(depo2);
        
        RE_Depot_Pricing_Backbone__c depo22 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                               RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD/LTR',
                                                                               RE_CND_Is_Base_Product__c=false,RE_Location_Name__c=loc1.Id,RE_Product_Name__c=prod.Id,
                                                                               RE_CND_Product_Pricing_Basis__c=prod.Id,RE_CND_Plant_Pricing_Basis__c=loc1.Id,RE_CND_Group_Pricing_Basis__c='Unbranded',
                                                                               RE_CND_Brand_Fees__c=ctsbrandFeeId, RE_CND_Brand_Discount__c=ctsbrandDiscountId,
                                                                               RE_CND_Plant_Differential__c = ctsplantDifferentialId,RE_CND_Product_Differentials__c = ctsproductDifferentialId);
        depoPrcng.add(depo22);    
        
        RE_Depot_Pricing_Backbone__c depo23 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                               RE_CND_Group__c='Unbranded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='USD CTS/LTR',
                                                                               RE_CND_Is_Base_Product__c=false,RE_Location_Name__c=loc2.Id,RE_Product_Name__c=prod1.Id,
                                                                               RE_CND_Product_Pricing_Basis__c=prod.Id,RE_CND_Plant_Pricing_Basis__c=loc1.Id,RE_CND_Group_Pricing_Basis__c='Unbranded',
                                                                               RE_CND_Brand_Fees__c=brandFeeId, RE_CND_Brand_Discount__c=brandDiscountId);
        depoPrcng.add(depo23);    
        
        RE_Depot_Pricing_Backbone__c depo24 = New RE_Depot_Pricing_Backbone__c(RecordTypeId=cndDepotPricingRecdTypId,RE_CND_Rack__c='Edmonton',
                                                                               RE_CND_Group__c='Branded',RE_Is_Active__c=TRUE,RE_Final_Price_Unit__c='CAD CTS/LTR',
                                                                               RE_CND_Is_Base_Product__c=false,RE_Location_Name__c=loc2.Id,RE_Product_Name__c=prod.Id,
                                                                               RE_CND_Product_Pricing_Basis__c=prod.Id,RE_CND_Plant_Pricing_Basis__c=loc1.Id,RE_CND_Group_Pricing_Basis__c='Unbranded',
                                                                               RE_CND_Brand_Fees__c=brandFeeId, RE_CND_Brand_Discount__c=brandDiscountId);
        depoPrcng.add(depo24);    
        
        
        insert depoPrcng;
        return depoPrcng;
    }
    
    public static RE_MY_CostPrice__c createCostPrice(Id recordType,String Group1,String Rack,String status,Decimal finalValue,
                                                     Id ProdID,Id LocID,String basis,Boolean isBase,String rateUnit,decimal supplr1,decimal supplr2,decimal supplr3)
    {
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1);
        
        RE_MY_CostPrice__c cp = new RE_MY_CostPrice__c();
        cp.RE_CND_Rack__c=Rack;
        cp.RE_CND_Final_Value__c=finalValue;
        cp.RE_CND_Differential_Basis__c='Edmonton-RUG';
        cp.RE_CND_Product_Group__c='RUG';
        cp.RE_CND_Adjustment_Value__c=0;
        cp.RE_Product_Name__c=ProdID;
        cp.RE_Depot_Name__c=LocID;
        cp.RE_IsLatest__c=TRUE;
        cp.RE_Pricing_Date__c=prngDateTime;
        cp.RE_CND_Brand_Discount__c=0;
        cp.RE_CND_Plant_Differential__c=0;
        cp.RE_CND_Brand_Fee__c=0;
        cp.RE_CND_Product_Differential__c=0;
        cp.RE_Fx_Rate__c=2;
        cp.RE_CND_Old_Base_Value__c=99;
        cp.RE_CND_Market_Move__c=1;
        cp.RE_CND_New_Base_Value__c=100;
        cp.RE_CND_Effective_From_Date__c=prngFrmToDate;
        cp.RE_CND_Effective_To_Date__c=prngFrmToDate;
        cp.RE_Requested_Date__c = reqDate;
        cp.RE_CND_Pricing_Basis__c=basis;
        cp.RE_CND_Parent_Rack__c='Edmonton';
        cp.RE_CND_Parent_Rack_Group__c='RUG';
        cp.RE_Status__c=status;
        cp.RE_CND_Is_Base_Product__c=isBase;
        cp.RE_CND_Group__c=Group1;
        cp.RE_Costprice_Unit__c=rateUnit;
        cp.RecordTypeId=recordType;
        cp.RE_CND_Supplier1_Price__c = supplr1;
        cp.RE_CND_Supplier2_Price__c = supplr2;
        cp.RE_CND_Supplier3_Price__c = supplr3;   
        
        insert cp;
        return cp;
    }
    
    public static RT_Price_Book__c createPriceBook(Id recordType,String Rack,String Group1,String status,Decimal finalValue,Id ProdID,Id LocID,String basis,
                                                   Id shipTo,Id soldTo,String rateUnit,Date fromDate,Date toDate)
    {
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        prngFrmToDate = prngFrmToDate.addDays(1);
        
        RT_Price_Book__c pb = new RT_Price_Book__c();
        pb.RecordTypeId=recordType;
        pb.RT_Location__c=LocID;
        pb.RE_CND_Rack__c=Rack; 
        pb.RE_CND_Product_Group__c=Group1;
        pb.RE_CND_Adjustment_Value__c=0;
        pb.RT_Product__c=ProdID;
        pb.RE_CND_Customer_Name__c=shipTo;
        pb.RT_Sold_to_Name__c=soldTo;
        pb.RE_Fx_Rate__c=1.5;
        pb.RE_CND_Old_Base_Value__c=5; 
        pb.RE_CND_New_Base_Value__c=finalValue;
        pb.RE_CND_Market_Move__c=5;
        pb.RE_CND_Final_Value__c=finalValue; 
        pb.RE_CND_Effective_From_Date__c=prngFrmToDate;
        pb.RE_CND_Effective_To_Date__c=prngFrmToDate;
        pb.RT_Effective_Date__c = reqDate;
        pb.RE_CND_Pricing_Basis__c=basis;
        pb.RE_Is_Latest__c=TRUE;
        pb.RE_Pricing_Date__c=prngDateTime;
        pb.RE_Final_Price_Unit__c=rateUnit;
        pb.RE_Custom_Opp_Approve__c=status; 
        insert pb;
        return pb;
    }
    
    public static RE_MY_CostPrice__c createCostPriceToday(Id recordType,String Group1,String Rack,String status,Decimal finalValue,
                                                          Id ProdID,Id LocID,String basis,Boolean isBase,String rateUnit,decimal supplr1,decimal supplr2,decimal supplr3)
    {       
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        
        RE_MY_CostPrice__c cp = new RE_MY_CostPrice__c();
        cp.RE_CND_Rack__c=Rack;
        cp.RE_CND_Final_Value__c=finalValue;
        cp.RE_CND_Differential_Basis__c='Edmonton-RUG';
        cp.RE_CND_Product_Group__c='RUG';
        cp.RE_CND_Adjustment_Value__c=0;
        cp.RE_Product_Name__c=ProdID;
        cp.RE_Depot_Name__c=LocID;
        cp.RE_IsLatest__c=TRUE;
        cp.RE_Pricing_Date__c=prngDateTime;
        cp.RE_Requested_Date__c =reqDate;
        cp.RE_CND_Brand_Discount__c=0;
        cp.RE_CND_Plant_Differential__c=0;
        cp.RE_CND_Brand_Fee__c=0;
        cp.RE_CND_Product_Differential__c=0;
        cp.RE_Fx_Rate__c=2;
        cp.RE_CND_Old_Base_Value__c=99;
        cp.RE_CND_Market_Move__c=1;
        cp.RE_CND_New_Base_Value__c=100;
        cp.RE_CND_Effective_From_Date__c=System.today();
        cp.RE_CND_Effective_To_Date__c=System.today();
        cp.RE_CND_Pricing_Basis__c=basis;
        cp.RE_CND_Parent_Rack__c='Edmonton';
        cp.RE_CND_Parent_Rack_Group__c='RUG';
        cp.RE_Status__c=status;
        cp.RE_CND_Is_Base_Product__c=isBase;
        cp.RE_CND_Group__c=Group1;
        cp.RE_Costprice_Unit__c=rateUnit;
        cp.RecordTypeId=recordType;
        cp.RE_CND_Supplier1_Price__c = supplr1;
        cp.RE_CND_Supplier2_Price__c = supplr2;
        cp.RE_CND_Supplier3_Price__c = supplr3;   
        cp.RE_Submitter_Comments__c='Test';
        insert cp;
        return cp;
    }
    
    public static RT_Price_Book__c createPriceBookToday(Id recordType,String Rack,String Group1,String status,Decimal finalValue,Id ProdID,Id LocID,String basis,
                                                        Id shipTo,Id soldTo,String rateUnit,Date fromDate,Date toDate)
    {
        Datetime prngDateTime = system.now();
        Date prngFrmToDate =  date.newinstance(prngDateTime.year(), prngDateTime.month(), prngDateTime.day());
        Date reqDate = prngFrmToDate;
        
        RT_Price_Book__c pb = new RT_Price_Book__c();
        pb.RecordTypeId=recordType;
        pb.RT_Location__c=LocID;
        pb.RE_CND_Rack__c=Rack; 
        pb.RE_CND_Product_Group__c=Group1;
        pb.RE_CND_Adjustment_Value__c=0;
        pb.RT_Product__c=ProdID;
        pb.RE_CND_Customer_Name__c=shipTo;
        pb.RT_Sold_to_Name__c=soldTo;
        pb.RE_Fx_Rate__c=1.5;
        pb.RE_CND_Old_Base_Value__c=5; 
        pb.RE_CND_New_Base_Value__c=finalValue;
        pb.RE_CND_Market_Move__c=5;
        pb.RE_CND_Final_Value__c=finalValue; 
        pb.RE_CND_Effective_From_Date__c=fromDate;
        pb.RE_CND_Effective_To_Date__c=toDate;
        pb.RE_CND_Pricing_Basis__c=basis;
        pb.RE_Is_Latest__c=TRUE;
        pb.RE_Pricing_Date__c=System.now();
        pb.RT_Effective_Date__c = reqDate;
        pb.RE_Final_Price_Unit__c=rateUnit;
        pb.RE_Custom_Opp_Approve__c=status; 
        pb.RE_Submitter_Comments__c='Test';
        insert pb;
        return pb;
    }   
    
    public static RE_CND_Conga_Output_Settings__c createCongaOutputSettngs (String Name,String FileName,String RackName, String ProductGroupName,String ProductCode,String LocationCode,String GroupName,String DisplayEnglishRack,
                                                                            String DisplayFrenchRack, String DisplayEnglishProdGroup, String DisplayFrenchProdGroup, Integer SequenceNo,String SectionName, Boolean IsActive)
    {
        RE_CND_Conga_Output_Settings__c conOPSett = new RE_CND_Conga_Output_Settings__c();
        conOPSett.Name =  Name;
        conOPSett.File_Name__c =  FileName;
        conOPSett.Rack_Name__c =  RackName;
        conOPSett.Product_Group_Name__c =  ProductGroupName;
        conOPSett.Product_Code__c =  ProductCode;
        conOPSett.Location_Code__c =  LocationCode;
        conOPSett.Group__c =  GroupName;
        conOPSett.Display_English_Rack_Name__c =  DisplayEnglishRack;
        conOPSett.Display_French_Rack_Name__c =  DisplayFrenchRack;
        conOPSett.Display_English_Product_Group__c =  DisplayEnglishProdGroup;
        conOPSett.Display_French_Product_Group__c =  DisplayFrenchProdGroup;
        conOPSett.Sequence_No__c =  SequenceNo;
        conOPSett.Section_Name__c =  SectionName;
        conOPSett.Is_Active__c = IsActive; 
        
        insert conOPSett;
        return conOPSett;
    }
    
    public static List<RE_MY_CostPrice__c> createCostPriceDataForEmailOutput(Datetime prngDateTime, Date reqDate, Date prngFrmToDate)
    {
        List<RE_MY_CostPrice__c> cndCPdata = New List<RE_MY_CostPrice__c>();
        Id costpriceRecordTypeId = Schema.SObjectType.RE_MY_CostPrice__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
                
        Id locRecordID=Schema.SObjectType.RE_Location__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Location__c loc1= RE_CND_TestDataFactory.createLocation(locRecordID,'C123','ABC Refuel','Scot','CA',true);
        RE_Location__c loc2= RE_CND_TestDataFactory.createLocation(locRecordID,'C234','XYZ Refuel','Shor','CA',true);
        
        Id prodRecordID=Schema.SObjectType.RE_Product__c.getRecordTypeInfosByDeveloperName().get('Canada').getRecordTypeId();
        RE_Product__c prod=RE_CND_TestDataFactory.createProduct(prodRecordID,'40004','prod1','Gasoline','IGO','RUG','IGO','CA',TRUE);
        RE_Product__c prod1=RE_CND_TestDataFactory.createProduct(prodRecordID,'40005','prod2','Gas Oil','Kero','ULSD','Kero','CA',TRUE);
        
        RE_MY_CostPrice__c cp1 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,RE_CND_Notify_Users__c=TRUE,
             RE_CND_Old_Base_Value__c=98.5, RE_CND_New_Base_Value__c=100, RE_CND_Final_Value__c=101.00,
             RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc1.Id,RE_CND_NewRack_Or_NewBAPP_File__c ='NewRack');
        cndCPdata.add(cp1);  
        
        RE_MY_CostPrice__c cp2 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='RUG',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,RE_CND_Notify_Users__c=TRUE,
             RE_CND_Old_Base_Value__c=98.5, RE_CND_New_Base_Value__c=100, RE_CND_Final_Value__c=101.00,
             RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc2.Id,RE_CND_NewRack_Or_NewBAPP_File__c ='NewRack', RE_CND_Req_in_DailyRackChange_Notifi__c= TRUE);
        cndCPdata.add(cp2); 
        
        RE_MY_CostPrice__c cp3 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='ULSD',RE_CND_Group__c='Branded',RE_IsLatest__c=TRUE,RE_CND_Notify_Users__c=TRUE,
             RE_CND_Old_Base_Value__c=98.5, RE_CND_New_Base_Value__c=100, RE_CND_Final_Value__c=101.00,
             RE_Product_Name__c = prod1.id,RE_Depot_Name__c=loc1.Id,RE_CND_NewRack_Or_NewBAPP_File__c ='NewBAPP');
        cndCPdata.add(cp3); 
        
        RE_MY_CostPrice__c cp4 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='ULSD',RE_CND_Group__c='Branded',RE_IsLatest__c=TRUE,RE_CND_Notify_Users__c=TRUE,
             RE_CND_Old_Base_Value__c=98.5, RE_CND_New_Base_Value__c=100, RE_CND_Final_Value__c=101.00,
             RE_Product_Name__c = prod1.id,RE_Depot_Name__c=loc2.Id,RE_CND_NewRack_Or_NewBAPP_File__c ='NewBAPP', RE_CND_Req_in_DailyRackChange_Notifi__c= TRUE);
        cndCPdata.add(cp4);  
                RE_MY_CostPrice__c cp5 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='ULSD',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,RE_CND_Notify_Users__c=TRUE,
             RE_CND_Old_Base_Value__c=98.5, RE_CND_New_Base_Value__c=100, RE_CND_Final_Value__c=101.00,
             RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc1.Id,RE_CND_NewRack_Or_NewBAPP_File__c ='NewRack', RE_CND_Req_in_DailyRackChange_Notifi__c= TRUE);
        cndCPdata.add(cp5);  
        
                RE_MY_CostPrice__c cp6 = new RE_MY_CostPrice__c
            (RecordTypeId = costpriceRecordTypeId, RE_Pricing_Date__c=prngDateTime,RE_CND_Effective_From_Date__c = prngFrmToDate, RE_CND_Effective_To_Date__c= prngFrmToDate,RE_Requested_Date__c=reqDate,
             RE_Status__c = 'Ready to Upload', RE_CND_Rack__c='Edmonton',RE_CND_Product_Group__c='ULSD',RE_CND_Group__c='Unbranded',RE_IsLatest__c=TRUE,RE_CND_Notify_Users__c=TRUE,
             RE_CND_Old_Base_Value__c=98.5, RE_CND_New_Base_Value__c=100, RE_CND_Final_Value__c=101.00,
             RE_Product_Name__c = prod.id,RE_Depot_Name__c=loc2.Id,RE_CND_NewRack_Or_NewBAPP_File__c ='NewRack', RE_CND_Req_in_DailyRackChange_Notifi__c= TRUE);
        cndCPdata.add(cp6); 
        insert cndCPdata;
        return cndCPdata;        
    } 
    
    public static RE_CND_Base_Reference_Rack_Settings__c creatBaseRefRackSettingsManager (String name1,String rack,String baseRack,String refRack, String prodClssi)
    {
        RE_CND_Base_Reference_Rack_Settings__c brr = new  RE_CND_Base_Reference_Rack_Settings__c();
        brr.Name=name1;
        brr.Rack__c=rack;
        brr.Base_Rack__c=baseRack;
        brr.Reference_Rack__c=refRack;
        brr.Product_Classification_L0__c=prodClssi;
        brr.Is_Active__c= True;
        
        insert brr;
        return brr;
    }   

}