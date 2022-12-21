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
})