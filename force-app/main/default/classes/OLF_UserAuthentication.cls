/*
    * @Class Name       : OLF_UserAuthentication
    * @Description: The class authenticates OLF user based on integration email id and returns available deals. 
    */ 
    @RestResource(urlMapping='/OLF/*')
    global class OLF_UserAuthentication{

        public static Map<String, String> trancheSettNameMap = new Map<String, String>();

        @HttpPost
        global static void get(){
            trancheSettNameMap.put('ATP1', OLF_DashboardApexController.global_liftingWindowOne);
            trancheSettNameMap.put('ATP2', OLF_DashboardApexController.global_liftingWindowTwo);
            trancheSettNameMap.put('ATP3', OLF_DashboardApexController.global_liftingWindowThree);
            trancheSettNameMap.put('ATP4', OLF_DashboardApexController.global_liftingWindowFour);
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            if(OLF_Utility.connectionAllowed()){
                OLFWrapper.customerEmailWrap customerEmailWrp=new OLFWrapper.customerEmailWrap();
                Map<String, String> headerMap=req.headers;
                //OLF_Utility.auditOlfApiLogin(headerMap,'GetPrice');
                Blob body = req.requestBody;
                String requestString = body.toString();
                customerEmailWrp=(OLFWrapper.customerEmailWrap)JSON.deserialize(requestString,OLFWrapper.customerEmailWrap.class);
                String tranche = 'ATP1';
                String contactEmail=customerEmailWrp.customerEmail;
                //START | Rahul Sharma | Date - 25-Sep-2020 : Adding tranche variable to allow OLF to get offers for all tranches.
                if(!String.isEmpty(customerEmailWrp.tranche))
                    tranche = customerEmailWrp.tranche;

                if(!String.isEmpty(tranche)){
                    if(trancheSettNameMap.containsKey(tranche))
                        validateContact(contactEmail, tranche);
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
            }
            else
            {
                System.debug('Connection Not Allowed');
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(OLF_Utility.connectionErrMsg)); 
                RestContext.response.statusCode = 500;
            }
        }
        
        //START | Rahul Sharma | Date - 29-Oct-2020 : Update logic to include tranche as extra parameter and get MRCs based on given tranche (lifting window)
        global static void validateContact(String emailId, String tranche){
            OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();
            List<OLFWrapper.MrcPriceWrap> olfResponse = new List<OLFWrapper.MrcPriceWrap>();
            OLFWrapper.returnMessageWrap authResult= new OLFWrapper.returnMessageWrap();
            olfTrancheWrap = OLF_Utility.checkOLFConnectionStatus(trancheSettNameMap.get(tranche));
            olfTrancheWrap.tranche = tranche;
            if(olfTrancheWrap.isOlfActive){
                if(olfTrancheWrap.startDay != null && olfTrancheWrap.endDay != null){
                    List<Account> actLst=OLF_Utility.queryForCustomerDetail(emailId, tranche);
                    if(!actLst.isEmpty()){
                    //START | Rahul Sharma | Date - 16-Mar-2020 : Updated logic to get MRCs based on Ship-to accounts instead of Sold-to accounts
                        List<MRC__c> mrcList = new List<MRC__c>();
                        Set<Id> accIdSet = (new Map<Id, Account>(actLst)).keySet();
                        Integer mrcCount = 0;
                        mrcCount = validateMRC(accIdSet); 
                        System.debug('MRC Count is not NULL -----'+mrcCount);
                        if(mrcCount > 0){
                            System.debug('Inside final data processing method-------');
                            olfResponse = getMRCData(actLst,emailId, olfTrancheWrap);
                            RestContext.response.addHeader('Content-Type', 'application/json');
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(olfResponse)); 
                            
                        }else{  
                            authResult.message='No valid MRC Found';
                            RestContext.response.addHeader('Content-Type', 'application/json');
                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(authResult));                          
                        }
                    //END | Rahul Sharma | Date - 16-Mar-2020 : Updated logic to get MRCs based on Ship-to accounts instead of Sold-to accounts
                    //END | Rahul Sharma | Date - 29-Oct-2020 : Update logic to include tranche as extra parameter and get MRCs based on given tranche (lifting window)
                    }
                    else{
                        authResult.message= OLF_Utility.connectionErrMsg;
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(authResult));
                    }
                }
                else{
                    authResult.message='Connection Failed. Internal Error. Please contact Shell Support.';
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(authResult));
                    System.debug('OLF_UserAuthentication >> validateContact: Lifting window start day and end day cannot be null or empty in Revolution Settings.');
                }
            }
            else{
                authResult.message = OLF_Utility.connectionErrMsg;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(authResult));
            }          
        }
        
        public static Integer validateMRC(Set<Id> accIdSet){
            //START | Rahul Sharma | Date - 16-Mar-2020 : Updated query to get list of MRCs based on Ship-to accounts instead of Sold-to accounts
            List<AggregateResult> results = [SELECT COUNT(Id) mrcCnt FROM MRC__c WHERE Shipping_Condition__c IN (10, 11) AND 
                                                                                       Ship_To__c IN : accIdSet AND
                                                                                       Valid_To_Date__c >= TODAY AND
                                                                                       Rv_Available_for_OLF__c =:true AND
                                                                                       Active__c = true];  
            //END | Rahul Sharma | Date - 16-Mar-2020 : Updated query to get list of MRCs based on Ship-to accounts instead of Sold-to accounts           
            Integer mrcCount = 0;
            mrcCount = (Integer) results[0].get('mrcCnt');
            if(mrcCount > 0){
                return mrcCount;
            }
            return null;
        }
        
        //START | Rahul Sharma | Date - 30-Oct-2020 : Updated logic to send tranche as extra parameter to calculate price.
		//START | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters to take Ship-to accounts
        public static List<OLFWrapper.MrcPriceWrap> getMRCData(List<Account> accList, String contactEmail, OLFWrapper.OlfTrancheWrap olfTrancheWrap){
            List<OLFWrapper.MrcPriceWrap> mrcLst = new List<OLFWrapper.MrcPriceWrap>();
            if(!accList.isEmpty())
                mrcLst = OLF_FetchMrcFinalPrice.fetchPrice(accList, contactEmail, olfTrancheWrap);
        //END | Rahul Sharma | Date - 30-Oct-2020 : Updated logic to send tranche as extra parameter to calculate price.
        //END | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters to take Ship-to accounts
            if(mrcLst !=null && mrcLst.size()>0){
                return mrcLst;
            }
            else{
                return null; 
            }             
        }    
    }