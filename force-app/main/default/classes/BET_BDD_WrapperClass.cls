/******************************************************************************************************************
className           :    BET_BDD_WrapperClass
Description         :    Wrapper class for VIES and ORBIS JSON.
*******************************************************************************************************************/

public class BET_BDD_WrapperClass {
    
/****************************************************************************************************************
Method Name:  responseParametersPdfFiles
Description: Wrapper class for VIES and Sovos
****************************************************************************************************************/ 
    public class responseParametersPdfFiles{
        @AuraEnabled
        public string resultPayload {get;set;}
        @AuraEnabled
        public string responseMessage {get;set;}
        @AuraEnabled
        public String isSuccess {get;set;}
        @AuraEnabled
        public Integer responseCode {get;set;} 
        @AuraEnabled
        public String accessToken{get;set;}
    } 
    
/****************************************************************************************************************
Method Name:  responseParametersORBIS
Description: Wrapper class for ORBIS 
****************************************************************************************************************/ 
    public class responseParametersORBIS{
        @AuraEnabled
        public ResultPayload resultPayload {get;set;} 
        @AuraEnabled
        public String responseMessage {get;set;} 
        @AuraEnabled
        public Boolean isSuccess {get;set;} 
        @AuraEnabled
        public Integer responseCode {get;set;} 
        @AuraEnabled
        public String accessToken{get;set;}   
    }
    
    public class ResultPayload {
        @AuraEnabled
        public SearchSummary searchSummary {get;set;} 
        @AuraEnabled
        public List<Data> data {get;set;} 
        
    }
    
    public class SearchSummary {
        @AuraEnabled
        public Integer totalRecordsFound {get;set;} 
        @AuraEnabled
        public Integer offset {get;set;} 
        @AuraEnabled
        public Integer recordsReturned {get;set;} 
        @AuraEnabled
        public DatabaseInfo databaseInfo {get;set;} 
        @AuraEnabled
        public sortBy sortBy {get;set;} 
        
    }
    
    public class DatabaseInfo {
        @AuraEnabled
        public String releaseNumber {get;set;} 
        @AuraEnabled
        public String updateNumber {get;set;} 
        @AuraEnabled
        public String updateDate {get;set;} 
        @AuraEnabled
        public String versionNumber {get;set;} 
        
    }
    
    public class sortBy {
        public String descOrder  {get;set;}        
    }
    
    
    public class Data {
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String namE_INTERNATIONAL {get;set;} 
        @AuraEnabled
        public String bvdid {get;set;} 
        @AuraEnabled
        public List<String> status {get;set;} 
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
        public List<String> nationaL_ID {get;set;} 
        @AuraEnabled
        public String nationaL_ID_LABEL {get;set;} 
        @AuraEnabled
        public List<String> address_Line1_Additional {get;set;}
        @AuraEnabled
        public List<String> address_Line2_Additional {get;set;}
        @AuraEnabled
        public List<String> address_Line3_Additional {get;set;}
        @AuraEnabled
        public List<String> address_Line4_Additional {get;set;}
        @AuraEnabled
        public List<String> postcodE_ADDITIONAL {get;set;} 
        @AuraEnabled
        public List<String> citY_ADDITIONAL {get;set;}
        @AuraEnabled
        public List<String> COUNTRY_ADDITIONAL {get;set;}
        @AuraEnabled
        public String addresS_LINE1 {get;set;} 
        @AuraEnabled
        public String addresS_LINE2 {get;set;} 
        @AuraEnabled
        public String addresS_LINE3 {get;set;}
        @AuraEnabled
        public String postcode {get;set;} 
        @AuraEnabled
        public String city {get;set;} 
        @AuraEnabled
        public String country {get;set;} 
        @AuraEnabled
        public String worlD_REGION {get;set;} 
        @AuraEnabled
        public String industrY_CLASSIFICATION {get;set;} 
        @AuraEnabled
        public String productS_SERVICES {get;set;}
        @AuraEnabled
        public List<String> previouS_NAME {get;set;} 
        @AuraEnabled
        public String europeaN_VAT_NUMBER {get;set;} 
        @AuraEnabled
        public Double opre {get;set;} 
        @AuraEnabled
        public String cf {get;set;}
        @AuraEnabled
        public Double toas {get;set;} 
        @AuraEnabled
        public Double shfd {get;set;}
        @AuraEnabled
        public Double prma {get;set;} 
        @AuraEnabled
        public String empl {get;set;}
        @AuraEnabled
        public String uS_STATE {get;set;} 
        @AuraEnabled
        public List<String> tradE_REGISTER_NUMBER {get;set;} 
        @AuraEnabled
        public List<String> akA_NAME {get;set;} 
        @AuraEnabled
        public String bO_STATUS {get;set;} 
        @AuraEnabled
        public List<String> bO_NAME {get;set;} 
        @AuraEnabled
        public List<String> bO_ENTITY_TYPE {get;set;} 
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

/****************************************************************************************************************
Method Name:  OAuth2AccessToken
Description: Wrapper class for SFDC Access token 
****************************************************************************************************************/ 

    public class OAuth2AccessToken {
        public String id{get;set;}
        public String issued_at{get;set;}
        public String instance_url{get;set;}
        public String signature{get;set;}
        public String access_token{get;set;}
        public String user_id{get;set;}  
        public Integer status_code{get;set;} 
        public String error{get;set;}
        public String error_description{get;set;}
    }

    /*Class Name   : EdpResponseWrapper
     *Date         : 09-Sep-20
     *Developer    : Rahul Sharma
     *Description  : Wrapper class for EDP Response.
     */
    public class EdpResponseWrapper{
        public String[] resultPayload;
        public String responseMessage;
        public Boolean isSuccess;
        public Integer responseCode; 
    }

    /*Class Name   : EdpEndpointVsDocumentWrapper
     *Date         : 09-Sep-20
     *Developer    : Rahul Sharma
     *Description  : Wrapper class for EDP document automatic upload.
     */
    public class EdpEndpointVsDocumentWrapper{
        public String accessToken;
        public String userId;
        public String endPointURL;
        public BET_BDD_Document__c bddDoc;
    }
}