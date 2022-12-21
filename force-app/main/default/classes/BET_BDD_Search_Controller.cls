public class BET_BDD_Search_Controller { 
	public Static Id loggedInUser = UserInfo.getUserId();
    @AuraEnabled
    public static compInitWrapper getCompInitData(){
        compInitWrapper wrap = new compInitWrapper();
        try{
            wrap.disableEdpSearchAndVer = checkUserPermissionSets();
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> getCompInitData() method : ' + ex.getMessage());
        }
        return wrap;
    }
    
    public static Boolean checkUserPermissionSets(){
        List<String> assignedPermissionSet = BET_BDDFormTriggerUtil.getPermissionSetList(Userinfo.getUserId());
        if(assignedPermissionSet != Null && assignedPermissionSet.size() == 2 && assignedPermissionSet.contains('BET_Compliance')){
            return true;  
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static BET_BDD_GTMI_WrapperClass getGTRecordSet(String searchShortName, String IMONum, string accessToken){
        system.debug('Attributes from UI: searchShortName='+searchShortName+ ';IMONum='+IMONum+';accessToken='+accessToken);
        
        BET_BDD_GTMI_WrapperClass gtmiData = new BET_BDD_GTMI_WrapperClass();
        try{
            //GTMI Callout
            //searchShortName = searchShortName.replace(' ', '%20');
            if((IMONum != '' || IMONum != null) && (searchShortName == '' || searchShortName == null)){
                IMONum = IMONum.replace(' ', '');
                if(!IMONum.isNumeric()){
                    searchShortName = IMONum;
                    IMONum = '';
                }
            }
            gtmiData = BET_BDD_GTMI_Callout.getGTMIData(searchShortName, IMONum, 250, accessToken);
            
            system.debug('gtmiData -- ' + gtmiData.resultPayload);
            system.debug('gtmiData Access token -- ' + gtmiData.accessToken); 
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> getGTRecordSet() : ' + ex.getMessage());
        }
        return gtmiData;
    }
    
    @AuraEnabled
    public static BET_EdpResponse_WrapperClass getEdpData(String searchShortName, string sLOB, string sEntType, String sIncCountry, string sAccessToken, string sSource){
        BET_EdpResponse_WrapperClass edpRecList = new BET_EdpResponse_WrapperClass();
        string dataSource = '';
        string countryCode = '';
        map<string, string> dataSourceMap = BET_Utility.getSourceName(sLOB, sEntType, sSource, 'Identification');
        System.debug('dataSourceMap'+dataSourceMap);
        if(dataSourceMap.ContainsKey(sSource) ){
            dataSource = dataSourceMap.get(sSource);
        }
        if(dataSourceMap.ContainsKey('AdditionalSource') ){
            if(dataSourceMap.get('AdditionalSource') == 'NA'){
                edpRecList.AddEdpSourceAvailable = 'NA'; 
            }else{
                edpRecList.AddEdpSourceAvailable = 'Available';
            }
        }
        
        System.debug('dataSource'+dataSource);
        if(dataSource == 'Orbis'){
            BET_BDD_WrapperClass.responseParametersORBIS orbisRecordList = getOrbisRecordSet(searchShortName, sIncCountry, sAccessToken);
            if(orbisRecordList.responseCode == 200){
                 List<BET_EdpResponse_WrapperClass.OrbisResult> OrbisRecList = new List<BET_EdpResponse_WrapperClass.OrbisResult>();
                
                for(BET_BDD_WrapperClass.data item: orbisRecordList.resultPayload.data){
                    BET_EdpResponse_WrapperClass.OrbisResult wrapRec = new BET_EdpResponse_WrapperClass.OrbisResult();
                    wrapRec.name = item.name;
                    wrapRec.namE_INTERNATIONAL = item.namE_INTERNATIONAL;
                    wrapRec.bvdid = item.bvdid;
                    wrapRec.lei = item.lei;
                    wrapRec.tin = item.tin;
                    wrapRec.vaT_NUMBER = item.vaT_NUMBER;
                    wrapRec.entitY_TYPE = item.entitY_TYPE;
                    wrapRec.companY_ID_NUMBER = item.companY_ID_NUMBER;
                    wrapRec.tradE_REGISTER_NUMBER = item.tradE_REGISTER_NUMBER;                     
                    wrapRec.addresS_LINE1 = item.addresS_LINE1;
                    wrapRec.addresS_LINE2 = item.addresS_LINE2;
                    wrapRec.addresS_LINE3 = item.addresS_LINE3;
                    wrapRec.city = item.city;
                    wrapRec.uS_STATE = item.uS_STATE;
                    wrapRec.country = item.country;
                    wrapRec.postcode = item.postcode;
                    wrapRec.productS_SERVICES = item.productS_SERVICES;
                    wrapRec.europeaN_VAT_NUMBER = item.europeaN_VAT_NUMBER;
                                        
                    string tempString = null;
                    
                    if(item.companY_ID_NUMBER != null){
                        tempString = item.companY_ID_NUMBER.toString();
                        wrapRec.companY_ID_NUMBER_Str = tempString.substring(1, tempString.length()-1);
                    }
                    if(item.tradE_REGISTER_NUMBER != null){
                        tempString = item.tradE_REGISTER_NUMBER.toString();
                        wrapRec.tradE_REGISTER_NUMBER_Str = tempString.substring(1, tempString.length()-1);
                    }
                    if(item.vaT_NUMBER != null){
                        tempString = item.vaT_NUMBER.toString();
                        wrapRec.vaT_NUMBER_Str = tempString.substring(1, tempString.length()-1);
                    }
                    if(item.akA_NAME != null){
                        tempString = item.akA_NAME.toString();
                        wrapRec.akA_NAME_Str = tempString.substring(1, tempString.length()-1);
                    }
                    if(item.previouS_NAME != null){
                        tempString = item.previouS_NAME.toString();
                        wrapRec.previouS_NAME_Str = tempString.substring(1, tempString.length()-1);
                    }
                    wrapRec.naicS2017_CORE_CODE = item.naicS2017_CORE_CODE;
                    wrapRec.NAICS2017_CORE_LABEL = item.NAICS2017_CORE_LABEL;
                    wrapRec.incorporatioN_STATE = item.incorporatioN_STATE;
                    wrapRec.worldcompliancE_MATCH_SANCTION_INDICATOR = item.worldcompliancE_MATCH_SANCTION_INDICATOR;
                    wrapRec.worldcompliancE_MATCH_CURRENT_PEP_INDICATOR = item.worldcompliancE_MATCH_CURRENT_PEP_INDICATOR;
                    wrapRec.worldcompliancE_MATCH_ADVERSE_MEDIA_INDICATOR = item.worldcompliancE_MATCH_ADVERSE_MEDIA_INDICATOR;
                    wrapRec.WORLDCOMPLIANCE_MATCH_ENFORCEMENT_INDICATOR = item.WORLDCOMPLIANCE_MATCH_ENFORCEMENT_INDICATOR;
                    wrapRec.WORLDCOMPLIANCE_MATCH_SOE_INDICATOR = item.WORLDCOMPLIANCE_MATCH_SOE_INDICATOR;
                    wrapRec.WORLDCOMPLIANCE_MATCH_GOVERNMENT_LINKED_INDICATOR = item.WORLDCOMPLIANCE_MATCH_GOVERNMENT_LINKED_INDICATOR;
                    wrapRec.WORLDCOMPLIANCE_MATCH_ASSOCIATED_ENTITY_INDICATOR = item.WORLDCOMPLIANCE_MATCH_ASSOCIATED_ENTITY_INDICATOR;
                    wrapRec.WORLDCOMPLIANCE_MATCH_REGISTRATIONS_INDICATOR = item.WORLDCOMPLIANCE_MATCH_REGISTRATIONS_INDICATOR;
                    if(item.address_Line1_Additional.size() > 0){
                        wrapRec.address_Line1_Additional = item.address_Line1_Additional[0];
                    }
                    if(item.address_Line2_Additional.size() > 0){
                        wrapRec.address_Line2_Additional = item.address_Line2_Additional[0];
                    }
                    if(item.address_Line3_Additional.size() > 0){
                        wrapRec.address_Line3_Additional = item.address_Line3_Additional[0];
                    }
                    if(item.address_Line4_Additional.size() > 0){
                        wrapRec.address_Line4_Additional = item.address_Line4_Additional[0];
                    }
                    if(item.citY_ADDITIONAL.size() > 0){
                        wrapRec.citY_ADDITIONAL = item.citY_ADDITIONAL[0];
                    }
                    if(item.COUNTRY_ADDITIONAL.size() > 0){
                        wrapRec.COUNTRY_ADDITIONAL = item.COUNTRY_ADDITIONAL[0];
                    }
                    if(item.postcodE_ADDITIONAL.size() > 0){
                        wrapRec.postcodE_ADDITIONAL = item.postcodE_ADDITIONAL[0];
                    }
                    OrbisRecList.add(wrapRec);
                }
                
                edpRecList.OrbisResult = OrbisRecList;
                edpRecList.totalRecordCount = orbisRecordList.resultPayload.SearchSummary.totalRecordsFound;
                edpRecList.availableRecordCount = orbisRecordList.resultPayload.SearchSummary.recordsReturned;
            }
            edpRecList.accessToken = orbisRecordList.accessToken;
            edpRecList.responseCode = orbisRecordList.responseCode;
            edpRecList.responseMessage = orbisRecordList.responseMessage;
            edpRecList.isSuccess = orbisRecordList.isSuccess;
        }else if(dataSource == 'Bankers Almanac'){
            countryCode = BET_Utility.getCountryCodeByName(sIncCountry);
            BET_BDD_BankersWrapper.responseParametersBankers bankersRecordList = getBankersRecordSet(searchShortName, countryCode, sAccessToken);
            if(bankersRecordList.responseCode == 200){
                system.debug('bankersRecordList==resultPayload==Results' + bankersRecordList.resultPayload.Results);
                
                List<BET_EdpResponse_WrapperClass.BankersResult> BankersRecList = new List<BET_EdpResponse_WrapperClass.BankersResult>();
                
                for(BET_BDD_BankersWrapper.Results item: bankersRecordList.resultPayload.results){
                    BET_EdpResponse_WrapperClass.BankersResult wrapRec = new BET_EdpResponse_WrapperClass.BankersResult();
                    
                    wrapRec.bankersAlmanacId = item.legalEntity.bankersAlmanacId;
                    wrapRec.linkToFullDetails = item.legalEntity.linkToFullDetails;
                    wrapRec.status = item.legalEntity.status;
                    wrapRec.type = item.legalEntity.type;
                    wrapRec.lei = item.legalEntity.lei;
                    wrapRec.noOfDomesticOffices = item.legalEntity.noOfDomesticOffices;
                    wrapRec.noOfForeignOffices = item.legalEntity.noOfForeignOffices;
                    wrapRec.officeId = item.office.officeId;
                    wrapRec.giin = item.office.giin;
                    if(item.office.location.area != null){
                        wrapRec.area = item.office.location.area;
                    }
                    if(item.legalEntity.names.size() > 0){
                        wrapRec.name = item.legalEntity.names[0].value;
                        
                        List<String> PreviousNames = new List<String>();
                        List<String> TradingNames = new List<String>();
                        for(BET_BDD_BankersWrapper.names item1:item.legalEntity.names){
                            if(item1.type == 'Former Name'){
                                PreviousNames.add(item1.value);
                            }
                            if(item1.type == 'Marketing Name'){
                                TradingNames.add(item1.value);
                            }
                        }
                        if(PreviousNames.size() > 0){
                            string preName = PreviousNames.toString();
                            preName = preName.substring(1, preName.length()-1);
                            wrapRec.previousName = preName;
                        }
                        if(TradingNames.size() > 0){
                            string tradName = TradingNames.toString();
                            tradName = tradName.substring(1, tradName.length()-1);
                            wrapRec.tradingName = tradName;
                        }
                    }
                    
                    wrapRec.city = item.office.location.city;
                    wrapRec.country = item.office.location.country.name;
                    wrapRec.postalCode = item.office.location.postalCode;
                    wrapRec.subArea = item.office.location.subArea;
                    wrapRec.addressLine1 = item.office.location.streetAddress.addressLine1;
                    wrapRec.addressLine2 = item.office.location.streetAddress.addressLine2;
                    wrapRec.addressLine3 = item.office.location.streetAddress.addressLine3;
                    wrapRec.addressLine4 = item.office.location.streetAddress.addressLine4;
                    BankersRecList.add(wrapRec);
                }
                system.debug(BankersRecList);       
                
                edpRecList.bankersResult = BankersRecList;  
                edpRecList.totalRecordCount = bankersRecordList.resultPayload.totalResults;
                edpRecList.availableRecordCount = bankersRecordList.resultPayload.displayedResults;
            }
            edpRecList.accessToken = bankersRecordList.accessToken;
            edpRecList.responseCode = bankersRecordList.responseCode;
            edpRecList.responseMessage = bankersRecordList.responseMessage;
            edpRecList.isSuccess = bankersRecordList.isSuccess;
        }
        edpRecList.dataSource = dataSource;
        edpRecList.sourceType = sSource;
        return edpRecList;
    }
    
    public static BET_BDD_BankersWrapper.responseParametersBankers getBankersRecordSet(String searchShortName, string countryCode, string sAccessToken){
        /*if(searchShortName != '' || searchShortName != null){
            searchShortName = searchShortName.replace(' ', '%20'); 
        }*/
        
        BET_BDD_BankersWrapper.responseParametersBankers bankersDdata = BET_BDD_BankersCallout.getBankersData(searchShortName, countryCode, sAccessToken);
        
        system.debug('bankersDdata -- ' + bankersDdata);
        return bankersDdata;
    }
    
    public static BET_BDD_WrapperClass.responseParametersORBIS getOrbisRecordSet(String searchShortName, String sIncCountry, string sAccessToken){
        /*if(searchShortName != '' || searchShortName != null){
            searchShortName = searchShortName.replace(' ', '%20'); 
        }
        if(sIncCountry != '' || sIncCountry != null){
            sIncCountry = sIncCountry.replace(' ', '%20'); 
        }*/
        
        BET_BDD_WrapperClass.responseParametersORBIS orbisDdata = BET_BDD_ORBIS_Callout.getOrbisData(searchShortName, sIncCountry, sAccessToken);
        
        system.debug('orbisdata -- ' + orbisDdata);
        return orbisDdata;
    }
    
    @AuraEnabled
    public static BET_VerResponse_WrapperClass getVerificationStatus
        (string vatNum, string sCountry, string accessToken, string sLOB, string entType, string imoNum, string name){
       
        BET_VerResponse_WrapperClass verResponse = new BET_VerResponse_WrapperClass();
        try{
            //Get verification source
            string dataSource = '';
            map<string, string> dataSourceMap = BET_Utility.getSourceName(sLOB, entType, '', 'Verification');
            
            if(dataSourceMap.ContainsKey('SourceName') ){
                dataSource = dataSourceMap.get('SourceName');
            }
            system.debug('dataSourceMap ' + dataSourceMap);
            if(dataSource == 'VIES'){
                system.debug('vatNum : '+vatNum+'  sCountry'+sCountry);       
                String sCountryCode = BET_Utility.countryISOMatcher(sCountry);
                system.debug('sCountryCode ' + sCountryCode);
 
                if((sCountryCode != '') && (vatNum != null || vatNum != '')){
                    vatNum = vatNum.replace(sCountryCode, '');
                    vatNum = vatNum.replace(' ', '');
                    if(sCountry == 'Belgium'){
                        vatNum = vatNum.replace('.', ''); 
                    }
                    BET_BDD_WrapperClass.responseParametersPdfFiles viesRes = getViesPdf(vatNum, sCountryCode, accessToken);
                    if(viesRes.responseCode == 200){
                        verResponse.resultPayload = viesRes.resultPayload;
                    }
                    verResponse.responseMessage = viesRes.responseMessage;
                    verResponse.isSuccess = viesRes.isSuccess;
                    verResponse.responseCode = viesRes.responseCode;
                    verResponse.accessToken = viesRes.accessToken;
                }else{
                     verResponse.responseMessage = 'Mentioned country is not valid for VIES verification.';
                }
            }else if(dataSource == 'OFAC'){
                imoNum = imoNum.replace(' ', '');
                BET_BDD_OFAC_WrapperClass ofacRes = getOfacPdf(imoNum, accessToken);
                if(ofacRes.responseCode == 200){
                    verResponse.resultPayload = ofacRes.resultPayload;
                }
                verResponse.responseMessage = ofacRes.responseMessage;
                verResponse.isSuccess = ofacRes.isSuccess;
                verResponse.responseCode = ofacRes.responseCode;
                verResponse.accessToken = ofacRes.accessToken;
            }else if(dataSource == 'IRS'){
                system.debug('vatNum : '+vatNum);       
                //String sCountryCode = BET_Utility.countryISOMatcher(sCountry);
                if(vatNum != null || vatNum != ''){
                    vatNum = vatNum.replace(' ', '');
                }
                
                BET_BDD_WrapperClass.responseParametersPdfFiles irsResult = getIrsPdf(name, vatNum, accessToken);
                if(irsResult.responseCode == 200){
                    verResponse.resultPayload = irsResult.resultPayload;
                }
                verResponse.responseMessage = irsResult.responseMessage;
                verResponse.isSuccess = irsResult.isSuccess;
                verResponse.responseCode = irsResult.responseCode;
                verResponse.accessToken = irsResult.accessToken;
            }
            system.debug('verification dara source >> ' + dataSource);
            verResponse.verificationSource = dataSource;
        }catch(exception ex){
            system.debug('Error in getVerificationStatus method: ' + ex.getMessage());
        }     
        return verResponse; 
    }
    
    //Verification: VIES
    public static BET_BDD_WrapperClass.responseParametersPdfFiles getViesPdf(string vatNum, string countryCode, string accessToken){
        BET_BDD_WrapperClass.responseParametersPdfFiles viesRes = BET_BDD_VIES_Callout.getViesData(vatNum, countryCode, accessToken);
        return viesRes;
    }
    
    //Verification: OFAC
    public static BET_BDD_OFAC_WrapperClass getOfacPdf(string imoNum, string accessToken){
        BET_BDD_OFAC_WrapperClass ofacRes = BET_BDD_OFAC_Callout.getOFACData(imoNum, '', 'I', accessToken);
        return ofacRes;
    }
    
    //Verification: IRS/SOVOS
    public static BET_BDD_WrapperClass.responseParametersPdfFiles getIrsPdf(string name, string tinNumber, string accessToken){
        BET_BDD_WrapperClass.responseParametersPdfFiles irsRes = BET_BDD_SovosCallout.getSovosData(name, tinNumber, '', accessToken);
        return irsRes;
    }
    
    @AuraEnabled
    public static newBddFormCrResponse getNewBddFormId(BET_BDD_Form__c newBddForm, object orbisRecord, object bankersRecord, 
                                         boolean UIVerfDone, string verfTaxVATNum, string verfCountry, object gtmiRec, string accessToken, 
                                         string vesselName){
        system.debug('newBddForm ' + newBddForm);
        string sRecordId       = null;
        string verSource       = '';
        string region          = newBddForm.BDD_Line_of_Business__c;
        string entType         = newBddForm.BDD_Entity_Type__c;
        string onBoardingType  = newBddForm.BDD_Onboard_Type__c;
        string primarySource   = '';
        string secondarySource = '';
        string bvdId = '';
        map<string, string> dataSourceMap = new map<string, string>();
        BET_EdpResponse_WrapperClass.OrbisResult orbisRecWrap = null;
        BET_EdpResponse_WrapperClass.BankersResult bankersRecWrap = null;
        BET_BDD_GTMI_WrapperClass.resultPayload gtmiRecWrap = null;
        BET_BDD_Bankers_baidWrapper.responseParameterBaid bankersBaidWrap = null;
        //boolean legalNameAv = false;
        string orbislegalName = ''; string orbisEntType = ''; string orbisIncCountry = ''; string orbisIncState = '';
        string docPrimSource = ''; string docSecSource = ''; string orbisTradingName = ''; boolean picklistValAv = false;
        string bankersAlmanacId = ''; string bankersLegalName = ''; string baid = ''; integer baidResponseCode = 0; string baidResponseMsg = '';
        string matchPeps = ''; string mactchSanc = ''; string matchNegStories = ''; string taxId = ''; 
        string enfInd = ''; string soeInd = ''; string govtLinkedInd = ''; string assEntInd = ''; string regInd = '';
        List<BET_Utility.BddDocumentWrap> bddDocWrapList = new List<BET_Utility.BddDocumentWrap>();
        BET_BDD_Bankers_baidWrapper.responseParameterBaid bankersDetailsByBaid = null; 
        BET_BDD_BankersDetailsWrapper bankBaidDetails = null; boolean allowNewRecordCr = true;
        newBddFormCrResponse newRecWrap = new newBddFormCrResponse();
        list<string> coreBusPickList = new list<string>();
        //list<string> picklistValues = new list<string>();
        list<string> gtPicklistValues = BET_Utility.getPickListValuesIntoList('BET_Registration_Details__c', 'Registration_Country__c');
        list<string> mdnPicklistValues = BET_Utility.getPickListValuesIntoList('BET_BDD_Form__c', 'MDN_CD_Country_of_Inc__c');
                                             
        try{        
            //Get bankers details
            if(bankersRecord != '""'){
                system.debug('2');
                bankersRecWrap = (BET_EdpResponse_WrapperClass.BankersResult)JSON.deserialize(bankersRecord.toString(), BET_EdpResponse_WrapperClass.BankersResult.class);
                system.debug('bankersRecWrap' + bankersRecWrap);
                baid = bankersRecWrap.bankersAlmanacId;
            }
            system.debug('Bankers API 2 >> ' + baid);
            if(bankersRecord != '""' && baid != ''){
                //call baid api 
                bankersDetailsByBaid = getBankersDetailsByBaid(baid, accessToken); 
                system.debug('bankersDetailsByBaid res >> ' + bankersDetailsByBaid);
                baidResponseCode = bankersDetailsByBaid.responseCode;
                baidResponseMsg = bankersDetailsByBaid.responseMessage;
                
                //parse baid api response
                if(bankersDetailsByBaid != null && baidResponseCode == 200){
                    bankBaidDetails = parseBaidDetailsWrapper(bankersDetailsByBaid);
                }
            }
            if(bankersRecord != '""' && bankersDetailsByBaid.responseCode != 200){
                //allowNewRecordCr = false;
                newRecWrap.baidApiStatus = 'Failed';
            }
            
            dataSourceMap = BET_Utility.getDataSourceMapping(region, entType);
            if(!dataSourceMap.isEmpty()){
                primarySource = dataSourceMap.get('Primary');
                secondarySource = dataSourceMap.get('Secondary');
            }
            system.debug('primarySource: ' + primarySource + ';secondarySource: ' + secondarySource);
            system.debug('orbisRecord' + orbisRecord);
            system.debug('bankersRecord' + bankersRecord);
            if(gtmiRec != '""'){
                gtmiRecWrap = (BET_BDD_GTMI_WrapperClass.resultPayload)JSON.deserialize(gtmiRec.toString(), BET_BDD_GTMI_WrapperClass.resultPayload.class);            
            }
            if(orbisRecord != '""'){
                orbisRecWrap = (BET_EdpResponse_WrapperClass.OrbisResult)JSON.deserialize(orbisRecord.toString(), BET_EdpResponse_WrapperClass.OrbisResult.class); 
            }
            
            BET_BDD_Form__c newBddRecord = newBddForm;
            if(orbisRecWrap != null || bankersRecWrap != null){
                if(primarySource == 'Orbis' && orbisRecWrap != null){
                    system.debug('Orbis >> primary');
                    docPrimSource = 'Orbis';
                    orbislegalName = orbisRecWrap.name;
                    
                    if(orbislegalName != ''){
                        newBddRecord.GT_Legal_Name__c = orbislegalName;
                        newBddRecord.MDN_OI_Full_Legal_Name__c = orbislegalName;
                        newBddRecord.MDN_OI_ShortName__c = orbislegalName;
                    }
                    orbisTradingName = orbisRecWrap.akA_NAME_Str;
                    if(orbisTradingName != ''){
                        newBddRecord.GT_Trading_Name__c = orbisTradingName;
                    }else if(orbislegalName != ''){
                        newBddRecord.GT_Trading_Name__c = orbislegalName;
                    }
                    
                    orbisEntType = orbisRecWrap.entitY_TYPE;
                    if(orbisEntType != ''){
                        //newBddRecord.GT_Entity_Type__c = orbisEntType;
                    }
                    orbisIncCountry = orbisRecWrap.country;
                    if(orbisIncCountry != ''){
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisIncCountry, mdnPicklistValues);
                        if(picklistValAv == true){
                           newBddRecord.MDN_CD_Country_of_Inc__c = orbisIncCountry; 
                        }
                    }
                    orbisIncState = orbisRecWrap.uS_STATE;
                    if(orbisIncState != '' && 
                       (orbisIncCountry == 'United States' || orbisIncCountry == 'Canada' || orbisIncCountry == 'United States of America' || 
                        orbisIncCountry == 'USA')){
                            newBddRecord.MDN_CD_State_Province_Region__c = orbisIncState;
                        }
                    
                    if(orbisRecWrap.lei != '' || !(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty()){
                        newBddRecord.GT_Is_Comp_Reg__c = true;
                    }
                    bvdId = orbisRecWrap.bvdid; 
                    if(orbisRecWrap.PRODUCTS_SERVICES != ''){
                        newBddRecord.GT_Nature_of_Business__c = orbisRecWrap.PRODUCTS_SERVICES;
                    }
                    if(orbisRecWrap.NAICS2017_CORE_LABEL != ''){
                        newBddRecord.MDN_CD_Core_Business__c = orbisRecWrap.NAICS2017_CORE_LABEL;
                        coreBusPickList = BET_Utility.getCoreBusPicklistValuesByName();
                        if(coreBusPickList.contains(orbisRecWrap.NAICS2017_CORE_LABEL)){
                            newBddRecord.GT_Core_Business_Act__c = orbisRecWrap.NAICS2017_CORE_LABEL; 
                        }
                    }
                    
                    matchPeps = orbisRecWrap.WORLDCOMPLIANCE_MATCH_CURRENT_PEP_INDICATOR;
                    mactchSanc = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SANCTION_INDICATOR;
                    matchNegStories = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ADVERSE_MEDIA_INDICATOR;
                    enfInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ENFORCEMENT_INDICATOR;
                    soeInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SOE_INDICATOR; 
                    govtLinkedInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_GOVERNMENT_LINKED_INDICATOR; 
                    assEntInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ASSOCIATED_ENTITY_INDICATOR;
                    regInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_REGISTRATIONS_INDICATOR;
                    
                    if(matchPeps == 'true' || mactchSanc == 'true' || enfInd == 'true' || soeInd == 'true' || govtLinkedInd == 'true'
                      || assEntInd == 'true' || regInd == 'true'){
                        newBddRecord.PEPs_and_Sanc_Found__c = 'Yes';
                    }else{
                        newBddRecord.PEPs_and_Sanc_Found__c = 'No';
                    }
                    if(matchNegStories == 'true'){
                        newBddRecord.Negative_Stories_Found__c = 'Yes';
                    }else{
                        newBddRecord.Negative_Stories_Found__c = 'No';
                    }
                    if(region == 'WONA'){
                        system.debug('WONA >> orbis >> Fill related fields');
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        if(taxId != ''){
                            newBddRecord.MDN_CD_PVAT_TaxNum__c = taxId;
                        }
                        system.debug('MDN CD >> Reg number mapping');
                        string mdnCdRegNum = getOrbisRegNumforMdnCd(orbisRecWrap, taxId);
                        if(mdnCdRegNum != ''){
                            newBddRecord.MDN_CD_RegNum__c = mdnCdRegNum;
                        }
                    }
                }else if(primarySource == 'Bankers Almanac' && bankersRecWrap != null){
                    system.debug('Bankers >> primary');
                    docPrimSource = 'Bankers Almanac';
                    bankersAlmanacId = bankersRecWrap.bankersAlmanacId;
                    bankersLegalName = bankersRecWrap.name;
                    if(bankersLegalName != ''){
                        newBddRecord.GT_Legal_Name__c = bankersLegalName;
                        newBddRecord.MDN_OI_Full_Legal_Name__c = bankersLegalName;
                        newBddRecord.MDN_OI_ShortName__c = bankersLegalName;
                    }
                    system.debug('bankersAlmanacId:' + bankersAlmanacId);
                    if(bankersAlmanacId != ''){
                        bankersBaidWrap = getBankersDetailsByBaid(bankersAlmanacId, accessToken);
                        system.debug('bankersBaidWrap response***' + bankersBaidWrap);
                    }
                    if(bankersRecWrap.lei != ''){
                        newBddRecord.GT_Is_Comp_Reg__c = true;
                    }
                    
                    if(bankBaidDetails.tradingName != null){
                        newBddRecord.GT_Trading_Name__c = bankBaidDetails.tradingName;
                    }else if(bankersLegalName != ''){
                        newBddRecord.GT_Trading_Name__c = bankersLegalName;
                    }
                    
                    system.debug('bankersRecWrap.country >> ' + bankersRecWrap.country);
                    if(bankersRecWrap.country != ''){
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(bankersRecWrap.country, mdnPicklistValues);
                        if(picklistValAv == true){
                            newBddRecord.MDN_CD_Country_of_Inc__c = bankersRecWrap.country; 
                        }
                    }
                    
                    if(region == 'WONA'){
                        string bankerRegNum = getBankersRegNumforMdnCd(bankersRecWrap);
                        if(bankerRegNum != ''){
                            newBddRecord.MDN_CD_RegNum__c = bankerRegNum;
                        }
                    }                    
                }
                
                if(secondarySource == 'Orbis' && orbisRecWrap != null){
                    system.debug('Orbis >> secondary');
                    docSecSource = 'Orbis';
                    orbislegalName = orbisRecWrap.name;
                    if(newBddRecord.GT_Legal_Name__c == null && orbislegalName != ''){
                        newBddRecord.GT_Legal_Name__c = orbislegalName;
                    }
                    if(newBddRecord.MDN_OI_Full_Legal_Name__c == null && orbislegalName != ''){
                        newBddRecord.MDN_OI_Full_Legal_Name__c = orbislegalName;
                    }
                    if(newBddRecord.MDN_OI_ShortName__c == null && orbislegalName != ''){
                        newBddRecord.MDN_OI_ShortName__c = orbislegalName;
                    }
                    orbisTradingName = orbisRecWrap.akA_NAME_Str;  
                    if(newBddRecord.GT_Trading_Name__c == null && orbisTradingName != ''){
                        newBddRecord.GT_Trading_Name__c = orbisTradingName;
                    }else if(newBddRecord.GT_Trading_Name__c == null && orbislegalName != ''){
                        newBddRecord.GT_Trading_Name__c = orbislegalName;
                    }
                    
                    orbisEntType = orbisRecWrap.entitY_TYPE;
                    if(newBddRecord.GT_Entity_Type__c == null && orbisEntType != ''){
                        //newBddRecord.GT_Entity_Type__c = orbisEntType;
                    }
                    orbisIncCountry = orbisRecWrap.country;
                    if(newBddRecord.MDN_CD_Country_of_Inc__c == null && orbisIncCountry != ''){
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisIncCountry, mdnPicklistValues);
                        if(picklistValAv == true){
                            newBddRecord.MDN_CD_Country_of_Inc__c = orbisIncCountry; 
                        }
                    }
                    orbisIncState = orbisRecWrap.uS_STATE;
                    if(newBddRecord.MDN_CD_State_Province_Region__c == null && orbisIncState != '' 
                       && (orbisIncCountry == 'United States' || orbisIncCountry == 'Canada' || orbisIncCountry == 'United States of America' 
                           || orbisIncCountry == 'USA')){
                               newBddRecord.MDN_CD_State_Province_Region__c = orbisIncState;
                           }
                    
                    if(newBddRecord.GT_Is_Comp_Reg__c != true && (orbisRecWrap.lei != '' || !(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty())){
                        newBddRecord.GT_Is_Comp_Reg__c = true;
                    }
                    bvdId = orbisRecWrap.bvdid; 
                    if(newBddRecord.GT_Nature_of_Business__c == null && orbisRecWrap.PRODUCTS_SERVICES != ''){
                        newBddRecord.GT_Nature_of_Business__c = orbisRecWrap.PRODUCTS_SERVICES;
                    }
                    if(orbisRecWrap.NAICS2017_CORE_LABEL != ''){
                        if(newBddRecord.MDN_CD_Core_Business__c == null){
                            newBddRecord.MDN_CD_Core_Business__c = orbisRecWrap.NAICS2017_CORE_LABEL; 
                        }
                        
                        coreBusPickList = BET_Utility.getCoreBusPicklistValuesByName();
                        if(newBddRecord.GT_Core_Business_Act__c == null && coreBusPickList.contains(orbisRecWrap.NAICS2017_CORE_LABEL)){
                            newBddRecord.GT_Core_Business_Act__c = orbisRecWrap.NAICS2017_CORE_LABEL; 
                        }
                    }
                    matchPeps = orbisRecWrap.WORLDCOMPLIANCE_MATCH_CURRENT_PEP_INDICATOR;
                    mactchSanc = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SANCTION_INDICATOR;
                    matchNegStories = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ADVERSE_MEDIA_INDICATOR;
                    enfInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ENFORCEMENT_INDICATOR;
                    soeInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SOE_INDICATOR; 
                    govtLinkedInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_GOVERNMENT_LINKED_INDICATOR; 
                    assEntInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ASSOCIATED_ENTITY_INDICATOR;
                    regInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_REGISTRATIONS_INDICATOR;
                    
                    if(newBddRecord.PEPs_and_Sanc_Found__c == null && (matchPeps == 'true' || mactchSanc == 'true' || enfInd == 'true' || 
                                                                       soeInd == 'true' || govtLinkedInd == 'true' || assEntInd == 'true' || regInd == 'true')){
                        newBddRecord.PEPs_and_Sanc_Found__c = 'Yes';
                    }else{
                        newBddRecord.PEPs_and_Sanc_Found__c = 'No';
                    }

                    if(newBddRecord.Negative_Stories_Found__c == null){
                        if(matchNegStories == 'true'){
                            newBddRecord.Negative_Stories_Found__c = 'Yes';
                        }else{
                            newBddRecord.Negative_Stories_Found__c = 'No';
                        }
                    }
                    
                    if(region == 'WONA'){
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        if(taxId != '' && newBddRecord.MDN_CD_PVAT_TaxNum__c == null){
                            newBddRecord.MDN_CD_PVAT_TaxNum__c = taxId;
                        }
                        system.debug('MDN CD >> Reg number mapping');
                        if(newBddRecord.MDN_CD_RegNum__c == null){
                            string mdnCdRegNum = getOrbisRegNumforMdnCd(orbisRecWrap, taxId);
                            if(mdnCdRegNum != ''){
                                newBddRecord.MDN_CD_RegNum__c = mdnCdRegNum;
                            }   
                        }
                    }
                }else if(secondarySource == 'Bankers Almanac' && bankersRecWrap != null){
                    docSecSource = 'Bankers Almanac';
                }
            }else{
                //when there is no record selected in EDP search
                if(region == 'GLOBAL'){
                    newBddRecord.GT_Legal_Name__c = vesselName;
                    newBddRecord.GT_Short_Name__c = vesselName;
                }else{
                    newBddRecord.GT_Legal_Name__c = newBddForm.Full_Legal_Name__c;
                    newBddRecord.MDN_OI_Full_Legal_Name__c = newBddForm.Full_Legal_Name__c;
                    newBddRecord.MDN_OI_ShortName__c = newBddForm.Full_Legal_Name__c;
                }
            }
            
            system.debug('insert new record >> ');
            newBddRecord.recordTypeId = BET_Utility.getRecordTypeId(region, entType, onBoardingType);
            if(newBddRecord != null){
                if(region == 'WONA' || region == 'SENA'){
                    newBddRecord.MDN_PC_Type__c = 'Main'; 
                }else if(region == 'STUSCO'){
                    newBddRecord.MDN_PC_Type__c = 'Invoice'; 
                }
                
                if(newBddRecord.BDD_Onboard_Type__c == 'Remediation Update'){
                    newBddRecord.GT_Is_Rem__c = 'Yes';
                    newBddRecord.MDN_Status__c = '';
                }else{
                    newBddRecord.GT_Is_Rem__c = 'No';
                }
                
                if(newBddRecord.BDD_Entity_Type__c == 'Vessel'){
                    newBddRecord.GT_Product_Risk__c = 'High';
                    newBddRecord.GT_Cust_Entity_Type_Class__c = 'Vessel';
                    newBddRecord.GT_BDD_Region_Role_Comm__c = 'WORLDWIDE | Vessel';
                    //commented by Ashish J. on 20/09/2021 for changing the field type to Multiselect picklist
                    //newBddRecord.GT_BDD_Commodity__c = 'N/A';
                    //newBddRecord.GT_BDD_Business_Division__c = 'Shipping';
                    newBddRecord.MDN_Status__c = '';
					//uncommented the above code by Ashish J. on 7th Oct 2021 after field type change is deployed
					//check
                }else{
                    newBddRecord.GT_Product_Risk__c = 'Low';
                }
                
                if(gtmiRecWrap != null && (newBddRecord.BDD_Onboard_Type__c == 'Remediation Update' || newBddRecord.BDD_Onboard_Type__c == 'Related Party Update')){
                    newBddRecord.GT_GoldTier_Id__c = gtmiRecWrap.goldtieR_ID;  
                }
                
                string userId = UserInfo.getUserId();
                User activeUser = [Select firstname, lastname, Email From User where Id =: userId limit 1];
                if(activeUser != null){
                    string requestorName = activeUser.Email;
                    integer maxLength = requestorName.indexOf('@');
                    requestorName = requestorName.substring(0, maxLength);
                    newBddRecord.MDN_OI_Requester__c = requestorName;
                    if(requestorName != ''){
                        list<string> nameList = requestorName.split('\\.');
                        requestorName = '';
                        for(string name: nameList){
                            requestorName = requestorName + ' ' + name;
                        }
                        newBddRecord.GT_Req_Name__c = requestorName.trim();
                    }
                }
               
                Integer mdnOIShortNameLength = SObjectType.BET_BDD_Form__c.Fields.MDN_OI_ShortName__c.Length;
                Integer mdnCoreBusLength = SObjectType.BET_BDD_Form__c.Fields.MDN_CD_Core_Business__c.Length;
                Integer regNumLength = SObjectType.BET_BDD_Form__c.Fields.MDN_CD_RegNum__c.Length;
                Integer taxNumLength = SObjectType.BET_BDD_Form__c.Fields.MDN_CD_PVAT_TaxNum__c.Length;

                if(newBddRecord.MDN_OI_ShortName__c != null){
                    newBddRecord.MDN_OI_ShortName__c = BET_Utility.truncateText(newBddRecord.MDN_OI_ShortName__c, mdnOIShortNameLength);
                }                
                if(newBddRecord.MDN_CD_Core_Business__c != null){
                    newBddRecord.MDN_CD_Core_Business__c = BET_Utility.truncateText(newBddRecord.MDN_CD_Core_Business__c, mdnCoreBusLength);
                }
                if(newBddRecord.MDN_CD_RegNum__c != null){
                    newBddRecord.MDN_CD_RegNum__c = BET_Utility.truncateText(newBddRecord.MDN_CD_RegNum__c, regNumLength);
                }
                if(newBddRecord.MDN_CD_PVAT_TaxNum__c != null){
                    newBddRecord.MDN_CD_PVAT_TaxNum__c = BET_Utility.truncateText(newBddRecord.MDN_CD_PVAT_TaxNum__c, taxNumLength); 
                }
                newBddRecord.Last_Modifiedby_User__c = userId;   
                try{
                    insert newBddRecord;
                }catch(exception ex){
                    system.debug('Issue in creating new BET Form >> ' + ex.getMessage());
                }
                sRecordId = newBddRecord.Id;
            }
            
            //map EDP data to BET form
            list<BET_Registration_Details__c> regDetailsList = new list<BET_Registration_Details__c>();
            list<BET_BDD_Address__c> addressList             = new list<BET_BDD_Address__c>();
            list<BET_BDD_Address__c> addrTempList            = new list<BET_BDD_Address__c>();
            BET_Registration_Details__c regDetail            = new BET_Registration_Details__c();
            string lei = ''; string giin = '';
            boolean regAddrAv = false; boolean traAddrAv = false; boolean taxIdAv = false;
            boolean leiAv = false; boolean giinAv = false; boolean regNumAv = false;
            boolean mapLegalAddrToOperAddr = false;
            
            if(sRecordId != null || sRecordId != ''){
                newRecWrap.recId = sRecordId;
                if(orbisRecWrap != null || bankersRecWrap != null){
                    system.debug('Start >> Add child records to BDD form');
                    //primary source field mapping
                    if(primarySource == 'Orbis' && orbisRecWrap != null){
                        system.debug('Start >> Primary >> Orbis');
                        if(orbisRecWrap.bvdid != null){
                            bvdId = orbisRecWrap.bvdid;
                        }
                        if(orbisRecWrap.addresS_LINE1 != null){
                            if(orbisRecWrap.address_Line1_Additional == null){
                                mapLegalAddrToOperAddr = true;
                            }
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Registered', onBoardingType, gtPicklistValues, mdnPicklistValues, mapLegalAddrToOperAddr);
                            addressList.addAll(addrTempList);
                            regAddrAv = true;
                        }
                        if(orbisRecWrap.address_Line1_Additional != null){
                            addrTempList = null;
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Trading', onBoardingType, gtPicklistValues, mdnPicklistValues, false);
                            addressList.addAll(addrTempList);
                            traAddrAv = true;
                        }
                        
                        //check if the country is part of picklist
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisRecWrap.country, gtPicklistValues);
                        if(picklistValAv == false){
                            orbisRecWrap.country = '';
                        }
                        
                        lei = orbisRecWrap.lei;
                        if(lei != ''){
                            regDetail = getRegDetailRec('LEI', lei, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            leiAv = true;
                        }
                        if(!(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty()){
                            string regNum = orbisRecWrap.tradE_REGISTER_NUMBER.toString();
                            regNum = regNum.substring(1, regNum.length() - 1);
                            regDetail = null;
                            regDetail = getRegDetailRec('Registration Number', regNum, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            regNumAv = true;
                        }
                        taxId = '';
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        system.debug('registration details map >> taxId >> ' + taxId);
                        if(taxId != ''){
                            regDetail = getRegDetailRec('Tax ID', taxId, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            taxIdAv = true;
                        }
                    }else if(primarySource == 'Bankers Almanac' && bankersRecWrap != null){
                        system.debug('Start >> Primary >> Bankers');
                        lei = bankersRecWrap.lei;
                        system.debug('lei >> ' + lei);
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(bankersRecWrap.country, gtPicklistValues);
                        if(picklistValAv == false){
                            bankersRecWrap.country = ''; 
                        }
                        
                        if(lei != null){
                            regDetail = null;
                            regDetail = getRegDetailRec('LEI', lei, bankersRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            leiAv = true;
                        }
                        //system.debug('bankersRecWrap.giin >> ' + bankersRecWrap.giin);  
                        if(!(bankersRecWrap.giin).isEmpty()){
                            giin = bankersRecWrap.giin.toString();
                            giin = giin.substring(1, giin.length() - 1);
                            regDetail = null;
                            regDetail = getRegDetailRec('Other', GIIN, bankersRecWrap.country, sRecordId);
                            regDetail.Registration_Type_Other__c = 'GIIN';
                            regDetailsList.add(regDetail);
                            giinAv = true;
                        }
                        system.debug('bankBaidDetails >> ' + bankBaidDetails);
                        //bankBaidDetails = null;
                        if(bankBaidDetails != null){
                            system.debug('bankBaidDetails >> not null');
                            system.debug('bankBaidDetails.regAddressLine1 >> ' + bankBaidDetails.regAddressLine1);

                            if(bankBaidDetails.regAddressLine1 != null){
                                if(bankBaidDetails.tradAddressLine1 == null){
                                    mapLegalAddrToOperAddr = true;
                                }                                
                                addrTempList = createBankersAddressRec(sRecordId, bankBaidDetails, region, 'Registered', onBoardingType, 
                                                                       gtPicklistValues, mdnPicklistValues, mapLegalAddrToOperAddr);
                                if(addrTempList.size() > 0){
                                    addressList.addAll(addrTempList);
                                    regAddrAv = true;
                                }
                                system.debug('temp address list' + addrTempList);
                            }
                            system.debug('bankBaidDetails.tradAddressLine1 >> ' + bankBaidDetails.tradAddressLine1);
                            if(bankBaidDetails.tradAddressLine1 != null){
                                addrTempList = null;
                                addrTempList = createBankersAddressRec(sRecordId, bankBaidDetails, region, 'Trading', onBoardingType, 
                                                                       gtPicklistValues, mdnPicklistValues, false);
                                if(addrTempList.size() > 0){
                                    addressList.addAll(addrTempList);
                                    traAddrAv = true;
                                }
                            }
                        }else{
                            system.debug('map registered address from bankers >> API 1');
                            system.debug('bankersRecWrap >> ' + bankersRecWrap.addressLine1);
                            if(bankersRecWrap.addressLine1 != null){
                                bankBaidDetails = new BET_BDD_BankersDetailsWrapper();
                                addrTempList = null;
                                bankBaidDetails.regAddressLine1 = bankersRecWrap.addressLine1;
                                bankBaidDetails.regAddressLine2 = bankersRecWrap.addressLine2;
                                bankBaidDetails.regAddressLine3 = bankersRecWrap.addressLine3;
                                bankBaidDetails.regAddressLine4 = bankersRecWrap.addressLine4;
                                bankBaidDetails.regCity = bankersRecWrap.city;
                                bankBaidDetails.regcountry = bankersRecWrap.country;
                                bankBaidDetails.regPostalCode = bankersRecWrap.postalCode;
                                addrTempList = createBankersAddressRec(sRecordId, bankBaidDetails, region, 'Registered', onBoardingType, 
                                                                       gtPicklistValues, mdnPicklistValues, true);
                                if(addrTempList.size() > 0){
                                    addressList.addAll(addrTempList);
                                    regAddrAv = true;
                                }
                            }
                        }
                    }
                    
                    //secondary source field mapping
                    if(secondarySource == 'Orbis' && orbisRecWrap != null){
                        system.debug('secondary >> Orbis >> started');
                        if(regAddrAv == false && orbisRecWrap.addresS_LINE1 != null){
                            addrTempList = null;
                            if(orbisRecWrap.address_Line1_Additional == null){
                                mapLegalAddrToOperAddr = true;
                            }
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Registered', onBoardingType, gtPicklistValues, 
                                                                 mdnPicklistValues, mapLegalAddrToOperAddr);
                            addressList.addAll(addrTempList);
                        }
                        
                        if(traAddrAv == false && orbisRecWrap.address_Line1_Additional != null){
                            addrTempList = null;
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Trading', onBoardingType, gtPicklistValues, 
                                                                 mdnPicklistValues, false);
                            addressList.addAll(addrTempList);
                            traAddrAv = true;
                        }
                        
                        //check if the country is part of picklist
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisRecWrap.country, gtPicklistValues);
                        if(picklistValAv == false){
                            orbisRecWrap.country = '';
                        }
                        system.debug('orbisRecWrap.country >> ' + orbisRecWrap.country);
                        lei = orbisRecWrap.lei;
                        if(leiAv == false && lei != ''){
                            regDetail = null;
                            regDetail = getRegDetailRec('LEI', lei, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                        }
                        if(regNumAv == false && !(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty() && regAddrAv == false){
                            system.debug('seconday >> orbis >> reg address added');
                            string regNum = orbisRecWrap.tradE_REGISTER_NUMBER.toString();
                            regNum = regNum.substring(1, regNum.length() - 1);
                            regDetail = null;
                            regDetail = getRegDetailRec('Registration Number', regNum, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                        }
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        if(taxIdAv == false && taxId != ''){
                            regDetail = null;
                            regDetail = getRegDetailRec('Tax ID', taxId, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                        }
                    }else if(secondarySource == 'Bankers Almanac' && bankersRecWrap != null){
                        
                    }
                }
                
                //document section   
                system.debug('*****Upload document section***');    
                string verCountryCode = '';
                map<string, string> verSourceMap = BET_Utility.getSourceName(region, entType, '', 'Verification');
                system.debug('verSourceMap >> ' + verSourceMap);
                if(verSourceMap.ContainsKey('SourceName')){
                    verSource = verSourceMap.get('SourceName');
                }
                system.debug('bankersAlmanacId >> ' + bankersAlmanacId);
                BET_Utility.BddDocumentWrap bddDocWrap = new BET_Utility.BddDocumentWrap();
                bddDocWrap.bvdId = bvdId;
                bddDocWrap.baId = bankersAlmanacId;
                bddDocWrap.formRecId = sRecordId;
                bddDocWrap.bddRegion = region;
                bddDocWrap.entityType = entType;
                bddDocWrap.gtLegalName = newBddRecord.GT_Legal_Name__c;                
                bddDocWrap.primarySource = docPrimSource;
                bddDocWrap.secondarySource = docSecSource;
                if(UIVerfDone == true){
                    system.debug('**UI Verifcation is done**');
                    system.debug('verSource is ' + verSource);
                    system.debug('ver tax id is ' + verfTaxVATNum);
                    bddDocWrap.verficationSource = verSource;
                    if(verSource == 'VIES'){
                        verCountryCode = BET_Utility.countryISOMatcher(verfCountry);
                        verfTaxVATNum = verfTaxVATNum.replace(verCountryCode, '');
                        bddDocWrap.taxVATNumber = verfTaxVATNum;
                        bddDocWrap.countryCode = verCountryCode;
                    }else if(verSource == 'IRS'){
                        bddDocWrap.taxVATNumber = verfTaxVATNum;
                    }else if(verSource == 'OFAC' && newBddRecord.Srch_Vsl_Name_or_IMO__c != ''){
                        system.debug('verf OFAC: IMO# > ' + newBddRecord.Srch_Vsl_Name_or_IMO__c);
                        bddDocWrap.imoNumber = Integer.valueof(newBddRecord.Srch_Vsl_Name_or_IMO__c);
                    }
                }
                bddDocWrapList.add(bddDocWrap);
            }
            
            if(bddDocWrapList.size() > 0){
                BET_Utility.createBddDocument(bddDocWrapList);
            }
            
            if(regDetailsList.size() > 0){
                try{
                    database.insert(regDetailsList);
                }catch(exception ex){
                    system.debug('BET_BDD_Search_Controller >> inserting registration child records : ' + ex.getMessage());
                }
            }
            
            if(addressList.size() > 0){
                try{
                    database.insert(addressList);
                }catch(exception ex){
                    system.debug('BET_BDD_Search_Controller >> inserting address child records : ' + ex.getMessage());
                }
            }
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> getNewBddFormId() : ' + ex.getMessage());
        }
        return newRecWrap;
    }
    
    public static boolean checkIfPicklistValExists(string respValue, list<string> picklistValues){
        boolean picklistValAv = false;
        try{
            if(picklistValues.size() > 0 && picklistValues.contains(respValue)){
                picklistValAv = true;
            }
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> checkIfPicklistValExists() : ' + ex.getMessage());
        }
        return picklistValAv;
    }
    
    public static string getOrbisRegNumforMdnCd(BET_EdpResponse_WrapperClass.OrbisResult orbisRecWrap, string taxId){
        string regNumber = '';
        try{
            if(orbisRecWrap.tradE_REGISTER_NUMBER != null){
                string tradRegNum = orbisRecWrap.tradE_REGISTER_NUMBER.toString();
                tradRegNum = tradRegNum.substring(1, tradRegNum.length() - 1);
                regNumber = tradRegNum;
            }else if(orbisRecWrap.companY_ID_NUMBER != null){
                string orbisCompId = orbisRecWrap.companY_ID_NUMBER.toString();
                orbisCompId = orbisCompId.substring(1, orbisCompId.length() - 1);
                regNumber = orbisCompId;
            }else if(taxId != ''){
                regNumber = taxId;
            }else if(orbisRecWrap.lei != ''){
                regNumber = orbisRecWrap.lei;
            }
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> getOrbisRegNumforMdnCd : ' + ex.getMessage());
        }        
        return regNumber;
    }
    
    public static string getBankersRegNumforMdnCd(BET_EdpResponse_WrapperClass.BankersResult bankersRecWrap){
        string regNumber = '';
        try{
            if(bankersRecWrap.lei != ''){
                regNumber = bankersRecWrap.lei;
            }
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> getBankersRegNumforMdnCd : ' + ex.getMessage());
        }        
        return regNumber;
    }
    
    public static string getTaxIdFromWrapper(BET_EdpResponse_WrapperClass.OrbisResult orbisRecWrap, string region){
        string taxId = '';
        string orbisCountry = orbisRecWrap.country;
        try{
            system.debug('getTaxIdFromWrapper method >> VAT >> ' + orbisRecWrap.vaT_NUMBER.toString());
            system.debug('eu_VAT >> ' + orbisRecWrap.europeaN_VAT_NUMBER);
            system.debug('orbisCountry >> ' + orbisCountry);
            
            if((orbisCountry == 'United Kingdom' || orbisCountry == 'UK') && !((orbisRecWrap.vaT_NUMBER).isEmpty())){
                taxId = orbisRecWrap.vaT_NUMBER.toString();
                taxId = taxId.substring(1, taxId.length() - 1);
            }else if(orbisCountry != 'United Kingdom' && (orbisRecWrap.europeaN_VAT_NUMBER != '' && orbisRecWrap.europeaN_VAT_NUMBER != 'n.a.')){
                taxId = orbisRecWrap.europeaN_VAT_NUMBER;
            }else if(orbisRecWrap.tin != '' && (region == 'SENA' || region == 'STUSCO')){
                taxId = orbisRecWrap.tin;
                taxId = taxId.replace('-', '').replace('\\', '').replace('.', '').replace('/', '');
                taxId = taxId.substring(0, 9);
            }else if(orbisRecWrap.tin != ''){
                taxId = orbisRecWrap.tin;                
            } 
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> getTaxIdFromWrapper : ' + ex.getMessage());
        }
        return taxId;
    }
    
    public static BET_BDD_Bankers_baidWrapper.responseParameterBaid getBankersDetailsByBaid(string baidNumber, string accessToken){
        BET_BDD_Bankers_baidWrapper.responseParameterBaid bankersDetails = null; 
        try{
            bankersDetails = BET_BDD_Bankers_baidCallout.getbaidData(baidNumber, accessToken);
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> getBankersDetailsByBaid() : ' + ex.getMessage());
        }
        return bankersDetails;
    }
    
    //Parse bankers baid details api and map the values to BET_BDD_BankersDetailsWrapper
    public static BET_BDD_BankersDetailsWrapper parseBaidDetailsWrapper(BET_BDD_Bankers_baidWrapper.responseParameterBaid baidRespWrap){
        BET_BDD_BankersDetailsWrapper bankDetailsFinalWrapper = new BET_BDD_BankersDetailsWrapper();
        system.debug('inside parseBaidDetailsWrapper >> ' + baidRespWrap.resultPayload);
        List<BET_BDD_BankersDetailsWrapper> BankersDetails = new List<BET_BDD_BankersDetailsWrapper>();
        boolean raAvailable = false; boolean taAvailable = false;
     
        for(BET_BDD_Bankers_baidWrapper.names item: baidRespWrap.ResultPayload.legalEntity.names){
            if(item.type == 'Marketing Name'){
                bankDetailsFinalWrapper.tradingName = item.value;
            }
        }
        
        try{
            for(BET_BDD_Bankers_baidWrapper.locations regAddr: baidRespWrap.ResultPayload.legalEntity.RegisteredOffice.locations){
                if(raAvailable == false){
                    bankDetailsFinalWrapper.regAddressLine1 = regAddr.address.streetAddress.addressLine1;
                    bankDetailsFinalWrapper.regAddressLine2 = regAddr.address.streetAddress.addressLine2;
                    bankDetailsFinalWrapper.regAddressLine3 = regAddr.address.streetAddress.addressLine3;
                    bankDetailsFinalWrapper.regAddressLine4 = regAddr.address.streetAddress.addressLine4;
                    bankDetailsFinalWrapper.regCity = regAddr.address.city;
                    bankDetailsFinalWrapper.regcountry = regAddr.address.country;
                    bankDetailsFinalWrapper.regPostalCode = regAddr.address.postalCode;
                }
                raAvailable = true;
            }
            for(BET_BDD_Bankers_baidWrapper.locations traAddr: baidRespWrap.ResultPayload.legalEntity.HeadOffice.locations){
                if(taAvailable == false){
                    bankDetailsFinalWrapper.tradAddressLine1 = traAddr.address.streetAddress.addressLine1;
                    bankDetailsFinalWrapper.tradAddressLine2 = traAddr.address.streetAddress.addressLine2;
                    bankDetailsFinalWrapper.tradAddressLine3 = traAddr.address.streetAddress.addressLine3;
                    bankDetailsFinalWrapper.tradAddressLine4 = traAddr.address.streetAddress.addressLine4;
                    bankDetailsFinalWrapper.tradCity = traAddr.address.city;
                    bankDetailsFinalWrapper.tradCountry = traAddr.address.country;
                    bankDetailsFinalWrapper.tradPostalCode = traAddr.address.postalCode;
                }
                taAvailable = true;
            } 
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> parseBaidDetailsWrapper() : ' + ex.getMessage());
        }
        return bankDetailsFinalWrapper;
    }
    
    private static List<BET_BDD_Address__c> createBankersAddressRec(string sRecordId, BET_BDD_BankersDetailsWrapper bankersBaidWrap, string region, 
                                                                    string addrType, string onBoardingType, list<string> gtPicklistValues, 
                                                                    list<string> mdnPicklistValues, boolean mapLegalAddrToOperAddr){  
        id gtRecordTypeId = BET_Utility.getRecordTypeIdByName('BET_BDD_Address__c', 'GOLDTIER');
        id mdnRecordTypeId = BET_Utility.getRecordTypeIdByName('BET_BDD_Address__c', 'MDN');
        List<BET_BDD_Address__c> newAddressList = new List<BET_BDD_Address__c>();
        BET_BDD_Address__c newAddr = null; boolean addrTypeReq = true;
        map<string, string>  addrRecMap = new map<string, string>();
        string gtAddrType = ''; string mdnAddrType = ''; boolean gtPicklistValAv = false; boolean mdnPicklistValAv = false;
        map<string, string> addrTypeMap = BET_Utility.getGtAddressTypeByRegion(region, addrType);
        string bankRegCountry = bankersBaidWrap.regCountry;
        string bankTradCountry = bankersBaidWrap.tradCountry; 
                                                                        
        if(!addrTypeMap.isEmpty()){
            if(addrTypeMap.ContainsKey('gtAddrType')){
                gtAddrType = addrTypeMap.get('gtAddrType');
            }
            if(addrTypeMap.ContainsKey('mdnAddrType')){
                mdnAddrType = addrTypeMap.get('mdnAddrType');
            }
        }
        gtPicklistValAv = checkIfPicklistValExists(bankersBaidWrap.regCountry, gtPicklistValues);
        mdnPicklistValAv = checkIfPicklistValExists(bankersBaidWrap.regCountry, mdnPicklistValues);
        
        try{
            if(gtAddrType != '' &&  mdnAddrType != '' && addrType == 'Registered'){                
                //GT address
                addrRecMap.put('addrLine1', bankersBaidWrap.regAddressLine1);
                addrRecMap.put('addrLine2', bankersBaidWrap.regAddressLine2);
                addrRecMap.put('addrLine3', bankersBaidWrap.regAddressLine3);
                addrRecMap.put('addrLine4', bankersBaidWrap.regAddressLine4);
                addrRecMap.put('city', bankersBaidWrap.regCity);
                addrRecMap.put('state', '');
                if(bankRegCountry == 'United States' || bankRegCountry == 'Canada' || bankRegCountry == 'United States of America' || bankRegCountry == 'USA'){
                    addrTypeReq = false;
                }
                if(gtPicklistValAv == false){
                    addrRecMap.put('country', '');
                }else{
                    addrRecMap.put('country', bankRegCountry);
                }
                
                addrRecMap.put('postCode', bankersBaidWrap.regPostalCode);
                newAddr = createAddressRec(sRecordId, addrRecMap, gtAddrType, gtRecordTypeId, addrTypeReq);
                newAddressList.add(newAddr);
                
                //copy legal to operating address when trading address is not available
                if(mapLegalAddrToOperAddr == true){
                    newAddr = createAddressRec(sRecordId, addrRecMap, 'Operating', gtRecordTypeId, addrTypeReq);
                    newAddressList.add(newAddr);
                }
                
                if(onBoardingType != 'Remediation Update'){
                    //MDN address
                    newAddr = null;
                    if(mdnPicklistValAv == false){
                        addrRecMap.put('country', '');
                    }else{
                        addrRecMap.put('country', bankRegCountry);
                    }
                    newAddr = createAddressRec(sRecordId, addrRecMap, mdnAddrType, mdnRecordTypeId, addrTypeReq); 
                    newAddressList.add(newAddr); 
                }
            }else if(gtAddrType != '' &&  mdnAddrType != '' && addrType == 'Trading'){
                //GT address
                addrRecMap.put('addrLine1', bankersBaidWrap.tradAddressLine1);
                addrRecMap.put('addrLine2', bankersBaidWrap.tradAddressLine2);
                addrRecMap.put('addrLine3', bankersBaidWrap.tradAddressLine3);
                addrRecMap.put('addrLine4', bankersBaidWrap.tradAddressLine4);
                addrRecMap.put('city', bankersBaidWrap.tradCity);
                addrRecMap.put('state', '');

                if(bankTradCountry == 'United States' || bankTradCountry == 'Canada' || bankTradCountry == 'United States of America' || bankTradCountry == 'USA'){
                    addrTypeReq = false;
                }
                if(gtPicklistValAv == false){
                    addrRecMap.put('country', '');
                }else{
                    addrRecMap.put('country', bankTradCountry);
                }
                
                addrRecMap.put('postCode', bankersBaidWrap.tradPostalCode);
                newAddr = createAddressRec(sRecordId, addrRecMap, gtAddrType, gtRecordTypeId, addrTypeReq);
                newAddressList.add(newAddr);
                
                if(onBoardingType != 'Remediation Update'){
                    //MDN address
                    newAddr = null;
                    newAddr = createAddressRec(sRecordId, addrRecMap, mdnAddrType, mdnRecordTypeId, addrTypeReq); 
                    newAddressList.add(newAddr); 
                }
            }   
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> createBankersAddressRec() : ' + ex.getMessage());
        }
        return newAddressList;     
    }
    
    private static List<BET_BDD_Address__c> createOrbisAddressRec(string sRecordId, BET_EdpResponse_WrapperClass.OrbisResult orbisRecWrap, string region, 
                                                                  string addrType, string onBoardingType, list<string> gtPicklistValues, 
                                                                  list<string> mdnPicklistValues, boolean mapLegalAddrToOperAddr){
        List<BET_BDD_Address__c> newAddressList = new List<BET_BDD_Address__c>();
        BET_BDD_Address__c newAddr = null; string orbisCountry = orbisRecWrap.country;
        map<string, string>  addrRecMap = new map<string, string>();
        id gtRecordTypeId = BET_Utility.getRecordTypeIdByName('BET_BDD_Address__c', 'GOLDTIER');
        id mdnRecordTypeId = BET_Utility.getRecordTypeIdByName('BET_BDD_Address__c', 'MDN');
        string gtAddrType = ''; string mdnAddrType = ''; boolean gtPicklistValAv = false; boolean mdnPicklistValAv = false; boolean addrTypeReq = true;
        map<string, string> addrTypeMap = BET_Utility.getGtAddressTypeByRegion(region, addrType);
                                                                      
        gtPicklistValAv = checkIfPicklistValExists(orbisRecWrap.country, gtPicklistValues);
        mdnPicklistValAv = checkIfPicklistValExists(orbisRecWrap.country, mdnPicklistValues);
                                                                      
        if(!addrTypeMap.isEmpty()){
            if(addrTypeMap.ContainsKey('gtAddrType')){
                gtAddrType = addrTypeMap.get('gtAddrType');
            }
            if(addrTypeMap.ContainsKey('mdnAddrType')){
                mdnAddrType = addrTypeMap.get('mdnAddrType');
            }
        }
        
        try{
            if(gtAddrType != '' &&  mdnAddrType != '' && addrType == 'Registered'){
                //GT address
                addrRecMap.put('addrLine1', orbisRecWrap.addresS_LINE1);
                addrRecMap.put('addrLine2', orbisRecWrap.addresS_LINE2);
                addrRecMap.put('addrLine3', orbisRecWrap.addresS_LINE3);
                addrRecMap.put('addrLine4', '');
                addrRecMap.put('city', orbisRecWrap.city);
                addrRecMap.put('state', orbisRecWrap.uS_STATE);
                if(orbisCountry == 'United States' || orbisCountry == 'Canada' || orbisCountry == 'United States of America' || orbisCountry == 'USA'){
                    addrTypeReq = false;
                }
                if(gtPicklistValAv == false){
                    addrRecMap.put('country', ''); 
                }else{
                    addrRecMap.put('country', orbisCountry);
                }                
                addrRecMap.put('postCode', orbisRecWrap.postcode);
                newAddr = createAddressRec(sRecordId, addrRecMap, gtAddrType, gtRecordTypeId, addrTypeReq);
                newAddressList.add(newAddr);
                
                //copy legal to operating address when trading address is not available
                if(mapLegalAddrToOperAddr == true){
                    newAddr = createAddressRec(sRecordId, addrRecMap, 'Operating', gtRecordTypeId, addrTypeReq);
                    newAddressList.add(newAddr);
                }
                
                if(onBoardingType != 'Remediation Update'){
                    //MDN address
                    newAddr = null;
                    if(mdnPicklistValAv == false){
                        addrRecMap.put('country', ''); 
                    }else{
                        addrRecMap.put('country', orbisCountry);
                    } 
                    newAddr = createAddressRec(sRecordId, addrRecMap, mdnAddrType, mdnRecordTypeId, addrTypeReq); 
                    newAddressList.add(newAddr);
                }
            }else if(gtAddrType != '' &&  mdnAddrType != '' && addrType == 'Trading'){
                //GT address
                addrRecMap.put('addrLine1', orbisRecWrap.address_Line1_Additional);
                if(orbisRecWrap.address_Line2_Additional != 'null'){
                  addrRecMap.put('addrLine2', orbisRecWrap.address_Line2_Additional);  
                }else{
                  addrRecMap.put('addrLine2', '');
                }
                if(orbisRecWrap.address_Line3_Additional != 'null'){
                  addrRecMap.put('addrLine3', orbisRecWrap.address_Line3_Additional);  
                }else{
                  addrRecMap.put('addrLine3', '');
                }
                if(orbisRecWrap.address_Line4_Additional != 'null'){
                  addrRecMap.put('addrLine4', orbisRecWrap.address_Line4_Additional);  
                }else{
                  addrRecMap.put('addrLine4', '');
                }
                addrRecMap.put('city', orbisRecWrap.citY_ADDITIONAL);
                addrRecMap.put('state', '');
                orbisCountry = orbisRecWrap.COUNTRY_ADDITIONAL;
                if(orbisCountry == 'United States' || orbisCountry == 'Canada' || orbisCountry == 'United States of America' || orbisCountry == 'USA'){
                    addrTypeReq = false;
                }
                if(gtPicklistValAv == false){
                    addrRecMap.put('country', ''); 
                }else{
                    addrRecMap.put('country', orbisCountry);
                }                
                addrRecMap.put('postCode', orbisRecWrap.postcodE_ADDITIONAL);
                newAddr = createAddressRec(sRecordId, addrRecMap, gtAddrType, gtRecordTypeId, addrTypeReq);
                newAddressList.add(newAddr);
                if(onBoardingType != 'Remediation Update'){
                    //MDN address
                    newAddr = null;
                    if(mdnPicklistValAv == false){
                        addrRecMap.put('country', ''); 
                    }else{
                        addrRecMap.put('country', orbisCountry);
                    } 
                    newAddr = createAddressRec(sRecordId, addrRecMap, mdnAddrType, mdnRecordTypeId, addrTypeReq); 
                    newAddressList.add(newAddr);
                }
            }      
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> createOrbisAddressRec() : ' + ex.getMessage());
        }
        return newAddressList;   
    }
    
    private static BET_BDD_Address__c createAddressRec(string bddFormId, map<string, string> newAddrMap, string addrType, Id recordTypeId, boolean addrTypeReq){
        BET_BDD_Address__c newAddress = new BET_BDD_Address__c();
        string addrLine1 = ''; string addrLine2 = ''; string addrLine3 = ''; string addrLine4 = '';
        string city = ''; string state = ''; string country = ''; string postalCode = '';
        
        Integer addrLine1Length = SObjectType.BET_BDD_Address__c.Fields.AddLine1__c.Length;
        Integer addrLine2Length = SObjectType.BET_BDD_Address__c.Fields.AddLine2__c.Length;
        Integer addrLine3Length = SObjectType.BET_BDD_Address__c.Fields.AddLine3__c.Length;
        Integer addrLine4Length = SObjectType.BET_BDD_Address__c.Fields.AddLine4__c.Length;
        Integer cityLength = SObjectType.BET_BDD_Address__c.Fields.City__c.Length;
        Integer countryLength = SObjectType.BET_BDD_Address__c.Fields.Country__c.Length;
        Integer postalCodeLength = SObjectType.BET_BDD_Address__c.Fields.PostCode__c.Length;
        
        try{            
            if(!newAddrMap.isEmpty()){
                if(newAddrMap.ContainsKey('addrLine1')){
                    addrLine1 = newAddrMap.get('addrLine1');
                }
                if(newAddrMap.ContainsKey('addrLine2')){
                    addrLine2 = newAddrMap.get('addrLine2');
                }
                if(newAddrMap.ContainsKey('addrLine3')){
                    addrLine3 = newAddrMap.get('addrLine3');
                }
                if(newAddrMap.ContainsKey('addrLine4')){
                    addrLine4 = newAddrMap.get('addrLine4');
                }
                if(newAddrMap.ContainsKey('city')){
                    city = newAddrMap.get('city');
                }
                if(newAddrMap.ContainsKey('state')){
                    state = newAddrMap.get('state');
                }
                if(newAddrMap.ContainsKey('country')){
                    country = newAddrMap.get('country');
                }
                if(newAddrMap.ContainsKey('postCode')){
                    postalCode = newAddrMap.get('postCode');
                }
            }
            if(addrTypeReq == true){
                newAddress.Address_Type__c = addrType;
            }else{
                newAddress.Address_Type__c = '';
            }
            
            newAddress.BDD_Form__c  = bddFormId;
            if(addrLine1 != null){
                newAddress.AddLine1__c  = BET_Utility.truncateText(addrLine1, addrLine1Length);
            }
            if(addrLine2 != null){
                newAddress.AddLine2__c  = BET_Utility.truncateText(addrLine2, addrLine2Length);  
            }
            if(addrLine3 != null){
                newAddress.AddLine3__c  = BET_Utility.truncateText(addrLine3, addrLine3Length);  
            }
            if(addrLine4 != null){
                newAddress.AddLine4__c  = BET_Utility.truncateText(addrLine4, addrLine4Length);  
            }
            if(city != null){
                newAddress.City__c      = BET_Utility.truncateText(city, cityLength); 
            }
            newAddress.State__c     	= state;
            if(country != null){
                newAddress.Country__c   = BET_Utility.truncateText(country, countryLength);
            }
            if(postalCode != null){
               newAddress.PostCode__c   = BET_Utility.truncateText(postalCode, postalCodeLength); 
            }
            newAddress.recordTypeId = recordTypeId;
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller >> createAddressRec() : ' + ex.getMessage());
        }
        return newAddress;
    }
    
    private static BET_Registration_Details__c getRegDetailRec(string type, string regNum, string country, id bddFormId){
        BET_Registration_Details__c regDet = new BET_Registration_Details__c();
        /*if(country == 'USA' || country == 'United States of America'){
            country = 'United States';
        }else if(country == 'UK'){
            country = 'United Kingdom';
        }*/
        regDet.Registration_ID_Type__c = type;
        regDet.Registration_ID__c = regNum;
        regDet.Registration_Country__c = country;
        regDet.BDD_Form__c = bddFormId;
        return regDet;
    }
    
    /*Method Name  : newBddFormCrResponse
    *Date          : 12-Sep-20
    *Developer     : Naveen K N
    *Description   : This wrapper is used to send new bdd form creation result to the lightning component
    */
    public class newBddFormCrResponse{
        @AuraEnabled
        public string recId;
        @AuraEnabled
        public string baidApiStatus;
    }
    
     public class compInitWrapper{
        @AuraEnabled
        public boolean disableEdpSearchAndVer;
    }
    
    
    public static newBddFormCrResponse bulkUploadRecordUpdate(BET_BDD_Form__c newBddForm, BET_EdpResponse_WrapperClass.OrbisResult orbisRecord, 
                                                              BET_EdpResponse_WrapperClass.BankersResult bankersRecord, 
                                         boolean UIVerfDone, string verfTaxVATNum, string verfCountry, object gtmiRec, string accessToken, 
                                         string vesselName, Boolean considerGTFieldsOnly){
        system.debug('newBddForm ' + newBddForm);
        string sRecordId       = null;
        string verSource       = '';
        string region          = newBddForm.BDD_Line_of_Business__c;
        string entType         = newBddForm.BDD_Entity_Type__c;
        string onBoardingType  = newBddForm.BDD_Onboard_Type__c;
        string primarySource   = '';
        string secondarySource = '';
        string bvdId = '';
        map<string, string> dataSourceMap = new map<string, string>();
        BET_EdpResponse_WrapperClass.OrbisResult orbisRecWrap = null;
        BET_EdpResponse_WrapperClass.BankersResult bankersRecWrap = null;
        BET_BDD_GTMI_WrapperClass.resultPayload gtmiRecWrap = null;
        BET_BDD_Bankers_baidWrapper.responseParameterBaid bankersBaidWrap = null;
        //boolean legalNameAv = false;
        string orbislegalName = ''; string orbisEntType = ''; string orbisIncCountry = ''; string orbisIncState = '';
        string docPrimSource = ''; string docSecSource = ''; string orbisTradingName = ''; boolean picklistValAv = false;
        string bankersAlmanacId = ''; string bankersLegalName = ''; string baid = ''; integer baidResponseCode = 0; string baidResponseMsg = '';
        string matchPeps = ''; string mactchSanc = ''; string matchNegStories = ''; string taxId = ''; 
        string enfInd = ''; string soeInd = ''; string govtLinkedInd = ''; string assEntInd = ''; string regInd = '';
        List<BET_Utility.BddDocumentWrap> bddDocWrapList = new List<BET_Utility.BddDocumentWrap>();
        BET_BDD_Bankers_baidWrapper.responseParameterBaid bankersDetailsByBaid = null; 
        BET_BDD_BankersDetailsWrapper bankBaidDetails = null; boolean allowNewRecordCr = true;
        newBddFormCrResponse newRecWrap = new newBddFormCrResponse();
        list<string> coreBusPickList = new list<string>();
        //list<string> picklistValues = new list<string>();
        list<string> gtPicklistValues = BET_Utility.getPickListValuesIntoList('BET_Registration_Details__c', 'Registration_Country__c');
        list<string> mdnPicklistValues = BET_Utility.getPickListValuesIntoList('BET_BDD_Form__c', 'MDN_CD_Country_of_Inc__c');
                                             
        try{        
            //Get bankers details
            if(bankersRecord !=null ){
                system.debug('2');
				bankersRecWrap = bankersRecord;
                //bankersRecWrap = (BET_EdpResponse_WrapperClass.BankersResult)JSON.deserialize(bankersRecord.toString(), BET_EdpResponse_WrapperClass.BankersResult.class);
                //JSON.stringify(
                
                system.debug('bankersRecWrap' + bankersRecWrap);
                baid = bankersRecWrap.bankersAlmanacId;
            }
            system.debug('Bankers API 2 >> ' + baid);
            if(bankersRecord !=null && baid !=null &&  baid != ''){
                //call baid api 
                bankersDetailsByBaid = getBankersDetailsByBaid(baid, accessToken); 
                system.debug('bankersDetailsByBaid res >> ' + bankersDetailsByBaid);
                baidResponseCode = bankersDetailsByBaid.responseCode;
                baidResponseMsg = bankersDetailsByBaid.responseMessage;
                
                //parse baid api response
                if(bankersDetailsByBaid != null && baidResponseCode == 200){
                    bankBaidDetails = parseBaidDetailsWrapper(bankersDetailsByBaid);
                }
            }
            if(bankersRecord !=null  && bankersDetailsByBaid.responseCode != 200){
                //allowNewRecordCr = false;
                newRecWrap.baidApiStatus = 'Failed';
            }
            
            dataSourceMap = BET_Utility.getDataSourceMapping(region, entType);
            if(!dataSourceMap.isEmpty()){
                primarySource = dataSourceMap.get('Primary');
                secondarySource = dataSourceMap.get('Secondary');
            }
            system.debug('primarySource: ' + primarySource + ';secondarySource: ' + secondarySource);
            system.debug('orbisRecord' + orbisRecord);
            //system.debug('bankersRecord' + bankersRecord);
            if( gtmiRec !=null && gtmiRec != '""'){
                gtmiRecWrap = (BET_BDD_GTMI_WrapperClass.resultPayload)JSON.deserialize(gtmiRec.toString(), BET_BDD_GTMI_WrapperClass.resultPayload.class);            
            }
            if(orbisRecord !=null ){
                orbisRecWrap = orbisRecord;
                //orbisRecWrap = (BET_EdpResponse_WrapperClass.OrbisResult)JSON.deserialize(orbisRecord.toString(), BET_EdpResponse_WrapperClass.OrbisResult.class); 
                //orbisRecWrap = (BET_EdpResponse_WrapperClass.OrbisResult)JSON.deserialize(orbisRecord.toString(), BET_EdpResponse_WrapperClass.OrbisResult.class); 
            }
            system.debug('orbisRecWrap :' + orbisRecWrap);
            BET_BDD_Form__c newBddRecord = newBddForm;
            if(orbisRecWrap != null || bankersRecWrap != null){
                if(primarySource == 'Orbis' && orbisRecWrap != null){
                    system.debug('Orbis >> primary');
                    docPrimSource = 'Orbis';
                    orbislegalName = orbisRecWrap.name;
                    
                    if(orbislegalName != ''){
                        newBddRecord.GT_Legal_Name__c = orbislegalName;
                        if(!considerGTFieldsOnly){
                        	newBddRecord.MDN_OI_Full_Legal_Name__c = orbislegalName;
                        	newBddRecord.MDN_OI_ShortName__c = orbislegalName;
                        }
                    }
                    orbisTradingName = orbisRecWrap.akA_NAME_Str;
                    if(orbisTradingName != ''){
                        newBddRecord.GT_Trading_Name__c = orbisTradingName;
                    }else if(orbislegalName != ''){
                        newBddRecord.GT_Trading_Name__c = orbislegalName;
                    }
                    
                    orbisEntType = orbisRecWrap.entitY_TYPE;
                    if(orbisEntType != ''){
                        //newBddRecord.GT_Entity_Type__c = orbisEntType;
                    }
                    orbisIncCountry = orbisRecWrap.country;
                    if(orbisIncCountry != ''){
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisIncCountry, mdnPicklistValues);
                        if(picklistValAv == true && !considerGTFieldsOnly){
                           newBddRecord.MDN_CD_Country_of_Inc__c = orbisIncCountry; 
                        }
                    }
                    orbisIncState = orbisRecWrap.uS_STATE;
                    if(orbisIncState != '' && 
                       (orbisIncCountry == 'United States' || orbisIncCountry == 'Canada' || orbisIncCountry == 'United States of America' || 
                        orbisIncCountry == 'USA')){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_State_Province_Region__c = orbisIncState;
                        }
                    
                    if(orbisRecWrap.lei != '' || !(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty()){
                        newBddRecord.GT_Is_Comp_Reg__c = true;
                    }
                    bvdId = orbisRecWrap.bvdid; 
                    if(orbisRecWrap.PRODUCTS_SERVICES != ''){
                        newBddRecord.GT_Nature_of_Business__c = orbisRecWrap.PRODUCTS_SERVICES;
                    }
                    if(orbisRecWrap.NAICS2017_CORE_LABEL != ''){
                        if(!considerGTFieldsOnly)
                        	newBddRecord.MDN_CD_Core_Business__c = orbisRecWrap.NAICS2017_CORE_LABEL;
                        coreBusPickList = BET_Utility.getCoreBusPicklistValuesByName();
                        if(coreBusPickList.contains(orbisRecWrap.NAICS2017_CORE_LABEL)){
                            newBddRecord.GT_Core_Business_Act__c = orbisRecWrap.NAICS2017_CORE_LABEL; 
                        }
                    }
                    
                    matchPeps = orbisRecWrap.WORLDCOMPLIANCE_MATCH_CURRENT_PEP_INDICATOR;
                    mactchSanc = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SANCTION_INDICATOR;
                    matchNegStories = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ADVERSE_MEDIA_INDICATOR;
                    enfInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ENFORCEMENT_INDICATOR;
                    soeInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SOE_INDICATOR; 
                    govtLinkedInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_GOVERNMENT_LINKED_INDICATOR; 
                    assEntInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ASSOCIATED_ENTITY_INDICATOR;
                    regInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_REGISTRATIONS_INDICATOR;
                    
                    if(matchPeps == 'true' || mactchSanc == 'true' || enfInd == 'true' || soeInd == 'true' || govtLinkedInd == 'true'
                      || assEntInd == 'true' || regInd == 'true'){
                        newBddRecord.PEPs_and_Sanc_Found__c = 'Yes';
                    }else{
                        newBddRecord.PEPs_and_Sanc_Found__c = 'No';
                    }
                    if(matchNegStories == 'true'){
                        newBddRecord.Negative_Stories_Found__c = 'Yes';
                    }else{
                        newBddRecord.Negative_Stories_Found__c = 'No';
                    }
                    if(region == 'WONA'){
                        system.debug('WONA >> orbis >> Fill related fields');
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        if(taxId != ''){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_PVAT_TaxNum__c = taxId;
                        }
                        system.debug('MDN CD >> Reg number mapping');
                        string mdnCdRegNum = getOrbisRegNumforMdnCd(orbisRecWrap, taxId);
                        if(mdnCdRegNum != ''){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_RegNum__c = mdnCdRegNum;
                        }
                    }
                }else if(primarySource == 'Bankers Almanac' && bankersRecWrap != null){
                    system.debug('Bankers >> primary');
                    docPrimSource = 'Bankers Almanac';
                    bankersAlmanacId = bankersRecWrap.bankersAlmanacId;
                    bankersLegalName = bankersRecWrap.name;
                    if(bankersLegalName != ''){
                        newBddRecord.GT_Legal_Name__c = bankersLegalName;
                        if(!considerGTFieldsOnly){
                        	newBddRecord.MDN_OI_Full_Legal_Name__c = bankersLegalName;
                        	newBddRecord.MDN_OI_ShortName__c = bankersLegalName;
                        }
                    }
                    system.debug('bankersAlmanacId:' + bankersAlmanacId);
                    if( bankersAlmanacId !=null && bankersAlmanacId != ''){
                        bankersBaidWrap = getBankersDetailsByBaid(bankersAlmanacId, accessToken);
                        system.debug('bankersBaidWrap response***' + bankersBaidWrap);
                    }
                    if(bankersRecWrap !=null && bankersRecWrap.lei != ''){
                        newBddRecord.GT_Is_Comp_Reg__c = true;
                    }
                    
                    if(bankBaidDetails !=null && bankBaidDetails.tradingName != null){
                        newBddRecord.GT_Trading_Name__c = bankBaidDetails.tradingName;
                    }else if(bankersLegalName !=null && bankersLegalName != ''){
                        newBddRecord.GT_Trading_Name__c = bankersLegalName;
                    }
                    
                    system.debug('bankersRecWrap.country >> ' + bankersRecWrap.country);
                    if(bankersRecWrap != null && bankersRecWrap.country != ''){
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(bankersRecWrap.country, mdnPicklistValues);
                        if(picklistValAv == true){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_Country_of_Inc__c = bankersRecWrap.country; 
                        }
                    }
                    
                    if(region == 'WONA'){
                        string bankerRegNum = getBankersRegNumforMdnCd(bankersRecWrap);
                        if(bankerRegNum != ''){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_RegNum__c = bankerRegNum;
                        }
                    }                    
                }
                
                if(secondarySource == 'Orbis' && orbisRecWrap != null){
                    system.debug('Orbis >> secondary');
                    docSecSource = 'Orbis';
                    orbislegalName = orbisRecWrap.name;
                    if(newBddRecord.GT_Legal_Name__c == null && orbislegalName != ''){
                        newBddRecord.GT_Legal_Name__c = orbislegalName;
                    }
                    if(newBddRecord.MDN_OI_Full_Legal_Name__c == null && orbislegalName != ''){
                        if(!considerGTFieldsOnly)
                        	newBddRecord.MDN_OI_Full_Legal_Name__c = orbislegalName;
                    }
                    if(newBddRecord.MDN_OI_ShortName__c == null && orbislegalName != ''){
                        if(!considerGTFieldsOnly)
                        	newBddRecord.MDN_OI_ShortName__c = orbislegalName;
                    }
                    orbisTradingName = orbisRecWrap.akA_NAME_Str;  
                    if(newBddRecord.GT_Trading_Name__c == null && orbisTradingName != ''){
                        newBddRecord.GT_Trading_Name__c = orbisTradingName;
                    }else if(newBddRecord.GT_Trading_Name__c == null && orbislegalName != ''){
                        newBddRecord.GT_Trading_Name__c = orbislegalName;
                    }
                    
                    orbisEntType = orbisRecWrap.entitY_TYPE;
                    if(newBddRecord.GT_Entity_Type__c == null && orbisEntType != ''){
                        //newBddRecord.GT_Entity_Type__c = orbisEntType;
                    }
                    orbisIncCountry = orbisRecWrap.country;
                    if(newBddRecord.MDN_CD_Country_of_Inc__c == null && orbisIncCountry != ''){
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisIncCountry, mdnPicklistValues);
                        if(picklistValAv == true){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_Country_of_Inc__c = orbisIncCountry; 
                        }
                    }
                    orbisIncState = orbisRecWrap.uS_STATE;
                    if(newBddRecord.MDN_CD_State_Province_Region__c == null && orbisIncState != '' 
                       && (orbisIncCountry == 'United States' || orbisIncCountry == 'Canada' || orbisIncCountry == 'United States of America' 
                           || orbisIncCountry == 'USA')){
                               if(!considerGTFieldsOnly)
                               	newBddRecord.MDN_CD_State_Province_Region__c = orbisIncState;
                           }
                    
                    if(newBddRecord.GT_Is_Comp_Reg__c != true && (orbisRecWrap.lei != '' || !(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty())){
                        newBddRecord.GT_Is_Comp_Reg__c = true;
                    }
                    bvdId = orbisRecWrap.bvdid; 
                    if(newBddRecord.GT_Nature_of_Business__c == null && orbisRecWrap.PRODUCTS_SERVICES != ''){
                        newBddRecord.GT_Nature_of_Business__c = orbisRecWrap.PRODUCTS_SERVICES;
                    }
                    if(orbisRecWrap.NAICS2017_CORE_LABEL != ''){
                        if(newBddRecord.MDN_CD_Core_Business__c == null){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_Core_Business__c = orbisRecWrap.NAICS2017_CORE_LABEL; 
                        }
                        
                        coreBusPickList = BET_Utility.getCoreBusPicklistValuesByName();
                        if(newBddRecord.GT_Core_Business_Act__c == null && coreBusPickList.contains(orbisRecWrap.NAICS2017_CORE_LABEL)){
                            newBddRecord.GT_Core_Business_Act__c = orbisRecWrap.NAICS2017_CORE_LABEL; 
                        }
                    }
                    matchPeps = orbisRecWrap.WORLDCOMPLIANCE_MATCH_CURRENT_PEP_INDICATOR;
                    mactchSanc = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SANCTION_INDICATOR;
                    matchNegStories = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ADVERSE_MEDIA_INDICATOR;
                    enfInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ENFORCEMENT_INDICATOR;
                    soeInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_SOE_INDICATOR; 
                    govtLinkedInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_GOVERNMENT_LINKED_INDICATOR; 
                    assEntInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_ASSOCIATED_ENTITY_INDICATOR;
                    regInd = orbisRecWrap.WORLDCOMPLIANCE_MATCH_REGISTRATIONS_INDICATOR;
                    
                    if(newBddRecord.PEPs_and_Sanc_Found__c == null && (matchPeps == 'true' || mactchSanc == 'true' || enfInd == 'true' || 
                                                                       soeInd == 'true' || govtLinkedInd == 'true' || assEntInd == 'true' || regInd == 'true')){
                        newBddRecord.PEPs_and_Sanc_Found__c = 'Yes';
                    }else{
                        newBddRecord.PEPs_and_Sanc_Found__c = 'No';
                    }

                    if(newBddRecord.Negative_Stories_Found__c == null){
                        if(matchNegStories == 'true'){
                            newBddRecord.Negative_Stories_Found__c = 'Yes';
                        }else{
                            newBddRecord.Negative_Stories_Found__c = 'No';
                        }
                    }
                    
                    if(region == 'WONA'){
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        if(taxId != '' && newBddRecord.MDN_CD_PVAT_TaxNum__c == null){
                            if(!considerGTFieldsOnly)
                            	newBddRecord.MDN_CD_PVAT_TaxNum__c = taxId;
                        }
                        system.debug('MDN CD >> Reg number mapping');
                        if(newBddRecord.MDN_CD_RegNum__c == null){
                            string mdnCdRegNum = getOrbisRegNumforMdnCd(orbisRecWrap, taxId);
                            if(mdnCdRegNum != ''){
                                if(!considerGTFieldsOnly)
                                	newBddRecord.MDN_CD_RegNum__c = mdnCdRegNum;
                            }   
                        }
                    }
                }else if(secondarySource == 'Bankers Almanac' && bankersRecWrap != null){
                    docSecSource = 'Bankers Almanac';
                }
            }else{
                //when there is no record selected in EDP search
                if(region == 'GLOBAL'){
                    newBddRecord.GT_Legal_Name__c = vesselName;
                    newBddRecord.GT_Short_Name__c = vesselName;
                }else{
                    newBddRecord.GT_Legal_Name__c = newBddForm.Full_Legal_Name__c;
                    if(!considerGTFieldsOnly){
                    	newBddRecord.MDN_OI_Full_Legal_Name__c = newBddForm.Full_Legal_Name__c;
                    	newBddRecord.MDN_OI_ShortName__c = newBddForm.Full_Legal_Name__c;
                    }
                }
            }
            
            system.debug('insert new record >> ');
            //newBddRecord.recordTypeId = BET_Utility.getRecordTypeId(region, entType, onBoardingType);
            if(newBddRecord != null){
                if(region == 'WONA' || region == 'SENA'){
                    if(!considerGTFieldsOnly)
                    	newBddRecord.MDN_PC_Type__c = 'Main'; 
                }else if(region == 'STUSCO'){
                    if(!considerGTFieldsOnly)
                    	newBddRecord.MDN_PC_Type__c = 'Invoice'; 
                }
                
                if(newBddRecord.BDD_Onboard_Type__c == 'Remediation Update'){
                    newBddRecord.GT_Is_Rem__c = 'Yes';
                    if(!considerGTFieldsOnly)
                    	newBddRecord.MDN_Status__c = '';
                }else{
                    newBddRecord.GT_Is_Rem__c = 'No';
                }
                
                if(newBddRecord.BDD_Entity_Type__c == 'Vessel'){
                    newBddRecord.GT_Product_Risk__c = 'High';
                    newBddRecord.GT_Cust_Entity_Type_Class__c = 'Vessel';
                    newBddRecord.GT_BDD_Region_Role_Comm__c = 'WORLDWIDE | Vessel';
                    //commented by Ashish J. on 20/09/2021 for changing the field type to Multiselect picklist
                    //newBddRecord.GT_BDD_Commodity__c = 'N/A';
                    //newBddRecord.GT_BDD_Business_Division__c = 'Shipping';
                    if(!considerGTFieldsOnly)
                    	newBddRecord.MDN_Status__c = '';
					//uncommented the above code by Ashish J. on 7th Oct 2021 after field type change is deployed
					//check
                }else{
                    newBddRecord.GT_Product_Risk__c = 'Low';
                }
                
                if(gtmiRecWrap != null && (newBddRecord.BDD_Onboard_Type__c == 'Remediation Update' || newBddRecord.BDD_Onboard_Type__c == 'Related Party Update')){
                    newBddRecord.GT_GoldTier_Id__c = gtmiRecWrap.goldtieR_ID;  
                }
                
                string userId = UserInfo.getUserId();
                User activeUser = [Select firstname, lastname, Email From User where Id =: userId limit 1];
                if(activeUser != null){
                    string requestorName = activeUser.Email;
                    integer maxLength = requestorName.indexOf('@');
                    requestorName = requestorName.substring(0, maxLength);
                    if(!considerGTFieldsOnly)
                    	newBddRecord.MDN_OI_Requester__c = requestorName;
                    if(requestorName != ''){
                        list<string> nameList = requestorName.split('\\.');
                        requestorName = '';
                        for(string name: nameList){
                            requestorName = requestorName + ' ' + name;
                        }
                        newBddRecord.GT_Req_Name__c = requestorName.trim();
                    }
                }
               
                Integer mdnOIShortNameLength = SObjectType.BET_BDD_Form__c.Fields.MDN_OI_ShortName__c.Length;
                Integer mdnCoreBusLength = SObjectType.BET_BDD_Form__c.Fields.MDN_CD_Core_Business__c.Length;
                Integer regNumLength = SObjectType.BET_BDD_Form__c.Fields.MDN_CD_RegNum__c.Length;
                Integer taxNumLength = SObjectType.BET_BDD_Form__c.Fields.MDN_CD_PVAT_TaxNum__c.Length;

                if(newBddRecord.MDN_OI_ShortName__c != null && !considerGTFieldsOnly){
                    newBddRecord.MDN_OI_ShortName__c = BET_Utility.truncateText(newBddRecord.MDN_OI_ShortName__c, mdnOIShortNameLength);
                }                
                if(newBddRecord.MDN_CD_Core_Business__c != null && !considerGTFieldsOnly){
                    newBddRecord.MDN_CD_Core_Business__c = BET_Utility.truncateText(newBddRecord.MDN_CD_Core_Business__c, mdnCoreBusLength);
                }
                if(newBddRecord.MDN_CD_RegNum__c != null && !considerGTFieldsOnly){
                    newBddRecord.MDN_CD_RegNum__c = BET_Utility.truncateText(newBddRecord.MDN_CD_RegNum__c, regNumLength);
                }
                if(newBddRecord.MDN_CD_PVAT_TaxNum__c != null && !considerGTFieldsOnly){
                    newBddRecord.MDN_CD_PVAT_TaxNum__c = BET_Utility.truncateText(newBddRecord.MDN_CD_PVAT_TaxNum__c, taxNumLength); 
                }
                newBddRecord.Last_Modifiedby_User__c = userId; 
                newBddRecord.IsSuccessInBulkBatch__c = true;
                try{
					// changed to upsert by Ashish
                    upsert newBddRecord;
                }catch(exception ex){
                    system.debug('Issue in updating new BET Form >> ' + ex.getMessage());
                }
                sRecordId = newBddRecord.Id;
            }
            
            //map EDP data to BET form
            list<BET_Registration_Details__c> regDetailsList = new list<BET_Registration_Details__c>();
            list<BET_BDD_Address__c> addressList             = new list<BET_BDD_Address__c>();
            list<BET_BDD_Address__c> addrTempList            = new list<BET_BDD_Address__c>();
            BET_Registration_Details__c regDetail            = new BET_Registration_Details__c();
            string lei = ''; string giin = '';
            boolean regAddrAv = false; boolean traAddrAv = false; boolean taxIdAv = false;
            boolean leiAv = false; boolean giinAv = false; boolean regNumAv = false;
            boolean mapLegalAddrToOperAddr = false;
            id mdnRecordTypeId = BET_Utility.getRecordTypeIdByName('BET_BDD_Address__c', 'MDN');
            
            if(sRecordId != null || sRecordId != ''){
                newRecWrap.recId = sRecordId;
                if(orbisRecWrap != null || bankersRecWrap != null){
                    system.debug('Start >> Add child records to BDD form');
                    //primary source field mapping
                    if(primarySource == 'Orbis' && orbisRecWrap != null){
                        system.debug('Start >> Primary >> Orbis');
                        if(orbisRecWrap.bvdid != null){
                            bvdId = orbisRecWrap.bvdid;
                        }
                        if(orbisRecWrap.addresS_LINE1 != null){
                            if(orbisRecWrap.address_Line1_Additional == null){
                                mapLegalAddrToOperAddr = true;
                            }
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Registered', onBoardingType, gtPicklistValues, mdnPicklistValues, mapLegalAddrToOperAddr);
                            for(BET_BDD_Address__c  addrTemp : addrTempList){
								if(addrTemp.recordTypeId != mdnRecordTypeId){
									addressList.add(addrTemp);
								}
							}
							//addressList.addAll(addrTempList);
                            regAddrAv = true;
                        }
                        if(orbisRecWrap.address_Line1_Additional != null){
                            addrTempList = null;
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Trading', onBoardingType, gtPicklistValues, mdnPicklistValues, false);
                            for(BET_BDD_Address__c  addrTemp : addrTempList){
								if(addrTemp.recordTypeId != mdnRecordTypeId){
									addressList.add(addrTemp);
								}
							}
							//addressList.addAll(addrTempList);
                            traAddrAv = true;
                        }
                        
                        //check if the country is part of picklist
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisRecWrap.country, gtPicklistValues);
                        if(picklistValAv == false){
                            orbisRecWrap.country = '';
                        }
                        
                        lei = orbisRecWrap.lei;
                        if(lei != ''){
                            regDetail = getRegDetailRec('LEI', lei, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            leiAv = true;
                        }
                        if(!(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty()){
                            string regNum = orbisRecWrap.tradE_REGISTER_NUMBER.toString();
                            regNum = regNum.substring(1, regNum.length() - 1);
                            regDetail = null;
                            regDetail = getRegDetailRec('Registration Number', regNum, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            regNumAv = true;
                        }
                        taxId = '';
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        system.debug('registration details map >> taxId >> ' + taxId);
                        if(taxId != ''){
                            regDetail = getRegDetailRec('Tax ID', taxId, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            taxIdAv = true;
                        }
                    }else if(primarySource == 'Bankers Almanac' && bankersRecWrap != null){
                        system.debug('Start >> Primary >> Bankers');
                        lei = bankersRecWrap.lei;
                        system.debug('lei >> ' + lei);
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(bankersRecWrap.country, gtPicklistValues);
                        if(picklistValAv == false){
                            bankersRecWrap.country = ''; 
                        }
                        
                        if(lei != null){
                            regDetail = null;
                            regDetail = getRegDetailRec('LEI', lei, bankersRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                            leiAv = true;
                        }
                        //system.debug('bankersRecWrap.giin >> ' + bankersRecWrap.giin);  
                        if(!(bankersRecWrap.giin).isEmpty()){
                            giin = bankersRecWrap.giin.toString();
                            giin = giin.substring(1, giin.length() - 1);
                            regDetail = null;
                            regDetail = getRegDetailRec('Other', GIIN, bankersRecWrap.country, sRecordId);
                            regDetail.Registration_Type_Other__c = 'GIIN';
                            regDetailsList.add(regDetail);
                            giinAv = true;
                        }
                        system.debug('bankBaidDetails >> ' + bankBaidDetails);
                        //bankBaidDetails = null;
                        if(bankBaidDetails != null){
                            system.debug('bankBaidDetails >> not null');
                            system.debug('bankBaidDetails.regAddressLine1 >> ' + bankBaidDetails.regAddressLine1);

                            if(bankBaidDetails.regAddressLine1 != null){
                                if(bankBaidDetails.tradAddressLine1 == null){
                                    mapLegalAddrToOperAddr = true;
                                }                                
                                addrTempList = createBankersAddressRec(sRecordId, bankBaidDetails, region, 'Registered', onBoardingType, 
                                                                       gtPicklistValues, mdnPicklistValues, mapLegalAddrToOperAddr);
                                if(addrTempList.size() > 0){
                                    addressList.addAll(addrTempList);
                                    regAddrAv = true;
                                }
                                system.debug('temp address list' + addrTempList);
                            }
                            system.debug('bankBaidDetails.tradAddressLine1 >> ' + bankBaidDetails.tradAddressLine1);
                            if(bankBaidDetails.tradAddressLine1 != null){
                                addrTempList = null;
                                addrTempList = createBankersAddressRec(sRecordId, bankBaidDetails, region, 'Trading', onBoardingType, 
                                                                       gtPicklistValues, mdnPicklistValues, false);
                                if(addrTempList.size() > 0){
                                    addressList.addAll(addrTempList);
                                    traAddrAv = true;
                                }
                            }
                        }else{
                            system.debug('map registered address from bankers >> API 1');
                            system.debug('bankersRecWrap >> ' + bankersRecWrap.addressLine1);
                            if(bankersRecWrap.addressLine1 != null){
                                bankBaidDetails = new BET_BDD_BankersDetailsWrapper();
                                addrTempList = null;
                                bankBaidDetails.regAddressLine1 = bankersRecWrap.addressLine1;
                                bankBaidDetails.regAddressLine2 = bankersRecWrap.addressLine2;
                                bankBaidDetails.regAddressLine3 = bankersRecWrap.addressLine3;
                                bankBaidDetails.regAddressLine4 = bankersRecWrap.addressLine4;
                                bankBaidDetails.regCity = bankersRecWrap.city;
                                bankBaidDetails.regcountry = bankersRecWrap.country;
                                bankBaidDetails.regPostalCode = bankersRecWrap.postalCode;
                                addrTempList = createBankersAddressRec(sRecordId, bankBaidDetails, region, 'Registered', onBoardingType, 
                                                                       gtPicklistValues, mdnPicklistValues, true);
                                if(addrTempList.size() > 0){
                                    addressList.addAll(addrTempList);
                                    regAddrAv = true;
                                }
                            }
                        }
                    }
                    
                    //secondary source field mapping
                    if(secondarySource == 'Orbis' && orbisRecWrap != null){
                        system.debug('secondary >> Orbis >> started');
                        if(regAddrAv == false && orbisRecWrap.addresS_LINE1 != null){
                            addrTempList = null;
                            if(orbisRecWrap.address_Line1_Additional == null){
                                mapLegalAddrToOperAddr = true;
                            }
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Registered', onBoardingType, gtPicklistValues, 
                                                                 mdnPicklistValues, mapLegalAddrToOperAddr);
                            for(BET_BDD_Address__c  addrTemp : addrTempList){
								if(addrTemp.recordTypeId != mdnRecordTypeId){
									addressList.add(addrTemp);
								}
							}
							//addressList.addAll(addrTempList);
                        }
                        
                        if(traAddrAv == false && orbisRecWrap.address_Line1_Additional != null){
                            addrTempList = null;
                            addrTempList = createOrbisAddressRec(sRecordId, orbisRecWrap, region, 'Trading', onBoardingType, gtPicklistValues, 
                                                                 mdnPicklistValues, false);
                            for(BET_BDD_Address__c  addrTemp : addrTempList){
								if(addrTemp.recordTypeId != mdnRecordTypeId){
									addressList.add(addrTemp);
								}
							}
							//addressList.addAll(addrTempList);
                            traAddrAv = true;
                        }
                        
                        //check if the country is part of picklist
                        picklistValAv = false;
                        picklistValAv = checkIfPicklistValExists(orbisRecWrap.country, gtPicklistValues);
                        if(picklistValAv == false){
                            orbisRecWrap.country = '';
                        }
                        system.debug('orbisRecWrap.country >> ' + orbisRecWrap.country);
                        lei = orbisRecWrap.lei;
                        if(leiAv == false && lei != ''){
                            regDetail = null;
                            regDetail = getRegDetailRec('LEI', lei, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                        }
                        if(regNumAv == false && !(orbisRecWrap.tradE_REGISTER_NUMBER).isEmpty() && regAddrAv == false){
                            system.debug('seconday >> orbis >> reg address added');
                            string regNum = orbisRecWrap.tradE_REGISTER_NUMBER.toString();
                            regNum = regNum.substring(1, regNum.length() - 1);
                            regDetail = null;
                            regDetail = getRegDetailRec('Registration Number', regNum, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                        }
                        taxId = getTaxIdFromWrapper(orbisRecWrap, region);
                        if(taxIdAv == false && taxId != ''){
                            regDetail = null;
                            regDetail = getRegDetailRec('Tax ID', taxId, orbisRecWrap.country, sRecordId);
                            regDetailsList.add(regDetail);
                        }
                    }else if(secondarySource == 'Bankers Almanac' && bankersRecWrap != null){
                        
                    }
                }
                
                //document section   
                system.debug('*****Upload document section***');    
                string verCountryCode = '';
                map<string, string> verSourceMap = BET_Utility.getSourceName(region, entType, '', 'Verification');
                system.debug('verSourceMap >> ' + verSourceMap);
                if(verSourceMap.ContainsKey('SourceName')){
                    verSource = verSourceMap.get('SourceName');
                }
                system.debug('bankersAlmanacId >> ' + bankersAlmanacId);
                BET_Utility.BddDocumentWrap bddDocWrap = new BET_Utility.BddDocumentWrap();
                bddDocWrap.bvdId = bvdId;
                bddDocWrap.baId = bankersAlmanacId;
                bddDocWrap.formRecId = sRecordId;
                bddDocWrap.bddRegion = region;
                bddDocWrap.entityType = entType;
                bddDocWrap.gtLegalName = newBddRecord.GT_Legal_Name__c;                
                bddDocWrap.primarySource = docPrimSource;
                bddDocWrap.secondarySource = docSecSource;
                if(UIVerfDone == true){
                    system.debug('**UI Verifcation is done**');
                    system.debug('verSource is ' + verSource);
                    system.debug('ver tax id is ' + verfTaxVATNum);
                    bddDocWrap.verficationSource = verSource;
                    if(verSource == 'VIES'){
                        verCountryCode = BET_Utility.countryISOMatcher(verfCountry);
                        verfTaxVATNum = verfTaxVATNum.replace(verCountryCode, '');
                        bddDocWrap.taxVATNumber = verfTaxVATNum;
                        bddDocWrap.countryCode = verCountryCode;
                    }else if(verSource == 'IRS'){
                        bddDocWrap.taxVATNumber = verfTaxVATNum;
                    }else if(verSource == 'OFAC' && newBddRecord.Srch_Vsl_Name_or_IMO__c != ''){
                        system.debug('verf OFAC: IMO# > ' + newBddRecord.Srch_Vsl_Name_or_IMO__c);
                        bddDocWrap.imoNumber = Integer.valueof(newBddRecord.Srch_Vsl_Name_or_IMO__c);
                    }
                }
                bddDocWrapList.add(bddDocWrap);
            }
            
            if(bddDocWrapList.size() > 0){
                BET_Utility.createBddDocument(bddDocWrapList);
            }
            
            if(regDetailsList.size() > 0){
                try{
                    database.insert(regDetailsList);
                }catch(exception ex){
                    system.debug('BET_BDD_Search_Controller >> inserting registration child records : ' + ex.getMessage());
                }
            }
            
            if(addressList.size() > 0){
                try{
                    database.insert(addressList);
                }catch(exception ex){
                    system.debug('BET_BDD_Search_Controller >> inserting address child records : ' + ex.getMessage());
                }
            }
        }catch(exception ex){
            system.debug('BET_BDD_Search_Controller update method : ' + ex.getMessage()+ ' Line no: '+ex.getLineNumber());
        }
        return newRecWrap;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<BET_BDD_Form__c> getBulkUploadRecords( String searchKey, String sortBy,  String sortDirection) {
        string recTypeIDWonaCpt = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW CPT/BANK FORM').getRecordTypeId(); 
        //string recTypeIDWonaIndvl = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW INDIVIDUAL FORM').getRecordTypeId();
        String betstatus ='Draft';
        String yesString ='Yes';
        Set<String> recordtypeSet = new Set<String>{recTypeIDWonaCpt};
            String query = ' SELECT Id,Assigned_COF__c, Assigned_COF__r.Name,Name,GT_Legal_Name__c,recordtypeId,recordtype.Name,BET_Status__c, BDD_Entity_Type__c,Full_Legal_Name__c,Inc_Country__c,BDD_Line_of_Business__c,BDD_Onboard_Type__c FROM BET_BDD_Form__c ';
        query +=' WHERE RecordTypeId IN :recordtypeSet and IsSuccessInBulkBatch__c = true AND BET_Status__c =:betstatus AND BDD_Eligible_Status__c =:yesString  AND Assigned_COF__c =: loggedInUser ';
        system.debug('query---'+query);
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' AND (Name LIKE :key OR GT_Legal_Name__c LIKE :key)';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        query = query + ' LIMIT 10000 ';
        return Database.query( query );
    }
}