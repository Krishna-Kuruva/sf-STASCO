({
	doInit : function(component, event, helper) {
		helper.getAllDetails(component, event, helper);
        $A.enqueueAction(component.get('c.checkBrowser'));
        helper.setDefaultInputs(component, event, helper); //Rahul Sharma | Date - 26-May-20 : Calling helper method to set default inputs.
        /* START | Surbhi | Date 2-Aug-2022 : PBI-1366142 */
        helper.checkEditPermisnAndgetInactiveNextFireDt(component, event, helper);
        /* END | Surbhi | Date 2-Aug-2022 : PBI-1366142*/
	},
    refreshPage : function(component, event, helper) {
		helper.getAllDetails(component, event, helper);
        component.set("v.SelectCustomer",'ALL');
        component.set("v.SelectMaterial",'ALL');
        component.set("v.SelectLocation",'ALL');
        component.set("v.ThresholdEditDisabled",true);
         /* START | Surbhi | Date 2-Aug-2022 : PBI-1366142 */
        component.set("v.hasUserClkOLFInactvatnEditBtn",false);
        /* END | Surbhi | Date 2-Aug-2022 : PBI-1366142 */
	},
    getSelCustDtl : function(component, event, helper) {
		helper.getCustDtl(component, event, helper);
        component.set("v.SelectMaterial",'ALL');
        component.set("v.SelectLocation",'ALL');
	},
    getSelMRCDtl : function(component, event, helper) {
		helper.getMRCDtl(component, event, helper);
	},
    //UserActivateButton_Soumyajit_01Aug2019 starts
    userActivateDeactivate : function(component, event, helper) {
        helper.userActivateDeactivate(component, event, helper);
        helper.getAllDetails(component, event, helper);
	},
    //UserActivateButton_Soumyajit_01Aug2019 ends
    checkBrowser : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");  
        if(device === "PHONE")
        {
            console.log('Adding Phone Settings');
            
            helper.addClasses(component,"OLFCONNECTION","slds-grid_vertical;");
            helper.addClasses(component,"masterGrid","slds-grid_vertical;");
            helper.removeClasses(component,"masterGridChild1","slds-size_1-of-12;slds-align_absolute-center;noPadding;");
            helper.removeClasses(component,"masterGridChild2","slds-size_2-of-12;slds-align_absolute-center;noPadding;");
            helper.removeClasses(component,"masterGridChild3","slds-size_2-of-12;slds-align_absolute-center;noPadding;");
            helper.removeClasses(component,"masterGridChild4","slds-size_3-of-12;slds-align_absolute-center;noPadding;");
            
            helper.addClasses(component,"PRICETHRESHOLD","slds-grid_vertical;");
            helper.addClasses(component,"priceGrid","slds-grid_vertical;");
            helper.removeClasses(component,"priceGridChild1","slds-size_2-of-12;slds-align_absolute-center;noPadding;");
            helper.removeClasses(component,"PRICETHRESHOLDINNER2","slds-size_2-of-12;");
        }
    },
    //ICELimit_Soumyajit_27Apr2020 starts
    editThreshold : function(component, event, helper) {
        component.set("v.ThresholdEditDisabled",false);
        helper.removeClasses(component,"PRICETHRESHOLDINNER1","slds-size_11-of-12;");
        helper.addClasses(component,"PRICETHRESHOLDINNER1","slds-size_10-of-12;");
    },
    saveThreshold : function(component, event, helper) {
        var ICELGO_threshold = component.get("v.ICEThreshold");
        var hasError = false;
        
        if(ICELGO_threshold !=undefined && ICELGO_threshold != '')
        {
            if(ICELGO_threshold<0)
            {
                helper.popToast(component,'Error','Price cannot be negative!');
                hasError = true;
            }
        }
        
        if(!hasError)
        {
            helper.saveThresholdPrice(component, event, helper);
            
        	helper.removeClasses(component,"PRICETHRESHOLDINNER1","slds-size_10-of-12;");
        	helper.addClasses(component,"PRICETHRESHOLDINNER1","slds-size_11-of-12;");
        }
    },
    cancelSaveThreshold : function(component, event, helper) {
        component.set("v.ThresholdEditDisabled",true);
        
        helper.removeClasses(component,"PRICETHRESHOLDINNER1","slds-size_10-of-12;");
        helper.addClasses(component,"PRICETHRESHOLDINNER1","slds-size_11-of-12;");
    },
    //ICELimit_Soumyajit_27Apr2020 ends

    /*Method Name : getCountOfGsapData
     *Developer   : Rahul Sharma
     *Date        : 19-May-2020
     *Description : Counts SAP Staging records for which 'Sent to OLF?' is 'Failed' for the given input window.
     */
    getCountOfGsapData : function(component, event, helper){
        component.set("v.olfMessage", '');
        component.set("v.openRetryModal", true);
        helper.countGsapData(component, event, helper);
    },

    /*Method Name : retryCallout
     *Developer   : Rahul Sharma
     *Date        : 27-May-2020
     *Description : Retry callout to OLF with failed SAP Staging records.
     */
    retryCallout : function(component, event, helper){
        helper.retryOlfCallout(component, event, helper);
    },

    /*Method Name : validateInput
     *Developer   : Rahul Sharma
     *Date        : 19-May-2020
     *Description : Validates input fields.
     */
    validateInput : function(component, event, helper){
        //Validate From Date and To Date for OLF push retry.
        helper.validateDates(component, event, helper);
    },

    /*Method Name : validateInput
     *Developer   : Rahul Sharma
     *Date        : 27-May-2020
     *Description : Closes OLF popup modal.
     */
    closeModel : function(component, event, helper){
        component.set("v.openRetryModal", false);
        component.set("v.openWaringPopup", false);
        /* START | Surbhi | Date 2-Aug-2022 : PBI-1366142 */
        component.set("v.showWaringPopup", false);
        /* END | Surbhi | Date 2-Aug-2022 : PBI-1366142 */
    },

    /*Method Name  : toggleTrancheSetting
      *Developer   : Rahul Sharma
      *Date        : 19-Oct-2020
      *Description : this method toggle the edit option for Lifting Window Setup section.
      */
    toggleTrancheSetting : function(component, event, helper){
        if(component.get('v.editTranche')){
            let tranchSetup = JSON.parse(JSON.stringify(component.get("v.trancheSetupLstBkp")));
            console.log('trancheSetupLstBkp: '+JSON.stringify(tranchSetup));
            component.set('v.editTranche', false);
            component.set('v.trancheSetupList', tranchSetup);
            component.set('v.trancheSetupValid', true);
        }
        else{
            component.set('v.editTranche', true);
            let tranchSetup = JSON.parse(JSON.stringify(component.get("v.trancheSetupList")));;
            console.log('trancheSetupList: '+JSON.stringify(tranchSetup));
            component.set('v.trancheSetupLstBkp', tranchSetup);
        }
    },

    /*Method Name  : verifytranchesForOLF
      *Developer   : Rahul Sharma
      *Date        : 16-Oct-2020
      *Description : this method verify whether OLF inactivation is required before saving tranche setting.
      */
     verifytranchesForOLF : function(component, event, helper){
        var trancheSetupList = component.get("v.trancheSetupList");
        if(trancheSetupList){
            var isValid = helper.validateTrancheSetup(component, event, helper);
            if(isValid){
                var requireConfirmation = helper.checkAllTranchesStatus(component, event, helper, trancheSetupList);
                if(requireConfirmation)
                    component.set('v.openWaringPopup', true);
                else{
                    helper.startSpinner(component, event, helper);
                    helper.saveTranches(component, event, helper, trancheSetupList);
                }
            }
        }
        else{
            helper.endSpinner(component, event, helper);
            helper.popToast(component,
                            'error',
                            'An unknown error occurred. Please contact System Administrator.');
        }
    },

    /*Method Name  : updateTranches
      *Developer   : Rahul Sharma
      *Date        : 16-Oct-2020
      *Description : this method updates tranche setting.
      */
    updateTranches : function(component, event, helper){
        helper.startSpinner(component, event, helper);
        var trancheSetupList = component.get("v.trancheSetupList");
        if(trancheSetupList){
                helper.saveTranches(component, event, helper, trancheSetupList);
                helper.deactivateOLF(component, event, helper);
        }
        else{
            helper.endSpinner(component, event, helper);
            helper.popToast(component,
                            'error',
                            'An unknown error occurred. Please contact System Administrator.');
        }
    },

    /*Method Name  : validateTranches
      *Developer   : Rahul Sharma
      *Date        : 16-Oct-2020
      *Description : this validates the tranche windows.
      */
     validateTranches : function(component, event, helper){
        helper.validateTrancheSetup(component, event, helper);
     },

     /*Method Name  : validateTrancheOnChange
      *Developer   : Rahul Sharma
      *Date        : 20-Oct-2020
      *Description : this method validates bad input values for tranche setting.
      */
     validateTrancheOnChange : function(component, event, helper){
         //START Surbhi Srivastava,Date  22-Jul-22 : PBI-(1343336), Description: Based on Start day, End day, populating Start Date and End Date automatically                                               
        if(event.getSource() != null){
            if(event.getSource().get('v.name') != null && event.getSource().get('v.value') != '' && event.getSource().get('v.label') != ''){                
                var index = event.getSource().get('v.name');
                var getStartOrEndDateEle = (event.getSource().get('v.label') == 'Start Day') ? component.find("displayStartDate")[index] : component.find("displayEndDate")[index];
                if(getStartOrEndDateEle != null){                    
                    var getStartOrEndDay = event.getSource().get('v.value');
                    var getTodayDate = new Date();               
                    getTodayDate.setDate(getTodayDate.getDate() + parseInt(getStartOrEndDay));
                    var getDate = getTodayDate.toISOString();
                    getStartOrEndDateEle.set("v.value",getDate);
                }              
            }           
        }
        //END Surbhi Srivastava, Date: 22-Jul-22,PBI-(1343336),Description: Based on Start day, End day, populating Start Date and End Date automatically 
        helper.validateTrancheInputs(component, event, helper);
     },
    /* Start | Surbhi | Date 2-Aug-2022 : PBI-1366142 */    
    handleEditCnclBtnLogicOfOLFInactiveDt : function(component,event,helper){
        helper.editCnclBtnLogicOfOLFInactiveDt(component,event,helper);
    },    
    validateInactiveTimeAndCreateSchdlrLogic : function(component,event,helper){
        helper.validateITAndCreateSchdlrLogic(component,event,helper);
    },
    userConfirmatnToschdleOLFInactiveTime : function(component,event,helper){        
        helper.scheduleJobOLFConnAutoInactivatn(component,event,helper); 
    }
    /* END | Surbhi | Date 2-Aug-2022 : PBI-1366142 */
})