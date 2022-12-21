@isTest
public class RE_CovamoControllerTest {  
     public static testMethod void covamoTest() {
         String offerRecordTypeId = Schema.SObjectType.Rev_Covamo_Detail__c.getRecordTypeInfosByName().get('Offer').getRecordTypeId();
         Rev_Covamo_Header__c covHeader = new Rev_Covamo_Header__c(Contract_Name__c='Test Name',Customer_Name__c='Test Name',RE_Valuation_Start_Year__c='2020',RE_Valuation_End_Year__c='2022',Local_Currency__c='MYR',Base_Unit__c='Litre',Inflation_Rate__c=10,Weighted_Avearge_Percentage__c=5,VAT_Percentage__c=12,Payment_Days__c=5,Income_Tax_Payable_Days__c=7,Income_Tax_Payable_Percentage__c=18,Exchange_Rate__c=11.11);
         insert covHeader;
         RE_FX_Rates__c fxRates = new RE_FX_Rates__c(RE_Forex_Name__c='MYR/USD',RE_Conversion_Unit__c='MYR',RE_Trade_Type__c='Exchange Rate',RE_Tracker__c='D');
         insert fxRates;
         RE_Product__c product = new RE_Product__c(Name='Kerosene');
         insert product;
         Rev_Covamo_Detail__c covDetail = new Rev_Covamo_Detail__c(Volume__c=500000,MOPS__c=-0.108,Freight__c=0,Oil_Loss__c=-0.1192,Breakbulk_Cost__c=0,Handling_Cost__c=-0.308,Secondary_Transport__c=-0.9794,Product_Name__c='Kerosene',Type__c='Offer',Expected_Premium_Price_Out__c=0.1192,BDF__c=2.00);
		 insert covDetail;
         List<Rev_Covamo_Detail__c> covDetailList = new List<Rev_Covamo_Detail__c>();
         List<Rev_Covamo_Detail__c> covDetailList1 = new List<Rev_Covamo_Detail__c>();
         Rev_Covamo_Detail__c covDetail1 = new Rev_Covamo_Detail__c(Payables_Days__c=5,BDF__C=2.00,Excise_Fee__c=40,Cost_Between_C3_C5__c=-0.1,Cost_Below_C5__c=-0.2,Transportation_Margin__c=2,Receivables_Days__c=45,Total_Sales_Margin__c=1.7841,Stocks_Days__c=10,Purchase_Margin__c=5,RE_Product__c=product.Id,Volume__c=500000,MOPS__c=-0.108,Freight__c=0,Oil_Loss__c=-0.1192,Breakbulk_Cost__c=0,Handling_Cost__c=-0.308,Secondary_Transport__c=-0.9794,Product_Name__c='Kerosene',Type__c='Offer',Expected_Premium_Price_Out__c=0.1192);
         covDetailList1.add(covDetail1);
         
         Covamo_Admin_Setup__c adminData = new Covamo_Admin_Setup__c(NAME='Malaysia',Base_Unit__c='Litre',Local_Currency__c='MYR',Analysis_Period_Setting__c='ANNUAL MODEL',Conversion_SI__c=1000,Corporate_income_tax_payable__c=30,Corporate_income_tax_rate__c=24.00,Days_Per_year__c=365,Inflation_Rate__c=2.00,Integrity_check__c=1.00,VAT_Duties_payable_receivable__c=0.00,VAT_Rate__c=1.00,Cost_Below_C5__c=1.00,Cost_Between_C3_C5__c=1.00,Payables__c=5,Temperature_Gain__c=1.00,RE_Excise_Duties_in_local_currency__c=1.00);
         insert adminData;
         RE_Market_Quotes__c marketQuote = new RE_Market_Quotes__c(RE_Price__c=-4.3,RE_Tracker__c='D',RE_Quote_Type__c='Settlement',RE_Quote_Name__c='Kero');
         insert marketQuote;
         RE_FX_Rates__c fxRates1 = new RE_FX_Rates__c(RE_Forex_Name__c='MYR/USD',RE_Conversion_Unit__c='MYR',RE_Trade_Type__c='Sell',RE_Tracker__c='D+1');
		 insert fxRates1;
         RE_Rate_Unit_Manager__c rateUnit = new RE_Rate_Unit_Manager__c(Name='SGD/BBL',re_rate_unit__c='USD/BBL',RE_Currency_Unit__c='USD',RE_Volume_Unit__c='BBL');
		 insert rateUnit;
         RE_Rate_Unit_Manager__c rateUnit1 = new RE_Rate_Unit_Manager__c(Name='MYR/LTR',re_rate_unit__c='MYR/LTR',RE_Currency_Unit__c='MYR',RE_Volume_Unit__c='LTR');
		 insert rateUnit1;//"a2p0C0000008JWHQA2"
         String datasetval = '[{"Product_Name__c":"Kerosene","RE_Product__c":"'+product.id+'","RecordTypeId":"","Type__c":"Offer","Volume__c":"400","MOPS__c":"-0.108","Market_Premium__c":"","Fixed_Premium__c":"","Freight__c":"0","Oil_Loss__c":"-0.1192","Additives__c":"","Biofuel__c":"","Hedging_Cost__c":"","Breakbulk_Cost__c":"","Miscellaneous_Cost__c":"","Purchase_Margin__c":"","Primary_Transport__c":"","Handling_Cost__c":"","Secondary_Transport__c":"","Transportation_Margin__c":"","Temperature_Gain__c":"","Expected_Premium_Price_Out__c":"0.1192","Distillation_Premium__c":"","Total_Sales_Margin__c":"","Amortization_Per_Unit__c":"","Unit_C3__c":"","Target_Unit_C3__c":"","Cost_Between_C3_C5__c":"","Cost_Below_C5__c":"","Stocks_Days__c":"","Receivables_Days__c":"","Payables_Days__c":"","Excise_Fee__c":""}]';
         String covamoupdateddataset = '[{"comHeader":{"Unit_C3__c":0.4,"Freight__c":0,"Transportation_Margin__c":-1.6649,"Total_Sales_Margin__c":1.7841,"RecordTypeId":"0120C00000074TrQAI","Volume__c":300,"Secondary_Transport__c":-1.3059,"MOPS__c":-0.108,"Expected_Premium_Price_Out__c":1.7841,"RE_Product__c":"'+product.Id+'","Cost_Between_C3_C5__c":-0.13,"Cost_Below_C5__c":-0.14,"Breakbulk_Cost__c":0,"Product_Name__c":"Kerosene","Purchase_Margin__c":-0.1192,"Type__c":"Offer","attributes":{"type":"Rev_Covamo_Detail__c"},"Oil_Loss__c":-0.1192,"Handling_Cost__c":-0.359}}]';
		 Rev_Covamo_FS__c covamoFS = new Rev_Covamo_FS__c();
         insert covamoFS;
         List<Rev_Covamo_FS__c> covamoFSList = new List<Rev_Covamo_FS__c>();
         Rev_Covamo_FS__c covamoFS1 = new Rev_Covamo_FS__c();
		 covamoFSList.add(covamoFS1);         
         List<Rev_Covamo_Yearly_FS__c> covamoYealyFSList = new List<Rev_Covamo_Yearly_FS__c>();
         Rev_Covamo_Yearly_FS__c covamoYearlyFS1 = new Rev_Covamo_Yearly_FS__c(Rev_Covamo_Header__c=covHeader.Id,Year__c='2020',Type__c='Offer');
         covamoYealyFSList.add(covamoYearlyFS1);
         Map<String,String> yearlyFSMap	= new Map<String,String>();
         for(Rev_Covamo_Yearly_FS__c bs: covamoYealyFSList){
            String keyVal = ''+bs.Year__c + bs.Type__c;
            yearlyFSMap.put(keyVal,bs.Id);
             System.debug('yearlyFSMap test---'+yearlyFSMap);
        }
         List<String> delList = new List<String>();
         Test.startTest();
		 System.debug('marketQuote'+marketQuote);
         RE_CovamoController.getCovamo_HeaderValueset(covHeader.Id);
         RE_CovamoController.getCovamo_DetailsValueset(covDetail.Id);
         RE_CovamoController.fetchProductValues();
         RE_CovamoController.fetchRecordTypeValues('Offer');
         RE_CovamoController.getCovamo_HeaderFieldataset();
         RE_CovamoController.saveCovamo_HeaderFieldataset(JSON.serialize(covHeader),JSON.serialize(covDetailList),delList);
         RE_CovamoController.covemoDetailInitialization(product.Name,product.Id,'Offer',offerRecordTypeId,10.1,10.2,10.3,10.4,10.5,10.6,JSON.serialize(covHeader),0.308,0.00);
         RE_CovamoController.saveCovamo_detailsset(JSON.serialize(covDetail),datasetval);
         RE_CovamoController.saveUpdatedCovamo_detailsset(JSON.serialize(covDetail),datasetval,0);
         RE_CovamoController.deleteCovamo_detailsset(covamoupdateddataset,0,delList);
         RE_CovamoController.getRev_Covamo_Header();
         RE_CovamoController.searchRev_Covamo_Header('Test');
         RE_CovamoController.getCovHeaderRecordTypeName(covHeader.Id);
         RE_CovamoController.getCovamoHeaderQueueUsers();
         RE_CovamoController.insertProducts_FS(covDetailList,covamoFS.Id);
         RE_CovamoController.calculateFinancialSummary(covHeader,covDetailList1,covamoYealyFSList,covamoFSList);
         RE_CovamoController.getFinancialBase(covHeader,covDetailList1,yearlyFSMap);
         RE_CovamoController.FinanceDataSet(covHeader.Id);
         Test.stopTest();
         
    }
}