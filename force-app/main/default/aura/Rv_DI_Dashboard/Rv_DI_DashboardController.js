({
	doInit : function(component, event, helper) {
        //Fix_469777_07Apr2020_Soumyajit starts
        try{
        var instance = 'https://' + window.location.hostname.split(".")[0] + '.lightning.force.com';
        console.log('pageURL=' + instance);
        component.set("v.pageURL",instance);
        }catch(err){console.log('Error while finding pageURL'+err.message);}
        //Fix_469777_07Apr2020_Soumyajit ends
        
        document.title='DI Dashboard';
        var getProdDiffList=true;
		helper.getDashboadrdData(component, event, helper,getProdDiffList);
	},
    calculateMaxDate: function(component,event,helper){
        var endate=component.get("v.contractEndDate");
        var todaysDate=component.get("v.todaysDate");
        var maxEndate=component.get("v.ContractLastPossibleDate");
        var startDate=component.get("v.contractStartDate");
        if(endate > maxEndate ){
            component.set("v.validDateSelected",false);
            helper.displayToast(component,'Error','End Date Should not be more than M+15.'); 
        }else if(endate < startDate){
             component.set("v.validDateSelected",false);
            helper.displayToast(component,'Error','End Date Should not be less than Start Date.'); 
        }
        else if(endate <todaysDate){
            component.set("v.validDateSelected",false);
            helper.displayToast(component,'Error','End Date Should not be less than today.');
        }else{
             component.set("v.validDateSelected",true);
        }
    },
    calculateDays : function(component,event,helper){
        var startDate=component.get("v.contractStartDate");
        var todaysDate=component.get("v.todaysDate");
        var endate=component.get("v.contractEndDate");
        if(endate <startDate){
             component.set("v.validDateSelected",false);
            //helper.displayToast(component,'Error','Start Date Should not be less than End Date.'); 
        }
        if(startDate < todaysDate){
            component.set("v.validDateSelected",false);
            helper.displayToast(component,'Error','Start Date Should not be less than Today.');
        }
        else{
           
            var action = component.get("c.getMaxContractEndDate");
            action.setParams({
                "dateInput" :component.get("v.contractStartDate")
            });
            action.setCallback(this, function(a) { 
                var state = a.getState();
                if(state === 'SUCCESS'){
                    console.log('dates==>'+JSON.stringify(a.getReturnValue()));
                    component.set("v.ContractLastPossibleDate",a.getReturnValue().maxEndDate); 
                    component.set("v.contractEndDate",a.getReturnValue().conEndDate);
                    component.set("v.validDateSelected",true); 
                }
            });
            $A.enqueueAction(action);
        }
    },   
    handleMessage : function(component, event, helper) {
        var priceChange= event.getParam("priceChanged");
        var getProdDiffList=false; 
        var validateDateChk = component.get("v.validDateSelected");
        console.log('priceChanged',priceChange);
        if(priceChange!= undefined){
            if(priceChange && validateDateChk){
                helper.getDashboadrdData(component, event, helper,getProdDiffList);
            }  
        }    
    },
    updateFutDiffTable: function(component, event, helper) {
        var prdDiffValUpdate=event.getParam("QuoteName");
        if(prdDiffValUpdate!= undefined ){
            if(prdDiffValUpdate.Column__c == 'Left1'){
                helper.updateLiveLst(component, event, helper,"v.ProdDiffLeftLiveLst1",prdDiffValUpdate);
            } 
            if(prdDiffValUpdate.Column__c == 'Left2'){
                helper.updateLiveLst(component, event, helper,"v.ProdDiffLeftLiveLst2",prdDiffValUpdate);
            }
            if(prdDiffValUpdate.Column__c == 'Right1'){
                 helper.updateLiveLst(component, event, helper,"v.ProdDiffRightLiveLst1",prdDiffValUpdate);
            }
            if(prdDiffValUpdate.Column__c == 'Right2'){
                helper.updateLiveLst(component, event, helper,"v.ProdDiffRightLiveLst2",prdDiffValUpdate);
            }
  			if(prdDiffValUpdate.Quote_Name__c == $A.get("$Label.c.RV_Mogas_Live_vs_8_00_o_clock_value")){
            	console.debug("AGO/IGO Delta: "+prdDiffValUpdate.Value__c);
               component.set("v.mogasLiveVs8am",prdDiffValUpdate.Value__c); 
            }
            if(prdDiffValUpdate.Quote_Name__c == $A.get("$Label.c.RV_AGO_IGO_Live_vs_8_00_o_clock_value")){ 
               component.set("v.agoIgoLiveVs8Am",prdDiffValUpdate.Value__c); 
               console.debug("MOGAS Delta: "+prdDiffValUpdate.Value__c);
            }
        }
    },
    /* added by Dharmendra for channel change radio button : PBI328 - Start */
    ChanelChange: function(component, event, helper) {
        console.log('Dev');
		var selected = event.getSource().get("v.text");
		component.set("v.selChannel",selected);
        console.log('Selected item: '+selected);
        var getProdDiffLst=false;
        helper.getDashboadrdData(component, event, helper,getProdDiffLst);
    },
     MOTChange: function(component, event, helper) {
        var getProdDiffLst=false;
        helper.getDashboadrdData(component, event, helper,getProdDiffLst);
    }, 
    /* added by Dharmendra for channel change radio button - End */
    onLocTypeChange: function(component, event ,helper) {
        var selected = event.getSource().get("v.text");        
        component.set("v.showLocType",selected);
        var getProdDiffLst=false;
        helper.getDashboadrdData(component, event, helper,getProdDiffLst);
    },
    onTaxSelChange: function(component, event ,helper) {
        var selected = event.getSource().get("v.text");        
        component.set("v.taxType",selected);
         var getProdDiffLst=false;
        helper.getDashboadrdData(component, event, helper,getProdDiffLst);
    }
})