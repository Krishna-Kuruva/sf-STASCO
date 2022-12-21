@RestResource(urlMapping='/Mops/*')
global class RE_MarketQuotesController {
	@HttpPost
    global static void createMops() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<jsonWrap> jsonWrapList = (List<jsonWrap>)JSON.deserialize(req.requestbody.tostring(),List<jsonWrap>.class);
        List<RE_External_Market_Quotes__c> mopsdatalist = new List<RE_External_Market_Quotes__c>();
        for(jsonWrap jsondata : jsonWrapList){
            if(jsondata.quoteNo != null && jsondata.quoteSource != null && jsondata.quoteType != null && jsondata.quoteDate != null){
                RE_External_Market_Quotes__c marketdata = new RE_External_Market_Quotes__c();
                marketdata.RE_Quote_Source__c = jsondata.quoteSource;
                marketdata.RE_Quote_Type__c = jsondata.quoteType;
                marketdata.RE_Quote_No__c = jsondata.quoteNo;
                marketdata.RE_Quote_Date__c = jsondata.quoteDate;
                marketdata.RE_Quote_Price__c = jsondata.quotePrice;
                marketdata.RE_Default_Currency__c = jsondata.defaultCurrency;
                marketdata.RE_Default_Per_Unit__c = jsondata.defaultPerUnit;
                marketdata.RE_Unit_of_Measure__c = jsondata.unitofMeasure;
                marketdata.RE_No_Quote_Indicator__c = jsondata.noQuoteIndicator;
                marketdata.RE_Gross_Net_Indicator__c = jsondata.grossNetIndicator;
                mopsdatalist.add(marketdata);
            }           	
        }
        if(!mopsdatalist.isEmpty()){
            try{ 
                Database.insert(mopsdatalist, True);
				res.statusCode = 201;    
                res.responseBody = Blob.valueOf('Success');
            }
            catch(Exception e){     
                res.statusCode = 403;
                res.responseBody = Blob.valueOf('Failure - '+e.getMessage());
                System.debug('Failed Mops load');
            }
        }
        else{
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Failure');            
        }
    } 
    
    public class jsonWrap{
        String quoteSource;
        String quoteType;
        String quoteNo;
        String quoteDate;
        Double quotePrice;
        String defaultCurrency;
        Double defaultPerUnit;
        String unitofMeasure;
        String noQuoteIndicator;
        String grossNetIndicator;
    }
}