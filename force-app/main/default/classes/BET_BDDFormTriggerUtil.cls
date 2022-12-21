public class BET_BDDFormTriggerUtil {
    static final String WonaCreditInfo = 'MDN_CR_CredType__c;MDN_CR_Lim_req__c;MDN_CR_Credit_Limit__c;MDN_CR_Ant_FirstTrade_Date__c;MDN_CR_Price__c;MDN_CR_PhyFin__c;MDN_CR_PurchSale__c;MDN_CR_PriceType__c;MDN_CR_BusLine__c;MDN_CR_IntRelations__c';
    static final String SenaCreditInfo = 'MDN_CR_CredType__c;MDN_CR_Lim_req__c;MDN_CR_Credit_Limit__c;MDN_CR_Credit_Limit__c;MDN_CR_StartDate__c;MDN_CR_LocationPP__c;MDN_CR_VolFreq__c;MDN_CR_Commodity__c;MDN_CR_EndDate__c;MDN_CR_Price__c;MDN_CR_PhyFin__c;MDN_CR_Cur__c;MDN_CR_Vol__c;MDN_CR_PurchSale__c;MDN_CR_Units__c;MDN_CR_BusLine__c;MDN_CR_IntRelations__c';
    static final String StuscoCreditInfo = 'MDN_CR_CredType__c;MDN_CR_Lim_req__c;MDN_CR_StartDate__c;MDN_CR_LocationPP__c;MDN_CR_VolFreq__c;MDN_CR_Commodity__c;MDN_CR_EndDate__c;MDN_CR_Price__c;MDN_CR_PhyFin__c;MDN_CR_Cur__c;MDN_CR_Vol__c;MDN_CR_PurchSale__c;MDN_CR_Units__c;MDN_CR_IntRelations__c';
    static final String gsapMandatoryFields = 'GSAP_Classof_Prod__c;GSAP_Banding__c;GSAP_Legal_Status__c;GSAP_Customer_Sector__c;GSAP_Export_Allowed__c;GSAP_Ship_Cond__c;GSAP_Delivery_Pri__c;GSAP_SalesPayment_Term__c;GSAP_Sales_Group__c;GSAP_Desired_CredLimit__c;GSAP_NACE_Code__c;GSAP_NAICS_Code__c';
    public static string recTypeIDWonaCpt = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW CPT/BANK FORM').getRecordTypeId(); 
    public static string recTypeIDWonaIndv = Schema.SobjectType.BET_BDD_Form__c.getRecordTypeInfosByName().get('MASS UPLOAD WONA NEW INDIVIDUAL FORM').getRecordTypeId(); 
        
    public static List<Schema.FieldSetMember> getFields(String fieldSetName) {
        System.debug('field set name' +fieldSetName);
        return SObjectType.BET_BDD_Form__c.FieldSets.getMap().get(fieldSetName).getFields();
    }
    public static boolean isGsapSectionFilled(BET_BDD_Form__c formRec){
        List<String> companyList = new List<String> {'US16 (0201) - SOPUS','USN6 (0301) - STUSCO (Domestic)','0308 - STUSCO (Puerto Rico)','MX01 - Shell Mexico','XXXX - SCAPSA (Argentina)'};
            List<String> busLineList = new List<String> {'Products','Broker - Products','Terminalling','Marine - Products','SOPUS NOC'};
                if((formRec.MDN_OI_Company__c != Null && companyList.contains(formRec.MDN_OI_Company__c)) && (formRec.MDN_CP_Rel_Desc__c != Null && formRec.MDN_CP_Rel_Desc__c != 'Vendor Only')&& (formRec.MDN_OI_Business_Line__c != Null && busLineList.contains(formRec.MDN_OI_Business_Line__c))){
                    List<String> gsapFields = gsapMandatoryFields.split(';');
                    if(formRec.MDN_OI_Business_Line__c != 'Terminalling'){
                        gsapFields.add('GSAP_Purchase_PaymentTerm__c');}
                    System.debug('list vals'+gsapFields);
                    for(String crFls : gsapFields){
                        if(formRec.get(crFls)!= Null && formRec.get(crFls)!= '')
                            continue;
                        else 
                            return false;
                    }}
        
        return true;}
    public static void gsapSectionDefault(BET_BDD_Form__c formRec,Map<String,BET_Custom_Picklist__c> defaultCodeMap){
        System.debug('defaultCodeMap***'+defaultCodeMap.keySet());
        List<String> companyList = new List<String> {'US16 (0201) - SOPUS','USN6 (0301) - STUSCO (Domestic)','0308 - STUSCO (Puerto Rico)','MX01 - Shell Mexico','XXXX - SCAPSA (Argentina)'};
            List<String> busLineList = new List<String> {'Products','Broker - Products','Terminalling','Marine - Products','SOPUS NOC'};
                if((formRec.MDN_OI_Company__c != Null && companyList.contains(formRec.MDN_OI_Company__c)) && (formRec.MDN_CP_Rel_Desc__c != Null && formRec.MDN_CP_Rel_Desc__c != 'Vendor Only')&& (formRec.MDN_OI_Business_Line__c != Null && busLineList.contains(formRec.MDN_OI_Business_Line__c))){
                    formRec.GSAP_Customer_Sector__c = 'WHOLESALE FUEL - 10070 - Wholesale Fuel';
                    formRec.GSAP_Ship_Cond__c = '10 Road Pickup';
                    formRec.GSAP_Delivery_Pri__c = '09 - Deliver by Day';
                    formRec.GSAP_Sales_Group__c = 'A28 - ZZ Supply';
                    if(formRec.MDN_OI_Company__c == 'US16 (0201) - SOPUS'){
                        if(defaultCodeMap.get('46.71') != Null)
                            formRec.GSAP_NACE_Code__c = defaultCodeMap.get('46.71').Id;
                        if(defaultCodeMap.get('424720') != Null)
                            formRec.GSAP_NAICS_Code__c = defaultCodeMap.get('424720').Id;
                        formRec.GSAP_Export_Allowed__c = 'No';
                        formRec.GSAP_SalesPayment_Term__c = 'HC03 - 3 Working days from Invoice Date Receipt';
                        if(formRec.MDN_OI_Business_Line__c != 'Terminalling'){
                            formRec.GSAP_Purchase_PaymentTerm__c = 'HH15 - Net 15 days from end of month';}
                        else{
                            formRec.GSAP_Purchase_PaymentTerm__c = Null;}
                    }else{
                        if(defaultCodeMap.get('46.12') != Null)
                            formRec.GSAP_NACE_Code__c = defaultCodeMap.get('46.12').Id;
                        if(defaultCodeMap.get('425110') != Null)
                            formRec.GSAP_NAICS_Code__c = defaultCodeMap.get('425110').Id;
                        formRec.GSAP_Export_Allowed__c = 'Yes';
                        formRec.GSAP_SalesPayment_Term__c = 'Z000 - Net 0 Days';
                        if(formRec.MDN_OI_Business_Line__c != 'Terminalling'){
                            formRec.GSAP_Purchase_PaymentTerm__c = 'HB30 - Due 30 days from Invoice Date';}
                        else{
                            formRec.GSAP_Purchase_PaymentTerm__c = Null;}}}}
    public static boolean isCreditInfoFilled(BET_BDD_Form__c formRec){
        if(formRec.BDD_Line_of_Business__c == 'WONA' && formRec.recordtypeId != recTypeIDWonaCpt && formRec.recordtypeId != recTypeIDWonaIndv){
            //if(formRec.MDN_OI_BusLine_multi__c != 'OIL SHIPPING' && formRec.MDN_CP_Rel_Desc__c == 'Counterparty'){ //Commented through INC0936412/CHG0085082
            if(formRec.MDN_CP_Rel_Desc__c == 'Counterparty'){
                List<String> creditInfoFields = WonaCreditInfo.split(';');
                System.debug('list vals'+creditInfoFields);
                for(String crFls : creditInfoFields){
                    if(formRec.get(crFls)!= Null && formRec.get(crFls)!= '')
                        continue;
                    else 
                        return false;
                }}}
        if(formRec.BDD_Line_of_Business__c == 'SENA'){
            if(formRec.MDN_CP_Rel_Desc__c == 'Counterparty (Customer & Vendor)' ||formRec.MDN_CP_Rel_Desc__c == 'Customer Only'){
                List<String> creditInfoFields = SenaCreditInfo.split(';');
                System.debug('list vals'+creditInfoFields);
                for(String crFls : creditInfoFields){
                    if(formRec.get(crFls)!= Null && formRec.get(crFls)!= '')
                        continue;
                    else 
                        return false;
                }}}
        if(formRec.BDD_Line_of_Business__c == 'STUSCO'){
            if(formRec.MDN_CP_Rel_Desc__c == 'Counterparty (Customer & Vendor)' || formRec.MDN_CP_Rel_Desc__c == 'Customer Only'){
                List<String> creditInfoFields = StuscoCreditInfo.split(';');
                for(String crFls : creditInfoFields){
                    if(formRec.get(crFls)!= Null && formRec.get(crFls)!= '')
                        continue;
                    else 
                        return false;
                }}}
        return true;
    }
    public static Map<String,String> getFieldSetMetadataMapping(){
        map<String,String> metadataMapping = new map<String,String>();
        List<BET_Field_Set_Mapping__mdt> mcs = [select id,Field_Set_Name__c,Record_Type_Name__c from BET_Field_Set_Mapping__mdt];
        for(BET_Field_Set_Mapping__mdt metaD : mcs){
            metadataMapping.put(metaD.Record_Type_Name__c, metaD.Field_Set_Name__c);
        }
        return metadataMapping;
    }
    public static Map<String,BET_BDD_Required_Address_Mapping__mdt> getReqAddressMetadataMapping(){
        map<String,BET_BDD_Required_Address_Mapping__mdt> metadataAddressMapping = new map<String,BET_BDD_Required_Address_Mapping__mdt>();
        List<BET_BDD_Required_Address_Mapping__mdt> mcsAdd = [select id,Record_Type_Name__c,Required_Address_Types__c,Required_Address_Type__c from BET_BDD_Required_Address_Mapping__mdt];
        for(BET_BDD_Required_Address_Mapping__mdt metaD : mcsAdd){
            metadataAddressMapping.put(metaD.Record_Type_Name__c, metaD);
        }
        return metadataAddressMapping;
    }
    public static Map<ID,List<BET_BDD_Document__c>> getDocumentsMap(Set<Id> bddIds){
        List<BET_BDD_Document__c> documentList = [Select ID,BET_BDD_Form__c,BET_Document__c,BET_Document_Type__c,BET_IDD_Link__c,Created_Date__c From BET_BDD_Document__c Where BET_BDD_Form__c IN:bddIds];
        Map<Id,List<BET_BDD_Document__c>> documentMap = new Map<Id,List<BET_BDD_Document__c>>();
        for(BET_BDD_Document__c addRec : documentList){
            if(documentMap.containsKey(addRec.BET_BDD_Form__c)){
                List<BET_BDD_Document__c> addList = documentMap.get(addRec.BET_BDD_Form__c);
                addList.add(addRec);
                documentMap.put(addRec.BET_BDD_Form__c,addList);
            }else{
                documentMap.put(addRec.BET_BDD_Form__c,new List<BET_BDD_Document__c> {addRec} );}}
        return documentMap;
    }
    public static Map<ID,List<BET_Registration_Details__c>> getRegDetailsMap(Set<Id> bddIds){
        List<BET_Registration_Details__c> regDetailsList = [Select Id,Name,Registration_Country__c,Registration_ID__c,Registration_State__c,BDD_Form__c from BET_Registration_Details__c where BDD_Form__c IN:bddIds];
        Map<Id,List<BET_Registration_Details__c>> regDetailsMap = new Map<Id,List<BET_Registration_Details__c>>();
    	for(BET_Registration_Details__c regRec : regDetailsList){
            if(regDetailsMap.containsKey(regRec.BDD_Form__c)){
                List<BET_Registration_Details__c> regList = regDetailsMap.get(regRec.BDD_Form__c);
                regList.add(regRec);
                regDetailsMap.put(regRec.BDD_Form__c,regList);
            }else{
                regDetailsMap.put(regRec.BDD_Form__c,new List<BET_Registration_Details__c> {regRec} );}}
        return regDetailsMap;
    }
    public static Map<ID,List<BET_BDD_Address__c>> getAddressMap(Set<Id> bddIds){
        List<BET_BDD_Address__c> addressList = [Select ID,Address_Type__c,BDD_Form__c,Section__c,RecordTypeId,AddLine1__c,City__c,Country__c,PostCode__c,State_Lkp__c,County__c,BusLine__c From BET_BDD_Address__c Where BDD_Form__c IN:bddIds];
        Map<Id,List<BET_BDD_Address__c>> addressMap = new Map<Id,List<BET_BDD_Address__c>>();
        for(BET_BDD_Address__c addRec : addressList){
            if(addressMap.containsKey(addRec.BDD_Form__c)){
                List<BET_BDD_Address__c> addList = addressMap.get(addRec.BDD_Form__c);
                addList.add(addRec);
                addressMap.put(addRec.BDD_Form__c,addList);
            }else{
                addressMap.put(addRec.BDD_Form__c,new List<BET_BDD_Address__c> {addRec} );}}
        return addressMap;}
    public static String getRecordTypeNameById(Id strRecordTypeId){
        System.debug('rctype'+Schema.SObjectType.BET_BDD_Form__c.getRecordTypeInfosById().get(strRecordTypeId).getname());
        return Schema.SObjectType.BET_BDD_Form__c.getRecordTypeInfosById().get(strRecordTypeId).getname();
    } 
    public static String getAddressRecTypeById(Id strRecordTypeId){
        return Schema.SObjectType.BET_BDD_Address__c.getRecordTypeInfosById().get(strRecordTypeId).getname();
    }
    public static String getProfileName(Id loggedInUserId){
        Profile profileName = [Select Name from Profile where Id =: loggedInUserId];
        return profileName.Name;
    }
    public static Map<Id,List<String>> getPermissionListBulk(Set<Id> userIds){
        Map<Id,List<String>> permissionsMap = new Map<Id,List<String>>();
        List<PermissionSetAssignment> lstcurrentUserPerSet = new List<PermissionSetAssignment>();
        lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN: userIds];
        for (PermissionSetAssignment psa: lstcurrentUserPerSet)
        {
            if(!permissionsMap.isEmpty() && permissionsMap.containsKey(psa.AssigneeId)){
                List<String> permissionsList = permissionsMap.get(psa.AssigneeId);
                permissionsList.add(psa.PermissionSet.Name);
                permissionsMap.put(psa.AssigneeId,permissionsList);
            }else{
                permissionsMap.put(psa.AssigneeId,new List<String> {psa.PermissionSet.Name} );
            }}
        return permissionsMap;
    }
    
    public static List<String> getPermissionSetList(Id loggedInUserId){
        List<String> permissionsList = new List<String>();
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :loggedInUserId];
        for (PermissionSetAssignment psa: lstcurrentUserPerSet)
        {
            permissionsList.add(psa.PermissionSet.Name);
        }
        return permissionsList;
    }
    public static List<String> getListOfChangedFields(BET_BDD_Form__c oldRec,BET_BDD_Form__c newRec,List<String> listofFields){
        List<String> changedFields = new List<String>();
        System.debug('listofFields in meth'+listofFields);
        BET_BDD_Form__c oldRecMeth = new BET_BDD_Form__c();
        oldRecMeth = oldRec;
        
        for(String str : listofFields){
            try{
                if(oldRec.get(str) != newRec.get(str)){
                    changedFields.add(str);
                }}catch(Exception e){
                    System.debug(e);
                }
        }
        
        System.debug('changed fields in meth'+changedFields);
        if(changedFields.size()>0)
            return changedFields;
        else 
            return Null;
    }
    public static List<String> getFieldsFromLayout(String recordType){
        List<String> fieldNames = new List<String>();
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                                                                       new List<String> {'BET_BDD_Form__c-'+recordType});
        
        System.debug('rectype'+recordType);
        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        for (Metadata.LayoutSection section : layoutMd.layoutSections) {
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                if (column.layoutItems != null) {
                    for (Metadata.LayoutItem item : column.layoutItems) {
                        // System.debug(item.field);
                        fieldNames.add(item.field);
                    }}}}
        return fieldNames;
    }}