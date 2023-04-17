public class OLF_DashboardApexController {
    /*
    Version : 0.0
    Author  : Soumyajit
    Date    : 03-May-2019
    Details : Apex controller for OLF Dashboard
    */  
    public static Boolean global_OLFStatus = false;
    public static String global_returnLastRequestFromOLF;
    public static String global_returnLastResponseFromRevolution;
    static final String global_returnDateFormat = 'dd.MM.yyyy HH:mm:ss';
    static final String global_returnNullDate = '01.01.0001 00:00:00';
    public static boolean global_overrideChecks = false;
    
    public static final String global_usernameLabel = 'OLF Username';
    public static final String global_activeLabel = 'OLF Connection Active';
    public static final String global_ICELGO_thresholdLabel = 'OLF ICE_LGO Threshold';

    //START - Rahul Sharma | Date: 16-Oct-20 : Adding new variables for lifting window setup.
    public static final String global_liftingWindowOne = 'Lifting Window 1';
    public static final String global_liftingWindowTwo = 'Lifting Window 2';
    public static final String global_liftingWindowThree = 'Lifting Window 3';
    public static final String global_liftingWindowFour = 'Lifting Window 4';
    static final Set<String> global_settingNames = new Set<String> {global_usernameLabel, global_activeLabel, global_ICELGO_thresholdLabel, global_liftingWindowOne, 
                                                                    global_liftingWindowTwo, global_liftingWindowThree, global_liftingWindowFour};
    //END - Rahul Sharma | Date: 16-Oct-20 : Adding new variables for lifting window setup.

    static map<String,OLF_Utility.settingWrapper> global_SettWrap = new map<String,OLF_Utility.settingWrapper>();
    public static boolean setSettingsCalled = false;
    
    //Method Declarations starts here
    
    //Method to write debug log -- Dependent on OLF_ApexControllerDebugLogOn label
    public static void writeDebugLog(String log)
    {
        if(System.label.OLF_ApexControllerDebugLogOn.toUpperCase().equals('TRUE'))
            System.debug(log);
    }
    
    @AuraEnabled
    public static boolean checkPermission(){
        boolean hasPermission = false;
        if (Schema.sObjectType.PermissionSetAssignment.isAccessible())
        {
            PermissionSetAssignment[] psa = [SELECT Id, AssigneeId, Assignee.name FROM PermissionSetAssignment where PermissionSet.name='RV_PO1' order by Assignee.name];
            if(psa.size()>0)
            {
                for (PermissionSetAssignment p : psa)
                {
                    if(p.Assignee.name.equals(UserInfo.getName())){
                        hasPermission = true;
                    }
                }
            }
        }
        system.debug('hasPermission::'+hasPermission);
        return hasPermission;
    }

    //Method to return data for page load and reload
    @AuraEnabled
    public static OLFInitWrap getAllDetails (){
        OLFInitWrap returnOLFInitWrap = new OLFInitWrap();
        List<AccountWrap> returnAccountWrap = new List<AccountWrap>();
        List<String> returnCustomerList = new List<String>();
        
        if(!setSettingsCalled)
            qryOLFsettings();
        
        checkOLFuserStatus();
        map<String,Double> thrPrice = getThresholdPrice();
        
        writeDebugLog('User Status is ' + global_OLFStatus + ' and refresh date is ' + global_returnLastRequestFromOLF + ' and ' + global_returnLastResponseFromRevolution);
            
        //Query further, only if status is true
        if (global_OLFStatus)
        {
            OLFAccountMRCWrap returnOLFAccountMRCWrap = getAccountData('','ALL');            
            
            if(returnOLFAccountMRCWrap.CustomerDetails.size()>0)
            {
                    for(AccountWrap aw : returnOLFAccountMRCWrap.CustomerDetails)
                    {
                        if(!returnCustomerList.contains(aw.Name))
                            returnCustomerList.add(aw.Name);
                        returnAccountWrap.add(aw);
                    }
                returnCustomerList.sort();
            }
        }
        
        //Build return list
        returnOLFInitWrap.OLFStatus = global_OLFStatus;
        returnOLFInitWrap.hasPermission = checkPermission();
        if (global_returnLastRequestFromOLF == null)
            returnOLFInitWrap.LastRequestFromOLF = global_returnNullDate;
        else
            returnOLFInitWrap.LastRequestFromOLF = global_returnLastRequestFromOLF;
        if (global_returnLastResponseFromRevolution == null)
            returnOLFInitWrap.LastResponseFromRevolution = global_returnNullDate;
        else
            returnOLFInitWrap.LastResponseFromRevolution = global_returnLastResponseFromRevolution;
        returnOLFInitWrap.CustomerDetails = returnAccountWrap;
        returnOLFInitWrap.CustomerList = returnCustomerList;
        returnOLFInitWrap.HasMRC = false;
        returnOLFInitWrap.NextInactivationBatchTime = getInactivationBatchDetails();	//327368_Soumyajit_09Aug2019
        if(thrPrice.containsKey(global_ICELGO_thresholdLabel))
        {
            Double icePrice = thrPrice.get(global_ICELGO_thresholdLabel);
            if(icePrice != -999.99)
            	returnOLFInitWrap.ICELGO_threshold = icePrice;					//ICELimit_Soumyajit_27Apr2020
        }

        //START - Rahul Sharma | Date: 16-Oct-20 : Added logic to include OLF tranche setting
        if(!global_SettWrap.isEmpty()){
            List<OLF_Utility.settingWrapper> trancheWrapList = new List<OLF_Utility.settingWrapper>();
            if(global_SettWrap.containsKey(global_liftingWindowOne))
                trancheWrapList.add(global_SettWrap.get(global_liftingWindowOne));
            if(global_SettWrap.containsKey(global_liftingWindowTwo))
                trancheWrapList.add(global_SettWrap.get(global_liftingWindowTwo));
            if(global_SettWrap.containsKey(global_liftingWindowThree))
                trancheWrapList.add(global_SettWrap.get(global_liftingWindowThree));
            if(global_SettWrap.containsKey(global_liftingWindowFour))
                trancheWrapList.add(global_SettWrap.get(global_liftingWindowFour));
            returnOLFInitWrap.trancheWrapList = trancheWrapList;
        }
        //END - Rahul Sharma | Date: 16-Oct-20 : Added logic to include OLF tranche setting
        return returnOLFInitWrap;
    }
    
    //Method to check Integration User status -- Dependent on OLF_Integration_Username label
    public static void checkOLFuserStatus(){
        
        if(!setSettingsCalled)
            qryOLFsettings();
        
        String usernameLabel = global_usernameLabel;
        String activeLabel = global_activeLabel;
        map<String,OLF_Utility.settingWrapper> settWrap = global_SettWrap;
        
        String IntegrationUsername='';
        
        if(settWrap.containskey(usernameLabel))
            IntegrationUsername = settWrap.get(usernameLabel).SettingValue;
        
        writeDebugLog('Username is ' + IntegrationUsername);
        
        if(IntegrationUsername.length()>0 || global_overrideChecks)     
        {
            User[] u=[Select Id , isactive from User where username = :IntegrationUsername Limit 1];
            if(global_overrideChecks)
                u=[Select Id , isactive from User where username = :Userinfo.getUserName() Limit 1];
            
            if(u.size()>0)
            {
                writeDebugLog('Found the user');
                
                
                if(settWrap.containskey(activeLabel) && u[0].isactive)
                {
                    if(settWrap.get(activeLabel).SettingValue.toUpperCase().equals('TRUE'))
                        global_OLFStatus = true;
                    else
                        global_OLFStatus = false;
                }
                else
                    global_OLFStatus = false;
            }
            else
            {
                writeDebugLog('User Not found');
                global_OLFStatus = false;
            }        
        }
        else
            global_OLFStatus = false;
        
        if(global_overrideChecks)
            global_OLFStatus = true;
        
        //UserActivateButton_Soumyajit_01Aug2019 starts
        AggregateResult[] lastConnection = [select max(API_Request_Time__c)rslt from Online_User_API_Audit__c where lastmodifieddate >= LAST_N_DAYS:7];
        if(lastConnection.size()>0)
        {
            if(lastConnection[0].get('rslt') != null)
                global_returnLastRequestFromOLF = DateTime.valueof(lastConnection[0].get('rslt')).format(global_returnDateFormat);
        } 
        
        AggregateResult[] lastDeal = [select max(createddate)rslt from SHT__c where isOlfDeal__c = true and Status__c in ('Completed','Auto-Completed') and createddate >= LAST_N_DAYS:7];
        if(lastDeal.size()>0)
        {
            if(lastDeal[0].get('rslt') != null)
                global_returnLastResponseFromRevolution = DateTime.valueof(lastDeal[0].get('rslt')).format(global_returnDateFormat);
        }
        //UserActivateButton_Soumyajit_01Aug2019 ends
    }
    
    //Method to get Account Data
    @AuraEnabled
    public static OLFAccountMRCWrap getAccountData(
                                                String AccountName, //Pass the account name, if need to filter
                                                String SearchType   // ALL : returns all accounts, THIS : returns account matching AccountName
                                              ) 
    {
        List<AccountWrap> returnAccountWrap = new List<AccountWrap>();
        List<MRCWrap> returnMRCWrap = new List<MRCWrap>();
        List<String> returnMaterialList = new List<String>();
        List<String> returnLocationList = new List<String>();
        OLFAccountMRCWrap returnOLFAccountMRCWrap = new OLFAccountMRCWrap();
        
        checkOLFuserStatus();
        
        if (global_OLFStatus)
        {
            if(SearchType.length()==0)
                SearchType = 'ALL';
            
            Id revRcdTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Revolution').getRecordTypeId();
            String SearchQry = 'select Id, Name, Sold_To_Number__c,Rv_Credit_Limit__c, Rv_Credit_Available__c, Rv_Available_for_OLF__c from Account'
                                + ' where RecordTypeId = :revRcdTypId and Rv_Available_for_OLF__c = true '; 
                                                      
            if (!SearchType.toUpperCase().equals('ALL'))
                SearchQry = SearchQry + ' and name = :AccountName ';  
            SearchQry = SearchQry + ' order by name ';
            
            writeDebugLog('Account Query is ' + SearchQry);
              
            List<String> AccountNames = new List<String>();                                          
                                                      
            List<Account> AccList = Database.query(SearchQry);
            
            if(!AccList.isEmpty())
            {
                writeDebugLog('Found Account(s)');
                for (Account acc: AccList)
                {
                    AccountWrap aw = new AccountWrap();
                    
                    aw.AccountID = acc.id;
                    aw.Name = acc.name;
                    aw.SoldTo = acc.Sold_To_Number__c;
                    if(acc.Rv_Credit_Limit__c==null)
                        aw.TotalCredit = 0;
                    else
                        aw.TotalCredit = acc.Rv_Credit_Limit__c;
                    
                    if(acc.Rv_Credit_Available__c==null)
                        aw.AvailableCredit = 0;
                    else
                        aw.AvailableCredit = acc.Rv_Credit_Available__c;
                    
                    aw.AvailableForOLF = acc.Rv_Available_for_OLF__c;
                        
                    returnAccountWrap.add(aw);
                    if(!AccountNames.contains(acc.Name))
                        AccountNames.add(acc.Name);
                }
                
                returnOLFAccountMRCWrap.CustomerDetails = returnAccountWrap;
                returnOLFAccountMRCWrap.HasMRC = false;
                                                          
                if (!SearchType.toUpperCase().equals('ALL'))
                {
                    if(AccountNames.size()>0)
                    {
                        returnMRCWrap = getMRCData(AccountName,'ALL','ALL','ALL');
                        if(returnMRCWrap.size()>0)
                        {
                            for(MRCWrap mw : returnMRCWrap)
                            {
                                if(!returnMaterialList.contains(mw.Material))
                                    returnMaterialList.add(mw.Material);
                                if(!returnLocationList.contains(mw.Location))
                                    returnLocationList.add(mw.Location);  
                            }
                            returnMaterialList.sort();
                            returnLocationList.sort();
                            
                            returnOLFAccountMRCWrap.HasMRC = true; 
                            returnOLFAccountMRCWrap.MaterialList = returnMaterialList;
                            returnOLFAccountMRCWrap.LocationList = returnLocationList;                                          
                            returnOLFAccountMRCWrap.MRCDetails = returnMRCWrap;
                        }
                        else
                            returnOLFAccountMRCWrap.HasMRC = false;                     
                    }   
                }
            }
            else
            {
                writeDebugLog('No Account Found');
                returnOLFAccountMRCWrap.CustomerDetails = returnAccountWrap;
            }
        }
        
        returnOLFAccountMRCWrap.OLFStatus = global_OLFStatus;
        
        return returnOLFAccountMRCWrap;
    }
    
    //Method to get MRC Data
    @AuraEnabled
    public static List<MRCWrap> getMRCData  (
                                            String AccountName,  //Required
                                            String MaterialName, //Pass Material name, if need to filter
                                            String LocationName, //Pass Location name, if need to filter
                                            String SearchType    // ALL : returns all MRCs, THIS : returns MRC matching account, material, location
                                            )
    {
        List<MRCWrap> ReturnMRCWrap = new List<MRCWrap>();
        
        checkOLFuserStatus();
        
        if (global_OLFStatus)
        {
            if(SearchType.length()==0)
                SearchType = 'ALL';
            if(MaterialName.length()==0)
                MaterialName= 'ALL';
            if(LocationName.length()==0)
                LocationName = 'ALL';
            
            String SearchQry = 'Select Id ,Name , Sold_To__c, Sold_To__r.name, Plant__c, Plant_Name__c, Product__c, Material_Name__c,Sales_Organization__c,Handling_Type__c,Rv_Available_for_OLF__c FROM MRC__c'
                               + ' where Sold_To__r.name = :AccountName ';                                     
            if (!SearchType.toUpperCase().equals('ALL'))
            {
                if (!MaterialName.toUpperCase().equals('ALL'))
                    SearchQry = SearchQry + ' and Material_Name__c = :MaterialName';
                if (!LocationName.toUpperCase().equals('ALL'))
                    SearchQry = SearchQry + ' and Plant_Name__c = :LocationName';
            }
                
            SearchQry = SearchQry + ' order by Sales_Organization__c,  Plant_Name__c, Material_Name__c, Handling_Type__c, Rv_Available_for_OLF__c ';
            
            writeDebugLog('Searching for ' + AccountName + ' with ' + MaterialName + ' and ' + LocationName);
            writeDebugLog('MRC Query is ' + SearchQry);
            
            List<MRC__c> MRCList = Database.query(SearchQry);
            
            if(!MRCList.isEmpty())
            {
                writeDebugLog('Found MRCs');
    			for(MRC__c m : MRCList)
                {
                    MRCWrap mw = new MRCWrap();
                    
                    mw.MRCid = m.id;
                    mw.Name = m.name;
                    mw.SoldToId = m.Sold_To__c;
                    mw.SoldTo = m.Sold_To__r.name;
                    mw.LocationId = m.Plant__c;
                    mw.Location = m.Plant_Name__c;
                    mw.MaterialId = m.Product__c;
                    mw.Material = m.Material_Name__c;
                    mw.SalesOrg = m.Sales_Organization__c;
                    mw.HandlingType = m.Handling_Type__c;
                    mw.AvailableForOLF = m.Rv_Available_for_OLF__c;
                    
                    ReturnMRCWrap.add(mw);
                }                
            }
            else
                writeDebugLog('No MRC Found');
            
        }
        return ReturnMRCWrap;    
    }
    //Method Declarations ends here
    
    //UserActivateButton_Soumyajit_01Aug2019 starts
    @AuraEnabled
    public static String userActivateInactivateFromScreen (String actionType)
    {
        Rv_RevolutionSettingTriggerHelper.global_reason = 'Manual status update from OLF Dashboard.';
        startAndStopOLFMrcDataSchedulers(actionType);
        return userActivateInactivate(actionType);
    }
    
    @AuraEnabled
    public static String userActivateInactivate(String actionType)
    {
        if(!setSettingsCalled)
            qryOLFsettings();
        
        String usernameLabel = global_usernameLabel; //OLF Username
        String activeLabel = global_activeLabel; //OLF Connection Active
        map<String,OLF_Utility.settingWrapper> settWrap = global_SettWrap;
        
        String IntegrationUsername ='';
        String returnMsg;
        
        if(settWrap.containskey(usernameLabel))
            IntegrationUsername = settWrap.get(usernameLabel).SettingValue;
        
        writeDebugLog('Username is ' + IntegrationUsername);
        
        if(IntegrationUsername.length()>0 || global_overrideChecks)     
        {
            User[] u=[Select Id , isactive from User where username = :IntegrationUsername Limit 1];
            if(global_overrideChecks)
                u=[Select Id , isactive from User where username = :Userinfo.getUserName() Limit 1];
            if(u.size()>0)
            {
                writeDebugLog('Found the user');
                Boolean doUpdate = false;
                
                if(!u[0].isactive)
                {
                    doUpdate = false;
                    writeDebugLog('User Inactive');
                    returnMsg = 'Connection user is Inactive. Please contact Administrator';
                }
                
                Revolution_Setting__c revSet = new Revolution_Setting__c();
                if(settWrap.containskey(activeLabel))
                {
                    revSet.id = settWrap.get(activeLabel).settingID;
                    if(actionType.equals('STOP') && settWrap.get(activeLabel).SettingValue.toUpperCase().equals('TRUE'))
                    {
                        revSet.Value__c = 'FALSE';
                        doUpdate = true;
                    }
					else if(actionType.equals('START') && settWrap.get(activeLabel).SettingValue.toUpperCase().equals('FALSE'))
                    {
                        revSet.Value__c = 'TRUE';
                        doUpdate = true;
                    }
                    else
                        doUpdate = false;
                }
                else
                {
                    doUpdate = false;
                    writeDebugLog('Unable to find OLF Connection Active Setting record');
                    returnMsg = 'Unable to find OLF Connection Active Setting record. Please contact Administrator';
                }
                
                try{
                    if(Revolution_Setting__c.sObjectType.getDescribe().isUpdateable())
                    {
                        if(doUpdate)
                        {
                            update revSet;
                            if(actionType.equals('STOP'))
                                returnMsg = 'Connection Inactivation is Successful';
                            else
                                returnMsg = 'Connection Activation is Successful';
                        }
                    }
                    else
                        returnMsg = 'You are not allowed to perform this action. Please contact Administrator';
                }
                catch(Exception e)
                {
                    writeDebugLog('Error while updating user '+e);
                    returnMsg = 'Something went wrong. Please contact Administrator';
                }
            }
            else
            {
                writeDebugLog('User Not found');
                returnMsg = 'Connection user not found. Please contact Administrator';
            }
        }
        
        return returnMsg;
    }
    //UserActivateButton_Soumyajit_01Aug2019 ends
    
    //327368_Soumyajit_09Aug2019 starts
    static String getInactivationBatchDetails()
    {
        String jobName = 'Auto Inactivation OLF Scheduler';
        String returnDate = 'NA';        
        CronJobDetail[] cjd = [SELECT Id, name FROM CronJobDetail where name = :jobName limit 1];
        if(cjd.size()>0)
        {
            CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression 
                                from CronTrigger 
                                where CronJobDetailId = :cjd[0].id and state != 'DELETED' limit 1];
            if(ct.size()>0)
            {
                returnDate = ct[0].NextFireTime.format(global_returnDateFormat);
            }
        }
        
        return returnDate;
    }
    //327368_Soumyajit_09Aug2019 ends
    
    //ICELimit_Soumyajit_27Apr2020 starts
    @AuraEnabled
    public static String setThresholdPrice(String ICELGO_threshold)
    {
        if(!setSettingsCalled)
            qryOLFsettings();
        
        String ICELGO_thresholdLabel = global_ICELGO_thresholdLabel;
        map<String,OLF_Utility.settingWrapper> settWrap = global_SettWrap;
        String returnMsg;
        
        if(settWrap.size()>0 || global_overrideChecks)     
        {
            writeDebugLog('Found Threshold Settings');
            
            if(settWrap.containskey(ICELGO_thresholdLabel))
            {
                writeDebugLog('Found ICE_LGO Threshold');

                Revolution_Setting__c revSet = new Revolution_Setting__c();
                revSet.id = settWrap.get(ICELGO_thresholdLabel).settingID;
                revSet.Value__c = ICELGO_threshold;
                
                try{
                    if(Revolution_Setting__c.sObjectType.getDescribe().isUpdateable())
                    {
                        update revSet;
                        returnMsg = 'Threshold Price has been set';
                    }
                    else
                        returnMsg = 'You are not allowed to perform this action. Please contact Administrator';
                }
                catch(Exception e)
                {
                    writeDebugLog('Error while updating Threshold '+e);
                    returnMsg = 'Something went wrong. Please contact Administrator';
                }
            }
            else
            {
                Revolution_Setting__c revSet = new Revolution_Setting__c();
                revSet.Name = ICELGO_thresholdLabel;
                revSet.Value__c = ICELGO_threshold;
                
                try{
                    if(Revolution_Setting__c.sObjectType.getDescribe().isCreateable())
                    {
                        insert revSet;
                        returnMsg = 'Threshold Price has been set';
                    }
                    else
                        returnMsg = 'You are not allowed to perform this action. Please contact Administrator.';
                }
                catch(Exception e)
                {
                    writeDebugLog('Error while updating Threshold '+e);
                    returnMsg = 'Something went wrong. Please contact Administrator';
                }
            }
        }
        
        return returnMsg;
    }
    
    public static map<String,Double> getThresholdPrice()
    {
        if(!setSettingsCalled)
            qryOLFsettings();
        
        map<String,Double> returnMap = new map<String,Double>();
        
        if(global_SettWrap.containsKey(global_ICELGO_thresholdLabel))
        {
            try{
                String icePrice = global_SettWrap.get(global_ICELGO_thresholdLabel).SettingValue;
                if(icePrice.length()>0)
                	returnMap.put(global_ICELGO_thresholdLabel,Double.valueOf(icePrice));
                else
                    returnMap.put(global_ICELGO_thresholdLabel,-999.99);
            }
            catch(Exception e) {
                writeDebugLog('Error' + e); 
                returnMap.put(global_ICELGO_thresholdLabel,-999.99); 
            }
        }
        
        return returnMap;
    }
    
    static void qryOLFsettings()
    {
        if(global_settingNames.size()>0)
        	global_SettWrap = OLF_Utility.getSettings(global_settingNames);
        System.debug(global_SettWrap);
        setSettingsCalled = true;
    }
    //ICELimit_Soumyajit_27Apr2020 ends
    
    /*Method Name : getOlfStagingRecordCount
     *Developer   : Rahul Sharma
     *Date        : 27-May-2020
     *Description : Counts and returns SAP Staging records for which 'Sent to OLF?' is 'Failed' for the given input window.
     */
    @AuraEnabled
    public static Integer getOlfStagingRecordCount(DateTime fromDateTime, DateTime toDateTime){
        try{
            return [SELECT COUNT() FROM SAP_Staging__c WHERE Sent_to_OLF__c = 'Failed' AND 
                                                               Deal_Created_Date__c >=: fromDateTime AND 
                                                               Deal_Created_Date__c <=: toDateTime];
        }
        catch(Exception e){
            System.debug('OLF_DashboardApexController >> getOlfStagingRecordCount >> Exception: '+e.getMessage()+' Line Number: '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }     
    }

    /*Method Name : retryOlfStagingRecords
     *Developer   : Rahul Sharma
     *Date        : 27-May-2020
     *Description : Resend SAP Staging records to OLF for which 'Sent to OLF?' is 'Failed' for the given input window.
     */
    @AuraEnabled
    public static Integer retryOlfStagingRecords(DateTime fromDateTime, DateTime toDateTime){
        Set<Id> shtIdSet = new Set<Id>();
        Map<String, List<OLFWrapper.olfDealWrap>> orderGrpVsDealWrapMap = new Map<String, List<OLFWrapper.olfDealWrap>>();
        if(Revolution_Setting__c.sObjectType.getDescribe().isCreateable() || Revolution_Setting__c.sObjectType.getDescribe().isUpdateable()){
            for(SAP_Staging__c stagingRec : [SELECT Id, 
                                                    SHTId__c FROM SAP_Staging__c WHERE SHTId__c != NULL AND 
                                                                                    Sent_to_OLF__c = 'Failed' AND 
                                                                                    Deal_Created_Date__c >=: fromDateTime AND 
                                                                                    Deal_Created_Date__c <=: toDateTime]){
                shtIdSet.add(stagingRec.SHTId__c);
            }
            if(!shtIdSet.isEmpty()){
                for(SHT__c shtRec : [SELECT Id,
                                            MRC__r.Load_Id__c,
                                            SAP_Contract_Number__c,
                                            OLF_Deal_Number__c FROM SHT__c WHERE Id IN : shtIdSet AND 
                                                                                        SAP_Contract_Number__c != NULL AND
                                                                                        OLF_Deal_Number__c != NULL]){
                    if(shtRec.OLF_Deal_Number__c != null){
                        String dealGroup = shtRec.OLF_Deal_Number__c.subStringBefore('-');
                        if(orderGrpVsDealWrapMap.containsKey(dealGroup)){
                            List<OLFWrapper.olfDealWrap> olfDealWrapList = orderGrpVsDealWrapMap.get(dealGroup);
                            OLFWrapper.olfDealWrap dealWrap = new OLFWrapper.olfDealWrap();
                            dealWrap.orderId = shtRec.OLF_Deal_Number__c;
                            dealWrap.vendorContractNo = shtRec.SAP_Contract_Number__c;
                            dealWrap.vendorLiftingId = shtRec.MRC__r.Load_Id__c != null ? shtRec.MRC__r.Load_Id__c : '';
                            olfDealWrapList.add(dealWrap);
                            orderGrpVsDealWrapMap.put(dealGroup, olfDealWrapList);
                        }
                        else{
                            List<OLFWrapper.olfDealWrap> olfDealWrapList = new List<OLFWrapper.olfDealWrap>();
                            OLFWrapper.olfDealWrap dealWrap = new OLFWrapper.olfDealWrap();
                            dealWrap.orderId = shtRec.OLF_Deal_Number__c;
                            dealWrap.vendorContractNo = shtRec.SAP_Contract_Number__c;
                            dealWrap.vendorLiftingId = shtRec.MRC__r.Load_Id__c != null ? shtRec.MRC__r.Load_Id__c : '';
                            olfDealWrapList.add(dealWrap);
                            orderGrpVsDealWrapMap.put(dealGroup, olfDealWrapList);
                        }
                    }
                }
                if(!orderGrpVsDealWrapMap.isEmpty()){
                    if(!Test.isRunningTest())
                        OLF_SendContractInformation.sendContractInfoToOLF(orderGrpVsDealWrapMap);
                    OLF_Callout_Setting__mdt calloutSetting = [SELECT Enable_Rerty__c,
                                                                    Max_Retry__c,
                                                                    Time_Interval_In_Minutes__c FROM OLF_Callout_Setting__mdt WHERE DeveloperName = 'OLF_SHT_Data_Push'];
                    if(calloutSetting != null){
                        Integer timeInMinutes;
                        if(calloutSetting.Enable_Rerty__c == false)
                            timeInMinutes = 0;
                        else if(calloutSetting.Max_Retry__c != null && calloutSetting.Time_Interval_In_Minutes__c != null)
                            timeInMinutes = (calloutSetting.Max_Retry__c * calloutSetting.Time_Interval_In_Minutes__c).intValue();
                        return timeInMinutes;
                    }
                    else{
                        System.debug('OLF_DashboardApexController >> retryOlfStagingRecords: OLF Callout Setting not found.');
                        return null;
                    }
                }
                else{
                    System.debug('OLF_DashboardApexController >> retryOlfStagingRecords: orderGrpVsDealWrapMap is empty.');
                    return null;
                }
            }
            else{
                System.debug('OLF_DashboardApexController >> retryOlfStagingRecords: No SHT records found on SAP Staging.');
                return null;
            }
        }   
        else{
            throw new AuraHandledException('You are not allowed to perform this action. Please contact Administrator.');
        }   
    }

    /*Method Name : updateTrancheSetting
     *Developer   : Rahul Sharma
     *Date        : 16-Oct-2020
     *Description : Update lifting window/tranche setting.
     */
    @AuraEnabled
    public static void updateTrancheSetting(String trancheSetting){
        System.debug('OLF_DashboardApexController >> updateTrancheSetting: Method starts');
        List<Revolution_Setting__c> revSettingList = new List<Revolution_Setting__c>();
        if(!String.isEmpty(trancheSetting)){
            List<OLF_Utility.settingWrapper> trancheSettingWrapList = (List<OLF_Utility.settingWrapper>)JSON.deserialize(trancheSetting, List<OLF_Utility.settingWrapper>.class);
            if(Revolution_Setting__c.sObjectType.getDescribe().isUpdateable()){
                try{
                    for(OLF_Utility.settingWrapper trancheSettingWrap : trancheSettingWrapList){
                        Revolution_Setting__c revSetting = new Revolution_Setting__c();
                        revSetting.Id = trancheSettingWrap.settingID;
                        revSetting.Active__c = trancheSettingWrap.isActive;
                        revSetting.Start_Day__c = trancheSettingWrap.startDay;
                        revSetting.End_Day__c = trancheSettingWrap.endDay;
                        revSettingList.add(revSetting);
                    }
                    update revSettingList;
                }
                catch(Exception e){
                    System.debug('OLF_DashboardApexController >> updateTrancheSetting >> Exception: '+e.getMessage()+' Line Number: '+e.getLineNumber());
                    throw new AuraHandledException(e.getMessage());
                }
            }
            else{
                throw new AuraHandledException('You are not allowed to perform this action. Please contact Administrator.');
            }
        }
        else{
            System.debug('OLF_DashboardApexController >> updateTrancheSetting: Tranche setup is null.');
        }
    }
 /* Added by Sampada.Bhat */
    public static void startAndStopOLFMrcDataSchedulers(String actionType){
        try{
            CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger where NextFireTime != null and state != 'DELETED' and CronJobDetail.name like '%ATP%Scheduler%'];
            for(CronTrigger cronT : ct){
                System.abortJob(cronT.id);
            }
            if(actionType == 'Start'){
                Datetime sysTime = System.now().addSeconds(5);
                String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                System.schedule('ATP1 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP1Scheduler());
                System.schedule('ATP2 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP2Scheduler());
                System.schedule('ATP3 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP3Scheduler());
                System.schedule('ATP4 Scheduler' +sysTime.getTime(),chronExpression, new OLF_MRCDataATP5Scheduler());
            }
        }
        catch(exception e){
            System.debug('Something exception occured');
            RV_Exception__c rvException = new RV_Exception__c(getMessage__c = 'Message: ' + e.getMessage() + ' Line: '+e.getLineNumber() + ' Trace: '+e.getStackTraceString(),Apex_Class__c = 'OLF_DashboardApexController',Method_Name__c = 'startAndStopOLFMrcDataSchedulers' );
            insert rvException;
        }
    }
     //START | Surbhi | Date 2-Aug-2022 : PBI-1366142
    @AuraEnabled
    public static OLFSchedulerResponseWrap OLFAutoInactivationScheduleJob(Datetime getOlfInactivationDttime){
        System.debug('inside OLFAutoInactivationScheduleJob ::::');
         OLFSchedulerResponseWrap wrapperRes  = new OLFSchedulerResponseWrap();
        try{           
            Datetime olfInactivationTime = null;
            //Deleting existing job 
            for(CronTrigger objOLFInactivationJob :  [SELECT ID,State,NextFireTime FROM CronTrigger WHERE CronJobDetail.name='Auto Inactivation OLF Scheduler']){
                System.abortJob(objOLFInactivationJob.ID); 
            } 
            if(getOlfInactivationDttime != null){
                System.debug('inside if condn ::::');
                olfInactivationTime = getOlfInactivationDttime;
                String chronExpression = '' + olfInactivationTime.second() + ' ' + olfInactivationTime.minute() + ' ' + olfInactivationTime.hour() + ' ' + olfInactivationTime.day() + ' ' + olfInactivationTime.month() + ' ? ' + olfInactivationTime.year();
                System.debug('chronExpression ::' +chronExpression);
                System.schedule('Auto Inactivation OLF Scheduler',chronExpression, new OLF_AutoInactivateConnection());                
                wrapperRes.returnMsg = 'OLF Connection Auto-Inactivation time has been scheduled successfully.';                   
                wrapperRes.returnDate = olfInactivationTime.format(global_returnDateFormat);              
            }
            else{
                wrapperRes.returnMsg = 'OLF Connection Auto-Inactivation time scheduler has been deleted successfully.';
            }
            System.debug('response ::::'+wrapperRes);
            return wrapperRes;            
        }
        catch(Exception ex){            
            RV_Exception__c objRvException = new RV_Exception__c();
            objRvException.RV_GetExceptionMessage__c = ex.getMessage()+'\n'+ex.getStackTraceString();
            objRvException.Apex_Class__c = 'OLF_DashboardApexController';
            objRvException.Method_Name__c = 'OLFAutoInactivationScheduleJob';
            objRvException.Type__c = 'Exception';
            insert objRvException;
            System.debug('objRvException :::' +objRvException);
            return null;
        }
    }
     //START | Surbhi | Date 2-Aug-2022 : PBI-1366142
    public class OLFSchedulerResponseWrap{       
        @AuraEnabled public String returnMsg = '';
        @AuraEnabled public String returnDate = 'NA';
        @AuraEnabled public Datetime returnDateTime = null;
        @AuraEnabled public Boolean returnDateEditPermission = false;
    }
     //END | Surbhi | Date 2-Aug-2022 : PBI-1366142
     
     //START | Surbhi | Date 2-Aug-2022 : PBI-1366142
    @AuraEnabled
    public static OLFSchedulerResponseWrap getNextFireTimeOLFSInactivateSch(){
        OLFSchedulerResponseWrap wrapperRes  = new OLFSchedulerResponseWrap();
        // Fetching next fire time of the existing scheduler of OLF Auto connection deactivation
        CronJobDetail[] cjd = [SELECT Id, name FROM CronJobDetail where Name = 'Auto Inactivation OLF Scheduler' limit 1];
        if(cjd.size()>0)
        {
            CronTrigger[] ct = [SELECT ID, NextFireTime FROM CronTrigger where CronJobDetailId = :cjd[0].id AND state != 'DELETED' limit 1];                 
            if(ct.size()>0)
            {
                wrapperRes.returnDateTime = ct[0].NextFireTime;
            }
        }
        wrapperRes.returnDateEditPermission = checkUserPermission('RV_OnlineSalesManagement');        
        return wrapperRes;      
    }
     //END | Surbhi | Date 2-Aug-2022 : PBI-1366142
     
     //START | Surbhi | Date 2-Aug-2022 : PBI-1366142
    // Generic method to check the assignee user in the permission set, just to pass only PS name as a parameter
    @AuraEnabled
    public static boolean checkUserPermission(String permissionSetName){
        boolean hasPermission = false;
        if (Schema.sObjectType.PermissionSetAssignment.isAccessible())
        {
            PermissionSetAssignment[] psa = [SELECT ID, AssigneeId, Assignee.name FROM PermissionSetAssignment WHERE PermissionSet.name =: permissionSetName Order by Assignee.name];

            if(psa.size()>0)
            {
                for (PermissionSetAssignment p : psa)
                {
                    if(p.Assignee.name.equals(UserInfo.getName())){
                        hasPermission = true;
                    }
                }
            }
        }
        system.debug('hasPermission::'+hasPermission);
        return hasPermission;
    }
    //END | Surbhi | Date 2-Aug-2022 : PBI-1366142
    
/******************************************************************************************************************
@Author | Surbhi | Date 27-Dec-2022 : 1593743
@MethodName    : getUserEmailFromPermissionSet
@PurposeMethod :  Generic method to retrieve the email address of all the assignee users from the permission set,
                  just to pass only PS name as a parameter
*******************************************************************************************************************/
    public static List<String> getUserEmailFromPermissionSet(String permissionSetName){
        List<PermissionSetAssignment> listOfPSRec = [SELECT ID, AssigneeId, Assignee.name, Assignee.Email FROM PermissionSetAssignment
                                                     WHERE PermissionSet.name =: permissionSetName AND Assignee.isActive=true  Order by Assignee.name];
        if(listOfPSRec.size() > 0){
            List<String> listOfUserEmails = new List<String>();
            for(PermissionSetAssignment psa : listOfPSRec){
                listOfUserEmails.add(psa.Assignee.Email);
            }
            return listOfUserEmails;
        }
        return null;
    }
    
/******************************************************************************************************************
@Author | Rinkita | Date 14-Dec-2022 : PBI-1616869
@MethodName : handleReadOnlyPermission
@PurposeMethod :  Display OLF Tab Read Only For Define permission set in "RV_PermissionSetList" Custom Label
*******************************************************************************************************************/
  /*  @AuraEnabled
    public static boolean handleReadOnlyPermission(){
        List<String> permissionSetList = Label.RV_PermissionSetList.split(',');
        String userId =UserInfo.getUserId();
        boolean isReadOnlyPermission = false;
        if (Schema.sObjectType.PermissionSetAssignment.isAccessible()){
            PermissionSetAssignment[] psa = [SELECT ID, AssigneeId, Assignee.name, PermissionSet.Name
                                             FROM PermissionSetAssignment
                                             WHERE AssigneeId =: userId];
            if(psa.size()>0) {
                for (PermissionSetAssignment p : psa){
                        if(p.PermissionSet.Name == 'RV_OnlineSalesManagement'){
                            isReadOnlyPermission = false;
                            break;
                        }
                        if(permissionSetList.contains(p.PermissionSet.Name)){
                            isReadOnlyPermission = true;
                        }
                }
            }
        }
        return isReadOnlyPermission;
    }  */
    

    //Wrapper Declarations starts here
    public class AccountWrap{
        @AuraEnabled
        public ID AccountID;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String SoldTo;
        @AuraEnabled
        public Decimal TotalCredit;
        @AuraEnabled
        public Decimal AvailableCredit;
        @AuraEnabled
        public Boolean AvailableForOLF;
    }
    
    public class MRCWrap{
        @AuraEnabled
        public Id MRCid;
        @AuraEnabled
        public Id SoldToId;
        @AuraEnabled
        public Id LocationId;
        @AuraEnabled
        public Id MaterialId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String SoldTo;
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String Material;
        @AuraEnabled
        public String SalesOrg;
        @AuraEnabled
        public String HandlingType;
        @AuraEnabled
        public Boolean AvailableForOLF;
    }
    
    public class OLFAccountMRCWrap{
        @AuraEnabled
        public Boolean OLFStatus;
        @AuraEnabled
        public List<AccountWrap> CustomerDetails;
        @AuraEnabled
        public List<String> MaterialList;
        @AuraEnabled
        public List<String> LocationList;
        @AuraEnabled
        public Boolean HasMRC;
        @AuraEnabled
        public List<MRCWrap> MRCDetails;
    } 
    
    public class OLFInitWrap{
        @AuraEnabled
        public Boolean OLFStatus;
        @AuraEnabled
        public String LastRequestFromOLF;
        @AuraEnabled
        public String LastResponseFromRevolution;
        @AuraEnabled
        public List<String> CustomerList;
        @AuraEnabled
        public List<AccountWrap> CustomerDetails;
        @AuraEnabled
        public Boolean HasMRC;
        //327368_Soumyajit_09Aug2019 starts
        @AuraEnabled
        public String NextInactivationBatchTime;
        //327368_Soumyajit_09Aug2019 ends
        @AuraEnabled
        public Double ICELGO_threshold;	//ICELimit_Soumyajit_27Apr2020
        @AuraEnabled
        public List<OLF_Utility.settingWrapper> trancheWrapList;
        @AuraEnabled
        public Boolean hasPermission;
    }
    //Wrapper Declarations ends here
}