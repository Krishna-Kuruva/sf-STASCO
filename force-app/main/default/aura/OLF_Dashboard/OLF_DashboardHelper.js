({
	getAllDetails : function(cmp,evt,help) {
        help.startSpinner(cmp, evt, help);
		var callApexGetAllDetails = cmp.get("c.getAllDetails");
        callApexGetAllDetails.setCallback(this, function(a) {
            var state = a.getState();
            
            if(state === 'SUCCESS'){
                cmp.set("v.hasPO_Permission",a.getReturnValue().hasPermission);
                cmp.set("v.OLFStatus",a.getReturnValue().OLFStatus);
                cmp.set("v.LastRequestFromOLF",a.getReturnValue().LastRequestFromOLF);
                cmp.set("v.LastResponseFromRevolution",a.getReturnValue().LastResponseFromRevolution);
                cmp.set("v.ICEThreshold",a.getReturnValue().ICELGO_threshold);
                cmp.set("v.CustomerList",a.getReturnValue().CustomerList);
                //START - Rahul Sharma | Date: 16-Oct-20 : Added tranche setup list
                console.log('Tranche List: ' + JSON.stringify(a.getReturnValue().trancheWrapList));
                //cmp.set("v.trancheSetupList", a.getReturnValue().trancheWrapList);
                //END - Rahul Sharma | Date: 16-Oct-20 : Added tranche setup list
                var CustRecords =a.getReturnValue().CustomerDetails;
                if(CustRecords != undefined)
                {
                	CustRecords.forEach(function(record){record.linkName = '/'+record.AccountID;});
                }
                cmp.set("v.CustomerDetails",CustRecords);
                cmp.set("v.HasMRC",a.getReturnValue().HasMRC);
                cmp.set("v.NextInactivationBatchTime",a.getReturnValue().NextInactivationBatchTime);//327368_Soumyajit_09Aug2019
                /* START | Surbhi | Date 2-Aug-2022 : PBI-1366142 */   
                cmp.get("v.NextInactivationBatchTime") == "NA" ?  cmp.set("v.enableOLFInactvatnEditBtn",false) : cmp.set("v.enableOLFInactvatnEditBtn",true);                
                /* END | Surbhi | Date 2-Aug-2022 : PBI-1366142 */   
                var CustomerSection = cmp.find("CustomerSection");
                $A.util.removeClass(CustomerSection, "CustomerSectionHeightReduce");
                $A.util.addClass(CustomerSection, "CustomerSectionHeightEnlarge");
                var today = new Date();
                var trancheList = [];  
                
                for (var i=0; i< a.getReturnValue().trancheWrapList.length; i++)
                {
                    var newStartDate = new Date();
                    var newEndDate = new Date();
                    var item = a.getReturnValue().trancheWrapList[i];
                    newStartDate.setDate(newStartDate.getDate() + item.startDay);
                    newEndDate.setDate(newEndDate.getDate() + item.endDay);
                    //newStartDate = getUTCDate() today.addDays(5);
                    var tranche = {endDay: item.endDay, isActive: item.isActive, settingID: item.settingID, settingName: item.settingName, settingValue: item.settingValue, startDay: item.startDay, startDate: newStartDate.toISOString(), endDate:newEndDate.toISOString()};
                    trancheList.push(tranche);
                }
                console.log('new trancheList:'+JSON.stringify(trancheList));
                cmp.set("v.trancheSetupList", trancheList);
               
                /* End | Mohan | Date 27-Jan-2022 |PBI (1043402) */
            }
            else
                help.popToast(cmp,'Error','Something went wrong. Please try again later!');
            help.endSpinner(cmp, evt, help);
        })
        $A.enqueueAction(callApexGetAllDetails);
	},
    getCustDtl : function(cmp,evt,help) {
        help.startSpinner(cmp, evt, help);
		var callApexGetAccountData = cmp.get("c.getAccountData");
        var CustName= cmp.get("v.SelectCustomer");
        
        if(CustName === "ALL")
        {
            callApexGetAccountData.setParams({
            "AccountName": "",
            "SearchType" : "ALL"
        	});
        }
        else
        {
            callApexGetAccountData.setParams({
            "AccountName": CustName,
            "SearchType" : "THIS"
        	});
        }

        callApexGetAccountData.setCallback(this, function(a) {
            var state = a.getState();
            
            if(state === 'SUCCESS'){
                cmp.set("v.OLFStatus",a.getReturnValue().OLFStatus);
                //
                var CustRecords =a.getReturnValue().CustomerDetails;
                if(CustRecords != undefined)
                {
                    CustRecords.forEach(function(record){record.linkName = '/'+record.AccountID;});
                }
                cmp.set("v.CustomerDetails",CustRecords);
                //
                cmp.set("v.HasMRC",a.getReturnValue().HasMRC);
                cmp.set("v.MaterialList",a.getReturnValue().MaterialList);
                cmp.set("v.LocationList",a.getReturnValue().LocationList);
                //
                var MRCRecords =a.getReturnValue().MRCDetails;
                if(MRCRecords != undefined)
                {
                    MRCRecords.forEach(function(record){
                        record.MRClinkName = '/'+record.MRCid;
                        record.SoldTolinkName = '/'+record.SoldToId;
                        record.LocationlinkName = '/'+record.LocationId;
                        record.MateriallinkName = '/'+record.MaterialId;
                    });
                }
                cmp.set("v.MRCDetails",MRCRecords);
                //
                var CustomerSection = cmp.find("CustomerSection");
                if(CustName != "ALL"){
                    var MRCDTL = a.getReturnValue().MRCDetails;
                    if(a.getReturnValue().HasMRC)
                    {
                        help.popToast(cmp,'Success', MRCDTL.length + ' MRC(s) found for this customer');
                        $A.util.removeClass(CustomerSection, "CustomerSectionHeightEnlarge");
                        $A.util.addClass(CustomerSection, "CustomerSectionHeightReduce");
                    }     
                    else
                    {
                     	help.popToast(cmp,'Success','No MRC found for this customer');
                        $A.util.addClass(CustomerSection, "CustomerSectionHeightEnlarge");
                    }
        			
                }
                else
                {
                     $A.util.removeClass(CustomerSection, "CustomerSectionHeightReduce");
                     $A.util.addClass(CustomerSection, "CustomerSectionHeightEnlarge");
                }
            }
            else
                help.popToast(cmp,'Error','Something went wrong. Please try again later!');
            help.endSpinner(cmp, evt, help);
        })
        $A.enqueueAction(callApexGetAccountData);
	},
    getMRCDtl : function(cmp,evt,help) {
        help.startSpinner(cmp, evt, help);
		var callApexGetMRCData = cmp.get("c.getMRCData");
        var CustName= cmp.get("v.SelectCustomer");
        var MatName= cmp.get("v.SelectMaterial");
        var LocName= cmp.get("v.SelectLocation");
        
        if(MatName === "ALL" && LocName === "ALL")
        {
            callApexGetMRCData.setParams({
            "AccountName": CustName,
            "MaterialName" : "ALL",
            "LocationName" : "ALL",
            "SearchType" : "ALL"
        	});
        }
        else
        {
            callApexGetMRCData.setParams({
            "AccountName" : CustName,
            "MaterialName" : MatName,
            "LocationName" : LocName,
            "SearchType" : "THIS"
        	});
        }

        callApexGetMRCData.setCallback(this, function(a) {
            var state = a.getState();
            
            if(state === 'SUCCESS'){
                var MRCRecords =a.getReturnValue();
                MRCRecords.forEach(function(record){
                    record.MRClinkName = '/'+record.MRCid;
                    record.SoldTolinkName = '/'+record.SoldToId;
                    record.LocationlinkName = '/'+record.LocationId;
                    record.MateriallinkName = '/'+record.MaterialId;
                });
                cmp.set("v.MRCDetails",MRCRecords);
            }
            else
                help.popToast(cmp,'Error','Something went wrong. Please try again later!');
            help.endSpinner(cmp, evt, help);
        })
        $A.enqueueAction(callApexGetMRCData);
	},
    //UserActivateButton_Soumyajit_01Aug2019 starts
    userActivateDeactivate : function(component, event, helper) {
        helper.startSpinner(component, event, helper);
        var type = event.getSource().get("v.name");
        /* START | Surbhi | Date 2-Aug-2022 : PBI-1366142 */   
        type == 'START' ? helper.addClasses(component,"saveCancelbtnId","cust_OLFActiveSaveCnclBtn") : helper.removeClasses(component,"saveCancelbtnId","cust_OLFActiveSaveCnclBtn");
        /* END | Surbhi | Date 2-Aug-2022 : PBI-1366142 */
        var callApexUserActivateInactivate = component.get("c.userActivateInactivateFromScreen");
        callApexUserActivateInactivate.setParams({
                "actionType" : type
                });
        callApexUserActivateInactivate.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS')
                helper.popToast(component,'Success',a.getReturnValue());
            else
                helper.popToast(component,'Error','Something went wrong. Please try again later!');      
            helper.endSpinner(component, event, helper);
        });
        $A.enqueueAction(callApexUserActivateInactivate);
	},
    //UserActivateButton_Soumyajit_01Aug2019 ends
    //ICELimit_Soumyajit_27Apr2020 starts
    saveThresholdPrice : function(component, event, helper) {
        helper.startSpinner(component, event, helper);
        var ICELGO_threshold = component.get("v.ICEThreshold");
        var callApexSetThresholdPrice = component.get("c.setThresholdPrice");
        callApexSetThresholdPrice.setParams({
                "ICELGO_threshold" : ICELGO_threshold
                });
        callApexSetThresholdPrice.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS')
                helper.popToast(component,'Success',a.getReturnValue());
            else
                helper.popToast(component,'Error','Something went wrong. Please try again later!');
            
            component.set("v.ThresholdEditDisabled",true);
            helper.endSpinner(component, event, helper);
        });
        $A.enqueueAction(callApexSetThresholdPrice);
	},
    //ICELimit_Soumyajit_27Apr2020 ends
    startSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    endSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    popToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },
    addClasses: function(component,componentId,classNames) {
        var modal = component.find(componentId);
        var classNameArray = classNames.split(";");
        for (var i=0; i<classNameArray.length; i+=1)
            $A.util.addClass(modal,classNameArray[i]);
    },
    removeClasses: function(component,componentId,classNames) {
        var modal = component.find(componentId);
        var classNameArray = classNames.split(";");
        for (var i=0; i<classNameArray.length; i+=1)
            $A.util.removeClass(modal,classNameArray[i]);
    },

    /*Method Name : validateDates
     *Developer   : Rahul Sharma
     *Date        : 19-May-2020
     *Description : Validates From Date and To Date for aura:id = 'GsapContractPushToOLF' input fields.
     */
    validateDates : function(component, event, helper){
        var fromDateInput =  component.find("fromDate");
        var toDateInput = component.find("toDate");
        var fromDateISOString = fromDateInput.get('v.value');
        var toDateISOString = toDateInput.get('v.value');
        var maxToDateISOString = component.get("v.maxToDate");
        var maxToDateTime = new Date(maxToDateISOString);
        var maxValidity = component.get("v.maxDaysForResend");
        var minFromDateIsoString = component.get("v.minFromDate");
        if(fromDateISOString && toDateISOString){
            var fromDateTime = new Date(fromDateISOString);
            var toDateTime = new Date(toDateISOString);
            var minValidDateTime = new Date(minFromDateIsoString);
            if(fromDateTime > toDateTime){
                component.set("v.olfRetryValid", false);
            }
            else if(fromDateTime < minValidDateTime){
                component.set("v.olfRetryValid", false);
            }
            else if(toDateTime > maxToDateTime){
                component.set("v.olfRetryValid", false);
            }
            else{
                component.set("v.olfRetryValid", true); 
            }
        }
        else if(!fromDateISOString){
            component.set("v.olfRetryValid", false);
        }
        else if(!toDateISOString){
            component.set("v.olfRetryValid", false);
        }
        else{
            component.set("v.olfRetryValid", true); 
        }
    },

    /*Method Name : countGsapData
     *Developer   : Rahul Sharma
     *Date        : 19-May-2020
     *Description : Counts SAP Staging records for which 'Sent to OLF?' is 'Failed' for the given input window.
     */
    countGsapData : function(component, event, helper){
        var fromDateIsoString = component.get("v.fromDate");
        var toDateIsoString = component.get("v.toDate");
        var fromDateTime = new Date(fromDateIsoString);
        var toDateTime = new Date(toDateIsoString);
        helper.callServer(component, 
                         event, 
                         helper, 
                         'c.getOlfStagingRecordCount', 
                         function(response){
                            if(response){
                                if(response > 0 && response < 2){
                                    component.set("v.olfMessage", 'There is '+response+' failed record to be processed. Are you sure you want to re-attempt callout to OLF for this record?');
                                    component.set("v.enableRetry", true);
                                }
                                else if(response > 1){
                                    component.set("v.olfMessage", 'There are '+response+' failed records to be processed. Are you sure you want to re-attempt callout to OLF for these records?');
                                    component.set("v.enableRetry", true);
                                }
                                else{
                                    component.set("v.olfMessage", 'No failed records found for the given time period.');
                                    component.set("v.enableRetry", false); 
                                }
                            }
                            else{
                                component.set("v.olfMessage", 'No failed records found for the given time period.');
                                component.set("v.enableRetry", false);
                            }
                         },
                         {
                             "fromDateTime" : fromDateTime,
                             "toDateTime" : toDateTime
                         }
                    );  
    },

    /*Method Name : retryOlfCallout
     *Developer   : Rahul Sharma
     *Date        : 27-May-2020
     *Description : Retry callout to OLF with failed SAP Staging records.
     */
    retryOlfCallout : function(component, event, helper){
        var fromDateIsoString = component.get("v.fromDate");
        var toDateIsoString = component.get("v.toDate");
        var fromDateTime = new Date(fromDateIsoString);
        var toDateTime = new Date(toDateIsoString);
        helper.callServer(component, 
                          event, 
                          helper, 
                          'c.retryOlfStagingRecords', 
                          function(response){
                            var message;
                            var type
                            if(response){
                                if(response == 0)
                                    message = 'Your request has been submitted and will be processed in few minutes.';
                                else
                                    message = 'Your request has been submitted and may take up to '+response+' minutes to be processed.';
                                type = 'Success';
                            }
                            else{
                                message = 'Your request cannot be processed at this time due to internal error.';
                                type = 'Error';
                            }
                            component.set("v.openRetryModal", false);
                            helper.popToast(component, type, message);
                          },
                          {
                              "fromDateTime": fromDateTime,
                              "toDateTime" : toDateTime
                          }
        );
    },

    /*Method Name : setDefaultInputs
     *Developer   : Rahul Sharma
     *Date        : 26-May-2020
     *Description : Method to set default inputs for the component markup. 
                    Should be only called from doInit.
     */
    setDefaultInputs: function(component, event, helper){
        helper.setDefaultInputDates(component, event, helper);
    },

    /*Method Name : setDefaultInputDates
     *Developer   : Rahul Sharma
     *Date        : 26-May-2020
     *Description : Set default 'From Date' and 'To Date' for aura:id = 'GsapContractPushToOLF' input fields.
     */
    setDefaultInputDates: function(component, event, helper){     
        var minFromDays = component.get("v.maxDaysForResend");
        //var timezone = $A.get("$Locale.timezone");
        var dateToday = new Date();
        var currentDateTime = dateToday.toISOString();
        var yesterdayDate = new Date();
        yesterdayDate.setDate(dateToday.getDate() - 1);
        var yesterdayDateTime = yesterdayDate.toISOString();
        var minFromDate = new Date();
        minFromDate.setDate(dateToday.getDate() - minFromDays);
        var minFromDateTime = minFromDate.toISOString();
        component.set("v.maxToDate", currentDateTime);
        component.set("v.toDate", currentDateTime);
        component.set("v.fromDate", yesterdayDateTime);
        component.set("v.minFromDate", minFromDateTime);
    },

    /*Method Name : callServer
     *Developer   : Rahul Sharma
     *Date        : 26-May-2020
     *Description : Method to call server.
     */
    callServer : function(component, event, helper, method, callback, params){    
        var action = component.get(method);
        if(params){      
            action.setParams(params);
        }
        action.setCallback(this, function(response){
            var state = response.getState();         
            if(state === "SUCCESS" ) {           
                callback.call(this,response.getReturnValue());
                
            } else if(state === "ERROR"){        
                var errors = response.getError();
                if(errors) {             
                    if(errors[0] && errors[0].message){
                        helper.popToast(component,'error',  errors[0].message);                  
                    } 
                    else{
                        helper.popToast(component,'error',  'Unknown Error');  
                    }
                }
            }
         });
            $A.enqueueAction(action);
     },

     /*Method Name : saveTranches
      *Developer   : Rahul Sharma
      *Date        : 16-Oct-2020
      *Description : this method saves updated tranche setting.
      */
     saveTranches : function(component, event, helper, trancheSetupList){
        component.set('v.openWaringPopup', false);
        helper.callServer(component, 
                          event, 
                          helper, 
                          'c.updateTrancheSetting', 
                          function(response){
                            helper.endSpinner(component, event, helper);
                            component.set("v.editTranche", false);
                            helper.popToast(component,
                                             'success',
                                             'Lifting window(s) updated successfully.');
                          },
                          {
                            trancheSetting : JSON.stringify(trancheSetupList)
                          }
        );
    },

    /*Method Name  : validateTrancheSetup
      *Developer   : Rahul Sharma
      *Date        : 16-Oct-2020
      *Description : this validates the tranche windows.
      */
validateTrancheSetup : function(component, event, helper){
        var isValidInput = helper.validateTrancheInputs(component, event, helper);
        var isValidData = true;
        if(isValidInput){
            var trancheSettingList = component.get('v.trancheSetupList');
            var lastInput; 
             if(trancheSettingList){
                for(let i = 0; i < trancheSettingList.length; i++){
                    let trancheSetup = trancheSettingList[i];
                    if(lastInput){
                        if(parseInt(trancheSetup['startDay']) >= parseInt(trancheSetup['endDay'])){
                            helper.popToast(component,
                                            'error',
                                            'Start day cannot be greater or equal to end day.');
                            isValidData = false;
                            break;
                        }
                        else if(parseInt(lastInput) >= parseInt(trancheSetup['startDay'])){
                            helper.popToast(component,
                                            'error',
                                            'Lifting windows cannot have overlapping days.');
                            isValidData = false;
                            break;
                        }
                        else if(parseInt(trancheSetup['startDay']) > (parseInt(lastInput) + 1)){
                            helper.popToast(component,
                                            'error',
                                            'Lifting windows cannot have gaps.');
                            isValidData = false;
                            break;
                        }
                        else{
                            lastInput = parseInt(trancheSetup['endDay']);
                        }
                    }
                    else{
                        if(parseInt(trancheSetup['startDay']) >= parseInt(trancheSetup['endDay'])){
                            helper.popToast(component,
                                            'error',
                                            'Start day cannot be greater or equal to end day.');
                            isValidData = false;
                            break;
                        }
                        else
                            lastInput = parseInt(trancheSetup['endDay']);
                    }
                }
            }
        }
        else{
            helper.removeStyle(component, 
                               event,
                               helper, 
                               'saveTranche', 
                               'OLFstatusGreen');
            helper.popToast(component,
                            'error',
                            'Please fill the valid information.');
            isValidData = false;
        }
        return isValidData;
    },

    /*Method Name  : validateTrancheInputs
      *Developer   : Rahul Sharma
      *Date        : 20-Oct-2020
      *Description : this method validates bad input values for tranche setting.
      */
    validateTrancheInputs : function(component, event, helper){
        var allValid = component.find('trancheInputChild2').reduce(function(validSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
           //START Surbhi Srivastava,Date  22-Jul-22 : PBI-(1343336),Description - added checkValidity() method in return statement               
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
            //END Surbhi Srivastava,Date  22-Jul-22 : PBI-(1343336),Description - added checkValidity() method in return statement
         }, true);
         if(allValid){
             component.set('v.trancheSetupValid', true);
             helper.addStyle(component, 
                             event, 
                             helper, 
                             'saveTranche', 
                             'OLFstatusGreen');
             return true;
         } 
         else{
            component.set('v.trancheSetupValid', false);
            helper.removeStyle(component, 
                               event, 
                               helper, 
                               'saveTranche', 
                               'OLFstatusGreen');
            return false;
        }   
    },

    /*Method Name  : addStyle
      *Developer   : Rahul Sharma
      *Date        : 20-Oct-2020
      *Description : this method adds CSS style to the component.
      */
     addStyle : function(component, event, helper, auraId, className){
        var btnTarget = component.find(auraId);
        $A.util.addClass(btnTarget, className);
     },

    /*Method Name  : removeStyle
      *Developer   : Rahul Sharma
      *Date        : 20-Oct-2020
      *Description : this method removes CSS style from the component.
      */
    removeStyle : function(component, event, helper, auraId, className){
        var btnTarget = component.find(auraId);
        $A.util.removeClass(btnTarget, className);
    },

    /*Method Name  : checkAllTranchesStatus
      *Developer   : Rahul Sharma
      *Date        : 20-Oct-2020
      *Description : this method checks is any of the tranche is active.
      */
    checkAllTranchesStatus : function(component, event, helper, trancheSetupList){
        var openWarning = true;
        for(let i = 0; i < trancheSetupList.length; i++){
            let trancheSetup = trancheSetupList[i];
            if(trancheSetup['isActive']){
                openWarning = false;
                break;
            }
        }
        return openWarning;
    },

    /*Method Name  : checkAllTranchesStatus
      *Developer   : Rahul Sharma
      *Date        : 20-Oct-2020
      *Description : this method deactivates the OLF connection.
      */
    deactivateOLF : function(component, event, helper){
        console.log('deactivateOLF');
        if(component.get('v.OLFStatus')){
            helper.callServer(component, 
                event, 
                helper, 
                'c.userActivateInactivateFromScreen', 
                function(response){
                    component.set('v.OLFStatus', false);
                },
                {
                  actionType : 'STOP'
                }
            );
        }
    },
          // Start | Surbhi | Date 2-Aug-2022 | PBI-1366142 | Description : Invokes when user clicks on EDIT button   
    editCnclBtnLogicOfOLFInactiveDt : function(component,event,helper){
        var btnAction = event.getSource().get('v.label');
        var nextInactivationBatchTime = component.get("v.NextInactivationBatchTime");
        if(nextInactivationBatchTime == 'NA' || nextInactivationBatchTime ==''){
            component.set("v.setOlfInactiveDt",null);
        }
        if(btnAction == 'Cancel'){
            component.set("v.hasUserClkOLFInactvatnEditBtn",false);
            helper.removeClasses(component,"masterGridChild4","slds-size_4-of-12;");
            helper.addClasses(component,"masterGridChild4","slds-size_3-of-12;");
        }        
        else if(btnAction == 'Edit'){
            component.set("v.hasUserClkOLFInactvatnEditBtn",true);            
            helper.removeClasses(component,"masterGridChild4","slds-size_3-of-12;");
            helper.addClasses(component,"masterGridChild4","slds-size_4-of-12;");
            helper.checkEditPermisnAndgetInactiveNextFireDt(component, event, helper);
            if(component.get("v.OLFStatus")){
                 helper.addClasses(component,"saveCancelbtnId","cust_OLFActiveSaveCnclBtn");
            } 
        }
    }, 
    // this method handles the validation of inactivation time field and invoking the scheduler creation logic
    validateITAndCreateSchdlrLogic: function(component, event, helper){
        if(component.find('inactiveDate') != null && component.find('inactiveDate') != undefined){
            var allValid = component.find("inactiveDate").get("v.validity");
            var isValid = false;
            if(allValid != undefined && allValid != null && allValid.valid != null){
                isValid = allValid.valid;
            }
            if(!isValid){
                helper.popToast(component,'error','Please enter the valid date or time.'); 
                return;
            } 
        }
        var dateToday = new Date();
        var currentDtTime = dateToday.toISOString();
        var olfInactivationDttime = component.get("v.setOlfInactiveDt"); 
        if(olfInactivationDttime < currentDtTime){
            helper.popToast(component,'error','OLF Connection Auto-Inactivation time cannot be in the past.'); 
            return;
        }        
        else{
            var nextInactivationBatchTime = component.get("v.NextInactivationBatchTime"); 
            if((nextInactivationBatchTime == "NA" || nextInactivationBatchTime == "")){
                if(olfInactivationDttime != null){                    
                    helper.scheduleJobOLFConnAutoInactivatn(component, event, helper);
                }
                else{
                    helper.popToast(component,'error','No OLF Connection Auto-Inactivation time scheduled at this moment. If you want to schedule, please enter the date and time.');
                }
            }
            else{
                component.set("v.showWaringPopup",true);
                var getOLFWarningMessage = $A.get("$Label.c.RV_OLFInactivationWarningMsg");
                if(getOLFWarningMessage != '' && getOLFWarningMessage != undefined){
                    component.set("v.OLFInactivationWarningMsg",getOLFWarningMessage);
                }                
            }
        }
    },
    scheduleJobOLFConnAutoInactivatn : function(component, event, helper){  
        var spinner = component.find("spinnerModel");
        $A.util.removeClass(spinner, "slds-hide");
        var olfInactivationDttime = component.get("v.setOlfInactiveDt"); 
        var action = component.get("c.OLFAutoInactivationScheduleJob");  
        action.setParams({ "getOlfInactivationDttime" : olfInactivationDttime });  
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            var res = response.getReturnValue();
            if (state === "SUCCESS") { 
                if(res != null){
                    helper.popToast(component,'Success',res.returnMsg);
                }
                else{
                    helper.popToast(component,'Error','Something went wrong. Please try again later!');
                }
                if(res.returnDate != null){
                    component.set("v.NextInactivationBatchTime",res.returnDate); 
                }
                component.set("v.hasUserClkOLFInactvatnEditBtn",false);
                helper.removeClasses(component,"masterGridChild4","slds-size_4-of-12;");
                helper.addClasses(component,"masterGridChild4","slds-size_3-of-12;"); 
                var spinner = component.find("spinnerModel");
                $A.util.addClass(spinner, "slds-hide");
                component.set("v.showWaringPopup",false);
            } 
            else { 
                helper.popToast(component,'Error','Something went wrong. Please try again later!');
            }
            
        }); 
        $A.enqueueAction(action);  
    },
    checkEditPermisnAndgetInactiveNextFireDt : function(component, event, helper){
        var action = component.get("c.getNextFireTimeOLFSInactivateSch");         
        action.setCallback(this, function(response) { 
            var state = response.getState();            
            if (state === "SUCCESS") { 
             let res = response.getReturnValue();
             component.set("v.setOlfInactiveDt",res.returnDateTime); 
             component.set("v.hasInactiveDateEditPermission",res.returnDateEditPermission);
            } 
        }); 
        $A.enqueueAction(action);  
    }
    //END | Surbhi | Date 2-Aug-2022 | PBI-1366142

})