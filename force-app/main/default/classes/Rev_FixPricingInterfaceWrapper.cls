public class Rev_FixPricingInterfaceWrapper { 
		public String IdnForFix;
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
        public String Change; 
    
    	public List<ScaleValues> ScaleValues;
        public Rev_FixPricingInterfaceWrapper(){
            ScaleValues = new List<ScaleValues>();
        }
        public class ScaleValues{
            public String SeqNo;
            public String IdnForFix ;
            public String ScaleAmount;
            public String ScaleQuantity;
            public String ScaleUOM ;
            public String ScaleDate;
            public String ScaleTime;
        }
    
    	public class exceptionClass{
                public String errorMessage;
                public exceptionClass(){
                    errorMessage = '';
                }
        }
}