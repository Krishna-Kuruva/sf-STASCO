({  
    doInit : function(component, event, helper) {
        var action = component.get('c.checkRecordInApprovalProcess');
        action.setParams({
            idValue : component.get("v.recordId")
        }); 
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('data--'+JSON.stringify(response.getReturnValue()))
            if (state == "SUCCESS") {
                var datafromServer=response.getReturnValue();
                component.set("v.checkApprovalReocrd",(datafromServer.isRecordInApprovalPro === "true" ? true : false));
                component.set("v.AppRejButton",(datafromServer.ApproveRejectButton  === "true" ? true : false));                
            }
            else if(state == "ERROR"){
                var errors = response.getError();                       
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    handleApprove : function(component, event, helper){
        helper.processSelectedRecords(component,event,helper,'Approve');
    },
    handleReject : function(component, event, helper){
        helper.processSelectedRecords(component,event,helper,'Reject');
    }
})