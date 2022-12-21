({
	getAllATPData : function(component, event, helper){ 
		var changeValue=component.get("v.value");        
        component.set("v.SalesChannel",changeValue);
        var intervalVal = component.get("v.selWindow");        
        var channelVal = component.get("v.SalesChannel");        
        var locVal = component.get("v.selLocation");         
        var action = component.get("c.getAllATPList");
        action.setParams({
         	 channel:channelVal,
             window:intervalVal,
             locType:locVal
        }); 
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log("getAllATPData==>"+state);
            console.log("data==>"+JSON.stringify(a.getReturnValue()));
            if(state === 'SUCCESS'){
                component.set("v.ATPWrapList",a.getReturnValue());
                
            }
        });
        $A.enqueueAction(action);
           
    },
	
})