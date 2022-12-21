public class BET_BDD_UpdateEntityLegalForm{
    public static void updateRationale(BET_BDD_Form__c form){
        if(form.MDN_CD_Rationale__c.length() > 256)
            form.MDN_CR_IntRelations__c = form.MDN_CD_Rationale__c.substring(0, 256); 
        else
            form.MDN_CR_IntRelations__c = form.MDN_CD_Rationale__c;
    }
    public static void updateContact(BET_BDD_Form__c form){
        form.MDN_CD_Contact_With_CP__c = form.GT_Contact_With_CP__c;
    }
    public static void updateGTRationale(BET_BDD_Form__c form){
        if(form.GT_Rationale_OB_CP__c.length() > 256)
            form.MDN_CD_Rationale__c = form.GT_Rationale_OB_CP__c.substring(0, 256); 
        else
            form.MDN_CD_Rationale__c = form.GT_Rationale_OB_CP__c;   
    }
    public static void updateGTEntity(BET_BDD_Form__c form){
        if(!form.GT_Cust_Entity_Type_Class__c.contains('|')){
            form.GT_Entity_Type__c=form.GT_Cust_Entity_Type_Class__c;
            form.GT_Legal_Form__c='';
        }
        else if(form.GT_Cust_Entity_Type_Class__c.indexOf('|')==form.GT_Cust_Entity_Type_Class__c.length()-1){
            form.GT_Entity_Type__c=form.GT_Cust_Entity_Type_Class__c.left(form.GT_Cust_Entity_Type_Class__c.indexOf('|')-1);
            form.GT_Legal_Form__c='';
        }
        else{
            form.GT_Entity_Type__c=form.GT_Cust_Entity_Type_Class__c.left(form.GT_Cust_Entity_Type_Class__c.indexOf('|')-1);
            form.GT_Legal_Form__c=form.GT_Cust_Entity_Type_Class__c.right(form.GT_Cust_Entity_Type_Class__c.length()-(form.GT_Cust_Entity_Type_Class__c.indexOf('|')+1));
        } 
        
    }
    public static void updateRecordFromTrigger(List<BET_BDD_Form__c> lstBDDForms,Map<Id,BET_BDD_Form__c> oldFormList){
        //system.debug('lstBDDIDs' + lstBDDIDs);
        //  List<BET_BDD_Form__c> lstBDDForms=[SELECT Id,GT_Cust_Entity_Type_Class__c,BET_Status__c,GT_Entity_Type__c,GT_Legal_Form__c FROM BET_BDD_Form__c WHERE Id IN:lstBDDIDs];
        for(BET_BDD_Form__c form:lstBDDForms){
            BET_BDD_Form__c oldFormRec;
            //= new BET_BDD_Form__c();
            if(form.Id != Null)
                oldFormRec = oldFormList.get(form.Id);
            if(oldFormRec != Null){
                if(oldFormRec.BET_Status__c != 'Ready for BDD Approver' && oldFormRec.BET_Status__c != 'Ready for COF' && oldFormRec.BET_Status__c != 'Ready to Onboard' && oldFormRec.BET_Status__c != 'Submitted'){
                    if((oldFormRec.GT_Cust_Entity_Type_Class__c != Null && form.GT_Cust_Entity_Type_Class__c != Null && oldFormRec.GT_Cust_Entity_Type_Class__c != form.GT_Cust_Entity_Type_Class__c) ||(oldFormRec.GT_Cust_Entity_Type_Class__c == Null && form.GT_Cust_Entity_Type_Class__c != Null)){
                        updateGTEntity(form);
                    }

                    if((oldFormRec.GT_Contact_With_CP__c != Null && form.GT_Contact_With_CP__c != Null && oldFormRec.GT_Contact_With_CP__c != form.GT_Contact_With_CP__c) ||(oldFormRec.GT_Contact_With_CP__c == Null && form.GT_Contact_With_CP__c != Null)){
                        updateContact(form);
                    }
                    if((oldFormRec.GT_Rationale_OB_CP__c != Null && form.GT_Rationale_OB_CP__c != Null && oldFormRec.GT_Rationale_OB_CP__c != form.GT_Rationale_OB_CP__c) ||(oldFormRec.GT_Rationale_OB_CP__c == Null && form.GT_Rationale_OB_CP__c != Null)){
                        updateGTRationale(form);
                    }
                     if((oldFormRec.MDN_CD_Rationale__c != Null && form.MDN_CD_Rationale__c != Null && oldFormRec.MDN_CD_Rationale__c != form.MDN_CD_Rationale__c) ||(oldFormRec.MDN_CD_Rationale__c == Null && form.MDN_CD_Rationale__c != Null)){
                        updateRationale(form);
                    }
                } }if(oldFormRec == Null ){
                    if(form.GT_Cust_Entity_Type_Class__c != Null){
                        updateGTEntity(form);
                    }
                    if(form.GT_Contact_With_CP__c != Null){
                        updateContact(form);
                    }if(form.GT_Rationale_OB_CP__c != Null){
                        updateGTRationale(form);
                    }if(form.MDN_CD_Rationale__c != Null){
                        updateRationale(form);
                    }}
        }
        //  if(lstBDDForms.size()>0 && lstBDDForms != Null)
        // update lstBDDForms;
    }
}