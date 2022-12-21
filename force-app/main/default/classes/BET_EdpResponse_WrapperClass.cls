public class BET_EdpResponse_WrapperClass {
    @AuraEnabled
    public BET_BDD_WrapperClass.ResultPayload orbisResultPayload {get;set;}
    @AuraEnabled
    public BET_BDD_BankersWrapper.ResultPayload bankersResultPayload {get;set;} 
    @AuraEnabled
    public String responseMessage {get;set;} 
    @AuraEnabled
    public Boolean isSuccess {get;set;} 
    @AuraEnabled
    public Integer responseCode {get;set;} 
    @AuraEnabled
    public Integer availableRecordCount{get;set;}
    @AuraEnabled
    public Integer totalRecordCount{get;set;}
    @AuraEnabled
    public String accessToken{get;set;}
    @AuraEnabled
    public String dataSource{get;set;}
    @AuraEnabled
    public String sourceType{get;set;}
    @AuraEnabled
    public String AddEdpSourceAvailable{get;set;}
    @AuraEnabled
    public List<OrbisResult> OrbisResult{get; set;} 
    @AuraEnabled
    public List<BankersResult> bankersResult{get; set;} 
    
    public class OrbisResult{
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public string namE_INTERNATIONAL {get;set;}
        @AuraEnabled
        public String bvdid {get;set;} 
        @AuraEnabled
        public String lei {get;set;}
        @AuraEnabled
        public List<String> giin {get;set;} 
        @AuraEnabled
        public String tin {get;set;}
        @AuraEnabled
        public List<String> vaT_NUMBER {get;set;}
        @AuraEnabled
        public String entitY_TYPE {get;set;}
        @AuraEnabled
        public List<String> companY_ID_NUMBER {get;set;}
        @AuraEnabled
        public String addresS_LINE1 {get;set;} 
        @AuraEnabled
        public String addresS_LINE2 {get;set;} 
        @AuraEnabled
        public String addresS_LINE3 {get;set;}
        @AuraEnabled
        public String city {get;set;} 
		@AuraEnabled
        public String uS_STATE {get;set;} 
        @AuraEnabled
        public String country {get;set;} 
      	@AuraEnabled
        public String postcode {get;set;}
        @AuraEnabled
        public String productS_SERVICES {get;set;}
        @AuraEnabled
        public String europeaN_VAT_NUMBER {get;set;} 
        @AuraEnabled
        public String akA_NAME {get;set;}   
        @AuraEnabled
        public String companY_ID_NUMBER_Str {get;set;}
        @AuraEnabled
        public List<String> tradE_REGISTER_NUMBER {get;set;}
        @AuraEnabled
        public String tradE_REGISTER_NUMBER_Str {get;set;} 
        @AuraEnabled
        public String vaT_NUMBER_Str{get;set;}
        @AuraEnabled
        public String akA_NAME_Str {get;set;}
        @AuraEnabled
        public String previouS_NAME_Str {get;set;}
        @AuraEnabled
        public String address_Line1_Additional {get;set;}
        @AuraEnabled
        public String address_Line2_Additional {get;set;}
        @AuraEnabled
        public String address_Line3_Additional {get;set;}
        @AuraEnabled
        public String address_Line4_Additional {get;set;}
        @AuraEnabled
        public String citY_ADDITIONAL {get;set;}
        @AuraEnabled
        public String postcodE_ADDITIONAL {get;set;}
        @AuraEnabled
        public String COUNTRY_ADDITIONAL {get;set;}
        @AuraEnabled
        public String naicS2017_CORE_CODE {get;set;}
        @AuraEnabled
        public string NAICS2017_CORE_LABEL{get;set;} 
        @AuraEnabled
        public string incorporatioN_STATE{get;set;}
        @AuraEnabled
        public String worldcompliancE_MATCH_SANCTION_INDICATOR {get;set;}
        @AuraEnabled
        public String worldcompliancE_MATCH_CURRENT_PEP_INDICATOR {get;set;} 
        @AuraEnabled
        public string worldcompliancE_MATCH_ADVERSE_MEDIA_INDICATOR{get;set;}
        @AuraEnabled
        public String WORLDCOMPLIANCE_MATCH_ENFORCEMENT_INDICATOR {get;set;} 
        @AuraEnabled
        public String WORLDCOMPLIANCE_MATCH_SOE_INDICATOR {get;set;} 
        @AuraEnabled
        public String WORLDCOMPLIANCE_MATCH_GOVERNMENT_LINKED_INDICATOR {get;set;} 
        @AuraEnabled
        public String WORLDCOMPLIANCE_MATCH_ASSOCIATED_ENTITY_INDICATOR {get;set;} 
        @AuraEnabled
        public String WORLDCOMPLIANCE_MATCH_REGISTRATIONS_INDICATOR {get;set;} 
    }
    
    public class BankersResult{
        //Legal entity
        @AuraEnabled 
        public string bankersAlmanacId{get;set;}
        @AuraEnabled 
        public string linkToFullDetails{get;set;}
        @AuraEnabled
        public String status {get;set;} 
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String lei {get;set;} 
        @AuraEnabled
        public Integer noOfDomesticOffices {get;set;} 
        @AuraEnabled
        public Integer noOfForeignOffices {get;set;} 
        //Office
        @AuraEnabled
        public String officeId {get;set;} 
        @AuraEnabled
        public list<String> giin {get;set;} 
        //Name
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public string previousName {get;set;} 
        @AuraEnabled
        public string tradingName {get;set;} 
        //Location
        @AuraEnabled
        public String area {get;set;} 
        @AuraEnabled
        public String city {get;set;} 
        @AuraEnabled
        public String country {get;set;} 
        @AuraEnabled
        public String postalCode {get;set;}
        @AuraEnabled
        public String subArea {get;set;} 
        //street address
        @AuraEnabled
        public String addressLine1 {get;set;} 
        @AuraEnabled
        public String addressLine2 {get;set;} 
        @AuraEnabled
        public String addressLine3 {get;set;} 
        @AuraEnabled
        public String addressLine4 {get;set;}
    }
}