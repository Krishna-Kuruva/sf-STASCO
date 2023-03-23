/******************************************************************************************************************
className           :    BET_BDD_Bankers_baidWrapper
Description         :    This class contains a wrapper class of Bankers baid.
----------------------Modiflication Logs------------------------------------
20th March 2023 - added the new parameters as per Banker APIs BY Ashish.A.Jadhav@shell.com
*******************************************************************************************************************/
public class BET_BDD_Bankers_baidWrapper {
    public class responseParameterBaid{
        @AuraEnabled
        public ResultPayload resultPayload {get;set;}
        @AuraEnabled
        public string responseMessage {get;set;}
        @AuraEnabled
        public Boolean isSuccess {get;set;}
        @AuraEnabled
        public Integer responseCode {get;set;} 
        @AuraEnabled
        public String accessToken{get;set;}
    } 
    
    public class ResultPayload {
        @AuraEnabled
        public LegalEntity legalEntity {get;set;} 
        @AuraEnabled
        public List<Financials> financials {get;set;}
    }
    
    public class LegalEntity {
        @AuraEnabled
        public List<Names> names {get;set;} 
        @AuraEnabled
        public String type {get;set;} 
        @AuraEnabled
        public String status {get;set;} 
        @AuraEnabled
        public Boolean offshoreIndicator {get;set;} 
        @AuraEnabled
        public RegisteredOffice registeredOffice {get;set;} 
        @AuraEnabled
        public HeadOffice headOffice {get;set;} 
        @AuraEnabled
        public Identifiers identifiers {get;set;}
        @AuraEnabled 
        public Overview overview {get;set;} 
        @AuraEnabled
        public MemberOf memberOf {get;set;} 
        @AuraEnabled
        public List<Regulators> regulators {get;set;} 
        @AuraEnabled
        public List<Auditors> auditors {get;set;} 
        @AuraEnabled
        public Ownership ownership {get;set;} 
        @AuraEnabled
        public List<String> stockExchanges {get;set;} 
        @AuraEnabled
        public List<Personnel> personnel {get;set;} 
        @AuraEnabled
        public List<DueDiligenceDocuments> dueDiligenceDocuments {get;set;} 
        @AuraEnabled
        public List<String> websites {get;set;} 
        @AuraEnabled
        public Summary summary {get;set;} 
    }
    
    public class Names { 
        @AuraEnabled
        public String type {get;set;}  
        @AuraEnabled
        public String value {get;set;} 
    }
    
    public class RegisteredOffice {
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public List<String> types {get;set;} 
        @AuraEnabled
        public String status {get;set;} 
        @AuraEnabled
        public List<Locations> locations {get;set;} 
        @AuraEnabled
        public List<Departments> departments {get;set;} 
        @AuraEnabled
        public Identifiers identifiers {get;set;}
    }
    
    public class Locations {
        @AuraEnabled
        public Address address {get;set;} 
        @AuraEnabled
        public ContactDetails contactDetails {get;set;} 
    }
    
    public class Address {
        @AuraEnabled
        public String type {get;set;} 
        @AuraEnabled
        public StreetAddress streetAddress {get;set;} 
        @AuraEnabled
        public String city {get;set;} 
        @AuraEnabled
        public Subarea subarea {get;set;} 
        @AuraEnabled
        public Subarea area {get;set;} 
        @AuraEnabled
        public String country {get;set;} 
        @AuraEnabled
        public String postalCode {get;set;} 
        @AuraEnabled
        public String postalCodePosition {get;set;} 
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
    
    public class Subarea {
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String displayName {get;set;}
        @AuraEnabled 
        public Boolean isUsedInAddress {get;set;} 
    }
    
    public class ContactDetails {
        @AuraEnabled 
        public List<String> telephone {get;set;} 
        @AuraEnabled 
        public List<String> fax {get;set;} 
        @AuraEnabled 
        public List<String> email {get;set;} 
        @AuraEnabled 
        public List<String> telex {get;set;} 
        @AuraEnabled 
        public List<String> reuters {get;set;}     
    }
    
    public class Departments {
        @AuraEnabled 
        public String name {get;set;} 
        @AuraEnabled 
        public List<RoutingCodes> routingCodes {get;set;} 
        @AuraEnabled 
        public ContactDetails contactDetails {get;set;} 
    }
    
    
    public class RoutingCodes {
        @AuraEnabled 
        public String routingCodeType {get;set;} 
        @AuraEnabled 
        public String routingCodeValue {get;set;} 
        @AuraEnabled 
        public String routingCodeStatus {get;set;} 
    }
    
    public class Identifiers {
        @AuraEnabled 
        public String bankersAlmanacId {get;set;} 
        @AuraEnabled 
        public List<String> swiftBICs {get;set;} 
        @AuraEnabled 
        public List<String> giin {get;set;}
        @AuraEnabled 
            public Lei lei {get;set;}    
    }
    
    public class HeadOffice { 
        @AuraEnabled 
        public String name {get;set;}  
        @AuraEnabled 
        public List<String> types {get;set;}  
        @AuraEnabled 
        public String status {get;set;}  
        @AuraEnabled 
        public List<Locations> locations {get;set;}  
        @AuraEnabled 
        public List<Departments> departments {get;set;}  
        @AuraEnabled 
        public Identifiers identifiers {get;set;} 
    }
    
    public class Overview {
        @AuraEnabled 
        public List<String> activities {get;set;} 
        @AuraEnabled 
        public List<String> services {get;set;} 
    }
    
    public class MemberOf {
        @AuraEnabled 
        public List<Items> items {get;set;} 
    }
    
    public class Items {
        @AuraEnabled 
        public String bankersAlmanacId {get;set;} 
        @AuraEnabled 
        public String name {get;set;} 
    }
    
    public class Regulators {
        @AuraEnabled 
        public String bankersAlmanacId {get;set;} 
        @AuraEnabled 
        public String name {get;set;} 
        @AuraEnabled 
        public String regulatorType {get;set;} 
        @AuraEnabled 
        public RegisteredOffice registeredOffice {get;set;}
    } 
    
    public class Auditors {
        @AuraEnabled 
        public String bankersAlmanacId {get;set;}
        @AuraEnabled  
        public String name {get;set;} 
        @AuraEnabled 
        public String auditorType {get;set;} 
    }
    
    public class Ownership {    
        @AuraEnabled 
        public UltimateParent ultimateParent {get;set;} 
        @AuraEnabled 
        public List<DirectOwners> directOwners {get;set;} 
        @AuraEnabled 
        public List<Ubos> ubos {get;set;} 
        @AuraEnabled 
        public List<DirectSubsidiaries> directSubsidiaries {get;set;} 
        @AuraEnabled 
        public GroupStructure groupStructure {get;set;} 
    }
    
    public class UltimateParent {
        @AuraEnabled 
        public String name {get;set;} 
        @AuraEnabled 
        public String entityType {get;set;}
        @AuraEnabled  
        public String bankersAlmanacId {get;set;} 
    }
    
    public class DirectOwners {
        @AuraEnabled  
        public String name {get;set;} 
        @AuraEnabled  
        public String country {get;set;} 
        @AuraEnabled  
        public String percentageOwnership {get;set;} 
        @AuraEnabled  
        public String bankersAlmanacId {get;set;} 
        @AuraEnabled  
        public String lastVerifiedDate {get;set;} 
        @AuraEnabled  
        public String entityType {get;set;}
        @AuraEnabled  
        public String source {get;set;} 
    }
    
    public class Ubos{
        @AuraEnabled  
        public string name {get;set;}
        @AuraEnabled  
        public string entityType {get;set;}
        @AuraEnabled  
        public string percentageOwnership {get;set;}
    }
    
    public class DirectSubsidiaries {
        @AuraEnabled  
        public String name {get;set;} 
        @AuraEnabled  
        public String country {get;set;} 
        @AuraEnabled  
        public String bankersAlmanacId {get;set;} 
        @AuraEnabled  
        public String entityType {get;set;}
    }
    
    public class GroupStructure { 
        @AuraEnabled  
        public Data data {get;set;}  
        @AuraEnabled  
        public String link {get;set;} 
    }
    
    public class Data {
        @AuraEnabled  
        public String bankersAlmanacId {get;set;} 
        @AuraEnabled  
        public String name {get;set;} 
        @AuraEnabled
        public String country{get;set;}
        @AuraEnabled  
        public List<Children> children {get;set;} 
    }
    
    public class Children {
        @AuraEnabled  
        public String bankersAlmanacId {get;set;} 
        @AuraEnabled  
        public String name {get;set;} 
        @AuraEnabled  
        public String country {get;set;} 
        @AuraEnabled  
        public Double percentageOwnership {get;set;}    
        @AuraEnabled  
        public List<Children> children{get;set;}
    }
    
    
    public class Personnel {    
        @AuraEnabled  
        public String name {get;set;}     
        @AuraEnabled  
        public List<String> titles {get;set;}     
        @AuraEnabled  
        public String lastVerifiedDate {get;set;} 
    }
    
    public class DueDiligenceDocuments {  
        @AuraEnabled  
        public String nametype {get;set;}   
        @AuraEnabled  
        public String link {get;set;}   
        @AuraEnabled  
        public String filename {get;set;}   
        @AuraEnabled  
        public String publishedDate {get;set;}   
        @AuraEnabled  
        public String documentRecordType {get;set;}   
        @AuraEnabled  
        public String documentStatus {get;set;}   
        @AuraEnabled  
        public String documentGroup {get;set;}   
        @AuraEnabled  
        public String documentSet {get;set;}   
        @AuraEnabled  
        public ParentDocument parentDocument {get;set;} 
    }
    
    public class ParentDocument {
        @AuraEnabled  
        public String nametype {get;set;} 
        @AuraEnabled  
        public String link {get;set;} 
        @AuraEnabled  
        public String filename {get;set;} 
        @AuraEnabled  
        public String publishedDate {get;set;} 
        @AuraEnabled  
        public String documentRecordType {get;set;}
        @AuraEnabled   
        public String documentStatus {get;set;} 
        @AuraEnabled  
        public String documentGroup {get;set;} 
        @AuraEnabled  
        public String documentSet {get;set;} 
    }
    
    
    public class Summary {
        @AuraEnabled  
        public Integer numberOfOffices {get;set;} 
    }
    
    
    public class Financials {
        @AuraEnabled  
        public String statementType {get;set;}
        @AuraEnabled   
        public String periodStart {get;set;} 
        @AuraEnabled  
        public String periodEnd {get;set;} 
        @AuraEnabled  
        public Boolean consolidated {get;set;} 
        @AuraEnabled  
        public String originalCurrencyName {get;set;} 
        @AuraEnabled  
        public String originalCurrencyCode {get;set;} 
        @AuraEnabled  
        public String orderOfMagnitude {get;set;} 
        @AuraEnabled  
        public List<LineItemsSets> lineItemsSets {get;set;} 
        @AuraEnabled  
        public List<RatioItemSet> ratioItemSet {get;set;} 
    }
    
    
    public class LineItemsSets {
        @AuraEnabled  
        public String currencyName {get;set;} 
        @AuraEnabled  
        public String currencyCode {get;set;} 
        @AuraEnabled  
        public string exchangeRate {get;set;} 
        @AuraEnabled  
        public List<LineItemsSet> lineItemsSet {get;set;} 
    }
    
    public class LineItemsSet {
        @AuraEnabled  
        public String lineGroup {get;set;} 
        @AuraEnabled  
        public String lineName {get;set;} 
        @AuraEnabled  
        public String lineValue {get;set;} 
    }
    
    public class RatioItemSet {
        @AuraEnabled  
        public String lineName {get;set;}
        @AuraEnabled   
        public Double lineValue {get;set;} 
    }
    
    public class Lei {
        @AuraEnabled  
        public String issuer {get;set;}
        @AuraEnabled   
        public String value {get;set;} 
    }
    
}