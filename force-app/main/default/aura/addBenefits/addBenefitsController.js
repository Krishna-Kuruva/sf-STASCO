({
	doInit : function(component, event, helper) {
        var urlRecordTypeId = component.get('v.pageReference.state.recordTypeId');  
        helper.getL1PickList(component,event,helper,urlRecordTypeId); 
		helper.getImpactedPickListValues(component,event,helper,urlRecordTypeId);    
       	helper.getLoadedData(component,event,helper);  
        helper.createObjectData(component, event);
        var ePageURL = window.location.href;
        if(ePageURL.indexOf('edit')>-1){
        	component.set("v.readOnly",false);   
        }        
   },
    
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.benefitByYearList");
        AllRowsList.splice(index, 1);
        // set the List after remove selected row element  
        component.set("v.benefitByYearList", AllRowsList);
    },
    
    saveData:function(component,event,helper){
        var benefit=component.get('v.benefits');   
        //var depType=component.find('L1Type').get("v.value"); 
        var iUnit=component.find('ImpactedUnit').get("v.value");
        var urlRecordTypeId=null;
        var urlParentId=null;
        var urlRecordTypeId = component.get('v.pageReference.state.recordTypeId');       
        if (component.get('v.pageReference.state.additionalParams') != undefined)
			urlParentId = component.get('v.pageReference.state.additionalParams').match(new RegExp('_lkid=' + "(.*)" + '&'))[1];
        if(urlParentId==null){
            urlParentId=component.get('v.benefits.BE_Activities__r.Id');
        }
        if(component.get("v.recordId") !=undefined)
        var recordId=component.get("v.recordId");  
        
         if (helper.validateRequired(component, event)) {
            var saveAction = component.get("c.saveDataMethod");        
            saveAction.setParams({
                "benefitObj" :benefit ,
                "benefitChild":JSON.stringify(component.get('v.benefitByYearList')),
                "ParentId":urlParentId,
                "recordTypeId":urlRecordTypeId,
                "recordId":recordId
            });
            
            saveAction.setCallback(this, function(response) {
                var st=response.getState();
                if (response.getState() == "SUCCESS") {
                    helper.getLoadedData(component,event,helper);
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "DATA SAVED .",
                            "type": 'success'
                        });
                        toastEvent.fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": urlParentId,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                        //To referesh the related list view automatically
                    	window.location.reload();
                }
                else{
                	var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error Occurred while Saving Data",
                        "type": 'error'
                    });
             		toastEvent.fire();     
                }
        	
            })
             $A.enqueueAction(saveAction);
			component.set("v.readOnly",true);      
         }
        else{
             var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Enter Mandatory Field .",
                        "type": 'error'
                    });
             toastEvent.fire();   
        }           
    },
    
    edit:function(component,event,helper){
    	component.set("v.readOnly",false);    
    },
    
    navigatetoSObject:function(component, event, helper){ 
        var benefit=component.get('v.benefits');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "slideDevName": "related",
            "recordId": component.get('v.benefits.BE_Activities__r.Id')           
        });
        navEvt.fire();
    },  
    navigatetoListView:function(component, event, helper){
        var lstVwId=component.get("v.listViewId");
        if(lstVwId !=''){
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": lstVwId,
                "scope": "Initiatives__c"
            });
            navEvent.fire();
        }
    },
   
    IncludeLEVal:function(component, event, helper){
        var iBoolean     = component.get('v.benefits.Included_In_LE__c');
        component.set('v.benefits.Included_In_LE__c',iBoolean);
    }
})