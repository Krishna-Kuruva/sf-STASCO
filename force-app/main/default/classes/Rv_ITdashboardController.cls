public class Rv_ITdashboardController {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 25-Jun-2019
	Details	: Apex controller for IT Dashboard
	*/
    static final String global_returnDateFormat = 'dd.MM.yyyy HH:mm:ss';
    
    public static boolean global_errorStatus = false;
    public static List<errorWrapper> global_errorList = new List<errorWrapper>();
    public static boolean global_BatchActionAllowed = false;
    public static boolean global_BatchRunAllowed = false;
    public static boolean global_ShowRunAllButton = false;
    public static boolean global_ShowStopAllButton = false;
    public static boolean global_overrideChecks = false;
    public static DateTime global_DealLastCheckTime = System.now();
    static String global_DealLastCheckTimeSOQL = '';
    static List<String> global_BatchActionAllowedProfiles = new List<String>();
    static List<String> global_BatchActionAllowedUsers = new List<String>();
    static String global_Dashboard30secBatchName = '';
    static String  global_ShowDashboard30secBatch = '';
    static String global_DashboardName = '';
    static String globalGSAP_ProdURL = '';
    static String globalGSAP_TestURL = '';
    static String globalGSAP_ConnectLabel = '';
    static String globalBRENT_M15Label = '';
    static String globalIGO_M15Label = '';
    static String globalNYMEX_M15Label = '';
    static String globalZero_HCVLabel = '';
    public static Integer global_limitQueries = 0;
    public static boolean global_StopOLF = false;										//Fix_365305_Soumyajit_18Oct2019
    static String global_StopOLFMsg = '';												//Fix_365305_Soumyajit_18Oct2019
    static String global_StopOLFReason = '';
    
    public static final String global_DaveSectionName = 'Dave';
    public static final String global_DealSectionName = 'Deal';
    public static final String global_MRCUploadSectionName = 'MRC Upload';
    public static final String global_LiveSectionName = 'Price';
    public static final String global_BatchSectionName = 'Batch';
    public static final String global_DailyCheckSectionName = 'Daily Check';	//Fix_301484_26Dec2019_Soumyajit
    
    static boolean setMDTCalled = false;
    @TestVisible
    static void setGlobalVarFromMDT()
    {
        map<String,String> mdtMap = new map<String,String>();
        
        IT_Dashboard_Setting__mdt[] setMDT = [select id, label,developername, value__c from IT_Dashboard_Setting__mdt];
        for(IT_Dashboard_Setting__mdt s : setMDT)
        	mdtMap.put(s.developername, s.Value__c);
        
        if(mdtMap.containsKey('BatchActionAllowedProfiles'))
        {
            try{global_BatchActionAllowedProfiles = mdtMap.get('BatchActionAllowedProfiles').split(';');}catch(Exception e){}
        }
        if(mdtMap.containsKey('BatchActionAllowedUsers'))
        {
            try{global_BatchActionAllowedUsers = mdtMap.get('BatchActionAllowedUsers').split(';');}catch(Exception e){}
        }
        global_Dashboard30secBatchName = mdtMap.containsKey('Dashboard30secBatchName') ? mdtMap.get('Dashboard30secBatchName') : '';
        global_ShowDashboard30secBatch = mdtMap.containsKey('ShowDashboard30secBatch') ? mdtMap.get('ShowDashboard30secBatch') : 'FALSE';
        global_DashboardName = mdtMap.containsKey('DashboardName') ? mdtMap.get('DashboardName') : 'IT Dashboard';
        global_DealLastCheckTimeSOQL = mdtMap.containsKey('DealLastCheckTimeSOQL') ? mdtMap.get('DealLastCheckTimeSOQL') : '';
        global_StopOLFMsg = mdtMap.containsKey('OLF_StopMessage') ? mdtMap.get('OLF_StopMessage') : '';
        globalGSAP_ProdURL = mdtMap.containsKey('GSAP_ProdURL') ? mdtMap.get('GSAP_ProdURL') : 'UNDEFINED';
        globalGSAP_TestURL = mdtMap.containsKey('GSAP_TestURL') ? mdtMap.get('GSAP_TestURL') : 'UNDEFINED';
        globalGSAP_ConnectLabel = mdtMap.containsKey('GSAP_Connect_MDT') ? mdtMap.get('GSAP_Connect_MDT') : '';
        globalBRENT_M15Label = mdtMap.containsKey('BRENT_M15_MDT') ? mdtMap.get('BRENT_M15_MDT') : '';
        globalIGO_M15Label = mdtMap.containsKey('IGO_M15_MDT') ? mdtMap.get('IGO_M15_MDT') : '';
        globalNYMEX_M15Label = mdtMap.containsKey('NYMEX_M15_MDT') ? mdtMap.get('NYMEX_M15_MDT') : '';
        globalZero_HCVLabel = mdtMap.containsKey('Zero_HCV_MDT') ? mdtMap.get('Zero_HCV_MDT') : '';
        setMDTCalled = true;
    }
    
    public static void checkBatchActionUser(){
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<String> UsernameLst = new List<String>();
        Id loggedInUsrID = System.UserInfo.getUserId();
        Id loggedInProfileID = System.UserInfo.getProfileId();
        String loggedInUsrName = System.UserInfo.getUserName();
        
        Profile profileDetail = [select id,name from profile where id = :loggedInProfileID limit 1];
        
        if(global_BatchActionAllowedProfiles.contains(profileDetail.name))
            global_BatchActionAllowed = true;
        else
            global_BatchActionAllowed = false;
        
        if(global_BatchActionAllowed)
        {
            try
            {
                List<String> usr=global_BatchActionAllowedUsers;
                Id checkUsrID;
                 
                for(String u : usr)
                {
                    if(u.length()>0 && u.equals(loggedInUsrName))
                    {
                        checkUsrID = loggedInUsrID;
                        break;
                    }
                }
                 
                 if(checkUsrID != null)
                     global_BatchRunAllowed = true;
                 else
                     global_BatchRunAllowed = false;
             }catch(Exception e){
                             //system.debug('Error while finding usernames:'+e);
                 			 global_BatchRunAllowed = false;
                        }
        }
        
        if(global_overrideChecks)
        {
            global_BatchActionAllowed = true;
            global_BatchRunAllowed = true;
        }
    }
    
    public static Boolean checkGovenorLimits(String fnName)
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        
        Boolean returnVar = false;
        Integer buffer = 1000;
        
        global_limitQueries += Limits.getQueries();
        
        if(global_limitQueries >= Limits.getLimitQueries() + buffer)
        {
            //System.debug('Limit Error in '+ fnName + ' with limit = '+ global_limitQueries);
            returnVar = true;
        }
        else
            returnVar = false;
        
        return returnVar;
    }
    
    public static void setDealLastCheckTime()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        try
        {
            if(!checkGovenorLimits('setDealLastCheckTime'))
            {
                AggregateResult[] result = Database.query(global_DealLastCheckTimeSOQL);
                if(result.size()>0)
                {
                    if(result[0].get('rslt') != null)
                    {
                        global_DealLastCheckTime = DateTime.valueof(result[0].get('rslt'));
                    }
                }
            }
        }
        catch(system.nullpointerexception e)
        {
        	//System.debug('Query for global_DealLastCheckTimeSOQL returns no result');
        }
        catch(Exception e)
        {
			//System.debug('Error in setDealLastCheckTime '+e);
        }
    }
    
    @AuraEnabled
    public static pageWrapper getAllData()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        pageWrapper returnPageWrapper = new pageWrapper();
        
        setDealLastCheckTime();
        checkBatchActionUser();
        
        if(!global_errorList.isEmpty())
            global_errorList.clear();
        
        returnPageWrapper = setSectionLabels (returnPageWrapper);
        
        returnPageWrapper.BatchData = getBatchDetails();
        returnPageWrapper.DealData =  getDealDetails();
        returnPageWrapper.PriceData = getPriceDetails();
        returnPageWrapper.DaveData = getDaveDetails();
        returnPageWrapper.MRCUploadData = getMRCUploadDetails();
        returnPageWrapper.DailyCheckData =  getDailyCheckDetails(); //Fix_301484_26Dec2019_Soumyajit
        
        returnPageWrapper.ErrorStatus = global_errorStatus;
        returnPageWrapper.ErrorList = global_errorList;
        returnPageWrapper.BatchActionAllowed = global_BatchActionAllowed;
        returnPageWrapper.StopOLF = global_StopOLF;	//Fix_365305_Soumyajit_18Oct2019
        returnPageWrapper.StopOLFReason = global_StopOLFReason;
        returnPageWrapper.RunRefreshAllowed = Rv_PrepareSandbox.checkPageAccess();
        returnPageWrapper.ShowRunAllButton = global_ShowRunAllButton;
        returnPageWrapper.ShowStopAllButton = global_ShowStopAllButton;
            
        updateAlertSettings(global_errorList);
            
        return returnPageWrapper;                                               
    } 
    
    @AuraEnabled
    public static List<dealWrapper> getDealDetails()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<dealWrapper> returnDealWrapper = new List<dealWrapper>();
        List<IT_Dashboard_Controller__mdt> displayLabelLst = getControllerMdt(global_DealSectionName,'THIS');
        
        if(displayLabelLst.size()>0)
        {
            for(IT_Dashboard_Controller__mdt mdt : displayLabelLst)
            {
                dealWrapper dw = new dealWrapper();
                    
                dw.DisplaySequence = mdt.Display_Order__c;
                dw.DisplayLabel = mdt.Display_Label__c;
                dw.DisplayValue = '';
                
                if(mdt.Controller_Value_Return_Type__c.equals('DateTime'))
                    dw.DisplayValue = '-';
                if(mdt.Controller_Value_Return_Type__c.equals('Integer'))
                    dw.DisplayValue = '0';
                
                dw.SendAlert = false;
                
                if (mdt.Controller_Value__c.length()>0)
                {
                    try{
                        if(!checkGovenorLimits('getDealDetails'))
                        {
                            AggregateResult[] result = Database.query(mdt.Controller_Value__c);
                            
                            if(result.size()>0)
                            {
                                if(result[0].get('rslt') != null)
                                {
                                    if(mdt.Controller_Value_Return_Type__c.equals('DateTime'))
                                        dw.DisplayValue = DateTime.valueof(result[0].get('rslt')).format(global_returnDateFormat);
                                    else
                                        dw.DisplayValue = String.valueof(result[0].get('rslt'));
                                    
                                    if(mdt.Alert_Needed__c)
                                        dw.SendAlert = setAlert(mdt, result[0].get('rslt'), mdt.Display_Label__c + ' = ' + dw.DisplayValue);
                                }
                            }
                        }
                        
                    }
                        catch(system.nullpointerexception e)
                        {
                            //System.debug('Query for ' + mdt.Display_Label__c + ' returns no result');
                        }
                        catch(Exception e)
                            {
                                setAlert(mdt.Section_Name__c, 
                                         mdt.Display_Label__c, 
                                         'Error while execution '+ mdt.Controller_Value__c + ' soql' + e.getMessage(),
                                        true,
                                        //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                        false,
                                        null);
                                        //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                            }
                }
                
                if(!mdt.Invisible_on_Dashboard__c)
                	returnDealWrapper.add(dw);
            }
        }
        
        return returnDealWrapper;
    }
    
    @AuraEnabled
    public static List<daveWrapper> getDaveDetails()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<daveWrapper> returnDaveWrapper = new List<daveWrapper>();
        Map<String,daveWrapper> mapDaveWrapper = new Map<String,daveWrapper>();
        List<IT_Dashboard_Controller__mdt> displayLabelLst = getControllerMdt(global_DaveSectionName,'THIS');
            
        if(displayLabelLst.size()>0)
        {
            List<String> productLst = new List<String>();
            
            for(IT_Dashboard_Controller__mdt mdt : displayLabelLst)
            {
                if(!mdt.Invisible_on_Dashboard__c){
                    daveWrapper dw = new daveWrapper();
                        
                    dw.DisplaySequence = mdt.Display_Order__c;
                    dw.DisplayLabel = mdt.Display_Label__c;
                    dw.Hedge = 0;
                    dw.LastUpdateTime ='-';
                    
                    if(mdt.Controller_Value__c.length()>0)
                    {
                        mapDaveWrapper.put(mdt.Controller_Value__c,dw);
                        productLst.add(mdt.Controller_Value__c);
                    }
                }
            }
            
            if(productLst.size()>0)
            {
                if(!checkGovenorLimits('getDaveDetails'))
                {
                AggregateResult[] hedgeLot = [SELECT Product_Name__c, sum(Hedge__c)hedgeLot 
                                              FROM SHT_Dave__c 
                                              where lastmodifieddate=today and Product_Name__c in :productLst and Hedge__c != null and Transactions__c = 'Hedge'
                                              group by Product_Name__c];
                
                for(AggregateResult hl : hedgeLot)
                {
                    if(mapDaveWrapper.containskey(String.valueof(hl.get('Product_Name__c'))) && hl.get('hedgeLot') !=null)
                        mapDaveWrapper.get(String.valueof(hl.get('Product_Name__c'))).Hedge = Integer.valueof(hl.get('hedgeLot'));
                }
                
                AggregateResult[] hedgeTime = [SELECT Product_Name__c, max(Hedging_Date__c)hedgeTime 
                                               FROM SHT_Dave__c 
                                               where lastmodifieddate=today and Product_Name__c in :productLst and Hedge__c != null and Transactions__c = 'Hedge'
                                               group by Product_Name__c];
                
                for(AggregateResult hl : hedgeTime)
                {
                    if(mapDaveWrapper.containskey(String.valueof(hl.get('Product_Name__c'))) && hl.get('hedgeTime') !=null)
                        mapDaveWrapper.get(String.valueof(hl.get('Product_Name__c'))).LastUpdateTime = DateTime.valueof(hl.get('hedgeTime')).format(global_returnDateFormat);
                }
                    
                returnDaveWrapper.addAll(mapDaveWrapper.values());
                }
            }
        }
        
        return returnDaveWrapper;
    }
    
    @AuraEnabled
    public static List<priceWrapper> getPriceDetails()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<priceWrapper> returnPriceWrapper = new List<priceWrapper>();
        List<IT_Dashboard_Controller__mdt> displayLabelLst = getControllerMdt(global_LiveSectionName,'THIS');
        
        if(displayLabelLst.size()>0)
        {
            for(IT_Dashboard_Controller__mdt mdt : displayLabelLst)
            {
                priceWrapper pw = new priceWrapper();
                    
                pw.DisplaySequence = mdt.Display_Order__c;
                pw.DisplayLabel = mdt.Display_Label__c;
                pw.LastUpdateTime = '-';
                pw.SendAlert = false;
                
                if (mdt.Controller_Value__c.length()>0)
                {
                    try{
                        if(!checkGovenorLimits('getPriceDetails'))
                		{
                        AggregateResult[] result = Database.query(mdt.Controller_Value__c);
                        
                        if(result.size()>0)
                        {
                            if(result[0].get('rslt') != null && mdt.Controller_Value_Return_Type__c.equals('DateTime'))
                            	pw.LastUpdateTime = DateTime.valueof(result[0].get('rslt')).format(global_returnDateFormat);
                            
                            if(mdt.Alert_Needed__c)
                                pw.SendAlert = setAlert(mdt, result[0].get('rslt'), ' Last updated at ' + pw.LastUpdateTime);
                                
                        }
                        }
                        
                    }
                    catch(system.nullpointerexception e)
                        {
                            //System.debug('Query for ' + mdt.Display_Label__c + ' returns no result');
                        }
                    catch(Exception e)
                            {
                            	setAlert(mdt.Section_Name__c, 
                                         mdt.Display_Label__c,
                                         'Error while execution '+ mdt.Controller_Value__c + ' soql' + e.getMessage(),
                                        true,
                                        //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                        false,
                                        null);
                                        //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                            }
                }
                
                if(!mdt.Invisible_on_Dashboard__c)
                	returnPriceWrapper.add(pw);
            }
        }
        
        return returnPriceWrapper;
    }
    
    public static Boolean setAlert (IT_Dashboard_Controller__mdt mdt, Object checkValue, String extraErrorMsg)
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        Boolean hasError = false;
        Boolean returnValue = false;
        DateTime tday = System.now();
        Integer tdayOfWeek = Integer.valueof(tday.format('u'));
        DateTime yesterday;
        
        if(tdayOfWeek != 1)
            yesterday = System.now().addDays(-1);
        else
            yesterday = System.now().addDays(-3);
        
        if(mdt.Alert_Needed__c && ((tdayOfWeek != 6 && tdayOfWeek != 7 && !mdt.Alert_on_Weekend__c) || global_overrideChecks) )
        {
            if(mdt.Controller_Value_Return_Type__c.equals('DateTime'))
            {
                DateTime checkValueDateTime = DateTime.valueof(checkValue);
                //START - Rahul Sharma | Date : 02-Jul-20 : Added logic for test coverage
                if(Test.isRunningTest())
                    checkValueDateTime = checkValueDateTime.addMinutes(-(Integer.valueOf(mdt.Alert_Interval__c) + 1));
                //END - Rahul Sharma | Date : 02-Jul-20 : Added logic for test coverage
        		if(mdt.Alert_Interval__c != null)
                {   
                	if(tday >= checkValueDateTime.addMinutes(Integer.valueOf(mdt.Alert_Interval__c)))
                    {                  
                        if (mdt.Alert_Time__c != null)
                        {
                        	if(mdt.Alert_Time__c.equals('NA'))
                            	hasError = true;
                            else if(!mdt.Alert_Time__c.equals('NA'))
                            {  
                                DateTime checkYesterday = DateTime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), Integer.valueOf(mdt.Alert_Time__c), 0, 0);
                               	DateTime checkToday = DateTime.newInstance(tday.year(), tday.month(), tday.day(), Integer.valueOf(mdt.Alert_Time__c), 0, 0).addMinutes(Integer.valueOf(mdt.Alert_Interval__c));

                                if(checkValueDateTime >= checkYesterday)
                                {
                                	if(checkValueDateTime < checkToday)
                                    	hasError = false;
                                    else
                                        hasError = true;
                                }
                                    else
                                        hasError = true;
                             }
                             else
                             	hasError = false;
                        }
                    }
                }
            }
            else if (mdt.Controller_Value_Return_Type__c.equals('Integer'))
            {
                Integer checkValueInteger = Integer.valueof(checkValue);
                
                if(mdt.Alert_Value_Reverse_Check__c)
                {
                     if(checkValueInteger <= Integer.valueOf(mdt.Alert_Value__c))
                     {
                         hasError = true;
                     }
                }
                else
                {
                    if(checkValueInteger > Integer.valueOf(mdt.Alert_Value__c))
                    {
                        if(mdt.Section_Name__c.equals(global_DealSectionName))
                        {  
                            if(tday <= global_DealLastCheckTime.addMinutes(Integer.valueOf(mdt.Alert_Interval__c)))
                                hasError = false;
                            else
                                hasError = true;
                        }
                        else
                            hasError = true;
                    }
                }
            }
        }
        
        //Fix_365305_Soumyajit_18Oct2019 starts
        if(hasError)
        {
            String errMsg;
            if(mdt.StopOLF__c)
            {
                global_StopOLFReason += mdt.Alert_Message__c + '; ' + extraErrorMsg +';';
                errMsg = mdt.Alert_Message__c + '; ' + extraErrorMsg + '; ' + global_StopOLFMsg;
                if(!global_StopOLF)
                    global_StopOLF = true;
            }
            else
                errMsg = mdt.Alert_Message__c + '; ' + extraErrorMsg;
            //START - Rahul Sharma | Date - 26-Jun-20 : Added logic to disable alert for specified time window in metadata
            Boolean alertValid = checkAlertValidity(mdt.Alert_Disable_Start_Time__c, mdt.Alert_Disable_End_Time__c, mdt.Time_Zone__c);
            if(alertValid){
                //START - Rahul Sharma | Date - 01-Jul-20 : Added mdt.Repeat_Alert__c, mdt.Repeat_Alert_Frequency__c parameters
                if(mdt.Repeat_Alert__c && mdt.Repeat_Alert_Frequency__c != null && Integer.valueOf(mdt.Repeat_Alert_Frequency__c) != 0){
                    Integer alertIntervalInMin = Integer.valueOf(mdt.Repeat_Alert_Frequency__c);
                    returnValue = setAlert(mdt.Section_Name__c, mdt.Display_Label__c, errMsg, mdt.Save_Error__c, mdt.Repeat_Alert__c, Integer.valueOf(mdt.Repeat_Alert_Frequency__c));
                }
                else
                returnValue = setAlert(mdt.Section_Name__c, mdt.Display_Label__c, errMsg, mdt.Save_Error__c, false, null);
                //END - Rahul Sharma | Date - 01-Jul-20 : Added mdt.Repeat_Alert__c, mdt.Repeat_Alert_Frequency__c parameters
            }
            //END - Rahul Sharma | Date - 26-Jun-20 : Added logic to disable alert for specified time window in metadata
        }  
        //Fix_365305_Soumyajit_18Oct2019 ends
        
        return returnValue;
    }
    
    //START - Rahul Sharma | Date - 01-Jul-20 : Updated method to include repeatAlert and alertIntervalInMin parameters as input and also included in errorWrapper.
    public static Boolean setAlert ( String SectionName
                             		,String DisplayLabel
                             		,String ErrorMsg
                                    ,Boolean saveError
                                    ,Boolean repeatAlert
                                    ,Integer alertIntervalInMin)
    {
        Boolean returnValue = false;
        errorWrapper ew = new errorWrapper();
        
        if(!global_errorStatus)
        	global_errorStatus = true;
        
        ew.SectionName = SectionName;
        ew.DisplayLabel = DisplayLabel;
        ew.ErrorMsg = ErrorMsg;
        ew.NotificationSent = false;
        ew.CheckTime = System.now();
        ew.saveError = saveError;
        ew.repeatAlert = repeatAlert;
        ew.alertIntervalInMin = alertIntervalInMin;
    //END - Rahul Sharma | Date - 01-Jul-20 : Updated method to include repeatAlert and alertIntervalInMin parameters as input and also included in errorWrapper.
        
        global_errorList.add(ew); 
        returnValue = true;
        
        return returnValue;
    }
    
    @AuraEnabled
    public static List<mrcUploadWrapper> getMRCUploadDetails()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<mrcUploadWrapper> returnMRCUploadWrapper = new List<mrcUploadWrapper>();
        List<IT_Dashboard_Controller__mdt> displayLabelLst = getControllerMdt(global_MRCUploadSectionName,'THIS');
        // Dharmendra : PBI 702439 Starts
        if(displayLabelLst.size()>0)
        {
            for(IT_Dashboard_Controller__mdt mdt : displayLabelLst)
            {
                mrcUploadWrapper mw = new mrcUploadWrapper();
                
                mw.DisplaySequence = mdt.Display_Order__c;
                mw.DisplayLabel = mdt.Display_Label__c;
                mw.DisplayValue = '';
                    
                    if (mdt.Controller_Value__c.length()>0)
                    {
                        try{
                        if(!checkGovenorLimits('getDealDetails'))
                        {
                            AggregateResult[] result = Database.query(mdt.Controller_Value__c);
                            
                            if(result.size()>0)
                            {
                                if(result[0].get('rslt') != null)
                                {
                                    if(mdt.Controller_Value_Return_Type__c.equals('DateTime'))
                                        mw.DisplayValue = DateTime.valueof(result[0].get('rslt')).format(global_returnDateFormat);
                                    else
                                        mw.DisplayValue = String.valueof(result[0].get('rslt'));
                                    
                                    if(mdt.Alert_Needed__c)
                                        mw.SendAlert = setAlert(mdt, result[0].get('rslt'), mdt.Display_Label__c + ' = ' + mw.DisplayValue);
                                }
                            }
                        }
                        
                    }
                        // Dharmendra : PBI 702439 Ends
                        catch(system.nullpointerexception e)
                        {
                            //System.debug('Query for ' + mdt.Display_Label__c + ' returns no result');
                        }
                        Catch (Exception e)
                        {
                            //System.debug('Error while executing');
                        }
                    }
            
                if(!mdt.Invisible_on_Dashboard__c)
                	returnMRCUploadWrapper.add(mw);
            }
        }
        
        return returnMRCUploadWrapper;
    }
    
    public static PageWrapper setSectionLabels (PageWrapper returnPageWrapper)
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        Map<String,String> sectionLabels = new Map<String,String>();
        
        returnPageWrapper.PageName = global_DashboardName;
        returnPageWrapper.DaveSectionName = global_DaveSectionName;
        returnPageWrapper.DealSectionName = global_DealSectionName;
        returnPageWrapper.MRCUploadSectionName = global_MRCUploadSectionName;
        returnPageWrapper.LiveSectionName = global_LiveSectionName;
        returnPageWrapper.BatchSectionName = global_BatchSectionName;
        returnPageWrapper.DailyCheckSectionName = global_DailyCheckSectionName;	//Fix_301484_26Dec2019_Soumyajit
        
        Schema.DescribeFieldResult field = IT_Dashboard_Controller__mdt.Section_Name__c.getDescribe();
        for (Schema.PicklistEntry f : field.getPicklistValues())
        	sectionLabels.put(f.getValue(), f.getLabel());
        
        if(sectionLabels.containsKey(global_DaveSectionName))
        	returnPageWrapper.DaveSectionName = sectionLabels.get(global_DaveSectionName);
        if(sectionLabels.containsKey(global_DealSectionName))
        	returnPageWrapper.DealSectionName = sectionLabels.get(global_DealSectionName);
        if(sectionLabels.containsKey(global_MRCUploadSectionName))
        	returnPageWrapper.MRCUploadSectionName = sectionLabels.get(global_MRCUploadSectionName);
        if(sectionLabels.containsKey(global_LiveSectionName))
        	returnPageWrapper.LiveSectionName = sectionLabels.get(global_LiveSectionName);
        if(sectionLabels.containsKey(global_BatchSectionName))
        	returnPageWrapper.BatchSectionName = sectionLabels.get(global_BatchSectionName);
        if(sectionLabels.containsKey(global_DailyCheckSectionName))
        	returnPageWrapper.DailyCheckSectionName = sectionLabels.get(global_DailyCheckSectionName);	//Fix_301484_26Dec2019_Soumyajit

        return returnPageWrapper;
    }
    
    static List<IT_Dashboard_Controller__mdt> getControllerMdt(
        											String SectionName, //Pass the Section name, if need to filter
                                                	String SearchType   // ALL : returns all mdt, THIS : returns mdt matching SectionName
    											 )
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<IT_Dashboard_Controller__mdt> returnMdt = new List<IT_Dashboard_Controller__mdt>();
        String searchQry = 'select 	DeveloperName, Section_Name__c,Display_Order__c,Display_Label__c'
                           +',Controller_Value__c,Controller_Value_Return_Type__c'
                           +',Alert_Needed__c,Alert_Interval__c,Alert_Time__c,Alert_Value__c,Alert_Message__c '
            			   +',Invisible_on_Dashboard__c, Alert_on_Weekend__c, Save_Error__c'
            			   +',StopOLF__c' //Fix_365305_Soumyajit_18Oct2019
                           +',Alert_Value_Reverse_Check__c'	//Fix_301484_26Dec2019_Soumyajit
                           +', Alert_Disable_Start_Time__c, Alert_Disable_End_Time__c, Time_Zone__c'    //Rahul Sharma | Date - 25-Jun-20 : Added new fields.
                           +', Repeat_Alert__c, Repeat_Alert_Frequency__c'  //Rahul Sharma | Date - 01-Jul-20 : Added new fields.
                           +' from IT_Dashboard_Controller__mdt';
        
        if(SearchType.length()==0)
                SearchType = 'ALL';
        
        if(SearchType.toUpperCase().equals('THIS'))
            searchQry = searchQry + ' where Section_Name__c= :SectionName';
        
        searchQry = searchQry + ' order by Display_Order__c';
        
        try{
            returnMdt = Database.query(searchQry); 
        }
        catch(Exception e)
        {
        	setAlert(SectionName, 
                     SearchType,
                     e.getMessage()
                    ,true
                    //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                    ,false
                    ,null);
                    //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
        }
        
        return returnMdt;
    }
    
    @TestVisible
    static List<Revolution_Batch__mdt> getBatchMdt(
        											String BatchName, //Pass the batch name, if need to filter
                                                	String SearchType   // ALL : returns all mdt, THIS : returns mdt matching BatchName
    											 )
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<Revolution_Batch__mdt> returnMdt = new List<Revolution_Batch__mdt>();
        String searchQryBase = 'select 	IT_Dashboard_Label__c,IT_Dashboard_Display_Order__c,Batch_Name__c'
                           +',Parent_Class_Name__c,Parent_Class_Type__c,Adhoc_Run_Allowed__c,MasterLabel,Related_MasterLabel__c '
                           +',Schedulable_Class_Name__c,Schedule_Expression__c,Alert_Needed__c,Invisible_on_Dashboard__c,Only_Adhoc_Run_Allowed__c '
                           +' from Revolution_Batch__mdt';
        String searchQry = searchQryBase;
        
        if(SearchType.length()==0)
                SearchType = 'ALL';
        
        if(SearchType.toUpperCase().equals('THIS'))
            searchQry = searchQry + ' where Batch_Name__c= :BatchName';
        else
            searchQry = searchQry + ' order by IT_Dashboard_Display_Order__c';
        
        try{
            returnMdt = Database.query(searchQry); 
        }
        catch(Exception e)
        {
            setAlert(global_BatchSectionName 
                     ,SearchType
                     ,e.getMessage()
                     ,true
                     //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                     ,false
                     ,null);
                    //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
        }
        
        if(SearchType.toUpperCase().equals('THIS') && returnMdt.size()>0)
        {
            String relatedLabel = returnMdt[0].MasterLabel;
            searchQry = searchQryBase + ' where Related_MasterLabel__c= :relatedLabel';
            
            List<Revolution_Batch__mdt> additionalReturnMdt = new List<Revolution_Batch__mdt>();
            
            try{
                additionalReturnMdt = Database.query(searchQry); 
            }
            catch(Exception e)
            {
                setAlert(global_BatchSectionName, 
                         SearchType,
                         e.getMessage()
                        ,true
                        //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                        ,false
                        ,null);
                        //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
            }
            
            if(additionalReturnMdt.size()>0)
                returnMdt.addall(additionalReturnMdt);
        }
        
        return returnMdt;
    }
    
    @AuraEnabled
    public static List<batchWrapper> getBatchDetails()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<batchWrapper> returnBatchWrapper = new List<batchWrapper>();
        List<batchWrapper> tempBatchWrapper = new List<batchWrapper>();
        List<Revolution_Batch__mdt> batches = getBatchMdt('','ALL');
        Map<String,DateTime> batchNextFireTime = new map<String,DateTime>();
        Decimal currentDisplaySequence = 0;
        
        if(batches.size()>0)
        {
            List<String> jobNames = new List<String>();
            
            for (Revolution_Batch__mdt rb : batches)
            {
                batchWrapper bw = new batchWrapper();
                bw.BatchName = rb.Batch_Name__c;
                bw.DisplaySequence = rb.IT_Dashboard_Display_Order__c;
                bw.DisplayLabel = rb.IT_Dashboard_Label__c;
                bw.ParentClassName = rb.Parent_Class_Name__c;
                bw.ParentClassType = rb.Parent_Class_Type__c;
                bw.AdhocRunAllowed = rb.Adhoc_Run_Allowed__c;
                bw.SchedulableClassName = rb.Schedulable_Class_Name__c;
                bw.ScheduleTime = rb.Schedule_Expression__c;
                bw.NextRunTime = '-';
                bw.Status = 'NA';
                bw.SendAlert = false;
                bw.AlertNeeded = rb.Alert_Needed__c;
                bw.InvisibleOnDashboard = rb.Invisible_on_Dashboard__c;
                bw.MasterLabel = rb.MasterLabel;
                bw.RelatedMasterLabel = rb.Related_MasterLabel__c;
                bw.OnlyAdhocRunAllowed = rb.Only_Adhoc_Run_Allowed__c;
                
                if(currentDisplaySequence < bw.DisplaySequence)
                	currentDisplaySequence = bw.DisplaySequence;
                
                jobNames.add(rb.Batch_Name__c);
                tempBatchWrapper.add(bw);
            }
            
            if(jobNames.size()>0)
            {
                CronJobDetail[] cjd = [SELECT Id, name FROM CronJobDetail where name in :jobNames];
                if(cjd.size()>0)
                {
                    map<id,String> cjdMapIdName = new map<id,String>();
                    map<String,id> cjdMapNameId = new map<String,id>();
                    map<id,CronTrigger> ctMap = new map<id,CronTrigger>();
                    
                    for(CronJobDetail cj : cjd)
					{
                        cjdMapIdName.put(cj.id, cj.name);
                        cjdMapNameId.put(cj.name, cj.id);
                    }
                    
                    CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger where CronJobDetailId in :cjdMapIdName.keyset() and state != 'DELETED'];
                    if(ct.size()>0)
                    {
                        for(CronTrigger c : ct)
                            ctMap.put(c.CronJobDetailId, c);
                    }
                    
                    for(batchWrapper bw : tempBatchWrapper)
                    {
                        if(cjdMapNameId.containsKey(bw.BatchName))
                        {
                            if(ctMap.containsKey(cjdMapNameId.get(bw.BatchName)))
                            {
                                bw.BatchID = ctMap.get(cjdMapNameId.get(bw.BatchName)).id;
                                if(ctMap.get(cjdMapNameId.get(bw.BatchName)).NextFireTime !=null)
                                {
                                    bw.NextRunTime = ctMap.get(cjdMapNameId.get(bw.BatchName)).NextFireTime.format(global_returnDateFormat);
                                    
                                    if(bw.RelatedMasterLabel != null)
                                    {
                                        if(batchNextFireTime.containskey(bw.RelatedMasterLabel))
                                        {
                                            if(batchNextFireTime.get(bw.RelatedMasterLabel)>ctMap.get(cjdMapNameId.get(bw.BatchName)).NextFireTime)
                                            {
                                                batchNextFireTime.remove(bw.RelatedMasterLabel);
                                            	batchNextFireTime.put(bw.RelatedMasterLabel, ctMap.get(cjdMapNameId.get(bw.BatchName)).NextFireTime);
                                            }
                                        }
                                        else
                                        	batchNextFireTime.put(bw.MasterLabel, ctMap.get(cjdMapNameId.get(bw.BatchName)).NextFireTime);    
                                    }
                                    else
                                        batchNextFireTime.put(bw.MasterLabel, ctMap.get(cjdMapNameId.get(bw.BatchName)).NextFireTime);
                                }

                                switch on ctMap.get(cjdMapNameId.get(bw.BatchName)).State
                                {
                                    when 'WAITING' {
                                        bw.Status = 'SUCCESS';
                                    }
                                    when 'ACQUIRED' {
                                        bw.Status = 'EXECUTING';
                                    }
                                    when 'EXECUTING' {
                                        bw.Status = 'EXECUTING';
                                    }
                                    when 'DELETED' {
                                        bw.Status = 'EXECUTING';
                                    }
                                    when 'COMPLETE' {
                                        bw.Status = 'SUCCESS';
                                    }
                                    when 'ERROR' {
                                        bw.Status = 'ERROR';
                                        if(bw.AlertNeeded)
                                        	bw.SendAlert = setAlert(global_BatchSectionName,
                                                                    bw.DisplayLabel,
                                                                    'Batch status of \'' + bw.DisplayLabel + '\' = ' + bw.Status
                                                                   ,true
                                                                   //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                                                   ,false
                                                                   ,null);
                                                                   //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                    }
                                }
                            }
                        }
                        else
                        {
                            if(bw.AlertNeeded)
                            	bw.SendAlert = setAlert(global_BatchSectionName,
                                                        bw.DisplayLabel,
                                                        'Batch status of \'' + bw.DisplayLabel + '\' = STOPPED',
                                                        true,
                                                       //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                                       false,
                                                       null);
                                                       //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                        }
                    }
                }
                else
                {
                    for(batchWrapper bw : tempBatchWrapper)
                    {
                        if(bw.AlertNeeded)
                            	bw.SendAlert = setAlert(global_BatchSectionName,
                                                        bw.DisplayLabel,
                                                        'Batch status of \'' + bw.DisplayLabel + '\' = STOPPED'
                                                       ,true
                                                       //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                                       ,false,
                                                       null);
                                                       //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                    }
                }
                
            }
            
            
        }
        
        Integer RunningBatchCnt = 0;
        for(batchWrapper bw : tempBatchWrapper)
        {
            if(batchNextFireTime.containskey(bw.MasterLabel))
                bw.NextRunTime = batchNextFireTime.get(bw.MasterLabel).format(global_returnDateFormat);
            
            if(bw.status.equalsIgnoreCase('EXECUTING') || bw.Status.equalsIgnoreCase('SUCCESS'))
                RunningBatchCnt ++;
        }
        
        if(RunningBatchCnt > 0)
        {
            if(RunningBatchCnt == tempBatchWrapper.size())
            	global_ShowRunAllButton = true;
            else
                global_ShowRunAllButton = false;
            global_ShowStopAllButton = false;
        }
        else
        {
            global_ShowRunAllButton = false;
            global_ShowStopAllButton = true;
        }
        
        //Dashboard Scheduler starts
        Boolean showDashboardExcutionBatch = false;
        if(global_ShowDashboard30secBatch.toUpperCase().equals('TRUE'))
            showDashboardExcutionBatch = true;
        String DashboardExcutionBatchName = global_Dashboard30secBatchName;
        
        if(showDashboardExcutionBatch || global_overrideChecks)
        {
            batchWrapper bw = new batchWrapper();
            bw.BatchName = DashboardExcutionBatchName;
            bw.DisplaySequence = Math.round(currentDisplaySequence) + 1;
            bw.DisplayLabel = DashboardExcutionBatchName;
            bw.ParentClassName = 'RV_DI_DashboardBatch';
            bw.ParentClassType = 'Batchable';
            bw.AdhocRunAllowed = false;
            bw.SchedulableClassName = 'RV_DI_DashboardScheduler';
            bw.ScheduleTime = '0 0 * * * ';
            bw.NextRunTime = '-';
            bw.Status = 'NA';
            bw.SendAlert = false;
            bw.AlertNeeded = false;
            bw.InvisibleOnDashboard = false;
            bw.MasterLabel = DashboardExcutionBatchName;
            bw.OnlyAdhocRunAllowed = false;
            bw.isDashboard30secBatch = true;
            
            String qryBatchName = '%' + DashboardExcutionBatchName + '%';
                
            CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger 
                                where CronJobDetail.name like :qryBatchName and state != 'DELETED'];

            if(ct.size()>0)
            {
                if(ct[0].NextFireTime != null)
                {
                    bw.Status = 'EXECUTING';
                    bw.NextRunTime = ct[0].NextFireTime.format(global_returnDateFormat);
                }
            }
            tempBatchWrapper.add(bw);
        }
        //Dashboard Scheduler ends
        
        for(batchWrapper bw : tempBatchWrapper)
        {
            if(!bw.InvisibleOnDashboard)
            	returnBatchWrapper.add(bw);
        } 
        
        for(batchWrapper bw : returnBatchWrapper)
        {
            if(batchNextFireTime.containskey(bw.MasterLabel))
                bw.NextRunTime = batchNextFireTime.get(bw.MasterLabel).format(global_returnDateFormat);
        }
                
        return returnBatchWrapper;
    }
     @AuraEnabled
    public static String doBatchAction(   String batchDetail
                                    	, String actionType)
    {  
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        String returnStatus = ''; 
    
        if(batchDetail != null)
        {
            checkBatchActionUser();
            
            if(global_BatchActionAllowed)
            {
                if(actionType.toUpperCase().equals('RUN'))
                {
                    if(global_BatchRunAllowed)
                    {
                        if(batchDetail.equals(global_Dashboard30secBatchName))
                        {
                            String qryBatchName = '%' + global_Dashboard30secBatchName + '%';
                            CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger 
                                                            where CronJobDetail.name like :qryBatchName and state != 'DELETED'];
                            if(ct.size()==0)
                            {
                                try{
                                RV_DI_DashboardBatch dashboard = new RV_DI_DashboardBatch();
                                database.executeBatch(dashboard);
                                returnStatus = batchDetail + ' has been started';
                                saveError('Batch ' + batchDetail + ' has been executed by ' + Userinfo.getName() + ' (' + Userinfo.getUserName() + ')'
                                             ,'doBatchActionRUN');
                                }catch(Exception e){
                                    returnStatus ='Error : ' + e.getMessage();
                                    setAlert(global_BatchSectionName,
                                             actionType,
                                             e.getMessage()
                                            ,true
                                            //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                            ,false
                                            ,null);
                                            //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                 }
                            }
                        }
                        else
                        {
                        List<Revolution_Batch__mdt> batchMdt = getBatchMdt(batchDetail,'THIS');
                        
                        if(batchMdt.size()>0)
                        {
                            Map<String,Boolean> executedBatch =new map<String,Boolean>();
                            for(Revolution_Batch__mdt b :batchMdt)
                            {
                                try{
                                    String jobID = System.schedule(b.Batch_Name__c
                                                    , b.Schedule_Expression__c
                                                    , (Schedulable)Type.forName(b.Schedulable_Class_Name__c).newInstance());
                                    executedBatch.put(b.IT_Dashboard_Label__c + ' with Batch ID =' +jobID,true);
                                    
                                    saveError('Batch ' + b.Batch_Name__c + ' has been executed by ' + Userinfo.getName() + ' (' + Userinfo.getUserName() + ')'
                                             ,'doBatchActionRUN');
                                }catch(Exception e){
                                    returnStatus ='Error : ' + e.getMessage();
                                    setAlert(global_BatchSectionName,
                                             actionType,
                                             e.getMessage()
                                            ,true
                                            //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                            ,false
                                            ,null);
                                            //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                    executedBatch.put(b.IT_Dashboard_Label__c,false);
                                 }
                            }
                            
                            for(String eb: executedBatch.keyset())
                            {
                                if(executedBatch.get(eb))
                                    returnStatus = returnStatus + eb + ' has been scheduled; ';
                                else
                                    returnStatus = returnStatus + 'Failed to schedule ' + eb +'; ';
                            }
                        }
                        }
                    }
                    else
                        returnStatus = 'You are not allowed to run batches';
                }
                
                if(actionType.toUpperCase().equals('STOP'))
                {
                    if(global_BatchRunAllowed)
                    {
                        if(batchDetail.equals(global_Dashboard30secBatchName))
                        {
                            String qryBatchName = '%' + global_Dashboard30secBatchName + '%';
                            CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger 
                                                            where CronJobDetail.name like :qryBatchName and state != 'DELETED'];
                            if(ct.size()>0)
                            {
                                try{
                                   System.abortJob(ct[0].id);
                                    returnStatus = batchDetail + ' has been stopped';
                                    saveError(batchDetail + ' has been aborted by ' + Userinfo.getName() + ' (' + Userinfo.getUserName() + ')'
                                               ,'doBatchActionSTOP');
                                   }catch(Exception e){
                                       returnStatus = 'Failed to stop ' + batchDetail ;
                                       setAlert(global_BatchSectionName
                                                 ,actionType
                                                 ,e.getMessage()
                                                 ,true
                                                 //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                                 ,false
                                                 ,null);
                                                 //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                   }
                            }
                        }
                        else
                        {
                        Id batchId = ID.valueof(batchDetail);
                        CronTrigger[] ct = [SELECT Id, CronJobDetail.name FROM CronTrigger where Id = :batchId limit 1];
                        if(ct.size()>0)
                        {
                            List<Revolution_Batch__mdt> batchMdt = getBatchMdt(ct[0].CronJobDetail.name,'THIS');
                            
                            if(batchMdt.size()>1)
                            {
                                List<String> batchNames = new List<String>();
                                Map<String,Boolean> stoppedBatch =new map<String,Boolean>();
                                
                                for(Revolution_Batch__mdt b: batchMdt)
                                    batchNames.add(b.Batch_Name__c);
                                
                                CronTrigger[] ctRelated = [SELECT Id, CronJobDetail.name FROM CronTrigger where CronJobDetail.name in :batchNames];
                                
                                for(CronTrigger ctr : ctRelated)
                                {
                                    try{
                                        System.abortJob(ctr.id);
                                        stoppedBatch.put('Batch ' + ctr.CronJobDetail.name + ' with Batch ID =' +ctr.id,true);
                                        
                                        saveError('Batch ' + ct[0].CronJobDetail.name + ' has been aborted by ' + Userinfo.getName() + ' (' + Userinfo.getUserName() + ')'
                                                   ,'doBatchActionSTOP');
                                        
                                    }catch(Exception e){
                                        returnStatus ='Error : ' + e.getMessage();
                                        setAlert(global_BatchSectionName
                                                 ,actionType
                                                 ,e.getMessage()
                                                 ,true
                                                 //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                                 ,false
                                                 ,null);
                                                 //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                        stoppedBatch.put('Batch ' + ctr.CronJobDetail.name + ' with Batch ID =' +ctr.id,false);
                                     }
                                }
                                
                                for(String sb: stoppedBatch.keyset())
                                {
                                    if(stoppedBatch.get(sb))
                                        returnStatus = returnStatus + sb + ' has been stopped; ';
                                    else
                                        returnStatus = returnStatus + 'Failed to stop ' + sb +'; ';
                                }
                            }
                            else
                            {
                                try{
                                    System.abortJob(batchId);
                                    returnStatus = 'Batch ' + ct[0].CronJobDetail.name + ' with Batch ID =' +batchDetail +' has been aborted';
                                    
                                    saveError('Batch ' + ct[0].CronJobDetail.name + ' has been aborted by ' + Userinfo.getName() + ' (' + Userinfo.getUserName() + ')'
                                               ,'doBatchActionSTOP');
                                    
                                }catch(Exception e){
                                    returnStatus ='Error : ' + e.getMessage();
                                    setAlert(global_BatchSectionName
                                             ,actionType
                                             ,e.getMessage()
                                             ,true
                                             //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                             ,false
                                             ,null);
                                             //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                 }
                            }
                        }
                        }
                    }
                    else
                        returnStatus = 'You are not allowed to stop batches';
                }
                
                if(actionType.toUpperCase().equals('RUNADHOC'))
                {
                    if(global_BatchRunAllowed)
                    {
                        List<Revolution_Batch__mdt> batchMdt = getBatchMdt(batchDetail,'THIS');
                        
                        if(batchMdt.size()>0)
                        {
                            try{
                                Id BatchID;
                                if(batchMdt[0].Parent_Class_Name__c.toUpperCase().equals('NA'))
                                {
                                    returnStatus = 'Adhoc Run not allowed for ' + batchMdt[0].IT_Dashboard_Label__c;
                                }
                                else
                                {
                                    if(batchMdt[0].Parent_Class_Type__c.equals('Batchable'))
                                    {
                                        BatchID = Database.executebatch((Database.Batchable<sObject>)Type.forName(batchMdt[0].Parent_Class_Name__c).newInstance());
                                        
                                    }
                                    
                                    if(batchMdt[0].Parent_Class_Type__c.equals('Queueable'))
                                    {
                                        BatchID = System.enqueueJob((Queueable)Type.forName(batchMdt[0].Parent_Class_Name__c).newInstance());
                                    }
                                    returnStatus = batchMdt[0].IT_Dashboard_Label__c + ' has been sent for execution. Batch ID =' +BatchID;
                                    
                                    saveError('Batch ' + batchMdt[0].Batch_Name__c + ' has been executed on adhoc basis by ' + Userinfo.getName() + ' (' + Userinfo.getUserName() + ')'
                                             ,'doBatchActionRUNADHOC');
                                }
                            }catch(Exception e){
                                returnStatus ='Error : ' + e.getMessage();
                                setAlert(global_BatchSectionName
                                         ,actionType
                                         ,e.getMessage()
                                         ,true
                                         //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                         ,false
                                         ,null);
                                         //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                             }
                        }
                        }
                    else
                        returnStatus = 'You are not allowed to run batches';
                }
            }
        }
        else
            returnStatus = 'Batch Details not found';
        
        return returnStatus;
        
    } 
    
    public static void updateAlertSettings(List<errorWrapper> errList)
    {
        Map<String, IT_Alert_Notification_Control__c> alertMap = IT_Alert_Notification_Control__c.getAll();
        Map<String,errorWrapper> errMap = new Map<String,errorWrapper>();
        List<IT_Alert_Notification_Control__c> delAlert = new List<IT_Alert_Notification_Control__c>();
        
        for(errorWrapper err : errList)
        {
            String key = (err.SectionName.replaceAll( '\\s+', '') + '-' + err.DisplayLabel.replaceAll( '\\s+', '')).left(80);
            errMap.put(key,err);
        }
            
        if(!alertMap.isEmpty() && alertMap.size()>0)
        {
            for(String key : alertMap.keyset())
            {
                //START - Rahul Sharma | Date - 02-Jul-20 : Added additional check to avoid deleting alert subscribed for repeat alert.
                if(!errMap.containskey(key) && alertMap.get(key).Notification_Sent__c && !alertMap.get(key).Repeat_Alert__c)
                {
                //END - Rahul Sharma | Date - 02-Jul-20 : Added additional check to avoid deleting alert subscribed for repeat alert.
                    delAlert.add(IT_Alert_Notification_Control__c.getValues(key));
                }
            }
        }
        
        if(delAlert.size()>0)
        {
            try{delete delAlert;}
            catch(Exception e)
            {System.debug(e);}
        }
    }
    
    public static void checkAndSendAlert(List<errorWrapper> errList, Boolean sendEmail)
    {
        List<errorWrapper> errMsgList = new List<errorWrapper>();
        Map<String, IT_Alert_Notification_Control__c> alertMap = IT_Alert_Notification_Control__c.getAll();
        List<IT_Alert_Notification_Control__c> upsertAlert = new List<IT_Alert_Notification_Control__c>();
        //START - Rahul Sharma | Date - 02-Jul-20 : Updated logic to send frequent email alerts if repeat alert is subscribed
        for(errorWrapper err : errList){
                String key = (err.SectionName.replaceAll( '\\s+', '') + '-' + err.DisplayLabel.replaceAll( '\\s+', '')).left(80);
                String action;
                Boolean sendAlert = false;
                //Error notification already exists in the custom setting.
                if(alertMap.containsKey(key)){
                    //Notification is already sent.
                    if(alertMap.get(key).Notification_Sent__c)
                    {
                        //Repeat alert is subscribed.
                        if(err.repeatAlert){
                            //Current Time is greater than Next_Alert_Date_Time__c
                            if(alertMap.get(key).Next_Alert_Date_Time__c != null){
                                if(System.now() >= alertMap.get(key).Next_Alert_Date_Time__c){
                                    sendAlert = true;
                                    err.NotificationSent = true;
                                    action = 'UPD';
                                }
                                else{
                                    err.NotificationSent = true;
                                    sendAlert = false;
                                }            
                            }
                            else{
                                sendAlert = true;
                                err.NotificationSent = true;
                                action = 'UPD'; 
                            }
                        }
                        //Repeat alert is not subscribed and alert already sent for the current day.
                        else if(alertMap.get(key).Last_Notification_Time__c.isSameDay(err.CheckTime)){
                            err.NotificationSent = true;
                            sendAlert = false;
                        }
                        //Repeat alert is not subscribed and alert not sent for the current day.
                        else{
                            err.NotificationSent = false;
                            sendAlert = true;
                            action = 'UPD'; 
                        }
                    }
                    else
                    {
                        sendAlert = true;
                        err.NotificationSent = false;
                        action = 'UPD'; 
                    }
                }
                else
                {
                    sendAlert = true;
                    err.NotificationSent = false;
                    action = 'INS';
                }
                
                if(sendAlert){
                    if(action.equals('UPD')){
                        IT_Alert_Notification_Control__c al = IT_Alert_Notification_Control__c.getValues(key);
                        al.Last_Notification_Time__c = err.CheckTime;
                        al.Notification_Sent__c = (sendEmail ? true:false);
                        if(err.repeatAlert && err.alertIntervalInMin != null && err.alertIntervalInMin != 0){
                            al.Repeat_Alert__c = err.repeatAlert;
                            al.Next_Alert_Date_Time__c = System.now().addMinutes(err.alertIntervalInMin);
                        }
                        upsertAlert.add(al);
					}
                    if(action.equals('INS')){
                        IT_Alert_Notification_Control__c al = new IT_Alert_Notification_Control__c();
                        al.Name = key;
                        al.Last_Notification_Time__c = err.CheckTime;
                        al.Notification_Sent__c = (sendEmail ? true:false);
                        if(err.repeatAlert && err.alertIntervalInMin != null && err.alertIntervalInMin != 0){
                            al.Repeat_Alert__c = err.repeatAlert;
                            al.Next_Alert_Date_Time__c = System.now().addMinutes(err.alertIntervalInMin);
                        }
                        upsertAlert.add(al);
                    }
                        //upsertAlert.add(new IT_Alert_Notification_Control__c(name = key, Last_Notification_Time__c = err.CheckTime, Notification_Sent__c = (sendEmail ? true:false)));
        //END - Rahul Sharma | Date - 02-Jul-20 : Updated logic to send frequent email alerts if repeat alert is subscribed
                       errMsgList.add(err);
                }
            }
        
        if(errMsgList.size()>0 && sendEmail)
            sendEmailAlert(errMsgList);
        
        if(upsertAlert.size()>0)
        {
            try{upsert upsertAlert;}
            catch(Exception e)
            {System.debug(e);}
        }      
        updateAlertSettings(errList);
    }
    
    public static void saveError(String errMsg, String methodName)
    {
        RV_ClassException.getInstance();
        RV_ClassException.insertExceptionRecord('NA', errMsg, 'Rv_ITdashboardController', methodName,'Info'); 
    }
    
    public static void saveError(List<Rv_ITdashboardController.errorWrapper> errList)
    {
        List<RV_Exception__c> rvExcepLst = new List<RV_Exception__c>();
        for(Rv_ITdashboardController.errorWrapper err :errList)
                {
                    if(err.saveError)
                    {
                        RV_Exception__c rvExcep = new RV_Exception__c();
            
                        rvExcep.Status_Code__c = 'NA';
                        rvExcep.getMessage__c = err.ErrorMsg;
                        rvExcep.Apex_Class__c = 'Rv_ITdashboardAlert';
                        rvExcep.Method_Name__c = 'saveError';
                        rvExcep.Type__c = 'Info';
                        
                        rvExcepLst.add(rvExcep);
                    }
                }
        if(rvExcepLst.size()>0)
        {
            try{
               insert rvExcepLst;
               }catch(DmlException e){
               		system.debug('Error while inserting error==>'+e.getMessage());
               }
        }
    }
    
    @TestVisible
    static void sendEmailAlert(List<errorWrapper> errorLst){
        String emailTemplateLabel = 'default';
        IT_Alert_Email_Template__mdt et = new IT_Alert_Email_Template__mdt();
        //Added by Surbhi, PBI-1756697
        Set<String> setToAddress = new Set<String>();            
        Set<String> setCCAddress = new Set<String>();
        //Ended by Surbhi, PBI-1756697
        String emailTemplate='';
        String emailSubject='';
        String emailBody =  '';
        
        try{
            et = [select EMAIL_TEMPLATE__c
                  ,EMAIL_SUBJECT__c
                  ,EMAIL_CC__c
                  ,EMAIL_CSS__c
                  ,EMAIL_HEADER__c
                  ,EMAIL_TO__c
                  ,EMAIL_FOOTER__c 
                  from IT_Alert_Email_Template__mdt 
                  where MasterLabel= :emailTemplateLabel limit 1];
        }catch(Exception e){
            system.debug('Error while finding Email Template'+e);
            et = new IT_Alert_Email_Template__mdt();
        }
        
        if(et.EMAIL_TEMPLATE__c != null && et.EMAIL_TO__c!=null)
        {  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            emailSubject=et.EMAIL_SUBJECT__c;
            emailTemplate = et.EMAIL_TEMPLATE__c;
            
            try{
                //Added by Surbhi, PBI-1756697
                //Fetching TO email address from EMAIL_TO_c custom field from custom metadata
                    List<String> lstToAddress=et.EMAIL_TO__c.split(';');                    
                    for(String toAddress : lstToAddress)
                    {
                        setToAddress.add(toAddress);
                    }
                //Fetching TO email address from permission set
                List<String> lstToAddressFromPermissionSet = OLF_DashboardApexController.getUserEmailFromPermissionSet('RV_OnlineSalesManagement');                 
                if(lstToAddressFromPermissionSet.size() > 0){
                    setToAddress.addAll(lstToAddressFromPermissionSet);
                }
                //Ended by Surbhi, PBI-1756697
                
            }catch(Exception e){
                //system.debug('Error while finding email To :'+e);
                //Added by Surbhi, PBI-1756697
                setToAddress = new Set<String>();
                //Ended by Surbhi, PBI-1756697
            }
            
            try{
                //Added by Surbhi, PBI-1756697
                if(String.isNotEmpty(et.EMAIL_CC__c)){
                    List<String> ccList=et.EMAIL_CC__c.split(';');
                    for(String cc : ccList)
                    {
                        setCCAddress.add(cc);
                    }
                }
                //Ended by Surbhi, PBI-1756697                  
            }catch(Exception e){
                //Added by Surbhi, PBI-1756697
                system.debug('Error while finding email CC :'+e);
                setCCAddress = new Set<String>();
                //Ended by Surbhi, PBI-1756697
            }
            
            emailBody = emailTemplate;
            emailBody = emailBody.replace('{!EMAIL_CSS__C}', et.EMAIL_CSS__c);
            emailBody = emailBody.replace('{!EMAIL_HEADER__C}', et.EMAIL_HEADER__c);
            emailBody = emailBody.replace('{!EMAIL_FOOTER__C}', et.EMAIL_FOOTER__c);
            
            String emailTableBody = '';
            for(errorWrapper err :errorLst)
            {
                emailTableBody = emailTableBody +'<tr>' 
                    +'<td>'+err.ErrorMsg+'</td>'
                    +'</tr>';
            }
            emailBody = emailBody.replace('<!--<TABLE_BODY/>-->', emailTableBody);
            
            //Added by Surbhi, PBI-1756697
            if(setToAddress.size()>0)
            {
                //Added by Surbhi, PBI-1756697
                List<String> toAddresses = new List<String>();
                toAddresses.addAll(setToAddress);
                mail.setToAddresses(toAddresses); 
                if(setCCAddress.size()>0){
                    List<String> ccAddresses = new List<String>();
                    ccAddresses.addAll(setCCAddress); 
                    mail.setCcAddresses(ccAddresses);
                }
                //Ended by Surbhi, PBI-1756697
                mail.setSubject(emailSubject);
                mail.setHtmlBody(emailBody);
                mail.setSaveAsActivity(false);
                
                try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                }catch(Exception e){
                    System.debug('Error while sending email :'+e);
                }
            }
        }
        else
        {
            //system.debug('Else part Error');
        }
    }
    
    //Fix_301484_26Dec2019_Soumyajit starts
    @AuraEnabled
    public static List<dailyCheckWrapper> getDailyCheckDetails()
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        List<dailyCheckWrapper> returnDailyCheckWrapper = new List<dailyCheckWrapper>();
        List<IT_Dashboard_Controller__mdt> displayLabelLst = getControllerMdt(global_DailyCheckSectionName,'THIS');
        Map<String,IT_Dashboard_Controller__mdt> mdtMap = new Map<String,IT_Dashboard_Controller__mdt>();
        
        for(IT_Dashboard_Controller__mdt mdt : displayLabelLst)
            mdtMap.put(mdt.DeveloperName,mdt);
        
        if(mdtMap.containsKey(globalZero_HCVLabel))
        {
            IT_Dashboard_Controller__mdt mdt = mdtMap.get(globalZero_HCVLabel);
			dailyCheckWrapper dw = new dailyCheckWrapper();
            dw.DisplaySequence = 1;
            dw.DisplayLabel = mdt.Display_Label__c;
            dw.DisplayValue = '0';                
            dw.SendAlert = false;
			dw.gsapCheck = false;
            
            List<String> QueryParamLst = new List<String>();
            List<String> AlertMsgLst = new List<String>();
            try{QueryParamLst = mdt.Controller_Value__c.split(';');}catch(Exception e){QueryParamLst = new List<String>{'','',''};}
            try{AlertMsgLst = mdt.Alert_Message__c.split(';');}catch(Exception e){AlertMsgLst = new List<String>{'','',''};}
            
            if(QueryParamLst.size()>1 && AlertMsgLst.size()>1)
            {
                String qryString = 'Select count(id)rslt from ' + QueryParamLst[0] + ' where ' + QueryParamLst[1];
                try{
                    AggregateResult[] result = Database.query(qryString);
                    if(result.size()>0)
                    {
                        if(result[0].get('rslt') != null)
                        {
                            if(Integer.valueof(result[0].get('rslt')) > 0)
                            {
                                qryString += ' and ' +  QueryParamLst[2];
                                AggregateResult[] result2 = Database.query(qryString);
                                
                                if(result2[0].get('rslt') != null)
                                {
                                    dw.DisplayValue = String.valueof(result2[0].get('rslt'));
                                    
                                    if(mdt.Alert_Needed__c && Integer.valueof(result2[0].get('rslt')) > Integer.valueOf(mdt.Alert_Value__c))
                						dw.SendAlert = setAlert(mdt.Section_Name__c, mdt.Display_Label__c, AlertMsgLst[1], mdt.Save_Error__c, false, null); //Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                                }
                            }
                            else
                            {
                                dw.DisplayValue = AlertMsgLst[0];
                            }
                        }
                    }
                }
                catch(Exception e)
                {
                    setAlert(mdt.Section_Name__c,
                             mdt.Display_Label__c,
                             'Error '+ e.getMessage(),
                             true,
                             //START - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                             false,
                             null);
                             //END - Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                }
            }
            else
                mdt.Invisible_on_Dashboard__c = true;
            
            if(!mdt.Invisible_on_Dashboard__c)
                returnDailyCheckWrapper.add(dw);
        }
        
        if(mdtMap.containsKey(globalGSAP_ConnectLabel))
        {
            IT_Dashboard_Controller__mdt mdt = mdtMap.get(globalGSAP_ConnectLabel);
			dailyCheckWrapper dw = new dailyCheckWrapper();
            dw.DisplaySequence = 2;
            dw.DisplayLabel = mdt.Display_Label__c;
            dw.DisplayValue = '-';                
            dw.SendAlert = false;
			dw.gsapCheck = true;
            
            List<String> DisplayValueLst = new List<String>();
            List<String> AlertMsgLst = new List<String>();
            try{DisplayValueLst = mdt.Controller_Value__c.split(';');}catch(Exception e){DisplayValueLst = new List<String>{'','',''};}
            try{AlertMsgLst = mdt.Alert_Message__c.split(';');}catch(Exception e){AlertMsgLst = new List<String>{'','',''};}
                    
            if(mdt.Alert_Needed__c && AlertMsgLst.size()>2)
            {
                Organization org = [SELECT Id, IsSandbox FROM Organization limit 1];
                ExternalDataSource exSrc = [SELECT Id, Endpoint FROM ExternalDataSource where DeveloperName = :mdt.DeveloperName limit 1];
                        
                if(exSrc == null)
                {
                    dw.DisplayValue = DisplayValueLst[2];
                    dw.SendAlert = setAlert(mdt.Section_Name__c, mdt.Display_Label__c, AlertMsgLst[2], mdt.Save_Error__c, false, null); //Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                }
                else
                {
                    if(exSrc.Endpoint.toUpperCase().contains(globalGSAP_ProdURL.toUpperCase()))
                    {
                        dw.DisplayValue = DisplayValueLst[0];
                        if(org.IsSandbox)
                            dw.SendAlert = setAlert(mdt.Section_Name__c, mdt.Display_Label__c, AlertMsgLst[1], mdt.Save_Error__c, false, null); //Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                    }
                    else if(exSrc.Endpoint.toUpperCase().contains(globalGSAP_TestURL.toUpperCase()))
                    {
                        dw.DisplayValue = DisplayValueLst[1];
                        if(!org.IsSandbox)
                            dw.SendAlert = setAlert(mdt.Section_Name__c, mdt.Display_Label__c, AlertMsgLst[0], mdt.Save_Error__c, false, null); //Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                    }
                    else
                    {
                        dw.DisplayValue = DisplayValueLst[2];
                        dw.SendAlert = setAlert(mdt.Section_Name__c, mdt.Display_Label__c, AlertMsgLst[2], mdt.Save_Error__c, false, null); //Rahul Sharma | Date- 1-Jul-20 : Added additional parameters
                    }
                }
            }
            else
                mdt.Invisible_on_Dashboard__c = true;
            
            if(!mdt.Invisible_on_Dashboard__c)
                returnDailyCheckWrapper.add(dw);
        }
        
        if (mdtMap.containsKey(globalBRENT_M15Label) 
            || mdtMap.containsKey(globalIGO_M15Label) 
            || mdtMap.containsKey(globalNYMEX_M15Label))
        {
            Map<String,IT_Dashboard_Controller__mdt> mdtPriceMap = new Map<String,IT_Dashboard_Controller__mdt>();
            
            if(mdtMap.containsKey(globalNYMEX_M15Label))
                mdtPriceMap.put(mdtMap.get(globalNYMEX_M15Label).Controller_Value__c,mdtMap.get(globalNYMEX_M15Label));
            if(mdtMap.containsKey(globalBRENT_M15Label))
                mdtPriceMap.put(mdtMap.get(globalBRENT_M15Label).Controller_Value__c,mdtMap.get(globalBRENT_M15Label));
            if(mdtMap.containsKey(globalIGO_M15Label))
                mdtPriceMap.put(mdtMap.get(globalIGO_M15Label).Controller_Value__c,mdtMap.get(globalIGO_M15Label));
                
            if(mdtPriceMap.size()>0)
            {    
                map<String,Integer> iceCountMap = new map<String,Integer>();
                
                
                ice_month__mdt[] iceMdtFuture = [select id,Quote_Name__c from ice_month__mdt 
                                                 where Start_Date__c > TODAY 
                                                 and End_Date__c >= TODAY 
                                                 and Quote_Name__c in :mdtPriceMap.keySet()];
                ice_month__mdt[] iceMdtCurrent = [select id,Quote_Name__c from ice_month__mdt 
                                                 where Start_Date__c <= TODAY 
                                                 and End_Date__c >= TODAY 
                                                 and Quote_Name__c in :mdtPriceMap.keySet()];
                
                for(ice_month__mdt i : iceMdtFuture)
                {
                    String key = i.Quote_Name__c;
                    if(iceCountMap.containsKey(key))
                        iceCountMap.put(key, iceCountMap.get(key) + 1);
                    else
                        iceCountMap.put(key, 1);
                }
                
                for(ice_month__mdt i : iceMdtCurrent)
                {
                    String key = i.Quote_Name__c;
                    if(iceCountMap.containsKey(key))
                        iceCountMap.put(key, iceCountMap.get(key) + 1);
                    else
                        iceCountMap.put(key, 1);
                }
                
                for(String key : mdtPriceMap.keySet())
                {
                    IT_Dashboard_Controller__mdt mdt = mdtPriceMap.get(key);
                    Integer count = iceCountMap.containskey(key) ? iceCountMap.get(key) : 0; 
                    String quotename = key;//Fix_PBI-517826_08Jun2020_Lakshmi
                    
                    dailyCheckWrapper dw = new dailyCheckWrapper();
                    dw.DisplaySequence = mdt.Display_Order__c;
                    dw.DisplayLabel = mdt.Display_Label__c;
                    dw.DisplayValue =  String.valueOf(count);             
                    dw.SendAlert = false;
                    dw.gsapCheck = false;
                    dw.checkICEmonthdetails = true;//Fix_PBI-517826_08Jun2020_Lakshmi
                    dw.QuoteName = quotename;//Fix_PBI-517826_08Jun2020_Lakshmi
                    

                    if(mdt.Alert_Needed__c)
                        dw.SendAlert = setAlert(mdt, count, mdt.Display_Label__c + ' = ' + dw.DisplayValue);
                    
                    if(!mdt.Invisible_on_Dashboard__c)
                		returnDailyCheckWrapper.add(dw);
                }
            }
        }
        
        return returnDailyCheckWrapper;
    }
    //Fix_301484_26Dec2019_Soumyajit ends
    
    //Fix_PBI-517826_08Jun2020_Lakshmi_Starts
    @AuraEnabled(cacheable=true)
    public static List<IceMonthWrapper> getIceMonthDetails(String quote)
    {
         List<IceMonthWrapper> returnIceMonthWrapper = new List<IceMonthWrapper>();
          List<ice_month__mdt> IceMonthLst= new List<ice_month__mdt>();
        
         ice_month__mdt[] iceMdtFuture = [select id,Label,Quote_Name__c,Start_Date__c,End_Date__c from ice_month__mdt 
                                                 where Start_Date__c > TODAY
                                                 and End_Date__c >= TODAY 
                                                 and Quote_Name__c =: quote order by Start_Date__c asc];
         ice_month__mdt[] iceMdtCurrent = [select id,Label,Quote_Name__c,Start_Date__c,End_Date__c from ice_month__mdt
                                                 where Start_Date__c <= TODAY 
                                                 and End_Date__c >= TODAY 
                                                 and Quote_Name__c =: quote order by Start_Date__c asc];
        
        	for(ice_month__mdt i : iceMdtCurrent)
                {
                    
                     IceMonthLst.add(i);
                   
                }
        
        	for(ice_month__mdt i : iceMdtFuture)
                {
                    
                    IceMonthLst.add(i);
                    
                 }
                
                
        
        for(ice_month__mdt i : IceMonthLst)
                {
                    IceMonthWrapper iw = new IceMonthWrapper();
                    iw.icemonth = i.Label;
                    iw.QuoteName = i.Quote_Name__c;
                    iw.StartDate = i.Start_Date__c;
                    iw.EndDate = i.End_Date__c;
                    
                    returnIceMonthWrapper.add(iw);
                   
                }
        return returnIceMonthWrapper;
	}
//Fix_PBI-517826_08Jun2020_Lakshmi_Ends
    @AuraEnabled
    public static string startStopAllBatches(String actionType)
    {
        if(!setMDTCalled)
			setGlobalVarFromMDT();
        
        String status = '';
        if(actionType.equalsIgnoreCase('RunAll'))
        {
            List<batchWrapper> bw = getBatchDetails();
            for(batchWrapper b : bw)
            {
                if(! (b.Status.equalsIgnoreCase('EXECUTING') || b.Status.equalsIgnoreCase('SUCCESS')))
                    status += doBatchAction(b.BatchName,'RUN');
            }
        }
        if(actionType.equalsIgnoreCase('StopAll'))
        {
            List<Revolution_Batch__mdt> batchMdt = [select Batch_Name__c from Revolution_Batch__mdt];
            List<String> batchNames = new List<String>();
            for(Revolution_Batch__mdt b: batchMdt)
                batchNames.add(b.Batch_Name__c);
            CronTrigger[] ctTrigg = [SELECT Id, CronJobDetail.name FROM CronTrigger where CronJobDetail.name in :batchNames];
            for(CronTrigger ctr : ctTrigg)
            {
                try{
                   System.abortJob(ctr.id);
                   }catch(Exception e){status = e.getMessage();}
            }
            
            String qryBatchName = '%' + global_Dashboard30secBatchName + '%';
            CronTrigger[] ct = [select id, CronJobDetailId, CronJobDetail.name, NextFireTime, State, CronExpression from CronTrigger 
                                            where CronJobDetail.name like :qryBatchName and state != 'DELETED'];
            if(ct.size()>0)
            {
                try{
                   System.abortJob(ct[0].id);
                   }catch(Exception e){status = e.getMessage();}
            }
            status = 'All Running Batches Have Been Stopped.';
        }
        return status;
    }

    /*Method Name       : checkAlertValidity
     *Date              : 25-Jun-20
     *Developer         : Rahul Sharma
     *Description       : Check wether alert is valid or not by comparing current time with alert disable start time and end time fields of the IT_Dashboard_Controller__mdt mwetadata.
     *Modification Log  : 
     */
    public static Boolean checkAlertValidity(String startTimeStr, String endTimeStr, String timeZoneIdKeyStr){
        Boolean alertValid = true;
        String startDateTimeStr;
        String endDateTimeStr;
        DateTime currentDateTime;
        DateTime startDateTime;
        DateTime endDateTime;
        Datetime currentDateTimeGMT = Datetime.now();
        if(!String.isBlank(startTimeStr) && !String.isBlank(endTimeStr) && !String.isBlank(timeZoneIdKeyStr)){
            List<String> startTimeList = startTimeStr.split(':');
            List<String> endTimeList = endTimeStr.split(':');
            Time startTime = Time.newInstance(Integer.valueOf(startTimeList[0]), Integer.valueOf(startTimeList[1]), Integer.valueOf(startTimeList[2]), 0);
            Time endTime = Time.newInstance(Integer.valueOf(endTimeList[0]), Integer.valueOf(endTimeList[1]), Integer.valueOf(endTimeList[2]), 0);
            String currentDateTimeStr = currentDateTimeGMT.format('yyyy-MM-dd HH:mm:ss', timeZoneIdKeyStr);
            if(startTime < endTime){
                startDateTimeStr = currentDateTimeStr.subString(0, 11) + startTimeStr;
                endDateTimeStr = currentDateTimeStr.subString(0, 11) + endTimeStr;
            }
            else if(startTime > endTime){
                startDateTimeStr = currentDateTimeStr.subString(0, 11) + startTimeStr;
                DateTime nextDateTime = DateTime.valueOf(startDateTimeStr).addDays(1);
                String nextDateTimeStr = nextDateTime.format('yyyy-MM-dd HH:mm:ss'); 
                endDateTimeStr = nextDateTimeStr.subString(0, 11) + endTimeStr;
            }
            currentDateTime = DateTime.valueOf(currentDateTimeStr);
            startDateTime = DateTime.valueOf(startDateTimeStr);
            endDateTime = DateTime.valueOf(endDateTimeStr);
            if(startDateTime <= currentDateTime && currentDateTime <= endDateTime)
                alertValid = false;
        }
        else{
            System.debug('Rv_ITdashboardController >> checkAlertValidity >> Input paramters are neigther valid nor in correct format: '+
                        +'startTimeStr: ' + startTimeStr + ' endTimeStr: ' + endTimeStr + ' timeZoneIdKeyStr: ' + timeZoneIdKeyStr);
        }
        System.debug('Rv_ITdashboardController >> checkAlertValidity >> alertValid: '+alertValid);
        return alertValid;
    }
    
    public class dealWrapper
    {
        @AuraEnabled
        public Decimal DisplaySequence;
        @AuraEnabled
        public String DisplayLabel;
        @AuraEnabled
        public string DisplayValue;
        @AuraEnabled
        public boolean SendAlert;
    }
    
    //Fix_301484_26Dec2019_Soumyajit starts
    public class dailyCheckWrapper
    {
        @AuraEnabled
        public Decimal DisplaySequence;
        @AuraEnabled
        public String DisplayLabel;
        @AuraEnabled
        public string DisplayValue;
        @AuraEnabled
        public boolean SendAlert;
        @AuraEnabled
        public boolean gsapCheck;
        @AuraEnabled
        public Boolean checkICEmonthdetails; //Fix_PBI-517826_08Jun2020_Lakshmi
        @AuraEnabled
        public string QuoteName;//Fix_PBI-517826_08Jun2020_Lakshmi
    }
    //Fix_301484_26Dec2019_Soumyajit ends
    
    //Fix_PBI-517826_08Jun2020_Lakshmi_Starts
     public class IceMonthWrapper
    {
       @AuraEnabled
        public string icemonth;
        @AuraEnabled
        public string QuoteName;
        @AuraEnabled
        public Date StartDate;
        @AuraEnabled
        public Date EndDate;
        
    }
    //Fix_PBI-517826_08Jun2020_Lakshmi_Ends
    
    public class daveWrapper
    {
        @AuraEnabled
        public Decimal DisplaySequence;
        @AuraEnabled
        public String DisplayLabel;
        @AuraEnabled
        public Integer Hedge;
        @AuraEnabled
        public string LastUpdateTime;
    }
    
    public class priceWrapper
    {
        @AuraEnabled
        public Decimal DisplaySequence;
        @AuraEnabled
        public String DisplayLabel;
        @AuraEnabled
        public string LastUpdateTime;
        @AuraEnabled
        public boolean SendAlert;
    }
    
    public class mrcUploadWrapper
    {
        @AuraEnabled
        public Decimal DisplaySequence;
        @AuraEnabled
        public String DisplayLabel;
        @AuraEnabled
        public string LastUpdateTime;
        @AuraEnabled
        public string DisplayValue; // added by Dharmendra
        @AuraEnabled
        public boolean SendAlert;
    }
    
    public class errorWrapper
    {
        @AuraEnabled
        public String SectionName;
        @AuraEnabled
        public String DisplayLabel;
        @AuraEnabled
        public String ErrorMsg;
        public Boolean NotificationSent;
        public DateTime CheckTime;
        public Boolean saveError;
        //START - Rahul Sharma | Date - 1-Jul-20 : Adding new variables to allow email alert at the specified time interval
        public Boolean repeatAlert;
        public Integer alertIntervalInMin;
        //END - Rahul Sharma | Date - 1-Jul-20 : Adding new variables to allow email alert at the specified time interval
    }
    
    public class batchWrapper
    {
        @AuraEnabled
        public ID BatchID;
        @AuraEnabled
        public Decimal DisplaySequence;
        @AuraEnabled
        public String DisplayLabel;
        @AuraEnabled
        public String BatchName;
        public String ParentClassName;
        public String ParentClassType;
        @AuraEnabled
        public Boolean AdhocRunAllowed;
        public String SchedulableClassName;
        public String ScheduleTime;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String NextRunTime;
        @AuraEnabled
        public boolean SendAlert;
        public boolean AlertNeeded;
        public boolean InvisibleOnDashboard;
        public String MasterLabel;
        public String RelatedMasterLabel;
        @AuraEnabled
        public boolean OnlyAdhocRunAllowed;
        @AuraEnabled
        public boolean isDashboard30secBatch = false;
    }

    public class pageWrapper
    {
        @AuraEnabled
        public String PageName;
        @AuraEnabled
        public String DaveSectionName;
        @AuraEnabled
        public String DealSectionName;
        @AuraEnabled
        public String MRCUploadSectionName;
        @AuraEnabled
        public String LiveSectionName;
        @AuraEnabled
        public String BatchSectionName;
        
        @AuraEnabled
        public String DailyCheckSectionName;	//Fix_301484_26Dec2019_Soumyajit
        
        @AuraEnabled
        public Boolean ErrorStatus;
        @AuraEnabled
        public List<errorWrapper> ErrorList;
        @AuraEnabled
        public Boolean BatchActionAllowed;
        @AuraEnabled
        public Boolean RunRefreshAllowed;
        @AuraEnabled
        public Boolean ShowRunAllButton;
        @AuraEnabled
        public Boolean ShowStopAllButton;
        
        @AuraEnabled
        public List<priceWrapper> PriceData;
        @AuraEnabled
        public List<batchWrapper> BatchData;
        @AuraEnabled
        public List<dealWrapper> DealData;
        @AuraEnabled
        public List<daveWrapper> DaveData;
        @AuraEnabled
        public List<mrcUploadWrapper> MRCUploadData;
        @AuraEnabled
        public List<dailyCheckWrapper> DailyCheckData;	//Fix_301484_26Dec2019_Soumyajit
        
        public Boolean StopOLF;	//Fix_365305_Soumyajit_18Oct2019
        public String StopOLFReason;
    }
}