@RestResource(urlMapping='/updateDealNo/*')
global class OLF_UpdateOlfDealOnSht {
	@HttpPost
    global static void updateOlfDealNoOnSht(){
        RestRequest req= RestContext.request;
        if(OLF_Utility.connectionAllowed()){ 	//292153_OLFConnectionTime_11Jul2019_Soumyajit
            Map<String, String> headerMap=req.headers;
            OLF_Utility.auditOlfApiLogin(headerMap,'updateOlfDealNumber',system.now());
            Blob body=req.requestBody;
            String requestString = body.toString();
            List<OLFWrapper.shtAndOlfDealNumberWrap> olfDealWrpLst=new List<OLFWrapper.shtAndOlfDealNumberWrap>();
            olfDealWrpLst=(List<OLFWrapper.shtAndOlfDealNumberWrap>)JSON.deserialize(requestString,List<OLFWrapper.shtAndOlfDealNumberWrap>.class);
            string result = updateOlfNoOnSht(olfDealWrpLst);
            //Return Response
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(result);
            
        //292153_OLFConnectionTime_11Jul2019_Soumyajit starts
        }
        else
        {
            System.debug('Connection Not Allowed');
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(OLF_Utility.connectionErrMsg)); 
            RestContext.response.statusCode = 500;
        }
        //292153_OLFConnectionTime_11Jul2019_Soumyajit ends
    }
    public static String updateOlfNoOnSht(List<OLFWrapper.shtAndOlfDealNumberWrap> olfWrapLst){
        Map<String,String> shtNoAndOlfDealNoMap= new Map<String,String>();
        if(olfWrapLst.size()>0){
            for(OLFWrapper.shtAndOlfDealNumberWrap olfWrp : olfWrapLst){
                shtNoAndOlfDealNoMap.put(olfWrp.sfdcDealNumber,olfWrp.olfDealNumber);
            } 
        }
        OLFWrapper.returnMessageWrap returnMsg= new OLFWrapper.returnMessageWrap();
        if(shtNoAndOlfDealNoMap.keyset().size()>0){
            List<Sht__c> shtLstToBeUpdated=[Select Id,Name,OLF_Deal_Number__c from sht__c where name IN :shtNoAndOlfDealNoMap.keyset()];
            if(shtLstToBeUpdated.size()>0){
                for(sht__c sh :shtLstToBeUpdated){
                    sh.OLF_Deal_Number__c=shtNoAndOlfDealNoMap.get(sh.Name);
                }
                try{
                    system.debug('shtLstToBeUpdated==>'+shtLstToBeUpdated);
                    RV_SHTTriggerHelper.isOlfDeal = true; //UrgentFix_24Apr2020_Soumyajit
					RV_SHTTriggerHelper.accountAlreadyUpdated = true; //UrgentFix_24Apr2020_Soumyajit
                    update shtLstToBeUpdated;
                    returnMsg.message='Deals updated Successfully.';
                }catch(DmlException e){
                    returnMsg.message= e.getMessage();
                }
            }
            
        }
       
        
        return JSON.serialize(returnMsg);
    }
}