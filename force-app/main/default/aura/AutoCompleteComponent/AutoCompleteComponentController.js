({
	chooseItem : function(component, event, helper) {
		var record = component.get('v.record');
        console.log("recordEvent"+record)
		var chooseEvent = component.getEvent("choose");
        chooseEvent.setParams({"record": record});
        chooseEvent.fire();
    } 
})