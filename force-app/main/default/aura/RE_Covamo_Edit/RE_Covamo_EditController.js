({
	
    doInit : function(component, event, helper) {
  /*     var action = component.get("c.getCovamoHeaderQueueUsers");
    	 action.setCallback(this, function(response) { 
             console.log("check 2 in do init");         
            var state = response.getState();
             if(state === 'SUCCESS') {
                 console.log("check 3 in do init");
                var userInQueue = response.getReturnValue();
                 console.log("userInQueue",userInQueue);
                component.set("v.checkUserInQueue",userInQueue);
                 if(component.get("v.checkUserInQueue") == true){
                     helper.fetchCovamoStatus(component, event, helper);
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

        $A.enqueueAction(action); */
        var action = component.get("c.getCovHeaderRecordTypeName");
        console.log("check 1",component.get("v.recordId"));
        var recId = component.get("v.recordId");
        action.setParams({
            recordID: recId
        });
        action.setCallback(this, function(response) {
            console.log("inside callback 1");
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log("check 2",state);
                var covHeader = response.getReturnValue();
                component.set("v.status",covHeader);
                console.log("check 3 covHeader",covHeader,component.get("v.status"));
                if(component.get("v.status") == true){
                   // helper.fetchCovamoQueue(component, event, helper);
                   component.set("v.showCovamoForm",true);
                }else{
                    helper.fetchCovamoQueue(component, event, helper);
                /*    helper.showToast("Error","Error","Cannot Edit Submitted Covamo");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "Detail"
                    });
                    navEvt.fire(); */
                }
            }else {
   
                alert('Error in getting status data');
            }
        });
        $A.enqueueAction(action);
        } 
})