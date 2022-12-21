({
    doInit : function(component, event, helper) {
        document.title='Sales Capture';
        helper.getAllSHTData(component, event, helper);  
    },
    picklistOnchange: function(component, event, helper) {
        helper.getPrice(component, event, helper);
    },
    searchEvents: function(component, event, helper) {
        
        if(event.getParams().keyCode == 13){
          //alert('Enter key pressed');
             helper.searchPlant(component, event, helper); 
        }
        //AdditionalFix_170797_28Aug2019_Soumyajit starts
        if(event.getParams().keyCode == 9){
            var customerId = component.get("v.lookupSoldToId");
            var customer = component.get("v.lookupSoldTo");
            var potype=component.get("v.poType");
			var plant=component.get("v.plant");
			var mrc=component.get("v.mrcNumber");
			var mot=component.get("v.mot"); 
            console.log('customer'+customer);
            if(customer == undefined){
                component.set("v.lookupSoldTo",'');
                component.set("v.lookupSoldToId",'');
                component.set("v.mrcNoList",[]);
                component.set("v.shipToList",[]);
                component.set("v.poTypeLst",[]);
                component.set("v.plantLst",[]);
                component.set("v.motLst",[]);
            }
           
        setTimeout(function(){
            component.find("ContractDate").focus();
        }, 100);
        }
        //AdditionalFix_170797_28Aug2019_Soumyajit ends
    },
    saveComment:function(component, event, helper) {
        var name = event.getSource().get("v.name");
        var cmpList= component.get("v.SHTCompList"); 
        var newComment;
        for(var i=0;i<cmpList.length;i++){
            if(cmpList[i].shtRecordId == name ){
                newComment=cmpList[i].Comment;
            }
        }
        var action = component.get("c.updateDealComment");
        action.setParams({ "shtId" : name,
                          "comment": newComment
                         });   
         action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                //CommentUpdateFix_10Jul2019_Soumyajit starts
                var status = response.getReturnValue();
                if(status === 'Success')
                //CommentUpdateFix_10Jul2019_Soumyajit ends
                	helper.displayToast(component,'Success','Comment Updated Successfully.');   
            }
            else{
                helper.displayToast(component,'ERROR','Internal Error.'); 
            } 
        });
        $A.enqueueAction(action);
    },
    getMoreFilters:function(component,event,helper){
        //START - Rahul Sharma | Date - 01-Feb-2021 | PBI-702438 : Moving logic to helper for reusability.
       /*var action=component.get('c.getSelAccountPOTypeMRC'); 
       helper.startSpinner(component,event,helper);
       action.setParams({ 
            "soldTo" : component.get("v.lookupSoldToId"),
            "poType" : component.get("v.poType")
       });
        action.setCallback(this, function(response) {
          var state = response.getState();
            if(state === 'SUCCESS'){
                helper.endSpinner(component,event,helper);
                if(response.getReturnValue() != null){
                    helper.setMrcMOTPlant(component,response.getReturnValue());
                }
            }  
        });
        $A.enqueueAction(action);*/
        helper.showFilterBasedOnPoType(component, event, helper);
        //END - Rahul Sharma | Date - 01-Feb-2021 | PBI-702438 : Moving logic to helper for reusability.
    },
    
    setCancelReason :function(component,event,helper){
        var label=component.find("ReasonId");
        if(label!=undefined && component.get("v.value")!=undefined)
        var reasonLabel=label.get("v.value");
        var data=component.get("v.cancelResaonMap");
        for(var r in data){
            if(data[r].label==reasonLabel){
				component.set("v.cancelCode",data[r].value);
            }
}  
    },
    resetMrc :function(component, event, helper) {
        component.set("v.mrcNumber",'');
        component.find("search").focus() ; 
    },

    setFocusOnSrchBtn:function(component, event, helper){
        if(event.keyCode == 9){
            setTimeout(function(){
                component.find("poType").focus();   //Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Changed focus to PO Type
            }, 100);
        }
    },
   
    resetSearchShipTo :function(component, event, helper) {
        var shipTo = component.get("v.lookupShipToNo");
        component.set("v.lookupSoldTo",'');
        component.set("v.lookupSoldToId",'');
        component.set("v.mrcNoList",[]);
        component.set("v.shipToList",[]);
        component.set("v.poTypeLst",[]);
        component.set("v.plantLst",[]);
        component.set("v.motLst",[]);
        //START - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Reset searched filter data.
        component.set("v.searchFilterWrap", '');    
        component.set("v.plant",'');
        component.set("v.mot",''); 
        //END - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Reset searched filter data.
        if(shipTo && shipTo.length >= 8){
            helper.getShipToMrcList(component, event, helper);
            if(event.keyCode == 9 || event.keyCode == 13){
                setTimeout(function(){
                    component.find("poType").focus();   //Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Changed focus to PO Type
                }, 100);
            }
        }
    },

    /*setFocusOnSearch :function(component, event, helper) {
        console.log('==');
        var mrcNo = component.get("v.lookupMRCNo");
        var shipTo = component.get("v.lookupShipToNo");
        var customer = component.get("v.lookupSoldToId");
        if(mrcNo != undefined){
            if(shipTo != undefined){
                component.set("v.lookupShipToNo",'');
            }
            if(customer != undefined){
                component.set("v.lookupSoldTo",'');
                component.set("v.lookupSoldToId",'');
                component.set("v.mrcNoList",[]);
                component.set("v.shipToList",[]);
                component.set("v.poTypeLst",[]);
                component.set("v.plantLst",[]);
                component.set("v.motLst",[]);
            }
        }
        /*
        //Fix_170797_02May2019_Soumyajit starts
        setTimeout(function(){
            component.find("ContractDate").focus();
        }, 100);
        //Fix_170797_02May2019_Soumyajit ends
        */
//    },

    resetMrcMot:function(component, event, helper) {
        component.set("v.mrcNumber",'');
        component.set("v.mot",''); 
        component.find("search").focus() ; 
    },
    resetPlantMot:function(component, event, helper) {
        component.set("v.plant",'');
        component.set("v.mot",''); 
        component.find("search").focus() ; 
    },
    resetPlantMrc:function(component, event, helper) {
        component.set("v.plant",'');
        component.set("v.mrcNumber",''); 
        component.find("search").focus() ; 
    },
    ChanelChange : function(component, event, helper) {
        var changeValue = event.getParam("value");
        if(changeValue.length>0){
            component.set("v.SalesChannel",changeValue);
            helper.getAllATPData(component, event, helper);
        }
        else{
            component.set("v.ATPWrapList",'');
        }   
    },
    doSearchSoldTo: function(component, event, helper){
        var soldTo=component.get("v.lookupSoldTo");
        if(event.getParams().keyCode != 13){//Fix_PBI_521711_Lakshmi_060220
        if(soldTo.length>3){
         var action = component.get("c.searchRecords");
            //action.setStorable();
            action.setParams({
                "soldTo": soldTo                
            }); 
            action.setCallback(this, function(a){
                var records = a.getReturnValue();
                component.set("v.matchedRecords",records);
            });
            $A.enqueueAction(action);    
        }
        }
        else{
            component.set("v.matchedRecords",[]);
            //Fix_PBI_521711_Lakshmi_060220_starts
          /*component.set("v.poTypeLst",[]);
            component.set("v.plantLst",[]);
            component.set("v.mrcNoList",[]);
            component.set("v.motLst",[]);
            component.set("v.poType",'');
            component.set("v.plant",'');
            component.set("v.mrcNumber",'');
            component.set("v.mrcNumber",'');
            component.set("v.mot",'');*/
            //Fix_PBI_521711_Lakshmi_060220_Ends
        }
        helper.addClass(component,"searchBox","showName"); 
        //Fix_PBI_521711_Lakshmi_060220_starts
        //AdditionalFix_170797_28Aug2019_Soumyajit starts
        if(event.getParams().keyCode == 9){
        setTimeout(function(){
            component.find("ContractDate").focus();
        }, 100);
        }
        //AdditionalFix_170797_28Aug2019_Soumyajit ends
        if(event.getParams().keyCode == 13){
            var key = event.getParams().keyCode;
             helper.searchPlant(component, event, helper); 
        }
        //Fix_PBI_521711_Lakshmi_060220_Ends
    },

    removeChosen: function(component, event, helper) {
        var soldTo= component.get("v.lookupSoldTo");
        //Fix_PBI_201967_Lakshmi_Starts
        if(soldTo && soldTo.length==0){
            component.set("v.lookupSoldTo","");
            component.set("v.matchedRecords",[]);
            component.set("v.lookupSoldToId",'');
            var blanklst=[];
            component.set("v.mrcNoList",blanklst);
            component.set("v.shipToList",blanklst);
            component.set("v.searchFilterWrap", '');
            component.set("v.lookupShipToNo", "");
        }
    },
    
    onGroup: function(component ,event ,helper) {
        var selected = event.getSource().get("v.text");
        component.set("v.selWindow",selected);
        helper.getAllATPData(component, selected);
    },
    setChosen: function(component, event, helper) {
        //Fix_PBI_521711_Lakshmi_060220_starts
        setTimeout(function(){
            component.find("soldToName").focus();
        }, 50);
        //Fix_PBI_521711_Lakshmi_060220_Ends
        var record = event.getParam('record');
        component.set("v.lookupSoldTo",record.Name);
        component.set("v.lookupSoldToId",record.Id);
        component.set("v.lookupMRCNo",'');
        component.set("v.lookupShipToNo",'');
        helper.removeClass(component,"searchBox","showName");
        if(record.Id != null || record.Id !=''){
            helper.getShipToMrcList(component, event, helper);
        }
    },
    validateDate :function(component, event, helper) {
        var dateInput=component.get("v.ContractEndDate");
        var text=dateInput;
        var first = dateInput.substring(0,2);
        var second = dateInput.substring(2,4);
        var third= dateInput.substring(4,8);
        var date=first+'.'+second+'.'+third;
        component.set("v.ContractEndDate",date);   
    },    
    getMaxDate:function(component,event,helper){
        var maxEndDate;
        var action = component.get("c.getMaxContractEndDate");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS'){
                maxEndDate=a.getReturnValue();
                component.set("v.ContractLastPossibleDate",maxEndDate);
                helper.setFormat(component, event, helper);
            }
        });
        $A.enqueueAction(action);

    },
    calculateDays: function(component, event, helper) {
        var dateInput=component.get("v.ContractStartDate");
        var dateTobePassed;
        var validError = false;
        var formatError = false;
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; 
        var yyyy = today.getFullYear();
        if(dd < 10){
            dd = '0' + dd;
        } 
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(dateInput.indexOf("-") >= 0){
            dateTobePassed=component.get("v.ContractStartDate");
        }
        else if(dateInput.length == 8 && !dateInput.includes('.')){
            var date =component.get("v.ContractStartDate");
            var first1 = date.substring(0,2);
            var second2 = date.substring(2,4);
            var third3= date.substring(4,8);
            var date1=third3+'-'+second2+'-'+first1;
            dateTobePassed = date1;
            component.set("v.ContractStartDate",dateTobePassed);  
        }
        else if(dateInput.length <= 8 ){
            validError = true;
            component.set("v.validDateError",true);
            formatError = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "INFO": "Required Format Missing!",
                "type":"ERROR",
                "message": "Please enter date format as [DD.MM.YYYY] OR [DDMMYYYY] ."
            });  
            toastEvent.fire();  
        }
        else{
                formatError = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "INFO": "Required Format Missing!",
                    "type":"ERROR",
                    "message": "Please enter date format as [DD.MM.YYYY] OR [DDMMYYYY] ."
                });  
                toastEvent.fire();   
         }
        
        if(!validError){
            var action=component.get("c.getContarctEndDate");
            action.setParams({
                "dateInput":dateTobePassed
            })
            action.setCallback(this, function(a) {
                var state = a.getState();
                if(state === 'SUCCESS'){
                    var name=a.getReturnValue();
                    component.set("v.ContractEndDate",name.conEndDate);
                    var diffDays=name.diffDays;
                    var maxDays=name.maxdiffDays; 
                    //Fix_211888_Soumyajit_17Apr2019 starts
                    //if(diffDays<=13 && diffDays>= -30){
                    if(diffDays<=14 && diffDays>= -30){
                    //Fix_211888_Soumyajit_17Apr2019 ends
                        component.set("v.TrancheValue",'ATP1');
                        component.set("v.validDateError",false);
                    }
                    //Fix_211888_Soumyajit_17Apr2019 starts
                    //else if(diffDays>13 && diffDays<=28 ){
                    else if(diffDays>14 && diffDays<=28 ){
                    //Fix_211888_Soumyajit_17Apr2019 ends
                         component.set("v.validDateError",false);
                        component.set("v.TrancheValue",'ATP2');      
                    }
                        else if(diffDays>28 && diffDays<=maxDays){
                             component.set("v.validDateError",false);
                            component.set("v.TrancheValue",'ATP3');       
                        }
                            else{
                                component.set("v.TrancheValue",'none');
                                component.set("v.validDateError",true);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "type" : "error",
                                    "message": "Please Select Valid Contract Start date"
                                });
                                toastEvent.fire();  
                            }
                    
                 //Fix_252970_30Apr2019_Soumyajit starts
                 //FixReverted_252970_07Aug2019_Soumyajit
                 //component.set("v.disableContractEndDate",name.disableConEndDate);
                 //Fix_252970_30Apr2019_Soumyajit ends
                    
                }
            });
            $A.enqueueAction(action);
        }else{
            if(!formatError){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "Please Select Contract Start Date Today Or Greater than Today's Date"
                });
                toastEvent.fire(); 
            }
        }
    },
    onChange: function(component, event, helper){
        helper.getMrcAtpSp(component, event, helper);
    },
    agoOnChange : function(component, event, helper){
        helper.getMrcAtpSp(component, event, helper);
    },
    igoOnChange :  function(component, event, helper){
        helper.getMrcAtpSp(component, event, helper);
    },
    mogasOnChange :  function(component, event, helper){
        helper.getMrcAtpSp(component, event, helper);
    },
    getPlantSHTData: function(component, event, helper) {
        helper.searchPlant(component, event, helper);  
    },
    cancelSelSavedDeal: function(component, event, helper) {
        component.set("v.selDeal","Saved");
        helper.cancelSellDeal(component, event, helper);
    },
    cancelSelCompDeal:function(component, event, helper) {
        var name = event.getSource().get("v.name");
        component.set("v.selDeal","Completed");
        var cmpList= component.get("v.SHTCompList"); 
        var callserver = true;
        for(var i=0;i<cmpList.length;i++){
            if(cmpList[i].shtRecordId == name && (cmpList[i].cancellationReason =='' || cmpList[i].cancellationReason == undefined)){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "ERROR": "ERROR!",
                    "type":"ERROR",
                    "message": "Please Select Reason for Cancellation!"
                });
                toastEvent.fire(); 
                callserver=false; 
            }
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "ERROR": "Warning!",
            "type":"Warning",
            "message": "This contract could already contain booked liftings in GSAP. Please consider checking the open contract volume in GSAP before cancelling this deal."
        });
        toastEvent.fire(); 
        
        if(callserver){
            helper.cancelSellDeal(component, event, helper);
        }
        
    },
    getCompletedSHT: function(component, event, helper) {
        helper.getCompCanDeal(component, event, helper);
    },
    ValidateSavedDate: function(component, event, helper) {
        var evt = event.getSource();
        var dateVal = evt.get("v.value");
        var isError = false;
        var message = '';
        if(dateVal.length == 8 && dateVal.includes('.')){
            isError = true;
            message = 'Please enter Valid Input Date in DD.MM.YYYY format';
        }
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; 
        var yyyy = today.getFullYear();
        if(dd < 10){
            dd = '0' + dd;
        } 
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(!isError && dateVal < todayFormattedDate){
            isError = true;
            message = 'Contract Start Date should be Today or Greater than Today';
        }
        if(isError){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": message
            });
            toastEvent.fire(); 
        }
    },
    validateSPValues: function(component, event, helper) {
        var evt = event.getSource();
        var priceVal = evt.get("v.value");
        var spVal =0;
        var index = 0;
        var allRows = component.get("v.MRCValues");
        for (var indexVar = 0; indexVar < allRows.length; indexVar++) {
            if (allRows[indexVar].pricePerVol == priceVal) {
                spVal = allRows[indexVar].spVal;
                index = indexVar;
                break;
            }
        }
        if(priceVal < spVal && priceVal != null ){
            $A.util.addClass(evt, 'putAlert');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "INFO": "Validation!",
                "type":"WARNING",
                "message": "Enterend Price should not be less than Selling Price."
            });
            toastEvent.fire();
        }else{
            $A.util.removeClass(evt, 'putAlert');
        }
    },
    validateSavedSPValues: function(component, event, helper) {
        var evt = event.getSource();
        var priceVal = evt.get("v.value");
        var spVal =0;
        var index = 0;
        var allRows = component.get("v.SHTSaveList");
        for (var indexVar = 0; indexVar < allRows.length; indexVar++) {
            if (allRows[indexVar].pricePerVol == priceVal) {
                spVal = allRows[indexVar].spVal;
                index = indexVar;
                break;
            }
        }
        if(priceVal < spVal){
            $A.util.addClass(evt, 'putAlert');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "INFO": "Validation!",
                "type":"WARNING",
                "message": "Enterend Price should not be less than Selling Price."
            });
            toastEvent.fire();
        }else{
            $A.util.removeClass(evt, 'putAlert');
        }
    },
    getSelectedName : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            alert("You selected: " + selectedRows[i].shtId);
        }
    },
    saveEnteredDeals:function(component, event, helper) {
        //Fix_207589_Soumyajit_17Apr2019 starts
        //Added to disable Save button immediately
        component.set("v.disableSaveonSerach",true);
        //Fix_207589_Soumyajit_17Apr2019 ends
        var data = component.get("v.MRCValues");
        var tranche = component.get("v.TrancheValue");
        var account=component.get("v.soldTo");
        var contractEndDate=component.get("v.ContractEndDate");
        if(contractEndDate.length == 8 && !contractEndDate.includes('.')){
            var date=contractEndDate;
            var first1 = date.substring(0,2);
            var second2 = date.substring(2,4);
            var third3= date.substring(4,8);
            var date1=third3+'-'+second2+'-'+first1;
            contractEndDate=date1;
        }
        var contractStartDate=component.get("v.ContractStartDate");
        if(contractStartDate.length == 8 && !contractStartDate.includes('.')){
            var date=contractStartDate;
            var first1 = date.substring(0,2);
            var second2 = date.substring(2,4);
            var third3= date.substring(4,8);
            var date1=third3+'-'+second2+'-'+first1;
            contractStartDate=date1;
        }
        var checkVal  = component.get('v.retailMix');
        //Price against Volume check
        var isError = false;
        var msg ='';
        var count=0;
        var  totalSize=data.length;
        for(var i=0;i<data.length;i++){
           
            if((data[i].volumeCBM == null || data[i].volumeCBM == '' || data[i].volumeCBM == undefined) &&
               (data[i].pricePerVol == null || data[i].pricePerVol == '' || data[i].pricePerVol == undefined )){
                count++;
            }
            if(data[i].volumeCBM != null){
                if((!data[i].isZeroPriceDeal) &&(data[i].pricePerVol == '' || data[i].pricePerVol == undefined)){
                    isError = true;msg='Please enter Price against Volume-'+data[i].volumeCBM+' for MRC NO '+data[i].mrcName;
                    break;
                }
            }
            //START - Rahul Sharma | Date - 09-Feb-2021 | PBI-702438 : Allowing zero price deal for TTTT.
            if(data[i].pricePerVol != null){
                if((data[i].volumeCBM == '' || data[i].volumeCBM == undefined) && !data[i].isZeroPriceDeal){
                    isError = true;msg='Please enter Volume against Price-'+data[i].pricePerVol+' for MRC NO '+data[i].mrcName;
                    break;
                }
            }
            //END - Rahul Sharma | Date - 09-Feb-2021 | PBI-702438 : Allowing zero price deal for TTTT.
            
        }
        if(count== totalSize){
            isError=true;
            msg='Please Enter Values for atleast one Deal before Saving!';
        }
        if(!isError){
            component.set("v.disableSaveonSerach",true);
            helper.startSpinner(component, event, helper); 
            var action=component.get('c.saveSHTObjectRecord'); 
            action.setParams({
                "dataList": JSON.stringify(data),
                "trancheVal":tranche,
                "account" : account,
                "salesType": "Obam Sales",
                "status" : "Saved" ,
                "contractStartDate" : contractStartDate ,
                "contractEndDate" : contractEndDate,
                "checked" : checkVal
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                
                if(state === "SUCCESS")
                {
                    var name = response.getReturnValue();
                    if(name != undefined){
                        if(name.savedResult != undefined && name.savedResult.length>0){
                            component.set("v.SHTSaveList",name.savedResult);
                            component.set("v.disableSaveonSerach",true);
                            component.set("v.MRCValues",[]);
                        }
                        else{
                             component.set("v.disableSaveonSerach",false);
                        }
                        
                    }  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": "SHT Record Created Successfully."
                    });
                    toastEvent.fire();   
                }
                else
                {
                    component.set("v.disableSaveonSerach",false);
                    var name = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"error",
                        "message": "Error while saving SHT Record ."
                    });
                    
                    toastEvent.fire(); 
                }
                helper.endSpinner(component, event, helper); 
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type":"error",
                "message": msg
            });
            toastEvent.fire();
        }
    },
    saveSavedDeals:function(component, event, helper) {
       var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; 
        var yyyy = today.getFullYear();
        if(dd < 10){
            dd = '0' + dd;
        } 
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        var maxDate = new Date(today);  
        maxDate.setDate(maxDate.getDate() + 61);
        var dd1 = maxDate.getDate();
        var mm1 = maxDate.getMonth() + 1;
        var yyyy1 = maxDate.getFullYear();
        if(dd1 < 10){
            dd1 = '0' + dd1;
        } 
        if(mm1 < 10){
            mm1 = '0' + mm1;
        }
        var maxFormattedDate = yyyy1+'-'+mm1+'-'+dd1;
        var isErrorV = false;
        var isErrorP = false;
        var isErrorS = false;
        var isErrorE = false; 
        var data = component.get("v.SHTSaveList");
        var selLst=[];
        var dateLst=[];
        var enddateLst=[];
        var priceLst=[];
        var volumeLst=[];
        var msg='';
        for(var i=0;i<data.length;i++){
            if(data[i].selected == true){
                selLst.push(data[i]);
            }
        }
        if(selLst.length>0){
            for(var i=0;i<data.length;i++){
                if(data[i].selected == true){
                    if(data[i].contractStartDate.length==8){
                        var date=data[i].contractStartDate;
                        var first1 = date.substring(0,2);
                        var second2 = date.substring(2,4);
                        var third3= date.substring(4,8);
                        var date1=third3+'-'+second2+'-'+first1;
                        data[i].contractStartDate=date1;
                        dateLst.push(date1);
                    }else{
                        dateLst.push(data[i].contractStartDate);
                    }
                    
                    if(data[i].contractEndDate.length==8){
                        var date=data[i].contractEndDate;
                        var first1 = date.substring(0,2);
                        var second2 = date.substring(2,4);
                        var third3= date.substring(4,8);
                        var date1=third3+'-'+second2+'-'+first1;
                        data[i].contractEndDate=date1;
                        enddateLst.push(date1);
                    }else{
                        enddateLst.push(data[i].contractEndDate);
                    }
                    if(!data[i].isZeroPriceDeal){
                        priceLst.push(data[i].spPer100L);
                    }
                    
                    volumeLst.push(data[i].volCbm);
                }
            }
            if(volumeLst.length>0){
                for(var i=0;i<volumeLst.length;i++){
                    if(volumeLst[i] == '' || volumeLst[i] == undefined){
                        component.set("v.validPriceError",true);
                        msg = "Volume enterd should not be blank for selected row."
                        isErrorV = true;
                        break;
                    }else{
                        component.set("v.validPriceError",false);
                        isErrorV = false;
                    }
                }
            }
            if(!isErrorV && priceLst.length>0){
                for(var i=0;i<priceLst.length;i++){
                    if(priceLst[i] == '' || priceLst[i] == undefined){
                        component.set("v.validPriceError",true);
                        msg = "Price enterd should not be blank for selected row."
                        isErrorP = true;
                        break;
                    }else{
                        component.set("v.validPriceError",false);
                        isErrorP = false;
                    }
                }
            }
            /*
            if(!isErrorV && !isErrorP && dateLst.length>0){
                for(var i=0;i<dateLst.length;i++){
                    if(dateLst[i] < todayFormattedDate){
                        component.set("v.validDateSaveError",true);
                        isErrorS = true;
                        msg = "Contract Start Date should be Today or Greater than Today."
                        break;
                    }else{
                        component.set("v.validDateSaveError",false);
                        isErrorS = false;
                    }
                }
            }
            if(!isErrorV && !isErrorP && !isErrorS && enddateLst.length>0){
                for(var i=0;i<enddateLst.length;i++){
                    if(enddateLst[i] > maxFormattedDate || enddateLst[i] < dateLst[i]){
                        component.set("v.validEndDateSaveError",true);
                        msg = "Contract End Date must be less than 61 days from today and Greater than Start Date."
                        isErrorE = true;
                        break;
                    }else{
                        component.set("v.validEndDateSaveError",false);
                        isErrorE = false;
                    }
                }
            }
            */
            var validError = false;
            if(isErrorV || isErrorP ||  isErrorS || isErrorE){
                validError = true;
                component.set("v.validSaveError",true);
            }else{
                validError = false;
                component.set("v.validSaveError",false);
            }
            if( !validError ){
                helper.startSpinner(component, event, helper); 
                var action=component.get('c.updateSHTObjectRecord'); 
                action.setParams({
                    "dataList": JSON.stringify(data)
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS")
                    {
                        helper.endSpinner(component, event, helper); 
                        var name=response.getReturnValue();
                        if(name != undefined && name.length>0){
                            component.set("v.SHTCompList",name);
                        }
                        var savelist= component.get("v.SHTSaveList");
                        var cmpList=  component.get("v.SHTCompList");
                        var newSaveLst=[];
                        var updatedSavedList=[];
                        var updatedCompList=[];
                        for(var i=0;i<savelist.length;i++){
                            if(savelist[i].selected){
                                if(savelist[i].volCbm != undefined){
                                    newSaveLst.push(savelist[i]);
                                }
                            }
                        }
                        for(var j=0;j<savelist.length;j++){
                            for(var i=0;i<newSaveLst.length;i++){ 
                                if(newSaveLst[i].shtRecordId == savelist[j].shtRecordId){
                                    savelist.splice(j, 1);
                                }
                            } 
                        }
                        if(savelist.length >0){
                            component.set("v.disableSaveonSerach",true);
                        }else{
                             component.set("v.disableSaveonSerach",false);
                        }
                        component.set("v.SHTSaveList",savelist);
                        
                        //Fix_170853_13May2019_Soumyajit starts
                        component.set("v.UseAdvanceFilter",false);
                        //Fix_170853_13May2019_Soumyajit ends
                        
                        component.set("v.interval","TODAY");
                        component.set("v.status","Completed");
                        component.set("v.createdBy","Me");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type":"success",
                            "message": "SHT Record Updated Successfully."
                        });
                        toastEvent.fire(); 
                        component.set("v.MRCValues",[]);
                        component.set("v.lookupMRCNo",'');
                        component.set("v.lookupShipToNo",'');
                        component.set("v.lookupSoldTo",'');
                        component.set("v.lookupSoldToId",'');
                        component.set("v.shipTo",'');
                        component.set("v.mrcNumber",'');
                        component.set("v.ContractStartDate",component.get("v.ClonedContractStartDate"));
                        component.set("v.ContractEndDate",component.get("v.ClonedContractEndDate"));
                        component.set("v.TrancheValue","ATP1");
                        component.set("v.mrcNoList",[]);
                        component.set("v.shipToList",[]);
                        component.set("v.disableRetMix",false);
                        component.set("v.poType",'');
                        component.set("v.plant",'');
                        component.set("v.mot",'');
                        component.set("v.poTypeLst",[]);
                        component.set("v.plantLst",[]);
                        component.set("v.motLst",[]);
                    }
                    else
                    {
                         helper.endSpinner(component, event, helper); 
                        var name = response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type":"error",
                            "message": "Error while saving SHT Record ."
                        });
                        toastEvent.fire(); 
                        
                    }
                });
                $A.enqueueAction(action);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": msg
                });
                toastEvent.fire(); 
            }
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type":"error",
                "message": "Please select deals to confrim."
            });
            toastEvent.fire(); 
        }
        component.set("v.isSPConfirmOpen", false);	//Fix_329724_10Oct2019_Soumyajit
    },
    showSpinner: function(component, event, helper) {
        helper.startSpinner(component, event, helper);  
    },
    hideSpinner: function(component, event, helper) {
        helper.endSpinner(component, event, helper);
    },
    //Fix_170853_13May2019_Soumyajit starts
    storeOldSelectFilters: function(component, event, helper) {
        component.set("v.OldSelectCreatedStartDate",component.get("v.SelectCreatedStartDate"));
        component.set("v.OldSelectCreatedEndDate",component.get("v.SelectCreatedEndDate"));
        component.set("v.OldSelectCreatedBy",component.get("v.createdBy"));
        component.set("v.OldSelectStatus",component.get("v.status"));
        component.set("v.OldSelectSoldTo",component.get("v.SelectSoldTo"));
        component.set("v.OldInternetSales",component.get("v.InternetSales")); //270192_OLFDealCancel_08Jul2019_Soumyajit
        component.set("v.oldSelectedPoTypeAdv", component.get("v.selectedPoTypeAdv"));  //Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : adding olf list of PO Types.
    },

    showAdvanceFilters: function(component, event, helper) {
       if(component.get("v.UseAdvanceFilter"))
       { 
           if(component.get("v.AdvanceFilterFirstTimeCheck"))
           {
               helper.getCreatedByList(component, event, helper);
               component.set("v.AdvanceFilterFirstTimeCheck",false);
           }
           
           helper.createdDateValidate(component, event, helper);

           if (!component.get("v.startDateValidationError") && !component.get("v.endDateValidationError"))
           		helper.getAdvanceFiltersList(component, event, helper);
       }
       else
       {
            component.set("v.SelectCreatedStartDate","");
            component.set("v.interval","TODAY");
            component.set("v.createdBy","Me");
            component.set("v.status","Completed");
            component.set("v.AdvanceFilterFirstTimeCheck",true);
           	component.set("v.InternetSales",false); //270192_OLFDealCancel_08Jul2019_Soumyajit
            component.set("v.InternetSales",false);
            helper.getCompCanDeal(component, event, helper);
       }    	
    },
    //Fix_170853_13May2019_Soumyajit ends
    
    //Fix_329724_10Oct2019_Soumyajit starts
    openSPConfirmPopUp: function(component, event, helper) 
    {
        var shtSaveData = component.get("v.SHTSaveList");
        var spCheckErrData=[];
        var ConfirmSkipMaterials = component.get("v.ConfirmSkipMaterials").split(";");	//AdditionalFix_329724_25Nov2019_Soumyajit
        
        for(var i=0;i<shtSaveData.length;i++)
        {
            if(shtSaveData[i].spPer100L != '' && shtSaveData[i].spPer100L != undefined
              && shtSaveData[i].msp != '' && shtSaveData[i].msp != undefined)
            {
                if(Number(shtSaveData[i].spPer100L) < Number(shtSaveData[i].msp)
                  && !(ConfirmSkipMaterials.indexOf(shtSaveData[i].materialNo) > -1)	//AdditionalFix_329724_25Nov2019_Soumyajit
                  )
                	spCheckErrData.push(shtSaveData[i]);
            }
        }
        
        if(spCheckErrData.length >0)
        {
        	component.set("v.SHTConfirmSavedList",spCheckErrData);
      	  	component.set("v.isSPConfirmOpen", true);
        }
        else
        {
            component.set("v.isSPConfirmOpen", false);
            $A.enqueueAction(component.get('c.saveSavedDeals'));
        }
      
    },
       
  	closeSPConfirmPopUp: function(component, event, helper) 
    {
      component.set("v.isSPConfirmOpen", false);
   	},
    //Fix_329724_10Oct2019_Soumyajit ends
    
     /*Method Name   : searchShipToAccs
     *Date          : 02-Feb-2021
     *Developer     : Rahul Sharma
     *PBI           : 702438
     *Description   : Search accounts based on Ship-To number.
     */
    searchShipToAccs : function(component, event, helper){
        var shipToNum = component.get("v.lookupShipToNo");
        if(event.getParams().keyCode == 13){
            helper.getShipToMrcList(component, event, helper);
        }
        if(event.getParams().keyCode == 9){
            setTimeout(function(){
                component.find("poType").focus();
            }, 100);
        }
    }
})