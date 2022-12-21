public class BET_BDD_GTMI_WrapperClass {
    @AuraEnabled
	public List<ResultPayload> resultPayload {get; set;}
    @AuraEnabled
	public String responseMessage {get; set;}
    @AuraEnabled
	public Boolean isSuccess {get; set;}
    @AuraEnabled
	public Integer responseCode {get; set;}
    @AuraEnabled
    public String accessToken {get; set;}

	public class ResultPayload {
        @AuraEnabled
		public Integer goldtieR_ID {get; set;}
        @AuraEnabled
		public String legaL_NAME {get; set;}
        @AuraEnabled
		public String shorT_NAME {get; set;}
        @AuraEnabled
		public String dD_LEVEL {get; set;}
        @AuraEnabled
		public String cusT_DD_LEVEL_KEY {get; set;}
        @AuraEnabled
		public String policY_STS {get; set;}
        @AuraEnabled
		public String policY_STS_DT {get; set;}
        @AuraEnabled
		public String legaL_CNTRY {get; set;}
        @AuraEnabled
		public String dD_LEVEL_APPRD {get; set;}
        @AuraEnabled
		public String entitY_TYP {get; set;}
        @AuraEnabled
		public String dndB_LIST {get; set;}
        @AuraEnabled
		public String reC_ACTIVE_FLAG {get; set;}
        @AuraEnabled
		public String shiP_ID_NO_IMO {get; set;}
        @AuraEnabled
		public String apprD_WITH_CONDITIONS_FLAG {get; set;}
        @AuraEnabled
		public String rejecteD_WITH_CONDITIONS_FLAG {get; set;}
        @AuraEnabled
        public String REG_ID {get; set;}
        @AuraEnabled
        public String REG_ID_TYP {get; set;}
	}
}