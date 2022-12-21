({   
    getInitialParamaterDetails: function(component, event, helper) {
    	var cuUserId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getInitParameterDetails");
        action.setParams({'userId':cuUserId});
        action.setCallback(this,function(response){
            
            var state = response.getState();            
            if(state == "SUCCESS"){
                var resp = response.getReturnValue();
                component.set("v.isValidProfile",resp.validProfile);
                component.set("v.lastModifiedDate",resp.lastJobRun);
                component.set("v.MOPSDetails",resp.mops);
                component.set("v.ExRateDetails",resp.fxrates);
                component.set("v.peninsularcostData",resp.costMaps['costingMaps']);
                component.set("v.SabahcostData",resp.costMaps['costingSabahs']);
                component.set("v.SarawakcostData",resp.costMaps['costingDataSarawaks']);
                console.log('Sarawak'+JSON.stringify(resp.costMaps['costingDataSarawaks']));
                }  else if(state == "ERROR"){
                    console.log('Error in calling server side action');
                }
            });
        $A.enqueueAction(action);
	},
      getMOPSData : function(component, event, helper) {
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
    getfxratesdata : function(component, event, helper) {
        var action = component.get("c.getFxData");
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                console.log('result'+JSON.stringify(result));
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.ExRateDetails",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    getPeninsularcostingData : function(component, event, helper) {
        var action = component.get("c.getCostingDataPeninsular");
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.peninsularcostData",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    getSabahcostingData : function(component, event, helper) {
        var action = component.get("c.getCostingDataSabah");
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.SabahcostData",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    getSarawakcostingData : function(component, event, helper) {
        var action = component.get("c.getCostingDataSarawak");        
        action.setCallback(this,function(a){
        var state = a.getState();            
            if(state == "SUCCESS"){
                var result = a.getReturnValue();
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.SarawakcostData",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
    executejobhelper : function(component, event, helper) {
        var action = component.get("c.jobExecute");   
        action.setParams({"country":"Malaysia Output"});
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
                component.set("v.lastModifiedDate",a.getReturnValue());                
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }            
        });
        $A.enqueueAction(action);
    },
    getmiddaydata : function(component, event, helper){
        var action = component.get("c.fetchmiddaydata");        
        action.setCallback(this,function(a){
        	var state = a.getState();            
            if(state == "SUCCESS"){
                component.set("v.isMiddayoutput",a.getReturnValue());
				component.set("v.isMidDay",true);                
            } else if(state == "ERROR"){
                console.log('Error in calling server side action');
            }            
        });
        $A.enqueueAction(action);
    },
})