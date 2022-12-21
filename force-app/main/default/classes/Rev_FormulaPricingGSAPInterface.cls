public class Rev_FormulaPricingGSAPInterface {
    
	public static void callGSAPforFrmulaPricing(String access_Token,List<String> gsapstagingStrngList,
                                        Map<String,Revolution_Deal_GSAP_Config__mdt> revDealGSAPMap){
        List<Rev_Formula_Price_Staging_Table__c>  gsapStagingTableLst = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Active__c, Amount__c, Application__c, Average_currency_rule__c, Base_UOM_Code__c, Calculation_exit_for_term_item__c, Calculation_factor_1__c, Calculation_factor_2__c, Calculation_Type__c, Calculation_type_formula_condtn_item__c, Cond_Type__c, Condition_Table_ID__c, Condition_Table_Usage__c, condRecordnumber__c, Currency_display_of_calc_formula_rate__c, Currency_for_formula_condition__c, Currency_for_formula_term__c, Currency_non_posted_days_rule_exit__c, Currency_time_unit_of_measure_exit__c, Currency_weekend_rule_exit__c, Daily_currency_rule__c, Date_from_fixation_period_for_currency__c, Date_from_fixation_period_for_currency1__c, Date_from_for_average_period__c, Date_to_determined_for_fixatn_period__c, Date_to_for_fixation_period__c, Date_to_for_fixation_period_for_currency__c, DateFrom_determined_for_fixatn_period__c, Days_for_simple_average__c, Denomitr_for_convertng_formu_conditn_UoM__c, Determination_exit_for_currency_ref__c, Display_pricing_unit_Formula_Avg_Condt__c, Display_unit_measure_Formula_Avg_Condt__c, End_Date__c, End_date_for_currency_period__c, Error__c, Error_handling_exit_if_no_quotatn_found__c, Error_handling_exit_no_exch_rate_found__c, Exchange_rate_type__c, Exclude_Base_Date__c, Exclude_Base_Date_for_Currency__c, Factory_calendar_ID_for_currency__c, Formula_condition_value__c, Formula_description__c, Formula_evaluation_status__c, Formula_provisional_final_indicator__c, Formula_provisional_final_indicator1__c, Formula_term_item_number__c, Formula_term_selection_exit__c, Formula_term_type__c, Formula_term_type1__c, Formula_term_value__c, Gross_net_pricing_strategy_used_quotatn__c, Gross_net_pricing_strategy_used_surchrge__c, ID_used_to_identify_gravity_scales__c, Indicator_if_F_A_calc_perform_rate_based__c, Key_Value__c, Material_Description__c, Non_posted_days_rule_exit__c, Numeratr_for_convertng_formu_conditn_UoM__c, Offset_from_reference_date__c, Offset_from_reference_date_for_currency__c, Override_of_formula_calculation__c, Period_after_base_date__c, Period_after_base_date_for_currency__c, Period_before_base_date__c, Period_before_base_date_for_currency__c, Quantity__c, Quotation_average_value__c, Quotation_group__c, Quotation_source__c, Quotation_type__c, Rate_Unit__c, Ref_data_1_for_formula_term_item_calc__c, Refinery__c, Rule_conversion_displayed_of_Formula_UoM__c, Rule_for_rounding_currency_exchange_rate__c, Rule_for_rounding_formula_term_value__c, Rule_for_rounding_quotatn_price_value__c, Rule_for_rounding_surcharge_price_value__c, Rule_for_rounding_term_item_value__c, Scale_Type__c, Sequence_No__c, Start_Date__c, Status__c, Surcharge__c, Surcharge_currency__c, Surcharge_per_unit__c, Surcharge_unit_of_measure__c, Surcharge_value_for_formula_term_item__c, Term_item_value__c, Term_item_value_currency__c, Term_status__c, Time_unit_of_measure_exit__c, UoM_ref_data_1_in_formula_term_item_calc__c, User_exit_for_reference_date_determinatn__c, Value__c, Weekend_rule_exit__c FROM Rev_Formula_Price_Staging_Table__c where 
                                                               Id in:gsapstagingStrngList order by Sequence_No__c];
       System.debug('-------------------'+gsapStagingTableLst.size());        
       System.debug('-------------------'+revDealGSAPMap.keyset());                                             
       if(revDealGSAPMap.containskey('CreateFrmulaPrice')){
            Revolution_Deal_GSAP_Config__mdt createDeal = revDealGSAPMap.get('CreateFrmulaPrice'); 
                HttpRequest req = new HttpRequest();
                req.setMethod(createDeal.Method__c);
                req.setEndpoint(createDeal.Endpoint__c);
                req.setHeader('Content-Type',createDeal.Content_Type__c);
                req.setHeader('Authorization', 'Bearer ' +access_Token);
                req.setBody(createJSOnStringDeal(gsapStagingTableLst));
            	req.setTimeout(120000);
                Http binding = new Http();
                HttpResponse res = binding.send(req);
                System.debug('-------------'+res.getBody());
            	System.debug('-------------'+res.getStatusCode());
                if (res.getStatusCode() == 201) {
                    List<Rev_FrmulaPricingInterfaceWrapper> deserializeWrapper =(List<Rev_FrmulaPricingInterfaceWrapper>)JSON.deserialize(res.getBody(), List<Rev_FrmulaPricingInterfaceWrapper>.class);
                    System.debug('-------deserializeWrapper-------'+deserializeWrapper);
                    if(deserializeWrapper.size()>0){
                    	updateGSAPStaging(gsapStagingTableLst,deserializeWrapper);
                    }
                }else{
                    if(res.getStatusCode() == 504){
                        System.debug('-------------'+res.getBody());
                        callGSAPforFrmulaPricing(access_Token,gsapstagingStrngList,revDealGSAPMap);
                    }else{
                        Rev_FrmulaPricingInterfaceWrapper.exceptionClass deserializeWrapperexception =(Rev_FrmulaPricingInterfaceWrapper.exceptionClass)JSON.deserialize(res.getBody(), Rev_FrmulaPricingInterfaceWrapper.exceptionClass.class);
                        System.debug('------deserializeWrapper------'+deserializeWrapperexception);
                        updateerrorMessage(gsapStagingTableLst,deserializeWrapperexception);
                    }
                   // createDealinGSAP(access_Token,fetchsapStagingLst,revDealGSAPMap);
                }
        }
    }
    
    public static String createJSOnStringDeal(List<Rev_Formula_Price_Staging_Table__c> fetchContractMasterLst){
         Map<String,List<Rev_Formula_Price_Staging_Table__c>> frmlaPricingGSPIntrfcMap = new Map<String,List<Rev_Formula_Price_Staging_Table__c>>();
         Map<String,List<Rev_FrmulaPricingInterfaceWrapper>> frmlaPricingIntrfcMap = new Map<String,List<Rev_FrmulaPricingInterfaceWrapper>>();
         for(Rev_Formula_Price_Staging_Table__c contractMaster : fetchContractMasterLst){
             System.debug('-------contractMaster------'+contractMaster);
             
             if(!frmlaPricingGSPIntrfcMap.containsKey(String.valueof(contractMaster.Sequence_No__c))){
                 frmlaPricingGSPIntrfcMap.put(String.valueof(contractMaster.Sequence_No__c),new List<Rev_Formula_Price_Staging_Table__c> {contractMaster});
             }else{
                 List<Rev_Formula_Price_Staging_Table__c> fixprcLst = frmlaPricingGSPIntrfcMap.get(String.valueof(contractMaster.Sequence_No__c));
                 fixprcLst.add(contractMaster);
                 frmlaPricingGSPIntrfcMap.put(String.valueof(contractMaster.Sequence_No__c),fixprcLst);
             }

         }
         List<Rev_FrmulaPricingInterfaceWrapper> frmlaPricingWrapper = new List<Rev_FrmulaPricingInterfaceWrapper>();
          for(String seqNo : frmlaPricingGSPIntrfcMap.keyset()){
              
              if(frmlaPricingGSPIntrfcMap.containskey(seqNo)){
                  
                  List<Rev_Formula_Price_Staging_Table__c> frmlaPrcLst = frmlaPricingGSPIntrfcMap.get(seqNo);
                  List<Rev_FrmulaPricingInterfaceWrapper.PriceItems> PriceItems = new List<Rev_FrmulaPricingInterfaceWrapper.PriceItems>();
                  Rev_Formula_Price_Staging_Table__c frmlaHeader = frmlaPrcLst.get(0);
                  Rev_FrmulaPricingInterfaceWrapper revFrmlaPricing = new Rev_FrmulaPricingInterfaceWrapper();
                     revFrmlaPricing.IdnForForm = 'FRMLA';
                     if(frmlaHeader.Status__c == null)
                        revFrmlaPricing.Status = '';
                     else
                        revFrmlaPricing.Status = '';
                     if(frmlaHeader.condRecordnumber__c == null)
                        revFrmlaPricing.condRecordnumber = '';
                     else
                        revFrmlaPricing.condRecordnumber = frmlaHeader.condRecordnumber__c;
                     
                     if(frmlaHeader.Sequence_No__c == null)
                         revFrmlaPricing.SeqNo = String.valueof(frmlaHeader.Sequence_No__c);
                     else
                         revFrmlaPricing.SeqNo = String.valueof(frmlaHeader.Sequence_No__c);
                     
                     if(frmlaHeader.Condition_Table_Usage__c == null)
                         revFrmlaPricing.CondUsageTable = '';
                     else
                        revFrmlaPricing.CondUsageTable = frmlaHeader.Condition_Table_Usage__c;
                     
                     if(frmlaHeader.Condition_Table_ID__c == null)
                         revFrmlaPricing.Condtableno = '';
                     else
                        revFrmlaPricing.Condtableno = frmlaHeader.Condition_Table_ID__c;
                     
                     if(frmlaHeader.Application__c == null)
                         revFrmlaPricing.Application = '';
                     else
                        revFrmlaPricing.Application = frmlaHeader.Application__c;
                     
                     if(frmlaHeader.Cond_Type__c == null)
                         revFrmlaPricing.CondType = '';
                     else
                        revFrmlaPricing.CondType = frmlaHeader.Cond_Type__c;
                     
                     if(frmlaHeader.Key_Value__c == null)
                         revFrmlaPricing.Varkey = '';
                     else
                        revFrmlaPricing.Varkey = frmlaHeader.Key_Value__c;
                     
                     if(frmlaHeader.Start_Date__c == null)
                         revFrmlaPricing.StartDate = '';
                     else
                        revFrmlaPricing.StartDate = frmlaHeader.Start_Date__c;
                     
                     if(frmlaHeader.End_Date__c == null)
                         revFrmlaPricing.EndDate = '';
                     else
                        revFrmlaPricing.EndDate = frmlaHeader.End_Date__c;
                     
                     if(frmlaHeader.Scale_Type__c == null)
                         revFrmlaPricing.ScaleType = '';
                     else
                        revFrmlaPricing.ScaleType = frmlaHeader.Scale_Type__c;
                     
                     if(frmlaHeader.Calculation_Type__c == null)
                         revFrmlaPricing.Calculationtype = '';
                     else
                        revFrmlaPricing.Calculationtype = frmlaHeader.Calculation_Type__c;
                     
                     if(frmlaHeader.Value__c == null)
                         revFrmlaPricing.PriceVal = '';
                     else
                        revFrmlaPricing.PriceVal = String.valueof(frmlaHeader.Value__c);
                                  
                     //revFrmlaPricing.RateUnit = contractMaster.RV_Rate_Unit__c;
                     if(frmlaHeader.Rate_Unit__c == null)
                        revFrmlaPricing.RateUnit = '';
                     else
                        revFrmlaPricing.RateUnit = frmlaHeader.Rate_Unit__c;
                     
                     if(frmlaHeader.Base_UOM_Code__c == null)
                        revFrmlaPricing.Uom = '';
                     else
                        revFrmlaPricing.Uom = frmlaHeader.Base_UOM_Code__c;
                     
                     if(frmlaHeader.Quantity__c == null)
                        revFrmlaPricing.Quantity = '';
                     else
                        revFrmlaPricing.Quantity = frmlaHeader.Quantity__c;
                     
                     if(frmlaHeader.Material_Description__c	 == null)
                        revFrmlaPricing.MaterialDesc = '';
                     else
                        revFrmlaPricing.MaterialDesc = frmlaHeader.Material_Description__c	;
                     
                     if(frmlaHeader.Formula_term_selection_exit__c == null)
                        revFrmlaPricing.Formtermselexit = '';
                     else
                        revFrmlaPricing.Formtermselexit = frmlaHeader.Formula_term_selection_exit__c;
                     
                     if(frmlaHeader.Formula_description__c == null)
                        revFrmlaPricing.Fordescr = '';
                     else
                        revFrmlaPricing.Fordescr = frmlaHeader.Formula_description__c;
                     
                     if(frmlaHeader.Formula_condition_value__c == null)
                        revFrmlaPricing.Formulaconditionvalue = '';
                     else
                        revFrmlaPricing.Formulaconditionvalue = frmlaHeader.Formula_condition_value__c;
                     
                     if(frmlaHeader.Currency_for_formula_condition__c == null)
                        revFrmlaPricing.Currencyforformulacondition = '';
                     else
                        revFrmlaPricing.Currencyforformulacondition = frmlaHeader.Currency_for_formula_condition__c;
                              
                     //revFrmlaPricing.Currencyforformulacondition = contractMaster.RV_Currency_for_formula_condition__c;
                     if(frmlaHeader.Formula_evaluation_status__c == null)
                        revFrmlaPricing.Formulaevaluationstatus = '';
                     else
                        revFrmlaPricing.Formulaevaluationstatus = frmlaHeader.Formula_evaluation_status__c;
                     
                     if(frmlaHeader.Currency_display_of_calc_formula_rate__c == null)
                        revFrmlaPricing.Currfordisofcalformula = '';
                     else
                        revFrmlaPricing.Currfordisofcalformula = frmlaHeader.Currency_display_of_calc_formula_rate__c;
                     
                     if(frmlaHeader.Display_unit_measure_Formula_Avg_Condt__c == null)
                        revFrmlaPricing.DisdunitofmsrforFrmlanAvgcon = '';
                     else
                        revFrmlaPricing.DisdunitofmsrforFrmlanAvgcon = frmlaHeader.Display_unit_measure_Formula_Avg_Condt__c;
                     
                     if(frmlaHeader.Display_pricing_unit_Formula_Avg_Condt__c == null)
                        revFrmlaPricing.DisedprcingunitfrFrmlandAvgconds = '';
                     else
                        revFrmlaPricing.DisedprcingunitfrFrmlandAvgconds = frmlaHeader.Display_pricing_unit_Formula_Avg_Condt__c;
                     
                     if(frmlaHeader.Rule_conversion_displayed_of_Formula_UoM__c == null)
                        revFrmlaPricing.RuleforconversionofthedisplayedFormulaUoM = '';
                     else
                        revFrmlaPricing.RuleforconversionofthedisplayedFormulaUoM = frmlaHeader.Rule_conversion_displayed_of_Formula_UoM__c;
                     
                     if(frmlaHeader.Numeratr_for_convertng_formu_conditn_UoM__c == null)
                        revFrmlaPricing.NumeratorforconvertingtoformulaconditionUoM = '';
                     else
                        revFrmlaPricing.NumeratorforconvertingtoformulaconditionUoM = frmlaHeader.Numeratr_for_convertng_formu_conditn_UoM__c;
                     
                     if(frmlaHeader.Denomitr_for_convertng_formu_conditn_UoM__c == null)
                        revFrmlaPricing.DenominatorforconvertingtoformulaconditionUoM = '';
                     else
                        revFrmlaPricing.DenominatorforconvertingtoformulaconditionUoM = frmlaHeader.Denomitr_for_convertng_formu_conditn_UoM__c;
                      
                     if(frmlaHeader.Indicator_if_F_A_calc_perform_rate_based__c == null)
                        revFrmlaPricing.IndicatorifFAcalculationisperformedratebased = '';
                     else
                        revFrmlaPricing.IndicatorifFAcalculationisperformedratebased = frmlaHeader.Indicator_if_F_A_calc_perform_rate_based__c;
                      
                     //revFrmlaPricing.Overrideofformulacaluculation = contractMaster.RV_Override_of_formula_calculation__c;
                     if(frmlaHeader.Override_of_formula_calculation__c == null)
                         revFrmlaPricing.Overrideofformulacaluculation = '';
                     else
                         revFrmlaPricing.Overrideofformulacaluculation = frmlaHeader.Override_of_formula_calculation__c;
                     
                  for(Rev_Formula_Price_Staging_Table__c revContractMaster : frmlaPrcLst){
                      
                      Rev_FrmulaPricingInterfaceWrapper.PriceItems scaleValue = new Rev_FrmulaPricingInterfaceWrapper.PriceItems();
             		  scaleValue.SeqNo = String.valueof(revContractMaster.Sequence_No__c);
                      scaleValue.IdnForForm = 'FRMLA';
                      if(revContractMaster.Formula_term_type__c == null)
                      	  scaleValue.Formulatermtype = '';
                      else
                          scaleValue.Formulatermtype = revContractMaster.Formula_term_type__c;

                      if(revContractMaster.Formula_provisional_final_indicator__c == null)
                          scaleValue.Formulaprovisionalfinalindicator = '';
                      else
                      		scaleValue.Formulaprovisionalfinalindicator = revContractMaster.Formula_provisional_final_indicator__c;

                      if(revContractMaster.User_exit_for_reference_date_determinatn__c == null)
                      	scaleValue.Usrexitfrrefrncdtdetrminatn = '';
                      else
                          scaleValue.Usrexitfrrefrncdtdetrminatn = revContractMaster.User_exit_for_reference_date_determinatn__c;
                      
                      if(revContractMaster.Time_unit_of_measure_exit__c == null)
                      	scaleValue.Timeunitofmeasureexit = '';
                      else
                          scaleValue.Timeunitofmeasureexit = revContractMaster.Time_unit_of_measure_exit__c;
                      
                      if(revContractMaster.Weekend_rule_exit__c == null)
                          scaleValue.Weekendruleexit = '';
                      else
                          scaleValue.Weekendruleexit = revContractMaster.Weekend_rule_exit__c;
                      
                      if(revContractMaster.Non_posted_days_rule_exit__c == null)
                          scaleValue.Nonposteddaysruleexit = '';
                      else
                          scaleValue.Nonposteddaysruleexit = revContractMaster.Non_posted_days_rule_exit__c;
                      
                      if(revContractMaster.Error_handling_exit_if_no_quotatn_found__c == null)
                          scaleValue.Errhandlgexitifnoquotationfound = '';
                      else
                          scaleValue.Errhandlgexitifnoquotationfound = revContractMaster.Error_handling_exit_if_no_quotatn_found__c;
                      
                      if(revContractMaster.Offset_from_reference_date__c == null)
                          scaleValue.Offsetfromreferencedate = '';
                      else
                          scaleValue.Offsetfromreferencedate = revContractMaster.Offset_from_reference_date__c;
                      
                      if(revContractMaster.Period_before_base_date__c	 == null)
                          scaleValue.Periodbeforebasedate = '';
                      else
                          scaleValue.Periodbeforebasedate = revContractMaster.Period_before_base_date__c	;
                      
                      if(revContractMaster.Period_after_base_date__c == null)
                          scaleValue.Periodafterbasedate = '';
                      else
                          scaleValue.Periodafterbasedate = revContractMaster.Period_after_base_date__c;
                      
                      if(revContractMaster.Exclude_Base_Date__c == null)
                          scaleValue.ExcludeBaseDate = '';
                      else
                          scaleValue.ExcludeBaseDate = revContractMaster.Exclude_Base_Date__c;
                      
                      if(revContractMaster.Date_from_for_average_period__c == null)
                          scaleValue.Datefromforavgperiod = '';
                      else
                          scaleValue.Datefromforavgperiod = revContractMaster.Date_from_for_average_period__c;
                      
                      if(revContractMaster.Date_to_for_fixation_period_for_currency__c == null)
                          scaleValue.Dttofrfixationprd = '';
                      else
                          scaleValue.Dttofrfixationprd = revContractMaster.Date_to_for_fixation_period_for_currency__c;
                      
                      if(revContractMaster.Average_currency_rule__c == null)
                          scaleValue.AvgCurrrule = '';
                      else
                          scaleValue.AvgCurrrule = revContractMaster.Average_currency_rule__c;
                      
                      if(revContractMaster.Daily_currency_rule__c == null)
                          scaleValue.Dailycurrrule = '';
                      else
                          scaleValue.Dailycurrrule = revContractMaster.Daily_currency_rule__c;
                      
                      if(revContractMaster.Determination_exit_for_currency_ref__c == null)
                          scaleValue.Determinatnexitfrcurrrferencdt = '';
                      else
                          scaleValue.Determinatnexitfrcurrrferencdt = revContractMaster.Determination_exit_for_currency_ref__c;
                      
                      if(revContractMaster.Currency_time_unit_of_measure_exit__c == null)
                          scaleValue.Currtimeunitofmsrexit = '';
                      else
                          scaleValue.Currtimeunitofmsrexit = revContractMaster.Currency_time_unit_of_measure_exit__c;
                      
                      if(revContractMaster.Currency_weekend_rule_exit__c == null)
                          scaleValue.Currweekendruleexit = '';
                      else
                          scaleValue.Currweekendruleexit = revContractMaster.Currency_weekend_rule_exit__c;
                      
                      if(revContractMaster.Currency_non_posted_days_rule_exit__c == null)
                          scaleValue.Currnonposteddaysruleexit = '';
                      else
                          scaleValue.Currnonposteddaysruleexit = revContractMaster.Currency_non_posted_days_rule_exit__c;
                      
                      if(revContractMaster.Error_handling_exit_no_exch_rate_found__c == null)
                          scaleValue.Errhandlexitifnoexchratfnd = '';
                      else
                          scaleValue.Errhandlexitifnoexchratfnd = revContractMaster.Error_handling_exit_no_exch_rate_found__c	;
                      
                      if(revContractMaster.Offset_from_reference_date_for_currency__c == null)
                          scaleValue.Ofstfrmrfrncdtfrcurr = '';
                      else
                          scaleValue.Ofstfrmrfrncdtfrcurr = revContractMaster.Offset_from_reference_date_for_currency__c;
                      
                      if(revContractMaster.Period_before_base_date_for_currency__c == null)
                          scaleValue.Periodbfrbsedtfrcurr = '';
                      else
                          scaleValue.Periodbfrbsedtfrcurr = revContractMaster.Period_before_base_date_for_currency__c;
                      
                      if(revContractMaster.Period_after_base_date_for_currency__c == null)
                          scaleValue.Priodaftrbasedtefrcurr = '';
                      else
                          scaleValue.Priodaftrbasedtefrcurr = revContractMaster.Period_after_base_date_for_currency__c;
                      
                      if(revContractMaster.Exclude_Base_Date_for_Currency__c == null)
                          scaleValue.ExcldeBaseDtfrCurr = '';
                      else
                          scaleValue.ExcldeBaseDtfrCurr = revContractMaster.Exclude_Base_Date_for_Currency__c;
                      
                      if(revContractMaster.Date_from_fixation_period_for_currency__c == null)
                          scaleValue.Dtfrmfrfixationprdfrcurr = '';
                      else
                          scaleValue.Dtfrmfrfixationprdfrcurr = revContractMaster.Date_from_fixation_period_for_currency__c;
                      
                      if(revContractMaster.Date_to_for_fixation_period_for_currency__c == null)
                          scaleValue.Dttofrfixationperiodorcurr = '';
                      else
                          scaleValue.Dttofrfixationperiodorcurr = revContractMaster.Date_to_for_fixation_period_for_currency__c;
                      
                      if(revContractMaster.Formula_term_value__c == null)
                          scaleValue.Formulatermvalue = '';
                      else
                          scaleValue.Formulatermvalue = revContractMaster.Formula_term_value__c;
                      
                      if(revContractMaster.Currency_for_formula_term__c == null)
                          scaleValue.Currfrfrmulatrm = '';
                      else
                          scaleValue.Currfrfrmulatrm = revContractMaster.Currency_for_formula_term__c;
                      
                      if(revContractMaster.DateFrom_determined_for_fixatn_period__c == null)
                          scaleValue.Dtfrmdeterminedfrfixatioperiod = '';
                      else
                          scaleValue.Dtfrmdeterminedfrfixatioperiod = revContractMaster.DateFrom_determined_for_fixatn_period__c;
                      
                      if(revContractMaster.Date_to_determined_for_fixatn_period__c == null)
                          scaleValue.Dttodeterminedfrfixationprd = '';
                      else
                          scaleValue.Dttodeterminedfrfixationprd = revContractMaster.Date_to_determined_for_fixatn_period__c;
                      
                      if(revContractMaster.Date_from_fixation_period_for_currency1__c == null)
                          scaleValue.Dtfrmfrfixationprdfrcurr1 = '';
                      else
                          scaleValue.Dtfrmfrfixationprdfrcurr1 = revContractMaster.Date_from_fixation_period_for_currency1__c;
                      
                      if(revContractMaster.End_date_for_currency_period__c == null)
                          scaleValue.Enddatefrcurrprd = '';
                      else
                          scaleValue.Enddatefrcurrprd = revContractMaster.End_date_for_currency_period__c;
                      
                      if(revContractMaster.Term_status__c == null)
                          scaleValue.Termstatus = '';
                      else
                          scaleValue.Termstatus = revContractMaster.Term_status__c;
                      
                      if(revContractMaster.Factory_calendar_ID_for_currency__c == null)
                          scaleValue.FctrycalendarIDforcurrency = '';
                      else
                          scaleValue.FctrycalendarIDforcurrency = revContractMaster.Factory_calendar_ID_for_currency__c;
                      
                      if(revContractMaster.Rule_for_rounding_formula_term_value__c == null)
                          scaleValue.Rulefrroundingformulatrmvalue = '';
                      else
                          scaleValue.Rulefrroundingformulatrmvalue = revContractMaster.Rule_for_rounding_formula_term_value__c;
                      
                      if(revContractMaster.Rule_for_rounding_currency_exchange_rate__c == null)
                          scaleValue.Ruleforroundingcurrencyexchangerate = '';
                      else
                          scaleValue.Ruleforroundingcurrencyexchangerate = revContractMaster.Rule_for_rounding_currency_exchange_rate__c;
                      
                      
                      if(revContractMaster.Days_for_simple_average__c == null)
                          scaleValue.Daysforsimpleaverage = '';
                      else
                          scaleValue.Daysforsimpleaverage = revContractMaster.Days_for_simple_average__c;
                      
                      if(revContractMaster.Formula_term_type1__c == null)
                          scaleValue.Formulatermtype1 = '';
                      else
                          scaleValue.Formulatermtype1 = revContractMaster.Formula_term_type1__c;
                      
                      if(revContractMaster.Formula_term_item_number__c == null)
                          scaleValue.Formulatermitemnumber = '';
                      else
                          scaleValue.Formulatermitemnumber = revContractMaster.Formula_term_item_number__c;
                      
                      if(revContractMaster.Formula_provisional_final_indicator1__c == null)
                          scaleValue.Formulaprovisionalfinalind = '';
                      else
                          scaleValue.Formulaprovisionalfinalind = revContractMaster.Formula_provisional_final_indicator1__c;
                      
                      if(revContractMaster.Calculation_factor_1__c == null)
                          scaleValue.Calfactor1 = '';
                      else
                          scaleValue.Calfactor1 = String.valueof(revContractMaster.Calculation_factor_1__c);
                      
                      if(revContractMaster.Calculation_factor_2__c == null)
                          scaleValue.Calfactor2 = '';
                      else
                          scaleValue.Calfactor2 = revContractMaster.Calculation_factor_2__c;
                      
                      if(revContractMaster.Quotation_source__c == null)
                          scaleValue.Quotationsource = '';
                      else
                          scaleValue.Quotationsource = revContractMaster.Quotation_source__c;
                      
                      if(revContractMaster.Quotation_type__c == null)
                          scaleValue.Quotationtype = '';
                      else
                          scaleValue.Quotationtype = revContractMaster.Quotation_type__c;
                      
                       if(revContractMaster.Refinery__c == null)
                          scaleValue.Quotationnumber = '';
                      else
                          scaleValue.Quotationnumber = revContractMaster.Refinery__c;
                      
                      
                      if(revContractMaster.Calculation_exit_for_term_item__c == null)
                          scaleValue.Calexitfrtermitem = '';
                      else
                          scaleValue.Calexitfrtermitem = revContractMaster.Calculation_exit_for_term_item__c;
                      
                      if(revContractMaster.Exchange_rate_type__c == null)
                          scaleValue.Exchangeratetype = '';
                      else
                          scaleValue.Exchangeratetype = revContractMaster.Exchange_rate_type__c;
                      
                      if(revContractMaster.Surcharge__c == null)
                          scaleValue.Surcharge = '';
                      else
                          scaleValue.Surcharge = String.valueof(revContractMaster.Surcharge__c);
                      
                      if(revContractMaster.Surcharge_currency__c == null)
                          scaleValue.Surchargecurrency = '';
                      else
                          scaleValue.Surchargecurrency = revContractMaster.Surcharge_currency__c;
                      
                      if(revContractMaster.Surcharge_per_unit__c == null)
                          scaleValue.Surchargeperunit = '';
                      else
                          scaleValue.Surchargeperunit = revContractMaster.Surcharge_per_unit__c;
                      
                      if(revContractMaster.Surcharge_unit_of_measure__c == null)
                          scaleValue.Surchargeunitofmsr = '';
                      else
                          scaleValue.Surchargeunitofmsr = revContractMaster.Surcharge_unit_of_measure__c;
                      
                      if(revContractMaster.Term_item_value__c == null)
                          scaleValue.Termitemvalue = '';
                      else
                          scaleValue.Termitemvalue = revContractMaster.Term_item_value__c;
                      
                      if(revContractMaster.Term_item_value_currency__c == null)
                          scaleValue.Termitemvaluecurrency = '';
                      else
                          scaleValue.Termitemvaluecurrency = revContractMaster.Term_item_value_currency__c;
                      
                      if(revContractMaster.Quotation_average_value__c == null)
                          scaleValue.Quotationaveragevalue = '';
                      else
                          scaleValue.Quotationaveragevalue = revContractMaster.Quotation_average_value__c;
                      
                      if(revContractMaster.Surcharge_value_for_formula_term_item__c == null)
                          scaleValue.Surchargevalueforformulatermitem = '';
                      else
                          scaleValue.Surchargevalueforformulatermitem = revContractMaster.Surcharge_value_for_formula_term_item__c;
                      
                      if(revContractMaster.Gross_net_pricing_strategy_used_quotatn__c == null)
                          scaleValue.Grsornetprcstrtgyusedfrquot = '';
                      else
                          scaleValue.Grsornetprcstrtgyusedfrquot = revContractMaster.Gross_net_pricing_strategy_used_quotatn__c;
                      
                      if(revContractMaster.Gross_net_pricing_strategy_used_surchrge__c == null)
                          scaleValue.Grsornetprcstrtgyusedfrsurcharge = '';
                      else
                          scaleValue.Grsornetprcstrtgyusedfrsurcharge = revContractMaster.Gross_net_pricing_strategy_used_surchrge__c;
                      
                      if(revContractMaster.Rule_for_rounding_quotatn_price_value__c == null)
                          scaleValue.Rulefrroundingqutationprcval = '';
                      else
                          scaleValue.Rulefrroundingqutationprcval = revContractMaster.Rule_for_rounding_quotatn_price_value__c;
                      
                      if(revContractMaster.Rule_for_rounding_surcharge_price_value__c == null)
                          scaleValue.Rulefrrndsrchrgprceval = '';
                      else
                          scaleValue.Rulefrrndsrchrgprceval = revContractMaster.Rule_for_rounding_surcharge_price_value__c;
                      
                      if(revContractMaster.Rule_for_rounding_term_item_value__c == null)
                          scaleValue.Rulefrrndtrmitemval = '';
                      else
                          scaleValue.Rulefrrndtrmitemval = revContractMaster.Rule_for_rounding_term_item_value__c; 
                      
                      if(revContractMaster.Calculation_type_formula_condtn_item__c == null)
                          scaleValue.Caltpefrfrmulconditem = '';
                      else
                          scaleValue.Caltpefrfrmulconditem = revContractMaster.Calculation_type_formula_condtn_item__c; 
                      
                      if(revContractMaster.Ref_data_1_for_formula_term_item_calc__c == null)
                          scaleValue.Rfrncedata1frfrmulatermitemcal = '';
                      else
                          scaleValue.Rfrncedata1frfrmulatermitemcal = revContractMaster.Ref_data_1_for_formula_term_item_calc__c;  
                      
                      if(revContractMaster.UoM_ref_data_1_in_formula_term_item_calc__c == null)
                          scaleValue.UoMfrrfrncedata1infrmultrmitemcal = '';
                      else
                          scaleValue.UoMfrrfrncedata1infrmultrmitemcal = revContractMaster.UoM_ref_data_1_in_formula_term_item_calc__c; 
                      
                      if(revContractMaster.Quotation_group__c == null)
                          scaleValue.Quotationgroup = '';
                      else
                          scaleValue.Quotationgroup = revContractMaster.Quotation_group__c; 
                      
                      if(revContractMaster.ID_used_to_identify_gravity_scales__c == null)
                          scaleValue.IDusdtoidntifygravityscales = '';
                      else
                          scaleValue.IDusdtoidntifygravityscales = revContractMaster.ID_used_to_identify_gravity_scales__c; 
                      
                      PriceItems.add(scaleValue);
                  }
                  revFrmlaPricing.PriceItems.addAll(PriceItems);
                  frmlaPricingWrapper.add(revFrmlaPricing);     
              }
				        
          }
         System.debug('------------------------'+JSON.serializePretty(frmlaPricingWrapper));
        return JSON.serializePretty(frmlaPricingWrapper);
     }
    
	public static void updateGSAPStaging(List<Rev_Formula_Price_Staging_Table__c>  gsapStagingTableLst,
                                        List<Rev_FrmulaPricingInterfaceWrapper> deserializeWrapper){
            Map<String,Rev_FrmulaPricingInterfaceWrapper> frmlaPrcMap = new Map<String,Rev_FrmulaPricingInterfaceWrapper>();
                                            
            if(deserializeWrapper.size()>0){
                for(Rev_FrmulaPricingInterfaceWrapper fixPrc :  deserializeWrapper){
                    frmlaPrcMap.put(fixPrc.SeqNo,fixPrc);
                }                                 
            } 
            
                                            
            List<Rev_Formula_Price_Staging_Table__c> gsapStagingLst = new List<Rev_Formula_Price_Staging_Table__c>();
            for(Rev_Formula_Price_Staging_Table__c sapStaging : gsapStagingTableLst){
                if(frmlaPrcMap.containskey(String.valueof(sapStaging.Sequence_No__c))){
                     sapStaging.Status__c = frmlaPrcMap.get(String.valueof(sapStaging.Sequence_No__c)).Status;
                     sapStaging.condRecordnumber__c = frmlaPrcMap.get(String.valueof(sapStaging.Sequence_No__c)).condRecordnumber;
                    gsapStagingLst.add(sapStaging);
                }
                
                
            }
            if(!gsapStagingLst.isEmpty()){
                try{
                    update gsapStagingLst;
                }catch(Exception de){
                    System.debug('----------de--------'+de);
                }                             
            }                                
    }
    
    public static void updateerrorMessage(List<Rev_Formula_Price_Staging_Table__c>  fetchsapStagingLst,
                                        Rev_FrmulaPricingInterfaceWrapper.exceptionClass deserializeWrapperException){
            List<Rev_Formula_Price_Staging_Table__c> sapStagingLst = new List<Rev_Formula_Price_Staging_Table__c>();
            Map<String,Rev_Formula_Price_Staging_Table__c> shtNumberMap = new Map<String,Rev_Formula_Price_Staging_Table__c>();                                
            for(Rev_Formula_Price_Staging_Table__c sapStaging : fetchsapStagingLst){
                sapStaging.Error__c = deserializeWrapperException.errorMessage;
                sapStagingLst.add(sapStaging);
                //shtNumberMap.put(sapStaging.SfItemShtNo__c,sapStaging);
            }
                                    
           
                                            
            if(!sapStagingLst.isEmpty()){
                try{
                    update sapStagingLst;
                }catch(Exception de){
                    System.debug('----------de--------'+de);
                }                             
            }  

    }    

}