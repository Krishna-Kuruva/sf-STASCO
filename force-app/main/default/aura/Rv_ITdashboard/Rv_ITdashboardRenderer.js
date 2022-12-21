({
	unrender: function (component, helper) {
        this.superUnrender();
        
		var intervalID = component.get("v.RefreshIntervalId");
        console.log("intervalID closed: " +intervalID);
        if(intervalID != undefined)
        	window.clearInterval(intervalID);
    }
})