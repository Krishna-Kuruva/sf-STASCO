({
	doInit : function(component, event, helper) {
        document.title='Location Settings';        
        helper.getAllATPData(component, event, helper);
      
	},
    
    onGroup: function(component, event ,helper) {
        var selected = event.getSource().get("v.text");        
        component.set("v.selWindow",selected);
        helper.getAllATPData(component, event, helper);
    }, 
    onLocationSelect: function(component, event, helper) {        
		var interval; 
        var selectedType = event.getSource().get("v.text");        
        component.set("v.selLocation", selectedType);        
        if(selectedType == "All"){
         
            helper.getAllATPData(component, event, helper);
        
        }else if(selectedType == "My"){
        
            helper.getAllATPData(component, event, helper);          
         
        }else{
          
            helper.getAllATPData(component, event, helper);        	  
        }        
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
     showSpinner: function(component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function(component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
	},
    getSelectedLocations:function(component, event, helper) {
        var data = component.get("v.ATPWrapList");
        var action=component.get('c.saveLocationPref');
        var channel=component.get("v.SalesChannel");
        action.setParams({
            "dataList": JSON.stringify(data),
            "channel" : channel
        });
        action.setCallback(this, function(response){
            var state = response.getState();        
            if(state === "SUCCESS"){            	
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "message": "Location Preferences are Saved Successfully."
                });
                toastEvent.fire(); 
            }
        });
        $A.enqueueAction(action);
    }
})