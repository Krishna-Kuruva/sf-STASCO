({
    getInitialParamaterDetails: function(component, event, helper) {
        var cuUserId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getInitParameterDetailsMobile");
        action.setParams({"userId" : cuUserId});
        action.setCallback(this,function(response){            
            var rsp	  = response.getReturnValue();             
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.isValidProfile",rsp.validProfile);
                component.set("v.ExRateDetails",rsp.fxDatas);
                component.set("v.lastModifiedDate",rsp.lastJobRun);
                component.set("v.SpotSaleDetails",rsp.costingdata);
                component.set("v.MOPSDetails",rsp.mops);
                component.set("v.SpotSaleProdDetails",rsp.listProdName);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
		$A.enqueueAction(action);
    },
    getfxratesdata : function(component, event, helper) {
        var action = component.get("c.getFxData");
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.ExRateDetails",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
    getfxcostingdata : function(component, event, helper) {
        var action = component.get("c.getFxCostingData");
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                console.log('result'+result);
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.SpotSaleDetails",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
    getmopsdata : function(component, event, helper) {
        var action = component.get("c.getMOPSData");
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.MOPSDetails",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
    executejobhelper : function(component, event, helper) {
        var action = component.get("c.jobExecute");    
        action.setParams({"country":"Singapore Output"});
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    }, 
    
    getCurrentUser : function(component, event, helper){
        var cuUserId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getUserInfo");
        action.setParams({
            userId : cuUserId,
        });
        action.setCallback( this, function(response){
            if(response.getState() == 'SUCCESS') {               
                component.set('v.isValidProfile',response.getReturnValue());
            }
            else if(response.getState() == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
    executelastruntime : function(component, event, helper){
        var action = component.get("c.lastJobRun");        
        action.setCallback(this,function(a){
        	var state = a.getState();            
            if(state == "SUCCESS"){
                console.log('lastrun-'+a.getReturnValue());
                component.set("v.lastModifiedDate",a.getReturnValue());                
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
            component.set("v.isRecalculate",true);
        });
        $A.enqueueAction(action);
    },
})