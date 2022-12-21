public class BET_Utility {    
    public static string countryISOMatcher(string country){
        string countryCode = '';
        List<BET_Country_ISO__mdt> countryiso = [SELECT ISO__c, Country__c from BET_Country_ISO__mdt where Country__c=:country LIMIT 1];			        
        if(!countryiso.isEmpty()){
            countryCode = countryiso[0].ISO__c; 
        }
        return countryCode;      
    }
    
    public static string truncateText(string text, integer txtLength){
        string updText = '';
        if((text != '' || text != null || text != 'null') && (text.length() > txtLength)){
            updText = text.substring(0, txtLength); 
        }else{
            updText = text;
        }
        return updText;
    }
    
    public static List<String> getPickListValuesIntoList(string objectName, string field_apiname){
        List<String> pickListValues = new List<String>();     
        try{
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();            
            List<Schema.PicklistEntry> picklistVal = field_map.get(field_apiname).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry pv : picklistVal) {
                pickListValues.add(pv.getValue());
            }
        }catch(exception ex){
            system.debug('BET_Utility >> getPickListValuesIntoList : ' + ex.getMessage());
        }
        return pickListValues;
    }
      
    public static list<String> getCoreBusPicklistValuesByName(){  
        list<string> picklistValues = new list<string>();
        try{
            Schema.DescribeFieldResult fieldResult = BET_BDD_Form__c.GT_Core_Business_Act__c.getDescribe();
            List<Schema.PicklistEntry> coreBusActPickList = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry item : coreBusActPickList) {
                system.debug(item.getLabel());
                picklistValues.add(item.getLabel());
            }            
        }catch(exception ex){
            system.debug('BET_Utility >> getCoreBusPicklistValuesByName : ' + ex.getMessage());
        }
        return picklistValues;
    }
    
    public static string getCountryCodeByName(string country){
        string countryCode = '';
        try{
            List<BET_Bankers_Country_Mapping__mdt> countryiso = [SELECT ISO_Code__c from BET_Bankers_Country_Mapping__mdt where Country_Name__c=:country LIMIT 1];			        
            if(!countryiso.isEmpty()){
                countryCode = countryiso[0].ISO_Code__c; 
            }
        }catch(exception ex){
            system.debug('BET_Utility >> getCountryCodeByName() : ' + ex.getMessage());
        }
        return countryCode;
    }
    
    public static map<string, string> getDataSourceMapping(string region, string entType){
        map<string, string> dataSourceMap = new map<string, string>();
        BET_EDP_Source_Mapping__mdt sMapping = [select Primary_Source__c, Secondary_Source__c, Ver_Source__c from BET_EDP_Source_Mapping__mdt 
                                                where Region__c =:region and Entity_Type__c =:entType];
        if(sMapping != null){
            dataSourceMap.put('Primary', sMapping.Primary_Source__c);
            dataSourceMap.put('Secondary', sMapping.Secondary_Source__c);
        }
        return dataSourceMap;
    }
    
    public static map<string, string> getGtAddressTypeByRegion(string region, string mdnAddrType){
        string gtAddrType = ''; 
        map<string, string> addrTypeMap = new map<string, string>();
        if(region == 'WONA'){
            if(mdnAddrType == 'Registered'){
                mdnAddrType = 'Registered';
                gtAddrType = 'Legal';
            }else if(mdnAddrType == 'Trading'){
                gtAddrType = 'Operating';
            }
        }else if(region == 'SENA'){
            if(mdnAddrType == 'Registered'){
                mdnAddrType = 'Legal';
                gtAddrType = 'Legal';
            }else if(mdnAddrType == 'Trading'){
                mdnAddrType = 'Physical';
                gtAddrType = 'Operating';
            }
        }else if(region == 'STUSCO'){
            if(mdnAddrType == 'Registered'){
                mdnAddrType = 'Invoice';
                gtAddrType = 'Legal';
            }else if(mdnAddrType == 'Trading'){
                mdnAddrType = 'Other';
                gtAddrType = 'Operating';
            }
        }
        addrTypeMap.put('mdnAddrType', mdnAddrType);
        addrTypeMap.put('gtAddrType', gtAddrType);
        return addrTypeMap;
    }
    
    public static map<string, string> getSourceName(string sRegion, string sEntityType, string sourceType, string sOperation){
        string dataSource = '';
        map<string, string> dataSourceMap = new map<string, string>();
        BET_EDP_Source_Mapping__mdt sMapping = [select Primary_Source__c, Secondary_Source__c, Ver_Source__c from BET_EDP_Source_Mapping__mdt 
                                                where Region__c =:sRegion and Entity_Type__c =:sEntityType];
        system.debug('sMapping :' + sMapping);
        if(sMapping != null){
            if(sOperation == 'Identification'){
                if(sourceType == 'Primary'){
                    dataSource = sMapping.Primary_Source__c;
                    if(sMapping.Secondary_Source__c == 'NA'){
                        dataSourceMap.put('AdditionalSource', 'NA');
                    }else{
                        dataSourceMap.put('AdditionalSource', 'Available');
                    }
                }else if(sourceType == 'Secondary'){
                    dataSource = sMapping.Secondary_Source__c;
                }
                dataSourceMap.put(sourceType, dataSource);
            }else if(sOperation == 'Verification'){
                dataSource = sMapping.Ver_Source__c;
				dataSourceMap.put('SourceName', dataSource);
            }
        }
        return dataSourceMap;
    }
        
    public static string getRecordTypeId(string sRegion, string sEntity, string sOnboardingType){
        string recordTypeId = null;
        string recordTypeName = null;
        if(sRegion == 'WONA'){
            if((sOnboardingType == 'New Onboard' || sOnboardingType == 'Related Party Update') && (sEntity == 'Bank' || sEntity == 'Counterparty')){
                recordTypeName = 'WONA_NEW_CPTBNK';
            }else if(sOnboardingType == 'Remediation Update' && (sEntity == 'Bank' || sEntity == 'Counterparty')){
                recordTypeName = 'WONA_REM_CPTBNK';
            }else if((sOnboardingType == 'New Onboard' || sOnboardingType == 'Related Party Update') && sEntity == 'Individual'){
                recordTypeName = 'WONA_NEW_IND';
            }else if((sOnboardingType == 'Remediation Update') && (sEntity == 'Individual')){
                recordTypeName = 'WONA_REM_IND';
            }
        }else if(sRegion == 'SENA'){
            if((sOnboardingType == 'New Onboard' || sOnboardingType == 'Related Party Update') && (sEntity == 'Bank' || sEntity == 'Counterparty')){
                recordTypeName = 'SENA_NEW_CPTBNK';
            }else if(sOnboardingType == 'Remediation Update' && (sEntity == 'Bank' || sEntity == 'Counterparty')){
                recordTypeName = 'SENA_REM_CPTBNK';
            }else if((sOnboardingType == 'New Onboard' || sOnboardingType == 'Related Party Update') && sEntity == 'Individual'){
                recordTypeName = 'SENA_NEW_IND';
            }else if((sOnboardingType == 'Remediation Update') && (sEntity == 'Individual')){
                recordTypeName = 'SENA_REM_IND';
            }
        }else if(sRegion == 'STUSCO'){
            if((sOnboardingType == 'New Onboard' || sOnboardingType == 'Related Party Update') && (sEntity == 'Bank' || sEntity == 'Counterparty')){
                recordTypeName = 'STUSCO_NEW_CPTBNK';
            }else if((sOnboardingType == 'Remediation Update') && (sEntity == 'Bank' || sEntity == 'Counterparty')){
                recordTypeName = 'STUSCO_REM_CPTBNK';
            }else if((sOnboardingType == 'New Onboard' || sOnboardingType == 'Related Party Update') && sEntity == 'Individual'){
                recordTypeName = 'STUSCO_NEW_IND';
            }else if((sOnboardingType == 'Remediation Update') && (sEntity == 'Individual')){
                recordTypeName = 'STUSCO_REM_IND';
            }
        }else{
            recordTypeName = 'GLOBAL_NEW_VES';
        }
        recordTypeId = getRecordTypeIdByName('BET_BDD_Form__c', recordTypeName);
        return recordTypeId;
    } 
    
    public static id getRecordTypeIdByName(string objectAPIName, string recordTypeName){
        id recordTypeId;
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapOfRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapOfRecordTypeNameandId.put(info.getDeveloperName(), info.getRecordTypeId());
        }
        recordTypeId = mapOfRecordTypeNameandId.get(recordTypeName);
        system.debug('recordTypeId >> ' + recordTypeId);
        return recordTypeId;
    }
	
	/*Method Name   : createBddDocument
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : This method updates BDD Document object record missing fields from the BDD Document Map metadata records.
     */
    public static void createBddDocument(List<BddDocumentWrap> bddDocWrapList){
        List<BET_BDD_Document__c> bddDocList = new List<BET_BDD_Document__c>();
        List<BET_BDD_Support_Doc_Auto_Create_Map__mdt> autoCreateDocMatrixList = new List<BET_BDD_Support_Doc_Auto_Create_Map__mdt>();
        autoCreateDocMatrixList = [SELECT MasterLabel,
                                          Region__c,
                                          Entity_Type__c,
                                          Active__c,
                                          Primary_Source__c,
                                          Secondary_Source__c,
                                          Verification_Source__c,
                                          Document_Category__c,
                                          Document_Type__c,
                                          Document_Creation_Source__c FROM BET_BDD_Support_Doc_Auto_Create_Map__mdt LIMIT 50000];
        if(!bddDocWrapList.isEmpty() && !autoCreateDocMatrixList.isEmpty()){
            for(BddDocumentWrap bddDocWrap : bddDocWrapList){
                String docRecTypeId =  '';
                System.debug('BET_Utility >> createBddDocument() >> bddDocWrap: ' + bddDocWrap);
                if(!String.isEmpty(bddDocWrap.formRecId) && !String.isEmpty(bddDocWrap.bddRegion) && !String.isEmpty(bddDocWrap.entityType) &&
                    (!String.isEmpty(bddDocWrap.primarySource) || !String.isEmpty(bddDocWrap.secondarySource) || !String.isEmpty(bddDocWrap.verficationSource)) &&
                    (!String.isEmpty(bddDocWrap.bvdId) || !String.isEmpty(bddDocWrap.taxVATNumber) || bddDocWrap.imoNumber != null || !String.isEmpty(bddDocWrap.baid)) &&
                     !String.isEmpty(bddDocWrap.gtLegalName)){
                    try{
                        docRecTypeId = Schema.SObjectType.BET_BDD_Document__c.getRecordTypeInfosByName().get(bddDocWrap.bddRegion).getRecordTypeId();
                    }
                    catch(Exception e){
                        //Log exception but do not throw error.
                        System.debug('BET_Utility >> createBddDocument(): Exception: ' + e.getMessage());
                    }
                    if(!String.isEmpty(docRecTypeId)){
                        for(BET_BDD_Support_Doc_Auto_Create_Map__mdt docMatrix : autoCreateDocMatrixList){
                            if(bddDocWrap.bddRegion == docMatrix.Region__c && bddDocWrap.entityType == docMatrix.Entity_Type__c && docMatrix.Active__c){
                                BET_BDD_Document__c bddDoc = new BET_BDD_Document__c();
                                bddDoc.RecordTypeId = docRecTypeId;
                                bddDoc.BET_BDD_Form__c = bddDocWrap.formRecId;
                                bddDoc.BET_Upload_Status__c = '	In Progress';
                                if(bddDocWrap.primarySource == docMatrix.Primary_Source__c && bddDocWrap.secondarySource == docMatrix.Secondary_Source__c && 
                                   !String.isEmpty(bddDocWrap.primarySource) && !String.isEmpty(bddDocWrap.secondarySource)){
                                    if(docMatrix.Document_Creation_Source__c == 'Primary'){
                                        bddDoc.BET_Document__c = docMatrix.Document_Category__c;
                                        bddDoc.BET_Document_Type__c = docMatrix.Document_Type__c;
                                        bddDoc.BET_Source__c = docMatrix.Primary_Source__c;
                                        bddDoc.BET_EDP_Doc_Id__c = bddDocWrap.baId;
                                    }
                                    else if(docMatrix.Document_Creation_Source__c == 'Secondary'){
                                        bddDoc.BET_Document__c = docMatrix.Document_Category__c;
                                        bddDoc.BET_Document_Type__c = docMatrix.Document_Type__c;
                                        bddDoc.BET_Source__c = docMatrix.Secondary_Source__c;
                                        bddDoc.BET_EDP_Doc_Id__c = bddDocWrap.bvdId;
                                    }
                                    else{
                                        //Couldn't find valid metadata.
                                    }
                                }
                                else if(!String.isEmpty(bddDocWrap.primarySource) && String.isEmpty(bddDocWrap.secondarySource) &&
                                        bddDocWrap.primarySource == docMatrix.Primary_Source__c && docMatrix.Secondary_Source__c == null){
                                    bddDoc.BET_Document__c = docMatrix.Document_Category__c;
                                    bddDoc.BET_Document_Type__c = docMatrix.Document_Type__c;
                                    bddDoc.BET_Source__c = docMatrix.Primary_Source__c;
                                    if(!String.isEmpty(bddDocWrap.baId))
                                        bddDoc.BET_EDP_Doc_Id__c = bddDocWrap.baid;
                                    if(!String.isEmpty(bddDocWrap.bvdId))
                                        bddDoc.BET_EDP_Doc_Id__c = bddDocWrap.bvdId;
                                }
                                else if(!String.isEmpty(bddDocWrap.secondarySource) && String.isEmpty(bddDocWrap.primarySource) && 
                                        bddDocWrap.secondarySource == docMatrix.Secondary_Source__c && docMatrix.Primary_Source__c == null){
                                    bddDoc.BET_Document__c = docMatrix.Document_Category__c;
                                    bddDoc.BET_Document_Type__c = docMatrix.Document_Type__c;
                                    bddDoc.BET_Source__c = docMatrix.Secondary_Source__c;
                                    if(!String.isEmpty(bddDocWrap.baId))
                                        bddDoc.BET_EDP_Doc_Id__c = bddDocWrap.baid;
                                    if(!String.isEmpty(bddDocWrap.bvdId))
                                        bddDoc.BET_EDP_Doc_Id__c = bddDocWrap.bvdId;
                                }
                                else if(!String.isEmpty(bddDocWrap.verficationSource) && bddDocWrap.verficationSource  == docMatrix.Verification_Source__c){
                                    bddDoc.BET_Document__c = docMatrix.Document_Category__c;
                                    bddDoc.BET_Document_Type__c = docMatrix.Document_Type__c;
                                    bddDoc.BET_Source__c = docMatrix.Verification_Source__c;
                                    if(bddDocWrap.imoNumber != null)
                                        bddDoc.BET_EDP_Ver_Id__c = String.valueOf(bddDocWrap.imoNumber);
                                    else if(!String.isEmpty(bddDocWrap.taxVATNumber))
                                        bddDoc.BET_EDP_Ver_Id__c = bddDocWrap.taxVATNumber;
                                    if(!String.isEmpty(bddDocWrap.countryCode))
                                        bddDoc.BET_Country_Code__c = bddDocWrap.countryCode;
                                    if(!String.isEmpty(bddDocWrap.searchType))
                                        bddDoc.BET_Search_Type__c = bddDocWrap.searchType;
                                }
                                else{
                                    //Couldn't find valid metadata.
                                }
                                //Check if all required data is populated before creating document.
                                if(bddDoc != null && bddDoc.BET_Document__c != null && bddDoc.BET_Document_Type__c != null && bddDoc.BET_Source__c != null &&
                                   bddDoc.BET_BDD_Form__c != null && bddDoc.RecordTypeId != null){
                                    bddDocList.add(bddDoc);
                                }
                            }  
                        }
                    }
                    else{
                        //Log reccord type id not found. Log exception.
                        System.debug('BET_Utility >> createBddDocument(): RecordTypeId/Folder name not found.');
                    }
                }
                else{
                    //Log exception but do not throw error.
                    System.debug('BET_Utility >> createBddDocument(): BDD Document could not be created. Input parameters are invalid or null.');
                }
            }
        }
        else{
            //bddDocWrapList is empty.
        }
        if(!bddDocList.isEmpty()){
            try{
                Database.insert(bddDocList, false);
            }
            catch(Exception e){
                System.debug('BET_Utility >> createBddDocument() >> Exception: ' + e.getMessage());
            }
        }
        else{
            System.debug('BET_Utility >> createBddDocument(): No document is created.');
        }
    }

    /*Method Name   : BddDocumentWrap
     *Date          : 31-Aug-20
     *Developer     : Rahul Sharma
     *Description   : Wrapper class for BDD Document.
     */
    public class BddDocumentWrap{
        public String bvdId;
        public String baId;
        public String formRecId;
        public String bddRegion;
        public String entityType;
        public String gtLegalName;
        public String primarySource;
        public String secondarySource;
        public String verficationSource;
        public String taxVATNumber;
        public String taxVATCountry;
        public String countryCode;
        public Integer imoNumber;
        public String taxIdType ;
        public String name;
        public String searchType = 'i';

    }
}