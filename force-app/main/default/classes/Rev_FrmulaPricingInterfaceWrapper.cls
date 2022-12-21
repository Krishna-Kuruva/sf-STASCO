public class Rev_FrmulaPricingInterfaceWrapper {
		public String IdnForForm;
        public String Status;
        public String condRecordnumber;
        public String SeqNo;
    
    	public String CondUsageTable;
        public String Condtableno;
        public String Application;
        public String CondType; 
    
    	public String Varkey;
        public String StartDate;
        public String EndDate;
        public String ScaleType; 
    
    	public String Calculationtype;
        public String PriceVal;
        public String RateUnit;
        public String Uom; 
    
    	public String Quantity;
        public String MaterialDesc;
    
    	public String Formtermselexit;
        public String Fordescr;
    	public String Formulaconditionvalue;
        public String Currencyforformulacondition;
    	public String Formulaevaluationstatus;
        public String Currfordisofcalformula;
    
    	public String DisdunitofmsrforFrmlanAvgcon;
    	public String DisedprcingunitfrFrmlandAvgconds;
        public String RuleforconversionofthedisplayedFormulaUoM;
    	public String NumeratorforconvertingtoformulaconditionUoM;
        public String DenominatorforconvertingtoformulaconditionUoM;
    	public String IndicatorifFAcalculationisperformedratebased;
        public String Overrideofformulacaluculation;
    
    	public List<PriceItems> PriceItems;
    	public Rev_FrmulaPricingInterfaceWrapper(){
            PriceItems = new List<PriceItems>();
        }
        public class PriceItems{
             public String IdnForForm;
        	 public String SeqNo;
			 public String Formulatermtype;
        	 public String Formulaprovisionalfinalindicator;    
             public String Usrexitfrrefrncdtdetrminatn;  
             public String Timeunitofmeasureexit;  
            
             public String Weekendruleexit;
        	 public String Nonposteddaysruleexit;
			 public String Errhandlgexitifnoquotationfound;
        	 public String Offsetfromreferencedate;    
             public String Periodbeforebasedate;  
             public String Periodafterbasedate; 
             public String ExcludeBaseDate;  
             public String Datefromforavgperiod; 
            
            public String Dttofrfixationprd;
        	 public String AvgCurrrule;
			 public String Dailycurrrule;
        	 public String Determinatnexitfrcurrrferencdt;    
             public String Currtimeunitofmsrexit;  
             public String Currweekendruleexit; 
             public String Currnonposteddaysruleexit;  
             public String Errhandlexitifnoexchratfnd; 
            
             public String Ofstfrmrfrncdtfrcurr;
        	 public String Periodbfrbsedtfrcurr;
             public String Priodaftrbasedtefrcurr;
        	 public String ExcldeBaseDtfrCurr;    
             public String Dtfrmfrfixationprdfrcurr;  
             public String Dttofrfixationperiodorcurr; 
             public String Formulatermvalue;  
             public String Currfrfrmulatrm; 
            
             public String Dtfrmdeterminedfrfixatioperiod;
        	 public String Dttodeterminedfrfixationprd;
             public String Dtfrmfrfixationprdfrcurr1;
        	 public String Enddatefrcurrprd;    
             public String Termstatus;  
             public String FctrycalendarIDforcurrency; 
             public String Rulefrroundingformulatrmvalue;  
             public String Ruleforroundingcurrencyexchangerate; 
            
             public String Daysforsimpleaverage;
        	 public String Formulatermtype1;
             public String Formulatermitemnumber;
        	 public String Formulaprovisionalfinalind;    
             public String Calfactor1;  
             public String Calfactor2; 
             public String Quotationsource;  
             public String Quotationtype; 
            
             public String Quotationnumber;
        	 public String Calexitfrtermitem;
             public String Exchangeratetype;
        	 public String Surcharge;    
             public String Surchargecurrency;  
             public String Surchargeperunit; 
             public String Surchargeunitofmsr;  
             public String Termitemvalue; 
            
             public String Termitemvaluecurrency;
        	 public String Quotationaveragevalue;
             public String Surchargevalueforformulatermitem;
        	 public String Grsornetprcstrtgyusedfrquot;    
             public String Grsornetprcstrtgyusedfrsurcharge;  
             public String Rulefrroundingqutationprcval; 
             public String Rulefrrndsrchrgprceval;  
             public String Rulefrrndtrmitemval; 
            
             public String Caltpefrfrmulconditem;
        	 public String Rfrncedata1frfrmulatermitemcal;
             public String UoMfrrfrncedata1infrmultrmitemcal;
        	 public String Quotationgroup;    
             public String IDusdtoidntifygravityscales;  
        }
    
    
        public class exceptionClass{
                public String errorMessage;
                public exceptionClass(){
                    errorMessage = '';
                }
        }
        
}