({
    getInitAttributes:function(component, event){
        var action = component.get("c.getCompInitData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != ""){
                    if(result.disableEdpSearchAndVer == true){
                        component.set('v.displayEdpAndVerTabs', false)
                    }
                }else{
                    this.displayMessage('informational', '', 'No Response from server.');
                }
            }else if (state === "ERROR") {
                this.displayMessage('error', 'Error', 'Error in executing this operation.');
            }
        });
        $A.enqueueAction(action); 
    },
    validateNewBddForm: function(component, event) {        
        var sLOB		  = component.get("v.objBDDForm.BDD_Line_of_Business__c");
        var sEntType 	  = component.get("v.objBDDForm.BDD_Entity_Type__c");
        var sShortName 	  = component.get("v.objBDDForm.Full_Legal_Name__c");
        var sIncCountry   = component.get("v.objBDDForm.Inc_Country__c");
        var sIMONum	      = component.get("v.objBDDForm.Srch_Vsl_Name_or_IMO__c");
        var taxViewer	  = component.get("v.taxWaiver");
        var manualVer     = component.get("v.manualTaxVer");
        var manOfacVal    = component.get("v.manualOfacVal");
        var verDone       = component.get("v.verificationDone");
        var gtmiSelRow    = component.get('v.GTMISelectedRow');
        var vesName   	  = component.get('v.vesselName');
        var onBoardingType = component.get('v.onBoardingType');
        var sTriggerNewBddRec = false;
        
        if(onBoardingType == 'New Onboard'){
            component.set('v.showEdpEntityMsg', false);
        }else if(onBoardingType == 'Related Party Update' || onBoardingType == 'Remediation Update'){
            component.set('v.showEdpEntityMsg', true);
        }
        
        if(sLOB && sEntType){
            if(sLOB == 'WONA' || sLOB == 'SENA' || sLOB == 'STUSCO'){
                if(gtmiSelRow){
                    var ddLevel = gtmiSelRow.dD_LEVEL;
                    var policyStatus = gtmiSelRow.policY_STS;
                    /*if(onBoardingType == 'Related Party Update'){
                        this.displayMessage('error', '', 'Related party onboarding is temporarily disabled in the BET.'); 
                    }else */
                    if(sEntType == 'Individual' && policyStatus.includes('VEDaaS')){
                        this.displayMessage('error', '', 'BET does not support remediation of an Individual.'); 
                    }else if(ddLevel != 'Related Party' && !policyStatus.includes('VEDaaS')){
                        this.displayMessage('error', '', 'You cannot onboard the selected GTMI entity.'); 
                    }else if(sShortName){
                        sTriggerNewBddRec = true;
                    }
                }else{
                    if(sShortName){
                        sTriggerNewBddRec = true;
                    }else{
                        this.displayMessage('error', 'Error', 'Short Name is required.'); 
                    }
                }
            }else{
                if(gtmiSelRow){
                    this.displayMessage('error', 'Error', 'You cannot onboard the selected GTMI entity.'); 
                }else if(sIMONum && sIMONum.length >= 2){
                    sTriggerNewBddRec = true;
                }else{
                    this.displayMessage('error', 'Error', 'IMO Number is required for New BDD Form and must be more than 2 characters.'); 
                }
            }
        }else{
            this.displayMessage('error', 'Error', 'Please fill Line of Business and Entity Type.');
        }
        
        console.log('taxViewer: ' + taxViewer + '; manualVer: ' + manualVer + '; verDone: ' + verDone);
        if(sLOB == 'GLOBAL' && sTriggerNewBddRec == true){
            if(!vesName){
                sTriggerNewBddRec == false;
                this.displayMessage('error', 'Error', 'Please fill vessel name.'); 
            }else if(!manOfacVal && !verDone){
                sTriggerNewBddRec == false;
                this.displayMessage('error', 'Error', 'Please select or perform any verification.');    
            }else{
                var showModal = component.get('v.showModal');
                component.set('v.showModal', !showModal);
            } 
        }else if(sTriggerNewBddRec == true){           
            if(!taxViewer && !manualVer && !verDone){
                sTriggerNewBddRec == false;
                this.displayMessage('error', 'Error', 'Please select or perform any verification.');    
            }else{
                var showModal = component.get('v.showModal');
                component.set('v.showModal', !showModal);
            }    
        }
    }, 
    createNewBddForm: function(component){        
        var actNewBddRec 	= component.get("c.getNewBddFormId");
        var sNewBddRec 		= component.get("v.objBDDForm");
        var GTMISelectedRec = component.get('v.GTMISelectedRow');
        var mapRegDetail 	= '';
        var OrbisRec 	 	= JSON.stringify(component.get('v.OrbisSelectedRow'));
        var BankersRec 	 	= JSON.stringify(component.get('v.BankersSelectedRow'));
        var gtmiRec 	 	= JSON.stringify(component.get('v.GTMISelectedRow'));
      	var verDone       	= component.get("v.verificationDone");
        var manTaxVal      	= component.get("v.manualTaxVer");
        var manOfacVal     	= component.get("v.manualOfacVal");
        var taxWavier      	= component.get("v.taxWaiver");
        var verfTaxVATNum  	= component.get("v.verVATNum");
        var verfCountry     = component.get("v.VerCountry");
        var accessToken     = component.get("v.accessToken");
        var vesselName     = component.get("v.vesselName");
        
        component.set("v.objBDDForm.BDD_Onboard_Type__c", component.get("v.onBoardingType"));
        if(taxWavier || manTaxVal || manOfacVal){
            verDone = false;
        }
        
        actNewBddRec.setParams({
            newBddForm: sNewBddRec,
            orbisRecord: OrbisRec,
            bankersRecord: BankersRec,
            UIVerfDone: verDone,
            verfTaxVATNum: verfTaxVATNum,
            verfCountry: verfCountry,
            gtmiRec: gtmiRec,
            accessToken: accessToken,
            vesselName: vesselName
        });
        
        var showModal = component.get('v.showModal');
        component.set('v.showModal', !showModal);
         this.toggleSpinner(component);
        
        actNewBddRec.setCallback(this, function(response) {
            var state = response.getState();
            var msgBankersResp = '';
            this.toggleSpinner(component);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    var baidResStatus = result.baidApiStatus;
                    var recId = result.recId;
                    if(baidResStatus == 'Failed'){
                        msgBankersResp = 'Unable to connect to Bankers details API. ';
                    }
                    console.log('new bdd form created >> baidResStatus >> ' + baidResStatus);
                    if(recId != undefined){
                        navEvt.setParams({
                            "recordId": recId
                        });
                        navEvt.fire();
                        this.displayMessage('success', '', msgBankersResp + 'New BDD Form is created!');
                    }else{
                        this.displayMessage('error', 'Error', 'Issue in creating new BDD Form.');
                    }
                }
            }else if (state === "ERROR") {
                this.displayMessage('error', 'Error', 'Error in executing this operation.');
            }
        });
        $A.enqueueAction(actNewBddRec);
    },
    getGTRecords: function(component, event) {
        /*var betGtDiv 		= component.find("betGtDiv");
        var betGtRecordsdiv		= component.find("betGtRecordsdiv");
        
        $A.util.removeClass(betGtDiv, "slds-hide");        
        $A.util.addClass(betGtRecordsdiv, "slds-hide");*/
        
        this.resetAllSections(component, event, false);
        //Focus GTMI search tab
        component.find('bet-tabset').set('v.selectedTabId', 'gtmi');
        
        var sLOB		  = component.get("v.objBDDForm.BDD_Line_of_Business__c");
        var sEntType 	  = component.get("v.objBDDForm.BDD_Entity_Type__c");
        var sShortName 	  = component.get("v.objBDDForm.Full_Legal_Name__c");
        var sIncCountry   = component.get("v.objBDDForm.Inc_Country__c");
        var sIMONum	      = component.get("v.objBDDForm.Srch_Vsl_Name_or_IMO__c");
        var accessToken   = component.get("v.accessToken");
        var sEDPBtn 	  = component.find("bet-edp-btn");
        var sTriggerGTAPI = false;
        
        if(sShortName){
            sShortName = sShortName.trim(); 
        }
        if(sIMONum){
            sIMONum = sIMONum.trim(); 
        }
        if(sLOB && sEntType){
            if(sLOB == 'WONA' || sLOB == 'SENA' || sLOB == 'STUSCO'){
                if(sShortName && sShortName.length >= 2){
                    sTriggerGTAPI = true;
                }else{
                    this.displayMessage('error', 'Error', 'Short Name is required for GT Search and must be more than 2 characters'); 
                }
            }else{
                if(!sIMONum){
                    this.displayMessage('error', 'Error', 'IMO Number is required for GT search.');  
                }else if(sIMONum.length <= 2){
                    this.displayMessage('error', 'Error', 'IMO Number must be more than 2 digits.'); 
                }else if(sIMONum.length > 7){
                    this.displayMessage('error', 'Error', 'IMO Number must be upto 7 digits.'); 
                }else if(isNaN(sIMONum)){
                    this.displayMessage('error', 'Error', 'Please enter valid IMO Number.'); 
                }else{
                    sTriggerGTAPI = true;
                }
            }
        }else{
            this.displayMessage('error', 'Error', 'Please fill Line of Business and Entity Type.');
        }
        
        if(sTriggerGTAPI == true){
            this.toggleSpinner(component);
            var searchSection = component.find("bet-search-res");
            $A.util.removeClass(searchSection, "slds-hide");
            
            var action = component.get("c.getGTRecordSet");
            action.setParams({
                searchShortName : sShortName,
                IMONum : sIMONum,
                accessToken : accessToken
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result != ""){
                        this.gTMIRespHandler(component, result);
                    }else{
                        this.toggleSpinner(component);
                        //$A.util.removeClass(sGTCon, "slds-hide");        
                        //$A.util.addClass(sGTDiv, "slds-hide");
                        this.displayMessage('informational', '', 'No Response from server.');
                    }
                    $A.util.removeClass(sEDPBtn, "slds-hide");
                }else if (state === "ERROR") {
                    this.toggleSpinner(component);
                    this.displayMessage('error', 'Error', 'Error in executing this operation.');
                }
            });
            $A.enqueueAction(action);
        }
    },
    gTMIRespHandler:function(component, result){
        var sGTCon 		= component.find("betGtDiv");
        var sGTDiv		= component.find("betGtRecordsdiv");
        var sRecLength 	= '';	 
        var resMessage 	= result.responseMessage;
        component.set("v.GTMIRespRecCount", 0);
        this.toggleSpinner(component);
        
        if(result.responseCode == '200'){
            sRecLength = result.resultPayload.length;
            if(sRecLength > 0){
                if (resMessage != "Success"){
                    sRecLength = resMessage;
                }
                
                this.displayMessage('success', '', 'Records from GTMI: ' + sRecLength);
                
                component.set("v.GTMIRespRecCount", sRecLength);
                component.set("v.GTMIdata", result.resultPayload);
                component.set("v.accessToken", result.accessToken);
                component.set("v.GTMIRespMessage", result.responseMessage);
                
                
                $A.util.addClass(sGTCon, "slds-hide");        
                $A.util.removeClass(sGTDiv, "slds-hide");
            }
        }else if(result.responseCode == '204'){
            this.displayMessage('informational', '', 'No Records found in the GTMI.');
            $A.util.addClass(sGTCon, "slds-hide");        
            $A.util.removeClass(sGTDiv, "slds-hide");
        }else if(result.responseCode == '400'){
            this.displayMessage('Error', '', 'Input format is wrong. Please contact administrator.');
        }else if(result.responseCode == '401'){
            this.displayMessage('Error', '', 'Unauthorized access. Please contact administrator.');
        }else if(result.responseCode == '404'){
            this.displayMessage('Error', '', 'Unable to reach GTMI server. Please try again later.');
        }else if(result.responseCode == '408'){
            this.displayMessage('Error', '', 'Request timed out. Please try again later.');
        }else if(result.responseCode == '500'){ 
            this.displayMessage('Error', '', 'Internal Server Error. Please try again later.');
        }else{
            this.displayMessage('Error', '', 'Unable to reach GTMI server. Please try again later.');
        }
    },
    getEDPRecords: function(component, event, btnId) {
        //Focus EDP search tab 
        component.find('bet-tabset').set('v.selectedTabId', 'edp');
        var sLOB		  = component.get("v.objBDDForm.BDD_Line_of_Business__c");
        var sEntType 	  = component.get("v.objBDDForm.BDD_Entity_Type__c");
        var sShortName 	  = component.get("v.objBDDForm.Full_Legal_Name__c");
        var sIncCountry   = component.get("v.objBDDForm.Inc_Country__c");
        var accessToken   = component.get("v.accessToken");
        var sTriggerORBISSearch = false;
        
        if(sShortName){
            sShortName = sShortName.trim(); 
        }
        
        if(sLOB && sEntType){
            if(sLOB == 'WONA' || sLOB == 'SENA' || sLOB == 'STUSCO'){
                if(sShortName){
                    sTriggerORBISSearch = true;
                }else{
                    this.displayMessage('error', 'Error', 'Please fill short name.');
                }
            }
        }else{
            this.displayMessage('error', 'Error', 'Please fill Line of Business and Entity Type.');
        }
        
        
        if(sTriggerORBISSearch == true){
            var sourceType = '';
            if(btnId == 'bet-edp-btn'){
                sourceType = 'Primary';
            }else{
                sourceType = 'Secondary';
            }
            
            this.toggleSpinner(component);
            var action = component.get("c.getEdpData");
            action.setParams({
                sLOB: sLOB,
                sEntType: sEntType,
                searchShortName : sShortName,
                sIncCountry : sIncCountry,
                accessToken : accessToken,
                sSource: sourceType
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result != ""){
                        this.edpRespHandler(component, result);
                    }else{
                        this.toggleSpinner(component);
                        this.displayMessage('informational', '', 'No Response from server.');
                    }
                }else if (state === "ERROR") {
                    this.toggleSpinner(component);
                    this.displayMessage('error', 'Error', 'Error in executing this operation.');
                }
            });
            $A.enqueueAction(action);
        }
    },
    edpRespHandler: function(cmp, result){
        cmp.set("v.accessToken", result.accessToken);
        var dataSource = result.dataSource;
        var sourceType = result.sourceType;
        var addEdpSourceAvailable = result.AddEdpSourceAvailable;
        var dataTableId = '';
        var addbutton = false;
        var secBtnStatus = cmp.get('v.secButtonAdded');
        this.toggleSpinner(cmp);
        if(result.responseCode == '200'){
            var edpRecordList = '';
            var edpColumns = '';
            var totalRecCount = result.totalRecordCount;
            var availRecCount = result.availableRecordCount;
            var recCount = '';
            if(availRecCount > 0){
                if(availRecCount == 250){
                    recCount = availRecCount + ' records of ' + totalRecCount;
                }else{
                    recCount = availRecCount;
                }
                
                this.displayMessage('success', '', 'Records from ' + dataSource + ': ' + recCount);
                if(dataSource == 'Orbis'){
                    edpRecordList = result.OrbisResult;
                    edpColumns = cmp.get("v.OrbisColumns");
                    dataTableId = dataSource;
                }else if(dataSource == 'Bankers Almanac'){
                    edpRecordList = result.bankersResult;
                    edpColumns = cmp.get("v.bankersColumns");
                    dataTableId = 'BankersAlmanac';
                }   
                if(sourceType == 'Secondary'){
                    cmp.set('v.secDataTableAdded', true); 
                }
                                    
                $A.createComponent(
                    "c:BET_Data_Table",
                    {
                        "edpData": edpRecordList,
                        "edpColumns": edpColumns,
                        "sourceType": sourceType,
                        "sourceName": dataSource,
                        "componentId": dataTableId
                    },
                    function(component, status, errorMessage){
                        if (status === "SUCCESS") {
                            cmp.set('v.secButtonAdded', true);
                            var body = cmp.get("v.body");
                            body.push(component);
                            cmp.set("v.body", body);
                            
                            //Add button to the EDP Layout
                            if(sourceType == 'Primary' && addEdpSourceAvailable == 'Available' && secBtnStatus != true){
                                cmp.set('v.secButtonAdded', true);
                                var btnId = 'bet-edp-sec';
                                $A.createComponent(
                                    "lightning:button",
                                    {
                                        "aura:id": btnId,
                                        "label": "Secondary source data",
                                        "class": "slds-button_brand slds-m-top_medium",
                                        "onclick": cmp.getReference("c.searchEDPBtnHandler")
                                    },
                                    function(newButton, status, errorMessage){
                                        if (status === "SUCCESS") {
                                            var body = cmp.get("v.body");
                                            body.push(newButton);
                                            cmp.set("v.body", body);
                                        }else if (status === "ERROR") {
                                            console.log("Error: " + errorMessage);
                                        }
                                    }
                                ); 
                            }
                            
                        }else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    }
                );
            }else{
                this.displayMessage('informational', '', 'No Records found in ' + dataSource);
            }
        }else if(result.responseCode == '500'){
            addbutton = true;
            this.displayMessage('Error', '', dataSource + ': Internal Server Error');
        }else if(result.responseCode == '502'){
            addbutton = true;
            this.displayMessage('Error', '', dataSource + ': Internal Server Error, Please try again later.');
        }else if(result.responseCode == '401'){
            addbutton = true;
            this.displayMessage('Error', '', 'Unauthorized access. Please contact administrator.');
        }else if(result.responseCode == '404' && dataSource == "Orbis" ){
            addbutton = true;
            this.displayMessage('Error', '', 'Unable to reach ' + dataSource + ' server. Please try again later.');
        }else if(result.responseCode == '404'&& dataSource == "Bankers Almanac"){
            addbutton = true;
            this.displayMessage('Info', '', dataSource + ': No records found');
        }else if(result.responseCode == '400'){
            addbutton = true;
            this.displayMessage('Error', '', 'Input parameter missing');
        }else if(result.responseCode == '204'){
            addbutton = true;
            this.displayMessage('Info', '', dataSource + ': No records found');
        }else if(result.responseCode == '429'){
            addbutton = true;
            this.displayMessage('Error', '', dataSource + ': Too many requests.');
        }else{
            addbutton = true;
            this.displayMessage('Error', '', dataSource + ': Internal Server Error');
        }
        
        if(addbutton == true && addEdpSourceAvailable == 'Available' && secBtnStatus != true ){
            cmp.set('v.secButtonAdded', true);
            this.createNewButton(cmp);
        }
    },
    createNewButton: function(cmp){
        var btnId = 'bet-edp-sec';
        $A.createComponent(
            "lightning:button",
            {
                "aura:id": btnId,
                "label": "Secondary source data",
                "class": "slds-button_brand slds-m-top_medium",
                "onclick": cmp.getReference("c.searchEDPBtnHandler")
            },
            function(newButton, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body.push(newButton);
                    cmp.set("v.body", body);
                }else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        ); 
    },
    verifyEDP: function(component, result){
        var vatNum		 = component.get("v.verVATNum");
        var sCountry 	 = component.get("v.VerCountry");
        var accessToken  = component.get("v.accessToken");
        var sLOB		 = component.get("v.objBDDForm.BDD_Line_of_Business__c");
        var entType 	 = component.get("v.objBDDForm.BDD_Entity_Type__c");
        var imoNum	     = component.get("v.objBDDForm.Srch_Vsl_Name_or_IMO__c");
        var shortName 	 = component.get("v.objBDDForm.Full_Legal_Name__c");
        var irsLegalName = component.get("v.irsLegalName");
        
        if(imoNum){
            imoNum = imoNum.trim();
        }
        if(sLOB == 'SENA' || sLOB == 'STUSCO'){
            if(irsLegalName){
                shortName = irsLegalName.trim();
            }
        }else{
            if(shortName){
                shortName = shortName.trim();
            }
        }

        var triggerVer   = false;
        if(sLOB && entType){
            if(sLOB == 'WONA'){
                if(vatNum && sCountry){
                    triggerVer = true;
                }else{
                    this.displayMessage('error', 'Error', 'Please fill VAT Number/Tax ID and Country.');
                }
            }else if(sLOB == 'SENA' || sLOB == 'STUSCO'){
                if(vatNum && shortName){
                    triggerVer = true;
                }else{
                    this.displayMessage('error', 'Error', 'Please fill TIN Number and Short Name.');
                }
            }else if(sLOB == 'GLOBAL'){
                if(imoNum){
                    if(isNaN(imoNum)){
                       this.displayMessage('error', 'Error', 'Verification is allowed only on IMO number'); 
                    }else{
                        triggerVer = true; 
                    }
                }else{
                    this.displayMessage('error', 'Error', 'Please fill IMO Number.');
                }
            }
        }else{
            this.displayMessage('error', 'Error', 'Please fill Line of Business and Entity Type.');
        }
        
        if(triggerVer == true){  
            this.toggleSpinner(component);
            var pdfContent = component.get("v.pdfContainer");    
            var action = component.get("c.getVerificationStatus");
            action.setParams({
                vatNum: vatNum,
                sCountry: sCountry,
                accessToken: accessToken,
                sLOB: sLOB,
                entType: entType,
                imoNum: imoNum,
                name: shortName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //console.log(JSON.stringify(result));
                    this.verRespHandler(component,result);
                }else if (state === "ERROR") {
                    this.toggleSpinner(component);
                    this.displayMessage('error', 'Error', 'Error in executing this operation.');
                }
            });
            $A.enqueueAction(action);
        }
    },
    verRespHandler: function(component, result){
        var respCode = result.responseCode;
        var verSource = result.verificationSource;
        console.log('respCode >> ' + respCode + 'verSource >> ' + verSource);
        var resMessage = result.responseMessage;
        component.set("v.accessToken", result.accessToken);
        this.toggleSpinner(component);
        if(respCode == '200'){
           	component.set("v.verificationDone", true);
            $A.createComponent(
                "c:pdfViewer",
                {
                    "pdfData": result.resultPayload
                },
                function(pdfViewer, status, errorMessage){
                    if (status === "SUCCESS") {
                        //var pdfContainer = component.get("v.pdfContainer");
                        component.set("v.pdfContainer", []);     
                        var pdfContainer1 = component.get("v.pdfContainer");
                        pdfContainer1.push(pdfViewer);                    
                        component.set("v.pdfContainer", pdfContainer1);
                    }else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        }else if(respCode == '500'){
            this.displayMessage('Error', 'Error', 'Issue in connecting to ' + verSource + ', please try again later.');
        }else if(respCode == '401'){
            this.displayMessage('Error', 'Error', 'Unauthorised access. Please contact administrator.');
        }else{
            this.displayMessage('Error', 'Error', resMessage);
        }
    },
    toggleSpinner: function(component) {
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide"); 
    },
    resetAllSections: function(component, event, resetHeader){  
        var displayEdpAndVerTabs = component.get("v.displayEdpAndVerTabs")
        if(resetHeader != false){
            component.set("v.objBDDForm.Full_Legal_Name__c", '');
            component.set("v.objBDDForm.Inc_Country__c", '');
            component.set("v.objBDDForm.Srch_Vsl_Name_or_IMO__c", '');
        }
        
        //GTMI
        component.set("v.GTMIdata", "");
        component.set('v.GTMISelectedRow', "");
        component.set('v.showGTMIResetBtn', false);
        
        //EDP
        if(displayEdpAndVerTabs == true){
            component.set("v.body", []);
            component.set('v.secDataTableAdded', false);
            component.set('v.secButtonAdded', false);
            component.set('v.OrbisSelectedRow', '');
            component.set('v.BankersSelectedRow', '');
            
            //verification
            component.set('v.irsLegalName', '');
            component.set('v.verVATNum', '');
            component.set('v.VerCountry', '');
            if(component.find("betTaxWai") != undefined){
                component.find("betTaxWai").set('v.checked', false);
            }
            if(component.find("betTaxVal") != undefined){
                component.find("betTaxVal").set('v.checked', false);
            }
            if(component.find("betOfacVal") != undefined){
                component.find("betOfacVal").set('v.checked', false);
            }
            
            component.set('v.taxWaiver', false);
            component.set('v.manualOfacVal', false);
            component.set('v.vesselName', '');
            component.set('v.manualVerification', false);
            component.set('v.verificationDone', false);
            component.set('v.pdfContainer', []);
        }
    },
    displayMessage: function(sType, sTitle, sMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": sType,
            "title": sTitle,
            "message": sMessage,
            "mode": 'dismissible',
            "duration":8000
        });
        toastEvent.fire();
    },
})