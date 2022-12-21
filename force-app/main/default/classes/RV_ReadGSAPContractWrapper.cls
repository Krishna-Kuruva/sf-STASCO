public class RV_ReadGSAPContractWrapper {
	 public String SapSalesContNo;
        public String shtHeader;
        public String contStartDate;
        public String contEndDate;

        public String CreationDateSap;
        public String CreationTimeSap;
    	public String changeDateSAP;
        public String soldTo;
        public String POType;
    	public List<SHTItems> SHTItems;
        public class SHTItems{
            public String SfItemShtNo;
            public String MaterialNo;
            public String Quantity;
            public String QuantityUOM;
            public String OpenQuantity;
            public String RejectionReason;
            public String CondType;
            public String SalesPrice;
            public String CurrencyKey;
            public String CondPUnt;
            public String CondUnit;
            public String PriceInd;
            public String PriceVar;
            public String TasLoadId;
            public String Tas3rdPtyDel;
        }
}