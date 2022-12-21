/***********************************************************************************************************
* @Name        		: BET_BDDFormTriggerHelper  
* @Author       
* @Description  	: This class contains all methods related to trigger on object BET_BDD_Form__c
*******************************************************************************************/
/* MODIFICATION LOG
* Developer          			Date               		Description
*-------------------------------------------------------------------------------------------                 
Ashish.A.Jadhav@shell.com		29/09/2021				Added the method "relationShipMandatoryValidation"
														to check the mandatory fields have values selected.
Ashish.A.Jadhav@shell.com		06/10/2021				Commented the method "relationShipMandatoryValidation"

Ashish.A.Jadhav@shell.com		06/10/2021				Modified the method "fieldRequiredCheck" for adding 
														error message and highlighting the error causing fields.
***********************************************************************************************************/
public class BET_BDDFormTriggerHelper { 
    static final String Address_Mandatory_Felds = 'Address_Type__c;Country__c;AddLine1__c;City__c;State_Lkp__c;PostCode__c';
    static final String Address_Mandatory_Fields_Gold = 'Address_Type__c;Country__c;AddLine1__c;City__c';
    static final String Gsap_Fields_List = 'GSAP_Classof_Prod__c;GSAP_Legal_Status__c;GSAP_Export_Allowed__c;GSAP_Delivery_Pri__c;GSAP_Incoterm_Desc__c;GSAP_Incoterm__c;GSAP_Sales_Group__c;GSAP_SalesPayment_Term__c;GSAP_Purchase_PaymentTerm__c;GSAP_Banding__c;GSAP_Ship_Cond__c;GSAP_Customer_Sector__c;GSAP_Desired_CredLimit__c;GSAP_NACE_Code__c;GSAP_NAICS_Code__c';
    public static Boolean validateEmail(String email){
        Pattern MyPattern = Pattern.compile('\\w+([-+.\']\\w+)*@(?i:shell.com)');
        Matcher MyMatcher = MyPattern.matcher(email);
        return MyMatcher.matches();
    }
    public static void emailFieldValidation(List<BET_BDD_Form__c> bddForm,Map<Id,BET_BDD_Form__c> oldBddRec){
        for(BET_BDD_Form__c formRec : bddForm){
            BET_BDD_Form__c oldRec = new BET_BDD_Form__c();
            if(oldBddRec != Null){
                oldRec = oldBddRec.get(formRec.Id);}
            if((oldRec != Null && formRec.MDN_EmailAddList__c != Null && oldRec.MDN_EmailAddList__c != formRec.MDN_EmailAddList__c)|| (oldRec == Null && formRec.MDN_EmailAddList__c != Null)){
                if(formRec.MDN_EmailAddList__c.endsWith(';')){
                    formRec.addError('Invalid email format or email domain');
                }
                else{
                    formRec.MDN_EmailAddList__c = formRec.MDN_EmailAddList__c.replaceAll( '\\s+', '');
                    List<String> emailsList = formRec.MDN_EmailAddList__c.split(';');
                    for(String str : emailsList){
                        Boolean isValid = validateEmail(str);
                        if(isValid == false){
                            formRec.addError('Invalid email format or email domain');}  
                    }}}}}
    public static void updateLastModifiedbyUser(List<BET_BDD_Form__c> bddForm){
        for(BET_BDD_Form__c formRec : bddForm){
            System.debug('last modified**'+formRec.LastModifiedById);
            if(formRec.BET_Status__c != 'Submitted' && formRec.LastModifiedById != Null){
                formRec.Last_Modifiedby_User__c = formRec.LastModifiedById;
            }}}
    public static void ownerValidateonUpdate(List<BET_BDD_Form__c> bddForm, Boolean isInsert){
        if(isInsert == true){
            Set<Id> ownerList = new Set<Id>();
            for(BET_BDD_Form__c fromRec : bddForm){
                ownerList.add(fromRec.OwnerId);
            }
            Map<Id,List<String>> permissionsMap = new Map<Id,List<String>>();
            permissionsMap = BET_BDDFormTriggerUtil.getPermissionListBulk(ownerList);
            for(BET_BDD_Form__c fromRec : bddForm){
                List<String> permissionsList = new List<String>();
                permissionsList = permissionsMap.get(fromRec.OwnerId);
                if(permissionsList != Null && permissionsList.contains('BET_COF')){
                    fromRec.Assigned_COF__c = fromRec.OwnerId;
                }
                else{
                    fromRec.addError('Only COF user can be the Owner of the record');
                }}}
    }
    public static void ownerUpdateValidation(List<BET_BDD_Form__c> bddForm){
        Set<Id> ownerList = new Set<Id>();
        for(BET_BDD_Form__c fromRec : bddForm){
            ownerList.add(fromRec.OwnerId);
        }
        System.debug('owner list'+ownerList);
        Map<Id,List<String>> permissionsMap = new Map<Id,List<String>>();
        permissionsMap = BET_BDDFormTriggerUtil.getPermissionListBulk(ownerList);
        for(BET_BDD_Form__c fromRec : bddForm){
            List<String> permissionsList = new List<String>();
            permissionsList = permissionsMap.get(fromRec.OwnerId);
            if(permissionsList != Null && permissionsList.contains('BET_COF')){
                fromRec.Assigned_COF__c = fromRec.OwnerId;
            }
            else{
                continue;
            }}}
    public static void updateOwnerAndCof(List<BET_BDD_Form__c> bddForm, Map<Id,BET_BDD_Form__c> oldBddRec, Boolean isUpdate){
        System.debug('method called');
        List<BET_BDD_Form__c> validateOwnerRecs = new List<BET_BDD_Form__c>();
        for(BET_BDD_Form__c fromRec : bddForm){
            BET_BDD_Form__c oldRec = oldBddRec.get(fromRec.Id);
            if((fromRec.Assigned_COF__c != Null && fromRec.OwnerId == Null) ||((oldRec.Assigned_COF__c != fromRec.Assigned_COF__c) && fromRec.Assigned_COF__c != fromRec.OwnerId))
                fromRec.OwnerId = fromRec.Assigned_COF__c;
            else if((fromRec.OwnerId != Null && fromRec.Assigned_COF__c == Null)||((oldRec.OwnerId != fromRec.OwnerId) && fromRec.OwnerId != fromRec.Assigned_COF__c))
            {
                validateOwnerRecs.add(fromRec);
            }
        }
        if(validateOwnerRecs.size()>0)
            ownerValidateonUpdate(validateOwnerRecs,isUpdate);
    }
    public static void makeGsapFieldsNull(BET_BDD_Form__c bddForm){
        List<String> gsapFields = Gsap_Fields_List.split(';');
        for(String str : gsapFields){
            bddForm.put(str,Null); 
        }
    }
    public static void fillGsapDefaults(List<BET_BDD_Form__c> bddForm,Map<Id,BET_BDD_Form__c> bddFormold){
        Map<String,BET_Custom_Picklist__c> defaultCodeMap = new Map<String,BET_Custom_Picklist__c>();
        List<BET_Custom_Picklist__c> getNaceNaicsDefaults = [SELECT BET_NACE_Code__c,BET_NAICS_Code__c,BET_Picklist_Value__c,Name FROM BET_Custom_Picklist__c WHERE BET_Picklist_Value__c LIKE '%425110%' or BET_Picklist_Value__c LIKE '%424720%' or BET_Picklist_Value__c LIKE '%46.71%' or BET_Picklist_Value__c LIKE '%46.12%'];
        for(BET_Custom_Picklist__c pklstVal : getNaceNaicsDefaults){
            if(pklstVal.BET_Picklist_Value__c.contains('424720'))
                defaultCodeMap.put('424720',pklstVal);
            if(pklstVal.BET_Picklist_Value__c.contains('425110'))
                defaultCodeMap.put('425110',pklstVal);
            if(pklstVal.BET_Picklist_Value__c.contains('46.71'))
                defaultCodeMap.put('46.71',pklstVal);
            if(pklstVal.BET_Picklist_Value__c.contains('46.12'))
                defaultCodeMap.put('46.12',pklstVal);
            for(BET_BDD_Form__c formRec : bddForm){
                BET_BDD_Form__c oldRec = new BET_BDD_Form__c();
                if(bddFormold != Null){
                    oldRec = bddFormold.get(formRec.Id);
                }
                if(oldRec != Null){
                    List<String> companyList = new List<String> {'US16 (0201) - SOPUS','USN6 (0301) - STUSCO (Domestic)','0308 - STUSCO (Puerto Rico)','MX01 - Shell Mexico','XXXX - SCAPSA (Argentina)'};
                        List<String> busLineList = new List<String> {'Products','Broker - Products','Terminalling','Marine - Products','SOPUS NOC'};
                            if(oldRec.MDN_OI_Company__c != formRec.MDN_OI_Company__c || oldRec.MDN_CP_Rel_Desc__c != formRec.MDN_CP_Rel_Desc__c || oldRec.MDN_OI_Business_Line__c != formRec.MDN_OI_Business_Line__c){
                                makeGsapFieldsNull(formRec);
                            }
                    boolean companyCheck = ((oldRec.MDN_OI_Company__c == Null && formRec.MDN_OI_Company__c != Null && companyList.contains(formRec.MDN_OI_Company__c)) || (oldRec.MDN_OI_Company__c != formRec.MDN_OI_Company__c && companyList.contains(formRec.MDN_OI_Company__c)));
                    boolean cpRelDesc = ((oldRec.MDN_CP_Rel_Desc__c == Null && formRec.MDN_CP_Rel_Desc__c != Null && formRec.MDN_CP_Rel_Desc__c != 'Vendor Only') || (oldRec.MDN_CP_Rel_Desc__c != formRec.MDN_CP_Rel_Desc__c && formRec.MDN_CP_Rel_Desc__c != 'Vendor Only'));
                    boolean busLine = ((oldRec.MDN_OI_Business_Line__c == Null && formRec.MDN_OI_Business_Line__c != Null && busLineList.contains(formRec.MDN_OI_Business_Line__c)) || (oldRec.MDN_OI_Business_Line__c != formRec.MDN_OI_Business_Line__c && busLineList.contains(formRec.MDN_OI_Business_Line__c)));
                    System.debug('companyCheck**'+companyCheck);
                    System.debug('cpRelDesc**'+cpRelDesc);
                    System.debug('busLine**'+busLine);
                    if((companyCheck || cpRelDesc || busLine)&& (companyList.contains(formRec.MDN_OI_Company__c) && formRec.MDN_CP_Rel_Desc__c != 'Vendor Only' && busLineList.contains(formRec.MDN_OI_Business_Line__c))){
                        BET_BDDFormTriggerUtil.gsapSectionDefault(formRec,defaultCodeMap);
                    }
                }
                else{
                    List<String> companyList = new List<String> {'US16 (0201) - SOPUS','USN6 (0301) - STUSCO (Domestic)','0308 - STUSCO (Puerto Rico)','MX01 - Shell Mexico','XXXX - SCAPSA (Argentina)'};
                        List<String> busLineList = new List<String> {'Products','Broker - Products','Terminalling','Marine - Products','SOPUS NOC'};
                            if((formRec.MDN_OI_Company__c != Null && companyList.contains(formRec.MDN_OI_Company__c)) && (formRec.MDN_CP_Rel_Desc__c != Null && formRec.MDN_CP_Rel_Desc__c != 'Vendor Only')&& (formRec.MDN_OI_Business_Line__c != Null && busLineList.contains(formRec.MDN_OI_Business_Line__c))){
                                BET_BDDFormTriggerUtil.gsapSectionDefault(formRec,defaultCodeMap);
                            }}}}}
    public static void fillGsapDefaultValues(List<BET_BDD_Form__c> bddForm){
       }
    public static void preventSubmitDelete(List<BET_BDD_Form__c> bddForm){
        for(BET_BDD_Form__c fromRec : bddForm){
            if(fromRec.BET_Status__c == 'Submitted'||fromRec.BET_Status__c == 'Ready to Onboard'){
                fromRec.addError('Only ‘BET Status’ is editable at this stage.');
            } } }
    public static void businessLineValidation(List<BET_BDD_Form__c> bddForm){
        for(BET_BDD_Form__c bddRec : bddForm){
            if(bddRec.BDD_Line_of_Business__c != 'STUSCO'){
                if(bddRec.MDN_OI_BusLine_multi__c !=Null){
                    Boolean busLineNonApplicable;
                    /* Boolean onlyOneBusLine;
if((bddRec.MDN_PC_Business_Line__c != Null && bddRec.MDN_PC_Business_Line__c.contains(';')) || (bddRec.MDN_CR_BusLine__c != Null && bddRec.MDN_CR_BusLine__c.contains(';') || bddRec.MDN_BA_BusLine__c != Null && bddRec.MDN_BA_BusLine__c.contains(';')))
bddRec.addError('You can only choose one busi'); */
                    if((bddRec.MDN_PC_Business_Line__c != Null) && (!bddRec.MDN_OI_BusLine_multi__c.contains(bddRec.MDN_PC_Business_Line__c) ||bddRec.MDN_PC_Business_Line__c.contains(';')))
                        bddRec.addError('You can only choose one business line item that is selected in the MDN org information section');
                    if((bddRec.MDN_CR_BusLine__c != Null) && (!bddRec.MDN_OI_BusLine_multi__c.contains(bddRec.MDN_CR_BusLine__c) || bddRec.MDN_CR_BusLine__c.contains(';')))
                        bddRec.addError('You can only choose one business line item that is selected in the MDN org information section');
                    if((bddRec.MDN_BA_BusLine__c != Null) && (!bddRec.MDN_OI_BusLine_multi__c.contains(bddRec.MDN_BA_BusLine__c) || bddRec.MDN_BA_BusLine__c.contains(';')))
                        bddRec.addError('You can only choose one business line item that is selected in the MDN org information section');
                }
                else if((bddRec.MDN_OI_BusLine_multi__c ==Null)&&(bddRec.MDN_PC_Business_Line__c !=Null || bddRec.MDN_CR_BusLine__c !=Null||bddRec.MDN_BA_BusLine__c !=Null)){
                    bddRec.addError('Please complete Business line in MDN org information section to add Business Line in other sections');
                }}
        }}
    public static void updateBusinessLine(List<BET_BDD_Form__c> bddForm,Map<Id,BET_BDD_Form__c> bddFormold){
        set<Id> recIds = new set<Id>();
        List<BET_BDD_Form__c> updateFormRec = new List<BET_BDD_Form__c>();
        List<BET_BDD_Address__c> updateAddressRec = new List<BET_BDD_Address__c>();
        
        for(BET_BDD_Form__c bddRec : bddForm){
            if(bddRec.BDD_Line_of_Business__c != 'STUSCO'){
                if((bddFormold != Null)&&(bddRec.MDN_OI_BusLine_multi__c != bddFormold.get(bddRec.Id).MDN_OI_BusLine_multi__c)){
                    String updateBusLine;
                    if(bddRec.MDN_OI_BusLine_multi__c != Null && bddRec.MDN_OI_BusLine_multi__c.contains(';')){
                        List<String> busLine = bddRec.MDN_OI_BusLine_multi__c.split(';');
                        updateBusLine = busLine.get(0);
                    }
                    else 
                        updateBusLine = bddRec.MDN_OI_BusLine_multi__c;
                    bddRec.MDN_CR_BusLine__c = updateBusLine;
                    bddRec.MDN_BA_BusLine__c = updateBusLine;
                    bddRec.MDN_PC_Business_Line__c = updateBusLine;
                    updateFormRec.add(bddRec);
                }}}}
    
    public static void fieldRequiredCheck(Map<Id,BET_BDD_Form__c> bddFormList){
        List<String> rectyps = new List<String>{'STUSCO NEW INDVIDUAL FORM','STUSCO REMEDIATED INDIVIDUAL FORM','SENA NEW INDVIDUAL FORM','SENA REMEDIATED INDIVIDUAL FORM','WONA NEW INDIVIDUAL FORM','WONA REMEDIATED INDIVIDUAL FORM'};
            map<String,String> metadataMapping = BET_BDDFormTriggerUtil.getFieldSetMetadataMapping();
        map<String,BET_BDD_Required_Address_Mapping__mdt> metadataAddressMapping = BET_BDDFormTriggerUtil.getReqAddressMetadataMapping();
        Boolean hasPermission = FeatureManagement.checkPermission('Ignore_Validation_Rules');
        Map<Id,List<BET_BDD_Address__c>> addressMap = BET_BDDFormTriggerUtil.getAddressMap(bddFormList.keySet());
        Map<Id,List<BET_Registration_Details__c>> regDetMap = BET_BDDFormTriggerUtil.getRegDetailsMap(bddFormList.keySet());
        Map<Id,List<BET_BDD_Document__c>> documentsMap = BET_BDDFormTriggerUtil.getDocumentsMap(bddFormList.keySet());
        For(BET_BDD_Form__c bddForm : bddFormList.values()){
            if((bddForm.BET_Status__c == 'Ready to Onboard') && hasPermission == False){
                String recTypeName;
                boolean isGsapFilled;
                boolean isRegStateFilled;
                if(bddForm.BDD_Line_of_Business__c == 'STUSCO'){
                    isGsapFilled = BET_BDDFormTriggerUtil.isGsapSectionFilled(bddForm);
                }
                if(regDetMap != Null && regDetMap.get(bddForm.Id) != Null &&regDetMap.get(bddForm.Id).size()>0){
                    isRegStateFilled = isRegDetailsStateFilled(regDetMap.get(bddForm.Id));
                }
                if(bddForm.BDD_Line_of_Business__c == 'STUSCO' && bddForm.MDN_OI_Business_Line__c != Null){
                    List<String> counterParty = new List<String>{'Crude','Crude Lease Net'};
                        List<String> vendorOnly = new List<String>{'Crude Lease NonNet','Crude Lease Check','Crude Lease Royalty'};
                            List<String> distributionDivisionNonNull = new List<String>{'Broker - Products','Terminalling','Marine - Products','SOPUS NOC','Products'};
                                String trmnlAgrmntNonNull = 'Products';
                    String lpsNumNonNull = 'Crude Lease Royalty';
                    List<String> federalWatersNonNull = new List<String>{'Crude Lease Net','Crude Lease NonNet','Crude Lease Check','Crude Lease Royalty'};
                        String errorMessage = '';
                    if((counterParty.contains(bddForm.MDN_OI_Business_Line__c) && bddForm.MDN_CP_Rel_Desc__c != 'Counterparty (Customer & Vendor)') )
                        errorMessage = errorMessage+' ‘Counterparty Relationship Description’ ';
                    if(vendorOnly.contains(bddForm.MDN_OI_Business_Line__c) && bddForm.MDN_CP_Rel_Desc__c !='Vendor Only')
                        errorMessage = errorMessage+' ‘Counterparty Relationship Description’ ';
                    if(distributionDivisionNonNull.contains(bddForm.MDN_OI_Business_Line__c) && bddForm.MDN_OI_DistChan__c == Null)
                        errorMessage = errorMessage+' ‘Distribution Channel’ ';
                    if(distributionDivisionNonNull.contains(bddForm.MDN_OI_Business_Line__c) && bddForm.MDN_OI_Div__c == Null)
                        errorMessage = errorMessage+' ‘Division’ ';
                    if(!distributionDivisionNonNull.contains(bddForm.MDN_OI_Business_Line__c) && bddForm.MDN_OI_Div__c != Null)
                        errorMessage = errorMessage+' ‘Division’ ';
                    if(!distributionDivisionNonNull.contains(bddForm.MDN_OI_Business_Line__c) && bddForm.MDN_OI_DistChan__c != Null)
                        errorMessage = errorMessage+' ‘Distribution Channel’ ';
                    if((bddForm.MDN_OI_Business_Line__c == trmnlAgrmntNonNull && bddForm.MDN_OI_TerAgmt__c == Null))
                        errorMessage = errorMessage+' ‘Any Terminal Agreement with this CP?’ ';
                    if((bddForm.MDN_OI_Business_Line__c != trmnlAgrmntNonNull && bddForm.MDN_OI_TerAgmt__c != Null))
                        errorMessage = errorMessage+' ‘Any Terminal Agreement with this CP?’ ';
                    if(bddForm.MDN_OI_Business_Line__c == lpsNumNonNull && bddForm.MDN_OI_LPSNum__c == Null)
                        errorMessage = errorMessage+' ‘LPS Number’ ';
                    if(bddForm.MDN_OI_Business_Line__c != lpsNumNonNull && bddForm.MDN_OI_LPSNum__c != Null)
                        errorMessage = errorMessage+' ‘LPS Number’ ';
                    if(federalWatersNonNull.contains(bddForm.MDN_OI_Business_Line__c) && (bddForm.MDN_OI_FedWat__c == Null))
                        errorMessage = errorMessage+' ‘Federal Waters’ ';
                    if(!federalWatersNonNull.contains(bddForm.MDN_OI_Business_Line__c) && (bddForm.MDN_OI_FedWat__c != Null))
                        errorMessage = errorMessage+' ‘Federal Waters’ ';
                    if(errorMessage != Null && errorMessage != '')
                        bddForm.addError('Please review the following fields according to Business Line selection'+errorMessage);
                }
                boolean isDocumentUploaded;
                
                if(bddForm.BDD_Entity_Type__c != Null){
                    if(bddForm.BDD_Line_of_Business__c == 'STUSCO' && bddForm.BDD_Entity_Type__c == 'Individual'){
                        isDocumentUploaded = True;
                    }
                    if(bddForm.BDD_Entity_Type__c == 'Counterparty' || bddForm.BDD_Entity_Type__c == 'Bank')
                        isDocumentUploaded =  isDocumentsAdded(documentsMap,'3rd Party Report',bddForm);
                    if(bddForm.BDD_Entity_Type__c == 'Vessel'){
                        boolean isDocumentUploadedVsl = isDocumentsAdded(documentsMap,'Vessel Report',bddForm);
                        boolean isDocumentUploadedOfc = isDocumentsAdded(documentsMap,'OFAC IMO Check',bddForm);
                        isDocumentUploaded = isDocumentUploadedVsl && isDocumentUploadedOfc;
                    }
                    if(bddForm.BDD_Entity_Type__c == 'Individual')
                        isDocumentUploaded = isDocumentsAdded(documentsMap,'3rd Party Report',bddForm); 
                }
                /*  if(bddForm.BDD_Line_of_Business__c == 'WONA'||bddForm.BDD_Line_of_Business__c == 'SENA'||bddForm.BDD_Line_of_Business__c == 'STUSCO')
isDocumentUploaded =  isDocumentsAdded(documentsMap,'3rd Party Report',bddForm);
if(bddForm.BDD_Line_of_Business__c == 'GLOBAL')
isDocumentUploaded =  isDocumentsAdded(documentsMap,'Vessel Report',bddForm); */
                if(bddForm.RecordTypeId != Null)
                    recTypeName = BET_BDDFormTriggerUtil.getRecordTypeNameById(bddForm.RecordTypeId);
                String fieldSetName = metadataMapping.get(recTypeName);
                String requiredAddressTypes;
                requiredAddressTypes = metadataAddressMapping.get(recTypeName).Required_Address_Type__c;
                List<String> nullValueList = new List<String>();
                booleanWrapper isAddressFilled;
                if(fieldSetName != Null)
                    nullValueList = fieldListValueCheck(fieldSetName,bddForm);
                if(requiredAddressTypes != Null)
                    isAddressFilled=  isAddressTypeFilled(requiredAddressTypes,bddForm,addressMap);
                boolean isCreditInfoFilled = BET_BDDFormTriggerUtil.isCreditInfoFilled(bddForm);
                if(isCreditInfoFilled == false){
                    bddForm.addError('Credit Information Section fields denoted by * must be completed');
                }
                if(isGsapFilled == false){
                    bddForm.addError('GSAP Section fields denoted by * must be completed');
                }
                if(isRegStateFilled == false && bddForm.BDD_Entity_Type__c != 'Vessel'){
                    bddForm.addError('Registration State is mandatory when Registration Country is ‘Canada’ or ‘United States’');
                }
                else if(nullValueList!= Null && nullValueList.size() > 0){
                    System.debug('nullValueList'+nullValueList);
                    if(!Test.isRunningTest()){
                        for(String fieldName : nullValueList){
                            bddForm.addError(fieldName,' Mandatory fields denoted by * must be completed ');
                }
                    }
                }
                
                else if( (isAddressFilled.isAddressTypeFilled == False)){
                    bddForm.addError('Please complete ‘Address Type’ as applicable to the region');
                }
                else if((isAddressFilled.isAllFieldsFilled == False)){
                    bddForm.addError('Please complete all ‘Address Types’ mandatory fields as applicable to the region');
                }
                else if(isDocumentUploaded == false){
                    bddForm.addError('Please complete ‘Document Type’ as applicable to the region');
                }
                else if(addressMap.get(bddForm.Id) != Null){
                    BET_BDDAddressTriggerHelper.businessLineOnboardValidate(addressMap.get(bddForm.Id),bddForm);}
                //add new individual record types
                else if(((bddForm.Negative_Stories_Verified__c == False)||(bddForm.BDD_Eligible_Status__c != 'Yes')||(bddForm.PEPs_and_Sacs_Verified__c == False)) &&(!rectyps.contains(recTypeName)) && recTypeName != 'GLOBAL NEW VESSEL'){
                    bddForm.addError('Please complete ‘Adverse Media Reviewed’, ‘PEPs and Sanctions Reviewed’,Set ‘BDD Eligible Status’to ‘Yes’ before setting ‘BET Status’ to “Ready to Onboard” ');
                }
                else if((rectyps.contains(recTypeName))&&(bddForm.BDD_Eligible_Status__c != 'Yes' ||bddForm.PEPs_and_Sacs_Verified__c == False)){
                    bddForm.addError('Please complete ‘PEPs and Sanctions Reviewed’,Set ‘BDD Eligible Status’to ‘Yes’ before setting ‘BET Status’ to “Ready to Onboard” ');
                }
            }}}
    public static boolean isDocumentsAdded(Map<Id,List<BET_BDD_Document__c>> docMap, String reqDoc,BET_BDD_Form__c bddFormRec ){
        List<BET_BDD_Document__c> relDoc = docMap.get(bddFormRec.Id);
        if(relDoc != Null && relDoc.size()>0){
            for(BET_BDD_Document__c docRec:relDoc){
                if(docRec.BET_Document__c == reqDoc && docRec.BET_IDD_Link__c != Null && docRec.Created_Date__c != Null)
                    return True;
                else 
                    continue;
            }}
        return false;
    }
    public static booleanWrapper isAddressTypeFilled(String addressTypes,BET_BDD_Form__c bddFormRec, Map<Id,List<BET_BDD_Address__c>> addMap){
        List<BET_BDD_Address__c> relAdd = addMap.get(bddFormRec.Id);
        boolean isAddFilled = false;boolean isTypeAvl=false;
        if(relAdd != Null && addressTypes != Null){
            List<String> addressMandate = addressTypes.split(';');
            Set<String> addRecTypes = new Set<String>();
            isAddFilled = addressFieldsFilled(relAdd,bddFormRec.BDD_Line_of_Business__c);
            isTypeAvl = false;
            for(BET_BDD_Address__c addRec : relAdd){
                addRecTypes.add(addRec.Section__c+addRec.Address_Type__c); }
            if(addRecTypes.containsAll(addressMandate))
                isTypeAvl= True;
            else
                isTypeAvl= False;
            
        }
        booleanWrapper boolWrap = new booleanWrapper();
        boolWrap.isAllFieldsFilled = isAddFilled;
        boolWrap.isAddressTypeFilled = isTypeAvl;
        return boolWrap;
    }
    public class booleanWrapper{
        boolean isAddressTypeFilled;
        boolean isAllFieldsFilled;
    }
    public static boolean gtAddress(BET_BDD_Address__c addRec){
        List<String> mandFieldsGoldtier = Address_Mandatory_Fields_Gold.split(';');
        if((addRec.Country__c =='Canada'||addRec.Country__c == 'United States')&&(addRec.State_Lkp__c == Null))
            return false;
        for(String str :mandFieldsGoldtier){
            if(addRec.get(str) != Null)
                continue;
            else 
                return false;
        }   return true; }
    public static boolean addressFieldsFilled(List<BET_BDD_Address__c> addRecs, String formRegion){
        List<String> mandFieldList = new List<String>();
        List<String> mandFieldsGoldtier = new List<String>();
        mandFieldList.addAll(Address_Mandatory_Felds.split(';'));
        
        for(BET_BDD_Address__c addRec:addRecs){
            if(formRegion == 'GLOBAL'){
                if(addRec.Section__c == 'GOLDTIER'){
                    boolean gtFilled = gtAddress(addRec);
                    if(gtFilled == false)
                        return gtFilled;
                } 
            }
            if(formRegion == 'WONA'){
                if(addRec.Section__c == 'GOLDTIER'){
                    boolean gtFilled = gtAddress(addRec);
                    if(gtFilled == false)
                        return gtFilled;
                }
                if(addRec.Section__c == 'MDN'){
                    if(addRec.BusLine__c == Null)
                        return false;
                    for(String str :mandFieldList){
                        if(addRec.get(str) != Null)
                            continue;
                        else 
                            return false;
                    }
                }
                continue; //return true;
            }
            else if(formRegion == 'STUSCO'){
                if(addRec.Section__c == 'GOLDTIER'){
                    boolean gtFilled = gtAddress(addRec);
                    if(gtFilled == false)
                        return gtFilled;
                }
                if(addRec.Section__c == 'MDN'){
                    for(String str :mandFieldList){
                        if(addRec.get(str) != Null)
                            continue;
                        else 
                            return false;
                    }
                }
                continue; //return true;
            }
            else if(formRegion == 'SENA'){
                if(addRec.Section__c == 'GOLDTIER'){
                    boolean gtFilled = gtAddress(addRec);
                    if(gtFilled == false)
                        return gtFilled;
                }
                if(addRec.Section__c == 'MDN'){
                    if(addRec.BusLine__c == Null || addRec.County__c == Null)
                        return false;
                    for(String str :mandFieldList){
                        if(addRec.get(str) != Null)
                            continue;
                        else 
                            return false;
                    }
                }
                continue; //return true;
            }
        } 
        return true;
    }
    public static List<String> fieldListValueCheck(String fieldSetName,BET_BDD_Form__c bddFormRec){
        List<String> nullValueList = new List<String>();
        List<String> bankInfoFields = new List<String>{'MDN_BA_BankName__c','MDN_BA_Acc_Num__c','MDN_BA_EPayment__c'};
            List<Schema.FieldSetMember> fieldSetMemberList = BET_BDDFormTriggerUtil.getFields(fieldSetName);
        if(bddFormRec.MDN_Setup_CP_Bank__c == 'Yes'){
            for(String str :bankInfoFields){
                if(bddFormRec.get(str) != Null && bddFormRec.get(str) != ''){
                    continue;  
                } else {
                    nullValueList.add(str);
                }
            }
            if(bddFormRec.BDD_Line_of_Business__c != 'STUSCO' && (bddFormRec.MDN_BA_BusLine__c == Null || bddFormRec.MDN_BA_BusLine__c ==''))
                nullValueList.add('* Business Line');
        }
        for(Schema.FieldSetMember field : fieldSetMemberList){
            String fieldName = field.getFieldPath();
            if(bddFormRec.get(fieldName) != Null && bddFormRec.get(fieldName) != ''){
                continue;  
            } else {
                nullValueList.add(fieldName);
            } 
        }
        if(nullValueList.size()>0)
            return nullValueList;
        else 
            return Null;
    }
    public static boolean isRegDetailsStateFilled(List<BET_Registration_Details__c> regDetList){
        for(BET_Registration_Details__c regRec : regDetList){
            if((regRec.Registration_Country__c == 'United States'|| regRec.Registration_Country__c == 'Canada') && (regRec.Registration_State__c == Null)){
                return false;
            }
        }
        return true;
    }
    public static void recordLock(Map<Id,BET_BDD_Form__c> bddFromNewList,Map<Id,BET_BDD_Form__c> bddFromOldList){
        List<String> assignedPermissionSet = BET_BDDFormTriggerUtil.getPermissionSetList(Userinfo.getUserId());
        System.debug('assigned permisions set'+assignedPermissionSet);
        List<String> bddApproverEditableFields = new List<String>{'BDD_Eligible_Status__c','BDD_AppCom__c','BET_Status__c','Assigned_COF__c','Last_Modifiedby_User__c'};
            map<String,String> metadataMapping = new map<String,String>();
        Boolean isCof = assignedPermissionSet.contains('BET_COF');
        Boolean isTrader = assignedPermissionSet.contains('BET_Trader');
        Boolean isBddApprover = assignedPermissionSet.contains('BET_Eligible_Approver');
        List<BET_RecordTypeMapping__mdt> mcs = [select id,Layout_Name__c,Record_Type_Name__c from BET_RecordTypeMapping__mdt];
        for(BET_RecordTypeMapping__mdt metaD : mcs){
            metadataMapping.put(metaD.Record_Type_Name__c, metaD.Layout_Name__c);
        }
        String profileName = BET_BDDFormTriggerUtil.getProfileName(userinfo.getProfileId());
        for(String bddRecId : bddFromNewList.keySet()){
            BET_BDD_Form__c oldRec = bddFromOldList.get(bddRecId);
            BET_BDD_Form__c newRec = bddFromNewList.get(bddRecId);
            Boolean isAssignedBdd = False;
            if((isBddApprover)&&(oldRec.BDD_Approver__c == Userinfo.getUserId()))
                isAssignedBdd = True;
            Boolean hasPermission = FeatureManagement.checkPermission('Ignore_Validation_Rules');
            System.debug('isAssignedBdd***'+isAssignedBdd);
            if((oldRec != newRec) && (profileName != 'System Administrator') && hasPermission == False){
                System.debug('rectypeId***'+newRec.RecordTypeId);
                String layoutName = metadataMapping.get(BET_BDDFormTriggerUtil.getRecordTypeNameById(newRec.RecordTypeId));
                System.debug('layoutname**'+layoutName);
                List<String> listofFields = BET_BDDFormTriggerUtil.getFieldsFromLayout(layoutName);
                List<String> changedFields = BET_BDDFormTriggerUtil.getListOfChangedFields(oldRec,newRec,listofFields);
                // System.debug('changedFields'+changedFields.size());
                System.debug('bet status'+oldRec.BET_Status__c);
                if(layoutName != 'GLOBAL NEW VESSEL'){
                    if((oldRec.BET_Status__c == 'Draft' &&(isCof||isTrader))||((oldRec.BET_Status__c == 'Review with BDD Approver') &&(isTrader || isCof))||((oldRec.BET_Status__c == 'Review with COF')&& (isCof))){
                        continue;
                    }
                    else if(((oldRec.BET_Status__c == 'Submitted')&& (isBddApprover || isTrader || isCof))||((oldRec.BET_Status__c == 'Review with COF')&& (isTrader))){
                        newRec.addError('Record is not editable at this stage');
                    }
                    else if(oldRec.BET_Status__c == 'Ready for BDD Approver' || oldRec.BET_Status__c == 'Ready for COF'||oldRec.BET_Status__c == 'Ready to Onboard'){
                        if((changedFields != Null && changedFields.size() == 2 && changedFields.contains('BET_Status__c') && changedFields.contains('Last_Modifiedby_User__c'))||(changedFields != Null && changedFields.size() == 1 && (changedFields.get(0)=='BET_Status__c' ||changedFields.get(0)=='Last_Modifiedby_User__c'))){
                            continue;}
                        else{
                            newRec.addError('Only ‘BET Status’ is editable at this stage');
                        }}
                    else if((oldRec.BET_Status__c == 'Draft' && isBddApprover)||((oldRec.BET_Status__c == 'Review with COF')&&(isBddApprover))||((oldRec.BET_Status__c == 'Review with BDD Approver')&&(isBddApprover))){
                        if((changedFields != Null && changedFields.size() == 2 && changedFields.contains('BET_Status__c') && changedFields.contains('Last_Modifiedby_User__c'))||(changedFields != Null && changedFields.size() == 1 && (changedFields.get(0)=='BET_Status__c' ||changedFields.get(0)=='Last_Modifiedby_User__c'))){
                            continue;}
                        else if(changedFields.size()<= bddApproverEditableFields.size()){
                            for(String str :changedFields){
                                if(bddApproverEditableFields.contains(str) && isAssignedBdd)
                                    continue;
                                else
                                    newRec.addError('Only the assigned approver in ‘BDD Approver Name’  is allowed to update the  ‘Eligibility Status’ and ‘Approver Comments’'); 
                            }}
                        else{ newRec.addError('Record is not editable at this stage');}}
                    else{
                        // Continue;
                        newRec.addError('Record is not editable at this stage');
                    }}
                else if(layoutName == 'GLOBAL NEW VESSEL'){
                    if((oldRec.BET_Status__c == 'Draft' &&(isBddApprover||isTrader))|| (oldRec.BET_Status__c == 'Ready to Onboard'&&((isBddApprover||isTrader))) ||(oldRec.BET_Status__c == 'Submitted'&&((isBddApprover||isTrader||isCof)))){
                        newRec.addError('Record is not editable at this stage');
                    }
                    else if(oldRec.BET_Status__c == 'Draft' &&(isCof)){
                        continue;
                    }
                    else if(oldRec.BET_Status__c == 'Ready to Onboard' &&(isCof)){
                        if((changedFields != Null && changedFields.size() == 2 && changedFields.contains('BET_Status__c') && changedFields.contains('Last_Modifiedby_User__c'))||(changedFields != Null && changedFields.size() == 1 && (changedFields.get(0)=='BET_Status__c' ||changedFields.get(0)=='Last_Modifiedby_User__c'))){
                            continue;}
                        else{
                            newRec.addError('Only ‘BET Status’ is editable at this stage');
                        }
                    }
                    else{
                        newRec.addError('Record is not editable at this stage');
                    }
                }
            }
        }
    }
    
    /**************************************************************************************
* @Description  : This method checks if "GT_Type_Of_RelationShip__c" & "GT_Relationship__c" 
both fields has value populated before saving the record.
* @Param		: trigger.new (List of new BET_BDD_Form__c object)
* @Author       : Ashish.A.Jadhav@shell.com
* @Date			: 29/09/2021
**************************************************************************************/ 
    /*public static void relationShipMandatoryValidation(List<BET_BDD_Form__c> bddFromNewList) {
        For(BET_BDD_Form__c bddForm : bddFromNewList){
            if(String.isBlank(bddForm.GT_Type_Of_RelationShip__c)){
                bddForm.addError('GT_Type_Of_RelationShip__c',Label.RelationShipMandatoryMessage);
            } else if (String.isBlank(bddForm.GT_Relationship__c)){
                bddForm.addError('GT_Relationship__c',Label.RelationShipMandatoryMessage);
            }
        }
    }*/
	
   
    /**************************************************************************************
* @Description  : This method checks if all the mandatory fields are populated before adding approver. 
* @Param		: trigger.new (List of new BET_BDD_Form__c object),trigger.oldMap (Map of old BET_BDD_Form__c object)
* @Author       : Ashish.A.Jadhav@shell.com
* @Date			: 11/06/2022
**************************************************************************************/ 
    public static void checkApproverMandatoryFields(List<BET_BDD_Form__c> bddFormList){
        Boolean hasPermission = FeatureManagement.checkPermission('Ignore_Validation_Rules');
        List<Schema.FieldSetMember> fieldSetMemberList = BET_BDDFormTriggerUtil.getFields('Approval_Mandatory_Fields');
        for(BET_BDD_Form__c bddForm : bddFormList) {
            if(bddForm.BDD_Approver__c !=null && hasPermission == false){
                List<String> nullValueList = new List<String>();
                nullValueList = approverFieldListValueCheck(fieldSetMemberList,bddForm);
                if(nullValueList!= Null && nullValueList.size() > 0){
                    System.debug('nullValueList'+nullValueList);
                    if(!Test.isRunningTest()){
                        for(String fieldName : nullValueList){
                            bddForm.addError(fieldName,'Field must be completed before selecting an approver');
                        }
                    }
                }
            }
        }
    }
    
    /**************************************************************************************
* @Description  : This method checks if all the mandatory fields are populated before adding approver. 
* @Param		: trigger.new (List of new BET_BDD_Form__c object),trigger.oldMap (Map of old BET_BDD_Form__c object)
* @Author       : Ashish.A.Jadhav@shell.com
* @Date			: 11/06/2022
**************************************************************************************/ 
    public static void restrictChangesAfterApproval(List<BET_BDD_Form__c> bddFormList,Map<Id,BET_BDD_Form__c> oldBddRecMap){
        List<Schema.FieldSetMember> fieldSetMemberList = BET_BDDFormTriggerUtil.getFields('Approval_Mandatory_Fields');
        Boolean hasPermission = FeatureManagement.checkPermission('Ignore_Validation_Rules');
        for(BET_BDD_Form__c bddForm : bddFormList) {
            BET_BDD_Form__c oldform = oldBddRecMap.get(bddForm.Id);
            if(bddForm.BDD_Eligible_Status__c=='Yes' && hasPermission == false){
                List<String> nullValueList = new List<String>();
                nullValueList = restrictFieldListValueCheck(fieldSetMemberList,bddForm,oldform);
                if(nullValueList!= Null && nullValueList.size() > 0){
                    System.debug('nullValueList'+nullValueList);
                    if(!Test.isRunningTest()){
                        for(String fieldName : nullValueList){
                            bddForm.addError(fieldName,'Field non-editable since record is approved. Use "Revoke Approval" button to edit');
                        }
                    }
                }
            }
            if(hasPermission == false && bddForm.BDD_Eligible_Status__c!='Yes' && bddForm.BET_Status__c =='Ready to Onboard' && oldform.BET_Status__c != bddForm.BET_Status__c){
                bddForm.addError('BET_Status__c',' BET Status can be changed to "Ready to Onboard" only if the BDD Eligible Status is "Yes" ');
            }
        }
    }
    
    public static List<String> approverFieldListValueCheck(List<Schema.FieldSetMember> fieldSetMemberList,BET_BDD_Form__c bddFormRec){
        List<String> nullValueList = new List<String>();
        String recTypeName;
        String vesselRecType = 'GLOBAL NEW VESSEL';
        Set<String> rectyps = new Set<String>{'STUSCO NEW INDVIDUAL FORM','STUSCO REMEDIATED INDIVIDUAL FORM','SENA NEW INDVIDUAL FORM','SENA REMEDIATED INDIVIDUAL FORM','WONA NEW INDIVIDUAL FORM','WONA REMEDIATED INDIVIDUAL FORM'};
        Set<String> individualIgnoreFields = new Set<String>{'GT_Trading_Name__c'};
        Set<String> individualFields = new Set<String>{'GT_First_Name__c','GT_Last_Name__c'};
        Set<String> vesselIgnoreFields = new Set<String>{'GT_Trading_Name__c','GT_GI__c','GT_Legal_Form__c','GT_Counterparty_Type__c','GT_Operating_Region__c','GT_Contact_With_CP__c','GT_Rationale_OB_CP__c','GT_Nature_of_Business__c','GT_Int_Business_Rel__c','GT_Core_Business_Act__c'};
        if(bddFormRec.RecordTypeId != Null)
           recTypeName = BET_BDDFormTriggerUtil.getRecordTypeNameById(bddFormRec.RecordTypeId);    
        
        for(Schema.FieldSetMember field : fieldSetMemberList){
            String fieldName = field.getFieldPath();
            if(bddFormRec.get(fieldName) != Null && bddFormRec.get(fieldName) != ''){
                continue;  
            } else if(recTypeName !=null && rectyps.contains(recTypeName) && individualIgnoreFields.contains(fieldName)) {
                continue; 
            } else if(recTypeName !=null && recTypeName == vesselRecType && vesselIgnoreFields.contains(fieldName)) {
                continue; 
            } else {
                nullValueList.add(fieldName);
            }
        }
        if(recTypeName !=null && rectyps.contains(recTypeName)){
            for(String fieldName : individualFields){
                if(bddFormRec.get(fieldName) != Null && bddFormRec.get(fieldName) != ''){
                    continue;
                } else {
                	nullValueList.add(fieldName);
            	}  
            }
        }
        if(nullValueList.size()>0)
            return nullValueList;
        else 
            return Null;
    }
    
    public static List<String> restrictFieldListValueCheck(List<Schema.FieldSetMember> fieldSetMemberList, BET_BDD_Form__c bddFormNewRec, BET_BDD_Form__c bddFormOldRec){
        List<String> nullValueList = new List<String>();
        for(Schema.FieldSetMember field : fieldSetMemberList) {
            String fieldName = field.getFieldPath();
            if(bddFormNewRec.get(fieldName) !=  bddFormOldRec.get(fieldName)){
                nullValueList.add(fieldName);
            }
        }
        if(nullValueList.size()>0)
            return nullValueList;
        else 
            return Null;
    }	
    
    //
    public static void restricMDNProposedTransactionFields(List<BET_BDD_Form__c> bddFormList,Map<Id,BET_BDD_Form__c> oldBddRecMap){
        Set<String> rectyps = new Set<String>{'STUSCO NEW INDVIDUAL FORM','STUSCO NEW CPT/BANK FORM','SENA NEW INDVIDUAL FORM','SENA NEW CPT/BANK FORM','WONA NEW INDIVIDUAL FORM','WONA NEW CPT/BANK FORM'};
            String recTypeName;
        List<Schema.FieldSetMember> fieldSetMemberList = BET_BDDFormTriggerUtil.getFields('MDN_Proposed_Transaction_Fields');
        List<String> nullValueList = new List<String>();
        for(BET_BDD_Form__c bddFormRec: bddFormList){
            if(bddFormRec.RecordTypeId != Null) {
                recTypeName = BET_BDDFormTriggerUtil.getRecordTypeNameById(bddFormRec.RecordTypeId);
            }
            if(recTypeName !=null && rectyps.contains(recTypeName) && checkProposedTranscationRestrictCondition(bddFormRec)){
                //bddFormRec.addError('','');
                nullValueList = new List<String>();
                for(Schema.FieldSetMember field : fieldSetMemberList){
                    String fieldName = field.getFieldPath();
                    if(bddFormRec.get(fieldName) != Null && bddFormRec.get(fieldName) != ''){
                        nullValueList.add(fieldName);  
                    } 
                }
                if(nullValueList !=null && !nullValueList.isEmpty() && !Test.isRunningTest()){
                    for(String fieldName : nullValueList){
                        bddFormRec.addError(fieldName,' Proposed Transaction Field must be blank based on Counterparty Relationship Description and Business Line');
                    }
                }
            }
        }
    }
    
    public static Boolean checkProposedTranscationRestrictCondition(BET_BDD_Form__c bddFormRec){
        List<String> relDescriptions = new List<String>();
        List<String> busLines = new List<String>();
        if(bddFormRec.MDN_CP_Rel_Desc__c != null){
            relDescriptions = bddFormRec.MDN_CP_Rel_Desc__c.split(';');
        }
        if(bddFormRec.MDN_OI_BusLine_multi__c != null) {
            busLines = bddFormRec.MDN_OI_BusLine_multi__c.split(';');
        } else if(bddFormRec.MDN_OI_Business_Line__c != null) {
            busLines = bddFormRec.MDN_OI_Business_Line__c.split(';');
        }
        if(relDescriptions.contains('Parent Setup Only') && (busLines.contains('CREDIT PARENT LINE') || busLines.contains('NA Credit Parent Line')) ){
            return true;
        }else {
            return false;
        }
    }
    /*
	* this method is added
	*/
    public static void updateGTMDNStatusFields(List<BET_BDD_Form__c> bddFormList,Map<Id,BET_BDD_Form__c> oldBddRecMap){
        for(BET_BDD_Form__c formRec : bddFormList){
            if(formRec.MDN_Status__c !=null && formRec.MDN_Status__c != oldBddRecMap.get(formRec.Id).MDN_Status__c){
                formRec.MDN_Status_Change_Email_Sent__c = false;
                formRec.MDN_Status_Updated_Date__c = Datetime.Now();
            }
            if(formRec.GoldTier_Status__c !=null && formRec.GoldTier_Status__c != oldBddRecMap.get(formRec.Id).GoldTier_Status__c){
                formRec.Goldtier_Status_Change_Email_Sent__c = false;
                formRec.Goldtier_Status_Updated_Date__c = Datetime.Now();
            }
        }
    }
	// method ends here
}