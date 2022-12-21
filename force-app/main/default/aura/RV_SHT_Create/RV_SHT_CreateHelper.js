({
    getAllSHTData:function(component, event, helper) {
        var interval=[];
        interval.push({"class": "optionClass",label: "TODAY",value: "TODAY", selected: "true"},
                      //Fix_170853_13May2019_Soumyajit starts
                      //{"class": "optionClass",label: "YESTERDAY",value: "YESTERDAY"},
                      {"class": "optionClass",label: "LAST DEAL DATE",value: "LAST_DEAL_DATE"},
                      //Fix_170853_13May2019_Soumyajit ends
                      {"class": "optionClass",label: "THIS WEEK",value: "THIS_WEEK"},
                      {"class": "optionClass",label: "LAST WEEK",value: "LAST_WEEK"}
                      //Fix_170853_13May2019_Soumyajit starts
                      ,{"class": "optionClass",label: "LAST 3 WEEKS",value: "LAST_3_WEEKS"}
                      //Fix_170853_13May2019_Soumyajit ends
                     );
        component.set("v.intervalList",interval); 
        var status=[];
        status.push({"class": "optionClass",label: "COMPLETED",value: "Completed", selected: "true"},
                    
                    {"class": "optionClass",label: "CANCELLED",value: "Cancelled"},
                    {"class": "optionClass",label: "EXPIRED",value: "Expired"}
                    );
        component.set("v.statusList",status); 
        
        var usersLst=[];
        usersLst.push({"class": "optionClass",label: "ME",value: "Me", selected: "true"},
                      {"class": "optionClass",label: "ALL",value: "All"}
                      
                    );
        component.set("v.userList",usersLst); 
        //Fix_170853_13May2019_Soumyajit starts
        component.set("v.UseAdvanceFilter",false);
        //Fix_170853_13May2019_Soumyajit ends
       // helper.startSpinner(component, event, helper);  
        var action = component.get("c.getAllSHTDeals");
        action.setCallback(this, function(a) {
        
            var state = a.getState();
            if(state === 'SUCCESS'){
                
                 //Tranche Picklist Values
                var tranche=[];
                tranche.push(
                          {"class": "optionClass",label: "Tranche1",value: "ATP1"},
                          {"class": "optionClass",label: "Tranche2",value: "ATP2"},
                          {"class": "optionClass",label: "Tranche3",value: "ATP3"}
                         );
                component.set("v.trancheList",tranche);
                //Interval Picklsit Values
                var interval=[];
                interval.push({"class": "optionClass",label: "TODAY",value: "TODAY", selected: "true"},
                          	//Fix_170853_13May2019_Soumyajit starts
                      		//{"class": "optionClass",label: "YESTERDAY",value: "YESTERDAY"},
                      		{"class": "optionClass",label: "LAST DEAL DATE",value: "LAST_DEAL_DATE"},
                      		//Fix_170853_13May2019_Soumyajit ends
                          {"class": "optionClass",label: "THIS WEEK",value: "THIS_WEEK"},
                          {"class": "optionClass",label: "LAST WEEK",value: "LAST_WEEK"}
                          //Fix_170853_13May2019_Soumyajit starts
                      	  ,{"class": "optionClass",label: "LAST 3 WEEKS",value: "LAST_3_WEEKS"}
                          //Fix_170853_13May2019_Soumyajit ends
                         );
                component.set("v.intervalList",interval);
                
                //SHT Completed List
                var shtCmpLst=a.getReturnValue().CompletedDeal;
                if(shtCmpLst != undefined && shtCmpLst.length >0){
                    component.set("v.SHTCompList",shtCmpLst);
                }
                //Cancellation Reason Picklist Values
                
                var reasonlst = a.getReturnValue().reasonList;
                if(reasonlst != undefined && reasonlst.length >0){
                     var reason=[];
                     reason.push({"class": "optionClass",label: "--Select--",value: ""});
                    for(var i=0;i< reasonlst.length;i++){
                        reason.push({"class": "optionClass", label: reasonlst[i], value: reasonlst[i]});
                    }
                    component.set("v.reasonList", reason);
                }
                //SHT saved List
                var shtSaveLst=a.getReturnValue().savedDeal;
               // console.log("saved deal==>"+JSON.stringify(a.getReturnValue().savedDeal));
                if(shtSaveLst != undefined && shtSaveLst.length >0){
                    component.set("v.SHTSaveList",shtSaveLst);
                    component.set("v.disableSaveonSerach",true);
                }
                //SHT Contract Start Date
                var startDate = a.getReturnValue().ContractStartDate;
                component.set("v.ContractStartDate",startDate);
                component.set("v.ClonedContractStartDate",startDate);
				
                var endDate = a.getReturnValue().ContractEndDate;
                component.set("v.ContractEndDate",endDate);
                component.set("v.ClonedContractEndDate",endDate);
             //   helper.endSpinner(component, event, helper);  
             
                //AdditionalFix_166256_29Apr2019_Soumyajit starts
                if (a.getReturnValue().hasEditAccess === false)
                {
                    component.set("v.disableSaveonSerach",true);
                    component.set("v.disableCancelOnSearch",true);
                    component.set("v.disableConfirmOnSearch",true);
                    component.set("v.disableCommentOnConfirmedDeals",true);
                    component.set("v.disableCancelOnConfirmedDeals",true);
                    helper.displayToast(component, 'Warning','You do not have permission to Save or Cancel Deals!' );
                }
                //AdditionalFix_166256_29Apr2019_Soumyajit ends
            }
        });
        $A.enqueueAction(action);  
		      
    },
    searchPlant:function(component, event, helper){
        var iserror = component.get("v.validDateError");
        if(!iserror){
        	helper.getMrcAtpSp(component, event, helper);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": "Please Select Contract Start Date Today Or Greater than Today's Date"
            });
            toastEvent.fire();
        }
    },
    getSavedSHT: function(component, event, helper) {
        
        var action = component.get("c.getSavedSHTDeal");
           
        action.setCallback(this, function(a) {
            var state = a.getState();
            
            if(state === 'SUCCESS'){
                component.set("v.SHTSaveList",a.getReturnValue());
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getMrcAtpSp: function(component, event, helper){      
        var Mrcno=component.get("v.lookupMRCNo");
        var tranche=component.get("v.TrancheValue");
        var accnt=component.get("v.lookupSoldToId");
        var shipto=component.get("v.lookupShipToNo");
        if(accnt != undefined && accnt.length>0 ){
            shipto=component.get("v.shipTo");
            Mrcno=component.get("v.mrcNumber");
        }
        if(component.get("v.mrcNumber") != ''){
            accnt='';
        }
        var callServer = true;
        var checkVal  = component.get('v.retailMix');
        var agoChk=component.get('v.showAGO');
        var igoChk=component.get('v.showIGO');
        var mogasChk=component.get('v.showMOGAS');   
        if( (Mrcno =='' || Mrcno === undefined) && (accnt =='' || accnt === undefined ) && (shipto =='' || shipto === undefined )  ){
            callServer = false;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "INFO": "Required Field Missing!",
                "type":"ERROR",
                "message": "Please [ MRC Number ] OR [Customer] OR [Ship To ] ."
            });  
            toastEvent.fire();   
            component.set("v.MRCValues",[]);
        }
        //START - Rahul Sharma | Date - 12-Mar-2021 | PBI-752044 : Added additional condition to avoid search for invalid ShipTo/MRC number.
        if(shipto && (shipto.length < 8 || !component.get("v.poType"))){
           callServer = false;
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({"type":"error",
                                 "message": "Please enter a valid Ship-To number.."
           });  
           toastEvent.fire();
           component.set("v.MRCValues",[]);
    	}
        if(Mrcno && Mrcno.length < 9){
            callServer = false;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "message": "Please enter a valid MRC number.."
            });  
            toastEvent.fire();
            component.set("v.MRCValues",[]);
        }
        //END - Rahul Sharma | Date - 12-Mar-2021 | PBI-752044 : Added additional condition to avoid search for invalid ShipTo/MRC number.
        if(callServer){
            helper.startSpinner(component, event, helper); 
            var action = component.get('c.getMrcData');
            action.setParams({ "tranche" : tranche,
                              "Mrcno" : Mrcno,
                              "accId" : accnt,
                              "shipto" :shipto,
                              "checked":checkVal,
                              "agoChk" :agoChk ,
                              "igoChk" : igoChk,
                              "mogasChk" :mogasChk,
                              "poType" :component.get("v.poType"),
                              "plant":component.get("v.plant"),
                              "mot":component.get("v.mot"),
                              "contractStartDate" : component.get("v.ContractStartDate"),
                              "contractEndDate" : component.get("v.ContractEndDate"),
                              "callFromOlf" : false,
                              //START - Rahul Sharma | Date - 21-Jul-2020 : Adding additional check to filter OLF deals
                              "OLFOnly" :component.get("v.OLFOnly")
                              //END - Rahul Sharma | Date - 21-Jul-2020 : Adding additional check to filter OLF deals
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    helper.endSpinner(component, event, helper);
                    if(response.getReturnValue() != null){  
                       var searchrslt = response.getReturnValue();
                        if(searchrslt.length>0){
                            component.set("v.MRCValues", searchrslt);
                            //START - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Added list of customer returned based on Ship-To number search.
                            var accNames = [];
                            var accNameSet = [];
                            for(var i=0; i < searchrslt.length; i++){
                                accNames.push(searchrslt[i].accName);
                            } 
                            accNameSet = helper.getUniqueList(accNames);
                            component.set("v.customerNames", accNameSet.toString());
                            //END - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Added list of customer returned based on Ship-To number search.
                        }
                        else{
                             helper.displayToast(component, 'ERROR','No Results Found' );
                        }
                   }
                   else{ 
                        component.set("v.MRCValues",[]);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "INFO": "Record Not Found!",
                            "type":"ERROR",
                            "message": "MRC Record does not exist for the search criteria."
                        });
                        
                        toastEvent.fire(); 
                    }
                }
                else{
                    component.set("v.MRCValues",[]);
                     helper.endSpinner(component, event, helper);
                     helper.displayToast(component, 'ERROR','Error while searching' );
                }
                
            });
            $A.enqueueAction(action);
        }      
    },

    //START - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Updated method logic to search MRCs based on either Ship-To number or Sold-To Name.
    getShipToMrcList : function(component, event, helper) {
        var acctId=  component.get("v.lookupSoldToId");
        var action = component.get('c.searchDependentShipToMRC');
        var shipToNum = component.get("v.lookupShipToNo");
        action.setParams({ 
            "acctId" : acctId,
            "shipToNum" : shipToNum  
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() != null){
                    component.set("v.searchFilterWrap", response.getReturnValue());
                    var mrcVsPoTypeMap = response.getReturnValue().mrcNoVsPoTypeMap
                    if(mrcVsPoTypeMap){
                        var poTypeList = [];
                        let tempPoTypeList = [];
                        for(var mrcNo in mrcVsPoTypeMap){
                            if(poTypeList.length > 0){
                                if(mrcVsPoTypeMap[mrcNo] == 'TSFP')
                                    poTypeList.unshift({"class": "optionClass", label: mrcVsPoTypeMap[mrcNo], value: mrcVsPoTypeMap[mrcNo]});
                                else
                                    poTypeList.push({"class": "optionClass", label: mrcVsPoTypeMap[mrcNo], value: mrcVsPoTypeMap[mrcNo]});
                            }    
                            else if(poTypeList.length <= 0 || !poTypeList){
                                poTypeList.push({"class": "optionClass", label: mrcVsPoTypeMap[mrcNo], value: mrcVsPoTypeMap[mrcNo]});
                            }
                        }
                        if(poTypeList && poTypeList.length > 0){
                            var poTypeSet = helper.getUniqueListBy(poTypeList, 'label');
                            component.set("v.poType", poTypeList[0].value);
                            component.set("v.poTypeLst", poTypeSet);
                            helper.showFilterBasedOnPoType(component, event, helper);
                        }
                        else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "INFO": "Record Not Found!",
                                "type":"ERROR",
                                "message": "No Customer(s) found for the selected Ship-To Number."
                            });
                            
                            toastEvent.fire(); 
                        }
                    }
                    /*var singlePoType=false;
                    if(response.getReturnValue().poTypeLst.length > 0){
                        //Po Type Values
                        var poTypeLst=[];
                        var poType = response.getReturnValue().poTypeLst;
                        if(poType.length==1){
                            poTypeLst.push({"class": "optionClass", label: poType[0], value: poType[0]}); 
                            component.set("v.poType",poType[0]);
                            //singlePoType=true;
                        }
                        else{
                            //poTypeLst.push({"class": "optionClass",label: "----Select----",value: ""});
                            for(var i=0;i< poType.length;i++){
                                if(poType[i] == 'TSFP')
                                   poTypeLst.unshift({"class": "optionClass", label: poType[i], value: poType[i]});
                                else
                                    poTypeLst.push({"class": "optionClass", label: poType[i], value: poType[i]});   
                            }
                        }       
                        component.set("v.poTypeLst", poTypeLst);  
                        if(poTypeLst)
                            component.set("v.poType", poTypeLst[0].value);                      
                    }
                    if(singlePoType){
                        helper.setMrcMOTPlant(component,response.getReturnValue());
                    } 
                    helperhelper.showFilterBasedOnPoType(component, event, helper);*/
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "INFO": "Record Not Found!",
                        "type":"ERROR",
                        "message": "No Customer(s) found for the selected Ship-To Number."
                    });
                    
                    toastEvent.fire(); 
                }
            }
        });
        $A.enqueueAction(action);
    },
    //END - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Updated method logic to search MRCs based on either Ship-To number or Sold-To Name.

    //START - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Commenting obsolete method.
    /*setMrcMOTPlant: function(component,returnVal){
        if(returnVal.mrcLst.length >0){
            var accMrcNo=[];
            var mrcValuesAcc = returnVal.mrcLst;
            accMrcNo.push({"class": "optionClass",label: "--Select--",value: ""});
            for(var i=0;i< mrcValuesAcc.length;i++){
                accMrcNo.push({"class": "optionClass", label: mrcValuesAcc[i], value: mrcValuesAcc[i]});
            }
            component.set("v.mrcNoList", accMrcNo);
        }
        else{
           component.set("v.mrcNoList",[]);
        }
        if(returnVal.plantLst.length >0){
            var plant=[];
            var plantLst = returnVal.plantLst;
            plant.push({"class": "optionClass",label: "--Select--",value: ""});
            for(var i=0;i< plantLst.length;i++){
                plant.push({"class": "optionClass", label: plantLst[i], value: plantLst[i]});
            }
            component.set("v.plantLst", plant);
        }
        else{
            component.set("v.plantLst",[]);
        }
        if(returnVal.motLst.length >0){
            var mot=[];
            var motLt = returnVal.motLst;
            mot.push({"class": "optionClass",label: "--Select--",value: ""});
            for(var i=0;i< mrcValuesAcc.length;i++){
                mot.push({"class": "optionClass", label: motLt[i], value: motLt[i]});
            }
            component.set("v.motLst", mot);
        }
        else{
             component.set("v.motLst", []);
        }
    },*/
    //END - Rahul Sharma | Date - 04-Feb-2021 | PBI-702438 : Commenting obsolete method.

    setFormat : function(component, event, helper) {
        var dateInput=component.get("v.ContractEndDate");
        var dateStart=component.get("v.ContractStartDate");
        var validError = false;
        var maxFormattedDate;        
        maxFormattedDate=component.get("v.ContractLastPossibleDate");
        console.log('maxFormattedDate==>'+maxFormattedDate);
        if(dateInput.indexOf("-") >= 0){
            if(dateInput <dateStart || dateInput > maxFormattedDate){
                validError = true;
                component.set("v.validDateError",true);
            }else{
                validError = false;
                component.set("v.validDateError",false);
            }
        }
        else if(dateInput.length == 8 && !dateInput.includes('.')){
			//FIX_PBI_281710_19Jun2019_Lakshmi_Starts
			var first1 = dateInput.substring(0,2);
            var second2 = dateInput.substring(2,4);
            var third3= dateInput.substring(4,8);
            var date1=third3+'-'+second2+'-'+first1;
            var dateTobePassed = date1;
            component.set("v.ContractEndDate",dateTobePassed); 
            var dateInput=component.get("v.ContractEndDate");
            //FIX_PBI_281710_19Jun2019_Lakshmi_Ends
            if(dateInput < dateStart || dateInput > maxFormattedDate){
                validError = true;
                component.set("v.validDateError",true);
            }else{
                validError = false;
                component.set("v.validDateError",false);
            }
        }else if(dateInput.length <= 8 ){
            
            validError = true;
            component.set("v.validDateError",true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "INFO": "Required Format Missing!",
                "type":"ERROR",
                "message": "Please enter date format as [DD.MM.YYYY] OR [DDMMYYYY] ."
            });  
            toastEvent.fire();  
        }
            else{
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "INFO": "Required Format Missing!",
                    "type":"ERROR",
                    "message": "Please enter date format as [DD.MM.YYYY] OR [DDMMYYYY] ."
                });  
                toastEvent.fire(); 
                
            }
        if(validError){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": "Contract End Date should be Greater than Contract Start Date and within M+15 from Today's Date"
            });
            toastEvent.fire(); 
        }
    },
    addClass: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.addClass(modal,className);
    },
    removeClass: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.removeClass(modal,className);
    },
    cancelSellDeal : function(component, event, helper) { 
        var name = event.getSource().get("v.name");
        var selDeal= component.get("v.selDeal");
        var reason ;
        var searchResult=component.get("v.MRCValues");
        //searchList
        if(selDeal== "Completed"){
            var cmpList= component.get("v.SHTCompList"); 
            for(var i=0;i<cmpList.length;i++){
                if(cmpList[i].shtRecordId == name ){
                    reason=cmpList[i].cancellationReason;
                }
            }
        }
        var action = component.get("c.cancelSHTDeal");
        action.setParams({ "shtId" : name,
                          "status": selDeal,
                          "reason" : reason,
                          "code":component.get("v.cancelCode"),
                          "searchList" : JSON.stringify(searchResult)
                         });            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var ret=response.getReturnValue();
                var msg;
                
                if(ret != undefined){
                    
                   
                    if(ret.searchResult != undefined && ret.searchResult.length>0){
                        component.set("v.MRCValues",ret.searchResult);
                    }
                    else{
                        component.set("v.MRCValues",[]);
                    }
                   
                    if(ret.savedResult != undefined && ret.savedResult.length>0){
                        component.set("v.SHTCompList",ret.savedResult);
                    }
                    else{
                        component.set("v.SHTCompList",[]);
                        
                        
                    }
                    if(ret.cancelMsg != undefined ){
                        msg=ret.cancelMsg;
                    }
                }
                
                
                component.set("v.interval","TODAY");
                component.set("v.createdBy","Me");
                component.set("v.status","Completed"); 
                //Fix_170853_13May2019_Soumyajit starts
                component.set("v.UseAdvanceFilter",false);
                //Fix_170853_13May2019_Soumyajit ends
                if(selDeal== "Completed"){
                    
                    helper.displayToast(component, 'Success','Completed Deal Cancelled Successfully!' );
                }
                else if(selDeal== "Auto-Completed"){
                    helper.displayToast(component, 'Success','Auto-Completed Deal Cancelled Successfully!' );
                }
                    else{
                        
                        var saveLst= component.get("v.SHTSaveList");
                        for(var i=0;i<saveLst.length;i++){
                            if(saveLst[i].shtRecordId == name){  
                                saveLst.splice(i, 1);
                            }
                        }
                        if(saveLst.length>0){
                            component.set("v.disableSaveonSerach",true);
                        }else{
                            component.set("v.disableSaveonSerach",false);
                        }
                        component.set("v.SHTSaveList",saveLst);
                        if(msg=='Completed'){
                            helper.displayToast(component, 'Success','Saved Deal Cancelled Successfully!' );
                        }
                        else if(msg=='Auto-Completed'){
                            helper.displayToast(component, 'ERROR','This Deal is Auto-Completed.Please Cancel it from Completed Section' );
                        }  
                        
                    }
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "ERROR": "Record Not Found!",
                    "type":"ERROR",
                    "message": "Internal Error."
                });
                toastEvent.fire(); 
            }
            
        });
        $A.enqueueAction(action);
        
    },
    getPrice : function(component, event, helper) {
        var loc = component.find('locationSelect').get('v.value');
        var grade= component.find('gradeSelect').get('v.value');
        if( loc=='' || loc=='none' || grade=='' || grade=='none' ){ 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "message": "Please select all required values of Location and Product"
            });
            toastEvent.fire();
            
        }
         else{
           
            // Call Backend and get price & Volume Available
         }
    },
    getAllSHTList:function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Product', fieldName: 'product', type: 'text' },
            {label: 'Location', fieldName:'location', type: 'text' },
            {label: 'Quantity CBM', fieldName: 'quantityCBM', type: 'number'},
            {label: 'Contract Start', fieldName: 'contractDate', type: 'text'},
            {label: 'Lifting Window', fieldName: 'liftWindow', type: 'currency'}
        ]); 
        
        var action = component.get("c.getSavedSHTvalues");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS'){
                component.set("v.SHTList",a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },
    getGradeValuesList : function(component, event, helper) {
        var opts=[];
        var retrieveOptions = component.get("c.getGradeValuesList");
        
        retrieveOptions.setCallback(this,function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({"class": "optionClass",label: "-Select-",value: ""});
                    for(var i=0;i< allValues.length;i++){
                        opts.push({"class": "optionClass", label: allValues[i].Name, value: allValues[i].Id});
                    }
                    component.set("v.gradeList", opts);
                }
            }    
        });
        $A.enqueueAction(retrieveOptions);
    },
    getCompCanDeal : function(component, event, helper) {    
        var interval=component.find('interval').get('v.value');
        var status= component.get("v.status");
        var createdby=component.get("v.createdBy");
        var action = component.get("c.getCompletedSHTDeal");
        //Fix_170853_13May2019_Soumyajit starts
		helper.startSpinner(component,event,helper);
        //Fix_170853_13May2019_Soumyajit ends
        action.setParams({
            "day":interval,
            "status" : status,
            "createdby" :createdby
        });    
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS'){
                component.set("v.SHTCompList",a.getReturnValue());
                
            }
            //Fix_170853_13May2019_Soumyajit starts
			helper.endSpinner(component,event,helper);
        	//Fix_170853_13May2019_Soumyajit ends   
        });
        $A.enqueueAction(action);
    },
    addHideremoveOpen : function(component,componentId,backdropId,className) {
        var modal = component.find(componentId);
        $A.util.removeClass(modal,className);
        $A.util.addClass(modal,"slds-fade-in-open"); 
        var modalBckdrop = component.find(backdropId);
        $A.util.removeClass(modalBckdrop,className);
        $A.util.addClass(modalBckdrop,"slds-fade-in-open"); 
        
    },
    
    getLocationValuesList : function(component, event, helper) {
        var opts=[];
        var retrieveOptions = component.get("c.getLocationValuesList");
        retrieveOptions.setCallback(this,function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({"class": "optionClass",label: "-Select-",value: ""});
                    for(var i=0;i< allValues.length;i++){
                        opts.push({"class": "optionClass", label: allValues[i].Name, value: allValues[i].Id});
                    }
                    component.set("v.locationList", opts);
                }
            }      
        });
        $A.enqueueAction(retrieveOptions);
    },
    startSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        
        $A.util.removeClass(spinner, "slds-hide");
      
    },
    endSpinner : function(component, event, helper) {
         var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    //Fix_170853_13May2019_Soumyajit starts
    createdDateValidate: function(component, event, helper) {
        var startDate =  component.get("v.SelectCreatedStartDate");
		var endDate =  component.get("v.SelectCreatedEndDate");
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear() 
        if(dd < 10){
            dd = '0' + dd;
        }    
        if(mm < 10){
            mm = '0' + mm;
        }
 
     	var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        
        //Start Date Validation
        if(startDate=='' || startDate==undefined){
            component.set("v.SelectCreatedStartDate",todayFormattedDate);
            component.set("v.SelectCreatedEndDate",todayFormattedDate);
            startDate = todayFormattedDate;
            endDate = todayFormattedDate;
        }
        else if(startDate != '' && startDate > todayFormattedDate){
            component.set("v.startDateValidationError", true);
            component.set("v.startDateValidationErrorMsg", "Start Date cannot be future date");
        }
        else if(startDate.length < 8 || !(startDate.indexOf("-") >= 0)){
            component.set("v.startDateValidationError", true);
            component.set("v.startDateValidationErrorMsg", "Start Date format must be [DD.MM.YYYY] OR [DDMMYYYY]");
        }
        else{
            component.set("v.startDateValidationError" , false);
        }
        
        //End Date Validation
            if(endDate=='' || endDate==undefined){
                component.set("v.endDateValidationError", true);
                component.set("v.endDateValidationErrorMsg", "End Date is required");
            }
            else if(endDate != '' && startDate > endDate){
                component.set("v.endDateValidationError", true);
                component.set("v.endDateValidationErrorMsg", "End Date must be greater than Start Date");
            }
            else if(endDate.length < 8 || !(endDate.indexOf("-") >= 0)){
                component.set("v.startDateValidationError", true);
                component.set("v.startDateValidationErrorMsg", "End Date format must be [DD.MM.YYYY] OR [DDMMYYYY]");
            }
            else{
                component.set("v.endDateValidationError" , false);
            }
    },
    getCreatedByList : function(component, event, helper) {
        helper.startSpinner(component,event,helper);

        var action = component.get("c.getUserList");

        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS'){
                var usersLst=[];
                
                for (var key in a.getReturnValue()) 
                {
                    if (a.getReturnValue().hasOwnProperty(key)) {
                        usersLst.push({value: key, label: a.getReturnValue()[key]});
                    }
                };
        		component.set("v.userList",usersLst); 
            }
            else
                helper.displayToast(component,'Error','Something went wrong. Please try again later');
            
            helper.endSpinner(component,event,helper);
        });
        
        $A.enqueueAction(action);
        
        component.set("v.createdBy","Me");        
    },

    getAdvanceFiltersList : function(component, event, helper){
        var createdOnStartDate=component.get("v.SelectCreatedStartDate");
        var createdOnEndDate=component.get("v.SelectCreatedEndDate");
        var status= component.get("v.status");
        var createdby=component.get("v.createdBy");
        var oldCreatedOnStartDate=component.get("v.OldSelectCreatedStartDate");
        var oldCreatedOnEndDate=component.get("v.OldSelectCreatedEndDate");
        var oldSelectCreatedBy=component.get("v.OldSelectCreatedBy");
        var oldSelectStatus=component.get("v.OldSelectStatus");
        //270192_OLFDealCancel_08Jul2019_Soumyajit starts
        var InternetSales=component.get("v.InternetSales");
        var OldInternetSales=component.get("v.OldInternetSales");
        //270192_OLFDealCancel_08Jul2019_Soumyajit ends
        //START - Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : Updated logic to include PO Type in advance filter.
        var oldPoType = component.get("v.oldSelectedPoTypeAdv");
        var dayInterval = 5;
        if(oldCreatedOnStartDate != createdOnStartDate
           || oldCreatedOnEndDate != createdOnEndDate
           || createdby != oldSelectCreatedBy 
           || status != oldSelectStatus
           || OldInternetSales != InternetSales //270192_OLFDealCancel_08Jul2019_Soumyajit
          ){
           component.set("v.selectedPoTypeAdv", "ALL");
           component.set("v.SelectSoldTo", "ALL");
           component.set("v.DisableSelectSHTNo", true);
        }      
        var sht=component.get("v.SelectSHTNo");
        var soldTo=component.get("v.SelectSoldTo");
        var oldSelectSoldTo=component.get("v.OldSelectSoldTo");
		var poType = component.get("v.selectedPoTypeAdv");
        if(oldCreatedOnStartDate != createdOnStartDate
           || oldCreatedOnEndDate != createdOnEndDate
           || createdby != oldSelectCreatedBy 
           || status != oldSelectStatus 
           || oldSelectSoldTo != soldTo
           || OldInternetSales != InternetSales //270192_OLFDealCancel_08Jul2019_Soumyajit
          ){
            sht = "ALL";
            poType = "ALL";
        }
        if(oldPoType != poType){
            soldTo = "ALL";
            component.set("v.DisableSelectSHTNo", true);
         }
        helper.startSpinner(component,event,helper);

        var action = component.get("c.getCompletedSHTDealWithAdvanceFilterWrap");
        action.setParams({
            	"createdOnStartDate" : createdOnStartDate,
            	"createdOnEndDate" : createdOnEndDate,
            	"dayInterval" : dayInterval,
                "status" : status,
                "createdBy" :createdby,
            	"soldTo" : soldTo,
                "sht" : sht,
                "internetSales" : InternetSales, //270192_OLFDealCancel_08Jul2019_Soumyajit
                "poType" : poType 
            	}); 
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state === 'SUCCESS'){
                var chkDate = a.getReturnValue().DateValid;

                if(chkDate)
                {
                    component.set("v.SHTCompList",a.getReturnValue().SHTDisplayWrapList);
                    if(oldCreatedOnStartDate != createdOnStartDate 
                       || oldCreatedOnEndDate != createdOnEndDate
                       || createdby != oldSelectCreatedBy 
                       || status != oldSelectStatus
                       || OldInternetSales != InternetSales //270192_OLFDealCancel_08Jul2019_Soumyajit
                      ){
                        var soldToList = a.getReturnValue().SoldToList;
                        component.set("v.SelectSoldToList",soldToList);
                        component.set("v.SelectSoldTo","ALL");
                        component.set("v.SelectSHTNo","ALL");
                        component.set("v.DisableSelectSHTNo",true);
                        component.set("v.selectedPoTypeAdv", "ALL");
                        component.set("v.poTypeListAdv", a.getReturnValue().poTypeList);
                        setTimeout(function(){
                            component.find("SelectCreatedStartDateID").focus();
                            }, 100);
                    }                       
                    if(oldCreatedOnStartDate != createdOnStartDate 
                       || oldCreatedOnEndDate != createdOnEndDate
                       || createdby != oldSelectCreatedBy 
                       || status != oldSelectStatus 
                       || oldSelectSoldTo != soldTo
                       || OldInternetSales != InternetSales //270192_OLFDealCancel_08Jul2019_Soumyajit
                      ){
                        component.set("v.selectedPoTypeAdv", "ALL");
                        component.set("v.poTypeListAdv", a.getReturnValue().poTypeList);
                        if(soldTo === "ALL"){
                            component.set("v.SelectSHTNo","ALL");
                            component.set("v.DisableSelectSHTNo",true);
                        }
                        else{
                            var shtList = a.getReturnValue().SHTList;
                            if(shtList.length != 0){
                                component.set("v.SelectSHTNoList",shtList);
                        		component.set("v.DisableSelectSHTNo",false);
                                setTimeout(function(){
                                    component.find("SelectSHTNoID").focus();
                                    }, 100);
                            }
                            else{
                                component.set("v.SelectSHTNoList",shtList);
                        		component.set("v.DisableSelectSHTNo",true);
                            }     
                        }                      
                    }
                    else if(oldPoType != poType){
                        component.set("v.SelectSoldToList", a.getReturnValue().SoldToList);
                        component.set("v.SelectSoldTo","ALL");
                        component.set("v.SelectSHTNo","ALL");
                        component.set("v.DisableSelectSHTNo",true);
                        setTimeout(function(){
                            component.find("selectPoType").focus();
                            }, 100);
                       }
                }
                else{
                    helper.displayToast(component,'Error','Created Date range must be ' + dayInterval + ' days');
                    setTimeout(function(){
                    	component.find("SelectCreatedEndDateID").focus();
                        }, 100);
                }   
            }
            else
                helper.displayToast(component,'Error','Something went wrong. Please try again later');
			helper.endSpinner(component,event,helper);
        });
        $A.enqueueAction(action);
        
        //Reset Old Values
        component.set("v.OldSelectCreatedStartDate",createdOnStartDate);
        component.set("v.OldSelectCreatedEndDate",createdOnEndDate);
        component.set("v.OldSelectCreatedBy",createdby);
        component.set("v.OldSelectStatus",status);
        component.set("v.OldSelectSoldTo",soldTo);
        component.set("v.OldInternetSales",InternetSales); //270192_OLFDealCancel_08Jul2019_Soumyajit
        component.set("v.OldInternetSales", poType);
        //END - Rahul Dharma | Date - 01-Feb-2021 | PBI-702438 : Updated logic to include PO Type in advance filter.
    },

    /*Method Name   : showFilterBasedOnPoType
     *Date          : 01-Feb-2021
     *Developer     : Rahul Sharma
     *PBI           : 702438
     *Description   : Get Plant, MRC and MOT options based on PO Type.
     */
    showFilterBasedOnPoType : function(component, event, helper){
        var searchFilterWrap = component.get("v.searchFilterWrap");
        var poType = component.get("v.poType");
        if(poType){
            var mrcNoList = [];
            for(var mrcNo in searchFilterWrap.mrcNoVsPoTypeMap){
                if(searchFilterWrap.mrcNoVsPoTypeMap[mrcNo] == poType){
                    if(mrcNoList == null || mrcNoList.length == 0)
                    mrcNoList.push(mrcNo);
                    else if(!mrcNoList.includes(mrcNo))
                        mrcNoList.push(mrcNo); 
                }
            }
            if(mrcNoList && mrcNoList.length > 0){
                var plantSet = [];
                var mrcSet = [];
                var motSet = [];
                var mrcVsPlantMap = searchFilterWrap.mrcNoVsPlantMap;
                var mrcMap = searchFilterWrap.mrcNoVsMrcHeadMap;
                var mrcVsMotMap = searchFilterWrap.mrcNoVsMotMap;
                if(mrcVsPlantMap){
                    let plantList = [];
                    plantList.push({"class": "optionClass", label: "--Select--", value: ""});
                    for(var i = 0; i < mrcNoList.length; i++){
                        if(mrcVsPlantMap[mrcNoList[i]]){
                            plantList.push({"class": "optionClass",label: mrcVsPlantMap[mrcNoList[i]], value: mrcVsPlantMap[mrcNoList[i]]});
                        }
                    }
                    if(plantList.length > 0)
                        plantSet = helper.getUniqueListBy(plantList, 'label');
                }
                if(mrcMap){
                    let mrcList = [];
                    mrcList.push({"class": "optionClass", label: "--Select--", value: ""});
                    for(var i = 0; i < mrcNoList.length; i++){
                        if(mrcMap[mrcNoList[i]]){
                            mrcList.push({"class": "optionClass",label: mrcMap[mrcNoList[i]], value: mrcMap[mrcNoList[i]]});
                        }
                    }
                    if(mrcList.length > 0)
                        mrcSet = helper.getUniqueListBy(mrcList, 'label');
                }
                if(mrcVsMotMap){
                    let motList = [];
                    motList.push({"class": "optionClass", label: "--Select--", value: ""});
                    for(var i = 0; i < mrcNoList.length; i++){
                        if(mrcVsMotMap[mrcNoList[i]]){
                            motList.push({"class": "optionClass",label: mrcVsMotMap[mrcNoList[i]], value: mrcVsMotMap[mrcNoList[i]]});
                        }
                    }
                    if(motList.length > 0)
                        motSet = helper.getUniqueListBy(motList, 'label');
                }
            }
            component.set("v.plantLst", plantSet);
            component.set("v.mrcNoList", mrcSet);
            component.set("v.motLst", motSet);
        }
    },

    /*Method Name   : getUniqueListBy
     *Date          : 04-Feb-2021
     *Developer     : Rahul Sharma
     *PBI           : 702438
     *Description   : This method removes duplicate values from the array of object based on given key.
     */
    getUniqueListBy : function(arr, key) {
        return [...new Map(arr.map(item => [item[key], item])).values()]
    },

    /*Method Name   : getUniqueList
     *Date          : 04-Feb-2021
     *Developer     : Rahul Sharma
     *PBI           : 702438
     *Description   : This method removes duplicate values from the array of string..
     */
    getUniqueList : function(arr){
        return [...new Set(arr)]
    }
})