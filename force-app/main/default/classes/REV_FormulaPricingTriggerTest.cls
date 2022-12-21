@isTest
public class REV_FormulaPricingTriggerTest {
    
     private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"Varkey" : "TR0402020011798530T314000000000400003981","Uom" : "L15","Status" : "","StartDate" : "20210210","SeqNo" : "1","ScaleType" : "A","RuleforconversionofthedisplayedFormulaUoM" : "0","RateUnit" : "","Quantity" : "0","PriceVal" : "0","PriceItems" : [ {"Weekendruleexit" : "900","Usrexitfrrefrncdtdetrminatn" : "1","UoMfrrfrncedata1infrmultrmitemcal" : "","Timeunitofmeasureexit" : "1","Termstatus" : "","Termitemvaluecurrency" : "","Termitemvalue" : "0","Surchargevalueforformulatermitem" : "0","Surchargeunitofmsr" : "L15","Surchargeperunit" : "1000","Surchargecurrency" : "TRY","Surcharge" : "999","SeqNo" : "1","Rulefrroundingqutationprcval" : "0","Rulefrroundingformulatrmvalue" : "0","Rulefrrndtrmitemval" : "0","Rulefrrndsrchrgprceval" : "0","Ruleforroundingcurrencyexchangerate" : "0","Rfrncedata1frfrmulatermitemcal" : "0","Quotationtype" : "P","Quotationsource" : "TR","Quotationnumber" : "FOB IZMIT GO 10","Quotationgroup" : "","Quotationaveragevalue" : "0","Priodaftrbasedtefrcurr" : "0","Periodbfrbsedtfrcurr" : "0","Periodbeforebasedate" : "0","Periodafterbasedate" : "0","Ofstfrmrfrncdtfrcurr" : "0","Offsetfromreferencedate" : "1","Nonposteddaysruleexit" : "901","IDusdtoidntifygravityscales" : "","IdnForForm" : "FRMLA","Grsornetprcstrtgyusedfrsurcharge" : "","Grsornetprcstrtgyusedfrquot" : "","Formulatermvalue" : "0","Formulatermtype1" : "1","Formulatermtype" : "1","Formulatermitemnumber" : "1","Formulaprovisionalfinalindicator" : "1","Formulaprovisionalfinalind" : "1","FctrycalendarIDforcurrency" : "","ExcludeBaseDate" : "","ExcldeBaseDtfrCurr" : "","Exchangeratetype" : "TR01","Errhandlgexitifnoquotationfound" : "901","Errhandlexitifnoexchratfnd" : "0","Enddatefrcurrprd" : "0","Dttofrfixationprd" : "0","Dttofrfixationperiodorcurr" : "0","Dttodeterminedfrfixationprd" : "0","Dtfrmfrfixationprdfrcurr1" : "0","Dtfrmfrfixationprdfrcurr" : "0","Dtfrmdeterminedfrfixatioperiod" : "0","Determinatnexitfrcurrrferencdt" : "0","Daysforsimpleaverage" : "","Datefromforavgperiod" : "0","Dailycurrrule" : "1","Currweekendruleexit" : "0","Currtimeunitofmsrexit" : "0","Currnonposteddaysruleexit" : "0","Currfrfrmulatrm" : "","Caltpefrfrmulconditem" : "1","Calfactor2" : "1","Calfactor1" : "1","Calexitfrtermitem" : "1","AvgCurrrule" : "0"} ],"Overrideofformulacaluculation" : "","NumeratorforconvertingtoformulaconditionUoM" : "0","MaterialDesc" : "","IndicatorifFAcalculationisperformedratebased" : "X","IdnForForm" : "FRMLA","Formulaevaluationstatus" : "0","Formulaconditionvalue" : "0","Formtermselexit" : "901","Fordescr" : "TR IZT AGO","EndDate" : "20210210","DisedprcingunitfrFrmlandAvgconds" : "1000","DisdunitofmsrforFrmlanAvgcon" : "L15","DenominatorforconvertingtoformulaconditionUoM" : "0","Currfordisofcalformula" : "TRY","Currencyforformulacondition" : "","CondUsageTable" : "A","CondType" : "YP04","Condtableno" : "604","condRecordnumber" : "","Calculationtype" : "Q","Application" : "V"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
	static testmethod void getMRCRecordsData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
		Rev_Formula_Price_Staging_Table__c formulaPricing = new Rev_Formula_Price_Staging_Table__c();
        formulaPricing.Sequence_No__c = '1';
        formulaPricing.Condition_Table_Usage__c = 'A';
        formulaPricing.CONDITION_TABLE_ID__c = '604';
        formulaPricing.Application__c = 'V';
        formulaPricing.Cond_Type__c = 'YP04';
        formulaPricing.Key_Value__c = 'TR0402020011798530T314000000000400003981';
        formulaPricing.Start_Date__c = '20210210';
        formulaPricing.End_Date__c = '20210210';
        formulaPricing.Scale_Type__c = 'A';
        formulaPricing.Calculation_Type__c = 'Q';
        formulaPricing.Value__c = '0';
        formulaPricing.Rate_Unit__c = '';
        formulaPricing.Base_UOM_Code__c = 'L15';
        formulaPricing.Quantity__c = '0';
        formulaPricing.Material_Description__c = '';
        formulaPricing.Formula_term_selection_exit__c = '901';
        formulaPricing.Formula_description__c = 'TR IZT AGO';
        formulaPricing.Formula_condition_value__c = '0';
        formulaPricing.Currency_for_formula_condition__c = '';
        formulaPricing.Formula_evaluation_status__c = '0';
        formulaPricing.Currency_display_of_calc_formula_rate__c = 'TRY';
        formulaPricing.Display_unit_measure_Formula_Avg_Condt__c = 'L15';
        formulaPricing.Display_pricing_unit_Formula_Avg_Condt__c = '1000';
        formulaPricing.Rule_conversion_displayed_of_Formula_UoM__c = '0';
        formulaPricing.Numeratr_for_convertng_formu_conditn_UoM__c = '0';
        formulaPricing.Denomitr_for_convertng_formu_conditn_UoM__c = '0';
        formulaPricing.Indicator_if_F_A_calc_perform_rate_based__c = 'X';
        formulaPricing.Override_of_formula_calculation__c = '';
        formulaPricing.Formula_term_type__c = '1';
        
        formulaPricing.Formula_provisional_final_indicator__c = '1';
        formulaPricing.User_exit_for_reference_date_determinatn__c = '1';
        formulaPricing.Time_unit_of_measure_exit__c = '1';
        
        formulaPricing.Weekend_rule_exit__c = '900';
        formulaPricing.Non_posted_days_rule_exit__c = '901';
        formulaPricing.Error_handling_exit_if_no_quotatn_found__c = '901';
        
        formulaPricing.Offset_from_reference_date__c = '1';
        formulaPricing.Period_before_base_date__c = '0';
        formulaPricing.Period_after_base_date__c = '0';
        
        formulaPricing.Exclude_Base_Date__c = '';
        formulaPricing.Date_from_for_average_period__c = '0';
        formulaPricing.Date_to_for_fixation_period__c = '0';
        
        formulaPricing.Average_currency_rule__c= '0';
        formulaPricing.Daily_currency_rule__c = '1';
        formulaPricing.Determination_exit_for_currency_ref__c = '0';
        
        formulaPricing.Currency_time_unit_of_measure_exit__c= '0';
        formulaPricing.Currency_weekend_rule_exit__c = '0';
        formulaPricing.Currency_non_posted_days_rule_exit__c = '0';
        
        formulaPricing.Error_handling_exit_no_exch_rate_found__c= '0';
        formulaPricing.Offset_from_reference_date_for_currency__c = '0';
        formulaPricing.Period_before_base_date_for_currency__c = '0';
        
        formulaPricing.Period_after_base_date_for_currency__c= '0';
        formulaPricing.Exclude_Base_Date_for_Currency__c = '';
        formulaPricing.Date_from_fixation_period_for_currency__c = '0';
        
        formulaPricing.Date_to_for_fixation_period_for_currency__c= '0';
        formulaPricing.Formula_term_value__c = '0';
        formulaPricing.Currency_for_formula_term__c = '';
        
        formulaPricing.DateFrom_determined_for_fixatn_period__c= '0';
        formulaPricing.Date_to_determined_for_fixatn_period__c = '0';
        formulaPricing.Date_from_fixation_period_for_currency1__c = '0';
        
        formulaPricing.End_date_for_currency_period__c = '0';
        formulaPricing.Term_status__c = '';
        formulaPricing.Factory_calendar_ID_for_currency__c = '';
        
        formulaPricing.Rule_for_rounding_formula_term_value__c = '0';
        formulaPricing.Rule_for_rounding_currency_exchange_rate__c = '0';
        formulaPricing.Days_for_simple_average__c = '';
        
        
        formulaPricing.Formula_term_type1__c = '1';
        formulaPricing.Formula_term_item_number__c = '1';
        formulaPricing.Formula_provisional_final_indicator1__c = '1';
        
        formulaPricing.Calculation_factor_1__c = '1';
        formulaPricing.Calculation_factor_2__c = '1';
        formulaPricing.Quotation_source__c = 'TR';
        
        formulaPricing.Quotation_type__c = 'P';
        formulaPricing.refinery__c = 'FOB IZMIT GO 10';
        formulaPricing.Calculation_exit_for_term_item__c = '1';
        
        formulaPricing.Exchange_rate_type__c = 'TR01';
        formulaPricing.Surcharge__c = '999';
        formulaPricing.Surcharge_currency__c = 'TRY';
        
        formulaPricing.Surcharge_per_unit__c = '1000';
        formulaPricing.Surcharge_unit_of_measure__c = 'L15';
        formulaPricing.Term_item_value__c = '0';
        
        formulaPricing.Term_item_value_currency__c = '';
        formulaPricing.Quotation_average_value__c = '0';
        formulaPricing.Surcharge_value_for_formula_term_item__c = '0';
        
        formulaPricing.Gross_net_pricing_strategy_used_quotatn__c = '';
        formulaPricing.Gross_net_pricing_strategy_used_surchrge__c = '';
        formulaPricing.Rule_for_rounding_quotatn_price_value__c = '0';
        
        formulaPricing.Rule_for_rounding_surcharge_price_value__c = '0';
        formulaPricing.Rule_for_rounding_term_item_value__c = '0';
        formulaPricing.Calculation_type_formula_condtn_item__c = '1';
        
        formulaPricing.Ref_data_1_for_formula_term_item_calc__c = '0';
        formulaPricing.UoM_ref_data_1_in_formula_term_item_calc__c = '';
        formulaPricing.Quotation_group__c = '';
        formulaPricing.ID_used_to_identify_gravity_scales__c = '';
        
        insert formulaPricing;
        //List<Revolution_Deal_GSAP_Config__mdt> revDeal = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Client_Id__c, Client_Secret__c, Content_Type__c, Endpoint__c, Method__c, Max_Retry__c FROM Revolution_Deal_GSAP_Config__mdt];
        test.startTest();
			
        test.stopTest();
    }
}