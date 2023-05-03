({
	resendOrderToGsap : function(component, event, helper) {
		var OrderId = component.get("v.recordId");
        
        var action = component.get("c.reProcessFailedGsapOrder");
        action.setParams({"orderId": OrderId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.OrderResendMessage",response.getReturnValue());
                window.setTimeout(
                     $A.getCallback(function(response) {
                     $A.get("e.force:closeQuickAction").fire();
                     location.reload(true);
                    }),4000
                  );
                    
           }
        });
        
        $A.enqueueAction(action);
	}
})