({
	handleClick : function(component, event, helper) {
        var iconStr = component.get("v.iconNameAtt");
        if(iconStr == "utility:chevronright"){
            component.set("v.iconNameAtt","utility:chevrondown");
            component.set("v.showLinks","true");
        }
        if(iconStr == "utility:chevrondown"){
            component.set("v.iconNameAtt","utility:chevronright");
        component.set("v.showLinks","false");}   
	},
})