global class OLFWrapper{
    public class customerEmailWrap{
        public String customerEmail='';
        public String tranche='';   //Rahul Sharma | Date - 23-Sep-20 : Added additional parameter to enable deal booking for multiple lifting windows.
    }
    public class MrcPriceWrap{
	    public String MRCNumber = '';
        public String Location = '';
        public String MaterialName = '';
        public String PricePerUnit = '';
        public String inputPricePerUnit = '';
        public String StartDate = '';
        public String EndDate = '';
        public String availableVolume = '';
        public String inputVolume = '';
    	public String contactEmail = '';
        public String sfdcDealNumber = '';
        public String dealMessage = '';
        public String customerName='';
        public String grade='';
        public String LastModifiedTime='';
    }
    
    public class shtAndOlfDealNumberWrap{
        public String sfdcDealNumber = '';
        public String olfDealNumber = '';   
    }
     public class returnMessageWrap{
        public String message='';
    }

    /*Class Name	: olfDealWrap
	 *Developer		: Rahul Sharma
	 *Date			: 26-Mar-2020
	 *Description	: Wrapper class that contains OLF deal number, Load id and GSAP Number
	 */
    public class olfDealWrap{
        //OLF Deal Number
        public String orderId = '';
        //GSAP Contract Number
        public String vendorContractNo = '';
        //Load Id
        public String vendorLiftingId = '';
    }

    /*Class Name	: olfDealGroupWrap
	 *Developer		: Rahul Sharma
	 *Date			: 12-May-2020
	 *Description	: Wrapper class that contains OLF deal number, Load id and GSAP Number
	 */
    public class olfDealGroupWrap{
        //Grouped OLF Deal Number
        public String orderId = '';
        public List<olfDealWrap> items;
    }

    /*Class Name	: olfTrancheWrap
	 *Developer		: Rahul Sharma
	 *Date			: 30-Oct-2020
	 *Description	: Wrapper class that contains OLF connection status and tranche info.
	 */
    public class OlfTrancheWrap{
        public String tranche;
        public Boolean isOlfActive;
        public Integer startDay;
        public Integer endDay;
        //Addition By Sampada.Bhat
        public OlfTrancheWrap(String tranche,Integer startday, Integer endDay){
            this.tranche=tranche;
            this.startDay = startday;
            this.endDay = endDay;
        }
        public OlfTrancheWrap(){
            
        }
    }

    /*Class Name	: ContractDateWindowWrap
	 *Developer		: Rahul Sharma
	 *Date			: 02-Nov-2020
	 *Description	: Wrapper class that contains contract start date and end date.
	 */
    public class ContractDateWindowWrap{
        public Date contractStartDate;
        public Date contractEndDate;
    }
}