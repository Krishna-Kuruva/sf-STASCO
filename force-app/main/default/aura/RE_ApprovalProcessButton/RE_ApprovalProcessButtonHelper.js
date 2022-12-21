({   
    processSelectedRecords : function(component,event,helper,processType){
        var action = component.get('c.processRecords');
        action.setParams({
            idValue : component.get("v.recordId"),
            comments : component.get("v.comments"),
            ProcessType : processType
        }); 
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.onSuccess",true);
                component.set("v.successMessage",'Record '+processType);
                component.set("v.displaySubmit",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Record "+processType+" successfully ",
                    message: " ",
                    type: "success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            }
            else if(state == "ERROR"){
                var errors = response.getError();                       
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
                component.set("v.onSuccess",false);
                component.set("v.displaySubmit",false);
                
            }
        });
        
        $A.enqueueAction(action);
    }
})