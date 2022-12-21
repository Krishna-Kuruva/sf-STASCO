({
	getDashboadrdData : function(component, event, helper,getProdDiffList) {
        var validateMandatoryMissing = helper.validateMandatory(component, event, helper);
        if(validateMandatoryMissing){
            component.set("v.mandatoryOptionSel",false);
            component.set("v.validDateSelected",false);
            helper.displayToast(component,'Error','Please Select atleast one Channel and one MOT.');
        }else{
            console.log('mot==>', component.get("v.selMOT"));
             component.set("v.mandatoryOptionSel",true);
            component.set("v.validDateSelected",true);
            var action = component.get("c.getATPPriceforDashboard");
            action.setParams({
                "channel" : component.get("v.selChannel"),
                "MOT" : component.get("v.selMOT"),
                "locType" : component.get("v.showLocType"),
                "taxType" : component.get("v.taxType"),
                "getProdDiffList" :getProdDiffList
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                // alert('dashboard '+state);
                if(state === 'SUCCESS'){
                    var data=response.getReturnValue();
                    console.log('data==>',data);
                    if(data.dashBoardList != undefined && data.dashBoardList.length>0){
                         component.set("v.AllPlant",data.dashBoardList);
                    }else{         
                        component.set("v.AllPlant",[]);
                    }
                    console.log('AllPlant==>',data.dashBoardList); 					//added by Dharmendra
                    component.set("v.LastRefreshedTime",data.lastRefreshedAt);
                    if(getProdDiffList){
                        component.set("v.contractStartDate",data.contractStartDate);
                        component.set("v.todaysDate",data.contractStartDate);
                    	component.set("v.contractEndDate",data.contractEndDate);
                    	component.set("v.E5_Surcharge",data.E5_Surcharge);  //added by Dharmendra : PBI328
                    	component.set("v.S98_Surcharge",data.S98_Surcharge);  //added by Dharmendra : PBI328
                        console.log('data==>'+JSON.stringify(data.prdWrp));
                        if(data.prdWrp.leftProdDiffLst != undefined){
                             component.set("v.ProdDiffLeftLst",data.prdWrp.leftProdDiffLst);
                        }
                        if(data.prdWrp.rightProdDiffLst != undefined){
                            component.set("v.ProdDiffRightLst",data.prdWrp.rightProdDiffLst);
                        }
                        if(data.prdLiveWrp.leftProdDiffLiveLst1 != undefined){
                             component.set("v.ProdDiffLeftLiveLst1",data.prdLiveWrp.leftProdDiffLiveLst1);
                        }
                        if(data.prdLiveWrp.leftProdDiffLiveLst2 != undefined){
                             component.set("v.ProdDiffLeftLiveLst2",data.prdLiveWrp.leftProdDiffLiveLst2);
                        }
                        if(data.prdLiveWrp.rightProdDiffLiveLst1 != undefined){
                             component.set("v.ProdDiffRightLiveLst1",data.prdLiveWrp.rightProdDiffLiveLst1);
                        }
                        if(data.prdLiveWrp.rightProdDiffLiveLst2 != undefined){
                             component.set("v.ProdDiffRightLiveLst2",data.prdLiveWrp.rightProdDiffLiveLst2);
                        }
                        if(data.prdLiveWrp.agoIgoLiveVs8am != undefined){
                            component.set("v.agoIgoLiveVs8Am",data.prdLiveWrp.agoIgoLiveVs8am);
                        }
                        if(data.prdLiveWrp.mogasLiveVs8am != undefined){
                            component.set("v.mogasLiveVs8am",data.prdLiveWrp.mogasLiveVs8am);
                        }
                    }
                    console.log('prodDiffLst',data.prdWrp);
                }
            });
            $A.enqueueAction(action);
        }
		 
	},
    updateLiveLst : function(component,event,helper,allQuotes,prdDiffValUpdate){
         var quoteLst=component.get(allQuotes);
                for(var i=0;i<quoteLst.length;i++){
                    if(quoteLst[i].Display_Name__c == prdDiffValUpdate.Quote_Name__c){
                        quoteLst[i].Price__c = prdDiffValUpdate.Value__c;  
                    }
                }
                component.set(allQuotes,quoteLst); 
    },
    validateMandatory : function(component, event, helper) {
        var channel =component.get("v.selChannel");
        var mot =component.get("v.selMOT");
        var mandatMissing=false;
        if(channel.length == 0 || mot.length ==0){
            mandatMissing=true;
        }
        return mandatMissing;
    },
    displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },
})