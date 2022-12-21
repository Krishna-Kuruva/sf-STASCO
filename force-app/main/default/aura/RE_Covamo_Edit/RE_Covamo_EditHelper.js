({
	fetchCovamoQueue : function(component, event, helper) {
	/*var action = component.get("c.getCovHeaderRecordTypeName");
		console.log("check 1",component.get("v.recordId"));
        var recId = component.get("v.recordId"); 
        action.setParams({
            recordID: recId
        });
        action.setCallback(this, function(response) {
   			console.log("check 2");         
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log("check 3");
                var covHeader = response.getReturnValue();
                console.log("covHeader",covHeader);
                component.set("v.showCovamoForm",covHeader);
                if(component.get("v.showCovamoForm") == false){
                    helper.showToast("Error","error","Cannot Edit Submitted Covamo");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                }
            }
            else {
   
                alert('Error in getting data');
            }
        });

        $A.enqueueAction(action); */
        console.log("check 4 inside helper");
        var action = component.get("c.getCovamoHeaderQueueUsers");
    	 action.setCallback(this, function(response) {
              var state = response.getState();
             if(state === 'SUCCESS') {
                 console.log("check 5",state);
                 var userInQueue = response.getReturnValue();
                 console.log("userInQueue",userInQueue);
                component.set("v.checkUserInQueue",userInQueue);
                 if(component.get("v.checkUserInQueue") == true){
                     component.set("v.showCovamoForm",true);
                 }else{
                      helper.showToast("Error","Error","This User cannot Edit the Covamo.");
                     var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                 }
             }else {
   
                alert('Error in getting data from Queue');
            }
         });
        $A.enqueueAction(action);
	},
    showToast : function(title,variant,message){
        var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": title,
                        "variant": variant,
                        "message": message
                    });
                    toastEvent.fire();
    }
})