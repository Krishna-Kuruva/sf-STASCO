@RestResource(urlMapping='/RE_FX_Rates/*')
global class RE_FxRateController {  
    @HttpPost
    global static void createFxRate() {
		RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        List<jsonFxWrap> jsonWrapList = (List<jsonFxWrap>)JSON.deserialize(req.requestbody.tostring(),List<jsonFxWrap>.class);
        List<RE_External_Exchange_Rate__c> fxdatalist = new List<RE_External_Exchange_Rate__c>();
        for(jsonFxWrap jsondata : jsonWrapList){
            if(jsondata.exchangeRateType != null && jsondata.fromCurrency != null && jsondata.toCurrency != null && jsondata.effectiveDate != null){
                RE_External_Exchange_Rate__c exfxdata = new RE_External_Exchange_Rate__c();
                exfxdata.RE_Exchange_Rate_Type__c = jsondata.exchangeRateType;
                exfxdata.RE_From_Currency__c = jsondata.fromCurrency;
                exfxdata.RE_To_Currency__c = jsondata.toCurrency;
                exfxdata.RE_Effective_Date__c = jsondata.effectiveDate;
                exfxdata.RE_Rate__c = jsondata.rate;
                fxdatalist.add(exfxdata);
            }
        }
        if(!fxdatalist.isEmpty()){
            try{ 
                Database.insert(fxdatalist, True);
            	res.statusCode = 201;
                res.responseBody = Blob.valueOf('Success');
            }
            catch(Exception e){
                res.statusCode = 403;
                res.responseBody = Blob.valueOf('Failure - '+e.getMessage());
                System.debug('Failed Fx load');
            }
        }
        else{
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Failure'); 
        }
        
    } 
    
    public class jsonFxWrap{
        String exchangeRateType;
        String fromCurrency;
        String toCurrency;
        String effectiveDate;
        Double rate;
    }
}