public class OLF_Utility {
    
    public static String connectionErrMsg;
    public static Boolean global_overrideChecks = false;

    //Method to check each api hit by olf and audit if logged in by human
    @Future
    public static void auditOlfApiLogin(Map<String,String> headerMap,string apiReqType,Datetime dateTimeToBeUpdated){
        if(headerMap.containsKey('CustomerEmail') && headerMap.get('CustomerEmail') != null && headerMap.get('CustomerEmail')!=''){
            insertApiHitEntrybyOlf(headerMap,apiReqType,dateTimeToBeUpdated);
        }
    }
    public static void insertApiHitEntrybyOlf(Map<String,String> headerMap,String apiReqType,Datetime dateTimeToBeUpdated){
        Online_User_API_Audit__c onlUsrApiAdt= new Online_User_API_Audit__c();
        onlUsrApiAdt.API_Request_By__c= headerMap.get('CustomerEmail');
        onlUsrApiAdt.API_Request_For__c=apiReqType;
        onlUsrApiAdt.API_Request_Time__c=dateTimeToBeUpdated;
        insert onlUsrApiAdt;
    }

    //START - Rahul Sharma | Date: 29-Oct-20 : Updated method to validate tranche input.
    public static OLFWrapper.OlfTrancheWrap checkOLFConnectionStatus(String tranche){
        Boolean connectionStatus=false;
        OLFWrapper.OlfTrancheWrap olfTrancheWrap = new OLFWrapper.OlfTrancheWrap();
        Map<String,settingWrapper> setWrap=getSettings(new SET<String>{'OLF Connection Active', tranche});
        if(!setWrap.isEmpty()){
            for(String s:setWrap.keyset()){
                if(setWrap.containsKey('OLF Connection Active') && setWrap.get('OLF Connection Active') != null && setWrap.containsKey(tranche)){
                    if(setWrap.get(tranche).isActive)
                        connectionStatus=Boolean.valueOf(setWrap.get('OLF Connection Active').SettingValue);
                }
            }
        }
        if(global_overrideChecks)
            connectionStatus = true;
        if(!connectionStatus){
            if(setWrap.isEmpty()){
                connectionErrMsg = 'Shell Online connection is disabled. Please contact Shell Support.';
                System.debug('OLF_Utility >> checkOLFConnectionStatus: OLF Settings not found in Revolution Settings object.');
            }
            else if(!setWrap.containsKey('OLF Connection Active') || setWrap.get('OLF Connection Active') == null){
                connectionErrMsg = 'Shell Online connection is disabled. Please contact Shell Support.';
                System.debug('OLF_Utility >> checkOLFConnectionStatus: OLF connection is inactive.');
            }
            else if(setWrap.containsKey(tranche)){
                connectionErrMsg = 'The given lifting window (tranche) is not active. Please contact Shell Support for more information.';
                System.debug('OLF_Utility >> checkOLFConnectionStatus: Tranche is inactive from the OLF Dashboard.');
            }
            else{
                connectionErrMsg = 'Lifting window (tranche) input is not valid. Please contact Shell Support for more information.';
                System.debug('OLF_Utility >> checkOLFConnectionStatus: Invalid tranche input.');
            }
        }
        olfTrancheWrap.isOlfActive = connectionStatus;
        if(!setWrap.isEmpty() && setWrap.containsKey(tranche)){
            olfTrancheWrap.startDay = setWrap.get(tranche).startDay;
            olfTrancheWrap.endDay = setWrap.get(tranche).endDay;
        }
        return olfTrancheWrap;
    }
    //END - Rahul Sharma | Date: 29-Oct-20 : Updated method to validate tranche input.

    //START - Rahul Sharma | Date: 22-Oct-20 : Modifying logic to also check atleast one lifting window.
    public static Boolean connectionAllowed(){
        Boolean returnStatus = false;
        Boolean anyTrancheActive = false;  
        String usernameLabel = 'OLF Username';
        String activeLabel = 'OLF Connection Active';
        Set<String> trancheSettNameSet = new Set<String>{OLF_DashboardApexController.global_liftingWindowOne, OLF_DashboardApexController.global_liftingWindowTwo,
                                                         OLF_DashboardApexController.global_liftingWindowThree, OLF_DashboardApexController.global_liftingWindowFour};
        Set<String> settingNames = new Set<String> {usernameLabel, activeLabel};
        settingNames.addAll(trancheSettNameSet);
        Map<String,OLF_Utility.settingWrapper> settWrap = new map<String,OLF_Utility.settingWrapper>();
        settWrap = OLF_Utility.getSettings(settingNames);
        String IntegrationUsername='';
        if(!settWrap.isEmpty()){
            for(String settName : trancheSettNameSet){
                if(settWrap.containsKey(settName) && settWrap.get(settName).isActive){
                    anyTrancheActive = true;
                    break;
                }
            }
            if(settWrap.containskey(usernameLabel))
            IntegrationUsername = settWrap.get(usernameLabel).SettingValue;   
            System.debug('Username is ' + IntegrationUsername);
            if((IntegrationUsername.length()>0 || global_overrideChecks) && anyTrancheActive){
                User[] u=[Select Id , isactive from User where username = :IntegrationUsername Limit 1];
                if(global_overrideChecks)
                    u=[Select Id , isactive from User where username = :Userinfo.getUserName() Limit 1]; 
                if(u.size()>0){
                    System.debug('Found the user');
                    if(settWrap.containskey(activeLabel) && u[0].isactive){
                        if(settWrap.get(activeLabel).SettingValue.toUpperCase().equals('TRUE'))
                            returnStatus =true;
                    }
                }
            }
        }
        if(global_overrideChecks && anyTrancheActive)
            returnStatus = true;     
        if(!returnStatus)
            connectionErrMsg = System.label.OLF_ConnectionErrorMessage;     
        return returnStatus;
    }
    //END - Rahul Sharma | Date: 22-Oct-20 : Modifying logic to also check atleast one lifting window.

    //Updating Credit Limit for Customer
    public static void updateCreditForCustomer(Account acc,decimal creditTobeDeducted){
        //START | Rahul Sharma | Date - 18-Mar-2020 : Updated logic to update parent account instead on child account
        acc.Parent.Rv_Credit_Available__c=acc.Parent.Rv_Credit_Available__c-creditTobeDeducted;
        acc.Parent.Rv_Credit_Utilized__c=acc.Parent.Rv_Credit_Utilized__c+creditTobeDeducted;
        system.debug('acc==>'+acc);
        update acc.Parent; 
        //END | Rahul Sharma | Date - 18-Mar-2020 : Updated logic to update parent account instead on child account 
    }
    //Calculate Volume based on sales and Max atp for that plant grade
    //START | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters to take account Id instead of Account object
    //START | Rahul Sharma | Date - 27-Jan-2021 : Updated logic to fetch ATP volume based on tranche.
    public static Map<String,Decimal> getCustomerSpecificVolume(Map<String, Decimal> atpGrdLocMap, Id accId, List<String> trancheList){
        List<Customer_Sales_Management__c> csmLst=new List<Customer_Sales_Management__c>();
        Map<String,Decimal> atpLocCustVolMap = new Map<String,Decimal>();
        csmLst = [SELECT Customer__c,
                         Plant__c,
                         Plant_Code__c,
                         Product_Category__c,
                         Tranche__c,
                         Sales_CBM__c FROM Customer_Sales_Management__c WHERE Customer__c =: accId AND 
                                                                              Tranche__c IN: trancheList];
    //END | Rahul Sharma | Date - 17-Mar-2020 : Updated method parameters to take account Id instead of Account object
        if(csmLst.size()>0){
            for(Customer_Sales_Management__c csm :csmLst){
                atpLocCustVolMap.put(csm.Plant_Code__c+csm.Product_Category__c+csm.Tranche__c, csm.Sales_CBM__c); 
    //END | Rahul Sharma | Date - 27-Jan-2021 : Updated logic to fetch ATP volume based on tranche.
            }   
        }
        for(string plantGrd : atpGrdLocMap.keyset()){
            if(atpLocCustVolMap.containsKey(plantGrd)){
              Decimal avlVol  = atpGrdLocMap.get(plantGrd) - atpLocCustVolMap.get(plantGrd);
              atpGrdLocMap.put(plantGrd, avlVol);
            }
        }
        return atpGrdLocMap;
    }
    
    //START | Rahul Sharma | Date - 30-Oct-2020 : Updated logic to check if the account is eligible for the given tranche.
    public static List<Account> queryForCustomerDetail(String customerEmail, String tranche){
        //START | Rahul Sharma | Date - 16-March-2020 : Updated query and record type
        //Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
        Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Ship_To').getRecordTypeId();
        List<Account> actLst = new List<Account>();
        actLst=[SELECT Id,
                       ParentId,
                       Name,
                       Rv_Olf_Customer_Email__c,
                       Parent.Rv_Credit_Available__c,
                       Parent.RV_Available_Tranches__c,
                       Ship_to_Number__c,                 
                       Parent.Rv_Credit_Utilized__c FROM Account WHERE RecordTypeId=:recTypeId AND 
                                                                       Rv_Olf_Customer_Email__c =: customerEmail AND 
                                                                       Rv_Available_for_OLF__c= true AND
                                                                       Customer_Type__c = 'Ship To' AND
                                                                       (Parent.Rv_AT01_Deletion_Flag__c = false OR
                                                                       Parent.Rv_DE01_Deletion_Flag__c = false)];  
        //END | Rahul Sharma | Date - 16-March-2020 : Updated query and record type
        if(!actLst.isEmpty() && actLst[0].Parent.RV_Available_Tranches__c != null){
            if(!actLst[0].Parent.RV_Available_Tranches__c.contains(tranche)){
                connectionErrMsg = 'The customer is not eligible for the offer requested.';
                return new List<Account>();
            }
            else
                return actLst;
        }
        else{
            connectionErrMsg = 'Authentication Failed! Contact Not Found.';
            return new List<Account>();
        }
        //END | Rahul Sharma | Date - 30-Oct-2020 : Updated logic to check if the account is eligible for the given tranche.
    }

    public static Map<String, Decimal> convertTonCBM(List<ATP__c> atpList, String sobjectField, String tranche){    //Rahul Sharma | Date - 27-Jan-2021 : Added addtional tranche parameter.
        Map<String ,Decimal>  atpLocTrancheMap = new Map<String, Decimal >();
        decimal astmAgoIgo=Decimal.valueOf(Label.Rv_ConversionAgoIgoCBMtoTon);
        decimal astmMogas= Decimal.valueOf(Label.Rv_ConversionMogasCBMtoTon);  
        if(atpList.size() > 0){
            for(ATP__c atp:atpList){
                Decimal atpVol = 0;
                if(atp.Grade_Level2__c.contains('ULG')){
                    if(atp.get(sobjectField) !=null){
                    atpVol = ((Decimal)atp.get(sobjectField)/astmMogas).round(System.RoundingMode.HALF_DOWN);
                    }
                    else
                        atpVol = 0;
                }
                else{
                    if(atp.get(sobjectField) !=null)
                        atpVol = ((Decimal)atp.get(sobjectField)/astmAgoIgo).round(System.RoundingMode.HALF_DOWN);
                    else
                        atpVol = 0;
                }
                atpLocTrancheMap.put(atp.Plant_Code__c+atp.Grade_Level2__c+tranche, atpVol);   //Rahul Sharma | Date - 27-Jan-2021 : Updated key for the map returning.
            } 
        }
        return atpLocTrancheMap;
    }
    //Method to insert or update Online sales in Customer sales management Object 
    //START | Rahul Sharma | Date - 09-Nov-2020 : Updated logic to update customer specific volume based on tranche.
    public static void makeEntryInCustomerSalesManagement(List<Sht__c> shtLst, Id accountId, Map<String,String> gradeMap,
                                                          Map<String,String> plantIdCodeMap){
        List<Customer_Sales_Management__c> csmLst= new List<Customer_Sales_Management__c>();
        Set<Customer_Sales_Management__c> csmSet= new Set<Customer_Sales_Management__c>(); 
        List<Customer_Sales_Management__c> oldCsmLst= new List<Customer_Sales_Management__c>();
        Map<String,Customer_Sales_Management__c> plntGrdSalesMap= new Map<String,Customer_Sales_Management__c>();                                                    
		Map<String,List<Customer_Sales_Management__c>> customerCsmLstMap= new Map<String,List<Customer_Sales_Management__c>>();                                                             
        //Map<String,Customer_Sales_Management__c> customerCsmMap= new Map<String,Customer_Sales_Management__c>();
        oldCsmLst = [SELECT Customer__c,
                            Plant_Code__c,
                            Product_Category__c,
                            Sales_CBM__c,
                            Online_Deal_Count__c,
                            Tranche__c FROM Customer_Sales_Management__c WHERE Customer__c =: accountId];
        if(oldCsmLst.size()>0){
            for(Customer_Sales_Management__c csm :oldCsmLst){
                plntGrdSalesMap.put(csm.Plant_Code__c + csm.Product_Category__c + csm.Tranche__c, csm); 
                //customerCsmMap.put(csm.Customer__c, csm);
            } 
        }                                                  
        for(sht__c sh:shtLst){
            Customer_Sales_Management__c csm;
            if(plntGrdSalesMap.containsKey(plantIdCodeMap.get(sh.Location__c) + gradeMap.get(sh.Product_Category__c) + sh.Tranche__c)){
                csm=plntGrdSalesMap.get(plantIdCodeMap.get(sh.Location__c) + gradeMap.get(sh.Product_Category__c) + sh.Tranche__c);
                csm.Sales_CBM__c=csm.Sales_CBM__c+sh.Volume_CBM__c;
                csm.Online_Deal_Count__c=csm.Online_Deal_Count__c+1;
                plntGrdSalesMap.put(plantIdCodeMap.get(sh.Location__c)+gradeMap.get(sh.Product_Category__c) + sh.Tranche__c, csm);  
            }else{
                csm=new Customer_Sales_Management__c();
                csm.Customer__c=sh.Customer__c;
                csm.Plant__c=sh.Location__c;
                csm.Product_Category__c=gradeMap.get(sh.Product_Category__c);
                csm.Sales_CBM__c=sh.Volume_CBM__c;
                csm.Online_Deal_Count__c=1;
                csm.Tranche__c=sh.Tranche__c;
                plntGrdSalesMap.put(plantIdCodeMap.get(sh.Location__c)+gradeMap.get(sh.Product_Category__c) + sh.Tranche__c, csm);
    //END | Rahul Sharma | Date - 09-Nov-2020 : Updated logic to update customer specific volume based on tranche.
            }
        }
        if(plntGrdSalesMap.size()>0){
            /*for(string key:plntGrdSalesMap.keyset()){
                csmLst.add(plntGrdSalesMap.get(key));
            }*/
            csmLst.addAll(plntGrdSalesMap.values());   
        }                                                  
        if(csmLst.size()>0){
            try{
                upsert csmLst;
            }catch(Exception e){
                System.debug('Error while Inserting CSM Record'+e);
            }
        }
    }

   //Revolution Settings
   //START | Rahul Sharma | Date - 16-Oct-2020 : Updated logic to query and include OLF tranche setting records
   public class settingWrapper{
       @AuraEnabled
       public Id settingID;
       @AuraEnabled
       public String settingName;
       @AuraEnabled
       public String settingValue;
       @AuraEnabled
       public Boolean isActive;
       @AuraEnabled
       public Integer startDay;
       @AuraEnabled
       public Integer endDay;
   }

    public static Map<String,settingWrapper> getSettings (Set<String> settingNames){
        Map<String,settingWrapper> returnValue = new Map<String,settingWrapper>();
        if(settingNames.size()>0){
            Revolution_Setting__c[] revSet = [SELECT Id,
                                                    Name, 
                                                    Value__c,
                                                    Active__c,
                                                    Start_Day__c,
                                                    End_Day__c FROM Revolution_Setting__c WHERE Name IN :settingNames];
            for(Revolution_Setting__c sett : revSet){
                settingWrapper sw = new settingWrapper();
                sw.settingID = sett.id;
                sw.settingName = sett.name;
                sw.SettingValue = sett.value__c;
                sw.isActive = sett.Active__c;
                sw.startDay = Integer.valueOf(sett.Start_Day__c);
                sw.endDay = Integer.valueOf(sett.End_Day__c);
                returnValue.put(sw.settingName, sw);
            }
        }
        return returnValue;
    }
   //END | Rahul Sharma | Date - 16-Oct-2020 : Updated logic to query and include OLF tranche setting records

    /*Method Name	:	getContractDateWindow
    * Date			:	02-Nov-2020
    * Developer		:	Rahul Sharma
    * Description	:	Calculate and return contract start date and end date for the given start day and end day*/
    public static OLFWrapper.ContractDateWindowWrap getContractDateWindow(Integer startDay, Integer endDay){
        OLFWrapper.ContractDateWindowWrap dateWrap = new OLFWrapper.ContractDateWindowWrap();
        if(startDay != null && endDay != null){
            dateWrap.contractStartDate = Date.today().addDays(startDay);
            dateWrap.contractEndDate = Date.today().addDays(endDay);
        }
        else{
            try{
                throw new CustomException('startDay/endDay cannot be empty.');
            }
            catch(Exception e){
                System.debug('OLF_Utility >> getContractDateWindow >> Exception: ' + e.getMessage() + 'Line Number: ' + e.getLineNumber());
            }
        }
        return dateWrap;
    }

    /*Method Name	:	getOnilineTranche
    * Date			:	03-Nov-2020
    * Developer		:	Rahul Sharma
    * Description	:	Calculate and return tranche for the given contract start dates.*/
    public static Map<String, String> getOnilineTranche(List<Date> startDateList){
        Map<String, String> startDateVsTrancheMap = new Map<String, String>();
        if(!startDateList.isEmpty()){
            for(Revolution_Setting__c revSett : [SELECT Id,
                                                        Name, 
                                                        Value__c,
                                                        Active__c,
                                                        Start_Day__c,
                                                        End_Day__c FROM Revolution_Setting__c WHERE Start_Day__c != NULL AND 
                                                                                                    End_Day__c != NULL LIMIT 50000]){
                for(Date startDate : startDateList){
                    if(startDate >= Date.today().addDays(Integer.valueOf(revSett.Start_Day__c)) && startDate <= Date.today().addDays(Integer.valueOf(revSett.End_Day__c)) &&
                       revSett.Active__c){
                        startDateVsTrancheMap.put(String.valueOf(startDate), revSett.Value__c);
                    }
                }                                                                                        
            }
            if(startDateVsTrancheMap.isEmpty()){
                try{
                    throw new CustomException('Deal cannot be booked as the lifting date is not valid.');
                }
                catch(Exception e){
                    System.debug('OLF_Utility >> getOnilineTranche >> Exception: ' + e.getMessage() + 'Line Number: ' + e.getLineNumber());
                }
            }
        }
        else{
            try{
                throw new CustomException('startDateList cannot be empty or null.');
            }
            catch(Exception e){
                System.debug('OLF_Utility >> getOnilineTranche >> Exception: ' + e.getMessage() + 'Line Number: ' + e.getLineNumber());
            }
        }
        return startDateVsTrancheMap;
    }

    /*Method Name	:	queryForCustomerDetail
    * Date			:	27-Jan-2021
    * Developer		:	Rahul Sharma
    * Description	:	Returns list of Ship-To accounts for the given email Id.*/
    public static List<Account> queryForCustomerDetail(String customerEmail){
        Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Revolution_Ship_To').getRecordTypeId();
        List<Account> actLst = new List<Account>();
        //START | Rahul Sharma | Date - 18-Feb-2021 | PBI-712396 : Updated query filter to get only active accounts.
        actLst=[SELECT Id,
                       ParentId,
                       Name,
                       Rv_Olf_Customer_Email__c,
                       Parent.Rv_Credit_Available__c,
                       Parent.RV_Available_Tranches__c, 
                       Ship_to_Number__c,            
                       Parent.Rv_Credit_Utilized__c FROM Account WHERE RecordTypeId =: recTypeId AND 
                                                                       Rv_Olf_Customer_Email__c =: customerEmail AND 
                                                                       Rv_Available_for_OLF__c = true AND
                                                                       Customer_Type__c = 'Ship To' AND
                                                                       (Parent.Rv_AT01_Deletion_Flag__c = false OR
                                                                       Parent.Rv_DE01_Deletion_Flag__c = false)]; 
        //END | Rahul Sharma | Date - 18-Feb-2021 | PBI-712396 : Updated query filter to get only active accounts. 
        if(!actLst.isEmpty() && actLst[0].Parent.RV_Available_Tranches__c != null){
            return actLst;
        }
        else{
            connectionErrMsg = 'Authentication Failed! Contact Not Found.';
            return new List<Account>();
        }
    }

    /*Class Name	:	CustomException
    * Date			:	12-Jun-2020
    * Developer		:	Rahul Sharma
    * Description	:	Custom excception class*/
    public class CustomException extends Exception{}
}