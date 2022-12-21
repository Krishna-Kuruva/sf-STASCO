public class BET_BDDAddressTriggerHelper {
    static final String GtLayoutFields = 'AddLine1__c;AddLine2__c;AddLine3__c;AddLine4__c;City__c;Country__c;State_Lkp__c;PostCode__c;SameAs_LegAdd__c';
    static final String MdnLayoutFields = 'AddLine1__c;AddLine2__c;AddLine3__c;AddLine4__c;City__c;Country__c;State_Lkp__c;PostCode__c;BusLine__c;County__c;Same_TR_AND_REGAdd__c';
    public static void duplicateRecordBlock(List<BET_BDD_Address__c> addressRecords,Map<Id,BET_BDD_Address__c> oldAddRec){
         set<Id> formRecId = new set<Id>();
        List<String> addTypeList = new List<String>();
        addTypeList.clear();
        for(BET_BDD_Address__c addRec :addressRecords){
            formRecId.add(addRec.BDD_Form__c);
        }
        Map<ID,List<BET_BDD_Address__c>> addMap = new Map<ID,List<BET_BDD_Address__c>>();
        addMap = BET_BDDFormTriggerUtil.getAddressMap(formRecId);
         for(BET_BDD_Address__c addRecForm :addressRecords){
             BET_BDD_Address__c oldAdd = new BET_BDD_Address__c();
             if(addRecForm.Id != Null)
                 oldAdd = oldAddRec.get(addRecForm.Id);
             System.debug('old add'+oldAdd);
             if((oldAdd == Null) || (oldAdd != Null && oldAdd.Address_Type__c != addRecForm.Address_Type__c )){
             String addRecType = addRecForm.Address_Type__c+BET_BDDFormTriggerUtil.getAddressRecTypeById(addRecForm.RecordTypeId);
            List<BET_BDD_Address__c> relAddRecs = new List<BET_BDD_Address__c>();
             if(addRecForm.BDD_Form__c != Null && addMap !=Null)
                relAddRecs = addMap.get(addRecForm.BDD_Form__c);
             if(relAddRecs != Null && relAddRecs.size()>0){
             for(BET_BDD_Address__c addRec : relAddRecs){
                 System.debug('addrec'+addRec);
            String addRecTypeExist = addRec.Address_Type__c+BET_BDDFormTriggerUtil.getAddressRecTypeById(addRec.RecordTypeId);
                addTypeList.add(addRecTypeExist);
                 System.debug('add out if'+addRecType);
                 System.debug('add2out if'+addRecTypeExist);
               
             } }if(addTypeList.contains(addRecType))
                 addRecForm.addError('Address record of this type is already added');}}
    }
    public static void mdnRecordTypeLock(List<BET_BDD_Address__c> addressRecords){
        set<Id> formRecId = new set<Id>();
        for(BET_BDD_Address__c addRec :addressRecords){
            formRecId.add(addRec.BDD_Form__c);
        }
       Map<Id,BET_BDD_Form__c> bddFormRecsMap =  getParentForm(formRecId);
        for(BET_BDD_Address__c addRec :addressRecords){
            List<String> recTypeNamesList = new List<String>{'GLOBAL NEW VESSEL','SENA REMEDIATED CPT/BANK FORM','STUSCO REMEDIATED CPT/BANK FORM','STUSCO REMEDIATED INDIVIDUAL FORM','WONA REMEDIATED CPT/BANK FORM'};
           BET_BDD_Form__c parentRec = bddFormRecsMap.get(addRec.BDD_Form__c);
            String recTypeName;
            if(parentRec !=Null && parentRec.RecordTypeId != Null)
             recTypeName = BET_BDDFormTriggerUtil.getRecordTypeNameById(parentRec.RecordTypeId);
            String addRecType = BET_BDDFormTriggerUtil.getAddressRecTypeById(addRec.RecordTypeId);
            if(recTypeNamesList.contains(recTypeName) && addRecType == 'MDN'){
                addRec.addError(' MDN Address Type is not applicable for this Region');
            }
        }}
    public static void addressRecordLocked(List<BET_BDD_Address__c> addressRecords){
        List<String> lockedStatusList = new List<String>{'Ready for BDD Approver','Ready for COF','Ready to Onboard','Submitted'};
        set<Id> formRecId = new set<Id>();
        for(BET_BDD_Address__c addRecs :addressRecords){
            formRecId.add(addRecs.BDD_Form__c);
        }
       Map<Id,BET_BDD_Form__c> bddFormRecsMap =  getParentForm(formRecId);
        for(BET_BDD_Address__c addRec :addressRecords){
             BET_BDD_Form__c parentRec = bddFormRecsMap.get(addRec.BDD_Form__c);
            System.debug('parentRec** '+parentRec);
            if(parentRec!= Null && lockedStatusList.contains(parentRec.BET_Status__c)){
                System.debug('in error method');
              addRec.addError('Only ‘BET Status’ is editable at this stage.');  
            }
        }
    }		
    public static void businessLineOnboardValidate(List<BET_BDD_Address__c> addressRecords, BET_BDD_Form__c parentRec){
        for(BET_BDD_Address__c addRec : addressRecords){
            List<String> recTypeNamesList = new List<String>{'GLOBAL NEW VESSEL','SENA REMEDIATED CPT/BANK FORM','STUSCO REMEDIATED CPT/BANK FORM','STUSCO REMEDIATED INDIVIDUAL FORM','WONA REMEDIATED CPT/BANK FORM','SENA REMEDIATED INDIVIDUAL FORM','WONA REMEDIATED INDIVIDUAL FORM'};
            if(parentRec !=Null && parentRec.RecordTypeId != Null)
            String recTypeName = BET_BDDFormTriggerUtil.getRecordTypeNameById(parentRec.RecordTypeId);
            System.debug('rectype'+parentRec.RecordType.name);
            String errorMsg;
             if(!recTypeNamesList.contains(parentRec.RecordType.name) && parentRec.BDD_Line_of_Business__c != 'STUSCO'){
                 if((parentRec != Null && parentRec.MDN_OI_BusLine_multi__c !=Null &&addRec.BusLine__c !=Null && parentRec.BDD_Line_of_Business__c != 'STUSCO') && (!parentRec.MDN_OI_BusLine_multi__c.contains(addRec.BusLine__c)||addRec.BusLine__c.contains(';'))){
                    parentRec.addError(' ‘Business Line’ mismatch in related ‘Address Type’ record ');
                }else if(parentRec.MDN_OI_BusLine_multi__c ==Null && addRec.BusLine__c !=Null && parentRec.BDD_Line_of_Business__c != 'STUSCO'){
                 parentRec.addError('Please complete Business line in MDN org information section to add Business Line in other sections');
                }}}}
    public static void updateBusinessLine(List<BET_BDD_Address__c> addressRecords){
        set<Id> formRecId = new set<Id>();
        for(BET_BDD_Address__c addRec :addressRecords){
            formRecId.add(addRec.BDD_Form__c);
        }
       Map<Id,BET_BDD_Form__c> bddFormRecsMap =  getParentForm(formRecId);
        for(BET_BDD_Address__c addRec :addressRecords){
            List<String> recTypeNamesList = new List<String>{'GLOBAL NEW VESSEL','SENA REMEDIATED CPT/BANK FORM','STUSCO REMEDIATED CPT/BANK FORM','STUSCO REMEDIATED INDIVIDUAL FORM','WONA REMEDIATED CPT/BANK FORM','SENA REMEDIATED INDIVIDUAL FORM','WONA REMEDIATED INDIVIDUAL FORM'};
           BET_BDD_Form__c parentRec = bddFormRecsMap.get(addRec.BDD_Form__c);
            if(parentRec !=Null && parentRec.RecordTypeId != Null)
            String recTypeName = BET_BDDFormTriggerUtil.getRecordTypeNameById(parentRec.RecordTypeId);
            System.debug('rectype'+parentRec.RecordType.name);
             if(!recTypeNamesList.contains(parentRec.RecordType.name) && parentRec.BDD_Line_of_Business__c != 'STUSCO'){
                 if((parentRec != Null && parentRec.MDN_OI_BusLine_multi__c !=Null &&addRec.BusLine__c !=Null && parentRec.BDD_Line_of_Business__c != 'STUSCO') && (!parentRec.MDN_OI_BusLine_multi__c.contains(addRec.BusLine__c)||addRec.BusLine__c.contains(';'))){
                   	System.debug('in the error if');
                     addRec.addError('You can only choose one ‘Business Line’ item that is selected in the ‘MDN org information’ section in the related ‘BDD Form’ ');
                }else if(parentRec.MDN_OI_BusLine_multi__c ==Null && addRec.BusLine__c !=Null && parentRec.BDD_Line_of_Business__c != 'STUSCO'){
                 addRec.addError('Please complete Business line in MDN org information section to add Business Line in other sections');
            }
           /* if(context == 'Insert'){ if((parentRec != Null)&&(parentRec.BDD_Line_of_Business__c == 'SENA' || parentRec.BDD_Line_of_Business__c == 'WONA')){
              addRec.BusLine__c = Null;
                  //parentRec.MDN_OI_BusLine_multi__c;
            }}
            if(context == 'Update'){
                if((parentRec != Null && parentRec.MDN_OI_BusLine_multi__c !=Null &&addRec.BusLine__c !=Null && parentRec.BDD_Line_of_Business__c != 'STUSCO') && (!parentRec.MDN_OI_BusLine_multi__c.contains(addRec.BusLine__c)||addRec.BusLine__c.contains(';'))){
                    addRec.addError('You can only choose one ‘Business Line’ item that is selected in the ‘MDN org information’ section in the related ‘BDD Form’ ');
                }else if(parentRec.MDN_OI_BusLine_multi__c ==Null && addRec.BusLine__c !=Null && parentRec.BDD_Line_of_Business__c != 'STUSCO'){
                 addRec.addError('Please complete Business line in MDN org information section to add Business Line in other sections');
            }
                
            } */
        }}
    }
    public static Map<Id,BET_BDD_Form__c> getParentForm(set<Id> idSet){
        Map<Id,BET_BDD_Form__c> bddParentForm = new Map<Id,BET_BDD_Form__c>();
        List<BET_BDD_Form__c> formRecs = [Select Id,RecordTypeId,BDD_Line_of_Business__c,MDN_OI_Business_Line__c,Business_Line__c,RecordType.name,MDN_OI_BusLine_multi__c,BET_Status__c from BET_BDD_Form__c where Id IN : idSet];
        for(BET_BDD_Form__c formRec : formRecs){
            bddParentForm.put(formRec.Id,formRec);
        }
        return bddParentForm;
    }
    public static void sameAsLegalAddressUpdate(List<BET_BDD_Address__c> addressRecords,Map<Id,BET_BDD_Address__c> addressRecordsOld){
        List<BET_BDD_Address__c> opAddRec = new List<BET_BDD_Address__c>();
        System.debug('meth entered');
        for(BET_BDD_Address__c addRec :addressRecords){
            Boolean oldSameasLegal = false;
            Boolean oldSameasReg = false;
            if(addressRecordsOld != Null && addRec.Id != Null){
                oldSameasLegal = addressRecordsOld.get(addRec.Id).SameAs_LegAdd__c;
                oldSameasReg = addressRecordsOld.get(addRec.Id).Same_TR_AND_REGAdd__c;
            }
            system.debug('oldSameasLegal'+oldSameasLegal);
            system.debug('SameAs_LegAdd__c'+addRec.SameAs_LegAdd__c);
            if((addRec.SameAs_LegAdd__c == True && oldSameasLegal == false) ||(addRec.Same_TR_AND_REGAdd__c == True &&  oldSameasReg == false)){
                if((addRec.Address_Type__c != Null) && (addRec.Address_Type__c == 'Legal' || addRec.Address_Type__c == 'Operating'|| addRec.Address_Type__c == 'Trading'||addRec.Address_Type__c == 'Registered')){
                    BET_BDD_Address__c addRecCreate = new BET_BDD_Address__c();
                    addRecCreate = addRec.clone(false, false, false, false);
                    if(addRec.Address_Type__c == 'Legal')
                    addRecCreate.Address_Type__c = 'Operating';
                     if(addRec.Address_Type__c == 'Operating')
                    addRecCreate.Address_Type__c = 'Legal';
                      if(addRec.Address_Type__c == 'Trading')
                    addRecCreate.Address_Type__c = 'Registered';
                      if(addRec.Address_Type__c == 'Registered')
                    addRecCreate.Address_Type__c = 'Trading';
                    addRecCreate.SameAs_LegAdd__c = True;
                     addRecCreate.Same_TR_AND_REGAdd__c = True;
                    opAddRec.add(addRecCreate);
                } 
                else if((addRec.SameAs_LegAdd__c == True) &&(addRec.Address_Type__c != 'Legal' || addRec.Address_Type__c != 'Operating')){
                     addRec.addError('Address Type must be Legal or Operational');
                }
                 else if((addRec.Same_TR_AND_REGAdd__c == True) &&(addRec.Address_Type__c != 'Trading' || addRec.Address_Type__c != 'Registered')){
                     addRec.addError('Address Type must be Trading or Registered');
                }
                else{
                    addRec.addError('Please complete Address type field');
                }
            }
        }
        try{
            insert opAddRec;}
        catch(Exception e){
            system.debug('exception'+e);
        }
            
    }
    public static void addressTypeInvalid(List<BET_BDD_Address__c> addressRecords){
        List<String> formIds = new List<String>();
        for(BET_BDD_Address__c addRec :addressRecords){
            formIds.add(addRec.BDD_Form__c);}
        Map<Id,BET_BDD_Form__c> parentBddForm =new Map<Id,BET_BDD_Form__c> ([Select Id,RecordTypeId from BET_BDD_Form__c where Id IN :formIds]);
        for(BET_BDD_Address__c addRec :addressRecords){
            map<String,BET_BDD_Required_Address_Mapping__mdt> metadataAddressMapping = BET_BDDFormTriggerUtil.getReqAddressMetadataMapping();
            String recTypeName = BET_BDDFormTriggerUtil.getRecordTypeNameById(parentBddForm.get(addRec.BDD_Form__c).RecordTypeId);
          String requiredAddressTypes;
            if(metadataAddressMapping.get(recTypeName) != Null)
             requiredAddressTypes = metadataAddressMapping.get(recTypeName).Required_Address_Types__c;
            Set<String> addTypes = new set<String>();
            addTypes.addAll(requiredAddressTypes.split(';'));
            if(addTypes.contains(addRec.Section__c+addRec.Address_Type__c) == false && addRec.Address_Type__c != Null){
                addRec.addError('Selected address type is invalid for this region');
            }}}
    public static wrapAddress addToUpdateAndInsertList(Map<Id,Map<String,BET_BDD_Address__c>> addMapofMap, String addType,BET_BDD_Address__c addRec){
      System.debug('addType***'+addType);
        Map<String,BET_BDD_Address__c> addList = addMapofMap.get(addRec.BDD_Form__c);
                    BET_BDD_Address__c addRecDest = addList.get(addType);
        			List<String> fieldsList = new List<String>();
                    if(addRecDest != Null){
                        if(addType == 'Registered' || addType == 'Trading'){
                            fieldsList = MdnLayoutFields.split(';');}
                        if(addType == 'Legal' || addType == 'Operating'){
                            fieldsList = GtLayoutFields.split(';');}
                            for(String str : fieldsList){
                                addRecDest.put(str,addRec.get(str)); 
                            }
                        wrapAddress wrpAdd = new wrapAddress();
                        wrpAdd.updateAddRec = addRecDest;
                        wrpAdd.isUpdate = True;
                        return wrpAdd;
                      //  updateAddressList.add(addRecDest);
                        }
                    else{
                      BET_BDD_Address__c addRecCreate = addRec.clone(false, false, false, false);
                    addRecCreate.Address_Type__c = addType;
                        wrapAddress wrpAdd = new wrapAddress();
                        wrpAdd.updateAddRec = addRecCreate;
                        wrpAdd.isUpdate = False;
                        return wrpAdd;
                        //insertAddressList.add(addRecCreate);
                    }
    }
     public class wrapAddress {
        public BET_BDD_Address__c updateAddRec {get; set;}
        public Boolean isUpdate {get; set;}
     }
    public static void updateLegalandRegisteredAddress(List<BET_BDD_Address__c> addressRecords, Map<Id,BET_BDD_Address__c> addressRecordsOld){
       if(checkRecursive.runOnce()){
        Set<Id> parentIds = new Set<Id>();
        List<BET_BDD_Address__c> updateAddressList = new List<BET_BDD_Address__c>();
        List<BET_BDD_Address__c> insertAddressList = new List<BET_BDD_Address__c>();
        for(BET_BDD_Address__c addRec : addressRecords){
            parentIds.add(addRec.BDD_Form__c);
        }
         Map<Id,List<BET_BDD_Address__c>> addRecMap = new Map<Id,List<BET_BDD_Address__c>>();
        Map<Id,Map<String,BET_BDD_Address__c>> addMapofMap = new Map<Id,Map<String,BET_BDD_Address__c>>();
        if(parentIds.size()>0)
        addRecMap = BET_BDDFormTriggerUtil.getAddressMap(parentIds);
        if(addRecMap != Null)
        addMapofMap = getAddressMap(addRecMap);
        for(BET_BDD_Address__c addRec : addressRecords){
            BET_BDD_Address__c addOld = addressRecordsOld.get(addRec.Id);
            if((addRec != addOld) &&(addRec.Address_Type__c == 'Legal'||addRec.Address_Type__c == 'Operating'||addRec.Address_Type__c == 'Registered'||addRec.Address_Type__c == 'Trading')){
                wrapAddress wrpAdd = new wrapAddress();
                if(addRec.Address_Type__c == 'Legal' && addRec.SameAs_LegAdd__c == true){
                     wrpAdd = addToUpdateAndInsertList(addMapofMap,'Operating',addRec);
                }
                else if(addRec.Address_Type__c == 'Operating' && addRec.SameAs_LegAdd__c == true){
                     wrpAdd = addToUpdateAndInsertList(addMapofMap,'Legal',addRec);
                }
                else if(addRec.Address_Type__c == 'Trading' && addRec.Same_TR_AND_REGAdd__c == true){
                      wrpAdd = addToUpdateAndInsertList(addMapofMap,'Registered',addRec);
                }
                else if(addRec.Address_Type__c == 'Registered' && addRec.Same_TR_AND_REGAdd__c == true){
                      wrpAdd = addToUpdateAndInsertList(addMapofMap,'Trading',addRec);
                }
                System.debug('wrpAdd**'+wrpAdd);
                if(wrpAdd.updateAddRec != Null && wrpAdd.isUpdate != Null){
                    System.debug('in wrap ins');
                    if(wrpAdd.isUpdate == True){
                        updateAddressList.add(wrpAdd.updateAddRec);}
                    else{
                        insertAddressList.add(wrpAdd.updateAddRec); }}
            } 
        }
       if(updateAddressList != Null && updateAddressList.size()>0)
        database.update(updateAddressList,false) ;
        if(insertAddressList != Null && insertAddressList.size()>0)
        database.insert(insertAddressList,false);
        
       }}
    public static Map<Id,Map<String,BET_BDD_Address__c>> getAddressMap(Map<Id,List<BET_BDD_Address__c>> addMap){
        Map<Id,Map<String,BET_BDD_Address__c>> addMapofMap = new Map<Id,Map<String,BET_BDD_Address__c>>(); 
        Set<Id> IdSet = addMap.keySet();
        for(Id idStr : IdSet){
            List<BET_BDD_Address__c> addRecList = addMap.get(idStr);
            Map<String,BET_BDD_Address__c> addTypeMap = new Map<String,BET_BDD_Address__c>();
            for(BET_BDD_Address__c addRec : addRecList){
                addTypeMap.put(addRec.Address_Type__c,addRec);
            }
            addMapofMap.put(idStr,addTypeMap);
        }
        return addMapofMap;
    }
     public static void preventSubmitDelete(List<BET_BDD_Address__c> addressRecords){
         Map<Id, BET_BDD_Form__c> bddFormMap = new Map<Id, BET_BDD_Form__c>();
         Set<Id> formIds = new Set<Id>();
         for(BET_BDD_Address__c addressRec : addressRecords){
             formIds.add(addressRec.BDD_Form__c);
         }
        bddFormMap = new Map<Id, BET_BDD_Form__c>([SELECT Id,
                                                          BDD_Entity_Type__c,BET_Status__c,BDD_Onboard_Type__c,
                                                          GT_Legal_Name__c FROM BET_BDD_Form__c WHERE Id IN : formIds]);
        for(BET_BDD_Address__c addRec : addressRecords){
            BET_BDD_Form__c parentForm = bddFormMap.get(addRec.BDD_Form__c);
            System.debug('parentForm***'+parentForm);
            if((parentForm != Null)&&(parentForm.BET_Status__c == 'Submitted' || parentForm.BET_Status__c == 'Ready to Onboard')){
                addRec.addError('Only ‘BET Status’ is editable at this stage.');
            } } }
}