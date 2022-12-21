/**
 * Created by Dharmendra.Singh2 on 12/9/2020.
 * Purpose: for MRC interface. 
 */

public class RV_MRCWrapperClass {
    public String MRCNo;
    public String actionInd;
    public String SalesDoctype;
    public String ShipToPOtype;
    public String SalesOrg;
    public String DistributionChannel;
    public String Division;
    public String ValidFrom;
    public String ValidTo;
    public String SoldTo;
    public String SoldToName;
    public String ShipTo;
    public String ShipToName;
    public String ShippingCondition;
    public String Description;
    public String ShipCondDescription;
    public String SoldToDelFlgAllArea;
    public String SoldToDelFlgSaleArea;
    public String SoldToNatiAccPart;
    public String SoldToNatiAccPartName;
    public String SoldToPrimSalesRep;
    public String SoldToPrimSalesRepName;
    public String SoldToSalesGrp;
    public String SoldToSalesGrpDescrp;
    public String ShipToPrimrySalesRepr;
    public String ShipToPrimrySalesReprName;
    public String ShipToSalesGrp;
    public String ShipToSalesGrpDesc;
    public String customerCreditLimit;
    public List<mrcItemClass> MRCItemList;
    public Class mrcItemClass{
        public String MRCItemNo;
        public String MRCNumber;
        public String PlantCode;

        public String PlantName;
        public String MaterialNumber;
        public String MaterialDescription;

        public String HandlingType;
        public String ReasonforRejectionCode;
        public String ReasonforRejectionMessage;
        public String ModeofTransport;
        
        public String ExterMOTDesc;
        public String incoTermsPart1;
        public String incoTermsPart2;
        public String PaymentTerms;
        public String PaymentTermsDescrp;
        public String ValuationType;
        public String CondGroup2;
        public String CondGroup2Desc;
        public String InvoiceDate;
        public String InvoiceDateDesc;
        public String Paymentmethod;
        public String PaymentmethodDesc;
        public String TASDataLoadId;
        public String TASData3rdPartCode;
    }
}