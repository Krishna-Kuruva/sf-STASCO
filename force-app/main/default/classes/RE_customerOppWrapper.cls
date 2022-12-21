/*************************************************************************************
    @Name:  RE_customerOppWrapper     
    @=================================================================================
    @Purpose: wrapper class contain both Reseller and Direct Customer Opp's data which is used
				to display data in LWC(RE_customerOppWrapper).
    @=================================================================================
    @History                                                            
    @---------                                                            
    @VERSION AUTHOR                            DATE                                                 
    @2.0 - Vijaykumar S     ```````````````    15-Feb-2021             
*************************************************************************************/
public class RE_customerOppWrapper {     
    public class getuserdata{
        @AuraEnabled
        public Boolean isApprover{get;set;}
        @AuraEnabled
        public List<picklistdata> userList{get;set;}
    }
    
    public class getcustomerOppdata{ 
        @AuraEnabled
        public resellerlist reseller {get;set;} 
        @AuraEnabled
        public directlist direct {get;set;}
        @AuraEnabled
        public Boolean isApprover{get;set;}
        @AuraEnabled 
        public String status{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public date midpublishDate{get;set;}
        @AuraEnabled
        public date cubpublishDate{get;set;}
        @AuraEnabled
        public String checkNewContract{get;set;}
        @AuraEnabled
        public boolean controlFunction{get;set;}
    }
    
    public class returnResult{
        @AuraEnabled 
        public String status{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String resultdata{get;set;}
        
    }
    
    public class resellerlist{
        
        //PBI 1420266 start
        @AuraEnabled public Set<String> customerList {get;set;}
        @AuraEnabled public Set<String> locationList {get;set;}
        @AuraEnabled public Set<String> MaterialList {get;set;}
        @AuraEnabled public Set<String> AMCodeList {get;set;}
        //PBI 1420266 end
        @AuraEnabled
        public List<picklistdata> plant {get;set;}
        @AuraEnabled
        public List<picklistdata> Material {get;set;}
        @AuraEnabled
        public List<picklistdata> customerName {get;set;}
        @AuraEnabled
        public List<picklistdata> soldTo {get;set;}
        @AuraEnabled
        public List<picklistdata> amCode {get;set;}
        @AuraEnabled
        public list<pricebookdata> resellerdata {get;set;}       
        @AuraEnabled
        public list<picklistdata> CalMod {get;set;}  
        @AuraEnabled
        public list<picklistdata> status {get;set;} 
    }
    
    public class directlist{
        //PBI 1420266 start
        @AuraEnabled public Set<String> customerList {get;set;}
        @AuraEnabled public Set<String> locationList {get;set;}
        @AuraEnabled public Set<String> MaterialList {get;set;}
        @AuraEnabled public Set<String> AMCodeList {get;set;}
        
        //PBI 1420266 ends
        
        @AuraEnabled 
        public list<picklistdata> plant {get;set;}
        @AuraEnabled
        public list<picklistdata> Material {get;set;}
        @AuraEnabled
        public List<picklistdata> customerName {get;set;}
        @AuraEnabled
        public List<picklistdata> soldTo {get;set;}
        @AuraEnabled
        public List<picklistdata> amCode {get;set;}
        @AuraEnabled
        public list<pricebookdata> directdata {get;set;}  
        @AuraEnabled
        public list<picklistdata> CalMod {get;set;}  
    }
    
    public class picklistdata{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string value { get;set;}
    }
    
    public class pricebookdata{
        @AuraEnabled
        public string id{get;set;}
        @AuraEnabled
        public string customerName{get;set;}
        @AuraEnabled
        public string customerNameId{get;set;}
        @AuraEnabled
        public string customerNameSoldTo{get;set;}
        @AuraEnabled
        public string customerSoldToID{get;set;}
        @AuraEnabled
        public string product{get;set;}
        @AuraEnabled
        public string productCode{get;set;}
        @AuraEnabled
        public string Location{get;set;}
        @AuraEnabled
        public string amCode{get;set;}
        @AuraEnabled
        public string salesOrg{get;set;}
        @AuraEnabled
        public string transportCharge{get;set;}
        @AuraEnabled
        public string serviceSurChg{get;set;}
        @AuraEnabled
        public string tptMode{get;set;}
        @AuraEnabled
        public string units{get;set;}
        @AuraEnabled
        public string listPrice{get;set;} 
        @AuraEnabled
        public string tieredDiscount{get;set;}
        @AuraEnabled
        public String finalPrice{get;set;}
        @AuraEnabled
        public String finalPriceOld{get;set;}
        @AuraEnabled
        public String discount{get;set;}
        @AuraEnabled
        public String tempDiscount{get;set;}        
        @AuraEnabled
        public String soldTo{get;set;}
        @AuraEnabled
        public String shipTo{get;set;}
        @AuraEnabled
        public String shipToAddress{get;set;}
        @AuraEnabled
        public string midDayPrice{get;set;}
        @AuraEnabled
        public string fcMarginInd{get;set;}
        @AuraEnabled
        public string cbuMC{get;set;}
        @AuraEnabled
        public string MarginaboveCBUMC{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date startDateOld{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public Date endDateOld{get;set;}
        @AuraEnabled
        public string approvedBy{get;set;}
        @AuraEnabled
        public string approveStatus{get;set;}
        @AuraEnabled
        public string approveStatusFull{get;set;}
        @Auraenabled
        public Boolean isChecked{get; set;}
        @Auraenabled
        public boolean checkBoxController{get;set;}
        @Auraenabled
        public string contractID{get; set;}
        @Auraenabled
        public string customerID{get; set;} 
        @Auraenabled
        public boolean recordMode{get; set;} 
        @Auraenabled
        public boolean trackDateEdit{get; set;}
        @Auraenabled
        public string fields{get; set;} 
        @Auraenabled
        public string pricingLevel{get;set;} 
        @Auraenabled
        public string pricingLevelOld{get;set;} 
        @Auraenabled
        public string submittedBy{get;set;}  
        @Auraenabled
        public string marginAboveLDC{get; set;} 
        @Auraenabled
        public string  marginAboveMC{get; set;} 
        @Auraenabled 
        public string  RE_CBU_LDC{get; set;} 
        @Auraenabled 
        public string  RE_Afternoon_Indication{get; set;}
        @Auraenabled
        public string forecastMarginAboveLDC {get;set;} 
        @Auraenabled
        public string forecastMarginAboveMC {get;set;}  
        @Auraenabled
        public string dfoaCharges {get;set;} 
        @Auraenabled
        public string rebate {get;set;} 
        @Auraenabled
        public string bdf {get;set;} 
        @Auraenabled
        public string calculationLogic {get;set;}
        @Auraenabled
        public Boolean inlineEdit {get;set;}
        @Auraenabled
        public Boolean finalPriceEdit {get;set;}
        @Auraenabled
        public Boolean priceLevelEdit {get;set;}
        @Auraenabled
        public Boolean validDateEdited {get;set;}
        @Auraenabled
        public string approverComments {get;set;}
        @Auraenabled
        public string submitterComments {get;set;}
        @Auraenabled
        public string submitterCommentsOld {get;set;}
        @Auraenabled
        public string lastModifiedBy {get;set;}
        @Auraenabled
        public string yesterdayFinalPrice {get;set;}
        @Auraenabled
        public string avatarCssClass {get;set;}  
        @Auraenabled
        public Date directValidFrom {get;set;} 
        @Auraenabled
        public Date directValidTo {get;set;} 
        @Auraenabled
        public String listPriceTier {get;set;} 
        @Auraenabled
        public String cbuMCforFinalPrice {get;set;}
        @Auraenabled
        public String cbuLDCforFinalPrice {get;set;}
        @Auraenabled
        public String locationCode{get;set;}
        @Auraenabled
        public String autocalcrefamnt{get;set;}
        @Auraenabled
        public String autocalcrefamntadj{get;set;}
        @Auraenabled
        public String calcmethod{get;set;}
        @Auraenabled
        public String refperiod{get;set;}
        @Auraenabled
        public String refperiodOld{get;set;}
        @Auraenabled
        public String refprice{get;set;}
        @Auraenabled
        public String refuc3{get;set;}
        @Auraenabled
        public String tpM_1 {get;set;}
        @Auraenabled
        public String tpMTD {get;set;}
        @Auraenabled
        public String tpWTD {get;set;}
        @Auraenabled
        public String tpD_1 {get;set;}
        @Auraenabled
        public String tpW_1 {get;set;}
        @Auraenabled
        public String exgM_1 {get;set;}
        @Auraenabled
        public String exgMTD {get;set;}
        @Auraenabled
        public String exgWTD {get;set;}
        @Auraenabled
        public String exgD_1 {get;set;}
        @Auraenabled
        public String exgW_1 {get;set;}
        @Auraenabled
        public String uc3M_1 {get;set;}
        @Auraenabled
        public String uc3MTD {get;set;}
        @Auraenabled
        public String uc3WTD {get;set;}
        @Auraenabled
        public String uc3D_1 {get;set;}
        @Auraenabled
        public String uc3W_1 {get;set;}
        @Auraenabled
        public String backStopMargin {get;set;}
        @Auraenabled
        public String approvalScheme {get;set;}
        @Auraenabled
        public String d_1vsD_2 {get;set;}
        @Auraenabled
        public String d_1vsWTD {get;set;}
        @Auraenabled
        public String d_1vsW_1 {get;set;}
        @Auraenabled
        public String d_1vsMTD {get;set;}
        @Auraenabled
        public String d_1vsM_1 {get;set;}
        @Auraenabled
        public String wtdvsW_1 {get;set;}
        @Auraenabled
        public String w_1vsW_2 {get;set;}
        @Auraenabled
        public String mtdvsM_1{get;set;}
        @Auraenabled
        public String exciseTax{get;set;}
        @Auraenabled
        public String approverRole{get;set;}
        @Auraenabled
        public String approverName{get;set;}
        @Auraenabled
        public String amprice{get;set;}
        @Auraenabled
        public String priceSupport{get;set;}
        @AuraEnabled
        public Date psStartDate{get;set;}
        @AuraEnabled
        public Date psEndDate{get;set;}
        @Auraenabled
        public String priceSupportOld{get;set;}
        @AuraEnabled
        public Date psStartDateOld{get;set;}
        @AuraEnabled
        public Date psEndDateOld{get;set;}
    }
    
  
    public class ProductListprice{
        @Auraenabled
        public String product {get;set;}
         @Auraenabled
        public String material {get;set;}
        @Auraenabled
        public String productId {get;set;}
        @Auraenabled
        public String SalesOrg {get;set;}
        @Auraenabled
        public String Id {get;set;}
        @Auraenabled
        public date validFrom {get;set;}
        @Auraenabled
        public date validTo {get;set;}
        @Auraenabled
        public String listPrice {get;set;}
        @Auraenabled
        public String salesOrgProduct {get;set;}        
        
    }
}