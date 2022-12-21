({
	doInit : function(component, event, helper) {
		//document.title='Live ATP';
		var action = component.get("c.GetUrl");
       
        action.setCallback(this,function(response){
            var state = response.getState();
             //   alert('dashboard '+state);
                if(state === 'SUCCESS'){
                    var data=response.getReturnValue();
                    console.log('child data==>',data);
            data = data + 'LiveAtpPsp'
            component.set("v.LiveATPUrl",data);
            console.log('Base Url:'+ component.get("v.LiveATPUrl"));
        }else if(state === "ERROR"){
            alert('Unknown Error');
        }
             });
        $A.enqueueAction(action);

	}
})