public with sharing class BET_BDD_BankersWrapper {
    public class responseParametersBankers{
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
        public Integer totalResults {get;set;}         
        @AuraEnabled
        public Integer displayedResults {get;set;} 
        @AuraEnabled
        public List<Results> results {get;set;} 
    }
    
    public class Results {
        @AuraEnabled
        public LegalEntity legalEntity {get;set;}
        @AuraEnabled 
        public Office office {get;set;} 
    }
    
    public class LegalEntity {
        @AuraEnabled
        public String bankersAlmanacId {get;set;}
        @AuraEnabled 
        public String linkToFullDetails {get;set;}
        @AuraEnabled 
        public List<Names> names {get;set;} 
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
    }
    
    public class Names {
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String value {get;set;} 
    }
    
    public class Office {
        @AuraEnabled
        public String officeId {get;set;} 
        @AuraEnabled
        public List<Names> names {get;set;} 
        @AuraEnabled
        public List<String> types {get;set;} 
        @AuraEnabled
        public String status {get;set;} 
        @AuraEnabled
        public List<String> giin {get;set;} 
        @AuraEnabled
        public Location location {get;set;} 
        @AuraEnabled
        public List<String> swiftBICs {get;set;} 
        @AuraEnabled
        public List<Sobject> clearingCodes {get;set;} 
        @AuraEnabled
        public string linkToFullDetails {get;set;} 
    }
    
    public class Location {
        @AuraEnabled
        public String id {get;set;} 
        @AuraEnabled
        public StreetAddress streetAddress {get;set;} 
        @AuraEnabled
        public String area {get;set;} 
        @AuraEnabled
        public String city {get;set;} 
        @AuraEnabled
        public Country country {get;set;} 
        @AuraEnabled
        public String postalCode {get;set;} 
        @AuraEnabled
        public String subArea {get;set;} 
    }
    
    public class StreetAddress {
        @AuraEnabled
        public String addressLine1 {get;set;} 
        @AuraEnabled
        public String addressLine2 {get;set;} 
        @AuraEnabled
        public String addressLine3 {get;set;} 
        @AuraEnabled
        public String addressLine4 {get;set;}
    }
    
    public class Country {
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String iso3 {get;set;}
    }
    
}