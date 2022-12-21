({
    validateNewFormBtnHandler: function(component, event, helper) {
        helper.validateNewBddForm(component, event); 
    },
    ResetGTMIResSelection : function(component, event, helper) {
        var GtmiData =  component.get("v.GTMIdata");
        component.set('v.GTMISelectedRow', "");
        component.set("v.GTMIdata", GtmiData);
        component.set("v.GTMIdata", GtmiData);
    },
    createNewFormBtnHandler : function(component, event, helper) {
        helper.createNewBddForm(component);
    },
    searchGTRecordsBtnHandler: function(component, event, helper) {
        component.set("v.GTMIdata", "");
        component.set('v.GTMISelectedRow', "");
        helper.getGTRecords(component, event);
    },
    searchEDPBtnHandler: function(component, event, helper) {
        var btnId = event.getSource().getLocalId();
        if(btnId == 'bet-edp-btn'){
            component.set("v.body", []);
            component.set('v.secButtonAdded', false);
            component.set('v.secDataTableAdded', false); 
        }else if(btnId == 'bet-edp-sec' && component.get('v.secDataTableAdded') == true){
            var body = component.get("v.body");
            body.splice(body.length-1, 1);
            component.set("v.body", body);
        }
        helper.getEDPRecords(component, event, btnId);
    },
    verifyBtnHandler: function(component, event, helper) {
        helper.verifyEDP(component, event);
    },
    cancelSearchResBtnHandler: function(component, event, helper) {
        var searchSection = component.find("bet-search-res");
        $A.util.addClass(searchSection, "slds-hide");
    },
    regionOnChangeHandler: function(component, event, helper) {
        helper.resetAllSections(component, event, true);
        var region  = component.get("v.objBDDForm.BDD_Line_of_Business__c");
        var betCountry = component.find("bet-country");
        var betVat = component.find("bet-vat");
        //var taxWavier = component.find("betTaxWai");
        //var manTaxVal = component.find("betTaxVal");
        //var manOfacVal = component.find("betOfacVal");
        
        if(region == 'WONA' ){
            component.set('v.showNonVesSection', true);
            component.set('v.showVesSection', false);
            component.set('v.showVatTaxId', true);
            component.set('v.showVatTaxCountry', true);
            component.set('v.showTaxWaiCb', true);
            component.set('v.showManTaxCb', true);
            component.set('v.showManOfacCb', false);
        }else if(region == 'STUSCO' || region == 'SENA'){
            component.set('v.showNonVesSection', true);
            component.set('v.showVesSection', false);
            component.set('v.showVatTaxId', true);
            component.set('v.showVatTaxCountry', false);
            component.set('v.showTaxWaiCb', true);
            component.set('v.showManTaxCb', true);;
            component.set('v.showManOfacCb', false);
        }else if(region == 'GLOBAL'){
            component.set('v.showNonVesSection', false);
            component.set('v.showVesSection', true);
            component.set('v.showVatTaxId', false);
            component.set('v.showVatTaxCountry', false);
            component.set('v.showTaxWaiCb', false);
            component.set('v.showManTaxCb', false);
            component.set('v.showManOfacCb', true);
        }
    },
    entityTypeOnChangeHandler: function(component, event, helper) {
        helper.resetAllSections(component);
        var dispEdpAndVerTabs = component.get("v.displayEdpAndVerTabs")
        if(dispEdpAndVerTabs == true){
            var region  = component.get("v.objBDDForm.BDD_Line_of_Business__c");
            var searchEdpbtn = component.find('bet-edp-btn');
            var entType = component.get("v.objBDDForm.BDD_Entity_Type__c");
            
            if(entType == 'Individual' || entType == 'Vessel'){
                searchEdpbtn.set('v.disabled', true);
            }else{
                searchEdpbtn.set('v.disabled', false);
            } 
        }
    },
    closeModal : function(component, event, helper) {
        var showModal = component.get('v.showModal');
        component.set('v.showModal', !showModal);
    },
    dataTableCompEventHandler : function(component, event, helper) {
        var sourceCompId = event.getParam("componentId");
        var selRec = event.getParam("selectedRecord");
        var region  = component.get("v.objBDDForm.BDD_Line_of_Business__c");

        if(sourceCompId == 'Orbis'){
            component.set('v.OrbisSelectedRow', '');
            if(selRec){
                component.set('v.OrbisSelectedRow', selRec);
                var vatNum = selRec.vaT_NUMBER;
                var euVatNum = selRec.europeaN_VAT_NUMBER;
                var verCountry = selRec.country;
                var orbisLegalName = selRec.name;
                var tinNum = selRec.tin;
                
                if(orbisLegalName){
                    component.set('v.irsLegalName', orbisLegalName);
                }
                
                if(verCountry){
                    component.set('v.VerCountry', verCountry); 
                }else{
                    component.set('v.VerCountry', '');  
                }
                
                if(tinNum && (region == 'SENA' || region == 'STUSCO')){
                    console.log('IRS');
                    tinNum = tinNum.toString();
                    tinNum = tinNum.replace(/-/g, '').replace(/\./g, '').replace(/\\/g, '').replace('/', '');
                    tinNum = tinNum.replace('/', '');
                    tinNum = tinNum.substring(0, 9);
                    console.log('tinNum, remove . ' + tinNum);
                    component.set('v.verVATNum', tinNum); 
                }else if((verCountry == 'United Kingdom' || verCountry == 'UK') && vatNum){
                    console.log('WONA UK');
                    vatNum = vatNum.toString();
                    vatNum = vatNum.split(',');
                    component.set('v.verVATNum', vatNum[0]); 
                }else if(verCountry != 'United Kingdom' && euVatNum) {
                    console.log('WONA EU');
                    euVatNum = euVatNum.toString();
                    euVatNum = euVatNum.split(',');
                    component.set('v.verVATNum', euVatNum[0]);
                }else if(tinNum){
                    console.log('Other');
                    tinNum = tinNum.toString();
                    component.set('v.verVATNum', tinNum);  
                }
            }
        }   
        if(sourceCompId == 'BankersAlmanac'){
            component.set('v.BankersSelectedRow', '');
            if(selRec){
                component.set('v.BankersSelectedRow', selRec);
            }
        }
    },
    GTMIRowSelectHandler: function(component, event, helper) {
		var sEntType = component.get("v.objBDDForm.BDD_Entity_Type__c");
		var region  = component.get("v.objBDDForm.BDD_Line_of_Business__c");
        let recList = [];
        //var isVeDaas = '';
        recList = component.find('GTMIRecTable').getSelectedRows();
        component.set('v.onBoardingType', 'New Onboard');
        component.set('v.GTMISelectedRow', '');
        component.set('v.showGTMIResetBtn', true);
        
        if(recList != "" && recList.length >= 1){
            var selectedRec = recList[0];
            component.set('v.GTMISelectedRow', selectedRec);
            var sLegalName = selectedRec.legaL_NAME;
            var sLegalCountry = selectedRec.legaL_CNTRY;
            var ddLevel = selectedRec.dD_LEVEL;
            var policyStatus = selectedRec.policY_STS;
            /*if(policyStatus.contains('VEDaaS')){
                isVeDaas = 'YES';
            }*/

            if(sLegalName){
                component.set('v.objBDDForm.Full_Legal_Name__c', sLegalName); 
            }
            if(sLegalCountry){
                component.set('v.objBDDForm.Inc_Country__c', sLegalCountry); 
            }

            if(region != 'GLOBAL' && ddLevel == 'Related Party'){
                component.set('v.onBoardingType', 'Related Party Update');
            }else if(region != 'GLOBAL' && policyStatus.includes('VEDaaS')){
                component.set('v.onBoardingType', 'Remediation Update');
            }
        }
    },
    checkboxMethodHandler: function(component, event, helper) {
        var checkBox = event.getSource().get('v.value');
        var checkBoxVal = event.getSource().get('v.checked');
        if(checkBox == 'taxWaiver'){
            component.set('v.taxWaiver', checkBoxVal);
        }else if(checkBox == 'manualTaxVer'){
            component.set('v.manualTaxVer', checkBoxVal);
        }else if(checkBox == 'manualOfacVal'){
            component.set('v.manualOfacVal', checkBoxVal);
        }
    },
    init: function (component, event, helper) {
        helper.getInitAttributes(component, event, helper);
        component.set('v.GTMIColumns', [
            {label: 'GoldTier ID', fieldName: 'goldtieR_ID', type: 'text'},
            {label: 'Legal Name', fieldName: 'legaL_NAME', type: 'text'},
            {label: 'Short Name', fieldName: 'shorT_NAME', type: 'text'},
            {label: 'Entity Type', fieldName: 'entitY_TYP', type: 'text'},
            {label: 'Legal Country', fieldName: 'legaL_CNTRY', type: 'text'},
            {label: 'DD Level', fieldName: 'dD_LEVEL', type: 'text'},
            {label: 'DD Level Approved', fieldName: 'dD_LEVEL_APPRD', type: 'text'},
            {label: 'Policy Status', fieldName: 'policY_STS', type: 'text'},
            {label: 'Approved with Conditions', fieldName: 'apprD_WITH_CONDITIONS_FLAG', type: 'text'},
            {label: 'Rejected with COnditions', fieldName: 'rejecteD_WITH_CONDITIONS_FLAG', type: 'text'},           
            {label: 'Reg Num', fieldName: 'REG_ID', type: 'text'},
            {label: 'DNDB List', fieldName: 'dndB_LIST', type: 'text'},
            {label: 'Policy Status Date', fieldName: 'policY_STS_DT', type: 'text'},
            {label: 'IMO#', fieldName: 'shiP_ID_NO_IMO', type: 'text'},
        ]);
            component.set('v.OrbisColumns', [
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'Address Line 1', fieldName: 'addresS_LINE1', type: 'text'},
            {label: 'Address Line 2', fieldName: 'addresS_LINE2', type: 'text'},
            {label: 'Address Line 3', fieldName: 'addresS_LINE3', type: 'text'},
            {label: 'City', fieldName: 'city', type: 'text'},
            {label: 'State', fieldName: 'uS_STATE', type: 'text'},
            {label: 'Country', fieldName: 'country', type: 'text'},
            {label: 'Post Code', fieldName: 'postcode', type: 'text'},
            {label: 'Company ID', fieldName: 'companY_ID_NUMBER_Str', type: 'text'},
            {label: 'LEI', fieldName: 'lei', type: 'text'},
            {label: 'Reg ID', fieldName: 'tradE_REGISTER_NUMBER_Str', type: 'text'},
            {label: 'VAT Num', fieldName: 'vaT_NUMBER_Str', type: 'text'},
            {label: 'EU VAT Num', fieldName: 'europeaN_VAT_NUMBER', type: 'text'},
            {label: 'TIN', fieldName: 'tin', type: 'text'},
           	{label: 'Trading Name', fieldName: 'akA_NAME_Str', type: 'text'},
           	{label: 'Previous Name', fieldName: 'previouS_NAME_Str', type: 'text'}
        ]);
        
        component.set('v.bankersColumns', [
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'Status', fieldName: 'status', type: 'text'},
            {label: 'Address Line1', fieldName: 'addressLine1', type: 'text'},
            {label: 'Address Line2', fieldName: 'addressLine2', type: 'text'},
            {label: 'Address Line3', fieldName: 'addressLine3', type: 'text'},
            {label: 'Area', fieldName: 'area', type: 'text'},
            {label: 'City', fieldName: 'city', type: 'text'},
            {label: 'Country', fieldName: 'country', type: 'text'},
            {label: 'Postal Code', fieldName: 'postalCode', type: 'text'},
            {label: 'Type', fieldName: 'type', type: 'text'},
            {label: 'LEI', fieldName: 'lei', type: 'text'},
            {label: 'Trading Name', fieldName: 'tradingName', type: 'text'},
            {label: 'Previous Name', fieldName: 'previousName', type: 'text'}
        ]);
    },
})