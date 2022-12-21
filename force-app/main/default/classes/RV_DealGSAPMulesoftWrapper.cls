/*****************************************************************************
@Name:  RV_DealGSAPMulesoftWrapper     
@=========================================================================
@Purpose: Wrapper class used to serailze and deserialize JSON object for deal interface                                                                                  
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Dhriti Krishna Ghosh Moulick      13/01/2021         INITIAL DEVELOPMENT

******************************************************************************/
public class RV_DealGSAPMulesoftWrapper {
    
			public String SfHeaderShtNo;
            public String SapSalesContNo;
            public String Status;
            public String SapMrcNo;
            public String TotalItems;
            public String Action;
            public String ContStartDate;
            public String ContEndDate;
            public String MsgTxt;
            public String SalesOrg;
            public String POType;
    		public String InstanceURL;
            public List<RV_SHTItems> SHTItems;
    
            public RV_DealGSAPMulesoftWrapper(){
                SfHeaderShtNo = '';
                SapSalesContNo = '';
                Status = '';
                SapMrcNo = '';
                TotalItems = '';
                Action = '';
                ContStartDate = '';
                ContEndDate = '';
                MsgTxt = '';
                SalesOrg = '';
                POType = '';
                instanceURL = '';
                SHTItems = new List<RV_SHTItems>();
            }

            public class RV_SHTItems{
                public String SfHeaderShtNo;
                public String SfItemShtNo;
                public String SapMrcItemNo;
                public String ItemCount;
                public String CondPUnt;
                public String CondType;
                public String CondUnit;
                public String CurrencyKey;
                public String DealCreationDate;
                public String DealCreationTime;
                public String MaterialNo;
                public String QuantityUom;
                public String Quantity;
                public String RejectionReason;
                public String SalesPrice;
                public String PriceInd;
            }
            public class exceptionClass{
                public String errorMessage;
                public exceptionClass(){
                    errorMessage = '';
                }
            }
       
}