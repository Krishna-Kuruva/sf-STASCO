@RestResource(urlMapping='/OLFMRCData/*')   
      global without sharing class OLF_MRCSendTrancheData {
	 public static Map<String, String> trancheSettNameMap = new Map<String, String>();
        @HttpPost
        global static void get(){
            trancheSettNameMap.put('ATP1', OLF_DashboardApexController.global_liftingWindowOne);
            trancheSettNameMap.put('ATP2', OLF_DashboardApexController.global_liftingWindowTwo);
            trancheSettNameMap.put('ATP3', OLF_DashboardApexController.global_liftingWindowThree);
            trancheSettNameMap.put('ATP4', OLF_DashboardApexController.global_liftingWindowFour);
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String tranche ='';
            List<RV_OLF_MRC_Data__c> olfResponse = new List<RV_OLF_MRC_Data__c>();
            List<String> customerEmails = new List<String>();
                        OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();

            if(OLF_Utility.connectionAllowed()){
                Map<String, String> headerMap=req.headers;
                //OLF_Utility.auditOlfApiLogin(headerMap,'GetPrice');
                      Blob body = req.requestBody;
                String requestString = body.toString();
  OLFWrapper.customerEmailWrap customerTrancheEmailWrp=(OLFWrapper.customerEmailWrap)JSON.deserialize(requestString,OLFWrapper.customerEmailWrap.class);
                     olfTrancheWrap= OLF_Utility.checkOLFConnectionStatus(trancheSettNameMap.get(customerTrancheEmailWrp.tranche));
   			
                if(customerTrancheEmailWrp.customerEmail != 'All'){
                        customerEmails=customerTrancheEmailWrp.customerEmail.split(';');
                    }else{
                        customerEmails=null;
                    }
    
              tranche = customerTrancheEmailWrp.tranche;
                  
                System.debug(tranche);
                OLFWrapper.returnMessageWrap authResult= new OLFWrapper.returnMessageWrap();
				
        List<OLFWrapper.MrcPriceWrap> mrcPriceWrapVar = new List<OLFWrapper.MrcPriceWrap>();
                if(olfTrancheWrap.isOlfActive){
                if(!String.isEmpty(tranche)){
                    if(trancheSettNameMap.containsKey(tranche)){
                        if(customerEmails != null){
                     olfResponse = [Select RV_MaterialName__c,RV_LocationName__c,RV_ContractEndDate__c,RV_ContractStartDate__c,RV_Grade__c,RV_MrcId__c,RV_OLF_Contact_Email__c,tranche__c,RV_VolumeCBM__c,RV_PricePerVol__c,LastModifiedTime__c from RV_OLF_MRC_Data__c where tranche__c = :tranche and RV_OLF_Contact_Email__c IN :customerEmails];
                        }else{
                            
                      olfResponse = [Select RV_MaterialName__c,RV_LocationName__c,RV_ContractEndDate__c,RV_ContractStartDate__c,RV_Grade__c,RV_MrcId__c,RV_OLF_Contact_Email__c,tranche__c,RV_VolumeCBM__c,RV_PricePerVol__c,LastModifiedTime__c from RV_OLF_MRC_Data__c where tranche__c = :tranche];
                        }
                        System.debug('OLF Response'+olfResponse.size());
                            for(RV_OLF_MRC_Data__c olf:olfResponse){
                            OLFWrapper.MrcPriceWrap wrapRecord = new OLFWrapper.MrcPriceWrap();
                			wrapRecord.MRCNumber = olf.RV_MrcId__c;
                			wrapRecord.Location = olf.RV_LocationName__c;
                			wrapRecord.MaterialName = olf.RV_MaterialName__c;
                			wrapRecord.grade = olf.RV_Grade__c;
                            wrapRecord.availableVolume=String.valueOf(olf.RV_VolumeCBM__c);
                            wrapRecord.PricePerUnit = String.valueOf(olf.RV_PricePerVol__c);
                			wrapRecord.StartDate = olf.RV_ContractStartDate__c;
                			wrapRecord.EndDate = olf.RV_ContractEndDate__c;
                            wrapRecord.LastModifiedTime=olf.LastModifiedTime__c;
              //  wrapRecord.customerName=wrp.accName;
                			wrapRecord.contactEmail=olf.RV_OLF_Contact_Email__c;
                			mrcPriceWrapVar.add(wrapRecord);
                        }
                        if(olfResponse.size()>0){
                            RestContext.response.addHeader('Content-Type', 'application/json');
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(mrcPriceWrapVar)); 
                      
                        }else{
                             authResult.message='No valid MRC Found';
                            RestContext.response.addHeader('Content-Type', 'application/json');
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(authResult));                          
                   
                        }
                    }
                    else{
                        System.debug('OLF_UserAuthentication >> get >> Lifting window (tranche) is invalid.');
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize('Lifting window (Tranche) is invalid.')); 
                        RestContext.response.statusCode = 500;
                    }
                }
                else{
                    System.debug('OLF_UserAuthentication >> get >> Lifting window (tranche) is blank.');
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize('Lifting window (Tranche) cannot be blank.')); 
                    RestContext.response.statusCode = 500;
                }
                //END | Rahul Sharma | Date - 25-Sep-2020 : Adding tranche variable to allow OLF to get offers for all tranches.
                }    else{
                        System.debug('inside else response body ::' +authResult);
                        authResult.message= OLF_Utility.connectionErrMsg;
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(authResult));
                    }
                }
            else
            {
                System.debug('Connection Not Allowed');
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(OLF_Utility.connectionErrMsg)); 
                RestContext.response.statusCode = 500;
            }
        }
}